package com.nlogistic.dao;

import com.nlogistic.model.User;
import com.nlogistic.util.DBConnectionManager;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    /**
     * FR1.5 Login using login_attempt SP.
     * DB signature: login_attempt(p_username, p_password_hash, p_ip_address, OUT p_result)
     * This enforces lockout (FR1.8) and audit logging (FR1.9).
     */
    public String loginAttempt(String username, String password, String ipAddress) {
        String sql = "{CALL login_attempt(?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, username);
            cs.setString(2, password);  // SP does SHA2 internally
            cs.setString(3, ipAddress);
            cs.registerOutParameter(4, Types.VARCHAR);
            cs.execute();
            return cs.getString(4); // SUCCESS, USER_NOT_FOUND, INVALID_PASSWORD, ACCOUNT_LOCKED, ACCOUNT_INACTIVE
        } catch (Exception e) {
            e.printStackTrace();
            return "DB_ERROR: " + e.getMessage();
        }
    }

    /**
     * After successful loginAttempt, fetch the user object for session.
     */
        public User getUserById(int userId) {
        String sql = "SELECT u.*, r.role_name FROM users u JOIN roles r ON u.role_id = r.role_id WHERE u.user_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setUsername(rs.getString("username"));
                    u.setEmail(rs.getString("email"));
                    u.setPhone(rs.getString("phone"));
                    u.setRoleId(rs.getInt("role_id"));
                                        u.setCompanyId(rs.getInt("company_id"));
                    u.setStatus(rs.getString("status"));
                    u.setFailedLoginCount(rs.getInt("failed_login_count"));
                    u.setLastLoginAt(rs.getTimestamp("last_login_at"));
                    u.setCreatedAt(rs.getTimestamp("created_at"));
                    u.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return u;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

public User getUserByUsername(String username) {
        String sql = "SELECT u.*, r.role_name FROM users u JOIN roles r ON u.role_id = r.role_id WHERE u.username = ? OR u.email = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setUsername(rs.getString("username"));
                    u.setEmail(rs.getString("email"));
                    u.setRoleId(rs.getInt("role_id"));
                    u.setCompanyId(rs.getInt("company_id"));
                    u.setStatus(rs.getString("status"));
                    u.setPhone(rs.getString("phone"));
                    return u;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    /**
     * Legacy authenticate for backward compat - still works but bypasses SP.
     */
    public User authenticate(String email, String passwordHash) {
        String sql = "SELECT * FROM users WHERE email = ? AND password_hash = SHA2(?, 256)";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, passwordHash);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setUsername(rs.getString("username"));
                    u.setEmail(rs.getString("email"));
                    u.setRoleId(rs.getInt("role_id"));
                    u.setCompanyId(rs.getInt("company_id"));
                    u.setStatus(rs.getString("status"));
                    return u;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    /**
     * Create user directly and return generated user_id
     */
    public int createUser(String username, String email, String password, String phone, int roleId, Integer companyId, String status) {
        String sql = "INSERT INTO users (username, email, password_hash, phone, role_id, company_id, status) VALUES (?, ?, SHA2(?, 256), ?, ?, ?, ?)";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, username);
            ps.setString(2, email);
            ps.setString(3, password);
            ps.setString(4, phone != null ? phone : "");
            ps.setInt(5, roleId);
            if (companyId != null) ps.setInt(6, companyId); else ps.setNull(6, Types.INTEGER);
            ps.setString(7, (status != null && !status.trim().isEmpty()) ? status : "Pending");
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Direct persistent registration with SHA-256 password hashing and audit logging
     */
    public void registerUser(String username, String email, String password, String phone, int roleId, Integer companyId, String status) {
        int newId = createUser(username, email, password, phone, roleId, companyId, (status != null && !status.trim().isEmpty()) ? status : "Pending");
        if (newId > 0) {
            logAuditEvent(newId, "USER_REGISTERED", username, "127.0.0.1");
        }
    }

    /**
     * DB signature: register_customer(p_user_id, p_customer_name, p_address, p_kyc_doc_path, p_credit_limit)
     */
    public void registerCustomer(int userId, String customerName, String address, String kycDocPath, double creditLimit) {
        String sql = "{CALL register_customer(?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, userId);
            cs.setString(2, customerName);
            cs.setString(3, address);
            cs.setString(4, kycDocPath);
            cs.setDouble(5, creditLimit);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * DB signature: logout(p_user_id, p_ip_address)
     */
    public void logout(int userId, String ipAddress) {
        String sql = "{CALL logout(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, userId);
            cs.setString(2, ipAddress);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * DB signature: approve_user(p_user_id, p_approver_id)
     */
    public void approveUser(int userId, int approverId) {
        String sql = "{CALL approve_user(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, userId);
            cs.setInt(2, approverId);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * DB signature: unlock_user(p_user_id, p_unlocked_by)
     */
    public void unlockUser(int userId, int unlockedBy) {
        String sql = "{CALL unlock_user(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, userId);
            cs.setInt(2, unlockedBy);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * DB signature: deactivate_user(p_user_id, p_changed_by)
     */
    public void deactivateUser(int userId, int changedBy) {
        String sql = "{CALL deactivate_user(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, userId);
            cs.setInt(2, changedBy);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * DB signature: change_user_role(p_user_id, p_new_role_id, p_changed_by)
     */
    public void changeUserRole(int userId, int newRoleId, int changedBy) {
        String sql = "{CALL change_user_role(?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, userId);
            cs.setInt(2, newRoleId);
            cs.setInt(3, changedBy);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * DB signature: check_permission(p_user_id, p_required_role, OUT p_allowed)
     */
    public boolean checkPermission(int userId, String requiredRole) {
        String sql = "{CALL check_permission(?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, userId);
            cs.setString(2, requiredRole);
            cs.registerOutParameter(3, Types.TINYINT);
            cs.execute();
            return cs.getInt(3) == 1;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    /**
     * DB signature: get_users_by_company(p_company_id)
     */
    public List<User> getUsersByCompany(int companyId) {
        List<User> list = new ArrayList<>();
        String sql = "{CALL get_users_by_company(?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, companyId);
            ResultSet rs = cs.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setUsername(rs.getString("username"));
                u.setEmail(rs.getString("email"));
                u.setRoleId(rs.getInt("role_id"));
                u.setStatus(rs.getString("status"));
                list.add(u);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * DB signature: get_audit_history(p_entity_name, p_entity_id)
     */
    public List<java.util.Map<String, Object>> getAuditHistory(String entityName, int entityId) {
        List<java.util.Map<String, Object>> list = new ArrayList<>();
        String sql = "{CALL get_audit_history(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, entityName);
            cs.setInt(2, entityId);
            ResultSet rs = cs.executeQuery();
            while (rs.next()) {
                java.util.Map<String, Object> map = new java.util.LinkedHashMap<>();
                map.put("log_id", rs.getInt("log_id"));
                map.put("action", rs.getString("action"));
                map.put("old_value", rs.getString("old_value"));
                map.put("new_value", rs.getString("new_value"));
                map.put("timestamp", rs.getTimestamp("timestamp"));
                list.add(map);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * DB: delete_users(p_user_id, p_requesting_user_id) - Super Admin only
     */
    public void deleteUser(int userId, int requestingUserId) {
        String sql = "{CALL delete_users(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, userId);
            cs.setInt(2, requestingUserId);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * DB: update_users(p_user_id, p_requesting_user_id, p_username, p_email, p_phone, p_role_id, p_company_id, p_status, p_failed_login_count, p_last_login_at)
     */
    public void updateUser(int userId, int requestingUserId, String username, String email, String phone, Integer roleId, Integer companyId, String status) {
        String sql = "{CALL update_users(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, userId);
            cs.setInt(2, requestingUserId);
            if (username != null) cs.setString(3, username); else cs.setNull(3, Types.VARCHAR);
            if (email != null) cs.setString(4, email); else cs.setNull(4, Types.VARCHAR);
            if (phone != null) cs.setString(5, phone); else cs.setNull(5, Types.VARCHAR);
            if (roleId != null) cs.setInt(6, roleId); else cs.setNull(6, Types.INTEGER);
            if (companyId != null) cs.setInt(7, companyId); else cs.setNull(7, Types.INTEGER);
            if (status != null) cs.setString(8, status); else cs.setNull(8, Types.VARCHAR);
            cs.setNull(9, Types.INTEGER); // failed_login_count
            cs.setNull(10, Types.TIMESTAMP); // last_login_at
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }



    public java.util.List<com.nlogistic.model.User> getAllUsers() {
        java.util.List<com.nlogistic.model.User> list = new java.util.ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY user_id ASC";
        try (java.sql.Connection conn = com.nlogistic.util.DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             java.sql.ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                com.nlogistic.model.User u = new com.nlogistic.model.User();
                u.setUserId(rs.getInt("user_id"));
                u.setUsername(rs.getString("username"));
                u.setEmail(rs.getString("email"));
                u.setPhone(rs.getString("phone"));
                u.setRoleId(rs.getInt("role_id"));
                u.setCompanyId(rs.getInt("company_id"));
                u.setStatus(rs.getString("status"));
                u.setLastLoginAt(rs.getTimestamp("last_login_at"));
                u.setCreatedAt(rs.getTimestamp("created_at"));
                u.setUpdatedAt(rs.getTimestamp("updated_at"));
                list.add(u);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    public java.util.List<com.nlogistic.model.User> getPendingUsers() {
        java.util.List<com.nlogistic.model.User> list = new java.util.ArrayList<>();
        String sql = "SELECT * FROM users WHERE status = 'Pending' OR status = 'Inactive'";
        try (java.sql.Connection conn = com.nlogistic.util.DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             java.sql.ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                com.nlogistic.model.User u = new com.nlogistic.model.User();
                u.setUserId(rs.getInt("user_id"));
                u.setUsername(rs.getString("username"));
                u.setEmail(rs.getString("email"));
                u.setPhone(rs.getString("phone"));
                u.setRoleId(rs.getInt("role_id"));
                u.setStatus(rs.getString("status"));
                u.setCompanyId(rs.getInt("company_id"));
                list.add(u);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean updateUserStatus(int userId, String status) {
        String sql = "UPDATE users SET status = ? WHERE user_id = ?";
        try (java.sql.Connection conn = com.nlogistic.util.DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }    /**
     * Finds a user by email and generates a password reset token.
     * Returns the generated token, or null if user not found.
     */
    public String generatePasswordResetToken(String email) {
        User user = getUserByUsername(email); // Since this queries by username OR email
        if (user == null) return null;
        
        String token = java.util.UUID.randomUUID().toString();
        // Set expiry to 15 minutes from now
        String sql = "INSERT INTO password_resets (user_id, token, expires_at) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 15 MINUTE))";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, user.getUserId());
            ps.setString(2, token);
            ps.executeUpdate();
            return token;
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    /**
     * Validates the token and returns the associated user ID.
     * Returns -1 if invalid, expired, or used.
     */
    public int validateResetToken(String token) {
        String sql = "SELECT user_id FROM password_resets WHERE token = ? AND used = FALSE AND expires_at > NOW()";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("user_id");
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return -1;
    }

    /**
     * Resets the user's password using the token and marks the token as used.
     */
    public boolean resetPasswordWithToken(String token, String newPassword) {
        int userId = validateResetToken(token);
        if (userId == -1) return false;

        String updatePassSql = "UPDATE users SET password_hash = SHA2(?, 256) WHERE user_id = ?";
        String updateTokenSql = "UPDATE password_resets SET used = TRUE WHERE token = ?";

        try (Connection conn = DBConnectionManager.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps1 = conn.prepareStatement(updatePassSql);
                 PreparedStatement ps2 = conn.prepareStatement(updateTokenSql)) {
                
                ps1.setString(1, newPassword);
                ps1.setInt(2, userId);
                ps1.executeUpdate();

                ps2.setString(1, token);
                ps2.executeUpdate();

                conn.commit();
                return true;
            } catch (Exception ex) {
                conn.rollback();
                ex.printStackTrace();
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
    public void logAuditEvent(int userId, String action, String entityName, String ipAddress) {
        String sql = "INSERT INTO audit_log (user_id, action, entity_name, entity_id, ip_address) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, action);
            ps.setString(3, entityName);
            ps.setInt(4, userId); // Use user_id as entity_id for these events
            ps.setString(5, ipAddress);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

}
