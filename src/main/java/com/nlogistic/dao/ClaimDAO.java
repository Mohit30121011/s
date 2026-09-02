package com.nlogistic.dao;

import com.nlogistic.model.*;
import com.nlogistic.util.DBConnectionManager;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ClaimDAO {

    /**
     * Reads all claims from the claims table, using correct column names from schema.
     */
    public List<Claim> getAllClaims() {
        List<Claim> list = new ArrayList<>();
        String sql = "SELECT * FROM claims ORDER BY claim_id DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
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
                list.add(c);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * DB signature: file_claim(p_shipment_id, p_container_id, p_product_id, p_customer_id,
     *   p_claim_type, p_description, p_incident_date, p_claimed_amount, p_reason_id, p_filed_by)
     * 10 IN params, NO OUT param.
     */
    public void fileClaim(int shipmentId, Integer containerId, Integer productId, int customerId,
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
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * DB signature: review_claim(p_claim_id, p_new_status, p_approved_amount, p_changed_by, p_remark)
     * 5 IN params.
     */
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

    /**
     * DB signature: reject_claim(p_claim_id, p_rejected_by, p_remark)
     * 3 IN params.
     */
    public void rejectClaim(int claimId, int rejectedBy, String remark) {
        String sql = "{CALL reject_claim(?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, claimId);
            cs.setInt(2, rejectedBy);
            cs.setString(3, remark);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * DB signature: settle_claim(p_claim_id, p_resolved_by)
     * 2 IN params only!
     */
    public void settleClaim(int claimId, int resolvedBy) {
        String sql = "{CALL settle_claim(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, claimId);
            cs.setInt(2, resolvedBy);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * DB signature: add_claim_document(p_claim_id, p_doc_type, p_file_path, p_uploaded_by)
     */
    public void addClaimDocument(int claimId, String docType, String filePath, int uploadedBy) {
        String sql = "{CALL add_claim_document(?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, claimId);
            cs.setString(2, docType);
            cs.setString(3, filePath);
            cs.setInt(4, uploadedBy);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * DB signature: get_claim_history(p_claim_id)
     */
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
                list.add(h);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * DB signature: get_claims_by_status(p_status)
     */
    public List<Claim> getClaimsByStatus(String status) {
        List<Claim> list = new ArrayList<>();
        String sql = "{CALL get_claims_by_status(?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, status);
            ResultSet rs = cs.executeQuery();
            while (rs.next()) {
                Claim c = new Claim();
                c.setClaimId(rs.getInt("claim_id"));
                c.setShipmentId(rs.getInt("shipment_id"));
                c.setCustomerId(rs.getInt("customer_id"));
                c.setClaimType(rs.getString("claim_type"));
                c.setClaimedAmount(rs.getDouble("claimed_amount"));
                c.setApprovedAmount(rs.getDouble("approved_amount"));
                c.setStatus(rs.getString("status"));
                c.setDescription(rs.getString("description"));
                list.add(c);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}
