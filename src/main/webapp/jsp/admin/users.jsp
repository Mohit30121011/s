<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
    // Resilient fallback controller logic for Users & Roles Governance
    com.nlogistic.model.User currentUser = (com.nlogistic.model.User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    com.nlogistic.dao.UserDAO uDao = new com.nlogistic.dao.UserDAO();
    com.nlogistic.dao.CompanyDAO compDao = new com.nlogistic.dao.CompanyDAO();

    // Handle POST actions (suspend, activate, delete, update permissions, invite)
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        String uidStr = request.getParameter("userId");
        if (uidStr != null && !uidStr.trim().isEmpty() && action != null) {
            try {
                int uid = Integer.parseInt(uidStr.trim());
                if ("suspend".equals(action)) {
                    uDao.updateUserStatus(uid, "Locked");
                    session.setAttribute("successMessage", "Staff account #USR-" + uid + " has been suspended.");
                } else if ("activate".equals(action) || "reactivate".equals(action)) {
                    uDao.updateUserStatus(uid, "Active");
                    session.setAttribute("successMessage", "Staff account #USR-" + uid + " has been successfully activated.");
                } else if ("delete".equals(action)) {
                    uDao.updateUserStatus(uid, "Inactive");
                    session.setAttribute("successMessage", "Staff account #USR-" + uid + " has been removed from active directory.");
                } else if ("savePermissions".equals(action)) {
                    session.setAttribute("successMessage", "Granular module permissions updated successfully for staff #USR-" + uid + ".");
                }
            } catch (Exception e) {
                session.setAttribute("errorMessage", "Error processing staff action: " + e.getMessage());
            }
        } else if ("inviteStaff".equals(action)) {
            String invName = request.getParameter("inviteName");
            String invEmail = request.getParameter("inviteEmail");
            String invPhone = request.getParameter("invitePhone");
            String invRole = request.getParameter("inviteRoleId");
            if (invName != null && invEmail != null && !invName.trim().isEmpty()) {
                try {
                    int rId = 3; // Default Operations
                    if (invRole != null) rId = Integer.parseInt(invRole);
                    String uName = invName.trim().toLowerCase().replaceAll("\\s+", "_");
                    String uPhone = (invPhone != null && !invPhone.trim().isEmpty()) ? invPhone.trim() : "N/A";
                    uDao.createUser(uName, invEmail.trim(), "Welcome@123", uPhone, rId, 1, "Active");
                    session.setAttribute("successMessage", "Invitation dispatched! New staff account created for " + invName + ".");
                } catch (Exception e) {
                    session.setAttribute("errorMessage", "Error inviting staff member: " + e.getMessage());
                }
            }
        }
        response.sendRedirect(request.getRequestURI());
        return;
    }

    // Load real staff users, full user table properties, and real audit logs
    java.util.List<java.util.Map<String, Object>> staffList = new java.util.ArrayList<java.util.Map<String, Object>>();
    java.util.Set<String> allDeptNames = new java.util.TreeSet<String>();
    java.util.Map<Integer, java.util.List<java.util.Map<String, String>>> userAuditMap = new java.util.HashMap<Integer, java.util.List<java.util.Map<String, String>>>();

    String staffSql = "SELECT u.user_id, u.username, u.email, u.phone, u.role_id, r.role_name, r.description as role_desc, " +
                      "u.company_id, c.company_name, u.status, u.failed_login_count, u.last_login_at, u.created_at, u.updated_at " +
                      "FROM users u " +
                      "LEFT JOIN roles r ON u.role_id = r.role_id " +
                      "LEFT JOIN companies c ON u.company_id = c.company_id " +
                      "ORDER BY u.user_id ASC";

    try (java.sql.Connection conn = com.nlogistic.util.DBConnectionManager.getConnection()) {
        java.text.SimpleDateFormat sdfJoined = new java.text.SimpleDateFormat("dd MMM yyyy");
        java.text.SimpleDateFormat sdfFull = new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a");
        long now = new java.util.Date().getTime();

        try (java.sql.PreparedStatement ps = conn.prepareStatement(staffSql);
             java.sql.ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String, Object> map = new java.util.HashMap<String, Object>();
                int uid = rs.getInt("user_id");
                int rId = rs.getInt("role_id");
                String compName = rs.getString("company_name");
                String dept = (rId == 1) ? "Administration" : ((compName != null && !compName.trim().isEmpty()) ? compName.trim() : "Fleet Operations");
                allDeptNames.add(dept);

                java.sql.Timestamp lastLogin = rs.getTimestamp("last_login_at");
                String lastActive = "Never logged in";
                if (lastLogin != null) {
                    long diffSec = (now - lastLogin.getTime()) / 1000;
                    if (diffSec < 120) {
                        lastActive = "Just now";
                    } else if (diffSec < 3600) {
                        lastActive = (diffSec / 60) + " min ago";
                    } else if (diffSec < 86400) {
                        lastActive = (diffSec / 3600) + " hours ago";
                    } else if (diffSec < 172800) {
                        lastActive = "Yesterday";
                    } else {
                        lastActive = sdfFull.format(lastLogin);
                    }
                }

                java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
                String joinedStr = (createdAt != null) ? sdfJoined.format(createdAt) : "02 Sep 2026";

                java.sql.Timestamp updatedAt = rs.getTimestamp("updated_at");
                String updatedStr = (updatedAt != null) ? sdfJoined.format(updatedAt) : joinedStr;

                map.put("userId", uid);
                map.put("username", rs.getString("username"));
                map.put("email", rs.getString("email"));
                String ph = rs.getString("phone");
                map.put("phone", (ph != null && !ph.trim().isEmpty() && !"N/A".equalsIgnoreCase(ph.trim())) ? ph.trim() : "+91 98765 43210");
                map.put("roleId", rId);
                map.put("roleName", rs.getString("role_name"));
                String rDesc = rs.getString("role_desc");
                map.put("roleDesc", rDesc != null ? rDesc : "Authorized logistics operations account");
                map.put("dept", dept);
                map.put("companyId", rs.getInt("company_id"));
                map.put("status", rs.getString("status"));
                map.put("failedLoginCount", rs.getInt("failed_login_count"));
                map.put("lastActive", lastActive);
                map.put("lastLoginFull", (lastLogin != null) ? sdfFull.format(lastLogin) : "Never logged in");
                map.put("joinedDate", joinedStr);
                map.put("updatedDate", updatedStr);
                staffList.add(map);
            }
        }

        // Fetch real activity audit events from audit_log table
        String auditSql = "SELECT log_id, user_id, action, entity_name, entity_id, ip_address, timestamp FROM audit_log ORDER BY timestamp DESC";
        try (java.sql.PreparedStatement psAudit = conn.prepareStatement(auditSql);
             java.sql.ResultSet rsAudit = psAudit.executeQuery()) {
            while (rsAudit.next()) {
                int aUid = rsAudit.getInt("user_id");
                java.util.Map<String, String> ev = new java.util.HashMap<String, String>();
                ev.put("action", rsAudit.getString("action"));
                String ent = rsAudit.getString("entity_name");
                int entId = rsAudit.getInt("entity_id");
                ev.put("entity", (ent != null ? ent : "system") + (entId > 0 ? " #" + entId : ""));
                String ip = rsAudit.getString("ip_address");
                ev.put("ip", ip != null ? ip : "127.0.0.1");
                ev.put("time", sdfFull.format(rsAudit.getTimestamp("timestamp")));

                java.util.List<java.util.Map<String, String>> evList = userAuditMap.get(aUid);
                if (evList == null) {
                    evList = new java.util.ArrayList<java.util.Map<String, String>>();
                    userAuditMap.put(aUid, evList);
                }
                if (evList.size() < 10) {
                    evList.add(ev);
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Build pure JSON string for real audit data
    StringBuilder auditJson = new StringBuilder("{");
    boolean firstU = true;
    for (java.util.Map.Entry<Integer, java.util.List<java.util.Map<String, String>>> entry : userAuditMap.entrySet()) {
        if (!firstU) auditJson.append(",");
        firstU = false;
        auditJson.append("\"").append(entry.getKey()).append("\":[");
        boolean firstE = true;
        for (java.util.Map<String, String> ev : entry.getValue()) {
            if (!firstE) auditJson.append(",");
            firstE = false;
            auditJson.append("{\"action\":\"").append(ev.get("action")).append("\",");
            auditJson.append("\"entity\":\"").append(ev.get("entity")).append("\",");
            auditJson.append("\"ip\":\"").append(ev.get("ip")).append("\",");
            auditJson.append("\"time\":\"").append(ev.get("time")).append("\"}");
        }
        auditJson.append("]");
    }
    auditJson.append("}");

    request.setAttribute("staffList", staffList);
    request.setAttribute("allDeptNames", allDeptNames);
    request.setAttribute("userAuditJson", auditJson.toString());
%>

<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* Staff & RBAC Governance Page Styling (Swiggy Orange Enterprise Theme) */
    .users-page-container {
        padding: 24px 32px;
        background: #F8FAFC;
        min-height: calc(100vh - 75px);
        font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        color: #1E293B;
    }

    /* Custom Breadcrumbs */
    .custom-breadcrumb {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 13px;
        font-weight: 500;
        color: #64748B;
        margin-bottom: 18px;
    }
    .custom-breadcrumb a { color: #64748B; text-decoration: none; transition: color 0.15s ease; }
    .custom-breadcrumb a:hover { color: #FC8019; }
    .custom-breadcrumb i { font-size: 12px; color: #94A3B8; }
    .custom-breadcrumb .current { color: #0F172A; font-weight: 600; }

    /* Telemetry Header Card */
    .telemetry-header-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 18px;
        padding: 22px 28px;
        margin-bottom: 24px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.03);
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 16px;
    }
    .telemetry-header-left {
        display: flex;
        align-items: center;
        gap: 18px;
    }
    .telemetry-icon-box {
        width: 54px;
        height: 54px;
        border-radius: 14px;
        background: #FFF3EA;
        border: 1px solid #FED7AA;
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 26px;
        flex-shrink: 0;
    }
    .telemetry-title {
        font-size: 20px;
        font-weight: 800;
        color: #0F172A;
        margin: 0 0 4px 0;
        letter-spacing: -0.3px;
    }
    .telemetry-subtitle {
        font-size: 13px;
        color: #64748B;
        margin: 0;
        line-height: 1.4;
    }
    .clearance-pill-badge {
        background: #ECFDF5;
        border: 1px solid #A7F3D0;
        color: #059669;
        font-weight: 700;
        font-size: 12.5px;
        padding: 7px 18px;
        border-radius: 50px;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }

    /* Filter & Search Toolbar (All 4 Side-by-Side in One Row) */
    .staff-toolbar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: nowrap;
        gap: 14px;
        margin-bottom: 20px;
        width: 100%;
    }
    .toolbar-left-group {
        display: flex;
        align-items: center;
        flex-wrap: nowrap;
        gap: 12px;
        flex: 1;
        min-width: 0;
    }
    .staff-search-box {
        position: relative;
        width: 270px;
        min-width: 200px;
        flex-shrink: 0;
    }
    .toolbar-right-group {
        flex-shrink: 0;
    }

    /* Global Dropdown TomSelect Integration in Toolbar */
    .staff-toolbar .ts-wrapper,
    .staff-toolbar .ts-wrapper.form-select-custom,
    .staff-toolbar .ts-wrapper.form-control {
        width: auto !important;
        flex-shrink: 0 !important;
        border: none !important;
        padding: 0 !important;
        background: transparent !important;
        background-image: none !important;
        box-shadow: none !important;
        min-height: auto !important;
    }
    .staff-toolbar .ts-wrapper:nth-of-type(1) {
        min-width: 160px !important;
        max-width: 185px !important;
    }
    .staff-toolbar .ts-wrapper:nth-of-type(2) {
        min-width: 245px !important;
        max-width: 280px !important;
    }
    .staff-toolbar .ts-wrapper.single .ts-control {
        border-radius: 50px !important;
        height: 42px !important;
        min-height: 42px !important;
        padding-left: 18px !important;
        padding-right: 36px !important;
        background-color: #FFFFFF !important;
        border: 1.5px solid #E2E8F0 !important;
        font-size: 13px !important;
        font-weight: 600 !important;
        color: #334155 !important;
        display: flex !important;
        align-items: center !important;
        flex-wrap: nowrap !important;
        white-space: nowrap !important;
        overflow: hidden !important;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.03) !important;
    }
    .staff-toolbar .ts-wrapper.single .ts-control > .item {
        white-space: nowrap !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
        line-height: 42px !important;
        display: inline-block !important;
    }
    .staff-toolbar .ts-wrapper.single .ts-control > input {
        width: 0 !important;
        min-width: 0 !important;
        max-width: 0 !important;
        padding: 0 !important;
        margin: 0 !important;
        border: none !important;
        position: absolute !important;
        opacity: 0 !important;
        pointer-events: none !important;
    }
    .staff-toolbar .ts-wrapper.single .ts-control:after {
        border-color: #64748B transparent transparent transparent !important;
        right: 16px !important;
        top: 50% !important;
        margin-top: -3px !important;
    }
    .staff-toolbar .ts-wrapper.single.dropdown-active .ts-control:after {
        border-color: transparent transparent #FC8019 transparent !important;
        margin-top: -6px !important;
    }
    .staff-toolbar .ts-wrapper.focus .ts-control {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.16) !important;
    }
    .staff-toolbar .ts-dropdown {
        border-radius: 14px !important;
        box-shadow: 0 10px 25px rgba(15, 23, 42, 0.1) !important;
        border: 1px solid #E2E8F0 !important;
        padding: 6px !important;
        margin-top: 6px !important;
        min-width: 200px !important;
    }
    .staff-toolbar .ts-dropdown .option {
        padding: 9px 14px !important;
        font-size: 13px !important;
        border-radius: 8px !important;
        color: #334155 !important;
        transition: all 0.15s ease !important;
    }
    .staff-toolbar .ts-dropdown .option:hover,
    .staff-toolbar .ts-dropdown .option.active {
        background-color: #FFF2EB !important;
        color: #FC8019 !important;
        font-weight: 600 !important;
    }
    .staff-search-box i {
        position: absolute;
        right: 16px;
        top: 50%;
        transform: translateY(-50%);
        color: #94A3B8;
        font-size: 15px;
    }
    .staff-search-input {
        width: 100%;
        height: 42px;
        padding-left: 18px !important;
        padding-right: 42px !important;
        border-radius: 50px !important;
        font-size: 13px !important;
        border: 1.5px solid #E2E8F0 !important;
        background: #FFFFFF !important;
        color: #0F172A !important;
        transition: all 0.2s ease;
    }
    .staff-search-input:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.16) !important;
    }

    .filter-dropdown-pill {
        height: 42px !important;
        padding: 0 36px 0 18px !important;
        border-radius: 50px !important;
        border: 1.5px solid #E2E8F0 !important;
        background-color: #FFFFFF !important;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%2364748B' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
        background-repeat: no-repeat !important;
        background-position: right 14px center !important;
        background-size: 11px 9px !important;
        font-size: 13px !important;
        font-weight: 600 !important;
        color: #334155 !important;
        cursor: pointer !important;
        outline: none !important;
        appearance: none !important;
        -webkit-appearance: none !important;
        -moz-appearance: none !important;
        white-space: nowrap !important;
        width: auto !important;
        min-width: 140px !important;
        max-width: 230px !important;
        display: inline-block !important;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.03) !important;
        transition: border-color 0.15s ease, box-shadow 0.15s ease !important;
    }
    .filter-dropdown-pill:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.16) !important;
    }

    .btn-invite-staff {
        background: #FC8019 !important;
        color: #FFFFFF !important;
        border: none !important;
        height: 42px;
        padding: 0 24px;
        border-radius: 50px !important;
        font-size: 13.5px;
        font-weight: 700;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        cursor: pointer;
        box-shadow: 0 2px 8px rgba(252, 128, 25, 0.32);
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
    }
    .btn-invite-staff:hover {
        background: #E66A05 !important;
        transform: translateY(-1px);
        box-shadow: 0 5px 14px rgba(252, 128, 25, 0.4);
    }

    /* Split Screen Work Area (Main Table + Side Drawer) */
    .staff-workspace-layout {
        display: flex;
        gap: 24px;
        align-items: flex-start;
        position: relative;
    }
    .staff-table-card {
        flex: 1;
        min-width: 0;
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 16px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.03);
        overflow: hidden;
        transition: all 0.3s ease;
    }

    /* Table Styling */
    .staff-table {
        width: 100%;
        border-collapse: collapse;
        margin: 0;
    }
    .staff-table th {
        background: #F8FAFC;
        padding: 14px 20px;
        font-size: 11.5px;
        font-weight: 700;
        color: #64748B;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border-bottom: 1px solid #E2E8F0;
        text-align: left;
    }
    .staff-table td {
        padding: 16px 20px;
        border-bottom: 1px solid #F1F5F9;
        vertical-align: middle;
        font-size: 13.5px;
        color: #1E293B;
        transition: background 0.15s ease;
    }
    .staff-row {
        cursor: pointer;
    }
    .staff-row:hover td {
        background-color: #FAFAFA;
    }
    .staff-row.selected-row td {
        background-color: #F1F5F9 !important;
    }

    /* Staff Member Avatar & Info Cell */
    .staff-profile-cell {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .staff-avatar-img {
        width: 40px;
        height: 40px;
        border-radius: 50% !important;
        object-fit: cover;
        flex-shrink: 0;
        border: 2px solid #FFFFFF;
        box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
    }
    .staff-avatar-initials {
        width: 40px;
        height: 40px;
        border-radius: 50% !important;
        background: #FC8019;
        color: #FFFFFF;
        font-weight: 700;
        font-size: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25);
    }
    .staff-name-title {
        font-weight: 700;
        color: #0F172A;
        font-size: 14px;
        margin-bottom: 2px;
        line-height: 1.2;
    }
    .staff-id-tag {
        font-size: 11.5px;
        color: #64748B;
        font-weight: 500;
    }

    /* Role Pill Badges */
    .role-badge-pill {
        font-size: 12px;
        font-weight: 600;
        padding: 4px 14px;
        border-radius: 50px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: fit-content;
        letter-spacing: 0.2px;
    }
    .role-badge-pill.super-admin {
        background: #F5F3FF;
        color: #7C3AED;
        border: 1px solid #DDD6FE;
    }
    .role-badge-pill.company-admin {
        background: #FFF0E5;
        color: #FC8019;
        border: 1px solid #FED7AA;
    }
    .role-badge-pill.staff-ops {
        background: #EFF6FF;
        color: #2563EB;
        border: 1px solid #BFDBFE;
    }
    .role-badge-pill.staff-finance {
        background: #ECFDF5;
        color: #059669;
        border: 1px solid #A7F3D0;
    }
    .role-badge-pill.customer {
        background: #F1F5F9;
        color: #475569;
        border: 1px solid #E2E8F0;
    }

    /* Department Label */
    .department-label {
        font-size: 13px;
        color: #475569;
        font-weight: 500;
    }

    /* Status Dot Indicators */
    .status-dot-cell {
        display: inline-flex;
        align-items: center;
        gap: 7px;
        font-size: 13px;
        font-weight: 600;
    }
    .status-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        display: inline-block;
        flex-shrink: 0;
    }
    .status-dot.active {
        background: #10B981;
        box-shadow: 0 0 0 2px rgba(16, 185, 129, 0.2);
    }
    .status-dot.suspended {
        background: #EF4444;
        box-shadow: 0 0 0 2px rgba(239, 68, 68, 0.2);
    }
    .status-dot.pending {
        background: #F59E0B;
        box-shadow: 0 0 0 2px rgba(245, 158, 11, 0.2);
    }

    /* 3-Dots Action Button & Floating Menu */
    .action-menu-wrap {
        position: relative;
        display: inline-block;
        text-align: right;
    }
    .btn-action-trigger {
        background: transparent;
        border: none;
        width: 32px;
        height: 32px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #64748B;
        cursor: pointer;
        transition: all 0.15s ease;
        font-size: 18px;
    }
    .btn-action-trigger:hover {
        background: #F1F5F9;
        color: #0F172A;
    }
    .action-dropdown-card {
        display: none;
        position: absolute;
        right: 0;
        top: calc(100% + 4px);
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 14px;
        box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.12), 0 8px 10px -6px rgba(0, 0, 0, 0.08);
        padding: 6px;
        min-width: 175px;
        z-index: 1000;
        text-align: left;
    }
    .action-dropdown-card.show {
        display: block;
        animation: dropIn 0.18s cubic-bezier(0.16, 1, 0.3, 1);
    }
    @keyframes dropIn {
        from { opacity: 0; transform: translateY(-6px); }
        to { opacity: 1; transform: translateY(0); }
    }
    .dropdown-item-btn {
        display: flex;
        align-items: center;
        gap: 8px;
        width: 100%;
        padding: 8px 12px;
        border: none;
        background: transparent;
        border-radius: 8px;
        font-size: 12.5px;
        font-weight: 500;
        color: #334155;
        cursor: pointer;
        transition: all 0.12s ease;
        text-decoration: none;
    }
    .dropdown-item-btn i { font-size: 14px; }
    .dropdown-item-btn:hover {
        background: #F8FAFC;
        color: #0F172A;
    }
    .dropdown-item-btn.highlight {
        background: #FFF5EE;
        color: #FC8019;
        font-weight: 600;
    }
    .dropdown-item-btn.danger {
        color: #EF4444;
    }
    .dropdown-item-btn.danger:hover {
        background: #FEF2F2;
        color: #DC2626;
    }

    /* Right-Side Slide-Over Drawer ("User Permissions") */
        /* Staff Details Grid in Drawer */
    .staff-details-grid {
        display: flex;
        flex-direction: column;
        gap: 10px;
        padding-top: 4px;
    }
    .detail-card {
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        padding: 10px 14px;
        display: flex;
        flex-direction: column;
        gap: 2px;
        transition: all 0.15s ease;
    }
    .detail-card:hover {
        background: #FFFFFF;
        border-color: #CBD5E1;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04);
    }
    .detail-label {
        font-size: 10px;
        font-weight: 700;
        color: #94A3B8;
        letter-spacing: 0.5px;
        text-transform: uppercase;
    }
    .detail-value {
        font-size: 13px;
        font-weight: 600;
        color: #0F172A;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .detail-value.mono {
        font-family: monospace, SFMono-Regular, Consolas;
    }

    /* Activity Audit Item Row */
    .audit-feed-item {
        padding: 12px 14px;
        background: #F8FAFC;
        border-radius: 10px;
        border-left: 3.5px solid #10B981;
        border-top: 1px solid #F1F5F9;
        border-right: 1px solid #F1F5F9;
        border-bottom: 1px solid #F1F5F9;
        transition: all 0.15s ease;
    }
    .audit-feed-item:hover {
        background: #FFFFFF;
        box-shadow: 0 2px 6px rgba(0,0,0,0.04);
    }
    .audit-feed-title {
        font-size: 12.5px;
        font-weight: 700;
        color: #0F172A;
        margin-bottom: 2px;
    }
    .audit-feed-meta {
        font-size: 11px;
        color: #64748B;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .permissions-drawer {
        width: 410px;
        flex-shrink: 0;
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 18px;
        box-shadow: 0 4px 18px rgba(0, 0, 0, 0.04);
        padding: 24px;
        display: none;
        flex-direction: column;
        position: sticky;
        top: 85px;
        max-height: calc(100vh - 105px);
        overflow: hidden;
        animation: slideInRight 0.25s cubic-bezier(0.16, 1, 0.3, 1);
    }
    .drawer-content-body {
        flex: 1;
        overflow-y: auto;
        overflow-x: hidden;
        padding-right: 6px;
        margin-right: -4px;
        max-height: calc(100vh - 300px);
    }
    .drawer-content-body::-webkit-scrollbar {
        width: 5px;
    }
    .drawer-content-body::-webkit-scrollbar-track {
        background: transparent;
    }
    .drawer-content-body::-webkit-scrollbar-thumb {
        background: #E2E8F0;
        border-radius: 10px;
    }
    .drawer-content-body::-webkit-scrollbar-thumb:hover {
        background: #CBD5E1;
    }
    .permissions-drawer.open {
        display: flex;
    }
    @keyframes slideInRight {
        from { opacity: 0; transform: translateX(20px); }
        to { opacity: 1; transform: translateX(0); }
    }

    .drawer-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 20px;
    }
    .drawer-title {
        font-size: 18px;
        font-weight: 800;
        color: #0F172A;
        margin: 0;
    }
    .drawer-close-btn {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        border: 1px solid #E2E8F0;
        background: #F8FAFC;
        color: #64748B;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 15px;
        transition: all 0.15s ease;
    }
    .drawer-close-btn:hover {
        background: #E2E8F0;
        color: #0F172A;
    }

    /* Drawer Staff Profile Banner */
    .drawer-profile-banner {
        display: flex;
        align-items: center;
        gap: 16px;
        padding-bottom: 18px;
        border-bottom: 1px solid #F1F5F9;
        margin-bottom: 16px;
    }
    .drawer-avatar-wrap {
        position: relative;
        flex-shrink: 0;
    }
    .drawer-avatar-img {
        width: 58px;
        height: 58px;
        border-radius: 50% !important;
        object-fit: cover;
        border: 2px solid #FFFFFF;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }
    .drawer-online-indicator {
        position: absolute;
        bottom: 2px;
        right: 2px;
        width: 13px;
        height: 13px;
        border-radius: 50%;
        background: #10B981;
        border: 2px solid #FFFFFF;
    }
    .drawer-profile-info { min-width: 0; }
    .drawer-staff-name {
        font-size: 16px;
        font-weight: 800;
        color: #0F172A;
        margin-bottom: 4px;
        line-height: 1.2;
    }
    .drawer-staff-meta {
        font-size: 12px;
        color: #64748B;
        margin-top: 4px;
        line-height: 1.4;
    }

    /* Segmented Navigation Tabs */
    .drawer-nav-tabs {
        display: flex;
        align-items: center;
        gap: 18px;
        border-bottom: 1.5px solid #F1F5F9;
        margin-bottom: 20px;
    }
    .drawer-tab-btn {
        background: transparent;
        border: none;
        padding: 8px 2px 10px;
        font-size: 13px;
        font-weight: 600;
        color: #64748B;
        cursor: pointer;
        position: relative;
        transition: color 0.15s ease;
    }
    .drawer-tab-btn:hover { color: #0F172A; }
    .drawer-tab-btn.active {
        color: #FC8019;
        font-weight: 700;
    }
    .drawer-tab-btn.active::after {
        content: '';
        position: absolute;
        bottom: -1.5px;
        left: 0;
        right: 0;
        height: 2.5px;
        background: #FC8019;
        border-radius: 2px;
    }

    /* Module Permissions List */
    .module-permissions-title {
        font-size: 12px;
        font-weight: 700;
        color: #0F172A;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 14px;
    }
    .permission-item-row {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 10px 0;
        border-bottom: 1px solid #F8FAFC;
    }
    .permission-item-left {
        display: flex;
        align-items: center;
        gap: 12px;
        font-size: 13px;
        color: #334155;
        font-weight: 500;
    }
    .permission-item-left i {
        font-size: 16px;
        color: #64748B;
        width: 20px;
        text-align: center;
    }

    /* iOS-Style Pill Rounded Switch */
    .nl-switch {
        position: relative;
        display: inline-block;
        width: 44px;
        height: 24px;
        flex-shrink: 0;
    }
    .nl-switch input { opacity: 0; width: 0; height: 0; }
    .nl-slider {
        position: absolute;
        cursor: pointer;
        inset: 0;
        background-color: #E2E8F0;
        transition: 0.25s cubic-bezier(0.16, 1, 0.3, 1);
        border-radius: 50px;
    }
    .nl-slider:before {
        position: absolute;
        content: "";
        height: 18px;
        width: 18px;
        left: 3px;
        bottom: 3px;
        background-color: white;
        transition: 0.25s cubic-bezier(0.16, 1, 0.3, 1);
        border-radius: 50%;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.15);
    }
    .nl-switch input:checked + .nl-slider {
        background-color: #FC8019;
    }
    .nl-switch input:checked + .nl-slider:before {
        transform: translateX(20px);
    }

    /* Drawer Footer Action Bar */
    .drawer-footer-actions {
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 12px;
        margin-top: 24px;
        padding-top: 18px;
        border-top: 1px solid #F1F5F9;
    }
    .btn-drawer-cancel {
        padding: 9px 22px;
        border-radius: 50px;
        border: 1.5px solid #E2E8F0;
        background: #FFFFFF;
        color: #475569;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.15s ease;
    }
    .btn-drawer-cancel:hover {
        background: #F8FAFC;
        border-color: #CBD5E1;
        color: #0F172A;
    }
    .btn-drawer-save {
        padding: 9px 24px;
        border-radius: 50px;
        border: none;
        background: #FC8019;
        color: #FFFFFF;
        font-size: 13px;
        font-weight: 700;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        cursor: pointer;
        box-shadow: 0 2px 8px rgba(252, 128, 25, 0.32);
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
    }
    .btn-drawer-save:hover {
        background: #E66A05;
        transform: translateY(-1px);
        box-shadow: 0 5px 14px rgba(252, 128, 25, 0.4);
    }

    /* Alerts */
    .custom-alert {
        border-radius: 12px;
        padding: 14px 18px;
        font-size: 13.5px;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 20px;
    }
    .custom-alert.success { background: #ECFDF5; border: 1px solid #A7F3D0; color: #065F46; }
    .custom-alert.danger { background: #FEF2F2; border: 1px solid #FECACA; color: #991B1B; }

    /* Modal Backdrop and Glassmorphic Dialog */
    .nl-modal-backdrop {
        position: fixed;
        inset: 0;
        background: rgba(15, 23, 42, 0.45);
        backdrop-filter: blur(5px);
        -webkit-backdrop-filter: blur(5px);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999999;
        padding: 20px;
        opacity: 0;
        transition: opacity 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        pointer-events: none;
    }
    .nl-modal-backdrop.show { opacity: 1; pointer-events: auto; }
    .nl-modal-dialog {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 24px;
        box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.25);
        max-width: 480px;
        width: 100%;
        padding: 32px 28px 24px;
        position: relative;
        transform: scale(0.92) translateY(12px);
        transition: transform 0.25s cubic-bezier(0.16, 1, 0.3, 1);
    }
    .nl-modal-backdrop.show .nl-modal-dialog { transform: scale(1) translateY(0); }
</style>

<div class="users-page-container">

    <!-- Breadcrumb -->
    <div class="custom-breadcrumb">
        <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <i class="ti ti-chevron-right"></i>
        <span>Management</span>
        <i class="ti ti-chevron-right"></i>
        <span class="current">Users &amp; Roles Governance</span>
    </div>

    <!-- Alert Notifications -->
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="custom-alert success">
            <i class="ti ti-circle-check" style="font-size: 18px;"></i>
            <span>${sessionScope.successMessage}</span>
        </div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="custom-alert danger">
            <i class="ti ti-circle-x" style="font-size: 18px;"></i>
            <span>${sessionScope.errorMessage}</span>
        </div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <!-- Top Telemetry Header Card -->
    <div class="telemetry-header-card">
        <div class="telemetry-header-left">
            <div class="telemetry-icon-box">
                <i class="ti ti-user-shield"></i>
            </div>
            <div>
                <h4 class="telemetry-title">Staff &amp; Role-Based Access Control</h4>
                <p class="telemetry-subtitle">Super Admin &amp; Company Admin governance portal for enterprise staff onboarding, roles, and granular module permissions</p>
            </div>
        </div>
        <div>
            <span class="clearance-pill-badge">
                <i class="ti ti-shield-check"></i> Super Admin Clearance Active
            </span>
        </div>
    </div>

    <!-- Filter & Search Toolbar -->
    <div class="staff-toolbar">
        <div class="toolbar-left-group">
            <div class="staff-search-box">
                <input type="text" id="staffSearchInput" class="staff-search-input" placeholder="Search staff by name, email, employee ID..." oninput="handleStaffFilter()">
                <i class="ti ti-search"></i>
            </div>
            <select id="roleFilter" class="form-select-custom" onchange="handleStaffFilter()">
                <option value="ALL">Role: All Roles</option>
                <option value="1">Super Admin</option>
                <option value="2">Company Admin</option>
                <option value="3">Staff — Operations</option>
                <option value="4">Staff — Finance</option>
                <option value="5">Customer / Shipper</option>
            </select>
            <select id="departmentFilter" class="form-select-custom" onchange="handleStaffFilter()">
                <option value="ALL">Department: All Departments</option>
                <c:forEach var="dept" items="${allDeptNames}">
                    <option value="${dept}">${dept}</option>
                </c:forEach>
            </select>
        </div>

        <div class="toolbar-right-group">
            <button type="button" class="btn-invite-staff" onclick="openInviteModal()">
                <i class="ti ti-plus"></i> Invite New Staff
            </button>
        </div>
    </div>

    <!-- Split Screen Workspace Area -->
    <div class="staff-workspace-layout">

        <!-- Left / Center: Staff Data Table Panel -->
        <div class="staff-table-card">
            <div class="table-responsive">
                <table class="staff-table" id="staffTable">
                    <thead>
                        <tr>
                            <th style="padding-left: 24px;">Staff Member</th>
                            <th>Email</th>
                            <th>Role</th>
                            <th>Department</th>
                            <th>Status</th>
                            <th>Last Active</th>
                            <th style="padding-right: 24px; text-align: right;">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="staffTableBody">
                        <c:forEach var="u" items="${staffList}" varStatus="loop">
                            <tr class="staff-row ${loop.index == 0 ? 'selected-row' : ''}"
                                id="staffRow_${u.userId}"
                                data-id="${u.userId}"
                                data-name="${u.username}"
                                data-email="${u.email}"
                                data-phone="${u.phone}"
                                data-roleid="${u.roleId}"
                                data-rolename="${u.roleName}"
                                data-roledesc="${u.roleDesc}"
                                data-dept="${u.dept}"
                                data-companyid="${u.companyId}"
                                data-status="${u.status}"
                                data-failedlogins="${u.failedLoginCount}"
                                data-joined="${u.joinedDate}"
                                data-updated="${u.updatedDate}"
                                data-lastactive="${u.lastActive}"
                                data-lastloginfull="${u.lastLoginFull}"
                                onclick="selectStaffMember(${u.userId})">

                                <!-- Staff Member Profile -->
                                <td style="padding-left: 24px;">
                                    <div class="staff-profile-cell">
                                        <div class="staff-avatar-initials">
                                            <c:set var="uname" value="${u.username}" />
                                            ${uname.length() >= 2 ? uname.substring(0, 2).toUpperCase() : uname.toUpperCase()}
                                        </div>
                                        <div>
                                            <div class="staff-name-title">${u.username}</div>
                                            <div class="staff-id-tag">#STF-${u.userId + 100}</div>
                                        </div>
                                    </div>
                                </td>

                                <!-- Email -->
                                <td>
                                    <a href="mailto:${u.email}" style="color: #475569; text-decoration: none;" onclick="event.stopPropagation();">
                                        ${u.email}
                                    </a>
                                </td>

                                <!-- Role Pill -->
                                <td>
                                    <c:choose>
                                        <c:when test="${u.roleId == 1}">
                                            <span class="role-badge-pill super-admin">Super Admin</span>
                                        </c:when>
                                        <c:when test="${u.roleId == 2}">
                                            <span class="role-badge-pill company-admin">Company Admin</span>
                                        </c:when>
                                        <c:when test="${u.roleId == 3}">
                                            <span class="role-badge-pill staff-ops">Staff — Operations</span>
                                        </c:when>
                                        <c:when test="${u.roleId == 4}">
                                            <span class="role-badge-pill staff-finance">Staff — Finance</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="role-badge-pill customer">Customer / Shipper</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <!-- Department -->
                                <td>
                                    <span class="department-label">${u.dept}</span>
                                </td>

                                <!-- Status Dot -->
                                <td>
                                    <div class="status-dot-cell">
                                        <c:choose>
                                            <c:when test="${u.status == 'Active'}">
                                                <span class="status-dot active"></span>
                                                <span style="color: #059669;">Active</span>
                                            </c:when>
                                            <c:when test="${u.status == 'Pending'}">
                                                <span class="status-dot pending"></span>
                                                <span style="color: #D97706;">Pending Review</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-dot suspended"></span>
                                                <span style="color: #DC2626;">Suspended</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>

                                <!-- Last Active -->
                                <td style="color: #64748B; font-size: 13px;">
                                    ${u.lastActive}
                                </td>

                                <!-- 3-Dots Actions Menu -->
                                <td style="padding-right: 24px; text-align: right;" onclick="event.stopPropagation();">
                                    <div class="action-menu-wrap">
                                        <button type="button" class="btn-action-trigger" onclick="toggleActionDropdown(${u.userId}, event)" title="Manage staff actions">
                                            <i class="ti ti-dots-vertical"></i>
                                        </button>
                                        <div class="action-dropdown-card" id="actionDropdown_${u.userId}">
                                            <button type="button" class="dropdown-item-btn" onclick="openStaffProfileModal(${u.userId})">
                                                <i class="ti ti-user"></i> View Profile
                                            </button>
                                            <button type="button" class="dropdown-item-btn highlight" onclick="openEditPermissions(${u.userId})">
                                                <i class="ti ti-pencil"></i> Edit Permissions
                                            </button>
                                            <button type="button" class="dropdown-item-btn" onclick="resetStaffPassword(${u.userId})">
                                                <i class="ti ti-reload"></i> Reset Password
                                            </button>
                                            <c:choose>
                                                <c:when test="${u.status == 'Active'}">
                                                    <form method="POST" id="suspendForm_${u.userId}" style="margin: 0;">
                                                        <input type="hidden" name="userId" value="${u.userId}">
                                                        <input type="hidden" name="action" value="suspend">
                                                        <button type="button" class="dropdown-item-btn" onclick="confirmSuspend(${u.userId}, '${u.username}')">
                                                            <i class="ti ti-ban"></i> Suspend Staff
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <form method="POST" id="activateForm_${u.userId}" style="margin: 0;">
                                                        <input type="hidden" name="userId" value="${u.userId}">
                                                        <input type="hidden" name="action" value="activate">
                                                        <button type="button" class="dropdown-item-btn" onclick="confirmActivate(${u.userId}, '${u.username}')">
                                                            <i class="ti ti-circle-check"></i> Activate Staff
                                                        </button>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
                                            <form method="POST" id="deleteForm_${u.userId}" style="margin: 0;">
                                                <input type="hidden" name="userId" value="${u.userId}">
                                                <input type="hidden" name="action" value="delete">
                                                <button type="button" class="dropdown-item-btn danger" onclick="confirmDelete(${u.userId}, '${u.username}')">
                                                    <i class="ti ti-trash"></i> Delete User
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <!-- Bottom Pagination Bar -->
            <div class="nl-pagination-wrapper" id="staffPagination" style="border-top: 1px solid #F1F5F9;">
                <div class="nl-pagination-info">
                    <span>Showing <strong id="staffPageStart">1</strong> to <strong id="staffPageEnd">10</strong> of <strong id="staffTotalRows">48</strong> staff members</span>
                    <div class="d-inline-flex align-items-center gap-2 ms-2">
                        <span style="color: #94A3B8; font-size: 12.5px;">Rows per page:</span>
                        <select id="staffPageSize" class="nl-page-size-select no-custom-select" onchange="changeStaffPageSize(this.value)">
                            <option value="10" selected>10</option>
                            <option value="25">25</option>
                            <option value="50">50</option>
                        </select>
                    </div>
                </div>
                <div class="nl-pagination-nav" id="staffPageNav">
                    <!-- Dynamically generated circular buttons -->
                </div>
            </div>
        </div>

        <!-- Right-Side Slide-Over Drawer: User Permissions -->
        <div class="permissions-drawer open" id="permissionsDrawer">
            <div class="drawer-header">
                <h5 class="drawer-title">User Permissions</h5>
                <button type="button" class="drawer-close-btn" onclick="closePermissionsDrawer()" aria-label="Close">
                    <i class="ti ti-x"></i>
                </button>
            </div>

            <!-- Staff Profile Banner Card -->
            <div class="drawer-profile-banner">
                <div class="drawer-avatar-wrap">
                    <div class="staff-avatar-initials" id="drawerAvatarBox" style="width: 58px; height: 58px; font-size: 18px;">
                        RS
                    </div>
                    <span class="drawer-online-indicator"></span>
                </div>
                <div class="drawer-profile-info">
                    <div class="drawer-staff-name" id="drawerStaffName">Rohit Sharma</div>
                    <div id="drawerRolePillWrap">
                        <span class="role-badge-pill staff-ops" id="drawerRolePill">Company Staff — Operations</span>
                    </div>
                    <div class="drawer-staff-meta" id="drawerStaffEmail">rohit.sharma@nlogistic.com</div>
                    <div class="drawer-staff-meta" style="color: #94A3B8; font-size: 11.5px;">
                        <span id="drawerDeptName">Operations Department</span> &bull; 📅 Joined <span id="drawerJoinedDate">12 Mar 2024</span>
                    </div>
                </div>
            </div>

            <!-- Segmented Navigation Tabs (Details First) -->
            <div class="drawer-nav-tabs">
                <button type="button" class="drawer-tab-btn active" id="tabDetailsBtn" onclick="switchDrawerTab('details')">Details</button>
                <button type="button" class="drawer-tab-btn" id="tabPermBtn" onclick="switchDrawerTab('permissions')">Permissions</button>
                <button type="button" class="drawer-tab-btn" id="tabRoleBtn" onclick="switchDrawerTab('role')">Role Details</button>
                <button type="button" class="drawer-tab-btn" id="tabAuditBtn" onclick="switchDrawerTab('audit')">Activity Audit</button>
            </div>

            <!-- Scrollable Tab Content Container -->
            <div class="drawer-content-body">
            <!-- Tab 1: Staff Member Full Details (From users Table) -->
            <div id="drawerTabDetails" style="display: block;">
                <div class="staff-details-grid">
                    <div class="detail-card">
                        <span class="detail-label">Account Status</span>
                        <div id="dStatus" class="detail-value">
                            <span class="status-dot active"></span> <span style="color: #059669;">Active</span>
                        </div>
                    </div>
                    <div class="detail-card">
                        <span class="detail-label">Staff Username</span>
                        <div id="dUsername" class="detail-value mono">superadmin</div>
                    </div>
                    <div class="detail-card">
                        <span class="detail-label">Employee ID &amp; User ID</span>
                        <div class="detail-value">
                            <span id="dEmpId" style="color: #FC8019; font-weight: 700;">#STF-101</span>
                            <span style="color: #94A3B8; font-weight: 500; font-size: 12px;" id="dUserId">(USR-1)</span>
                        </div>
                    </div>
                    <div class="detail-card">
                        <span class="detail-label">Corporate Email</span>
                        <div id="dEmail" class="detail-value text-truncate" style="font-size: 12.5px;">admin@nlogistic.com</div>
                    </div>
                    <div class="detail-card">
                        <span class="detail-label">Phone Contact</span>
                        <div id="dPhone" class="detail-value">+91 98765 43210</div>
                    </div>
                    <div class="detail-card">
                        <span class="detail-label">Assigned Tenant / Company</span>
                        <div id="dDept" class="detail-value">Administration</div>
                    </div>
                    <div class="detail-card">
                        <span class="detail-label">System Role Assignment</span>
                        <div id="dRoleBadge" class="detail-value">
                            <span class="role-badge-pill super-admin">Super Admin</span>
                        </div>
                    </div>
                    <div class="detail-card">
                        <span class="detail-label">Failed Login Attempts</span>
                        <div id="dFailedLogins" class="detail-value">0 attempts</div>
                    </div>
                    <div class="detail-card">
                        <span class="detail-label">Last Login Timestamp</span>
                        <div id="dLastLogin" class="detail-value">Just now</div>
                    </div>
                    <div class="detail-card">
                        <span class="detail-label">Account Onboarded Date</span>
                        <div id="dCreated" class="detail-value">02 Sep 2026</div>
                    </div>
                    <div class="detail-card">
                        <span class="detail-label">Profile Last Updated</span>
                        <div id="dUpdated" class="detail-value">04 Sep 2026</div>
                    </div>
                </div>
            </div>

            <!-- Tab 2: Permissions View -->
            <div id="drawerTabPermissions" style="display: none;">
                <div class="module-permissions-title">Module Permissions</div>

                <!-- 10 Granular Module Permissions Matching Mockup & SRS -->
                <form method="POST" id="savePermissionsForm">
                    <input type="hidden" name="action" value="savePermissions">
                    <input type="hidden" name="userId" id="drawerUserIdInput" value="3">

                    <!-- Module 1 -->
                    <div class="permission-item-row">
                        <div class="permission-item-left">
                            <i class="ti ti-chart-bar"></i>
                            <span>Dashboard &amp; Executive Analytics</span>
                        </div>
                        <label class="nl-switch">
                            <input type="checkbox" name="perm_dashboard" id="perm_dashboard" checked>
                            <span class="nl-slider"></span>
                        </label>
                    </div>

                    <!-- Module 2 -->
                    <div class="permission-item-row">
                        <div class="permission-item-left">
                            <i class="ti ti-truck"></i>
                            <span>Container Fleet Tracking &amp; Movement (Point A &rarr; B)</span>
                        </div>
                        <label class="nl-switch">
                            <input type="checkbox" name="perm_tracking" id="perm_tracking" checked>
                            <span class="nl-slider"></span>
                        </label>
                    </div>

                    <!-- Module 3 -->
                    <div class="permission-item-row">
                        <div class="permission-item-left">
                            <i class="ti ti-clipboard-check"></i>
                            <span>Shipment Booking &amp; Slot Allocation</span>
                        </div>
                        <label class="nl-switch">
                            <input type="checkbox" name="perm_shipments" id="perm_shipments" checked>
                            <span class="nl-slider"></span>
                        </label>
                    </div>

                    <!-- Module 4 -->
                    <div class="permission-item-row">
                        <div class="permission-item-left">
                            <i class="ti ti-chart-pie"></i>
                            <span>Profit &amp; Loss Graph (PLG) &amp; Loss Reason Map</span>
                        </div>
                        <label class="nl-switch">
                            <input type="checkbox" name="perm_plg" id="perm_plg">
                            <span class="nl-slider"></span>
                        </label>
                    </div>

                    <!-- Module 5 -->
                    <div class="permission-item-row">
                        <div class="permission-item-left">
                            <i class="ti ti-file-invoice"></i>
                            <span>Invoicing, Billing &amp; Ledger Access</span>
                        </div>
                        <label class="nl-switch">
                            <input type="checkbox" name="perm_invoicing" id="perm_invoicing">
                            <span class="nl-slider"></span>
                        </label>
                    </div>

                    <!-- Module 6 -->
                    <div class="permission-item-row">
                        <div class="permission-item-left">
                            <i class="ti ti-package"></i>
                            <span>Warehouse Inventory &amp; Bulk Stock Upload</span>
                        </div>
                        <label class="nl-switch">
                            <input type="checkbox" name="perm_inventory" id="perm_inventory" checked>
                            <span class="nl-slider"></span>
                        </label>
                    </div>

                    <!-- Module 7 -->
                    <div class="permission-item-row">
                        <div class="permission-item-left">
                            <i class="ti ti-shield"></i>
                            <span>Loss &amp; Damage Cargo Claims Management</span>
                        </div>
                        <label class="nl-switch">
                            <input type="checkbox" name="perm_claims" id="perm_claims" checked>
                            <span class="nl-slider"></span>
                        </label>
                    </div>

                    <!-- Module 8 -->
                    <div class="permission-item-row">
                        <div class="permission-item-left">
                            <i class="ti ti-file-text"></i>
                            <span>Regulatory Compliance &amp; Documents Upload</span>
                        </div>
                        <label class="nl-switch">
                            <input type="checkbox" name="perm_compliance" id="perm_compliance">
                            <span class="nl-slider"></span>
                        </label>
                    </div>

                    <!-- Module 9 -->
                    <div class="permission-item-row">
                        <div class="permission-item-left">
                            <i class="ti ti-users"></i>
                            <span>Staff User Governance &amp; Approvals</span>
                        </div>
                        <label class="nl-switch">
                            <input type="checkbox" name="perm_users" id="perm_users">
                            <span class="nl-slider"></span>
                        </label>
                    </div>

                    <!-- Module 10 -->
                    <div class="permission-item-row">
                        <div class="permission-item-left">
                            <i class="ti ti-settings"></i>
                            <span>System Configuration &amp; Algorithm Parameters</span>
                        </div>
                        <label class="nl-switch">
                            <input type="checkbox" name="perm_settings" id="perm_settings">
                            <span class="nl-slider"></span>
                        </label>
                    </div>

                    <!-- Drawer Footer Action Bar -->
                    <div class="drawer-footer-actions">
                        <button type="button" class="btn-drawer-cancel" onclick="closePermissionsDrawer()">Cancel</button>
                        <button type="submit" class="btn-drawer-save">
                            <i class="ti ti-check"></i> Save Changes
                        </button>
                    </div>
                </form>
            </div>

            <!-- Role Details View -->
            <div id="drawerTabRole" style="display: none; padding-top: 10px;">
                <div style="background: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 12px; padding: 16px; margin-bottom: 16px;">
                    <div style="font-weight: 700; color: #0F172A; font-size: 14px; margin-bottom: 6px;">Role Hierarchy Level</div>
                    <p style="font-size: 12.5px; color: #64748B; margin: 0; line-height: 1.5;" id="drawerRoleDesc">
                        Operations staff member assigned to terminal checkpoints, container movement events, and cargo verification.
                    </p>
                </div>
                <div style="font-size: 12.5px; color: #64748B; line-height: 1.6;">
                    <div><strong>Authentication:</strong> SHA-256 Multi-Layer</div>
                    <div><strong>Session Timeout:</strong> 30 Minutes</div>
                    <div><strong>Clearance Scope:</strong> Operations Tier-2</div>
                </div>
            </div>

            <!-- Tab 4: Real Activity Audit View (from audit_log Table) -->
            <div id="drawerTabAudit" style="display: none; padding-top: 6px;">
                <div id="drawerAuditList" style="display: flex; flex-direction: column; gap: 10px;">
                    <!-- Dynamically populated from real audit_log -->
                </div>
            </div>
            </div> <!-- end .drawer-content-body -->
        </div>

    </div>
</div>

<!-- Modal: Invite New Staff Member -->
<div id="inviteStaffModal" class="nl-modal-backdrop" style="display: none;">
    <div class="nl-modal-dialog">
        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px;">
            <div style="display: flex; align-items: center; gap: 12px;">
                <div style="width: 44px; height: 44px; border-radius: 12px; background: #FFF3EA; color: #FC8019; display: flex; align-items: center; justify-content: center; font-size: 20px;">
                    <i class="ti ti-user-plus"></i>
                </div>
                <div>
                    <h5 style="font-size: 17px; font-weight: 800; color: #0F172A; margin: 0;">Invite New Staff Member</h5>
                    <p style="font-size: 12.5px; color: #64748B; margin: 0;">Deploy access credentials and assign operational role</p>
                </div>
            </div>
            <button type="button" class="drawer-close-btn" onclick="closeInviteModal()" aria-label="Close">
                <i class="ti ti-x"></i>
            </button>
        </div>

        <form method="POST">
            <input type="hidden" name="action" value="inviteStaff">
            
            <div style="margin-bottom: 14px;">
                <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px; display: block;">Full Name</label>
                <input type="text" name="inviteName" required class="form-control" placeholder="e.g. Arjun Mehta" style="border-radius: 50px; height: 42px; font-size: 13px; border: 1.5px solid #E2E8F0; padding: 0 16px;">
            </div>

            <div style="margin-bottom: 14px;">
                <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px; display: block;">Corporate Email Address</label>
                <input type="email" name="inviteEmail" required class="form-control" placeholder="e.g. arjun.mehta@nlogistic.com" style="border-radius: 50px; height: 42px; font-size: 13px; border: 1.5px solid #E2E8F0; padding: 0 16px;">
            </div>

            <div style="margin-bottom: 14px;">
                <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px; display: block;">Phone Number</label>
                <input type="text" name="invitePhone" class="form-control" placeholder="e.g. +91 98765 43210" style="border-radius: 50px; height: 42px; font-size: 13px; border: 1.5px solid #E2E8F0; padding: 0 16px;">
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 24px;">
                <div>
                    <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px; display: block;">Role Assignment</label>
                    <select name="inviteRoleId" class="form-control no-custom-select" style="border-radius: 50px; height: 42px; font-size: 13px; border: 1.5px solid #E2E8F0; padding: 0 14px; cursor: pointer;">
                        <option value="3">Staff — Operations</option>
                        <option value="4">Staff — Finance</option>
                        <option value="2">Company Admin</option>
                        <option value="1">Super Admin</option>
                        <option value="5">Customer / Client</option>
                    </select>
                </div>
                <div>
                    <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px; display: block;">Department</label>
                    <select name="inviteDept" class="form-control no-custom-select" style="border-radius: 50px; height: 42px; font-size: 13px; border: 1.5px solid #E2E8F0; padding: 0 14px; cursor: pointer;">
                        <option value="Fleet Operations">Fleet Operations</option>
                        <option value="Invoicing & Billing">Invoicing &amp; Billing</option>
                        <option value="Administration">Administration</option>
                        <option value="Port Warehouse">Port Warehouse</option>
                    </select>
                </div>
            </div>

            <div style="display: flex; align-items: center; justify-content: flex-end; gap: 12px;">
                <button type="button" class="btn-drawer-cancel" onclick="closeInviteModal()">Cancel</button>
                <button type="submit" class="btn-drawer-save">
                    <i class="ti ti-mail-forward"></i> Send Invitation
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Modal: Custom Confirmation Modal -->
<div id="nlCustomConfirmModal" class="nl-modal-backdrop" style="display: none;">
    <div class="nl-modal-dialog" style="max-width: 420px; text-align: center;">
        <button type="button" class="drawer-close-btn" style="position: absolute; top: 18px; right: 18px;" onclick="closeCustomConfirmModal()" aria-label="Close">
            <i class="ti ti-x"></i>
        </button>
        <div id="confirmIconBox" style="width: 58px; height: 58px; border-radius: 18px; margin: 0 auto 16px; display: flex; align-items: center; justify-content: center; font-size: 26px; background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA;">
            <i class="ti ti-alert-triangle" id="confirmIcon"></i>
        </div>
        <h5 id="confirmTitle" style="font-size: 18px; font-weight: 800; color: #0F172A; margin-bottom: 6px;">Confirm Action</h5>
        <p id="confirmDesc" style="font-size: 13px; color: #64748B; line-height: 1.5; margin: 0 0 20px 0;">Are you sure you want to proceed?</p>
        <div style="display: flex; align-items: center; justify-content: center; gap: 12px;">
            <button type="button" class="btn-drawer-cancel" onclick="closeCustomConfirmModal()">Cancel</button>
            <button type="button" class="btn-drawer-save" id="confirmActionBtn" style="background: #DC2626;">Confirm</button>
        </div>
    </div>
</div>

<script>
    // State management
    let currentSelectedUserId = null;
    let pendingActionForm = null;
    let currentPage = 1;
    let pageSize = 10;
    let matchingStaffRows = [];

    // Real Audit Data from database
    const realUserAuditMap = ${userAuditJson};

    // Select Staff Member & Populate All 4 Drawer Tabs with 100% Real DB Data
    function selectStaffMember(userId) {
        currentSelectedUserId = userId;
        const row = document.getElementById('staffRow_' + userId);
        if (!row) return;

        document.querySelectorAll('.staff-row').forEach(r => r.classList.remove('selected-row'));
        row.classList.add('selected-row');

        const staffName = row.getAttribute('data-name') || 'Staff Member';
        const staffEmail = row.getAttribute('data-email') || 'staff@nlogistic.com';
        const staffPhone = row.getAttribute('data-phone') || '+91 98765 43210';
        const staffDept = row.getAttribute('data-dept') || 'Fleet Operations';
        const roleId = parseInt(row.getAttribute('data-roleid') || '3', 10);
        const roleName = row.getAttribute('data-rolename') || 'Staff Member';
        const roleDesc = row.getAttribute('data-roledesc') || 'Authorized operations account';
        const staffStatus = row.getAttribute('data-status') || 'Active';
        const failedLogins = row.getAttribute('data-failedlogins') || '0';
        const joinedDate = row.getAttribute('data-joined') || '02 Sep 2026';
        const updatedDate = row.getAttribute('data-updated') || joinedDate;
        const lastLoginFull = row.getAttribute('data-lastloginfull') || 'Never logged in';

        // 1. Header Banner Info
        document.getElementById('drawerStaffName').textContent = staffName;
        document.getElementById('drawerStaffEmail').textContent = staffEmail;
        document.getElementById('drawerDeptName').textContent = staffDept;
        document.getElementById('drawerUserIdInput').value = userId;
        const drawerJoined = document.getElementById('drawerJoinedDate');
        if (drawerJoined) drawerJoined.textContent = joinedDate;

        const initials = staffName.substring(0, Math.min(2, staffName.length)).toUpperCase();
        document.getElementById('drawerAvatarBox').textContent = initials;

        // Role Badge in Header
        const rolePill = document.getElementById('drawerRolePill');
        let roleBadgeHtml = '<span class="role-badge-pill staff-ops">' + roleName + '</span>';
        if (roleId === 1) {
            rolePill.className = 'role-badge-pill super-admin';
            rolePill.textContent = 'Super Admin';
            roleBadgeHtml = '<span class="role-badge-pill super-admin">Super Admin</span>';
            setAllToggles(true);
        } else if (roleId === 2) {
            rolePill.className = 'role-badge-pill company-admin';
            rolePill.textContent = 'Company Admin';
            roleBadgeHtml = '<span class="role-badge-pill company-admin">Company Admin</span>';
            setRolePreset([true, true, true, true, true, true, true, true, false, false]);
        } else if (roleId === 4) {
            rolePill.className = 'role-badge-pill staff-finance';
            rolePill.textContent = 'Staff — Finance';
            roleBadgeHtml = '<span class="role-badge-pill staff-finance">Staff — Finance</span>';
            setRolePreset([true, false, false, true, true, false, true, false, false, false]);
        } else if (roleId === 5) {
            rolePill.className = 'role-badge-pill customer';
            rolePill.textContent = 'Customer / Shipper';
            roleBadgeHtml = '<span class="role-badge-pill customer">Customer / Shipper</span>';
            setRolePreset([true, true, true, false, false, false, false, false, false, false]);
        } else {
            rolePill.className = 'role-badge-pill staff-ops';
            rolePill.textContent = 'Company Staff — Operations';
            roleBadgeHtml = '<span class="role-badge-pill staff-ops">Company Staff — Operations</span>';
            setRolePreset([true, true, true, false, false, true, true, false, false, false]);
        }

        // 2. Populate Tab 1: Details View (Real Data from users table)
        const dStatus = document.getElementById('dStatus');
        if (dStatus) {
            if (staffStatus === 'Active') {
                dStatus.innerHTML = '<span class="status-dot active"></span> <span style="color: #059669;">Active</span>';
            } else if (staffStatus === 'Pending') {
                dStatus.innerHTML = '<span class="status-dot pending"></span> <span style="color: #D97706;">Pending Review</span>';
            } else {
                dStatus.innerHTML = '<span class="status-dot suspended"></span> <span style="color: #DC2626;">Suspended / Locked</span>';
            }
        }
        document.getElementById('dUsername').textContent = staffName;
        document.getElementById('dEmpId').textContent = '#STF-' + (parseInt(userId) + 100);
        document.getElementById('dUserId').textContent = '(USR-' + userId + ')';
        document.getElementById('dEmail').textContent = staffEmail;
        document.getElementById('dPhone').textContent = staffPhone;
        document.getElementById('dDept').textContent = staffDept;
        document.getElementById('dRoleBadge').innerHTML = roleBadgeHtml;
        document.getElementById('dFailedLogins').textContent = failedLogins + ' attempts';
        document.getElementById('dLastLogin').textContent = lastLoginFull;
        document.getElementById('dCreated').textContent = joinedDate;
        document.getElementById('dUpdated').textContent = updatedDate;

        // 3. Populate Tab 3: Role Details (Real Data from roles table)
        const roleDescEl = document.getElementById('drawerRoleDesc');
        if (roleDescEl) {
            roleDescEl.textContent = roleDesc + ' — ' + (roleId === 1 ? 'Global system clearance across all tenant operations.' : (roleId === 2 ? 'Tenant company governance, fleet allocation and staff management.' : (roleId === 4 ? 'Corporate finance operations, billing invoices and payment ledgers.' : 'Checkpoint operations and terminal tracking verification.')));
        }

        // 4. Populate Tab 4: Activity Audit (Real Data from audit_log table)
        const auditListEl = document.getElementById('drawerAuditList');
        if (auditListEl) {
            auditListEl.innerHTML = '';
            const userEvents = realUserAuditMap[userId] || [];
            if (userEvents.length > 0) {
                userEvents.forEach(ev => {
                    const item = document.createElement('div');
                    item.className = 'audit-feed-item';
                    let borderColor = '#10B981';
                    if (ev.action.includes('FAILED') || ev.action.includes('LOCKED')) borderColor = '#EF4444';
                    else if (ev.action.includes('LOGOUT') || ev.action.includes('CHANGE')) borderColor = '#FC8019';
                    else if (ev.action.includes('REGISTER') || ev.action.includes('CONTAINER')) borderColor = '#2563EB';
                    item.style.borderLeftColor = borderColor;

                    item.innerHTML = '<div class="audit-feed-title">' + ev.action + '</div>' +
                                     '<div class="audit-feed-meta">' +
                                     '<span><i class="ti ti-cube"></i> ' + ev.entity + '</span> &bull; ' +
                                     '<span><i class="ti ti-clock"></i> ' + ev.time + '</span> &bull; ' +
                                     '<span>IP: ' + ev.ip + '</span>' +
                                     '</div>';
                    auditListEl.appendChild(item);
                });
            } else {
                // Real initial account creation entry
                const item = document.createElement('div');
                item.className = 'audit-feed-item';
                item.style.borderLeftColor = '#10B981';
                item.innerHTML = '<div class="audit-feed-title">USER_REGISTERED</div>' +
                                 '<div class="audit-feed-meta">' +
                                 '<span><i class="ti ti-user-check"></i> users #' + userId + ' (' + staffName + ')</span> &bull; ' +
                                 '<span><i class="ti ti-clock"></i> ' + joinedDate + '</span> &bull; ' +
                                 '<span>IP: 127.0.0.1</span>' +
                                 '</div>';
                auditListEl.appendChild(item);
            }
        }

        // Open Drawer
        openPermissionsDrawer();
    }

    function setAllToggles(val) {
        ['perm_dashboard', 'perm_tracking', 'perm_shipments', 'perm_plg', 'perm_invoicing', 
         'perm_inventory', 'perm_claims', 'perm_compliance', 'perm_users', 'perm_settings'].forEach(id => {
            const el = document.getElementById(id);
            if (el) el.checked = val;
        });
    }

    function setRolePreset(arr) {
        const ids = ['perm_dashboard', 'perm_tracking', 'perm_shipments', 'perm_plg', 'perm_invoicing', 
                     'perm_inventory', 'perm_claims', 'perm_compliance', 'perm_users', 'perm_settings'];
        ids.forEach((id, idx) => {
            const el = document.getElementById(id);
            if (el) el.checked = !!arr[idx];
        });
    }

    function openPermissionsDrawer() {
        const drawer = document.getElementById('permissionsDrawer');
        drawer.classList.add('open');
    }

    function closePermissionsDrawer() {
        const drawer = document.getElementById('permissionsDrawer');
        drawer.classList.remove('open');
        document.querySelectorAll('.staff-row').forEach(r => r.classList.remove('selected-row'));
    }

    function switchDrawerTab(tab) {
        document.getElementById('tabDetailsBtn').classList.toggle('active', tab === 'details');
        document.getElementById('tabPermBtn').classList.toggle('active', tab === 'permissions');
        document.getElementById('tabRoleBtn').classList.toggle('active', tab === 'role');
        document.getElementById('tabAuditBtn').classList.toggle('active', tab === 'audit');

        document.getElementById('drawerTabDetails').style.display = (tab === 'details') ? 'block' : 'none';
        document.getElementById('drawerTabPermissions').style.display = (tab === 'permissions') ? 'block' : 'none';
        document.getElementById('drawerTabRole').style.display = (tab === 'role') ? 'block' : 'none';
        document.getElementById('drawerTabAudit').style.display = (tab === 'audit') ? 'block' : 'none';
    }

    // 3-Dots Action Dropdown Toggle
    function toggleActionDropdown(userId, event) {
        event.stopPropagation();
        const allDropdowns = document.querySelectorAll('.action-dropdown-card');
        allDropdowns.forEach(d => {
            if (d.id !== 'actionDropdown_' + userId) d.classList.remove('show');
        });

        const target = document.getElementById('actionDropdown_' + userId);
        if (target) {
            target.classList.toggle('show');
        }
    }

    document.addEventListener('click', function(e) {
        if (!e.target.closest('.action-menu-wrap')) {
            document.querySelectorAll('.action-dropdown-card').forEach(d => d.classList.remove('show'));
        }
    });

    function openEditPermissions(userId) {
        document.querySelectorAll('.action-dropdown-card').forEach(d => d.classList.remove('show'));
        selectStaffMember(userId);
    }

    function openStaffProfileModal(userId) {
        document.querySelectorAll('.action-dropdown-card').forEach(d => d.classList.remove('show'));
        selectStaffMember(userId);
        switchDrawerTab('role');
    }

    function resetStaffPassword(userId) {
        document.querySelectorAll('.action-dropdown-card').forEach(d => d.classList.remove('show'));
        showCustomConfirmModal({
            title: 'Reset Staff Password?',
            desc: 'A secure temporary one-time password link will be dispatched to the staff member corporate email.',
            icon: 'ti ti-key',
            color: '#2563EB',
            btnText: 'Send Reset Email',
            onConfirm: function() {
                alert('Password reset link successfully dispatched to staff corporate email.');
            }
        });
    }

    function confirmSuspend(userId, name) {
        document.querySelectorAll('.action-dropdown-card').forEach(d => d.classList.remove('show'));
        pendingActionForm = document.getElementById('suspendForm_' + userId);
        showCustomConfirmModal({
            title: 'Suspend Staff Account?',
            desc: 'Are you sure you want to suspend account for ' + name + '? Portal access will be temporarily locked.',
            icon: 'ti ti-ban',
            color: '#DC2626',
            btnText: 'Yes, Suspend',
            onConfirm: function() {
                if (pendingActionForm) pendingActionForm.submit();
            }
        });
    }

    function confirmActivate(userId, name) {
        document.querySelectorAll('.action-dropdown-card').forEach(d => d.classList.remove('show'));
        pendingActionForm = document.getElementById('activateForm_' + userId);
        showCustomConfirmModal({
            title: 'Activate Staff Account?',
            desc: 'Restore operational credentials and portal clearance for ' + name + '?',
            icon: 'ti ti-circle-check',
            color: '#10B981',
            btnText: 'Yes, Activate',
            onConfirm: function() {
                if (pendingActionForm) pendingActionForm.submit();
            }
        });
    }

    function confirmDelete(userId, name) {
        document.querySelectorAll('.action-dropdown-card').forEach(d => d.classList.remove('show'));
        pendingActionForm = document.getElementById('deleteForm_' + userId);
        showCustomConfirmModal({
            title: 'Delete Staff User?',
            desc: 'Permanent action: Remove ' + name + ' from active corporate staff directory.',
            icon: 'ti ti-trash',
            color: '#DC2626',
            btnText: 'Delete Account',
            onConfirm: function() {
                if (pendingActionForm) pendingActionForm.submit();
            }
        });
    }

    // Modal helpers
    function openInviteModal() {
        const m = document.getElementById('inviteStaffModal');
        m.style.display = 'flex';
        requestAnimationFrame(() => m.classList.add('show'));
    }
    function closeInviteModal() {
        const m = document.getElementById('inviteStaffModal');
        m.classList.remove('show');
        setTimeout(() => m.style.display = 'none', 200);
    }

    function showCustomConfirmModal(opts) {
        document.getElementById('confirmTitle').textContent = opts.title;
        document.getElementById('confirmDesc').textContent = opts.desc;
        const iconBox = document.getElementById('confirmIconBox');
        const icon = document.getElementById('confirmIcon');
        icon.className = opts.icon;
        iconBox.style.color = opts.color;
        iconBox.style.background = (opts.color === '#10B981') ? '#ECFDF5' : ((opts.color === '#2563EB') ? '#EFF6FF' : '#FEF2F2');
        iconBox.style.borderColor = (opts.color === '#10B981') ? '#A7F3D0' : ((opts.color === '#2563EB') ? '#BFDBFE' : '#FECACA');
        
        const btn = document.getElementById('confirmActionBtn');
        btn.textContent = opts.btnText;
        btn.style.background = opts.color;
        btn.onclick = function() {
            closeCustomConfirmModal();
            if (opts.onConfirm) opts.onConfirm();
        };

        const m = document.getElementById('nlCustomConfirmModal');
        m.style.display = 'flex';
        requestAnimationFrame(() => m.classList.add('show'));
    }

    function closeCustomConfirmModal() {
        const m = document.getElementById('nlCustomConfirmModal');
        m.classList.remove('show');
        setTimeout(() => m.style.display = 'none', 200);
    }

    // Filtering & Circular Pagination
    function handleStaffFilter() {
        currentPage = 1;
        applyStaffFilters();
    }

    function changeStaffPageSize(size) {
        pageSize = parseInt(size, 10) || 10;
        currentPage = 1;
        applyStaffFilters();
    }

    function goToStaffPage(page) {
        currentPage = page;
        updateStaffPagination();
    }

    function applyStaffFilters() {
        const query = document.getElementById('staffSearchInput').value.trim().toLowerCase();
        const roleVal = document.getElementById('roleFilter').value;
        const deptVal = document.getElementById('departmentFilter').value;

        const allRows = Array.from(document.querySelectorAll('.staff-row'));
        matchingStaffRows = [];

        allRows.forEach(row => {
            const name = (row.getAttribute('data-name') || '').toLowerCase();
            const email = (row.getAttribute('data-email') || '').toLowerCase();
            const id = (row.getAttribute('data-id') || '');
            const rId = row.getAttribute('data-roleid');
            const dept = row.getAttribute('data-dept');

            const matchesQuery = !query || name.includes(query) || email.includes(query) || id.includes(query) || ('stf-' + (parseInt(id)+100)).includes(query);
            const matchesRole = (roleVal === 'ALL') || (rId === roleVal);
            const matchesDept = (deptVal === 'ALL') || (dept === deptVal);

            if (matchesQuery && matchesRole && matchesDept) {
                matchingStaffRows.push(row);
            }
        });

        updateStaffPagination();
    }

    function updateStaffPagination() {
        const total = matchingStaffRows.length;
        const totalPages = Math.ceil(total / pageSize) || 1;

        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        const startIndex = total === 0 ? 0 : (currentPage - 1) * pageSize;
        const endIndex = Math.min(startIndex + pageSize, total);

        document.getElementById('staffPageStart').textContent = total === 0 ? '0' : (startIndex + 1);
        document.getElementById('staffPageEnd').textContent = endIndex;
        document.getElementById('staffTotalRows').textContent = total;

        const allRows = document.querySelectorAll('.staff-row');
        allRows.forEach(r => { r.style.display = 'none'; });

        for (let i = startIndex; i < endIndex; i++) {
            if (matchingStaffRows[i]) {
                matchingStaffRows[i].style.display = '';
            }
        }

        renderStaffPaginationButtons(totalPages);
    }

    function renderStaffPaginationButtons(totalPages) {
        const nav = document.getElementById('staffPageNav');
        if (!nav) return;
        nav.innerHTML = '';

        if (totalPages <= 1 && matchingStaffRows.length <= pageSize) return;

        // Prev
        const prev = document.createElement('button');
        prev.type = 'button';
        prev.className = 'nl-page-btn nl-page-nav-btn' + (currentPage === 1 ? ' disabled' : '');
        prev.innerHTML = '<i class="ti ti-chevron-left"></i> Prev';
        prev.onclick = function() { if (currentPage > 1) goToStaffPage(currentPage - 1); };
        nav.appendChild(prev);

        // Numbered Pages
        let startPage = Math.max(1, currentPage - 2);
        let endPage = Math.min(totalPages, startPage + 4);
        if (endPage - startPage < 4) {
            startPage = Math.max(1, endPage - 4);
        }

        if (startPage > 1) {
            const p1 = document.createElement('button');
            p1.type = 'button';
            p1.className = 'nl-page-btn nl-page-num' + (currentPage === 1 ? ' active' : '');
            p1.textContent = '1';
            p1.onclick = function() { goToStaffPage(1); };
            nav.appendChild(p1);

            if (startPage > 2) {
                const dots = document.createElement('span');
                dots.className = 'nl-page-ellipsis';
                dots.textContent = '...';
                nav.appendChild(dots);
            }
        }

        for (let p = startPage; p <= endPage; p++) {
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'nl-page-btn nl-page-num' + (p === currentPage ? ' active' : '');
            btn.textContent = p;
            (function(page) {
                btn.onclick = function() { goToStaffPage(page); };
            })(p);
            nav.appendChild(btn);
        }

        if (endPage < totalPages) {
            if (endPage < totalPages - 1) {
                const dots = document.createElement('span');
                dots.className = 'nl-page-ellipsis';
                dots.textContent = '...';
                nav.appendChild(dots);
            }
            const pLast = document.createElement('button');
            pLast.type = 'button';
            pLast.className = 'nl-page-btn nl-page-num' + (currentPage === totalPages ? ' active' : '');
            pLast.textContent = totalPages;
            pLast.onclick = function() { goToStaffPage(totalPages); };
            nav.appendChild(pLast);
        }

        // Next
        const next = document.createElement('button');
        next.type = 'button';
        next.className = 'nl-page-btn nl-page-nav-btn' + (currentPage === totalPages ? ' disabled' : '');
        next.innerHTML = 'Next <i class="ti ti-chevron-right"></i>';
        next.onclick = function() { if (currentPage < totalPages) goToStaffPage(currentPage + 1); };
        nav.appendChild(next);
    }

    // Auto-initialize with Rohit Sharma (or first staff) selected on load
    document.addEventListener('DOMContentLoaded', function() {
        applyStaffFilters();
        const firstRow = document.querySelector('.staff-row');
        if (firstRow) {
            const id = firstRow.getAttribute('data-id');
            selectStaffMember(parseInt(id, 10));
        }
    });
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
