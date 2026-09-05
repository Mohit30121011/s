package com.nlogistic.dao;

import com.nlogistic.model.*;
import com.nlogistic.util.DBConnectionManager;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BarcodeDAO {

    /**
     * Calls: getall_barcode_entries() - returns all columns from barcode_entries.
     * DB columns: barcode_id, barcode_value, barcode_type, entity_type, entity_id, image_path, generated_by, generated_at
     */
    public List<BarcodeEntry> getAllBarcodes() {
        List<BarcodeEntry> list = new ArrayList<>();
        String sql = "{CALL getall_barcode_entries()}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {
            while (rs.next()) {
                BarcodeEntry b = new BarcodeEntry();
                b.setBarcodeId(rs.getInt("barcode_id"));
                b.setBarcodeValue(rs.getString("barcode_value"));
                b.setBarcodeType(rs.getString("barcode_type"));
                b.setEntityType(rs.getString("entity_type"));
                b.setEntityId(rs.getInt("entity_id"));
                b.setImagePath(rs.getString("image_path"));
                b.setGeneratedBy(rs.getInt("generated_by"));
                b.setGeneratedAt(rs.getTimestamp("generated_at"));
                list.add(b);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /** Paginated, searchable, category-filterable barcode library (for barcode-management.jsp). */
    public List<BarcodeEntry> searchBarcodes(String search, String category, int limit, int offset) {
        List<BarcodeEntry> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT b.barcode_id, b.barcode_value, b.barcode_type, b.entity_type, b.entity_id, b.image_path, b.generated_by, b.generated_at " +
            "FROM barcode_entries b WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (category != null && !category.trim().isEmpty() && !category.equalsIgnoreCase("All")) {
            sql.append(" AND b.entity_type = ?");
            params.add(category.trim());
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (b.barcode_value LIKE ? OR b.entity_id = ?)");
            params.add("%" + search.trim() + "%");
            try { params.add(Integer.parseInt(search.trim())); } catch (NumberFormatException e) { params.add(-1); }
        }
        sql.append(" ORDER BY b.generated_at DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BarcodeEntry b = new BarcodeEntry();
                    b.setBarcodeId(rs.getInt("barcode_id"));
                    b.setBarcodeValue(rs.getString("barcode_value"));
                    b.setBarcodeType(rs.getString("barcode_type"));
                    b.setEntityType(rs.getString("entity_type"));
                    b.setEntityId(rs.getInt("entity_id"));
                    b.setImagePath(rs.getString("image_path"));
                    b.setGeneratedBy(rs.getInt("generated_by"));
                    b.setGeneratedAt(rs.getTimestamp("generated_at"));
                    list.add(b);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public int countBarcodes(String search, String category) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM barcode_entries b WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (category != null && !category.trim().isEmpty() && !category.equalsIgnoreCase("All")) {
            sql.append(" AND b.entity_type = ?");
            params.add(category.trim());
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (b.barcode_value LIKE ? OR b.entity_id = ?)");
            params.add("%" + search.trim() + "%");
            try { params.add(Integer.parseInt(search.trim())); } catch (NumberFormatException e) { params.add(-1); }
        }
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    /** Deletes a barcode entry (and its scan-log history) by id. */
    public boolean deleteBarcode(int barcodeId) {
        try (Connection conn = DBConnectionManager.getConnection()) {
            try (PreparedStatement psLog = conn.prepareStatement("DELETE FROM barcode_scan_log WHERE barcode_id = ?")) {
                psLog.setInt(1, barcodeId);
                psLog.executeUpdate();
            }
            try (PreparedStatement psDel = conn.prepareStatement("DELETE FROM barcode_entries WHERE barcode_id = ?")) {
                psDel.setInt(1, barcodeId);
                return psDel.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /** Count of barcodes per entity_type, for the category filter tabs/counters. */
    public java.util.Map<String, Integer> getCategoryCounts() {
        java.util.Map<String, Integer> map = new java.util.LinkedHashMap<>();
        String sql = "SELECT entity_type, COUNT(*) c FROM barcode_entries GROUP BY entity_type ORDER BY entity_type";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) map.put(rs.getString("entity_type"), rs.getInt("c"));
        } catch (Exception e) { e.printStackTrace(); }
        return map;
    }

    /**
     * Calls: getall_barcode_scan_logs() - returns all columns from barcode_scan_log.
     * DB columns: scan_id, barcode_id, scanned_by, scanned_at, scan_location, module_context
     */
    public List<BarcodeScanLog> getAllScanLogs() {
        List<BarcodeScanLog> list = new ArrayList<>();
        String sql = "{CALL getall_barcode_scan_logs()}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {
            while (rs.next()) {
                BarcodeScanLog log = new BarcodeScanLog();
                log.setScanId(rs.getInt("scan_id"));
                log.setBarcodeId(rs.getInt("barcode_id"));
                log.setScannedBy(rs.getInt("scanned_by"));
                log.setScannedAt(rs.getTimestamp("scanned_at"));
                log.setScanLocation(rs.getString("scan_location"));
                log.setModuleContext(rs.getString("module_context"));
                list.add(log);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Calls: generate_barcode(p_barcode_value, p_barcode_type, p_entity_type, p_entity_id, p_image_path, p_generated_by)
     * 6 IN params, NO OUT param. Barcode value is auto-generated if empty.
     */
    public String generateBarcode(String entityType, int entityId, int generatedBy) {
        // Auto-generate barcode value: ENTITYTYPE-ENTITYID-TIMESTAMP
        String barcodeValue = entityType.toUpperCase() + "-" + entityId + "-" + System.currentTimeMillis();
        return generateBarcode(entityType, entityId, generatedBy, "Code128", barcodeValue, null);
    }

    /**
     * FR8.1/FR8.2 — same generate_barcode procedure, with the real barcode type/value/image
     * path supplied by the caller (used by BarcodeAutoGenerator for automatic barcode
     * creation on every core entity, with a genuine ZXing-rendered image on disk).
     */
    public String generateBarcode(String entityType, int entityId, int generatedBy, String barcodeType, String barcodeValue, String imagePath) {
        String sql = "{CALL generate_barcode(?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, barcodeValue);
            cs.setString(2, barcodeType);
            cs.setString(3, entityType);
            cs.setInt(4, entityId);
            cs.setString(5, imagePath);
            cs.setInt(6, generatedBy);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
        return barcodeValue;
    }

    /**
     * Calls: scan_barcode(p_barcode_value, p_scanned_by, p_scan_location, p_module_context, OUT p_entity_type, OUT p_entity_id)
     * 4 IN + 2 OUT params.
     */
    public String[] scanBarcode(String barcodeValue, String scanLocation, int scannedBy, String moduleContext) {
        String sql = "{CALL scan_barcode(?, ?, ?, ?, ?, ?)}";
        String[] result = new String[2]; // [entityType, entityId]
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, barcodeValue);
            cs.setInt(2, scannedBy);
            cs.setString(3, scanLocation);
            cs.setString(4, moduleContext);
            cs.registerOutParameter(5, Types.VARCHAR);
            cs.registerOutParameter(6, Types.INTEGER);
            cs.execute();
            result[0] = cs.getString(5);
            result[1] = String.valueOf(cs.getInt(6));
        } catch (Exception e) { e.printStackTrace(); }
        return result;
    }

    /**
     * Calls: get_scan_history_for_barcode(p_barcode_id)
     */
    public List<BarcodeScanLog> getScanHistoryForBarcode(int barcodeId) {
        List<BarcodeScanLog> list = new ArrayList<>();
        String sql = "{CALL get_scan_history_for_barcode(?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, barcodeId);
            ResultSet rs = cs.executeQuery();
            while (rs.next()) {
                BarcodeScanLog log = new BarcodeScanLog();
                log.setScanId(rs.getInt("scan_id"));
                log.setBarcodeId(rs.getInt("barcode_id"));
                log.setScannedBy(rs.getInt("scanned_by"));
                log.setScannedAt(rs.getTimestamp("scanned_at"));
                log.setScanLocation(rs.getString("scan_location"));
                log.setModuleContext(rs.getString("module_context"));
                list.add(log);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Calls: get_entity_by_barcode(p_barcode_value)
     */
    public String[] getEntityByBarcode(String barcodeValue) {
        String sql = "{CALL get_entity_by_barcode(?)}";
        String[] result = new String[3]; // [entityType, entityId, generatedAt]
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, barcodeValue);
            ResultSet rs = cs.executeQuery();
            if (rs.next()) {
                result[0] = rs.getString("entity_type");
                result[1] = String.valueOf(rs.getInt("entity_id"));
                result[2] = rs.getString("generated_at");
            }
        } catch (Exception e) { e.printStackTrace(); }
        return result;
    }

    /* ==================================================================
     * Multi-tenancy for Module 8.
     *
     * Every barcode query in this class ran unscoped: the registry listed
     * every tenant's barcodes, the counts and category tallies were global,
     * and deleteBarcode() would remove any row by id. Because a barcode value
     * is the key to the scanner's full record lookup, an unscoped registry
     * also handed staff the exact values needed to read a rival's shipments.
     *
     * A barcode has no company of its own - it inherits the company of the
     * entity it labels, which is reached by a different path for each of the
     * six entity types. TENANT_JOIN resolves all six in one go.
     * ================================================================== */
    private static final String TENANT_JOIN =
          " LEFT JOIN containers bc ON b.entity_type = 'Container' AND bc.container_id = b.entity_id "
        + " LEFT JOIN stock bk ON b.entity_type = 'Stock' AND bk.stock_id = b.entity_id "
        + " LEFT JOIN shipment bs ON b.entity_type = 'Shipment' AND bs.shipment_id = b.entity_id "
        + " LEFT JOIN compliance_documents bd ON b.entity_type = 'ComplianceDocument' AND bd.doc_id = b.entity_id "
        + " LEFT JOIN billing_invoices bi ON b.entity_type = 'Invoice' AND bi.invoice_id = b.entity_id "
        + " LEFT JOIN claims bcl ON b.entity_type = 'Claim' AND bcl.claim_id = b.entity_id "
        + " LEFT JOIN shipment ls ON ls.shipment_id = COALESCE(bs.shipment_id, bd.shipment_id, bi.shipment_id, bcl.shipment_id) "
        + " LEFT JOIN containers lc ON lc.container_id = ls.container_id ";

    /** Restricts a TENANT_JOIN query to one company. Binds the company id 3 times. */
    private static final String TENANT_WHERE =
          " AND (bc.owner_company_id = ? OR lc.owner_company_id = ? "
        + "      OR bk.company_id = ? OR ls.created_by IN (SELECT user_id FROM users WHERE company_id = ?)) ";

    /** True when this role must be limited to its own company's barcodes. */
    public static boolean isTenantScoped(int roleId) {
        return roleId >= 2 && roleId <= 4;
    }

    private static int bindTenant(PreparedStatement ps, int idx, Integer companyId) throws SQLException {
        int cid = (companyId != null) ? companyId : -1;
        for (int i = 0; i < 4; i++) ps.setInt(idx++, cid);
        return idx;
    }

    /** Tenant-scoped registry page. */
    public List<BarcodeEntry> searchBarcodesScoped(String search, String category, int limit, int offset,
                                                   int roleId, Integer companyId) {
        List<BarcodeEntry> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT b.* FROM barcode_entries b").append(TENANT_JOIN)
                .append(" WHERE 1=1 ");
        boolean scoped = isTenantScoped(roleId);
        if (scoped) sql.append(TENANT_WHERE);
        boolean hasSearch = search != null && !search.trim().isEmpty();
        boolean hasCat = category != null && !category.trim().isEmpty() && !"All".equalsIgnoreCase(category.trim());
        if (hasSearch) sql.append(" AND (b.barcode_value LIKE ? OR CAST(b.entity_id AS CHAR) LIKE ?) ");
        if (hasCat) sql.append(" AND b.entity_type = ? ");
        sql.append(" ORDER BY b.barcode_id DESC LIMIT ? OFFSET ?");

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int i = 1;
            if (scoped) i = bindTenant(ps, i, companyId);
            if (hasSearch) { String like = "%" + search.trim() + "%"; ps.setString(i++, like); ps.setString(i++, like); }
            if (hasCat) ps.setString(i++, category.trim());
            ps.setInt(i++, limit);
            ps.setInt(i, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapEntry(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /** Tenant-scoped total, so pagination matches what is actually listed. */
    public int countBarcodesScoped(String search, String category, int roleId, Integer companyId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM barcode_entries b").append(TENANT_JOIN)
                .append(" WHERE 1=1 ");
        boolean scoped = isTenantScoped(roleId);
        if (scoped) sql.append(TENANT_WHERE);
        boolean hasSearch = search != null && !search.trim().isEmpty();
        boolean hasCat = category != null && !category.trim().isEmpty() && !"All".equalsIgnoreCase(category.trim());
        if (hasSearch) sql.append(" AND (b.barcode_value LIKE ? OR CAST(b.entity_id AS CHAR) LIKE ?) ");
        if (hasCat) sql.append(" AND b.entity_type = ? ");
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int i = 1;
            if (scoped) i = bindTenant(ps, i, companyId);
            if (hasSearch) { String like = "%" + search.trim() + "%"; ps.setString(i++, like); ps.setString(i++, like); }
            if (hasCat) ps.setString(i, category.trim());
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getInt(1); }
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    /** Tenant-scoped counts for the category chips. */
    public java.util.Map<String, Integer> getCategoryCountsScoped(int roleId, Integer companyId) {
        java.util.Map<String, Integer> map = new java.util.LinkedHashMap<>();
        StringBuilder sql = new StringBuilder(
                "SELECT b.entity_type, COUNT(*) n FROM barcode_entries b").append(TENANT_JOIN).append(" WHERE 1=1 ");
        boolean scoped = isTenantScoped(roleId);
        if (scoped) sql.append(TENANT_WHERE);
        sql.append(" GROUP BY b.entity_type");
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (scoped) bindTenant(ps, 1, companyId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) map.put(rs.getString(1), rs.getInt(2));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return map;
    }

    /**
     * May this caller see the entity a barcode points at?
     *
     * This is the check the scanner never made: a barcode value was enough to
     * pull back another carrier's freight cost, customer name and cargo detail.
     */
    public boolean canAccessEntity(String entityType, int entityId, int roleId, Integer companyId) {
        if (roleId == 1) return true;
        if (!isTenantScoped(roleId)) return false;
        String sql = "SELECT 1 FROM barcode_entries b" + TENANT_JOIN
                   + " WHERE b.entity_type = ? AND b.entity_id = ? " + TENANT_WHERE + " LIMIT 1";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entityType);
            ps.setInt(2, entityId);
            bindTenant(ps, 3, companyId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    /** Tenant-scoped check used before a delete. */
    public boolean canAccessBarcode(int barcodeId, int roleId, Integer companyId) {
        if (roleId == 1) return true;
        if (!isTenantScoped(roleId)) return false;
        String sql = "SELECT 1 FROM barcode_entries b" + TENANT_JOIN
                   + " WHERE b.barcode_id = ? " + TENANT_WHERE + " LIMIT 1";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, barcodeId);
            bindTenant(ps, 2, companyId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    /** The existing barcode for an entity, if one has already been issued (FR8.6). */
    public BarcodeEntry findByEntity(String entityType, int entityId) {
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT * FROM barcode_entries WHERE entity_type = ? AND entity_id = ? ORDER BY barcode_id LIMIT 1")) {
            ps.setString(1, entityType);
            ps.setInt(2, entityId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return mapEntry(rs); }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    /**
     * FR8.5 scan history for the register, scoped to the caller's tenant.
     * Returned as maps because the view only needs flat display fields.
     */
    public List<java.util.Map<String, Object>> getRecentScans(int roleId, Integer companyId, int limit) {
        List<java.util.Map<String, Object>> out = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
              "SELECT l.scan_id, l.scanned_at, l.scan_location, l.module_context, "
            + "       b.barcode_value, b.entity_type, b.entity_id, u.username "
            + "FROM barcode_scan_log l "
            + "JOIN barcode_entries b ON b.barcode_id = l.barcode_id "
            + "LEFT JOIN users u ON u.user_id = l.scanned_by").append(TENANT_JOIN).append(" WHERE 1=1 ");
        boolean scoped = isTenantScoped(roleId);
        if (scoped) sql.append(TENANT_WHERE);
        sql.append(" ORDER BY l.scan_id DESC LIMIT ?");
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int i = 1;
            if (scoped) i = bindTenant(ps, i, companyId);
            ps.setInt(i, Math.max(1, limit));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> m = new java.util.LinkedHashMap<>();
                    m.put("scanId", rs.getInt("scan_id"));
                    m.put("scannedAt", rs.getTimestamp("scanned_at"));
                    m.put("location", rs.getString("scan_location"));
                    m.put("device", rs.getString("module_context"));
                    m.put("barcodeValue", rs.getString("barcode_value"));
                    m.put("entityType", rs.getString("entity_type"));
                    m.put("entityId", rs.getInt("entity_id"));
                    m.put("username", rs.getString("username"));
                    out.add(m);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return out;
    }

    /**
     * Retrieves up to 150 available entities of a given type with friendly display labels,
     * ordered so unassigned entities (without a barcode) appear first.
     */
    public List<Map<String, Object>> getAvailableEntitiesForType(String entityType, int roleId, Integer companyId) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (entityType == null || entityType.trim().isEmpty()) {
            entityType = "Container";
        }

        String sql = "";
        switch (entityType) {
            case "Container":
                sql = "SELECT c.container_id AS id, " +
                      "CONCAT('Container #', c.container_id, ' - ', c.container_number, ' (', c.type, ' | ', c.status, ')') AS label, " +
                      "b.barcode_value " +
                      "FROM containers c " +
                      "LEFT JOIN barcode_entries b ON b.entity_type = 'Container' AND b.entity_id = c.container_id " +
                      "WHERE (? IS NULL OR c.owner_company_id = ?) " +
                      "ORDER BY (b.barcode_value IS NULL) DESC, c.container_id DESC LIMIT 150";
                break;
            case "Shipment":
                sql = "SELECT s.shipment_id AS id, " +
                      "CONCAT('Shipment #', s.shipment_id, ' - ', IFNULL(s.cargo_description, 'Freight Consignment'), ' (', s.status, ')') AS label, " +
                      "b.barcode_value " +
                      "FROM shipment s " +
                      "LEFT JOIN barcode_entries b ON b.entity_type = 'Shipment' AND b.entity_id = s.shipment_id " +
                      "ORDER BY (b.barcode_value IS NULL) DESC, s.shipment_id DESC LIMIT 150";
                break;
            case "Stock":
                sql = "SELECT st.stock_id AS id, " +
                      "CONCAT('Stock #', st.stock_id, ' - Batch: ', IFNULL(st.batch_no, 'N/A'), ' (Qty: ', st.quantity_on_hand, ')') AS label, " +
                      "b.barcode_value " +
                      "FROM stock st " +
                      "LEFT JOIN barcode_entries b ON b.entity_type = 'Stock' AND b.entity_id = st.stock_id " +
                      "WHERE (? IS NULL OR st.company_id = ?) " +
                      "ORDER BY (b.barcode_value IS NULL) DESC, st.stock_id DESC LIMIT 150";
                break;
            case "ComplianceDocument":
                sql = "SELECT cd.doc_id AS id, " +
                      "CONCAT('Doc #', cd.doc_id, ' - ', cd.doc_type, ' (No: ', IFNULL(cd.doc_number, 'N/A'), ' | ', cd.status, ')') AS label, " +
                      "b.barcode_value " +
                      "FROM compliance_documents cd " +
                      "LEFT JOIN barcode_entries b ON b.entity_type = 'ComplianceDocument' AND b.entity_id = cd.doc_id " +
                      "ORDER BY (b.barcode_value IS NULL) DESC, cd.doc_id DESC LIMIT 150";
                break;
            case "Invoice":
                sql = "SELECT inv.invoice_id AS id, " +
                      "CONCAT('Invoice #', inv.invoice_id, ' - ₹', FORMAT(ABS(inv.total_amount), 2), ' (', inv.payment_status, ')') AS label, " +
                      "b.barcode_value " +
                      "FROM billing_invoices inv " +
                      "LEFT JOIN barcode_entries b ON b.entity_type = 'Invoice' AND b.entity_id = inv.invoice_id " +
                      "ORDER BY (b.barcode_value IS NULL) DESC, inv.invoice_id DESC LIMIT 150";
                break;
            case "Claim":
                sql = "SELECT cl.claim_id AS id, " +
                      "CONCAT('Claim #', cl.claim_id, ' - ', cl.claim_type, ' (', cl.status, ')') AS label, " +
                      "b.barcode_value " +
                      "FROM claims cl " +
                      "LEFT JOIN barcode_entries b ON b.entity_type = 'Claim' AND b.entity_id = cl.claim_id " +
                      "ORDER BY (b.barcode_value IS NULL) DESC, cl.claim_id DESC LIMIT 150";
                break;
            default:
                return list;
        }

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (entityType.equals("Container") || entityType.equals("Stock")) {
                if (roleId == 1) { // Super Admin has global tenant visibility
                    ps.setNull(1, Types.INTEGER);
                    ps.setNull(2, Types.INTEGER);
                } else {
                    ps.setObject(1, companyId);
                    ps.setObject(2, companyId);
                }
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getInt("id"));
                    map.put("label", rs.getString("label"));
                    String bVal = rs.getString("barcode_value");
                    map.put("hasBarcode", bVal != null && !bVal.isEmpty());
                    map.put("barcodeValue", bVal != null ? bVal : "");
                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Shared row mapper for the queries above. */
    private BarcodeEntry mapEntry(ResultSet rs) throws SQLException {
        BarcodeEntry b = new BarcodeEntry();
        b.setBarcodeId(rs.getInt("barcode_id"));
        b.setBarcodeValue(rs.getString("barcode_value"));
        b.setBarcodeType(rs.getString("barcode_type"));
        b.setEntityType(rs.getString("entity_type"));
        b.setEntityId(rs.getInt("entity_id"));
        b.setImagePath(rs.getString("image_path"));
        b.setGeneratedBy(rs.getInt("generated_by"));
        b.setGeneratedAt(rs.getTimestamp("generated_at"));
        return b;
    }
}
