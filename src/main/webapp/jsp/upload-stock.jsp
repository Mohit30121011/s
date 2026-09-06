<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    :root {
        --nlog-orange: #FC8019;
        --nlog-orange-hover: #E67012;
        --nlog-light-orange: #FFF0E5;
        --nlog-green: #10b981;
        --nlog-purple: #8b5cf6;
        --nlog-yellow: #f59e0b;
        --card-radius: 14px;
    }

    .page-title { font-weight: 700; color: #0F172A; font-size: 24px; }
    .breadcrumb-text { font-size: 13px; color: #64748b; }

    /* Frameless Stock Header Hero */
    .stock-header-hero,
    .telemetry-header-card {
        background: transparent !important;
        background-color: transparent !important;
        border: none !important;
        box-shadow: none !important;
        padding: 0 !important;
        margin-bottom: 24px;
        display: flex;
        align-items: center;
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

    .stat-card {
        background: #fff;
        border-radius: var(--card-radius);
        padding: 20px;
        display: flex;
        align-items: center;
        border: 1px solid #E2E8F0;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03);
        transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
    }
    .stat-card:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,0,0,0.06); border-color: #CBD5E1; }

    .stat-icon {
        width: 48px;
        height: 48px;
        border-radius: 50% !important;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 22px;
        margin-right: 16px;
        flex-shrink: 0;
    }
    .stat-icon.orange { background: var(--nlog-light-orange); color: var(--nlog-orange); }
    .stat-icon.green { background: #ecfdf5; color: var(--nlog-green); }
    .stat-icon.purple { background: #f5f3ff; color: var(--nlog-purple); }
    .stat-icon.yellow { background: #fffbeb; color: #D97706; }

    .stat-value { font-size: 24px; font-weight: 700; color: #0f172a; margin-bottom: 2px; }
    .stat-label { font-size: 13px; color: #64748b; }

    .nav-tabs-custom {
        display: flex; align-items: center; gap: 8px; background: #F8FAFC; padding: 5px;
        border-radius: 50px !important; border: 1px solid #E2E8F0; margin-bottom: 24px; width: fit-content; flex-wrap: wrap;
    }
    .nav-tabs-custom .nav-link {
        background: transparent; border: none; padding: 8px 22px; border-radius: 50px !important; font-size: 13px; font-weight: 600;
        color: #64748B; cursor: pointer; transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); display: flex; align-items: center;
    }
    .nav-tabs-custom .nav-link:hover { color: #0F172A; }
    .nav-tabs-custom .nav-link.active {
        background: #FFFFFF; color: var(--nlog-orange); box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08); border-bottom: none;
    }

    .btn-nlog {
        background-color: var(--nlog-orange);
        color: white;
        font-weight: 600;
        border: none;
        border-radius: 50px !important;
        padding: 10px 24px;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25);
        transition: all 0.18s ease;
    }
    .btn-nlog:hover {
        background-color: var(--nlog-orange-hover);
        color: white;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.35);
    }

    .btn-outline-nlog {
        border: 1.5px solid #cbd5e1;
        color: #475569;
        background: white;
        font-weight: 600;
        border-radius: 50px !important;
        padding: 10px 22px;
        transition: all 0.18s ease;
        display: inline-flex;
        align-items: center;
        text-decoration: none;
    }
    .btn-outline-nlog:hover { background: #f8fafc; border-color: #CBD5E1; color: #0F172A; }

    /* Drag & Drop */
    .upload-dropzone {
        border: 2px dashed #cbd5e1;
        border-radius: 16px;
        background-color: #f8fafc;
        padding: 50px 30px;
        text-align: center;
        transition: all 0.3s ease;
        cursor: pointer;
    }
    .upload-dropzone.dragover { border-color: var(--nlog-orange); background-color: var(--nlog-light-orange); }
    .upload-dropzone i { font-size: 44px; color: #94a3b8; margin-bottom: 14px; transition: color 0.3s ease; }
    .upload-dropzone.dragover i { color: var(--nlog-orange); }

    .form-control, .form-select, .form-select-custom {
        border-color: #e2e8f0;
        padding: 10px 16px;
        border-radius: 50px !important;
        font-size: 13.5px;
    }
    textarea.form-control {
        border-radius: 14px !important;
    }
    .form-control:focus, .form-select:focus, .form-select-custom:focus {
        border-color: var(--nlog-orange);
        box-shadow: 0 0 0 0.2rem rgba(252, 128, 25, 0.15);
    }
    .form-label { font-size: 13px; font-weight: 600; color: #334155; }
    .required-asterisk { color: var(--nlog-orange); }

    .badge-success-custom { background-color: #ecfdf5; color: #059669; padding: 5px 14px; border-radius: 50px !important; font-size: 12px; font-weight: 600; border: 1px solid #A7F3D0; display: inline-flex; align-items: center; }
    .badge-failed-custom { background-color: #fef2f2; color: #DC2626; padding: 5px 14px; border-radius: 50px !important; font-size: 12px; font-weight: 600; border: 1px solid #FECACA; display: inline-flex; align-items: center; }
    .badge-warning-custom { background-color: #fffbeb; color: #D97706; padding: 5px 14px; border-radius: 50px !important; font-size: 12px; font-weight: 600; border: 1px solid #FDE68A; display: inline-flex; align-items: center; }
    .badge-company-custom { background-color: #F1F5F9; color: #475569; padding: 4px 12px; border-radius: 50px !important; font-size: 11.5px; font-weight: 600; display: inline-flex; align-items: center; }

    /* Select wrapper (design system) */
    .select-wrapper { position: relative; width: 100%; }
    .select-wrapper::after {
        content: ''; position: absolute; right: 16px; top: 50%; transform: translateY(-50%); width: 14px; height: 14px;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2364748B' stroke-width='2.2'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E");
        background-size: contain; background-repeat: no-repeat; pointer-events: none;
    }
    .select-wrapper select { appearance: none; -webkit-appearance: none; padding-right: 42px !important; border-radius: 50px !important; }

    /* Table Toolbar */
    .table-toolbar {
        display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;
        padding: 14px 20px; background: #F8FAFC; border-bottom: 1px solid #E2E8F0; border-top-left-radius: var(--card-radius); border-top-right-radius: var(--card-radius);
    }
    .search-input-box { position: relative; min-width: 240px; max-width: 340px; }
    .search-input-box i { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #94A3B8; font-size: 15px; }
    .search-input-box input { padding-left: 40px !important; height: 40px; font-size: 13px; border-radius: 50px !important; border: 1px solid #CBD5E1; width: 100%; }
    .search-input-box input:focus { border-color: var(--nlog-orange); outline: none; box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.15); }

    /* Enterprise Table Architecture */
    .enterprise-table.tracking-table {
        width: 100%;
        border-collapse: collapse;
        margin: 0;
    }
    .enterprise-table.tracking-table th {
        background-color: #F8FAFC;
        padding: 14px 18px;
        font-size: 11.5px;
        font-weight: 700;
        color: #64748B;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border-bottom: 1px solid #E2E8F0;
        white-space: nowrap;
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
        padding: 14px 18px;
        border-bottom: 1px solid #F1F5F9;
        vertical-align: middle;
        font-size: 13.5px;
    }
    .enterprise-table.tracking-table tr:hover td {
        background-color: #F8FAFC;
    }

    /* Modals & Buttons Pill Geometry */
    .modal-content { border-radius: 16px !important; overflow: hidden; }
    .btn-close { border-radius: 50% !important; }

    /* Hide Export/Fullscreen Card Tools Everywhere on this Page */
    .nl-card-tools,
    .no-card-tools .nl-card-tools,
    [data-no-tools="true"] .nl-card-tools,
    .nl-card-tools-floating {
        display: none !important;
    }

    /* Base Target Company Box & Toolbar */
    .stock-page-container {
        background: transparent !important;
    }
    .stock-target-company-box {
        background: #F8FAFC;
        border-radius: 12px;
        border: 1px solid #E2E8F0;
        padding: 16px;
    }
    .stock-toolbar-wrap {
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 12px;
    }
    .stock-filter-label {
        color: #475569;
        font-weight: 600;
        font-size: 13px;
    }
    .stock-company-picker-wrap {
        position: relative;
        min-width: 290px;
    }
    .stock-select-search-icon {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #94A3B8;
        font-size: 14px;
        pointer-events: none;
        z-index: 6;
        transition: color 0.15s ease;
    }
    .stock-company-picker-wrap:focus-within .stock-select-search-icon {
        color: #FC8019;
    }
    .stock-company-picker-wrap .ts-wrapper.single .ts-control {
        padding-left: 36px !important;
        border-radius: 50px !important;
        font-size: 13px !important;
        font-weight: 500;
    }

    /* Restock Button Base & Hover */
    .btn-restock-action {
        background: #FFF0E5;
        color: #FC8019 !important;
        border: 1px solid #FC8019;
        border-radius: 50px !important;
        font-weight: 600;
        font-size: 12px;
        padding: 5px 14px;
        display: inline-flex;
        align-items: center;
        gap: 4px;
        cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        text-decoration: none;
    }
    .btn-restock-action:hover {
        background: #FC8019;
        color: #FFFFFF !important;
        transform: translateY(-1px);
        box-shadow: 0 4px 10px rgba(252, 128, 25, 0.28);
    }

    /* Dark Mode Design Standards */
    [data-theme="dark"] .container-fluid,
    [data-theme="dark"] .stock-page-container,
    [data-theme="dark"] .stock-header-hero,
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
    [data-theme="dark"] .telemetry-desc {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .stat-card,
    [data-theme="dark"] .card {
        background: #101820 !important;
        border: 1px solid #223447 !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .card-body {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .stat-value {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .stat-label {
        color: #94A3B8 !important;
    }

    /* KPI Circular Icons in Dark Mode */
    [data-theme="dark"] .stat-icon.orange {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FC8019 !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .stat-icon.green {
        background: rgba(16, 185, 129, 0.16) !important;
        color: #34D399 !important;
        border: 1px solid rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .stat-icon.purple {
        background: rgba(139, 92, 246, 0.16) !important;
        color: #A78BFA !important;
        border: 1px solid rgba(139, 92, 246, 0.3) !important;
    }
    [data-theme="dark"] .stat-icon.yellow {
        background: rgba(245, 158, 11, 0.16) !important;
        color: #FBBF24 !important;
        border: 1px solid rgba(245, 158, 11, 0.3) !important;
    }

    /* Toolbar & Navigation Tabs in Dark Mode */
    [data-theme="dark"] .nav-tabs-custom {
        background: #101820 !important;
        border-color: #223447 !important;
    }
    [data-theme="dark"] .nav-tabs-custom .nav-link {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .nav-tabs-custom .nav-link:hover {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .nav-tabs-custom .nav-link.active {
        background: #1E293B !important;
        color: #FC8019 !important;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3) !important;
    }
    [data-theme="dark"] .stock-filter-label {
        color: #CBD5E1 !important;
    }

    /* Target Company Box in Bulk & Manual Upload */
    [data-theme="dark"] .stock-target-company-box {
        background-color: #101820 !important;
        border-color: #223447 !important;
        color: #F8FAFC !important;
    }

    /* Dropzone in Dark Mode */
    [data-theme="dark"] .upload-dropzone {
        background-color: #101820 !important;
        border-color: #2D3F4D !important;
    }
    [data-theme="dark"] .upload-dropzone:hover,
    [data-theme="dark"] .upload-dropzone.dragover {
        border-color: #FC8019 !important;
        background-color: rgba(252, 128, 25, 0.08) !important;
    }
    [data-theme="dark"] .upload-dropzone i {
        color: #FC8019 !important;
    }
    [data-theme="dark"] .upload-dropzone h5 {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .upload-dropzone p {
        color: #94A3B8 !important;
    }

    /* Form Controls, Inputs & Selects in Dark Mode */
    [data-theme="dark"] .form-control,
    [data-theme="dark"] .form-select,
    [data-theme="dark"] .form-select-custom,
    [data-theme="dark"] .stock-company-select,
    [data-theme="dark"] .nl-page-size-select {
        background-color: #101820 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .form-control:focus,
    [data-theme="dark"] .form-select:focus,
    [data-theme="dark"] .form-select-custom:focus,
    [data-theme="dark"] .stock-company-select:focus {
        background-color: #101820 !important;
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.22) !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .form-control::placeholder {
        color: #64748B !important;
    }
    [data-theme="dark"] .form-label {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .input-group-text {
        background-color: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #FC8019 !important;
        font-weight: 600;
    }
    [data-theme="dark"] .text-dark {
        color: #F8FAFC !important;
    }

    /* TomSelect Custom Dropdown in Dark Mode */
    [data-theme="dark"] .select-wrapper .ts-wrapper.single .ts-control {
        background-color: #101820 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .select-wrapper .ts-wrapper.single .ts-control .item {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .select-wrapper .ts-wrapper.single .ts-control input {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .select-wrapper .ts-dropdown {
        background-color: #151F28 !important;
        border-color: #2D3F4D !important;
    }
    [data-theme="dark"] .select-wrapper .ts-dropdown .option {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .select-wrapper .ts-dropdown .option:hover,
    [data-theme="dark"] .select-wrapper .ts-dropdown .option.active {
        background-color: rgba(252, 128, 25, 0.15) !important;
        color: #FC8019 !important;
    }

    /* Buttons & Modals in Dark Mode */
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
    [data-theme="dark"] .modal-content {
        background-color: #151F28 !important;
        border-color: #223447 !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .btn-restock-action {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FC8019 !important;
        border: 1px solid rgba(252, 128, 25, 0.35) !important;
    }
    [data-theme="dark"] .btn-restock-action:hover {
        background: #FC8019 !important;
        color: #FFFFFF !important;
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.38) !important;
    }

    /* Tables & Toolbars in Dark Mode */
    [data-theme="dark"] .enterprise-table.tracking-table th,
    [data-theme="dark"] #lowStockTable th {
        background-color: #0B1520 !important;
        color: #94A3B8 !important;
        border-bottom-color: #223447 !important;
    }
    [data-theme="dark"] .enterprise-table.tracking-table th.sortable:hover {
        background-color: #151F28 !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .enterprise-table.tracking-table td,
    [data-theme="dark"] #lowStockTable td {
        border-bottom-color: #1E293B !important;
        color: #E2E8F0 !important;
    }
    [data-theme="dark"] .enterprise-table.tracking-table tr:hover td,
    [data-theme="dark"] #lowStockTable tr:hover td {
        background-color: #101820 !important;
    }
    [data-theme="dark"] .table-toolbar {
        background: #101820 !important;
        border-color: #223447 !important;
    }
    [data-theme="dark"] .search-input-box input {
        background-color: #101820 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }

    /* Badges in Dark Mode */
    [data-theme="dark"] .badge-company-custom {
        background: #1E293B !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .badge-success-custom {
        background: rgba(16, 185, 129, 0.15) !important;
        color: #34D399 !important;
        border-color: rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .badge-failed-custom {
        background: rgba(239, 68, 68, 0.15) !important;
        color: #F87171 !important;
        border-color: rgba(239, 68, 68, 0.3) !important;
    }
    [data-theme="dark"] .badge-warning-custom {
        background: rgba(245, 158, 11, 0.15) !important;
        color: #FBBF24 !important;
        border-color: rgba(245, 158, 11, 0.3) !important;
    }
    [data-theme="dark"] input[type="date"]::-webkit-calendar-picker-indicator {
        filter: invert(1) brightness(1.2);
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

<div class="container-fluid py-4 stock-page-container">
    <!-- Frameless Stock Header Hero -->
    <div class="stock-header-hero mb-4">
        <div class="telemetry-icon-box">
            <i class="ti ti-box"></i>
        </div>
        <div>
            <h1 class="telemetry-title">Stock &amp; Inventory Management</h1>
            <div class="telemetry-desc">Dashboard &nbsp;&gt;&nbsp; Stock &amp; Inventory &nbsp;&gt;&nbsp; Stock Details &amp; Upload</div>
        </div>
    </div>
<!-- Stat Cards -->
    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon orange"><i class="ti ti-box"></i></div>
                <div>
                    <div class="stat-label">Total Products</div>
                    <div class="stat-value">${empty kpi.totalProducts ? 0 : kpi.totalProducts}</div>
                    <div class="stat-label" style="font-size: 11px;">Active In Catalog</div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon green"><i class="ti ti-stack-2"></i></div>
                <div>
                    <div class="stat-label">Total Stock</div>
                    <div class="stat-value"><fmt:formatNumber value="${empty kpi.totalStock ? 0 : kpi.totalStock}" maxFractionDigits="2"/></div>
                    <div class="stat-label" style="font-size: 11px;">Units On Hand</div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon purple"><i class="ti ti-upload"></i></div>
                <div>
                    <div class="stat-label">Last Upload</div>
                    <div class="stat-value">${empty kpi.lastUploadCount ? '0' : kpi.lastUploadCount}</div>
                    <div class="stat-label" style="font-size: 11px;">Rows Processed</div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon yellow"><i class="ti ti-alert-triangle"></i></div>
                <div>
                    <div class="stat-label">Low Stock Alerts</div>
                    <div class="stat-value" style="color: ${not empty lowStockList && lowStockList.size() > 0 ? '#DC2626' : '#0F172A'};">${empty lowStockList ? 0 : lowStockList.size()}</div>
                    <div class="stat-label" style="font-size: 11px;">Items Below 50 Units</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Unified Single-Line Action & Filter Toolbar -->
    <div class="stock-toolbar-wrap mb-4">
        <!-- Segmented Navigation Tabs -->
        <div class="nav-tabs-custom mb-0">
            <div class="nav-link" onclick="switchTab('manual')" id="tab-manual">
                <i class="ti ti-square-plus me-2"></i>Manual Entry
            </div>
            <div class="nav-link active" onclick="switchTab('bulk')" id="tab-bulk">
                <i class="ti ti-cloud-upload me-2"></i>Bulk Upload
            </div>
            <div class="nav-link" onclick="switchTab('history')" id="tab-history">
                <i class="ti ti-history me-2"></i>Upload History
                <c:if test="${not empty fullHistoryList && fullHistoryList.size() > 0}">
                    <span class="badge bg-secondary ms-2" style="font-size: 10px; border-radius: 10px;">${fullHistoryList.size()}</span>
                </c:if>
            </div>
            <div class="nav-link" onclick="switchTab('overview')" id="tab-overview">
                <i class="ti ti-chart-bar me-2"></i>Stock Overview
                <c:if test="${not empty stockList && stockList.size() > 0}">
                    <span class="badge bg-secondary ms-2" style="font-size: 10px; border-radius: 10px;">${stockList.size()}</span>
                </c:if>
            </div>
        </div>

        <!-- Super Admin Company Filter (Unified on the same line, multi-tenant banner removed) -->
        <c:if test="${sessionScope.user.roleId == 1}">
            <div class="d-flex align-items-center gap-2">
                <label class="mb-0 fw-semibold text-nowrap stock-filter-label" style="font-size: 13px;">
                    <i class="ti ti-building me-1 text-primary"></i> Managing stock for:
                </label>
                <div class="select-wrapper stock-company-picker-wrap">
                    <i class="ti ti-search stock-select-search-icon"></i>
                    <select class="form-select form-select-sm stock-company-select" id="stockCompanySelect" data-search="true" data-search-placeholder="Search company..." onchange="onCompanyChange(this.value)">
                        <option value="0" ${selectedCompanyId == 0 ? 'selected' : ''}>All Companies (Enterprise-wide)</option>
                        <c:forEach var="co" items="${companies}">
                            <option value="${co.id}" ${selectedCompanyId == co.id ? 'selected' : ''}>${co.name}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>
        </c:if>
    </div>

    <!-- Alerts -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger shadow-sm border-0 mb-4 d-flex align-items-center justify-content-between" style="border-radius: 8px;">
            <div><i class="ti ti-alert-triangle me-2 fs-5 align-middle"></i> ${errorMessage}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success shadow-sm border-0 mb-4" style="border-radius: 8px;">
            <div class="d-flex align-items-center justify-content-between">
                <div><i class="ti ti-circle-check me-2 fs-5 align-middle"></i> ${successMessage}</div>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:if test="${not empty errorFilePath}">
                <hr>
                <a href="${pageContext.request.contextPath}/download-errors?file=${errorFilePath}" class="btn btn-sm btn-danger mt-2">
                    <i class="ti ti-download me-1"></i> Download Error Report for Invalid Rows
                </a>
            </c:if>
        </div>
    </c:if>

    <div class="row g-4">
        <!-- Main Left Area -->
        <div class="col-lg-8">
            <div class="card shadow-sm border-0 h-100" style="border-radius: var(--card-radius); overflow: hidden;">
                
                <!-- 1. Bulk Upload Content -->
                <div class="card-body p-4 p-lg-5" id="content-bulk">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <div>
                            <h5 class="fw-bold mb-1">Bulk Stock Upload</h5>
                            <p class="text-muted small mb-0">Drag and drop your CSV file to upload inventory in bulk (FR4.1 / FR4.3).</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/assets/templates/stock_template.csv" class="btn btn-sm btn-outline-nlog" download="stock_template.csv">
                            <i class="ti ti-download me-1"></i> Template
                        </a>
                    </div>
                    
                    <form action="<c:url value='/upload-stock'/>" method="POST" enctype="multipart/form-data" id="uploadForm">
                        <c:choose>
                            <c:when test="${sessionScope.user.roleId == 1}">
                                <div class="mb-4 stock-target-company-box">
                                    <label class="form-label mb-1">Target Company <span class="required-asterisk">*</span></label>
                                    <div class="select-wrapper">
                                        <select class="form-select" name="companyId" id="bulkUploadCompanySelect" required>
                                            <c:if test="${selectedCompanyId == 0}">
                                                <option value="">-- Select Company for this Upload * --</option>
                                            </c:if>
                                            <c:forEach var="co" items="${companies}">
                                                <option value="${co.id}" ${selectedCompanyId == co.id ? 'selected' : ''}>${co.name}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="text-muted small mt-1">Uploaded stock records and ledger will be assigned to this company.</div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <input type="hidden" name="companyId" value="${selectedCompanyId}">
                            </c:otherwise>
                        </c:choose>

                        <div class="upload-dropzone mb-4" id="dropzone" onclick="document.getElementById('csvFile').click()">
                            <i class="ti ti-cloud-upload"></i>
                            <h5 class="fw-bold mb-1">Drag &amp; Drop your CSV file here</h5>
                            <p class="text-muted small mb-0">or click to browse from your computer (.csv)</p>
                            <input type="file" id="csvFile" name="csvFile" accept=".csv" style="display: none;" onchange="handleFileSelect(event)">
                        </div>
                        
                        <div id="fileDisplay" class="alert alert-info d-none d-flex justify-content-between align-items-center mb-4" style="border-radius: 8px;">
                            <div><i class="ti ti-file-type-csv me-2 fs-4 align-middle" style="color:#FC8019;"></i> <span id="fileName" class="fw-bold align-middle"></span></div>
                            <button type="button" class="btn-close" onclick="clearFile()"></button>
                        </div>
                        
                        <button type="submit" id="btnUpload" class="btn btn-nlog w-100 py-3 fs-6" disabled>
                            <i class="ti ti-upload me-2"></i>Upload &amp; Validate CSV
                        </button>
                    </form>
                </div>

                <!-- 2. Manual Entry Content (FR4.1, FR4.2, FR4.3) -->
                <div class="card-body p-4 p-lg-5 d-none" id="content-manual">
                    <h5 class="fw-bold mb-1">Manual Stock Entry</h5>
                    <p class="text-muted small mb-4">Add new stock/inventory item manually. All starred fields are required per SRS FR4.2.</p>

                    <form action="${pageContext.request.contextPath}/manual-stock" method="POST" id="manualStockForm" novalidate>
                        <c:choose>
                            <c:when test="${sessionScope.user.roleId == 1}">
                                <div class="mb-3 stock-target-company-box">
                                    <label class="form-label mb-1">Target Company <span class="required-asterisk">*</span></label>
                                    <div class="select-wrapper">
                                        <select class="form-select" name="companyId" required>
                                            <c:if test="${selectedCompanyId == 0}">
                                                <option value="">-- Select Company * --</option>
                                            </c:if>
                                            <c:forEach var="co" items="${companies}">
                                                <option value="${co.id}" ${selectedCompanyId == co.id ? 'selected' : ''}>${co.name}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <input type="hidden" name="companyId" value="${selectedCompanyId}">
                            </c:otherwise>
                        </c:choose>

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Product Name <span class="required-asterisk">*</span></label>
                                <input type="text" class="form-control" name="productName" id="manualProductName" placeholder="e.g. Steel Rod" required>
                                <div class="invalid-feedback">Product name is required.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Category <span class="required-asterisk">*</span></label>
                                <input type="text" class="form-control" name="category" placeholder="e.g. Raw Materials" required>
                                <div class="invalid-feedback">Category is required.</div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">HSN Code <span class="required-asterisk">*</span></label>
                                <input type="text" class="form-control" name="hsnCode" placeholder="e.g. 72142000" required>
                                <div class="invalid-feedback">HSN code is required.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Unit of Measure <span class="required-asterisk">*</span></label>
                                <div class="select-wrapper">
                                <select class="form-select" name="unitOfMeasure" required>
                                    <option value="">Select unit</option>
                                    <option value="kg">kg — Kilogram</option>
                                    <option value="pcs">pcs — Pieces</option>
                                    <option value="box">box — Box</option>
                                    <option value="pallet">pallet — Pallet</option>
                                    <option value="ltr">ltr — Litre</option>
                                    <option value="mtr">mtr — Metre</option>
                                    <option value="ton">ton — Metric Ton</option>
                                    <option value="cbm">cbm — Cubic Metre</option>
                                </select>
                                </div>
                                <div class="invalid-feedback">Unit of measure is required.</div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Quantity <span class="required-asterisk">*</span> <span class="text-muted small">(≥ 0 per FR4.3)</span></label>
                                <input type="number" class="form-control" name="quantity" min="0" step="0.01" placeholder="0.00" required>
                                <div class="invalid-feedback">Quantity must be 0 or greater.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Warehouse / Location <span class="required-asterisk">*</span></label>
                                <div class="select-wrapper">
                                <select class="form-select" name="warehouseLocation" required>
                                    <option value="">Select warehouse / location</option>
                                    <option value="Mumbai WH-1">Mumbai WH-1</option>
                                    <option value="Delhi WH-2">Delhi WH-2</option>
                                    <option value="Bangalore WH-3">Bangalore WH-3</option>
                                    <option value="Chennai WH-4">Chennai WH-4</option>
                                    <option value="Kolkata WH-5">Kolkata WH-5</option>
                                </select>
                                </div>
                                <div class="invalid-feedback">Warehouse location is required.</div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Unit Cost (₹) <span class="required-asterisk">*</span> <span class="text-muted small">(≥ 0)</span></label>
                                <div class="input-group">
                                    <span class="input-group-text">₹</span>
                                    <input type="number" class="form-control" name="unitCost" min="0" step="0.01" placeholder="0.00" required>
                                </div>
                                <div class="invalid-feedback">Unit cost must be 0 or greater.</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Unit Selling Price (₹) <span class="required-asterisk">*</span> <span class="text-muted small">(≥ 0)</span></label>
                                <div class="input-group">
                                    <span class="input-group-text">₹</span>
                                    <input type="number" class="form-control" name="unitPrice" min="0" step="0.01" placeholder="0.00" required>
                                </div>
                                <div class="invalid-feedback">Unit price must be 0 or greater.</div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Batch / Lot Number <span class="text-muted small">(Optional)</span></label>
                                <input type="text" class="form-control" name="batchNo" placeholder="e.g. BATCH-2026-001">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Expiry Date <span class="text-muted small">(Optional)</span></label>
                                <input type="date" class="form-control" name="expiryDate">
                            </div>

                            <div class="col-12">
                                <label class="form-label">Remarks / Notes <span class="text-muted small">(Optional)</span></label>
                                <textarea class="form-control" name="remarks" rows="2" placeholder="Enter any additional notes"></textarea>
                            </div>
                        </div>

                        <div class="d-flex justify-content-end gap-3 mt-4">
                            <button type="reset" class="btn btn-outline-nlog px-4">Reset</button>
                            <button type="submit" class="btn btn-nlog px-4"><i class="ti ti-plus me-2"></i>Add to Stock</button>
                        </div>
                    </form>
                </div>

                <!-- 3. Upload History Content (FR4.4) -->
                <div class="card-body p-0 d-none" id="content-history">
                    <div class="p-4 pb-3">
                        <h5 class="fw-bold mb-1">Bulk Upload History Log</h5>
                        <p class="text-muted small mb-0">Detailed audit trail of all CSV upload runs with processed rows and status</p>
                    </div>

                    <div class="table-responsive">
                        <table class="enterprise-table tracking-table align-middle text-nowrap mb-0" id="historyTable" style="font-size: 13.5px;">
                            <thead>
                                <tr>
                                    <th class="sortable px-4 py-3" onclick="sortHistoryTable(0)">Date &amp; Time <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                                    <c:if test="${selectedCompanyId == 0}">
                                        <th class="sortable py-3" onclick="sortHistoryTable(1)">Company <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                                    </c:if>
                                    <th class="sortable py-3" onclick="sortHistoryTable(${selectedCompanyId == 0 ? 2 : 1})">File Name <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                                    <th class="sortable text-center py-3" onclick="sortHistoryTable(${selectedCompanyId == 0 ? 3 : 2})">Total Rows <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                                    <th class="text-center py-3">Status</th>
                                    <th class="px-4 py-3">Uploaded By</th>
                                </tr>
                            </thead>
                            <tbody id="historyTableBody">
                                <c:forEach var="hist" items="${fullHistoryList}">
                                    <tr class="history-row">
                                        <td class="px-4 py-3">
                                            <fmt:formatDate value="${hist.date}" pattern="dd MMM yyyy, hh:mm a" />
                                        </td>
                                        <c:if test="${selectedCompanyId == 0}">
                                            <td class="py-3"><span class="badge-company-custom">${hist.companyName}</span></td>
                                        </c:if>
                                        <td class="py-3 font-monospace fw-semibold" style="color: #0F172A;">
                                            <i class="ti ti-file-type-csv me-2 text-danger fs-5 align-middle"></i>${hist.fileName}
                                        </td>
                                        <td class="text-center py-3 fw-bold">${hist.total}</td>
                                        <td class="text-center py-3">
                                            <span class="badge-success-custom me-1" title="Valid Rows">${hist.success} Valid <i class="ti ti-check"></i></span>
                                            <c:if test="${hist.failed > 0}">
                                                <span class="badge-failed-custom" title="Invalid Rows">${hist.failed} Failed <i class="ti ti-x"></i></span>
                                            </c:if>
                                        </td>
                                        <td class="px-4 py-3 text-muted">${hist.user}</td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty fullHistoryList}">
                                    <tr id="emptyHistoryRow"><td colspan="6" class="text-center py-5 text-muted">
                                        <i class="ti ti-history-off fs-1 text-muted d-block mb-2"></i>
                                        No upload history available for the selected view.
                                    </td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>

                    <!-- Global CSS Pagination Bar for Upload History -->
                    <div class="nl-pagination-wrapper" id="historyPagination" style="display: none;">
                        <div class="nl-pagination-info">
                            <span>Showing <strong id="histPageStart">1</strong> to <strong id="histPageEnd">10</strong> of <strong id="histTotalRows">0</strong> uploads</span>
                            <div class="d-inline-flex align-items-center gap-2 ms-2">
                                <span class="text-muted small">Show:</span>
                                <select class="nl-page-size-select" id="histPageSize" onchange="changeHistPageSize(this.value)">
                                    <option value="10" selected>10</option>
                                    <option value="25">25</option>
                                    <option value="50">50</option>
                                </select>
                            </div>
                        </div>
                        <div class="nl-pagination-nav" id="histPageNav"></div>
                    </div>
                </div>

                <!-- 4. Stock Overview & Adjustments (FR4.6 + Pagination + Global CSS) -->
                <div class="card-body p-0 d-none" id="content-overview">
                    
                    <!-- Toolbar: Search & Filters -->
                    <div class="table-toolbar">
                        <div class="d-flex align-items-center gap-2 flex-wrap flex-grow-1">
                            <div class="search-input-box">
                                <i class="ti ti-search"></i>
                                <input type="text" id="stockSearchInput" placeholder="Search product, HSN, batch, warehouse..." oninput="handleStockFilter()">
                            </div>
                            <div style="min-width: 170px;">
                                <select class="form-select form-select-sm" id="stockWarehouseFilter" onchange="handleStockFilter()" style="border-radius: 8px;">
                                    <option value="">All Warehouses</option>
                                    <option value="Mumbai">Mumbai WH-1</option>
                                    <option value="Delhi">Delhi WH-2</option>
                                    <option value="Bangalore">Bangalore WH-3</option>
                                    <option value="Chennai">Chennai WH-4</option>
                                    <option value="Kolkata">Kolkata WH-5</option>
                                </select>
                            </div>
                            <div style="min-width: 150px;">
                                <select class="form-select form-select-sm" id="stockStatusFilter" onchange="handleStockFilter()" style="border-radius: 8px;">
                                    <option value="">All Stock Levels</option>
                                    <option value="healthy">Healthy (> 50)</option>
                                    <option value="low">Low Stock (≤ 50)</option>
                                    <option value="zero">Out of Stock (0)</option>
                                </select>
                            </div>
                        </div>
                        <div class="text-muted small">
                            Total Records: <strong id="stockFilterCount">${empty stockList ? 0 : stockList.size()}</strong>
                        </div>
                    </div>

                    <!-- Stock Table -->
                    <div class="table-responsive">
                        <table class="enterprise-table tracking-table align-middle text-nowrap mb-0" id="stockOverviewTable" style="font-size: 13.5px;">
                            <thead>
                                <tr>
                                    <th class="sortable px-4 py-3" onclick="sortStockTable(0)">Product Name <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                                    <c:if test="${selectedCompanyId == 0}">
                                        <th class="sortable py-3" onclick="sortStockTable(1)">Company <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                                    </c:if>
                                    <th class="sortable py-3" onclick="sortStockTable(${selectedCompanyId == 0 ? 2 : 1})">Warehouse <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                                    <th class="sortable text-end py-3" onclick="sortStockTable(${selectedCompanyId == 0 ? 3 : 2})">Qty On Hand <i class="ti ti-arrows-sort text-muted ms-1"></i></th>
                                    <th class="text-center py-3">Status</th>
                                    <th class="text-center px-4 py-3">Action</th>
                                </tr>
                            </thead>
                            <tbody id="stockTableBody">
                                <c:forEach var="stk" items="${stockList}">
                                    <tr class="stock-row" 
                                        data-product="${stk.productName.toLowerCase()}"
                                        data-hsn="${stk.hsnCode.toLowerCase()}"
                                        data-batch="${empty stk.batchNo ? '' : stk.batchNo.toLowerCase()}"
                                        data-warehouse="${stk.warehouse}"
                                        data-company="${empty stk.companyName ? '' : stk.companyName.toLowerCase()}"
                                        data-qty="${stk.quantity}">
                                        <td class="px-4 py-3">
                                            <div class="fw-bold text-dark" style="font-size: 14px;">${stk.productName}</div>
                                            <div class="text-muted small d-flex align-items-center gap-2 mt-1">
                                                <span>HSN: <code>${empty stk.hsnCode ? '—' : stk.hsnCode}</code></span>
                                                <c:if test="${not empty stk.batchNo}">
                                                    <span class="badge" style="background:#F1F5F9; color:#475569; font-weight:500;">Batch: ${stk.batchNo}</span>
                                                </c:if>
                                            </div>
                                        </td>
                                        <c:if test="${selectedCompanyId == 0}">
                                            <td class="py-3">
                                                <span class="badge-company-custom">${stk.companyName}</span>
                                            </td>
                                        </c:if>
                                        <td class="py-3">
                                            <i class="ti ti-map-pin text-muted me-1"></i>${stk.warehouse}
                                        </td>
                                        <td class="py-3 text-end fw-bold" style="font-size: 14px; color: ${stk.quantity <= 50 ? '#DC2626' : '#FC8019'};">
                                            <fmt:formatNumber value="${stk.quantity}" maxFractionDigits="2"/>
                                        </td>
                                        <td class="py-3 text-center">
                                            <c:choose>
                                                <c:when test="${stk.quantity <= 0}">
                                                    <span class="badge-failed-custom">Out of Stock</span>
                                                </c:when>
                                                <c:when test="${stk.quantity <= 20}">
                                                    <span class="badge-failed-custom">Critical (&le; 20)</span>
                                                </c:when>
                                                <c:when test="${stk.quantity <= 50}">
                                                    <span class="badge-warning-custom">Low Stock (&le; 50)</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-success-custom">Healthy</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="px-4 py-3 text-center">
                                            <button class="btn btn-sm" style="border: 1.5px solid #DC2626; color: #DC2626; border-radius: 50px !important; font-weight:600; font-size:12px; padding: 5px 14px;" onclick="openAdjustModal(${stk.stockId}, '${stk.productName}', ${stk.quantity})">
                                                <i class="ti ti-circle-minus me-1"></i> Write-off
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty stockList}">
                                    <tr id="emptyStockRow"><td colspan="6" class="text-center py-5 text-muted">
                                        <i class="ti ti-box-off fs-1 text-muted d-block mb-2"></i>
                                        No stock records available for the selected company.
                                    </td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>

                    <!-- Global CSS Enterprise Pagination Bar for Stock Overview -->
                    <div class="nl-pagination-wrapper" id="stockPagination" style="display: flex;">
                        <div class="nl-pagination-info">
                            <span>Showing <strong id="stockPageStart">1</strong> to <strong id="stockPageEnd">10</strong> of <strong id="stockTotalRows">${empty stockList ? 0 : stockList.size()}</strong> items</span>
                            <div class="d-inline-flex align-items-center gap-2 ms-2">
                                <span class="text-muted small">Show:</span>
                                <select class="nl-page-size-select" id="stockPageSize" onchange="changeStockPageSize(this.value)">
                                    <option value="10" selected>10</option>
                                    <option value="25">25</option>
                                    <option value="50">50</option>
                                    <option value="100">100</option>
                                </select>
                            </div>
                        </div>
                        <div class="nl-pagination-nav" id="stockPageNav"></div>
                    </div>
                </div>

            </div>
        </div>

        <!-- Right Sidebar (Recent Uploads) -->
        <div class="col-lg-4">
            <div class="card shadow-sm border-0 h-100" style="border-radius: var(--card-radius);">
                <div class="card-body p-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h6 class="fw-bold mb-0 text-dark"><i class="ti ti-clock-history me-1 text-primary"></i> Recent Stock Uploads</h6>
                        <a href="javascript:void(0)" onclick="switchTab('history')" class="text-decoration-none small text-primary fw-semibold">View All</a>
                    </div>
                    
                    <div class="table-responsive">
                        <table class="table table-borderless align-middle text-nowrap mb-0" style="font-size: 13px;">
                            <thead class="text-muted" style="border-bottom: 1px solid #f1f5f9;">
                                <tr>
                                    <th class="fw-semibold pb-2">Date &amp; Time</th>
                                    <th class="fw-semibold pb-2">Company</th>
                                    <th class="fw-semibold pb-2 text-end">Rows</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="upload" items="${recentUploads}">
                                    <tr style="border-bottom: 1px solid #F8FAFC;">
                                        <td class="py-2.5">
                                            <div class="fw-semibold text-dark"><fmt:formatDate value="${upload.date}" pattern="dd MMM yyyy" /></div>
                                            <div class="text-muted small"><fmt:formatDate value="${upload.date}" pattern="hh:mm a" /></div>
                                        </td>
                                        <td class="py-2.5">
                                            <span class="badge-company-custom">${upload.companyName}</span>
                                        </td>
                                        <td class="py-2.5 text-end">
                                            <span class="badge-success-custom">${upload.success}</span>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty recentUploads}">
                                    <tr>
                                        <td colspan="3" class="text-center pt-4 text-muted small">No recent uploads found.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Low Stock Alerts Section (Threshold-based < 50 units) -->
    <div class="card shadow-sm border-0 mt-4" style="border-radius: var(--card-radius); overflow: hidden;">
        <div class="card-body p-4">
            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                <div>
                    <h6 class="fw-bold mb-1 text-danger d-flex align-items-center gap-2">
                        <i class="ti ti-alert-triangle fs-5"></i> Low Stock Alerts (&lt; 50 Units Reorder Level)
                    </h6>
                    <p class="text-muted small mb-0">Items requiring immediate reorder or replenishment</p>
                </div>
                <span class="badge" style="background:#FEE2E2; color:#B91C1C; font-weight:700; padding:6px 12px; border-radius:20px;">
                    ${empty lowStockList ? 0 : lowStockList.size()} Critical Alerts
                </span>
            </div>
            
            <div class="table-responsive">
                <table class="enterprise-table tracking-table align-middle text-nowrap mb-0" id="lowStockTable" style="font-size: 13.5px;">
                    <thead class="text-muted" style="background-color: #f8fafc; border-bottom: 1px solid #e2e8f0;">
                        <tr>
                            <th class="fw-semibold px-4 py-3">Product Name</th>
                            <th class="fw-semibold py-3">Company</th>
                            <th class="fw-semibold py-3">Warehouse</th>
                            <th class="fw-semibold text-end py-3">Current Stock</th>
                            <th class="fw-semibold text-end py-3">Reorder Threshold</th>
                            <th class="fw-semibold text-center py-3">Severity</th>
                            <th class="fw-semibold text-center px-4 py-3">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="low" items="${lowStockList}">
                            <tr class="low-stock-row" style="border-bottom: 1px solid #F1F5F9;">
                                <td class="px-4 py-3">
                                    <div class="fw-bold text-dark">${low.productName}</div>
                                    <div class="text-muted small">HSN: <code>${empty low.hsnCode ? '—' : low.hsnCode}</code></div>
                                </td>
                                <td class="py-3"><span class="badge-company-custom">${low.companyName}</span></td>
                                <td class="py-3"><i class="ti ti-map-pin text-muted me-1"></i>${low.warehouse}</td>
                                <td class="py-3 text-end fw-bold text-danger" style="font-size: 14px;">
                                    <fmt:formatNumber value="${low.quantity}" maxFractionDigits="2"/>
                                </td>
                                <td class="py-3 text-end text-muted font-monospace">50.00</td>
                                <td class="py-3 text-center">
                                    <c:choose>
                                        <c:when test="${low.quantity <= 20}">
                                            <span class="badge-failed-custom"><i class="ti ti-flame me-1"></i>Critical</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-warning-custom"><i class="ti ti-alert-circle me-1"></i>Low Stock</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="px-4 py-3 text-center">
                                    <button class="btn btn-restock-action" onclick="prefillManualEntry('${low.productName}', '${low.companyId}')">
                                        <i class="ti ti-plus me-1"></i> Restock
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty lowStockList}">
                            <tr><td colspan="7" class="text-center py-4 text-muted">
                                <i class="ti ti-circle-check text-success fs-5 me-1"></i> All inventory levels are healthy (above 50 units).
                            </td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

            <!-- Global CSS Enterprise Pagination Bar for Low Stock Alerts -->
            <div class="nl-pagination-wrapper mt-3" id="lowStockPagination" style="display: flex;">
                <div class="nl-pagination-info">
                    <span>Showing <strong id="lowStockPageStart">1</strong> to <strong id="lowStockPageEnd">5</strong> of <strong id="lowStockTotalRows">${empty lowStockList ? 0 : lowStockList.size()}</strong> alerts</span>
                    <div class="d-inline-flex align-items-center gap-2 ms-2">
                        <span class="text-muted small">Show:</span>
                        <select class="nl-page-size-select" id="lowStockPageSize" onchange="changeLowStockPageSize(this.value)">
                            <option value="5" selected>5</option>
                            <option value="10">10</option>
                            <option value="25">25</option>
                            <option value="50">50</option>
                        </select>
                    </div>
                </div>
                <div class="nl-pagination-nav" id="lowStockPageNav"></div>
            </div>
        </div>
    </div>
</div>

<!-- Write-off / Adjust Modal -->
<div class="modal fade" id="adjustModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content" style="border-radius: var(--card-radius); border: none;">
      <div class="modal-header border-0 pb-0">
        <h5 class="modal-title fw-bold text-danger"><i class="ti ti-alert-triangle me-2"></i> Stock Write-off</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <form action="${pageContext.request.contextPath}/adjust-stock" method="POST">
          <div class="modal-body pt-3">
              <p class="text-muted small mb-4">Adjust inventory down for <strong id="modalProdName" class="text-dark"></strong>.</p>
              
              <input type="hidden" name="stockId" id="modalStockId">
              
              <div class="mb-3">
                  <label class="form-label">Current Quantity</label>
                  <input type="text" class="form-control bg-light" id="modalMaxQty" readonly>
              </div>
              
              <div class="mb-3">
                  <label class="form-label">Quantity to Remove <span class="required-asterisk">*</span></label>
                  <input type="number" class="form-control" name="adjustmentQuantity" id="adjustmentQuantity" min="0.01" step="0.01" required>
              </div>
              
              <div class="mb-3">
                  <label class="form-label">Reason for Write-off <span class="required-asterisk">*</span></label>
                  <div class="select-wrapper">
                  <select class="form-select" name="reason" required>
                      <option value="">Select Reason</option>
                      <option value="Damage">Damage</option>
                      <option value="Expiry">Expiry</option>
                      <option value="Lost">Lost</option>
                      <option value="Audit Discrepancy">Audit Discrepancy</option>
                  </select>
                  </div>
              </div>
          </div>
          <div class="modal-footer border-0 pt-0">
            <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius: 50px !important;">Cancel</button>
            <button type="submit" class="btn btn-danger px-4" style="border-radius: 50px !important;">Confirm Write-off</button>
          </div>
      </form>
    </div>
  </div>
</div>

<script>
    let activeTabName = 'bulk';

    
    // =========================================================================
    // CLIENT-SIDE SORTING FOR HISTORY & STOCK TABLES
    // =========================================================================
    let histSortCol = -1;
    let histSortAsc = true;
    function sortHistoryTable(colIndex) {
        if (histSortCol === colIndex) histSortAsc = !histSortAsc;
        else { histSortCol = colIndex; histSortAsc = true; }
        allHistRows.sort((a, b) => {
            const cellA = a.cells[colIndex] ? a.cells[colIndex].innerText.trim() : '';
            const cellB = b.cells[colIndex] ? b.cells[colIndex].innerText.trim() : '';
            const numA = parseFloat(cellA.replace(/[^0-9.-]+/g, ''));
            const numB = parseFloat(cellB.replace(/[^0-9.-]+/g, ''));
            if (!isNaN(numA) && !isNaN(numB)) return histSortAsc ? numA - numB : numB - numA;
            return histSortAsc ? cellA.localeCompare(cellB) : cellB.localeCompare(cellA);
        });
        const tbody = document.getElementById('historyTableBody');
        allHistRows.forEach(row => tbody.appendChild(row));
        updateHistPaginationDisplay();
    }

    let stockSortCol = -1;
    let stockSortAsc = true;
    function sortStockTable(colIndex) {
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
        matchingStockRows.forEach(row => tbody.appendChild(row));
        updateStockPaginationDisplay();
    }

    // Switch Tabs
    function switchTab(tabName) {
        activeTabName = tabName;
        document.querySelectorAll('.nav-tabs-custom .nav-link').forEach(el => el.classList.remove('active'));
        const activeTabEl = document.getElementById('tab-' + tabName);
        if (activeTabEl) activeTabEl.classList.add('active');
        
        document.getElementById('content-manual').classList.add('d-none');
        document.getElementById('content-bulk').classList.add('d-none');
        document.getElementById('content-overview').classList.add('d-none');
        document.getElementById('content-history').classList.add('d-none');
        
        if (tabName === 'manual') document.getElementById('content-manual').classList.remove('d-none');
        if (tabName === 'bulk') document.getElementById('content-bulk').classList.remove('d-none');
        if (tabName === 'overview') {
            document.getElementById('content-overview').classList.remove('d-none');
            updateStockPaginationDisplay();
        }
        if (tabName === 'history') {
            document.getElementById('content-history').classList.remove('d-none');
            updateHistPaginationDisplay();
        }
    }

    function onCompanyChange(val) {
        window.location.href = '${pageContext.request.contextPath}/upload-stock?companyId=' + val + '&tab=' + activeTabName;
    }

    function prefillManualEntry(prodName, compId) {
        switchTab('manual');
        const prodInput = document.getElementById('manualProductName');
        if (prodInput) {
            prodInput.value = prodName;
            prodInput.focus();
        }
        if (compId) {
            const compSelect = document.querySelector('#content-manual select[name="companyId"]');
            if (compSelect) compSelect.value = compId;
        }
    }

    // Modal Logic
    function openAdjustModal(stockId, productName, maxQty) {
        document.getElementById('modalStockId').value = stockId;
        document.getElementById('modalProdName').innerText = productName;
        document.getElementById('modalMaxQty').value = maxQty;
        document.getElementById('adjustmentQuantity').max = maxQty;
        new bootstrap.Modal(document.getElementById('adjustModal')).show();
    }

    // Drag & Drop
    const dropzone = document.getElementById('dropzone');
    const fileInput = document.getElementById('csvFile');
    const fileDisplay = document.getElementById('fileDisplay');
    const fileNameSpan = document.getElementById('fileName');
    const btnUpload = document.getElementById('btnUpload');

    if (dropzone) {
        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
            dropzone.addEventListener(eventName, preventDefaults, false);
        });

        function preventDefaults(e) { e.preventDefault(); e.stopPropagation(); }

        ['dragenter', 'dragover'].forEach(eventName => {
            dropzone.addEventListener(eventName, () => dropzone.classList.add('dragover'), false);
        });

        ['dragleave', 'drop'].forEach(eventName => {
            dropzone.addEventListener(eventName, () => dropzone.classList.remove('dragover'), false);
        });

        dropzone.addEventListener('drop', function(e) {
            let dt = e.dataTransfer;
            let files = dt.files;
            if (files.length > 0 && files[0].name.endsWith('.csv')) {
                fileInput.files = files;
                updateFileDisplay(files[0].name);
            } else {
                alert("Please upload a valid .csv file.");
            }
        }, false);
    }

    function handleFileSelect(e) {
        if (e.target.files.length > 0) updateFileDisplay(e.target.files[0].name);
    }

    function updateFileDisplay(name) {
        fileNameSpan.textContent = name;
        dropzone.classList.add('d-none');
        fileDisplay.classList.remove('d-none');
        btnUpload.disabled = false;
    }

    function clearFile() {
        fileInput.value = '';
        fileNameSpan.textContent = '';
        fileDisplay.classList.add('d-none');
        dropzone.classList.remove('d-none');
        btnUpload.disabled = true;
    }

    // =========================================================================
    // STOCK OVERVIEW CLIENT-SIDE PAGINATION & SEARCH (GLOBAL CSS)
    // =========================================================================
    let stockPageSize = 10;
    let stockCurrentPage = 1;
    let allStockRows = [];
    let matchingStockRows = [];

    function initStockPagination() {
        allStockRows = Array.from(document.querySelectorAll('.stock-row'));
        matchingStockRows = [...allStockRows];
        updateStockPaginationDisplay();
    }

    function handleStockFilter() {
        const query = (document.getElementById('stockSearchInput').value || '').trim().toLowerCase();
        const whFilter = (document.getElementById('stockWarehouseFilter').value || '').toLowerCase();
        const statusFilter = (document.getElementById('stockStatusFilter').value || '').toLowerCase();

        matchingStockRows = allStockRows.filter(row => {
            const prod = row.getAttribute('data-product') || '';
            const hsn = row.getAttribute('data-hsn') || '';
            const batch = row.getAttribute('data-batch') || '';
            const wh = (row.getAttribute('data-warehouse') || '').toLowerCase();
            const co = row.getAttribute('data-company') || '';
            const qty = parseFloat(row.getAttribute('data-qty') || '0');

            const matchesQuery = !query || prod.includes(query) || hsn.includes(query) || batch.includes(query) || wh.includes(query) || co.includes(query);
            const matchesWh = !whFilter || wh.includes(whFilter);

            let matchesStatus = true;
            if (statusFilter === 'healthy') matchesStatus = qty > 50;
            else if (statusFilter === 'low') matchesStatus = qty <= 50 && qty > 0;
            else if (statusFilter === 'zero') matchesStatus = qty <= 0;

            return matchesQuery && matchesWh && matchesStatus;
        });

        stockCurrentPage = 1;
        const countEl = document.getElementById('stockFilterCount');
        if (countEl) countEl.innerText = matchingStockRows.length;
        updateStockPaginationDisplay();
    }

    function changeStockPageSize(size) {
        stockPageSize = parseInt(size) || 10;
        stockCurrentPage = 1;
        updateStockPaginationDisplay();
    }

    function updateStockPaginationDisplay() {
        const total = matchingStockRows.length;
        const totalPages = Math.ceil(total / stockPageSize) || 1;
        if (stockCurrentPage > totalPages) stockCurrentPage = totalPages;
        if (stockCurrentPage < 1) stockCurrentPage = 1;

        const startIdx = (stockCurrentPage - 1) * stockPageSize;
        const endIdx = startIdx + stockPageSize;

        allStockRows.forEach(row => row.style.display = 'none');
        matchingStockRows.slice(startIdx, endIdx).forEach(row => row.style.display = '');

        const pageStartEl = document.getElementById('stockPageStart');
        const pageEndEl = document.getElementById('stockPageEnd');
        const totalRowsEl = document.getElementById('stockTotalRows');
        const paginationWrapper = document.getElementById('stockPagination');

        if (pageStartEl) pageStartEl.innerText = total === 0 ? 0 : startIdx + 1;
        if (pageEndEl) pageEndEl.innerText = Math.min(endIdx, total);
        if (totalRowsEl) totalRowsEl.innerText = total;

        if (paginationWrapper) {
            paginationWrapper.style.display = total > 0 ? 'flex' : 'none';
        }

        renderStockPaginationButtons(totalPages);
    }

    function renderStockPaginationButtons(totalPages) {
        const nav = document.getElementById('stockPageNav');
        if (!nav) return;
        nav.innerHTML = '';

        if (totalPages <= 1) return;

        // Prev Button
        const prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'nl-page-btn nl-page-nav-btn' + (stockCurrentPage === 1 ? ' disabled' : '');
        prevBtn.disabled = (stockCurrentPage === 1);
        prevBtn.innerHTML = '<i class="ti ti-chevron-left"></i>';
        prevBtn.onclick = () => { if (stockCurrentPage > 1) { stockCurrentPage--; updateStockPaginationDisplay(); } };
        nav.appendChild(prevBtn);

        // Page Number Buttons
        let startPage = Math.max(1, stockCurrentPage - 2);
        let endPage = Math.min(totalPages, stockCurrentPage + 2);
        if (endPage - startPage < 4) {
            if (startPage === 1) endPage = Math.min(totalPages, startPage + 4);
            else if (endPage === totalPages) startPage = Math.max(1, endPage - 4);
        }

        if (startPage > 1) {
            const firstBtn = createStockNumBtn(1);
            nav.appendChild(firstBtn);
            if (startPage > 2) {
                const dots = document.createElement('span');
                dots.className = 'px-1 text-muted';
                dots.innerText = '...';
                nav.appendChild(dots);
            }
        }

        for (let p = startPage; p <= endPage; p++) {
            nav.appendChild(createStockNumBtn(p));
        }

        if (endPage < totalPages) {
            if (endPage < totalPages - 1) {
                const dots = document.createElement('span');
                dots.className = 'px-1 text-muted';
                dots.innerText = '...';
                nav.appendChild(dots);
            }
            nav.appendChild(createStockNumBtn(totalPages));
        }

        // Next Button
        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'nl-page-btn nl-page-nav-btn' + (stockCurrentPage === totalPages ? ' disabled' : '');
        nextBtn.disabled = (stockCurrentPage === totalPages);
        nextBtn.innerHTML = '<i class="ti ti-chevron-right"></i>';
        nextBtn.onclick = () => { if (stockCurrentPage < totalPages) { stockCurrentPage++; updateStockPaginationDisplay(); } };
        nav.appendChild(nextBtn);
    }

    function createStockNumBtn(page) {
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'nl-page-btn nl-page-num' + (page === stockCurrentPage ? ' active' : '');
        btn.innerText = page;
        btn.onclick = () => { stockCurrentPage = page; updateStockPaginationDisplay(); };
        return btn;
    }

    // =========================================================================
    // UPLOAD HISTORY CLIENT-SIDE PAGINATION (GLOBAL CSS)
    // =========================================================================
    let histPageSize = 10;
    let histCurrentPage = 1;
    let allHistRows = [];

    function initHistPagination() {
        allHistRows = Array.from(document.querySelectorAll('.history-row'));
        updateHistPaginationDisplay();
    }

    function changeHistPageSize(size) {
        histPageSize = parseInt(size) || 10;
        histCurrentPage = 1;
        updateHistPaginationDisplay();
    }

    function updateHistPaginationDisplay() {
        const total = allHistRows.length;
        const totalPages = Math.ceil(total / histPageSize) || 1;
        if (histCurrentPage > totalPages) histCurrentPage = totalPages;
        if (histCurrentPage < 1) histCurrentPage = 1;

        const startIdx = (histCurrentPage - 1) * histPageSize;
        const endIdx = startIdx + histPageSize;

        allHistRows.forEach((row, i) => {
            row.style.display = (i >= startIdx && i < endIdx) ? '' : 'none';
        });

        const pageStartEl = document.getElementById('histPageStart');
        const pageEndEl = document.getElementById('histPageEnd');
        const totalRowsEl = document.getElementById('histTotalRows');
        const paginationWrapper = document.getElementById('historyPagination');

        if (pageStartEl) pageStartEl.innerText = total === 0 ? 0 : startIdx + 1;
        if (pageEndEl) pageEndEl.innerText = Math.min(endIdx, total);
        if (totalRowsEl) totalRowsEl.innerText = total;

        if (paginationWrapper) {
            paginationWrapper.style.display = total > 0 ? 'flex' : 'none';
        }

        renderHistPaginationButtons(totalPages);
    }

    function renderHistPaginationButtons(totalPages) {
        const nav = document.getElementById('histPageNav');
        if (!nav) return;
        nav.innerHTML = '';
        if (totalPages <= 1) return;

        const prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'nl-page-btn nl-page-nav-btn' + (histCurrentPage === 1 ? ' disabled' : '');
        prevBtn.disabled = (histCurrentPage === 1);
        prevBtn.innerHTML = '<i class="ti ti-chevron-left"></i>';
        prevBtn.onclick = () => { if (histCurrentPage > 1) { histCurrentPage--; updateHistPaginationDisplay(); } };
        nav.appendChild(prevBtn);

        for (let p = 1; p <= totalPages; p++) {
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'nl-page-btn nl-page-num' + (p === histCurrentPage ? ' active' : '');
            btn.innerText = p;
            btn.onclick = () => { histCurrentPage = p; updateHistPaginationDisplay(); };
            nav.appendChild(btn);
        }

        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'nl-page-btn nl-page-nav-btn' + (histCurrentPage === totalPages ? ' disabled' : '');
        nextBtn.disabled = (histCurrentPage === totalPages);
        nextBtn.innerHTML = '<i class="ti ti-chevron-right"></i>';
        nextBtn.onclick = () => { if (histCurrentPage < totalPages) { histCurrentPage++; updateHistPaginationDisplay(); } };
        nav.appendChild(nextBtn);
    }

    // =========================================================================
    // LOW STOCK ALERTS CLIENT-SIDE PAGINATION (GLOBAL CSS)
    // =========================================================================
    let lowStockPageSize = 5;
    let lowStockCurrentPage = 1;
    let allLowStockRows = [];

    function initLowStockPagination() {
        allLowStockRows = Array.from(document.querySelectorAll('.low-stock-row'));
        updateLowStockPaginationDisplay();
    }

    function changeLowStockPageSize(size) {
        lowStockPageSize = parseInt(size) || 5;
        lowStockCurrentPage = 1;
        updateLowStockPaginationDisplay();
    }

    function updateLowStockPaginationDisplay() {
        const total = allLowStockRows.length;
        const totalPages = Math.ceil(total / lowStockPageSize) || 1;
        if (lowStockCurrentPage > totalPages) lowStockCurrentPage = totalPages;
        if (lowStockCurrentPage < 1) lowStockCurrentPage = 1;

        const startIdx = (lowStockCurrentPage - 1) * lowStockPageSize;
        const endIdx = startIdx + lowStockPageSize;

        allLowStockRows.forEach((row, i) => {
            row.style.display = (i >= startIdx && i < endIdx) ? '' : 'none';
        });

        const pageStartEl = document.getElementById('lowStockPageStart');
        const pageEndEl = document.getElementById('lowStockPageEnd');
        const totalRowsEl = document.getElementById('lowStockTotalRows');
        const paginationWrapper = document.getElementById('lowStockPagination');

        if (pageStartEl) pageStartEl.innerText = total === 0 ? 0 : startIdx + 1;
        if (pageEndEl) pageEndEl.innerText = Math.min(endIdx, total);
        if (totalRowsEl) totalRowsEl.innerText = total;

        if (paginationWrapper) {
            paginationWrapper.style.display = total > 0 ? 'flex' : 'none';
        }

        renderLowStockPaginationButtons(totalPages);
    }

    function renderLowStockPaginationButtons(totalPages) {
        const nav = document.getElementById('lowStockPageNav');
        if (!nav) return;
        nav.innerHTML = '';

        if (totalPages <= 1) return;

        const prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'nl-page-btn nl-page-nav-btn' + (lowStockCurrentPage === 1 ? ' disabled' : '');
        prevBtn.disabled = (lowStockCurrentPage === 1);
        prevBtn.innerHTML = '<i class="ti ti-chevron-left"></i>';
        prevBtn.onclick = () => { if (lowStockCurrentPage > 1) { lowStockCurrentPage--; updateLowStockPaginationDisplay(); } };
        nav.appendChild(prevBtn);

        for (let p = 1; p <= totalPages; p++) {
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'nl-page-btn nl-page-num' + (p === lowStockCurrentPage ? ' active' : '');
            btn.innerText = p;
            btn.onclick = () => { lowStockCurrentPage = p; updateLowStockPaginationDisplay(); };
            nav.appendChild(btn);
        }

        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'nl-page-btn nl-page-nav-btn' + (lowStockCurrentPage === totalPages ? ' disabled' : '');
        nextBtn.disabled = (lowStockCurrentPage === totalPages);
        nextBtn.innerHTML = '<i class="ti ti-chevron-right"></i>';
        nextBtn.onclick = () => { if (lowStockCurrentPage < totalPages) { lowStockCurrentPage++; updateLowStockPaginationDisplay(); } };
        nav.appendChild(nextBtn);
    }

    // On DOM Load: Initialize Paginations and URL Tab
    document.addEventListener('DOMContentLoaded', function() {
        initStockPagination();
        initHistPagination();
        initLowStockPagination();

        const urlParams = new URLSearchParams(window.location.search);
        const tabParam = urlParams.get('tab');
        if (tabParam && ['manual', 'bulk', 'history', 'overview'].includes(tabParam)) {
            switchTab(tabParam);
        }
    });
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
