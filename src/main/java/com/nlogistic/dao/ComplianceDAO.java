package com.nlogistic.dao;

import com.nlogistic.model.ComplianceDocument;
import com.nlogistic.model.ShipmentComplianceInfo;
import com.nlogistic.util.DBConnectionManager;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ComplianceDAO {

    /**
     * Retrieves all compliance documents with joined shipment, customer, and uploader data.
     */
    public List<ComplianceDocument> getAllDocuments() {
        List<ComplianceDocument> list = new ArrayList<>();
        String sql = "SELECT cd.*, s.cargo_description, c.customer_name, "
                   + "p_orig.port_name AS origin_port, p_dest.port_name AS dest_port, "
                   + "u.username AS uploader_name "
                   + "FROM COMPLIANCE_DOCUMENTS cd "
                   + "JOIN SHIPMENT s ON cd.shipment_id = s.shipment_id "
                   + "LEFT JOIN CUSTOMERS c ON s.customer_id = c.customer_id "
                   + "LEFT JOIN PORTS p_orig ON s.origin_port_id = p_orig.port_id "
                   + "LEFT JOIN PORTS p_dest ON s.destination_port_id = p_dest.port_id "
                   + "LEFT JOIN USERS u ON cd.uploaded_by = u.user_id "
                   + "ORDER BY cd.doc_id DESC";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToDocument(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Retrieves documents expiring within the specified days (default 15 days for FR5.4 alerts).
     */
    public List<ComplianceDocument> getExpiringDocuments(int days) {
        List<ComplianceDocument> list = new ArrayList<>();
        // First try stored procedure get_expiring_compliance_documents
        String callSql = "{CALL get_expiring_compliance_documents(?)}";
        boolean procedureSuccess = false;

        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(callSql)) {
            cs.setInt(1, days);
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    ComplianceDocument doc = new ComplianceDocument();
                    doc.setDocId(rs.getInt("doc_id"));
                    doc.setShipmentId(rs.getInt("shipment_id"));
                    doc.setDocType(rs.getString("doc_type"));
                    doc.setDocNumber(rs.getString("doc_number"));
                    doc.setIssuingAuthority(rs.getString("issuing_authority"));
                    doc.setIssueDate(rs.getDate("issue_date"));
                    doc.setExpiryDate(rs.getDate("expiry_date"));
                    doc.setStatus(rs.getString("status"));
                    doc.setFilePath(rs.getString("file_path"));
                    list.add(doc);
                }
                procedureSuccess = true;
            }
        } catch (Exception ignored) {}

        if (!procedureSuccess || list.isEmpty()) {
            String fallbackSql = "SELECT cd.*, s.cargo_description, c.customer_name, "
                               + "p_orig.port_name AS origin_port, p_dest.port_name AS dest_port, "
                               + "u.username AS uploader_name "
                               + "FROM COMPLIANCE_DOCUMENTS cd "
                               + "JOIN SHIPMENT s ON cd.shipment_id = s.shipment_id "
                               + "LEFT JOIN CUSTOMERS c ON s.customer_id = c.customer_id "
                               + "LEFT JOIN PORTS p_orig ON s.origin_port_id = p_orig.port_id "
                               + "LEFT JOIN PORTS p_dest ON s.destination_port_id = p_dest.port_id "
                               + "LEFT JOIN USERS u ON cd.uploaded_by = u.user_id "
                               + "WHERE cd.status NOT IN ('Rejected','Expired') "
                               + "AND cd.expiry_date IS NOT NULL "
                               + "AND cd.expiry_date BETWEEN CURRENT_DATE AND DATE_ADD(CURRENT_DATE, INTERVAL ? DAY) "
                               + "ORDER BY cd.expiry_date ASC";

            try (Connection conn = DBConnectionManager.getConnection();
                 PreparedStatement ps = conn.prepareStatement(fallbackSql)) {
                ps.setInt(1, days);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapResultSetToDocument(rs));
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return list;
    }

    /**
     * Flags past-due documents as 'Expired' (FR5.2, FR5.4).
     */
    public void flagExpiredDocuments() {
        try (Connection conn = DBConnectionManager.getConnection()) {
            try (CallableStatement cs = conn.prepareCall("{CALL flag_expired_documents()}")) {
                cs.execute();
            } catch (Exception e) {
                String sql = "UPDATE COMPLIANCE_DOCUMENTS SET status = 'Expired' "
                           + "WHERE expiry_date < CURRENT_DATE AND status NOT IN ('Expired','Rejected')";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.executeUpdate();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Uploads and attaches a compliance document per shipment (FR5.1, FR5.2).
     */
    public boolean uploadDocument(int shipmentId, String docType, String docNumber, String issuer, 
                                  java.sql.Date issueDate, java.sql.Date expiryDate, String filePath, int uploadedBy) {
        // Live nlogistic_db defines this procedure as upload_compliance_document
        // (verified via information_schema.parameters: p_shipment_id, p_doc_type, p_doc_number,
        // p_issuing_authority, p_issue_date, p_expiry_date, p_file_path, p_uploaded_by - matches
        // this method's parameter order exactly).
        boolean success = false;
        String callSql = "{CALL upload_compliance_document(?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(callSql)) {
            cs.setInt(1, shipmentId);
            cs.setString(2, docType);
            cs.setString(3, docNumber);
            cs.setString(4, issuer);
            cs.setDate(5, issueDate);
            cs.setDate(6, expiryDate);
            cs.setString(7, filePath);
            cs.setInt(8, uploadedBy);
            cs.execute();
            success = true;
        } catch (Exception ex) {
            // Fallback direct insert
            String insertSql = "INSERT INTO COMPLIANCE_DOCUMENTS "
                             + "(shipment_id, doc_type, doc_number, issuing_authority, issue_date, expiry_date, status, file_path, uploaded_by) "
                             + "VALUES (?, ?, ?, ?, ?, ?, 'Pending', ?, ?)";
            try (Connection conn = DBConnectionManager.getConnection();
                 PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, shipmentId);
                ps.setString(2, docType);
                ps.setString(3, docNumber);
                ps.setString(4, issuer);
                ps.setDate(5, issueDate);
                ps.setDate(6, expiryDate);
                ps.setString(7, filePath);
                ps.setInt(8, uploadedBy);
                success = ps.executeUpdate() > 0;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        if (success) {
            // Supersede older expiring/expired documents of the same type for this shipment
            try (Connection conn = DBConnectionManager.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                     "UPDATE COMPLIANCE_DOCUMENTS SET status = 'Expired' " +
                     "WHERE shipment_id = ? AND doc_type = ? AND doc_number != ? AND status NOT IN ('Rejected')")) {
                ps.setInt(1, shipmentId);
                ps.setString(2, docType);
                ps.setString(3, docNumber);
                ps.executeUpdate();
            } catch (Exception ignored) {}
        }

        return success;
    }

    /**
     * Renews an existing compliance document with an extended expiry date (FR5.4).
     */
    public boolean renewDocument(int docId, String docNumber, String issuer, java.sql.Date issueDate, java.sql.Date newExpiryDate, String filePath) {
        String callSql = "{CALL update_compliance_document(?, NULL, ?, ?, ?, ?, 'Approved', ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(callSql)) {
            cs.setInt(1, docId);
            cs.setString(2, docNumber);
            cs.setString(3, issuer);
            cs.setDate(4, issueDate);
            cs.setDate(5, newExpiryDate);
            cs.setString(6, filePath);
            cs.execute();
            return true;
        } catch (Exception ex) {
            String updateSql = "UPDATE COMPLIANCE_DOCUMENTS SET "
                             + "doc_number = COALESCE(?, doc_number), "
                             + "issuing_authority = COALESCE(?, issuing_authority), "
                             + "issue_date = COALESCE(?, issue_date), "
                             + "expiry_date = ?, "
                             + "status = 'Approved', "
                             + "file_path = COALESCE(?, file_path) "
                             + "WHERE doc_id = ?";
            try (Connection conn = DBConnectionManager.getConnection();
                 PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, docNumber);
                ps.setString(2, issuer);
                ps.setDate(3, issueDate);
                ps.setDate(4, newExpiryDate);
                ps.setString(5, filePath);
                ps.setInt(6, docId);
                return ps.executeUpdate() > 0;
            } catch (Exception e) {
                e.printStackTrace();
                return false;
            }
        }
    }

    /**
     * Reviews document status (Approved / Rejected) (FR5.2).
     */
    public boolean reviewDocument(int docId, String newStatus) {
        String callSql = "{CALL update_compliance_document(?, NULL, NULL, NULL, NULL, NULL, ?, NULL)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(callSql)) {
            cs.setInt(1, docId);
            cs.setString(2, newStatus);
            cs.execute();
            return true;
        } catch (Exception ex) {
            String updateSql = "UPDATE COMPLIANCE_DOCUMENTS SET status = ? WHERE doc_id = ?";
            try (Connection conn = DBConnectionManager.getConnection();
                 PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, newStatus);
                ps.setInt(2, docId);
                return ps.executeUpdate() > 0;
            } catch (Exception e) {
                e.printStackTrace();
                return false;
            }
        }
    }

    /**
     * Deletes a compliance document.
     */
    public boolean deleteDocument(int docId) {
        String callSql = "{CALL delete_compliance_document(?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(callSql)) {
            cs.setInt(1, docId);
            cs.execute();
            return true;
        } catch (Exception ex) {
            String sql = "DELETE FROM COMPLIANCE_DOCUMENTS WHERE doc_id = ?";
            try (Connection conn = DBConnectionManager.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, docId);
                return ps.executeUpdate() > 0;
            } catch (Exception e) {
                e.printStackTrace();
                return false;
            }
        }
    }

    /**
     * Retrieves a single compliance document by its ID.
     */
    public ComplianceDocument getDocumentById(int docId) {
        String sql = "SELECT cd.*, s.cargo_description, c.customer_name, "
                   + "p_orig.port_name AS origin_port, p_dest.port_name AS dest_port, "
                   + "u.username AS uploader_name "
                   + "FROM COMPLIANCE_DOCUMENTS cd "
                   + "JOIN SHIPMENT s ON cd.shipment_id = s.shipment_id "
                   + "LEFT JOIN CUSTOMERS c ON s.customer_id = c.customer_id "
                   + "LEFT JOIN PORTS p_orig ON s.origin_port_id = p_orig.port_id "
                   + "LEFT JOIN PORTS p_dest ON s.destination_port_id = p_dest.port_id "
                   + "LEFT JOIN USERS u ON cd.uploaded_by = u.user_id "
                   + "WHERE cd.doc_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, docId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToDocument(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Retrieves all documents for a specific shipment.
     */
    public List<ComplianceDocument> getByShipment(int shipmentId) {
        List<ComplianceDocument> list = new ArrayList<>();
        String sql = "SELECT cd.*, s.cargo_description, c.customer_name, "
                   + "p_orig.port_name AS origin_port, p_dest.port_name AS dest_port, "
                   + "u.username AS uploader_name "
                   + "FROM COMPLIANCE_DOCUMENTS cd "
                   + "JOIN SHIPMENT s ON cd.shipment_id = s.shipment_id "
                   + "LEFT JOIN CUSTOMERS c ON s.customer_id = c.customer_id "
                   + "LEFT JOIN PORTS p_orig ON s.origin_port_id = p_orig.port_id "
                   + "LEFT JOIN PORTS p_dest ON s.destination_port_id = p_dest.port_id "
                   + "LEFT JOIN USERS u ON cd.uploaded_by = u.user_id "
                   + "WHERE cd.shipment_id = ? "
                   + "ORDER BY cd.doc_id ASC";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToDocument(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Evaluates compliance clearance for shipment departure (FR5.3).
     * Enforces contract precondition: blocks transition to Departed status unless
     * all compliance documents are Approved and none are expired.
     */
    public boolean canShipmentDepart(int shipmentId) {
        String callSql = "{CALL check_shipment_compliance(?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(callSql)) {
            cs.setInt(1, shipmentId);
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    int cleared = rs.getInt("is_cleared_for_departure");
                    return cleared == 1;
                }
            }
        } catch (Exception ignored) {}

        // Fallback SQL evaluation matching the trigger movement_prevent_depart_if_docs_pending_upd
        String countSql = "SELECT "
                        + "COUNT(*) AS total_docs, "
                        + "SUM(CASE WHEN status = 'Approved' AND (expiry_date IS NULL OR expiry_date >= CURRENT_DATE) THEN 1 ELSE 0 END) AS approved_docs "
                        + "FROM COMPLIANCE_DOCUMENTS WHERE shipment_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(countSql)) {
            ps.setInt(1, shipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int total = rs.getInt("total_docs");
                    int approved = rs.getInt("approved_docs");
                    return (total > 0 && total == approved);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Returns compliance clearance summary for all active shipments to power
     * the Shipment Departure Gatekeeper widget in the frontend.
     */
    public List<ShipmentComplianceInfo> getShipmentComplianceList() {
        List<ShipmentComplianceInfo> list = new ArrayList<>();
        String sql = "SELECT s.shipment_id, s.status AS shipment_status, s.cargo_description, c.customer_name, "
                   + "COUNT(cd.doc_id) AS total_docs, "
                   + "SUM(CASE WHEN cd.status = 'Approved' AND (cd.expiry_date IS NULL OR cd.expiry_date >= CURRENT_DATE) THEN 1 ELSE 0 END) AS approved_docs "
                   + "FROM SHIPMENT s "
                   + "LEFT JOIN CUSTOMERS c ON s.customer_id = c.customer_id "
                   + "LEFT JOIN COMPLIANCE_DOCUMENTS cd ON s.shipment_id = cd.shipment_id "
                   + "WHERE s.status NOT IN ('Delivered','Cancelled') "
                   + "GROUP BY s.shipment_id, s.status, s.cargo_description, c.customer_name "
                   + "ORDER BY s.shipment_id DESC";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ShipmentComplianceInfo info = new ShipmentComplianceInfo();
                info.setShipmentId(rs.getInt("shipment_id"));
                info.setShipmentStatus(rs.getString("shipment_status"));
                info.setCargoDescription(rs.getString("cargo_description"));
                info.setCustomerName(rs.getString("customer_name"));
                int total = rs.getInt("total_docs");
                int approved = rs.getInt("approved_docs");
                info.setTotalDocuments(total);
                info.setApprovedDocuments(approved);
                info.setClearedForDeparture(total > 0 && total == approved);
                list.add(info);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private ComplianceDocument mapResultSetToDocument(ResultSet rs) throws SQLException {
        ComplianceDocument doc = new ComplianceDocument();
        doc.setDocId(rs.getInt("doc_id"));
        doc.setShipmentId(rs.getInt("shipment_id"));
        doc.setDocType(rs.getString("doc_type"));
        doc.setDocNumber(rs.getString("doc_number"));
        doc.setIssuingAuthority(rs.getString("issuing_authority"));
        doc.setIssueDate(rs.getDate("issue_date"));
        doc.setExpiryDate(rs.getDate("expiry_date"));
        doc.setStatus(rs.getString("status"));
        doc.setFilePath(rs.getString("file_path"));
        doc.setUploadedBy(rs.getInt("uploaded_by"));

        try {
            doc.setCargoDescription(rs.getString("cargo_description"));
            doc.setCustomerName(rs.getString("customer_name"));
            doc.setOriginPort(rs.getString("origin_port"));
            doc.setDestinationPort(rs.getString("dest_port"));
            doc.setUploaderName(rs.getString("uploader_name"));
        } catch (SQLException ignored) {}

        return doc;
    }
}
