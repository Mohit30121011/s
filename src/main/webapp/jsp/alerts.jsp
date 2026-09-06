<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="layout/header.jsp" %>

<style>
    /* ══════════════════════════════════════════
       ALERTS PAGE — DESIGN TOKENS
    ══════════════════════════════════════════ */
    :root {
        --al-primary:        #FC8019;
        --al-primary-hover:  #e57315;
        --al-primary-light:  #FFF7ED;
        --al-primary-border: #FFEDD5;

        --al-border:   #E2E8F0;
        --al-text:     #0F172A;
        --al-muted:    #64748B;
        --al-card:     #FFFFFF;
        --al-hover:    #F8FAFC;
        --al-surface:  #F1F5F9;
        --al-surface2: #E2E8F0;

        --al-danger-bg:  #FEF2F2; --al-danger-text:  #DC2626; --al-danger-bd:  #FECACA;
        --al-warning-bg: #FFFBEB; --al-warning-text: #D97706; --al-warning-bd: #FDE68A;
        --al-info-bg:    #EFF6FF; --al-info-text:    #2563EB; --al-info-bd:    #BFDBFE;
        --al-success-bg: #ECFDF5; --al-success-text: #059669; --al-success-bd: #A7F3D0;
        --al-amber-bg:   #FFFBEB; --al-amber-text:   #D97706; --al-amber-bd:   #FDE68A;

        --al-compliance-bg:   #FEF3C7; --al-compliance-text:  #92400E;
        --al-billing-bg:      #FEE2E2; --al-billing-text:     #991B1B;
        --al-claims-bg:       #DBEAFE; --al-claims-text:      #1E40AF;
        --al-general-bg:      #F1F5F9; --al-general-text:     #475569;

        --al-sev-danger-bg:  #FEE2E2; --al-sev-danger-text:  #991B1B;
        --al-sev-warning-bg: #FEF3C7; --al-sev-warning-text: #92400E;
        --al-sev-info-bg:    #EFF6FF; --al-sev-info-text:    #1E40AF;
    }

    [data-theme="dark"] {
        --al-primary-light:  rgba(252,128,25,0.14);
        --al-primary-border: rgba(252,128,25,0.28);

        --al-border:   #22303A;
        --al-text:     #F8FAFC;
        --al-muted:    #94A3B8;
        --al-card:     #101820;
        --al-hover:    #182430;
        --al-surface:  #151F28;
        --al-surface2: #1C2A37;

        --al-danger-bg:  rgba(239,68,68,0.14);  --al-danger-text:  #F87171; --al-danger-bd:  rgba(239,68,68,0.25);
        --al-warning-bg: rgba(245,158,11,0.14); --al-warning-text: #FBBF24; --al-warning-bd: rgba(245,158,11,0.25);
        --al-info-bg:    rgba(59,130,246,0.14); --al-info-text:    #60A5FA; --al-info-bd:    rgba(59,130,246,0.25);
        --al-success-bg: rgba(16,185,129,0.14); --al-success-text: #34D399; --al-success-bd: rgba(16,185,129,0.25);
        --al-amber-bg:   rgba(245,158,11,0.14); --al-amber-text:   #FBBF24; --al-amber-bd:   rgba(245,158,11,0.25);

        --al-compliance-bg:  rgba(245,158,11,0.15); --al-compliance-text: #FBBF24;
        --al-billing-bg:     rgba(239,68,68,0.15);  --al-billing-text:    #F87171;
        --al-claims-bg:      rgba(59,130,246,0.15); --al-claims-text:     #60A5FA;
        --al-general-bg:     #1C2A37;               --al-general-text:    #94A3B8;

        --al-sev-danger-bg:  rgba(239,68,68,0.15);  --al-sev-danger-text:  #F87171;
        --al-sev-warning-bg: rgba(245,158,11,0.15); --al-sev-warning-text: #FBBF24;
        --al-sev-info-bg:    rgba(59,130,246,0.15); --al-sev-info-text:    #60A5FA;
    }

    /* ══ Layout ══ */
    .alerts-container {
        padding: 24px 32px 48px;
        max-width: 1400px;
        margin: 0 auto;
    }

    /* ══ Page Header ══ */
    .alerts-page-header {
        display: flex; align-items: center; justify-content: space-between;
        flex-wrap: wrap; gap: 16px; margin-bottom: 24px;
    }
    .alerts-header-left { display: flex; flex-direction: column; gap: 4px; }
    .alerts-breadcrumb {
        display: flex; align-items: center; gap: 8px;
        font-size: 12.5px; color: var(--al-muted); font-weight: 500;
    }
    .alerts-breadcrumb a { color: var(--al-muted); text-decoration: none; transition: color 0.15s; }
    .alerts-breadcrumb a:hover { color: var(--al-primary); }

    .alerts-page-title {
        font-size: 24px; font-weight: 700; color: var(--al-text);
        letter-spacing: -0.02em; margin: 0; display: flex; align-items: center; gap: 10px;
    }
    .alerts-page-title .title-badge {
        font-size: 13px; font-weight: 700;
        background: var(--al-primary-light);
        color: var(--al-primary);
        border: 1px solid var(--al-primary-border);
        padding: 3px 10px; border-radius: 20px; transition: all 0.2s ease;
    }
    .alerts-page-desc { font-size: 13.5px; color: var(--al-muted); margin: 0; }
    .alerts-header-actions { display: flex; align-items: center; gap: 10px; }

    /* ══ Header Buttons ══ */
    .btn-alert-action {
        display: inline-flex; align-items: center; gap: 6px;
        font-size: 13px; font-weight: 600; padding: 8px 16px;
        border-radius: 8px; cursor: pointer; text-decoration: none;
        transition: all 0.18s ease; border: none;
    }
    .btn-alert-primary { background: var(--al-primary); color: #FFFFFF; }
    .btn-alert-primary:hover {
        background: var(--al-primary-hover); color: #FFFFFF;
        transform: translateY(-1px); box-shadow: 0 4px 12px rgba(252,128,25,0.25);
    }
    .btn-alert-outline {
        background: var(--al-card); color: var(--al-muted);
        border: 1px solid var(--al-border);
    }
    .btn-alert-outline:hover {
        background: var(--al-hover); border-color: var(--al-border);
        color: var(--al-text);
    }

    /* ══ Animations ══ */
    @keyframes spinRefresh { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
    .spin-anim { animation: spinRefresh 0.8s linear infinite; display: inline-block; }
    @keyframes feedPulse {
        0% { opacity: 0.5; transform: scale(0.998); }
        100% { opacity: 1; transform: scale(1); }
    }
    .feed-refreshed { animation: feedPulse 0.35s ease; }
    @keyframes alertSlideIn {
        from { opacity: 0; transform: translateY(-12px); }
        to   { opacity: 1; transform: translateY(0); }
    }
    .alert-newly-arrived { animation: alertSlideIn 0.35s cubic-bezier(0.16,1,0.3,1) forwards; }

    /* ══ KPI Grid ══ */
    .alerts-kpi-grid {
        display: grid; grid-template-columns: repeat(4,1fr); gap: 18px; margin-bottom: 24px;
    }
    .alert-kpi-card {
        background: var(--al-card); border: 1px solid var(--al-border); border-radius: 12px;
        padding: 18px 20px; display: flex; align-items: center; gap: 16px;
        transition: all 0.2s ease; box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        cursor: pointer; user-select: none;
    }
    .alert-kpi-card:hover {
        transform: translateY(-2px); border-color: var(--al-primary-border);
        box-shadow: 0 8px 20px -4px rgba(252,128,25,0.14);
    }
    .kpi-icon-box {
        width: 48px; height: 48px; border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
        font-size: 22px; flex-shrink: 0; border: 1px solid transparent;
    }
    .kpi-icon-box.orange { background: var(--al-primary-light); color: var(--al-primary); border-color: var(--al-primary-border); }
    .kpi-icon-box.red    { background: var(--al-danger-bg);  color: var(--al-danger-text);  border-color: var(--al-danger-bd); }
    .kpi-icon-box.amber  { background: var(--al-amber-bg);   color: var(--al-amber-text);   border-color: var(--al-amber-bd); }
    .kpi-icon-box.blue   { background: var(--al-info-bg);    color: var(--al-info-text);    border-color: var(--al-info-bd); }

    .kpi-data { display: flex; flex-direction: column; }
    .kpi-num  { font-size: 22px; font-weight: 700; color: var(--al-text); line-height: 1.2; }
    .kpi-title { font-size: 13px; font-weight: 600; color: var(--al-muted); margin-top: 2px; }
    .kpi-sub   { font-size: 11.5px; color: var(--al-muted); margin-top: 1px; }

    /* ══ Filter Toolbar ══ */
    .alerts-toolbar-card {
        background: var(--al-card); border: 1px solid var(--al-border); border-radius: 12px;
        padding: 14px 18px; margin-bottom: 20px; display: flex; align-items: center;
        justify-content: space-between; flex-wrap: wrap; gap: 14px;
    }
    .alerts-tabs-group { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }

    .alert-tab-btn {
        padding: 7px 14px; font-size: 13px; font-weight: 600; border-radius: 8px;
        border: 1px solid var(--al-border);
        background: var(--al-surface); color: var(--al-muted);
        cursor: pointer; display: flex; align-items: center; gap: 6px;
        transition: all 0.15s ease;
    }
    .alert-tab-btn:hover { background: var(--al-surface2); color: var(--al-text); }
    .alert-tab-btn.active {
        background: var(--al-primary); color: #FFFFFF; border-color: var(--al-primary);
        box-shadow: 0 2px 6px rgba(252,128,25,0.28);
    }
    .alert-tab-btn .tab-count {
        font-size: 11px; font-weight: 700; background: rgba(255,255,255,0.25);
        color: inherit; padding: 1px 6px; border-radius: 10px;
    }
    .alert-tab-btn:not(.active) .tab-count { background: var(--al-surface2); color: var(--al-muted); }

    /* ══ Search Box ══ */
    .alerts-search-box { position: relative; width: 320px; }
    .alerts-search-box input {
        width: 100%; height: 38px; padding: 8px 12px 8px 36px;
        font-size: 13px; border: 1px solid var(--al-border); border-radius: 8px;
        outline: none; transition: all 0.15s ease;
        background: var(--al-hover); color: var(--al-text);
    }
    .alerts-search-box input::placeholder { color: var(--al-muted); }
    .alerts-search-box input:focus {
        background: var(--al-card); border-color: var(--al-primary);
        box-shadow: 0 0 0 3px rgba(252,128,25,0.12);
    }
    .alerts-search-box i {
        position: absolute; left: 11px; top: 50%; transform: translateY(-50%);
        color: var(--al-muted); font-size: 16px; pointer-events: none;
    }

    /* ══ Feed List ══ */
    .alerts-feed { display: flex; flex-direction: column; gap: 12px; }
    .alert-feed-item {
        background: var(--al-card); border: 1px solid var(--al-border); border-radius: 12px;
        padding: 16px 20px; display: flex; align-items: flex-start; gap: 16px;
        transition: transform 0.25s ease, opacity 0.25s ease, box-shadow 0.2s ease;
        position: relative; overflow: hidden;
    }
    .alert-feed-item:hover {
        background: var(--al-hover); border-color: var(--al-border);
        box-shadow: 0 4px 14px rgba(0,0,0,0.08); transform: translateY(-1px);
    }

    /* Left accent strip */
    .alert-feed-item::before {
        content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 4px;
    }
    .alert-feed-item.danger::before  { background: #EF4444; }
    .alert-feed-item.warning::before { background: #F59E0B; }
    .alert-feed-item.info::before    { background: #3B82F6; }
    .alert-feed-item.success::before { background: #10B981; }

    /* ══ Alert Icon Box ══ */
    .alert-item-icon-box {
        width: 42px; height: 42px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center;
        font-size: 20px; flex-shrink: 0; margin-top: 2px; border: 1px solid transparent;
    }
    .alert-item-icon-box.danger  { background: var(--al-danger-bg);  color: var(--al-danger-text);  border-color: var(--al-danger-bd); }
    .alert-item-icon-box.warning { background: var(--al-warning-bg); color: var(--al-warning-text); border-color: var(--al-warning-bd); }
    .alert-item-icon-box.info    { background: var(--al-info-bg);    color: var(--al-info-text);    border-color: var(--al-info-bd); }
    .alert-item-icon-box.success { background: var(--al-success-bg); color: var(--al-success-text); border-color: var(--al-success-bd); }

    /* ══ Alert Content ══ */
    .alert-item-content { flex: 1; min-width: 0; }
    .alert-item-meta-row { display: flex; align-items: center; gap: 8px; margin-bottom: 4px; flex-wrap: wrap; }

    .alert-category-badge {
        font-size: 11px; font-weight: 700; text-transform: uppercase;
        letter-spacing: 0.04em; padding: 2px 8px; border-radius: 6px;
    }
    .alert-category-badge.compliance { background: var(--al-compliance-bg); color: var(--al-compliance-text); }
    .alert-category-badge.billing,
    .alert-category-badge.finance    { background: var(--al-billing-bg);    color: var(--al-billing-text); }
    .alert-category-badge.claims     { background: var(--al-claims-bg);     color: var(--al-claims-text); }
    .alert-category-badge.general    { background: var(--al-general-bg);    color: var(--al-general-text); }

    .alert-time-badge {
        font-size: 12px; color: var(--al-muted); font-weight: 500;
        display: inline-flex; align-items: center; gap: 4px;
    }
    .alert-severity-badge { font-size: 11px; font-weight: 700; padding: 2px 8px; border-radius: 6px; }
    .alert-severity-badge.danger  { background: var(--al-sev-danger-bg);  color: var(--al-sev-danger-text); }
    .alert-severity-badge.warning { background: var(--al-sev-warning-bg); color: var(--al-sev-warning-text); }
    .alert-severity-badge.info    { background: var(--al-sev-info-bg);    color: var(--al-sev-info-text); }

    .alert-item-title   { font-size: 15px; font-weight: 700; color: var(--al-text); margin: 2px 0 4px; line-height: 1.35; }
    .alert-item-message { font-size: 13.5px; color: var(--al-muted); line-height: 1.5; margin: 0; }

    /* ══ Action Buttons ══ */
    .alert-item-actions { display: flex; align-items: center; gap: 8px; flex-shrink: 0; margin-top: 4px; }
    .btn-action-review {
        padding: 7px 14px; font-size: 12.5px; font-weight: 600; border-radius: 7px;
        background: var(--al-primary); color: #FFFFFF; text-decoration: none;
        display: inline-flex; align-items: center; gap: 4px; transition: all 0.15s;
    }
    .btn-action-review:hover {
        background: var(--al-primary-hover); color: #FFFFFF;
        box-shadow: 0 2px 6px rgba(252,128,25,0.25);
    }
    .btn-action-dismiss {
        padding: 7px 10px; font-size: 12.5px; font-weight: 600; border-radius: 7px;
        background: var(--al-card); color: var(--al-muted);
        border: 1px solid var(--al-border); cursor: pointer;
        display: inline-flex; align-items: center; gap: 4px; transition: all 0.15s;
    }
    .btn-action-dismiss:hover {
        background: var(--al-danger-bg); color: var(--al-danger-text);
        border-color: var(--al-danger-bd);
    }

    /* ══ Empty State ══ */
    .alerts-empty-state {
        background: var(--al-card); border: 1px solid var(--al-border); border-radius: 16px;
        padding: 60px 24px; text-align: center; display: flex; flex-direction: column;
        align-items: center; justify-content: center; gap: 8px; animation: alertSlideIn 0.3s ease;
    }
    .empty-state-icon {
        width: 64px; height: 64px; border-radius: 50%;
        background: var(--al-success-bg); color: var(--al-success-text);
        display: flex; align-items: center; justify-content: center;
        font-size: 32px; margin-bottom: 8px;
    }
    .empty-state-title { font-size: 18px; font-weight: 700; color: var(--al-text); margin: 0; }
    .empty-state-desc  { font-size: 13.5px; color: var(--al-muted); max-width: 420px; line-height: 1.5; margin: 0; }

    /* ══ Responsive ══ */
    @media (max-width: 992px) { .alerts-kpi-grid { grid-template-columns: repeat(2,1fr); } }
    @media (max-width: 640px) {
        .alerts-container { padding: 16px; }
        .alerts-kpi-grid  { grid-template-columns: 1fr; }
        .alert-feed-item  { flex-direction: column; }
        .alert-item-actions { width: 100%; justify-content: flex-start; }
    }
</style>

<div class="alerts-container">
    <!-- Page Header -->
    <div class="alerts-page-header">
        <div class="alerts-header-left">
            <div class="alerts-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard"><i class="ti ti-smart-home"></i> Dashboard</a>
                <i class="ti ti-chevron-right" style="font-size:11px;"></i>
                <span>Alerts &amp; Notifications Center</span>
            </div>
            <h1 class="alerts-page-title">
                System Alerts &amp; Notifications
                <span class="title-badge" id="headerAlertCountBadge">${totalAlerts} Active</span>
            </h1>
            <p class="alerts-page-desc">
                Centralized real-time radar for compliance document expirations, overdue invoices, and supply chain claims.
            </p>
        </div>
        <div class="alerts-header-actions">
            <button type="button" class="btn-alert-action btn-alert-outline" onclick="markAllAlertsReadPage()" title="Mark all alerts as read">
                <i class="ti ti-checks"></i> Mark All as Read
            </button>
            <button type="button" class="btn-alert-action btn-alert-primary" onclick="refreshAlertsPage()" id="btnRefreshAlerts" title="Refresh notification feed">
                <i class="ti ti-refresh" id="refreshBtnIcon"></i> <span id="refreshBtnText">Refresh</span>
            </button>
        </div>
    </div>

    <!-- 4 KPI Summary Cards -->
    <div class="alerts-kpi-grid">
        <div class="alert-kpi-card" onclick="filterByTab('all')" title="Click to view all alerts">
            <div class="kpi-icon-box orange">
                <i class="ti ti-bell"></i>
            </div>
            <div class="kpi-data">
                <div class="kpi-num" id="kpiTotalAlerts">${totalAlerts}</div>
                <div class="kpi-title">Total Active Alerts</div>
                <div class="kpi-sub">Across all categories</div>
            </div>
        </div>

        <div class="alert-kpi-card" onclick="filterByTab('critical')" title="Click to filter critical alerts">
            <div class="kpi-icon-box red">
                <i class="ti ti-alert-triangle"></i>
            </div>
            <div class="kpi-data">
                <div class="kpi-num" id="kpiCritical">${criticalCount}</div>
                <div class="kpi-title">Action Required</div>
                <div class="kpi-sub">High severity warnings</div>
            </div>
        </div>

        <div class="alert-kpi-card" onclick="filterByTab('compliance')" title="Click to filter compliance alerts">
            <div class="kpi-icon-box amber">
                <i class="ti ti-file-certificate"></i>
            </div>
            <div class="kpi-data">
                <div class="kpi-num" id="kpiCompliance">${complianceCount}</div>
                <div class="kpi-title">Compliance Expirations</div>
                <div class="kpi-sub">Documents expiring soon</div>
            </div>
        </div>

        <div class="alert-kpi-card" onclick="filterByTab('billing')" title="Click to filter billing alerts">
            <div class="kpi-icon-box blue">
                <i class="ti ti-receipt-tax"></i>
            </div>
            <div class="kpi-data">
                <div class="kpi-num" id="kpiBilling">${billingCount}</div>
                <div class="kpi-title">Billing &amp; Invoices</div>
                <div class="kpi-sub">Pending balances &amp; claims</div>
            </div>
        </div>
    </div>

    <!-- Filter & Search Toolbar -->
    <div class="alerts-toolbar-card">
        <div class="alerts-tabs-group">
            <button type="button" class="alert-tab-btn active" data-tab="all" onclick="filterByTab('all')">
                <i class="ti ti-layout-grid"></i> All Alerts
                <span class="tab-count" id="tabCountAll">${totalAlerts}</span>
            </button>
            <button type="button" class="alert-tab-btn" data-tab="critical" onclick="filterByTab('critical')">
                <i class="ti ti-flame text-danger"></i> Critical
                <span class="tab-count" id="tabCountCritical">${criticalCount}</span>
            </button>
            <button type="button" class="alert-tab-btn" data-tab="compliance" onclick="filterByTab('compliance')">
                <i class="ti ti-file-check text-warning"></i> Compliance
                <span class="tab-count" id="tabCountCompliance">${complianceCount}</span>
            </button>
            <button type="button" class="alert-tab-btn" data-tab="billing" onclick="filterByTab('billing')">
                <i class="ti ti-file-invoice text-info"></i> Billing &amp; Finance
                <span class="tab-count" id="tabCountBilling">${billingCount}</span>
            </button>
            <button type="button" class="alert-tab-btn" data-tab="claims" onclick="filterByTab('claims')">
                <i class="ti ti-shield text-primary"></i> Claims
                <span class="tab-count" id="tabCountClaims">${claimsCount}</span>
            </button>
        </div>

        <div class="alerts-search-box">
            <i class="ti ti-search"></i>
            <input type="text" id="alertsSearchInput" placeholder="Filter alerts by keywords..." oninput="handleSearchAlerts()">
        </div>
    </div>

    <!-- Alerts Feed Cards -->
    <div class="alerts-feed" id="alertsFeedList">
        <c:choose>
            <c:when test="${not empty alertsList}">
                <c:forEach var="item" items="${alertsList}">
                    <div class="alert-feed-item ${item.type != null ? item.type : 'info'}"
                         data-category="${item.category != null ? item.category.toLowerCase() : 'general'}"
                         data-type="${item.type != null ? item.type.toLowerCase() : 'info'}"
                         data-id="${item.notifId}">
                        <div class="alert-item-icon-box ${item.type != null ? item.type : 'info'}">
                            <i class="${item.icon != null ? item.icon : 'ti ti-bell'}"></i>
                        </div>
                        <div class="alert-item-content">
                            <div class="alert-item-meta-row">
                                <span class="alert-category-badge ${item.category != null ? item.category.toLowerCase() : 'general'}">
                                    ${item.category != null ? item.category : 'General'}
                                </span>
                                <c:if test="${not empty item.timeAgo}">
                                    <span class="alert-time-badge">
                                        <i class="ti ti-clock" style="font-size:12px;"></i> ${item.timeAgo}
                                    </span>
                                </c:if>
                                <c:if test="${item.type == 'danger'}">
                                    <span class="alert-severity-badge danger"><i class="ti ti-alert-circle"></i> Action Required</span>
                                </c:if>
                                <c:if test="${item.type == 'warning'}">
                                    <span class="alert-severity-badge warning"><i class="ti ti-alert-triangle"></i> Warning</span>
                                </c:if>
                            </div>
                            <h3 class="alert-item-title">${item.title}</h3>
                            <p class="alert-item-message">${item.message}</p>
                        </div>
                        <div class="alert-item-actions">
                            <c:if test="${not empty item.link}">
                                <a href="${pageContext.request.contextPath}${item.link}" class="btn-action-review">
                                    Review Now <i class="ti ti-arrow-right"></i>
                                </a>
                            </c:if>
                            <button type="button" class="btn-action-dismiss" onclick="dismissSingleAlert(this, ${item.notifId})" title="Dismiss alert">
                                <i class="ti ti-check"></i> Dismiss
                            </button>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="alerts-empty-state" id="alertsMainEmptyState">
                    <div class="empty-state-icon">
                        <i class="ti ti-circle-check"></i>
                    </div>
                    <h2 class="empty-state-title">All Caught Up!</h2>
                    <p class="empty-state-desc">
                        There are no active operational alerts, pending document expirations, or overdue invoices requiring your attention right now.
                    </p>
                    <div style="margin-top:14px; display:flex; gap:10px;">
                        <a href="${pageContext.request.contextPath}/dashboard" class="btn-alert-action btn-alert-outline">
                            <i class="ti ti-smart-home"></i> Go to Dashboard
                        </a>
                        <a href="${pageContext.request.contextPath}/compliance" class="btn-alert-action btn-alert-outline">
                            <i class="ti ti-shield-check"></i> Compliance Center
                        </a>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Empty Search State (hidden by default) -->
    <div class="alerts-empty-state" id="alertsSearchEmptyState" style="display:none; margin-top:12px;">
        <div class="empty-state-icon" style="background:#F1F5F9; color:#64748B;">
            <i class="ti ti-search-off"></i>
        </div>
        <h2 class="empty-state-title">No Matching Alerts Found</h2>
        <p class="empty-state-desc">
            Try adjusting your search query or switching to another category tab.
        </p>
        <button type="button" class="btn-alert-action btn-alert-outline" onclick="resetFilters()" style="margin-top:10px;">
            <i class="ti ti-rotate-clockwise"></i> Reset Filters
        </button>
    </div>
</div>

<script>
    const ctx = '${pageContext.request.contextPath}';
    const currentUserId = '${sessionScope.user != null ? sessionScope.user.userId : ""}';
    const storageKey = 'nl_dismissed_alerts_' + currentUserId;
    let activeTab = 'all';

    function getDismissedSet() {
        let arr = [];
        try { arr = JSON.parse(localStorage.getItem(storageKey) || '[]'); } catch(e) {}
        return new Set(arr.map(Number));
    }

    function addDismissedId(id) {
        if (!id) return;
        let set = getDismissedSet();
        set.add(Number(id));
        try { localStorage.setItem(storageKey, JSON.stringify(Array.from(set))); } catch(e) {}
    }

    // Zero-flicker suppression of locally dismissed alerts on page load
    (function suppressLocallyDismissed() {
        const dismissed = getDismissedSet();
        if (dismissed.size > 0) {
            const items = document.querySelectorAll('#alertsFeedList .alert-feed-item');
            let removedAny = false;
            items.forEach(el => {
                const id = parseInt(el.dataset.id);
                if (id && dismissed.has(id)) {
                    el.remove();
                    removedAny = true;
                }
            });
            if (removedAny) {
                setTimeout(() => {
                    recalculateCountersFromDom();
                    const rem = document.querySelectorAll('#alertsFeedList .alert-feed-item').length;
                    if (rem === 0) renderEmptyState();
                }, 10);
            }
        }
    })();

    function escapeHtml(str) {
        if (str == null) return '';
        return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    function filterByTab(tab) {
        activeTab = tab;
        document.querySelectorAll('.alert-tab-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.tab === tab);
        });
        applyFilters();
    }

    function handleSearchAlerts() {
        applyFilters();
    }

    function applyFilters() {
        const query = (document.getElementById('alertsSearchInput').value || '').toLowerCase().trim();
        const items = document.querySelectorAll('#alertsFeedList .alert-feed-item');
        let visibleCount = 0;

        items.forEach(item => {
            const cat = (item.dataset.category || '').toLowerCase();
            const type = (item.dataset.type || '').toLowerCase();
            const text = (item.textContent || '').toLowerCase();

            let matchesTab = true;
            if (activeTab === 'critical') {
                matchesTab = (type === 'danger' || type === 'warning');
            } else if (activeTab === 'compliance') {
                matchesTab = (cat.indexOf('compliance') !== -1);
            } else if (activeTab === 'billing') {
                matchesTab = (cat.indexOf('billing') !== -1 || cat.indexOf('finance') !== -1);
            } else if (activeTab === 'claims') {
                matchesTab = (cat.indexOf('claims') !== -1);
            }

            let matchesSearch = (!query || text.indexOf(query) !== -1);

            if (matchesTab && matchesSearch) {
                item.style.display = 'flex';
                visibleCount++;
            } else {
                item.style.display = 'none';
            }
        });

        const emptySearch = document.getElementById('alertsSearchEmptyState');
        if (emptySearch) {
            emptySearch.style.display = (items.length > 0 && visibleCount === 0) ? 'flex' : 'none';
        }
    }

    function resetFilters() {
        document.getElementById('alertsSearchInput').value = '';
        filterByTab('all');
    }

    // Dynamic Departure: Single Dismiss with smooth slide-out and persistent storage
    function dismissSingleAlert(btn, notifId) {
        const item = btn.closest('.alert-feed-item');
        if (!item) return;

        addDismissedId(notifId);

        // Smooth slide-right animation
        item.style.transition = 'transform 0.25s ease, opacity 0.25s ease';
        item.style.transform = 'translateX(40px)';
        item.style.opacity = '0';
        item.style.pointerEvents = 'none';

        // Notify server immediately
        fetch(ctx + '/notifications?action=markRead&id=' + notifId, { credentials: 'same-origin' }).catch(function() {});

        setTimeout(() => {
            item.remove();
            recalculateCountersFromDom();

            // Trigger global notification sync so navbar bell and sidebar badges decrement instantly
            if (typeof window.pollNotifications === 'function') {
                window.pollNotifications();
            }

            const remaining = document.querySelectorAll('#alertsFeedList .alert-feed-item').length;
            if (remaining === 0) {
                renderEmptyState();
            } else {
                applyFilters();
            }
        }, 250);
    }

    // Dynamic Departure: Mark All as Read
    function markAllAlertsReadPage() {
        const feed = document.getElementById('alertsFeedList');
        const items = feed.querySelectorAll('.alert-feed-item');
        if (items.length === 0) return;

        // Fade out all items smoothly & persist dismissed
        items.forEach(el => {
            const id = parseInt(el.dataset.id);
            if (id) addDismissedId(id);
            el.style.transition = 'transform 0.2s ease, opacity 0.2s ease';
            el.style.transform = 'translateY(-10px)';
            el.style.opacity = '0';
        });

        // Notify server
        fetch(ctx + '/notifications?action=markAllRead', { credentials: 'same-origin' }).catch(function() {});

        setTimeout(() => {
            renderEmptyState();
            updateAllCounters(0, 0, 0, 0, 0);

            // Sync global bell and sidebar badges
            if (typeof window.pollNotifications === 'function') {
                window.pollNotifications();
            }
        }, 220);
    }

    // Dynamic Refresh Button with high-fidelity visual feedback
    let isRefreshing = false;
    function refreshAlertsPage() {
        if (isRefreshing) return;
        isRefreshing = true;

        const btn = document.getElementById('btnRefreshAlerts');
        const icon = document.getElementById('refreshBtnIcon');
        const textSpan = document.getElementById('refreshBtnText');

        if (btn) {
            btn.style.pointerEvents = 'none';
            btn.style.opacity = '0.9';
        }
        if (icon) {
            icon.className = 'ti ti-refresh spin-anim';
        }
        if (textSpan) {
            textSpan.textContent = 'Refreshing...';
        }

        const startTime = Date.now();
        const minSpinMs = 650; // Visible rotation guarantee

        const completeRefresh = function(data) {
            const elapsed = Date.now() - startTime;
            const delay = Math.max(0, minSpinMs - elapsed);

            setTimeout(function() {
                // Update feed & counters
                if (typeof window.onNotificationsPolled === 'function') {
                    try { window.onNotificationsPolled(data); } catch(e) { console.error(e); }
                }

                // Flash subtle pulse on feed cards
                const feed = document.getElementById('alertsFeedList');
                if (feed) {
                    feed.classList.remove('feed-refreshed');
                    void feed.offsetWidth; // trigger reflow
                    feed.classList.add('feed-refreshed');
                }

                // Success visual state
                if (icon) icon.className = 'ti ti-check';
                if (textSpan) textSpan.textContent = 'Updated!';
                if (btn) btn.style.background = '#10B981';

                setTimeout(function() {
                    if (icon) icon.className = 'ti ti-refresh';
                    if (textSpan) textSpan.textContent = 'Refresh';
                    if (btn) {
                        btn.style.background = '';
                        btn.style.opacity = '';
                        btn.style.pointerEvents = '';
                    }
                    isRefreshing = false;
                }, 1300);
            }, delay);
        };

        // Cache-busted fetch to notifications API
        fetch(ctx + '/notifications?_t=' + Date.now(), { credentials: 'same-origin', cache: 'no-store' })
            .then(function(res) { return res.ok ? res.json() : []; })
            .then(function(data) {
                if (typeof renderNotifications === 'function') {
                    try { renderNotifications(data); } catch(e) {}
                }
                completeRefresh(data);
            })
            .catch(function(err) {
                console.warn('Alerts refresh failed:', err);
                completeRefresh([]);
            });
    }

    function renderEmptyState() {
        const feed = document.getElementById('alertsFeedList');
        feed.innerHTML = 
            '<div class="alerts-empty-state" id="alertsMainEmptyState">' +
                '<div class="empty-state-icon">' +
                    '<i class="ti ti-circle-check"></i>' +
                '</div>' +
                '<h2 class="empty-state-title">All Caught Up!</h2>' +
                '<p class="empty-state-desc">' +
                    'There are no active operational alerts, pending document expirations, or overdue invoices requiring your attention right now.' +
                '</p>' +
                '<div style="margin-top:14px; display:flex; gap:10px;">' +
                    '<a href="' + ctx + '/dashboard" class="btn-alert-action btn-alert-outline">' +
                        '<i class="ti ti-smart-home"></i> Go to Dashboard' +
                    '</a>' +
                    '<a href="' + ctx + '/compliance" class="btn-alert-action btn-alert-outline">' +
                        '<i class="ti ti-shield-check"></i> Compliance Center' +
                    '</a>' +
                '</div>' +
            '</div>';

        const searchEmpty = document.getElementById('alertsSearchEmptyState');
        if (searchEmpty) searchEmpty.style.display = 'none';
        updateAllCounters(0, 0, 0, 0, 0);
    }

    function recalculateCountersFromDom() {
        const items = document.querySelectorAll('#alertsFeedList .alert-feed-item');
        let total = items.length;
        let critical = 0;
        let compliance = 0;
        let billing = 0;
        let claims = 0;

        items.forEach(el => {
            const cat = (el.dataset.category || '').toLowerCase();
            const type = (el.dataset.type || '').toLowerCase();
            if (type === 'danger' || type === 'warning') critical++;
            if (cat.indexOf('compliance') !== -1) compliance++;
            else if (cat.indexOf('billing') !== -1 || cat.indexOf('finance') !== -1) billing++;
            else if (cat.indexOf('claims') !== -1) claims++;
        });

        updateAllCounters(total, critical, compliance, billing, claims);
    }

    function updateAllCounters(total, critical, compliance, billing, claims) {
        const headerBadge = document.getElementById('headerAlertCountBadge');
        if (headerBadge) headerBadge.textContent = total + ' Active';

        const kpiTotal = document.getElementById('kpiTotalAlerts');
        if (kpiTotal) kpiTotal.textContent = total;

        const kpiCrit = document.getElementById('kpiCritical');
        if (kpiCrit) kpiCrit.textContent = critical;

        const kpiComp = document.getElementById('kpiCompliance');
        if (kpiComp) kpiComp.textContent = compliance;

        const kpiBill = document.getElementById('kpiBilling');
        if (kpiBill) kpiBill.textContent = billing;

        const tabAll = document.getElementById('tabCountAll');
        if (tabAll) tabAll.textContent = total;

        const tabCrit = document.getElementById('tabCountCritical');
        if (tabCrit) tabCrit.textContent = critical;

        const tabComp = document.getElementById('tabCountCompliance');
        if (tabComp) tabComp.textContent = compliance;

        const tabBill = document.getElementById('tabCountBilling');
        if (tabBill) tabBill.textContent = billing;

        const tabClaim = document.getElementById('tabCountClaims');
        if (tabClaim) tabClaim.textContent = claims;
    }

    // Dynamic Arrival & Sync Hook: Called automatically whenever background polling or refresh returns
    window.onNotificationsPolled = function(rawNotifs) {
        if (!rawNotifs || !Array.isArray(rawNotifs)) return;
        const dismissed = getDismissedSet();
        const liveNotifs = rawNotifs.filter(n => !dismissed.has(n.id));

        const feed = document.getElementById('alertsFeedList');
        if (!feed) return;

        if (liveNotifs.length === 0) {
            feed.querySelectorAll('.alert-feed-item').forEach(function(el) { el.remove(); });
            if (!document.getElementById('alertsMainEmptyState')) {
                renderEmptyState();
            }
            updateAllCounters(0, 0, 0, 0, 0);
            return;
        }

        // If empty state was showing and now new alerts arrived, clear it
        const emptyState = document.getElementById('alertsMainEmptyState');
        if (emptyState) {
            feed.innerHTML = '';
        }

        const liveIds = new Set(liveNotifs.map(n => n.id));
        const currentItems = feed.querySelectorAll('.alert-feed-item');

        // 1. Departure: Remove any items that are no longer in liveNotifs
        currentItems.forEach(el => {
            const id = parseInt(el.dataset.id);
            if (!liveIds.has(id)) {
                el.style.transition = 'transform 0.25s ease, opacity 0.25s ease';
                el.style.transform = 'translateX(40px)';
                el.style.opacity = '0';
                setTimeout(() => el.remove(), 250);
            }
        });

        // 2. Arrival: Add any new items that are in liveNotifs but not in DOM
        const currentDomIds = new Set(Array.from(feed.querySelectorAll('.alert-feed-item')).map(el => parseInt(el.dataset.id)));
        
        liveNotifs.forEach(n => {
            if (!currentDomIds.has(n.id)) {
                const link = n.link ? (ctx + n.link) : '#';
                const type = escapeHtml(n.type || 'info');
                const cat = escapeHtml(n.category || 'General');
                const catLower = cat.toLowerCase();
                const icon = escapeHtml(n.icon || 'ti ti-bell');
                const timeAgo = escapeHtml(n.timeAgo || '');

                let severityBadge = '';
                if (type === 'danger') {
                    severityBadge = '<span class="alert-severity-badge danger"><i class="ti ti-alert-circle"></i> Action Required</span>';
                } else if (type === 'warning') {
                    severityBadge = '<span class="alert-severity-badge warning"><i class="ti ti-alert-triangle"></i> Warning</span>';
                }

                const card = document.createElement('div');
                card.className = 'alert-feed-item ' + type + ' alert-newly-arrived';
                card.setAttribute('data-category', catLower);
                card.setAttribute('data-type', type);
                card.setAttribute('data-id', n.id);

                card.innerHTML = 
                    '<div class="alert-item-icon-box ' + type + '">' +
                        '<i class="' + icon + '"></i>' +
                    '</div>' +
                    '<div class="alert-item-content">' +
                        '<div class="alert-item-meta-row">' +
                            '<span class="alert-category-badge ' + catLower + '">' + cat + '</span>' +
                            (timeAgo ? '<span class="alert-time-badge"><i class="ti ti-clock" style="font-size:12px;"></i> ' + timeAgo + '</span>' : '') +
                            severityBadge +
                        '</div>' +
                        '<h3 class="alert-item-title">' + escapeHtml(n.title) + '</h3>' +
                        '<p class="alert-item-message">' + escapeHtml(n.message) + '</p>' +
                    '</div>' +
                    '<div class="alert-item-actions">' +
                        (n.link ? '<a href="' + link + '" class="btn-action-review">Review Now <i class="ti ti-arrow-right"></i></a>' : '') +
                        '<button type="button" class="btn-action-dismiss" onclick="dismissSingleAlert(this, ' + n.id + ')" title="Dismiss alert">' +
                            '<i class="ti ti-check"></i> Dismiss' +
                        '</button>' +
                    '</div>';

                feed.insertBefore(card, feed.firstChild);
            }
        });

        // 3. Recompute KPIs and tab counts
        let critical = 0;
        let compliance = 0;
        let billing = 0;
        let claims = 0;

        liveNotifs.forEach(n => {
            const t = (n.type || '').toLowerCase();
            const c = (n.category || '').toLowerCase();
            if (t === 'danger' || t === 'warning') critical++;
            if (c.indexOf('compliance') !== -1) compliance++;
            else if (c.indexOf('billing') !== -1 || c.indexOf('finance') !== -1) billing++;
            else if (c.indexOf('claims') !== -1) claims++;
        });

        updateAllCounters(liveNotifs.length, critical, compliance, billing, claims);
        applyFilters();
    };
</script>

<%@ include file="layout/footer.jsp" %>
