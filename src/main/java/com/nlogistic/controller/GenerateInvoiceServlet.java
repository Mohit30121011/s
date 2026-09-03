package com.nlogistic.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.model.User;
import com.nlogistic.util.DBConnectionManager;

@WebServlet("/generate-invoice")
public class GenerateInvoiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 4) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        String shipmentData = request.getParameter("shipmentData");
        String dueDateStr = request.getParameter("dueDate");
        
        if (shipmentData == null || dueDateStr == null) {
            response.sendRedirect(request.getContextPath() + "/invoices");
            return;
        }

        String[] parts = shipmentData.split("\\|");
        int shipmentId = Integer.parseInt(parts[0]);
        int customerId = Integer.parseInt(parts[1]);
        double cost = Double.parseDouble(parts[2]);
        
        // Simple 18% Tax logic for logistics
        double taxAmount = cost * 0.18;
        double totalAmount = cost + taxAmount;

        try (Connection conn = DBConnectionManager.getConnection()) {
            conn.setAutoCommit(false);
            
            // 1. Insert Invoice
            String sql = "INSERT INTO billing_invoices (customer_id, shipment_id, invoice_date, due_date, subtotal_amount, tax_amount, total_amount, payment_status) "
                       + "VALUES (?, ?, CURDATE(), ?, ?, ?, ?, 'Unpaid')";
            
            int invoiceId = -1;
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, customerId);
                ps.setInt(2, shipmentId);
                ps.setString(3, dueDateStr);
                ps.setDouble(4, cost);
                ps.setDouble(5, taxAmount);
                ps.setDouble(6, totalAmount);
                ps.executeUpdate();
                
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        invoiceId = rs.getInt(1);
                    }
                }
            }
            
            // 2. Insert Line Item
            if (invoiceId != -1) {
                String sqlLine = "INSERT INTO invoice_line_items (invoice_id, description, quantity, unit_price, line_total) "
                               + "VALUES (?, 'Freight Shipping Cost', 1, ?, ?)";
                try (PreparedStatement psLine = conn.prepareStatement(sqlLine)) {
                    psLine.setInt(1, invoiceId);
                    psLine.setDouble(2, cost);
                    psLine.setDouble(3, cost);
                    psLine.executeUpdate();
                }
            }
            
            conn.commit();
            request.getSession().setAttribute("successMessage", "Invoice INV-" + invoiceId + " successfully generated.");
            
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Error generating invoice: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/invoices");
    }
}
