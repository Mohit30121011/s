<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* Dashboard specific styling */
    /* Sortable Headers */
    .sortable { cursor: pointer; transition: color 0.2s; }
    .sortable:hover { color: var(--brand-orange); }
    .sortable i { color: #ccc; font-size: 12px; }
    .page-header-flex { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
    
    .card-panel {
        background: #fff; border-radius: 12px; border: 1px solid var(--border-color);
        box-shadow: 0 1px 3px rgba(0,0,0,0.02); padding: 24px; margin-bottom: 24px;
    }

    /* Filter Row - Clean seamless bar with no clunky card background */
    .filter-card {
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        padding: 0 !important;
        margin-bottom: 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    
    .filter-search {
        position: relative;
        width: 420px;
    }
    .filter-search .search-icon {
        position: absolute;
        left: 16px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--text-muted);
        font-size: 14px;
        pointer-events: none;
    }
    .filter-search input {
        width: 100%;
        padding: 11px 38px 11px 44px;
        border: 1.5px solid var(--border-color);
        border-radius: 50px !important;
        font-size: 13.5px;
        outline: none;
        background: #FFFFFF;
        color: var(--text-dark);
        transition: border-color 0.2s, box-shadow 0.2s;
    }
    .filter-search input:focus {
        border-color: var(--brand-orange);
        box-shadow: 0 0 0 3.5px rgba(252, 128, 25, 0.14);
    }
    .filter-search .clear-icon {
        position: absolute;
        right: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #9CA3AF;
        font-size: 14px;
        cursor: pointer;
        padding: 4px;
        transition: color 0.15s ease;
    }
    .filter-search .clear-icon:hover {
        color: #1F2937;
    }

    [data-theme="dark"] .filter-card {
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        padding: 0 !important;
    }
    [data-theme="dark"] .filter-search input {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .filter-search .search-icon {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .filter-search .clear-icon {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .filter-search .clear-icon:hover {
        color: #F8FAFC !important;
    }

    /* Action Button */
    .btn-book {
        background: var(--brand-orange); color: white; border: none; padding: 10px 20px;
        border-radius: 50px !important; font-size: 13px; font-weight: 600; display: inline-flex;
        align-items: center; gap: 8px; transition: background 0.2s; cursor: pointer;
        text-decoration: none;
    }
    .btn-book:hover { background: #e06c11; color: white; }

    /* Data Table */
    .tracking-table { width: 100%; border-collapse: separate; border-spacing: 0; }
    .tracking-table th {
        font-size: 12px; color: var(--text-muted); font-weight: 600; padding: 16px 24px;
        border-bottom: 1px solid var(--border-color); text-align: left; background: #F9FAFB;
    }
    .tracking-table th:first-child { border-top-left-radius: 8px; }
    .tracking-table th:last-child { border-top-right-radius: 8px; }

    .tracking-table td {
        padding: 18px 24px; font-size: 14px; color: var(--text-dark); font-weight: 500;
        border-bottom: 1px solid var(--border-color); vertical-align: middle;
    }
    .tracking-table tbody tr { transition: background-color 0.2s; }
    .tracking-table tbody tr:hover { background-color: #F9FAFB; }
    .tracking-table tbody tr:last-child td { border-bottom: none; }
    
    .route-arrow { color: var(--brand-orange); font-size: 10px; margin: 0 8px; }

    /* Status Badges */
    .status-badge {
        padding: 6px 16px; border-radius: 20px; font-weight: 600; font-size: 12px;
        display: inline-flex; align-items: center; justify-content: center; min-width: 120px;
    }
    
    .status-badge.Booked { background: #E0F2FE; color: #0284C7; }
    .status-badge.Container-Allocated { background: #FEF3C7; color: #D97706; }
    .status-badge.Departed { background: #FFEBE0; color: var(--brand-orange); }
    .status-badge.In-Transit { background: #DBEAFE; color: #1E40AF; }
    .status-badge.Customs-Hold { background: #FEE2E2; color: #DC2626; }
    .status-badge.Arrived, .status-badge.Delivered { background: #DCFCE7; color: #16A34A; }

    /* Update Button */
    .btn-update {
        background: white; border: 1px solid var(--border-color); color: var(--text-dark);
        padding: 6px 16px; border-radius: 6px; font-size: 12px; font-weight: 600;
        transition: all 0.2s; cursor: pointer;
    }
    .btn-update:hover { background: #F3F4F6; border-color: #D1D5DB; }

    /* Custom Modal */
    .modal-content { border-radius: 16px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
    .modal-header { border-bottom: 1px solid var(--border-color); padding: 20px 24px; }
    .modal-title { font-weight: 700; font-size: 18px; color: var(--text-dark); }
    .modal-body { padding: 24px; }
    .modal-footer { border-top: 1px solid var(--border-color); padding: 20px 24px; }
    .form-select-custom {
        padding: 12px 16px; border-radius: 8px; border: 1px solid var(--border-color);
        font-size: 14px; font-weight: 500; color: var(--text-dark); width: 100%; margin-top: 8px;
    }
    .form-label { font-size: 13px; font-weight: 600; color: var(--text-muted); }
    
    .btn-icon-action {
        width: 32px;
        height: 32px;
        border-radius: 8px;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 15px;
        cursor: pointer;
        text-decoration: none;
        transition: all 0.18s ease;
        padding: 0;
    }
    .btn-icon-action.edit {
        color: #475569;
    }
    .btn-icon-action.edit:hover {
        color: #2563EB;
        background: #EFF6FF;
        border-color: #BFDBFE;
        transform: translateY(-1px);
        box-shadow: 0 2px 6px rgba(37, 99, 235, 0.12);
    }
    .btn-icon-action.delete {
        color: #475569;
    }
    .btn-icon-action.delete:hover {
        color: #DC2626;
        background: #FEF2F2;
        border-color: #FECACA;
        transform: translateY(-1px);
        box-shadow: 0 2px 6px rgba(220, 38, 38, 0.12);
    }

    /* Premium Modern Confirmation Modal */
    .modal-dialog-confirm {
        max-width: 480px;
        margin: 1.75rem auto;
    }
    .modal-content-confirm {
        background: #FFFFFF;
        border: 1px solid #E7E9ED;
        border-radius: 16px;
        box-shadow: 0 20px 45px -10px rgba(15, 23, 42, 0.18), 0 8px 20px -6px rgba(15, 23, 42, 0.08);
        padding: 24px 28px;
        border: none;
        overflow: hidden;
    }
    .confirm-modal-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 16px;
    }
    .confirm-icon-box {
        width: 44px;
        height: 44px;
        border-radius: 10px;
        background: #FEE2E2;
        color: #DC2626;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        flex-shrink: 0;
    }
    .confirm-title {
        font-size: 17px;
        font-weight: 700;
        color: #111827;
        margin: 0 0 2px 0;
        letter-spacing: -0.2px;
    }
    .confirm-subtitle {
        font-size: 12px;
        color: #EF4444;
        font-weight: 600;
    }
    .confirm-text {
        font-size: 13.5px;
        color: #475569;
        line-height: 1.55;
        margin-bottom: 22px;
        background: #F8FAFC;
        padding: 12px 16px;
        border-radius: 10px;
        border: 1px solid #E2E8F0;
    }
    .confirm-btn-row {
        display: flex;
        gap: 12px;
    }
    .btn-modal-cancel {
        flex: 1;
        height: 42px;
        border-radius: 10px;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        color: #475569;
        font-size: 13.5px;
        font-weight: 600;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        white-space: nowrap !important;
        transition: all 0.15s ease;
    }
    .btn-modal-cancel:hover {
        background: #F8FAFC;
        border-color: #CBD5E1;
        color: #1E293B;
    }
    .btn-modal-danger {
        flex: 1;
        height: 42px;
        border-radius: 10px;
        border: 1px solid #DC2626;
        background: #DC2626;
        color: #FFFFFF !important;
        font-size: 13.5px;
        font-weight: 600;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        white-space: nowrap !important;
        box-shadow: 0 2px 6px rgba(220, 38, 38, 0.25);
        transition: all 0.15s ease;
    }
    .btn-modal-danger:hover {
        background: #B91C1C;
        border-color: #B91C1C;
        color: #FFFFFF !important;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(220, 38, 38, 0.35);
    }


    .btn-profit-loss {
        background: #FFF2EB;
        color: #FC8019 !important;
        border: 1.5px solid #FFD4C2;
        padding: 10px 20px;
        border-radius: 50px !important;
        font-size: 13px;
        font-weight: 600;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        transition: all 0.2s ease;
    }
    .btn-profit-loss:hover {
        background: #FC8019;
        color: #FFFFFF !important;
        border-color: #FC8019;
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.25);
        transform: translateY(-1px);
    }
    [data-theme="dark"] .btn-profit-loss {
        background: rgba(252, 128, 25, 0.15) !important;
        color: #FC8019 !important;
        border-color: rgba(252, 128, 25, 0.35) !important;
        border-radius: 50px !important;
    }
    [data-theme="dark"] .btn-profit-loss:hover {
        background: #FC8019 !important;
        color: #FFFFFF !important;
        border-color: #FC8019 !important;
    }
    .btn-icon-action.drilldown {
        background: #EFF6FF;
        color: #2563EB;
    }
    .btn-icon-action.drilldown:hover {
        background: #2563EB;
        color: #FFFFFF;
        box-shadow: 0 2px 6px rgba(37, 99, 235, 0.3);
    }

    /* ========================================================
       CONTAINER ALLOCATION WORKBENCH MASTER DESIGN SYSTEM
       ======================================================== */
    #allocateContainerModal .modal-content {
        border-radius: 16px !important;
        border: 1px solid #E2E8F0 !important;
        box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.25) !important;
        overflow: hidden !important;
        background: #FFFFFF !important;
    }
    #allocateContainerModal .modal-header {
        background: linear-gradient(135deg, #1E293B 0%, #0F172A 100%) !important;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1) !important;
        padding: 20px 26px !important;
    }
    #allocateContainerModal .modal-header .modal-title {
        color: #FFFFFF !important;
        font-weight: 700 !important;
        font-size: 17px !important;
        letter-spacing: -0.2px !important;
    }
    #allocateContainerModal .modal-header small {
        color: #94A3B8 !important;
        font-size: 12px !important;
        display: block !important;
        margin-top: 2px !important;
    }
    #allocateContainerModal .modal-header .btn-close {
        filter: invert(1) grayscale(100%) brightness(200%) !important;
        opacity: 0.85 !important;
        transition: opacity 0.2s ease, transform 0.2s ease !important;
    }
    #allocateContainerModal .modal-header .btn-close:hover {
        opacity: 1 !important;
        transform: scale(1.08) !important;
    }
    #allocateContainerModal .alloc-cargo-card {
        background: rgba(245, 158, 11, 0.08) !important;
        border: 1px solid rgba(245, 158, 11, 0.25) !important;
        border-radius: 12px !important;
        padding: 16px 20px !important;
    }
    #allocateContainerModal .alloc-cargo-card .alloc-shipment-pill {
        background: rgba(252, 128, 25, 0.15) !important;
        color: #D97706 !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
        font-size: 12px !important;
        font-weight: 700 !important;
        padding: 4px 10px !important;
        border-radius: 6px !important;
    }
    #allocateContainerModal .alloc-table-wrapper {
        border: 1.5px solid #E2E8F0 !important;
        border-radius: 12px !important;
        overflow: hidden !important;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.02) !important;
    }
    #allocateContainerModal table thead th {
        background: #F8FAFC !important;
        color: #64748B !important;
        font-size: 11px !important;
        font-weight: 700 !important;
        text-transform: uppercase !important;
        letter-spacing: 0.5px !important;
        border-bottom: 1.5px solid #E2E8F0 !important;
        padding: 12px 16px !important;
    }
    #allocateContainerModal table tbody td {
        padding: 12px 16px !important;
        vertical-align: middle !important;
        border-bottom: 1px solid #F1F5F9 !important;
        transition: background-color 0.15s ease !important;
        color: #0F172A !important;
    }
    #allocateContainerModal table tbody tr:last-child td {
        border-bottom: none !important;
    }
    #allocateContainerModal table tbody tr:hover {
        background-color: #F8FAFC !important;
    }
    #allocateContainerModal table tbody tr.selected-row,
    #allocateContainerModal table tbody tr:has(input[type="radio"]:checked) {
        background-color: rgba(252, 128, 25, 0.08) !important;
    }
    #allocateContainerModal input[type="radio"].form-check-input {
        width: 18px !important;
        height: 18px !important;
        cursor: pointer !important;
    }
    #allocateContainerModal input[type="radio"].form-check-input:checked {
        background-color: #FC8019 !important;
        border-color: #FC8019 !important;
    }
    #allocateContainerModal .alloc-type-pill {
        background: #F1F5F9 !important;
        color: #334155 !important;
        border: 1px solid #CBD5E1 !important;
        font-weight: 600 !important;
        font-size: 11px !important;
        border-radius: 6px !important;
        padding: 3px 8px !important;
    }
    #allocateContainerModal .alloc-input-remarks {
        border-radius: 50px !important;
        padding: 10px 20px !important;
        font-size: 13.5px !important;
        border: 1.5px solid #E2E8F0 !important;
        transition: border-color 0.2s, box-shadow 0.2s !important;
        outline: none !important;
    }
    #allocateContainerModal .alloc-input-remarks:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3.5px rgba(252, 128, 25, 0.16) !important;
    }
    #allocateContainerModal .modal-footer {
        background: #F8FAFC !important;
        border-top: 1px solid #E2E8F0 !important;
        padding: 16px 24px !important;
    }
    #allocateContainerModal .btn-alloc-cancel {
        background: #FFFFFF !important;
        border: 1px solid #E2E8F0 !important;
        color: #475569 !important;
        padding: 9px 22px !important;
        border-radius: 50px !important;
        font-weight: 500 !important;
        font-size: 13px !important;
        transition: all 0.18s ease !important;
    }
    #allocateContainerModal .btn-alloc-cancel:hover {
        background: #F1F5F9 !important;
        color: #0F172A !important;
    }
    #allocateContainerModal .btn-alloc-confirm {
        background: linear-gradient(135deg, #FC8019 0%, #FF6600 100%) !important;
        border: none !important;
        color: #FFFFFF !important;
        padding: 9px 24px !important;
        border-radius: 50px !important;
        font-weight: 600 !important;
        font-size: 13.5px !important;
        display: inline-flex !important;
        align-items: center !important;
        gap: 6px !important;
        box-shadow: 0 2px 8px rgba(252, 128, 25, 0.25) !important;
        transition: all 0.18s ease !important;
    }
    #allocateContainerModal .btn-alloc-confirm:hover:not(:disabled) {
        background: linear-gradient(135deg, #F97316 0%, #EA580C 100%) !important;
        transform: translateY(-1px) !important;
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.35) !important;
    }
    #allocateContainerModal .btn-alloc-confirm:disabled {
        opacity: 0.55 !important;
        cursor: not-allowed !important;
        box-shadow: none !important;
        transform: none !important;
    }

    /* Dark Mode Overrides */
    [data-theme="dark"] #allocateContainerModal .modal-content {
        background: #121A22 !important;
        border-color: #243240 !important;
        color: #F8FAFC !important;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.7) !important;
    }
    [data-theme="dark"] #allocateContainerModal .modal-header {
        background: #0B1117 !important;
        border-bottom-color: #1A252E !important;
    }
    [data-theme="dark"] #allocateContainerModal .modal-header .modal-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] #allocateContainerModal .alloc-cargo-card {
        background: rgba(245, 158, 11, 0.12) !important;
        border-color: rgba(245, 158, 11, 0.3) !important;
    }
    [data-theme="dark"] #allocateContainerModal .alloc-cargo-card strong,
    [data-theme="dark"] #allocateContainerModal .alloc-cargo-card span {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] #allocateContainerModal .alloc-table-wrapper {
        border-color: #22303A !important;
    }
    [data-theme="dark"] #allocateContainerModal table thead th {
        background: #151F28 !important;
        border-bottom-color: #22303A !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] #allocateContainerModal table tbody td {
        border-bottom-color: #1C2732 !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] #allocateContainerModal table tbody tr:hover {
        background-color: #18232F !important;
    }
    [data-theme="dark"] #allocateContainerModal table tbody tr.selected-row,
    [data-theme="dark"] #allocateContainerModal table tbody tr:has(input[type="radio"]:checked) {
        background-color: rgba(252, 128, 25, 0.15) !important;
    }
    [data-theme="dark"] #allocateContainerModal .alloc-type-pill {
        background: #1C2732 !important;
        color: #CBD5E1 !important;
        border-color: #2D3D4D !important;
    }
    [data-theme="dark"] #allocateContainerModal .alloc-input-remarks {
        background: #151F28 !important;
        border-color: #22303A !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] #allocateContainerModal .alloc-input-remarks::placeholder {
        color: #64748B !important;
    }
    [data-theme="dark"] #allocateContainerModal .modal-footer {
        background: #0E151D !important;
        border-top-color: #1A252E !important;
    }
    [data-theme="dark"] #allocateContainerModal .btn-alloc-cancel {
        background: #151F28 !important;
        border-color: #22303A !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] #allocateContainerModal .btn-alloc-cancel:hover {
        background: #1E2B38 !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .status-badge.Booked {
        background: rgba(2, 132, 199, 0.18) !important;
        color: #38BDF8 !important;
        border: 1px solid rgba(2, 132, 199, 0.35) !important;
    }
    [data-theme="dark"] .status-badge.Container-Allocated {
        background: rgba(245, 158, 11, 0.18) !important;
        color: #FBBF24 !important;
        border: 1px solid rgba(245, 158, 11, 0.35) !important;
    }
