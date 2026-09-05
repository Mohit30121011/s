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

    /** Parses a numeric form field, falling back to a default when absent/blank/invalid. */
    private static double parseOr(String value, double fallback) {
        if (value == null || value.trim().isEmpty()) return fallback;
        try { return Double.parseDouble(value.trim()); } catch (NumberFormatException e) { return fallback; }
    }

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

        // FR5.5: freight + service charges + surcharges + tax — all operator-entered on the
        // Generate Invoice form (prefilled from the shipment), falling back to sane defaults.
        double freightCost   = parseOr(request.getParameter("freightCost"), Double.parseDouble(parts[2]));
        double serviceCharges = parseOr(request.getParameter("serviceCharges"), 500.0);
        double surcharge      = parseOr(request.getParameter("surcharge"), Math.round(freightCost * 0.02 * 100) / 100.0);
        double taxRate        = parseOr(request.getParameter("taxRate"), 18.0);
        String notes          = request.getParameter("notes");

        if (freightCost < 0 || serviceCharges < 0 || surcharge < 0 || taxRate < 0) {
            request.getSession().setAttribute("errorMessage", "Charges and tax rate cannot be negative.");
            response.sendRedirect(request.getContextPath() + "/invoices");
            return;
        }

        String invoiceDateStr = request.getParameter("invoiceDate");
        double subtotal = freightCost + serviceCharges + surcharge;
        // Gap 7: one convention for tax rates across both billing pipelines.
        double taxAmount = subtotal * com.nlogistic.dao.BillingDAO.normaliseTaxRate(taxRate);
        double totalAmount = subtotal + taxAmount;

        try (Connection conn = DBConnectionManager.getConnection()) {
            conn.setAutoCommit(false);

            // 1. Insert Invoice
            String sql = "INSERT INTO billing_invoices (customer_id, shipment_id, invoice_date, due_date, subtotal_amount, tax_amount, total_amount, payment_status) "
                       + "VALUES (?, ?, COALESCE(?, CURDATE()), ?, ?, ?, ?, 'Unpaid')";

            int invoiceId = -1;
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, customerId);
                ps.setInt(2, shipmentId);
                if (invoiceDateStr != null && !invoiceDateStr.trim().isEmpty()) ps.setString(3, invoiceDateStr.trim());
                else ps.setNull(3, java.sql.Types.DATE);
                ps.setString(4, dueDateStr);
                ps.setDouble(5, subtotal);
                ps.setDouble(6, taxAmount);
                ps.setDouble(7, totalAmount);
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        invoiceId = rs.getInt(1);
                    }
                }
            }

            // 2. Insert Line Items (freight, service charges, surcharge, tax)
            if (invoiceId != -1) {
                String sqlLine = "INSERT INTO invoice_line_items (invoice_id, description, quantity, unit_price, line_total) VALUES (?, ?, 1, ?, ?)";
                try (PreparedStatement psLine = conn.prepareStatement(sqlLine)) {
                    psLine.setInt(1, invoiceId);
                    psLine.setString(2, "Freight Shipping Cost");
                    psLine.setDouble(3, freightCost);
                    psLine.setDouble(4, freightCost);
                    psLine.addBatch();

                    psLine.setInt(1, invoiceId);
                    psLine.setString(2, "Terminal Handling & Documentation (Service Charges)");
                    psLine.setDouble(3, serviceCharges);
                    psLine.setDouble(4, serviceCharges);
                    psLine.addBatch();

                    psLine.setInt(1, invoiceId);
                    psLine.setString(2, "Fuel / Handling Surcharge");
                    psLine.setDouble(3, surcharge);
                    psLine.setDouble(4, surcharge);
                    psLine.addBatch();

                    psLine.setInt(1, invoiceId);
                    psLine.setString(2, "Goods & Services Tax (GST / Customs Duty) @ " + taxRate + "%");
                    psLine.setDouble(3, taxAmount);
                    psLine.setDouble(4, taxAmount);
                    psLine.addBatch();

                    if (notes != null && !notes.trim().isEmpty()) {
                        psLine.setInt(1, invoiceId);
                        psLine.setString(2, notes.trim());
                        psLine.setDouble(3, 0);
                        psLine.setDouble(4, 0);
                        psLine.addBatch();
                    }

                    psLine.executeBatch();
                }
            }

            conn.commit();
            request.getSession().setAttribute("successMessage", "Invoice INV-" + invoiceId + " successfully generated.");

            // FR8.1: auto-generate a barcode for every newly generated invoice
            if (invoiceId != -1) {
                com.nlogistic.util.BarcodeAutoGenerator.generateFor(request, "Invoice", invoiceId, user.getUserId());
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Error generating invoice: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/invoices");
    }
}
