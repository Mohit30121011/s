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

@WebServlet("/adjust-stock")
public class StockAdjustmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        try {
            int stockId = Integer.parseInt(request.getParameter("stockId"));
            double adjustmentQty = Double.parseDouble(request.getParameter("adjustmentQuantity"));
            String reason = request.getParameter("reason"); // Damage, Expiry, Lost

            if (adjustmentQty <= 0) {
                throw new Exception("Adjustment quantity must be greater than 0");
            }

            try (Connection conn = DBConnectionManager.getConnection()) {
                conn.setAutoCommit(false);
                
                int productId = -1;
                double currentQty = 0;
                double unitCost = 0;
                
                // 1. Get current stock and verify ownership
                String checkSql = "SELECT s.product_id, s.quantity_on_hand, p.unit_cost "
                                + "FROM stock s JOIN products p ON s.product_id = p.product_id "
                                + "WHERE s.stock_id = ? AND s.company_id = ?";
                try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                    psCheck.setInt(1, stockId);
                    psCheck.setInt(2, user.getCompanyId());
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next()) {
                            productId = rs.getInt("product_id");
                            currentQty = rs.getDouble("quantity_on_hand");
                            unitCost = rs.getDouble("unit_cost");
                        } else {
                            throw new Exception("Stock record not found or access denied.");
                        }
                    }
                }

                if (adjustmentQty > currentQty) {
                    throw new Exception("Cannot remove more than the current quantity on hand.");
                }

                // 2. Update stock table
                String updateSql = "UPDATE stock SET quantity_on_hand = quantity_on_hand - ?, last_updated = CURRENT_TIMESTAMP WHERE stock_id = ?";
                try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                    psUpdate.setDouble(1, adjustmentQty);
                    psUpdate.setInt(2, stockId);
                    psUpdate.executeUpdate();
                }

                // 3. Insert into inventory_ledger (FR4.6: 'ADJUSTMENT' or 'OUT')
                String insertLedger = "INSERT INTO inventory_ledger (product_id, transaction_type, quantity, unit_cost_at_txn, reference_type) VALUES (?, 'OUT', ?, ?, ?)";
                try (PreparedStatement psInsert = conn.prepareStatement(insertLedger)) {
                    psInsert.setInt(1, productId);
                    psInsert.setDouble(2, adjustmentQty);
                    psInsert.setDouble(3, unitCost);
                    psInsert.setString(4, "Write-off: " + reason);
                    psInsert.executeUpdate();
                }

                conn.commit();
                request.getSession().setAttribute("successMessage", "Stock successfully written off (" + reason + "). Removed " + adjustmentQty + " units.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Error adjusting stock: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/upload-stock");
    }
}
