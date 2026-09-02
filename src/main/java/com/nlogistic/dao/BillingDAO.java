package com.nlogistic.dao;

import com.nlogistic.model.Invoice;
import com.nlogistic.model.InvoiceLineItem;
import com.nlogistic.model.Payment;
import com.nlogistic.util.DBConnectionManager;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class BillingDAO {
    
    public List<Invoice> getAllInvoices() {
        List<Invoice> list = new ArrayList<>();
        String sql = "SELECT * FROM billing_invoices ORDER BY invoice_date DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Invoice inv = new Invoice();
                inv.setInvoiceId(rs.getInt("invoice_id"));
                inv.setCustomerId(rs.getInt("customer_id"));
                inv.setShipmentId(rs.getInt("shipment_id"));
                inv.setInvoiceDate(rs.getDate("invoice_date"));
                inv.setDueDate(rs.getDate("due_date"));
                inv.setSubtotalAmount(rs.getDouble("subtotal_amount"));
                inv.setTaxAmount(rs.getDouble("tax_amount"));
                inv.setTotalAmount(rs.getDouble("total_amount"));
                inv.setPaidAmount(rs.getDouble("paid_amount"));
                inv.setPaymentStatus(rs.getString("payment_status"));
                list.add(inv);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int generateInvoice(int customerId, int shipmentId) {
        String sql = "{CALL generate_invoice(?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, customerId);
            cs.setInt(2, shipmentId);
            cs.registerOutParameter(3, Types.INTEGER);
            cs.execute();
            return cs.getInt(3);
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }

    public boolean recordPayment(int invoiceId, double amount, String mode, String ref) {
        String sql = "{CALL record_payment(?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, invoiceId);
            cs.setDouble(2, amount);
            cs.setString(3, mode);
            cs.setString(4, ref);
            cs.execute();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * DB: void_invoice(p_invoice_id, p_voided_by, p_reason)
     */
    public boolean voidInvoice(int invoiceId, int voidedBy, String reason) {
        String sql = "{CALL void_invoice(?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, invoiceId);
            cs.setInt(2, voidedBy);
            cs.setString(3, reason);
            cs.execute();
            return true;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    /**
     * DB: get_invoice_aging(p_customer_id)
     */
    public List<Invoice> getInvoiceAging(Integer customerId) {
        List<Invoice> list = new ArrayList<>();
        String sql = "{CALL get_invoice_aging(?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            if (customerId != null) cs.setInt(1, customerId); else cs.setNull(1, Types.INTEGER);
            ResultSet rs = cs.executeQuery();
            while (rs.next()) {
                Invoice inv = new Invoice();
                inv.setInvoiceId(rs.getInt("invoice_id"));
                inv.setCustomerId(rs.getInt("customer_id"));
                inv.setTotalAmount(rs.getDouble("total_amount"));
                inv.setPaidAmount(rs.getDouble("paid_amount"));
                inv.setPaymentStatus(rs.getString("payment_status"));
                list.add(inv);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * DB: add_invoice_line_item(p_invoice_id, p_description, p_quantity, p_unit_price)
     */
    public void addLineItem(int invoiceId, String description, double quantity, double unitPrice) {
        String sql = "{CALL add_invoice_line_item(?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, invoiceId);
            cs.setString(2, description);
            cs.setDouble(3, quantity);
            cs.setDouble(4, unitPrice);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

}
