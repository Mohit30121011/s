package com.nlogistic.controller;

import com.nlogistic.dao.BillingDAO;
import com.nlogistic.dao.CustomerDAO;
import com.nlogistic.dao.ShipmentDAO;
import com.nlogistic.model.Invoice;
import com.nlogistic.model.User;
import com.nlogistic.util.DBConnectionManager;

import java.io.IOException;
import java.sql.Connection;
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

@WebServlet({"/invoices", "/invoices/*", "/invoice-view"})
public class InvoiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private BillingDAO billingDAO = new BillingDAO();
    private CustomerDAO customerDAO = new CustomerDAO();
    private ShipmentDAO shipmentDAO = new ShipmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }
        // FR5.8 / CLAUDE.md S4: Super Admin, Company Admin, Finance and Customers
        // may open this page. Operations staff have no billing authority.
        if (user.getRoleId() == com.nlogistic.util.RbacContext.OPERATIONS) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access Denied: invoices are a Finance function.");
            return;
        }

        billingDAO.flagOverdueInvoices();

        String idParam = request.getParameter("id");
        String actionParam = request.getParameter("action");

        // 1. Single Invoice Printable / Exportable View (FR5.8)
        if (idParam != null && !idParam.trim().isEmpty() && ("view".equalsIgnoreCase(actionParam) || "print".equalsIgnoreCase(actionParam) || request.getServletPath().equals("/invoice-view"))) {
            try {
                int invoiceId = Integer.parseInt(idParam.trim());
                // IDOR guard: never render another customer's / tenant's invoice.
                if (!billingDAO.canAccessInvoice(invoiceId, user.getRoleId(),
                        com.nlogistic.util.RbacContext.companyId(request), com.nlogistic.util.RbacContext.customerId(request))) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN,
                            "Access Denied: this invoice does not belong to your account.");
                    return;
                }
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
        int rbacRole = com.nlogistic.util.RbacContext.roleId(request);
        Integer rbacCompany = com.nlogistic.util.RbacContext.companyId(request);
        Integer rbacCustomer = com.nlogistic.util.RbacContext.customerId(request);

        String customerIdParam = request.getParameter("customerId");
        List<Invoice> invoices;
        if (rbacRole == com.nlogistic.util.RbacContext.CUSTOMER) {
            // FR5.8: a Customer only ever sees their own statements. The
            // customerId request parameter is ignored so it cannot be tampered with.
            invoices = billingDAO.getInvoicesByCustomerId(rbacCustomer != null ? rbacCustomer : -1);
            request.setAttribute("selectedCustomerId", rbacCustomer);
        } else if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
            try {
                int custId = Integer.parseInt(customerIdParam.trim());
                invoices = billingDAO.getBillingHistory(custId);
                request.setAttribute("selectedCustomerId", custId);
            } catch (Exception e) {
                invoices = billingDAO.getInvoicesForRole(rbacRole, rbacCompany, rbacCustomer);
            }
        } else {
            invoices = billingDAO.getInvoicesForRole(rbacRole, rbacCompany, rbacCustomer);
        }

        // 3. Eligible (un-invoiced) shipments for the "Generate New Invoice" modal.
        List<Map<String, Object>> eligibleShipments = new ArrayList<>();
        // Invoicing is an internal function - Customers get no eligible-shipment list,
        // and company staff only see their own tenant's un-invoiced shipments.
        String eligibleSql = "SELECT s.shipment_id, c.customer_id, c.customer_name, s.freight_cost "
                           + "FROM SHIPMENT s JOIN CUSTOMERS c ON s.customer_id = c.customer_id "
                           + "LEFT JOIN CONTAINERS cnt ON s.container_id = cnt.container_id "
                           + "LEFT JOIN BILLING_INVOICES bi ON s.shipment_id = bi.shipment_id "
                           + "WHERE bi.invoice_id IS NULL ";
        if (rbacRole >= 2 && rbacRole <= 4) {
            eligibleSql += "AND (cnt.owner_company_id = ? "
                        +  "  OR s.created_by IN (SELECT user_id FROM users WHERE company_id = ?)) ";
        }
        eligibleSql += "ORDER BY s.shipment_id DESC";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(eligibleSql)) {
            if (rbacRole >= 2 && rbacRole <= 4) {
                int cid = rbacCompany != null ? rbacCompany : -1;
                ps.setInt(1, cid);
                ps.setInt(2, cid);
            }
            ResultSet rs = (rbacRole == com.nlogistic.util.RbacContext.CUSTOMER) ? null : ps.executeQuery();
            while (rs != null && rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("shipmentId", rs.getInt("shipment_id"));
                map.put("customerId", rs.getInt("customer_id"));
                map.put("customerName", rs.getString("customer_name"));
                map.put("cost", rs.getDouble("freight_cost"));
                eligibleShipments.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("invoices", invoices);
        // Customers must never see a directory of other customers (CLAUDE.md S3.5.6).
        request.setAttribute("customers", rbacRole == com.nlogistic.util.RbacContext.CUSTOMER
                ? java.util.Collections.emptyList()
                : customerDAO.getAllCustomers());
        request.setAttribute("shipments", shipmentDAO.getShipmentsForRole(rbacRole, rbacCompany, rbacCustomer));
        request.setAttribute("eligibleShipments", eligibleShipments);

        request.getRequestDispatcher("/jsp/invoices.jsp").forward(request, response);
    }
}
