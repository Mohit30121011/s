<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-regular-rounded/css/uicons-regular-rounded.css'>
<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-solid-rounded/css/uicons-solid-rounded.css'>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/dist/tabler-icons.min.css">
<link href="https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/css/tom-select.bootstrap5.min.css" rel="stylesheet">

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

    /* Frameless Telemetry Hero Header */
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

    /* KPI Cards Grid */
    .kpi-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        gap: 18px;
        margin-bottom: 24px;
    }
    .kpi-card {
        background: var(--bg-surface);
        border: 1px solid var(--border-color);
        border-radius: 16px;
        padding: 20px 22px;
        display: flex;
        align-items: center;
        gap: 16px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04);
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    .kpi-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(15, 23, 42, 0.08);
    }
    .kpi-icon {
        width: 48px;
        height: 48px;
        border-radius: 50% !important;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 22px;
        flex-shrink: 0;
    }
    .kpi-icon.icon-inv { background: rgba(147, 51, 234, 0.12); color: #9333EA; }
    .kpi-icon.icon-amount { background: rgba(59, 130, 246, 0.12); color: #3B82F6; }
    .kpi-icon.icon-approved { background: rgba(16, 185, 129, 0.12); color: #10B981; }
    .kpi-icon.icon-rejected { background: rgba(239, 68, 68, 0.12); color: #EF4444; }

    .kpi-data { flex: 1; }
    .kpi-title {
        color: var(--text-sub);
        font-size: 11.5px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.6px;
        margin-bottom: 4px;
    }
    .kpi-val {
        color: var(--text-main);
        font-size: 22px;
        font-weight: 800;
        line-height: 1.2;
        letter-spacing: -0.02em;
    }
    .kpi-sub {
        color: var(--text-sub);
        font-size: 12px;
        margin-top: 4px;
    }

    /* Filter & Search Toolbar */
    .filter-toolbar-card {
        background: #FFFFFF;
        border: 1px solid var(--border-color);
        border-radius: 50px !important;
        padding: 8px 16px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03);
        margin-bottom: 22px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 12px;
    }
    .search-wrap {
        position: relative;
        flex: 1;
        min-width: 240px;
        max-width: 380px;
    }
    .search-wrap i {
        position: absolute;
        left: 16px;
        top: 50%;
        transform: translateY(-50%);
        color: #94A3B8;
        font-size: 15px;
        pointer-events: none;
    }
    .search-input {
        width: 100%;
        padding: 9px 36px 9px 40px;
        border: 1.5px solid var(--border-color);
        border-radius: 50px !important;
        font-size: 13.5px;
        outline: none;
        background: #F8FAFC;
        color: #0F172A;
        transition: all 0.2s ease;
    }
    .search-input:focus {
        background: #FFFFFF;
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .search-clear {
        position: absolute;
        right: 14px;
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

    .status-filter-tabs {
        display: flex;
        align-items: center;
        background: #F1F5F9;
        padding: 4px;
        border-radius: 50px !important;
        gap: 3px;
    }
    .status-tab-btn {
        background: none;
        border: none;
        padding: 6px 14px;
        border-radius: 50px !important;
        font-size: 12.5px;
        font-weight: 600;
        color: #64748B;
        cursor: pointer;
        transition: all 0.15s ease;
    }
    .status-tab-btn:hover {
        color: #0F172A;
    }
    .status-tab-btn.active {
        background: #FFFFFF;
        color: #FC8019;
        box-shadow: 0 2px 6px rgba(15, 23, 42, 0.08);
    }

    /* Enterprise Table Architecture */
    .card.tracking-card {
        background: var(--bg-surface);
        border: 1px solid var(--border-color);
        border-radius: 16px;
        overflow: hidden;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03);
    }
    .table-responsive {
        width: 100%;
        overflow-x: auto;
    }
    table.enterprise-table {
        width: 100%;
        border-collapse: collapse;
        margin: 0;
    }
    table.enterprise-table th {
        background: #F8FAFC;
        padding: 13px 18px;
        text-align: left;
        font-size: 11.5px;
        font-weight: 700;
        color: #64748B;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border-bottom: 1px solid var(--border-color);
        border-top: none;
        white-space: nowrap;
        user-select: none;
    }
    table.enterprise-table th.sortable {
        cursor: pointer;
        transition: color 0.15s ease, background 0.15s ease;
    }
    table.enterprise-table th.sortable:hover {
        color: #FC8019;
        background: rgba(252, 128, 25, 0.04);
    }
    table.enterprise-table th.sort-active {
        color: #FC8019;
    }
    table.enterprise-table th .sort-indicator {
        margin-left: 4px;
        font-size: 13px;
        opacity: 0.5;
        vertical-align: middle;
    }
    table.enterprise-table th.sortable:hover .sort-indicator,
    table.enterprise-table th.sort-active .sort-indicator {
        opacity: 1;
        color: #FC8019;
    }
    table.enterprise-table td {
        padding: 14px 18px;
        border-bottom: 1px solid #F1F5F9;
        font-size: 13px;
        color: #334155;
        vertical-align: middle;
    }
    table.enterprise-table tr:hover td {
        background-color: #F8FAFC;
    }
    table.enterprise-table tr:last-child td {
        border-bottom: none;
    }

    /* 50px Pill Status Badges */
    .status-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 5px 12px;
        border-radius: 50px !important;
        font-size: 11.5px;
        font-weight: 700;
        letter-spacing: 0.3px;
        text-transform: uppercase;
    }
    .status-paid {
        background: #ECFDF5;
        color: #059669;
        border: 1px solid #A7F3D0;
    }
    .status-unpaid {
        background: #FEF2F2;
        color: #DC2626;
        border: 1px solid #FECACA;
    }
    .status-partial {
        background: #FFFBEB;
        color: #D97706;
        border: 1px solid #FDE68A;
    }
    .status-overdue {
        background: #FEF2F2;
        color: #B91C1C;
        border: 1px solid #FECACA;
    }

    /* 50% Circular Action Buttons */
    .action-cell {
        display: flex;
        gap: 8px;
        align-items: center;
    }
    .btn-icon {
        width: 34px;
        height: 34px;
        border-radius: 50% !important;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: 1px solid var(--border-color);
        background: white;
        color: var(--text-sub);
        cursor: pointer;
        transition: all 0.15s ease;
        text-decoration: none;
    }
    .btn-icon:hover {
        background: #F1F5F9;
        color: var(--text-main);
        border-color: #CBD5E1;
    }
    .btn-view {
        color: var(--info);
        border-color: var(--info-light);
        background: var(--info-light);
    }
    .btn-view:hover {
        background: #DBEAFE;
        color: #1D4ED8;
    }
    .btn-edit {
        color: #FC8019;
        border-color: #FFE0D1;
        background: #FFF2EB;
    }
    .btn-edit:hover {
        background: #FFE0D1;
        color: #E66F0F;
    }

    .dropdown-container {
        position: relative;
    }
    .dropdown-menu-custom {
        position: absolute;
        right: 0;
        top: 100%;
        margin-top: 6px;
        background: white;
        border: 1px solid var(--border-color);
        border-radius: 12px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        min-width: 170px;
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
        padding: 8px 14px;
        color: var(--text-main);
        text-decoration: none;
        font-size: 13px;
        border-radius: 50px !important;
        transition: all 0.15s ease;
    }
    .dropdown-item:hover {
        background: #F1F5F9;
        color: #FC8019;
    }

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

    /* Modal Styles */
    .modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(15, 23, 42, 0.5);
        backdrop-filter: blur(4px);
        -webkit-backdrop-filter: blur(4px);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 99999;
        opacity: 0;
        pointer-events: none;
        transition: opacity 0.2s;
        padding: 20px;
    }
    .modal-overlay.active {
        opacity: 1;
        pointer-events: auto;
    }
    .modal-content {
        background: white;
        border-radius: 20px !important;
        width: 100%;
        max-width: 520px;
        padding: 26px 28px;
        box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.25);
        border: 1px solid #E2E8F0;
        transform: translateY(20px);
        transition: transform 0.2s;
    }
    .modal-overlay.active .modal-content {
        transform: translateY(0);
    }
    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        padding-bottom: 14px;
        border-bottom: 1px solid #F1F5F9;
    }
    .modal-header h3 {
        margin: 0;
        font-size: 18px;
        font-weight: 700;
        color: var(--text-main);
    }
    .modal-close {
        background: none;
        border: none;
        font-size: 18px;
        color: var(--text-sub);
        cursor: pointer;
        width: 32px;
        height: 32px;
        border-radius: 50% !important;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.15s ease;
    }
    .modal-close:hover {
        background: #F1F5F9;
        color: #0F172A;
    }
    .form-group {
        margin-bottom: 18px;
    }
    .form-group label {
        display: block;
        margin-bottom: 6px;
        font-size: 13px;
        font-weight: 600;
        color: var(--text-main);
    }
    .form-control {
        width: 100%;
        padding: 10px 16px;
        border: 1.5px solid var(--border-color);
        border-radius: 50px !important;
        font-size: 13.5px;
        color: var(--text-main);
        background: white;
        box-sizing: border-box;
        outline: none;
        transition: all 0.2s ease;
    }
    .form-control:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .modal-actions {
        display: flex;
        justify-content: flex-end;
        gap: 12px;
        margin-top: 24px;
    }
    .btn-custom {
        padding: 10px 24px;
        border-radius: 50px !important;
        font-size: 13.5px;
        font-weight: 600;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        transition: all 0.2s ease;
        border: none;
    }
    .btn-primary-custom {
        background-color: var(--primary);
        color: white;
        box-shadow: 0 4px 14px rgba(252, 128, 25, 0.28);
    }
    .btn-primary-custom:hover {
        background-color: #E66F0F;
        transform: translateY(-1px);
    }
    .btn-outline {
        background-color: #F1F5F9;
        border: 1px solid var(--border-color);
        color: var(--text-main);
    }
    .btn-outline:hover {
        background-color: #E2E8F0;
    }

    .qr-box {
        background: var(--primary-light);
        border: 1px dashed var(--primary);
        border-radius: 14px;
        padding: 16px;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 8px;
        margin-bottom: 16px;
    }
    .qr-pattern {
        width: 140px;
        height: 140px;
        background-color: #fff;
        border-radius: 8px;
        padding: 4px;
    }

    /* Override unwanted card tools */
    .no-card-tools .nl-card-tools {
        display: none !important;
    }

    /* ==========================================================================
       DARK THEME STYLES [data-theme="dark"] FOR BILLING WORKSPACE
       ========================================================================== */
    [data-theme="dark"] body {
        background-color: #080E14 !important;
    }
    [data-theme="dark"] .dashboard-container {
        background: transparent !important;
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

    [data-theme="dark"] .kpi-card {
        background: #101820 !important;
        border-color: #22303A !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .kpi-card:hover {
        border-color: #2D3F4D !important;
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
    [data-theme="dark"] .kpi-icon.icon-inv { background: rgba(147, 51, 234, 0.18) !important; color: #C084FC !important; }
    [data-theme="dark"] .kpi-icon.icon-amount { background: rgba(59, 130, 246, 0.18) !important; color: #60A5FA !important; }
    [data-theme="dark"] .kpi-icon.icon-approved { background: rgba(16, 185, 129, 0.18) !important; color: #34D399 !important; }
    [data-theme="dark"] .kpi-icon.icon-rejected { background: rgba(239, 68, 68, 0.18) !important; color: #F87171 !important; }

    [data-theme="dark"] .filter-toolbar-card {
        background: #101820 !important;
        border-color: #22303A !important;
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
    [data-theme="dark"] .status-filter-tabs {
        background: #151F28 !important;
        border: 1px solid #2D3F4D !important;
    }
    [data-theme="dark"] .status-tab-btn {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .status-tab-btn:hover {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .status-tab-btn.active {
        background: #22303A !important;
        color: #FC8019 !important;
    }

    [data-theme="dark"] .card.tracking-card {
        background: #101820 !important;
        border-color: #22303A !important;
        box-shadow: 0 8px 30px rgba(0, 0, 0, 0.45) !important;
    }
    [data-theme="dark"] table.enterprise-table th {
        background-color: #0B1520 !important;
        color: #94A3B8 !important;
        border-bottom: 1px solid #22303A !important;
    }
    [data-theme="dark"] table.enterprise-table th.sortable:hover {
        color: #FC8019 !important;
        background-color: rgba(252, 128, 25, 0.1) !important;
    }
    [data-theme="dark"] table.enterprise-table th.sort-active {
        color: #FC8019 !important;
    }
    [data-theme="dark"] table.enterprise-table td {
        background-color: transparent !important;
        color: #F8FAFC !important;
        border-bottom: 1px solid #22303A !important;
    }
    [data-theme="dark"] table.enterprise-table tr:hover td {
        background-color: rgba(255, 255, 255, 0.03) !important;
    }

    /* Translucent dark status badges */
    [data-theme="dark"] .status-paid {
        background: rgba(16, 185, 129, 0.16) !important;
        color: #34D399 !important;
        border: 1px solid rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .status-unpaid {
        background: rgba(239, 68, 68, 0.16) !important;
        color: #F87171 !important;
        border: 1px solid rgba(239, 68, 68, 0.3) !important;
    }
    [data-theme="dark"] .status-partial {
        background: rgba(245, 158, 11, 0.16) !important;
        color: #FBBF24 !important;
        border: 1px solid rgba(245, 158, 11, 0.3) !important;
    }
    [data-theme="dark"] .status-overdue {
        background: rgba(239, 68, 68, 0.16) !important;
        color: #F87171 !important;
        border: 1px solid rgba(239, 68, 68, 0.3) !important;
    }

    /* Dark Action Buttons */
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
        background: rgba(252, 128, 25, 0.16) !important;
        border-color: #FC8019 !important;
        color: #FC8019 !important;
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
        color: #FC8019 !important;
    }

    /* Dark Pagination */
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

    /* Dark Modals */
    [data-theme="dark"] .modal-content {
        background: #101820 !important;
        border: 1px solid #22303A !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .modal-header {
        border-bottom-color: #22303A !important;
    }
    [data-theme="dark"] .modal-header h3 {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .modal-close {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .modal-close:hover {
        background: #1E293B !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .form-group label {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .form-control {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .form-control:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.22) !important;
    }
    [data-theme="dark"] .btn-outline {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .btn-outline:hover {
        background: #1E293B !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .qr-box {
        background: rgba(252, 128, 25, 0.1) !important;
        border-color: rgba(252, 128, 25, 0.4) !important;
    }
</style>

<div class="dashboard-container">
    <!-- Frameless Telemetry Hero Header -->
    <div class="telemetry-header-card">
        <div class="telemetry-header-left">
            <div class="telemetry-icon-box">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#FC8019" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="2" y="5" width="20" height="14" rx="2"></rect>
                    <line x1="2" y1="10" x2="22" y2="10"></line>
                </svg>
            </div>
            <div>
                <h1 class="telemetry-title">Billing &amp; Invoices Overview</h1>
                <p class="telemetry-desc">Commercial invoicing, customer accounts receivable, and payment realization ledger</p>
            </div>
        </div>
        <div class="telemetry-actions">
            <button class="btn-register-primary" onclick="openModal('invoiceModal')">
                <i class="ti ti-plus"></i> Generate New Invoice
            </button>
        </div>
    </div>
    
    <!-- Executive KPI Grid -->
    <div class="kpi-grid">
        <div class="kpi-card">
            <div class="kpi-icon icon-inv"><i class="ti ti-file-invoice"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Total Invoices</div>
                <div class="kpi-val">${invTotal}</div>
                <div class="kpi-sub">All Time Statements</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-amount"><i class="ti ti-receipt-tax"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Total Amount</div>
                <div class="kpi-val">&#8377;<fmt:formatNumber value="${invTotalAmount}" groupingUsed="true" maxFractionDigits="0"/></div>
                <div class="kpi-sub">Issued volume</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-approved"><i class="ti ti-circle-check"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Paid Amount</div>
                <div class="kpi-val" style="color: #059669;">&#8377;<fmt:formatNumber value="${invPaidAmount}" groupingUsed="true" maxFractionDigits="0"/></div>
                <div class="kpi-sub"><fmt:formatNumber value="${invTotalAmount > 0 ? (invPaidAmount/invTotalAmount)*100 : 0}" maxFractionDigits="0"/>% collected</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-rejected"><i class="ti ti-clock-hour-4"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Outstanding Amount</div>
                <div class="kpi-val" style="color: #DC2626;">&#8377;<fmt:formatNumber value="${invTotalAmount - invPaidAmount}" groupingUsed="true" maxFractionDigits="0"/></div>
                <div class="kpi-sub"><fmt:formatNumber value="${invTotalAmount > 0 ? ((invTotalAmount - invPaidAmount)/invTotalAmount)*100 : 0}" maxFractionDigits="0"/>% pending</div>
            </div>
        </div>
    </div>

    <!-- Filter & Search Toolbar -->
    <div class="filter-toolbar-card">
        <div class="search-wrap">
            <i class="ti ti-search"></i>
            <input type="text" id="billingSearchInput" class="search-input" placeholder="Search by invoice #, customer, shipment..." onkeyup="applyBillingFilters()">
            <button type="button" class="search-clear" id="billingSearchClearBtn" onclick="clearBillingSearch()">
                <i class="ti ti-x"></i>
            </button>
        </div>

        <div class="status-filter-tabs" id="billingStatusTabs">
            <button type="button" class="status-tab-btn active" data-status="ALL" onclick="setBillingStatusFilter('ALL', this)">All</button>
            <button type="button" class="status-tab-btn" data-status="Paid" onclick="setBillingStatusFilter('Paid', this)">Paid</button>
            <button type="button" class="status-tab-btn" data-status="Partial" onclick="setBillingStatusFilter('Partial', this)">Partial</button>
            <button type="button" class="status-tab-btn" data-status="Unpaid" onclick="setBillingStatusFilter('Unpaid', this)">Unpaid</button>
            <button type="button" class="status-tab-btn" data-status="Overdue" onclick="setBillingStatusFilter('Overdue', this)">Overdue</button>
        </div>
    </div>

    <!-- Enterprise Table Container Card -->
    <div class="card tracking-card no-card-tools" data-no-tools="true">
        <div class="table-responsive">
            <table class="enterprise-table tracking-table" id="invoiceTable">
                <thead>
                    <tr>
                        <th class="sortable" onclick="sortBillingTable(0, this)">
                            Invoice No. <i class="ti ti-arrows-sort sort-indicator"></i>
                        </th>
                        <th class="sortable" onclick="sortBillingTable(1, this)">
                            Shipment ID <i class="ti ti-arrows-sort sort-indicator"></i>
                        </th>
                        <th class="sortable" onclick="sortBillingTable(2, this)">
                            Customer <i class="ti ti-arrows-sort sort-indicator"></i>
                        </th>
                        <th class="sortable" onclick="sortBillingTable(3, this)">
                            Invoice Date <i class="ti ti-arrows-sort sort-indicator"></i>
                        </th>
                        <th class="sortable" onclick="sortBillingTable(4, this)">
                            Due Date <i class="ti ti-arrows-sort sort-indicator"></i>
                        </th>
                        <th class="sortable" onclick="sortBillingTable(5, this)">
                            Total Amount <i class="ti ti-arrows-sort sort-indicator"></i>
                        </th>
                        <th class="sortable" onclick="sortBillingTable(6, this)">
                            Paid Amount <i class="ti ti-arrows-sort sort-indicator"></i>
                        </th>
                        <th class="sortable" onclick="sortBillingTable(7, this)">
                            Status <i class="ti ti-arrows-sort sort-indicator"></i>
                        </th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody id="billingTableBody">
                    <c:if test="${empty invoices}">
                        <tr id="billingEmptyRow">
                            <td colspan="9" style="text-align: center; padding: 50px 20px; color: var(--text-sub);">
                                <i class="ti ti-file-invoice" style="font-size: 36px; display: block; margin-bottom: 12px; color: #CBD5E1;"></i>
                                <span style="font-weight: 600; font-size: 15px; color: #0F172A;">No Invoices Found</span><br>
                                <span style="font-size: 13px;">There are no billing records registered in the system.</span>
                            </td>
                        </tr>
                    </c:if>
                    <c:forEach var="inv" items="${invoices}">
                        <c:set var="custName" value="" />
                        <c:forEach var="c" items="${customers}">
                            <c:if test="${c.customerId == inv.customerId}"><c:set var="custName" value="${c.customerName}" /></c:if>
                        </c:forEach>
                        <tr class="billing-row"
                            data-inv="INV-${inv.invoiceId}"
                            data-ship="${inv.shipmentId}"
                            data-customer="${custName}"
                            data-date="<fmt:formatDate value='${inv.invoiceDate}' pattern='yyyy-MM-dd' />"
                            data-due="<fmt:formatDate value='${inv.dueDate}' pattern='yyyy-MM-dd' />"
                            data-total="${inv.totalAmount}"
                            data-paid="${inv.paidAmount}"
                            data-status="${inv.paymentStatus}">
                            <td><strong>INV-${inv.invoiceId}</strong></td>
                            <td><span class="badge" style="background: rgba(37, 99, 235, 0.1); color: #2563EB; border-radius: 50px !important; padding: 4px 10px; font-weight: 600;">SHP-${inv.shipmentId}</span></td>
                            <td>${empty custName ? 'Customer #' += inv.customerId : custName}</td>
                            <td><fmt:formatDate value="${inv.invoiceDate}" pattern="dd MMM yyyy" /></td>
                            <td><fmt:formatDate value="${inv.dueDate}" pattern="dd MMM yyyy" /></td>
                            <td>&#8377;<fmt:formatNumber value="${inv.totalAmount}" groupingUsed="true" maxFractionDigits="2" minFractionDigits="2"/></td>
                            <td>&#8377;<fmt:formatNumber value="${inv.paidAmount}" groupingUsed="true" maxFractionDigits="2" minFractionDigits="2"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${inv.paymentStatus == 'Paid'}"><span class="status-badge status-paid">Paid</span></c:when>
                                    <c:when test="${inv.paymentStatus == 'Partial'}"><span class="status-badge status-partial">Partial</span></c:when>
                                    <c:when test="${inv.paymentStatus == 'Overdue'}"><span class="status-badge status-overdue">Overdue</span></c:when>
                                    <c:otherwise><span class="status-badge status-unpaid">Unpaid</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="action-cell justify-content-end">
                                    <button type="button" class="btn-icon btn-view" title="View Invoice" onclick="window.open('${pageContext.request.contextPath}/invoices?id=${inv.invoiceId}&action=view', '_blank')"><i class="ti ti-eye"></i></button>
                                    <button type="button" class="btn-icon btn-edit" title="Record Payment" onclick="document.getElementById('payInvoiceId').value='${inv.invoiceId}'; openModal('paymentModal');"><i class="ti ti-cash"></i></button>
                                    <div class="dropdown-container">
                                        <button type="button" class="btn-icon action-dropdown" onclick="toggleDropdown(this)"><i class="ti ti-dots-vertical"></i></button>
                                        <div class="dropdown-menu-custom">
                                            <a href="${pageContext.request.contextPath}/invoices?id=${inv.invoiceId}&action=print" target="_blank" class="dropdown-item"><i class="ti ti-printer"></i> Print Statement</a>
                                        </div>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <!-- Global Enterprise Circular Pagination Bar -->
        <div class="nl-pagination-wrapper" id="billingPaginationWrapper">
            <div class="nl-pagination-info" id="billingPaginationInfo">
                Showing <strong>0</strong> to <strong>0</strong> of <strong>${invoices.size()}</strong> invoices
            </div>
            <div class="nl-pagination-nav" id="billingPaginationNav">
                <!-- Dynamic Circular Page Buttons -->
            </div>
        </div>
    </div>

    <!-- Generate Invoice Modal -->
    <div class="modal-overlay" id="invoiceModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Generate New Invoice</h3>
                <button type="button" class="modal-close" onclick="closeModal('invoiceModal')"><i class="ti ti-x"></i></button>
            </div>
            <form action="${pageContext.request.contextPath}/billing/generate" method="post">
                <div class="form-group">
                    <label>Customer <span class="text-danger">*</span></label>
                    <select name="customerId" class="form-control form-select-custom" required>
                        <option value="">Select Customer...</option>
                        <c:forEach var="c" items="${customers}">
                            <option value="${c.customerId}">${c.customerName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label>Shipment <span class="text-danger">*</span></label>
                    <select name="shipmentId" class="form-control form-select-custom" required>
                        <option value="">Select Shipment...</option>
                        <c:forEach var="s" items="${shipments}">
                            <option value="${s.shipmentId}">SHP-${s.shipmentId}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn-custom btn-outline" onclick="closeModal('invoiceModal')">Cancel</button>
                    <button type="submit" class="btn-custom btn-primary-custom">Generate Invoice</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Record Payment Modal -->
    <div class="modal-overlay" id="paymentModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Record Payment Settlement</h3>
                <button type="button" class="modal-close" onclick="closeModal('paymentModal')"><i class="ti ti-x"></i></button>
            </div>
            <form action="${pageContext.request.contextPath}/billing/pay" method="post" id="paymentForm" onsubmit="return preparePaymentSubmit();">
                <input type="hidden" name="invoiceId" id="payInvoiceId">
                <input type="hidden" name="transactionRef" id="transactionRefHidden">
                <div class="form-group">
                    <label>Amount Paid (&#8377;) <span class="text-danger">*</span></label>
                    <input type="number" step="0.01" name="amountPaid" class="form-control" required placeholder="0.00">
                </div>
                <div class="form-group">
                    <label>Payment Mode <span class="text-danger">*</span></label>
                    <select name="paymentMode" id="paymentModeSelect" class="form-control" required onchange="onPaymentModeChange()">
                        <option value="UPI">UPI (Instant QR / VPA)</option>
                        <option value="Card">Card</option>
                        <option value="Cheque">Cheque</option>
                        <option value="Bank Transfer">Bank Transfer / Netbanking</option>
                    </select>
                </div>

                <!-- UPI: instant QR code -->
                <div class="payment-mode-fields" id="fields-UPI">
                    <div class="qr-box" id="upiQrBox">
                        <div class="qr-pattern" id="upiQrPattern"></div>
                        <div style="font-size: 11.5px; font-weight: 600; color: #FC8019;">Scan to pay via any UPI app</div>
                    </div>
                    <div class="form-group">
                        <label>UPI Reference / VPA</label>
                        <input type="text" id="upiRef" class="form-control" placeholder="e.g. 9876543210@upi">
                    </div>
                </div>

                <!-- Card -->
                <div class="payment-mode-fields" id="fields-Card" style="display:none;">
                    <div class="form-group">
                        <label>Card Holder Name</label>
                        <input type="text" id="cardHolder" class="form-control" placeholder="e.g. R. Sharma">
                    </div>
                    <div style="display:flex; gap:16px;">
                        <div class="form-group" style="flex:1;">
                            <label>Card Number (last 4 digits)</label>
                            <input type="text" id="cardLast4" maxlength="4" pattern="[0-9]{4}" class="form-control" placeholder="1234">
                        </div>
                        <div class="form-group" style="flex:1;">
                            <label>Card Network</label>
                            <select id="cardNetwork" class="form-control">
                                <option value="Visa">Visa</option>
                                <option value="Mastercard">Mastercard</option>
                                <option value="RuPay">RuPay</option>
                                <option value="Amex">Amex</option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- Cheque -->
                <div class="payment-mode-fields" id="fields-Cheque" style="display:none;">
                    <div class="form-group">
                        <label>Cheque Number</label>
                        <input type="text" id="chequeNumber" class="form-control" placeholder="e.g. 004521">
                    </div>
                    <div class="form-group">
                        <label>Bearer Name</label>
                        <input type="text" id="bearerName" class="form-control" placeholder="e.g. Company Bank Pvt Ltd">
                    </div>
                </div>

                <!-- Netbanking -->
                <div class="payment-mode-fields" id="fields-Netbanking" style="display:none;">
                    <div class="form-group">
                        <label>Bank</label>
                        <select id="netbankBank" class="form-control">
                            <option value="HDFC Bank">HDFC Bank</option>
                            <option value="ICICI Bank">ICICI Bank</option>
                            <option value="State Bank of India">State Bank of India</option>
                            <option value="Axis Bank">Axis Bank</option>
                            <option value="Kotak Mahindra Bank">Kotak Mahindra Bank</option>
                        </select>
                    </div>
                </div>

                <!-- Bank Transfer / Cash: plain reference -->
                <div class="payment-mode-fields" id="fields-Other" style="display:none;">
                    <div class="form-group">
                        <label>Transaction Reference</label>
                        <input type="text" id="plainTxnRef" class="form-control" placeholder="e.g. TXN-12345">
                    </div>
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn-custom btn-outline" onclick="closeModal('paymentModal')">Cancel</button>
                    <button type="submit" class="btn-custom btn-primary-custom">Record Payment</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/js/tom-select.complete.min.js"></script>
<script>
    let billingStatusFilter = 'ALL';
    let billingCurrentPage = 1;
    const billingPageSize = 10;
    let billingSortCol = -1;
    let billingSortAsc = true;
    let lastMatchingBillingRows = [];

    window.setBillingStatusFilter = function(status, btn) {
        billingStatusFilter = status;
        document.querySelectorAll('#billingStatusTabs .status-tab-btn').forEach(b => b.classList.remove('active'));
        if (btn) btn.classList.add('active');
        billingCurrentPage = 1;
        applyBillingFilters();
    };

    window.sortBillingTable = function(colIndex, th) {
        if (billingSortCol === colIndex) {
            billingSortAsc = !billingSortAsc;
        } else {
            billingSortCol = colIndex;
            billingSortAsc = true;
        }

        document.querySelectorAll('#invoiceTable thead th.sortable').forEach(header => {
            header.classList.remove('sort-active');
            const icon = header.querySelector('.sort-indicator');
            if (icon) icon.className = 'ti ti-arrows-sort sort-indicator';
        });

        if (th) {
            th.classList.add('sort-active');
            const icon = th.querySelector('.sort-indicator');
            if (icon) {
                icon.className = (billingSortAsc ? 'ti ti-sort-ascending' : 'ti ti-sort-descending') + ' sort-indicator';
            }
        }

        const tbody = document.getElementById('billingTableBody');
        const rows = Array.from(tbody.querySelectorAll('tr.billing-row'));

        rows.sort((a, b) => {
            let valA, valB;
            switch (colIndex) {
                case 0:
                    valA = parseInt((a.dataset.inv || '').replace(/\D/g, ''), 10) || 0;
                    valB = parseInt((b.dataset.inv || '').replace(/\D/g, ''), 10) || 0;
                    break;
                case 1:
                    valA = parseInt(a.dataset.ship || '0', 10) || 0;
                    valB = parseInt(b.dataset.ship || '0', 10) || 0;
                    break;
                case 2:
                    valA = (a.dataset.customer || '').toLowerCase();
                    valB = (b.dataset.customer || '').toLowerCase();
                    break;
                case 3:
                    valA = a.dataset.date || '';
                    valB = b.dataset.date || '';
                    break;
                case 4:
                    valA = a.dataset.due || '';
                    valB = b.dataset.due || '';
                    break;
                case 5:
                    valA = parseFloat(a.dataset.total || '0') || 0;
                    valB = parseFloat(b.dataset.total || '0') || 0;
                    break;
                case 6:
                    valA = parseFloat(a.dataset.paid || '0') || 0;
                    valB = parseFloat(b.dataset.paid || '0') || 0;
                    break;
                case 7:
                    valA = (a.dataset.status || '').toLowerCase();
                    valB = (b.dataset.status || '').toLowerCase();
                    break;
                default:
                    return 0;
            }

            if (valA < valB) return billingSortAsc ? -1 : 1;
            if (valA > valB) return billingSortAsc ? 1 : -1;
            return 0;
        });

        rows.forEach(r => tbody.appendChild(r));
        applyBillingFilters();
    };

    window.applyBillingFilters = function() {
        const query = (document.getElementById('billingSearchInput').value || '').trim().toLowerCase();
        const clearBtn = document.getElementById('billingSearchClearBtn');
        if (clearBtn) clearBtn.style.display = query.length > 0 ? 'block' : 'none';

        const rows = document.querySelectorAll('#billingTableBody tr.billing-row');
        lastMatchingBillingRows = [];

        rows.forEach(row => {
            const inv = (row.dataset.inv || '').toLowerCase();
            const ship = (row.dataset.ship || '').toLowerCase();
            const cust = (row.dataset.customer || '').toLowerCase();
            const status = row.dataset.status || '';

            const matchesStatus = (billingStatusFilter === 'ALL') || (status.toLowerCase() === billingStatusFilter.toLowerCase());
            const matchesQuery = !query || inv.includes(query) || ship.includes(query) || cust.includes(query);

            if (matchesStatus && matchesQuery) {
                lastMatchingBillingRows.push(row);
            } else {
                row.style.display = 'none';
            }
        });

        renderBillingPagination();
    };

    window.goToBillingPage = function(page) {
        billingCurrentPage = page;
        renderBillingPagination();
    };

    window.renderBillingPagination = function() {
        const totalRows = lastMatchingBillingRows.length;
        const totalPages = Math.ceil(totalRows / billingPageSize) || 1;
        if (billingCurrentPage > totalPages) billingCurrentPage = totalPages;
        if (billingCurrentPage < 1) billingCurrentPage = 1;

        const startIdx = (billingCurrentPage - 1) * billingPageSize;
        const endIdx = startIdx + billingPageSize;

        lastMatchingBillingRows.forEach((row, idx) => {
            row.style.display = (idx >= startIdx && idx < endIdx) ? '' : 'none';
        });

        const infoEl = document.getElementById('billingPaginationInfo');
        if (infoEl) {
            const startDisplay = totalRows === 0 ? 0 : startIdx + 1;
            const endDisplay = Math.min(totalRows, endIdx);
            infoEl.innerHTML = 'Showing <strong>' + startDisplay + '</strong> to <strong>' + endDisplay + '</strong> of <strong>' + totalRows + '</strong> invoices';
        }

        const navEl = document.getElementById('billingPaginationNav');
        const wrapperEl = document.getElementById('billingPaginationWrapper');
        if (!navEl) return;

        if (totalRows <= billingPageSize) {
            if (wrapperEl) wrapperEl.style.display = totalRows === 0 ? 'none' : 'flex';
        } else {
            if (wrapperEl) wrapperEl.style.display = 'flex';
        }

        let navHtml = '';
        const prevDisabled = billingCurrentPage === 1 ? ' disabled' : '';
        navHtml += '<button type="button" class="nl-page-btn nl-page-nav-btn' + prevDisabled + '" onclick="goToBillingPage(' + (billingCurrentPage - 1) + ')">' +
                   '<i class="ti ti-chevron-left"></i> Prev</button>';

        for (let p = 1; p <= totalPages; p++) {
            if (totalPages > 7) {
                if (p > 2 && p < totalPages - 1 && Math.abs(p - billingCurrentPage) > 1) {
                    if (p === 3 || p === totalPages - 2) {
                        navHtml += '<span class="nl-page-ellipsis">&hellip;</span>';
                    }
                    continue;
                }
            }
            const activeClass = (p === billingCurrentPage) ? ' active' : '';
            navHtml += '<button type="button" class="nl-page-btn nl-page-num' + activeClass + '" onclick="goToBillingPage(' + p + ')">' + p + '</button>';
        }

        const nextDisabled = billingCurrentPage === totalPages ? ' disabled' : '';
        navHtml += '<button type="button" class="nl-page-btn nl-page-nav-btn' + nextDisabled + '" onclick="goToBillingPage(' + (billingCurrentPage + 1) + ')">' +
                   'Next <i class="ti ti-chevron-right"></i></button>';

        navEl.innerHTML = navHtml;
    };

    window.clearBillingSearch = function() {
        const input = document.getElementById('billingSearchInput');
        if (input) input.value = '';
        billingCurrentPage = 1;
        applyBillingFilters();
    };

    function toggleDropdown(btn) {
        document.querySelectorAll('.dropdown-menu-custom').forEach(menu => {
            if (menu !== btn.nextElementSibling) menu.classList.remove('show');
        });
        btn.nextElementSibling.classList.toggle('show');
    }
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.action-dropdown')) {
            document.querySelectorAll('.dropdown-menu-custom').forEach(menu => menu.classList.remove('show'));
        }
    });

    function openModal(id) {
        document.getElementById(id).classList.add('active');
        if (id === 'paymentModal') { onPaymentModeChange(); }
    }
    function closeModal(id) { document.getElementById(id).classList.remove('active'); }

    function onPaymentModeChange() {
        var mode = document.getElementById('paymentModeSelect').value;
        var groups = { 'UPI': 'fields-UPI', 'Card': 'fields-Card', 'Cheque': 'fields-Cheque', 'Bank Transfer': 'fields-Netbanking' };
        ['fields-UPI', 'fields-Card', 'fields-Cheque', 'fields-Netbanking', 'fields-Other'].forEach(function(id) {
            const el = document.getElementById(id);
            if (el) el.style.display = 'none';
        });
        var targetId = groups[mode] || 'fields-Other';
        const targetEl = document.getElementById(targetId);
        if (targetEl) targetEl.style.display = 'block';
        if (mode === 'UPI') {
            generateQrPattern();
        }
    }

    function generateQrPattern() {
        var el = document.getElementById('upiQrPattern');
        if (!el) return;
        var invId = document.getElementById('payInvoiceId').value || '0';
        var seed = parseInt(invId, 10) + Date.now();
        function rand() { seed = (seed * 9301 + 49297) % 233280; return seed / 233280; }
        var size = 10, cell = 14;
        var canvas = document.createElement('canvas');
        canvas.width = size * cell; canvas.height = size * cell;
        var ctx = canvas.getContext('2d');
        ctx.fillStyle = '#fff'; ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.fillStyle = '#111827';
        for (var r = 0; r < size; r++) {
            for (var c = 0; c < size; c++) {
                if (rand() > 0.5) ctx.fillRect(c * cell, r * cell, cell, cell);
            }
        }
        [[0,0],[size-3,0],[0,size-3]].forEach(function(p) {
            ctx.fillStyle = '#111827';
            ctx.fillRect(p[0]*cell, p[1]*cell, cell*3, cell*3);
            ctx.fillStyle = '#fff';
            ctx.fillRect(p[0]*cell+cell*0.5, p[1]*cell+cell*0.5, cell*2, cell*2);
            ctx.fillStyle = '#111827';
            ctx.fillRect(p[0]*cell+cell, p[1]*cell+cell, cell, cell);
        });
        el.innerHTML = '';
        canvas.style.width = '100%'; canvas.style.height = '100%'; canvas.style.borderRadius = '4px';
        el.appendChild(canvas);
        const upiEl = document.getElementById('upiRef');
        if (upiEl) upiEl.value = 'UPI' + invId + Date.now().toString().slice(-6) + '@nlogistic';
    }

    function preparePaymentSubmit() {
        var mode = document.getElementById('paymentModeSelect').value;
        var ref = '';
        if (mode === 'UPI') {
            var vpa = document.getElementById('upiRef').value.trim();
            ref = 'UPI-' + (vpa || 'REF' + Date.now());
        } else if (mode === 'Card') {
            var holder = document.getElementById('cardHolder').value.trim();
            var last4 = document.getElementById('cardLast4').value.trim();
            var net = document.getElementById('cardNetwork').value;
            if (!last4) { alert('Please enter the last 4 digits of the card.'); return false; }
            ref = 'CARD-' + net + '-XXXX' + last4 + (holder ? (' (' + holder + ')') : '');
        } else if (mode === 'Cheque') {
            var chq = document.getElementById('chequeNumber').value.trim();
            var bearer = document.getElementById('bearerName').value.trim();
            if (!chq) { alert('Please enter the cheque number.'); return false; }
            ref = 'CHQ-' + chq + (bearer ? (' / Bearer: ' + bearer) : '');
        } else if (mode === 'Bank Transfer') {
            var bank = document.getElementById('netbankBank').value;
            ref = 'NB-' + bank.replace(/\s+/g, '') + '-' + Date.now().toString().slice(-8);
        } else {
            var plain = document.getElementById('plainTxnRef').value.trim();
            if (!plain) { alert('Please enter a transaction reference.'); return false; }
            ref = plain;
        }
        document.getElementById('transactionRefHidden').value = ref;
        return true;
    }

    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('.form-select-custom').forEach((el) => {
            if (!el.tomselect) {
                try {
                    new TomSelect(el, {
                        create: false,
                        sortField: { field: "text", direction: "asc" }
                    });
                } catch(e) {}
            }
        });

        applyBillingFilters();
    });

    window.addEventListener('click', function(e) {
        if (e.target.classList.contains('modal-overlay')) {
            e.target.classList.remove('active');
        }
    });
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
