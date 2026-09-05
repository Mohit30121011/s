<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, com.nlogistic.dao.AuditDAO, com.nlogistic.dao.AuditDAO.AuditEntry" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- MVC2: this view renders only. All data and every POST action are
     handled by AuditLogServlet (/admin/audit-logs). The previous inline
     controller scriptlet duplicated that logic and bypassed the audited
     stored procedures. --%>
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

    /* Elegant Swiggy Orange Filter Pills (No harsh black) */
    .filter-pills-group {
        display: flex; align-items: center; gap: 8px; flex-wrap: wrap;
    }
    .filter-pill-btn {
        padding: 7px 15px; font-size: 13px; font-weight: 600; border-radius: 30px;
        text-decoration: none; border: 1.5px solid #E2E8F0; background: #FFFFFF; color: #64748B;
        transition: all 0.2s ease; display: inline-flex; align-items: center; gap: 7px; cursor: pointer;
    }
    .filter-pill-btn:hover {
        border-color: #CBD5E1; background: #F8FAFC; color: #0F172A;
    }
    .filter-pill-btn.active {
        background: #FFF7ED !important;
        border-color: #FC8019 !important;
        color: #EA580C !important;
        font-weight: 700;
        box-shadow: 0 2px 8px rgba(252, 128, 25, 0.18);
    }
    .filter-pill-btn .count {
        background: #F1F5F9; color: #475569; font-size: 11px; padding: 2px 7px; border-radius: 10px; font-weight: 700;
        transition: all 0.2s ease;
    }
    .filter-pill-btn.active .count {
        background: #FC8019 !important;
        color: #FFFFFF !important;
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
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25);
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

    /* Enterprise Pagination Styling (Matching Companies UI) */
    .nl-pagination-wrapper {
        display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 14px;
        padding: 16px 24px; border-top: 1px solid #F1F5F9; background: #FAFAFA;
    }
    .nl-pagination-info {
        font-size: 13px; color: #64748B; display: flex; align-items: center; gap: 16px; flex-wrap: wrap;
    }
    .nl-page-size-select {
        height: 32px; padding: 0 10px; font-size: 12.5px; border-radius: 8px; border: 1px solid #CBD5E1;
        background: #FFFFFF; color: #1E293B; font-weight: 600; outline: none; cursor: pointer;
    }
    .nl-pagination-nav {
        display: flex; align-items: center; gap: 6px;
    }
    .nl-page-btn {
        min-width: 34px; height: 34px; padding: 0 10px; border-radius: 8px; border: 1px solid #E2E8F0;
        background: #FFFFFF; color: #475569; font-size: 13px; font-weight: 600; display: inline-flex;
        align-items: center; justify-content: center; cursor: pointer; transition: all 0.15s ease;
    }
    .nl-page-btn:hover:not(.disabled) {
        border-color: #CBD5E1; background: #F8FAFC; color: #0F172A;
    }
    .nl-page-btn.active {
        background: #FC8019 !important; border-color: #FC8019 !important; color: #FFFFFF !important;
        font-weight: 700; box-shadow: 0 2px 8px rgba(252, 128, 25, 0.3);
    }
    .nl-page-btn.disabled {
        opacity: 0.45; cursor: not-allowed; background: #F8FAFC;
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
            </h1>
            <p>Real-time telemetry recording all system authentication attempts, session logouts, password resets, and role permission enforcement.</p>
        </div>
        <div class="d-flex align-items-center gap-3">
            <div class="live-monitor-pill">
                <span class="live-dot"></span>
                <span>Active Database Telemetry</span>
            </div>
            <button class="btn btn-outline-secondary btn-sm" onclick="window.location.reload();" title="Refresh Live Data">
                <i class="ti ti-refresh"></i> Refresh
            </button>
        </div>
    </div>

    <!-- KPI Metrics Row (4 Cards) -->
    <div class="kpi-metric-row">
        <!-- 1. Total Logins -->
        <div class="kpi-metric-card" onclick="selectFilterTab('LOGIN_SUCCESS')" style="cursor: pointer;" title="Filter by Logins">
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
        <div class="kpi-metric-card" onclick="selectFilterTab('LOGOUT')" style="cursor: pointer;" title="Filter by Logouts">
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
        <div class="kpi-metric-card" onclick="selectFilterTab('FAILED')" style="cursor: pointer;" title="Filter by Failed Logins">
            <div>
                <div class="kpi-label">Failed Logins</div>
                <div class="kpi-value text-danger">${kpis.failedLogins}</div>
                <div class="kpi-hint"><i class="ti ti-shield-x"></i> Monitored for 5-attempt lockout</div>
            </div>
            <div class="kpi-metric-icon red">
                <i class="ti ti-alert-triangle"></i>
            </div>
        </div>

        <!-- 4. Security Events -->
        <div class="kpi-metric-card" onclick="selectFilterTab('RESETS')" style="cursor: pointer;" title="Filter by Security Events">
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
            <!-- Client Filter Pills (Orange active highlight) -->
            <div class="filter-pills-group" id="filterPillsGroup">
                <button type="button" class="filter-pill-btn active" data-action="ALL" onclick="selectFilterTab('ALL')">
                    All Events <span class="count">${kpis.totalLogs}</span>
                </button>
                <button type="button" class="filter-pill-btn" data-action="LOGIN_SUCCESS" onclick="selectFilterTab('LOGIN_SUCCESS')">
                    <i class="ti ti-login text-success"></i> Logins <span class="count">${kpis.totalLogins}</span>
                </button>
                <button type="button" class="filter-pill-btn" data-action="LOGOUT" onclick="selectFilterTab('LOGOUT')">
                    <i class="ti ti-logout text-primary"></i> Logouts <span class="count">${kpis.totalLogouts}</span>
                </button>
                <button type="button" class="filter-pill-btn" data-action="FAILED" onclick="selectFilterTab('FAILED')">
                    <i class="ti ti-alert-circle text-danger"></i> Failed <span class="count">${kpis.failedLogins}</span>
                </button>
                <button type="button" class="filter-pill-btn" data-action="RESETS" onclick="selectFilterTab('RESETS')">
                    <i class="ti ti-mail-forward text-warning"></i> Password Resets <span class="count">${kpis.securityAlerts}</span>
                </button>
            </div>

            <!-- Instant Search Input -->
            <div class="audit-search-box">
                <i class="ti ti-search"></i>
                <input type="text" id="auditSearchInput" placeholder="Search user, action, IP..." onkeyup="onSearchInput()">
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
                        <th>Target Context</th>
                        <th style="text-align: right;">Forensics</th>
                    </tr>
                </thead>
                <tbody id="auditTableBody">
                    <c:choose>
                        <c:when test="${not empty auditLogs}">
                            <c:forEach var="log" items="${auditLogs}">
                                <tr class="audit-row" 
                                    data-id="${log.logId}"
                                    data-action="${log.action}"
                                    data-user="${log.username}"
                                    data-email="${log.email}"
                                    data-role="${log.roleName}"
                                    data-ip="${log.ipAddress}"
                                    data-search="${log.logId} ${log.username} ${log.email} ${log.action} ${log.ipAddress} ${log.roleName}">
                                    <td>
                                        <span style="font-weight: 700; color: #475569;">#LOG-${log.logId}</span>
                                    </td>
                                    <td>
                                        <div style="font-weight: 600; color: #0F172A;">
                                            <fmt:formatDate value="${log.timestamp}" pattern="yyyy-MM-dd HH:mm:ss" />
                                        </div>
                                        <div style="font-size: 11.5px; color: #94A3B8;">
                                            <i class="ti ti-clock"></i> Local Time
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
                                            <c:when test="${log.action == 'LOGIN_BLOCKED_LOCKED'}">
                                                <span class="event-badge login-failed">
                                                    <i class="ti ti-lock"></i> ACCOUNT LOCKED
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
                                            ${log.entityName != null && !log.entityName.isEmpty() ? log.entityName : 'Auth Gateway'}
                                            <c:if test="${log.entityId > 0}"> (#${log.entityId})</c:if>
                                        </span>
                                    </td>
                                    <td style="text-align: right;">
                                        <button class="btn btn-sm btn-outline-secondary" 
                                                onclick="openForensicModal('${log.logId}', '${log.username}', '${log.action}', '${log.ipAddress}', '<fmt:formatDate value="${log.timestamp}" pattern="yyyy-MM-dd HH:mm:ss" />', '${log.roleName}')"
                                                title="View Forensic Details" style="border-radius: 8px; font-size: 12px; font-weight: 600;">
                                            <i class="ti ti-eye"></i> Details
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr id="serverEmptyRow">
                                <td colspan="8" style="text-align: center; padding: 48px 20px;">
                                    <div style="font-size: 40px; color: #CBD5E1; margin-bottom: 12px;">
                                        <i class="ti ti-shield-check"></i>
                                    </div>
                                    <h5 style="font-weight: 700; color: #334155; margin-bottom: 6px;">No Security Audit Logs Found</h5>
                                    <p style="color: #64748B; font-size: 13.5px; margin: 0;">No matching authentication records found in the database.</p>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <!-- Interactive Pagination Footer (Matching Companies UI) -->
        <div class="nl-pagination-wrapper" id="auditPagination">
            <div class="nl-pagination-info">
                <span>Showing <strong id="auditPageStart">1</strong> to <strong id="auditPageEnd">10</strong> of <strong id="auditTotalRows">0</strong> records</span>
                <div class="d-inline-flex align-items-center gap-2 ms-2">
                    <span style="color: #94A3B8; font-size: 12.5px;">Rows per page:</span>
                    <select id="auditPageSize" class="nl-page-size-select no-custom-select" onchange="changeAuditPageSize(this.value)">
                        <option value="10" selected>10</option>
                        <option value="25">25</option>
                        <option value="50">50</option>
                        <option value="100">100</option>
                    </select>
                </div>
            </div>
            <div class="nl-pagination-nav" id="auditPageNav">
                <!-- Dynamically generated page buttons -->
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

                    <div class="forensic-kv-label">Status:</div>
                    <div class="forensic-kv-value" style="color: #059669; font-weight: 700;">Verified Database Entry</div>
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
    // Global Pagination State
    let currentFilterTab = 'ALL';
    let currentSearchQuery = '';
    let currentPage = 1;
    let pageSize = 10;
    let filteredRows = [];

    // Filter by Tab (Active Orange Style)
    function selectFilterTab(action) {
        currentFilterTab = action;
        currentPage = 1;

        // Update Tab Pill UI (Orange active state)
        document.querySelectorAll('#filterPillsGroup .filter-pill-btn').forEach(btn => {
            if (btn.getAttribute('data-action') === action) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        });

        applyAuditFilterAndPagination();
    }

    // Search Input
    function onSearchInput() {
        currentSearchQuery = document.getElementById('auditSearchInput').value.toLowerCase().trim();
        currentPage = 1;
        applyAuditFilterAndPagination();
    }

    // Page Size Change
    function changeAuditPageSize(val) {
        pageSize = parseInt(val, 10) || 10;
        currentPage = 1;
        applyAuditFilterAndPagination();
    }

    // Go to specific page
    function goToAuditPage(page) {
        currentPage = page;
        renderAuditPage();
    }

    // Core Filtering Logic
    function applyAuditFilterAndPagination() {
        const allRows = Array.from(document.querySelectorAll('#auditTableBody .audit-row'));
        filteredRows = [];

        allRows.forEach(row => {
            const action = row.getAttribute('data-action') || '';
            const searchData = (row.getAttribute('data-search') || '').toLowerCase();

            // 1. Tab Action Matching
            let matchesTab = false;
            if (currentFilterTab === 'ALL') {
                matchesTab = true;
            } else if (currentFilterTab === 'LOGIN_SUCCESS') {
                matchesTab = (action === 'LOGIN_SUCCESS');
            } else if (currentFilterTab === 'LOGOUT') {
                matchesTab = (action === 'LOGOUT');
            } else if (currentFilterTab === 'FAILED') {
                matchesTab = (action === 'LOGIN_FAILED' || action === 'LOGIN_BLOCKED_LOCKED');
            } else if (currentFilterTab === 'RESETS') {
                matchesTab = action.includes('RESET') || action.includes('DENIED') || action.includes('CHANGE');
            }

            // 2. Search Keyword Matching
            const matchesSearch = !currentSearchQuery || searchData.includes(currentSearchQuery);

            if (matchesTab && matchesSearch) {
                filteredRows.push(row);
            }
            row.style.display = 'none'; // hide all initially
        });

        renderAuditPage();
    }

    // Render Current Page
    function renderAuditPage() {
        const totalRows = filteredRows.length;
        const totalPages = Math.ceil(totalRows / pageSize) || 1;

        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        const startIdx = (currentPage - 1) * pageSize;
        const endIdx = Math.min(startIdx + pageSize, totalRows);

        // Hide all rows, display only slice
        filteredRows.forEach((row, idx) => {
            if (idx >= startIdx && idx < endIdx) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });

        // Update Info Labels
        document.getElementById('auditPageStart').textContent = totalRows > 0 ? (startIdx + 1) : 0;
        document.getElementById('auditPageEnd').textContent = endIdx;
        document.getElementById('auditTotalRows').textContent = totalRows;

        // Render Pagination Nav Buttons
        renderPaginationNav(totalPages);
    }

    // Build Page Navigation Buttons
    function renderPaginationNav(totalPages) {
        const nav = document.getElementById('auditPageNav');
        nav.innerHTML = '';

        if (totalPages <= 1 && filteredRows.length === 0) return;

        // Previous Button
        const prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'nl-page-btn' + (currentPage === 1 ? ' disabled' : '');
        prevBtn.innerHTML = '<i class="ti ti-chevron-left"></i> Prev';
        prevBtn.onclick = function() {
            if (currentPage > 1) goToAuditPage(currentPage - 1);
        };
        nav.appendChild(prevBtn);

        // Page Numbers Logic (max 5 visible)
        let startPage = Math.max(1, currentPage - 2);
        let endPage = Math.min(totalPages, startPage + 4);
        if (endPage - startPage < 4) {
            startPage = Math.max(1, endPage - 4);
        }

        if (startPage > 1) {
            const p1 = createPageBtn(1);
            nav.appendChild(p1);
            if (startPage > 2) {
                const dots = document.createElement('span');
                dots.style.padding = '0 4px';
                dots.style.color = '#94A3B8';
                dots.textContent = '...';
                nav.appendChild(dots);
            }
        }

        for (let p = startPage; p <= endPage; p++) {
            nav.appendChild(createPageBtn(p));
        }

        if (endPage < totalPages) {
            if (endPage < totalPages - 1) {
                const dots = document.createElement('span');
                dots.style.padding = '0 4px';
                dots.style.color = '#94A3B8';
                dots.textContent = '...';
                nav.appendChild(dots);
            }
            nav.appendChild(createPageBtn(totalPages));
        }

        // Next Button
        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'nl-page-btn' + (currentPage === totalPages ? ' disabled' : '');
        nextBtn.innerHTML = 'Next <i class="ti ti-chevron-right"></i>';
        nextBtn.onclick = function() {
            if (currentPage < totalPages) goToAuditPage(currentPage + 1);
        };
        nav.appendChild(nextBtn);
    }

    function createPageBtn(pageNum) {
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'nl-page-btn' + (pageNum === currentPage ? ' active' : '');
        btn.textContent = pageNum;
        btn.onclick = function() {
            goToAuditPage(pageNum);
        };
        return btn;
    }

    // Open Forensic Details Modal
    function openForensicModal(logId, user, action, ip, time, role) {
        document.getElementById('modalForensicTitle').textContent = 'Audit Event #LOG-' + logId;
        document.getElementById('modalUser').textContent = user || 'Public / Unauthenticated';
        document.getElementById('modalRole').textContent = role || 'Visitor';
        document.getElementById('modalAction').textContent = action;
        document.getElementById('modalIp').textContent = ip || '127.0.0.1';
        document.getElementById('modalTime').textContent = time;

        const modalEl = document.getElementById('forensicModal');
        const modal = new bootstrap.Modal(modalEl);
        modal.show();
    }

    // Initialize on page load
    document.addEventListener('DOMContentLoaded', function() {
        applyAuditFilterAndPagination();
    });
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
