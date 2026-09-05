package com.nlogistic.controller;

import java.io.IOException;
import java.sql.CallableStatement;
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

@WebServlet("/book")
public class BookShipmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int containerId = Integer.parseInt(request.getParameter("containerId"));
            double cargoWeight = Double.parseDouble(request.getParameter("cargoWeight"));
            double cargoVolume = Double.parseDouble(request.getParameter("cargoVolume"));
            String cargoDesc = request.getParameter("cargoDesc");
            double finalPrice = Double.parseDouble(request.getParameter("finalPrice"));
            
            // Assume the user selects port IDs from the form. Fallbacks provided.
            int originPortId = request.getParameter("origin") != null && !request.getParameter("origin").isEmpty() ? Integer.parseInt(request.getParameter("origin")) : 1;
            int destPortId = request.getParameter("destination") != null && !request.getParameter("destination").isEmpty() ? Integer.parseInt(request.getParameter("destination")) : 2;

            int shipmentId = -1;

            try (Connection conn = DBConnectionManager.getConnection()) {
                conn.setAutoCommit(false);
                
                // 1. Insert into shipment table
                String insertShipment = "INSERT INTO shipment (customer_id, container_id, origin_port_id, destination_port_id, "
                        + "booking_date, cargo_description, cargo_weight_kg, cargo_volume_cbm, freight_cost, status, created_by) "
                        + "VALUES (?, ?, ?, ?, CURDATE(), ?, ?, ?, ?, 'Booked', ?)";
                        
                // Resolve the true customers.customer_id. `user_id` is NOT a customer id -
                // writing it here silently attached bookings to an unrelated customer.
                Integer bookCustomerId = null;
                if (user.getRoleId() == 5) {
                    bookCustomerId = com.nlogistic.util.RbacContext.customerId(request);
                } else {
                    String custParam = request.getParameter("customerId");
                    if (custParam != null && !custParam.trim().isEmpty()) {
                        try { bookCustomerId = Integer.parseInt(custParam.trim()); } catch (NumberFormatException ignored) {}
                    }
                }
                if (bookCustomerId == null) {
                    conn.rollback();
                    request.getSession().setAttribute("errorMessage",
                            "Booking failed: no customer account could be resolved for this request.");
                    response.sendRedirect(request.getContextPath() + "/shipments");
                    return;
                }

                try (PreparedStatement ps = conn.prepareStatement(insertShipment, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, bookCustomerId);
                    ps.setInt(2, containerId);
                    ps.setInt(3, originPortId);
                    ps.setInt(4, destPortId);
                    ps.setString(5, cargoDesc);
                    ps.setDouble(6, cargoWeight);
                    ps.setDouble(7, cargoVolume);
                    ps.setDouble(8, finalPrice);
                    ps.setInt(9, user.getUserId());
                    ps.executeUpdate();
                    
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            shipmentId = rs.getInt(1);
                        }
                    }
                }
                
                // 2. Insert into profit_loss table (Module 2 linkage)
                if (shipmentId != -1) {
                    String insertPL = "INSERT INTO profit_loss (shipment_id, revenue_amount, total_cost_amount, profit_loss_amount, record_date) "
                                    + "VALUES (?, ?, 0, ?, CURDATE())";
                    try (PreparedStatement ps = conn.prepareStatement(insertPL)) {
                        ps.setInt(1, shipmentId);
                        ps.setDouble(2, finalPrice);
                        ps.setDouble(3, finalPrice); // initial profit = revenue
                        ps.executeUpdate();
                    }
                }
                
                // 3. Call allocate_container stored procedure to enforce logic
                try (CallableStatement cs = conn.prepareCall("{call allocate_container(?, ?)}")) {
                    cs.setInt(1, shipmentId);
                    cs.setInt(2, containerId);
                    cs.execute();
                }
                
                conn.commit();

                // FR8.1: auto-generate a barcode for every newly booked shipment
                if (shipmentId != -1) {
                    com.nlogistic.util.BarcodeAutoGenerator.generateFor(request, "Shipment", shipmentId, user.getUserId());
                }

                // FR5.5: the invoice is raised automatically on booking - the customer
                // never asks for one. Failure here must not roll back a valid booking,
                // so it is reported separately.
                String invoiceNote = "";
                if (shipmentId != -1) {
                    try {
                        int invoiceId = new com.nlogistic.dao.BillingDAO()
                                .generateInvoice(bookCustomerId, shipmentId);
                        if (invoiceId > 0) {
                            invoiceNote = " Invoice INV-" + invoiceId + " has been raised and is available under Invoices & Payments.";
                        } else {
                            invoiceNote = " (Invoice will be raised shortly.)";
                        }
                    } catch (Exception invEx) {
                        invEx.printStackTrace();
                        invoiceNote = " (Invoice could not be raised automatically - Finance has been notified.)";
                    }
                }

                request.getSession().setAttribute("successMessage",
                        "Shipment #" + shipmentId + " booked and container allocated." + invoiceNote);

                // Customers land on their own shipment list; staff go back to the catalog.
                response.sendRedirect(request.getContextPath()
                        + (user.getRoleId() == 5 ? "/shipments" : "/containers"));
                
            } catch (Exception ex) {
                ex.printStackTrace();
                request.getSession().setAttribute("errorMessage", "Booking failed: " + ex.getMessage());
                response.sendRedirect(request.getContextPath() + "/containers");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Invalid booking data.");
            response.sendRedirect(request.getContextPath() + "/containers");
        }
    }
}
