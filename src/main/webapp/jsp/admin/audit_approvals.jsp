<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, com.nlogistic.dao.AuditDAO, com.nlogistic.dao.AuditDAO.AuditEntry" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
    if (request.getAttribute("auditLogs") == null) {
        com.nlogistic.dao.AuditDAO fallbackAuditDAO = new com.nlogistic.dao.AuditDAO();
        String filterParam = request.getParameter("filter");
        if (filterParam == null || filterParam.trim().isEmpty()) {
            filterParam = "ALL";
        }
        String qParam = request.getParameter("q");
        List<AuditDAO.AuditEntry> fallbackLogs = fallbackAuditDAO.getApprovalAuditLogs(filterParam, qParam, 500);

        com.nlogistic.model.User sessionUser = (com.nlogistic.model.User) session.getAttribute("user");
        if (sessionUser != null && sessionUser.getRoleId() == 2) {
            final int cId = sessionUser.getCompanyId();
            final com.nlogistic.dao.UserDAO uDAO = new com.nlogistic.dao.UserDAO();
            java.util.Iterator<AuditDAO.AuditEntry> it = fallbackLogs.iterator();
            while (it.hasNext()) {
                AuditDAO.AuditEntry entry = it.next();
                com.nlogistic.model.User actor = uDAO.getUserById(entry.getUserId());
                if (actor == null || actor.getCompanyId() != cId) {
                    it.remove();
                }
            }
        }

        request.setAttribute("auditLogs", fallbackLogs);
        request.setAttribute("kpis", fallbackAuditDAO.getApprovalKPIs());
        request.setAttribute("currentFilter", filterParam);
        request.setAttribute("searchKeyword", qParam != null ? qParam : "");
    }
