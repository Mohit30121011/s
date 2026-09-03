package com.nlogistic.controller;

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

import com.nlogistic.model.User;
import com.nlogistic.util.DBConnectionManager;

@WebServlet("/invoices")
public class InvoiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 4) { // Allow Super Admin, Company Admin, Ops, Finance
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        List<Map<String, Object>> invoices = new ArrayList<>();
        
        String sql = "SELECT i.invoice_id, i.invoice_date, i.due_date, i.total_amount, i.paid_amount, i.payment_status, "
                   + "c.name as customer_name, s.shipment_id, s.cargo_description "
                   + "FROM billing_invoices i "
                   + "JOIN customers c ON i.customer_id = c.customer_id "
                   + "JOIN shipment s ON i.shipment_id = s.shipment_id "
                   + "ORDER BY i.invoice_date DESC";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
             
            while (rs.next()) {
                Map<String, Object> inv = new HashMap<>();
                inv.put("invoiceId", rs.getInt("invoice_id"));
                inv.put("invoiceDate", rs.getDate("invoice_date"));
                inv.put("dueDate", rs.getDate("due_date"));
                inv.put("totalAmount", rs.getDouble("total_amount"));
                inv.put("paidAmount", rs.getDouble("paid_amount"));
                inv.put("paymentStatus", rs.getString("payment_status"));
                inv.put("customerName", rs.getString("customer_name"));
                inv.put("shipmentId", rs.getInt("shipment_id"));
                inv.put("cargoDesc", rs.getString("cargo_description"));
                invoices.add(inv);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("invoices", invoices);
        
        // Fetch eligible shipments for new invoice generation
        List<Map<String, Object>> eligibleShipments = new ArrayList<>();
        String sqlShipments = "SELECT s.shipment_id, s.cargo_description, s.freight_cost, c.customer_id, c.name "
                            + "FROM shipment s "
                            + "JOIN customers c ON s.customer_id = c.customer_id "
                            + "LEFT JOIN billing_invoices i ON s.shipment_id = i.shipment_id "
                            + "WHERE i.invoice_id IS NULL";
        
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps2 = conn.prepareStatement(sqlShipments);
             ResultSet rs2 = ps2.executeQuery()) {
             
            while (rs2.next()) {
                Map<String, Object> ship = new HashMap<>();
                ship.put("shipmentId", rs2.getInt("shipment_id"));
                ship.put("cargoDesc", rs2.getString("cargo_description"));
                ship.put("cost", rs2.getDouble("freight_cost"));
                ship.put("customerId", rs2.getInt("customer_id"));
                ship.put("customerName", rs2.getString("name"));
                eligibleShipments.add(ship);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        request.setAttribute("eligibleShipments", eligibleShipments);

        request.getRequestDispatcher("/jsp/invoices.jsp").forward(request, response);
    }
}
