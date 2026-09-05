<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="en_IN" scope="page" />
<jsp:include page="/jsp/layout/header.jsp" />

<%-- Pre-calculate financial totals & KPI counters --%>
<c:set var="totalInvoiced" value="0" />
<c:set var="totalPaid" value="0" />
<c:set var="totalPending" value="0" />
<c:set var="totalOverdue" value="0" />
<c:set var="countPaid" value="0" />
<c:set var="countUnpaid" value="0" />
<c:set var="countOverdue" value="0" />
<c:set var="countPartial" value="0" />

<c:forEach var="inv" items="${invoices}">
    <c:set var="curTotal" value="${inv.totalAmount < 0 ? -inv.totalAmount : inv.totalAmount}" />
    <c:set var="curPaid" value="${inv.paidAmount < 0 ? -inv.paidAmount : inv.paidAmount}" />
    <c:set var="curBal" value="${curTotal - curPaid}" />
    <c:if test="${curBal < 0}"><c:set var="curBal" value="0" /></c:if>

    <c:set var="totalInvoiced" value="${totalInvoiced + curTotal}" />

    <c:choose>
        <c:when test="${inv.paymentStatus == 'Paid'}">
            <c:set var="countPaid" value="${countPaid + 1}" />
            <c:set var="totalPaid" value="${totalPaid + curTotal}" />
        </c:when>
        <c:when test="${inv.paymentStatus == 'Overdue'}">
            <c:set var="countOverdue" value="${countOverdue + 1}" />
            <c:set var="totalOverdue" value="${totalOverdue + curBal}" />
            <c:set var="totalPending" value="${totalPending + curBal}" />
            <c:set var="totalPaid" value="${totalPaid + curPaid}" />
        </c:when>
        <c:when test="${inv.paymentStatus == 'Partial'}">
            <c:set var="countPartial" value="${countPartial + 1}" />
            <c:set var="totalPending" value="${totalPending + curBal}" />
            <c:set var="totalPaid" value="${totalPaid + curPaid}" />
        </c:when>
        <c:otherwise>
            <c:set var="countUnpaid" value="${countUnpaid + 1}" />
            <c:set var="totalPending" value="${totalPending + curBal}" />
            <c:set var="totalPaid" value="${totalPaid + curPaid}" />
        </c:otherwise>
    </c:choose>
</c:forEach>

