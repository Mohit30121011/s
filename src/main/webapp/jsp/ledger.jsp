<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="en_IN" scope="page" />
<jsp:include page="/jsp/layout/header.jsp" />

<%-- Pre-calculate KPI statistics --%>
<c:set var="totalEntries" value="${empty ledgerList ? 0 : ledgerList.size()}" />
<c:set var="countIn" value="0" />
<c:set var="countOut" value="0" />
<c:set var="countAdj" value="0" />
<c:set var="totalUnits" value="0" />

<c:forEach var="item" items="${ledgerList}">
    <c:set var="totalUnits" value="${totalUnits + item.quantity}" />
    <c:choose>
        <c:when test="${item.type == 'IN'}">
            <c:set var="countIn" value="${countIn + 1}" />
        </c:when>
        <c:when test="${item.type == 'OUT'}">
            <c:set var="countOut" value="${countOut + 1}" />
        </c:when>
        <c:otherwise>
            <c:set var="countAdj" value="${countAdj + 1}" />
        </c:otherwise>
    </c:choose>
</c:forEach>

<style>
    /* ==========================================================================
       INVENTORY LEDGER THEME (ENTERPRISE PARITY)
       ========================================================================== */
    :root {
        --nl-primary: #FC8019;
        --nl-primary-hover: #E66F0F;
        --nl-surface: #FFFFFF;
        --nl-border: #E2E8F0;
        --nl-text-main: #0F172A;
        --nl-text-muted: #64748B;
        --card-radius: 14px;
    }

    .ledger-page-wrapper {
        background-color: #F8FAFC;
        min-height: calc(100vh - 70px);
        padding-bottom: 40px;
    }

    /* Frameless Ledger Header Hero */
    .ledger-header-hero {
        background: transparent !important;
        background-color: transparent !important;
        border: none !important;
        box-shadow: none !important;
        padding: 0 0 4px 0 !important;
        margin-bottom: 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 16px;
    }
    .telemetry-header-left {
        display: flex;
        align-items: center;
        gap: 16px;
    }
    .telemetry-icon-box {
        width: 52px;
        height: 52px;
        border-radius: 50% !important;
        background: rgba(252, 128, 25, 0.12);
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 26px;
        flex-shrink: 0;
        box-shadow: 0 2px 8px rgba(252, 128, 25, 0.18);
    }
    .telemetry-title {
        font-size: 24px;
        font-weight: 700;
        color: #0F172A;
        margin: 0 0 4px 0;
        letter-spacing: -0.02em;
    }
    .telemetry-desc {
        color: #64748B;
        margin: 0;
        font-size: 13.5px;
    }
    .telemetry-actions {
        display: flex;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
    }
    .btn-register-primary {
        background: #FC8019;
        color: #FFFFFF !important;
        border: none;
        padding: 10px 24px;
        border-radius: 50px !important;
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
    .btn-register-primary:hover {
        background: #E66F0F;
        transform: translateY(-1px);
        box-shadow: 0 6px 18px rgba(252, 128, 25, 0.38);
        color: #FFFFFF !important;
    }

    .btn-outline-nlog {
        background: #FFFFFF;
        color: #475569 !important;
        border: 1.5px solid #CBD5E1;
        padding: 10px 22px;
        border-radius: 50px !important;
        font-weight: 600;
        font-size: 13.5px;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        cursor: pointer;
        transition: all 0.18s ease;
        text-decoration: none;
    }
    .btn-outline-nlog:hover {
        background: #F8FAFC;
        border-color: #94A3B8;
        color: #0F172A !important;
    }

    /* KPI Cards Grid */
    .ledger-kpi-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 18px;
        margin-bottom: 24px;
    }
    @media (max-width: 1024px) { .ledger-kpi-grid { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 640px) { .ledger-kpi-grid { grid-template-columns: 1fr; } }
    .ledger-kpi-card {
        background: #FFFFFF;
        border: 1px solid var(--nl-border);
        border-radius: 16px;
        padding: 18px 20px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03);
        display: flex;
        align-items: center;
        justify-content: space-between;
        transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
    }
    .ledger-kpi-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(15, 23, 42, 0.06);
        border-color: #CBD5E1;
    }
    .ledger-kpi-label {
        font-size: 12px;
        font-weight: 600;
        color: #64748B;
        margin-bottom: 6px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    .ledger-kpi-value {
        font-size: 26px;
        font-weight: 800;
        color: #0F172A;
        line-height: 1;
        letter-spacing: -0.02em;
    }
    .ledger-kpi-icon {
        width: 48px;
        height: 48px;
        border-radius: 50% !important;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 22px;
        flex-shrink: 0;
    }
    .ledger-kpi-icon.blue { background: #EFF6FF; color: #2563EB; }
    .ledger-kpi-icon.green { background: #ECFDF5; color: #059669; }
    .ledger-kpi-icon.red { background: #FEF2F2; color: #DC2626; }
    .ledger-kpi-icon.amber { background: #FFFBEB; color: #D97706; }

    /* Table Toolbar & Filter Tabs */
    .ledger-panel {
        background: #FFFFFF;
        border: 1px solid var(--nl-border);
        border-radius: 16px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04);
        overflow: hidden;
    }
    .ledger-toolbar {
        padding: 16px 20px;
        background: #F8FAFC;
        border-bottom: 1px solid #E2E8F0;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 14px;
    }
    .nav-tabs-custom {
        display: inline-flex; align-items: center; gap: 4px; background: #F1F5F9; padding: 4px;
        border-radius: 50px !important; border: 1px solid #E2E8F0; width: fit-content; flex-wrap: wrap;
    }
    .nav-tabs-custom .nav-link {
        background: transparent; border: none; padding: 6px 16px; border-radius: 50px !important; font-size: 12.5px; font-weight: 600;
        color: #64748B; cursor: pointer; transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); display: inline-flex; align-items: center; gap: 8px; user-select: none;
    }
    .nav-tabs-custom .nav-link .tab-count {
        background: rgba(148, 163, 184, 0.22); color: #475569; font-size: 11px; font-weight: 700;
        padding: 2px 8px; border-radius: 50px; line-height: 1.2;
    }
    .nav-tabs-custom .nav-link:hover { color: #0F172A; }
    .nav-tabs-custom .nav-link.active {
        background: #FC8019 !important; color: #FFFFFF !important; box-shadow: 0 2px 10px rgba(252, 128, 25, 0.35); border-bottom: none;
    }
    .nav-tabs-custom .nav-link.active .tab-count {
        background: rgba(255, 255, 255, 0.28) !important; color: #FFFFFF !important;
    }

    .search-input-box { position: relative; min-width: 240px; max-width: 320px; }
    .search-input-box i { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #94A3B8; font-size: 14px; }
    .search-input-box input { padding-left: 38px !important; height: 38px; font-size: 13px; border-radius: 50px !important; border: 1px solid #CBD5E1; width: 100%; outline: none; }
    .search-input-box input:focus { border-color: var(--nl-primary); box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.15); }

    .records-count-badge { display: none !important; }

    /* Enterprise Table Architecture */
    .enterprise-table.tracking-table {
        width: 100%; border-collapse: collapse; margin: 0;
    }
    .enterprise-table.tracking-table th {
        background: #F8FAFC; padding: 14px 20px; font-size: 11.5px; font-weight: 700; color: #64748B;
        text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid #E2E8F0; text-align: left;
    }
    .enterprise-table.tracking-table th.sortable {
        cursor: pointer; user-select: none; transition: background-color 0.15s ease, color 0.15s ease;
    }
    .enterprise-table.tracking-table th.sortable:hover {
        background-color: #F1F5F9; color: var(--nl-primary);
    }
    /* Product name styling */
    .ledger-product-name { color: #0F172A; font-weight: 700; font-size: 13.5px; }

    /* Column spacing & alignment */
    .ledger-cost-cell {
        font-weight: 600; font-size: 13.5px; color: #0F172A; padding-right: 36px !important;
    }
    .ledger-cost-cell .currency-symbol {
        color: #94A3B8; font-size: 12px; margin-right: 2px;
    }
    .ref-pill {
        display: inline-flex; align-items: center; gap: 6px; background: #F1F5F9; border: 1px solid #CBD5E1;
        color: #334155; padding: 4px 12px; border-radius: 50px !important; font-size: 12px; font-weight: 600;
        letter-spacing: 0.2px; transition: all 0.15s ease;
    }
    .ref-pill i { color: #FC8019; font-size: 13px; }

    .enterprise-table.tracking-table td {
        padding: 14px 20px; border-bottom: 1px solid #F1F5F9; vertical-align: middle; font-size: 13.5px; color: #1E293B;
    }
    .enterprise-table.tracking-table tr:hover td { background-color: #FAFAFA; }

    /* Circular Pagination Architecture */
    .nl-pagination-wrapper {
        display: flex !important; align-items: center; justify-content: space-between; padding: 16px 24px;
        background: #FFFFFF; border-top: 1px solid #E2E8F0; flex-wrap: wrap; gap: 16px;
    }
    .nl-pagination-info {
        font-size: 13px; color: #64748B; display: flex; align-items: center; gap: 8px;
    }
    .nl-pagination-info strong { color: #0F172A; }
    .nl-pagination-nav { display: flex; align-items: center; gap: 6px; }
    .nl-page-size-select {
        background-color: #FFFFFF; border: 1px solid #CBD5E1; border-radius: 50px !important;
        padding: 4px 10px; font-size: 12.5px; font-weight: 600; color: #0F172A; outline: none; cursor: pointer;
    }
    .nl-page-btn {
        width: 32px; height: 32px; border-radius: 50% !important; display: inline-flex; align-items: center;
        justify-content: center; font-size: 12.5px; font-weight: 600; background-color: #FFFFFF; border: 1px solid #CBD5E1;
        color: #475569; cursor: pointer; transition: all 0.15s ease; flex-shrink: 0;
    }
    .nl-page-btn:hover:not(.disabled) { border-color: #FC8019; color: #FC8019; background-color: #FFF5EC; }
    .nl-page-btn.active {
        background-color: #FC8019 !important; border-color: #FC8019 !important; color: #FFFFFF !important;
        box-shadow: 0 2px 8px rgba(252, 128, 25, 0.35);
    }
    .nl-page-btn.disabled { opacity: 0.35; cursor: not-allowed; }
    .nl-page-dots {
        display: inline-flex; align-items: center; justify-content: center; width: 18px; height: 32px;
        color: #94A3B8; font-size: 13px; font-weight: 700; user-select: none;
    }

    /* Badges */
    .badge-in {
        background-color: #ECFDF5; color: #059669; padding: 4px 12px; border-radius: 50px !important;
        font-size: 12px; font-weight: 700; border: 1px solid #A7F3D0; display: inline-flex; align-items: center; gap: 4px;
    }
    .badge-out {
        background-color: #FEF2F2; color: #DC2626; padding: 4px 12px; border-radius: 50px !important;
        font-size: 12px; font-weight: 700; border: 1px solid #FECACA; display: inline-flex; align-items: center; gap: 4px;
    }
    .badge-adj {
        background-color: #FFFBEB; color: #D97706; padding: 4px 12px; border-radius: 50px !important;
        font-size: 12px; font-weight: 700; border: 1px solid #FDE68A; display: inline-flex; align-items: center; gap: 4px;
    }

    .empty-ledger-box { padding: 60px 24px; text-align: center; }
    .empty-ledger-icon {
        width: 64px; height: 64px; border-radius: 50% !important; background: #F1F5F9;
        color: #94A3B8; font-size: 28px; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px;
    }

    /* Hide Card Tools */
    .nl-card-tools, [data-theme="dark"] .nl-card-tools { display: none !important; }

    /* Dark Mode Standards */
    [data-theme="dark"] .ledger-page-wrapper {
        background-color: transparent !important;
    }
    [data-theme="dark"] .ledger-header-hero {
        background: transparent !important;
        background-color: transparent !important;
        border: none !important;
        box-shadow: none !important;
    }
    [data-theme="dark"] .telemetry-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .telemetry-desc {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .telemetry-icon-box {
        background: rgba(252, 128, 25, 0.15) !important;
        border: 1px solid rgba(252, 128, 25, 0.35) !important;
        color: #FC8019 !important;
        box-shadow: none !important;
    }
    [data-theme="dark"] .ledger-kpi-card,
    [data-theme="dark"] .ledger-panel {
        background: #101820 !important;
        border-color: #223447 !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3) !important;
    }
    [data-theme="dark"] .ledger-kpi-value {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .ledger-kpi-label {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .ledger-kpi-icon.blue {
        background: rgba(37, 99, 235, 0.16) !important;
        color: #60A5FA !important;
        border: 1px solid rgba(37, 99, 235, 0.3) !important;
    }
    [data-theme="dark"] .ledger-kpi-icon.green {
        background: rgba(16, 185, 129, 0.16) !important;
        color: #34D399 !important;
        border: 1px solid rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .ledger-kpi-icon.red {
        background: rgba(239, 68, 68, 0.16) !important;
        color: #F87171 !important;
        border: 1px solid rgba(239, 68, 68, 0.3) !important;
    }
    [data-theme="dark"] .ledger-kpi-icon.amber {
        background: rgba(245, 158, 11, 0.16) !important;
        color: #FBBF24 !important;
        border: 1px solid rgba(245, 158, 11, 0.3) !important;
    }
    [data-theme="dark"] .ledger-toolbar {
        background: #151F28 !important;
        border-bottom-color: #223447 !important;
    }
    [data-theme="dark"] .nav-tabs-custom {
        background: #0B131B !important;
        border: 1px solid #223447 !important;
    }
    [data-theme="dark"] .nav-tabs-custom .nav-link {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .nav-tabs-custom .nav-link:hover {
        color: #F8FAFC !important;
        background: rgba(255, 255, 255, 0.04);
    }
    [data-theme="dark"] .nav-tabs-custom .nav-link .tab-count {
        background: rgba(255, 255, 255, 0.08) !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .nav-tabs-custom .nav-link.active {
        background: #FC8019 !important;
        color: #FFFFFF !important;
        box-shadow: 0 4px 14px rgba(252, 128, 25, 0.4) !important;
    }
    [data-theme="dark"] .nav-tabs-custom .nav-link.active .tab-count {
        background: rgba(255, 255, 255, 0.28) !important;
        color: #FFFFFF !important;
    }
    [data-theme="dark"] .ledger-cost-cell {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .ledger-cost-cell .currency-symbol {
        color: #64748B !important;
    }
    [data-theme="dark"] .ref-pill {
        background: rgba(255, 255, 255, 0.04) !important;
        border: 1px solid #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .ref-pill i {
        color: #FC8019 !important;
    }
    [data-theme="dark"] .search-input-box input {
        background-color: #101820 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .search-input-box input:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.15) !important;
    }
    [data-theme="dark"] .records-count-badge {
        background: #101820 !important;
        border-color: #2D3F4D !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .enterprise-table.tracking-table th {
        background-color: #101820 !important;
        color: #94A3B8 !important;
        border-bottom-color: #223447 !important;
    }
    [data-theme="dark"] .enterprise-table.tracking-table th.sortable:hover {
        background-color: #151F28 !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .enterprise-table.tracking-table td {
        background-color: transparent !important;
        border-bottom-color: #1E2D3D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .enterprise-table.tracking-table tr:hover td {
        background-color: rgba(255, 255, 255, 0.02) !important;
    }
    [data-theme="dark"] .ledger-product-name {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .enterprise-table.tracking-table td.font-monospace {
        color: #E2E8F0 !important;
    }
    [data-theme="dark"] code {
        background: #151F28 !important;
        color: #FC8019 !important;
        border: 1px solid #2D3F4D !important;
        padding: 2px 6px;
        border-radius: 4px;
    }
    [data-theme="dark"] .btn-outline-nlog {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .btn-outline-nlog:hover {
        background: #1E2D3D !important;
        border-color: #FC8019 !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .badge-in {
        background: rgba(16, 185, 129, 0.15) !important;
        color: #34D399 !important;
        border-color: rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .badge-out {
        background: rgba(239, 68, 68, 0.15) !important;
        color: #F87171 !important;
        border-color: rgba(239, 68, 68, 0.3) !important;
    }
    [data-theme="dark"] .badge-adj {
        background: rgba(245, 158, 11, 0.15) !important;
        color: #FBBF24 !important;
        border-color: rgba(245, 158, 11, 0.3) !important;
    }
    [data-theme="dark"] .nl-pagination-wrapper {
        background: #101820 !important;
        border-top: 1px solid #223447 !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .nl-pagination-info strong {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .nl-page-size-select {
        background-color: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .nl-page-btn {
        background-color: #151F28 !important;
        border: 1px solid #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .nl-page-btn:hover {
        background-color: #1E2D3D !important;
        border-color: #FC8019 !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .nl-page-btn.active {
        background-color: #FC8019 !important;
        border-color: #FC8019 !important;
        color: #FFFFFF !important;
    }
    [data-theme="dark"] .nl-page-btn.disabled {
        background-color: #101820 !important;
        border-color: #223447 !important;
        color: #475569 !important;
    }
    [data-theme="dark"] .nl-page-dots {
        color: #64748B !important;
    }
    [data-theme="dark"] .empty-ledger-icon {
        background: #1E293B !important;
    }
</style>

<div class="ledger-page-wrapper py-4">
    <div class="container-fluid px-4">
        <!-- Frameless Ledger Header Hero -->
        <div class="ledger-header-hero">
            <div class="telemetry-header-left">
                <div class="telemetry-icon-box">
                    <i class="ti ti-notebook"></i>
                </div>
                <div>
                    <h1 class="telemetry-title">Stock &amp; Inventory Ledger</h1>
                    <div class="telemetry-desc">Dashboard &nbsp;&gt;&nbsp; Stock &amp; Inventory &nbsp;&gt;&nbsp; Inventory Movement History</div>
                </div>
            </div>
            <div class="telemetry-actions">
                <button class="btn btn-outline-nlog" onclick="window.print()" type="button">
                    <i class="ti ti-printer me-1"></i> Print Ledger
                </button>
                <a href="${pageContext.request.contextPath}/upload-stock" class="btn btn-register-primary">
                    <i class="ti ti-upload me-1"></i> Upload / Manage Stock
                </a>
            </div>
        </div>

        <!-- KPI Summary Cards -->
        <div class="ledger-kpi-grid">
            <div class="ledger-kpi-card">
                <div>
                    <div class="ledger-kpi-label">Total Transactions</div>
                    <div class="ledger-kpi-value">${totalEntries}</div>
                </div>
                <div class="ledger-kpi-icon blue"><i class="ti ti-arrows-exchange"></i></div>
            </div>
            <div class="ledger-kpi-card">
                <div>
                    <div class="ledger-kpi-label">Stock Inward</div>
                    <div class="ledger-kpi-value" style="color: #059669;">${countIn}</div>
                </div>
                <div class="ledger-kpi-icon green"><i class="ti ti-arrow-down-left"></i></div>
            </div>
            <div class="ledger-kpi-card">
                <div>
                    <div class="ledger-kpi-label">Stock Outward</div>
                    <div class="ledger-kpi-value" style="color: #DC2626;">${countOut}</div>
                </div>
                <div class="ledger-kpi-icon red"><i class="ti ti-arrow-up-right"></i></div>
            </div>
            <div class="ledger-kpi-card">
                <div>
                    <div class="ledger-kpi-label">Adjustments</div>
                    <div class="ledger-kpi-value" style="color: #D97706;">${countAdj}</div>
                </div>
                <div class="ledger-kpi-icon amber"><i class="ti ti-adjustments"></i></div>
            </div>
        </div>

        <!-- Ledger Table Panel -->
        <div class="ledger-panel">
            <div class="ledger-toolbar">
                <div class="d-flex align-items-center gap-3 flex-wrap">
                    <div class="search-input-box">
                        <i class="ti ti-search"></i>
                        <input type="text" id="ledgerSearchInput" placeholder="Search product, HSN, ref..." oninput="handleLedgerFilter()">
                    </div>
                    <div class="nav-tabs-custom">
                        <button type="button" class="nav-link active" onclick="filterLedgerType('ALL')" id="tab-all">All <span class="tab-count" id="countAll">${totalEntries}</span></button>
                        <button type="button" class="nav-link" onclick="filterLedgerType('IN')" id="tab-in">IN <span class="tab-count" id="countIn">${countIn}</span></button>
                        <button type="button" class="nav-link" onclick="filterLedgerType('OUT')" id="tab-out">OUT <span class="tab-count" id="countOut">${countOut}</span></button>
                        <button type="button" class="nav-link" onclick="filterLedgerType('ADJUSTMENT')" id="tab-adj">Adjust <span class="tab-count" id="countAdj">${countAdj}</span></button>
                    </div>
                </div>
            </div>

            <div class="table-responsive">
                <table class="enterprise-table tracking-table align-middle text-nowrap mb-0" id="ledgerTable">
                    <thead>
                        <tr>
                            <th class="sortable" onclick="sortLedgerTable(0)" style="width: 190px;">Date &amp; Time <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                            <th class="sortable" onclick="sortLedgerTable(1)" style="min-width: 220px;">Product Name <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                            <th class="sortable text-center" onclick="sortLedgerTable(2)" style="width: 100px;">Type <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                            <th class="sortable text-end" onclick="sortLedgerTable(3)" style="width: 130px; padding-right: 24px;">Quantity <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                            <th class="sortable text-end" onclick="sortLedgerTable(4)" style="width: 150px; padding-right: 36px;">Unit Cost (₹) <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                            <th style="min-width: 180px; padding-left: 24px;">Reference / Remarks</th>
                        </tr>
                    </thead>
                    <tbody id="ledgerTableBody">
                        <c:forEach var="entry" items="${ledgerList}">
                            <tr class="ledger-row"
                                data-product="${fn:toLowerCase(entry.productName)}"
                                data-hsn="${fn:toLowerCase(entry.hsnCode)}"
                                data-type="${entry.type}"
                                data-ref="${fn:toLowerCase(entry.reference)}">
                                <td><fmt:formatDate value="${entry.date}" pattern="dd MMM yyyy, hh:mm a" /></td>
                                <td>
                                    <strong class="ledger-product-name">${entry.productName}</strong><br>
                                    <small class="text-muted">HSN: <code>${empty entry.hsnCode ? '—' : entry.hsnCode}</code></small>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${entry.type == 'IN'}">
                                            <span class="badge-in"><i class="ti ti-arrow-down-left me-1"></i> IN</span>
                                        </c:when>
                                        <c:when test="${entry.type == 'OUT'}">
                                            <span class="badge-out"><i class="ti ti-arrow-up-right me-1"></i> OUT</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-adj"><i class="ti ti-adjustments me-1"></i> ADJ</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end fw-bold 
                                    <c:if test="${entry.type == 'IN'}">text-success</c:if>
                                    <c:if test="${entry.type == 'OUT'}">text-danger</c:if>
                                " style="padding-right: 24px;">
                                    <c:if test="${entry.type == 'IN'}">+</c:if>
                                    <c:if test="${entry.type == 'OUT'}">-</c:if>
                                    <fmt:formatNumber value="${entry.quantity}" maxFractionDigits="2"/>
                                </td>
                                <td class="text-end font-monospace ledger-cost-cell">
                                    <span class="currency-symbol">₹</span><fmt:formatNumber value="${entry.unitCost}" minFractionDigits="2" maxFractionDigits="2"/>
                                </td>
                                <td style="padding-left: 24px;">
                                    <span class="ref-pill"><i class="ti ti-tag"></i><span>${entry.reference}</span></span>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty ledgerList}">
                            <tr id="emptyLedgerRow"><td colspan="6" class="empty-ledger-box">
                                <div class="empty-ledger-icon"><i class="ti ti-notebook-off"></i></div>
                                <h6 class="fw-bold text-dark">No Ledger Entries Found</h6>
                                <p class="text-muted small mb-0">Inventory movements will be recorded here automatically.</p>
                            </td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

            <!-- Global Enterprise Circular Pagination -->
            <div class="nl-pagination-wrapper" id="ledgerPaginationWrapper" style="display: none;">
                <div class="nl-pagination-info">
                    <span>Showing <strong id="pageStart">1</strong> to <strong id="pageEnd">10</strong> of <strong id="totalRows">${totalEntries}</strong> entries</span>
                    <div class="d-inline-flex align-items-center gap-2 ms-2">
                        <span class="text-muted small">Show:</span>
                        <select class="nl-page-size-select" id="pageSizeSelect" onchange="changePageSize(this.value)">
                            <option value="10" selected>10</option>
                            <option value="25">25</option>
                            <option value="50">50</option>
                            <option value="100">100</option>
                        </select>
                    </div>
                </div>
                <div class="nl-pagination-nav" id="pageNav"></div>
            </div>
        </div>
    </div>
</div>

<script>
    let allRows = [];
    let filteredRows = [];
    let currentPage = 1;
    let pageSize = 10;
    let currentType = 'ALL';

    function initLedger() {
        allRows = Array.from(document.querySelectorAll('.ledger-row'));
        filteredRows = [...allRows];
        updatePaginationDisplay();
    }

    function filterLedgerType(type) {
        currentType = type;
        document.querySelectorAll('.nav-tabs-custom .nav-link').forEach(el => el.classList.remove('active'));
        if (type === 'ALL') document.getElementById('tab-all').classList.add('active');
        if (type === 'IN') document.getElementById('tab-in').classList.add('active');
        if (type === 'OUT') document.getElementById('tab-out').classList.add('active');
        if (type === 'ADJUSTMENT') document.getElementById('tab-adj').classList.add('active');
        handleLedgerFilter();
    }

    function handleLedgerFilter() {
        const query = (document.getElementById('ledgerSearchInput').value || '').trim().toLowerCase();

        filteredRows = allRows.filter(row => {
            const prod = row.getAttribute('data-product') || '';
            const hsn = row.getAttribute('data-hsn') || '';
            const type = row.getAttribute('data-type') || '';
            const ref = row.getAttribute('data-ref') || '';

            const matchesQuery = !query || prod.includes(query) || hsn.includes(query) || ref.includes(query);
            const matchesType = (currentType === 'ALL') || 
                                (currentType === 'ADJUSTMENT' && (type === 'ADJUSTMENT' || type === 'ADJ')) ||
                                (type === currentType);

            return matchesQuery && matchesType;
        });

        currentPage = 1;
        const countEl = document.getElementById('filterCount');
        if (countEl) countEl.innerText = filteredRows.length;
        updatePaginationDisplay();
    }

    function changePageSize(size) {
        pageSize = parseInt(size) || 10;
        currentPage = 1;
        updatePaginationDisplay();
    }

    function updatePaginationDisplay() {
        const total = filteredRows.length;
        const totalPages = Math.ceil(total / pageSize) || 1;
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        const startIdx = (currentPage - 1) * pageSize;
        const endIdx = startIdx + pageSize;

        allRows.forEach(row => row.style.display = 'none');
        filteredRows.slice(startIdx, endIdx).forEach(row => row.style.display = '');

        const pageStartEl = document.getElementById('pageStart');
        const pageEndEl = document.getElementById('pageEnd');
        const totalRowsEl = document.getElementById('totalRows');
        const wrapper = document.getElementById('ledgerPaginationWrapper');

        if (pageStartEl) pageStartEl.innerText = total === 0 ? 0 : startIdx + 1;
        if (pageEndEl) pageEndEl.innerText = Math.min(endIdx, total);
        if (totalRowsEl) totalRowsEl.innerText = total;

        if (wrapper) wrapper.style.display = total > 0 ? 'flex' : 'none';

        renderPaginationButtons(totalPages);
    }

    // Smart Ellipsis Pagination Helper
    function getPaginationWindow(current, total) {
        if (total <= 7) {
            return Array.from({ length: total }, (_, i) => i + 1);
        }
        if (current <= 4) {
            return [1, 2, 3, 4, 5, '...', total];
        }
        if (current >= total - 3) {
            return [1, '...', total - 4, total - 3, total - 2, total - 1, total];
        }
        return [1, '...', current - 1, current, current + 1, '...', total];
    }

    function renderPaginationButtons(totalPages) {
        const nav = document.getElementById('pageNav');
        if (!nav) return;
        nav.innerHTML = '';
        if (totalPages <= 1) return;

        // Prev Button
        const prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'nl-page-btn nl-page-nav-btn' + (currentPage === 1 ? ' disabled' : '');
        prevBtn.disabled = (currentPage === 1);
        prevBtn.innerHTML = '<i class="ti ti-chevron-left"></i>';
        prevBtn.onclick = () => { if (currentPage > 1) { currentPage--; updatePaginationDisplay(); } };
        nav.appendChild(prevBtn);

        const pages = getPaginationWindow(currentPage, totalPages);
        pages.forEach(p => {
            if (p === '...') {
                const dots = document.createElement('span');
                dots.className = 'nl-page-dots';
                dots.innerText = '…';
                nav.appendChild(dots);
            } else {
                const btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'nl-page-btn nl-page-num' + (p === currentPage ? ' active' : '');
                btn.innerText = p;
                btn.onclick = () => { currentPage = p; updatePaginationDisplay(); };
                nav.appendChild(btn);
            }
        });

        // Next Button
        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'nl-page-btn nl-page-nav-btn' + (currentPage === totalPages ? ' disabled' : '');
        nextBtn.disabled = (currentPage === totalPages);
        nextBtn.innerHTML = '<i class="ti ti-chevron-right"></i>';
        nextBtn.onclick = () => { if (currentPage < totalPages) { currentPage++; updatePaginationDisplay(); } };
        nav.appendChild(nextBtn);
    }

    // Client-side Sorting
    let ledgerSortCol = -1;
    let ledgerSortAsc = true;
    function sortLedgerTable(colIndex) {
        if (ledgerSortCol === colIndex) ledgerSortAsc = !ledgerSortAsc;
        else { ledgerSortCol = colIndex; ledgerSortAsc = true; }
        filteredRows.sort((a, b) => {
            const cellA = a.cells[colIndex] ? a.cells[colIndex].innerText.trim() : '';
            const cellB = b.cells[colIndex] ? b.cells[colIndex].innerText.trim() : '';
            const numA = parseFloat(cellA.replace(/[^0-9.-]+/g, ''));
            const numB = parseFloat(cellB.replace(/[^0-9.-]+/g, ''));
            if (!isNaN(numA) && !isNaN(numB)) return ledgerSortAsc ? numA - numB : numB - numA;
            return ledgerSortAsc ? cellA.localeCompare(cellB) : cellB.localeCompare(cellA);
        });
        const tbody = document.getElementById('ledgerTableBody');
        filteredRows.forEach(row => tbody.appendChild(row));
        updatePaginationDisplay();
    }

    document.addEventListener('DOMContentLoaded', initLedger);
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
