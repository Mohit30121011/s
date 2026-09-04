package com.nlogistic.dao;

import com.nlogistic.model.Company;
import com.nlogistic.util.DBConnectionManager;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CompanyDAO {

    public Company getCompanyById(int companyId) {
        String sql = "SELECT * FROM companies WHERE company_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, companyId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Company c = new Company();
                    c.setCompanyId(rs.getInt("company_id"));
                    c.setCompanyName(rs.getString("company_name"));
                    c.setLicenseNo(rs.getString("license_no"));
                    c.setGstNo(rs.getString("gst_no"));
                    c.setAddress(rs.getString("address"));
                    c.setContactEmail(rs.getString("contact_email"));
                    c.setContactPhone(rs.getString("contact_phone"));
                    c.setApprovalStatus(rs.getString("approval_status"));
                    return c;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public List<Company> getAllCompanies() {
        List<Company> list = new ArrayList<>();
        String sql = "SELECT * FROM companies ORDER BY company_id DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Company c = new Company();
                c.setCompanyId(rs.getInt("company_id"));
                c.setCompanyName(rs.getString("company_name"));
                c.setLicenseNo(rs.getString("license_no"));
                c.setGstNo(rs.getString("gst_no"));
                c.setAddress(rs.getString("address"));
                c.setContactEmail(rs.getString("contact_email"));
                c.setContactPhone(rs.getString("contact_phone"));
                c.setApprovalStatus(rs.getString("approval_status"));
                list.add(c);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * DB: register_company(p_company_name, p_license_no, p_gst_no, p_address, p_contact_email, p_contact_phone, OUT p_company_id)
     */
    public int registerCompany(String name, String license, String gst, String address, String email, String phone) {
        String sql = "{CALL register_company(?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, name);
            cs.setString(2, license);
            cs.setString(3, gst);
            cs.setString(4, address);
            cs.setString(5, email);
            cs.setString(6, phone);
            cs.registerOutParameter(7, Types.INTEGER);
            cs.execute();
            return cs.getInt(7);
        } catch (Exception e) { e.printStackTrace(); }
        return -1;
    }

    /**
     * DB: approve_company(p_company_id, p_approver_user_id)
     */
    public void approveCompany(int companyId, int approverUserId) {
        String sql = "{CALL approve_company(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, companyId);
            cs.setInt(2, approverUserId);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * DB: suspend_company(p_company_id, p_approver_user_id, p_reason)
     */
    public void suspendCompany(int companyId, int approverUserId, String reason) {
        String sql = "{CALL suspend_company(?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, companyId);
            cs.setInt(2, approverUserId);
            cs.setString(3, reason);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * DB: delete_companies(p_company_id, p_requesting_user_id) - Super Admin only
     */
    public void deleteCompany(int companyId, int requestingUserId) {
        String sql = "{CALL delete_companies(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, companyId);
            cs.setInt(2, requestingUserId);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * DB: update_companies(p_company_id, p_requesting_user_id, name, license, gst, address, email, phone, status)
     */
    public void updateCompany(int companyId, int requestingUserId, String name, String license, String gst, String address, String email, String phone, String approvalStatus) {
        String sql = "{CALL update_companies(?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, companyId);
            cs.setInt(2, requestingUserId);
            if (name != null) cs.setString(3, name); else cs.setNull(3, Types.VARCHAR);
            if (license != null) cs.setString(4, license); else cs.setNull(4, Types.VARCHAR);
            if (gst != null) cs.setString(5, gst); else cs.setNull(5, Types.VARCHAR);
            if (address != null) cs.setString(6, address); else cs.setNull(6, Types.VARCHAR);
            if (email != null) cs.setString(7, email); else cs.setNull(7, Types.VARCHAR);
            if (phone != null) cs.setString(8, phone); else cs.setNull(8, Types.VARCHAR);
            if (approvalStatus != null) cs.setString(9, approvalStatus); else cs.setNull(9, Types.VARCHAR);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }
    public java.util.List<com.nlogistic.model.Company> getPendingCompanies() {
        java.util.List<com.nlogistic.model.Company> list = new java.util.ArrayList<>();
        String sql = "SELECT * FROM companies WHERE approval_status = 'Pending' OR approval_status = 'Inactive' OR approval_status = '' OR approval_status IS NULL";
        try (java.sql.Connection conn = com.nlogistic.util.DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             java.sql.ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                com.nlogistic.model.Company c = new com.nlogistic.model.Company();
                c.setCompanyId(rs.getInt("company_id"));
                c.setCompanyName(rs.getString("company_name"));
                c.setLicenseNo(rs.getString("license_no"));
                c.setGstNo(rs.getString("gst_no"));
                c.setAddress(rs.getString("address"));
                c.setContactEmail(rs.getString("contact_email"));
                c.setContactPhone(rs.getString("contact_phone"));
                c.setApprovalStatus(rs.getString("approval_status"));
                list.add(c);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean updateCompanyStatus(int companyId, String status) {
        String sql = "UPDATE companies SET approval_status = ? WHERE company_id = ?";
        try (java.sql.Connection conn = com.nlogistic.util.DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, companyId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
}