</style>

<div class="main-content">
    <div class="page-header-flex">
        <div>
            <h2 style="font-weight: 700; margin-bottom: 8px; color: var(--text-dark);">All Shipments</h2>
            <div class="custom-breadcrumb d-flex align-items-center" style="margin-bottom: 0;">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <i class="fa-solid fa-angle-right custom-breadcrumb-separator"></i>
                <a href="${pageContext.request.contextPath}/shipments">Shipments</a>
                <i class="fa-solid fa-angle-right custom-breadcrumb-separator"></i>
                <span class="active">All Shipments</span>
            </div>
        </div>
    </div>

        <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success alert-dismissible fade show mb-4" role="alert" style="border-radius: 10px; border: 1px solid #A7F3D0; background: #ECFDF5; color: #065F46; font-size: 14px; font-weight: 500;">
            <i class="ti ti-circle-check me-2" style="font-size: 17px; vertical-align: -2px;"></i> ${sessionScope.successMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert" style="border-radius: 10px; border: 1px solid #FECACA; background: #FEF2F2; color: #991B1B; font-size: 14px; font-weight: 500;">
            <i class="ti ti-alert-circle me-2" style="font-size: 17px; vertical-align: -2px;"></i> ${sessionScope.errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <!-- Filter & Action Row -->
    <div class="filter-card">
        <div class="filter-search">
            <i class="fa-solid fa-magnifying-glass search-icon"></i>
            <input type="text" id="shipmentSearchInput" placeholder="Search by ID, Customer, Container, or Route...">
            <i class="fa-solid fa-xmark clear-icon d-none" id="clearSearchBtn" title="Clear Search"></i>
        </div>
        <div class="d-flex align-items-center gap-2">
            <%-- Cost structure & margins: Super Admin, Company Admin, Finance only --%>
            <c:if test="${sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2 || sessionScope.user.roleId == 4}">
                <a href="${pageContext.request.contextPath}/finance/profit-loss" class="btn-profit-loss" title="View Profit &amp; Loss Trend Graph &amp; Cost Attribution">
                    Profit &amp; Loss Analytics
                </a>
            </c:if>
            <%-- Finance staff do not create bookings --%>
            <c:if test="${sessionScope.user.roleId != 4}">
                <a href="${pageContext.request.contextPath}/shipments/create" class="btn-book">
                    Book Shipment
                </a>
            </c:if>
        </div>
    </div>

    <!-- Table Card -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <table class="tracking-table">
            <thead>
                <tr>
                    <th class="sortable" onclick="sortTable(0)">ID <i class="fa-solid fa-sort ms-1"></i></th>
                    <th class="sortable" onclick="sortTable(1)">Customer <i class="fa-solid fa-sort ms-1"></i></th>
                    <th>Container ID</th>
                    <th>Route Plan</th>
                    <th class="sortable" onclick="sortTable(4)">Booking Date <i class="fa-solid fa-sort ms-1"></i></th>
                    <th style="text-align: center;">Status</th>
                    <th style="text-align: center;">Action</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="s" items="${shipments}">
                    <tr>
                        <td style="color: var(--text-muted);">#${s.shipmentId}</td>
                        <td style="font-weight: 700;">${s.customerName}</td>
                        <td style="font-family: monospace;">
                            <c:choose>
                                <c:when test="${s.status == 'Booked'}">
                                    <span class="badge" style="background: rgba(245, 158, 11, 0.15); color: #D97706; border: 1px solid rgba(245, 158, 11, 0.35); font-size: 11px; padding: 4px 8px; border-radius: 6px; font-weight: 600;">
                                        <i class="ti ti-clock me-1"></i> Pending Allocation
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge" style="background: rgba(252, 128, 25, 0.12); color: #FC8019; border: 1px solid rgba(252, 128, 25, 0.25); font-size: 11.5px; font-family: monospace, monospace; padding: 4px 8px; border-radius: 6px; font-weight: 700;">
                                        <i class="ti ti-box me-1"></i>#${not empty s.containerNumber ? s.containerNumber : 'ALLOCATED'}
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <div style="display: flex; align-items: center;">
                                <span>${s.originPort}</span>
                                <i class="fa-solid fa-arrow-right route-arrow"></i>
                                <span>${s.destPort}</span>
                            </div>
                        </td>
                        <td>${s.bookingDate}</td>
                        <td style="text-align: center;">
                            <span class="status-badge ${s.status.replace(' ', '-')}">${s.status}</span>
                        </td>
                        <td style="text-align: center;">
                            <div style="display: flex; gap: 8px; justify-content: center; align-items: center;">
                                <%-- Container Allocation Workbench: Role 1, 2, 3 only, for Booked shipments (FR3.3 / FR3.4) --%>
                                <c:if test="${(sessionScope.user.roleId <= 3 || sessionScope.roleId <= 3 || sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2 || sessionScope.user.roleId == 3) && s.status == 'Booked'}">
                                    <button type="button" class="btn btn-sm btn-warning text-dark fw-bold px-2 py-1 d-inline-flex align-items-center gap-1" style="border-radius: 6px; font-size: 11.5px; background: #F59E0B; border: none; box-shadow: 0 2px 4px rgba(245,158,11,0.25);" onclick="openAllocationWorkbench(${s.shipmentId})" title="Allocate Container (FR3.3 / FR3.4)">
                                        <i class="ti ti-box"></i> Allocate
                                    </button>
                                </c:if>

                                <%-- Financial Drilldown: Admins & Finance only (CLAUDE.md S3.5.6) --%>
                                <c:if test="${sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2 || sessionScope.user.roleId == 4}">
                                    <a href="${pageContext.request.contextPath}/finance/shipment-drilldown?id=${s.shipmentId}" class="btn-icon-action drilldown" title="Financial Drilldown &amp; Loss Attribution">
                                        <i class="ti ti-chart-arrows-vertical"></i>
                                    </a>
                                </c:if>
                                <%-- Edit & checkpoint updates: Admins (Super & Company) & Operations only --%>
                                <c:if test="${sessionScope.user.roleId <= 3 || sessionScope.roleId <= 3 || sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2 || sessionScope.roleId == 1 || sessionScope.roleId == 2 || sessionScope.user.hasPermission('tracking')}">
                                    <a href="${pageContext.request.contextPath}/shipments/edit?id=${s.shipmentId}" class="btn-icon-action edit" title="Edit Shipment">
                                        <i class="ti ti-pencil"></i>
                                    </a>
                                    <button type="button" class="btn-icon-action" data-bs-toggle="modal" data-bs-target="#updateModal${s.shipmentId}" title="Update Checkpoint Status">
                                        <i class="ti ti-refresh"></i>
                                    </button>
                                </c:if>
                                <%-- Deletion of core records: Super Admin only --%>
                                <c:if test="${sessionScope.user.roleId == 1}">
                                    <button class="btn-icon-action delete" data-bs-toggle="modal" data-bs-target="#deleteModal${s.shipmentId}" title="Delete Shipment">
                                        <i class="ti ti-trash"></i>
                                    </button>
                                </c:if>
                                <%-- Live tracking timeline: available to every role --%>
                                <a href="${pageContext.request.contextPath}/shipments/tracking/detail?id=SHP-${s.shipmentId}" class="btn-icon-action" title="View Live Tracking Timeline">
                                    <i class="ti ti-map-pin"></i>
                                </a>
                            </div>
                        </td>
                    </tr>

                    <!-- Update Modal -->
                    <div class="modal fade" id="updateModal${s.shipmentId}" tabindex="-1">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content">
                                <form action="${pageContext.request.contextPath}/shipments/updateStatus" method="POST">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Update Status: #${s.shipmentId}</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>
                                    <div class="modal-body">
                                        <input type="hidden" name="shipmentId" value="${s.shipmentId}">
                                        <label class="form-label">Select New Checkpoint</label>
                                        <select name="status" class="form-select-custom">
                                            <option value="Container Allocated">Container Allocated</option>
                                            <option value="Departed">Departed</option>
                                            <option value="In Transit">In Transit</option>
                                            <option value="Customs Hold">Customs Hold</option>
                                            <option value="Arrived">Arrived</option>
                                            <option value="Delivered">Delivered</option>
                                        </select>
                                    </div>
                                    <div class="modal-footer" style="background: #F9FAFB;">
                                        <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius: 8px; font-weight: 500;">Cancel</button>
                                        <button type="submit" class="btn-book" style="margin: 0;">Save Changes</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- Delete Modal -->
                    <div class="modal fade" id="deleteModal${s.shipmentId}" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered modal-dialog-confirm">
                            <div class="modal-content modal-content-confirm">
                                <form action="${pageContext.request.contextPath}/shipments/delete" method="POST">
                                    <input type="hidden" name="id" value="${s.shipmentId}">
                                    <input type="hidden" name="shipmentId" value="${s.shipmentId}">
                                    <div class="confirm-modal-header">
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="confirm-icon-box">
                                                <i class="ti ti-trash"></i>
                                            </div>
                                            <div>
                                                <h5 class="confirm-title">Delete Shipment #${s.shipmentId}?</h5>
                                                <span class="confirm-subtitle">Permanent action &bull; Cannot be undone</span>
                                            </div>
                                        </div>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="confirm-text">
                                        Are you sure you want to permanently delete shipment <strong>#${s.shipmentId}</strong> for <strong>${s.customerName}</strong>? This action cannot be undone and will erase all tracking records.
                                    </div>
                                    <div class="confirm-btn-row">
                                        <button type="button" class="btn-modal-cancel" data-bs-dismiss="modal">Cancel</button>
                                        <button type="submit" class="btn-modal-danger">
                                            <i class="ti ti-trash"></i>
                                            <span>Delete Permanently</span>
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <c:if test="${empty shipments}">
                    <tr>
                        <td colspan="7" style="text-align: center; padding: 48px; color: var(--text-muted);">
                            <i class="fa-solid fa-box-open" style="font-size: 32px; color: #D1D5DB; margin-bottom: 16px; display: block;"></i>
                            No shipments found in the system.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>

        <!-- Enterprise Theme Pagination Bar -->
        <div class="nl-pagination-wrapper" id="shipmentPagination">
            <div class="nl-pagination-info">
                <span>Showing <strong id="shipmentPageStart">1</strong> to <strong id="shipmentPageEnd">10</strong> of <strong id="shipmentTotalRows">0</strong> shipments</span>
                <div class="d-inline-flex align-items-center gap-2 ms-2">
                    <span style="color: #94A3B8; font-size: 12.5px;">Rows per page:</span>
                    <select id="shipmentPageSize" class="nl-page-size-select no-custom-select">
                        <option value="10" selected>10</option>
                        <option value="25">25</option>
                        <option value="50">50</option>
                        <option value="100">100</option>
                    </select>
                </div>
            </div>
            <div class="nl-pagination-nav" id="shipmentPageNav">
                <!-- Dynamically generated buttons -->
            </div>
        </div>
    </div>
<!-- Container Allocation Workbench Modal (FR3.3 / FR3.4) -->
<div class="modal fade" id="allocateContainerModal" tabindex="-1" aria-labelledby="allocateContainerModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <div class="d-flex align-items-center gap-3">
                    <div style="width: 42px; height: 42px; background: rgba(245, 158, 11, 0.16); border: 1px solid rgba(245, 158, 11, 0.35); border-radius: 10px; display: flex; align-items: center; justify-content: center; color: #FC8019; font-size: 20px;">
                        <i class="ti ti-box"></i>
                    </div>
                    <div>
                        <h5 class="modal-title mb-0" id="allocateContainerModalLabel">Container Allocation Workbench</h5>
                        <small>SRS FR3.3 &amp; FR3.4 &bull; Physical fleet assignment &amp; capacity verification</small>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <form action="${pageContext.request.contextPath}/shipments/allocateContainer" method="POST" id="allocateForm">
                <input type="hidden" name="shipmentId" id="allocShipmentId" value="">
                
                <div class="modal-body" style="padding: 24px; max-height: 75vh; overflow-y: auto;">
                    <!-- Loading state -->
                    <div id="allocLoading" class="text-center py-5">
                        <div class="spinner-border text-warning mb-3" role="status" style="width: 2.5rem; height: 2.5rem;"></div>
                        <div style="font-weight: 600; color: var(--text-dark);">Inspecting Fleet Availability...</div>
                        <div style="font-size: 12.5px; color: var(--text-muted);">Fetching certified containers and capacity gates</div>
                    </div>

                    <!-- Content container -->
                    <div id="allocContent" style="display: none;">
                        <!-- Shipment Cargo Specs Card -->
                        <div class="alloc-cargo-card mb-4">
                            <div class="d-flex justify-content-between align-items-center mb-2 flex-wrap gap-2">
                                <span style="font-weight: 700; font-size: 14px;">
                                    Shipment <span id="allocShipmentBadge" class="alloc-shipment-pill ms-1">#SHP-</span>
                                </span>
                                <span id="allocCustomerName" style="font-size: 13.5px; font-weight: 700;">Customer</span>
                            </div>
                            <div class="row g-2 pt-2 border-top" style="border-color: rgba(245,158,11,0.2) !important; font-size: 13px;">
                                <div class="col-sm-6">
                                    <span style="color: var(--text-muted);"><i class="ti ti-map-pin me-1" style="color: #FC8019;"></i>Route:</span>
                                    <strong id="allocRoute" class="ms-1">Origin &rarr; Dest</strong>
                                </div>
                                <div class="col-sm-3">
                                    <span style="color: var(--text-muted);"><i class="ti ti-weight me-1" style="color: #3B82F6;"></i>Weight:</span>
                                    <strong id="allocWeight" class="ms-1">0 kg</strong>
                                </div>
                                <div class="col-sm-3">
                                    <span style="color: var(--text-muted);"><i class="ti ti-dimensions me-1" style="color: #10B981;"></i>Volume:</span>
                                    <strong id="allocVolume" class="ms-1">0 CBM</strong>
                                </div>
                            </div>
                        </div>

                        <!-- Available Container Fleet Section -->
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <label class="form-label fw-bold mb-0" style="font-size: 13.5px; color: var(--text-dark);">
                                Select Available Physical Container <span class="text-danger">*</span>
                            </label>
                            <span id="allocContainerCount" class="badge bg-secondary" style="font-size: 11px;">0 Available</span>
                        </div>

                        <div class="table-responsive alloc-table-wrapper mb-3" style="max-height: 280px; overflow-y: auto;">
                            <table class="table table-hover align-middle mb-0" style="font-size: 13px;">
                                <thead style="position: sticky; top: 0; z-index: 2;">
                                    <tr>
                                        <th style="width: 50px; text-align: center;">Pick</th>
                                        <th>Container No</th>
                                        <th>Type &amp; Size</th>
                                        <th>Current Depot</th>
                                        <th>Capacity Limits</th>
                                        <th style="text-align: center;">FR3.4 Gate</th>
                                    </tr>
                                </thead>
                                <tbody id="allocContainerTbody">
                                    <!-- Dynamic rows -->
                                </tbody>
                            </table>
                        </div>

                        <!-- Operational Remarks -->
                        <div class="mb-3">
                            <label class="form-label fw-semibold" style="font-size: 13px; color: var(--text-dark);">
                                Dispatch Remarks / Depot Inspection Note (Optional)
                            </label>
                            <input type="text" name="remarks" id="allocRemarks" class="form-control alloc-input-remarks w-100" placeholder="e.g. Assigned from Nhava Sheva Yard 3 &bull; Visual inspection verified">
                        </div>
                    </div>

                    <div id="allocEmpty" class="text-center py-4" style="display: none;">
                        <i class="ti ti-alert-circle text-danger mb-2" style="font-size: 32px;"></i>
                        <div class="fw-bold text-danger">No Available Containers Found</div>
                        <div class="text-muted" style="font-size: 12.5px;">All fleet units are currently Allocated or In-Transit. Please add or free up containers first.</div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-alloc-cancel" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" id="allocSubmitBtn" class="btn btn-alloc-confirm" disabled>
                        <i class="ti ti-check"></i>
                        <span>Confirm &amp; Allocate Container</span>
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>


<script>
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('shipmentSearchInput');
    const searchBtn = document.getElementById('searchBtn');
    const clearBtn = document.getElementById('clearSearchBtn');
    const table = document.querySelector('.tracking-table tbody');
    const pageSizeSelect = document.getElementById('shipmentPageSize');
    const pageNav = document.getElementById('shipmentPageNav');
    const pageStartEl = document.getElementById('shipmentPageStart');
    const pageEndEl = document.getElementById('shipmentPageEnd');
    const totalRowsEl = document.getElementById('shipmentTotalRows');

    if (!table) return;

    let currentPage = 1;
    let pageSize = parseInt(pageSizeSelect ? pageSizeSelect.value : 10, 10);
    let matchingRows = [];

    function updatePagination() {
        const total = matchingRows.length;
        const totalPages = Math.ceil(total / pageSize) || 1;

        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        const startIndex = total === 0 ? 0 : (currentPage - 1) * pageSize;
        const endIndex = Math.min(startIndex + pageSize, total);

        if (pageStartEl) pageStartEl.textContent = total === 0 ? '0' : (startIndex + 1);
        if (pageEndEl) pageEndEl.textContent = endIndex;
        if (totalRowsEl) totalRowsEl.textContent = total;

        const allDataRows = table.querySelectorAll('tr:not(.no-results-row)');
        allDataRows.forEach(row => { row.style.display = 'none'; });

        for (let i = startIndex; i < endIndex; i++) {
            if (matchingRows[i]) {
                matchingRows[i].style.display = '';
            }
        }

        renderPageButtons(totalPages);
    }

    function renderPageButtons(totalPages) {
        if (!pageNav) return;
        pageNav.innerHTML = '';

        if (totalPages <= 1 && matchingRows.length <= pageSize) {
            return;
        }

        const prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'nl-page-btn nl-page-nav-btn' + (currentPage === 1 ? ' disabled' : '');
        prevBtn.innerHTML = '<i class="ti ti-chevron-left"></i> Prev';
        prevBtn.addEventListener('click', function(e) {
            e.preventDefault();
            if (currentPage > 1) {
                currentPage--;
                updatePagination();
            }
        });
        pageNav.appendChild(prevBtn);

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
                        updatePagination();
                    }
                });
                pageNav.appendChild(btn);
            }
        });

        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'nl-page-btn nl-page-nav-btn' + (currentPage === totalPages ? ' disabled' : '');
        nextBtn.innerHTML = 'Next <i class="ti ti-chevron-right"></i>';
        nextBtn.addEventListener('click', function(e) {
            e.preventDefault();
            if (currentPage < totalPages) {
                currentPage++;
                updatePagination();
            }
        });
        pageNav.appendChild(nextBtn);
    }

    function performSearch() {
        const query = searchInput ? searchInput.value.toLowerCase().trim() : '';
        const allDataRows = Array.from(table.querySelectorAll('tr:not(.no-results-row)'));
        matchingRows = [];

        allDataRows.forEach(function(row) {
            const cells = Array.from(row.querySelectorAll('td')).slice(0, 6);
            const rowText = cells.map(td => td.textContent.toLowerCase()).join(' ');

            if (!query || rowText.includes(query)) {
                matchingRows.push(row);
            }
        });

        if (clearBtn) {
            if (query.length > 0) {
                clearBtn.classList.remove('d-none');
            } else {
                clearBtn.classList.add('d-none');
            }
        }

        let noResults = document.getElementById('noSearchResultsRow');
        if (matchingRows.length === 0 && allDataRows.length > 0) {
            if (!noResults) {
                noResults = document.createElement('tr');
                noResults.id = 'noSearchResultsRow';
                noResults.className = 'no-results-row';
                noResults.innerHTML = '<td colspan="7" style="text-align: center; padding: 48px; color: var(--text-muted);">' +
                    '<i class="ti ti-search" style="font-size: 28px; color: #D1D5DB; margin-bottom: 12px; display: block;"></i>' +
                    'No shipments matching "' + (searchInput ? searchInput.value : '') + '"</td>';
                table.appendChild(noResults);
            } else {
                noResults.style.display = '';
                noResults.querySelector('td').innerHTML = '<i class="ti ti-search" style="font-size: 28px; color: #D1D5DB; margin-bottom: 12px; display: block;"></i>No shipments matching "' + (searchInput ? searchInput.value : '') + '"';
            }
        } else if (noResults) {
            noResults.style.display = 'none';
        }

        currentPage = 1;
        updatePagination();
    }

    if (pageSizeSelect) {
        pageSizeSelect.addEventListener('change', function() {
            pageSize = parseInt(this.value, 10);
            currentPage = 1;
            updatePagination();
        });
    }

    if (searchInput) {
        searchInput.addEventListener('input', performSearch);
        searchInput.addEventListener('keydown', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                performSearch();
            }
        });
    }

    if (clearBtn) {
        clearBtn.addEventListener('click', function() {
            if (searchInput) {
                searchInput.value = '';
                searchInput.focus();
            }
            performSearch();
        });
    }

    if (searchBtn) {
        searchBtn.addEventListener('click', performSearch);
    }

    window.refreshPaginationAfterSort = function() {
        performSearch();
    };

    performSearch();
});

