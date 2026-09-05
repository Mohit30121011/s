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
        if (user == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }
        // FR5.7: Customers may pay their OWN invoices online. Operations staff
        // (Role 3) have no billing authority and are refused outright.
        int payRole = user.getRoleId();
        if (payRole == com.nlogistic.util.RbacContext.OPERATIONS) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access Denied: payment recording is a Finance function.");
            return;
        }

        int invoiceId = Integer.parseInt(request.getParameter("invoiceId"));

        // Ownership / tenant check before touching the accounting ledger.
        if (!new com.nlogistic.dao.BillingDAO().canAccessInvoice(invoiceId, payRole,
                com.nlogistic.util.RbacContext.companyId(request),
                com.nlogistic.util.RbacContext.customerId(request))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access Denied: this invoice does not belong to your account.");
            return;
        }
        double amountPaid = Double.parseDouble(request.getParameter("amountPaid"));
        String paymentMode = request.getParameter("paymentMode");
        String transactionRef = request.getParameter("transactionRef");

        java.sql.Date paymentDate = new java.sql.Date(System.currentTimeMillis());
        String payDateStr = request.getParameter("paymentDate");
        if (payDateStr != null && !payDateStr.trim().isEmpty()) {
            try { paymentDate = java.sql.Date.valueOf(payDateStr.trim()); } catch (Exception ignored) {}
        }

        if (amountPaid <= 0) {
            request.getSession().setAttribute("errorMessage", "Payment amount must be greater than zero.");
            response.sendRedirect(request.getContextPath() + "/invoices");
            return;
        }

        // Gap 7: single payment implementation. BillingDAO.recordPayment recomputes
        // paid_amount from the payments table and derives the status consistently,
        // so /record-payment and /billing/pay can no longer drift apart.
        boolean ok = new com.nlogistic.dao.BillingDAO()
                .recordPayment(invoiceId, amountPaid, paymentMode, transactionRef, paymentDate);

        if (ok) {
            request.getSession().setAttribute("successMessage",
                    String.format("Payment of %.2f recorded for INV-%d via %s.", amountPaid, invoiceId, paymentMode));
        } else {
            request.getSession().setAttribute("errorMessage",
                    "Could not record that payment. Please check the invoice and amount.");
        }

        response.sendRedirect(request.getContextPath() + "/invoices");
    }
}
