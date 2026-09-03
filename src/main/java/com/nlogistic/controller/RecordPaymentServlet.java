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

@WebServlet("/record-payment")
public class RecordPaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 4) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        int invoiceId = Integer.parseInt(request.getParameter("invoiceId"));
        double amountPaid = Double.parseDouble(request.getParameter("amountPaid"));
        String paymentMode = request.getParameter("paymentMode");
        String transactionRef = request.getParameter("transactionRef");

        try (Connection conn = DBConnectionManager.getConnection()) {
            conn.setAutoCommit(false);
            
            // 1. Record the Payment
            String sqlPay = "INSERT INTO payments (invoice_id, payment_date, amount_paid, payment_mode, transaction_ref) VALUES (?, CURDATE(), ?, ?, ?)";
            try (PreparedStatement psPay = conn.prepareStatement(sqlPay)) {
                psPay.setInt(1, invoiceId);
                psPay.setDouble(2, amountPaid);
                psPay.setString(3, paymentMode);
                psPay.setString(4, transactionRef);
                psPay.executeUpdate();
            }
            
            // 2. Update Invoice Status
            // First get current totals
            double totalAmount = 0;
            double currentPaid = 0;
            String getInv = "SELECT total_amount, paid_amount FROM billing_invoices WHERE invoice_id = ? FOR UPDATE";
            try (PreparedStatement psGet = conn.prepareStatement(getInv)) {
                psGet.setInt(1, invoiceId);
                try (ResultSet rs = psGet.executeQuery()) {
                    if (rs.next()) {
                        totalAmount = rs.getDouble("total_amount");
                        currentPaid = rs.getDouble("paid_amount");
                    }
                }
            }
            
            double newPaid = currentPaid + amountPaid;
            String newStatus = (newPaid >= totalAmount) ? "Paid" : "Partial";
            
            String updateInv = "UPDATE billing_invoices SET paid_amount = ?, payment_status = ? WHERE invoice_id = ?";
            try (PreparedStatement psUpdate = conn.prepareStatement(updateInv)) {
                psUpdate.setDouble(1, newPaid);
                psUpdate.setString(2, newStatus);
                psUpdate.setInt(3, invoiceId);
                psUpdate.executeUpdate();
            }
            
            conn.commit();
            request.getSession().setAttribute("successMessage", "Payment of ₹" + amountPaid + " recorded for INV-" + invoiceId);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Error recording payment: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/invoices");
    }
}
