package com.nlogistic.dao;

import com.nlogistic.model.ComplianceDocument;
import com.nlogistic.util.DBConnectionManager;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ComplianceDAO {
    
    public List<ComplianceDocument> getAllDocuments() {
        List<ComplianceDocument> list = new ArrayList<>();
        String sql = "SELECT * FROM compliance_documents ORDER BY doc_id DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
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
                doc.setUploadedBy(rs.getInt("uploaded_by"));
                list.add(doc);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean uploadDocument(int shipmentId, String docType, String docNumber, String issuer, java.sql.Date issueDate, java.sql.Date expiryDate, String filePath, int uploadedBy) {
        String sql = "{CALL upload_compliance_document(?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, shipmentId);
            cs.setString(2, docType);
            cs.setString(3, docNumber);
            cs.setString(4, issuer);
            cs.setDate(5, issueDate);
            cs.setDate(6, expiryDate);
            cs.setString(7, filePath);
            cs.setInt(8, uploadedBy);
            cs.execute();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean reviewDocument(int docId, String newStatus) {
        String sql = "{CALL review_compliance_document(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, docId);
            cs.setString(2, newStatus);
            cs.execute();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * DB: get_compliance_status(p_shipment_id)
     */
    public List<ComplianceDocument> getByShipment(int shipmentId) {
        List<ComplianceDocument> list = new ArrayList<>();
        String sql = "{CALL get_compliance_status(?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, shipmentId);
            ResultSet rs = cs.executeQuery();
            while (rs.next()) {
                ComplianceDocument doc = new ComplianceDocument();
                doc.setDocId(rs.getInt("doc_id"));
                doc.setShipmentId(rs.getInt("shipment_id"));
                doc.setDocType(rs.getString("doc_type"));
                doc.setDocNumber(rs.getString("doc_number"));
                doc.setStatus(rs.getString("status"));
                doc.setExpiryDate(rs.getDate("expiry_date"));
                list.add(doc);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * DB: check_shipment_can_depart(p_shipment_id, OUT p_can_depart)
     */
    public boolean canShipmentDepart(int shipmentId) {
        String sql = "{CALL check_shipment_can_depart(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, shipmentId);
            cs.registerOutParameter(2, java.sql.Types.TINYINT);
            cs.execute();
            return cs.getInt(2) == 1;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

}
