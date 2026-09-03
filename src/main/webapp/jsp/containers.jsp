<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* Container Catalog Header */
    .catalog-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-end;
        margin-bottom: 24px;
        flex-wrap: wrap;
        gap: 16px;
    }

    /* Filter & Search Bar */
    .filter-bar-card {
        background: #FFFFFF;
        border-radius: 12px;
        border: 1px solid var(--nl-border);
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03);
        padding: 14px 18px;
        margin-bottom: 24px;
        display: flex;
        align-items: center;
        gap: 14px;
        flex-wrap: wrap;
    }
    .filter-search-box {
        position: relative;
        flex: 1;
        min-width: 240px;
    }
    .filter-search-box i.search-icon {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--nl-text-muted);
        font-size: 15px;
        pointer-events: none;
    }
    .filter-search-box input {
        width: 100%;
        padding: 9px 36px 9px 38px;
        border: 1px solid #E2E5EA;
        border-radius: 8px;
        font-size: 13.5px;
        outline: none;
        background: #FFFFFF;
        color: var(--nl-text);
        transition: border-color 0.15s ease, box-shadow 0.15s ease;
    }
    .filter-search-box input:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .filter-search-clear {
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
    }
    .filter-search-clear:hover {
        color: #1F2937;
    }
    .filter-select-wrap {
        min-width: 160px;
    }

    .btn-add-container {
        background: #FC8019;
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
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25);
        transition: all 0.18s ease;
        text-decoration: none;
    }
    .btn-add-container:hover {
        background: #E66F0F;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.35);
    }

    .btn-reset-filters {
        width: 38px;
        height: 38px;
        border-radius: 8px;
        border: 1px solid #E2E5EA;
        background: #FFFFFF;
        color: var(--nl-text-muted);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 15px;
        cursor: pointer;
        transition: all 0.15s ease;
    }
    .btn-reset-filters:hover {
        background: #F8FAFC;
        color: #FC8019;
        border-color: #CBD5E1;
    }

    /* Container Card */
    .container-card {
        background: #FFFFFF;
        border-radius: 14px;
        border: 1px solid var(--nl-border);
        box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
        overflow: hidden;
        display: flex;
        flex-direction: column;
        height: 100%;
        transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
    }
    .container-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 20px rgba(15, 23, 42, 0.08);
        border-color: #CBD5E1;
    }

    /* Image Banner & Fallback */
    .container-banner {
        height: 165px;
        position: relative;
        background: #0F172A;
        overflow: hidden;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .container-banner img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.3s ease;
    }
    .container-card:hover .container-banner img {
        transform: scale(1.03);
    }
    .container-fallback-banner {
        width: 100%;
        height: 100%;
        background: linear-gradient(135deg, #1E293B 0%, #0F172A 100%);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        color: #FFFFFF;
        padding: 16px;
        text-align: center;
    }

    /* Card Floating Badges */
    .badge-status-pill {
        position: absolute;
        top: 12px;
        right: 12px;
        padding: 5px 12px;
        border-radius: 20px;
        font-weight: 600;
        font-size: 11.5px;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        z-index: 2;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.12);
        white-space: nowrap;
    }
    .badge-status-available {
        background: #ECFDF5;
        color: #059669;
        border: 1px solid #A7F3D0;
    }
    .badge-status-allocated {
        background: #FFF2EB;
        color: #FC8019;
        border: 1px solid #FFD4C2;
    }
    .badge-status-intransit {
        background: #EFF6FF;
        color: #2563EB;
        border: 1px solid #BFDBFE;
    }
    .badge-status-maintenance {
        background: #FFFBEB;
        color: #D97706;
        border: 1px solid #FDE68A;
    }

    .badge-size-pill {
        position: absolute;
        top: 12px;
        left: 12px;
        background: rgba(15, 23, 42, 0.75);
        color: #FFFFFF;
        backdrop-filter: blur(4px);
        border: 1px solid rgba(255, 255, 255, 0.2);
        font-weight: 700;
        font-size: 11.5px;
        padding: 4px 10px;
        border-radius: 6px;
        z-index: 2;
    }

    /* Card Content */
    .container-card-body {
        padding: 18px 20px;
        display: flex;
        flex-direction: column;
        flex: 1;
    }

    .container-title-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 8px;
    }
    .container-number {
        font-size: 16px;
        font-weight: 700;
        color: #0F172A;
        letter-spacing: -0.2px;
        font-family: 'Inter', monospace;
    }
    .container-type-pill {
        background: #F1F5F9;
        color: #475569;
        border: 1px solid #E2E8F0;
        font-weight: 600;
        font-size: 11.5px;
        padding: 3px 9px;
        border-radius: 6px;
        display: inline-flex;
        align-items: center;
        gap: 4px;
    }

    /* Specs List */
    .specs-list {
        list-style: none;
        padding: 0;
        margin: 14px 0 18px 0;
        font-size: 13px;
        color: #64748B;
        display: flex;
        flex-direction: column;
        gap: 8px;
        border-top: 1px dashed #E2E8F0;
        border-bottom: 1px dashed #E2E8F0;
        padding: 12px 0;
    }
    .specs-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .specs-item-label {
        display: flex;
        align-items: center;
        gap: 7px;
        color: #64748B;
        font-size: 12.5px;
    }
    .specs-item-label i {
        font-size: 14px;
        color: #94A3B8;
    }
    .specs-item-value {
        font-weight: 600;
        color: #1F2937;
        font-size: 13px;
    }

    /* Action Buttons */
    .card-actions-row {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-top: auto;
    }
    .btn-allocate {
        flex: 1;
        background: #FC8019;
        color: #FFFFFF !important;
        border: none;
        padding: 9px 16px;
        border-radius: 8px;
        font-weight: 600;
        font-size: 13px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        text-decoration: none;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25);
        transition: all 0.18s ease;
    }
    .btn-allocate:hover {
        background: #E66F0F;
        transform: translateY(-1px);
        box-shadow: 0 4px 10px rgba(252, 128, 25, 0.35);
    }

    .btn-not-available {
        flex: 1;
        background: #F8FAFC;
        color: #94A3B8;
        border: 1px solid #E2E8F0;
        padding: 9px 16px;
        border-radius: 8px;
        font-weight: 600;
        font-size: 13px;
        cursor: not-allowed;
        text-align: center;
    }

    .btn-more-actions {
        width: 38px;
        height: 38px;
        border-radius: 8px;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        color: #64748B;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 16px;
        cursor: pointer;
        transition: all 0.15s ease;
    }
    .btn-more-actions:hover {
        background: #F8FAFC;
        color: #FC8019;
        border-color: #CBD5E1;
    }

    /* Modal Form Customization */
    .modal-content-custom {
        border-radius: 14px;
        border: 1px solid var(--nl-border);
        box-shadow: 0 16px 40px rgba(15, 23, 42, 0.12);
        overflow: hidden;
    }
    .modal-header-custom {
        padding: 20px 24px;
        border-bottom: 1px solid #F1F3F6;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .modal-btn-submit {
        background: #FC8019;
        color: #FFFFFF;
        border: none;
        padding: 9px 22px;
        border-radius: 8px;
        font-weight: 600;
        font-size: 13.5px;
        transition: background-color 0.15s ease;
    }
    .modal-btn-submit:hover {
        background: #E66F0F;
    }
