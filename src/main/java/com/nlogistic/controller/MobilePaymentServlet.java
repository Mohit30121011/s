package com.nlogistic.controller;

import com.nlogistic.model.PaymentTransaction;
import com.nlogistic.util.PaymentTransactionManager;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/pay-mobile")
public class MobilePaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String txnId = request.getParameter("txn");
        if (txnId == null || txnId.trim().isEmpty()) {
            request.setAttribute("error", "Invalid or missing transaction identifier.");
            request.getRequestDispatcher("/jsp/pay-mobile.jsp").forward(request, response);
            return;
        }

        PaymentTransaction txn = PaymentTransactionManager.getTransaction(txnId);
        if (txn == null) {
            request.setAttribute("error", "Transaction expired or not found. Please regenerate QR from the booking page.");
            request.getRequestDispatcher("/jsp/pay-mobile.jsp").forward(request, response);
            return;
        }

        request.setAttribute("txn", txn);
        request.getRequestDispatcher("/jsp/pay-mobile.jsp").forward(request, response);
    }
}
