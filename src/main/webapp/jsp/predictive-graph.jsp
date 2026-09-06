<%-- MVC2 (SRS 10.2): data and actions come from PredictiveGraphServlet (/predictive-graph). --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<jsp:include page="/jsp/layout/header.jsp" />

<!-- Include Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.9/dist/chart.umd.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/nl-chart-theme.js"></script>

<style>
    /* ==========================================================================
       PREDICTIVE GRAPH & DEMAND FORECASTING THEME (LIGHT & DARK MODE)
       ========================================================================== */

    /* Breadcrumbs */
    .custom-breadcrumb {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 13px;
        color: #64748B;
        margin-bottom: 16px;
    }
    .custom-breadcrumb a { color: #64748B; text-decoration: none; transition: color 0.15s ease; }
    .custom-breadcrumb a:hover { color: #FC8019; }
    .custom-breadcrumb i { font-size: 11px; color: #94A3B8; }
    .custom-breadcrumb .current { color: #FC8019; font-weight: 600; }

    /* Page Header */
    .predictive-page-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 24px;
        flex-wrap: wrap;
        gap: 16px;
    }
    .predictive-page-title {
        font-weight: 800;
        color: #0F172A;
        font-size: 24px;
        letter-spacing: -0.3px;
        margin-bottom: 4px;
    }
    .predictive-page-subtitle {
        color: #64748B;
        font-size: 13.5px;
        margin: 0;
    }

    /* Filter Form & Pill Dropdown */
    .predictive-filter-form {
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .predictive-filter-select-wrap {
        position: relative;
        width: 220px;
    }
    .predictive-filter-select-wrap .ts-wrapper {
        width: 100% !important;
        border: none !important;
        background: transparent !important;
        padding: 0 !important;
        box-shadow: none !important;
    }
    .predictive-filter-select-wrap .ts-control,
    .select-wrapper .form-select-custom,
    .predictive-filter-select-wrap select {
        appearance: none !important;
        -webkit-appearance: none !important;
        -moz-appearance: none !important;
        width: 100% !important;
        height: 42px !important;
        min-height: 42px !important;
        padding: 0 42px 0 20px !important;
        border: 1.5px solid #E2E8F0 !important;
        border-radius: 50px !important; /* Pill shaped */
        font-size: 13.5px !important;
        font-weight: 600 !important;
        color: #1E293B !important;
        background-color: #FFFFFF !important;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23FC8019' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
        background-repeat: no-repeat !important;
        background-position: right 16px center !important;
        background-size: 13px 11px !important;
        outline: none !important;
        transition: all 0.2s ease !important;
        cursor: pointer !important;
        display: flex !important;
        align-items: center !important;
        box-sizing: border-box !important;
    }
    .predictive-filter-select-wrap .ts-wrapper.single .ts-control::after {
        display: none !important; /* Hide TomSelect default caret */
    }
    .predictive-filter-select-wrap .ts-control .item {
        color: #1E293B !important;
        font-size: 13.5px !important;
        font-weight: 600 !important;
        line-height: 40px !important;
        padding: 0 !important;
        margin: 0 !important;
        white-space: nowrap !important;
    }
    .predictive-filter-select-wrap .ts-wrapper:hover .ts-control {
        border-color: #CBD5E1 !important;
    }
    .predictive-filter-select-wrap .ts-wrapper.focus .ts-control,
    .predictive-filter-select-wrap .ts-wrapper.dropdown-active .ts-control,
    .predictive-filter-select-wrap .ts-wrapper.input-active .ts-control,
    .select-wrapper .form-select-custom:focus,
    .predictive-filter-select-wrap select:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.15) !important;
    }
    .predictive-filter-select-wrap .ts-wrapper.dropdown-active .ts-control {
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23FC8019' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 11 6-6 6 6'/%3e%3c/svg%3e") !important;
    }

    /* Floating Custom Dropdown Popup Menu */
    .ts-dropdown {
        border: 1px solid #E2E8F0 !important;
        border-radius: 12px !important;
        box-shadow: 0 12px 32px rgba(15, 23, 42, 0.12), 0 4px 12px rgba(15, 23, 42, 0.06) !important;
        padding: 6px !important;
        background: #FFFFFF !important;
        margin-top: 4px !important;
        z-index: 100000000 !important;
    }
    .ts-dropdown .option {
        padding: 9px 14px !important;
        font-size: 13.5px !important;
        font-weight: 500 !important;
        border-radius: 8px !important;
        color: #334155 !important;
        cursor: pointer !important;
        transition: all 0.12s ease !important;
    }
    .ts-dropdown .option:hover,
    .ts-dropdown .option.active {
        background-color: #FFF2EB !important;
        color: #FC8019 !important;
        font-weight: 600 !important;
    }
    .ts-dropdown .option.selected {
        background-color: #FC8019 !important;
        color: #FFFFFF !important;
        font-weight: 700 !important;
    }
    .ts-dropdown .option.selected:hover,
    .ts-dropdown .option.selected.active {
        background-color: #E66F0F !important;
        color: #FFFFFF !important;
    }
    .btn-filter-apply {
        width: 42px;
        height: 42px;
        border-radius: 50%;
        border: none;
        background: #FC8019;
        color: #FFFFFF;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 16px;
        cursor: pointer;
        box-shadow: 0 2px 8px rgba(252, 128, 25, 0.28);
        transition: all 0.18s ease;
        flex-shrink: 0;
    }
    .btn-filter-apply:hover {
        background: #E66F0F;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.38);
    }

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

    /* 4 Executive KPI Cards */
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
        box-shadow: 0 1px 3px rgba(0,0,0,0.03);
        display: flex;
        align-items: center;
        justify-content: space-between;
        transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
    }
    .kpi-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(0,0,0,0.06);
        border-color: #CBD5E1;
    }
    .kpi-label {
        font-size: 11.5px;
        font-weight: 700;
        color: #64748B;
        margin-bottom: 6px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    .kpi-value {
        font-size: 22px;
        font-weight: 800;
        color: #0F172A;
        line-height: 1.1;
    }
    .kpi-val-orange { color: #FC8019 !important; }
    .kpi-val-blue { color: #2563EB !important; }
    .kpi-val-amber { color: #D97706 !important; }
    .kpi-val-green { color: #059669 !important; }

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
    .kpi-icon-pill.orange { background: #FFF0E5; color: #FC8019; }
    .kpi-icon-pill.amber { background: #FFFBEB; color: #D97706; }
    .kpi-icon-pill.green { background: #ECFDF5; color: #059669; }
    .kpi-icon-pill.blue { background: #EFF6FF; color: #2563EB; }

    /* Middle Row Cards (Forecast Chart & Update Form) */
    .predictive-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 16px;
        box-shadow: 0 1px 4px rgba(15, 23, 42, 0.04);
        height: 100%;
    }
    .predictive-card-body {
        padding: 24px;
    }
    .predictive-card-title {
        font-weight: 700;
        color: #0F172A;
        font-size: 16px;
        margin-bottom: 20px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .predictive-card-title i { color: #FC8019; font-size: 18px; }

    .price-update-desc {
        color: #64748B;
        font-size: 12.5px;
        margin-bottom: 20px;
        line-height: 1.5;
    }
    .form-label-muted {
        color: #64748B;
        font-weight: 700;
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: 0.4px;
        margin-bottom: 6px;
        display: block;
    }
    .form-input-themed {
        width: 100%;
        padding: 11px 16px;
        border-radius: 10px;
        border: 1.5px solid #E2E8F0;
        font-size: 13.5px;
        font-weight: 500;
        color: #1E293B;
        background: #FFFFFF;
        outline: none;
        transition: all 0.2s ease;
    }
    .form-input-themed:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .form-input-readonly {
        background: #F8FAFC;
        color: #475569;
    }

    .btn-update-price {
        background: #FC8019;
        color: #FFFFFF !important;
        border: none;
        width: 100%;
        padding: 13px 20px;
        border-radius: 50px !important; /* Pill shaped */
        font-weight: 700;
        font-size: 14px;
        cursor: pointer;
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.28);
        transition: all 0.18s ease;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
    }
    .btn-update-price:hover {
        background: #E66F0F;
        transform: translateY(-1px);
        box-shadow: 0 6px 16px rgba(252, 128, 25, 0.38);
    }

    /* Price Change Audit Trail Panel */
    .predictive-audit-panel {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 16px;
        box-shadow: 0 1px 4px rgba(15, 23, 42, 0.04);
        overflow: hidden;
        margin-top: 32px;
        margin-bottom: 24px;
    }
    .predictive-audit-toolbar {
        padding: 18px 24px;
        border-bottom: 1px solid #F1F5F9;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 16px;
        background: #FFFFFF;
    }
    .audit-toolbar-left {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .audit-title-icon {
        width: 42px;
        height: 42px;
        border-radius: 12px;
        background: #FFF0E5;
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        flex-shrink: 0;
    }
    .audit-title-text {
        font-size: 16px;
        font-weight: 800;
        color: #0F172A;
    }
    .audit-subtitle-text {
        font-size: 12.5px;
        color: #64748B;
    }
    .audit-toolbar-right {
        display: flex;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
    }
    .audit-search-wrap {
        position: relative;
        width: 260px;
    }
    .audit-search-wrap i {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #94A3B8;
        font-size: 15px;
        pointer-events: none;
    }
    .audit-search-input {
        width: 100%;
        height: 38px;
        border-radius: 50px;
        border: 1.5px solid #E2E8F0;
        padding: 0 32px 0 38px;
        font-size: 12.5px;
        font-weight: 500;
        color: #1E293B;
        background: #FFFFFF;
        outline: none;
        transition: all 0.2s ease;
    }
    .audit-search-input:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .audit-search-clear {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        color: #94A3B8;
        font-size: 14px;
        cursor: pointer;
        display: none;
    }
    .audit-counter-badge,
    .records-count-badge {
        font-size: 12px;
        font-weight: 600;
        color: #64748B;
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        padding: 6px 16px;
        border-radius: 50px;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        white-space: nowrap;
    }

    /* Standard Tracking Table Styling (Matching All Shipments) */
    .tracking-table,
    .predictive-audit-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
        margin: 0;
    }
    .tracking-table th,
    .predictive-audit-table th {
        font-size: 12px;
        color: #64748B;
        font-weight: 600;
        padding: 16px 24px;
        border-bottom: 1px solid #E2E8F0;
        text-align: left;
        background: #F9FAFB;
        vertical-align: middle;
        white-space: nowrap;
    }
    .tracking-table td,
    .predictive-audit-table td {
        padding: 16px 24px;
        font-size: 14px;
        color: #1E293B;
        font-weight: 500;
        border-bottom: 1px solid #E2E8F0;
        vertical-align: middle;
        background: transparent;
        transition: background-color 0.15s ease;
    }
    .tracking-table tbody tr:hover,
    .predictive-audit-table tbody tr:hover {
        background-color: #F9FAFB;
    }
    .tracking-table tbody tr:last-child td,
    .predictive-audit-table tbody tr:last-child td {
        border-bottom: none;
    }

    /* Badges & Cell Components */
    .audit-id-badge {
        font-family: monospace;
        font-size: 12px;
        font-weight: 700;
        color: #475569;
        background: #F1F5F9;
        padding: 4px 10px;
        border-radius: 6px;
        border: 1px solid #E2E8F0;
        display: inline-block;
        white-space: nowrap !important;
        letter-spacing: 0.3px;
        line-height: 1.2;
    }
    .profile-cell {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        font-weight: 700;
        color: #0F172A;
    }
    .profile-icon {
        width: 32px;
        height: 32px;
        border-radius: 8px;
        background: #FFF0E5;
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
    }
    .old-price-val {
        color: #94A3B8;
        text-decoration: line-through;
        font-size: 13px;
    }
    .new-price-val {
        color: #059669;
        font-weight: 800;
        font-size: 14px;
    }
    .variance-pill {
        font-size: 11.5px;
        font-weight: 700;
        padding: 3px 10px;
        border-radius: 50px;
        display: inline-flex;
        align-items: center;
        gap: 4px;
        white-space: nowrap;
    }
    .variance-pill.up { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }
    .variance-pill.down { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }
    .variance-pill.neutral { background: #F1F5F9; color: #64748B; border: 1px solid #E2E8F0; }

    .reason-cell {
        color: #475569;
        font-size: 13px;
        display: flex;
        align-items: center;
        gap: 6px;
        max-width: 320px;
    }
    .reason-cell i { color: #FC8019; font-size: 14px; flex-shrink: 0; }
    .user-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        font-size: 13px;
        font-weight: 600;
        color: #334155;
    }
    .user-badge i { color: #059669; }
    .timestamp-val {
        color: #64748B;
        font-size: 12.5px;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }

    .empty-audit-cell {
        padding: 48px 20px !important;
        text-align: center;
    }
    .empty-audit-box {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 8px;
    }
    .empty-audit-icon {
        width: 52px;
        height: 52px;
        border-radius: 50%;
        background: #FFF0E5;
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 24px;
        margin-bottom: 4px;
    }
    .empty-audit-title {
        font-size: 15px;
        font-weight: 700;
        color: #0F172A;
    }
    .empty-audit-desc {
        font-size: 13px;
        color: #64748B;
        max-width: 420px;
    }

    /* Global Enterprise Circular Pagination */
    .nl-pagination-wrapper {
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 16px;
        padding: 16px 24px;
        background: #FFFFFF;
        border-top: 1px solid #F1F3F6;
    }
    .nl-pagination-info {
        display: flex;
        align-items: center;
        gap: 12px;
        font-size: 13px;
        color: #64748B;
    }
    .nl-pagination-info strong {
        color: #1F2937;
        font-weight: 700;
    }
    .nl-pagination-nav {
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .nl-page-btn {
        min-width: 36px;
        height: 36px;
        padding: 0 16px;
        border-radius: 50px !important;
        border: 1.5px solid #E2E8F0;
        background: #FFFFFF;
        color: #4B5563;
        font-size: 13px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 5px;
        cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        user-select: none;
    }
    .nl-page-btn.nl-page-num {
        width: 36px !important;
        min-width: 36px !important;
        max-width: 36px !important;
        height: 36px !important;
        padding: 0 !important;
        border-radius: 50% !important; /* Pure Circular */
    }
    .nl-page-btn:hover:not(.disabled) {
        border-color: #FC8019;
        color: #FC8019;
        background: #FFF0E5;
    }
    .nl-page-btn.active {
        background: #FC8019 !important;
        border-color: #FC8019 !important;
        color: #FFFFFF !important;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.3) !important;
    }
    .nl-page-btn.disabled {
        opacity: 0.45;
        cursor: not-allowed;
        pointer-events: none;
    }

    /* Suppress card tools buttons (Export/Fullscreen icons) */
    .nl-card-tools,
    .no-card-tools .nl-card-tools,
    [data-no-tools="true"] .nl-card-tools {
        display: none !important;
    }

    /* ==========================================================================
       DARK THEME STYLES [data-theme="dark"]
       ========================================================================== */

    [data-theme="dark"] .predictive-page-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .predictive-page-subtitle {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .custom-breadcrumb a {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .custom-breadcrumb a:hover {
        color: #FC8019 !important;
    }
    [data-theme="dark"] .custom-breadcrumb span {
        color: #64748B !important;
    }
    [data-theme="dark"] .custom-breadcrumb .current {
        color: #FC8019 !important;
    }

    /* Dropdown in Dark Mode */
    [data-theme="dark"] .predictive-filter-select-wrap .ts-control,
    [data-theme="dark"] .select-wrapper .form-select-custom,
    [data-theme="dark"] .predictive-filter-select-wrap select {
        background-color: #151F28 !important;
        border: 1.5px solid #2D3F4D !important;
        color: #F8FAFC !important;
        border-radius: 50px !important;
        box-shadow: none !important;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23FC8019' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
    }
    [data-theme="dark"] .predictive-filter-select-wrap .ts-control .item {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .predictive-filter-select-wrap .ts-wrapper:hover .ts-control {
        border-color: #3E5468 !important;
    }
    [data-theme="dark"] .predictive-filter-select-wrap .ts-wrapper.focus .ts-control,
    [data-theme="dark"] .predictive-filter-select-wrap .ts-wrapper.dropdown-active .ts-control,
    [data-theme="dark"] .predictive-filter-select-wrap .ts-wrapper.input-active .ts-control,
    [data-theme="dark"] .select-wrapper .form-select-custom:focus,
    [data-theme="dark"] .predictive-filter-select-wrap select:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.25) !important;
    }
    [data-theme="dark"] .predictive-filter-select-wrap .ts-wrapper.dropdown-active .ts-control {
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23FC8019' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 11 6-6 6 6'/%3e%3c/svg%3e") !important;
    }

    [data-theme="dark"] .ts-dropdown {
        background: #151F28 !important;
        border: 1px solid #2D3F4D !important;
        box-shadow: 0 14px 36px rgba(0, 0, 0, 0.55), 0 4px 12px rgba(0, 0, 0, 0.35) !important;
        color: #CBD5E1 !important;
        border-radius: 12px !important;
        padding: 6px !important;
    }
    [data-theme="dark"] .ts-dropdown .option {
        color: #94A3B8 !important;
        font-size: 13.5px !important;
        font-weight: 500 !important;
        padding: 9px 14px !important;
        border-radius: 8px !important;
        border-bottom: none !important;
        background: transparent !important;
        transition: all 0.12s ease !important;
        cursor: pointer !important;
    }
    [data-theme="dark"] .ts-dropdown .option:hover,
    [data-theme="dark"] .ts-dropdown .option.active,
    [data-theme="dark"] .ts-dropdown .active {
        background-color: #1E2D3D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .ts-dropdown .option.selected {
        background-color: #FC8019 !important;
        color: #FFFFFF !important;
        font-weight: 700 !important;
    }
    [data-theme="dark"] .ts-dropdown .option.selected:hover,
    [data-theme="dark"] .ts-dropdown .option.selected.active {
        background-color: #E66F0F !important;
        color: #FFFFFF !important;
    }

    /* KPI Cards in Dark Mode */
    [data-theme="dark"] .kpi-card {
        background: #151F28 !important;
        border: 1px solid #22303A !important;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3) !important;
    }
    [data-theme="dark"] .kpi-card:hover {
        border-color: #2D3F4D !important;
        box-shadow: 0 6px 16px rgba(0, 0, 0, 0.45) !important;
    }
    [data-theme="dark"] .kpi-label {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .kpi-value {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .kpi-val-orange { color: #FC8019 !important; }
    [data-theme="dark"] .kpi-val-blue { color: #60A5FA !important; }
    [data-theme="dark"] .kpi-val-amber { color: #FBBF24 !important; }
    [data-theme="dark"] .kpi-val-green { color: #34D399 !important; }

    [data-theme="dark"] .kpi-icon-pill.orange {
        background: rgba(252, 128, 25, 0.15) !important;
        color: #FC8019 !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .kpi-icon-pill.amber {
        background: rgba(245, 158, 11, 0.15) !important;
        color: #FBBF24 !important;
        border: 1px solid rgba(245, 158, 11, 0.3) !important;
    }
    [data-theme="dark"] .kpi-icon-pill.green {
        background: rgba(16, 185, 129, 0.15) !important;
        color: #34D399 !important;
        border: 1px solid rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .kpi-icon-pill.blue {
        background: rgba(59, 130, 246, 0.15) !important;
        color: #60A5FA !important;
        border: 1px solid rgba(59, 130, 246, 0.3) !important;
    }

    /* Middle Row Cards in Dark Mode */
    [data-theme="dark"] .predictive-card {
        background: #151F28 !important;
        border-color: #22303A !important;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3) !important;
    }
    [data-theme="dark"] .predictive-card-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .price-update-desc {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .form-label-muted {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .form-input-themed {
        background: #0E151C !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .form-input-themed:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.22) !important;
    }
    [data-theme="dark"] .form-input-themed::placeholder {
        color: #64748B !important;
    }
    [data-theme="dark"] .form-input-readonly {
        background: #0B1117 !important;
        border-color: #22303A !important;
        color: #94A3B8 !important;
    }

    /* Table Panel in Dark Mode */
    [data-theme="dark"] .predictive-audit-panel {
        background: #151F28 !important;
        border-color: #22303A !important;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3) !important;
    }
    [data-theme="dark"] .predictive-audit-toolbar {
        background: #151F28 !important;
        border-bottom: 1px solid #22303A !important;
    }
    [data-theme="dark"] .audit-title-icon {
        background: rgba(252, 128, 25, 0.15) !important;
        color: #FC8019 !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .audit-title-text {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .audit-subtitle-text {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .audit-search-input {
        background: #0E151C !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .audit-search-input:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.22) !important;
    }
    [data-theme="dark"] .audit-counter-badge,
    [data-theme="dark"] .records-count-badge {
        background: #0E151C !important;
        border-color: #2D3F4D !important;
        color: #94A3B8 !important;
    }

    /* Table Header & Rows in Dark Mode (Matching All Shipments) */
    [data-theme="dark"] .tracking-table th,
    [data-theme="dark"] .predictive-audit-table th {
        background-color: #0E151C !important;
        color: #94A3B8 !important;
        border-bottom: 1px solid #22303A !important;
    }
    [data-theme="dark"] .tracking-table td,
    [data-theme="dark"] .predictive-audit-table td {
        background-color: transparent !important;
        color: #F8FAFC !important;
        border-bottom: 1px solid #22303A !important;
    }
    [data-theme="dark"] .tracking-table tbody tr:hover,
    [data-theme="dark"] .predictive-audit-table tbody tr:hover {
        background-color: rgba(255, 255, 255, 0.03) !important;
    }
    [data-theme="dark"] .tracking-table tbody tr:last-child td,
    [data-theme="dark"] .predictive-audit-table tbody tr:last-child td {
        border-bottom: none !important;
    }

    [data-theme="dark"] .audit-id-badge {
        background: #0E151C !important;
        border-color: #2D3F4D !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .profile-cell {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .profile-icon {
        background: rgba(252, 128, 25, 0.15) !important;
        color: #FC8019 !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .old-price-val {
        color: #64748B !important;
    }
    [data-theme="dark"] .new-price-val {
        color: #34D399 !important;
    }
    [data-theme="dark"] .variance-pill.up {
        background: rgba(16, 185, 129, 0.15) !important;
        color: #34D399 !important;
        border: 1px solid rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .variance-pill.down {
        background: rgba(239, 68, 68, 0.15) !important;
        color: #F87171 !important;
        border: 1px solid rgba(239, 68, 68, 0.3) !important;
    }
    [data-theme="dark"] .variance-pill.neutral {
        background: #1E293B !important;
        color: #94A3B8 !important;
        border: 1px solid #334155 !important;
    }
    [data-theme="dark"] .reason-cell {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .user-badge {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .timestamp-val {
        color: #94A3B8 !important;
    }

    /* Pagination in Dark Mode */
    [data-theme="dark"] .nl-pagination-wrapper {
        background: #151F28 !important;
        border-top: 1px solid #22303A !important;
    }
    [data-theme="dark"] .nl-pagination-info {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .nl-pagination-info strong {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .nl-page-size-select {
        background: #0E151C !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .nl-page-btn {
        background-color: #0E151C !important;
        border-color: #2D3F4D !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .nl-page-btn:hover:not(.disabled) {
        background-color: #1E293B !important;
        border-color: #475569 !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .nl-page-btn.active {
        background-color: #FC8019 !important;
        border-color: #FC8019 !important;
        color: #FFFFFF !important;
    }
    [data-theme="dark"] .nl-page-btn.disabled {
        background-color: #0B1117 !important;
        border-color: #1E293B !important;
        color: #475569 !important;
    }
</style>

<div class="container-fluid py-4">
    <!-- Breadcrumbs -->
    <div class="custom-breadcrumb">
        <a href="${pageContext.request.contextPath}/dashboard"><i class="ti ti-smart-home"></i> Dashboard</a>
        <i class="ti ti-chevron-right"></i>
        <span>Pricing &amp; Governance</span>
        <i class="ti ti-chevron-right"></i>
        <span class="current">Advance Predictive Graph</span>
    </div>

    <!-- Page Header & Filter Form -->
    <div class="predictive-page-header">
        <div>
            <h2 class="predictive-page-title">Advance Predictive Graph</h2>
            <p class="predictive-page-subtitle">Demand Forecasting &amp; Price Trends</p>
        </div>

        <form action="<c:url value='/predictive-graph'/>" method="GET" class="predictive-filter-form">
            <div class="select-wrapper predictive-filter-select-wrap">
                <select name="type" id="predictiveTypeSelect" class="form-select-custom" onchange="if(this.form) this.form.submit();">
                    <option value="Dry" ${selectedType == 'Dry' ? 'selected' : ''}>Dry Containers</option>
                    <option value="Reefer" ${selectedType == 'Reefer' ? 'selected' : ''}>Reefer Containers</option>
                    <option value="Open Top" ${selectedType == 'Open Top' ? 'selected' : ''}>Open Top Containers</option>
                </select>
            </div>
            <button class="btn-filter-apply" type="submit" title="Apply Filter">
                <i class="ti ti-filter"></i>
            </button>
        </form>
    </div>

    <c:if test="${not empty sessionScope.successMessage}">
        <div class="custom-alert success">
            <i class="ti ti-circle-check" style="font-size: 18px;"></i>
            <span>${sessionScope.successMessage}</span>
        </div>
        <c:remove var="successMessage" scope="session" />
    </c:if>

    <!-- 4 Executive KPI Cards -->
    <div class="kpi-grid">
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Container Type</div>
                <div class="kpi-value kpi-val-orange">${selectedType}</div>
            </div>
            <div class="kpi-icon-pill orange"><i class="ti ti-box"></i></div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Current Base Price</div>
                <div class="kpi-value kpi-val-blue">$<fmt:formatNumber value="${currentBasePrice}" pattern="#,##0.00"/></div>
            </div>
            <div class="kpi-icon-pill blue"><i class="ti ti-currency-dollar"></i></div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Avg Forecasted Demand</div>
                <div class="kpi-value kpi-val-amber" id="kpiAvgDemand">--</div>
            </div>
            <div class="kpi-icon-pill amber"><i class="ti ti-chart-histogram"></i></div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Avg Forecasted Price</div>
                <div class="kpi-value kpi-val-green" id="kpiAvgPrice">--</div>
            </div>
            <div class="kpi-icon-pill green"><i class="ti ti-trending-up"></i></div>
        </div>
    </div>

    <!-- Middle Row: Forecast Chart & Base Price Form -->
    <div class="row g-4 mb-4">
        <div class="col-lg-8">
            <div class="predictive-card card tracking-card no-card-tools" data-no-tools="true" style="border-radius: 16px;">
                <div class="predictive-card-body">
                    <div class="predictive-card-title">
                        <i class="ti ti-chart-line"></i> Forecasted Demand &amp; Price Trend (Next 6 Periods)
                    </div>
                    <div style="height: 400px; position: relative;">
                        <canvas id="predictiveChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-lg-4">
            <div class="predictive-card card tracking-card no-card-tools" data-no-tools="true" style="border-radius: 16px;">
                <div class="predictive-card-body">
                    <div class="predictive-card-title">
                        <i class="ti ti-edit"></i> Update Base Price
                    </div>
                    <p class="price-update-desc">Every price change shall be logged with old value, new value, reason, timestamp and responsible user.</p>

                    <form action="<c:url value='/predictive-graph'/>" method="POST">
                        <input type="hidden" name="pricingId" value="${pricingId}">
                        <input type="hidden" name="containerType" value="${selectedType}">

                        <div class="mb-3">
                            <label class="form-label-muted">Current Base Price ($)</label>
                            <input type="text" class="form-input-themed form-input-readonly" value="$<fmt:formatNumber value="${currentBasePrice}" pattern="#,##0.00"/>" readonly>
                        </div>

                        <div class="mb-3">
                            <label class="form-label-muted">New Base Price ($)</label>
                            <input type="number" step="0.01" name="newPrice" class="form-input-themed" required placeholder="Enter new price">
                        </div>

                        <div class="mb-4">
                            <label class="form-label-muted">Reason for Change</label>
                            <textarea name="reason" class="form-input-themed" required rows="3" placeholder="e.g. Due to upcoming peak season" style="resize: vertical;"></textarea>
                        </div>

                        <button type="submit" class="btn-update-price">
                            <i class="ti ti-device-floppy"></i> Update Price &amp; Log Audit
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Price Change Audit Trail Table (FR3.7) -->
    <div class="predictive-audit-panel card tracking-card no-card-tools" data-no-tools="true" style="padding: 0; overflow: hidden; border-radius: 16px;">
        <div class="predictive-audit-toolbar">
            <div class="audit-toolbar-left">
                <div class="audit-title-icon"><i class="ti ti-history"></i></div>
                <div>
                    <div class="audit-title-text">Price Change Audit Trail &amp; Rate History</div>
                    <div class="audit-subtitle-text">Immutable historical ledger of rate adjustments, variance, and officer audit records for <strong><c:out value="${empty selectedType ? 'Dry' : selectedType}"/></strong> containers</div>
                </div>
            </div>
            <div class="audit-toolbar-right">
                <div class="audit-search-wrap">
                    <i class="ti ti-search"></i>
                    <input type="text" id="predictiveAuditSearch" class="audit-search-input" placeholder="Search reason, officer, profile..." oninput="handleAuditSearch()">
                    <button type="button" id="auditSearchClearBtn" class="audit-search-clear" onclick="clearAuditSearch()">&times;</button>
                </div>
                <div class="audit-counter-badge records-count-badge" id="auditCountBadge">
                    <i class="ti ti-list"></i> Showing ${auditHistory.size()} of ${auditHistory.size()} Logs
                </div>
            </div>
        </div>

        <div class="table-responsive tracking-table-responsive">
            <table class="tracking-table predictive-audit-table" id="predictiveAuditTable">
                <thead>
                    <tr>
                        <th style="width: 130px; min-width: 130px; white-space: nowrap;"><i class="ti ti-hash"></i> Audit ID</th>
                        <th><i class="ti ti-box"></i> Container Profile</th>
                        <th><i class="ti ti-tag"></i> Previous Base Price</th>
                        <th><i class="ti ti-tag-starred"></i> Updated Base Price</th>
                        <th><i class="ti ti-trending-up"></i> Rate Variance</th>
                        <th><i class="ti ti-message-2"></i> Reason for Change</th>
                        <th><i class="ti ti-user"></i> Changed By</th>
                        <th style="text-align: right;"><i class="ti ti-calendar-time"></i> Timestamp</th>
                    </tr>
                </thead>
                <tbody id="predictiveAuditTbody">
                    <c:forEach var="a" items="${auditHistory}">
                        <c:set var="diff" value="${a.newPrice - a.oldPrice}"/>
                        <tr class="audit-row" data-search="${a.auditId} ${a.containerProfile} ${a.reason.toLowerCase()} ${a.changedByName.toLowerCase()}">
                            <td style="white-space: nowrap;"><span class="audit-id-badge">#AUD-${a.auditId}</span></td>
                            <td>
                                <div class="profile-cell">
                                    <span class="profile-icon"><i class="ti ti-box-seam"></i></span>
                                    <span><c:out value="${empty a.containerProfile ? selectedType.concat(' Container') : a.containerProfile}"/></span>
                                </div>
                            </td>
                            <td><span class="old-price-val">$<fmt:formatNumber value="${a.oldPrice}" pattern="#,##0.00"/></span></td>
                            <td><span class="new-price-val">$<fmt:formatNumber value="${a.newPrice}" pattern="#,##0.00"/></span></td>
                            <td>
                                <c:choose>
                                    <c:when test="${diff > 0}">
                                        <span class="variance-pill up"><i class="ti ti-arrow-up-right"></i> +$<fmt:formatNumber value="${diff}" pattern="#,##0.00"/></span>
                                    </c:when>
                                    <c:when test="${diff < 0}">
                                        <span class="variance-pill down"><i class="ti ti-arrow-down-right"></i> -$<fmt:formatNumber value="${-diff}" pattern="#,##0.00"/></span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="variance-pill neutral"><i class="ti ti-minus"></i> $0.00</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="reason-cell" title="<c:out value="${a.reason}"/>">
                                    <i class="ti ti-quote"></i>
                                    <span><c:out value="${empty a.reason ? 'Periodic tariff adjustment' : a.reason}"/></span>
                                </div>
                            </td>
                            <td>
                                <span class="user-badge">
                                    <i class="ti ti-user-check"></i> <c:out value="${empty a.changedByName ? 'system_admin' : a.changedByName}"/>
                                </span>
                            </td>
                            <td style="text-align: right; white-space: nowrap;">
                                <span class="timestamp-val">
                                    <i class="ti ti-clock"></i> <fmt:formatDate value="${a.changedAt}" pattern="dd MMM yyyy, HH:mm"/>
                                </span>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty auditHistory}">
                        <tr id="emptyAuditRow">
                            <td colspan="8" class="empty-audit-cell">
                                <div class="empty-audit-box">
                                    <div class="empty-audit-icon"><i class="ti ti-history"></i></div>
                                    <div class="empty-audit-title">No Price Adjustments Logged Yet</div>
                                    <div class="empty-audit-desc">Use the Update Base Price form above to adjust the tariff rate and generate an immutable audit log trail.</div>
                                </div>
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <div class="nl-pagination-wrapper" id="predictiveAuditPagination">
            <div class="nl-pagination-info">
                <span>Showing <strong id="auditPageStart">1</strong> to <strong id="auditPageEnd">10</strong> of <strong id="auditTotalRows">${auditHistory.size()}</strong> records</span>
                <div class="d-inline-flex align-items-center gap-2 ms-2">
                    <span style="color: #94A3B8; font-size: 12.5px;">Rows:</span>
                    <select id="predictiveAuditPageSize" class="nl-page-size-select no-custom-select" onchange="changeAuditPageSize(this.value)">
                        <option value="5">5</option>
                        <option value="10" selected>10</option>
                        <option value="25">25</option>
                        <option value="ALL">All</option>
                    </select>
                </div>
            </div>
            <div class="nl-pagination-nav" id="auditPageNav"></div>
        </div>
    </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    // ==========================================
    // 1. KPI DERIVED AVERAGES
    // ==========================================
    const demandData = ${chartDemand};
    const priceData = ${chartPrice};
    const labels = ${chartLabels};

    const avg = (arr) => (arr && arr.length) ? (arr.reduce((a, b) => a + b, 0) / arr.length) : 0;
    const avgDemandEl = document.getElementById('kpiAvgDemand');
    const avgPriceEl = document.getElementById('kpiAvgPrice');
    if (avgDemandEl) avgDemandEl.textContent = Math.round(avg(demandData)).toLocaleString();
    if (avgPriceEl) avgPriceEl.textContent = '$' + avg(priceData).toFixed(2);

    // ==========================================
    // 2. THEME-AWARE CHART.JS
    // ==========================================
    function getChartThemeColors() {
        const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
        return {
            isDark: isDark,
            text: isDark ? '#94A3B8' : '#64748B',
            grid: isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(15, 23, 42, 0.06)',
            title: isDark ? '#F8FAFC' : '#1E293B'
        };
    }

    const tc = getChartThemeColors();
    const ctx = document.getElementById('predictiveChart').getContext('2d');

    const predictiveChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Forecasted Demand (Units)',
                    data: demandData,
                    borderColor: '#FC8019',
                    backgroundColor: 'rgba(252, 128, 25, 0.12)',
                    fill: true,
                    borderWidth: 2.5,
                    tension: 0.35,
                    pointRadius: 4,
                    pointHoverRadius: 6,
                    yAxisID: 'y'
                },
                {
                    label: 'Forecasted Price ($)',
                    data: priceData,
                    borderColor: '#10b981',
                    backgroundColor: 'rgba(16, 185, 129, 0.08)',
                    borderWidth: 2.5,
                    borderDash: [5, 5],
                    tension: 0.35,
                    pointRadius: 4,
                    pointHoverRadius: 6,
                    yAxisID: 'y1'
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
                mode: 'index',
                intersect: false
            },
            plugins: {
                legend: {
                    position: 'top',
                    labels: {
                        color: tc.text,
                        font: { family: "'Inter', sans-serif", size: 12.5, weight: '600' }
                    }
                }
            },
            scales: {
                x: {
                    grid: { color: tc.grid },
                    ticks: { color: tc.text, font: { family: "'Inter', sans-serif", size: 11.5 } }
                },
                y: {
                    type: 'linear',
                    display: true,
                    position: 'left',
                    title: {
                        display: true,
                        text: 'Demand',
                        color: tc.text,
                        font: { family: "'Inter', sans-serif", size: 12, weight: '700' }
                    },
                    grid: { color: tc.grid },
                    ticks: { color: tc.text, font: { family: "'Inter', sans-serif", size: 11.5 } }
                },
                y1: {
                    type: 'linear',
                    display: true,
                    position: 'right',
                    title: {
                        display: true,
                        text: 'Price ($)',
                        color: tc.text,
                        font: { family: "'Inter', sans-serif", size: 12, weight: '700' }
                    },
                    grid: { drawOnChartArea: false },
                    ticks: { color: tc.text, font: { family: "'Inter', sans-serif", size: 11.5 } }
                }
            }
        }
    });

    window.addEventListener('themeChanged', function() {
        if (!predictiveChart) return;
        const newTc = getChartThemeColors();
        predictiveChart.options.plugins.legend.labels.color = newTc.text;
        predictiveChart.options.scales.x.grid.color = newTc.grid;
        predictiveChart.options.scales.x.ticks.color = newTc.text;
        predictiveChart.options.scales.y.title.color = newTc.text;
        predictiveChart.options.scales.y.grid.color = newTc.grid;
        predictiveChart.options.scales.y.ticks.color = newTc.text;
        predictiveChart.options.scales.y1.title.color = newTc.text;
        predictiveChart.options.scales.y1.ticks.color = newTc.text;
        predictiveChart.update();
    });

    // ==========================================
    // 3. AUDIT TRAIL PAGINATION & SEARCH
    // ==========================================
    window.allAuditRows = Array.from(document.querySelectorAll('#predictiveAuditTbody .audit-row'));
    window.matchingAuditRows = window.allAuditRows.slice();
    window.currentAuditPage = 1;
    window.auditPageSize = 10;

    window.handleAuditSearch = function() {
        const query = (document.getElementById('predictiveAuditSearch').value || '').trim().toLowerCase();
        const clearBtn = document.getElementById('auditSearchClearBtn');
        if (clearBtn) clearBtn.style.display = query ? 'block' : 'none';

        window.matchingAuditRows = window.allAuditRows.filter(row => {
            const s = (row.getAttribute('data-search') || '').toLowerCase();
            return !query || s.includes(query);
        });

        window.currentAuditPage = 1;
        renderAuditPage();
    };

    window.clearAuditSearch = function() {
        const input = document.getElementById('predictiveAuditSearch');
        if (input) input.value = '';
        handleAuditSearch();
        if (input) input.focus();
    };

    window.changeAuditPageSize = function(val) {
        if (val === 'ALL') {
            window.auditPageSize = 999999;
        } else {
            window.auditPageSize = parseInt(val, 10) || 10;
        }
        window.currentAuditPage = 1;
        renderAuditPage();
    };

    window.changeAuditPage = function(delta) {
        window.currentAuditPage += delta;
        renderAuditPage();
    };

    function renderAuditPage() {
        window.allAuditRows.forEach(r => r.style.display = 'none');
        const total = window.matchingAuditRows.length;
        const totalPages = Math.max(1, Math.ceil(total / window.auditPageSize));
        if (window.currentAuditPage > totalPages) window.currentAuditPage = totalPages;

        const start = (window.currentAuditPage - 1) * window.auditPageSize;
        const end = Math.min(start + window.auditPageSize, total);

        for (let i = start; i < end; i++) {
            window.matchingAuditRows[i].style.display = '';
        }

        const pageStartEl = document.getElementById('auditPageStart');
        const pageEndEl = document.getElementById('auditPageEnd');
        const totalRowsEl = document.getElementById('auditTotalRows');
        if (pageStartEl) pageStartEl.textContent = total === 0 ? 0 : start + 1;
        if (pageEndEl) pageEndEl.textContent = end;
        if (totalRowsEl) totalRowsEl.textContent = total;

        const badgeEl = document.getElementById('auditCountBadge');
        if (badgeEl) {
            badgeEl.innerHTML = '<i class="ti ti-list"></i> Showing ' + total + ' of ' + window.allAuditRows.length + ' Logs';
        }

        const nav = document.getElementById('auditPageNav');
        if (nav) {
            nav.innerHTML = '';
            function createBtn(label, page, disabled, active) {
                const b = document.createElement('button');
                b.type = 'button';
                const isNav = (label === 'Prev' || label === 'Next');
                b.className = 'nl-page-btn' + (isNav ? ' nl-page-nav-btn' : ' nl-page-num') + (active ? ' active' : '') + (disabled ? ' disabled' : '');
                b.textContent = label;
                if (!disabled) b.onclick = function() { window.currentAuditPage = page; renderAuditPage(); };
                return b;
            }

            nav.appendChild(createBtn('Prev', window.currentAuditPage - 1, window.currentAuditPage <= 1, false));

            for (let p = 1; p <= totalPages; p++) {
                if (totalPages > 7 && p !== 1 && p !== totalPages && Math.abs(p - window.currentAuditPage) > 1) {
                    if (p === 2 || p === totalPages - 1) {
                        const s = document.createElement('span');
                        s.textContent = '...';
                        s.style.padding = '0 4px';
                        s.style.color = '#94A3B8';
                        nav.appendChild(s);
                    }
                    continue;
                }
                nav.appendChild(createBtn(String(p), p, false, p === window.currentAuditPage));
            }

            nav.appendChild(createBtn('Next', window.currentAuditPage + 1, window.currentAuditPage >= totalPages, false));
        }
    }

    const typeSelect = document.getElementById('predictiveTypeSelect');
    if (typeSelect) {
        typeSelect.addEventListener('change', function() {
            if (this.form) this.form.submit();
        });
    }

    renderAuditPage();
});
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