</style>
<div class="container-fluid py-2">
    <!-- Catalog Header -->
    <div class="catalog-header">
        <div>
            <h2 style="font-weight: 700; color: #1F2937; margin-bottom: 4px; font-size: 24px;">Container Master Catalog</h2>
            <p style="color: var(--nl-text-muted); margin-bottom: 0; font-size: 13px;">Browse, monitor, and allocate shipping container inventory</p>
        </div>

        <c:if test="${sessionScope.user.roleId <= 3}">
            <button class="btn-add-container" data-bs-toggle="modal" data-bs-target="#addContainerModal" type="button">
                <i class="ti ti-plus"></i> Add Container
            </button>
        </c:if>
    </div>

    <!-- Interactive Filter & Search Bar -->
    <div class="filter-bar-card">
        <div class="filter-search-box">
            <i class="ti ti-search search-icon"></i>
            <input type="text" id="containerSearchInput" placeholder="Search by container number, type, size...">
            <button class="filter-search-clear d-none" id="clearContainerSearchBtn" type="button"><i class="ti ti-x"></i></button>
        </div>

        <div class="filter-select-wrap">
            <select id="statusFilter" class="form-select form-select-custom">
                <option value="" selected>All Statuses</option>
                <option value="Available">Available</option>
                <option value="Allocated">Allocated</option>
                <option value="In-Transit">In-Transit</option>
                <option value="Under Maintenance">Under Maintenance</option>
            </select>
        </div>

        <div class="filter-select-wrap">
            <select id="typeFilter" class="form-select form-select-custom">
                <option value="" selected>All Types</option>
                <option value="Dry">Dry</option>
                <option value="Reefer">Reefer</option>
                <option value="Open Top">Open Top</option>
                <option value="Flat Rack">Flat Rack</option>
                <option value="Tank">Tank</option>
            </select>
        </div>

        <button class="btn-reset-filters" id="resetContainerFiltersBtn" title="Reset Filters" type="button">
            <i class="ti ti-rotate"></i>
        </button>
    </div>

    <!-- Container Cards Grid -->
    <div class="row g-4" id="containerGrid">
        <c:forEach var="container" items="${containers}">
            <div class="col-12 col-md-6 col-lg-4 col-xl-3 container-col"
                 data-number="${container.containerNumber}"
                 data-type="${container.type}"
                 data-size="${container.size}"
                 data-status="${container.status}">
                <div class="container-card">
                    <!-- Image Banner with Fallback Handlers -->
                    <div class="container-banner">
                        <span class="badge-size-pill">${container.size}</span>

                        <c:choose>
                            <c:when test="${container.status == 'Available'}">
                                <span class="badge-status-pill badge-status-available">
                                    <i class="ti ti-circle-check"></i> Available
                                </span>
                            </c:when>
                            <c:when test="${container.status == 'Allocated'}">
                                <span class="badge-status-pill badge-status-allocated">
                                    <i class="ti ti-box"></i> Allocated
                                </span>
                            </c:when>
                            <c:when test="${container.status == 'In-Transit'}">
                                <span class="badge-status-pill badge-status-intransit">
                                    <i class="ti ti-ship"></i> In-Transit
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge-status-pill badge-status-maintenance">
                                    <i class="ti ti-tool"></i> ${container.status}
                                </span>
                            </c:otherwise>
                        </c:choose>

                        <c:choose>
                            <c:when test="${not empty container.imageUrl}">
                                <img src="${container.imageUrl}" 
                                     alt="Container ${container.containerNumber}"
                                     onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                <div class="container-fallback-banner" style="display: none;">
                                    <div style="width: 52px; height: 52px; background: rgba(252, 128, 25, 0.15); border: 1px solid rgba(252, 128, 25, 0.35); border-radius: 12px; display: flex; align-items: center; justify-content: center; color: #FC8019; font-size: 26px; margin-bottom: 6px;">
                                        <i class="ti ti-box"></i>
                                    </div>
                                    <div style="font-weight: 700; font-size: 13px; font-family: monospace; color: #F8FAFC;">#${container.containerNumber}</div>
                                    <div style="font-size: 11px; color: #94A3B8;">${container.type} &bull; ${container.size}</div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="container-fallback-banner">
                                    <div style="width: 52px; height: 52px; background: rgba(252, 128, 25, 0.15); border: 1px solid rgba(252, 128, 25, 0.35); border-radius: 12px; display: flex; align-items: center; justify-content: center; color: #FC8019; font-size: 26px; margin-bottom: 6px;">
                                        <i class="ti ti-box"></i>
                                    </div>
                                    <div style="font-weight: 700; font-size: 13px; font-family: monospace; color: #F8FAFC;">#${container.containerNumber}</div>
                                    <div style="font-size: 11px; color: #94A3B8;">${container.type} &bull; ${container.size}</div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Card Body -->
                    <div class="container-card-body">
                        <div class="container-title-row">
                            <span class="container-number">#${container.containerNumber}</span>
                            <span class="container-type-pill">
                                <i class="ti ti-truck-delivery"></i> ${container.type}
                            </span>
                        </div>

                        <!-- Specs List -->
                        <ul class="specs-list">
                            <li class="specs-item">
                                <span class="specs-item-label"><i class="ti ti-weight"></i> Tare Weight</span>
                                <span class="specs-item-value"><fmt:formatNumber value="${container.tareWeightKg}" maxFractionDigits="0"/> kg</span>
                            </li>
                            <li class="specs-item">
                                <span class="specs-item-label"><i class="ti ti-packages"></i> Goods Capacity</span>
                                <span class="specs-item-value"><fmt:formatNumber value="${container.goodsCapacityKg}" maxFractionDigits="0"/> kg</span>
                            </li>
                            <li class="specs-item">
                                <span class="specs-item-label"><i class="ti ti-cube"></i> Cargo Volume</span>
                                <span class="specs-item-value"><fmt:formatNumber value="${container.goodsCapacityCbm}" maxFractionDigits="1"/> CBM</span>
                            </li>
                        </ul>

                        <!-- Bottom Actions -->
                        <div class="card-actions-row">
                            <c:choose>
                                <c:when test="${container.status == 'Available'}">
                                    <a href="${pageContext.request.contextPath}/shipments/create?containerId=${container.containerId}" class="btn-allocate">
                                        <span>Allocate</span>
                                        <i class="ti ti-arrow-right"></i>
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <button class="btn-not-available" disabled type="button">
                                        Not Available
                                    </button>
                                </c:otherwise>
                            </c:choose>

                            <c:if test="${sessionScope.user.roleId <= 3}">
                                <div class="dropdown">
                                    <button class="btn-more-actions" type="button" data-bs-toggle="dropdown" aria-expanded="false" title="Container Options">
                                        <i class="ti ti-dots-vertical"></i>
                                    </button>
                                    <ul class="dropdown-menu dropdown-menu-end shadow-sm" style="border-radius: 10px; padding: 6px; border: 1px solid #E2E8F0;">
                                        <li>
                                            <a class="dropdown-item d-flex align-items-center gap-2" href="javascript:void(0)" onclick="openUpdateModal('${container.containerId}', '${container.containerNumber}', '${container.status}', '${container.currentPortId}')" style="border-radius: 6px; padding: 7px 12px; font-size: 13px;">
                                                <i class="ti ti-pencil" style="color: #FC8019;"></i> Update Status & Port
                                            </a>
                                        </li>
                                        <li><hr class="dropdown-divider my-1"></li>
                                        <li>
                                            <a class="dropdown-item d-flex align-items-center gap-2 text-danger" href="javascript:void(0)" onclick="deleteContainer('${container.containerId}', '${container.containerNumber}')" style="border-radius: 6px; padding: 7px 12px; font-size: 13px;">
                                                <i class="ti ti-trash"></i> Delete Container
                                            </a>
                                        </li>
                                    </ul>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
    <!-- No Results Placeholder -->
    <div id="noContainerResults" class="text-center py-5 d-none">
        <div style="width: 64px; height: 64px; background: #F1F5F9; border-radius: 16px; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px auto; color: #94A3B8; font-size: 28px;">
            <i class="ti ti-box-off"></i>
        </div>
        <h5 style="font-weight: 700; color: #1F2937;">No Containers Found</h5>
        <p style="color: var(--nl-text-muted); font-size: 13.5px;">No containers matching your search and filter criteria.</p>
    </div>

    <!-- Enterprise Theme Pagination Bar -->
    <div class="nl-pagination-wrapper mt-4" id="containerPagination" style="border-radius: 12px; border: 1px solid var(--nl-border);">
        <div class="nl-pagination-info">
            <span>Showing <strong id="containerPageStart">1</strong> to <strong id="containerPageEnd">12</strong> of <strong id="containerTotalRows">0</strong> containers</span>
            <div class="d-inline-flex align-items-center gap-2 ms-2">
                <span style="color: #94A3B8; font-size: 12.5px;">Cards per page:</span>
                <select id="containerPageSize" class="nl-page-size-select no-custom-select">
                    <option value="12" selected>12</option>
                    <option value="24">24</option>
                    <option value="48">48</option>
                    <option value="96">96</option>
                </select>
            </div>
        </div>
        <div class="nl-pagination-nav" id="containerPageNav">
            <!-- Dynamically generated page buttons -->
        </div>
    </div>
