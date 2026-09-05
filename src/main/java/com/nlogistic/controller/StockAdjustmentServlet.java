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

            // FR4.6: reason is MANDATORY — enforce server-side, not just via the
            // client-side <select required> which can be bypassed with a raw POST.
            if (reason == null || reason.trim().isEmpty()) {
                throw new Exception("A reason is mandatory for stock write-off/adjustment (FR4.6).");
            }
            reason = reason.trim();

            try (Connection conn = DBConnectionManager.getConnection()) {
                conn.setAutoCommit(false);
                
                int productId = -1;
                double currentQty = 0;
                double unitCost = 0;
                
                // 1. Get current stock and verify ownership
                // Super Admin (roleId 1) has full system access (SRS 2.2) and may adjust stock across all companies
                boolean isSuperAdmin = (user.getRoleId() == 1);
                String checkSql;
                if (isSuperAdmin) {
                    checkSql = "SELECT s.product_id, s.quantity_on_hand, p.unit_cost "
                             + "FROM stock s JOIN products p ON s.product_id = p.product_id "
                             + "WHERE s.stock_id = ?";
                } else {
                    checkSql = "SELECT s.product_id, s.quantity_on_hand, p.unit_cost "
                             + "FROM stock s JOIN products p ON s.product_id = p.product_id "
                             + "WHERE s.stock_id = ? AND s.company_id = ?";
                }
                try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                    psCheck.setInt(1, stockId);
                    if (!isSuperAdmin) {
                        psCheck.setInt(2, user.getCompanyId());
                    }
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
                String insertLedger = "INSERT INTO inventory_ledger (product_id, transaction_type, quantity, unit_cost_at_txn, reference_type, reference_id) VALUES (?, 'OUT', ?, ?, ?, ?)";
                try (PreparedStatement psInsert = conn.prepareStatement(insertLedger)) {
                    psInsert.setInt(1, productId);
                    psInsert.setDouble(2, adjustmentQty);
                    psInsert.setDouble(3, unitCost);
                    psInsert.setString(4, "Write-off: " + reason);
                    psInsert.setInt(5, stockId); // FR4.5: traceable back to the stock row
                    psInsert.executeUpdate();
                }

                // 4. FR4.6 / Disconnect 5: attribute the monetary loss so warehouse
                //    write-offs are not invisible to loss reporting.
                //
                //    A warehouse write-off belongs to no shipment, so it is recorded as
                //    a standalone P&L row (shipment_id NULL) with zero revenue and the
                //    write-off value as cost, tagged with the mapped loss reason so it
                //    shows up in the same Pareto breakdown as shipment losses.
                double lossAmount = Math.round(adjustmentQty * unitCost * 100.0) / 100.0;
                int reasonId = mapWriteOffReason(reason);

                int plId = -1;
                try (PreparedStatement psPl = conn.prepareStatement(
                        "INSERT INTO profit_loss (shipment_id, revenue_amount, total_cost_amount, profit_loss_amount, record_date) "
                      + "VALUES (NULL, 0.00, ?, ?, CURDATE())", java.sql.Statement.RETURN_GENERATED_KEYS)) {
                    psPl.setDouble(1, lossAmount);
                    psPl.setDouble(2, -lossAmount);
                    psPl.executeUpdate();
                    try (java.sql.ResultSet gk = psPl.getGeneratedKeys()) {
                        if (gk.next()) plId = gk.getInt(1);
                    }
                }

                if (plId > 0) {
                    try (PreparedStatement psMap = conn.prepareStatement(
                            "INSERT INTO profit_loss_reason_map (pl_id, reason_id, remark) VALUES (?, ?, ?)")) {
                        psMap.setInt(1, plId);
                        psMap.setInt(2, reasonId);
                        psMap.setString(3, String.format(
                                "Warehouse write-off: %.2f unit(s) @ %.2f = %.2f - %s",
                                adjustmentQty, unitCost, lossAmount, reason));
                        psMap.executeUpdate();
                    }
                }

                conn.commit();
                request.getSession().setAttribute("successMessage", String.format(
                        "Stock written off (%s). Removed %.2f unit(s); loss of %.2f posted to Profit & Loss.",
                        reason, adjustmentQty, lossAmount));
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Error adjusting stock: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/upload-stock");
    }

    /**
     * Maps a free-text write-off reason onto the standard loss_reasons catalogue
     * (FR2.7) so warehouse losses appear in the same Pareto breakdown as shipment
     * losses. Anything unrecognised is attributed to Damaged Product.
     */
    private static int mapWriteOffReason(String reason) {
        String r = (reason == null) ? "" : reason.toLowerCase();
        if (r.contains("expire") || r.contains("expiry")) return 8; // Damaged Product
        if (r.contains("lost") || r.contains("theft") || r.contains("missing")) return 8;
        if (r.contains("weather") || r.contains("flood") || r.contains("water")) return 2; // Weather
        if (r.contains("delay")) return 3;
        return 8; // Damaged Product
    }
}
