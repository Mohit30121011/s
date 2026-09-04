package com.nlogistic.controller;

import com.nlogistic.dao.BillingDAO;
import com.nlogistic.dao.CustomerDAO;
import com.nlogistic.dao.ShipmentDAO;
import com.nlogistic.model.Invoice;
import com.nlogistic.model.User;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet({"/invoices", "/invoices/*", "/invoice-view"})
public class InvoiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private BillingDAO billingDAO = new BillingDAO();
    private CustomerDAO customerDAO = new CustomerDAO();
    private ShipmentDAO shipmentDAO = new ShipmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 4) { // Allow Super Admin, Company Admin, Ops, Finance
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        billingDAO.flagOverdueInvoices();

        String idParam = request.getParameter("id");
        String actionParam = request.getParameter("action");

        // 1. Single Invoice Printable / Exportable View (FR5.8)
        if (idParam != null && !idParam.trim().isEmpty() && ("view".equalsIgnoreCase(actionParam) || "print".equalsIgnoreCase(actionParam) || request.getServletPath().equals("/invoice-view"))) {
            try {
                int invoiceId = Integer.parseInt(idParam.trim());
                Invoice inv = billingDAO.getInvoiceById(invoiceId);
                if (inv != null) {
                    request.setAttribute("invoice", inv);
                    request.setAttribute("lineItems", inv.getLineItems());
                    request.setAttribute("payments", inv.getPayments());
                    request.getRequestDispatcher("/jsp/invoice-template.jsp").forward(request, response);
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // 2. Billing History Report per Customer (FR5.8)
        String customerIdParam = request.getParameter("customerId");
        List<Invoice> invoices;
        if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
            try {
                int custId = Integer.parseInt(customerIdParam.trim());
                invoices = billingDAO.getBillingHistory(custId);
                request.setAttribute("selectedCustomerId", custId);
            } catch (Exception e) {
                invoices = billingDAO.getAllInvoices();
            }
        } else {
            invoices = billingDAO.getAllInvoices();
        }

        request.setAttribute("invoices", invoices);
        request.setAttribute("customers", customerDAO.getAllCustomers());
        request.setAttribute("shipments", shipmentDAO.getAllShipments());

        request.getRequestDispatcher("/jsp/invoices.jsp").forward(request, response);
    }
}
