<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Self-contained resilient controller logic: supports direct JSP access or servlet forwarding
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        String userIdStr = request.getParameter("userId");
        if (userIdStr != null && action != null) {
            try {
                int uid = Integer.parseInt(userIdStr);
                com.nlogistic.dao.UserDAO uDao = new com.nlogistic.dao.UserDAO();
                if ("accept".equals(action)) {
                    uDao.updateUserStatus(uid, "Active");
                    session.setAttribute("successMessage", "Customer Account Approved & Activated Successfully.");
                } else if ("reject".equals(action)) {
                    uDao.updateUserStatus(uid, "Suspended");
                    session.setAttribute("errorMessage", "Customer Account Suspended / Rejected.");
                } else if ("delete".equals(action)) {
                    try (java.sql.Connection conn = com.nlogistic.util.DBConnectionManager.getConnection()) {
                        conn.setAutoCommit(false);
                        try {
                            try (java.sql.PreparedStatement ps = conn.prepareStatement("DELETE FROM customers WHERE user_id = ?")) {
                                ps.setInt(1, uid);
                                ps.executeUpdate();
                            }
                            try (java.sql.PreparedStatement ps = conn.prepareStatement("DELETE FROM audit_log WHERE user_id = ?")) {
                                ps.setInt(1, uid);
                                ps.executeUpdate();
                            }
                            try (java.sql.PreparedStatement ps = conn.prepareStatement("DELETE FROM pricing_rules WHERE user_id = ?")) {
                                ps.setInt(1, uid);
                                ps.executeUpdate();
                            }
                            try (java.sql.PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE user_id = ?")) {
                                ps.setInt(1, uid);
                                ps.executeUpdate();
                            }
                            conn.commit();
                            session.setAttribute("successMessage", "Customer account #USR-" + uid + " permanently deleted from database.");
                        } catch(Exception ex) {
                            conn.rollback();
                            session.setAttribute("errorMessage", "Failed to delete customer: " + ex.getMessage());
                            ex.printStackTrace();
                        } finally {
                            conn.setAutoCommit(true);
                        }
                    }
                } else if ("update".equals(action)) {
                    String username = request.getParameter("username");
                    String email = request.getParameter("email");
                    String phone = request.getParameter("phone");
                    String address = request.getParameter("address");
                    String roleIdStr = request.getParameter("roleId");
                    int roleId = 5;
                    if (roleIdStr != null && !roleIdStr.trim().isEmpty()) {
                        try { roleId = Integer.parseInt(roleIdStr.trim()); } catch(Exception ignored) {}
                    }
                    try (java.sql.Connection conn = com.nlogistic.util.DBConnectionManager.getConnection()) {
                        conn.setAutoCommit(false);
                        try {
                            try (java.sql.PreparedStatement ps = conn.prepareStatement(
                                    "UPDATE users SET username = ?, email = ?, phone = ?, role_id = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?")) {
                                ps.setString(1, username != null ? username.trim() : "");
                                ps.setString(2, email != null ? email.trim() : "");
                                ps.setString(3, phone != null ? phone.trim() : "");
                                ps.setInt(4, roleId);
                                ps.setInt(5, uid);
                                ps.executeUpdate();
                            }
                            try (java.sql.PreparedStatement ps = conn.prepareStatement(
                                    "UPDATE customers SET customer_name = ?, address = ? WHERE user_id = ?")) {
                                ps.setString(1, username != null ? username.trim() : "");
                                ps.setString(2, address != null ? address.trim() : "");
                                ps.setInt(3, uid);
                                ps.executeUpdate();
                            }
                            conn.commit();
                            session.setAttribute("successMessage", "Customer #" + uid + " details updated successfully.");
                        } catch(Exception ex) {
                            conn.rollback();
                            session.setAttribute("errorMessage", "Failed to update customer: " + ex.getMessage());
                            ex.printStackTrace();
                        } finally {
                            conn.setAutoCommit(true);
                        }
                    }
                }
            } catch(Exception ex) { ex.printStackTrace(); }
            response.sendRedirect(request.getRequestURI());
            return;
        }
    }

    if (request.getAttribute("allUsers") == null) {
        com.nlogistic.dao.UserDAO uDao = new com.nlogistic.dao.UserDAO();
        com.nlogistic.dao.CompanyDAO cDao = new com.nlogistic.dao.CompanyDAO();

        java.util.List<com.nlogistic.model.User> allUsrs = uDao.getAllUsers();
        java.util.List<com.nlogistic.model.User> pendUsrs = uDao.getPendingUsers();
        java.util.List<com.nlogistic.model.Company> allComps = cDao.getAllCompanies();

        java.util.Map<Integer, String> companyNameMap = new java.util.HashMap<>();
        if (allComps != null) {
            for (com.nlogistic.model.Company cp : allComps) {
                companyNameMap.put(cp.getCompanyId(), cp.getCompanyName());
            }
        }

        int pendingCount = 0;
        int activeCount = 0;
        int inactiveCount = 0;
        int totalCount = (allUsrs != null) ? allUsrs.size() : 0;

        if (allUsrs != null) {
            for (com.nlogistic.model.User u : allUsrs) {
                if ("Active".equalsIgnoreCase(u.getStatus())) {
                    activeCount++;
                } else if ("Suspended".equalsIgnoreCase(u.getStatus()) || "Locked".equalsIgnoreCase(u.getStatus()) || "Rejected".equalsIgnoreCase(u.getStatus())) {
                    inactiveCount++;
                } else {
                    pendingCount++;
                }
            }
        }

        request.setAttribute("allUsers", allUsrs);
        request.setAttribute("pendingUsers", pendUsrs);
        request.setAttribute("companyNameMap", companyNameMap);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("activeCount", activeCount);
        request.setAttribute("inactiveCount", inactiveCount);
        request.setAttribute("totalCount", totalCount);
    }
