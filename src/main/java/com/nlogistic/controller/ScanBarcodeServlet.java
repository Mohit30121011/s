package com.nlogistic.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.model.User;
import com.nlogistic.util.DBConnectionManager;

@WebServlet("/scan-barcode")
public class ScanBarcodeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        // FR8.3 — a QR code encodes a direct link to this servlet with ?value=<barcodeValue>,
        // so scanning it with a phone camera (once logged in) lands straight on the record
        // instead of a generic dashboard.
        String barcodeValue = request.getParameter("value");
        if (barcodeValue != null && !barcodeValue.trim().isEmpty()) {
            processScan(request, response, user, barcodeValue.trim(), "QR Camera Scan (Direct Link)");
            return;
        }

        request.getRequestDispatcher("/jsp/scan-barcode.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        String barcodeValue = request.getParameter("barcodeValue");
        String scanLocation = request.getParameter("scanLocation");
        if (scanLocation == null || scanLocation.isEmpty()) scanLocation = "Warehouse A";

        processScan(request, response, user, barcodeValue, scanLocation);
    }

    /**
     * FR8.3 - normalise whatever arrived in the input box.
     *
     * A QR label encodes the full direct link, and a USB/Bluetooth scanner gun
     * types that entire decoded string into the field:
     *     http://host:8080/NLogistic/scan-barcode?value=CON-101-3F9A1B
     * The lookup matched barcode_value exactly, so every QR label scanned with a
     * gun came back "Invalid Barcode! Not found in system." - the whole dock
     * workflow failed while phone-camera scans (which hit doGet with ?value=)
     * worked, which is why it went unnoticed.
     */
    static String normaliseScanInput(String raw) {
        if (raw == null) return "";
        String v = raw.trim();
        if (v.isEmpty()) return v;

        int q = v.indexOf("value=");
        if (q >= 0 && (v.startsWith("http://") || v.startsWith("https://") || v.contains("/scan-barcode"))) {
            v = v.substring(q + "value=".length());
            int amp = v.indexOf('&');
            if (amp >= 0) v = v.substring(0, amp);
            try {
                v = java.net.URLDecoder.decode(v, "UTF-8");
            } catch (Exception ignored) { /* keep the raw slice */ }
        }
        // Scanner guns commonly append a carriage return / line feed suffix.
        return v.replaceAll("[\\r\\n]", "").trim();
    }

    /** FR8.5 device telemetry, derived from the request rather than trusted input. */
    private String deviceInfo(HttpServletRequest request, String hint) {
        if (hint != null && !hint.trim().isEmpty()) return hint.trim();
        String ua = request.getHeader("User-Agent");
        if (ua == null) return "Unknown Device";
        String lower = ua.toLowerCase();
        if (lower.contains("mobile") || lower.contains("android") || lower.contains("iphone")) {
            return "Camera Scan (Mobile)";
        }
        return "Desktop Browser / Scanner Gun";
    }

    private void processScan(HttpServletRequest request, HttpServletResponse response, User user,
                              String barcodeValue, String scanLocation) throws ServletException, IOException {
        // FR8.3: a scanner gun submits the whole decoded QR URL, not the value.
        barcodeValue = normaliseScanInput(barcodeValue);

        try (Connection conn = DBConnectionManager.getConnection()) {
            // 1. Look up the barcode
            String sqlFind = "SELECT barcode_id, entity_type, entity_id FROM barcode_entries WHERE barcode_value = ?";
            int barcodeId = -1;
            String entityType = "";
            int entityId = -1;

            try (PreparedStatement ps = conn.prepareStatement(sqlFind)) {
                ps.setString(1, barcodeValue);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        barcodeId = rs.getInt("barcode_id");
                        entityType = rs.getString("entity_type");
                        entityId = rs.getInt("entity_id");
                    }
                }
            }

            if (barcodeId == -1) {
                request.setAttribute("errorMessage", "Invalid Barcode! Not found in system.");
                request.getRequestDispatcher("/jsp/scan-barcode.jsp").forward(request, response);
                return;
            }

            // 2. Tenant check BEFORE anything is read back.
            //
            // fetchEntityFields() below returns freight costs, customer names,
            // invoice totals and claim amounts. It ran with no company check at
            // all, so any Operations user who knew (or guessed, or read off the
            // unscoped barcode registry) a competitor's barcode value got their
            // complete commercial record.
            int roleId = user.getRoleId();
            Integer scopeCompany = com.nlogistic.util.RbacContext.companyId(request);
            com.nlogistic.dao.BarcodeDAO barcodeDAO = new com.nlogistic.dao.BarcodeDAO();
            if (!barcodeDAO.canAccessEntity(entityType, entityId, roleId, scopeCompany)) {
                try {
                    new com.nlogistic.dao.UserDAO().logAuditEvent(user.getUserId(),
                            "BARCODE_SCAN_DENIED", entityType + " #" + entityId + " (" + barcodeValue + ")",
                            request.getRemoteAddr());
                } catch (Exception ignored) {}
                request.setAttribute("errorMessage",
                        "This barcode belongs to another company's " + entityType.toLowerCase()
                        + ". The scan has been logged and the record is not available to you.");
                request.getRequestDispatcher("/jsp/scan-barcode.jsp").forward(request, response);
                return;
            }

            // 3. Log the scan (FR8.5) — who, when (DB default), which entity/barcode, on what device
            String device = deviceInfo(request, request.getParameter("deviceInfo"));
            String sqlLog = "INSERT INTO barcode_scan_log (barcode_id, scanned_by, scan_location, module_context) VALUES (?, ?, ?, ?)";
            try (PreparedStatement psLog = conn.prepareStatement(sqlLog)) {
                psLog.setInt(1, barcodeId);
                psLog.setInt(2, user.getUserId());
                psLog.setString(3, scanLocation);
                psLog.setString(4, device);
                psLog.executeUpdate();
            }

            // FR8.5: mirror the scan into the platform audit trail so a Super Admin
            // security review can correlate dock scans with everything else a user
            // did. Only barcode_scan_log was written before, which that review
            // never reads.
            try {
                new com.nlogistic.dao.UserDAO().logAuditEvent(user.getUserId(),
                        "BARCODE_SCAN", entityType + " #" + entityId + " (" + barcodeValue + ") @ " + scanLocation,
                        request.getRemoteAddr());
            } catch (Exception ignored) {}

            // 4. Fetch full entity detail fields (FR8.3) for every supported entity type
            Map<String, Object> fields = fetchEntityFields(conn, entityType, entityId);

            // FR8.3: a link straight to the record, instead of only a field dump.
            request.setAttribute("entityLink", entityLink(request, entityType, entityId));
            request.setAttribute("scanDevice", device);
            request.setAttribute("successMessage", "Barcode Scanned & Logged Successfully!");
            request.setAttribute("scannedBarcode", barcodeValue);
            request.setAttribute("entityType", entityType);
            request.setAttribute("entityId", entityId);
            request.setAttribute("entityFields", fields);
            request.setAttribute("entityDetails", fields.isEmpty()
                    ? (entityType + " #" + entityId + " scanned successfully.")
                    : summarize(entityType, fields));

            request.getRequestDispatcher("/jsp/scan-barcode.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "System Error: " + e.getMessage());
            request.getRequestDispatcher("/jsp/scan-barcode.jsp").forward(request, response);
        }
    }

    /** FR8.3 — where the scanned record actually lives, so the result is actionable. */
    private String entityLink(HttpServletRequest request, String entityType, int entityId) {
        String ctx = request.getContextPath();
        if (entityType == null) return null;
        switch (entityType) {
            case "Container":          return ctx + "/containers";
            case "Shipment":           return ctx + "/shipments/tracking?shipmentId=" + entityId;
            case "Stock":              return ctx + "/inventory/stock";
            case "ComplianceDocument": return ctx + "/compliance";
            case "Invoice":            return ctx + "/invoices";
            case "Claim":              return ctx + "/claims?action=view&claimId=" + entityId;
            default:                   return null;
        }
    }

    /** FR8.3 — full record lookup per entity type, not just a generic "scanned" message. */
    private Map<String, Object> fetchEntityFields(Connection conn, String entityType, int entityId) throws Exception {
        Map<String, Object> map = new LinkedHashMap<>();
        if (entityType == null) return map;

        switch (entityType) {
            case "Container": {
                String sql = "SELECT c.*, p.port_name FROM containers c LEFT JOIN ports p ON c.current_port_id = p.port_id WHERE c.container_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, entityId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            map.put("Container Number", rs.getString("container_number"));
                            map.put("Type", rs.getString("type"));
                            map.put("Size", rs.getString("size"));
                            map.put("Status", rs.getString("status"));
                            map.put("Current Port", rs.getString("port_name"));
                            map.put("Tare Weight (kg)", rs.getBigDecimal("tare_weight_kg"));
                            map.put("Max Gross Weight (kg)", rs.getBigDecimal("max_gross_weight_kg"));
                            map.put("Goods Capacity (kg)", rs.getBigDecimal("goods_capacity_kg"));
                            map.put("Goods Capacity (CBM)", rs.getBigDecimal("goods_capacity_cbm"));
                        }
                    }
                }
                break;
            }
            case "Shipment": {
                String sql = "SELECT s.*, op.port_name AS origin_name, dp.port_name AS dest_name, cu.customer_name "
                           + "FROM shipment s "
                           + "LEFT JOIN ports op ON s.origin_port_id = op.port_id "
                           + "LEFT JOIN ports dp ON s.destination_port_id = dp.port_id "
                           + "LEFT JOIN customers cu ON s.customer_id = cu.customer_id "
                           + "WHERE s.shipment_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, entityId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            map.put("Shipment ID", rs.getInt("shipment_id"));
                            map.put("Status", rs.getString("status"));
                            map.put("Cargo Description", rs.getString("cargo_description"));
                            map.put("Origin Port", rs.getString("origin_name"));
                            map.put("Destination Port", rs.getString("dest_name"));
                            map.put("Customer", rs.getString("customer_name"));
                            map.put("Container ID", rs.getInt("container_id"));
                            map.put("Cargo Weight (kg)", rs.getBigDecimal("cargo_weight_kg"));
                            map.put("Freight Cost", rs.getBigDecimal("freight_cost"));
                            map.put("Booking Date", rs.getDate("booking_date"));
                        }
                    }
                }
                break;
            }
            case "Stock": {
                String sql = "SELECT st.*, p.product_name, p.category, p.hsn_code, p.unit_of_measure "
                           + "FROM stock st JOIN products p ON st.product_id = p.product_id WHERE st.stock_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, entityId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            map.put("Product Name", rs.getString("product_name"));
                            map.put("Category", rs.getString("category"));
                            map.put("HSN Code", rs.getString("hsn_code"));
                            map.put("Quantity On Hand", rs.getBigDecimal("quantity_on_hand") + " " + rs.getString("unit_of_measure"));
                            map.put("Warehouse Location", rs.getString("warehouse_location"));
                            map.put("Batch No", rs.getString("batch_no"));
                            map.put("Expiry Date", rs.getDate("expiry_date"));
                        }
                    }
                }
                break;
            }
            case "ComplianceDocument": {
                String sql = "SELECT * FROM compliance_documents WHERE doc_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, entityId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            map.put("Document Type", rs.getString("doc_type"));
                            map.put("Document Number", rs.getString("doc_number"));
                            map.put("Issuing Authority", rs.getString("issuing_authority"));
                            map.put("Status", rs.getString("status"));
                            map.put("Issue Date", rs.getDate("issue_date"));
                            map.put("Expiry Date", rs.getDate("expiry_date"));
                            map.put("Shipment ID", rs.getInt("shipment_id"));
                        }
                    }
                }
                break;
            }
            case "Invoice": {
                String sql = "SELECT bi.*, cu.customer_name FROM billing_invoices bi LEFT JOIN customers cu ON bi.customer_id = cu.customer_id WHERE bi.invoice_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, entityId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            map.put("Invoice Number", "INV-" + rs.getInt("invoice_id"));
                            map.put("Customer", rs.getString("customer_name"));
                            map.put("Total Amount", rs.getBigDecimal("total_amount"));
                            map.put("Paid Amount", rs.getBigDecimal("paid_amount"));
                            map.put("Payment Status", rs.getString("payment_status"));
                            map.put("Invoice Date", rs.getDate("invoice_date"));
                            map.put("Due Date", rs.getDate("due_date"));
                            map.put("Shipment ID", rs.getInt("shipment_id"));
                        }
                    }
                }
                break;
            }
            case "Claim": {
                String sql = "SELECT cl.*, cu.customer_name FROM claims cl LEFT JOIN customers cu ON cl.customer_id = cu.customer_id WHERE cl.claim_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, entityId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            map.put("Claim Type", rs.getString("claim_type"));
                            map.put("Status", rs.getString("status"));
                            map.put("Customer", rs.getString("customer_name"));
                            map.put("Claimed Amount", rs.getBigDecimal("claimed_amount"));
                            map.put("Approved Amount", rs.getBigDecimal("approved_amount"));
                            map.put("Shipment ID", rs.getInt("shipment_id"));
                            map.put("Incident Date", rs.getDate("incident_date"));
                            map.put("Description", rs.getString("description"));
                        }
                    }
                }
                break;
            }
            default:
                break;
        }
        return map;
    }

    private String summarize(String entityType, Map<String, Object> fields) {
        Object first = fields.values().stream().filter(v -> v != null).findFirst().orElse(null);
        return entityType + " record retrieved" + (first != null ? " — " + first : "");
    }
}
