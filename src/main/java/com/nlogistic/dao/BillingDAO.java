package com.nlogistic.dao;

import com.nlogistic.model.Invoice;
import com.nlogistic.model.InvoiceLineItem;
import com.nlogistic.model.Payment;
import com.nlogistic.util.DBConnectionManager;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class BillingDAO {

    /**
     * Retrieves all billing invoices, enriched with joined customer/shipment details when available.
     */
    public List<Invoice> getAllInvoices() {
        List<Invoice> list = new ArrayList<>();
        String sql = "SELECT bi.*, c.customer_name, u.email AS customer_email, u.phone AS customer_phone, "
                   + "s.cargo_description, p_orig.port_name AS origin_port, p_dest.port_name AS dest_port "
                   + "FROM BILLING_INVOICES bi "
                   + "JOIN CUSTOMERS c ON bi.customer_id = c.customer_id "
                   + "LEFT JOIN USERS u ON c.user_id = u.user_id "
                   + "JOIN SHIPMENT s ON bi.shipment_id = s.shipment_id "
                   + "LEFT JOIN PORTS p_orig ON s.origin_port_id = p_orig.port_id "
                   + "LEFT JOIN PORTS p_dest ON s.destination_port_id = p_dest.port_id "
                   + "ORDER BY bi.invoice_id DESC";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToInvoice(rs));
            }
        } catch (Exception e) {
            // Fallback to a plain, unjoined select if the joined query fails for any reason.
            list.clear();
            String simpleSql = "SELECT * FROM billing_invoices ORDER BY invoice_date DESC";
            try (Connection conn = DBConnectionManager.getConnection();
                 PreparedStatement ps = conn.prepareStatement(simpleSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToInvoice(rs));
                }
            } catch (Exception e2) {
                e2.printStackTrace();
            }
        }
        return list;
    }

    /**
     * Retrieves a single invoice with joined details, line items, and payments.
     */
    public Invoice getInvoiceById(int invoiceId) {
        String sql = "SELECT bi.*, c.customer_name, u.email AS customer_email, u.phone AS customer_phone, "
                   + "s.cargo_description, p_orig.port_name AS origin_port, p_dest.port_name AS dest_port "
                   + "FROM BILLING_INVOICES bi "
                   + "JOIN CUSTOMERS c ON bi.customer_id = c.customer_id "
                   + "LEFT JOIN USERS u ON c.user_id = u.user_id "
                   + "JOIN SHIPMENT s ON bi.shipment_id = s.shipment_id "
                   + "LEFT JOIN PORTS p_orig ON s.origin_port_id = p_orig.port_id "
                   + "LEFT JOIN PORTS p_dest ON s.destination_port_id = p_dest.port_id "
                   + "WHERE bi.invoice_id = ?";

        Invoice inv = null;
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    inv = mapResultSetToInvoice(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (inv != null) {
            inv.setLineItems(getLineItems(invoiceId));
            inv.setPayments(getPayments(invoiceId));
        }
        return inv;
    }

    /**
     * Backward-compatible simple generator (DB: generate_invoice(p_customer_id, p_shipment_id, OUT p_invoice_id)).
     */
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

    /**
     * Detailed generator with explicit freight/service/tax breakdown, used by the richer billing UI.
     * Falls back to a manual transactional insert (with itemized line items) if no matching
     * stored procedure overload exists in the live database.
     */
    public int generateInvoice(int customerId, int shipmentId, double freightCost, double serviceCharges,
                                double taxRate, Date invoiceDate, Date dueDate) {
        try (Connection conn = DBConnectionManager.getConnection()) {
            conn.setAutoCommit(false);
            double subtotal = freightCost + serviceCharges;
            double tax = subtotal * taxRate;
            double total = subtotal + tax;

            String insertInv = "INSERT INTO BILLING_INVOICES (customer_id, shipment_id, invoice_date, due_date, "
                             + "subtotal_amount, tax_amount, total_amount, paid_amount, payment_status) "
                             + "VALUES (?, ?, ?, ?, ?, ?, ?, 0, 'Unpaid')";

            int invId = -1;
            try (PreparedStatement ps = conn.prepareStatement(insertInv, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, customerId);
                ps.setInt(2, shipmentId);
                ps.setDate(3, invoiceDate != null ? invoiceDate : new Date(System.currentTimeMillis()));
                ps.setDate(4, dueDate != null ? dueDate : new Date(System.currentTimeMillis() + 3L * 86400000L));
                ps.setDouble(5, subtotal);
                ps.setDouble(6, tax);
                ps.setDouble(7, total);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) invId = rs.getInt(1);
                }
            }

            if (invId > 0) {
                String lineSql = "INSERT INTO INVOICE_LINE_ITEMS (invoice_id, description, quantity, unit_price, line_total) "
                               + "VALUES (?, ?, 1, ?, ?)";
                try (PreparedStatement psLine = conn.prepareStatement(lineSql)) {
                    psLine.setInt(1, invId);
                    psLine.setString(2, "Freight Shipping Cost");
                    psLine.setDouble(3, freightCost);
                    psLine.setDouble(4, freightCost);
                    psLine.addBatch();

                    if (serviceCharges > 0) {
                        psLine.setInt(1, invId);
                        psLine.setString(2, "Terminal Handling & Documentation");
                        psLine.setDouble(3, serviceCharges);
                        psLine.setDouble(4, serviceCharges);
                        psLine.addBatch();
                    }

                    if (tax > 0) {
                        psLine.setInt(1, invId);
                        psLine.setString(2, "Goods & Services Tax (GST / Duty)");
                        psLine.setDouble(3, tax);
                        psLine.setDouble(4, tax);
                        psLine.addBatch();
                    }
                    psLine.executeBatch();
                }
                conn.commit();
                return invId;
            }
            conn.rollback();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Backward-compatible simple payment recorder (DB: record_payment(p_invoice_id, p_amount, p_mode, p_ref)).
     */
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
     * Payment recorder with an explicit payment date, used by the richer billing UI.
     * Falls back to a manual insert + total/status recalculation.
     */
    public boolean recordPayment(int invoiceId, double amount, String mode, String ref, Date paymentDate) {
        try (Connection conn = DBConnectionManager.getConnection()) {
            conn.setAutoCommit(false);
            String paySql = "INSERT INTO PAYMENTS (invoice_id, payment_date, amount_paid, payment_mode, transaction_ref) "
                          + "VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(paySql)) {
                ps.setInt(1, invoiceId);
                ps.setDate(2, paymentDate != null ? paymentDate : new Date(System.currentTimeMillis()));
                ps.setDouble(3, amount);
                ps.setString(4, mode);
                ps.setString(5, ref);
                ps.executeUpdate();
            }

            String calcSql = "SELECT COALESCE(SUM(amount_paid), 0) AS total_paid FROM PAYMENTS WHERE invoice_id = ?";
            double totalPaid = 0;
            try (PreparedStatement psCalc = conn.prepareStatement(calcSql)) {
                psCalc.setInt(1, invoiceId);
                try (ResultSet rs = psCalc.executeQuery()) {
                    if (rs.next()) totalPaid = rs.getDouble("total_paid");
                }
            }

            String getTot = "SELECT total_amount FROM BILLING_INVOICES WHERE invoice_id = ?";
            double totalAmount = 0;
            try (PreparedStatement psTot = conn.prepareStatement(getTot)) {
                psTot.setInt(1, invoiceId);
                try (ResultSet rs = psTot.executeQuery()) {
                    if (rs.next()) totalAmount = rs.getDouble("total_amount");
                }
            }

            String status = "Unpaid";
            if (totalPaid >= totalAmount && totalAmount > 0) {
                status = "Paid";
            } else if (totalPaid > 0) {
                status = "Partial";
            }

            String updInv = "UPDATE BILLING_INVOICES SET paid_amount = ?, payment_status = ? WHERE invoice_id = ?";
            try (PreparedStatement psUpd = conn.prepareStatement(updInv)) {
                psUpd.setDouble(1, totalPaid);
                psUpd.setString(2, status);
                psUpd.setInt(3, invoiceId);
                psUpd.executeUpdate();
            }

            conn.commit();
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
     * Retrieves all line items for an invoice.
     */
    public List<InvoiceLineItem> getLineItems(int invoiceId) {
        List<InvoiceLineItem> list = new ArrayList<>();
        String sql = "SELECT * FROM INVOICE_LINE_ITEMS WHERE invoice_id = ? ORDER BY item_id ASC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InvoiceLineItem item = new InvoiceLineItem();
                    item.setItemId(rs.getInt("item_id"));
                    item.setInvoiceId(rs.getInt("invoice_id"));
                    item.setDescription(rs.getString("description"));
                    item.setQuantity(rs.getDouble("quantity"));
                    item.setUnitPrice(rs.getDouble("unit_price"));
                    item.setLineTotal(rs.getDouble("line_total"));
                    list.add(item);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * DB: add_invoice_line_item(p_invoice_id, p_description, p_quantity, p_unit_price).
     * Recalculates invoice totals afterwards so the UI reflects the new line item immediately.
     */
    public boolean addLineItem(int invoiceId, String description, double quantity, double unitPrice) {
        String sql = "{CALL add_invoice_line_item(?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, invoiceId);
            cs.setString(2, description);
            cs.setDouble(3, quantity);
            cs.setDouble(4, unitPrice);
            cs.execute();
            return true;
        } catch (Exception ex) {
            String sql2 = "INSERT INTO INVOICE_LINE_ITEMS (invoice_id, description, quantity, unit_price, line_total) "
                       + "VALUES (?, ?, ?, ?, ?)";
            try (Connection conn = DBConnectionManager.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql2)) {
                ps.setInt(1, invoiceId);
                ps.setString(2, description);
                ps.setDouble(3, quantity);
                ps.setDouble(4, unitPrice);
                ps.setDouble(5, quantity * unitPrice);
                boolean success = ps.executeUpdate() > 0;
                if (success) recalculateInvoiceTotals(invoiceId);
                return success;
            } catch (Exception e) {
                e.printStackTrace();
                return false;
            }
        }
    }

    /**
     * Deletes a line item and recalculates invoice totals.
     */
    public boolean deleteLineItem(int itemId, int invoiceId) {
        String sql = "DELETE FROM INVOICE_LINE_ITEMS WHERE item_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, itemId);
            boolean success = ps.executeUpdate() > 0;
            if (success) recalculateInvoiceTotals(invoiceId);
            return success;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Retrieves all recorded payments for an invoice.
     */
    public List<Payment> getPayments(int invoiceId) {
        List<Payment> list = new ArrayList<>();
        String sql = "SELECT * FROM PAYMENTS WHERE invoice_id = ? ORDER BY payment_id ASC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Payment p = new Payment();
                    p.setPaymentId(rs.getInt("payment_id"));
                    p.setInvoiceId(rs.getInt("invoice_id"));
                    p.setPaymentDate(rs.getDate("payment_date"));
                    p.setAmountPaid(rs.getDouble("amount_paid"));
                    p.setPaymentMode(rs.getString("payment_mode"));
                    p.setTransactionRef(rs.getString("transaction_ref"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Flags overdue invoices where due_date has passed and status is Unpaid or Partial.
     */
    public void flagOverdueInvoices() {
        String sql = "UPDATE BILLING_INVOICES SET payment_status = 'Overdue' "
                   + "WHERE due_date < CURRENT_DATE AND payment_status IN ('Unpaid','Partial')";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Retrieves billing history for a customer.
     */
    public List<Invoice> getBillingHistory(int customerId) {
        List<Invoice> list = new ArrayList<>();
        String sql = "SELECT bi.*, c.customer_name, u.email AS customer_email, u.phone AS customer_phone, "
                   + "s.cargo_description, p_orig.port_name AS origin_port, p_dest.port_name AS dest_port "
                   + "FROM BILLING_INVOICES bi "
                   + "JOIN CUSTOMERS c ON bi.customer_id = c.customer_id "
                   + "LEFT JOIN USERS u ON c.user_id = u.user_id "
                   + "JOIN SHIPMENT s ON bi.shipment_id = s.shipment_id "
                   + "LEFT JOIN PORTS p_orig ON s.origin_port_id = p_orig.port_id "
                   + "LEFT JOIN PORTS p_dest ON s.destination_port_id = p_dest.port_id "
                   + "WHERE bi.customer_id = ? "
                   + "ORDER BY bi.invoice_date DESC";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToInvoice(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private void recalculateInvoiceTotals(int invoiceId) {
        String sumSql = "SELECT COALESCE(SUM(line_total), 0) AS new_subtotal FROM INVOICE_LINE_ITEMS WHERE invoice_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement psSum = conn.prepareStatement(sumSql)) {
            psSum.setInt(1, invoiceId);
            double subtotal = 0;
            try (ResultSet rs = psSum.executeQuery()) {
                if (rs.next()) subtotal = rs.getDouble("new_subtotal");
            }
            double tax = subtotal * 0.18;
            double total = subtotal + tax;

            String updateSql = "UPDATE BILLING_INVOICES SET subtotal_amount = ?, tax_amount = ?, total_amount = ? WHERE invoice_id = ?";
            try (PreparedStatement psUpd = conn.prepareStatement(updateSql)) {
                psUpd.setDouble(1, subtotal);
                psUpd.setDouble(2, tax);
                psUpd.setDouble(3, total);
                psUpd.setInt(4, invoiceId);
                psUpd.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Invoice mapResultSetToInvoice(ResultSet rs) throws SQLException {
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

        try {
            inv.setCustomerName(rs.getString("customer_name"));
            inv.setCustomerEmail(rs.getString("customer_email"));
            inv.setCustomerPhone(rs.getString("customer_phone"));
            inv.setCargoDescription(rs.getString("cargo_description"));
            inv.setOriginPort(rs.getString("origin_port"));
            inv.setDestinationPort(rs.getString("dest_port"));
        } catch (SQLException ignored) {}

        return inv;
    }
}