%>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* ==========================================================================
       CUSTOMER APPROVALS & CLIENT GOVERNANCE THEME (SWIGGY ORANGE ENTERPRISE)
       ========================================================================== */
    .approvals-page-container {
        padding: 0 4px 40px;
    }

    /* Top Breadcrumb */
    .custom-breadcrumb {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 13px;
        color: #64748B;
        margin-bottom: 16px;
    }
    .custom-breadcrumb a {
        color: #64748B;
        text-decoration: none;
        transition: color 0.15s ease;
    }
    .custom-breadcrumb a:hover {
        color: #FC8019;
    }
    .custom-breadcrumb i {
        font-size: 11px;
        color: #94A3B8;
    }
    .custom-breadcrumb .current {
        color: #FC8019;
        font-weight: 600;
    }

    /* Telemetry Header Panel */
    .telemetry-header-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 16px;
        padding: 24px 28px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
        margin-bottom: 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 20px;
    }
    .telemetry-header-left {
        display: flex;
        align-items: center;
        gap: 16px;
    }
    .telemetry-icon-box {
        width: 52px;
        height: 52px;
        border-radius: 14px;
        background: #FFF0E5;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #FC8019;
        font-size: 26px;
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.15);
        flex-shrink: 0;
    }
    .telemetry-title {
        font-size: 20px;
        font-weight: 700;
        color: #0F172A;
        margin: 0 0 4px 0;
        letter-spacing: -0.3px;
    }
    .telemetry-subtitle {
        font-size: 13.5px;
        color: #64748B;
        margin: 0;
    }

    /* 4-Column KPI Stats Cards */
    .kpi-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 18px;
        margin-bottom: 24px;
    }
    @media (max-width: 1024px) { .kpi-grid { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 640px) { .kpi-grid { grid-template-columns: 1fr; } }

    .kpi-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 14px;
        padding: 18px 20px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.03);
        display: flex;
        align-items: center;
        justify-content: space-between;
        transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
        cursor: pointer;
    }
    .kpi-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(0, 0, 0, 0.06);
        border-color: #CBD5E1;
    }
    .kpi-label {
        font-size: 12.5px;
        font-weight: 600;
        color: #64748B;
        margin-bottom: 6px;
        text-transform: uppercase;
        letter-spacing: 0.4px;
    }
    .kpi-value {
        font-size: 26px;
        font-weight: 800;
        color: #0F172A;
        line-height: 1;
    }
    .kpi-icon-pill {
        width: 44px;
        height: 44px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 22px;
        flex-shrink: 0;
    }
    .kpi-icon-pill.amber  { background: #FFFBEB; color: #D97706; }
    .kpi-icon-pill.green  { background: #ECFDF5; color: #059669; }
    .kpi-icon-pill.red    { background: #FEF2F2; color: #DC2626; }
    .kpi-icon-pill.blue   { background: #EFF6FF; color: #2563EB; }

    /* Filter Tabs & Search Toolbar */
    .approvals-toolbar {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 14px 14px 0 0;
        padding: 16px 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 16px;
        border-bottom: 1px solid #F1F5F9;
    }
    .nav-tabs-pill {
        display: flex;
        align-items: center;
        gap: 8px;
        background: #F8FAFC;
        padding: 4px;
        border-radius: 50px;
        border: 1px solid #E2E8F0;
    }
    .tab-pill-btn {
        background: transparent;
        border: none;
        padding: 7px 18px;
        border-radius: 50px;
        font-size: 13px;
        font-weight: 600;
        color: #64748B;
        cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .tab-pill-btn:hover { color: #0F172A; }
    .tab-pill-btn.active {
        background: #FFFFFF;
        color: #FC8019;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
    }
    .tab-counter {
        font-size: 11px;
        font-weight: 700;
        padding: 2px 7px;
        border-radius: 50px;
        background: #F1F5F9;
        color: #475569;
    }
    .tab-pill-btn.active .tab-counter {
        background: #FFF0E5;
        color: #FC8019;
    }

    /* Live Search Input Box */
    .table-search-wrap { position: relative; width: 300px; }
    .table-search-wrap i { position: absolute; left: 16px; top: 50%; transform: translateY(-50%); color: #94A3B8; font-size: 15px; }
    .table-search-input {
        width: 100%; height: 40px; padding-left: 42px !important; padding-right: 18px !important;
        border-radius: 50px !important; font-size: 13px !important; border: 1.5px solid #E2E8F0 !important;
        background: #F8FAFC !important;
    }
    .table-search-input:focus {
        background: #FFFFFF !important; border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.16) !important;
    }

    /* Main Table Container */
    .approvals-table-panel {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-top: none;
        border-radius: 0 0 16px 16px; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04); overflow: hidden;
    }
    .approvals-table { width: 100%; border-collapse: collapse; margin: 0; }
    .approvals-table th {
        background: #F8FAFC; padding: 14px 20px; font-size: 11.5px; font-weight: 700;
        color: #64748B; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid #E2E8F0; text-align: left;
    }
    .approvals-table th i { margin-right: 4px; color: #94A3B8; font-size: 13px; }
    .approvals-table td {
        padding: 16px 20px; border-bottom: 1px solid #F1F5F9; vertical-align: middle;
        font-size: 13.5px; color: #1E293B; transition: background-color 0.12s ease;
    }
    .customer-row:hover td { background-color: #FAFAFA; }

    /* Customer Name & Avatar Cell */
    .customer-cell { display: flex; align-items: center; gap: 14px; }
    .customer-avatar {
        width: 42px; height: 42px; border-radius: 50% !important; background: #FC8019;
        color: #FFFFFF; font-weight: 700; font-size: 15px; display: flex; align-items: center; justify-content: center;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25); flex-shrink: 0; letter-spacing: 0.5px;
    }
    .customer-info-wrap { min-width: 0; }
    .customer-name-title { font-weight: 700; color: #0F172A; font-size: 14px; margin-bottom: 2px; }
    .customer-meta-badge { font-size: 11px; color: #64748B; display: inline-flex; align-items: center; gap: 4px; }

    /* Role and Tenant Badges */
    .role-tenant-wrap { display: flex; flex-direction: column; gap: 4px; }
    .role-badge {
        font-size: 11.5px; font-weight: 600; padding: 3px 10px; border-radius: 50px;
        background: #F1F5F9; color: #334155; border: 1px solid #E2E8F0; display: inline-flex;
        align-items: center; gap: 5px; width: fit-content;
    }
    .company-name-chip {
        font-size: 12px; color: #64748B; display: inline-flex; align-items: center; gap: 5px;
    }

    /* Contact Details Chips */
    .contact-cell { display: flex; flex-direction: column; gap: 4px; }
    .contact-link { display: inline-flex; align-items: center; gap: 6px; color: #475569; font-size: 12.5px; text-decoration: none; transition: color 0.15s ease; }
    .contact-link:hover { color: #FC8019; }
    .contact-link i { font-size: 13px; color: #94A3B8; }

    /* Status Badges */
    .status-pill { display: inline-flex; align-items: center; gap: 6px; padding: 5px 12px; border-radius: 50px; font-size: 12px; font-weight: 600; }
    .status-pill.pending { background: #FFFBEB; color: #D97706; border: 1px solid #FDE68A; }
    .status-pill.active { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }
    .status-pill.suspended { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }

    /* Action Buttons (Pill-Shaped Flat, NO Gradient) */
    .actions-flex { display: flex; align-items: center; justify-content: flex-end; gap: 8px; }
    .btn-approval-accept {
        background: #10B981 !important; border: 1px solid #10B981 !important; color: #FFFFFF !important;
        padding: 7px 18px; border-radius: 50px; font-size: 12.5px; font-weight: 700; display: inline-flex; align-items: center; gap: 6px;
        cursor: pointer; transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); box-shadow: 0 2px 6px rgba(16, 185, 129, 0.22);
    }
    .btn-approval-accept:hover {
        background: #059669 !important; border-color: #059669 !important; transform: translateY(-1px); box-shadow: 0 5px 14px rgba(16, 185, 129, 0.35);
    }
    .btn-approval-accept:active { transform: translateY(0); }
    .btn-approval-accept i { font-size: 13px; transition: transform 0.2s ease; }
    .btn-approval-accept:hover i { transform: scale(1.15); }

    .btn-approval-reject {
        background: #FFFFFF; border: 1.5px solid #FCA5A5; color: #DC2626 !important; padding: 7px 18px; border-radius: 50px;
        font-size: 12.5px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); box-shadow: 0 1px 2px rgba(220, 38, 38, 0.05);
    }
    .btn-approval-reject:hover {
        background: #FEF2F2; border-color: #EF4444; color: #B91C1C !important; transform: translateY(-1px); box-shadow: 0 4px 10px rgba(239, 68, 68, 0.18);
    }
    .btn-approval-reject:active { transform: translateY(0); }
    .btn-approval-reject i { font-size: 13px; transition: transform 0.2s ease; }
    .btn-approval-reject:hover i { transform: scale(1.15); }

    /* Empty State */
    .empty-caught-up-card { padding: 60px 24px; text-align: center; background: #FFFFFF; }
    .empty-shield-icon-box {
        width: 68px; height: 68px; border-radius: 20px; background: #ECFDF5; border: 1px solid #A7F3D0;
        color: #059669; font-size: 32px; display: flex; align-items: center; justify-content: center; margin: 0 auto 18px;
        box-shadow: 0 8px 24px rgba(16, 185, 129, 0.15);
    }
    .empty-caught-up-title { font-size: 17px; font-weight: 700; color: #0F172A; margin-bottom: 6px; }
    .empty-caught-up-desc { font-size: 13.5px; color: #64748B; max-width: 440px; margin: 0 auto 20px; line-height: 1.5; }
    .btn-view-all-tenants {
        background: #FFFFFF; border: 1.5px solid #E2E8F0; color: #475569; padding: 9px 24px; border-radius: 50px;
        font-size: 13px; font-weight: 600; display: inline-flex; align-items: center; gap: 8px; cursor: pointer; text-decoration: none; transition: all 0.2s ease;
    }
    .btn-view-all-tenants:hover { background: #F8FAFC; border-color: #CBD5E1; color: #0F172A; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(15, 23, 42, 0.08); }

    /* Alerts */
    .custom-alert { border-radius: 12px; padding: 14px 18px; font-size: 13.5px; font-weight: 500; display: flex; align-items: center; gap: 10px; margin-bottom: 20px; }
    .custom-alert.success { background: #ECFDF5; border: 1px solid #A7F3D0; color: #065F46; }
    .custom-alert.danger { background: #FEF2F2; border: 1px solid #FECACA; color: #991B1B; }

    /* Custom Modern Confirmation Modal */
    .nl-modal-backdrop {
        position: fixed; inset: 0; background: rgba(15, 23, 42, 0.45);
        backdrop-filter: blur(5px); -webkit-backdrop-filter: blur(5px);
        display: flex; align-items: center; justify-content: center;
        z-index: 9999999; padding: 20px; opacity: 0;
        transition: opacity 0.2s cubic-bezier(0.16, 1, 0.3, 1); pointer-events: none;
    }
    .nl-modal-backdrop.show { opacity: 1; pointer-events: auto; }
    .nl-modal-dialog {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 24px;
        box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.25); max-width: 440px; width: 100%;
        padding: 32px 28px 24px; text-align: center; position: relative;
        transform: scale(0.92) translateY(12px); transition: transform 0.25s cubic-bezier(0.16, 1, 0.3, 1);
    }
    .nl-modal-backdrop.show .nl-modal-dialog { transform: scale(1) translateY(0); }
    .nl-modal-close {
        position: absolute; top: 18px; right: 18px; background: #F1F5F9; border: none;
        width: 32px; height: 32px; border-radius: 50px; display: flex; align-items: center;
        justify-content: center; color: #64748B; cursor: pointer; font-size: 16px; transition: all 0.15s ease;
    }
    .nl-modal-close:hover { background: #E2E8F0; color: #0F172A; }
    .nl-modal-icon-box {
        width: 60px; height: 60px; border-radius: 18px; margin: 0 auto 18px;
        display: flex; align-items: center; justify-content: center; font-size: 28px;
    }
    .nl-modal-icon-box.danger { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }
    .nl-modal-icon-box.success { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }
    .nl-modal-title { font-size: 19px; font-weight: 700; color: #0F172A; margin-bottom: 8px; letter-spacing: -0.3px; }
    .nl-modal-desc { font-size: 13.5px; color: #64748B; line-height: 1.5; margin: 0 0 24px 0; }
    .nl-modal-actions { display: flex; align-items: center; justify-content: center; gap: 12px; }
    .nl-modal-btn {
        padding: 9px 24px; border-radius: 50px; font-size: 13px; font-weight: 600;
        cursor: pointer; transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); border: none;
        display: inline-flex; align-items: center; gap: 6px;
    }
    .nl-modal-btn.cancel { background: #F1F5F9; color: #475569; border: 1px solid #E2E8F0; }
    .nl-modal-btn.cancel:hover { background: #E2E8F0; color: #0F172A; }
    .nl-modal-btn.confirm.danger { background: #DC2626 !important; color: #FFFFFF !important; box-shadow: 0 4px 12px rgba(220, 38, 38, 0.28); }
    .nl-modal-btn.confirm.danger:hover { background: #B91C1C !important; transform: translateY(-1px); }
    .nl-modal-btn.confirm.success { background: #10B981 !important; color: #FFFFFF !important; box-shadow: 0 4px 12px rgba(16, 185, 129, 0.28); }
    .nl-modal-btn.confirm.success:hover { background: #059669 !important; transform: translateY(-1px); }

    /* Action Buttons: Edit & Delete */
    .btn-approval-edit {
        background: #FFFFFF; border: 1.5px solid #BFDBFE; color: #2563EB !important; padding: 6px 14px; border-radius: 50px;
        font-size: 11.5px; font-weight: 600; display: inline-flex; align-items: center; gap: 5px; cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); box-shadow: 0 1px 2px rgba(37, 99, 235, 0.05);
    }
    .btn-approval-edit:hover {
        background: #EFF6FF; border-color: #3B82F6; color: #1D4ED8 !important; transform: translateY(-1px); box-shadow: 0 4px 10px rgba(37, 99, 235, 0.15);
    }
    .btn-approval-edit:active { transform: translateY(0); }
    .btn-approval-edit i { font-size: 12.5px; transition: transform 0.2s ease; }
    .btn-approval-edit:hover i { transform: scale(1.15); }

    .btn-approval-delete {
        background: #FFFFFF; border: 1.5px solid #FECACA; color: #DC2626 !important; padding: 6px 14px; border-radius: 50px;
        font-size: 11.5px; font-weight: 600; display: inline-flex; align-items: center; gap: 5px; cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); box-shadow: 0 1px 2px rgba(220, 38, 38, 0.05);
    }
    .btn-approval-delete:hover {
        background: #FEF2F2; border-color: #EF4444; color: #B91C1C !important; transform: translateY(-1px); box-shadow: 0 4px 10px rgba(239, 68, 68, 0.18);
    }
    .btn-approval-delete:active { transform: translateY(0); }
    .btn-approval-delete i { font-size: 12.5px; transition: transform 0.2s ease; }
    .btn-approval-delete:hover i { transform: scale(1.15); }

    /* Custom Form Controls & Select Styling */
    .edit-modal-dialog {
        max-width: 520px !important;
        text-align: left !important;
        padding: 28px 30px 24px !important;
    }
    .modal-form-group {
        margin-bottom: 16px;
        text-align: left;
    }
    .modal-form-label {
        display: block;
        font-size: 12.5px;
        font-weight: 600;
        color: #475569;
        margin-bottom: 6px;
    }
    .modal-form-input {
        width: 100%;
        height: 42px;
        padding: 0 16px;
        border: 1.5px solid #E2E8F0;
        border-radius: 50px;
        font-size: 13px;
        color: #1E293B;
        background-color: #FFFFFF;
        outline: none;
        transition: all 0.2s ease;
    }
    .modal-form-input:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }

    .select-wrapper {
        position: relative;
        width: 100%;
    }
    .select-wrapper::after {
        content: '';
        position: absolute;
        right: 16px;
        top: 50%;
        transform: translateY(-50%);
        width: 14px;
        height: 14px;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2364748B' stroke-width='2.2'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E");
        background-size: contain;
        background-repeat: no-repeat;
        pointer-events: none;
    }
    .form-select-custom, .select-wrapper select {
        appearance: none;
        -webkit-appearance: none;
        width: 100%;
        height: 42px;
        padding: 0 38px 0 16px;
        border: 1.5px solid #E2E8F0;
        border-radius: 50px;
        font-size: 13px;
        color: #1E293B;
        background-color: #FFFFFF;
        outline: none;
        transition: all 0.2s ease;
    }
    .form-select-custom:focus, .select-wrapper select:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }

</style>

<div class="approvals-page-container">

    <!-- Breadcrumb -->
    <div class="custom-breadcrumb">
        <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <i class="ti ti-chevron-right"></i>
        <span>Management</span>
        <i class="ti ti-chevron-right"></i>
        <span class="current">Customer Approvals</span>
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

    <!-- Top Telemetry Header -->
    <div class="telemetry-header-card">
        <div class="telemetry-header-left">
            <div class="telemetry-icon-box">
                <i class="ti ti-user-check"></i>
            </div>
            <div>
                <h4 class="telemetry-title">Customer Approvals &amp; Client Governance</h4>
                <p class="telemetry-subtitle">Super Admin regulatory verification portal for B2B portal customers, shipper accounts, and access clearance</p>
            </div>
        </div>
        <div>
            <span class="badge" style="background: #FFF0E5; color: #FC8019; font-weight: 700; font-size: 12px; padding: 7px 16px; border-radius: 50px; border: 1px solid #FED7AA;">
                <i class="ti ti-lock-access me-1"></i> Super Admin Clearance Required
            </span>
        </div>
    </div>

    <!-- 4 KPI Summary Cards -->
    <div class="kpi-grid">
        <div class="kpi-card" onclick="filterByTab('Pending')" style="cursor: pointer;" title="Click to view Pending Customer Approvals">
            <div>
                <div class="kpi-label">Pending Approval</div>
                <div class="kpi-value" style="color: #D97706;">${not empty pendingCount ? pendingCount : 0}</div>
            </div>
            <div class="kpi-icon-pill amber">
                <i class="ti ti-clock-hour-4"></i>
            </div>
        </div>
        <div class="kpi-card" onclick="filterByTab('Active')" style="cursor: pointer;" title="Click to view Active Customers">
            <div>
                <div class="kpi-label">Active Customers</div>
                <div class="kpi-value" style="color: #059669;">${not empty activeCount ? activeCount : 0}</div>
            </div>
            <div class="kpi-icon-pill green">
                <i class="ti ti-circle-check"></i>
            </div>
        </div>
        <div class="kpi-card" onclick="filterByTab('Suspended')" style="cursor: pointer;" title="Click to view Suspended &amp; Inactive Customers">
            <div>
                <div class="kpi-label">Suspended / Inactive</div>
                <div class="kpi-value" style="color: #DC2626;">${not empty inactiveCount ? inactiveCount : 0}</div>
            </div>
            <div class="kpi-icon-pill red">
                <i class="ti ti-ban"></i>
            </div>
        </div>
        <div class="kpi-card" onclick="filterByTab('All')" style="cursor: pointer;" title="Click to view All Accounts">
            <div>
                <div class="kpi-label">Total Registered Accounts</div>
                <div class="kpi-value" style="color: #2563EB;">${not empty totalCount ? totalCount : 0}</div>
            </div>
            <div class="kpi-icon-pill blue">
                <i class="ti ti-users"></i>
            </div>
        </div>
    </div>

    <!-- Toolbar: Filter Tabs & Real-Time Search -->
    <div class="approvals-toolbar">
        <div class="nav-tabs-pill">
            <button type="button" class="tab-pill-btn active" id="tabPendingBtn" onclick="filterByTab('Pending')">
                <i class="ti ti-clock"></i> Pending Review
                <span class="tab-counter">${not empty pendingCount ? pendingCount : 0}</span>
            </button>
            <button type="button" class="tab-pill-btn" id="tabActiveBtn" onclick="filterByTab('Active')">
                <i class="ti ti-circle-check"></i> Active Customers
                <span class="tab-counter">${not empty activeCount ? activeCount : 0}</span>
            </button>
            <button type="button" class="tab-pill-btn" id="tabSuspendedBtn" onclick="filterByTab('Suspended')">
                <i class="ti ti-ban"></i> Suspended &amp; Inactive
                <span class="tab-counter" style="color: #DC2626; background: #FEF2F2;">${not empty inactiveCount ? inactiveCount : 0}</span>
            </button>
            <button type="button" class="tab-pill-btn" id="tabAllBtn" onclick="filterByTab('All')">
                <i class="ti ti-list"></i> All Accounts
                <span class="tab-counter">${not empty totalCount ? totalCount : 0}</span>
            </button>
        </div>

        <div class="table-search-wrap">
            <i class="ti ti-search"></i>
            <input type="text" id="customerSearchInput" class="table-search-input form-control" placeholder="Search customer, email, phone, company..." oninput="handleCustomerSearch()">
        </div>
    </div>

    <!-- Table Container -->
    <div class="approvals-table-panel">
        <div class="table-responsive">
            <table class="approvals-table" id="customersTable">
                <thead>
                    <tr>
                        <th style="padding-left: 24px;"><i class="ti ti-user"></i> Customer / User</th>
                        <th><i class="ti ti-briefcase"></i> Role &amp; Tenant</th>
                        <th><i class="ti ti-address-book"></i> Contact Info</th>
                        <th><i class="ti ti-calendar"></i> Registered Date</th>
                        <th><i class="ti ti-activity"></i> Status</th>
                        <th style="padding-right: 24px; text-align: right;"><i class="ti ti-settings"></i> Action</th>
                    </tr>
                </thead>
                <tbody id="customersTableBody">
                    <c:forEach var="u" items="${allUsers}">
                        <tr class="customer-row"
                            data-status="${u.status}"
                            data-search="${u.username.toLowerCase()} ${u.email.toLowerCase()} ${u.phone} ${not empty companyNameMap[u.companyId] ? companyNameMap[u.companyId].toLowerCase() : ''}">
                            
                            <!-- Customer Name + Avatar -->
                            <td style="padding-left: 24px;">
                                <div class="customer-cell">
                                    <div class="customer-avatar">
                                        <c:set var="uInitials" value="${u.username.substring(0, u.username.length() >= 2 ? 2 : 1).toUpperCase()}" />
                                        ${uInitials}
                                    </div>
                                    <div class="customer-info-wrap">
                                        <div class="customer-name-title">${u.username}</div>
                                        <div class="customer-meta-badge">
                                            <i class="ti ti-hash"></i> USR-${u.userId}
                                        </div>
                                    </div>
                                </div>
                            </td>

                            <!-- Role & Tenant -->
                            <td>
                                <div class="role-tenant-wrap">
                                    <span class="role-badge">
                                        <c:choose>
                                            <c:when test="${u.roleId == 1}">
                                                <i class="ti ti-shield"></i> Super Admin
                                            </c:when>
                                            <c:when test="${u.roleId == 2}">
                                                <i class="ti ti-building"></i> Company Admin
                                            </c:when>
                                            <c:when test="${u.roleId == 5}">
                                                <i class="ti ti-user-check"></i> Customer / Client
                                            </c:when>
                                            <c:otherwise>
                                                <i class="ti ti-user"></i> Staff (Role ${u.roleId})
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                    <c:if test="${not empty u.companyId && u.companyId > 0}">
                                        <span class="company-name-chip">
                                            <i class="ti ti-building" style="color: #94A3B8; font-size: 13px;"></i>
                                            <span>${not empty companyNameMap[u.companyId] ? companyNameMap[u.companyId] : 'Tenant CMP-'.concat(u.companyId)}</span>
                                        </span>
                                    </c:if>
                                </div>
                            </td>

                            <!-- Contact Details -->
                            <td>
                                <div class="contact-cell">
                                    <a href="mailto:${u.email}" class="contact-link" title="Send Email">
                                        <i class="ti ti-mail"></i>
                                        <span>${u.email}</span>
                                    </a>
                                    <a href="tel:${u.phone}" class="contact-link" title="Call Phone">
                                        <i class="ti ti-phone"></i>
                                        <span>${not empty u.phone ? u.phone : 'N/A'}</span>
                                    </a>
                                </div>
                            </td>

                            <!-- Registered Date -->
                            <td style="color: #475569; font-size: 13px;">
                                <div style="display: flex; align-items: center; gap: 6px;">
                                    <i class="ti ti-calendar" style="color: #94A3B8; font-size: 14px;"></i>
                                    <span>
                                        <c:choose>
                                            <c:when test="${not empty u.createdAt}">
                                                <fmt:formatDate value="${u.createdAt}" pattern="MMM dd, yyyy" />
                                            </c:when>
                                            <c:otherwise>Active Member</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </td>

                            <!-- Status Badge -->
                            <td>
                                <c:choose>
                                    <c:when test="${u.status == 'Active'}">
                                        <span class="status-pill active">
                                            <i class="ti ti-circle-check"></i> Approved
                                        </span>
                                    </c:when>
                                    <c:when test="${u.status == 'Suspended' || u.status == 'Locked' || u.status == 'Rejected'}">
                                        <span class="status-pill suspended">
                                            <i class="ti ti-ban"></i> Suspended
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-pill pending">
                                            <i class="ti ti-clock"></i> Pending Review
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <!-- Actions -->
                            <td style="padding-right: 24px; text-align: right;">
                                <div class="actions-flex">
                                    <c:choose>
                                        <c:when test="${u.status == 'Active'}">
                                            <form method="POST" class="d-inline m-0">
                                                <input type="hidden" name="userId" value="${u.userId}">
                                                <input type="hidden" name="action" value="reject">
                                                <button type="button" class="btn-approval-reject" title="Suspend customer account" onclick="showCustomConfirm({title: 'Suspend Customer Account?', desc: 'Are you sure you want to suspend this customer account? Their portal access will be temporarily restricted.', icon: 'ti ti-ban', type: 'danger', confirmText: 'Yes, Suspend Account', form: this.form});" style="padding: 6px 14px; font-size: 11.5px;">
                                                    <i class="ti ti-ban"></i> Suspend
                                                </button>
                                            </form>
                                        </c:when>
                                        <c:when test="${u.status == 'Suspended' || u.status == 'Locked' || u.status == 'Rejected'}">
                                            <form method="POST" class="d-inline m-0">
                                                <input type="hidden" name="userId" value="${u.userId}">
                                                <input type="hidden" name="action" value="accept">
                                                <button type="button" class="btn-approval-accept" title="Reactivate customer account" onclick="showCustomConfirm({title: 'Reactivate Customer Account?', desc: 'Are you sure you want to restore and activate this customer account?', icon: 'ti ti-reload', type: 'success', confirmText: 'Yes, Reactivate', form: this.form});" style="padding: 6px 14px; font-size: 11.5px;">
                                                    <i class="ti ti-reload"></i> Reactivate
                                                </button>
                                            </form>
                                        </c:when>
                                        <c:otherwise>
                                            <form method="POST" class="d-inline m-0">
                                                <input type="hidden" name="userId" value="${u.userId}">
                                                <input type="hidden" name="action" value="accept">
                                                <button type="submit" class="btn-approval-accept" title="Approve Customer Account" style="padding: 6px 14px; font-size: 11.5px;">
                                                    <i class="ti ti-check"></i> Approve
                                                </button>
                                            </form>
                                            <form method="POST" class="d-inline m-0">
                                                <input type="hidden" name="userId" value="${u.userId}">
                                                <input type="hidden" name="action" value="reject">
                                                <button type="button" class="btn-approval-reject" title="Reject Customer Account" onclick="showCustomConfirm({title: 'Reject Customer Account?', desc: 'Are you sure you want to reject this customer registration request?', icon: 'ti ti-x', type: 'danger', confirmText: 'Yes, Reject', form: this.form});" style="padding: 6px 14px; font-size: 11.5px;">
                                                    <i class="ti ti-x"></i> Reject
                                                </button>
                                            </form>
                                        </c:otherwise>
                                    </c:choose>

                                    <!-- Edit Customer Details -->
                                    <button type="button" class="btn-approval-edit" title="Edit Customer Details" onclick="openEditCustomerModal({userId: '${u.userId}', username: '${u.username}', email: '${u.email}', phone: '${u.phone}', roleId: '${u.roleId}'})">
                                        <i class="ti ti-edit"></i> Edit
                                    </button>

                                    <!-- Delete Customer -->
                                    <form method="POST" class="d-inline m-0" id="deleteCustomerForm_${u.userId}">
                                        <input type="hidden" name="userId" value="${u.userId}">
                                        <input type="hidden" name="action" value="delete">
                                        <button type="button" class="btn-approval-delete" title="Permanently Delete Customer" onclick="showCustomConfirm({title: 'Delete Customer Account?', desc: 'Are you sure you want to permanently delete customer \'${u.username}\' (#USR-${u.userId}) from the database? This action cannot be undone.', icon: 'ti ti-trash', type: 'danger', confirmText: 'Yes, Delete Permanently', form: this.form});">
                                            <i class="ti ti-trash"></i> Delete
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        
        <!-- Enterprise Theme Pagination Bar -->
        <div class="nl-pagination-wrapper" id="usersPagination">
            <div class="nl-pagination-info">
                <span>Showing <strong id="usersPageStart">1</strong> to <strong id="usersPageEnd">10</strong> of <strong id="usersTotalRows">0</strong> records</span>
                <div class="d-inline-flex align-items-center gap-2 ms-2">
                    <span style="color: #94A3B8; font-size: 12.5px;">Rows per page:</span>
                    <select id="usersPageSize" class="nl-page-size-select no-custom-select" onchange="changeUsersPageSize(this.value)">
                        <option value="10" selected>10</option>
                        <option value="25">25</option>
                        <option value="50">50</option>
                    </select>
                </div>
            </div>
            <div class="nl-pagination-nav" id="usersPageNav">
                <!-- Dynamically generated page buttons -->
            </div>
        </div>

        <!-- Modern Empty State -->
        <div id="emptyStateBox" class="empty-caught-up-card" style="display: none;">
            <div class="empty-shield-icon-box">
                <i class="ti ti-user-check"></i>
            </div>
            <div class="empty-caught-up-title" id="emptyStateTitle">All Caught Up!</div>
            <p class="empty-caught-up-desc" id="emptyStateDesc">
                There are currently no pending customer registration requests requiring Super Admin verification. All client onboarding is up to date.
            </p>
            <button type="button" class="btn-view-all-tenants" onclick="filterByTab('All')">
                <i class="ti ti-list"></i> View All Registered Customers
            </button>
        </div>
    </div>

    <!-- Custom Action Confirmation Modal -->
    <div id="nlCustomConfirmModal" class="nl-modal-backdrop" style="display: none;">
        <div class="nl-modal-dialog">
            <button type="button" class="nl-modal-close" onclick="closeCustomConfirmModal()" aria-label="Close">
                <i class="ti ti-x"></i>
            </button>
            <div class="nl-modal-icon-box danger" id="nlConfirmIconBox">
                <i class="ti ti-alert-triangle" id="nlConfirmIcon"></i>
            </div>
            <h5 class="nl-modal-title" id="nlConfirmTitle">Confirm Action</h5>
            <p class="nl-modal-desc" id="nlConfirmDesc">Are you sure you want to proceed with this action?</p>
            <div class="nl-modal-actions">
                <button type="button" class="nl-modal-btn cancel" onclick="closeCustomConfirmModal()">Cancel</button>
                <button type="button" class="nl-modal-btn confirm danger" id="nlConfirmSubmitBtn">Confirm</button>
            </div>
        </div>
    </div>

    <!-- Custom Edit Customer Modal -->
    <div id="editCustomerModal" class="nl-modal-backdrop" style="display: none;">
        <div class="nl-modal-dialog edit-modal-dialog">
            <button type="button" class="nl-modal-close" onclick="closeEditCustomerModal()" aria-label="Close">
                <i class="ti ti-x"></i>
            </button>
            <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 20px;">
                <div style="width: 44px; height: 44px; border-radius: 12px; background: #EFF6FF; color: #2563EB; display: flex; align-items: center; justify-content: center; font-size: 22px; flex-shrink: 0;">
                    <i class="ti ti-user-edit"></i>
                </div>
                <div>
                    <h5 class="nl-modal-title" style="margin: 0; font-size: 17px; text-align: left;">Edit Customer Details</h5>
                    <p style="margin: 2px 0 0 0; font-size: 12.5px; color: #64748B; text-align: left;">Update profile, contact and address details</p>
                </div>
            </div>

            <form method="POST" id="editCustomerForm">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="userId" id="editUserId">

                <div class="modal-form-group">
                    <label class="modal-form-label" for="editUsername">Customer Name / Username <span style="color: #DC2626;">*</span></label>
                    <input type="text" id="editUsername" name="username" class="modal-form-input" required>
                </div>

                <div class="modal-form-group">
                    <label class="modal-form-label" for="editEmail">Email Address <span style="color: #DC2626;">*</span></label>
                    <input type="email" id="editEmail" name="email" class="modal-form-input" required>
                </div>

                <div class="modal-form-group">
                    <label class="modal-form-label" for="editPhone">Contact Phone</label>
                    <input type="tel" id="editPhone" name="phone" class="modal-form-input" placeholder="+91 98765 43210">
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                    <div class="modal-form-group">
                        <label class="modal-form-label" for="editRoleId">Assigned Role</label>
                        <div class="select-wrapper">
                            <select id="editRoleId" name="roleId" class="form-select-custom">
                                <option value="5">Customer / Client</option>
                                <option value="3">Operations Staff</option>
                                <option value="4">Finance Staff</option>
                                <option value="2">Company Admin</option>
                                <option value="1">Super Admin</option>
                            </select>
                        </div>
                    </div>

                    <div class="modal-form-group">
                        <label class="modal-form-label" for="editAddress">Registered Address</label>
                        <input type="text" id="editAddress" name="address" class="modal-form-input" placeholder="City, State, Country">
                    </div>
                </div>

                <div class="nl-modal-actions" style="margin-top: 22px; justify-content: flex-end;">
                    <button type="button" class="nl-modal-btn cancel" onclick="closeEditCustomerModal()">Cancel</button>
                    <button type="submit" class="nl-modal-btn confirm" style="background: #FC8019 !important; color: #FFFFFF !important; box-shadow: 0 4px 12px rgba(252, 128, 25, 0.28);">
                        <i class="ti ti-device-floppy"></i> Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>

</div>

<script>

    let pendingFormToSubmit = null;

    function openEditCustomerModal(data) {
        document.getElementById('editUserId').value = data.userId || '';
        document.getElementById('editUsername').value = data.username || '';
        document.getElementById('editEmail').value = data.email || '';
        document.getElementById('editPhone').value = data.phone || '';
        document.getElementById('editAddress').value = data.address || '';
        if (document.getElementById('editRoleId')) {
            document.getElementById('editRoleId').value = data.roleId || '5';
        }

        const modal = document.getElementById('editCustomerModal');
        modal.style.display = 'flex';
        requestAnimationFrame(() => {
            modal.classList.add('show');
        });
    }

    function closeEditCustomerModal() {
        const modal = document.getElementById('editCustomerModal');
        modal.classList.remove('show');
        setTimeout(() => {
            modal.style.display = 'none';
        }, 200);
    }

    function showCustomConfirm(options) {
        pendingFormToSubmit = options.form;
        document.getElementById('nlConfirmTitle').textContent = options.title || 'Confirm Action';
        document.getElementById('nlConfirmDesc').textContent = options.desc || 'Are you sure you want to proceed?';
        
        const iconBox = document.getElementById('nlConfirmIconBox');
        iconBox.className = 'nl-modal-icon-box ' + (options.type || 'danger');
        
        const icon = document.getElementById('nlConfirmIcon');
        icon.className = options.icon || (options.type === 'success' ? 'ti ti-check' : 'ti ti-alert-triangle');
        
        const confirmBtn = document.getElementById('nlConfirmSubmitBtn');
        confirmBtn.className = 'nl-modal-btn confirm ' + (options.type || 'danger');
        confirmBtn.textContent = options.confirmText || 'Confirm';
        
        const modal = document.getElementById('nlCustomConfirmModal');
        modal.style.display = 'flex';
        requestAnimationFrame(() => {
            modal.classList.add('show');
        });
    }

    function closeCustomConfirmModal() {
        const modal = document.getElementById('nlCustomConfirmModal');
        modal.classList.remove('show');
        setTimeout(() => {
            modal.style.display = 'none';
            pendingFormToSubmit = null;
        }, 200);
    }

    document.addEventListener('DOMContentLoaded', function() {
        const submitBtn = document.getElementById('nlConfirmSubmitBtn');
        if (submitBtn) {
            submitBtn.addEventListener('click', function() {
                if (pendingFormToSubmit) {
                    const form = pendingFormToSubmit;
                    closeCustomConfirmModal();
                    form.submit();
                }
            });
        }

        const confirmModal = document.getElementById('nlCustomConfirmModal');
        if (confirmModal) {
            confirmModal.addEventListener('click', function(e) {
                if (e.target === this) closeCustomConfirmModal();
            });
        }

        const editModal = document.getElementById('editCustomerModal');
        if (editModal) {
            editModal.addEventListener('click', function(e) {
                if (e.target === this) closeEditCustomerModal();
            });
        }

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeCustomConfirmModal();
                closeEditCustomerModal();
            }
        });
    });

    let currentTab = 'Pending';
    let currentPage = 1;
    let pageSize = 10;
    let matchingCustomerRows = [];

    function filterByTab(tab) {
        currentTab = tab;
        currentPage = 1;

        document.getElementById('tabPendingBtn').classList.toggle('active', tab === 'Pending');
        document.getElementById('tabActiveBtn').classList.toggle('active', tab === 'Active');
        if (document.getElementById('tabSuspendedBtn')) {
            document.getElementById('tabSuspendedBtn').classList.toggle('active', tab === 'Suspended');
        }
        document.getElementById('tabAllBtn').classList.toggle('active', tab === 'All');

        applyFilters();
    }

    function handleCustomerSearch() {
        currentPage = 1;
        applyFilters();
    }

    function changeUsersPageSize(newSize) {
        pageSize = parseInt(newSize, 10) || 10;
        currentPage = 1;
        applyFilters();
    }

    function goToCustomerPage(page) {
        currentPage = page;
        updateCustomerPaginationDisplay();
    }

    function applyFilters() {
        const query = document.getElementById('customerSearchInput').value.trim().toLowerCase();
        const allRows = Array.from(document.querySelectorAll('.customer-row'));
        matchingCustomerRows = [];

        allRows.forEach(row => {
            const status = row.getAttribute('data-status');
            const searchData = row.getAttribute('data-search') || '';

            const isSuspended = (status === 'Locked' || status === 'Suspended' || status === 'Rejected');
            const isActive = (status === 'Active');
            const isPending = (!isActive && !isSuspended);

            let matchesTab = false;
            if (currentTab === 'All') {
                matchesTab = true;
            } else if (currentTab === 'Active') {
                matchesTab = isActive;
            } else if (currentTab === 'Suspended') {
                matchesTab = isSuspended;
            } else if (currentTab === 'Pending') {
                matchesTab = isPending;
            }
            const matchesQuery = !query || searchData.includes(query);

            if (matchesTab && matchesQuery) {
                matchingCustomerRows.push(row);
            }
        });

        const table = document.getElementById('customersTable');
        const emptyState = document.getElementById('emptyStateBox');
        const emptyTitle = document.getElementById('emptyStateTitle');
        const emptyDesc = document.getElementById('emptyStateDesc');
        const pagination = document.getElementById('usersPagination');

        if (matchingCustomerRows.length === 0) {
            table.style.display = 'none';
            if (pagination) pagination.style.display = 'none';
            emptyState.style.display = 'block';

            if (query) {
                emptyTitle.textContent = 'No Customers Found';
                emptyDesc.textContent = 'No customer records matched your search query "' + query + '". Try adjusting your search term.';
            } else if (currentTab === 'Pending') {
                emptyTitle.textContent = 'All Caught Up!';
                emptyDesc.textContent = 'There are currently no pending customer registrations requiring Super Admin verification. All client accounts are up to date.';
            } else if (currentTab === 'Active') {
                emptyTitle.textContent = 'No Active Customers';
                emptyDesc.textContent = 'There are currently no active customer accounts found in the database.';
            } else if (currentTab === 'Suspended') {
                emptyTitle.textContent = 'No Suspended Customers';
                emptyDesc.textContent = 'Good news! There are currently no suspended or inactive customer accounts in the system.';
            } else {
                emptyTitle.textContent = 'No Customer Records';
                emptyDesc.textContent = 'No registered customers or portal users found.';
            }
        } else {
            table.style.display = 'table';
            if (pagination) pagination.style.display = 'flex';
            emptyState.style.display = 'none';
            updateCustomerPaginationDisplay();
        }
    }

    function updateCustomerPaginationDisplay() {
        const total = matchingCustomerRows.length;
        const totalPages = Math.ceil(total / pageSize) || 1;

        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        const startIndex = total === 0 ? 0 : (currentPage - 1) * pageSize;
        const endIndex = Math.min(startIndex + pageSize, total);

        const startEl = document.getElementById('usersPageStart');
        const endEl = document.getElementById('usersPageEnd');
        const totalEl = document.getElementById('usersTotalRows');

        if (startEl) startEl.textContent = total === 0 ? '0' : (startIndex + 1);
        if (endEl) endEl.textContent = endIndex;
        if (totalEl) totalEl.textContent = total;

        const allRows = document.querySelectorAll('.customer-row');
        allRows.forEach(r => { r.style.display = 'none'; });

        for (let i = startIndex; i < endIndex; i++) {
            if (matchingCustomerRows[i]) {
                matchingCustomerRows[i].style.display = '';
            }
        }

        renderCustomerPaginationButtons(totalPages);
    }

    function renderCustomerPaginationButtons(totalPages) {
        const nav = document.getElementById('usersPageNav');
        if (!nav) return;
        nav.innerHTML = '';

        if (totalPages <= 1 && matchingCustomerRows.length <= pageSize) {
            return;
        }

        // Prev Button
        const prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'nl-page-btn nl-page-nav-btn' + (currentPage === 1 ? ' disabled' : '');
        prevBtn.innerHTML = '<i class="ti ti-chevron-left"></i> Prev';
        prevBtn.onclick = function() { if (currentPage > 1) goToCustomerPage(currentPage - 1); };
        nav.appendChild(prevBtn);

        // Page Numbers
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
            p1.onclick = function() { goToCustomerPage(1); };
            nav.appendChild(p1);

            if (startPage > 2) {
                const dots = document.createElement('span');
                dots.style.padding = '0 6px';
                dots.style.color = '#94A3B8';
                dots.textContent = '...';
                nav.appendChild(dots);
            }
        }

        for (let p = startPage; p <= endPage; p++) {
            const pBtn = document.createElement('button');
            pBtn.type = 'button';
            pBtn.className = 'nl-page-btn nl-page-num' + (p === currentPage ? ' active' : '');
            pBtn.textContent = p;
            (function(page) {
                pBtn.onclick = function() { goToCustomerPage(page); };
            })(p);
            nav.appendChild(pBtn);
        }

        if (endPage < totalPages) {
            if (endPage < totalPages - 1) {
                const dots = document.createElement('span');
                dots.style.padding = '0 6px';
                dots.style.color = '#94A3B8';
                dots.textContent = '...';
                nav.appendChild(dots);
            }
            const pLast = document.createElement('button');
            pLast.type = 'button';
            pLast.className = 'nl-page-btn nl-page-num' + (currentPage === totalPages ? ' active' : '');
            pLast.textContent = totalPages;
            pLast.onclick = function() { goToCustomerPage(totalPages); };
            nav.appendChild(pLast);
        }

        // Next Button
        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'nl-page-btn nl-page-nav-btn' + (currentPage === totalPages ? ' disabled' : '');
        nextBtn.innerHTML = 'Next <i class="ti ti-chevron-right"></i>';
        nextBtn.onclick = function() { if (currentPage < totalPages) goToCustomerPage(currentPage + 1); };
        nav.appendChild(nextBtn);
    }

    document.addEventListener('DOMContentLoaded', function() {
        filterByTab('Pending');
    });
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