</div>


<!-- Single Reusable Update Container Modal (Zero-Flicker Viewport Anchored) -->
<div class="modal fade" id="singleUpdateContainerModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content modal-content-custom">
            <div class="modal-header modal-header-custom">
                <div class="d-flex align-items-center gap-2">
                    <div style="width: 36px; height: 36px; background: #FFF2EB; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #FC8019; font-size: 18px;">
                        <i class="ti ti-edit"></i>
                    </div>
                    <div>
                        <h5 class="modal-title mb-0" style="font-weight: 700; font-size: 16px;">Update Container <span id="updateContainerNumberDisplay" style="color: #FC8019;"></span></h5>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="<c:url value='/containers/update'/>" method="POST">
                <input type="hidden" name="containerId" id="updateContainerId" value="">
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label" style="font-weight: 600; font-size: 13px;">Status <span style="color: #FC8019;">*</span></label>
                        <select name="status" id="updateStatusSelect" class="form-select form-select-custom" required>
                            <option value="Available">Available</option>
                            <option value="In-Transit">In-Transit</option>
                            <option value="Under Maintenance">Under Maintenance</option>
                            <option value="Allocated">Allocated</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" style="font-weight: 600; font-size: 13px;">Current Assigned Port <span style="color: #FC8019;">*</span></label>
                        <select name="portId" id="updatePortSelect" class="form-select form-select-custom" required>
                            <c:forEach var="port" items="${ports}">
                                <option value="${port.portId}">${port.portName} (${port.country})</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="modal-footer border-top-0 pt-0 px-4 pb-4">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius: 8px; font-weight: 500;">Cancel</button>
                    <button type="submit" class="modal-btn-submit">Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<form id="singleDeleteForm" action="<c:url value='/containers/delete'/>" method="POST" style="display:none;">
    <input type="hidden" name="id" id="deleteContainerId" value="">
