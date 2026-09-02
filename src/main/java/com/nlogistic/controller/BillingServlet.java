package com.nlogistic.controller;

import com.nlogistic.dao.BillingDAO;
import com.nlogistic.dao.CustomerDAO;
import com.nlogistic.dao.ShipmentDAO;
import com.nlogistic.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/billing/*")
public class BillingServlet extends HttpServlet {

    private BillingDAO billingDAO = new BillingDAO();
    private CustomerDAO customerDAO = new CustomerDAO();
    private ShipmentDAO shipmentDAO = new ShipmentDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/")) {
            request.setAttribute("invoices", billingDAO.getAllInvoices());
            request.setAttribute("customers", customerDAO.getAllCustomers());
            request.setAttribute("shipments", shipmentDAO.getAllShipments());
            request.getRequestDispatcher("/jsp/billing.jsp").forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        if (pathInfo != null && pathInfo.equals("/generate")) {
            int customerId = Integer.parseInt(request.getParameter("customerId"));
            int shipmentId = Integer.parseInt(request.getParameter("shipmentId"));
            
            int invoiceId = billingDAO.generateInvoice(customerId, shipmentId);
            if (invoiceId != -1) {
                response.sendRedirect(request.getContextPath() + "/billing?success=true&inv=" + invoiceId);
            } else {
                response.sendRedirect(request.getContextPath() + "/billing?error=true");
            }
        } else if (pathInfo != null && pathInfo.equals("/pay")) {
            int invoiceId = Integer.parseInt(request.getParameter("invoiceId"));
            double amount = Double.parseDouble(request.getParameter("amountPaid"));
            String mode = request.getParameter("paymentMode");
            String ref = request.getParameter("transactionRef");
            
            boolean success = billingDAO.recordPayment(invoiceId, amount, mode, ref);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/billing?success=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/billing?error=true");
            }
        }
    }
}
