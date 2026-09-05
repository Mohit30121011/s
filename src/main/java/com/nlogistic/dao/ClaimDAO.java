package com.nlogistic.dao;

import com.nlogistic.model.*;
import com.nlogistic.util.DBConnectionManager;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ClaimDAO {

    /** Map a ResultSet row to a Claim object (tolerates absence of the enriched/joined columns). */
    private Claim mapClaim(ResultSet rs) throws SQLException {
        Claim c = new Claim();
        c.setClaimId(rs.getInt("claim_id"));
        c.setShipmentId(rs.getInt("shipment_id"));
        c.setContainerId((Integer) rs.getObject("container_id"));
        c.setProductId((Integer) rs.getObject("product_id"));
        c.setCustomerId(rs.getInt("customer_id"));
        c.setClaimType(rs.getString("claim_type"));
        c.setDescription(rs.getString("description"));
        c.setIncidentDate(rs.getDate("incident_date"));
        c.setClaimedAmount(rs.getDouble("claimed_amount"));
        c.setApprovedAmount(rs.getDouble("approved_amount"));
        c.setReasonId((Integer) rs.getObject("reason_id"));
        c.setStatus(rs.getString("status"));
        c.setFiledBy(rs.getInt("filed_by"));
        c.setFiledDate(rs.getTimestamp("filed_date"));
        c.setResolvedBy((Integer) rs.getObject("resolved_by"));
        c.setResolvedDate(rs.getTimestamp("resolved_date"));
        // Extended joined fields (may not always be present depending on the query)
        try { c.setCustomerName(rs.getString("customer_name")); } catch (Exception ignored) {}
        try { c.setReasonName(rs.getString("reason_name")); } catch (Exception ignored) {}
        try { c.setFiledByName(rs.getString("filed_by_name")); } catch (Exception ignored) {}
        try { c.setResolvedByName(rs.getString("resolved_by_name")); } catch (Exception ignored) {}
        try { c.setProductName(rs.getString("product_name")); } catch (Exception ignored) {}
        try { c.setContainerNumber(rs.getString("container_number")); } catch (Exception ignored) {}
        return c;
    }

    /** Get all claims with joined customer + loss reason names. */
    public List<Claim> getAllClaims() {
        List<Claim> list = new ArrayList<>();
        String sql = "SELECT c.*, cu.customer_name, lr.reason_name " +
                     "FROM CLAIMS c " +
                     "LEFT JOIN CUSTOMERS cu ON c.customer_id = cu.customer_id " +
                     "LEFT JOIN LOSS_REASONS lr ON c.reason_id = lr.reason_id " +
                     "ORDER BY c.claim_id DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapClaim(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Get a single claim with joined customer/reason/filer/resolver/product/container details.
     * NOTE: the live database does NOT have a get_claim_with_details stored procedure, so this
     * is composed from plain SELECTs over existing tables rather than calling a procedure.
     */
    public Claim getClaimById(int claimId) {
        String sql = "SELECT c.*, cu.customer_name, lr.reason_name, " +
                     "fu.username AS filed_by_name, ru.username AS resolved_by_name, " +
                     "p.product_name, cnt.container_number " +
                     "FROM CLAIMS c " +
                     "LEFT JOIN CUSTOMERS cu ON c.customer_id = cu.customer_id " +
                     "LEFT JOIN LOSS_REASONS lr ON c.reason_id = lr.reason_id " +
                     "LEFT JOIN USERS fu ON c.filed_by = fu.user_id " +
                     "LEFT JOIN USERS ru ON c.resolved_by = ru.user_id " +
                     "LEFT JOIN PRODUCTS p ON c.product_id = p.product_id " +
                     "LEFT JOIN CONTAINERS cnt ON c.container_id = cnt.container_id " +
                     "WHERE c.claim_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, claimId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapClaim(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Fallback: plain unjoined lookup so a claim can still be viewed if a join fails
            String simpleSql = "SELECT * FROM CLAIMS WHERE claim_id = ?";
            try (Connection conn = DBConnectionManager.getConnection();
                 PreparedStatement ps = conn.prepareStatement(simpleSql)) {
                ps.setInt(1, claimId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return mapClaim(rs);
                }
            } catch (Exception e2) {
                e2.printStackTrace();
            }
        }
        return null;
    }

    /** DB signature: get_claims_by_status(p_status) */
    public List<Claim> getClaimsByStatus(String status) {
        List<Claim> list = new ArrayList<>();
        String sql = "{CALL get_claims_by_status(?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, status);
            ResultSet rs = cs.executeQuery();
            while (rs.next()) list.add(mapClaim(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * File a new claim.
     * DB signature: file_claim(p_shipment_id, p_container_id, p_product_id, p_customer_id,
     *   p_claim_type, p_description, p_incident_date, p_claimed_amount, p_reason_id, p_filed_by)
     * Returns the new claim_id when it can be determined (either via a returned result set or
     * LAST_INSERT_ID() on the same connection), otherwise returns -1 without throwing.
     */
    public int fileClaim(int shipmentId, Integer containerId, Integer productId, int customerId,
                          String claimType, String description, java.sql.Date incidentDate,
                          double claimedAmount, Integer reasonId, int filedBy) {
        String sql = "{CALL file_claim(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, shipmentId);
            if (containerId != null) cs.setInt(2, containerId); else cs.setNull(2, Types.INTEGER);
            if (productId != null) cs.setInt(3, productId); else cs.setNull(3, Types.INTEGER);
            cs.setInt(4, customerId);
            cs.setString(5, claimType);
            cs.setString(6, description);
            cs.setDate(7, incidentDate);
            cs.setDouble(8, claimedAmount);
            if (reasonId != null) cs.setInt(9, reasonId); else cs.setNull(9, Types.INTEGER);
            cs.setInt(10, filedBy);

            boolean hasResult = cs.execute();
            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs != null && rs.next()) {
                        try { return rs.getInt("new_claim_id"); } catch (Exception ignored) {}
                        try { return rs.getInt(1); } catch (Exception ignored) {}
                    }
                }
            }
            // Fallback: ask MySQL for the last auto-increment id generated on this connection
            try (Statement st = conn.createStatement();
                 ResultSet rs2 = st.executeQuery("SELECT LAST_INSERT_ID() AS id")) {
                if (rs2.next()) {
                    int id = rs2.getInt("id");
                    if (id > 0) return id;
                }
            } catch (Exception ignored) {}
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Reduce a database failure to the message worth showing a user.
     *
     * The claims table carries BEFORE UPDATE triggers that refuse illegal
     * transitions (SQLSTATE 45000). Those refusals used to be caught and
     * discarded here, so the servlet went on to report "Claim settled" for a
     * change the database had rejected outright.
     */
    private String failureReason(Exception e, String fallback) {
        String m = (e != null && e.getMessage() != null) ? e.getMessage() : "";
        int cut = m.lastIndexOf(": ");
        if (cut >= 0 && cut + 2 < m.length()) m = m.substring(cut + 2);
        m = m.trim();
        if (m.isEmpty() || m.length() > 220) return fallback;
        return m;
    }

    /**
     * Move claim Filed -> Under Review.
     * DB: review_claim(claim_id, new_status, approved_amount, changed_by, remark)
     * @return null when applied, otherwise why the database refused it.
     */
    public String startReview(int claimId, int changedBy, String remark) {
        String sql = "{CALL review_claim(?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, claimId);
            cs.setString(2, "Under Review");
            cs.setNull(3, Types.DECIMAL);
            cs.setInt(4, changedBy);
            cs.setString(5, remark != null && !remark.isEmpty() ? remark : "Claim taken under review");
            cs.execute();
            return null;
        } catch (Exception e) {
            e.printStackTrace();
            return failureReason(e, "The claim could not be moved to Under Review.");
        }
    }

    /** Move claim Under Review -> Approved with approved amount. */
    public String approveClaim(int claimId, double approvedAmount, int changedBy, String remark) {
        String sql = "{CALL review_claim(?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, claimId);
            cs.setString(2, "Approved");
            cs.setDouble(3, approvedAmount);
            cs.setInt(4, changedBy);
            cs.setString(5, remark != null && !remark.isEmpty() ? remark : "Claim approved");
            cs.execute();
            return null;
        } catch (Exception e) {
            e.printStackTrace();
            return failureReason(e, "The claim could not be approved.");
        }
    }

    /** Backward-compatible alias matching the original review_claim(claimId, newStatus, approvedAmount, changedBy, remark) call shape. */
    public void reviewClaim(int claimId, String newStatus, double approvedAmount, int changedBy, String remark) {
        String sql = "{CALL review_claim(?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, claimId);
            cs.setString(2, newStatus);
            cs.setDouble(3, approvedAmount);
            cs.setInt(4, changedBy);
            cs.setString(5, remark);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /** Move claim Under Review -> Rejected. DB: reject_claim(claim_id, rejected_by, remark) */
    public String rejectClaim(int claimId, int rejectedBy, String remark) {
        String sql = "{CALL reject_claim(?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, claimId);
            cs.setInt(2, rejectedBy);
            cs.setString(3, remark != null && !remark.isEmpty() ? remark : "Claim rejected");
            cs.execute();
            return null;
        } catch (Exception e) {
            e.printStackTrace();
            return failureReason(e, "The claim could not be rejected.");
        }
    }

    /** Move claim Approved -> Settled. DB: settle_claim(claim_id, resolved_by) */
    public String settleClaim(int claimId, int resolvedBy) {
        String sql = "{CALL settle_claim(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, claimId);
            cs.setInt(2, resolvedBy);
            cs.execute();
            return null;
        } catch (Exception e) {
            e.printStackTrace();
            return failureReason(e, "The claim could not be settled.");
        }
    }

    /** DB signature: add_claim_document(p_claim_id, p_doc_type, p_file_path, p_uploaded_by). Returns false (instead of silently swallowing) on failure so the caller can surface a real error. */
    public boolean addClaimDocument(int claimId, String docType, String filePath, int uploadedBy) {
        String sql = "{CALL add_claim_document(?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, claimId);
            cs.setString(2, docType);
            cs.setString(3, filePath);
            cs.setInt(4, uploadedBy);
            cs.execute();
            return true;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    /** Get full status history for a claim (with username joined when available). DB: get_claim_history(p_claim_id) */
    public List<ClaimHistory> getClaimHistory(int claimId) {
        List<ClaimHistory> list = new ArrayList<>();
        String sql = "{CALL get_claim_history(?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, claimId);
            ResultSet rs = cs.executeQuery();
            while (rs.next()) {
                ClaimHistory h = new ClaimHistory();
                h.setHistoryId(rs.getInt("history_id"));
                h.setClaimId(rs.getInt("claim_id"));
                h.setPreviousStatus(rs.getString("old_status"));
                h.setNewStatus(rs.getString("new_status"));
                h.setChangedBy(rs.getInt("changed_by"));
                h.setRemarks(rs.getString("remark"));
                h.setChangedAt(rs.getTimestamp("changed_at"));
                try { h.setChangerName(rs.getString("changer_name")); } catch (Exception ignored) {}
                list.add(h);
            }
        } catch (Exception e) { e.printStackTrace(); }

        // Enrich with changer usernames if the procedure didn't already join them
        if (!list.isEmpty() && list.get(0).getChangerName() == null) {
            for (ClaimHistory h : list) {
                try (Connection conn = DBConnectionManager.getConnection();
                     PreparedStatement ps = conn.prepareStatement("SELECT username FROM USERS WHERE user_id = ?")) {
                    ps.setInt(1, h.getChangedBy());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) h.setChangerName(rs.getString("username"));
                    }
                } catch (Exception ignored) {}
            }
        }
        return list;
    }

    /** Get documents attached to a claim. Falls back to a plain SELECT if getall_claim_documents doesn't exist. */
    public List<ClaimDocument> getClaimDocuments(int claimId) {
        List<ClaimDocument> list = new ArrayList<>();
        String sql = "{CALL getall_claim_documents(?)}";
        boolean procedureSuccess = false;
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, claimId);
            ResultSet rs = cs.executeQuery();
            while (rs.next()) {
                list.add(mapClaimDocument(rs));
            }
            procedureSuccess = true;
        } catch (Exception ignored) {}

        if (!procedureSuccess) {
            String fallback = "SELECT * FROM CLAIM_DOCUMENTS WHERE claim_id = ? ORDER BY doc_id ASC";
            try (Connection conn = DBConnectionManager.getConnection();
                 PreparedStatement ps = conn.prepareStatement(fallback)) {
                ps.setInt(1, claimId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) list.add(mapClaimDocument(rs));
                }
            } catch (Exception e) { e.printStackTrace(); }
        }
        return list;
    }

    private ClaimDocument mapClaimDocument(ResultSet rs) throws SQLException {
        ClaimDocument d = new ClaimDocument();
        d.setDocId(rs.getInt("doc_id"));
        d.setClaimId(rs.getInt("claim_id"));
        d.setDocType(rs.getString("doc_type"));
        d.setFilePath(rs.getString("file_path"));
        try { d.setUploadedBy(rs.getInt("uploaded_by")); } catch (Exception ignored) {}
        try { d.setUploadedAt(rs.getTimestamp("uploaded_at")); } catch (Exception ignored) {}
        return d;
    }

    /** Get KPI stats for the claims dashboard (optionally scoped to a customer). */
    public Map<String, Object> getClaimStats() {
        return getClaimStats(null);
    }

    public Map<String, Object> getClaimStats(Integer customerId) {
        Map<String, Object> stats = new HashMap<>();
        boolean isCustomer = (customerId != null && customerId > 0);
        String sql = "SELECT " +
                     "COUNT(*) AS total, " +
                     "SUM(CASE WHEN status='Filed' THEN 1 ELSE 0 END) AS filed, " +
                     "SUM(CASE WHEN status='Under Review' THEN 1 ELSE 0 END) AS under_review, " +
                     "SUM(CASE WHEN status='Approved' THEN 1 ELSE 0 END) AS approved, " +
                     "SUM(CASE WHEN status='Settled' THEN 1 ELSE 0 END) AS settled, " +
                     "SUM(CASE WHEN status='Rejected' THEN 1 ELSE 0 END) AS rejected, " +
                     "COALESCE(SUM(claimed_amount), 0) AS total_claimed, " +
                     "COALESCE(SUM(approved_amount), 0) AS total_approved " +
                     "FROM CLAIMS" + (isCustomer ? " WHERE customer_id = ?" : "");
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (isCustomer) ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("total", rs.getInt("total"));
                    stats.put("filed", rs.getInt("filed"));
                    stats.put("underReview", rs.getInt("under_review"));
                    stats.put("approved", rs.getInt("approved"));
                    stats.put("settled", rs.getInt("settled"));
                    stats.put("rejected", rs.getInt("rejected"));
                    stats.put("totalClaimed", rs.getDouble("total_claimed"));
                    stats.put("totalApproved", rs.getDouble("total_approved"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            stats.put("total", 0); stats.put("filed", 0); stats.put("underReview", 0);
            stats.put("approved", 0); stats.put("settled", 0); stats.put("rejected", 0);
            stats.put("totalClaimed", 0.0); stats.put("totalApproved", 0.0);
        }
        return stats;
    }

    /** Get claims belonging to a specific customer (customer self-service isolation). */
    public List<Claim> getClaimsByCustomer(int customerId) {
        List<Claim> list = new ArrayList<>();
        String sql = "SELECT c.*, cu.customer_name, lr.reason_name " +
                     "FROM CLAIMS c " +
                     "LEFT JOIN CUSTOMERS cu ON c.customer_id = cu.customer_id " +
                     "LEFT JOIN LOSS_REASONS lr ON c.reason_id = lr.reason_id " +
                     "WHERE c.customer_id = ? ORDER BY c.claim_id DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapClaim(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Get shipments available for the File Claim dropdown.
     * Customers see only their own shipments; staff sees all.
     */
    public List<Object[]> getShipmentsForUser(int userId, int roleId, Integer customerId) {
        return getShipmentsForUser(userId, roleId, customerId, null);
    }

    /**
     * Shipments the caller may file a claim against.
     *
     * The company branch used to have no WHERE clause at all, so the "File a
     * Claim" dropdown listed every shipment on the platform together with the
     * owning customer's name - a directory of rival tenants' customers, and the
     * exact ids needed for the cross-tenant filing this module also allowed.
     */
    public List<Object[]> getShipmentsForUser(int userId, int roleId, Integer customerId, Integer companyId) {
        List<Object[]> list = new ArrayList<>();
        String sql;
        boolean restrictToCustomer = (roleId == 5 && customerId != null && customerId > 0);
        boolean restrictToCompany  = (roleId >= 2 && roleId <= 4);
        String base = "SELECT s.shipment_id, s.cargo_description, s.status, s.customer_id, cu.customer_name, s.container_id " +
                      "FROM SHIPMENT s " +
                      "LEFT JOIN CUSTOMERS cu ON s.customer_id = cu.customer_id " +
                      "LEFT JOIN CONTAINERS cnt ON cnt.container_id = s.container_id ";
        if (restrictToCustomer) {
            sql = base + "WHERE s.customer_id = ? ORDER BY s.shipment_id DESC";
        } else if (restrictToCompany) {
            sql = base + "WHERE (cnt.owner_company_id = ? OR s.created_by IN "
                       + "(SELECT user_id FROM users WHERE company_id = ?)) ORDER BY s.shipment_id DESC";
        } else {
            sql = base + "ORDER BY s.shipment_id DESC";
        }
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (restrictToCustomer) {
                ps.setInt(1, customerId);
            } else if (restrictToCompany) {
                int cid = (companyId != null) ? companyId : -1;
                ps.setInt(1, cid);
                ps.setInt(2, cid);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Object[]{
                    rs.getInt("shipment_id"),
                    rs.getString("cargo_description"),
                    rs.getString("status"),
                    rs.getInt("customer_id"),
                    rs.getString("customer_name"),
                    rs.getObject("container_id")
                });
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /** Get all loss reasons for dropdowns. */
    public List<LossReason> getAllLossReasons() {
        List<LossReason> list = new ArrayList<>();
        String sql = "SELECT reason_id, reason_code, reason_name FROM LOSS_REASONS ORDER BY reason_name";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LossReason lr = new LossReason();
                lr.setReasonId(rs.getInt("reason_id"));
                lr.setReasonCode(rs.getString("reason_code"));
                lr.setReasonName(rs.getString("reason_name"));
                list.add(lr);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /* ==================================================================
     * FR7.7 - "The claims register shall be filterable and scoped to the
     * caller's tenant."
     *
     * The register previously loaded every claim in the system and then
     * dropped the ones the caller could not see with a per-row
     * canAccessShipment() query - one round trip per claim, and a full
     * cross-tenant read before any filtering. Scoping now happens in SQL,
     * alongside the status / type / date / customer filters the SRS asks for
     * and which the old query had no support for at all.
     * ================================================================== */
    public List<Claim> getClaimsFiltered(int roleId, Integer companyId, Integer customerId,
                                         String status, String type,
                                         String dateFrom, String dateTo,
                                         Integer filterCustomerId, Integer filterCompanyId) {
        List<Claim> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
              "SELECT c.*, cu.customer_name, lr.reason_name "
            + "FROM CLAIMS c "
            + "LEFT JOIN CUSTOMERS cu ON c.customer_id = cu.customer_id "
            + "LEFT JOIN LOSS_REASONS lr ON c.reason_id = lr.reason_id "
            + "LEFT JOIN SHIPMENT s ON s.shipment_id = c.shipment_id "
            + "LEFT JOIN CONTAINERS cnt ON cnt.container_id = s.container_id "
            + "WHERE 1=1 ");
        List<Object> args = new ArrayList<>();

        // Tenant / self scoping. A Super Admin sees everything unless they pick
        // a company; everyone else is pinned to their own regardless of input.
        if (roleId == 5) {
            sql.append("AND c.customer_id = ? ");
            args.add(customerId != null ? customerId : -1);
        } else if (roleId >= 2 && roleId <= 4) {
            sql.append("AND (cnt.owner_company_id = ? OR s.created_by IN "
                     + "(SELECT user_id FROM users WHERE company_id = ?)) ");
            int cid = (companyId != null) ? companyId : -1;
            args.add(cid); args.add(cid);
        } else if (roleId == 1 && filterCompanyId != null) {
            sql.append("AND (cnt.owner_company_id = ? OR s.created_by IN "
                     + "(SELECT user_id FROM users WHERE company_id = ?)) ");
            args.add(filterCompanyId); args.add(filterCompanyId);
        }

        if (status != null && !status.trim().isEmpty()) { sql.append("AND c.status = ? "); args.add(status.trim()); }
        if (type   != null && !type.trim().isEmpty())   { sql.append("AND c.claim_type = ? "); args.add(type.trim()); }
        if (dateFrom != null && !dateFrom.trim().isEmpty()) { sql.append("AND c.incident_date >= ? "); args.add(dateFrom.trim()); }
        if (dateTo   != null && !dateTo.trim().isEmpty())   { sql.append("AND c.incident_date <= ? "); args.add(dateTo.trim()); }
        // A customer may never filter to somebody else's account.
        if (roleId != 5 && filterCustomerId != null) { sql.append("AND c.customer_id = ? "); args.add(filterCustomerId); }

        sql.append("ORDER BY c.claim_id DESC");

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < args.size(); i++) ps.setObject(i + 1, args.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapClaim(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * May this caller open / act on this claim?
     *
     * Gap 4: only customers were checked. Company staff could read, approve and
     * settle a rival tenant's claim just by putting its id in the URL, because
     * the single-claim path did no company check at all.
     */
    public boolean canAccessClaim(int claimId, int roleId, Integer companyId, Integer customerId) {
        if (roleId == 1) return true;
        String sql;
        if (roleId == 5) {
            sql = "SELECT 1 FROM CLAIMS WHERE claim_id = ? AND customer_id = ?";
        } else {
            sql = "SELECT 1 FROM CLAIMS c "
                + "LEFT JOIN SHIPMENT s ON s.shipment_id = c.shipment_id "
                + "LEFT JOIN CONTAINERS cnt ON cnt.container_id = s.container_id "
                + "WHERE c.claim_id = ? AND (cnt.owner_company_id = ? OR s.created_by IN "
                + "(SELECT user_id FROM users WHERE company_id = ?))";
        }
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, claimId);
            if (roleId == 5) {
                ps.setInt(2, customerId != null ? customerId : -1);
            } else {
                int cid = (companyId != null) ? companyId : -1;
                ps.setInt(2, cid);
                ps.setInt(3, cid);
            }
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    /** Distinct customers appearing in the register, for the FR7.7 customer filter. */
    public List<Object[]> getFilterCustomers(int roleId, Integer companyId) {
        List<Object[]> out = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
              "SELECT DISTINCT cu.customer_id, cu.customer_name FROM CLAIMS c "
            + "JOIN CUSTOMERS cu ON cu.customer_id = c.customer_id "
            + "LEFT JOIN SHIPMENT s ON s.shipment_id = c.shipment_id "
            + "LEFT JOIN CONTAINERS cnt ON cnt.container_id = s.container_id WHERE 1=1 ");
        if (roleId >= 2 && roleId <= 4) {
            sql.append("AND (cnt.owner_company_id = ? OR s.created_by IN "
                     + "(SELECT user_id FROM users WHERE company_id = ?)) ");
        }
        sql.append("ORDER BY cu.customer_name");
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (roleId >= 2 && roleId <= 4) {
                int cid = (companyId != null) ? companyId : -1;
                ps.setInt(1, cid); ps.setInt(2, cid);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(new Object[]{ rs.getInt(1), rs.getString(2) });
            }
        } catch (Exception e) { e.printStackTrace(); }
        return out;
    }

    /** Current status of one claim, for server-side state machine checks. */
    public String getClaimStatus(int claimId) {
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT status FROM CLAIMS WHERE claim_id = ?")) {
            ps.setInt(1, claimId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getString(1); }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }
}