<style>
    /* Invoices Revamped Enterprise Styling */
    .invoices-page-wrapper {
        background-color: #F8FAFC;
        min-height: calc(100vh - 70px);
        padding-bottom: 40px;
    }

    /* Page Header */
    .invoices-header-row {
        display: flex;
        align-items: flex-end;
        justify-content: space-between;
        margin-bottom: 24px;
        flex-wrap: wrap;
        gap: 16px;
    }
    .invoices-page-title {
        font-weight: 700;
        color: #0F172A;
        font-size: 24px;
        letter-spacing: -0.02em;
        margin-bottom: 4px;
    }
    .invoices-breadcrumb {
        font-size: 13px;
        color: #64748B;
        margin-bottom: 0;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .btn-create-invoice {
        background: linear-gradient(135deg, #FC8019 0%, #E66F0F 100%);
        color: #FFFFFF !important;
        border: none;
        padding: 9px 20px;
        border-radius: 8px;
        font-weight: 600;
        font-size: 13.5px;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        cursor: pointer;
        box-shadow: 0 4px 14px rgba(252, 128, 25, 0.28);
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        text-decoration: none;
    }
    .btn-create-invoice:hover {
        transform: translateY(-1px);
        box-shadow: 0 6px 18px rgba(252, 128, 25, 0.38);
        background: linear-gradient(135deg, #FF8E2E 0%, #E66F0F 100%);
    }

    /* KPI Cards Grid */
    .inv-kpi-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        gap: 18px;
        margin-bottom: 24px;
    }
    .inv-kpi-card {
        background: #FFFFFF;
        border: 1px solid var(--nl-border, #E2E8F0);
        border-radius: 12px;
        padding: 18px 20px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04);
        position: relative;
        overflow: hidden;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    .inv-kpi-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(15, 23, 42, 0.08);
    }
    .inv-kpi-top {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 12px;
    }
    .inv-kpi-icon {
        width: 42px;
        height: 42px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
    }
    .inv-kpi-icon.invoiced { background: #EEF2FF; color: #4F46E5; }
    .inv-kpi-icon.collected { background: #ECFDF5; color: #10B981; }
    .inv-kpi-icon.pending { background: #FFFBEB; color: #F59E0B; }
    .inv-kpi-icon.overdue { background: #FEF2F2; color: #EF4444; }

    .inv-kpi-label {
        font-size: 11.5px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.6px;
        color: #64748B;
        margin-bottom: 4px;
    }
    .inv-kpi-value {
        font-size: 22px;
        font-weight: 800;
        color: #0F172A;
        letter-spacing: -0.02em;
        line-height: 1.2;
    }
    .inv-kpi-sub {
        font-size: 12px;
        color: #64748B;
        margin-top: 6px;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    /* Filter & Search Toolbar */
    .inv-filter-toolbar {
        background: #FFFFFF;
        border: 1px solid var(--nl-border, #E2E8F0);
        border-radius: 12px;
        padding: 14px 18px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03);
        margin-bottom: 22px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 14px;
    }
    .inv-search-wrap {
        position: relative;
        flex: 1;
        min-width: 260px;
        max-width: 420px;
    }
    .inv-search-wrap i.search-icon {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #94A3B8;
        font-size: 15px;
        pointer-events: none;
    }
    .inv-search-input {
        width: 100%;
        padding: 9px 36px 9px 38px;
        border: 1px solid #E2E8F0;
        border-radius: 8px;
        font-size: 13.5px;
        outline: none;
        background: #F8FAFC;
        color: #0F172A;
        transition: all 0.15s ease;
    }
    .inv-search-input:focus {
        background: #FFFFFF;
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .inv-search-clear {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        color: #94A3B8;
        font-size: 14px;
        cursor: pointer;
        padding: 0;
        display: none;
    }
    .inv-search-clear:hover { color: #0F172A; }

    /* Segmented Status Filter Tabs */
    .inv-status-tabs {
        display: flex;
        align-items: center;
        background: #F1F5F9;
        padding: 3px;
        border-radius: 8px;
        gap: 2px;
    }
    .inv-tab-btn {
        background: none;
        border: none;
        padding: 6px 13px;
        border-radius: 6px;
        font-size: 12.5px;
        font-weight: 600;
        color: #64748B;
        cursor: pointer;
        transition: all 0.15s ease;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .inv-tab-btn:hover {
        color: #0F172A;
    }
    .inv-tab-btn.active {
        background: #FFFFFF;
        color: #0F172A;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.08);
    }
    .inv-tab-count {
        font-size: 11px;
        padding: 1px 6px;
        border-radius: 10px;
        background: rgba(100, 116, 139, 0.12);
        color: #475569;
    }
    .inv-tab-btn.active .inv-tab-count {
        background: #FFF2EB;
        color: #FC8019;
    }

    /* Customer Filter Select */
    .inv-customer-select-wrap {
        min-width: 220px;
    }
    .inv-customer-select {
        width: 100%;
        padding: 8px 12px;
        border: 1px solid #E2E8F0;
        border-radius: 8px;
        font-size: 13px;
        background-color: #FFFFFF;
        color: #0F172A;
        outline: none;
    }
    .inv-customer-select:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }

    /* Table Container Card */
    .inv-table-card {
        background: #FFFFFF;
        border: 1px solid var(--nl-border, #E2E8F0);
        border-radius: 12px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03);
        overflow: hidden;
    }
    .inv-table-header {
        padding: 16px 22px;
        border-bottom: 1px solid #F1F5F9;
        display: flex;
        align-items: center;
        justify-content: space-between;
        background: #FFFFFF;
    }
    .inv-table-title {
        font-size: 15px;
        font-weight: 700;
        color: #0F172A;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    /* Table Styles */
    .inv-table {
        width: 100%;
        margin-bottom: 0;
        border-collapse: collapse;
    }
    .inv-table th {
        background: #F8FAFC;
        font-size: 11.5px;
        font-weight: 700;
        color: #64748B;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        padding: 12px 18px;
        border-bottom: 1px solid #E2E8F0;
        border-top: none;
        white-space: nowrap;
    }
    .inv-table td {
        padding: 14px 18px;
        vertical-align: middle;
        border-bottom: 1px solid #F1F5F9;
        font-size: 13px;
        color: #334155;
    }
    .inv-table tbody tr {
        transition: background-color 0.15s ease;
    }
    .inv-table tbody tr:hover {
        background-color: #F8FAFC;
    }

    /* Column Specific Styles */
    .inv-code-badge {
        font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
        font-weight: 700;
        font-size: 13px;
        color: #0F172A;
        background: #F1F5F9;
        padding: 4px 8px;
        border-radius: 6px;
        border: 1px solid #E2E8F0;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
    .inv-issue-date {
        font-size: 11.5px;
        color: #94A3B8;
        margin-top: 3px;
    }

    .inv-cust-info {
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .inv-cust-avatar {
        width: 34px;
        height: 34px;
        border-radius: 8px;
        background: #FFF2EB;
        color: #FC8019;
        font-weight: 700;
        font-size: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        border: 1px solid #FFE0D1;
    }
    .inv-cust-name {
        font-weight: 600;
        color: #0F172A;
        line-height: 1.3;
    }

    .inv-shipment-pill {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        font-weight: 600;
        color: #2563EB;
        background: #EFF6FF;
        border: 1px solid #DBEAFE;
        padding: 3px 8px;
        border-radius: 6px;
        text-decoration: none;
        font-size: 12px;
        transition: all 0.15s ease;
    }
    .inv-shipment-pill:hover {
        background: #DBEAFE;
        color: #1D4ED8;
    }
    .inv-cargo-desc {
        font-size: 11.5px;
        color: #64748B;
        margin-top: 4px;
        max-width: 200px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .inv-amount-main {
        font-size: 14.5px;
        font-weight: 700;
        color: #0F172A;
        font-family: inherit;
    }
    .inv-amount-sub {
        font-size: 11.5px;
        margin-top: 2px;
    }

    /* Vibrant Status Badges */
    .inv-status-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 5px 11px;
        border-radius: 20px;
        font-size: 11.5px;
        font-weight: 700;
        letter-spacing: 0.3px;
        text-transform: uppercase;
    }
    .inv-status-badge.status-Paid {
        background: #ECFDF5;
        color: #059669;
        border: 1px solid #A7F3D0;
    }
    .inv-status-badge.status-Unpaid {
        background: #FFFBEB;
        color: #D97706;
        border: 1px solid #FDE68A;
    }
    .inv-status-badge.status-Overdue {
        background: #FEF2F2;
        color: #DC2626;
        border: 1px solid #FECACA;
    }
    .inv-status-badge.status-Partial {
        background: #EFF6FF;
        color: #2563EB;
        border: 1px solid #BFDBFE;
    }
    .inv-status-dot {
        width: 6px;
        height: 6px;
        border-radius: 50%;
        background-color: currentColor;
    }

    /* Action Buttons */
    .inv-actions-cell {
        white-space: nowrap;
        text-align: right;
    }
    .btn-inv-action {
        width: 32px;
        height: 32px;
        border-radius: 8px;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        color: #475569;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        transition: all 0.15s ease;
        text-decoration: none;
        cursor: pointer;
    }
    .btn-inv-action:hover {
        background: #F1F5F9;
        color: #0F172A;
        border-color: #CBD5E1;
    }
    .btn-inv-action.btn-pdf:hover {
        background: #EFF6FF;
        color: #2563EB;
        border-color: #BFDBFE;
    }
    .btn-inv-action.btn-qr:hover {
        background: #FFF2EB;
        color: #FC8019;
        border-color: #FFD4C2;
    }
    .btn-inv-pay {
        background: #10B981;
        color: #FFFFFF !important;
        border: none;
        padding: 5px 12px;
        border-radius: 8px;
        font-size: 12.5px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        cursor: pointer;
        box-shadow: 0 2px 5px rgba(16, 185, 129, 0.25);
        transition: all 0.15s ease;
    }
    .btn-inv-pay:hover {
        background: #059669;
        transform: translateY(-1px);
        box-shadow: 0 4px 10px rgba(16, 185, 129, 0.35);
    }

    /* Empty State */
    .inv-empty-state {
        text-align: center;
        padding: 50px 20px;
    }
    .inv-empty-icon {
        width: 56px;
        height: 56px;
        border-radius: 14px;
        background: #F1F5F9;
        color: #94A3B8;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 26px;
        margin-bottom: 14px;
    }

    /* Override any unwanted card tools */
    .no-card-tools .nl-card-tools,
    .filter-card .nl-card-tools,
    [data-no-tools="true"] .nl-card-tools {
        display: none !important;
    }
</style>

<div class="invoices-page-wrapper">
    <div class="container-fluid py-4">

        <!-- Page Header -->
        <div class="invoices-header-row">
            <div>
                <h1 class="invoices-page-title">
                    <c:choose>
                        <c:when test="${sessionScope.user.roleId == 5}">My Invoices &amp; Payments</c:when>
                        <c:otherwise>Billing &amp; Invoices</c:otherwise>
                    </c:choose>
                </h1>
                <p class="invoices-breadcrumb">
                    <span>Dashboard</span>
                    <i class="ti ti-chevron-right" style="font-size: 11px;"></i>
                    <span><c:choose><c:when test="${sessionScope.user.roleId == 5}">My Account</c:when><c:otherwise>Finance</c:otherwise></c:choose></span>
                    <i class="ti ti-chevron-right" style="font-size: 11px;"></i>
                    <span style="color: #0F172A; font-weight: 500;">Invoices &amp; Statements</span>
                </p>
            </div>

            <c:if test="${sessionScope.user.roleId != 5}">
                <button class="btn-create-invoice" data-bs-toggle="modal" data-bs-target="#generateInvoiceModal" type="button">
                    <i class="ti ti-plus"></i> Generate New Invoice
                </button>
            </c:if>
        </div>

        <!-- Session Flash Alerts -->
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center justify-content-between mb-4 shadow-sm" style="border-radius: 10px; border: 1px solid #FECACA; background: #FEF2F2; color: #991B1B;">
                <div class="d-flex align-items-center gap-2">
                    <i class="ti ti-alert-triangle fs-5 text-danger"></i>
                    <span>${sessionScope.errorMessage}</span>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success alert-dismissible fade show d-flex align-items-center justify-content-between mb-4 shadow-sm" style="border-radius: 10px; border: 1px solid #BBF7D0; background: #F0FDF4; color: #166534;">
                <div class="d-flex align-items-center gap-2">
                    <i class="ti ti-circle-check fs-5 text-success"></i>
                    <span>${sessionScope.successMessage}</span>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>

        <!-- Executive Financial KPI Cards -->
        <div class="inv-kpi-grid">
            <!-- Card 1: Total Invoiced -->
            <div class="inv-kpi-card" data-no-tools="true">
                <div class="inv-kpi-top">
                    <div>
                        <div class="inv-kpi-label">Total Invoiced</div>
                        <div class="inv-kpi-value">&#8377;<fmt:formatNumber value="${totalInvoiced}" type="number" minFractionDigits="2" maxFractionDigits="2"/></div>
                    </div>
                    <div class="inv-kpi-icon invoiced">
                        <i class="ti ti-receipt-tax"></i>
                    </div>
                </div>
                <div class="inv-kpi-sub">
                    <span class="badge" style="background: #EEF2FF; color: #4F46E5; font-size: 11px;">${invoices.size()} Statements</span>
                    <span>Issued across accounts</span>
                </div>
            </div>

            <!-- Card 2: Total Collected / Paid -->
            <div class="inv-kpi-card" data-no-tools="true">
                <div class="inv-kpi-top">
                    <div>
                        <div class="inv-kpi-label">Revenue Collected</div>
                        <div class="inv-kpi-value" style="color: #059669;">&#8377;<fmt:formatNumber value="${totalPaid}" type="number" minFractionDigits="2" maxFractionDigits="2"/></div>
                    </div>
                    <div class="inv-kpi-icon collected">
                        <i class="ti ti-circle-check"></i>
                    </div>
                </div>
                <div class="inv-kpi-sub">
                    <span class="badge" style="background: #ECFDF5; color: #059669; font-size: 11px;">${countPaid} Settled</span>
                    <span>Realized in treasury</span>
                </div>
            </div>

            <!-- Card 3: Pending Receivables -->
            <div class="inv-kpi-card" data-no-tools="true">
                <div class="inv-kpi-top">
                    <div>
                        <div class="inv-kpi-label">Pending Balance</div>
                        <div class="inv-kpi-value" style="color: #D97706;">&#8377;<fmt:formatNumber value="${totalPending}" type="number" minFractionDigits="2" maxFractionDigits="2"/></div>
                    </div>
                    <div class="inv-kpi-icon pending">
                        <i class="ti ti-clock-hour-4"></i>
                    </div>
                </div>
                <div class="inv-kpi-sub">
                    <span class="badge" style="background: #FFFBEB; color: #D97706; font-size: 11px;">${countUnpaid + countPartial} Open</span>
                    <span>Awaiting remittance</span>
                </div>
            </div>

            <!-- Card 4: Overdue Amount -->
            <div class="inv-kpi-card" data-no-tools="true">
                <div class="inv-kpi-top">
                    <div>
                        <div class="inv-kpi-label">Overdue Volume</div>
                        <div class="inv-kpi-value" style="color: #DC2626;">&#8377;<fmt:formatNumber value="${totalOverdue}" type="number" minFractionDigits="2" maxFractionDigits="2"/></div>
                    </div>
                    <div class="inv-kpi-icon overdue">
                        <i class="ti ti-alert-triangle"></i>
                    </div>
                </div>
                <div class="inv-kpi-sub">
                    <span class="badge" style="background: #FEF2F2; color: #DC2626; font-size: 11px;">${countOverdue} Overdue</span>
                    <span>Requires followup</span>
                </div>
            </div>
        </div>

        <!-- Unified Search & Filter Toolbar -->
        <div class="inv-filter-toolbar filter-card no-card-tools" data-no-tools="true">
            <!-- Real-time Search -->
            <div class="inv-search-wrap">
                <i class="ti ti-search search-icon"></i>
                <input type="text" id="invoiceSearchInput" class="inv-search-input" placeholder="Search by invoice #, customer, shipment, cargo..." onkeyup="applyInvoiceFilters()">
                <button type="button" class="inv-search-clear" id="invSearchClearBtn" onclick="clearInvoiceSearch()">
                    <i class="ti ti-x"></i>
                </button>
            </div>

            <!-- Segmented Status Tabs -->
            <div class="inv-status-tabs" id="invStatusTabs">
                <button type="button" class="inv-tab-btn active" data-status="ALL" onclick="setStatusFilter('ALL', this)">
                    All <span class="inv-tab-count">${invoices.size()}</span>
                </button>
                <button type="button" class="inv-tab-btn" data-status="Unpaid" onclick="setStatusFilter('Unpaid', this)">
                    Unpaid <span class="inv-tab-count">${countUnpaid}</span>
                </button>
                <button type="button" class="inv-tab-btn" data-status="Overdue" onclick="setStatusFilter('Overdue', this)">
                    Overdue <span class="inv-tab-count">${countOverdue}</span>
                </button>
                <button type="button" class="inv-tab-btn" data-status="Paid" onclick="setStatusFilter('Paid', this)">
                    Paid <span class="inv-tab-count">${countPaid}</span>
                </button>
                <c:if test="${countPartial > 0}">
                    <button type="button" class="inv-tab-btn" data-status="Partial" onclick="setStatusFilter('Partial', this)">
                        Partial <span class="inv-tab-count">${countPartial}</span>
                    </button>
                </c:if>
            </div>

            <!-- Customer Filter (for Staff / Admin) -->
            <c:if test="${sessionScope.user.roleId != 5}">
                <div class="d-flex align-items-center gap-2">
                    <form method="get" action="${pageContext.request.contextPath}/invoices" id="customerFilterForm" class="m-0">
                        <div class="inv-customer-select-wrap">
                            <select name="customerId" id="invCustomerSelect" class="inv-customer-select" onchange="document.getElementById('customerFilterForm').submit()">
                                <option value="">All Customers (${customers.size()})</option>
                                <c:forEach var="cust" items="${customers}">
                                    <option value="${cust.customerId}" ${selectedCustomerId == cust.customerId ? 'selected' : ''}>${cust.customerName}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </form>
                    <c:if test="${not empty selectedCustomerId}">
                        <a href="${pageContext.request.contextPath}/invoices" class="btn-inv-action" title="Reset Customer Filter">
                            <i class="ti ti-rotate"></i>
                        </a>
                    </c:if>
                </div>
            </c:if>
        </div>

        <!-- Invoices Data Table Card -->
        <div class="inv-table-card no-card-tools" data-no-tools="true">
            <div class="inv-table-header">
                <h3 class="inv-table-title">
                    <i class="ti ti-file-invoice" style="color: #FC8019;"></i>
                    <span>Invoice Ledger Records</span>
                    <span class="badge rounded-pill bg-light text-muted fw-normal" style="font-size: 11px; margin-left: 4px;" id="visibleInvoiceCount">${invoices.size()} Total</span>
                </h3>
            </div>

            <div class="table-responsive">
                <table class="inv-table" id="invoicesDataTable">
                    <thead>
                        <tr>
                            <th>Invoice #</th>
                            <th>Customer</th>
                            <th>Shipment Detail</th>
                            <th>Amount &amp; Balance</th>
                            <th>Status</th>
                            <th>Due Date</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="invoiceTableBody">
                        <c:forEach var="inv" items="${invoices}">
                            <%-- Safe absolute calculation to prevent negative sign anomalies --%>
                            <c:set var="invTotal" value="${inv.totalAmount < 0 ? -inv.totalAmount : inv.totalAmount}" />
                            <c:set var="invPaid" value="${inv.paidAmount < 0 ? -inv.paidAmount : inv.paidAmount}" />
                            <c:set var="invBal" value="${invTotal - invPaid}" />
                            <c:if test="${invBal < 0}"><c:set var="invBal" value="0.00" /></c:if>

                            <%-- Customer Initials --%>
                            <c:set var="custNameTrim" value="${empty inv.customerName ? 'Customer' : inv.customerName}" />
                            <c:set var="initials" value="${fn:substring(custNameTrim, 0, 2)}" />

                            <tr class="invoice-row"
                                data-inv-id="INV-${inv.invoiceId}"
                                data-customer="${fn:toLowerCase(custNameTrim)}"
                                data-shipment="${inv.shipmentId}"
                                data-cargo="${fn:toLowerCase(inv.cargoDescription)}"
                                data-status="${inv.paymentStatus}">
                                
                                <!-- Invoice # -->
                                <td>
                                    <div class="inv-code-badge">
                                        <i class="ti ti-receipt" style="color: #FC8019;"></i>
                                        <span>INV-${inv.invoiceId}</span>
                                    </div>
                                    <div class="inv-issue-date">
                                        <fmt:formatDate value="${inv.invoiceDate}" pattern="dd MMM yyyy" />
                                    </div>
                                </td>

                                <!-- Customer -->
                                <td>
                                    <div class="inv-cust-info">
                                        <div class="inv-cust-avatar">
                                            ${fn:toUpperCase(initials)}
                                        </div>
                                        <div>
                                            <div class="inv-cust-name">${custNameTrim}</div>
                                            <c:if test="${not empty inv.customerEmail}">
                                                <div style="font-size: 11px; color: #94A3B8;">${inv.customerEmail}</div>
                                            </c:if>
                                        </div>
                                    </div>
                                </td>

                                <!-- Shipment Detail -->
                                <td>
                                    <a href="${pageContext.request.contextPath}/live-tracking?id=${inv.shipmentId}" class="inv-shipment-pill" title="Track Shipment #${inv.shipmentId}">
                                        <i class="ti ti-package"></i>
                                        <span>#${inv.shipmentId}</span>
                                    </a>
                                    <div class="inv-cargo-desc" title="${inv.cargoDescription}">
                                        <c:out value="${empty inv.cargoDescription ? 'Standard Freight Consignment' : inv.cargoDescription}" />
                                    </div>
                                </td>

                                <!-- Amount & Balance -->
                                <td>
                                    <div class="inv-amount-main">
                                        &#8377;<fmt:formatNumber value="${invTotal}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
                                    </div>
                                    <div class="inv-amount-sub">
                                        <c:choose>
                                            <c:when test="${inv.paymentStatus == 'Paid'}">
                                                <span class="text-success fw-semibold"><i class="ti ti-check"></i> Paid in full</span>
                                            </c:when>
                                            <c:when test="${inv.paymentStatus == 'Partial'}">
                                                <span class="text-muted">Paid: &#8377;<fmt:formatNumber value="${invPaid}" type="number" minFractionDigits="2" maxFractionDigits="2"/></span> &bull; 
                                                <span class="text-warning fw-semibold">Bal: &#8377;<fmt:formatNumber value="${invBal}" type="number" minFractionDigits="2" maxFractionDigits="2"/></span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-danger fw-semibold">Due: &#8377;<fmt:formatNumber value="${invBal}" type="number" minFractionDigits="2" maxFractionDigits="2"/></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>

                                <!-- Status Badge -->
                                <td>
                                    <span class="inv-status-badge status-${inv.paymentStatus}">
                                        <span class="inv-status-dot"></span>
                                        <span>${inv.paymentStatus}</span>
                                    </span>
                                </td>

                                <!-- Due Date -->
                                <td>
                                    <div style="font-weight: 500; color: #1E293B;">
                                        <fmt:formatDate value="${inv.dueDate}" pattern="dd MMM yyyy" />
                                    </div>
                                    <div style="font-size: 11px; margin-top: 2px;">
                                        <c:choose>
                                            <c:when test="${inv.paymentStatus == 'Paid'}">
                                                <span class="text-success">Settled</span>
                                            </c:when>
                                            <c:when test="${inv.paymentStatus == 'Overdue'}">
                                                <span class="text-danger fw-semibold"><i class="ti ti-clock-alert me-1"></i>Overdue</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Payment Pending</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>

                                <!-- Actions -->
                                <td class="inv-actions-cell">
                                    <div class="d-inline-flex align-items-center gap-1">
                                        <button class="btn-inv-action btn-pdf" onclick="viewInvoice(${inv.invoiceId})" title="View &amp; Print Invoice PDF">
                                            <i class="ti ti-file-text"></i>
                                        </button>
                                        
                                        <c:if test="${inv.paymentStatus ne 'Paid'}">
                                            <button type="button" class="btn-inv-action btn-qr" onclick="openQuickQrModal(${inv.invoiceId}, '${fn:escapeXml(custNameTrim)}', ${invBal})" title="Instant Scan &amp; Pay QR">
                                                <i class="ti ti-qrcode" style="color: #FC8019;"></i>
                                            </button>
                                            
                                            <button class="btn-inv-pay" data-bs-toggle="modal" data-bs-target="#paymentModal" 
                                                    onclick="setupPayment(${inv.invoiceId}, ${invBal})" title="Record Payment">
                                                <i class="ti ti-cash"></i> Pay
                                            </button>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty invoices}">
                            <tr id="serverEmptyRow">
                                <td colspan="7">
                                    <div class="inv-empty-state">
                                        <div class="inv-empty-icon">
                                            <i class="ti ti-file-invoice"></i>
                                        </div>
                                        <h5 class="fw-bold text-dark mb-1">No Invoices Found</h5>
                                        <p class="text-muted small mb-0">There are no billing statements matching this account or filter criteria.</p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

            <!-- Client Filter Empty State (Hidden by default) -->
            <div id="clientNoMatchState" class="inv-empty-state" style="display: none;">
                <div class="inv-empty-icon">
                    <i class="ti ti-search-off"></i>
                </div>
                <h5 class="fw-bold text-dark mb-1">No Matching Invoices</h5>
                <p class="text-muted small mb-3">No billing records found matching your search term or active status filter.</p>
                <button type="button" class="btn btn-sm btn-outline-secondary" onclick="resetAllInvoiceFilters()">
                    <i class="ti ti-rotate me-1"></i> Clear Filters
                </button>
            </div>
        </div>

    </div>
</div>

<!-- Generate Invoice Modal -->
<c:if test="${sessionScope.user.roleId != 5}">
<div class="modal fade" id="generateInvoiceModal" tabindex="-1" aria-labelledby="genInvoiceModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 14px; overflow: hidden;">
            <div class="modal-header" style="background: #FFFFFF; border-bottom: 1px solid #F1F5F9; padding: 18px 24px;">
                <div class="d-flex align-items-center gap-2">
                    <div style="width: 38px; height: 38px; background: #FFF2EB; border-radius: 10px; display: flex; align-items: center; justify-content: center; color: #FC8019; font-size: 20px;">
                        <i class="ti ti-file-plus"></i>
                    </div>
                    <div>
                        <h5 class="modal-title fw-bold text-dark mb-0" id="genInvoiceModalLabel">Generate New Billing Invoice</h5>
                        <small class="text-muted" style="font-size: 12px;">Create and finalize receivable billing for an un-invoiced shipment</small>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <form action="<c:url value='/generate-invoice'/>" method="POST">
                <div class="modal-body p-4">
                    <div class="mb-4">
                        <label class="form-label text-dark fw-semibold" style="font-size: 13px;">Select Un-invoiced Shipment <span class="text-danger">*</span></label>
                        <select name="shipmentData" id="genShipmentSelect" class="form-select" required onchange="onGenShipmentChange(this)" style="border-radius: 8px; font-size: 13.5px;">
                            <option value="" disabled selected>-- Choose Shipment to Invoice --</option>
                            <c:forEach var="ship" items="${eligibleShipments}">
                                <option value="${ship.shipmentId}|${ship.customerId}|${ship.cost}" data-cost="${ship.cost}" data-customer="${ship.customerName}">
                                    Shipment #${ship.shipmentId} &mdash; ${ship.customerName} (Freight Cost: ₹<fmt:formatNumber value="${ship.cost}" pattern="#,##0.00"/>)
                                </option>
                            </c:forEach>
                        </select>
                        <c:if test="${empty eligibleShipments}">
                            <div class="alert alert-warning py-2 px-3 mt-2 mb-0 d-flex align-items-center gap-2" style="font-size: 12.5px; border-radius: 8px;">
                                <i class="ti ti-info-circle"></i>
                                <span>All currently active shipments have already been invoiced.</span>
                            </div>
                        </c:if>
                    </div>

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label text-dark fw-semibold" style="font-size: 13px;">Invoice Issue Date <span class="text-danger">*</span></label>
                            <input type="date" name="invoiceDate" id="genInvoiceDate" class="form-control" required style="border-radius: 8px;">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-dark fw-semibold" style="font-size: 13px;">Payment Due Date <span class="text-danger">*</span></label>
                            <input type="date" name="dueDate" id="genDueDate" class="form-control" required style="border-radius: 8px;">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-dark fw-semibold" style="font-size: 13px;">Base Freight Charges (₹) <span class="text-danger">*</span></label>
                            <input type="number" step="0.01" min="0" name="freightCost" id="genFreight" class="form-control" required oninput="recalcInvoiceTotals()" style="border-radius: 8px;">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-dark fw-semibold" style="font-size: 13px;">Handling &amp; Service Charges (₹) <span class="text-danger">*</span></label>
                            <input type="number" step="0.01" min="0" name="serviceCharges" id="genService" class="form-control" value="500.00" required oninput="recalcInvoiceTotals()" style="border-radius: 8px;">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-dark fw-semibold" style="font-size: 13px;">Fuel &amp; Peak Surcharge (₹)</label>
                            <input type="number" step="0.01" min="0" name="surcharge" id="genSurcharge" class="form-control" value="0.00" oninput="recalcInvoiceTotals()" style="border-radius: 8px;">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-dark fw-semibold" style="font-size: 13px;">GST / Tax Rate (%) <span class="text-danger">*</span></label>
                            <input type="number" step="0.01" min="0" max="100" name="taxRate" id="genTaxRate" class="form-control" value="18" required oninput="recalcInvoiceTotals()" style="border-radius: 8px;">
                        </div>
                        <div class="col-12">
                            <label class="form-label text-dark fw-semibold" style="font-size: 13px;">Invoice Notes / Memo</label>
                            <input type="text" name="notes" class="form-control" placeholder="Optional notes printed on invoice statement" style="border-radius: 8px;">
                        </div>
                    </div>

                    <!-- Live Calculation Panel -->
                    <div class="mt-4 p-3" style="background: #FFF9F5; border: 1px solid #FFD4C2; border-radius: 10px;">
                        <div class="d-flex justify-content-between mb-1" style="font-size: 13px; color: #64748B;">
                            <span>Subtotal (Freight + Service + Surcharge)</span>
                            <strong id="genSubtotal" style="color: #0F172A;">₹0.00</strong>
                        </div>
                        <div class="d-flex justify-content-between mb-2" style="font-size: 13px; color: #64748B;">
                            <span>Estimated GST Tax</span>
                            <strong id="genTax" style="color: #0F172A;">₹0.00</strong>
                        </div>
                        <div class="d-flex justify-content-between pt-2" style="border-top: 1px dashed #FFD4C2; font-size: 15px;">
                            <strong style="color: #0F172A;">Total Payable Invoice Amount</strong>
                            <strong id="genTotal" style="color: #FC8019; font-size: 16px;">₹0.00</strong>
                        </div>
                    </div>
                </div>

                <div class="modal-footer border-top-0 pt-0 px-4 pb-4">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius: 8px; font-weight: 500;">Cancel</button>
                    <button type="submit" class="btn-create-invoice" ${empty eligibleShipments ? 'disabled' : ''}>
                        <i class="ti ti-check"></i> Generate &amp; Save Invoice
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
</c:if>

<!-- Record Payment Modal -->
<div class="modal fade" id="paymentModal" tabindex="-1" aria-labelledby="payModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 14px; overflow: hidden;">
            <div class="modal-header" style="background: #FFFFFF; border-bottom: 1px solid #F1F5F9; padding: 18px 24px;">
                <div class="d-flex align-items-center gap-2">
                    <div style="width: 38px; height: 38px; background: #ECFDF5; border-radius: 10px; display: flex; align-items: center; justify-content: center; color: #10B981; font-size: 20px;">
                        <i class="ti ti-cash"></i>
                    </div>
                    <div>
                        <h5 class="modal-title fw-bold text-dark mb-0" id="payModalLabel">Record Payment Settlement</h5>
                        <small class="text-muted" style="font-size: 12px;">Disburse or collect payment against invoice balance</small>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <form action="<c:url value='/record-payment'/>" method="POST">
                <input type="hidden" name="invoiceId" id="payInvoiceId">
                <div class="modal-body p-4">
                    <!-- Balance Banner -->
                    <div class="p-3 mb-3 d-flex justify-content-between align-items-center" style="background: #FEF2F2; border: 1px solid #FECACA; border-radius: 10px;">
                        <div>
                            <span class="text-muted small d-block">Outstanding Balance:</span>
                            <span class="fw-bold text-dark" id="payInvoiceDisplay">Invoice Selected</span>
                        </div>
                        <span class="fw-bold text-danger fs-4">₹<span id="payBalance">0.00</span></span>
                    </div>

                    <div class="mb-3">
                        <label class="form-label text-dark fw-semibold" style="font-size: 13px;">Amount Paid (₹) <span class="text-danger">*</span></label>
                        <input type="number" step="0.01" name="amountPaid" id="amountPaidInput" class="form-control" required oninput="renderInvQr()" style="border-radius: 8px;">
                    </div>

                    <div class="mb-3">
                        <label class="form-label text-dark fw-semibold" style="font-size: 13px;">Payment Method <span class="text-danger">*</span></label>
                        <select name="paymentMode" id="invPaymentMode" class="form-select" required onchange="onInvPaymentModeChange()" style="border-radius: 8px;">
                            <option value="UPI">UPI (Instant QR / VPA)</option>
                            <option value="Card">Credit / Debit Card</option>
                            <option value="Bank Transfer">Bank Transfer (NEFT / RTGS / IMPS)</option>
                            <option value="Cheque">Bank Cheque / Draft</option>
                        </select>
                    </div>

                    <!-- Dynamic Real UPI QR Display -->
                    <div id="invUpiQr" class="text-center mb-3" style="background: #FFF9F5; border: 1px dashed #FC8019; border-radius: 12px; padding: 16px;">
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <span style="font-size: 11px; font-weight: 700; color: #FC8019; text-transform: uppercase; letter-spacing: 0.5px;">
                                <i class="ti ti-qrcode me-1"></i> Scan &amp; Pay via UPI
                            </span>
                            <span class="badge" style="background: #FFF2EB; color: #FC8019; font-size: 10.5px; border: 1px solid #FFE0D1;">Live Merchant QR</span>
                        </div>
                        <div id="invUpiQrCanvas" style="width: 156px; height: 156px; margin: 8px auto 10px; padding: 8px; background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 10px; box-shadow: 0 2px 6px rgba(0,0,0,0.06); display: flex; align-items: center; justify-content: center; overflow: hidden;"></div>
                        <div style="font-size: 12px; color: #0F172A; font-weight: 600;" id="qrPayeeText">
                            UPI ID: <span style="font-family: monospace; color: #FC8019;">nlogistic.billing@icici</span>
                            <button type="button" class="btn btn-link p-0 ms-1 text-decoration-none" onclick="copyUpiId('nlogistic.billing@icici', this)" title="Copy UPI ID">
                                <i class="ti ti-copy" style="font-size: 13px;"></i>
                            </button>
                        </div>
                        <div style="font-size: 11px; color: #64748B; margin-top: 4px;">
                            Scan using GPay, PhonePe, Paytm, Cred, or BHIM
                        </div>
                    </div>

                    <!-- Conditional Cheque Fields -->
                    <div id="invChequeFields" style="display: none;">
                        <div class="mb-2">
                            <input type="text" id="invChequeNo" class="form-control" placeholder="Cheque Number" style="border-radius: 8px;">
                        </div>
                        <div class="mb-2">
                            <input type="text" id="invBearer" class="form-control" placeholder="Bearer / Drawer Name" style="border-radius: 8px;">
                        </div>
                    </div>

                    <!-- Conditional Card Fields -->
                    <div id="invCardFields" style="display: none;">
                        <div class="mb-2">
                            <input type="text" id="invCardLast4" maxlength="4" class="form-control" placeholder="Card Last 4 Digits" style="border-radius: 8px;">
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label text-dark fw-semibold" style="font-size: 13px;">Transaction / UTR Reference <span class="text-danger">*</span></label>
                        <input type="text" name="transactionRef" id="invTransactionRef" class="form-control" placeholder="e.g. UTR2918340192" required style="border-radius: 8px;">
                    </div>
                </div>

                <div class="modal-footer border-top-0 pt-0 px-4 pb-4">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius: 8px; font-weight: 500;">Cancel</button>
                    <button type="submit" class="btn btn-success" style="border-radius: 8px; font-weight: 600; padding: 8px 18px;">
                        <i class="ti ti-check me-1"></i> Confirm Settlement
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Quick Instant QR Code Modal -->
<div class="modal fade" id="quickQrModal" tabindex="-1" aria-labelledby="quickQrModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width: 420px;">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px; overflow: hidden;">
            <div class="modal-header text-white" style="background: linear-gradient(135deg, #0F172A 0%, #1E293B 100%); border-bottom: none; padding: 18px 22px;">
                <div class="d-flex align-items-center gap-3">
                    <div style="width: 40px; height: 40px; background: rgba(252, 128, 25, 0.2); border: 1px solid rgba(252, 128, 25, 0.4); border-radius: 10px; display: flex; align-items: center; justify-content: center; color: #FC8019; font-size: 20px;">
                        <i class="ti ti-qrcode"></i>
                    </div>
                    <div>
                        <h5 class="modal-title fw-bold mb-0 text-white" id="quickQrModalLabel">Scan &amp; Pay Invoice</h5>
                        <small style="color: #94A3B8; font-size: 11.5px;">Official Verified Merchant UPI QR</small>
                    </div>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <div class="modal-body p-4 text-center">
                <!-- Amount Banner -->
                <div class="p-3 mb-3" style="background: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 12px;">
                    <div class="text-muted small mb-1" style="font-size: 11.5px;">Outstanding Balance</div>
                    <div class="fw-bold text-dark" style="font-size: 26px; letter-spacing: -0.5px;" id="quickQrAmountDisplay">&#8377;0.00</div>
                    <div class="badge mt-1" style="background: #FFF2EB; color: #FC8019; border: 1px solid #FFE0D1; font-weight: 600;" id="quickQrInvoiceDisplay">
                        Invoice #INV-000
                    </div>
                </div>

                <!-- High Resolution Real QR Code Container -->
                <div style="background: #FFFFFF; border: 2px dashed #CBD5E1; border-radius: 14px; padding: 14px; margin-bottom: 14px; display: inline-block; box-shadow: 0 4px 16px rgba(0,0,0,0.04);">
                    <div id="quickQrCodeContainer" style="width: 180px; height: 180px; margin: 0 auto; display: flex; align-items: center; justify-content: center; overflow: hidden;"></div>
                    <div class="mt-2 text-muted" style="font-size: 11px; font-weight: 600;">
                        <i class="ti ti-scan me-1" style="color: #FC8019;"></i> Point smartphone camera or UPI app
                    </div>
                </div>

                <!-- Payee VPA Details -->
                <div class="p-2 mb-3 d-flex align-items-center justify-content-between" style="background: #F1F5F9; border-radius: 8px; font-size: 12px;">
                    <div class="text-start">
                        <span class="text-muted d-block" style="font-size: 10px; font-weight: 700; text-transform: uppercase;">UPI ID / VPA</span>
                        <span class="fw-bold text-dark font-monospace" id="quickQrVpaText">nlogistic.billing@icici</span>
                    </div>
                    <button type="button" class="btn btn-sm btn-outline-secondary d-flex align-items-center gap-1" onclick="copyUpiId('nlogistic.billing@icici', this)" style="border-radius: 6px; font-size: 11px; padding: 4px 8px;">
                        <i class="ti ti-copy"></i> Copy
                    </button>
                </div>

                <!-- Mobile Intent Direct Link (for smartphone users) -->
                <a id="quickQrMobileIntentBtn" href="#" class="btn btn-primary w-100 mb-3 d-md-none" style="background: #FC8019; border-color: #FC8019; border-radius: 8px; font-weight: 600; padding: 9px;">
                    <i class="ti ti-external-link me-1"></i> Pay with Installed UPI App
                </a>

                <!-- Supported Apps Grid -->
                <div class="d-flex align-items-center justify-content-center gap-1 pt-2" style="border-top: 1px solid #F1F5F9;">
                    <span class="badge bg-white text-dark border px-2 py-1" style="font-size: 10.5px; font-weight: 600;"><i class="ti ti-brand-google text-primary me-1"></i>GPay</span>
                    <span class="badge bg-white text-dark border px-2 py-1" style="font-size: 10.5px; font-weight: 600;"><i class="ti ti-bolt text-purple me-1" style="color: #673AB7;"></i>PhonePe</span>
                    <span class="badge bg-white text-dark border px-2 py-1" style="font-size: 10.5px; font-weight: 600;"><i class="ti ti-wallet text-info me-1"></i>Paytm</span>
                    <span class="badge bg-white text-dark border px-2 py-1" style="font-size: 10.5px; font-weight: 600;"><i class="ti ti-building-bank text-success me-1"></i>BHIM</span>
                </div>
            </div>

            <div class="modal-footer bg-light border-0 py-2 px-4 justify-content-between">
                <button type="button" class="btn btn-sm btn-outline-secondary" data-bs-dismiss="modal" style="border-radius: 8px;">Close</button>
                <button type="button" class="btn btn-sm btn-success" id="quickQrRecordPayBtn" onclick="switchToRecordPayment()" style="border-radius: 8px; font-weight: 600;">
                    <i class="ti ti-cash me-1"></i> Record Settlement
                </button>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/qrcode.min.js"></script>
<script>
    // Current Active Status Filter ('ALL', 'Paid', 'Unpaid', 'Overdue', 'Partial')
    let currentStatusFilter = 'ALL';

    // Status Filter Tab Selection
    window.setStatusFilter = function(status, btn) {
        currentStatusFilter = status;
        document.querySelectorAll('#invStatusTabs .inv-tab-btn').forEach(b => b.classList.remove('active'));
        if (btn) btn.classList.add('active');
        applyInvoiceFilters();
    };

    // Real-time Instant Search & Status Filter
    window.applyInvoiceFilters = function() {
        const query = (document.getElementById('invoiceSearchInput').value || '').trim().toLowerCase();
        const clearBtn = document.getElementById('invSearchClearBtn');
        if (clearBtn) {
            clearBtn.style.display = query.length > 0 ? 'block' : 'none';
        }

        const rows = document.querySelectorAll('#invoiceTableBody tr.invoice-row');
        let visibleCount = 0;

        rows.forEach(row => {
            const invId = (row.dataset.invId || '').toLowerCase();
            const customer = (row.dataset.customer || '').toLowerCase();
            const shipment = (row.dataset.shipment || '').toLowerCase();
            const cargo = (row.dataset.cargo || '').toLowerCase();
            const status = row.dataset.status || '';

            // Status Match
            const matchesStatus = (currentStatusFilter === 'ALL') || (status.toLowerCase() === currentStatusFilter.toLowerCase());

            // Query Match across multiple fields
            const matchesQuery = !query || 
                invId.includes(query) || 
                customer.includes(query) || 
                shipment.includes(query) || 
                cargo.includes(query);

            if (matchesStatus && matchesQuery) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });

        // Update counter & empty state
        const countBadge = document.getElementById('visibleInvoiceCount');
        if (countBadge) {
            countBadge.textContent = visibleCount + ' Visible';
        }

        const emptyState = document.getElementById('clientNoMatchState');
        if (emptyState) {
            emptyState.style.display = (visibleCount === 0 && rows.length > 0) ? 'block' : 'none';
        }
    };

    window.clearInvoiceSearch = function() {
        const input = document.getElementById('invoiceSearchInput');
        if (input) input.value = '';
        applyInvoiceFilters();
    };

    window.resetAllInvoiceFilters = function() {
        clearInvoiceSearch();
        const allBtn = document.querySelector('#invStatusTabs .inv-tab-btn[data-status="ALL"]');
        if (allBtn) setStatusFilter('ALL', allBtn);
    };

    // Open Printable/Exportable View
    window.viewInvoice = function(invoiceId) {
        window.open('${pageContext.request.contextPath}/invoices?id=' + invoiceId + '&action=view', '_blank');
    };

    // Setup Payment Modal
    window.setupPayment = function(invoiceId, balance) {
        document.getElementById('payInvoiceId').value = invoiceId;
        const disp = document.getElementById('payInvoiceDisplay');
        if (disp) disp.textContent = 'Invoice #INV-' + invoiceId;

        const balFloat = Math.max(0, parseFloat(balance) || 0);
        document.getElementById('payBalance').innerText = balFloat.toFixed(2);
        const amtInput = document.getElementById('amountPaidInput');
        amtInput.value = balFloat.toFixed(2);
        amtInput.max = balFloat;

        const modeSel = document.getElementById('invPaymentMode');
        if (modeSel && modeSel.value === 'UPI') {
            renderInvQr();
        }
    };

    // Live Generate Invoice Modal Calculations
    window.onGenShipmentChange = function(sel) {
        const opt = sel.options[sel.selectedIndex];
        if (!opt) return;
        const cost = parseFloat(opt.getAttribute('data-cost')) || 0;
        document.getElementById('genFreight').value = cost.toFixed(2);
        // Default surcharge = 2% of freight
        document.getElementById('genSurcharge').value = (Math.round(cost * 0.02 * 100) / 100).toFixed(2);
        recalcInvoiceTotals();
    };

    window.recalcInvoiceTotals = function() {
        const num = (id) => parseFloat(document.getElementById(id).value) || 0;
        const subtotal = num('genFreight') + num('genService') + num('genSurcharge');
        const tax = subtotal * (num('genTaxRate') / 100);
        const total = subtotal + tax;
        const fmt = (v) => '₹' + v.toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        document.getElementById('genSubtotal').textContent = fmt(subtotal);
        document.getElementById('genTax').textContent = fmt(tax);
        document.getElementById('genTotal').textContent = fmt(total);
    };

    // Payment Mode Toggle & QR Canvas
    window.onInvPaymentModeChange = function() {
        const mode = document.getElementById('invPaymentMode').value;
        document.getElementById('invUpiQr').style.display = (mode === 'UPI') ? 'block' : 'none';
        document.getElementById('invChequeFields').style.display = (mode === 'Cheque') ? 'block' : 'none';
        document.getElementById('invCardFields').style.display = (mode === 'Card') ? 'block' : 'none';
        const ref = document.getElementById('invTransactionRef');
        if (mode === 'UPI') {
            ref.value = 'UPI-' + Date.now().toString().slice(-8);
            renderInvQr();
        } else {
            ref.value = '';
        }
    };

    // Real QR Code Generator using local qrcode.min.js with API fallback
    window.generateRealQr = function(container, upiUri, size) {
        if (!container) return;
        size = size || 160;
        container.innerHTML = '';

        if (typeof QRCode !== 'undefined') {
            try {
                new QRCode(container, {
                    text: upiUri,
                    width: size,
                    height: size,
                    colorDark: '#0F172A',
                    colorLight: '#FFFFFF',
                    correctLevel: (typeof QRCode.CorrectLevel !== 'undefined' && typeof QRCode.CorrectLevel.M !== 'undefined') ? QRCode.CorrectLevel.M : 0
                });
                const img = container.querySelector('img');
                const canvas = container.querySelector('canvas');
                if (img) {
                    img.style.margin = '0 auto';
                    img.style.display = 'block';
                    img.style.maxWidth = '100%';
                    img.style.height = 'auto';
                }
                if (canvas) {
                    canvas.style.margin = '0 auto';
                    canvas.style.display = 'block';
                    canvas.style.maxWidth = '100%';
                    canvas.style.height = 'auto';
                }
                return;
            } catch (err) {
                console.warn('Local QRCode warning, trying image fallback:', err);
            }
        }

        // Fallback to high-speed QR Server API
        const fallbackImg = document.createElement('img');
        fallbackImg.src = 'https://api.qrserver.com/v1/create-qr-code/?size=' + size + 'x' + size + '&margin=6&data=' + encodeURIComponent(upiUri);
        fallbackImg.alt = 'Scan UPI QR';
        fallbackImg.style.width = size + 'px';
        fallbackImg.style.height = size + 'px';
        fallbackImg.style.display = 'block';
        fallbackImg.style.margin = '0 auto';
        fallbackImg.style.borderRadius = '6px';
        container.appendChild(fallbackImg);
    };

    window.renderInvQr = function() {
        const el = document.getElementById('invUpiQrCanvas');
        if (!el) return;

        const invoiceId = document.getElementById('payInvoiceId').value || '0';
        const amountVal = parseFloat(document.getElementById('amountPaidInput').value) || 0;
        const cleanAmount = Math.max(0, amountVal).toFixed(2);

        // Official NPCI standard UPI URI format
        const upiUri = 'upi://pay?pa=nlogistic.billing@icici&pn=N%20Logistic%20Freight&am=' + cleanAmount + '&cu=INR&tn=Invoice%20INV-' + invoiceId;

        generateRealQr(el, upiUri, 140);
    };

    let currentQuickQrInvoice = { id: null, balance: 0, customer: '' };

    window.openQuickQrModal = function(invoiceId, customerName, balance) {
        currentQuickQrInvoice = { id: invoiceId, balance: balance, customer: customerName };

        const balFloat = Math.max(0, parseFloat(balance) || 0);
        const balFormatted = balFloat.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

        const amtDisplay = document.getElementById('quickQrAmountDisplay');
        if (amtDisplay) amtDisplay.innerHTML = '&#8377;' + balFormatted;

        const invDisplay = document.getElementById('quickQrInvoiceDisplay');
        if (invDisplay) invDisplay.textContent = 'Invoice #INV-' + invoiceId + ' (' + customerName + ')';

        const upiUri = 'upi://pay?pa=nlogistic.billing@icici&pn=N%20Logistic%20Freight&am=' + balFloat.toFixed(2) + '&cu=INR&tn=Invoice%20INV-' + invoiceId;

        const intentBtn = document.getElementById('quickQrMobileIntentBtn');
        if (intentBtn) {
            intentBtn.href = upiUri;
        }

        const qrContainer = document.getElementById('quickQrCodeContainer');
        if (qrContainer) {
            generateRealQr(qrContainer, upiUri, 180);
        }

        const modalEl = document.getElementById('quickQrModal');
        if (modalEl && window.bootstrap) {
            const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
            modal.show();
        }
    };

    window.switchToRecordPayment = function() {
        const qrModalEl = document.getElementById('quickQrModal');
        if (qrModalEl && window.bootstrap) {
            const qrModal = bootstrap.Modal.getInstance(qrModalEl);
            if (qrModal) qrModal.hide();
        }
        setTimeout(() => {
            setupPayment(currentQuickQrInvoice.id, currentQuickQrInvoice.balance);
            const payModalEl = document.getElementById('paymentModal');
            if (payModalEl && window.bootstrap) {
                const payModal = bootstrap.Modal.getOrCreateInstance(payModalEl);
                payModal.show();
            }
        }, 350);
    };

    window.copyUpiId = function(text, btn) {
        if (navigator.clipboard) {
            navigator.clipboard.writeText(text).then(() => {
                const orig = btn.innerHTML;
                btn.innerHTML = '<i class="ti ti-check text-success"></i> Copied!';
                setTimeout(() => { btn.innerHTML = orig; }, 2000);
            }).catch(() => fallbackCopy(text, btn));
        } else {
            fallbackCopy(text, btn);
        }
    };

    function fallbackCopy(text, btn) {
        const ta = document.createElement('textarea');
        ta.value = text;
        document.body.appendChild(ta);
        ta.select();
        document.execCommand('copy');
        document.body.removeChild(ta);
        const orig = btn.innerHTML;
        btn.innerHTML = '<i class="ti ti-check text-success"></i> Copied!';
        setTimeout(() => { btn.innerHTML = orig; }, 2000);
    }

    document.addEventListener('DOMContentLoaded', function() {
        // Default invoice date = today, due date = +30 days
        const inv = document.getElementById('genInvoiceDate');
        const due = document.getElementById('genDueDate');
        if (inv && due) {
            const today = new Date();
            const plus30 = new Date(today.getTime() + 30 * 86400000);
            inv.value = today.toISOString().slice(0, 10);
            due.value = plus30.toISOString().slice(0, 10);
        }

        const sel = document.getElementById('invPaymentMode');
        if (sel) onInvPaymentModeChange();
    });

    // Composite reference submission
    document.addEventListener('submit', function(e) {
        if (e.target && e.target.querySelector && e.target.querySelector('#invPaymentMode')) {
            const mode = document.getElementById('invPaymentMode').value;
            const ref = document.getElementById('invTransactionRef');
            if (mode === 'Cheque') {
                const chq = document.getElementById('invChequeNo').value.trim();
                const bearer = document.getElementById('invBearer').value.trim();
                if (!chq) { alert('Please enter the cheque number.'); e.preventDefault(); return; }
                ref.value = 'CHQ-' + chq + (bearer ? (' / Bearer: ' + bearer) : '');
            } else if (mode === 'Card') {
                const last4 = document.getElementById('invCardLast4').value.trim();
                if (!last4) { alert('Please enter the last 4 digits of the card.'); e.preventDefault(); return; }
                ref.value = 'CARD-XXXX' + last4;
            } else if (!ref.value.trim()) {
                if (mode !== 'UPI') { alert('Please enter a transaction reference.'); e.preventDefault(); return; }
            }
        }
    }, true);
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
