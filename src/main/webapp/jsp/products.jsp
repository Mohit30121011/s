<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<%-- MVC2 (SRS 10.2): data and actions come from InventoryServlet (/inventory/products).
     The inline controller block that used to live here re-queried the DAO
     with no tenant scope whenever the JSP was opened directly. --%>
<style>
    /* ==========================================================================
       PRODUCT CATALOG THEME (ENTERPRISE PARITY)
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
    [data-theme="dark"] {
        --nl-surface: #151F28 !important;
        --nl-border: #2D3F4D !important;
        --nl-text-main: #F8FAFC !important;
        --nl-text-muted: #94A3B8 !important;
    }

    .products-container {
        padding: 0 4px 40px;
    }

    /* Breadcrumbs */
    .custom-breadcrumb {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 13px;
        color: #64748B;
        margin-bottom: 16px;
    }
    .custom-breadcrumb a {
        color: #64748B;
        text-decoration: none;
        transition: color 0.15s ease;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
    .custom-breadcrumb a:hover {
        color: #FC8019;
    }
    .custom-breadcrumb .sep {
        color: #CBD5E1;
        font-size: 11px;
    }
    .custom-breadcrumb .current {
        color: #0F172A;
        font-weight: 600;
    }

    /* Hide Export/Fullscreen Card Tools Everywhere on this Page */
    .nl-card-tools,
    .no-card-tools .nl-card-tools,
    [data-no-tools="true"] .nl-card-tools,
    .nl-card-tools-floating {
        display: none !important;
    }

    /* Frameless Header Hero */
    .product-header-hero,
    .telemetry-header-card {
        background: transparent !important;
        background-color: transparent !important;
        border: none !important;
        box-shadow: none !important;
        padding: 0 !important;
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

    /* KPI Cards */
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
        border: 1px solid var(--nl-border);
        border-radius: 16px;
        padding: 18px 20px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03);
        display: flex;
        align-items: center;
        justify-content: space-between;
        transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
    }
    .kpi-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(15, 23, 42, 0.06);
        border-color: #CBD5E1;
    }
    .kpi-label {
        font-size: 12px;
        font-weight: 600;
        color: #64748B;
        margin-bottom: 6px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    .kpi-value {
        font-size: 26px;
        font-weight: 800;
        color: #0F172A;
        line-height: 1;
        letter-spacing: -0.02em;
    }
    .kpi-icon-pill {
        width: 48px;
        height: 48px;
        border-radius: 50% !important;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 22px;
        flex-shrink: 0;
    }
    .kpi-icon-pill.orange { background: #FFF2EB; color: #FC8019; }
    .kpi-icon-pill.green { background: #ECFDF5; color: #059669; }
    .kpi-icon-pill.blue { background: #EFF6FF; color: #2563EB; }
    .kpi-icon-pill.amber { background: #FFFBEB; color: #D97706; }

    /* Alerts */
    .custom-alert {
        border-radius: 50px !important;
        padding: 12px 24px;
        font-size: 13.5px;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 18px;
        position: relative;
        max-height: 80px;
        overflow: hidden;
        transition: opacity 0.5s ease, transform 0.5s ease, max-height 0.5s ease, margin 0.5s ease, padding 0.5s ease;
    }
    .custom-alert.success { background: #ECFDF5; border: 1px solid #A7F3D0; color: #065F46; }
    .custom-alert.danger { background: #FEF2F2; border: 1px solid #FECACA; color: #991B1B; }
    .custom-alert.warning { background: #FFFBEB; border: 1px solid #FDE68A; color: #92400E; }
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

    /* Filter Bar Card */
    .filter-bar-card {
        background: #FFFFFF;
        border-radius: 16px;
        border: 1px solid var(--nl-border);
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03);
        padding: 14px 20px;
        margin-bottom: 20px;
        display: flex;
        align-items: center;
    }
    .filter-bar-inner {
        display: flex;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
        width: 100%;
    }
    .filter-search-box {
        position: relative;
        width: 320px;
        max-width: 100%;
        flex-shrink: 0;
    }
    .filter-search-box i.search-icon {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #94A3B8;
        font-size: 15px;
        pointer-events: none;
    }
    .filter-search-box input {
        width: 100%;
        height: 40px;
        padding: 0 36px 0 40px;
        border: 1px solid #CBD5E1;
        border-radius: 50px !important;
        font-size: 13.5px;
        outline: none;
        background: #FFFFFF;
        color: #1E293B;
        transition: border-color 0.15s ease, box-shadow 0.15s ease;
    }
    .filter-search-box input:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .search-clear-btn {
        position: absolute;
        right: 14px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        color: #94A3B8;
        cursor: pointer;
        display: none;
        font-size: 16px;
    }
    .search-clear-btn:hover {
        color: #0F172A;
    }
    .filter-category-wrap {
        width: 240px;
        max-width: 100%;
        flex-shrink: 0;
    }
    .filter-category-wrap .ts-wrapper {
        border: none !important;
        background: transparent !important;
        box-shadow: none !important;
        padding: 0 !important;
        margin: 0 !important;
        width: 100% !important;
    }
    .filter-category-select {
        width: 100% !important;
        height: 40px !important;
        min-height: 40px !important;
        border: 1px solid #CBD5E1 !important;
        border-radius: 50px !important;
        padding: 0 38px 0 18px !important;
        font-size: 13.5px !important;
        font-weight: 500 !important;
        color: #1E293B !important;
        outline: none !important;
        background-color: #FFFFFF !important;
        cursor: pointer !important;
        display: block !important;
        appearance: none !important;
        -webkit-appearance: none !important;
        -moz-appearance: none !important;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23FC8019' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
        background-repeat: no-repeat !important;
        background-position: right 16px center !important;
        background-size: 12px 10px !important;
        transition: border-color 0.15s ease, box-shadow 0.15s ease !important;
    }
    .filter-category-select:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12) !important;
    }

    /* Enterprise Circular Pagination */
    .nl-pagination-wrapper {
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 16px;
        padding: 16px 24px;
        background: #FFFFFF;
        border-top: 1px solid #E2E8F0;
    }
    .nl-pagination-info {
        display: flex;
        align-items: center;
        gap: 12px;
        font-size: 13px;
        color: #64748B;
    }
    .nl-pagination-info strong {
        color: #0F172A;
        font-weight: 700;
    }
    .nl-page-size-select {
        height: 32px;
        padding: 0 12px;
        border-radius: 50px !important;
        border: 1px solid #CBD5E1;
        background-color: #FFFFFF;
        color: #1E293B;
        font-size: 12.5px;
        outline: none;
        cursor: pointer;
    }
    .nl-pagination-nav {
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .nl-page-btn {
        min-width: 34px;
        height: 34px;
        border-radius: 50px !important;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        color: #475569;
        font-size: 12.5px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 0 10px;
        cursor: pointer;
        transition: all 0.15s ease;
        user-select: none;
    }
    .nl-page-btn:hover:not(.disabled):not(.active) {
        border-color: #CBD5E1;
        background: #F8FAFC;
        color: #0F172A;
    }
    .nl-page-btn.active {
        background: #FC8019 !important;
        border-color: #FC8019 !important;
        color: #FFFFFF !important;
        box-shadow: 0 2px 8px rgba(252, 128, 25, 0.35);
    }
    .nl-page-btn.disabled {
        opacity: 0.4;
        cursor: not-allowed;
        pointer-events: none;
    }

    /* Product Table Panel */
    .product-table-panel {
        background: #FFFFFF;
        border: 1px solid var(--nl-border);
        border-radius: 16px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04);
        overflow: hidden;
    }
    .enterprise-table.tracking-table {
        width: 100%;
        border-collapse: collapse;
        margin: 0;
    }
    .enterprise-table.tracking-table th {
        background: #F8FAFC;
        padding: 14px 20px;
        font-size: 11.5px;
        font-weight: 700;
        color: #64748B;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border-bottom: 1px solid #E2E8F0;
        text-align: left;
    }
    .enterprise-table.tracking-table th.sortable {
        cursor: pointer;
        user-select: none;
        transition: background-color 0.15s ease, color 0.15s ease;
    }
    .enterprise-table.tracking-table th.sortable:hover {
        background-color: #F1F5F9;
        color: #FC8019;
    }
    .enterprise-table.tracking-table td {
        padding: 14px 20px;
        border-bottom: 1px solid #F1F5F9;
        vertical-align: middle;
        font-size: 13.5px;
        color: #1E293B;
    }
    .enterprise-table.tracking-table tr:hover td {
        background-color: #FAFAFA;
    }
    .product-id-chip {
        font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
        font-size: 12.5px;
        color: #64748B;
        font-weight: 700;
    }
    .category-pill {
        background: #F1F5F9;
        color: #475569;
        border: 1px solid #E2E8F0;
        font-weight: 600;
        font-size: 11.5px;
        padding: 4px 12px;
        border-radius: 50px !important;
        display: inline-flex;
        align-items: center;
        gap: 4px;
    }
    .price-value {
        font-weight: 700;
        color: #059669;
    }
    .cost-value {
        font-weight: 600;
        color: #64748B;
    }
    .product-name-txt {
        color: #0F172A;
        font-weight: 700;
    }
    .product-uom-badge {
        background: #F1F5F9;
        color: #475569;
        border: 1px solid #E2E8F0;
        font-size: 11.5px;
        padding: 3px 8px;
        border-radius: 6px;
        font-weight: 600;
        display: inline-block;
    }

    .actions-flex {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
    }
    .btn-action-edit {
        background: #FFFFFF;
        border: 1.5px solid #BFDBFE;
        color: #2563EB !important;
        padding: 6px 14px;
        border-radius: 50px !important;
        font-size: 11.5px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        cursor: pointer;
        transition: all 0.18s ease;
        box-shadow: 0 1px 2px rgba(37, 99, 235, 0.05);
    }
    .btn-action-edit:hover {
        background: #EFF6FF;
        border-color: #3B82F6;
        color: #1D4ED8 !important;
        transform: translateY(-1px);
        box-shadow: 0 4px 10px rgba(37, 99, 235, 0.15);
    }
    .btn-action-delete {
        background: #FFFFFF;
        border: 1.5px solid #FECACA;
        color: #DC2626 !important;
        padding: 6px 14px;
        border-radius: 50px !important;
        font-size: 11.5px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        cursor: pointer;
        transition: all 0.18s ease;
        box-shadow: 0 1px 2px rgba(220, 38, 38, 0.05);
    }
    .btn-action-delete:hover {
        background: #FEF2F2;
        border-color: #EF4444;
        color: #B91C1C !important;
        transform: translateY(-1px);
        box-shadow: 0 4px 10px rgba(239, 68, 68, 0.18);
    }

    /* Modal Customization */
    .modal-content-custom {
        border-radius: 16px !important;
        border: 1px solid #E2E8F0;
        box-shadow: 0 16px 40px rgba(15, 23, 42, 0.12);
        overflow: hidden;
        background: #FFFFFF;
    }
    .modal-header-custom {
        padding: 20px 24px;
        border-bottom: 1px solid #F1F3F6;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .modal-badge-icon {
        width: 38px;
        height: 38px;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        flex-shrink: 0;
    }
    .modal-badge-icon.add { background: #FFF2EB; color: #FC8019; }
    .modal-badge-icon.edit { background: #EFF6FF; color: #2563EB; }
    .modal-delete-icon {
        width: 60px;
        height: 60px;
        border-radius: 18px;
        background: #FEF2F2;
        border: 1px solid #FECACA;
        color: #DC2626;
        font-size: 28px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 16px;
    }
    .modal-delete-title {
        font-weight: 700;
        color: #0F172A;
    }
    .modal-btn-submit {
        background: #FC8019;
        color: #FFFFFF !important;
        border: none;
        padding: 10px 24px;
        border-radius: 50px !important;
        font-weight: 600;
        font-size: 13.5px;
        transition: background-color 0.15s ease;
        cursor: pointer;
    }
    .modal-btn-submit:hover { background: #E67012; }
    .modal-btn-danger {
        background: #DC2626;
        color: #FFFFFF !important;
        border: none;
        padding: 10px 24px;
        border-radius: 50px !important;
        font-weight: 600;
        font-size: 13.5px;
        transition: background-color 0.15s ease;
        cursor: pointer;
    }
    .modal-btn-danger:hover { background: #B91C1C; }
    .btn-close { border-radius: 50% !important; }
    .empty-catalog-box {
        padding: 60px 24px;
        text-align: center;
    }
    .empty-catalog-icon {
        width: 68px;
        height: 68px;
        border-radius: 50% !important;
        background: #F1F5F9;
        color: #94A3B8;
        font-size: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 18px;
    }

    /* Dark Mode Standards */
    [data-theme="dark"] .products-container {
        background: transparent !important;
        background-color: transparent !important;
    }
    [data-theme="dark"] .product-header-hero,
    [data-theme="dark"] .telemetry-header-card {
        background: transparent !important;
        background-color: transparent !important;
        border: none !important;
        box-shadow: none !important;
        padding: 0 !important;
    }
    [data-theme="dark"] .telemetry-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .telemetry-desc,
    [data-theme="dark"] .custom-breadcrumb,
    [data-theme="dark"] .custom-breadcrumb a {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .custom-breadcrumb .current {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .kpi-card {
        background: #101820 !important;
        border: 1px solid #223447 !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .filter-bar-card,
    [data-theme="dark"] .product-table-panel {
        background: #101820 !important;
        border: 1px solid #223447 !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.25) !important;
    }
    [data-theme="dark"] .kpi-value {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .kpi-label {
        color: #94A3B8 !important;
    }

    /* KPI Circular Icons in Dark Mode */
    [data-theme="dark"] .kpi-icon-pill.orange {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FC8019 !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .kpi-icon-pill.blue {
        background: rgba(37, 99, 235, 0.16) !important;
        color: #60A5FA !important;
        border: 1px solid rgba(37, 99, 235, 0.3) !important;
    }
    [data-theme="dark"] .kpi-icon-pill.green {
        background: rgba(16, 185, 129, 0.16) !important;
        color: #34D399 !important;
        border: 1px solid rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .kpi-icon-pill.amber {
        background: rgba(245, 158, 11, 0.16) !important;
        color: #FBBF24 !important;
        border: 1px solid rgba(245, 158, 11, 0.3) !important;
    }

    /* Action Buttons in Table */
    [data-theme="dark"] .btn-action-edit {
        background: rgba(37, 99, 235, 0.16) !important;
        border: 1px solid rgba(37, 99, 235, 0.35) !important;
        color: #60A5FA !important;
    }
    [data-theme="dark"] .btn-action-edit:hover {
        background: #2563EB !important;
        color: #FFFFFF !important;
        box-shadow: 0 4px 10px rgba(37, 99, 235, 0.28) !important;
    }
    [data-theme="dark"] .btn-action-delete {
        background: rgba(239, 68, 68, 0.16) !important;
        border: 1px solid rgba(239, 68, 68, 0.35) !important;
        color: #F87171 !important;
    }
    [data-theme="dark"] .btn-action-delete:hover {
        background: #EF4444 !important;
        color: #FFFFFF !important;
        box-shadow: 0 4px 10px rgba(239, 68, 68, 0.28) !important;
    }
    [data-theme="dark"] .product-row strong {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .cost-value {
        color: #94A3B8 !important;
    }

    /* Filter & Search Bar in Dark Mode */
    [data-theme="dark"] .filter-search-box input {
        background-color: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .filter-search-box input::placeholder {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .filter-search-box i.search-icon {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .filter-search-box input:focus {
        background-color: #101820 !important;
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.22) !important;
    }
    /* Category Filter Dark Mode */
    [data-theme="dark"] .filter-category-wrap .ts-wrapper {
        border: none !important;
        background: transparent !important;
        box-shadow: none !important;
        padding: 0 !important;
        margin: 0 !important;
    }
    [data-theme="dark"] .filter-category-select,
    [data-theme="dark"] .filter-category-wrap .ts-control,
    [data-theme="dark"] .form-control,
    [data-theme="dark"] .nl-page-size-select {
        background-color: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23FC8019' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
    }
    [data-theme="dark"] .filter-category-select option {
        background-color: #151F28 !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .filter-category-wrap .ts-control .item {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .filter-category-wrap .ts-control input {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .filter-category-select:focus,
    [data-theme="dark"] .filter-category-wrap .ts-wrapper.dropdown-active .ts-control,
    [data-theme="dark"] .filter-category-wrap .ts-wrapper.focus .ts-control {
        background-color: #151F28 !important;
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.22) !important;
    }
    [data-theme="dark"] .ts-dropdown,
    [data-theme="dark"] .filter-category-wrap .ts-dropdown {
        background: #151F28 !important;
        border: 1px solid #2D3F4D !important;
        box-shadow: 0 14px 36px rgba(0, 0, 0, 0.55) !important;
        border-radius: 14px !important;
    }
    [data-theme="dark"] .ts-dropdown .option,
    [data-theme="dark"] .filter-category-wrap .ts-dropdown .option {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .ts-dropdown .option:hover,
    [data-theme="dark"] .ts-dropdown .option.active,
    [data-theme="dark"] .filter-category-wrap .ts-dropdown .option:hover,
    [data-theme="dark"] .filter-category-wrap .ts-dropdown .option.active {
        background-color: #1E2D3D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .ts-dropdown .option.selected,
    [data-theme="dark"] .filter-category-wrap .ts-dropdown .option.selected {
        background-color: #FC8019 !important;
        color: #FFFFFF !important;
    }

    /* Dark Mode Pagination Styles */
    [data-theme="dark"] .nl-pagination-wrapper {
        background: #101820 !important;
        border-top: 1px solid #223447 !important;
    }
    [data-theme="dark"] .nl-pagination-info {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .nl-pagination-info strong {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .nl-page-btn {
        background: #151F28 !important;
        border: 1px solid #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .nl-page-btn:hover:not(.disabled):not(.active) {
        background: #1E2D3D !important;
        border-color: #FC8019 !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .nl-page-btn.active {
        background: #FC8019 !important;
        border-color: #FC8019 !important;
        color: #FFFFFF !important;
    }
    [data-theme="dark"] .nl-page-btn.disabled {
        background: #101820 !important;
        border-color: #223447 !important;
        color: #64748B !important;
        opacity: 0.35;
    }
    [data-theme="dark"] .enterprise-table.tracking-table th {
        background-color: #0B1520 !important;
        color: #94A3B8 !important;
        border-bottom-color: #223447 !important;
    }
    [data-theme="dark"] .enterprise-table.tracking-table th.sortable:hover {
        background-color: #151F28 !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .enterprise-table.tracking-table td {
        border-bottom-color: #1E293B !important;
        color: #E2E8F0 !important;
    }
    [data-theme="dark"] .enterprise-table.tracking-table tr:hover td {
        background-color: #101820 !important;
    }
    [data-theme="dark"] .btn-outline-nlog {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #E2E8F0 !important;
    }
    [data-theme="dark"] .btn-outline-nlog:hover {
        background: #1E2D3D !important;
        border-color: #FC8019 !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .category-pill {
        background: #151F28 !important;
        border: 1px solid #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .product-name-txt {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .product-uom-badge {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #94A3B8 !important;
    }

    /* Modal Dark Mode Customization (Add, Edit, Delete) */
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
    [data-theme="dark"] .modal-content-custom .modal-title,
    [data-theme="dark"] .modal-delete-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .modal-badge-icon.add {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FC8019 !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .modal-badge-icon.edit {
        background: rgba(37, 99, 235, 0.16) !important;
        color: #60A5FA !important;
        border: 1px solid rgba(37, 99, 235, 0.3) !important;
    }
    [data-theme="dark"] .modal-delete-icon {
        background: rgba(239, 68, 68, 0.16) !important;
        border: 1px solid rgba(239, 68, 68, 0.35) !important;
        color: #F87171 !important;
    }
    [data-theme="dark"] .modal-content-custom .btn-close {
        filter: invert(1) grayscale(100%) brightness(200%) !important;
        opacity: 0.75 !important;
    }
    [data-theme="dark"] .modal-content-custom .btn-close:hover {
        opacity: 1 !important;
    }
    [data-theme="dark"] .modal-content-custom .form-label {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .modal-content-custom .form-control {
        background-color: #101820 !important;
        border: 1px solid #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .modal-content-custom .form-control:focus {
        background-color: #0D141C !important;
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.22) !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .modal-content-custom .form-control::placeholder {
        color: #64748B !important;
    }
    [data-theme="dark"] .modal-content-custom .btn-light {
        background-color: #1E2D3D !important;
        border: 1px solid #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .modal-content-custom .btn-light:hover {
        background-color: #253749 !important;
        border-color: #3B5066 !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] #deleteProductNameText {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .empty-catalog-icon {
        background: #1E293B !important;
    }
    [data-theme="dark"] .custom-alert.success {
        background: rgba(6, 95, 70, 0.25) !important;
        border-color: #065F46 !important;
        color: #34D399 !important;
    }
    [data-theme="dark"] .custom-alert.danger {
        background: rgba(153, 27, 27, 0.25) !important;
        border-color: #991B1B !important;
        color: #F87171 !important;
    }
    [data-theme="dark"] .custom-alert.warning {
        background: rgba(146, 64, 14, 0.25) !important;
        border-color: #92400E !important;
        color: #FBBF24 !important;
    }
</style>

<div class="container-fluid products-container">
    <!-- Breadcrumb -->
    <div class="custom-breadcrumb">
        <a href="${pageContext.request.contextPath}/inventory/products"><i class="ti ti-packages"></i> Stock &amp; Inventory</a>
        <span class="sep"><i class="ti ti-chevron-right"></i></span>
        <span class="current">Product Catalog</span>
    </div>

    <!-- Frameless Product Header Hero -->
    <div class="product-header-hero">
        <div class="telemetry-header-left">
            <div class="telemetry-icon-box">
                <i class="ti ti-package"></i>
            </div>
            <div>
                <h1 class="telemetry-title">Product Catalog</h1>
                <div class="telemetry-desc">Manage product master data, pricing, inventory valuation, and HSN classifications</div>
            </div>
        </div>
        <div class="telemetry-actions">
            <a href="${pageContext.request.contextPath}/inventory/stock" class="btn btn-outline-nlog"><i class="ti ti-stack-2 me-1"></i> Manage Stock</a>
            <button class="btn btn-register-primary" data-bs-toggle="modal" data-bs-target="#addProductModal" type="button"><i class="ti ti-plus me-1"></i> Add Product</button>
        </div>
    </div>
<!-- Feedback Alerts -->
    <c:if test="${param.success == 'true'}">
        <div class="custom-alert success"><i class="ti ti-circle-check" style="font-size:18px;"></i><span>Product added successfully!</span><button type="button" class="alert-close-btn" onclick="dismissCustomAlert(this.parentElement)" title="Close">&times;</button></div>
    </c:if>
    <c:if test="${param.success == 'updated'}">
        <div class="custom-alert success"><i class="ti ti-circle-check" style="font-size:18px;"></i><span>Product updated successfully!</span><button type="button" class="alert-close-btn" onclick="dismissCustomAlert(this.parentElement)" title="Close">&times;</button></div>
    </c:if>
    <c:if test="${param.success == 'deleted'}">
        <div class="custom-alert success"><i class="ti ti-circle-check" style="font-size:18px;"></i><span>Product deleted successfully!</span><button type="button" class="alert-close-btn" onclick="dismissCustomAlert(this.parentElement)" title="Close">&times;</button></div>
    </c:if>
    <c:if test="${param.error == 'true'}">
        <div class="custom-alert danger"><i class="ti ti-circle-x" style="font-size:18px;"></i><span>Failed to add product!</span><button type="button" class="alert-close-btn" onclick="dismissCustomAlert(this.parentElement)" title="Close">&times;</button></div>
    </c:if>
    <c:if test="${param.error == 'delete_failed'}">
        <div class="custom-alert danger"><i class="ti ti-circle-x" style="font-size:18px;"></i><span>Failed to delete product! (It is referenced by active stock, inventory ledger, or sales records.)</span><button type="button" class="alert-close-btn" onclick="dismissCustomAlert(this.parentElement)" title="Close">&times;</button></div>
    </c:if>
    <c:if test="${param.error == 'negative_values'}">
        <div class="custom-alert warning"><i class="ti ti-alert-triangle" style="font-size:18px;"></i><span>Unit Cost and Unit Price must not be negative!</span><button type="button" class="alert-close-btn" onclick="dismissCustomAlert(this.parentElement)" title="Close">&times;</button></div>
    </c:if>
    <c:if test="${param.error == 'invalid_input'}">
        <div class="custom-alert danger"><i class="ti ti-circle-x" style="font-size:18px;"></i><span>Invalid input provided. Please check the form and try again.</span><button type="button" class="alert-close-btn" onclick="dismissCustomAlert(this.parentElement)" title="Close">&times;</button></div>
    </c:if>

    <!-- KPI Summary Grid -->
    <div class="kpi-grid">
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Total Products</div>
                <div class="kpi-value" id="kpiTotalProductsVal">${not empty kpiTotalProducts ? kpiTotalProducts : fn:length(products)}</div>
            </div>
            <div class="kpi-icon-pill orange"><i class="ti ti-package"></i></div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Categories</div>
                <div class="kpi-value" id="kpiTotalCategoriesVal" style="color:#2563EB;">${not empty kpiTotalCategories ? kpiTotalCategories : fn:length(categoriesSet)}</div>
            </div>
            <div class="kpi-icon-pill blue"><i class="ti ti-category"></i></div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Catalog Price Value</div>
                <div class="kpi-value" id="kpiTotalValueVal" style="color:#059669;">$<fmt:formatNumber type="number" groupingUsed="true" minFractionDigits="2" maxFractionDigits="2" value="${kpiTotalValue}"/></div>
            </div>
            <div class="kpi-icon-pill green"><i class="ti ti-currency-dollar"></i></div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Total Unit Cost</div>
                <div class="kpi-value" id="kpiTotalCostVal" style="color:#D97706;">$<fmt:formatNumber type="number" groupingUsed="true" minFractionDigits="2" maxFractionDigits="2" value="${kpiTotalCost}"/></div>
            </div>
            <div class="kpi-icon-pill amber"><i class="ti ti-receipt"></i></div>
        </div>
    </div>

    <!-- Search & Category Filter Bar (Compact Single Line) -->
    <div class="filter-bar-card">
        <div class="filter-bar-inner">
            <div class="filter-search-box">
                <i class="ti ti-search search-icon"></i>
                <input type="text" id="productSearchInput" placeholder="Search product name, category, HSN code...">
                <button type="button" id="clearProductSearchBtn" class="search-clear-btn" title="Clear Search">&times;</button>
            </div>
            <div class="filter-category-wrap">
                <select id="categoryFilterSelect" class="form-select-custom no-custom-select filter-category-select">
                    <option value="">All Categories (${not empty categoriesSet ? fn:length(categoriesSet) : 10})</option>
                    <c:forEach var="cat" items="${categoriesSet}">
                        <option value="${fn:toLowerCase(cat)}">${cat}</option>
                    </c:forEach>
                </select>
            </div>
        </div>
    </div>

    <!-- Product Table Panel -->
    <div class="product-table-panel">
        <div class="table-responsive">
            <table class="enterprise-table tracking-table" id="productsTable">
                <thead>
                    <tr>
                        <th class="sortable" style="width: 100px;" onclick="sortProductsTable(0)"><i class="ti ti-hash"></i>ID <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                        <th class="sortable" onclick="sortProductsTable(1)"><i class="ti ti-tag"></i>Product Name <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                        <th class="sortable" onclick="sortProductsTable(2)"><i class="ti ti-category"></i>Category <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                        <th class="sortable" onclick="sortProductsTable(3)"><i class="ti ti-file-certificate"></i>HSN Code <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                        <th class="sortable" onclick="sortProductsTable(4)"><i class="ti ti-ruler-2"></i>UOM <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                        <th class="sortable" onclick="sortProductsTable(5)"><i class="ti ti-coin"></i>Unit Cost <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                        <th class="sortable" onclick="sortProductsTable(6)"><i class="ti ti-currency-dollar"></i>Unit Price <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                        <th style="text-align:center; width: 180px;"><i class="ti ti-settings"></i>Action</th>
                    </tr>
                </thead>
                <tbody id="productsTbody">
                    <c:forEach var="p" items="${products}">
                        <tr class="product-row" 
                            data-search="${fn:toLowerCase(p.productName)} ${fn:toLowerCase(p.category)} ${fn:toLowerCase(p.hsnCode)}"
                            data-category="${fn:toLowerCase(p.category)}">
                            <td class="product-id-chip">#${p.productId}</td>
                            <td><strong class="product-name-txt">${p.productName}</strong></td>
                            <td><span class="category-pill"><i class="ti ti-tag" style="font-size: 11px;"></i> ${p.category}</span></td>
                            <td style="font-family: monospace; font-size: 12.5px;">${p.hsnCode}</td>
                            <td><span class="product-uom-badge">${p.unitOfMeasure}</span></td>
                            <td class="cost-value">$<fmt:formatNumber value="${p.unitCost}" minFractionDigits="2" maxFractionDigits="2"/></td>
                            <td><strong class="price-value">$<fmt:formatNumber value="${p.unitPrice}" minFractionDigits="2" maxFractionDigits="2"/></strong></td>
                            <td>
                                <div class="actions-flex">
                                    <button type="button" class="btn-action-edit btn-edit-product"
                                            data-id="${p.productId}"
                                            data-name="<c:out value='${p.productName}'/>"
                                            data-category="<c:out value='${p.category}'/>"
                                            data-hsn="<c:out value='${p.hsnCode}'/>"
                                            data-uom="<c:out value='${p.unitOfMeasure}'/>"
                                            data-cost="${p.unitCost}"
                                            data-price="${p.unitPrice}"
                                            title="Edit Product">
                                        <i class="ti ti-edit"></i> Edit
                                    </button>
                                    <button type="button" class="btn-action-delete btn-delete-product"
                                            data-id="${p.productId}"
                                            data-name="<c:out value='${p.productName}'/>"
                                            title="Delete Product">
                                        <i class="ti ti-trash"></i> Delete
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <c:if test="${empty products}">
            <div class="empty-catalog-box">
                <div class="empty-catalog-icon"><i class="ti ti-package-off"></i></div>
                <h5 style="font-weight:700; color:#1F2937;">No Products Found</h5>
                <p style="color:#94A3B8; font-size:13.5px;">Get started by adding your first product to the catalog.</p>
            </div>
        </c:if>

        <div id="noProductResults" class="empty-catalog-box d-none">
            <div class="empty-catalog-icon"><i class="ti ti-search-off"></i></div>
            <h5 style="font-weight:700; color:#1F2937;">No Matching Products</h5>
            <p style="color:#94A3B8; font-size:13.5px;">No products matching your search or category filter criteria.</p>
        </div>

        <!-- Global Enterprise Circular Pagination -->
        <div class="nl-pagination-wrapper" id="paginationFooter">
            <div class="nl-pagination-info">
                <span>Showing <strong id="pageStart">1</strong> to <strong id="pageEnd">10</strong> of <strong id="totalRecords">${kpiTotalProducts}</strong> products</span>
                <div class="d-inline-flex align-items-center gap-2 ms-2">
                    <span class="text-muted small">Show:</span>
                    <select id="pageSizeSelect" class="nl-page-size-select">
                        <option value="10" selected>10</option>
                        <option value="25">25</option>
                        <option value="50">50</option>
                        <option value="100">100</option>
                    </select>
                </div>
            </div>
            <div class="nl-pagination-nav" id="paginationNav"></div>
        </div>
    </div>
</div>

<!-- Add Product Modal -->
<div class="modal fade" id="addProductModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content modal-content-custom">
            <form action="${pageContext.request.contextPath}/inventory/product/add" method="POST">
                <div class="modal-header modal-header-custom">
                    <div class="d-flex align-items-center gap-2">
                        <div class="modal-badge-icon add">
                            <i class="ti ti-plus"></i>
                        </div>
                        <h5 class="modal-title mb-0" style="font-weight:700; font-size:16px;">Add New Product</h5>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label" style="font-weight:600; font-size:13px;">Product Name <span style="color:#FC8019;">*</span></label>
                        <input type="text" class="form-control" name="productName" required placeholder="e.g. Industrial Ball Bearings" style="border-radius:50px !important; font-size:13.5px;">
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Category <span style="color:#FC8019;">*</span></label>
                            <input type="text" class="form-control" name="category" required placeholder="e.g. Machinery" style="border-radius:50px !important; font-size:13.5px;">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">HSN Code <span style="color:#FC8019;">*</span></label>
                            <input type="text" class="form-control" name="hsnCode" required placeholder="e.g. 8482.10" style="border-radius:50px !important; font-size:13.5px;">
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">UOM <span style="color:#FC8019;">*</span></label>
                            <input type="text" class="form-control" name="unitOfMeasure" required placeholder="box, kg, pcs" style="border-radius:50px !important; font-size:13.5px;">
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Unit Cost ($) <span style="color:#FC8019;">*</span></label>
                            <input type="number" step="0.01" min="0" class="form-control" name="unitCost" required placeholder="0.00" style="border-radius:50px !important; font-size:13.5px;">
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Unit Price ($) <span style="color:#FC8019;">*</span></label>
                            <input type="number" step="0.01" min="0" class="form-control" name="unitPrice" required placeholder="0.00" style="border-radius:50px !important; font-size:13.5px;">
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-top-0 pt-0 px-4 pb-4">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius:50px !important; font-weight:500;">Cancel</button>
                    <button type="submit" class="modal-btn-submit">Add Product</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Edit Product Modal -->
<div class="modal fade" id="editProductModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content modal-content-custom">
            <form action="${pageContext.request.contextPath}/inventory/product/update" method="POST">
                <input type="hidden" name="productId" id="editProductId">
                <div class="modal-header modal-header-custom">
                    <div class="d-flex align-items-center gap-2">
                        <div class="modal-badge-icon edit">
                            <i class="ti ti-edit"></i>
                        </div>
                        <h5 class="modal-title mb-0" style="font-weight:700; font-size:16px;">Edit Product</h5>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label" style="font-weight:600; font-size:13px;">Product Name <span style="color:#FC8019;">*</span></label>
                        <input type="text" class="form-control" name="productName" id="editProductName" required style="border-radius:50px !important; font-size:13.5px;">
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Category <span style="color:#FC8019;">*</span></label>
                            <input type="text" class="form-control" name="category" id="editCategory" required style="border-radius:50px !important; font-size:13.5px;">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">HSN Code <span style="color:#FC8019;">*</span></label>
                            <input type="text" class="form-control" name="hsnCode" id="editHsnCode" required style="border-radius:50px !important; font-size:13.5px;">
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">UOM <span style="color:#FC8019;">*</span></label>
                            <input type="text" class="form-control" name="unitOfMeasure" id="editUnitOfMeasure" required style="border-radius:50px !important; font-size:13.5px;">
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Unit Cost ($) <span style="color:#FC8019;">*</span></label>
                            <input type="number" step="0.01" min="0" class="form-control" name="unitCost" id="editUnitCost" required style="border-radius:50px !important; font-size:13.5px;">
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Unit Price ($) <span style="color:#FC8019;">*</span></label>
                            <input type="number" step="0.01" min="0" class="form-control" name="unitPrice" id="editUnitPrice" required style="border-radius:50px !important; font-size:13.5px;">
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-top-0 pt-0 px-4 pb-4">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius:50px !important; font-weight:500;">Cancel</button>
                    <button type="submit" class="modal-btn-submit">Update Product</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Delete Product Confirmation Modal -->
<div class="modal fade" id="deleteProductModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content modal-content-custom">
            <form action="${pageContext.request.contextPath}/inventory/product/delete" method="POST">
                <input type="hidden" name="productId" id="deleteProductId">
                <div class="modal-body text-center py-4">
                    <div class="modal-delete-icon">
                        <i class="ti ti-trash"></i>
                    </div>
                    <p class="mb-1 fs-5 modal-delete-title">Delete this product?</p>
                    <p class="text-muted fw-bold mb-0" id="deleteProductNameText"></p>
                    <small class="text-danger mt-2 d-block">This action cannot be undone.</small>
                </div>
                <div class="modal-footer border-top-0 pt-0 px-4 pb-4 justify-content-center">
                    <button type="button" class="btn btn-light px-4" data-bs-dismiss="modal" style="border-radius:50px !important; font-weight:500;">Cancel</button>
                    <button type="submit" class="modal-btn-danger px-4">Delete Product</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Interactive JS: Edit/Delete modals + Search + Category Filter + Client-side Pagination -->
<script>
document.addEventListener('DOMContentLoaded', function() {
    // 1. Modals setup
    var editModalEl = document.getElementById('editProductModal');
    var editModal = editModalEl ? new bootstrap.Modal(editModalEl) : null;

    document.querySelectorAll('.btn-edit-product').forEach(function(btn) {
        btn.addEventListener('click', function() {
            document.getElementById('editProductId').value = this.dataset.id;
            document.getElementById('editProductName').value = this.dataset.name;
            document.getElementById('editCategory').value = this.dataset.category;
            document.getElementById('editHsnCode').value = this.dataset.hsn;
            document.getElementById('editUnitOfMeasure').value = this.dataset.uom;
            document.getElementById('editUnitCost').value = this.dataset.cost;
            document.getElementById('editUnitPrice').value = this.dataset.price;
            if (editModal) editModal.show();
        });
    });

    var deleteModalEl = document.getElementById('deleteProductModal');
    var deleteModal = deleteModalEl ? new bootstrap.Modal(deleteModalEl) : null;

    document.querySelectorAll('.btn-delete-product').forEach(function(btn) {
        btn.addEventListener('click', function() {
            document.getElementById('deleteProductId').value = this.dataset.id;
            document.getElementById('deleteProductNameText').textContent = this.dataset.name + ' (#' + this.dataset.id + ')';
            if (deleteModal) deleteModal.show();
        });
    });

    // 2. Pagination & Search Logic
    // 2. Pagination & Search Logic
    var allRows = Array.from(document.querySelectorAll('#productsTbody .product-row'));
    var filteredRows = allRows.slice();
    var currentPage = 1;
    var pageSize = 10;

    var searchInput = document.getElementById('productSearchInput');
    var clearBtn = document.getElementById('clearProductSearchBtn');
    var categorySelect = document.getElementById('categoryFilterSelect');
    var noResultsEl = document.getElementById('noProductResults');
    var paginationFooter = document.getElementById('paginationFooter');
    var pageSizeSelect = document.getElementById('pageSizeSelect');

    // 3. Fallback only if KPI values are completely empty
    var prodValEl = document.getElementById('kpiTotalProductsVal');
    var catValEl = document.getElementById('kpiTotalCategoriesVal');
    var priceValEl = document.getElementById('kpiTotalValueVal');
    var costValEl = document.getElementById('kpiTotalCostVal');

    var totalProdCount = allRows.length;
    if (prodValEl && (!prodValEl.textContent.trim() || prodValEl.textContent.trim() === '0')) {
        prodValEl.textContent = totalProdCount;
    }

    var uniqueCatsMap = {};
    allRows.forEach(function(row) {
        var catVal = (row.dataset.category || '').trim();
        var pill = row.querySelector('.category-pill');
        var dispText = pill ? pill.textContent.trim() : catVal;
        if (catVal && !uniqueCatsMap[catVal.toLowerCase()]) {
            uniqueCatsMap[catVal.toLowerCase()] = dispText;
        }
    });

    var numUniqueCats = Object.keys(uniqueCatsMap).length;
    if (catValEl && (!catValEl.textContent.trim() || catValEl.textContent.trim() === '0')) {
        catValEl.textContent = numUniqueCats;
    }

    // 4. Populate category filter options if empty or missing
    if (categorySelect && categorySelect.options.length <= 1 && numUniqueCats > 0) {
        var sortedCatKeys = Object.keys(uniqueCatsMap).sort(function(a, b) {
            return uniqueCatsMap[a].localeCompare(uniqueCatsMap[b]);
        });
        categorySelect.innerHTML = '<option value="">All Categories (' + numUniqueCats + ')</option>';
        sortedCatKeys.forEach(function(k) {
            var opt = document.createElement('option');
            opt.value = k;
            opt.textContent = uniqueCatsMap[k];
            categorySelect.appendChild(opt);
        });
    } else if (categorySelect && categorySelect.options.length > 1) {
        if (categorySelect.options[0].textContent.indexOf('(') === -1 && numUniqueCats > 0) {
            categorySelect.options[0].textContent = 'All Categories (' + numUniqueCats + ')';
        }
    }

    function applyFilters() {
        var query = searchInput ? searchInput.value.toLowerCase().trim() : '';
        var selectedCat = categorySelect ? categorySelect.value.toLowerCase().trim() : '';

        if (clearBtn) {
            clearBtn.style.display = query ? 'block' : 'none';
        }

        filteredRows = allRows.filter(function(row) {
            var searchTxt = (row.dataset.search || '').toLowerCase();
            var rowCat = (row.dataset.category || '').toLowerCase();
            var matchesQuery = !query || searchTxt.indexOf(query) !== -1;
            var matchesCat = !selectedCat || rowCat === selectedCat;
            return matchesQuery && matchesCat;
        });

        currentPage = 1;
        renderTable();
    }

    function renderTable() {
        var total = filteredRows.length;
        var totalPages = Math.ceil(total / pageSize) || 1;
        if (currentPage > totalPages) currentPage = totalPages;

        var startIdx = (currentPage - 1) * pageSize;
        var endIdx = Math.min(startIdx + pageSize, total);

        // Hide all rows first
        allRows.forEach(function(r) { r.style.display = 'none'; });

        // Show current page of filtered rows
        for (var i = startIdx; i < endIdx; i++) {
            filteredRows[i].style.display = '';
        }

        var startEl = document.getElementById('pageStart');
        var endEl = document.getElementById('pageEnd');
        var totalEl = document.getElementById('totalRecords');
        if (startEl) startEl.textContent = total === 0 ? 0 : (startIdx + 1);
        if (endEl) endEl.textContent = endIdx;
        if (totalEl) totalEl.textContent = total;

        // Toggle No Results
        if (noResultsEl) {
            noResultsEl.classList.toggle('d-none', total > 0);
        }
        if (paginationFooter) {
            paginationFooter.style.display = total > 0 ? 'flex' : 'none';
        }

        renderPaginationControls(totalPages);
    }

    // Client-side Sorting
    var prodSortCol = -1;
    var prodSortAsc = true;
    window.sortProductsTable = function(colIndex) {
        if (prodSortCol === colIndex) prodSortAsc = !prodSortAsc;
        else { prodSortCol = colIndex; prodSortAsc = true; }
        filteredRows.sort(function(a, b) {
            var cellA = a.cells[colIndex] ? a.cells[colIndex].innerText.trim() : '';
            var cellB = b.cells[colIndex] ? b.cells[colIndex].innerText.trim() : '';
            var numA = parseFloat(cellA.replace(/[^0-9.-]+/g, ''));
            var numB = parseFloat(cellB.replace(/[^0-9.-]+/g, ''));
            if (!isNaN(numA) && !isNaN(numB)) return prodSortAsc ? numA - numB : numB - numA;
            return prodSortAsc ? cellA.localeCompare(cellB) : cellB.localeCompare(cellA);
        });
        var tbody = document.getElementById('productsTbody');
        filteredRows.forEach(function(row) { tbody.appendChild(row); });
        renderTable();
    };

    function renderPaginationControls(totalPages) {
        var nav = document.getElementById('paginationNav');
        if (!nav) return;
        nav.innerHTML = '';

        if (totalPages <= 1) return;

        // Prev Button
        var prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'nl-page-btn nl-page-nav-btn' + (currentPage === 1 ? ' disabled' : '');
        prevBtn.disabled = (currentPage === 1);
        prevBtn.innerHTML = '<i class="ti ti-chevron-left"></i>';
        prevBtn.addEventListener('click', function() {
            if (currentPage > 1) {
                currentPage--;
                renderTable();
            }
        });
        nav.appendChild(prevBtn);

        function addBtn(pageNum) {
            var btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'nl-page-btn nl-page-num' + (pageNum === currentPage ? ' active' : '');
            btn.textContent = pageNum;
            btn.addEventListener('click', function() {
                currentPage = pageNum;
                renderTable();
            });
            nav.appendChild(btn);
        }

        function addDots() {
            var dots = document.createElement('span');
            dots.className = 'nl-page-btn disabled';
            dots.textContent = '...';
            dots.style.border = 'none';
            dots.style.background = 'transparent';
            nav.appendChild(dots);
        }

        if (totalPages <= 7) {
            for (var p = 1; p <= totalPages; p++) {
                addBtn(p);
            }
        } else {
            addBtn(1);
            if (currentPage > 4) {
                addDots();
            }
            var start = Math.max(2, currentPage - 1);
            var end = Math.min(totalPages - 1, currentPage + 1);
            if (currentPage <= 4) {
                start = 2;
                end = 4;
            } else if (currentPage >= totalPages - 3) {
                start = totalPages - 3;
                end = totalPages - 1;
            }
            for (var i = start; i <= end; i++) {
                addBtn(i);
            }
            if (currentPage < totalPages - 3) {
                addDots();
            }
            addBtn(totalPages);
        }

        // Next Button
        var nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'nl-page-btn nl-page-nav-btn' + (currentPage === totalPages ? ' disabled' : '');
        nextBtn.disabled = (currentPage === totalPages);
        nextBtn.innerHTML = '<i class="ti ti-chevron-right"></i>';
        nextBtn.addEventListener('click', function() {
            if (currentPage < totalPages) {
                currentPage++;
                renderTable();
            }
        });
        nav.appendChild(nextBtn);
    }

    if (searchInput) searchInput.addEventListener('input', applyFilters);
    if (clearBtn) clearBtn.addEventListener('click', function() {
        searchInput.value = '';
        applyFilters();
    });
    if (categorySelect) {
        categorySelect.addEventListener('change', applyFilters);
        if (categorySelect.tomselect) {
            categorySelect.tomselect.on('change', applyFilters);
        } else {
            setTimeout(function() {
                if (categorySelect.tomselect) {
                    categorySelect.tomselect.on('change', applyFilters);
                }
            }, 300);
        }
    }
    if (pageSizeSelect) pageSizeSelect.addEventListener('change', function() {
        pageSize = parseInt(this.value) || 10;
        currentPage = 1;
        renderTable();
    });

    renderTable();

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

    // Auto-dismiss feedback alert toasts after 5 seconds of appearing
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