</form>

<!-- Add Container Modal (FR3.1 Full Container Master Catalog) -->
<div class="modal fade" id="addContainerModal" tabindex="-1" aria-labelledby="addContainerModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content modal-content-custom">
            <div class="modal-header modal-header-custom">
                <div class="d-flex align-items-center gap-2">
                    <div style="width: 36px; height: 36px; background: #FFF2EB; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #FC8019; font-size: 18px;">
                        <i class="ti ti-box"></i>
                    </div>
                    <div>
                        <h5 class="modal-title fw-bold mb-0" id="addContainerModalLabel">Add New Shipping Container (FR3.1)</h5>
                        <small class="text-muted" style="font-size: 12px;">Enter standard ISO container specifications, capacities, and port assignment</small>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="<c:url value='/containers/add'/>" method="POST">
                <div class="modal-body p-4">
                    <div class="row g-3">
                        <!-- Container Number -->
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Container Number <span style="color: #FC8019;">*</span></label>
                            <input type="text" name="containerNumber" id="newContainerNumber" class="form-control" required placeholder="e.g. CONT0000301" style="border-radius: 8px; font-size: 13.5px; text-transform: uppercase;">
                        </div>

                        <!-- Assigned Port / Location -->
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Current Location (Port) <span style="color: #FC8019;">*</span></label>
                            <select name="portId" class="form-select form-select-custom" required>
                                <c:forEach var="port" items="${ports}">
                                    <option value="${port.portId}">${port.portName} (${port.country})</option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Type (FR3.1: Dry, Reefer, Open Top, Flat Rack, Tank) -->
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Container Type <span style="color: #FC8019;">*</span></label>
                            <select name="type" class="form-select form-select-custom" required>
                                <option value="Dry" selected>Dry (Dry Van / General Cargo)</option>
                                <option value="Reefer">Reefer (Refrigerated)</option>
                                <option value="Open Top">Open Top (Top-Loaded Heavy Cargo)</option>
                                <option value="Flat Rack">Flat Rack (Heavy / Out-of-Gauge)</option>
                                <option value="Tank">Tank (Liquid Bulk / Chemicals)</option>
                            </select>
                        </div>

                        <!-- Size (FR3.1: 20ft, 40ft, 40ft HC, 45ft) -->
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Standard Size <span style="color: #FC8019;">*</span></label>
                            <select name="size" id="newContainerSize" class="form-select form-select-custom" required onchange="applyContainerSizePreset(this.value)">
                                <option value="20ft">20ft Standard (20' x 8' x 8'6")</option>
                                <option value="40ft" selected>40ft Standard (40' x 8' x 8'6")</option>
                                <option value="40ft HC">40ft High Cube (40' x 8' x 9'6")</option>
                                <option value="45ft">45ft High Cube (45' x 8' x 9'6")</option>
                            </select>
                        </div>

                        <!-- Image URL (FR3.1) -->
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Container Image URL <span class="text-muted fw-normal">(Optional)</span></label>
                            <input type="url" name="imageUrl" class="form-control" placeholder="https://... (or leave blank for illustration)" style="border-radius: 8px; font-size: 13.5px;">
                        </div>

                        <!-- Status (FR3.1) -->
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Initial Status <span style="color: #FC8019;">*</span></label>
                            <select name="status" class="form-select form-select-custom" required>
                                <option value="Available" selected>Available (Ready for Allocation)</option>
                                <option value="Under Maintenance">Under Maintenance (Inspection / Repair)</option>
                                <option value="Allocated">Allocated (Reserved for Shipment)</option>
                                <option value="In-Transit">In-Transit (Currently Sailing / Moving)</option>
                            </select>
                        </div>

                        <!-- Specs Section Header -->
                        <div class="col-12 pt-1">
                            <div class="d-flex align-items-center justify-content-between">
                                <span style="font-weight: 700; font-size: 12.5px; color: #475569; text-transform: uppercase; letter-spacing: 0.5px;">
                                    <i class="ti ti-scale me-1" style="color: #FC8019;"></i> ISO Weight & Capacity Specifications
                                </span>
                                <span class="badge" style="background: #FFF2EB; color: #FC8019; font-size: 11px;">Auto-calculated via Size Preset</span>
                            </div>
                            <hr class="mt-1 mb-2" style="border-color: #E2E8F0;">
                        </div>

                        <!-- Tare Weight -->
                        <div class="col-md-3">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Tare Weight (kg) <span style="color: #FC8019;">*</span></label>
                            <input type="number" step="0.1" name="tareWeightKg" id="newTareWeight" class="form-control" required value="3750" style="border-radius: 8px; font-size: 13.5px;">
                        </div>

                        <!-- Max Gross Weight -->
                        <div class="col-md-3">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Max Gross (kg) <span style="color: #FC8019;">*</span></label>
                            <input type="number" step="0.1" name="maxGrossWeightKg" id="newMaxGrossWeight" class="form-control" required value="30480" style="border-radius: 8px; font-size: 13.5px;">
                        </div>

                        <!-- Goods Capacity (kg) -->
                        <div class="col-md-3">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Payload Cap. (kg) <span style="color: #FC8019;">*</span></label>
                            <input type="number" step="0.1" name="goodsCapacityKg" id="newGoodsCapacityKg" class="form-control" required value="26730" style="border-radius: 8px; font-size: 13.5px;">
                        </div>

                        <!-- Goods Capacity (CBM) -->
                        <div class="col-md-3">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Volume (CBM) <span style="color: #FC8019;">*</span></label>
                            <input type="number" step="0.1" name="goodsCapacityCbm" id="newGoodsCapacityCbm" class="form-control" required value="67.7" style="border-radius: 8px; font-size: 13.5px;">
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-top-0 pt-0 px-4 pb-4">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius: 8px; font-weight: 500;">Cancel</button>
                    <button type="submit" class="modal-btn-submit">Add Container to Catalog</button>
                </div>
            </form>
        </div>
    </div>
</div>
</div>

<script>

window.applyContainerSizePreset = function(size) {
    const tare = document.getElementById('newTareWeight');
    const gross = document.getElementById('newMaxGrossWeight');
    const capKg = document.getElementById('newGoodsCapacityKg');
    const capCbm = document.getElementById('newGoodsCapacityCbm');

    if (size === '20ft') {
        if (tare) tare.value = 2200;
        if (gross) gross.value = 24000;
        if (capKg) capKg.value = 21800;
        if (capCbm) capCbm.value = 33.2;
    } else if (size === '40ft') {
        if (tare) tare.value = 3750;
        if (gross) gross.value = 30480;
        if (capKg) capKg.value = 26730;
        if (capCbm) capCbm.value = 67.7;
    } else if (size === '40ft HC') {
        if (tare) tare.value = 3900;
        if (gross) gross.value = 32500;
        if (capKg) capKg.value = 28600;
        if (capCbm) capCbm.value = 76.4;
    } else if (size === '45ft') {
        if (tare) tare.value = 4800;
        if (gross) gross.value = 34000;
        if (capKg) capKg.value = 29200;
        if (capCbm) capCbm.value = 86.0;
    }
};

window.openUpdateModal = function(id, number, status, portId) {
    document.getElementById('updateContainerId').value = id;
    document.getElementById('updateContainerNumberDisplay').textContent = '#' + number;

    const statusSelect = document.getElementById('updateStatusSelect');
    if (statusSelect) {
        statusSelect.value = status;
        if (statusSelect.tomselect) statusSelect.tomselect.setValue(status);
    }

    const portSelect = document.getElementById('updatePortSelect');
    if (portSelect) {
        portSelect.value = portId;
        if (portSelect.tomselect) portSelect.tomselect.setValue(portId);
    }

    const modalEl = document.getElementById('singleUpdateContainerModal');
    const modalInstance = bootstrap.Modal.getOrCreateInstance(modalEl);
    modalInstance.show();
};

window.deleteContainer = function(id, number) {
    if (confirm('Are you sure you want to delete container #' + number + '?')) {
        document.getElementById('deleteContainerId').value = id;
        document.getElementById('singleDeleteForm').submit();
    }
};

document.addEventListener("DOMContentLoaded", function() {
    const searchInput = document.getElementById('containerSearchInput');
    const clearBtn = document.getElementById('clearContainerSearchBtn');
    const statusFilter = document.getElementById('statusFilter');
    const typeFilter = document.getElementById('typeFilter');
    const resetBtn = document.getElementById('resetContainerFiltersBtn');
    const pageSizeSelect = document.getElementById('containerPageSize');
    const pageNav = document.getElementById('containerPageNav');
    const pageStartEl = document.getElementById('containerPageStart');
    const pageEndEl = document.getElementById('containerPageEnd');
    const totalRowsEl = document.getElementById('containerTotalRows');
    const noResultsEl = document.getElementById('noContainerResults');
    const allCards = Array.from(document.querySelectorAll('.container-col'));

    let currentPage = 1;
    let pageSize = parseInt(pageSizeSelect ? pageSizeSelect.value : 12, 10);
    let matchingCards = [];

    function updatePagination() {
        const total = matchingCards.length;
        const totalPages = Math.ceil(total / pageSize) || 1;

        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        const startIndex = total === 0 ? 0 : (currentPage - 1) * pageSize;
        const endIndex = Math.min(startIndex + pageSize, total);

        if (pageStartEl) pageStartEl.textContent = total === 0 ? '0' : (startIndex + 1);
        if (pageEndEl) pageEndEl.textContent = endIndex;
        if (totalRowsEl) totalRowsEl.textContent = total;

        allCards.forEach(col => { col.style.display = 'none'; });

        for (let i = startIndex; i < endIndex; i++) {
            if (matchingCards[i]) {
                matchingCards[i].style.display = '';
            }
        }

        if (noResultsEl) {
            if (total === 0) {
                noResultsEl.classList.remove('d-none');
            } else {
                noResultsEl.classList.add('d-none');
            }
        }

        renderPageButtons(totalPages);
    }

    function renderPageButtons(totalPages) {
        if (!pageNav) return;
        pageNav.innerHTML = '';

        if (totalPages <= 1 && matchingCards.length <= pageSize) {
            return;
        }

        const prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'nl-page-btn' + (currentPage === 1 ? ' disabled' : '');
        prevBtn.innerHTML = '<i class=\"ti ti-chevron-left\"></i> Prev';
        prevBtn.addEventListener('click', function(e) {
            e.preventDefault();
            if (currentPage > 1) {
                currentPage--;
                updatePagination();
                window.scrollTo({ top: 100, behavior: 'smooth' });
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
                ellipsis.textContent = 'â€¦';
                pageNav.appendChild(ellipsis);
            } else {
                const btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'nl-page-btn' + (p === currentPage ? ' active' : '');
                btn.textContent = p;
                btn.addEventListener('click', function(e) {
                    e.preventDefault();
                    if (currentPage !== p) {
                        currentPage = p;
                        updatePagination();
                        window.scrollTo({ top: 100, behavior: 'smooth' });
                    }
                });
                pageNav.appendChild(btn);
            }
        });

        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'nl-page-btn' + (currentPage === totalPages ? ' disabled' : '');
        nextBtn.innerHTML = 'Next <i class=\"ti ti-chevron-right\"></i>';
        nextBtn.addEventListener('click', function(e) {
            e.preventDefault();
            if (currentPage < totalPages) {
                currentPage++;
                updatePagination();
                window.scrollTo({ top: 100, behavior: 'smooth' });
            }
        });
        pageNav.appendChild(nextBtn);
    }

    function filterCards() {
        const query = searchInput ? searchInput.value.toLowerCase().trim() : '';
        const selectedStatus = statusFilter ? statusFilter.value.toLowerCase().trim() : '';
        const selectedType = typeFilter ? typeFilter.value.toLowerCase().trim() : '';
        matchingCards = [];

        if (clearBtn) {
            if (query.length > 0) {
                clearBtn.classList.remove('d-none');
            } else {
                clearBtn.classList.add('d-none');
            }
        }

        allCards.forEach(col => {
            const num = (col.dataset.number || '').toLowerCase();
            const status = (col.dataset.status || '').toLowerCase();
            const type = (col.dataset.type || '').toLowerCase();
            const size = (col.dataset.size || '').toLowerCase();
            const cardText = col.textContent.toLowerCase();

            const matchesQuery = !query || num.includes(query) || type.includes(query) || size.includes(query) || cardText.includes(query);
            const matchesStatus = !selectedStatus || status === selectedStatus;
            const matchesType = !selectedType || type === selectedType;

            if (matchesQuery && matchesStatus && matchesType) {
                matchingCards.push(col);
            }
        });

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
        searchInput.addEventListener('input', filterCards);
    }

    if (clearBtn) {
        clearBtn.addEventListener('click', function() {
            if (searchInput) {
                searchInput.value = '';
                searchInput.focus();
            }
            filterCards();
        });
    }

    if (statusFilter) {
        statusFilter.addEventListener('change', filterCards);
    }
    if (typeFilter) {
        typeFilter.addEventListener('change', filterCards);
    }

    if (resetBtn) {
        resetBtn.addEventListener('click', function() {
            if (searchInput) searchInput.value = '';
            if (statusFilter) {
                statusFilter.value = '';
                if (statusFilter.tomselect) statusFilter.tomselect.setValue('');
            }
            if (typeFilter) {
                typeFilter.value = '';
                if (typeFilter.tomselect) typeFilter.tomselect.setValue('');
            }
            filterCards();
        });
    }

    filterCards();
});
</script>

<jsp:include page="/jsp/layout/footer.jsp" />