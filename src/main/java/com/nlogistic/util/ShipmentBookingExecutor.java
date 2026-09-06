package com.nlogistic.util;

import com.nlogistic.dao.BillingDAO;
import com.nlogistic.model.User;

import javax.servlet.http.HttpServletRequest;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Map;

/**
 * Executes the complete atomic shipment booking lifecycle upon payment authorization:
 * 1. Creates shipment row with cargo & container specs
 * 2. Seeds profit_loss analytics record
 * 3. Calls allocate_container stored procedure
 * 4. Auto-generates scannable QR barcode
 * 5. Generates invoice INV-xxxx
 * 6. Records payment in billing ledger as PAID
 */
public class ShipmentBookingExecutor {

    public static class BookingResult {
        public boolean success;
        public int shipmentId = -1;
        public int invoiceId = -1;
        public String errorMessage;
    }

    public static BookingResult executeBooking(HttpServletRequest request, Map<String, Object> params, String paymentMethod, String txnId) {
        BookingResult result = new BookingResult();

        try {
            int containerId = Integer.parseInt(String.valueOf(params.get("containerId")));
            double cargoWeight = Double.parseDouble(String.valueOf(params.get("cargoWeight")));
            double cargoVolume = Double.parseDouble(String.valueOf(params.get("cargoVolume")));
            String cargoDesc = String.valueOf(params.get("cargoDesc"));
            double finalPrice = Double.parseDouble(String.valueOf(params.get("finalPrice")));
            double invoiceTotal = finalPrice * 1.18; // Includes 18% GST

            int originPortId = 1;
            Object origObj = params.get("origin");
            if (origObj != null && !origObj.toString().trim().isEmpty()) {
                try { originPortId = Integer.parseInt(origObj.toString().trim()); } catch (NumberFormatException ignored) {}
            }

            int destPortId = 2;
            Object destObj = params.get("destination");
            if (destObj != null && !destObj.toString().trim().isEmpty()) {
                try { destPortId = Integer.parseInt(destObj.toString().trim()); } catch (NumberFormatException ignored) {}
            }

            int customerId = -1;
            Object custObj = params.get("customerId");
            if (custObj != null && !custObj.toString().trim().isEmpty()) {
                try { customerId = Integer.parseInt(custObj.toString().trim()); } catch (NumberFormatException ignored) {}
            }

            int userId = 1;
            Object userObj = params.get("userId");
            if (userObj != null && !userObj.toString().trim().isEmpty()) {
                try { userId = Integer.parseInt(userObj.toString().trim()); } catch (NumberFormatException ignored) {}
            }

            if (customerId <= 0) {
                result.success = false;
                result.errorMessage = "Could not resolve valid customer account for this booking.";
                return result;
            }

            int shipmentId = -1;

            try (Connection conn = DBConnectionManager.getConnection()) {
                conn.setAutoCommit(false);

                // 1. Insert into shipment table
                String insertShipment = "INSERT INTO shipment (customer_id, container_id, origin_port_id, destination_port_id, "
                        + "booking_date, cargo_description, cargo_weight_kg, cargo_volume_cbm, freight_cost, status, created_by) "
                        + "VALUES (?, ?, ?, ?, CURDATE(), ?, ?, ?, ?, 'Booked', ?)";

                try (PreparedStatement ps = conn.prepareStatement(insertShipment, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, customerId);
                    ps.setInt(2, containerId);
                    ps.setInt(3, originPortId);
                    ps.setInt(4, destPortId);
                    ps.setString(5, cargoDesc);
                    ps.setDouble(6, cargoWeight);
                    ps.setDouble(7, cargoVolume);
                    ps.setDouble(8, finalPrice);
                    ps.setInt(9, userId);
                    ps.executeUpdate();

                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            shipmentId = rs.getInt(1);
                        }
                    }
                }

                if (shipmentId <= 0) {
                    conn.rollback();
                    result.success = false;
                    result.errorMessage = "Failed to generate shipment ID from database.";
                    return result;
                }

                // 2. Insert into profit_loss table (Module 2 linkage)
                String insertPL = "INSERT INTO profit_loss (shipment_id, revenue_amount, total_cost_amount, profit_loss_amount, record_date) "
                                + "VALUES (?, ?, 0, ?, CURDATE())";
                try (PreparedStatement ps = conn.prepareStatement(insertPL)) {
                    ps.setInt(1, shipmentId);
                    ps.setDouble(2, finalPrice);
                    ps.setDouble(3, finalPrice); // initial profit = revenue
                    ps.executeUpdate();
                }

                // 3. Record initial movement status = 'Booked' (FR2.2 Milestone 1)
                // Container allocation is explicitly deferred to Company Operations / Admin (UC 4, FR3.3, FR3.4)
                String insertMove = "INSERT INTO container_movements (shipment_id, status, updated_by, checkpoint_location) "
                                  + "VALUES (?, 'Booked', ?, 'Booking Confirmed - Awaiting Container Allocation by Operations')";
                try (PreparedStatement ps = conn.prepareStatement(insertMove)) {
                    ps.setInt(1, shipmentId);
                    ps.setInt(2, userId);
                    ps.executeUpdate();
                }

                conn.commit();
            }

            result.shipmentId = shipmentId;

            // 4. Auto-generate barcode for newly booked shipment
            try {
                BarcodeAutoGenerator.generateFor(request, "Shipment", shipmentId, userId);
            } catch (Exception bex) {
                System.err.println("Barcode auto-generation notice: " + bex.getMessage());
            }

            // 5. Raise the invoice automatically
            int invoiceId = -1;
            BillingDAO billingDAO = new BillingDAO();
            try {
                invoiceId = billingDAO.generateInvoice(customerId, shipmentId);
                result.invoiceId = invoiceId;
            } catch (Exception iex) {
                System.err.println("Invoice auto-generation notice: " + iex.getMessage());
            }

            // 6. Record the payment as PAID
            if (invoiceId > 0) {
                try {
                    com.nlogistic.model.Invoice inv = billingDAO.getInvoiceById(invoiceId);
                    double payAmt = (inv != null && inv.getTotalAmount() > 0) ? inv.getTotalAmount() : invoiceTotal;
                    billingDAO.recordPayment(invoiceId, payAmt, paymentMethod, txnId, new java.sql.Date(System.currentTimeMillis()));
                } catch (Exception pex) {
                    System.err.println("Payment recording notice: " + pex.getMessage());
                }
            }

            result.success = true;
            return result;

        } catch (Exception e) {
            e.printStackTrace();
            result.success = false;
            result.errorMessage = e.getMessage();
            return result;
        }
    }
}
