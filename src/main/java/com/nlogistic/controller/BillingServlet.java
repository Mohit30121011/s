package com.nlogistic.controller;

import com.nlogistic.dao.BillingDAO;
import com.nlogistic.dao.CustomerDAO;
import com.nlogistic.dao.ShipmentDAO;
import com.nlogistic.model.Invoice;
import com.nlogistic.model.InvoiceLineItem;
import com.nlogistic.model.Payment;
import com.nlogistic.util.DBConnectionManager;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet({"/billing", "/billing/*"})
public class BillingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private BillingDAO billingDAO = new BillingDAO();
    private CustomerDAO customerDAO = new CustomerDAO();
    private ShipmentDAO shipmentDAO = new ShipmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        // AJAX: Fetch invoice details, line items & payment history
        if (pathInfo != null && pathInfo.equals("/details")) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            try {
                int invoiceId = Integer.parseInt(request.getParameter("invoiceId"));
                Invoice inv = billingDAO.getInvoiceById(invoiceId);
                if (inv == null) {
                    response.getWriter().write("{\"error\":\"Invoice not found\"}");
                    return;
                }

                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"invoiceId\":").append(inv.getInvoiceId()).append(",");
                json.append("\"customerName\":\"").append(inv.getCustomerName() != null ? inv.getCustomerName() : "").append("\",");
                json.append("\"totalAmount\":").append(inv.getTotalAmount()).append(",");
                json.append("\"paidAmount\":").append(inv.getPaidAmount()).append(",");
                json.append("\"balance\":").append(inv.getBalanceDue()).append(",");
                json.append("\"status\":\"").append(inv.getPaymentStatus()).append("\",");

                json.append("\"lineItems\":[");
                List<InvoiceLineItem> items = inv.getLineItems();
                for (int i = 0; i < items.size(); i++) {
                    InvoiceLineItem item = items.get(i);
                    json.append("{")
                        .append("\"itemId\":").append(item.getItemId()).append(",")
                        .append("\"description\":\"").append(item.getDescription().replace("\"", "\\\"")).append("\",")
                        .append("\"quantity\":").append(item.getQuantity()).append(",")
                        .append("\"unitPrice\":").append(item.getUnitPrice()).append(",")
                        .append("\"lineTotal\":").append(item.getLineTotal())
                        .append("}");
                    if (i < items.size() - 1) json.append(",");
                }
                json.append("],");

                json.append("\"payments\":[");
                List<Payment> payments = inv.getPayments();
                for (int i = 0; i < payments.size(); i++) {
                    Payment p = payments.get(i);
                    json.append("{")
                        .append("\"paymentId\":").append(p.getPaymentId()).append(",")
                        .append("\"date\":\"").append(p.getPaymentDate()).append("\",")
                        .append("\"amount\":").append(p.getAmountPaid()).append(",")
                        .append("\"mode\":\"").append(p.getPaymentMode()).append("\",")
                        .append("\"ref\":\"").append(p.getTransactionRef() != null ? p.getTransactionRef().replace("\"", "\\\"") : "").append("\"")
                        .append("}");
                    if (i < payments.size() - 1) json.append(",");
                }
                json.append("]");

                json.append("}");
                response.getWriter().write(json.toString());
            } catch (Exception e) {
                response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
            }
            return;
        }

        // 1. Auto-flag overdue invoices (FR5.8)
        billingDAO.flagOverdueInvoices();

        // 2. Fetch all invoices with complete details
        List<Invoice> invoices = billingDAO.getAllInvoices();

        // 3. Compute Financial Analytics KPIs
        int invTotal = invoices.size();
        double invTotalAmount = 0.0;
        double invPaidAmount = 0.0;
        int invOverdueCount = 0;
        int invPaidCount = 0;
        int invPartialCount = 0;
        int invUnpaidCount = 0;

        for (Invoice i : invoices) {
            invTotalAmount += i.getTotalAmount();
            invPaidAmount += i.getPaidAmount();
            String st = i.getPaymentStatus();
            if ("Paid".equalsIgnoreCase(st)) invPaidCount++;
            else if ("Partial".equalsIgnoreCase(st)) invPartialCount++;
            else if ("Overdue".equalsIgnoreCase(st)) invOverdueCount++;
            else invUnpaidCount++;
        }
        double invOutstandingAmount = Math.max(0.0, invTotalAmount - invPaidAmount);

        // 4. Fetch Eligible Unbilled Shipments
        List<Map<String, Object>> eligibleShipments = new ArrayList<>();
        String eligibleSql = "SELECT s.shipment_id, s.cargo_description, s.freight_cost, s.status, "
                           + "c.customer_id, c.customer_name "
                           + "FROM SHIPMENT s "
                           + "JOIN CUSTOMERS c ON s.customer_id = c.customer_id "
                           + "LEFT JOIN BILLING_INVOICES bi ON s.shipment_id = bi.shipment_id "
                           + "WHERE bi.invoice_id IS NULL "
                           + "ORDER BY s.shipment_id DESC";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(eligibleSql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("shipmentId", rs.getInt("shipment_id"));
                map.put("cargoDesc", rs.getString("cargo_description"));
                map.put("freightCost", rs.getDouble("freight_cost"));
                map.put("customerId", rs.getInt("customer_id"));
                map.put("customerName", rs.getString("customer_name"));
                map.put("status", rs.getString("status"));
                eligibleShipments.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Set request attributes
        request.setAttribute("invoices", invoices);
        request.setAttribute("invTotal", invTotal);
        request.setAttribute("invTotalAmount", invTotalAmount);
        request.setAttribute("invPaidAmount", invPaidAmount);
        request.setAttribute("invOutstandingAmount", invOutstandingAmount);
        request.setAttribute("invOverdueCount", invOverdueCount);
        request.setAttribute("invPaidCount", invPaidCount);
        request.setAttribute("invPartialCount", invPartialCount);
        request.setAttribute("invUnpaidCount", invUnpaidCount);

        request.setAttribute("eligibleShipments", eligibleShipments);
        request.setAttribute("customers", customerDAO.getAllCustomers());
        request.setAttribute("shipments", shipmentDAO.getAllShipments());

        request.getRequestDispatcher("/jsp/billing.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession();

        if (pathInfo != null && pathInfo.equals("/generate")) {
            try {
                int customerId = Integer.parseInt(request.getParameter("customerId"));
                int shipmentId = Integer.parseInt(request.getParameter("shipmentId"));

                String freightStr = request.getParameter("freightCost");
                double freight = (freightStr != null && !freightStr.trim().isEmpty()) ? Double.parseDouble(freightStr.trim()) : 5000.0;

                String serviceStr = request.getParameter("serviceCharges");
                double service = (serviceStr != null && !serviceStr.trim().isEmpty()) ? Double.parseDouble(serviceStr.trim()) : 500.0;

                String taxRateStr = request.getParameter("taxRate");
                double taxRate = (taxRateStr != null && !taxRateStr.trim().isEmpty()) ? Double.parseDouble(taxRateStr.trim()) : 0.18;

                String dueDateStr = request.getParameter("dueDate");
                Date dueDate = (dueDateStr != null && !dueDateStr.trim().isEmpty()) ? Date.valueOf(dueDateStr.trim()) : new Date(System.currentTimeMillis() + 7L * 86400000L);
                Date invoiceDate = new Date(System.currentTimeMillis());

                int invoiceId = billingDAO.generateInvoice(customerId, shipmentId, freight, service, taxRate, invoiceDate, dueDate);
                if (invoiceId > 0) {
                    session.setAttribute("successMessage", "Tax Invoice INV-" + invoiceId + " generated successfully with freight, handling, and GST line items.");
                } else {
                    session.setAttribute("errorMessage", "Failed to generate invoice. Please verify shipment and customer data.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Error generating invoice: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/billing");

        } else if (pathInfo != null && pathInfo.equals("/pay")) {
            try {
                int invoiceId = Integer.parseInt(request.getParameter("invoiceId"));
                double amountPaid = Double.parseDouble(request.getParameter("amountPaid"));
                String paymentMode = request.getParameter("paymentMode");
                String transactionRef = request.getParameter("transactionRef");

                String payDateStr = request.getParameter("paymentDate");
                Date payDate = (payDateStr != null && !payDateStr.trim().isEmpty()) ? Date.valueOf(payDateStr.trim()) : new Date(System.currentTimeMillis());

                boolean success = billingDAO.recordPayment(invoiceId, amountPaid, paymentMode, transactionRef, payDate);
                if (success) {
                    session.setAttribute("successMessage", "Payment of ₹" + String.format("%.2f", amountPaid) + " successfully recorded for INV-" + invoiceId + " via " + paymentMode + ".");
                } else {
                    session.setAttribute("errorMessage", "Failed to record payment. Please check invoice and amount.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Error recording payment: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/billing");

        } else if (pathInfo != null && pathInfo.equals("/add-item")) {
            try {
                int invoiceId = Integer.parseInt(request.getParameter("invoiceId"));
                String description = request.getParameter("description");
                double quantity = Double.parseDouble(request.getParameter("quantity"));
                double unitPrice = Double.parseDouble(request.getParameter("unitPrice"));

                boolean success = billingDAO.addLineItem(invoiceId, description, quantity, unitPrice);
                if (success) {
                    session.setAttribute("successMessage", "Line item '" + description + "' added to INV-" + invoiceId + ".");
                } else {
                    session.setAttribute("errorMessage", "Failed to add line item.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Error adding line item: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/billing");

        } else if (pathInfo != null && pathInfo.equals("/delete-item")) {
            try {
                int itemId = Integer.parseInt(request.getParameter("itemId"));
                int invoiceId = Integer.parseInt(request.getParameter("invoiceId"));

                boolean success = billingDAO.deleteLineItem(itemId, invoiceId);
                if (success) {
                    session.setAttribute("successMessage", "Line item removed successfully.");
                } else {
                    session.setAttribute("errorMessage", "Failed to remove line item.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Error deleting line item: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/billing");

        } else {
            response.sendRedirect(request.getContextPath() + "/billing");
        }
    }
}
