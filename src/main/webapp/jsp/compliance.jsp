<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:include page="/jsp/layout/header.jsp" />

<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-regular-rounded/css/uicons-regular-rounded.css'>
<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-solid-rounded/css/uicons-solid-rounded.css'>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/dist/tabler-icons.min.css">

<style>
    :root {
        --bg-surface: #ffffff;
        --border-color: #E2E8F0;
        --text-main: #0F172A;
        --text-sub: #64748B;
        --primary: #FC8019;
        --primary-light: #FFF3EA;
        --success: #10B981;
        --success-light: #ECFDF5;
        --danger: #EF4444;
        --danger-light: #FEF2F2;
        --warning: #F59E0B;
        --warning-light: #FFFBEB;
        --info: #3B82F6;
        --info-light: #EFF6FF;
    }
    body {
        background-color: #F8FAFC;
    }
    .dashboard-container {
        padding: 24px;
        max-width: 1400px;
        margin: 0 auto;
    }

    /* Frameless Telemetry Header Hero */
    .telemetry-header-card {
        background: transparent !important;
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
        transition: all 0.2s ease;
        text-decoration: none;
    }
    .btn-register-primary:hover {
        background: #E67012;
        transform: translateY(-1px);
        box-shadow: 0 6px 18px rgba(252, 128, 25, 0.35);
    }

    /* Expiry Alert Banner */
    .expiry-alert-banner {
        background: #F3E8FF;
        border: 1px solid #E9D5FF;
        border-radius: 16px;
        padding: 14px 20px;
        margin-bottom: 24px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.02);
    }
    .expiry-alert-head {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 13.5px;
        color: #6B21A8;
    }
    .expiry-alert-toggle {
        margin-left: auto;
        color: #9333EA;
        cursor: pointer;
        font-size: 12.5px;
        font-weight: 600;
        text-decoration: underline;
    }
    .expiry-alert-list {
        margin-top: 12px;
        border-top: 1px solid #E9D5FF;
        padding-top: 10px;
    }
    .expiry-alert-row {
        display: flex;
        justify-content: space-between;
        padding: 6px 0;
        font-size: 13px;
        color: #4C1D95;
    }

    /* KPI Cards */
    .kpi-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
        gap: 16px;
        margin-bottom: 24px;
    }
    .kpi-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 16px;
        padding: 18px 20px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03);
        display: flex;
        align-items: center;
        gap: 16px;
        transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
    }
    .kpi-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(0,0,0,0.06);
        border-color: #CBD5E1;
    }
    .kpi-icon {
        width: 48px;
        height: 48px;
        border-radius: 50% !important;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        flex-shrink: 0;
    }
    .kpi-icon.icon-docs { background: #FFF3EA; color: #FC8019; }
    .kpi-icon.icon-approved { background: #ECFDF5; color: #10B981; }
    .kpi-icon.icon-review { background: #FFFBEB; color: #F59E0B; }
    .kpi-icon.icon-rejected { background: #FEF2F2; color: #EF4444; }
    .kpi-icon.icon-expiring { background: #F3E8FF; color: #9333EA; }

    .kpi-data { flex: 1; }
    .kpi-title {
        color: #64748B;
        font-size: 11.5px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.4px;
        margin-bottom: 4px;
    }
    .kpi-val {
        color: #0F172A;
        font-size: 24px;
        font-weight: 800;
        line-height: 1.2;
    }
    .kpi-sub {
        color: #94A3B8;
        font-size: 11.5px;
        margin-top: 4px;
        font-weight: 500;
    }

    /* Unified Compliance Table Panel & Toolbar */
    .compliance-table-panel.card.tracking-card.no-card-tools {
        padding: 0 !important;
        overflow: hidden !important;
        border-radius: 16px !important;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
        margin-bottom: 32px;
    }
    .toolbar-card {
        background: #FFFFFF;
        border-bottom: 1px solid #F1F5F9;
        padding: 14px 20px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 14px;
    }
    .nav-tabs-pill {
        display: flex;
        align-items: center;
        gap: 6px;
        background: #F8FAFC;
        padding: 4px;
        border-radius: 50px;
        border: 1px solid #E2E8F0;
        flex-wrap: wrap;
    }
    .tab-pill-btn {
        background: transparent;
        border: none;
        padding: 7px 14px;
        border-radius: 50px;
        font-size: 12.5px;
        font-weight: 600;
        color: #64748B;
        cursor: pointer;
        transition: all 0.2s ease;
        display: flex;
        align-items: center;
        gap: 6px;
        text-decoration: none;
    }
    .tab-pill-btn:hover { color: #0F172A; }
    .tab-pill-btn.active {
        background: #FFFFFF;
        color: #FC8019;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
        font-weight: 700;
    }
    .tab-count-badge {
        background: #E2E8F0;
        color: #475569;
        font-size: 11px;
        font-weight: 700;
        padding: 1px 7px;
        border-radius: 50px;
        transition: all 0.2s ease;
    }
    .tab-pill-btn.active .tab-count-badge {
        background: #FFF3EA;
        color: #FC8019;
    }

    .toolbar-actions {
        display: flex;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
    }
    .search-wrap {
        position: relative;
        width: 240px;
    }
    .search-wrap i.search-icon {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #94A3B8;
        font-size: 15px;
        pointer-events: none;
    }
    .search-input {
        width: 100%;
        height: 38px;
        border-radius: 50px;
        border: 1.5px solid #E2E8F0;
        padding: 0 34px 0 38px;
        font-size: 12.5px;
        color: #1E293B;
        background: #FFFFFF;
        outline: none;
        transition: all 0.2s ease;
    }
    .search-input:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .search-clear {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        color: #94A3B8;
        cursor: pointer;
        display: none;
        font-size: 14px;
    }
    .search-clear:hover { color: #0F172A; }

    .type-filter-select {
        height: 38px;
        border-radius: 50px !important;
        border: 1.5px solid #E2E8F0;
        padding: 0 32px 0 14px;
        font-size: 12.5px;
        font-weight: 600;
        color: #1E293B;
        background-color: #FFFFFF;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23FC8019' stroke-linecap='round' stroke-linejoin='round' stroke-width='2.2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
        background-repeat: no-repeat !important;
        background-position: right 12px center !important;
        background-size: 10px 8px !important;
        cursor: pointer;
        outline: none;
        appearance: none;
        -webkit-appearance: none;
        transition: all 0.2s ease;
    }
    .type-filter-select:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12) !important;
    }

    .table-counter-badge {
        font-size: 12px;
        font-weight: 600;
        color: #64748B;
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        padding: 5px 12px;
        border-radius: 50px;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        white-space: nowrap;
    }

    /* Enterprise Table Styles */
    table.enterprise-table,
    table.tracking-table {
        width: 100%;
        border-collapse: collapse;
        margin: 0;
    }
    .enterprise-table thead th,
    .tracking-table thead th {
        background: #F8FAFC;
        padding: 14px 18px;
        font-size: 11.5px;
        font-weight: 700;
        color: #64748B;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border-bottom: 1px solid #E2E8F0;
        text-align: left;
        white-space: nowrap;
    }
    .enterprise-table tbody td,
    .tracking-table tbody td {
        padding: 14px 18px;
        border-bottom: 1px solid #F1F5F9;
        vertical-align: middle;
        font-size: 13.5px;
        color: #1E293B;
    }
    .enterprise-table tr:last-child td,
    .tracking-table tr:last-child td { border-bottom: none; }
    .enterprise-table tr.doc-row:hover td,
    .tracking-table tr.doc-row:hover td { background-color: #FAFAFA; }

    /* Sortable Header Columns */
    .enterprise-table th.sortable,
    .tracking-table th.sortable {
        cursor: pointer !important;
        user-select: none !important;
        transition: all 0.15s ease !important;
    }
    .enterprise-table th.sortable:hover,
    .tracking-table th.sortable:hover {
        color: #FC8019 !important;
        background-color: #FFF3EA !important;
    }
    .enterprise-table th.sort-active,
    .tracking-table th.sort-active {
        color: #FC8019 !important;
    }
    .sort-indicator {
        font-size: 13px;
        color: #94A3B8;
        vertical-align: middle;
        transition: color 0.15s ease;
    }
    .enterprise-table th.sortable:hover .sort-indicator,
    .enterprise-table th.sort-active .sort-indicator,
    .tracking-table th.sortable:hover .sort-indicator,
    .tracking-table th.sort-active .sort-indicator {
        color: #FC8019 !important;
    }

    /* Circular and Pill Shaped Badges & Buttons */
    .status-badge {
        padding: 5px 12px;
        border-radius: 50px !important;
        font-size: 11.5px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        white-space: nowrap;
    }
    .status-approved { background: #ECFDF5; color: #10B981; border: 1px solid #A7F3D0; }
    .status-review { background: #FFFBEB; color: #D97706; border: 1px solid #FDE68A; }
    .status-rejected { background: #FEF2F2; color: #EF4444; border: 1px solid #FECACA; }
    .status-expired { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }
    .status-pending { background: #FFFBEB; color: #D97706; border: 1px solid #FDE68A; }

    .action-cell {
        display: flex;
        gap: 8px;
        align-items: center;
        justify-content: flex-end;
    }
    .btn-icon {
        width: 34px;
        height: 34px;
        border-radius: 50% !important;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        color: #64748B;
        cursor: pointer;
        transition: all 0.2s;
    }
    .btn-icon:hover {
        background: #F8FAFC;
        color: #0F172A;
        border-color: #CBD5E1;
    }
    .btn-view { color: #2563EB; border-color: #BFDBFE; background: #EFF6FF; }
    .btn-view:hover { background: #DBEAFE; color: #1D4ED8; }
    .btn-edit { color: #D97706; border-color: #FDE68A; background: #FFFBEB; }
    .btn-edit:hover { background: #FEF3C7; color: #B45309; }

    .dropdown-container {
        position: relative;
    }
    .dropdown-menu-custom {
        position: absolute;
        right: 0;
        top: 100%;
        margin-top: 6px;
        background: white;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        box-shadow: 0 10px 25px rgba(15, 23, 42, 0.12), 0 4px 10px rgba(15, 23, 42, 0.06);
        min-width: 150px;
        z-index: 9999;
        display: none;
        padding: 6px;
    }
    .dropdown-menu-custom.show {
        display: block;
    }
    .dropdown-item {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 12px;
        color: #1E293B;
        text-decoration: none;
        font-size: 13px;
        border-radius: 8px;
        transition: all 0.15s ease;
    }
    .dropdown-item:hover {
        background: #F1F5F9;
        color: #0F172A;
    }
    .text-danger { color: #EF4444 !important; }

    /* Global Enterprise Circular Pagination Bar */
    .nl-pagination-wrapper {
        padding: 16px 24px;
        border-top: 1px solid #F1F5F9;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 14px;
        background: #FFFFFF;
    }
    .nl-pagination-info {
        font-size: 13px;
        color: #64748B;
        font-weight: 500;
    }
    .nl-pagination-info strong {
        color: #0F172A;
        font-weight: 700;
    }
    .nl-pagination-nav {
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .nl-page-btn {
        height: 36px;
        min-width: 36px;
        padding: 0 10px;
        border: 1.5px solid #E2E8F0;
        background: #FFFFFF;
        color: #475569;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        transition: all 0.18s ease;
    }
    .nl-page-btn.nl-page-num {
        width: 36px;
        height: 36px;
        padding: 0;
        border-radius: 50% !important;
    }
    .nl-page-btn.nl-page-nav-btn {
        border-radius: 50px !important;
        padding: 0 16px;
        gap: 6px;
    }
    .nl-page-btn:hover:not(.disabled):not(.active) {
        border-color: #FC8019;
        color: #FC8019;
        background: #FFF3EA;
    }
    .nl-page-btn.active {
        background: #FC8019 !important;
        border-color: #FC8019 !important;
        color: #FFFFFF !important;
        font-weight: 700;
        box-shadow: 0 3px 10px rgba(252, 128, 25, 0.35);
    }
    .nl-page-btn.disabled {
        opacity: 0.4;
        cursor: not-allowed;
        pointer-events: none;
    }
    .nl-page-ellipsis {
        padding: 0 4px;
        color: #94A3B8;
        font-weight: 700;
    }

    /* Modal Overlay & Dialogs */
    .modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(15, 23, 42, 0.5);
        backdrop-filter: blur(4px);
        -webkit-backdrop-filter: blur(4px);
        display: none;
        align-items: center;
        justify-content: center;
        z-index: 99999;
        opacity: 0;
        visibility: hidden;
        pointer-events: none;
        transition: opacity 0.2s ease;
        padding: 20px;
    }
    .modal-overlay.active {
        display: flex !important;
        opacity: 1 !important;
        visibility: visible !important;
        pointer-events: auto !important;
    }
    .modal-overlay:not(.active) {
        display: none !important;
        visibility: hidden !important;
        pointer-events: none !important;
    }
    .modal-overlay:not(.active) * {
        pointer-events: none !important;
    }
    .modal-content {
        background: #FFFFFF;
        border-radius: 20px !important;
        width: 100%;
        max-width: 520px;
        padding: 26px 28px;
        box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.25);
        border: 1px solid #E2E8F0;
        transform: translateY(20px);
        transition: transform 0.2s ease;
        position: relative;
        max-height: 90vh;
        overflow-y: auto;
    }
    .modal-overlay.active .modal-content {
        transform: translateY(0);
    }
    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
    }
    .modal-header h3 {
        margin: 0;
        font-size: 18px;
        font-weight: 700;
        color: #0F172A;
    }
    .modal-close {
        background: #F1F5F9;
        border: none;
        width: 32px;
        height: 32px;
        border-radius: 50% !important;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #64748B;
        cursor: pointer;
        font-size: 15px;
        transition: all 0.15s ease;
    }
    .modal-close:hover {
        background: #E2E8F0;
        color: #0F172A;
    }
    .form-group {
        margin-bottom: 16px;
    }
    .form-group label {
        display: block;
        font-size: 12.5px;
        font-weight: 600;
        margin-bottom: 6px;
        color: #475569;
    }
    .form-control {
        width: 100%;
        padding: 10px 14px;
        border: 1.5px solid #E2E8F0;
        border-radius: 50px;
        font-size: 13.5px;
        color: #1E293B;
        background-color: #FFFFFF;
        outline: none;
        transition: all 0.2s ease;
        box-sizing: border-box;
    }
    input[type="file"].form-control {
        height: auto !important;
        min-height: 48px !important;
        display: flex !important;
        align-items: center !important;
        padding: 6px 10px !important;
        border-radius: 12px !important;
        line-height: 1 !important;
        box-sizing: border-box !important;
    }
    input[type="file"]::file-selector-button,
    input[type="file"]::-webkit-file-upload-button {
        background: #F1F5F9;
        color: #334155;
        border: 1px solid #CBD5E1;
        border-radius: 50px !important;
        height: 32px !important;
        line-height: 30px !important;
        padding: 0 16px !important;
        font-size: 12px !important;
        font-weight: 600 !important;
        cursor: pointer !important;
        transition: all 0.2s ease;
        margin: 0 14px 0 0 !important;
        margin-inline-end: 14px !important;
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        box-sizing: border-box !important;
        vertical-align: middle !important;
    }
    input[type="file"]::file-selector-button:hover,
    input[type="file"]::-webkit-file-upload-button:hover {
        background: #E2E8F0;
        color: #FC8019;
    }
    .form-control:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }

    /* Modal Select Wrapper & Orange Custom Native Select */
    .select-wrapper {
        position: relative;
        width: 100%;
    }
    .select-wrapper select.form-select-custom,
    select.form-select-custom.no-custom-select {
        appearance: none;
        -webkit-appearance: none;
        -moz-appearance: none;
        width: 100%;
        height: 42px;
        padding: 0 38px 0 16px;
        border: 1.5px solid #E2E8F0;
        border-radius: 50px !important;
        font-size: 13.5px;
        font-weight: 500;
        color: #1E293B;
        background-color: #FFFFFF;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23FC8019' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
        background-repeat: no-repeat !important;
        background-position: right 14px center !important;
        background-size: 12px 10px !important;
        cursor: pointer;
        outline: none;
        transition: border-color 0.15s ease, box-shadow 0.15s ease;
        box-sizing: border-box;
    }
    .select-wrapper select.form-select-custom:focus,
    select.form-select-custom.no-custom-select:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12) !important;
        outline: none !important;
    }

    .modal-actions {
        display: flex;
        justify-content: flex-end;
        gap: 12px;
        margin-top: 24px;
    }
    .btn-modal-cancel {
        padding: 9px 20px;
        border-radius: 50px !important;
        font-size: 13px;
        font-weight: 600;
        background: #F1F5F9;
        border: 1px solid #E2E8F0;
        color: #475569;
        cursor: pointer;
        transition: all 0.2s ease;
    }
    .btn-modal-cancel:hover {
        background: #E2E8F0;
        color: #0F172A;
    }
    .btn-modal-submit {
        padding: 9px 24px;
        border-radius: 50px !important;
        font-size: 13px;
        font-weight: 600;
        background: #FC8019;
        border: none;
        color: #FFFFFF;
        cursor: pointer;
        box-shadow: 0 3px 10px rgba(252, 128, 25, 0.3);
        transition: all 0.2s ease;
    }
    .btn-modal-submit:hover {
        background: #E67012;
    }
    .btn-modal-danger {
        padding: 9px 24px;
        border-radius: 50px !important;
        font-size: 13px;
        font-weight: 600;
        background: #EF4444;
        border: none;
        color: #FFFFFF;
        cursor: pointer;
        box-shadow: 0 3px 10px rgba(239, 68, 68, 0.3);
        transition: all 0.2s ease;
    }
    .btn-modal-danger:hover {
        background: #DC2626;
    }

    /* ==========================================================================
       DARK THEME STYLES [data-theme="dark"] FOR GOVERNMENT COMPLIANCE
       ========================================================================== */
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
    }

    [data-theme="dark"] .expiry-alert-banner {
        background: rgba(147, 51, 234, 0.12) !important;
        border-color: rgba(147, 51, 234, 0.35) !important;
    }
    [data-theme="dark"] .expiry-alert-head {
        color: #D8B4FE !important;
    }
    [data-theme="dark"] .expiry-alert-toggle {
        color: #C084FC !important;
    }
    [data-theme="dark"] .expiry-alert-list {
        border-top-color: rgba(147, 51, 234, 0.3) !important;
    }
    [data-theme="dark"] .expiry-alert-row {
        color: #E9D5FF !important;
    }

    [data-theme="dark"] .kpi-card {
        background: #101820 !important;
        border-color: #22303A !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .kpi-card:hover {
        border-color: #2D3F4D !important;
        box-shadow: 0 8px 25px rgba(0, 0, 0, 0.45) !important;
    }
    [data-theme="dark"] .kpi-title {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .kpi-val {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .kpi-sub {
        color: #64748B !important;
    }
    [data-theme="dark"] .kpi-icon.icon-docs { background: rgba(252, 128, 25, 0.18) !important; color: #FC8019 !important; }
    [data-theme="dark"] .kpi-icon.icon-approved { background: rgba(16, 185, 129, 0.18) !important; color: #34D399 !important; }
    [data-theme="dark"] .kpi-icon.icon-review { background: rgba(245, 158, 11, 0.18) !important; color: #FBBF24 !important; }
    [data-theme="dark"] .kpi-icon.icon-rejected { background: rgba(239, 68, 68, 0.18) !important; color: #F87171 !important; }
    [data-theme="dark"] .kpi-icon.icon-expiring { background: rgba(147, 51, 234, 0.18) !important; color: #C084FC !important; }

    /* Compliance Table Panel in Dark Mode */
    [data-theme="dark"] .compliance-table-panel.card.tracking-card.no-card-tools {
        background: #101820 !important;
        border-color: #22303A !important;
        box-shadow: 0 8px 30px rgba(0, 0, 0, 0.45) !important;
    }
    [data-theme="dark"] .toolbar-card {
        background: #101820 !important;
        border-color: #22303A !important;
    }
    [data-theme="dark"] .nav-tabs-pill {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
    }
    [data-theme="dark"] .tab-pill-btn {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .tab-pill-btn:hover {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .tab-pill-btn.active {
        background: #22303A !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .tab-count-badge {
        background: #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .tab-pill-btn.active .tab-count-badge {
        background: rgba(252, 128, 25, 0.2) !important;
        color: #FC8019 !important;
    }

    [data-theme="dark"] .search-input {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .search-input:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.22) !important;
    }
    [data-theme="dark"] .type-filter-select {
        background-color: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .type-filter-select:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.22) !important;
    }
    [data-theme="dark"] .table-counter-badge {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #CBD5E1 !important;
    }

    /* Table in Dark Mode */
    [data-theme="dark"] .enterprise-table thead th,
    [data-theme="dark"] .tracking-table thead th {
        background-color: #0B1520 !important;
        color: #94A3B8 !important;
        border-bottom: 1px solid #22303A !important;
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
    [data-theme="dark"] .enterprise-table tr.doc-row:hover td,
    [data-theme="dark"] .tracking-table tr.doc-row:hover td {
        background-color: rgba(255, 255, 255, 0.03) !important;
    }
    [data-theme="dark"] .enterprise-table tr:last-child td,
    [data-theme="dark"] .tracking-table tr:last-child td {
        border-bottom: none !important;
    }

    /* Actions & Dropdowns in Dark Mode */
    [data-theme="dark"] .btn-icon {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .btn-icon:hover {
        background: #1E293B !important;
        color: #F8FAFC !important;
        border-color: #475569 !important;
    }
    [data-theme="dark"] .btn-view {
        background: rgba(37, 99, 235, 0.16) !important;
        border-color: #2563EB !important;
        color: #60A5FA !important;
    }
    [data-theme="dark"] .btn-edit {
        background: rgba(245, 158, 11, 0.16) !important;
        border-color: #F59E0B !important;
        color: #FBBF24 !important;
    }
    [data-theme="dark"] .dropdown-menu-custom {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.6) !important;
    }
    [data-theme="dark"] .dropdown-item {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .dropdown-item:hover {
        background: #1E293B !important;
        color: #F8FAFC !important;
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

    /* Modals & Inputs Active/Focus Dark Mode Fix */
    [data-theme="dark"] .modal-content {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.6) !important;
    }
    [data-theme="dark"] .modal-header h3 {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .modal-close {
        background: #101820 !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .modal-close:hover {
        background: #1E293B !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .form-group label {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .form-control,
    [data-theme="dark"] .select-wrapper select.form-select-custom,
    [data-theme="dark"] select.form-select-custom.no-custom-select {
        background-color: #101820 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .form-control:focus,
    [data-theme="dark"] .select-wrapper select.form-select-custom:focus,
    [data-theme="dark"] select.form-select-custom.no-custom-select:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.22) !important;
        background-color: #101820 !important;
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

    /* Status Badges in Dark Mode (Signature Translucent Fills) */
    [data-theme="dark"] .status-badge {
        border-radius: 50px !important;
        font-weight: 600 !important;
    }
    [data-theme="dark"] .status-approved {
        background: rgba(16, 185, 129, 0.16) !important;
        color: #34D399 !important;
        border: 1px solid rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .status-review,
    [data-theme="dark"] .status-pending {
        background: rgba(245, 158, 11, 0.16) !important;
        color: #FBBF24 !important;
        border: 1px solid rgba(245, 158, 11, 0.3) !important;
    }
    [data-theme="dark"] .status-rejected,
    [data-theme="dark"] .status-expired {
        background: rgba(239, 68, 68, 0.16) !important;
        color: #F87171 !important;
        border: 1px solid rgba(239, 68, 68, 0.3) !important;
    }

    /* File Input & Choose File Button in Dark Mode */
    [data-theme="dark"] input[type="file"].form-control {
        background-color: #101820 !important;
        border-color: #2D3F4D !important;
        color: #94A3B8 !important;
        height: auto !important;
        min-height: 48px !important;
        display: flex !important;
        align-items: center !important;
        padding: 6px 10px !important;
        box-sizing: border-box !important;
        line-height: 1 !important;
    }
    [data-theme="dark"] input[type="file"]::file-selector-button,
    [data-theme="dark"] input[type="file"]::-webkit-file-upload-button {
        background: #1E293B !important;
        color: #F8FAFC !important;
        border: 1px solid #2D3F4D !important;
        border-radius: 50px !important;
        height: 32px !important;
        line-height: 30px !important;
        padding: 0 16px !important;
        font-size: 12px !important;
        font-weight: 600 !important;
        cursor: pointer !important;
        transition: all 0.2s ease !important;
        margin: 0 14px 0 0 !important;
        margin-inline-end: 14px !important;
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        box-sizing: border-box !important;
        vertical-align: middle !important;
    }
    [data-theme="dark"] input[type="file"]::file-selector-button:hover,
    [data-theme="dark"] input[type="file"]::-webkit-file-upload-button:hover {
        background: #2D3F4D !important;
        color: #FC8019 !important;
        border-color: #FC8019 !important;
    }

    /* Date Picker Calendar Icon Dark Theme Fix */
    [data-theme="dark"] input[type="date"] {
        color-scheme: dark !important;
    }
    [data-theme="dark"] input[type="date"]::-webkit-calendar-picker-indicator {
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%23FFFFFF' stroke-width='2.2' stroke-linecap='round' stroke-linejoin='round'%3E%3Crect width='18' height='18' x='3' y='4' rx='2' ry='2'/%3E%3Cline x1='16' x2='16' y1='2' y2='6'/%3E%3Cline x1='8' x2='8' y1='2' y2='6'/%3E%3Cline x1='3' x2='21' y1='10' y2='10'/%3E%3C/svg%3E") !important;
        background-repeat: no-repeat !important;
        background-position: center !important;
        background-size: 16px 16px !important;
        cursor: pointer !important;
        filter: none !important;
        -webkit-filter: none !important;
        opacity: 0.95 !important;
    }
    [data-theme="dark"] input[type="date"]::-webkit-calendar-picker-indicator:hover {
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%23FC8019' stroke-width='2.4' stroke-linecap='round' stroke-linejoin='round'%3E%3Crect width='18' height='18' x='3' y='4' rx='2' ry='2'/%3E%3Cline x1='16' x2='16' y1='2' y2='6'/%3E%3Cline x1='8' x2='8' y1='2' y2='6'/%3E%3Cline x1='3' x2='21' y1='10' y2='10'/%3E%3C/svg%3E") !important;
        opacity: 1 !important;
    }
</style>

<div class="dashboard-container">
    <!-- Frameless Telemetry Header Hero -->
    <div class="telemetry-header-card">
        <div class="telemetry-header-left">
            <div class="telemetry-icon-box">
                <i class="fi fi-sr-shield-check"></i>
            </div>
            <div>
                <h1 class="telemetry-title">Government Compliance</h1>
                <p class="telemetry-desc">Upload, manage and track regulatory compliance documents, customs clearance, and shipment permits.</p>
            </div>
        </div>
        <div class="telemetry-actions">
            <button class="btn-register-primary" onclick="openModal('uploadModal')">
                <i class="fi fi-rr-upload"></i> Upload New Document
            </button>
        </div>
    </div>

    <!-- Expiring Docs Alert Banner -->
    <c:if test="${not empty expiringDocs}">
    <div class="expiry-alert-banner">
        <div class="expiry-alert-head">
            <i class="fi fi-rr-bell" style="color:#9333EA; font-size:16px;"></i>
            <strong>${fn:length(expiringDocs)} compliance document<c:if test="${fn:length(expiringDocs) != 1}">s</c:if> expiring within 15 days</strong>
            <span class="expiry-alert-toggle" onclick="var el=document.getElementById('expiryAlertList'); el.style.display = (el.style.display==='none'?'block':'none');">Show details</span>
        </div>
        <div id="expiryAlertList" class="expiry-alert-list" style="display:none;">
            <c:forEach var="ed" items="${expiringDocs}">
                <div class="expiry-alert-row">
                    <span><strong>DOC-${ed.docId}</strong> &middot; ${ed.docType} &middot; SHP-${ed.shipmentId}</span>
                    <span>Expires <fmt:formatDate value="${ed.expiryDate}" pattern="dd MMM yyyy"/></span>
                </div>
            </c:forEach>
        </div>
    </div>
    </c:if>

    <!-- KPI Metric Cards -->
    <div class="kpi-grid">
        <div class="kpi-card">
            <div class="kpi-icon icon-docs"><i class="fi fi-rr-document"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Total Documents</div>
                <div class="kpi-val">${docTotal}</div>
                <div class="kpi-sub">All Time</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-approved"><i class="fi fi-rr-check-circle"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Approved</div>
                <div class="kpi-val">${docApproved}</div>
                <div class="kpi-sub"><fmt:formatNumber value="${docTotal > 0 ? (docApproved/docTotal)*100 : 0}" maxFractionDigits="0"/>% of total</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-review"><i class="fi fi-rr-time-fast"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Under Review</div>
                <div class="kpi-val">${docReview}</div>
                <div class="kpi-sub"><fmt:formatNumber value="${docTotal > 0 ? (docReview/docTotal)*100 : 0}" maxFractionDigits="0"/>% of total</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-rejected"><i class="fi fi-rr-cross-circle"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Rejected</div>
                <div class="kpi-val">${docRejected}</div>
                <div class="kpi-sub"><fmt:formatNumber value="${docTotal > 0 ? (docRejected/docTotal)*100 : 0}" maxFractionDigits="0"/>% of total</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-expiring"><i class="fi fi-rr-calendar-clock"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Expiring Soon</div>
                <div class="kpi-val">${docExpiring}</div>
                <div class="kpi-sub">Next 15 days</div>
            </div>
        </div>
    </div>

    <!-- Unified Enterprise Document Repository Card -->
    <div class="compliance-table-panel card tracking-card no-card-tools">
        <!-- Interactive Toolbar -->
        <div class="toolbar-card">
            <div class="nav-tabs-pill">
                <button type="button" class="tab-pill-btn active" data-status="ALL" onclick="filterByDocStatus('ALL', this)">
                    All <span class="tab-count-badge">${fn:length(documents)}</span>
                </button>
                <button type="button" class="tab-pill-btn" data-status="Approved" onclick="filterByDocStatus('Approved', this)">
                    Approved <span class="tab-count-badge">${docApproved}</span>
                </button>
                <button type="button" class="tab-pill-btn" data-status="Under Review" onclick="filterByDocStatus('Under Review', this)">
                    Under Review <span class="tab-count-badge">${docReview}</span>
                </button>
                <button type="button" class="tab-pill-btn" data-status="Rejected" onclick="filterByDocStatus('Rejected', this)">
                    Rejected <span class="tab-count-badge">${docRejected}</span>
                </button>
            </div>
            
            <div class="toolbar-actions">
                <div class="search-wrap">
                    <i class="fi fi-rr-search search-icon"></i>
                    <input type="text" id="docSearchInput" class="search-input" placeholder="Search doc, shipment, type..." onkeyup="handleDocFilter()">
                    <button type="button" id="docSearchClear" class="search-clear" onclick="clearDocSearch()">&times;</button>
                </div>
                <div>
                    <select id="docTypeFilter" class="type-filter-select" onchange="handleDocFilter()">
                        <option value="">All Document Types</option>
                        <option value="Customs Declaration">Customs Declaration</option>
                        <option value="Import License">Import License</option>
                        <option value="Export License">Export License</option>
                        <option value="Certificate of Origin">Certificate of Origin</option>
                        <option value="Insurance">Insurance</option>
                        <option value="Inspection">Inspection</option>
                    </select>
                </div>
                <span class="table-counter-badge" id="docTableCount">
                    <i class="ti ti-file-text"></i> <span id="docCountValue">${fn:length(documents)}</span> Documents
                </span>
            </div>
        </div>

        <!-- Table -->
        <table id="docsTable" class="enterprise-table tracking-table">
            <thead>
                <tr>
                    <th class="sortable" onclick="sortDocsTable('id')">Document ID <i class="ti ti-arrows-sort sort-indicator ms-1" id="sort-icon-id"></i></th>
                    <th class="sortable" onclick="sortDocsTable('shipment')">Shipment ID <i class="ti ti-arrows-sort sort-indicator ms-1" id="sort-icon-shipment"></i></th>
                    <th class="sortable" onclick="sortDocsTable('type')">Document Type <i class="ti ti-arrows-sort sort-indicator ms-1" id="sort-icon-type"></i></th>
                    <th class="sortable" onclick="sortDocsTable('date')">Uploaded On <i class="ti ti-arrows-sort sort-indicator ms-1" id="sort-icon-date"></i></th>
                    <th class="sortable" onclick="sortDocsTable('user')">Uploaded By <i class="ti ti-arrows-sort sort-indicator ms-1" id="sort-icon-user"></i></th>
                    <th class="sortable" onclick="sortDocsTable('status')">Status <i class="ti ti-arrows-sort sort-indicator ms-1" id="sort-icon-status"></i></th>
                    <th class="sortable" onclick="sortDocsTable('expiry')">Expiry Date <i class="ti ti-arrows-sort sort-indicator ms-1" id="sort-icon-expiry"></i></th>
                    <th style="text-align: right;">Actions</th>
                </tr>
            </thead>
            <tbody id="docsTableBody">
                <c:if test="${empty documents}">
                    <tr id="emptyDocsRow">
                        <td colspan="8" style="text-align: center; padding: 48px; color: var(--text-sub);">
                            <i class="fi fi-rr-document" style="font-size: 36px; display: block; margin-bottom: 12px; color: #CBD5E1;"></i>
                            No compliance documents found in the database.
                        </td>
                    </tr>
                </c:if>
                <c:forEach var="doc" items="${documents}">
                    <tr class="doc-row"
                        data-id="${doc.docId}"
                        data-shipment="${doc.shipmentId}"
                        data-type="${fn:escapeXml(doc.docType)}"
                        data-date="${doc.issueDate}"
                        data-user="${doc.uploadedBy}"
                        data-status="${doc.status}"
                        data-expiry="${doc.expiryDate}"
                        data-search="DOC-${doc.docId} SHP-${doc.shipmentId} ${doc.docType} ${doc.status} ${doc.uploadedBy}">
                        <td><strong>DOC-${doc.docId}</strong></td>
                        <td>SHP-${doc.shipmentId}</td>
                        <td>${doc.docType}</td>
                        <td>${doc.issueDate}</td>
                        <td>User #${doc.uploadedBy}</td>
                        <td>
                            <c:choose>
                                <c:when test="${doc.status == 'Approved'}"><span class="status-badge status-approved"><i class="fi fi-rr-check"></i> ${doc.status}</span></c:when>
                                <c:when test="${doc.status == 'Rejected'}"><span class="status-badge status-rejected"><i class="fi fi-rr-cross"></i> ${doc.status}</span></c:when>
                                <c:when test="${doc.status == 'Expired'}"><span class="status-badge status-expired"><i class="fi fi-rr-clock"></i> ${doc.status}</span></c:when>
                                <c:otherwise><span class="status-badge status-review"><i class="fi fi-rr-time-fast"></i> ${doc.status}</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>${doc.expiryDate}</td>
                        <td>
                            <div class="action-cell">
                                <%-- View & Verify: opens the document with Approve/Reject for staff --%>
                                <button class="btn-icon btn-view"
                                        title="${sessionScope.user.roleId <= 3 ? 'View &amp; Review Document' : 'View Document'}"
                                        onclick="window.open('${pageContext.request.contextPath}/compliance-document?id=${doc.docId}', '_blank')"><i class="fi fi-rr-eye"></i></button>
                                <%-- Quick status change: Admins and Operations only --%>
                                <c:if test="${sessionScope.user.roleId <= 3}">
                                    <button class="btn-icon btn-edit" title="Update Status" onclick="document.getElementById('updateDocId').value='${doc.docId}'; document.getElementById('updateDocStatus').value='${doc.status}'; openModal('docUpdateModal');"><i class="fi fi-rr-edit"></i></button>
                                </c:if>
                                <div class="dropdown-container">
                                    <button class="btn-icon action-dropdown" onclick="toggleDropdown(this)"><i class="fi fi-rr-menu-dots-vertical"></i></button>
                                    <div class="dropdown-menu-custom">
                                        <a href="${pageContext.request.contextPath}/${doc.filePath}" download class="dropdown-item"><i class="fi fi-rr-download"></i> Download</a>
                                        <c:if test="${sessionScope.user.roleId <= 2}">
                                            <a href="#" class="dropdown-item text-danger" onclick="document.getElementById('deleteDocId').value='${doc.docId}'; openModal('docDeleteModal'); return false;"><i class="fi fi-rr-trash"></i> Delete</a>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

        <!-- Global Enterprise Circular Pagination Bar -->
        <div class="nl-pagination-wrapper" id="docsPagination">
            <div class="nl-pagination-info">
                Showing <strong id="docPageStart">0</strong> to <strong id="docPageEnd">0</strong> of <strong id="docTotalRows">0</strong> documents
            </div>
            <div class="nl-pagination-nav" id="docsPageNav"></div>
        </div>
    </div>

    <!-- Upload Document Modal -->
    <div class="modal-overlay" id="uploadModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Upload New Document</h3>
                <button class="modal-close" onclick="closeModal('uploadModal')"><i class="fi fi-rr-cross"></i></button>
            </div>
            <form action="${pageContext.request.contextPath}/compliance/upload" method="post" enctype="multipart/form-data">
                <div class="form-group">
                    <label>Related Shipment</label>
                    <div class="select-wrapper">
                        <select name="shipmentId" class="form-select form-select-custom no-custom-select" required>
                            <option value="">Select Shipment...</option>
                            <c:forEach var="s" items="${shipments}">
                                <option value="${s.shipmentId}">SHP-${s.shipmentId}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label>Document Type</label>
                    <div class="select-wrapper">
                        <select name="docType" class="form-select form-select-custom no-custom-select" required>
                            <option value="">Select Type...</option>
                            <option value="Customs Declaration">Customs Declaration</option>
                            <option value="Import License">Import License</option>
                            <option value="Export License">Export License</option>
                            <option value="Certificate of Origin">Certificate of Origin</option>
                            <option value="Insurance">Insurance</option>
                            <option value="Inspection">Inspection</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label>Document Number</label>
                    <input type="text" name="docNumber" class="form-control" required placeholder="e.g. CUS-2024-8899">
                </div>
                <div class="form-group">
                    <label>Issuing Authority</label>
                    <input type="text" name="issuingAuthority" class="form-control" required placeholder="e.g. US Customs">
                </div>
                <div style="display:flex; gap:16px;">
                    <div class="form-group" style="flex:1;">
                        <label>Issue Date</label>
                        <input type="date" name="issueDate" class="form-control" required>
                    </div>
                    <div class="form-group" style="flex:1;">
                        <label>Expiry Date</label>
                        <input type="date" name="expiryDate" class="form-control" required>
                    </div>
                </div>
                <div class="form-group">
                    <label>File Attachment (PDF/Image)</label>
                    <input type="file" name="docFile" class="form-control" required>
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn-modal-cancel" onclick="closeModal('uploadModal')">Cancel</button>
                    <button type="submit" class="btn-modal-submit"><i class="fi fi-rr-upload"></i> Upload</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Update Document Status Modal -->
    <div class="modal-overlay" id="docUpdateModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Update Document Status</h3>
                <button class="modal-close" onclick="closeModal('docUpdateModal')"><i class="fi fi-rr-cross"></i></button>
            </div>
            <form action="${pageContext.request.contextPath}/compliance/review" method="post">
                <input type="hidden" name="docId" id="updateDocId">
                <div class="form-group">
                    <label>New Status</label>
                    <div class="select-wrapper">
                        <select name="status" id="updateDocStatus" class="form-select form-select-custom no-custom-select" style="width:100%;" required>
                            <option value="Under Review">Under Review</option>
                            <option value="Approved">Approved</option>
                            <option value="Rejected">Rejected</option>
                        </select>
                    </div>
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn-modal-cancel" onclick="closeModal('docUpdateModal')">Cancel</button>
                    <button type="submit" class="btn-modal-submit">Update Status</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Delete Document Confirm Modal -->
    <div class="modal-overlay" id="docDeleteModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Delete Document</h3>
                <button class="modal-close" onclick="closeModal('docDeleteModal')"><i class="fi fi-rr-cross"></i></button>
            </div>
            <p style="color:var(--text-sub); font-size:13.5px; margin:0 0 16px; line-height:1.5;">This will permanently delete this compliance document record. This action cannot be undone.</p>
            <form action="${pageContext.request.contextPath}/compliance/delete" method="post">
                <input type="hidden" name="docId" id="deleteDocId">
                <div class="modal-actions">
                    <button type="button" class="btn-modal-cancel" onclick="closeModal('docDeleteModal')">Cancel</button>
                    <button type="submit" class="btn-modal-danger"><i class="fi fi-rr-trash"></i> Delete</button>
                </div>
            </form>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.9/dist/chart.umd.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/nl-chart-theme.js"></script>

<script>
    // State management for filtering, sorting, pagination
    let allDocRows = [];
    let matchingDocRows = [];
    let currentDocPage = 1;
    const docPageSize = 10;
    let currentStatusFilter = 'ALL';
    let docSortDirections = {};

    document.addEventListener('DOMContentLoaded', function() {
        const tbody = document.getElementById('docsTableBody');
        if (tbody) {
            allDocRows = Array.from(tbody.querySelectorAll('tr.doc-row'));
            matchingDocRows = [...allDocRows];
            renderDocPagination();
        }
    });

    function filterByDocStatus(status, tabBtn) {
        currentStatusFilter = status;
        document.querySelectorAll('.tab-pill-btn').forEach(btn => btn.classList.remove('active'));
        if (tabBtn) tabBtn.classList.add('active');
        handleDocFilter();
    }

    function handleDocFilter() {
        const query = (document.getElementById('docSearchInput')?.value || '').trim().toLowerCase();
        const typeFilter = (document.getElementById('docTypeFilter')?.value || '').trim();
        const clearBtn = document.getElementById('docSearchClear');
        if (clearBtn) clearBtn.style.display = query.length > 0 ? 'block' : 'none';

        matchingDocRows = allDocRows.filter(row => {
            const rowStatus = (row.dataset.status || '').trim();
            const rowType = (row.dataset.type || '').trim();
            const searchData = (row.dataset.search || '').toLowerCase();

            // Status filter
            if (currentStatusFilter !== 'ALL' && rowStatus !== currentStatusFilter) {
                return false;
            }
            // Type filter
            if (typeFilter && rowType !== typeFilter) {
                return false;
            }
            // Search text filter
            if (query && !searchData.includes(query)) {
                return false;
            }
            return true;
        });

        // Update counter badge
        const countVal = document.getElementById('docCountValue');
        if (countVal) countVal.textContent = matchingDocRows.length;

        currentDocPage = 1;
        renderDocPagination();
    }

    function clearDocSearch() {
        const input = document.getElementById('docSearchInput');
        if (input) {
            input.value = '';
            handleDocFilter();
        }
    }

    function renderDocPagination() {
        const totalRows = matchingDocRows.length;
        const totalPages = Math.ceil(totalRows / docPageSize) || 1;
        if (currentDocPage > totalPages) currentDocPage = totalPages;
        if (currentDocPage < 1) currentDocPage = 1;

        const start = (currentDocPage - 1) * docPageSize;
        const end = Math.min(start + docPageSize, totalRows);

        // Hide all rows first
        allDocRows.forEach(row => row.style.display = 'none');

        // Show matching rows for current page
        matchingDocRows.slice(start, end).forEach(row => row.style.display = '');

        // Update counters
        const startEl = document.getElementById('docPageStart');
        const endEl = document.getElementById('docPageEnd');
        const totalEl = document.getElementById('docTotalRows');
        if (startEl) startEl.textContent = totalRows === 0 ? 0 : start + 1;
        if (endEl) endEl.textContent = end;
        if (totalEl) totalEl.textContent = totalRows;

        // Render circular pagination numbers
        renderDocPaginationControls(totalPages);
    }

    function renderDocPaginationControls(totalPages) {
        const nav = document.getElementById('docsPageNav');
        if (!nav) return;
        nav.innerHTML = '';

        if (totalPages <= 1) return;

        // Prev Button
        const prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'nl-page-btn nl-page-nav-btn' + (currentDocPage === 1 ? ' disabled' : '');
        prevBtn.innerHTML = '<i class="ti ti-chevron-left"></i> Prev';
        prevBtn.onclick = () => {
            if (currentDocPage > 1) {
                currentDocPage--;
                renderDocPagination();
            }
        };
        nav.appendChild(prevBtn);

        // Circular Page Numbers with Ellipsis
        function appendDocPageBtn(p) {
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'nl-page-btn nl-page-num' + (p === currentDocPage ? ' active' : '');
            btn.textContent = p;
            btn.onclick = () => {
                currentDocPage = p;
                renderDocPagination();
            };
            nav.appendChild(btn);
        }

        function appendDocEllipsis() {
            const span = document.createElement('span');
            span.className = 'nl-page-ellipsis';
            span.textContent = '…';
            nav.appendChild(span);
        }

        if (totalPages <= 7) {
            for (let i = 1; i <= totalPages; i++) {
                appendDocPageBtn(i);
            }
        } else {
            appendDocPageBtn(1);
            if (currentDocPage > 3) appendDocEllipsis();

            const startP = Math.max(2, currentDocPage - 1);
            const endP = Math.min(totalPages - 1, currentDocPage + 1);

            for (let i = startP; i <= endP; i++) {
                appendDocPageBtn(i);
            }

            if (currentDocPage < totalPages - 2) appendDocEllipsis();
            appendDocPageBtn(totalPages);
        }

        // Next Button
        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'nl-page-btn nl-page-nav-btn' + (currentDocPage === totalPages ? ' disabled' : '');
        nextBtn.innerHTML = 'Next <i class="ti ti-chevron-right"></i>';
        nextBtn.onclick = () => {
            if (currentDocPage < totalPages) {
                currentDocPage++;
                renderDocPagination();
            }
        };
        nav.appendChild(nextBtn);
    }

    // Interactive Column Sorting
    function sortDocsTable(colKey) {
        const currentDir = docSortDirections[colKey] || 'none';
        const newDir = currentDir === 'asc' ? 'desc' : 'asc';
        docSortDirections[colKey] = newDir;

        // Reset all sort icons
        document.querySelectorAll('#docsTable thead th').forEach(th => {
            th.classList.remove('sort-active');
            const ico = th.querySelector('.sort-indicator');
            if (ico) {
                ico.className = 'ti ti-arrows-sort sort-indicator ms-1';
            }
        });

        // Set active header & icon
        const activeIcon = document.getElementById('sort-icon-' + colKey);
        if (activeIcon) {
            const parentTh = activeIcon.closest('th');
            if (parentTh) parentTh.classList.add('sort-active');
            activeIcon.className = (newDir === 'asc' ? 'ti ti-sort-ascending' : 'ti ti-sort-descending') + ' sort-indicator ms-1';
        }

        matchingDocRows.sort((a, b) => {
            let valA = a.dataset[colKey] || '';
            let valB = b.dataset[colKey] || '';

            if (colKey === 'id' || colKey === 'shipment' || colKey === 'user') {
                const numA = parseInt(valA.replace(/\D/g, '')) || 0;
                const numB = parseInt(valB.replace(/\D/g, '')) || 0;
                return newDir === 'asc' ? numA - numB : numB - numA;
            } else if (colKey === 'date' || colKey === 'expiry') {
                const dateA = new Date(valA).getTime() || 0;
                const dateB = new Date(valB).getTime() || 0;
                return newDir === 'asc' ? dateA - dateB : dateB - dateA;
            } else {
                return newDir === 'asc' ? valA.localeCompare(valB) : valB.localeCompare(valA);
            }
        });

        const tbody = document.getElementById('docsTableBody');
        matchingDocRows.forEach(row => tbody.appendChild(row));

        currentDocPage = 1;
        renderDocPagination();
    }

    function toggleDropdown(btn) {
        document.querySelectorAll('.dropdown-menu-custom').forEach(menu => {
            if (menu !== btn.nextElementSibling) menu.classList.remove('show');
        });
        btn.nextElementSibling.classList.toggle('show');
    }

    document.addEventListener('click', function(e) {
        if (!e.target.closest('.dropdown-container')) {
            document.querySelectorAll('.dropdown-menu-custom').forEach(menu => menu.classList.remove('show'));
        }
    });

    function openModal(id) {
        const modal = document.getElementById(id);
        if (modal) modal.classList.add('active');
    }

    function closeModal(id) {
        const modal = document.getElementById(id);
        if (modal) modal.classList.remove('active');
    }

    window.addEventListener('click', function(e) {
        if (e.target.classList.contains('modal-overlay')) {
            e.target.classList.remove('active');
        }
    });
</script>

<%-- Export + Fullscreen controls on every card --%>
<script src="${pageContext.request.contextPath}/assets/js/nl-card-tools.js"></script>
<jsp:include page="/jsp/layout/footer.jsp" />
