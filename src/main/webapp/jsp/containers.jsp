<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%-- MVC2 (SRS 10.2): data and actions come from ContainerCatalogServlet (/containers).
     The inline controller block that used to live here re-queried the DAO
     with no tenant scope whenever the JSP was opened directly. --%>
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

    <!-- Alert Notifications for Add / Update / Error -->
    <c:if test="${param.add == 'true'}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center justify-content-between mb-4 shadow-sm" role="alert" style="border-radius: 10px; border: 1px solid #BBF7D0; background: #F0FDF4; color: #166534; padding: 14px 20px;">
            <div class="d-flex align-items-center gap-3">
                <div style="width: 36px; height: 36px; background: #DCFCE7; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 20px; color: #16A34A; flex-shrink: 0;">
                    <i class="ti ti-circle-check"></i>
                </div>
                <div>
                    <strong style="font-size: 14px;">Container Registered Successfully!</strong>
                    <div style="font-size: 12.5px; margin-top: 2px;">
                        <c:choose>
                            <c:when test="${not empty param.number}">
                                Container <strong><c:out value="${param.number}"/></strong> has been saved and is now live in the catalog with automatic QR barcode tracking.
                            </c:when>
                            <c:otherwise>
                                Container has been added to the catalog and is ready for cargo allocation.
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <c:if test="${param.error == 'duplicate'}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center justify-content-between mb-4 shadow-sm" role="alert" style="border-radius: 10px; border: 1px solid #FECACA; background: #FEF2F2; color: #991B1B; padding: 14px 20px;">
            <div class="d-flex align-items-center gap-3">
                <div style="width: 36px; height: 36px; background: #FEE2E2; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 20px; color: #DC2626; flex-shrink: 0;">
                    <i class="ti ti-alert-triangle"></i>
                </div>
                <div>
                    <strong style="font-size: 14px;">Duplicate Container Number!</strong>
                    <div style="font-size: 12.5px; margin-top: 2px;">
                        A container with number <strong><c:out value="${param.number}"/></strong> already exists in the system. Container numbers must be unique.
                    </div>
                </div>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <c:if test="${param.add == 'false'}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center justify-content-between mb-4 shadow-sm" role="alert" style="border-radius: 10px; border: 1px solid #FECACA; background: #FEF2F2; color: #991B1B; padding: 14px 20px;">
            <div class="d-flex align-items-center gap-3">
                <div style="width: 36px; height: 36px; background: #FEE2E2; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 20px; color: #DC2626; flex-shrink: 0;">
                    <i class="ti ti-circle-x"></i>
                </div>
                <div>
                    <strong style="font-size: 14px;">Failed to Add Container</strong>
                    <div style="font-size: 12.5px; margin-top: 2px;">
                        An unexpected database error occurred while registering the container. Please verify all inputs and try again.
                    </div>
                </div>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <!--
      Filter & search bar.

      These controls used to filter in JavaScript over the cards already on the
      page, which was one page of the fleet - so searching for a container that
      happened to sit on page 4 found nothing. They now submit to the servlet and
      filter in SQL, and the selections are echoed back from the request.
    -->
    <form method="get" action="${pageContext.request.contextPath}/containers" id="containerFilterForm" class="filter-bar-card">
        <input type="hidden" name="pageSize" value="${pageSize}">
        <div class="filter-search-box">
            <i class="ti ti-search search-icon"></i>
            <input type="text" id="containerSearchInput" name="search" value="${searchTerm}"
                   placeholder="Search by container number, type, size...">
            <c:if test="${not empty searchTerm}">
                <a class="filter-search-clear" href="${pageContext.request.contextPath}/containers?status=${statusFilter}&amp;type=${typeFilter}&amp;pageSize=${pageSize}"><i class="ti ti-x"></i></a>
            </c:if>
        </div>

        <div class="filter-select-wrap">
            <select id="statusFilter" name="status" class="form-select form-select-custom no-custom-select"
                    onchange="document.getElementById('containerFilterForm').submit();">
                <c:forEach var="st" items="All,Available,Allocated,In-Transit,Under Maintenance">
                    <option value="${st}" ${statusFilter eq st ? 'selected' : ''}>${st eq 'All' ? 'All Statuses' : st}</option>
                </c:forEach>
            </select>
        </div>

        <div class="filter-select-wrap">
            <select id="typeFilter" name="type" class="form-select form-select-custom no-custom-select"
                    onchange="document.getElementById('containerFilterForm').submit();">
                <c:forEach var="ty" items="All,Dry,Reefer,Open Top,Flat Rack,Tank">
                    <option value="${ty}" ${typeFilter eq ty ? 'selected' : ''}>${ty eq 'All' ? 'All Types' : ty}</option>
                </c:forEach>
            </select>
        </div>

        <button class="btn-reset-filters" type="submit" title="Apply filters">
            <i class="ti ti-search"></i>
        </button>
        <a class="btn-reset-filters" href="${pageContext.request.contextPath}/containers" title="Reset Filters">
            <i class="ti ti-rotate"></i>
        </a>
    </form>

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
                            <li class="specs-item">
                                <span class="specs-item-label"><i class="ti ti-map-pin"></i> Current Location</span>
                                <span class="specs-item-value">
                                    <c:choose>
                                        <c:when test="${not empty container.portName}">${container.portName}<c:if test="${not empty container.portCountry}">, ${container.portCountry}</c:if></c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </span>
                            </li>
                        </ul>

                        <!-- Bottom Actions -->
                        <div class="card-actions-row">
                            <c:choose>
                                <%-- Allocation: Super Admin, Company Admin, Operations only --%>
                                <c:when test="${container.status == 'Available' && sessionScope.user.roleId <= 3}">
                                    <a href="${pageContext.request.contextPath}/allocate?containerId=${container.containerId}" class="btn-allocate">
                                        <span>Allocate</span>
                                        <i class="ti ti-arrow-right"></i>
                                    </a>
                                </c:when>
                                <%-- Customers book instead of allocating (FR2.1) --%>
                                <c:when test="${container.status == 'Available' && sessionScope.user.roleId == 5}">
                                    <a href="${pageContext.request.contextPath}/shipments/create?containerId=${container.containerId}" class="btn-allocate">
                                        <span>Book This Container</span>
                                        <i class="ti ti-arrow-right"></i>
                                    </a>
                                </c:when>
                                <%-- Finance: catalog is read-only --%>
                                <c:when test="${container.status == 'Available'}">
                                    <button class="btn-not-available" disabled type="button">
                                        Available
                                    </button>
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
                                            <a class="dropdown-item d-flex align-items-center gap-2" href="javascript:void(0)" onclick="openUpdateModal({id: '${container.containerId}', number: '${container.containerNumber}', type: '${container.type}', size: '${container.size}', tare: ${container.tareWeightKg}, maxGross: ${container.maxGrossWeightKg}, capKg: ${container.goodsCapacityKg}, capCbm: ${container.goodsCapacityCbm}, status: '${container.status}', portId: '${container.currentPortId}'})" style="border-radius: 6px; padding: 7px 12px; font-size: 13px;">
                                                <i class="ti ti-pencil" style="color: #FC8019;"></i> Update Container
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
    <!-- Empty state. Server-rendered now that filtering happens in SQL. -->
    <div id="noContainerResults" class="text-center py-5 ${empty containers ? '' : 'd-none'}">
        <div style="width: 64px; height: 64px; background: #F1F5F9; border-radius: 16px; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px auto; color: #94A3B8; font-size: 28px;">
            <i class="ti ti-box-off"></i>
        </div>
        <h5 style="font-weight: 700; color: #1F2937;">No Containers Found</h5>
        <p style="color: var(--nl-text-muted); font-size: 13.5px;">No containers matching your search and filter criteria.</p>
    </div>

    <!--
      Pagination.

      The old bar was driven entirely by JavaScript over the cards in the DOM,
      while the servlet was already paginating in SQL. The two cancelled out: the
      page always held 12 rows, the counter read "of 0 containers" because the
      script never saw a server total, and the page buttons hid themselves
      because 12 was never more than one client-side page. It is server-driven
      now, so the whole fleet is reachable.
    -->
    <c:set var="qsBase" value="status=${statusFilter}&amp;type=${typeFilter}&amp;search=${searchTerm}&amp;pageSize=${pageSize}" />
    <div class="nl-pagination-wrapper mt-4" id="containerPagination" style="border-radius: 12px; border: 1px solid var(--nl-border);">
        <div class="nl-pagination-info">
            <span>Showing <strong>${rangeStart}</strong> to <strong>${rangeEnd}</strong> of <strong>${totalRecords}</strong> containers</span>
            <div class="d-inline-flex align-items-center gap-2 ms-2">
                <span style="color: #94A3B8; font-size: 12.5px;">Cards per page:</span>
                <select id="containerPageSize" class="nl-page-size-select no-custom-select"
                        onchange="location.href='${pageContext.request.contextPath}/containers?status=${statusFilter}&amp;type=${typeFilter}&amp;search=${searchTerm}&amp;page=1&amp;pageSize=' + this.value;">
                    <c:forEach var="ps" items="${pageSizes}">
                        <option value="${ps}" ${pageSize eq ps ? 'selected' : ''}>${ps}</option>
                    </c:forEach>
                </select>
            </div>
        </div>
        <c:if test="${totalPages > 1}">
            <div class="nl-pagination-nav">
                <c:if test="${currentPage > 1}">
                    <a class="nl-page-btn nl-page-nav-btn" href="?${qsBase}&amp;page=${currentPage - 1}">Prev</a>
                </c:if>
                <c:forEach begin="${currentPage - 2 > 1 ? currentPage - 2 : 1}"
                           end="${currentPage + 2 < totalPages ? currentPage + 2 : totalPages}" var="pg">
                    <a class="nl-page-btn nl-page-num ${pg == currentPage ? 'active' : ''}" href="?${qsBase}&amp;page=${pg}">${pg}</a>
                </c:forEach>
                <c:if test="${currentPage < totalPages}">
                    <a class="nl-page-btn nl-page-nav-btn" href="?${qsBase}&amp;page=${currentPage + 1}">Next</a>
                </c:if>
            </div>
        </c:if>
    </div>

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
            <form action="<c:url value='/containers/update'/>" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="containerId" id="updateContainerId" value="">
                <div class="modal-body p-4">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Type <span style="color: #FC8019;">*</span></label>
                            <select name="type" id="updateTypeSelect" class="form-select form-select-custom no-custom-select" required>
                                <option value="Dry">Dry</option>
                                <option value="Reefer">Reefer</option>
                                <option value="Open Top">Open Top</option>
                                <option value="Flat Rack">Flat Rack</option>
                                <option value="Tank">Tank</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Size <span style="color: #FC8019;">*</span></label>
                            <select name="size" id="updateSizeSelect" class="form-select form-select-custom no-custom-select" required>
                                <option value="20ft">20ft</option>
                                <option value="40ft">40ft</option>
                                <option value="40ft HC">40ft HC</option>
                                <option value="45ft">45ft</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Tare Weight (kg) <span style="color: #FC8019;">*</span></label>
                            <input type="number" step="0.01" name="tareWeightKg" id="updateTareWeight" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Max Gross Weight (kg) <span style="color: #FC8019;">*</span></label>
                            <input type="number" step="0.01" name="maxGrossWeightKg" id="updateMaxGross" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Goods Capacity (kg) <span style="color: #FC8019;">*</span></label>
                            <input type="number" step="0.01" name="goodsCapacityKg" id="updateCapKg" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Cargo Volume (CBM) <span style="color: #FC8019;">*</span></label>
                            <input type="number" step="0.01" name="goodsCapacityCbm" id="updateCapCbm" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Status <span style="color: #FC8019;">*</span></label>
                            <select name="status" id="updateStatusSelect" class="form-select form-select-custom no-custom-select" required>
                                <option value="Available">Available</option>
                                <option value="In-Transit">In-Transit</option>
                                <option value="Under Maintenance">Under Maintenance</option>
                                <option value="Allocated">Allocated</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Current Assigned Port <span style="color: #FC8019;">*</span></label>
                            <select name="portId" id="updatePortSelect" class="form-select form-select-custom no-custom-select" required>
                                <option value="" disabled>-- Select Assigned Port --</option>
                                <c:forEach var="port" items="${ports}">
                                    <option value="${port.portId}">${port.portName} (${port.country})</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Replace Container Image (optional)</label>
                            <input type="file" name="containerImageFile" accept="image/*" class="form-control">
                        </div>
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
                        <h5 class="modal-title fw-bold mb-0" id="addContainerModalLabel">Add New Shipping Container</h5>
                        <small class="text-muted" style="font-size: 12px;">Enter standard ISO container specifications, capacities, and port assignment</small>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="<c:url value='/containers/add'/>" method="POST" enctype="multipart/form-data">
                <div class="modal-body p-4">
                    <div class="row g-3">
                        <!-- Container Number -->
                        <div class="col-md-6">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <label class="form-label mb-0" style="font-weight: 600; font-size: 13px;">Container Number <span style="color: #FC8019;">*</span></label>
                                <button type="button" class="btn btn-link p-0 text-decoration-none" style="font-size: 11.5px; color: #FC8019; font-weight: 600;" onclick="generateRandomContainerNumber()">
                                    <i class="ti ti-wand"></i> Auto-Generate
                                </button>
                            </div>
                            <input type="text" name="containerNumber" id="newContainerNumber" class="form-control" required placeholder="e.g. CONT0000305" style="border-radius: 8px; font-size: 13.5px; text-transform: uppercase;">
                        </div>

                        <!-- Owner Company (Super Admin selects tenant; Tenant staff defaults to own company) -->
                        <c:choose>
                            <c:when test="${sessionScope.user.roleId == 1}">
                                <div class="col-md-6">
                                    <label class="form-label" style="font-weight: 600; font-size: 13px;">
                                        <i class="ti ti-building me-1" style="color: #FC8019;"></i> Owner Company <span style="color: #FC8019;">*</span>
                                    </label>
                                    <select name="companyId" class="form-select form-select-custom no-custom-select" required>
                                        <c:forEach var="comp" items="${companies}" varStatus="cStatus">
                                            <option value="${comp.companyId}" ${cStatus.first ? 'selected' : ''}>${comp.companyName}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <input type="hidden" name="companyId" value="${sessionScope.user.companyId}">
                            </c:otherwise>
                        </c:choose>

                        <!-- Assigned Port / Location -->
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">
                                <i class="ti ti-anchor me-1" style="color: #FC8019;"></i> Current Location (Port) <span style="color: #FC8019;">*</span>
                            </label>
                            <select name="portId" id="newContainerPort" class="form-select form-select-custom no-custom-select" required>
                                <option value="" disabled>-- Select Assigned Port --</option>
                                <c:forEach var="port" items="${ports}" varStatus="pStatus">
                                    <option value="${port.portId}" ${pStatus.first ? 'selected' : ''}>${port.portName} (${port.country})</option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Type (FR3.1: Dry, Reefer, Open Top, Flat Rack, Tank) -->
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Container Type <span style="color: #FC8019;">*</span></label>
                            <select name="type" class="form-select form-select-custom no-custom-select" required>
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
                            <select name="size" id="newContainerSize" class="form-select form-select-custom no-custom-select" required onchange="applyContainerSizePreset(this.value)">
                                <option value="20ft">20ft Standard (20' x 8' x 8'6")</option>
                                <option value="40ft" selected>40ft Standard (40' x 8' x 8'6")</option>
                                <option value="40ft HC">40ft High Cube (40' x 8' x 9'6")</option>
                                <option value="45ft">45ft High Cube (45' x 8' x 9'6")</option>
                            </select>
                        </div>

                        <!-- Container Image File Picker (FR3.1) -->
                        <div class="col-12">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">
                                <i class="ti ti-photo me-1" style="color: #FC8019;"></i> Container Image <span class="text-muted fw-normal">(File Picker / Upload)</span>
                            </label>
                            
                            <!-- Hidden File Input -->
                            <input type="file" name="containerImageFile" id="containerImageFileInput" accept="image/png, image/jpeg, image/webp, image/gif" class="d-none" onchange="handleImageFilePicker(this)">
                            
                            <!-- Dropzone / Picker Trigger -->
                            <div id="imagePickerDropzone" onclick="document.getElementById('containerImageFileInput').click()" style="border: 2px dashed #E2E8F0; border-radius: 10px; padding: 18px 20px; text-align: center; cursor: pointer; background: #FFF9F5; transition: all 0.2s ease;">
                                <div style="width: 44px; height: 44px; background: #FFF2EB; border-radius: 10px; display: inline-flex; align-items: center; justify-content: center; color: #FC8019; font-size: 22px; margin-bottom: 6px;">
                                    <i class="ti ti-upload"></i>
                                </div>
                                <div style="font-weight: 600; font-size: 13.5px; color: #1F2937;">Click to Choose Container Image</div>
                                <div style="font-size: 11.5px; color: #94A3B8; margin-top: 2px;">Supports PNG, JPG, JPEG, WEBP up to 10MB</div>
                            </div>

                            <!-- Live Image Preview Card -->
                            <div id="imagePickerPreview" style="display: none; align-items: center; gap: 14px; padding: 10px 14px; background: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 10px; margin-top: 8px;">
                                <img id="imagePreviewElement" src="" alt="Container Preview" style="width: 54px; height: 42px; object-fit: cover; border-radius: 6px; border: 1px solid #E2E8F0;">
                                <div style="flex: 1; min-width: 0;">
                                    <div id="imagePreviewFilename" style="font-size: 13px; font-weight: 600; color: #1F2937; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">filename.jpg</div>
                                    <div id="imagePreviewFilesize" style="font-size: 11px; color: #64748B;">0 KB</div>
                                </div>
                                <button type="button" class="btn btn-sm btn-outline-danger" onclick="removeSelectedImage()" style="border-radius: 6px; font-size: 12px; padding: 4px 10px;">
                                    <i class="ti ti-trash"></i> Remove
                                </button>
                            </div>

                            <!-- Alternative Web URL Input Link -->
                            <div class="mt-2">
                                <a href="javascript:void(0)" onclick="toggleImageWebUrl()" style="font-size: 12px; color: #FC8019; text-decoration: none; font-weight: 500;">
                                    <i class="ti ti-link"></i> <span id="toggleUrlText">Or enter image web URL instead</span>
                                </a>
                                <div id="webUrlInputWrapper" style="display: none; margin-top: 6px;">
                                    <input type="url" name="imageUrl" id="containerWebUrlInput" class="form-control" placeholder="https://example.com/container.jpg" style="border-radius: 8px; font-size: 13px;">
                                </div>
                            </div>
                        </div>

                        <!-- Status (FR3.1) -->
                        <div class="col-md-6">
                            <label class="form-label" style="font-weight: 600; font-size: 13px;">Initial Status <span style="color: #FC8019;">*</span></label>
                            <select name="status" class="form-select form-select-custom no-custom-select" required>
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


window.handleImageFilePicker = function(input) {
    if (input.files && input.files[0]) {
        const file = input.files[0];
        const reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('imagePreviewElement').src = e.target.result;
            document.getElementById('imagePreviewFilename').textContent = file.name;
            const sizeInKb = (file.size / 1024).toFixed(1);
            document.getElementById('imagePreviewFilesize').textContent = sizeInKb + ' KB';
            document.getElementById('imagePickerPreview').style.display = 'flex';
            document.getElementById('imagePickerDropzone').style.borderColor = '#10B981';
            document.getElementById('imagePickerDropzone').style.background = '#ECFDF5';
        };
        reader.readAsDataURL(file);
    }
};

window.removeSelectedImage = function() {
    const input = document.getElementById('containerImageFileInput');
    if (input) input.value = '';
    document.getElementById('imagePickerPreview').style.display = 'none';
    const dropzone = document.getElementById('imagePickerDropzone');
    if (dropzone) {
        dropzone.style.borderColor = '#E2E8F0';
        dropzone.style.background = '#FFF9F5';
    }
};

window.toggleImageWebUrl = function() {
    const wrapper = document.getElementById('webUrlInputWrapper');
    const toggleText = document.getElementById('toggleUrlText');
    if (wrapper.style.display === 'none' || !wrapper.style.display) {
        wrapper.style.display = 'block';
        toggleText.textContent = 'Hide web URL input';
    } else {
        wrapper.style.display = 'none';
        toggleText.textContent = 'Or enter image web URL instead';
    }
};

// Modal TomSelect sync on shown (fixes selects rendering blank/unstyled since TomSelect
// can't measure width correctly while its modal is still display:none at init time)
function syncModalTomSelects(modalId) {
    const modal = document.getElementById(modalId);
    if (!modal) return;
    modal.addEventListener('shown.bs.modal', function() {
        this.querySelectorAll('select.tomselected').forEach(function(sel) {
            if (sel.tomselect) {
                sel.tomselect.sync();
            }
        });
    });
}
syncModalTomSelects('addContainerModal');
syncModalTomSelects('singleUpdateContainerModal');

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

window.openUpdateModal = function(c) {
    document.getElementById('updateContainerId').value = c.id;
    document.getElementById('updateContainerNumberDisplay').textContent = '#' + c.number;
    document.getElementById('updateTareWeight').value = c.tare;
    document.getElementById('updateMaxGross').value = c.maxGross;
    document.getElementById('updateCapKg').value = c.capKg;
    document.getElementById('updateCapCbm').value = c.capCbm;

    function setSelect(id, value) {
        const el = document.getElementById(id);
        if (!el) return;
        el.value = value;
        if (el.tomselect) {
            el.tomselect.setValue(String(value), false);
            el.tomselect.sync();
        }
    }
    setSelect('updateTypeSelect', c.type);
    setSelect('updateSizeSelect', c.size);
    setSelect('updateStatusSelect', c.status);
    setSelect('updatePortSelect', c.portId);

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

window.generateRandomContainerNumber = function() {
    const prefixes = ['CONT', 'MSCU', 'CMAU', 'HLCU', 'ONEU', 'MAEU'];
    const prefix = prefixes[Math.floor(Math.random() * prefixes.length)];
    const num = Math.floor(100000 + Math.random() * 900000);
    const check = Math.floor(Math.random() * 10);
    const input = document.getElementById('newContainerNumber');
    if (input) {
        input.value = prefix + num + check;
    }
};

document.addEventListener('DOMContentLoaded', function() {
    const modalEl = document.getElementById('addContainerModal');
    if (modalEl) {
        modalEl.addEventListener('show.bs.modal', function() {
            const input = document.getElementById('newContainerNumber');
            if (input && (!input.value || input.value.trim() === '')) {
                window.generateRandomContainerNumber();
            }
        });
    }
});

/*
 * The client-side search / filter / pagination engine that lived here has been
 * removed. It operated on the cards in the DOM, which is one server page of the
 * fleet, so it silently disagreed with the SQL pagination underneath it: the
 * counter reported "of 0 containers", the page buttons suppressed themselves,
 * and the cards-per-page selector changed nothing. Search, status, type, page
 * and page size are all query parameters now, handled in
 * ContainerCatalogServlet and ContainerDAO.getCatalogPage().
 */
</script>

<jsp:include page="/jsp/layout/footer.jsp" />