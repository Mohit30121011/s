<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, com.nlogistic.dao.AuditDAO, com.nlogistic.dao.AuditDAO.AuditEntry" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
    // Resilient self-contained controller logic for Audit Logins & Security
    com.nlogistic.model.User currentUser = (com.nlogistic.model.User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // Role check: Only Super Admin (1) or Company Admin (2) can view audit logs
    if (currentUser.getRoleId() != 1 && currentUser.getRoleId() != 2) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: You do not have permission to view security audit trails.");
        return;
    }

    AuditDAO auditDAO = new AuditDAO();

    // Query parameters
    String actionFilter = request.getParameter("action");
    if (actionFilter == null) actionFilter = "ALL";

    String searchKeyword = request.getParameter("q");

    // Fetch logs (limit 150 for snappy performance)
    List<AuditEntry> auditLogs = auditDAO.getAuditLogs(actionFilter, searchKeyword, 150);
    Map<String, Integer> kpis = auditDAO.getAuditKPIs();

    request.setAttribute("auditLogs", auditLogs);
    request.setAttribute("kpis", kpis);
    request.setAttribute("currentAction", actionFilter);
    request.setAttribute("searchKeyword", searchKeyword != null ? searchKeyword : "");
%>

<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* ==========================================================================
       SECURITY & AUTHENTICATION AUDIT TRAIL THEME (MATCHING APPROVALS UI)
       ========================================================================== */
    .audit-page-container {
        padding: 0 4px 40px;
    }
    .custom-breadcrumb {
        display: flex; align-items: center; gap: 8px; font-size: 13px; color: #64748B; margin-bottom: 16px;
    }
    .custom-breadcrumb a { color: #64748B; text-decoration: none; transition: color 0.15s ease; }
    .custom-breadcrumb a:hover { color: #FC8019; }
    .custom-breadcrumb i { font-size: 11px; color: #94A3B8; }
    .custom-breadcrumb .current { color: #FC8019; font-weight: 600; }

    /* Top Telemetry Header */
    .telemetry-header-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 16px; padding: 24px 28px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04); margin-bottom: 24px;
        display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 20px;
    }
    .telemetry-title-group h1 {
        font-size: 22px; font-weight: 800; color: #0F172A; margin: 0 0 6px 0;
        display: flex; align-items: center; gap: 10px;
    }
    .telemetry-title-group h1 .badge-security {
        font-size: 11.5px; font-weight: 700; background: #FEF3C7; color: #92400E;
        padding: 4px 10px; border-radius: 20px; border: 1px solid #FDE68A; text-transform: uppercase; letter-spacing: 0.5px;
    }
    .telemetry-title-group p {
        font-size: 13.5px; color: #64748B; margin: 0;
    }
    .live-monitor-pill {
        display: inline-flex; align-items: center; gap: 8px; background: #F0FDF4; border: 1px solid #BBF7D0;
        color: #166534; font-size: 12.5px; font-weight: 600; padding: 7px 14px; border-radius: 30px;
    }
    .live-dot {
        width: 8px; height: 8px; background: #22C55E; border-radius: 50%;
        box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.25); animation: pulseDot 2s infinite;
    }
    @keyframes pulseDot {
        0%, 100% { opacity: 1; transform: scale(1); }
        50% { opacity: 0.5; transform: scale(1.15); }
    }

    /* KPI Metrics Cards (4 Columns) */
    .kpi-metric-row {
        display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px; margin-bottom: 24px;
    }
    .kpi-metric-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 14px; padding: 20px 22px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03); display: flex; align-items: center; justify-content: space-between;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    .kpi-metric-card:hover {
        transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,0,0,0.06);
    }
    .kpi-metric-card .kpi-label {
        font-size: 12.5px; font-weight: 600; color: #64748B; text-transform: uppercase; letter-spacing: 0.4px; margin-bottom: 6px;
    }
    .kpi-metric-card .kpi-value {
        font-size: 26px; font-weight: 800; color: #0F172A; line-height: 1; margin-bottom: 4px;
    }
    .kpi-metric-card .kpi-hint {
        font-size: 12px; color: #94A3B8;
    }
    .kpi-metric-icon {
        width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center;
        font-size: 24px; flex-shrink: 0;
    }
    .kpi-metric-icon.emerald { background: #ECFDF5; color: #059669; }
    .kpi-metric-icon.blue { background: #EFF6FF; color: #2563EB; }
    .kpi-metric-icon.red { background: #FEF2F2; color: #DC2626; }
    .kpi-metric-icon.orange { background: #FFF7ED; color: #FC8019; }

    /* Main Table Card */
    .audit-table-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 16px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04); overflow: hidden;
    }

    /* Filter Toolbar */
    .audit-filter-toolbar {
        padding: 18px 24px; border-bottom: 1px solid #F1F5F9; background: #FAFAFA;
        display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 14px;
    }
    .audit-search-box {
        position: relative; flex: 1; min-width: 260px; max-width: 380px;
    }
    .audit-search-box input {
        width: 100%; height: 40px; padding: 0 14px 0 38px; font-size: 13.5px;
        border: 1px solid #CBD5E1; border-radius: 30px; background: #FFFFFF; outline: none; transition: all 0.2s ease;
    }
    .audit-search-box input:focus {
        border-color: #FC8019; box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.15);
    }
    .audit-search-box i {
        position: absolute; left: 14px; top: 12px; font-size: 16px; color: #94A3B8; pointer-events: none;
    }

    .filter-pills-group {
        display: flex; align-items: center; gap: 8px; flex-wrap: wrap;
    }
    .filter-pill-btn {
        padding: 6px 14px; font-size: 12.5px; font-weight: 600; border-radius: 20px;
        text-decoration: none; border: 1px solid #E2E8F0; background: #FFFFFF; color: #64748B;
        transition: all 0.15s ease; display: inline-flex; align-items: center; gap: 6px;
    }
    .filter-pill-btn:hover {
        border-color: #CBD5E1; background: #F8FAFC; color: #0F172A;
    }
    .filter-pill-btn.active {
        background: #0F172A; border-color: #0F172A; color: #FFFFFF;
    }
    .filter-pill-btn.active .count {
        background: rgba(255,255,255,0.25); color: #FFFFFF;
    }
    .filter-pill-btn .count {
        background: #F1F5F9; color: #475569; font-size: 11px; padding: 2px 7px; border-radius: 10px; font-weight: 700;
    }

    /* Table Styling */
    .audit-table {
        width: 100%; margin: 0; border-collapse: separate; border-spacing: 0;
    }
    .audit-table thead th {
        background: #F8FAFC; font-size: 12px; font-weight: 700; text-transform: uppercase;
        color: #475569; letter-spacing: 0.5px; padding: 14px 20px; border-bottom: 1px solid #E2E8F0;
        white-space: nowrap;
    }
    .audit-table tbody tr {
        transition: background 0.15s ease;
    }
    .audit-table tbody tr:hover {
        background: #F8FAFC;
    }
    .audit-table tbody td {
        padding: 16px 20px; vertical-align: middle; font-size: 13.5px; color: #1E293B;
        border-bottom: 1px solid #F1F5F9;
    }

    /* Event Badges */
    .event-badge {
        display: inline-flex; align-items: center; gap: 6px; padding: 5px 12px;
        border-radius: 20px; font-size: 12px; font-weight: 700; letter-spacing: 0.2px; text-transform: uppercase;
    }
    .event-badge.login-success { background: #ECFDF5; border: 1px solid #A7F3D0; color: #065F46; }
    .event-badge.login-failed { background: #FEF2F2; border: 1px solid #FCA5A5; color: #991B1B; }
    .event-badge.logout { background: #EFF6FF; border: 1px solid #BFDBFE; color: #1E40AF; }
    .event-badge.pwd-reset { background: #FFF7ED; border: 1px solid #FED7AA; color: #C2410C; }
    .event-badge.access-denied { background: #FFF1F2; border: 1px solid #FECDD3; color: #BE123C; }
    .event-badge.generic-audit { background: #F1F5F9; border: 1px solid #E2E8F0; color: #334155; }

    /* IP & Identifier Badges */
    .ip-badge {
        font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
        font-size: 12px; background: #F1F5F9; color: #334155; padding: 3px 8px; border-radius: 6px;
        border: 1px solid #E2E8F0; display: inline-flex; align-items: center; gap: 5px;
    }
    .user-avatar-initial {
        width: 34px; height: 34px; border-radius: 50%; background: #FC8019; color: #FFFFFF;
        display: inline-flex; align-items: center; justify-content: center; font-weight: 700; font-size: 13px;
    }
    .user-info-box {
        display: flex; align-items: center; gap: 10px;
    }
    .user-name-title {
        font-weight: 700; color: #0F172A; line-height: 1.2;
    }
    .user-email-sub {
        font-size: 12px; color: #64748B;
    }

    /* Modal Styling */
    .modal-forensic-header {
        background: #0F172A; color: #FFFFFF; padding: 20px 24px; border-radius: 16px 16px 0 0;
    }
    .modal-forensic-body {
        padding: 24px;
    }
    .forensic-kv-grid {
        display: grid; grid-template-columns: 140px 1fr; gap: 12px 20px; font-size: 13.5px;
    }
    .forensic-kv-label {
        font-weight: 600; color: #64748B;
    }
    .forensic-kv-value {
        color: #0F172A; font-weight: 500; word-break: break-all;
    }
</style>

<div class="approvals-page-container audit-page-container">

    <!-- Breadcrumb Navigation -->
    <div class="custom-breadcrumb">
        <a href="${pageContext.request.contextPath}/dashboard"><i class="ti ti-smart-home"></i> Dashboard</a>
        <i class="ti ti-chevron-right"></i>
        <span>Administration</span>
        <i class="ti ti-chevron-right"></i>
        <span>Audit Logs</span>
        <i class="ti ti-chevron-right"></i>
        <span class="current">Logins &amp; Security</span>
    </div>

    <!-- Header Telemetry Card -->
    <div class="telemetry-header-card">
        <div class="telemetry-title-group">
            <h1>
                <i class="ti ti-history" style="color: #FC8019;"></i>
                Logins &amp; Security Audit Trail
                <span class="badge-security"><i class="ti ti-shield-check"></i> FR1.9 Compliance</span>
            </h1>
            <p>Immutable forensic telemetry recording all system authentication attempts, session logouts, password resets, and role permission enforcement.</p>
        </div>
        <div class="d-flex align-items-center gap-3">
            <div class="live-monitor-pill">
                <span class="live-dot"></span>
                <span>Active Forensic Telemetry</span>
            </div>
            <button class="btn btn-outline-secondary btn-sm" onclick="window.location.reload();" title="Refresh Audit Log">
                <i class="ti ti-refresh"></i> Refresh
            </button>
        </div>
    </div>

    <!-- KPI Metrics Row (4 Cards) -->
    <div class="kpi-metric-row">
        <!-- 1. Total Logins -->
        <div class="kpi-metric-card">
            <div>
                <div class="kpi-label">Successful Logins</div>
                <div class="kpi-value text-success">${kpis.totalLogins}</div>
                <div class="kpi-hint"><i class="ti ti-circle-check"></i> Verified session auths</div>
            </div>
            <div class="kpi-metric-icon emerald">
                <i class="ti ti-login"></i>
            </div>
        </div>

        <!-- 2. Total Logouts -->
        <div class="kpi-metric-card">
            <div>
                <div class="kpi-label">Terminated Sessions</div>
                <div class="kpi-value text-primary">${kpis.totalLogouts}</div>
                <div class="kpi-hint"><i class="ti ti-logout"></i> Clean session invalidations</div>
            </div>
            <div class="kpi-metric-icon blue">
                <i class="ti ti-logout"></i>
            </div>
        </div>

        <!-- 3. Failed Attempts -->
        <div class="kpi-metric-card">
            <div>
                <div class="kpi-label">Failed Logins</div>
                <div class="kpi-value text-danger">${kpis.failedLogins}</div>
                <div class="kpi-hint"><i class="ti ti-shield-alert"></i> Monitored for 5-attempt lockout</div>
            </div>
            <div class="kpi-metric-icon red">
                <i class="ti ti-alert-triangle"></i>
            </div>
        </div>

        <!-- 4. Security Events -->
        <div class="kpi-metric-card">
            <div>
                <div class="kpi-label">Security Alerts</div>
                <div class="kpi-value" style="color: #FC8019;">${kpis.securityAlerts}</div>
                <div class="kpi-hint"><i class="ti ti-key"></i> Resets, locks &amp; permissions</div>
            </div>
            <div class="kpi-metric-icon orange">
                <i class="ti ti-shield-lock"></i>
            </div>
        </div>
    </div>

    <!-- Main Table Card -->
    <div class="audit-table-card">
        <!-- Filter Toolbar -->
        <div class="audit-filter-toolbar">
            <!-- Client Filter Pills -->
            <div class="filter-pills-group">
                <a href="${pageContext.request.contextPath}/jsp/admin/audit_logins.jsp?action=ALL" class="filter-pill-btn ${currentAction == 'ALL' ? 'active' : ''}">
                    All Events <span class="count">${kpis.totalLogs}</span>
                </a>
                <a href="${pageContext.request.contextPath}/jsp/admin/audit_logins.jsp?action=LOGIN_SUCCESS" class="filter-pill-btn ${currentAction == 'LOGIN_SUCCESS' ? 'active' : ''}">
                    <i class="ti ti-login text-success"></i> Logins <span class="count">${kpis.totalLogins}</span>
                </a>
                <a href="${pageContext.request.contextPath}/jsp/admin/audit_logins.jsp?action=LOGOUT" class="filter-pill-btn ${currentAction == 'LOGOUT' ? 'active' : ''}">
                    <i class="ti ti-logout text-primary"></i> Logouts <span class="count">${kpis.totalLogouts}</span>
                </a>
                <a href="${pageContext.request.contextPath}/jsp/admin/audit_logins.jsp?action=LOGIN_FAILED" class="filter-pill-btn ${currentAction == 'LOGIN_FAILED' ? 'active' : ''}">
                    <i class="ti ti-alert-circle text-danger"></i> Failed <span class="count">${kpis.failedLogins}</span>
                </a>
                <a href="${pageContext.request.contextPath}/jsp/admin/audit_logins.jsp?action=PASSWORD_RESET_DISPATCHED" class="filter-pill-btn ${currentAction == 'PASSWORD_RESET_DISPATCHED' ? 'active' : ''}">
                    <i class="ti ti-mail-forward text-warning"></i> Password Resets
                </a>
            </div>

            <!-- Instant Search Input -->
            <div class="audit-search-box">
                <i class="ti ti-search"></i>
                <input type="text" id="auditSearchInput" placeholder="Search user, action, IP..." onkeyup="filterAuditTable()">
            </div>
        </div>

        <!-- Table Container -->
        <div class="table-responsive">
            <table class="audit-table" id="auditTable">
                <thead>
                    <tr>
                        <th>Log ID</th>
                        <th>Event Timestamp</th>
                        <th>User Identity</th>
                        <th>Role</th>
                        <th>Security Event</th>
                        <th>IP Address</th>
                        <th>Entity Target</th>
                        <th style="text-align: right;">Forensics</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty auditLogs}">
                            <c:forEach var="log" items="${auditLogs}">
                                <tr class="audit-row" data-search="${log.logId} ${log.username} ${log.email} ${log.action} ${log.ipAddress} ${log.roleName}">
                                    <td>
                                        <span style="font-weight: 700; color: #475569;">#LOG-${log.logId}</span>
                                    </td>
                                    <td>
                                        <div style="font-weight: 600; color: #0F172A;">
                                            <fmt:formatDate value="${log.timestamp}" pattern="yyyy-MM-dd HH:mm:ss" />
                                        </div>
                                        <div style="font-size: 11.5px; color: #94A3B8;">
                                            <i class="ti ti-clock"></i> UTC+05:30
                                        </div>
                                    </td>
                                    <td>
                                        <div class="user-info-box">
                                            <div class="user-avatar-initial">
                                                ${log.username != null && log.username.length() > 0 ? log.username.substring(0, 1).toUpperCase() : 'U'}
                                            </div>
                                            <div>
                                                <div class="user-name-title">${log.username}</div>
                                                <div class="user-email-sub">${log.email}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge bg-light text-dark border" style="font-size: 11.5px; font-weight: 600;">
                                            ${log.roleName}
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${log.action == 'LOGIN_SUCCESS'}">
                                                <span class="event-badge login-success">
                                                    <i class="ti ti-circle-check"></i> LOGIN SUCCESS
                                                </span>
                                            </c:when>
                                            <c:when test="${log.action == 'LOGIN_FAILED'}">
                                                <span class="event-badge login-failed">
                                                    <i class="ti ti-circle-x"></i> LOGIN FAILED
                                                </span>
                                            </c:when>
                                            <c:when test="${log.action == 'LOGOUT'}">
                                                <span class="event-badge logout">
                                                    <i class="ti ti-logout"></i> LOGOUT
                                                </span>
                                            </c:when>
                                            <c:when test="${log.action == 'PASSWORD_RESET_DISPATCHED'}">
                                                <span class="event-badge pwd-reset">
                                                    <i class="ti ti-mail-forward"></i> RESET DISPATCHED
                                                </span>
                                            </c:when>
                                            <c:when test="${log.action == 'PASSWORD_RESET_SUCCESS'}">
                                                <span class="event-badge login-success">
                                                    <i class="ti ti-key"></i> PASSWORD CHANGED
                                                </span>
                                            </c:when>
                                            <c:when test="${log.action == 'PERMISSION_DENIED'}">
                                                <span class="event-badge access-denied">
                                                    <i class="ti ti-shield-x"></i> ACCESS DENIED
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="event-badge generic-audit">
                                                    <i class="ti ti-activity"></i> ${log.action}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="ip-badge">
                                            <i class="ti ti-world"></i> ${log.ipAddress != null ? log.ipAddress : '127.0.0.1'}
                                        </span>
                                    </td>
                                    <td>
                                        <span style="font-size: 12px; color: #64748B;">
                                            ${log.entityName != null ? log.entityName : 'Auth Terminal'}
                                            <c:if test="${log.entityId > 0}"> (#${log.entityId})</c:if>
                                        </span>
                                    </td>
                                    <td style="text-align: right;">
                                        <button class="btn btn-sm btn-outline-secondary" 
                                                onclick="openForensicModal('${log.logId}', '${log.username}', '${log.action}', '${log.ipAddress}', '${log.timestamp}', '${log.roleName}')"
                                                title="View Forensic Details" style="border-radius: 8px; font-size: 12px; font-weight: 600;">
                                            <i class="ti ti-eye"></i> Details
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="8" style="text-align: center; padding: 48px 20px;">
                                    <div style="font-size: 40px; color: #CBD5E1; margin-bottom: 12px;">
                                        <i class="ti ti-shield-check"></i>
                                    </div>
                                    <h5 style="font-weight: 700; color: #334155; margin-bottom: 6px;">No Security Audit Logs Found</h5>
                                    <p style="color: #64748B; font-size: 13.5px; margin: 0;">No matching authentication records found for the selected event filters.</p>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <!-- Footer Pagination / Summary -->
        <div style="padding: 14px 24px; border-top: 1px solid #F1F5F9; background: #FAFAFA; display: flex; align-items: center; justify-content: space-between; font-size: 13px; color: #64748B;">
            <div>
                Showing <strong id="visibleCount">${auditLogs.size()}</strong> of <strong>${auditLogs.size()}</strong> logged authentication events
            </div>
            <div style="font-size: 12px; color: #94A3B8;">
                <i class="ti ti-lock"></i> 256-Bit Immutable Forensic Storage
            </div>
        </div>
    </div>
</div>

<!-- Forensic Details Modal -->
<div class="modal fade" id="forensicModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 16px; border: none; overflow: hidden; box-shadow: 0 20px 40px rgba(0,0,0,0.18);">
            <div class="modal-forensic-header d-flex align-items-center justify-content-between">
                <div class="d-flex align-items-center gap-2">
                    <i class="ti ti-fingerprint" style="font-size: 20px; color: #FC8019;"></i>
                    <h5 class="modal-title" id="modalForensicTitle" style="font-size: 16px; font-weight: 700; margin: 0;">Audit Event #LOG-</h5>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-forensic-body">
                <div class="forensic-kv-grid mb-4">
                    <div class="forensic-kv-label">User Account:</div>
                    <div class="forensic-kv-value" id="modalUser">-</div>

                    <div class="forensic-kv-label">Assigned Role:</div>
                    <div class="forensic-kv-value" id="modalRole">-</div>

                    <div class="forensic-kv-label">Action / Event:</div>
                    <div class="forensic-kv-value" id="modalAction">-</div>

                    <div class="forensic-kv-label">Client IP:</div>
                    <div class="forensic-kv-value" id="modalIp">-</div>

                    <div class="forensic-kv-label">Timestamp:</div>
                    <div class="forensic-kv-value" id="modalTime">-</div>

                    <div class="forensic-kv-label">Compliance Ref:</div>
                    <div class="forensic-kv-value" style="color: #059669; font-weight: 700;">FR1.9 Audit Trail (Security Subsystem)</div>
                </div>

                <div class="p-3 bg-light rounded-3" style="font-size: 12px; color: #475569; border: 1px solid #E2E8F0;">
                    <i class="ti ti-info-circle text-primary"></i>
                    This record represents an immutable audit entry logged by NLogistic authentication filter &amp; database stored procedures during runtime.
                </div>
            </div>
            <div class="modal-footer" style="border-top: 1px solid #F1F5F9; padding: 12px 24px;">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal" style="border-radius: 8px;">Close</button>
            </div>
        </div>
    </div>
</div>

<script>
    // Live Client Filter
    function filterAuditTable() {
        const query = document.getElementById('auditSearchInput').value.toLowerCase().trim();
        const rows = document.querySelectorAll('#auditTable tbody .audit-row');
        let visible = 0;

        rows.forEach(row => {
            const data = row.getAttribute('data-search').toLowerCase();
            if (!query || data.includes(query)) {
                row.style.display = '';
                visible++;
            } else {
                row.style.display = 'none';
            }
        });

        const countEl = document.getElementById('visibleCount');
        if (countEl) countEl.textContent = visible;
    }

    // Open Forensic Details Modal
    function openForensicModal(logId, user, action, ip, time, role) {
        document.getElementById('modalForensicTitle').textContent = 'Audit Event #LOG-' + logId;
        document.getElementById('modalUser').textContent = user || 'Anonymous / Unauthenticated';
        document.getElementById('modalRole').textContent = role || 'Public Client';
        document.getElementById('modalAction').textContent = action;
        document.getElementById('modalIp').textContent = ip || '127.0.0.1';
        document.getElementById('modalTime').textContent = time;

        const modalEl = document.getElementById('forensicModal');
        const modal = new bootstrap.Modal(modalEl);
        modal.show();
    }
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
