<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%-- MVC2 (SRS 10.2): data and actions come from PortServlet (/ports).
     The inline controller block that used to live here re-queried the DAO
     with no tenant scope whenever the JSP was opened directly. --%>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* ==========================================================================
       GLOBAL PORTS & HARBOR TERMINAL DIRECTORY (SWIGGY ORANGE ENTERPRISE)
       ========================================================================== */
    .ports-page-container {
        padding: 0 4px 40px;
    }
    .custom-breadcrumb {
        display: flex; align-items: center; gap: 8px; font-size: 13px; color: #64748B; margin-bottom: 16px;
    }
    .custom-breadcrumb a { color: #64748B; text-decoration: none; transition: color 0.15s ease; }
    .custom-breadcrumb a:hover { color: #FC8019; }
    .custom-breadcrumb i { font-size: 11px; color: #94A3B8; }
    .custom-breadcrumb .current { color: #FC8019; font-weight: 600; }

    /* Telemetry Header Card (Frameless - Outer Container Removed) */
    .telemetry-header-card {
        background: transparent !important;
        border: none !important;
        border-radius: 0 !important;
        padding: 4px 0 20px 0 !important;
        box-shadow: none !important;
        margin-bottom: 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 20px;
    }
    .telemetry-header-left { display: flex; align-items: center; gap: 16px; }
    .telemetry-icon-box {
        width: 52px; height: 52px; border-radius: 50% !important;
        background: #FFF0E5;
        border: 1px solid rgba(252, 128, 25, 0.25);
        display: flex; align-items: center; justify-content: center;
        color: #FC8019; font-size: 26px; flex-shrink: 0;
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.15);
    }
    .telemetry-title { font-size: 20px; font-weight: 700; color: #0F172A; margin: 0 0 4px; letter-spacing: -0.3px; }
    .telemetry-desc { font-size: 13.5px; color: #64748B; margin: 0; }
    .telemetry-actions { display: flex; align-items: center; gap: 12px; }

    .btn-register-primary {
        background: #FC8019;
        color: #FFFFFF !important; font-weight: 600; font-size: 13.5px;
        padding: 10px 22px; border-radius: 50px !important; border: none;
        display: inline-flex; align-items: center; gap: 8px;
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.28);
        transition: all 0.2s ease; cursor: pointer; text-decoration: none;
    }
    .btn-register-primary:hover {
        background: #E67012;
        transform: translateY(-1px);
        box-shadow: 0 6px 16px rgba(252, 128, 25, 0.36);
        color: #FFFFFF !important;
    }
    .btn-register-primary:active { transform: translateY(0); }

    /* KPI Cards Grid */
    .kpi-grid {
        display: grid; grid-template-columns: repeat(4, 1fr); gap: 18px; margin-bottom: 24px;
    }
    @media (max-width: 1024px) { .kpi-grid { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 640px) { .kpi-grid { grid-template-columns: 1fr; } }

    .kpi-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 14px; padding: 18px 20px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03); transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
        display: flex; flex-direction: column; justify-content: space-between;
    }
    .kpi-card:hover {
        transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,0,0,0.06); border-color: #CBD5E1;
    }
    .kpi-card-inner { display: flex; align-items: center; justify-content: space-between; }
    .kpi-label { font-size: 12px; font-weight: 600; color: #64748B; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.4px; }
    .kpi-value { font-size: 24px; font-weight: 800; color: #0F172A; line-height: 1; }
    .kpi-badge {
        display: inline-flex; align-items: center; gap: 5px; font-size: 11.5px; font-weight: 600;
        padding: 4px 10px; border-radius: 50px !important; margin-top: 8px; width: fit-content;
    }
    .kpi-badge-orange { background: #FFF0E5; color: #FC8019; border: 1px solid rgba(252, 128, 25, 0.25); }
    .kpi-badge-blue { background: #EFF6FF; color: #2563EB; border: 1px solid rgba(37, 99, 235, 0.25); }
    .kpi-badge-green { background: #ECFDF5; color: #059669; border: 1px solid rgba(5, 150, 105, 0.25); }
    .kpi-badge-purple { background: #F5F3FF; color: #7C3AED; border: 1px solid rgba(124, 58, 237, 0.25); }

    .kpi-icon-wrap {
        width: 44px; height: 44px; border-radius: 50% !important; display: flex; align-items: center; justify-content: center;
        font-size: 22px; flex-shrink: 0;
    }
    .kpi-icon-orange { background: #FFF0E5; color: #FC8019; }
    .kpi-icon-blue { background: #EFF6FF; color: #2563EB; }
    .kpi-icon-green { background: #ECFDF5; color: #059669; }
    .kpi-icon-purple { background: #F5F3FF; color: #7C3AED; }

    /* Directory Main Card & Toolbar (Matching All Shipments & Rate Governance) */
    .ports-table-panel,
    .ports-main-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 16px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04); overflow: hidden; margin-bottom: 30px;
    }
    .toolbar-bar {
        padding: 18px 24px; border-bottom: 1px solid #F1F5F9;
        display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 16px;
        background: #FFFFFF;
    }
    .toolbar-left { display: flex; align-items: center; gap: 14px; flex-wrap: wrap; flex: 1; }

    .table-search-box {
        position: relative; width: 320px;
    }
    .table-search-box i {
        position: absolute; left: 16px; top: 50%; transform: translateY(-50%);
        color: #94A3B8; font-size: 15px; pointer-events: none;
    }
    .table-search-input {
        width: 100%; height: 42px; padding: 0 16px 0 42px !important; border-radius: 50px !important;
        border: 1.5px solid #E2E8F0 !important; font-size: 13px !important; font-weight: 500 !important;
        color: #1E293B !important; background-color: #F8FAFC !important; outline: none; transition: all 0.2s ease;
    }
    .table-search-input:focus {
        background-color: #FFFFFF !important; border-color: #FC8019 !important; box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.14) !important;
    }

    /* Country Filter Dropdown Wrap (Pill Shaped, No text wrapping) */
    .country-filter-wrap {
        min-width: 260px !important;
        position: relative !important;
    }
    .country-filter-wrap .ts-wrapper,
    .country-filter-wrap .ts-control,
    .country-filter-wrap select {
        min-width: 260px !important;
        white-space: nowrap !important;
        height: 42px !important;
        min-height: 42px !important;
        display: flex !important;
        align-items: center !important;
        border-radius: 50px !important;
        border: 1.5px solid #E2E8F0 !important;
        background-color: #FFFFFF !important;
        color: #1E293B !important;
        font-size: 13px !important;
        font-weight: 600 !important;
        padding-left: 18px !important;
        padding-right: 36px !important;
    }
    .country-filter-wrap .ts-control .item {
        white-space: nowrap !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
        font-size: 13px !important;
        font-weight: 600 !important;
        color: #1E293B !important;
        line-height: 1 !important;
    }
    .ts-dropdown {
        min-width: 270px !important;
        white-space: nowrap !important;
        border-radius: 12px !important;
        padding: 6px !important;
    }
    .ts-dropdown .option {
        white-space: nowrap !important;
        font-size: 13px !important;
        padding: 9px 16px !important;
        border-radius: 8px !important;
    }

    .toolbar-count-badge {
        font-size: 12.5px; font-weight: 600; color: #64748B; background: #F8FAFC; border: 1px solid #E2E8F0;
        padding: 7px 16px; border-radius: 50px !important; display: inline-flex; align-items: center; gap: 6px;
    }
    .btn-reset-filter {
        height: 42px; padding: 0 18px; border-radius: 50px !important; border: 1.5px solid #E2E8F0;
        background: #FFFFFF; color: #64748B; font-size: 13px; font-weight: 600;
        display: inline-flex; align-items: center; gap: 6px; cursor: pointer; transition: all 0.15s ease;
    }
    .btn-reset-filter:hover {
        background: #FFF0E5; color: #FC8019; border-color: #FC8019;
    }

    /* Enterprise Table Styling (Matching All Shipments) */
    .enterprise-table,
    .tracking-table {
        width: 100%; border-collapse: separate; border-spacing: 0; margin: 0;
    }
    .enterprise-table thead th,
    .tracking-table thead th {
        background: #F9FAFB; color: #64748B; font-size: 12px; font-weight: 600;
        text-transform: uppercase; letter-spacing: 0.5px; padding: 16px 20px;
        border-bottom: 1px solid #E2E8F0; border-top: none; text-align: left; vertical-align: middle; white-space: nowrap;
    }
    .enterprise-table thead th i,
    .tracking-table thead th i { margin-right: 5px; color: #94A3B8; font-size: 13px; }

    .enterprise-table th.sortable,
    .tracking-table th.sortable {
        cursor: pointer !important; user-select: none !important;
        transition: color 0.15s ease, background-color 0.15s ease !important;
    }
    .enterprise-table th.sortable:hover,
    .tracking-table th.sortable:hover {
        color: #FC8019 !important; background-color: #FFF7F2 !important;
    }
    .sort-indicator {
        font-size: 12px !important; opacity: 0.55; vertical-align: -1px;
        transition: opacity 0.15s ease, transform 0.15s ease;
    }
    .enterprise-table th.sortable:hover .sort-indicator,
    .tracking-table th.sortable:hover .sort-indicator {
        opacity: 1 !important; color: #FC8019 !important;
    }
    .enterprise-table th.sort-active,
    .tracking-table th.sort-active {
        color: #FC8019 !important;
    }
    .enterprise-table th.sort-active .sort-indicator,
    .tracking-table th.sort-active .sort-indicator {
        opacity: 1 !important; color: #FC8019 !important;
    }

    .enterprise-table tbody tr,
    .tracking-table tbody tr {
        transition: background-color 0.15s ease;
    }
    .enterprise-table tbody tr:hover,
    .tracking-table tbody tr:hover {
        background-color: #F8FAFC !important;
    }
    .enterprise-table tbody td,
    .tracking-table tbody td {
        padding: 16px 20px; vertical-align: middle; border-bottom: 1px solid #E2E8F0;
        font-size: 13.5px; color: #1E293B; font-weight: 500; background: transparent;
    }
    .enterprise-table tbody tr:last-child td,
    .tracking-table tbody tr:last-child td { border-bottom: none; }

    /* Table Badges & Elements (Pill & Circular) */
    .port-id-badge {
        font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace; font-size: 12px; font-weight: 700;
        color: #FC8019; background: #FFF0E5; padding: 5px 14px !important; border-radius: 50px !important;
        border: 1px solid rgba(252, 128, 25, 0.3); display: inline-flex; align-items: center; gap: 4px;
        letter-spacing: 0.3px;
    }
    .port-icon-avatar {
        width: 42px; height: 42px; border-radius: 50% !important;
        background: #FFF0E5;
        border: 1px solid rgba(252, 128, 25, 0.25);
        color: #FC8019; display: flex; align-items: center; justify-content: center;
        font-size: 20px; flex-shrink: 0; box-shadow: 0 2px 6px rgba(252, 128, 25, 0.15);
    }
    .port-name-main { font-weight: 700; color: #0F172A; font-size: 14px; margin-bottom: 3px; }
    .port-code-badge {
        font-family: monospace; font-size: 11px; font-weight: 700;
        color: #475569; background: #F1F5F9; padding: 3px 10px !important; border-radius: 50px !important;
        border: 1px solid #CBD5E1; letter-spacing: 0.05em; display: inline-block;
    }

    .coords-badge {
        font-family: ui-monospace, SFMono-Regular, monospace; font-size: 12px; font-weight: 600;
        color: #334155; background: #F8FAFC; padding: 5px 14px !important; border-radius: 50px !important;
        border: 1px solid #E2E8F0; display: inline-flex; align-items: center; gap: 5px;
    }
    .coords-badge i { color: #FC8019; font-size: 13px; }

    .country-cell {
        display: inline-flex; align-items: center; gap: 8px; font-weight: 600; color: #334155;
    }
    .country-cell i { color: #2563EB; font-size: 15px; }

    /* Operational Status Badge */
    .badge-status-operational {
        background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0;
        font-size: 11.5px; font-weight: 700; padding: 5px 14px !important; border-radius: 50px !important;
        display: inline-flex; align-items: center; gap: 6px; text-transform: uppercase; letter-spacing: 0.03em;
    }
    .pulse-dot {
        width: 7px; height: 7px; border-radius: 50% !important; background-color: #10B981;
        box-shadow: 0 0 0 2px rgba(16, 185, 129, 0.25);
        animation: pulseAnimation 2s infinite ease-in-out;
    }
    @keyframes pulseAnimation {
        0% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.5); }
        70% { box-shadow: 0 0 0 5px rgba(16, 185, 129, 0); }
        100% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
    }

    /* Actions Button Group (Circular) */
    .actions-group { display: flex; align-items: center; gap: 8px; justify-content: flex-end; }
    .action-btn {
        width: 34px; height: 34px; border-radius: 50% !important; border: 1px solid #E2E8F0;
        display: inline-flex; align-items: center; justify-content: center;
        font-size: 15px; cursor: pointer; transition: all 0.15s ease; background: #FFFFFF;
    }
    .action-btn-edit { color: #FC8019; background: #FFF0E5; border-color: rgba(252, 128, 25, 0.25); }
    .action-btn-edit:hover { background: #FC8019; color: #FFFFFF; border-color: #FC8019; }
    .action-btn-delete { color: #DC2626; background: #FEF2F2; border-color: rgba(220, 38, 38, 0.25); }
    .action-btn-delete:hover { background: #DC2626; color: #FFFFFF; border-color: #DC2626; }

    /* Empty State */
    .empty-state-box {
        padding: 64px 20px; text-align: center;
    }
    .empty-state-icon {
        width: 64px; height: 64px; border-radius: 50% !important; background: #FFF0E5; color: #FC8019;
        display: inline-flex; align-items: center; justify-content: center; font-size: 28px; margin-bottom: 16px;
    }
    .empty-state-title { font-size: 16px; font-weight: 700; color: #0F172A; margin-bottom: 6px; }
    .empty-state-desc { font-size: 13.5px; color: #64748B; max-width: 420px; margin: 0 auto 20px; }

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
        border-color: #E2E8F0;
        color: #9CA3AF;
        background: #F9FAFB;
    }
    .nl-page-ellipsis {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 28px;
        height: 36px;
        color: #94A3B8;
        font-weight: 700;
        font-size: 14px;
        user-select: none;
    }

    /* ==========================================================================
       ENTERPRISE MODALS STYLING (MATCHING EXACT SWIGGY ORANGE THEME)
       ========================================================================== */
    .custom-modal-backdrop {
        position: fixed; inset: 0; background: rgba(15, 23, 42, 0.55);
        backdrop-filter: blur(4px); z-index: 1050; display: none;
        align-items: center; justify-content: center; padding: 16px;
    }
    .custom-modal-backdrop.show { display: flex; }
    .custom-modal-dialog {
        background: #FFFFFF; border-radius: 20px; width: 100%; max-width: 520px;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); border: 1px solid #E2E8F0;
        overflow: hidden; animation: modalFadeIn 0.2s ease-out;
    }
    @keyframes modalFadeIn {
        from { opacity: 0; transform: scale(0.96) translateY(8px); }
        to { opacity: 1; transform: scale(1) translateY(0); }
    }
    .modal-hero-header {
        padding: 22px 28px; border-bottom: 1px solid #F1F5F9;
        display: flex; align-items: center; justify-content: space-between;
    }
    .modal-hero-icon {
        width: 46px; height: 46px; border-radius: 50% !important;
        background: #FFF0E5; color: #FC8019; font-size: 22px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        box-shadow: 0 2px 8px rgba(252, 128, 25, 0.2);
    }
    .modal-hero-icon.danger {
        background: #FEF2F2; color: #DC2626; box-shadow: 0 2px 8px rgba(220, 38, 38, 0.2);
    }
    .modal-hero-title { font-size: 18px; font-weight: 700; color: #0F172A; margin: 0; }
    .modal-hero-desc { font-size: 13px; color: #64748B; margin: 2px 0 0; }
    .btn-modal-close {
        background: transparent; border: none; font-size: 22px; color: #94A3B8;
        cursor: pointer; width: 32px; height: 32px; border-radius: 50% !important;
        display: flex; align-items: center; justify-content: center;
        transition: color 0.15s ease, background-color 0.15s ease;
    }
    .btn-modal-close:hover { color: #0F172A; background-color: #F1F5F9; }

    .modal-form-body { padding: 24px 28px; }
    .field-group { margin-bottom: 18px; }
    .field-label {
        font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px; display: block;
    }

    .field-input-wrap {
        position: relative !important;
        width: 100% !important;
    }
    .field-input-wrap i {
        position: absolute !important;
        left: 18px !important;
        top: 50% !important;
        transform: translateY(-50%) !important;
        color: #94A3B8 !important;
        font-size: 18px !important;
        z-index: 5 !important;
        pointer-events: none !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        width: 20px !important;
        height: 20px !important;
    }
    .field-input-wrap > input.field-input,
    .field-input-wrap > input,
    input.field-input {
        padding-left: 50px !important;
        padding-right: 20px !important;
        border-radius: 50px !important;
        height: 48px !important;
        min-height: 48px !important;
        font-size: 13.5px !important;
        border: 1.5px solid #E2E8F0 !important;
        background: #FFFFFF !important;
        color: #0F172A !important;
        width: 100% !important;
        outline: none !important;
        transition: all 0.2s ease !important;
        box-sizing: border-box !important;
    }
    .field-input-wrap > input.field-input:focus,
    .field-input-wrap > input:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3.5px rgba(252, 128, 25, 0.16) !important;
    }

    /* Modal Select & TomSelect Dropdown (Light Mode) */
    .field-input-wrap select.form-select-custom,
    .field-input-wrap .ts-wrapper,
    .field-input-wrap .ts-wrapper.form-select-custom {
        width: 100% !important;
        position: relative !important;
        border: none !important;
        background: transparent !important;
        padding: 0 !important;
        box-shadow: none !important;
    }
    .field-input-wrap select.form-select-custom,
    .field-input-wrap .ts-control {
        height: 48px !important;
        min-height: 48px !important;
        padding: 0 42px 0 20px !important;
        border-radius: 50px !important;
        border: 1.5px solid #E2E8F0 !important;
        background-color: #FFFFFF !important;
        color: #0F172A !important;
        font-size: 13.5px !important;
        font-weight: 500 !important;
        display: flex !important;
        align-items: center !important;
        box-sizing: border-box !important;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%2364748B' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
        background-repeat: no-repeat !important;
        background-position: right 18px center !important;
        background-size: 14px 14px !important;
        cursor: pointer !important;
        box-shadow: none !important;
        transition: all 0.2s ease !important;
    }
    .field-input-wrap select.form-select-custom:focus,
    .field-input-wrap .ts-wrapper.focus .ts-control,
    .field-input-wrap .ts-wrapper.dropdown-active .ts-control,
    .field-input-wrap .ts-control.focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3.5px rgba(252, 128, 25, 0.16) !important;
        background-color: #FFFFFF !important;
    }
    .field-input-wrap .ts-control input {
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        height: auto !important;
        min-height: 0 !important;
        padding: 0 !important;
        width: auto !important;
        color: inherit !important;
        font-size: 13.5px !important;
    }
    .field-input-wrap .ts-control .item {
        color: #0F172A !important;
        font-size: 13.5px !important;
        font-weight: 500 !important;
        padding: 0 !important;
        margin: 0 !important;
        line-height: 1 !important;
    }
    .field-input-wrap .ts-wrapper.single .ts-control::after {
        display: none !important;
    }

    .field-helper { font-size: 11.5px; color: #94A3B8; margin-top: 5px; }

    /* Quick Preset Chips */
    .preset-chips-wrap { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 8px; }
    .preset-chip {
        font-size: 11px; font-weight: 600; padding: 4px 12px; border-radius: 50px !important;
        background: #F8FAFC; border: 1px solid #E2E8F0; color: #64748B; cursor: pointer;
        transition: all 0.15s ease;
    }
    .preset-chip:hover {
        background: #FFF0E5; color: #FC8019; border-color: #FC8019;
    }

    .modal-form-footer {
        padding: 16px 28px 24px; display: flex; align-items: center; justify-content: flex-end; gap: 10px;
        border-top: 1px solid #F1F5F9;
    }
    .btn-modal-cancel {
        padding: 10px 20px; border-radius: 50px !important; border: 1.5px solid #E2E8F0;
        background: #FFFFFF; color: #64748B; font-weight: 600; font-size: 13px;
        cursor: pointer; transition: all 0.15s ease;
    }
    .btn-modal-cancel:hover { background: #F8FAFC; color: #334155; }
    .btn-modal-submit {
        padding: 10px 24px; border-radius: 50px !important; border: none;
        background: #FC8019; color: #FFFFFF; font-weight: 600; font-size: 13.5px;
        cursor: pointer; display: inline-flex; align-items: center; gap: 8px;
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.28);
        transition: all 0.2s ease;
    }
    .btn-modal-submit:hover {
        background: #E67012; box-shadow: 0 6px 16px rgba(252, 128, 25, 0.36); transform: translateY(-1px);
    }
    .btn-modal-danger {
        padding: 10px 24px; border-radius: 50px !important; border: none;
        background: #DC2626; color: #FFFFFF; font-weight: 600; font-size: 13.5px;
        cursor: pointer; display: inline-flex; align-items: center; gap: 8px;
        box-shadow: 0 4px 12px rgba(220, 38, 38, 0.28);
        transition: all 0.2s ease;
    }
    .btn-modal-danger:hover {
        background: #B91C1C; box-shadow: 0 6px 16px rgba(220, 38, 38, 0.36); transform: translateY(-1px);
    }

    /* ==========================================================================
       DARK THEME STYLES [data-theme="dark"] FOR PORTS PAGE
       ========================================================================== */
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

    /* Frameless Header in Dark Mode */
    [data-theme="dark"] .telemetry-header-card {
        background: transparent !important;
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
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FC8019 !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
        box-shadow: 0 2px 10px rgba(252, 128, 25, 0.2) !important;
    }

    /* Badges & Buttons in Dark Mode */
    [data-theme="dark"] .toolbar-count-badge {
        background: #151F28 !important;
        border: 1px solid #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .toolbar-count-badge i {
        color: #FC8019 !important;
    }
    [data-theme="dark"] .btn-register-primary {
        box-shadow: 0 4px 16px rgba(252, 128, 25, 0.35) !important;
    }

    /* Alerts in Dark Mode */
    [data-theme="dark"] .alert-success {
        background: rgba(16, 185, 129, 0.12) !important;
        border-color: rgba(16, 185, 129, 0.25) !important;
        color: #34D399 !important;
    }
    [data-theme="dark"] .alert-danger {
        background: rgba(239, 68, 68, 0.12) !important;
        border-color: rgba(239, 68, 68, 0.25) !important;
        color: #F87171 !important;
    }

    /* 4 KPI Metric Cards in Dark Mode */
    [data-theme="dark"] .kpi-card {
        background: #101820 !important;
        border: 1px solid #22303A !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .kpi-card:hover {
        border-color: #2D3F4D !important;
        box-shadow: 0 8px 25px rgba(0, 0, 0, 0.45) !important;
    }
    [data-theme="dark"] .kpi-label {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .kpi-value {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .kpi-badge-orange {
        background: rgba(252, 128, 25, 0.15) !important;
        color: #FB923C !important;
        border-color: rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .kpi-badge-blue {
        background: rgba(59, 130, 246, 0.15) !important;
        color: #60A5FA !important;
        border-color: rgba(59, 130, 246, 0.3) !important;
    }
    [data-theme="dark"] .kpi-badge-green {
        background: rgba(16, 185, 129, 0.15) !important;
        color: #34D399 !important;
        border-color: rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .kpi-badge-purple {
        background: rgba(168, 85, 247, 0.15) !important;
        color: #C084FC !important;
        border-color: rgba(168, 85, 247, 0.3) !important;
    }

    /* KPI Icon Badges in Dark Mode (Eliminates blinding white boxes) */
    [data-theme="dark"] .kpi-icon-orange {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FB923C !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .kpi-icon-blue {
        background: rgba(59, 130, 246, 0.16) !important;
        color: #60A5FA !important;
        border: 1px solid rgba(59, 130, 246, 0.3) !important;
    }
    [data-theme="dark"] .kpi-icon-green {
        background: rgba(16, 185, 129, 0.16) !important;
        color: #34D399 !important;
        border: 1px solid rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .kpi-icon-purple {
        background: rgba(168, 85, 247, 0.16) !important;
        color: #C084FC !important;
        border: 1px solid rgba(168, 85, 247, 0.3) !important;
    }

    /* Table Panel & Toolbar in Dark Mode */
    [data-theme="dark"] .ports-table-panel,
    [data-theme="dark"] .ports-main-card {
        background: #101820 !important;
        border: 1px solid #22303A !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .toolbar-bar {
        background: #101820 !important;
        border-bottom: 1px solid #22303A !important;
    }

    /* Toolbar Search & Select in Dark Mode */
    [data-theme="dark"] .table-search-input {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .table-search-input:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.18) !important;
    }
    [data-theme="dark"] .table-search-box i {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .btn-reset-filter {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .btn-reset-filter:hover {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FC8019 !important;
        border-color: #FC8019 !important;
    }

    /* Country Dropdown in Dark Mode */
    [data-theme="dark"] .country-filter-wrap .ts-control,
    [data-theme="dark"] .country-filter-wrap select {
        background-color: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23FC8019' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
    }
    [data-theme="dark"] .country-filter-wrap .ts-control .item {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .ts-dropdown,
    [data-theme="dark"] .country-filter-wrap .ts-dropdown {
        background: #151F28 !important;
        border: 1px solid #2D3F4D !important;
        box-shadow: 0 14px 36px rgba(0, 0, 0, 0.55) !important;
    }
    [data-theme="dark"] .ts-dropdown .option,
    [data-theme="dark"] .country-filter-wrap .ts-dropdown .option {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .ts-dropdown .option:hover,
    [data-theme="dark"] .ts-dropdown .option.active,
    [data-theme="dark"] .country-filter-wrap .ts-dropdown .option:hover,
    [data-theme="dark"] .country-filter-wrap .ts-dropdown .option.active {
        background-color: #1E2D3D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .ts-dropdown .option.selected,
    [data-theme="dark"] .country-filter-wrap .ts-dropdown .option.selected {
        background-color: #FC8019 !important;
        color: #FFFFFF !important;
        font-weight: 700 !important;
    }

    /* Table Headers & Rows in Dark Mode */
    [data-theme="dark"] .table-responsive,
    [data-theme="dark"] .enterprise-table,
    [data-theme="dark"] .tracking-table {
        background-color: #101820 !important;
    }
    [data-theme="dark"] .enterprise-table thead th,
    [data-theme="dark"] .tracking-table thead th {
        background-color: #0E151C !important;
        color: #94A3B8 !important;
        border-bottom: 1px solid #22303A !important;
    }
    [data-theme="dark"] .enterprise-table thead th i,
    [data-theme="dark"] .tracking-table thead th i {
        color: #64748B !important;
    }
    [data-theme="dark"] .enterprise-table th.sortable:hover,
    [data-theme="dark"] .tracking-table th.sortable:hover {
        color: #FC8019 !important;
        background-color: rgba(252, 128, 25, 0.1) !important;
    }
    [data-theme="dark"] .enterprise-table th.sort-active,
    [data-theme="dark"] .tracking-table th.sort-active {
        color: #FC8019 !important;
    }
    [data-theme="dark"] .sort-indicator {
        color: #64748B !important;
    }
    [data-theme="dark"] .enterprise-table th.sortable:hover .sort-indicator,
    [data-theme="dark"] .enterprise-table th.sort-active .sort-indicator,
    [data-theme="dark"] .tracking-table th.sortable:hover .sort-indicator,
    [data-theme="dark"] .tracking-table th.sort-active .sort-indicator {
        color: #FC8019 !important;
    }
    [data-theme="dark"] .enterprise-table tbody td,
    [data-theme="dark"] .tracking-table tbody td {
        background-color: transparent !important;
        color: #F8FAFC !important;
        border-bottom: 1px solid #22303A !important;
    }
    [data-theme="dark"] .port-row:hover td {
        background-color: rgba(255, 255, 255, 0.03) !important;
    }
    [data-theme="dark"] .port-row:last-child td {
        border-bottom: none !important;
    }

    /* Badges & Cell Components in Dark Mode */
    [data-theme="dark"] .port-id-badge {
        background: rgba(252, 128, 25, 0.15) !important;
        border-color: rgba(252, 128, 25, 0.3) !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .port-icon-avatar {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FC8019 !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .port-name-main {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .port-code-badge {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .coords-badge {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .country-cell {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .country-cell i {
        color: #60A5FA !important;
    }
    [data-theme="dark"] .badge-status-operational {
        background: rgba(16, 185, 129, 0.16) !important;
        color: #34D399 !important;
        border-color: rgba(16, 185, 129, 0.3) !important;
    }

    /* Action Buttons in Dark Mode */
    [data-theme="dark"] .action-btn {
        background: #151F28 !important;
        border: 1px solid #2D3F4D !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .action-btn:hover {
        background: #1E293B !important;
        border-color: #3E5468 !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .action-btn-edit:hover {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FC8019 !important;
        border-color: #FC8019 !important;
    }
    [data-theme="dark"] .action-btn-delete:hover {
        background: rgba(239, 68, 68, 0.16) !important;
        color: #F87171 !important;
        border-color: #DC2626 !important;
    }

    /* Pagination in Dark Mode */
    [data-theme="dark"] .nl-pagination-wrapper {
        background: #101820 !important;
        border-top: 1px solid #22303A !important;
    }
    [data-theme="dark"] .nl-pagination-info {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .nl-pagination-info strong {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .nl-page-btn {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .nl-page-btn:hover:not(.disabled):not(.active) {
        border-color: #FC8019 !important;
        color: #FC8019 !important;
        background: rgba(252, 128, 25, 0.12) !important;
    }
    [data-theme="dark"] .nl-page-btn.active {
        background: #FC8019 !important;
        border-color: #FC8019 !important;
        color: #FFFFFF !important;
    }
    [data-theme="dark"] .nl-page-btn.disabled {
        opacity: 0.35 !important;
        border-color: #22303A !important;
    }

    /* Modals in Dark Mode */
    [data-theme="dark"] .custom-modal-dialog {
        background: #151F28 !important;
        border: 1px solid #2D3F4D !important;
        box-shadow: 0 20px 50px rgba(0, 0, 0, 0.6) !important;
    }
    [data-theme="dark"] .modal-hero-icon {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FC8019 !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .modal-hero-icon.danger {
        background: rgba(239, 68, 68, 0.16) !important;
        color: #F87171 !important;
        border: 1px solid rgba(239, 68, 68, 0.3) !important;
    }
    [data-theme="dark"] .modal-hero-header {
        border-bottom: 1px solid #22303A !important;
    }
    [data-theme="dark"] .modal-hero-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .modal-hero-desc {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .btn-modal-close {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .btn-modal-close:hover {
        color: #F8FAFC !important;
        background-color: #1E293B !important;
    }
    [data-theme="dark"] .field-label {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .field-helper {
        color: #64748B !important;
    }
    [data-theme="dark"] .field-input-wrap > input.field-input,
    [data-theme="dark"] .field-input-wrap > input,
    [data-theme="dark"] input.field-input {
        background: #101820 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .field-input-wrap > input:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3.5px rgba(252, 128, 25, 0.22) !important;
    }
    [data-theme="dark"] .field-input-wrap i {
        color: #94A3B8 !important;
    }

    /* Modal Select & TomSelect in Dark Mode (Active, Focus, Normal) */
    [data-theme="dark"] .field-input-wrap select.form-select-custom,
    [data-theme="dark"] .field-input-wrap .ts-control,
    [data-theme="dark"] .field-input-wrap .ts-wrapper .ts-control,
    [data-theme="dark"] .field-input-wrap .ts-wrapper.focus .ts-control,
    [data-theme="dark"] .field-input-wrap .ts-wrapper.dropdown-active .ts-control,
    [data-theme="dark"] .field-input-wrap .ts-control.focus,
    [data-theme="dark"] .ts-wrapper.form-select-custom .ts-control,
    [data-theme="dark"] .ts-wrapper.form-select-custom.focus .ts-control,
    [data-theme="dark"] .ts-wrapper.form-select-custom.dropdown-active .ts-control {
        background-color: #101820 !important;
        background: #101820 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23FC8019' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
        background-repeat: no-repeat !important;
        background-position: right 18px center !important;
        background-size: 14px 14px !important;
    }

    [data-theme="dark"] .field-input-wrap select.form-select-custom:focus,
    [data-theme="dark"] .field-input-wrap .ts-wrapper.focus .ts-control,
    [data-theme="dark"] .field-input-wrap .ts-wrapper.dropdown-active .ts-control,
    [data-theme="dark"] .field-input-wrap .ts-control.focus,
    [data-theme="dark"] .ts-wrapper.form-select-custom.focus .ts-control,
    [data-theme="dark"] .ts-wrapper.form-select-custom.dropdown-active .ts-control {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3.5px rgba(252, 128, 25, 0.22) !important;
        background-color: #101820 !important;
        background: #101820 !important;
    }

    [data-theme="dark"] .field-input-wrap .ts-control .item,
    [data-theme="dark"] .ts-wrapper.form-select-custom .ts-control .item {
        color: #F8FAFC !important;
        font-size: 13.5px !important;
        font-weight: 500 !important;
    }

    [data-theme="dark"] .field-input-wrap .ts-control input,
    [data-theme="dark"] .ts-wrapper.form-select-custom .ts-control input {
        color: #F8FAFC !important;
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        height: auto !important;
        min-height: 0 !important;
        padding: 0 !important;
        width: auto !important;
    }

    [data-theme="dark"] select.form-select-custom option {
        background-color: #151F28 !important;
        color: #F8FAFC !important;
    }

    [data-theme="dark"] .preset-chip {
        background: #101820 !important;
        border-color: #2D3F4D !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .preset-chip:hover {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FC8019 !important;
        border-color: #FC8019 !important;
    }
    [data-theme="dark"] .modal-form-footer {
        border-top: 1px solid #22303A !important;
    }
    [data-theme="dark"] .btn-modal-cancel {
        background: #101820 !important;
        border-color: #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .btn-modal-cancel:hover {
        background: #1E293B !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] #deletePortModal p {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] #deletePortNameDisplay {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] #deletePortCodeDisplay {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .empty-state-box {
        background: transparent !important;
    }
    [data-theme="dark"] .empty-state-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .empty-state-desc {
        color: #94A3B8 !important;
    }
</style>

<div class="ports-page-container">
    <!-- Breadcrumb -->
    <div class="custom-breadcrumb">
        <a href="${pageContext.request.contextPath}/dashboard"><i class="ti ti-smart-home me-1"></i> Dashboard</a>
        <i class="ti ti-chevron-right"></i>
        <span>Maritime Infrastructure</span>
        <i class="ti ti-chevron-right"></i>
        <span class="current">Ports Directory</span>
    </div>

    <!-- Alert Messages (Toast style) -->
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success alert-dismissible fade show rounded-4 border-0 shadow-sm d-flex align-items-center mb-4" role="alert" style="background-color: #ECFDF5; border-left: 4px solid #10B981 !important;">
            <i class="ti ti-circle-check text-success fs-4 me-3"></i>
            <div class="text-success fw-medium flex-grow-1">${sessionScope.successMessage}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>

    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show rounded-4 border-0 shadow-sm d-flex align-items-center mb-4" role="alert" style="background-color: #FEF2F2; border-left: 4px solid #EF4444 !important;">
            <i class="ti ti-alert-triangle text-danger fs-4 me-3"></i>
            <div class="text-danger fw-medium flex-grow-1">${sessionScope.errorMessage}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <!-- Telemetry Header Card -->
    <div class="telemetry-header-card">
        <div class="telemetry-header-left">
            <div class="telemetry-icon-box">
                <i class="ti ti-anchor"></i>
            </div>
            <div>
                <h2 class="telemetry-title">Global Ports & Harbors Directory</h2>
                <p class="telemetry-desc">
                    Comprehensive registry of international maritime shipping terminals, UN/LOCODE designations, and geographical gateways.
                </p>
            </div>
        </div>
        <div class="telemetry-actions">
            <span class="badge-status-operational me-2">
                <span class="pulse-dot"></span> ${totalPortsCount} Global Terminals Active
            </span>
            <button type="button" class="btn-register-primary" onclick="openAddPortModal()">
                <i class="ti ti-plus"></i> Add Port
            </button>
        </div>
    </div>

    <!-- 4 Dynamic KPI Telemetry Cards (Calculated directly from Database rows) -->
    <div class="kpi-grid">
        <!-- 1. Total Ports Count (Dynamic from DB) -->
        <div class="kpi-card">
            <div class="kpi-card-inner">
                <div>
                    <div class="kpi-label">Total Ports</div>
                    <div class="kpi-value">${totalPortsCount}</div>
                    <div class="kpi-badge kpi-badge-orange">
                        <i class="ti ti-anchor"></i> Live Database Records
                    </div>
                </div>
                <div class="kpi-icon-wrap kpi-icon-orange">
                    <i class="ti ti-building-carousel"></i>
                </div>
            </div>
        </div>

        <!-- 2. Distinct Sovereign Countries Covered (Dynamic from DB) -->
        <div class="kpi-card">
            <div class="kpi-card-inner">
                <div>
                    <div class="kpi-label">Countries Covered</div>
                    <div class="kpi-value">${distinctCountriesCount}</div>
                    <div class="kpi-badge kpi-badge-blue">
                        <i class="ti ti-world"></i> Sovereign Territories
                    </div>
                </div>
                <div class="kpi-icon-wrap kpi-icon-blue">
                    <i class="ti ti-world"></i>
                </div>
            </div>
        </div>

        <!-- 3. Geotagged Gateways (Dynamic from DB) -->
        <div class="kpi-card">
            <div class="kpi-card-inner">
                <div>
                    <div class="kpi-label">Geocoded Ports</div>
                    <div class="kpi-value">${geotaggedCount}</div>
                    <div class="kpi-badge kpi-badge-green">
                        <i class="ti ti-map-pin"></i> GPS Calibrated
                    </div>
                </div>
                <div class="kpi-icon-wrap kpi-icon-green">
                    <i class="ti ti-map-pin"></i>
                </div>
            </div>
        </div>

        <!-- 4. Dynamic GPS Calibration Percentage (Calculated from DB geotagged / totalPorts) -->
        <div class="kpi-card">
            <div class="kpi-card-inner">
                <div>
                    <div class="kpi-label">GPS Calibrated Ratio</div>
                    <div class="kpi-value">${geocodePercent}%</div>
                    <div class="kpi-badge kpi-badge-purple">
                        <i class="ti ti-check"></i> ${geotaggedCount} of ${totalPortsCount} Geotagged
                    </div>
                </div>
                <div class="kpi-icon-wrap kpi-icon-purple">
                    <i class="ti ti-route"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Ports Table Card -->
    <div class="ports-table-panel card tracking-card no-card-tools" data-no-tools="true" style="padding: 0; overflow: hidden; border-radius: 16px;">
        <!-- Search & Filter Toolbar -->
        <div class="toolbar-bar">
            <div class="toolbar-left">
                <!-- Search Box -->
                <div class="table-search-box">
                    <i class="ti ti-search"></i>
                    <input type="text" id="portSearchInput" class="table-search-input" placeholder="Search ports by name, code, country, or PRT ID..." oninput="handleFilter()">
                </div>

                <!-- Country Filter Dropdown (Custom non-breaking wrap, dynamically populated from DB) -->
                <div class="country-filter-wrap">
                    <select id="countryFilter" class="form-select-custom" onchange="handleFilter()">
                        <option value="ALL">All Countries / Territories</option>
                    </select>
                </div>

                <!-- Reset Filter -->
                <button type="button" class="btn-reset-filter" onclick="resetFilters()" title="Reset Filters">
                    <i class="ti ti-rotate"></i> Reset
                </button>
            </div>

            <!-- Visible Count Badge -->
            <div class="toolbar-count-badge" id="showingCountBadge">
                <i class="ti ti-list"></i> Showing ${totalPortsCount} of ${totalPortsCount} Ports
            </div>
        </div>

        <!-- Table Container -->
        <div class="table-responsive">
            <table class="enterprise-table tracking-table" id="portsTable">
                <thead>
                    <tr>
                        <th class="sortable" style="width: 120px;" onclick="sortPortsTable(0)">
                            Port ID <i class="ti ti-arrows-sort sort-indicator ms-1"></i>
                        </th>
                        <th class="sortable" onclick="sortPortsTable(1)">
                            Harbor Port & Code <i class="ti ti-arrows-sort sort-indicator ms-1"></i>
                        </th>
                        <th class="sortable" style="width: 220px;" onclick="sortPortsTable(2)">
                            Country / Territory <i class="ti ti-arrows-sort sort-indicator ms-1"></i>
                        </th>
                        <th class="sortable" style="width: 240px;" onclick="sortPortsTable(3)">
                            Geographical Coordinates <i class="ti ti-arrows-sort sort-indicator ms-1"></i>
                        </th>
                        <th class="sortable" style="width: 160px;" onclick="sortPortsTable(4)">
                            Operational Status <i class="ti ti-arrows-sort sort-indicator ms-1"></i>
                        </th>
                        <th style="width: 110px; text-align: right;">Actions</th>
                    </tr>
                </thead>
                <tbody id="portsTableBody">
                    <c:choose>
                        <c:when test="${not empty ports}">
                            <c:forEach var="p" items="${ports}">
                                <tr class="port-row" 
                                    data-search="prt-${p.portId} ${p.portName.toLowerCase()} ${p.portCode.toLowerCase()} ${p.country.toLowerCase()}"
                                    data-country="${p.country}"
                                    data-id="${p.portId}"
                                    data-name="${p.portName}"
                                    data-code="${p.portCode}"
                                    data-lat="${p.latitude}"
                                    data-lng="${p.longitude}">
                                    
                                    <!-- Port ID -->
                                    <td>
                                        <span class="port-id-badge">PRT-${p.portId}</span>
                                    </td>

                                    <!-- Port Name & Code -->
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="port-icon-avatar">
                                                <i class="ti ti-anchor"></i>
                                            </div>
                                            <div>
                                                <div class="port-name-main">${p.portName}</div>
                                                <div>
                                                    <span class="port-code-badge" title="UN/LOCODE / Terminal Identifier">
                                                        <c:out value="${p.portCode}" default="N/A" />
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </td>

                                    <!-- Country -->
                                    <td>
                                        <div class="country-cell">
                                            <i class="ti ti-world"></i>
                                            <span><c:out value="${p.country}" default="International" /></span>
                                        </div>
                                    </td>

                                    <!-- Coordinates -->
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.latitude != 0.0 || p.longitude != 0.0}">
                                                <span class="coords-badge" title="GPS Coordinates">
                                                    <i class="ti ti-map-pin"></i>
                                                    <fmt:formatNumber value="${p.latitude}" pattern="##0.0000" />&deg;, 
                                                    <fmt:formatNumber value="${p.longitude}" pattern="##0.0000" />&deg;
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted small fst-italic">
                                                    <i class="ti ti-map-pin-off me-1"></i> Not Geotagged
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Operational Status -->
                                    <td>
                                        <span class="badge-status-operational">
                                            <span class="pulse-dot"></span> Operational
                                        </span>
                                    </td>

                                    <!-- Actions (Edit & Delete) -->
                                    <td>
                                        <div class="actions-group">
                                            <button type="button" class="action-btn action-btn-edit" 
                                                    onclick="openEditPortModal(${p.portId}, '${p.portName}', '${p.portCode}', '${p.country}', ${p.latitude}, ${p.longitude})" 
                                                    title="Edit Port">
                                                <i class="ti ti-pencil"></i>
                                            </button>
                                            <button type="button" class="action-btn action-btn-delete" 
                                                    onclick="openDeletePortModal(${p.portId}, '${p.portName}', '${p.portCode}')" 
                                                    title="Decommission Port">
                                                <i class="ti ti-trash"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                    </c:choose>
                </tbody>
            </table>

            <!-- Empty State Box -->
            <div class="empty-state-box" id="emptyStateBox" style="display: ${empty ports ? 'block' : 'none'};">
                <div class="empty-state-icon">
                    <i class="ti ti-anchor-off"></i>
                </div>
                <h4 class="empty-state-title">No Maritime Ports Found</h4>
                <p class="empty-state-desc">
                    No international harbor ports match your current search query or country filter. Try adjusting your search or add a new port.
                </p>
                <button type="button" class="btn-register-primary" onclick="openAddPortModal()">
                    <i class="ti ti-plus"></i> Register New Port
                </button>
            </div>
        </div>

        <!-- Global Enterprise Circular Pagination Bar -->
        <div class="nl-pagination-wrapper" id="portsPagination">
            <div class="nl-pagination-info">
                <span>Showing <strong id="portPageStart">1</strong> to <strong id="portPageEnd">10</strong> of <strong id="portTotalRows">${totalPortsCount}</strong> Ports</span>
            </div>
            <div class="nl-pagination-nav" id="portsPageNav">
                <!-- Dynamically generated circular pagination buttons -->
            </div>
        </div>
    </div>
</div>

<!-- ==========================================================================
     REVAMPED ENTERPRISE MODAL: REGISTER NEW PORT
     ========================================================================== -->
<div class="custom-modal-backdrop" id="addPortModal">
    <div class="custom-modal-dialog">
        <div class="modal-hero-header">
            <div class="d-flex align-items-center gap-3">
                <div class="modal-hero-icon">
                    <i class="ti ti-anchor"></i>
                </div>
                <div>
                    <h3 class="modal-hero-title">Register New Port</h3>
                    <p class="modal-hero-desc">Add an international commercial harbor or container terminal gateway.</p>
                </div>
            </div>
            <button type="button" class="btn-modal-close" onclick="closeAddPortModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/ports" id="addPortForm">
            <input type="hidden" name="action" value="add">
            <div class="modal-form-body">
                <!-- Port Name -->
                <div class="field-group">
                    <label class="field-label">Port Official Name <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-anchor"></i>
                        <input type="text" class="field-input" name="portName" id="addPortName" required placeholder="e.g. Jawaharlal Nehru Port (JNPT)">
                    </div>
                    <div class="field-helper">Official commercial harbor or terminal facility designation.</div>
                </div>

                <!-- Port Code -->
                <div class="field-group">
                    <label class="field-label">Port Code (UN/LOCODE) <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-barcode"></i>
                        <input type="text" class="field-input" name="portCode" id="addPortCode" required placeholder="e.g. INNSA" style="font-family: monospace; text-transform: uppercase;">
                    </div>
                    <div class="field-helper">Standard international 3-5 alphanumeric identifier assigned to maritime terminals.</div>
                </div>

                <!-- Country -->
                <div class="field-group">
                    <label class="field-label">Sovereign Country / Territory <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-world"></i>
                        <input type="text" class="field-input" name="country" id="addCountry" required placeholder="e.g. India">
                    </div>
                    <div class="field-helper">Country or sovereign jurisdiction where the harbor terminal operates.</div>
                </div>

                <!-- Coordinates (Lat & Lng) -->
                <div class="row">
                    <div class="col-md-6">
                        <div class="field-group">
                            <label class="field-label">Latitude (&deg; N/S)</label>
                            <div class="field-input-wrap input-icon-wrap has-lead-icon">
                                <i class="ti ti-map-pin"></i>
                                <input type="number" step="any" class="field-input" name="latitude" id="addLatitude" placeholder="e.g. 18.949900">
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="field-group">
                            <label class="field-label">Longitude (&deg; E/W)</label>
                            <div class="field-input-wrap input-icon-wrap has-lead-icon">
                                <i class="ti ti-compass"></i>
                                <input type="number" step="any" class="field-input" name="longitude" id="addLongitude" placeholder="e.g. 72.951200">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Quick Preset Chips -->
                <div class="field-helper mb-1">Quick Harbor Presets:</div>
                <div class="preset-chips-wrap">
                    <span class="preset-chip" onclick="setPortPreset('JNPT (Mumbai)', 'INNSA', 'India', 18.9499, 72.9512)">JNPT Mumbai</span>
                    <span class="preset-chip" onclick="setPortPreset('Port of Singapore', 'SGSIN', 'Singapore', 1.2902, 103.8519)">Singapore</span>
                    <span class="preset-chip" onclick="setPortPreset('Port of Rotterdam', 'NLRTM', 'Netherlands', 51.9244, 4.4777)">Rotterdam</span>
                    <span class="preset-chip" onclick="setPortPreset('Jebel Ali Port', 'AEJEA', 'United Arab Emirates', 25.0113, 55.0617)">Dubai</span>
                </div>
            </div>
            <div class="modal-form-footer">
                <button type="button" class="btn-modal-cancel" onclick="closeAddPortModal()">Cancel</button>
                <button type="submit" class="btn-modal-submit">
                    <i class="ti ti-check"></i> Save Port
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ==========================================================================
     REVAMPED ENTERPRISE MODAL: EDIT PORT DETAILS
     ========================================================================== -->
<div class="custom-modal-backdrop" id="editPortModal">
    <div class="custom-modal-dialog">
        <div class="modal-hero-header">
            <div class="d-flex align-items-center gap-3">
                <div class="modal-hero-icon">
                    <i class="ti ti-pencil"></i>
                </div>
                <div>
                    <h3 class="modal-hero-title">Edit Port Details</h3>
                    <p class="modal-hero-desc">Update commercial harbor name, UN/LOCODE, territory, or GPS coordinates.</p>
                </div>
            </div>
            <button type="button" class="btn-modal-close" onclick="closeEditPortModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/ports" id="editPortForm">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="portId" id="editPortId">
            <div class="modal-form-body">
                <!-- Port Name -->
                <div class="field-group">
                    <label class="field-label">Port Official Name <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-anchor"></i>
                        <input type="text" class="field-input" name="portName" id="editPortName" required>
                    </div>
                </div>

                <!-- Port Code -->
                <div class="field-group">
                    <label class="field-label">Port Code (UN/LOCODE) <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-barcode"></i>
                        <input type="text" class="field-input" name="portCode" id="editPortCode" required style="font-family: monospace; text-transform: uppercase;">
                    </div>
                </div>

                <!-- Country -->
                <div class="field-group">
                    <label class="field-label">Sovereign Country / Territory <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-world"></i>
                        <input type="text" class="field-input" name="country" id="editCountry" required>
                    </div>
                </div>

                <!-- Coordinates (Lat & Lng) -->
                <div class="row">
                    <div class="col-md-6">
                        <div class="field-group">
                            <label class="field-label">Latitude (&deg; N/S)</label>
                            <div class="field-input-wrap input-icon-wrap has-lead-icon">
                                <i class="ti ti-map-pin"></i>
                                <input type="number" step="any" class="field-input" name="latitude" id="editLatitude">
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="field-group">
                            <label class="field-label">Longitude (&deg; E/W)</label>
                            <div class="field-input-wrap input-icon-wrap has-lead-icon">
                                <i class="ti ti-compass"></i>
                                <input type="number" step="any" class="field-input" name="longitude" id="editLongitude">
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-form-footer">
                <button type="button" class="btn-modal-cancel" onclick="closeEditPortModal()">Cancel</button>
                <button type="submit" class="btn-modal-submit">
                    <i class="ti ti-check"></i> Update Port
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ==========================================================================
     REVAMPED ENTERPRISE MODAL: DECOMMISSION / DELETE PORT
     ========================================================================== -->
<div class="custom-modal-backdrop" id="deletePortModal">
    <div class="custom-modal-dialog">
        <div class="modal-hero-header">
            <div class="d-flex align-items-center gap-3">
                <div class="modal-hero-icon danger">
                    <i class="ti ti-alert-triangle"></i>
                </div>
                <div>
                    <h3 class="modal-hero-title">Decommission Port?</h3>
                    <p class="modal-hero-desc">Confirm permanent removal of this port from maritime directory.</p>
                </div>
            </div>
            <button type="button" class="btn-modal-close" onclick="closeDeletePortModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/ports" id="deletePortForm">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="portId" id="deletePortId">
            <div class="modal-form-body">
                <p style="font-size: 13.5px; color: #475569; line-height: 1.5; margin-bottom: 0;">
                    Are you sure you want to permanently decommission and delete <strong id="deletePortNameDisplay" style="color: #0F172A;"></strong> (<span id="deletePortCodeDisplay" style="font-family: monospace;"></span>)?
                    Maritime carriers and container terminals referencing this hub will be affected.
                </p>
            </div>
            <div class="modal-form-footer">
                <button type="button" class="btn-modal-cancel" onclick="closeDeletePortModal()">Cancel</button>
                <button type="submit" class="btn-modal-danger">
                    <i class="ti ti-trash"></i> Yes, Decommission
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ==========================================================================
     FRONTEND CONTROLLER & SEARCH / FILTER / PAGINATION JS
     ========================================================================== -->
<script>
    let allPortRows = [];
    let matchingPortRows = [];
    let currentPage = 1;
    const pageSize = 10;

    document.addEventListener('DOMContentLoaded', function() {
        allPortRows = Array.from(document.querySelectorAll('.port-row'));
        deduplicateCountryFilter();
        handleFilter();
    });

    // Populate country dropdown without duplicate entries dynamically from database rows
    function deduplicateCountryFilter() {
        const select = document.getElementById('countryFilter');
        if (!select) return;

        const countries = new Set();
        allPortRows.forEach(row => {
            const c = (row.getAttribute('data-country') || '').trim();
            if (c) countries.add(c);
        });

        const sortedCountries = Array.from(countries).sort();
        select.innerHTML = '<option value="ALL">All Countries / Territories</option>';
        sortedCountries.forEach(c => {
            const opt = document.createElement('option');
            opt.value = c;
            opt.textContent = c;
            select.appendChild(opt);
        });

        // Initialize TomSelect if available
        if (typeof TomSelect !== 'undefined' && !select.tomselect) {
            new TomSelect(select, {
                create: false,
                maxItems: 1,
                allowEmptyOption: false,
                placeholder: 'Filter by Country...',
                onChange: function() {
                    handleFilter();
                }
            });
        }
    }

    function handleFilter() {
        const query = (document.getElementById('portSearchInput').value || '').trim().toLowerCase();
        const countrySelect = document.getElementById('countryFilter');
        const selectedCountry = countrySelect ? countrySelect.value : 'ALL';

        matchingPortRows = [];

        allPortRows.forEach(row => {
            const searchData = (row.getAttribute('data-search') || '').toLowerCase();
            const rowCountry = (row.getAttribute('data-country') || '').trim();

            // Country Match
            const matchesCountry = (selectedCountry === 'ALL' || rowCountry.toLowerCase() === selectedCountry.toLowerCase());

            // Search Query Match
            const matchesQuery = !query || searchData.includes(query);

            if (matchesCountry && matchesQuery) {
                matchingPortRows.push(row);
            }
        });

        currentPage = 1;
        renderPage();
    }

    let portSortDirections = [true, true, true, true, true, true];

    function renderPage() {
        const table = document.getElementById('portsTable');
        const emptyState = document.getElementById('emptyStateBox');
        const pagination = document.getElementById('portsPagination');
        const countBadge = document.getElementById('showingCountBadge');

        const totalMatches = matchingPortRows.length;
        if (countBadge) {
            countBadge.innerHTML = '<i class="ti ti-list"></i> Showing ' + totalMatches + ' of ' + allPortRows.length + ' Ports';
        }

        if (totalMatches === 0) {
            if (table) table.style.display = 'none';
            if (emptyState) emptyState.style.display = 'block';
            if (pagination) pagination.style.display = 'none';
            allPortRows.forEach(row => row.style.display = 'none');
            return;
        }

        if (table) table.style.display = 'table';
        if (emptyState) emptyState.style.display = 'none';
        if (pagination) pagination.style.display = 'flex';

        const totalPages = Math.ceil(totalMatches / pageSize) || 1;
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        // Hide all rows first
        allPortRows.forEach(row => row.style.display = 'none');

        // Show slice
        const start = (currentPage - 1) * pageSize;
        const end = Math.min(start + pageSize, totalMatches);

        for (let i = start; i < end; i++) {
            matchingPortRows[i].style.display = '';
        }

        // Update Info Text
        const pStart = document.getElementById('portPageStart');
        const pEnd = document.getElementById('portPageEnd');
        const pTotal = document.getElementById('portTotalRows');
        if (pStart) pStart.innerText = totalMatches > 0 ? (start + 1) : 0;
        if (pEnd) pEnd.innerText = end;
        if (pTotal) pTotal.innerText = totalMatches;

        // Render Circular Page Number Buttons
        renderPaginationNumbers(totalPages);
    }

    function renderPaginationNumbers(totalPages) {
        const pageNav = document.getElementById('portsPageNav');
        if (!pageNav) return;
        pageNav.innerHTML = '';

        if (totalPages <= 1) {
            return;
        }

        // Prev Button
        const prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'nl-page-btn nl-page-nav-btn' + (currentPage === 1 ? ' disabled' : '');
        prevBtn.innerHTML = '<i class="ti ti-chevron-left"></i> Prev';
        prevBtn.addEventListener('click', function(e) {
            e.preventDefault();
            if (currentPage > 1) {
                currentPage--;
                renderPage();
            }
        });
        pageNav.appendChild(prevBtn);

        // Page Numbers Logic with ellipsis
        let pages = [];
        if (totalPages <= 7) {
            for (let i = 1; i <= totalPages; i++) pages.push(i);
        } else {
            if (currentPage <= 4) {
                pages = [1, 2, 3, 4, 5, '...', totalPages];
            } else if (currentPage >= totalPages - 3) {
                pages = [1, '...', totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1, totalPages];
            } else {
                pages = [1, '...', currentPage - 1, currentPage, currentPage + 1, '...', totalPages];
            }
        }

        pages.forEach(p => {
            if (p === '...') {
                const ellipsis = document.createElement('span');
                ellipsis.className = 'nl-page-ellipsis';
                ellipsis.textContent = '…';
                pageNav.appendChild(ellipsis);
            } else {
                const btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'nl-page-btn nl-page-num' + (p === currentPage ? ' active' : '');
                btn.textContent = p;
                btn.addEventListener('click', function(e) {
                    e.preventDefault();
                    if (currentPage !== p) {
                        currentPage = p;
                        renderPage();
                    }
                });
                pageNav.appendChild(btn);
            }
        });

        // Next Button
        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'nl-page-btn nl-page-nav-btn' + (currentPage === totalPages ? ' disabled' : '');
        nextBtn.innerHTML = 'Next <i class="ti ti-chevron-right"></i>';
        nextBtn.addEventListener('click', function(e) {
            e.preventDefault();
            if (currentPage < totalPages) {
                currentPage++;
                renderPage();
            }
        });
        pageNav.appendChild(nextBtn);
    }

    function sortPortsTable(columnIndex) {
        const isAscending = portSortDirections[columnIndex];
        portSortDirections[columnIndex] = !isAscending;

        // Reset all sort indicators
        const headers = document.querySelectorAll('#portsTable thead th.sortable');
        headers.forEach((th) => {
            th.classList.remove('sort-active');
            const icon = th.querySelector('.sort-indicator');
            if (icon) {
                icon.className = 'ti ti-arrows-sort sort-indicator ms-1';
            }
        });

        // Set active sort indicator on clicked column
        if (headers[columnIndex]) {
            headers[columnIndex].classList.add('sort-active');
            const icon = headers[columnIndex].querySelector('.sort-indicator');
            if (icon) {
                icon.className = isAscending ? 'ti ti-sort-ascending sort-indicator ms-1' : 'ti ti-sort-descending sort-indicator ms-1';
            }
        }

        const sortFn = (rowA, rowB) => {
            if (columnIndex === 0) {
                const valA = parseInt(rowA.getAttribute('data-id') || '0', 10);
                const valB = parseInt(rowB.getAttribute('data-id') || '0', 10);
                return isAscending ? valA - valB : valB - valA;
            } else if (columnIndex === 1) {
                const valA = (rowA.getAttribute('data-name') || '').toLowerCase();
                const valB = (rowB.getAttribute('data-name') || '').toLowerCase();
                return isAscending ? valA.localeCompare(valB) : valB.localeCompare(valA);
            } else if (columnIndex === 2) {
                const valA = (rowA.getAttribute('data-country') || '').toLowerCase();
                const valB = (rowB.getAttribute('data-country') || '').toLowerCase();
                return isAscending ? valA.localeCompare(valB) : valB.localeCompare(valA);
            } else if (columnIndex === 3) {
                const valA = parseFloat(rowA.getAttribute('data-lat') || '0');
                const valB = parseFloat(rowB.getAttribute('data-lat') || '0');
                return isAscending ? valA - valB : valB - valA;
            } else if (columnIndex === 4) {
                const valA = (rowA.children[4] ? rowA.children[4].innerText : '').trim().toLowerCase();
                const valB = (rowB.children[4] ? rowB.children[4].innerText : '').trim().toLowerCase();
                return isAscending ? valA.localeCompare(valB) : valB.localeCompare(valA);
            }
            return 0;
        };

        allPortRows.sort(sortFn);
        matchingPortRows.sort(sortFn);

        const tbody = document.getElementById('portsTableBody');
        if (tbody) {
            allPortRows.forEach(row => tbody.appendChild(row));
        }

        renderPage();
    }

    function resetFilters() {
        document.getElementById('portSearchInput').value = '';
        const cSelect = document.getElementById('countryFilter');
        if (cSelect.tomselect) {
            cSelect.tomselect.setValue('ALL');
        } else {
            cSelect.value = 'ALL';
        }
        handleFilter();
    }

    // Modal Operations
    function openAddPortModal() {
        document.getElementById('addPortForm').reset();
        document.getElementById('addPortModal').classList.add('show');
    }
    function closeAddPortModal() {
        document.getElementById('addPortModal').classList.remove('show');
    }

    function setPortPreset(name, code, country, lat, lng) {
        document.getElementById('addPortName').value = name;
        document.getElementById('addPortCode').value = code;
        document.getElementById('addCountry').value = country;
        document.getElementById('addLatitude').value = lat;
        document.getElementById('addLongitude').value = lng;
    }

    function openEditPortModal(id, name, code, country, lat, lng) {
        document.getElementById('editPortId').value = id;
        document.getElementById('editPortName').value = name || '';
        document.getElementById('editPortCode').value = code || '';
        document.getElementById('editCountry').value = country || '';
        document.getElementById('editLatitude').value = (lat !== undefined && lat !== 0) ? lat : '';
        document.getElementById('editLongitude').value = (lng !== undefined && lng !== 0) ? lng : '';
        document.getElementById('editPortModal').classList.add('show');
    }
    function closeEditPortModal() {
        document.getElementById('editPortModal').classList.remove('show');
    }

    function openDeletePortModal(id, name, code) {
        document.getElementById('deletePortId').value = id;
        document.getElementById('deletePortNameDisplay').innerText = name || ('PRT-' + id);
        document.getElementById('deletePortCodeDisplay').innerText = code || '';
        document.getElementById('deletePortModal').classList.add('show');
    }
    function closeDeletePortModal() {
        document.getElementById('deletePortModal').classList.remove('show');
    }

    // Backdrop click to close modals
    window.addEventListener('click', function(e) {
        ['addPortModal', 'editPortModal', 'deletePortModal'].forEach(mId => {
            const modal = document.getElementById(mId);
            if (e.target === modal) {
                modal.classList.remove('show');
            }
        });
    });

    // ESC key closes modals
    window.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            ['addPortModal', 'editPortModal', 'deletePortModal'].forEach(mId => {
                const modal = document.getElementById(mId);
                if (modal && modal.classList.contains('show')) {
                    modal.classList.remove('show');
                }
            });
        }
    });
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