let sortDirections = [true, true, true, true, true];

function sortTable(columnIndex) {
    const table = document.querySelector(".tracking-table tbody");
    if (!table) return;
    const rows = Array.from(table.querySelectorAll("tr:not(.no-results-row)"));

    const isAscending = sortDirections[columnIndex];
    sortDirections[columnIndex] = !isAscending;

    rows.sort((rowA, rowB) => {
        let valA = rowA.children[columnIndex].innerText.trim();
        let valB = rowB.children[columnIndex].innerText.trim();

        if (columnIndex === 0) {
            valA = parseInt(valA.replace('#', '')) || 0;
            valB = parseInt(valB.replace('#', '')) || 0;
            return isAscending ? valA - valB : valB - valA;
        }

        return isAscending ? valA.localeCompare(valB) : valB.localeCompare(valA);
    });

    rows.forEach(row => table.appendChild(row));
    if (window.refreshPaginationAfterSort) window.refreshPaginationAfterSort();
}

function openAllocationWorkbench(shipmentId) {
    const modalEl = document.getElementById('allocateContainerModal');
    if (!modalEl) return;
    const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
    modal.show();

    document.getElementById('allocShipmentId').value = shipmentId;
    document.getElementById('allocLoading').style.display = 'block';
    document.getElementById('allocContent').style.display = 'none';
    document.getElementById('allocEmpty').style.display = 'none';
    document.getElementById('allocSubmitBtn').disabled = true;

    fetch('${pageContext.request.contextPath}/shipments/availableContainers?shipmentId=' + shipmentId)
        .then(res => res.json())
        .then(data => {
            document.getElementById('allocLoading').style.display = 'none';

            if (data.shipment) {
                const s = data.shipment;
                document.getElementById('allocShipmentBadge').textContent = '#SHP-' + s.shipmentId;
                document.getElementById('allocCustomerName').textContent = s.customerName || 'Customer';
                document.getElementById('allocRoute').textContent = (s.originPort || 'Origin') + ' → ' + (s.destPort || 'Destination');
                document.getElementById('allocWeight').textContent = (s.cargoWeight || 0).toLocaleString() + ' kg';
                document.getElementById('allocVolume').textContent = (s.cargoVolume || 0) + ' CBM';
            }

            const containers = data.containers || [];
            document.getElementById('allocContainerCount').textContent = containers.length + ' Available';

            if (containers.length === 0) {
                document.getElementById('allocEmpty').style.display = 'block';
                return;
            }

            document.getElementById('allocContent').style.display = 'block';
            const tbody = document.getElementById('allocContainerTbody');
            tbody.innerHTML = '';

            let firstValidSelected = false;

            function handleAllocRadioChange(radio) {
                document.getElementById('allocSubmitBtn').disabled = false;
                document.querySelectorAll('#allocContainerTbody tr').forEach(row => row.classList.remove('selected-row'));
                if (radio && radio.checked) {
                    radio.closest('tr')?.classList.add('selected-row');
                }
            }

            containers.forEach(c => {
                const tr = document.createElement('tr');
                const fits = c.fitsAll;
                const matchesOrigin = c.matchesOrigin;

                let badgeHtml = '';
                if (fits) {
                    badgeHtml += '<span class="badge" style="background: rgba(16, 185, 129, 0.12); color: #059669; border: 1px solid rgba(16, 185, 129, 0.25); font-weight: 600; font-size: 11px; padding: 4px 9px; border-radius: 50px;"><i class="ti ti-check me-1"></i>Fits Cargo</span>';
                } else {
                    badgeHtml += '<span class="badge" style="background: rgba(239, 68, 68, 0.12); color: #DC2626; border: 1px solid rgba(239, 68, 68, 0.25); font-weight: 600; font-size: 11px; padding: 4px 9px; border-radius: 50px;"><i class="ti ti-x me-1"></i>Over Capacity</span>';
                }

                if (matchesOrigin) {
                    badgeHtml += '<span class="badge ms-1" style="background: rgba(59, 130, 246, 0.12); color: #2563EB; border: 1px solid rgba(59, 130, 246, 0.25); font-weight: 600; font-size: 11px; padding: 4px 9px; border-radius: 50px;"><i class="ti ti-map-pin me-1"></i>At Origin</span>';
                }

                const radioAttr = fits ? '' : 'disabled';
                const isChecked = (fits && !firstValidSelected) ? 'checked' : '';
                if (fits && !firstValidSelected) {
                    firstValidSelected = true;
                    document.getElementById('allocSubmitBtn').disabled = false;
                    tr.classList.add('selected-row');
                }

                tr.style.cursor = fits ? 'pointer' : 'not-allowed';
                tr.onclick = function(e) {
                    if (fits && e.target.type !== 'radio') {
                        const r = tr.querySelector('input[type="radio"]');
                        if (r && !r.checked) {
                            r.checked = true;
                            handleAllocRadioChange(r);
                        }
                    }
                };

                tr.innerHTML = '<td style="text-align: center;">' +
                        '<input type="radio" name="containerId" value="' + c.containerId + '" class="form-check-input" ' + radioAttr + ' ' + isChecked + ' onchange="handleAllocRadioChange(this);">' +
                    '</td>' +
                    '<td>' +
                        '<strong style="font-family: monospace; color: #FC8019; font-size: 13.5px;">#' + c.containerNumber + '</strong>' +
                        '<div style="font-size: 11.5px; color: var(--text-muted);">' + (c.ownerCompanyName || '') + '</div>' +
                    '</td>' +
                    '<td>' +
                        '<span class="badge alloc-type-pill me-1">' + c.type + '</span>' +
                        '<span class="badge alloc-type-pill">' + c.size + '</span>' +
                    '</td>' +
                    '<td>' +
                        '<div style="font-weight: 600; font-size: 13px;"><i class="ti ti-building-warehouse text-primary me-1"></i>' + c.portName + '</div>' +
                        '<div style="font-size: 11px; color: var(--text-muted);">' + (c.portCountry || '') + '</div>' +
                    '</td>' +
                    '<td>' +
                        '<div style="font-size: 12.5px;">Max: <strong style="font-weight: 700;">' + (c.goodsCapacityKg || c.maxGrossWeightKg || 0).toLocaleString() + ' kg</strong></div>' +
                        '<div style="font-size: 11.5px; color: var(--text-muted);">Vol: <strong>' + (c.goodsCapacityCbm || 0) + ' CBM</strong></div>' +
                    '</td>' +
                    '<td style="text-align: center;">' +
                        badgeHtml +
                    '</td>';
                tbody.appendChild(tr);
            });
        })
        .catch(err => {
            console.error(err);
            document.getElementById('allocLoading').style.display = 'none';
            alert('Failed to load available containers: ' + err.message);
        });
}
</script>

<jsp:include page="/jsp/layout/footer.jsp" />




