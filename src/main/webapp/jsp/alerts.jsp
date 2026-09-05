<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="layout/header.jsp" %>

<style>
    :root {
        --nl-primary: #FC8019;
        --nl-primary-hover: #e57315;
        --nl-primary-light: #FFF7ED;
        --nl-border: #E2E8F0;
        --nl-text-main: #0F172A;
        --nl-text-muted: #64748B;
        --nl-bg-card: #FFFFFF;
        --nl-bg-hover: #F8FAFC;
    }

    .alerts-container {
        padding: 24px 32px 48px;
        max-width: 1400px;
        margin: 0 auto;
    }

    /* Page Header */
    .alerts-page-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 16px;
        margin-bottom: 24px;
    }
    .alerts-header-left {
        display: flex;
        flex-direction: column;
        gap: 4px;
    }
    .alerts-breadcrumb {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 12.5px;
        color: var(--nl-text-muted);
        font-weight: 500;
    }
    .alerts-breadcrumb a {
        color: var(--nl-text-muted);
        text-decoration: none;
        transition: color 0.15s;
    }
    .alerts-breadcrumb a:hover {
        color: var(--nl-primary);
    }
    .alerts-page-title {
        font-size: 24px;
        font-weight: 700;
        color: var(--nl-text-main);
        letter-spacing: -0.02em;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .alerts-page-title .title-badge {
        font-size: 13px;
        font-weight: 700;
        background: #FFF7ED;
        color: #FC8019;
        border: 1px solid #FFEDD5;
        padding: 3px 10px;
        border-radius: 20px;
        transition: all 0.2s ease;
    }
    .alerts-page-desc {
        font-size: 13.5px;
        color: var(--nl-text-muted);
        margin: 0;
    }
    .alerts-header-actions {
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .btn-alert-action {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        font-size: 13px;
        font-weight: 600;
        padding: 8px 16px;
        border-radius: 8px;
        cursor: pointer;
        text-decoration: none;
        transition: all 0.18s ease;
        border: none;
    }
    .btn-alert-primary {
        background: #FC8019;
        color: #FFFFFF;
    }
    .btn-alert-primary:hover {
        background: #e57315;
        color: #FFFFFF;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.25);
    }
    .btn-alert-outline {
        background: #FFFFFF;
        color: #475569;
        border: 1px solid var(--nl-border);
    }
    .btn-alert-outline:hover {
        background: #F8FAFC;
        border-color: #CBD5E1;
        color: var(--nl-text-main);
    }

    /* Spinning animation for refresh button */
    @keyframes spinRefresh {
        from { transform: rotate(0deg); }
        to { transform: rotate(360deg); }
    }
    .spin-anim {
        animation: spinRefresh 0.8s linear infinite;
        display: inline-block;
    }

    /* Feed pulse animation on manual refresh */
    @keyframes feedPulse {
        0% { opacity: 0.5; transform: scale(0.998); }
        100% { opacity: 1; transform: scale(1); }
    }
    .feed-refreshed {
        animation: feedPulse 0.35s ease;
    }

    /* KPI Summary Cards Grid */
    .alerts-kpi-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 18px;
        margin-bottom: 24px;
    }
    .alert-kpi-card {
        background: var(--nl-bg-card);
        border: 1px solid var(--nl-border);
        border-radius: 12px;
        padding: 18px 20px;
        display: flex;
        align-items: center;
        gap: 16px;
        transition: all 0.2s ease;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.03);
        cursor: pointer;
        user-select: none;
    }
    .alert-kpi-card:hover {
        transform: translateY(-2px);
        border-color: #FED7AA;
        box-shadow: 0 8px 20px -4px rgba(252, 128, 25, 0.12);
    }
    .kpi-icon-box {
        width: 48px;
        height: 48px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 22px;
        flex-shrink: 0;
    }
    .kpi-icon-box.orange { background: #FFF7ED; color: #FC8019; border: 1px solid #FFEDD5; }
    .kpi-icon-box.red { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }
    .kpi-icon-box.amber { background: #FFFBEB; color: #D97706; border: 1px solid #FDE68A; }
    .kpi-icon-box.blue { background: #EFF6FF; color: #2563EB; border: 1px solid #BFDBFE; }

    .kpi-data {
        display: flex;
        flex-direction: column;
    }
    .kpi-num {
        font-size: 22px;
        font-weight: 700;
        color: var(--nl-text-main);
        line-height: 1.2;
    }
    .kpi-title {
        font-size: 13px;
        font-weight: 600;
        color: var(--nl-text-muted);
        margin-top: 2px;
    }
    .kpi-sub {
        font-size: 11.5px;
        color: #94A3B8;
        margin-top: 1px;
    }

    /* Filter Toolbar Card */
    .alerts-toolbar-card {
        background: var(--nl-bg-card);
        border: 1px solid var(--nl-border);
        border-radius: 12px;
        padding: 14px 18px;
        margin-bottom: 20px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 14px;
    }
    .alerts-tabs-group {
        display: flex;
        align-items: center;
        gap: 6px;
        flex-wrap: wrap;
    }
    .alert-tab-btn {
        padding: 7px 14px;
        font-size: 13px;
        font-weight: 600;
        border-radius: 8px;
        border: 1px solid transparent;
        background: #F1F5F9;
        color: #475569;
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 6px;
        transition: all 0.15s ease;
    }
    .alert-tab-btn:hover {
        background: #E2E8F0;
        color: var(--nl-text-main);
    }
    .alert-tab-btn.active {
        background: #FC8019;
        color: #FFFFFF;
        border-color: #FC8019;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25);
    }
    .alert-tab-btn .tab-count {
        font-size: 11px;
        font-weight: 700;
        background: rgba(255, 255, 255, 0.25);
        color: inherit;
        padding: 1px 6px;
        border-radius: 10px;
    }
    .alert-tab-btn:not(.active) .tab-count {
        background: #E2E8F0;
        color: #475569;
    }

    .alerts-search-box {
        position: relative;
        width: 320px;
    }
    .alerts-search-box input {
        width: 100%;
        height: 38px;
        padding: 8px 12px 8px 36px;
        font-size: 13px;
        border: 1px solid var(--nl-border);
        border-radius: 8px;
        outline: none;
        transition: all 0.15s ease;
        background: #FAFAFC;
    }
    .alerts-search-box input:focus {
        background: #FFFFFF;
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .alerts-search-box i {
        position: absolute;
        left: 11px;
        top: 50%;
        transform: translateY(-50%);
        color: #94A3B8;
        font-size: 16px;
        pointer-events: none;
    }

    /* Alerts Feed List */
    .alerts-feed {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    .alert-feed-item {
        background: var(--nl-bg-card);
        border: 1px solid var(--nl-border);
        border-radius: 12px;
        padding: 16px 20px;
        display: flex;
        align-items: flex-start;
        gap: 16px;
        transition: transform 0.25s ease, opacity 0.25s ease, box-shadow 0.2s ease;
        position: relative;
        overflow: hidden;
    }
    .alert-feed-item:hover {
        background: var(--nl-bg-hover);
        border-color: #CBD5E1;
        box-shadow: 0 4px 14px rgba(15, 23, 42, 0.05);
        transform: translateY(-1px);
    }

    /* Dynamic Arrival animation */
    @keyframes alertSlideIn {
        from { opacity: 0; transform: translateY(-12px); }
        to { opacity: 1; transform: translateY(0); }
    }
    .alert-newly-arrived {
        animation: alertSlideIn 0.35s cubic-bezier(0.16, 1, 0.3, 1) forwards;
    }

    /* Left accent status strip */
    .alert-feed-item::before {
        content: '';
        position: absolute;
        left: 0;
        top: 0;
        bottom: 0;
        width: 4px;
    }
    .alert-feed-item.danger::before { background: #EF4444; }
    .alert-feed-item.warning::before { background: #F59E0B; }
    .alert-feed-item.info::before { background: #3B82F6; }
    .alert-feed-item.success::before { background: #10B981; }

    .alert-item-icon-box {
        width: 42px;
        height: 42px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        flex-shrink: 0;
        margin-top: 2px;
    }
    .alert-item-icon-box.danger { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }
    .alert-item-icon-box.warning { background: #FFFBEB; color: #D97706; border: 1px solid #FDE68A; }
    .alert-item-icon-box.info { background: #EFF6FF; color: #2563EB; border: 1px solid #BFDBFE; }
    .alert-item-icon-box.success { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }

    .alert-item-content {
        flex: 1;
        min-width: 0;
    }
    .alert-item-meta-row {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 4px;
        flex-wrap: wrap;
    }
    .alert-category-badge {
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        padding: 2px 8px;
        border-radius: 6px;
    }
    .alert-category-badge.compliance { background: #FEF3C7; color: #92400E; }
    .alert-category-badge.billing, .alert-category-badge.finance { background: #FEE2E2; color: #991B1B; }
    .alert-category-badge.claims { background: #DBEAFE; color: #1E40AF; }
    .alert-category-badge.general { background: #F1F5F9; color: #475569; }

    .alert-time-badge {
        font-size: 12px;
        color: #64748B;
        font-weight: 500;
        display: inline-flex;
        align-items: center;
        gap: 4px;
    }
    .alert-severity-badge {
        font-size: 11px;
        font-weight: 700;
        padding: 2px 8px;
        border-radius: 6px;
    }
    .alert-severity-badge.danger { background: #FEE2E2; color: #991B1B; }
    .alert-severity-badge.warning { background: #FEF3C7; color: #92400E; }
    .alert-severity-badge.info { background: #EFF6FF; color: #1E40AF; }

    .alert-item-title {
        font-size: 15px;
        font-weight: 700;
        color: var(--nl-text-main);
        margin: 2px 0 4px 0;
        line-height: 1.35;
    }
    .alert-item-message {
        font-size: 13.5px;
        color: #475569;
        line-height: 1.5;
        margin: 0;
    }

    .alert-item-actions {
        display: flex;
        align-items: center;
        gap: 8px;
        flex-shrink: 0;
        margin-top: 4px;
    }
    .btn-action-review {
        padding: 7px 14px;
        font-size: 12.5px;
        font-weight: 600;
        border-radius: 7px;
        background: #FC8019;
        color: #FFFFFF;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 4px;
        transition: all 0.15s;
    }
    .btn-action-review:hover {
        background: #e57315;
        color: #FFFFFF;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25);
    }
    .btn-action-dismiss {
        padding: 7px 10px;
        font-size: 12.5px;
        font-weight: 600;
        border-radius: 7px;
        background: #FFFFFF;
        color: #64748B;
        border: 1px solid var(--nl-border);
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 4px;
        transition: all 0.15s;
    }
    .btn-action-dismiss:hover {
        background: #FEE2E2;
        color: #DC2626;
        border-color: #FECACA;
    }

    /* Empty State */
    .alerts-empty-state {
        background: var(--nl-bg-card);
        border: 1px solid var(--nl-border);
        border-radius: 16px;
        padding: 60px 24px;
        text-align: center;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 8px;
        animation: alertSlideIn 0.3s ease;
    }
    .empty-state-icon {
        width: 64px;
        height: 64px;
        border-radius: 50%;
        background: #ECFDF5;
        color: #059669;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 32px;
        margin-bottom: 8px;
    }
    .empty-state-title {
        font-size: 18px;
        font-weight: 700;
        color: var(--nl-text-main);
        margin: 0;
    }
    .empty-state-desc {
        font-size: 13.5px;
        color: var(--nl-text-muted);
        max-width: 420px;
        line-height: 1.5;
        margin: 0;
    }

    @media (max-width: 992px) {
        .alerts-kpi-grid { grid-template-columns: repeat(2, 1fr); }
    }
    @media (max-width: 640px) {
        .alerts-container { padding: 16px; }
        .alerts-kpi-grid { grid-template-columns: 1fr; }
        .alert-feed-item { flex-direction: column; }
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
    let activeTab = 'all';

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

    // Dynamic Departure: Single Dismiss with smooth slide-out and instant count decrement
    function dismissSingleAlert(btn, notifId) {
        const item = btn.closest('.alert-feed-item');
        if (!item) return;

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

        // Fade out all items smoothly
        items.forEach(el => {
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
    window.onNotificationsPolled = function(liveNotifs) {
        if (!liveNotifs || !Array.isArray(liveNotifs)) return;

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
