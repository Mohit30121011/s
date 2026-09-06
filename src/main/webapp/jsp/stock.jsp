<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* ==========================================================================
       STOCK MANAGEMENT & LEDGER THEME (ENTERPRISE PARITY)
       ========================================================================== */
    :root {
        --nl-primary: #FC8019;
        --nl-primary-hover: #E66F0F;
        --nl-surface: #FFFFFF;
        --nl-border: #E2E8F0;
        --nl-text-main: #0F172A;
        --nl-text-muted: #64748B;
    }

    /* Frameless Stock Header Hero */
    .stock-header-hero {
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

    /* Alerts */
    .custom-alert {
        border-radius: 50px !important;
        padding: 10px 22px;
        font-size: 13.5px;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 20px;
        position: relative;
        max-height: 80px;
        overflow: hidden;
        transition: opacity 0.5s ease, transform 0.5s ease, max-height 0.5s ease, margin 0.5s ease, padding 0.5s ease;
    }
    .custom-alert.success { background: #ECFDF5; border: 1px solid #A7F3D0; color: #065F46; }
    .custom-alert.danger { background: #FEF2F2; border: 1px solid #FECACA; color: #991B1B; }
    .alert-icon-wrap {
        width: 28px;
        height: 28px;
        border-radius: 50% !important;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 15px;
        flex-shrink: 0;
    }
    .custom-alert.success .alert-icon-wrap { background: #DCFCE7; color: #059669; }
    .custom-alert.danger .alert-icon-wrap { background: #FEE2E2; color: #DC2626; }
    .custom-alert .alert-close-btn {
        margin-left: auto;
        background: transparent;
        border: none;
        color: inherit;
        font-size: 20px;
        line-height: 1;
        cursor: pointer;
        padding: 0 4px;
        opacity: 0.6;
        transition: opacity 0.15s ease, transform 0.15s ease;
    }
    .custom-alert .alert-close-btn:hover {
        opacity: 1;
        transform: scale(1.15);
    }

    .stock-panel {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 16px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04); overflow: hidden; height: 100%; display: flex; flex-direction: column;
    }
    .stock-panel-header {
        padding: 16px 22px; border-bottom: 1px solid #F1F5F9; display: flex; align-items: center; justify-content: space-between;
        background: #F8FAFC; flex-wrap: wrap; gap: 10px;
    }
    .stock-panel-header-title { display: flex; align-items: center; gap: 12px; }
    .stock-panel-header .panel-icon {
        width: 38px; height: 38px; border-radius: 50% !important;
        display: flex; align-items: center; justify-content: center; font-size: 18px; flex-shrink: 0;
    }
    .stock-panel-header .panel-icon.orange { background: #FFF0E5; color: #FC8019; }
    .stock-panel-header .panel-icon.blue { background: #EFF6FF; color: #2563EB; }
    .stock-panel-header h5 { margin: 0; font-weight: 700; font-size: 15px; color: #0F172A; }

    .panel-search-box { position: relative; min-width: 200px; max-width: 260px; }
    .panel-search-box i { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #94A3B8; font-size: 14px; }
    .panel-search-box input { padding-left: 38px !important; height: 38px; font-size: 13px; border-radius: 50px !important; border: 1px solid #CBD5E1; width: 100%; }
    .panel-search-box input:focus { border-color: #FC8019; outline: none; box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.15); }

    /* Enterprise Table Architecture */
    .enterprise-table.tracking-table {
        width: 100%; border-collapse: collapse; margin: 0;
    }
    .enterprise-table.tracking-table th {
        background: #F8FAFC; padding: 14px 18px; font-size: 11.5px; font-weight: 700; color: #64748B;
        text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid #E2E8F0; text-align: left;
    }
    .enterprise-table.tracking-table th.sortable {
        cursor: pointer; user-select: none; transition: background-color 0.15s ease, color 0.15s ease;
    }
    .enterprise-table.tracking-table th.sortable:hover {
        background-color: #F1F5F9; color: #FC8019;
    }
    .enterprise-table.tracking-table td {
        padding: 14px 18px; border-bottom: 1px solid #F1F5F9; vertical-align: middle; font-size: 13.5px; color: #1E293B;
    }
    .enterprise-table.tracking-table tr:hover td { background-color: #FAFAFA; }
    .stock-qty-value { font-weight: 700; color: #FC8019; }

    .btn-action-sale {
        background: #FFFFFF; border: 1.5px solid #A7F3D0; color: #059669 !important; padding: 5px 14px; border-radius: 50px !important;
        font-size: 11.5px; font-weight: 600; display: inline-flex; align-items: center; gap: 5px; cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); box-shadow: 0 1px 2px rgba(5, 150, 105, 0.05); text-decoration: none;
    }
    .btn-action-sale:hover { background: #ECFDF5; border-color: #10B981; color: #047857 !important; transform: translateY(-1px); }

    .btn-action-adjust {
        background: #FFFFFF; border: 1.5px solid #FED7AA; color: #D97706 !important; padding: 5px 14px; border-radius: 50px !important;
        font-size: 11.5px; font-weight: 600; display: inline-flex; align-items: center; gap: 5px; cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); box-shadow: 0 1px 2px rgba(217, 119, 6, 0.05); text-decoration: none;
    }
    .btn-action-adjust:hover { background: #FFFBEB; border-color: #F59E0B; color: #B45309 !important; transform: translateY(-1px); }

    .btn-approval-delete {
        background: #FFFFFF; border: 1.5px solid #FECACA; color: #DC2626 !important; padding: 5px 14px; border-radius: 50px !important;
        font-size: 11.5px; font-weight: 600; display: inline-flex; align-items: center; gap: 5px; cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); box-shadow: 0 1px 2px rgba(220, 38, 38, 0.05); text-decoration: none;
    }
    .btn-approval-delete:hover { background: #FEF2F2; border-color: #EF4444; color: #B91C1C !important; transform: translateY(-1px); box-shadow: 0 4px 10px rgba(239, 68, 68, 0.18); }

    .ledger-type-pill { display: inline-flex; align-items: center; gap: 4px; padding: 4px 12px; border-radius: 50px !important; font-size: 11.5px; font-weight: 700; }
    .ledger-type-pill.in { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }
    .ledger-type-pill.out { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }
    .ledger-type-pill.adj { background: #FFFBEB; color: #D97706; border: 1px solid #FDE68A; }

    /* Select wrapper (design system) */
    .select-wrapper { position: relative; width: 100%; }
    .select-wrapper::after {
        content: ''; position: absolute; right: 16px; top: 50%; transform: translateY(-50%); width: 14px; height: 14px;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2364748B' stroke-width='2.2'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E");
        background-size: contain; background-repeat: no-repeat; pointer-events: none;
    }
    .select-wrapper select, .form-select-custom { appearance: none; -webkit-appearance: none; padding-right: 42px !important; border-radius: 50px !important; }

    /* Modal customization */
    .modal-content-custom { border-radius: 16px !important; border: 1px solid #E2E8F0; box-shadow: 0 16px 40px rgba(15, 23, 42, 0.12); overflow: hidden; }
    .modal-header-custom { padding: 20px 24px; border-bottom: 1px solid #F1F3F6; display: flex; align-items: center; justify-content: space-between; }
    .modal-content-custom .modal-footer,
    .modal-footer { background-color: transparent !important; background: transparent !important; }
    .modal-btn-submit { background: #FC8019; color: #FFFFFF; border: none; padding: 10px 24px; border-radius: 50px !important; font-weight: 600; font-size: 13.5px; transition: background-color 0.15s ease; cursor: pointer; }
    .modal-btn-submit:hover { background: #E67012; }
    .modal-btn-danger { background: #DC2626; color: #FFFFFF; border: none; padding: 10px 24px; border-radius: 50px !important; font-weight: 600; font-size: 13.5px; transition: background-color 0.15s ease; cursor: pointer; }
    .modal-btn-danger:hover { background: #B91C1C; }
    .modal-btn-cancel { border-radius: 50px !important; font-weight: 500; }
    .btn-close { border-radius: 50% !important; }
    .empty-stock-box { padding: 40px 24px; text-align: center; }
    .empty-stock-icon { width: 56px; height: 56px; border-radius: 50% !important; background: #F1F5F9; color: #94A3B8; font-size: 26px; display: flex; align-items: center; justify-content: center; margin: 0 auto 14px; }

    /* Modal Badge Icons */
    .modal-badge-icon {
        width: 40px; height: 40px; border-radius: 10px !important;
        display: flex; align-items: center; justify-content: center; font-size: 20px; flex-shrink: 0;
    }
    .modal-badge-icon.upload { background: #FFF0E5; color: #FC8019; }
    .modal-badge-icon.sale { background: #ECFDF5; color: #059669; }
    .modal-badge-icon.adjust { background: #FEF2F2; color: #DC2626; }

    /* Hide Card Tools */
    .nl-card-tools, [data-theme="dark"] .nl-card-tools { display: none !important; }

    /* Circular Pagination Architecture */
    .nl-pagination-wrapper {
        display: flex !important;
        align-items: center;
        justify-content: space-between;
        padding: 12px 18px;
        background: #FFFFFF;
        border-top: 1px solid #E2E8F0;
        flex-wrap: wrap;
        gap: 10px;
    }
    .nl-pagination-info {
        font-size: 12.5px;
        color: #64748B;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .nl-pagination-info strong {
        color: #0F172A;
    }
    .nl-pagination-nav {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        flex-wrap: nowrap;
    }
    .nl-page-size-select {
        background-color: #FFFFFF;
        border: 1px solid #CBD5E1;
        border-radius: 50px !important;
        padding: 2px 8px;
        font-size: 12px;
        font-weight: 600;
        color: #0F172A;
        outline: none;
        cursor: pointer;
    }
    .nl-page-btn {
        width: 30px;
        height: 30px;
        border-radius: 50% !important;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 12px;
        font-weight: 600;
        background-color: #FFFFFF;
        border: 1px solid #CBD5E1;
        color: #475569;
        cursor: pointer;
        transition: all 0.15s ease;
        padding: 0;
        flex-shrink: 0;
    }
    .nl-page-btn:hover:not(.disabled) {
        border-color: #FC8019;
        color: #FC8019;
        background-color: #FFF5EC;
    }
    .nl-page-btn.active {
        background-color: #FC8019 !important;
        border-color: #FC8019 !important;
        color: #FFFFFF !important;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.35);
    }
    .nl-page-btn.disabled {
        opacity: 0.35;
        cursor: not-allowed;
    }
    .nl-page-dots {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 18px;
        height: 30px;
        color: #94A3B8;
        font-size: 13px;
        font-weight: 700;
        user-select: none;
    }

    /* ==========================================================================
       ENTERPRISE DARK THEME PARITY
       ========================================================================== */
    [data-theme="dark"] .container-fluid {
        background-color: transparent !important;
    }
    [data-theme="dark"] .stock-header-hero {
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
    [data-theme="dark"] .btn-outline-nlog {
        background: #151F28 !important;
        border: 1.5px solid #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .btn-outline-nlog:hover {
        background: #1E2D3D !important;
        border-color: #FC8019 !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .custom-alert.success {
        background: rgba(16, 185, 129, 0.12) !important;
        border: 1px solid rgba(16, 185, 129, 0.35) !important;
        color: #6EE7B7 !important;
        box-shadow: 0 4px 18px rgba(16, 185, 129, 0.12) !important;
    }
    [data-theme="dark"] .custom-alert.danger {
        background: rgba(239, 68, 68, 0.12) !important;
        border: 1px solid rgba(239, 68, 68, 0.35) !important;
        color: #FCA5A5 !important;
        box-shadow: 0 4px 18px rgba(239, 68, 68, 0.12) !important;
    }
    [data-theme="dark"] .custom-alert.success .alert-icon-wrap {
        background: rgba(16, 185, 129, 0.22) !important;
        color: #34D399 !important;
    }
    [data-theme="dark"] .custom-alert.danger .alert-icon-wrap {
        background: rgba(239, 68, 68, 0.22) !important;
        color: #F87171 !important;
    }
    [data-theme="dark"] .custom-alert .alert-close-btn {
        color: inherit !important;
        opacity: 0.75 !important;
    }
    [data-theme="dark"] .custom-alert .alert-close-btn:hover {
        opacity: 1 !important;
    }
    [data-theme="dark"] .stock-panel {
        background: #101820 !important;
        border: 1px solid #223447 !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3) !important;
    }
    [data-theme="dark"] .stock-panel-header {
        background: #151F28 !important;
        border-bottom: 1px solid #223447 !important;
    }
    [data-theme="dark"] .stock-panel-header h5 {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .stock-panel-header .panel-icon.orange {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FC8019 !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .stock-panel-header .panel-icon.blue {
        background: rgba(37, 99, 235, 0.16) !important;
        color: #60A5FA !important;
        border: 1px solid rgba(37, 99, 235, 0.3) !important;
    }
    [data-theme="dark"] .panel-search-box input {
        background-color: #101820 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .panel-search-box input:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.15) !important;
    }
    [data-theme="dark"] .enterprise-table.tracking-table th {
        background-color: #101820 !important;
        color: #94A3B8 !important;
        border-bottom: 1px solid #223447 !important;
    }
    [data-theme="dark"] .enterprise-table.tracking-table th.sortable:hover {
        background-color: #151F28 !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .enterprise-table.tracking-table td {
        background-color: transparent !important;
        border-bottom: 1px solid #1E2D3D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .enterprise-table.tracking-table td small.text-muted {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .enterprise-table.tracking-table tr:hover td {
        background-color: rgba(255, 255, 255, 0.02) !important;
    }
    [data-theme="dark"] .btn-action-sale {
        background: rgba(16, 185, 129, 0.12) !important;
        border: 1px solid rgba(16, 185, 129, 0.35) !important;
        color: #34D399 !important;
        box-shadow: none !important;
    }
    [data-theme="dark"] .btn-action-sale:hover {
        background: rgba(16, 185, 129, 0.25) !important;
        border-color: #10B981 !important;
        color: #6EE7B7 !important;
        transform: translateY(-1px);
    }
    [data-theme="dark"] .btn-action-adjust {
        background: rgba(245, 158, 11, 0.12) !important;
        border: 1px solid rgba(245, 158, 11, 0.35) !important;
        color: #FBBF24 !important;
        box-shadow: none !important;
    }
    [data-theme="dark"] .btn-action-adjust:hover {
        background: rgba(245, 158, 11, 0.25) !important;
        border-color: #F59E0B !important;
        color: #FDE68A !important;
        transform: translateY(-1px);
    }
    [data-theme="dark"] .ledger-type-pill.in {
        background: rgba(16, 185, 129, 0.15) !important;
        color: #34D399 !important;
        border: 1px solid rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .ledger-type-pill.out {
        background: rgba(239, 68, 68, 0.15) !important;
        color: #F87171 !important;
        border: 1px solid rgba(239, 68, 68, 0.3) !important;
    }
    [data-theme="dark"] .ledger-type-pill.adj {
        background: rgba(245, 158, 11, 0.15) !important;
        color: #FBBF24 !important;
        border: 1px solid rgba(245, 158, 11, 0.3) !important;
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
    [data-theme="dark"] .nl-page-btn:hover:not(.disabled) {
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
    [data-theme="dark"] .modal-content-custom {
        background-color: #151F28 !important;
        border: 1px solid #223447 !important;
        color: #F8FAFC !important;
        box-shadow: 0 20px 50px rgba(0, 0, 0, 0.6) !important;
    }
    [data-theme="dark"] .modal-header-custom {
        background-color: #151F28 !important;
        border-bottom: 1px solid #223447 !important;
    }
    [data-theme="dark"] .modal-content-custom .modal-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .modal-badge-icon.upload {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FC8019 !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .modal-badge-icon.sale {
        background: rgba(16, 185, 129, 0.16) !important;
        color: #34D399 !important;
        border: 1px solid rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .modal-badge-icon.adjust {
        background: rgba(239, 68, 68, 0.16) !important;
        color: #F87171 !important;
        border: 1px solid rgba(239, 68, 68, 0.3) !important;
    }
    [data-theme="dark"] .modal-content-custom .btn-close {
        filter: invert(1) grayscale(100%) brightness(200%) !important;
        opacity: 0.75 !important;
    }
    [data-theme="dark"] .modal-content-custom .form-label {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .modal-content-custom .form-control,
    [data-theme="dark"] .modal-content-custom .form-select,
    [data-theme="dark"] .modal-content-custom .form-select-custom {
        background-color: #101820 !important;
        border: 1px solid #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .modal-content-custom .form-control:focus,
    [data-theme="dark"] .modal-content-custom .form-select:focus {
        background-color: #0D141C !important;
        border-color: #FC8019 !important;
    }
    [data-theme="dark"] .modal-content-custom code {
        background: #101820 !important;
        color: #FC8019 !important;
        border: 1px solid #2D3F4D !important;
        padding: 2px 6px;
        border-radius: 4px;
    }
    [data-theme="dark"] .modal-footer,
    [data-theme="dark"] .modal-content-custom .modal-footer {
        background-color: #151F28 !important;
        background: #151F28 !important;
        border-top: none !important;
    }
    [data-theme="dark"] .modal-content-custom .modal-btn-cancel,
    [data-theme="dark"] .modal-content-custom .btn-light {
        background-color: #1E2D3D !important;
        border: 1px solid #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .modal-content-custom .modal-btn-cancel:hover,
    [data-theme="dark"] .modal-content-custom .btn-light:hover {
        background-color: #253749 !important;
        border-color: #3B5066 !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .empty-stock-icon {
        background: #1E293B !important;
    }
    [data-theme="dark"] input[type="file"]::file-selector-button {
        background: #1E293B !important;
        color: #F8FAFC !important;
        border: 1px solid #334155 !important;
        border-radius: 50px !important;
        min-height: 48px;
        padding: 6px 14px;
        margin: 0 14px 0 0 !important;
    }
</style>

<div class="container-fluid py-2 mb-5">
    <!-- Frameless Stock Header Hero -->
    <div class="stock-header-hero">
        <div class="telemetry-header-left">
            <div class="telemetry-icon-box">
                <i class="ti ti-stack-2"></i>
            </div>
            <div>
                <h1 class="telemetry-title">Stock Management &amp; Ledger</h1>
                <div class="telemetry-desc">Track current stock levels, adjustments, and inventory movement history</div>
            </div>
        </div>
        <div class="telemetry-actions">
            <a href="${pageContext.request.contextPath}/inventory/products" class="btn btn-outline-nlog"><i class="ti ti-package"></i> Products</a>
            <a href="${pageContext.request.contextPath}/upload-stock" class="btn btn-outline-nlog"><i class="ti ti-upload"></i> Upload / Manage Stock</a>
            <button class="btn btn-register-primary" data-bs-toggle="modal" data-bs-target="#uploadCsvModal" type="button"><i class="ti ti-cloud-upload"></i> Upload CSV</button>
        </div>
    </div>
<c:if test="${not empty uploadInfo}">
        <div class="custom-alert ${uploadInfo.failed > 0 ? 'danger' : 'success'}" style="display:block;">
            <div class="d-flex align-items-center gap-3">
                <div class="alert-icon-wrap"><i class="ti ${uploadInfo.failed > 0 ? 'ti-alert-triangle' : 'ti-circle-check'}"></i></div>
                <span>File '${uploadInfo.fileName}' processed. Total: ${uploadInfo.total}, Success: ${uploadInfo.success}, Failed: ${uploadInfo.failed}.</span>
                <button type="button" class="alert-close-btn ms-auto" onclick="dismissCustomAlert(this.closest('.custom-alert'))" title="Close">&times;</button>
            </div>
            <c:if test="${not empty uploadInfo.errorReportPath}">
                <a href="${pageContext.request.contextPath}/download-errors?file=${uploadInfo.errorReportPath}" class="btn btn-sm btn-danger mt-2" style="border-radius:50px !important;">
                    <i class="ti ti-download me-1"></i> Download Error Report for Invalid Rows
                </a>
            </c:if>
        </div>
    </c:if>
    <c:if test="${param.success == 'true' && empty uploadInfo}">
        <div class="custom-alert success">
            <div class="alert-icon-wrap"><i class="ti ti-circle-check"></i></div>
            <span>Stock updated / recorded successfully!</span>
            <button type="button" class="alert-close-btn" onclick="dismissCustomAlert(this.parentElement)" title="Close">&times;</button>
        </div>
    </c:if>
    <c:if test="${param.error == 'true'}">
        <div class="custom-alert danger">
            <div class="alert-icon-wrap"><i class="ti ti-circle-x"></i></div>
            <span>Failed to process stock operation! Please check input values or CSV format.</span>
            <button type="button" class="alert-close-btn" onclick="dismissCustomAlert(this.parentElement)" title="Close">&times;</button>
        </div>
    </c:if>

    <!-- Upload CSV Modal -->
    <div class="modal fade" id="uploadCsvModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content modal-content-custom">
                <form action="${pageContext.request.contextPath}/inventory/stock/upload" method="POST" enctype="multipart/form-data">
                    <div class="modal-header modal-header-custom">
                        <div class="d-flex align-items-center gap-2">
                            <div class="modal-badge-icon upload">
                                <i class="ti ti-cloud-upload"></i>
                            </div>
                            <h5 class="modal-title mb-0" style="font-weight:700; font-size:16px;">Bulk Upload Stock</h5>
                        </div>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <p class="text-muted small mb-3">Upload a CSV file containing: <code>ProductId, WarehouseLocation, Quantity, UnitCost, BatchNo, ExpiryDate</code></p>
                        <div class="mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Select CSV File</label>
                            <input type="file" class="form-control" name="stockCsv" accept=".csv" required style="border-radius:50px !important; font-size:13.5px;">
                        </div>
                    </div>
                    <div class="modal-footer border-top-0 pt-0 px-4 pb-4">
                        <button type="button" class="btn btn-light modal-btn-cancel" data-bs-dismiss="modal" style="border-radius:50px !important; font-weight:500;">Cancel</button>
                        <button type="submit" class="modal-btn-submit"><i class="ti ti-upload"></i> Upload</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <!-- Current Stock Panel -->
        <div class="col-lg-6">
            <div class="stock-panel">
                <div class="stock-panel-header">
                    <div class="stock-panel-header-title">
                        <div class="panel-icon orange"><i class="ti ti-layers-intersect"></i></div>
                        <h5>Current Stock Levels</h5>
                    </div>
                    <div class="panel-search-box">
                        <i class="ti ti-search"></i>
                        <input type="text" id="stockSearchInput" placeholder="Filter stock..." oninput="handleStockFilter()">
                    </div>
                </div>
                <div class="table-responsive flex-grow-1">
                    <table class="enterprise-table tracking-table" id="stockTable">
                        <thead>
                            <tr>
                                <th class="sortable" onclick="sortStockLevels(0)">Product <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                                <th class="sortable" onclick="sortStockLevels(1)">Location <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                                <th class="sortable" onclick="sortStockLevels(2)">Qty On Hand <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                                <th style="text-align:center;">Action</th>
                            </tr>
                        </thead>
                        <tbody id="stockTableBody">
                            <c:forEach var="s" items="${stocks}">
                                <tr class="stock-item-row" data-text="${s.productName.toLowerCase()} ${empty s.batchNo ? '' : s.batchNo.toLowerCase()} ${s.warehouseLocation.toLowerCase()}">
                                    <td>
                                        <strong>${s.productName}</strong><br>
                                        <small class="text-muted">Batch: ${empty s.batchNo ? '—' : s.batchNo}</small>
                                    </td>
                                    <td>${s.warehouseLocation}</td>
                                    <td><span class="stock-qty-value">${s.quantityOnHand}</span></td>
                                    <td style="text-align:center;">
                                        <div class="d-flex gap-1 justify-content-center">
                                            <button class="btn-action-sale" type="button" data-bs-toggle="modal" data-bs-target="#saleModal${s.stockId}" title="Record Sale (FR4.5)">
                                                <i class="ti ti-cash-register"></i> Sale
                                            </button>
                                            <button class="btn-action-adjust" type="button" data-bs-toggle="modal" data-bs-target="#adjustModal${s.stockId}">
                                                <i class="ti ti-adjustments"></i> Adjust
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty stocks}">
                                <tr><td colspan="4">
                                    <div class="empty-stock-box">
                                        <div class="empty-stock-icon"><i class="ti ti-box-off"></i></div>
                                        <p style="color:#94A3B8; font-size:13px; margin:0;">No stock records available.</p>
                                    </div>
                                </td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

                <!-- Global CSS Pagination for Stock Levels -->
                <div class="nl-pagination-wrapper" id="stockPagination" style="display: none;">
                    <div class="nl-pagination-info">
                        <span>Showing <strong id="stockPageStart">1</strong> to <strong id="stockPageEnd">10</strong> of <strong id="stockTotalRows">0</strong> records</span>
                        <div class="d-inline-flex align-items-center gap-2 ms-2">
                            <span class="text-muted small">Show:</span>
                            <select class="nl-page-size-select" id="stockPageSize" onchange="changeStockPageSize(this.value)">
                                <option value="10" selected>10</option>
                                <option value="25">25</option>
                                <option value="50">50</option>
                            </select>
                        </div>
                    </div>
                    <div class="nl-pagination-nav" id="stockPageNav"></div>
                </div>
            </div>
        </div>

        <!-- Inventory Ledger Panel -->
        <div class="col-lg-6">
            <div class="stock-panel">
                <div class="stock-panel-header">
                    <div class="stock-panel-header-title">
                        <div class="panel-icon blue"><i class="ti ti-notebook"></i></div>
                        <h5>Inventory Ledger</h5>
                    </div>
                    <div class="panel-search-box">
                        <i class="ti ti-search"></i>
                        <input type="text" id="ledgerSearchInput" placeholder="Filter ledger..." oninput="handleLedgerFilter()">
                    </div>
                </div>
                <div class="table-responsive flex-grow-1">
                    <table class="enterprise-table tracking-table" id="ledgerTable">
                        <thead style="position: sticky; top: 0; z-index: 1;">
                            <tr>
                                <th class="sortable" onclick="sortLedgerEntries(0)">Date <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                                <th class="sortable" onclick="sortLedgerEntries(1)">Type <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                                <th class="sortable" onclick="sortLedgerEntries(2)">Product <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                                <th class="sortable" onclick="sortLedgerEntries(3)">Qty <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                                <th>Ref</th>
                            </tr>
                        </thead>
                        <tbody id="ledgerTableBody">
                            <c:forEach var="l" items="${ledger}">
                                <tr class="ledger-item-row" data-text="${l.productName.toLowerCase()} ${l.transactionType.toLowerCase()} ${l.referenceType.toLowerCase()}">
                                    <td>${l.transactionDate}</td>
                                    <td>
                                        <span class="ledger-type-pill ${l.transactionType == 'IN' ? 'in' : (l.transactionType == 'OUT' ? 'out' : 'adj')}">
                                            ${l.transactionType}
                                        </span>
                                    </td>
                                    <td>${l.productName}</td>
                                    <td>${l.quantity}</td>
                                    <td class="text-muted small">${l.referenceType} #${l.referenceId}</td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty ledger}">
                                <tr><td colspan="5">
                                    <div class="empty-stock-box">
                                        <div class="empty-stock-icon"><i class="ti ti-notebook-off"></i></div>
                                        <p style="color:#94A3B8; font-size:13px; margin:0;">No ledger entries available.</p>
                                    </div>
                                </td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

                <!-- Global CSS Pagination for Inventory Ledger -->
                <div class="nl-pagination-wrapper" id="ledgerPagination" style="display: none;">
                    <div class="nl-pagination-info">
                        <span>Showing <strong id="ledgerPageStart">1</strong> to <strong id="ledgerPageEnd">10</strong> of <strong id="ledgerTotalRows">0</strong> entries</span>
                        <div class="d-inline-flex align-items-center gap-2 ms-2">
                            <span class="text-muted small">Show:</span>
                            <select class="nl-page-size-select" id="ledgerPageSize" onchange="changeLedgerPageSize(this.value)">
                                <option value="10" selected>10</option>
                                <option value="25">25</option>
                                <option value="50">50</option>
                            </select>
                        </div>
                    </div>
                    <div class="nl-pagination-nav" id="ledgerPageNav"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal Container for Sale & Adjust Modals (Outside table to prevent layout disruption) -->
<div id="stockModalsContainer">
    <c:forEach var="s" items="${stocks}">
        <!-- Record Sale Modal (FR4.5) -->
        <div class="modal fade" id="saleModal${s.stockId}" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content modal-content-custom">
                    <form action="${pageContext.request.contextPath}/inventory/stock/sale" method="POST">
                        <div class="modal-header modal-header-custom">
                            <div class="d-flex align-items-center gap-2">
                                <div class="modal-badge-icon sale">
                                    <i class="ti ti-cash-register"></i>
                                </div>
                                <h5 class="modal-title mb-0" style="font-weight:700; font-size:16px;">Record Sale: ${s.productName}</h5>
                            </div>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body p-4">
                            <input type="hidden" name="productId" value="${s.productId}">
                            <p class="mb-3">Available Qty: <strong class="stock-qty-value">${s.quantityOnHand}</strong></p>
                            <div class="mb-3">
                                <label class="form-label" style="font-weight:600; font-size:13px;">Customer</label>
                                <div class="select-wrapper">
                                <select class="form-select form-select-custom" name="customerId" required style="border-radius:50px !important; font-size:13.5px;">
                                    <option value="">Select customer</option>
                                    <c:forEach var="cust" items="${customers}">
                                        <option value="${cust.customerId}">${cust.customerName}</option>
                                    </c:forEach>
                                </select>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label" style="font-weight:600; font-size:13px;">Quantity Sold</label>
                                <input type="number" step="0.01" min="0.01" max="${s.quantityOnHand}" class="form-control" name="quantity" required style="border-radius:50px !important; font-size:13.5px;">
                            </div>
                            <div class="mb-3">
                                <label class="form-label" style="font-weight:600; font-size:13px;">Unit Sale Price (₹)</label>
                                <input type="number" step="0.01" min="0" class="form-control" name="salePrice" required style="border-radius:50px !important; font-size:13.5px;">
                            </div>
                        </div>
                        <div class="modal-footer border-top-0 pt-0 px-4 pb-4">
                            <button type="button" class="btn btn-light modal-btn-cancel" data-bs-dismiss="modal" style="border-radius:50px !important; font-weight:500;">Cancel</button>
                            <button type="submit" class="modal-btn-submit"><i class="ti ti-cash-register"></i> Record Sale</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Adjust Modal -->
        <div class="modal fade" id="adjustModal${s.stockId}" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content modal-content-custom">
                    <form action="${pageContext.request.contextPath}/inventory/stock/adjust" method="POST">
                        <div class="modal-header modal-header-custom">
                            <div class="d-flex align-items-center gap-2">
                                <div class="modal-badge-icon adjust">
                                    <i class="ti ti-adjustments"></i>
                                </div>
                                <h5 class="modal-title mb-0" style="font-weight:700; font-size:16px;">Adjust Stock: ${s.productName}</h5>
                            </div>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body p-4">
                            <input type="hidden" name="stockId" value="${s.stockId}">
                            <input type="hidden" name="productId" value="${s.productId}">
                            <p class="mb-3">Current Qty: <strong class="stock-qty-value">${s.quantityOnHand}</strong></p>
                            <div class="mb-3">
                                <label class="form-label" style="font-weight:600; font-size:13px;">New Total Quantity (after adjustment)</label>
                                <input type="number" step="0.01" class="form-control" name="newQty" required style="border-radius:50px !important; font-size:13.5px;">
                            </div>
                            <div class="mb-3">
                                <label class="form-label" style="font-weight:600; font-size:13px;">Reason (Mandatory)</label>
                                <input type="text" class="form-control" name="reason" placeholder="e.g. Damage, Audit Discrepancy" required style="border-radius:50px !important; font-size:13.5px;">
                            </div>
                        </div>
                        <div class="modal-footer border-top-0 pt-0 px-4 pb-4">
                            <button type="button" class="btn btn-light modal-btn-cancel" data-bs-dismiss="modal" style="border-radius:50px !important; font-weight:500;">Cancel</button>
                            <button type="submit" class="modal-btn-danger">Confirm Adjustment</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </c:forEach>
</div>

<script>
    
    // =========================================================================
    // CLIENT-SIDE SORTING FOR STOCK LEVELS & LEDGER
    // =========================================================================
    let stockSortCol = -1;
    let stockSortAsc = true;
    function sortStockLevels(colIndex) {
        if (stockSortCol === colIndex) stockSortAsc = !stockSortAsc;
        else { stockSortCol = colIndex; stockSortAsc = true; }
        matchingStockRows.sort((a, b) => {
            const cellA = a.cells[colIndex] ? a.cells[colIndex].innerText.trim() : '';
            const cellB = b.cells[colIndex] ? b.cells[colIndex].innerText.trim() : '';
            const numA = parseFloat(cellA.replace(/[^0-9.-]+/g, ''));
            const numB = parseFloat(cellB.replace(/[^0-9.-]+/g, ''));
            if (!isNaN(numA) && !isNaN(numB)) return stockSortAsc ? numA - numB : numB - numA;
            return stockSortAsc ? cellA.localeCompare(cellB) : cellB.localeCompare(cellA);
        });
        const tbody = document.getElementById('stockTableBody');
        matchingStockRows.forEach(r => tbody.appendChild(r));
        updateStockPagination();
    }

    let ledgerSortCol = -1;
    let ledgerSortAsc = true;
    function sortLedgerEntries(colIndex) {
        if (ledgerSortCol === colIndex) ledgerSortAsc = !ledgerSortAsc;
        else { ledgerSortCol = colIndex; ledgerSortAsc = true; }
        matchingLedgerRows.sort((a, b) => {
            const cellA = a.cells[colIndex] ? a.cells[colIndex].innerText.trim() : '';
            const cellB = b.cells[colIndex] ? b.cells[colIndex].innerText.trim() : '';
            const numA = parseFloat(cellA.replace(/[^0-9.-]+/g, ''));
            const numB = parseFloat(cellB.replace(/[^0-9.-]+/g, ''));
            if (!isNaN(numA) && !isNaN(numB)) return ledgerSortAsc ? numA - numB : numB - numA;
            return ledgerSortAsc ? cellA.localeCompare(cellB) : cellB.localeCompare(cellA);
        });
        const tbody = document.getElementById('ledgerTableBody');
        matchingLedgerRows.forEach(r => tbody.appendChild(r));
        updateLedgerPagination();
    }

    // =========================================================================
    // STOCK LEVELS CLIENT-SIDE PAGINATION (GLOBAL CSS)
    // =========================================================================
    let stockPageSize = 10;
    let stockCurrentPage = 1;
    let allStockRows = [];
    let matchingStockRows = [];

    function initStockPagination() {
        allStockRows = Array.from(document.querySelectorAll('.stock-item-row'));
        matchingStockRows = [...allStockRows];
        updateStockPagination();
    }

    function handleStockFilter() {
        const query = (document.getElementById('stockSearchInput').value || '').trim().toLowerCase();
        matchingStockRows = allStockRows.filter(row => {
            const txt = row.getAttribute('data-text') || '';
            return !query || txt.includes(query);
        });
        stockCurrentPage = 1;
        updateStockPagination();
    }

    function changeStockPageSize(val) {
        stockPageSize = parseInt(val) || 10;
        stockCurrentPage = 1;
        updateStockPagination();
    }

    function updateStockPagination() {
        const total = matchingStockRows.length;
        const totalPages = Math.ceil(total / stockPageSize) || 1;
        if (stockCurrentPage > totalPages) stockCurrentPage = totalPages;
        if (stockCurrentPage < 1) stockCurrentPage = 1;

        const startIdx = (stockCurrentPage - 1) * stockPageSize;
        const endIdx = startIdx + stockPageSize;

        allStockRows.forEach(r => r.style.display = 'none');
        matchingStockRows.slice(startIdx, endIdx).forEach(r => r.style.display = '');

        const pageStartEl = document.getElementById('stockPageStart');
        const pageEndEl = document.getElementById('stockPageEnd');
        const totalRowsEl = document.getElementById('stockTotalRows');
        const wrapper = document.getElementById('stockPagination');

        if (pageStartEl) pageStartEl.innerText = total === 0 ? 0 : startIdx + 1;
        if (pageEndEl) pageEndEl.innerText = Math.min(endIdx, total);
        if (totalRowsEl) totalRowsEl.innerText = total;

        if (wrapper) wrapper.style.display = total > 0 ? 'flex' : 'none';

        renderStockPageNav(totalPages);
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

    function renderStockPageNav(totalPages) {
        const nav = document.getElementById('stockPageNav');
        if (!nav) return;
        nav.innerHTML = '';
        if (totalPages <= 1) return;

        const prev = document.createElement('button');
        prev.type = 'button';
        prev.className = 'nl-page-btn nl-page-nav-btn' + (stockCurrentPage === 1 ? ' disabled' : '');
        prev.disabled = (stockCurrentPage === 1);
        prev.innerHTML = '<i class="ti ti-chevron-left"></i>';
        prev.onclick = () => { if (stockCurrentPage > 1) { stockCurrentPage--; updateStockPagination(); } };
        nav.appendChild(prev);

        const pages = getPaginationWindow(stockCurrentPage, totalPages);
        pages.forEach(p => {
            if (p === '...') {
                const dots = document.createElement('span');
                dots.className = 'nl-page-dots';
                dots.innerText = '…';
                nav.appendChild(dots);
            } else {
                const btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'nl-page-btn nl-page-num' + (p === stockCurrentPage ? ' active' : '');
                btn.innerText = p;
                btn.onclick = () => { stockCurrentPage = p; updateStockPagination(); };
                nav.appendChild(btn);
            }
        });

        const next = document.createElement('button');
        next.type = 'button';
        next.className = 'nl-page-btn nl-page-nav-btn' + (stockCurrentPage === totalPages ? ' disabled' : '');
        next.disabled = (stockCurrentPage === totalPages);
        next.innerHTML = '<i class="ti ti-chevron-right"></i>';
        next.onclick = () => { if (stockCurrentPage < totalPages) { stockCurrentPage++; updateStockPagination(); } };
        nav.appendChild(next);
    }

    // =========================================================================
    // INVENTORY LEDGER CLIENT-SIDE PAGINATION (GLOBAL CSS)
    // =========================================================================
    let ledgerPageSize = 10;
    let ledgerCurrentPage = 1;
    let allLedgerRows = [];
    let matchingLedgerRows = [];

    function initLedgerPagination() {
        allLedgerRows = Array.from(document.querySelectorAll('.ledger-item-row'));
        matchingLedgerRows = [...allLedgerRows];
        updateLedgerPagination();
    }

    function handleLedgerFilter() {
        const query = (document.getElementById('ledgerSearchInput').value || '').trim().toLowerCase();
        matchingLedgerRows = allLedgerRows.filter(row => {
            const txt = row.getAttribute('data-text') || '';
            return !query || txt.includes(query);
        });
        ledgerCurrentPage = 1;
        updateLedgerPagination();
    }

    function changeLedgerPageSize(val) {
        ledgerPageSize = parseInt(val) || 10;
        ledgerCurrentPage = 1;
        updateLedgerPagination();
    }

    function updateLedgerPagination() {
        const total = matchingLedgerRows.length;
        const totalPages = Math.ceil(total / ledgerPageSize) || 1;
        if (ledgerCurrentPage > totalPages) ledgerCurrentPage = totalPages;
        if (ledgerCurrentPage < 1) ledgerCurrentPage = 1;

        const startIdx = (ledgerCurrentPage - 1) * ledgerPageSize;
        const endIdx = startIdx + ledgerPageSize;

        allLedgerRows.forEach(r => r.style.display = 'none');
        matchingLedgerRows.slice(startIdx, endIdx).forEach(r => r.style.display = '');

        const pageStartEl = document.getElementById('ledgerPageStart');
        const pageEndEl = document.getElementById('ledgerPageEnd');
        const totalRowsEl = document.getElementById('ledgerTotalRows');
        const wrapper = document.getElementById('ledgerPagination');

        if (pageStartEl) pageStartEl.innerText = total === 0 ? 0 : startIdx + 1;
        if (pageEndEl) pageEndEl.innerText = Math.min(endIdx, total);
        if (totalRowsEl) totalRowsEl.innerText = total;

        if (wrapper) wrapper.style.display = total > 0 ? 'flex' : 'none';

        renderLedgerPageNav(totalPages);
    }

    function renderLedgerPageNav(totalPages) {
        const nav = document.getElementById('ledgerPageNav');
        if (!nav) return;
        nav.innerHTML = '';
        if (totalPages <= 1) return;

        const prev = document.createElement('button');
        prev.type = 'button';
        prev.className = 'nl-page-btn nl-page-nav-btn' + (ledgerCurrentPage === 1 ? ' disabled' : '');
        prev.disabled = (ledgerCurrentPage === 1);
        prev.innerHTML = '<i class="ti ti-chevron-left"></i>';
        prev.onclick = () => { if (ledgerCurrentPage > 1) { ledgerCurrentPage--; updateLedgerPagination(); } };
        nav.appendChild(prev);

        const pages = getPaginationWindow(ledgerCurrentPage, totalPages);
        pages.forEach(p => {
            if (p === '...') {
                const dots = document.createElement('span');
                dots.className = 'nl-page-dots';
                dots.innerText = '…';
                nav.appendChild(dots);
            } else {
                const btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'nl-page-btn nl-page-num' + (p === ledgerCurrentPage ? ' active' : '');
                btn.innerText = p;
                btn.onclick = () => { ledgerCurrentPage = p; updateLedgerPagination(); };
                nav.appendChild(btn);
            }
        });

        const next = document.createElement('button');
        next.type = 'button';
        next.className = 'nl-page-btn nl-page-nav-btn' + (ledgerCurrentPage === totalPages ? ' disabled' : '');
        next.disabled = (ledgerCurrentPage === totalPages);
        next.innerHTML = '<i class="ti ti-chevron-right"></i>';
        next.onclick = () => { if (ledgerCurrentPage < totalPages) { ledgerCurrentPage++; updateLedgerPagination(); } };
        nav.appendChild(next);
    }

    // Dismiss custom alert with smooth collapse
    window.dismissCustomAlert = function(alertEl) {
        if (!alertEl) return;
        alertEl.style.opacity = '0';
        alertEl.style.transform = 'translateY(-10px)';
        setTimeout(function() {
            alertEl.style.maxHeight = '0';
            alertEl.style.marginBottom = '0';
            alertEl.style.paddingTop = '0';
            alertEl.style.paddingBottom = '0';
            setTimeout(function() {
                alertEl.remove();
            }, 500);
        }, 300);
    };

    document.addEventListener('DOMContentLoaded', function() {
        initStockPagination();
        initLedgerPagination();

        // Auto-dismiss feedback alert toasts after 5 seconds
        var activeAlerts = document.querySelectorAll('.custom-alert');
        if (activeAlerts.length > 0) {
            setTimeout(function() {
                activeAlerts.forEach(function(el) {
                    dismissCustomAlert(el);
                });
            }, 5000);
        }
    });
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
