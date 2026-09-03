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

@WebServlet("/manual-stock")
public class ManualStockServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        int companyId = user.getCompanyId();
        if (companyId == 0) {
            request.getSession().setAttribute("errorMessage", "Super Admins cannot upload stock manually.");
            response.sendRedirect(request.getContextPath() + "/upload-stock");
            return;
        }

        try {
            int productId = Integer.parseInt(request.getParameter("productId"));
            double quantity = Double.parseDouble(request.getParameter("quantity"));
            String warehouse = request.getParameter("warehouseLocation");
            String batchNo = request.getParameter("batchNo");

            if (quantity <= 0) {
                throw new Exception("Quantity must be greater than 0");
            }

            try (Connection conn = DBConnectionManager.getConnection()) {
                conn.setAutoCommit(false);
                
                // Get unit cost for ledger
                double unitCost = 0;
                try (PreparedStatement ps = conn.prepareStatement("SELECT unit_cost FROM products WHERE product_id = ?")) {
                    ps.setInt(1, productId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) unitCost = rs.getDouble("unit_cost");
                    }
                }

                // 2. Stock Logic
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
                    String insertStock = "INSERT INTO stock (company_id, product_id, warehouse_location, quantity_on_hand, batch_no) VALUES (?, ?, ?, ?, ?)";
                    try (PreparedStatement psInsertStock = conn.prepareStatement(insertStock)) {
                        psInsertStock.setInt(1, companyId);
                        psInsertStock.setInt(2, productId);
                        psInsertStock.setString(3, warehouse);
                        psInsertStock.setDouble(4, quantity);
                        psInsertStock.setString(5, batchNo);
                        psInsertStock.executeUpdate();
                    }
                } else {
                    String updateStock = "UPDATE stock SET quantity_on_hand = quantity_on_hand + ?, warehouse_location = ?, batch_no = ?, last_updated = CURRENT_TIMESTAMP WHERE stock_id = ?";
                    try (PreparedStatement psUpdateStock = conn.prepareStatement(updateStock)) {
                        psUpdateStock.setDouble(1, quantity);
                        psUpdateStock.setString(2, warehouse);
                        psUpdateStock.setString(3, batchNo);
                        psUpdateStock.setInt(4, stockId);
                        psUpdateStock.executeUpdate();
                    }
                }
                
                // 3. Inventory Ledger (FR4.5)
                String insertLedger = "INSERT INTO inventory_ledger (product_id, transaction_type, quantity, unit_cost_at_txn, reference_type) VALUES (?, 'IN', ?, ?, 'Manual Entry')";
                try (PreparedStatement psInsertLedger = conn.prepareStatement(insertLedger)) {
                    psInsertLedger.setInt(1, productId);
                    psInsertLedger.setDouble(2, quantity);
                    psInsertLedger.setDouble(3, unitCost);
                    psInsertLedger.executeUpdate();
                }
                
                conn.commit();
                request.getSession().setAttribute("successMessage", "Manual stock entry added successfully for Product ID: " + productId);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Error adding manual stock: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/upload-stock");
    }
}
