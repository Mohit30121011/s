package com.nlogistic.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.nlogistic.model.AuditLog;
import com.nlogistic.util.DBConnectionManager;

public class AuditDAO {

    public static class AuditEntry extends AuditLog {
        private String username;
        private String email;
        private String roleName;
        private int roleId;

        public String getUsername() { return username != null ? username : "System / Anonymous"; }
        public void setUsername(String username) { this.username = username; }

        public String getEmail() { return email != null ? email : "-"; }
        public void setEmail(String email) { this.email = email; }

        public String getRoleName() { return roleName != null ? roleName : "External"; }
        public void setRoleName(String roleName) { this.roleName = roleName; }

        public int getRoleId() { return roleId; }
        public void setRoleId(int roleId) { this.roleId = roleId; }
    }

    /**
     * Retrieve security & login audit logs with filtering and user details
     */
    public List<AuditEntry> getAuditLogs(String actionFilter, String searchKeyword, int limit) {
        List<AuditEntry> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT a.log_id, a.user_id, a.action, a.entity_name, a.entity_id, ");
        sql.append("       a.old_value, a.new_value, a.ip_address, a.timestamp, ");
        sql.append("       u.username, u.email, r.role_name, u.role_id ");
        sql.append("FROM audit_log a ");
        sql.append("LEFT JOIN users u ON a.user_id = u.user_id ");
        sql.append("LEFT JOIN roles r ON u.role_id = r.role_id ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (actionFilter != null && !actionFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(actionFilter)) {
            sql.append("AND a.action = ? ");
            params.add(actionFilter.trim());
        }

        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            sql.append("AND (u.username LIKE ? OR u.email LIKE ? OR a.action LIKE ? OR a.ip_address LIKE ? OR a.entity_name LIKE ?) ");
            String like = "%" + searchKeyword.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }

        sql.append("ORDER BY a.timestamp DESC, a.log_id DESC ");
        if (limit > 0) {
            sql.append("LIMIT ?");
            params.add(limit);
        }

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditEntry entry = new AuditEntry();
                    entry.setLogId(rs.getInt("log_id"));
                    entry.setUserId(rs.getInt("user_id"));
                    entry.setAction(rs.getString("action"));
                    entry.setEntityName(rs.getString("entity_name"));
                    entry.setEntityId(rs.getInt("entity_id"));
                    entry.setOldValue(rs.getString("old_value"));
                    entry.setNewValue(rs.getString("new_value"));
                    entry.setIpAddress(rs.getString("ip_address"));
                    entry.setTimestamp(rs.getTimestamp("timestamp"));

                    entry.setUsername(rs.getString("username"));
                    entry.setEmail(rs.getString("email"));
                    entry.setRoleName(rs.getString("role_name"));
                    entry.setRoleId(rs.getInt("role_id"));

                    list.add(entry);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Compute real-time telemetry metrics for the KPI dashboard
     */
    public Map<String, Integer> getAuditKPIs() {
        Map<String, Integer> kpis = new HashMap<>();
        kpis.put("totalLogins", 0);
        kpis.put("totalLogouts", 0);
        kpis.put("failedLogins", 0);
        kpis.put("securityAlerts", 0);
        kpis.put("totalLogs", 0);

        String sql = "SELECT action, COUNT(*) as cnt FROM audit_log GROUP BY action";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            int total = 0;
            while (rs.next()) {
                String act = rs.getString("action");
                int cnt = rs.getInt("cnt");
                total += cnt;

                if ("LOGIN_SUCCESS".equalsIgnoreCase(act)) {
                    kpis.put("totalLogins", kpis.get("totalLogins") + cnt);
                } else if ("LOGOUT".equalsIgnoreCase(act)) {
                    kpis.put("totalLogouts", kpis.get("totalLogouts") + cnt);
                } else if ("LOGIN_FAILED".equalsIgnoreCase(act)) {
                    kpis.put("failedLogins", kpis.get("failedLogins") + cnt);
                } else if (act != null && (act.contains("RESET") || act.contains("DENIED") || act.contains("LOCKED"))) {
                    kpis.put("securityAlerts", kpis.get("securityAlerts") + cnt);
                }
            }
            kpis.put("totalLogs", total);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return kpis;
    }
}