%>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* ==========================================================================
       APPROVALS & GOVERNANCE AUDIT TRAIL THEME (LIGHT & DARK MODE COMPATIBLE)
       Identical to audit_logins.jsp and shipments.jsp enterprise design tokens
       ========================================================================== */
    :root {
        --al-primary:        #FC8019;
        --al-primary-hover:  #E66A05;
        --al-primary-light:  #FFF3EA;
        --al-primary-border: #FED7AA;

        --al-card:           #FFFFFF;
        --al-bg:             #F8FAFC;
        --al-border:         #E2E8F0;
        --al-border-hover:   #CBD5E1;
        --al-text:           #0F172A;
        --al-text-sub:       #1E293B;
        --al-muted:          #64748B;
        --al-surface:        #FAFAFA;
        --al-surface2:       #F1F5F9;
        --al-table-head:     #F8FAFC;
        --al-table-hover:    #F8FAFC;
        --al-modal-header:   #0F172A;

        --al-pill-live-bg:   #F0FDF4;
        --al-pill-live-bd:   #BBF7D0;
        --al-pill-live-text: #166534;

        --al-kpi-emerald-bg: #ECFDF5;
        --al-kpi-emerald-fg: #059669;
        --al-kpi-blue-bg:    #EFF6FF;
        --al-kpi-blue-fg:    #2563EB;
        --al-kpi-red-bg:     #FEF2F2;
        --al-kpi-red-fg:     #DC2626;
        --al-kpi-orange-bg:  #FFF7ED;
        --al-kpi-orange-fg:  #FC8019;

        --al-badge-success-bg: #ECFDF5;
        --al-badge-success-bd: #A7F3D0;
        --al-badge-success-fg: #065F46;

        --al-badge-failed-bg:  #FEF2F2;
        --al-badge-failed-bd:  #FCA5A5;
        --al-badge-failed-fg:  #991B1B;

        --al-badge-logout-bg:  #EFF6FF;
        --al-badge-logout-bd:  #BFDBFE;
        --al-badge-logout-fg:  #1E40AF;

        --al-badge-reset-bg:   #FFF7ED;
        --al-badge-reset-bd:   #FED7AA;
        --al-badge-reset-fg:   #C2410C;

        --al-badge-denied-bg:  #FFF1F2;
        --al-badge-denied-bd:  #FECDD3;
        --al-badge-denied-fg:  #BE123C;

        --al-badge-generic-bg: #F1F5F9;
        --al-badge-generic-bd: #E2E8F0;
        --al-badge-generic-fg: #334155;
    }

    [data-theme="dark"] {
        --al-card:           #101820;
        --al-bg:             #0B1117;
        --al-border:         #22303A;
        --al-border-hover:   #2D3F4D;
        --al-text:           #F8FAFC;
        --al-text-sub:       #E2E8F0;
        --al-muted:          #94A3B8;
        --al-surface:        #151F28;
        --al-surface2:       #1C2A37;
        --al-table-head:     #151F28;
        --al-table-hover:    #182430;
        --al-modal-header:   #151F28;

        --al-pill-live-bg:   rgba(16, 185, 129, 0.15);
        --al-pill-live-bd:   rgba(16, 185, 129, 0.3);
        --al-pill-live-text: #34D399;

        --al-kpi-emerald-bg: rgba(16, 185, 129, 0.14);
        --al-kpi-emerald-fg: #34D399;
        --al-kpi-blue-bg:    rgba(37, 99, 235, 0.14);
        --al-kpi-blue-fg:    #60A5FA;
        --al-kpi-red-bg:     rgba(239, 68, 68, 0.14);
        --al-kpi-red-fg:     #F87171;
        --al-kpi-orange-bg:  rgba(252, 128, 25, 0.14);
        --al-kpi-orange-fg:  #FB923C;

        --al-badge-success-bg: rgba(16, 185, 129, 0.14);
        --al-badge-success-bd: rgba(16, 185, 129, 0.28);
        --al-badge-success-fg: #34D399;

        --al-badge-failed-bg:  rgba(239, 68, 68, 0.14);
        --al-badge-failed-bd:  rgba(239, 68, 68, 0.28);
        --al-badge-failed-fg:  #F87171;

        --al-badge-logout-bg:  rgba(59, 130, 246, 0.14);
        --al-badge-logout-bd:  rgba(59, 130, 246, 0.28);
        --al-badge-logout-fg:  #60A5FA;

        --al-badge-reset-bg:   rgba(252, 128, 25, 0.14);
        --al-badge-reset-bd:   rgba(252, 128, 25, 0.28);
        --al-badge-reset-fg:   #FB923C;

        --al-badge-denied-bg:  rgba(244, 63, 94, 0.14);
        --al-badge-denied-bd:  rgba(244, 63, 94, 0.28);
        --al-badge-denied-fg:  #FB7185;

        --al-badge-generic-bg: #1C2A37;
        --al-badge-generic-bd: #22303A;
        --al-badge-generic-fg: #94A3B8;
    }

    .audit-page-container {
        padding: 0 4px 40px;
        color: var(--al-text);
        font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }
    .custom-breadcrumb {
        display: flex; align-items: center; gap: 8px; font-size: 13px; color: var(--al-muted); margin-bottom: 16px;
    }
    .custom-breadcrumb a { color: var(--al-muted); text-decoration: none; transition: color 0.15s ease; }
    .custom-breadcrumb a:hover { color: var(--al-primary); }
    .custom-breadcrumb i { font-size: 11px; color: var(--al-muted); }
    .custom-breadcrumb .current { color: var(--al-text); font-weight: 600; }

    /* Top Telemetry Header */
    .telemetry-header-card {
        background: var(--al-card); border: 1px solid var(--al-border); border-radius: 16px; padding: 24px 28px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04); margin-bottom: 24px;
        display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 20px;
        transition: background 0.2s ease, border-color 0.2s ease;
    }
    .telemetry-title-group h1 {
        font-size: 22px; font-weight: 800; color: var(--al-text); margin: 0 0 6px 0;
        display: flex; align-items: center; gap: 10px;
    }
    .telemetry-title-group p {
        font-size: 13.5px; color: var(--al-muted); margin: 0;
    }
    .live-monitor-pill {
        display: inline-flex; align-items: center; gap: 8px; background: var(--al-pill-live-bg); border: 1px solid var(--al-pill-live-bd);
        color: var(--al-pill-live-text); font-size: 12.5px; font-weight: 600; padding: 7px 14px; border-radius: 30px;
    }
    .live-dot {
        width: 8px; height: 8px; background: #22C55E; border-radius: 50%;
        box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.25); animation: pulseDot 2s infinite;
    }
    @keyframes pulseDot {
        0%, 100% { opacity: 1; transform: scale(1); }
        50% { opacity: 0.5; transform: scale(1.15); }
    }
    .btn-refresh-telemetry {
        background: var(--al-card); border: 1px solid var(--al-border); color: var(--al-text-sub);
        font-size: 13px; font-weight: 600; padding: 7px 16px; border-radius: 8px;
        display: inline-flex; align-items: center; gap: 6px; cursor: pointer; transition: all 0.15s ease;
    }
    .btn-refresh-telemetry:hover {
        border-color: var(--al-primary); color: var(--al-primary); background: var(--al-surface2);
    }

    /* KPI Metrics Cards (4 Columns) */
    .kpi-metric-row {
        display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px; margin-bottom: 24px;
    }
    .kpi-metric-card {
        background: var(--al-card); border: 1px solid var(--al-border); border-radius: 14px; padding: 20px 22px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03); display: flex; align-items: center; justify-content: space-between;
        transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease, background 0.2s ease;
    }
    .kpi-metric-card:hover {
        transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,0,0,0.08); border-color: var(--al-border-hover);
    }
    .kpi-metric-card .kpi-label {
        font-size: 12px; font-weight: 700; color: var(--al-muted); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 6px;
    }
    .kpi-metric-card .kpi-value {
        font-size: 26px; font-weight: 800; line-height: 1; margin-bottom: 4px;
    }
    .kpi-metric-card .kpi-hint {
        font-size: 12px; color: var(--al-muted); display: flex; align-items: center; gap: 4px;
    }
    .kpi-metric-icon {
        width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center;
        font-size: 24px; flex-shrink: 0;
    }
    .kpi-metric-icon.emerald { background: var(--al-kpi-emerald-bg); color: var(--al-kpi-emerald-fg); }
    .kpi-metric-icon.blue    { background: var(--al-kpi-blue-bg);    color: var(--al-kpi-blue-fg); }
    .kpi-metric-icon.red     { background: var(--al-kpi-red-bg);     color: var(--al-kpi-red-fg); }
    .kpi-metric-icon.orange  { background: var(--al-kpi-orange-bg);  color: var(--al-kpi-orange-fg); }

    /* Main Table Card (Matches shipments.jsp card-panel style) */
    .audit-table-card {
        background: var(--al-card); border: 1px solid var(--al-border); border-radius: 16px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04); overflow: hidden;
        transition: background 0.2s ease, border-color 0.2s ease;
    }

    /* Filter Toolbar */
    .audit-filter-toolbar {
        padding: 18px 24px; border-bottom: 1px solid var(--al-border); background: var(--al-surface);
        display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 14px;
        transition: background 0.2s ease, border-color 0.2s ease;
    }
    .audit-search-box {
        position: relative; flex: 1; min-width: 260px; max-width: 380px;
    }
    .audit-search-box input {
        width: 100%; height: 40px; padding: 0 14px 0 38px; font-size: 13.5px;
        border: 1.5px solid var(--al-border); border-radius: 30px; background: var(--al-card);
        color: var(--al-text); outline: none; transition: all 0.2s ease;
    }
    .audit-search-box input::placeholder {
        color: var(--al-muted);
    }
    .audit-search-box input:focus {
        border-color: var(--al-primary); box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.15);
    }
    .audit-search-box i {
        position: absolute; left: 14px; top: 12px; font-size: 16px; color: var(--al-muted); pointer-events: none;
    }

    /* Filter Pills Group */
    .filter-pills-group {
        display: flex; align-items: center; gap: 8px; flex-wrap: wrap;
    }
    .filter-pill-btn {
        padding: 7px 15px; font-size: 13px; font-weight: 600; border-radius: 30px;
        text-decoration: none; border: 1.5px solid var(--al-border); background: var(--al-card); color: var(--al-muted);
        transition: all 0.2s ease; display: inline-flex; align-items: center; gap: 7px; cursor: pointer;
    }
    .filter-pill-btn:hover {
        border-color: var(--al-border-hover); background: var(--al-surface2); color: var(--al-text);
    }
    .filter-pill-btn.active {
        background: var(--al-primary-light) !important;
        border-color: var(--al-primary) !important;
        color: var(--al-primary) !important;
        font-weight: 700;
        box-shadow: 0 2px 8px rgba(252, 128, 25, 0.22);
    }
    [data-theme="dark"] .filter-pill-btn.active {
        background: rgba(252, 128, 25, 0.18) !important;
        color: #FB923C !important;
    }
    .filter-pill-btn .count {
        background: var(--al-surface2); color: var(--al-muted); font-size: 11px; padding: 2px 7px; border-radius: 10px; font-weight: 700;
        transition: all 0.2s ease;
    }
    .filter-pill-btn.active .count {
        background: var(--al-primary) !important;
        color: #FFFFFF !important;
    }

    /* Table Styling (Matched to shipments.jsp) */
    .audit-table {
        width: 100%; margin: 0; border-collapse: separate; border-spacing: 0;
    }
    .audit-table thead th {
        background: var(--al-table-head); font-size: 12px; font-weight: 700; text-transform: uppercase;
        color: var(--al-muted); letter-spacing: 0.5px; padding: 14px 20px; border-bottom: 1px solid var(--al-border);
        white-space: nowrap; transition: background 0.2s ease, border-color 0.2s ease;
    }
    .audit-table tbody tr {
        transition: background 0.15s ease;
    }
    .audit-table tbody tr:hover {
        background: var(--al-table-hover);
    }
    .audit-table tbody td {
        padding: 16px 20px; vertical-align: middle; font-size: 13.5px; color: var(--al-text);
        border-bottom: 1px solid var(--al-border); transition: border-color 0.2s ease;
    }

    /* Decision Event Badges */
    .event-badge {
        display: inline-flex; align-items: center; gap: 6px; padding: 5px 12px;
        border-radius: 20px; font-size: 12px; font-weight: 700; letter-spacing: 0.2px; text-transform: uppercase;
    }
    .event-badge.approved   { background: var(--al-badge-success-bg); border: 1px solid var(--al-badge-success-bd); color: var(--al-badge-success-fg); }
    .event-badge.rejected   { background: var(--al-badge-failed-bg);  border: 1px solid var(--al-badge-failed-bd);  color: var(--al-badge-failed-fg); }
    .event-badge.unlocked   { background: var(--al-badge-logout-bg);  border: 1px solid var(--al-badge-logout-bd);  color: var(--al-badge-logout-fg); }
    .event-badge.changed    { background: var(--al-badge-reset-bg);   border: 1px solid var(--al-badge-reset-bd);   color: var(--al-badge-reset-fg); }
    .event-badge.generic    { background: var(--al-badge-generic-bg); border: 1px solid var(--al-badge-generic-bd); color: var(--al-badge-generic-fg); }

    .entity-type-pill {
        display: inline-flex; align-items: center; gap: 4px; padding: 3px 8px; font-size: 11px; font-weight: 700;
        border-radius: 6px; text-transform: uppercase; letter-spacing: 0.4px;
    }
    .entity-type-pill.company  { background: var(--al-kpi-blue-bg); color: var(--al-kpi-blue-fg); border: 1px solid rgba(37,99,235,0.2); }
    .entity-type-pill.user     { background: var(--al-kpi-orange-bg); color: var(--al-kpi-orange-fg); border: 1px solid rgba(252,128,25,0.2); }
    .entity-type-pill.generic  { background: var(--al-surface2); color: var(--al-text-sub); border: 1px solid var(--al-border); }

    .role-badge-pill {
        display: inline-flex; align-items: center; padding: 4px 10px; font-size: 11.5px; font-weight: 600;
        border-radius: 6px; background: var(--al-surface2); color: var(--al-text-sub); border: 1px solid var(--al-border);
    }

    .user-avatar-initial {
        width: 34px; height: 34px; border-radius: 50%; background: #FC8019; color: #FFFFFF;
        display: inline-flex; align-items: center; justify-content: center; font-weight: 700; font-size: 13px;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25); flex-shrink: 0;
    }
    .user-info-box {
        display: flex; align-items: center; gap: 10px;
    }
    .user-name-title {
        font-weight: 700; color: var(--al-text); line-height: 1.2;
    }
    .user-email-sub {
        font-size: 12px; color: var(--al-muted);
    }

    .btn-forensic-details {
        background: var(--al-card); border: 1px solid var(--al-border); color: var(--al-text-sub);
        border-radius: 8px; font-size: 12px; font-weight: 600; padding: 6px 12px;
        display: inline-flex; align-items: center; gap: 5px; cursor: pointer; transition: all 0.15s ease;
    }
    .btn-forensic-details:hover {
        border-color: var(--al-primary); color: var(--al-primary); background: var(--al-surface2);
    }

    /* Enterprise Pagination Styling (Matched to shipments.jsp) */
    .nl-pagination-wrapper {
        display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 14px;
        padding: 16px 24px; border-top: 1px solid var(--al-border); background: var(--al-surface);
        transition: background 0.2s ease, border-color 0.2s ease;
    }
    .nl-pagination-info {
        font-size: 13px; color: var(--al-muted); display: flex; align-items: center; gap: 16px; flex-wrap: wrap;
    }
    .nl-pagination-info strong {
        color: var(--al-text);
    }
    .nl-page-size-select {
        height: 32px; padding: 0 10px; font-size: 12.5px; border-radius: 8px; border: 1px solid var(--al-border);
        background: var(--al-card); color: var(--al-text); font-weight: 600; outline: none; cursor: pointer;
    }
    .nl-pagination-nav {
        display: flex; align-items: center; gap: 6px;
    }
    .nl-page-btn {
        min-width: 34px; height: 34px; padding: 0 10px; border-radius: 8px; border: 1px solid var(--al-border);
        background: var(--al-card); color: var(--al-muted); font-size: 13px; font-weight: 600; display: inline-flex;
        align-items: center; justify-content: center; cursor: pointer; transition: all 0.15s ease;
    }
    .nl-page-btn:hover:not(.disabled) {
        border-color: var(--al-border-hover); background: var(--al-surface2); color: var(--al-text);
    }
    .nl-page-btn.active {
        background: var(--al-primary) !important; border-color: var(--al-primary) !important; color: #FFFFFF !important;
        font-weight: 700; box-shadow: 0 2px 8px rgba(252, 128, 25, 0.3);
    }
    .nl-page-btn.disabled {
        opacity: 0.45; cursor: not-allowed; background: var(--al-surface2); border-color: var(--al-border);
    }

    /* Modal Styling */
    .modal-dialog .modal-content {
        background: var(--al-card) !important; border: 1px solid var(--al-border) !important;
        border-radius: 16px; overflow: hidden; box-shadow: 0 20px 50px rgba(0,0,0,0.3);
        color: var(--al-text);
    }
    .modal-forensic-header {
        background: var(--al-modal-header); color: #FFFFFF; padding: 20px 24px; border-bottom: 1px solid var(--al-border);
    }
    .modal-forensic-body {
        padding: 24px; background: var(--al-card);
    }
    .forensic-kv-grid {
        display: grid; grid-template-columns: 140px 1fr; gap: 12px 20px; font-size: 13.5px;
    }
    .forensic-kv-label {
        font-weight: 600; color: var(--al-muted);
    }
    .forensic-kv-value {
        color: var(--al-text); font-weight: 500; word-break: break-all;
    }
    .forensic-info-box {
        padding: 12px 16px; border-radius: 10px; font-size: 12px;
        background: var(--al-surface2) !important; border: 1px solid var(--al-border) !important;
        color: var(--al-muted) !important;
    }
    .modal-footer-custom {
        border-top: 1px solid var(--al-border); padding: 14px 24px; background: var(--al-surface);
        display: flex; justify-content: flex-end;
    }
    .btn-modal-close {
        background: var(--al-surface2); border: 1px solid var(--al-border); color: var(--al-text);
        border-radius: 8px; padding: 7px 18px; font-size: 13px; font-weight: 600; cursor: pointer;
        transition: all 0.15s ease;
    }
    .btn-modal-close:hover {
        background: var(--al-border); color: var(--al-text);
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
        <span class="current">Approvals</span>
    </div>

    <!-- Header Telemetry Card -->
    <div class="telemetry-header-card">
        <div class="telemetry-title-group">
            <h1>
                <i class="ti ti-checkup-list" style="color: #FC8019;"></i>
                Approvals &amp; Governance Decisions Audit
            </h1>
            <p>Complete tamper-evident trail of company onboarding approvals, user activations, deactivations, account unlocks, and suspension actions.</p>
        </div>
        <div class="d-flex align-items-center gap-3">
            <div class="live-monitor-pill">
                <span class="live-dot"></span>
                <span>Active Decision Telemetry</span>
            </div>
            <button class="btn-refresh-telemetry" onclick="window.location.reload();" title="Refresh Live Data">
                <i class="ti ti-refresh"></i> Refresh
            </button>
        </div>
    </div>

    <!-- KPI Metrics Row (4 Cards) -->
    <div class="kpi-metric-row">
        <!-- 1. Total Approvals -->
        <div class="kpi-metric-card" onclick="selectFilterTab('APPROVED')" style="cursor: pointer;" title="Filter by Approvals">
            <div>
                <div class="kpi-label">Total Approved</div>
                <div class="kpi-value text-success">${kpis.totalApprovals}</div>
                <div class="kpi-hint"><i class="ti ti-circle-check"></i> Companies &amp; users approved</div>
            </div>
            <div class="kpi-metric-icon emerald">
                <i class="ti ti-checkup-list"></i>
            </div>
        </div>

        <!-- 2. Companies Approved -->
        <div class="kpi-metric-card" onclick="selectFilterTab('COMPANIES')" style="cursor: pointer;" title="Filter by Companies">
            <div>
                <div class="kpi-label">Companies Approved</div>
                <div class="kpi-value text-primary">${kpis.companiesApproved}</div>
                <div class="kpi-hint"><i class="ti ti-building"></i> Partner tenants onboarded</div>
            </div>
            <div class="kpi-metric-icon blue">
                <i class="ti ti-building-check"></i>
            </div>
        </div>

        <!-- 3. Users Approved -->
        <div class="kpi-metric-card" onclick="selectFilterTab('USERS')" style="cursor: pointer;" title="Filter by Users">
            <div>
                <div class="kpi-label">Users Approved</div>
                <div class="kpi-value" style="color: #FC8019;">${kpis.usersApproved}</div>
                <div class="kpi-hint"><i class="ti ti-user-check"></i> Verified customer &amp; staff logins</div>
            </div>
            <div class="kpi-metric-icon orange">
                <i class="ti ti-users"></i>
            </div>
        </div>

        <!-- 4. Rejections & Suspensions -->
        <div class="kpi-metric-card" onclick="selectFilterTab('REJECTIONS')" style="cursor: pointer;" title="Filter by Rejections">
            <div>
                <div class="kpi-label">Suspensions &amp; Rejections</div>
                <div class="kpi-value text-danger">${kpis.totalRejections}</div>
                <div class="kpi-hint"><i class="ti ti-ban"></i> Suspended &amp; deactivated</div>
            </div>
            <div class="kpi-metric-icon red">
                <i class="ti ti-shield-x"></i>
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
                    All Decisions <span class="count">${kpis.totalLogs}</span>
                </button>
                <button type="button" class="filter-pill-btn" data-action="COMPANIES" onclick="selectFilterTab('COMPANIES')">
                    <i class="ti ti-building text-primary"></i> Company Approvals <span class="count">${kpis.companiesApproved}</span>
                </button>
                <button type="button" class="filter-pill-btn" data-action="USERS" onclick="selectFilterTab('USERS')">
                    <i class="ti ti-users" style="color: #FC8019;"></i> User Approvals <span class="count">${kpis.usersApproved}</span>
                </button>
                <button type="button" class="filter-pill-btn" data-action="REJECTIONS" onclick="selectFilterTab('REJECTIONS')">
                    <i class="ti ti-alert-circle text-danger"></i> Suspensions &amp; Rejections <span class="count">${kpis.totalRejections}</span>
                </button>
            </div>

            <!-- Instant Search Input -->
            <div class="audit-search-box">
                <i class="ti ti-search"></i>
                <input type="text" id="auditSearchInput" placeholder="Search entity, approver, reason..." onkeyup="onSearchInput()">
            </div>
        </div>

        <!-- Table Container -->
        <div class="table-responsive">
            <table class="audit-table" id="auditTable">
                <thead>
                    <tr>
                        <th>Log ID</th>
                        <th>Decision Timestamp</th>
                        <th>Approver Admin</th>
                        <th>Admin Role</th>
                        <th>Decision Action</th>
                        <th>Target Entity Context</th>
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
                                    data-entity="${log.entityName}"
                                    data-entitytype="${log.entityType}"
                                    data-old="${log.oldValue}"
                                    data-new="${log.newValue}"
                                    data-search="${log.logId} ${log.username} ${log.email} ${log.action} ${log.entityName} ${log.entityType} ${log.oldValue} ${log.newValue}">
                                    <td>
                                        <span style="font-weight: 700; color: var(--al-muted);">#LOG-${log.logId}</span>
                                    </td>
                                    <td>
                                        <div style="font-weight: 600; color: var(--al-text);">
                                            <fmt:formatDate value="${log.timestamp}" pattern="yyyy-MM-dd HH:mm:ss" />
                                        </div>
                                        <div style="font-size: 11.5px; color: var(--al-muted);">
                                            <i class="ti ti-clock"></i> Local Time
                                        </div>
                                    </td>
                                    <td>
                                        <div class="user-info-box">
                                            <div class="user-avatar-initial">
                                                ${log.username != null && log.username.length() > 0 ? log.username.substring(0, 1).toUpperCase() : 'A'}
                                            </div>
                                            <div>
                                                <div class="user-name-title">${log.username}</div>
                                                <div class="user-email-sub">${log.email}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="role-badge-pill">
                                            ${log.roleName}
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${log.action == 'APPROVE_COMPANY'}">
                                                <span class="event-badge approved">
                                                    <i class="ti ti-building-check"></i> COMPANY APPROVED
                                                </span>
                                            </c:when>
                                            <c:when test="${log.action == 'APPROVE_USER'}">
                                                <span class="event-badge approved">
                                                    <i class="ti ti-user-check"></i> USER APPROVED
                                                </span>
                                            </c:when>
                                            <c:when test="${log.action == 'SUSPEND_COMPANY'}">
                                                <span class="event-badge rejected">
                                                    <i class="ti ti-building-community"></i> COMPANY SUSPENDED
                                                </span>
                                            </c:when>
                                            <c:when test="${log.action == 'DEACTIVATE_USER'}">
                                                <span class="event-badge rejected">
                                                    <i class="ti ti-user-off"></i> USER DEACTIVATED
                                                </span>
                                            </c:when>
                                            <c:when test="${log.action == 'UNLOCK_USER'}">
                                                <span class="event-badge unlocked">
                                                    <i class="ti ti-lock-open"></i> USER UNLOCKED
                                                </span>
                                            </c:when>
                                            <c:when test="${log.action == 'STATUS_CHANGE'}">
                                                <span class="event-badge changed">
                                                    <i class="ti ti-refresh"></i> STATUS CHANGE
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="event-badge generic">
                                                    <i class="ti ti-activity"></i> ${log.action}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2 mb-1">
                                            <span class="entity-type-pill ${log.entityType == 'Company' ? 'company' : (log.entityType == 'Customer / User' ? 'user' : 'generic')}">
                                                ${log.entityType}
                                            </span>
                                            <span style="font-weight: 700; color: var(--al-text); font-size: 13.5px;">
                                                ${log.entityName != null && !log.entityName.isEmpty() ? log.entityName : 'Target #' += log.entityId}
                                            </span>
                                            <c:if test="${log.entityId > 0}">
                                                <span style="font-size: 11.5px; color: var(--al-muted);">(#${log.entityId})</span>
                                            </c:if>
                                        </div>
                                        <c:if test="${not empty log.oldValue or not empty log.newValue}">
                                            <div style="font-size: 12px; color: var(--al-muted);">
                                                <c:if test="${not empty log.oldValue}">
                                                    <span style="text-decoration: line-through; opacity: 0.75;">${log.oldValue}</span>
                                                    <i class="ti ti-arrow-right mx-1" style="font-size: 10px;"></i>
                                                </c:if>
                                                <span style="font-weight: 600; color: ${log.action.contains('APPROVE') ? '#059669' : (log.action.contains('SUSPEND') || log.action.contains('DEACTIVAT') ? '#DC2626' : 'var(--al-primary)')};">
                                                    ${log.newValue}
                                                </span>
                                            </div>
                                        </c:if>
                                    </td>
                                    <td style="text-align: right;">
                                        <button class="btn-forensic-details" 
                                                onclick="openForensicModal('${log.logId}', '${log.username}', '${log.action}', '${log.entityName}', '${log.entityType}', '${log.oldValue}', '${log.newValue}', '<fmt:formatDate value="${log.timestamp}" pattern="yyyy-MM-dd HH:mm:ss" />', '${log.roleName}')"
                                                title="View Decision Forensics">
                                            <i class="ti ti-eye"></i> Details
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr id="serverEmptyRow">
                                <td colspan="7" style="text-align: center; padding: 48px 20px;">
                                    <div style="font-size: 40px; color: var(--al-border-hover); margin-bottom: 12px;">
                                        <i class="ti ti-checkup-list"></i>
                                    </div>
                                    <h5 style="font-weight: 700; color: var(--al-text); margin-bottom: 6px;">No Approval Audit Logs Found</h5>
                                    <p style="color: var(--al-muted); font-size: 13.5px; margin: 0;">No matching approval, rejection or suspension records found in the database.</p>
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
                    <span style="color: var(--al-muted); font-size: 12.5px;">Rows per page:</span>
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
                    <h5 class="modal-title" id="modalForensicTitle" style="font-size: 16px; font-weight: 700; margin: 0;">Decision Audit #LOG-</h5>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-forensic-body">
                <div class="forensic-kv-grid mb-4">
                    <div class="forensic-kv-label">Approver Admin:</div>
                    <div class="forensic-kv-value" id="modalUser">-</div>

                    <div class="forensic-kv-label">Admin Role:</div>
                    <div class="forensic-kv-value" id="modalRole">-</div>

                    <div class="forensic-kv-label">Decision Action:</div>
                    <div class="forensic-kv-value" id="modalAction">-</div>

                    <div class="forensic-kv-label">Target Entity:</div>
                    <div class="forensic-kv-value" id="modalEntity">-</div>

                    <div class="forensic-kv-label">Previous State:</div>
                    <div class="forensic-kv-value" id="modalOldVal">-</div>

                    <div class="forensic-kv-label">New State / Note:</div>
                    <div class="forensic-kv-value" id="modalNewVal">-</div>

                    <div class="forensic-kv-label">Timestamp:</div>
                    <div class="forensic-kv-value" id="modalTime">-</div>

                    <div class="forensic-kv-label">Integrity Status:</div>
                    <div class="forensic-kv-value" style="color: #059669; font-weight: 700;">Verified Database Entry</div>
                </div>

                <div class="forensic-info-box">
                    <i class="ti ti-info-circle" style="color: var(--al-primary);"></i>
                    This record represents an immutable governance decision recorded by NLogistic stored procedures &amp; administrative handlers during runtime.
                </div>
            </div>
            <div class="modal-footer-custom">
                <button type="button" class="btn-modal-close" data-bs-dismiss="modal">Close</button>
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
    function selectFilterTab(filter) {
        currentFilterTab = filter;
        currentPage = 1;

        // Update Tab Pill UI (Orange active state)
        document.querySelectorAll('#filterPillsGroup .filter-pill-btn').forEach(btn => {
            if (btn.getAttribute('data-action') === filter) {
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
            const action = (row.getAttribute('data-action') || '').toUpperCase();
            const entityType = (row.getAttribute('data-entitytype') || '').toUpperCase();
            const searchData = (row.getAttribute('data-search') || '').toLowerCase();

            // 1. Tab Action Matching
            let matchesTab = false;
            if (currentFilterTab === 'ALL') {
                matchesTab = true;
            } else if (currentFilterTab === 'COMPANIES') {
                matchesTab = action.includes('COMPANY');
            } else if (currentFilterTab === 'USERS') {
                matchesTab = action.includes('USER') || action.includes('CUSTOMER');
            } else if (currentFilterTab === 'APPROVED') {
                matchesTab = action.includes('APPROVE');
            } else if (currentFilterTab === 'REJECTIONS') {
                matchesTab = action.includes('SUSPEND') || action.includes('REJECT') || action.includes('DEACTIVAT');
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
    function openForensicModal(logId, user, action, entity, entityType, oldVal, newVal, time, role) {
        document.getElementById('modalForensicTitle').textContent = 'Decision Audit #LOG-' + logId;
        document.getElementById('modalUser').textContent = user || 'Administrator';
        document.getElementById('modalRole').textContent = role || 'Super Admin';
        document.getElementById('modalAction').textContent = action;
        document.getElementById('modalEntity').textContent = (entity || '-') + (entityType ? ' (' + entityType + ')' : '');
        document.getElementById('modalOldVal').textContent = oldVal || '—';
        document.getElementById('modalNewVal').textContent = newVal || '—';
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
