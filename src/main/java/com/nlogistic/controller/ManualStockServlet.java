package com.nlogistic.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.model.User;
import com.nlogistic.util.DBConnectionManager;

/**
 * ManualStockServlet — POST /manual-stock
 *
 * Handles manual stock entry per SRS Module 4:
 *   FR4.1  – manual entry pathway
 *   FR4.2  – all required fields captured (product name, category, HSN, UOM,
 *            quantity, unit cost, unit selling price, warehouse, optional
 *            batch/lot number and expiry date)
 *   FR4.3  – quantity >= 0, unit cost >= 0, unit price >= 0 (server-side)
 *   FR4.5  – inventory_ledger entry written on every new/updated stock
 */
@WebServlet("/manual-stock")
public class ManualStockServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        // Super Admin has no company of their own — they must pick which company this
        // entry is for (hidden "companyId" field on the form, from the page's company picker).
        int companyId = user.getCompanyId();
        if (user.getRoleId() == 1) {
            String companyParam = request.getParameter("companyId");
            if (companyParam == null || companyParam.trim().isEmpty()) {
                request.getSession().setAttribute("errorMessage", "Please select which company this stock entry is for.");
                request.getSession().setAttribute("selectedCompanyId", companyId);
        response.sendRedirect(request.getContextPath() + "/upload-stock?companyId=" + companyId + "&tab=overview");
                return;
            }
            try {
                companyId = Integer.parseInt(companyParam.trim());
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("errorMessage", "Invalid company selection.");
                request.getSession().setAttribute("selectedCompanyId", companyId);
        response.sendRedirect(request.getContextPath() + "/upload-stock?companyId=" + companyId + "&tab=overview");
                return;
            }
        } else if (companyId == 0) {
            request.getSession().setAttribute("errorMessage", "You must belong to a company to upload stock manually.");
            request.getSession().setAttribute("selectedCompanyId", companyId);
        response.sendRedirect(request.getContextPath() + "/upload-stock?companyId=" + companyId + "&tab=overview");
            return;
        }

        try {
            // ── FR4.2: Read all required stock fields ────────────────────────
            String productName = request.getParameter("productName");
            String category    = request.getParameter("category");
            String hsnCode     = request.getParameter("hsnCode");
            String uom         = request.getParameter("unitOfMeasure");
            String warehouse   = request.getParameter("warehouseLocation");
            String batchNo     = request.getParameter("batchNo");
            String expiryStr   = request.getParameter("expiryDate");

            double quantity  = Double.parseDouble(request.getParameter("quantity"));
            double unitCost  = Double.parseDouble(request.getParameter("unitCost"));
            double unitPrice = Double.parseDouble(request.getParameter("unitPrice"));

            // ── FR4.3: Server-side validation ────────────────────────────────
            if (productName == null || productName.trim().isEmpty()) {
                throw new IllegalArgumentException("Product name is required.");
            }
            if (category == null || category.trim().isEmpty()) {
                throw new IllegalArgumentException("Category is required.");
            }
            if (hsnCode == null || hsnCode.trim().isEmpty()) {
                throw new IllegalArgumentException("HSN code is required.");
            }
            if (uom == null || uom.trim().isEmpty()) {
                throw new IllegalArgumentException("Unit of measure is required.");
            }
            if (warehouse == null || warehouse.trim().isEmpty()) {
                throw new IllegalArgumentException("Warehouse location is required.");
            }
            if (quantity < 0) {
                throw new IllegalArgumentException("Quantity must be ≥ 0 (FR4.3).");
            }
            if (unitCost < 0) {
                throw new IllegalArgumentException("Unit cost must be ≥ 0 (FR4.3).");
            }
            if (unitPrice < 0) {
                throw new IllegalArgumentException("Unit selling price must be ≥ 0 (FR4.3).");
            }

            java.sql.Date expiryDate = null;
            if (expiryStr != null && !expiryStr.trim().isEmpty()) {
                try {
                    expiryDate = java.sql.Date.valueOf(expiryStr.trim());
                } catch (IllegalArgumentException ex) {
                    // non-fatal: skip invalid date
                }
            }

            try (Connection conn = DBConnectionManager.getConnection()) {
                conn.setAutoCommit(false);

                // ── Step 1: Upsert product (insert if new, update if exists) ──
                int productId = -1;
                String checkProduct = "SELECT product_id FROM products WHERE product_name = ?";
                try (PreparedStatement ps = conn.prepareStatement(checkProduct)) {
                    ps.setString(1, productName.trim());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) productId = rs.getInt("product_id");
                    }
                }

                if (productId == -1) {
                    String insertProd = "INSERT INTO products "
                            + "(product_name, category, hsn_code, unit_of_measure, unit_cost, unit_price) "
                            + "VALUES (?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement psIns = conn.prepareStatement(insertProd,
                            java.sql.Statement.RETURN_GENERATED_KEYS)) {
                        psIns.setString(1, productName.trim());
                        psIns.setString(2, category.trim());
                        psIns.setString(3, hsnCode.trim());
                        psIns.setString(4, uom);
                        psIns.setDouble(5, unitCost);
                        psIns.setDouble(6, unitPrice);
                        psIns.executeUpdate();
                        try (ResultSet gk = psIns.getGeneratedKeys()) {
                            if (gk.next()) productId = gk.getInt(1);
                        }
                    }
                } else {
                    // Existing product — refresh cost/price to reflect the latest values
                    String updateProd = "UPDATE products SET unit_cost = ?, unit_price = ? WHERE product_id = ?";
                    try (PreparedStatement psUpd = conn.prepareStatement(updateProd)) {
                        psUpd.setDouble(1, unitCost);
                        psUpd.setDouble(2, unitPrice);
                        psUpd.setInt(3, productId);
                        psUpd.executeUpdate();
                    }
                }

                // ── Step 2: Upsert stock record ────────────────────────────────
                int stockId = -1;
                String checkStock = "SELECT stock_id FROM stock WHERE company_id = ? AND product_id = ?";
                try (PreparedStatement psCheckStock = conn.prepareStatement(checkStock)) {
                    psCheckStock.setInt(1, companyId);
                    psCheckStock.setInt(2, productId);
                    try (ResultSet rs = psCheckStock.executeQuery()) {
                        if (rs.next()) stockId = rs.getInt("stock_id");
                    }
                }

                if (stockId == -1) {
                    String insertStock = "INSERT INTO stock "
                            + "(company_id, product_id, warehouse_location, quantity_on_hand, batch_no, expiry_date) "
                            + "VALUES (?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement psInsertStock = conn.prepareStatement(insertStock)) {
                        psInsertStock.setInt(1, companyId);
                        psInsertStock.setInt(2, productId);
                        psInsertStock.setString(3, warehouse);
                        psInsertStock.setDouble(4, quantity);
                        psInsertStock.setString(5, batchNo != null && !batchNo.trim().isEmpty() ? batchNo.trim() : null);
                        psInsertStock.setDate(6, expiryDate);
                        psInsertStock.executeUpdate();
                    }
                } else {
                    String updateStock = "UPDATE stock SET quantity_on_hand = quantity_on_hand + ?, "
                            + "warehouse_location = ?, batch_no = ?, expiry_date = ?, "
                            + "last_updated = CURRENT_TIMESTAMP WHERE stock_id = ?";
                    try (PreparedStatement psUpdateStock = conn.prepareStatement(updateStock)) {
                        psUpdateStock.setDouble(1, quantity);
                        psUpdateStock.setString(2, warehouse);
                        psUpdateStock.setString(3, batchNo != null && !batchNo.trim().isEmpty() ? batchNo.trim() : null);
                        psUpdateStock.setDate(4, expiryDate);
                        psUpdateStock.setInt(5, stockId);
                        psUpdateStock.executeUpdate();
                    }
                }

                // ── Step 3: Inventory Ledger entry (FR4.5) ────────────────────
                String insertLedger = "INSERT INTO inventory_ledger (product_id, transaction_type, quantity, unit_cost_at_txn, reference_type) VALUES (?, 'IN', ?, ?, 'Manual Entry')";
                try (PreparedStatement psInsertLedger = conn.prepareStatement(insertLedger)) {
                    psInsertLedger.setInt(1, productId);
                    psInsertLedger.setDouble(2, quantity);
                    psInsertLedger.setDouble(3, unitCost);
                    psInsertLedger.executeUpdate();
                }

                conn.commit();
                request.getSession().setAttribute("successMessage",
                        String.format("Manual stock entry added successfully for '%s' (Qty: %.2f %s, Warehouse: %s).",
                                productName.trim(), quantity, uom, warehouse));
            }
        } catch (IllegalArgumentException e) {
            request.getSession().setAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Error adding manual stock: " + e.getMessage());
        }

        request.getSession().setAttribute("selectedCompanyId", companyId);
        response.sendRedirect(request.getContextPath() + "/upload-stock?companyId=" + companyId + "&tab=overview");
    }
}
