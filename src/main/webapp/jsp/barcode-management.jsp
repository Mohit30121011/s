<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="en_IN" scope="page" />
<jsp:include page="/jsp/layout/header.jsp" />

<%-- Calculate KPI metrics --%>
<c:set var="cntContainer" value="${categoryCounts['Container'] != null ? categoryCounts['Container'] : 0}" />
<c:set var="cntShipment" value="${categoryCounts['Shipment'] != null ? categoryCounts['Shipment'] : 0}" />
<c:set var="cntStock" value="${categoryCounts['Stock'] != null ? categoryCounts['Stock'] : 0}" />
<c:set var="cntDocs" value="${(categoryCounts['ComplianceDocument'] != null ? categoryCounts['ComplianceDocument'] : 0) + (categoryCounts['Invoice'] != null ? categoryCounts['Invoice'] : 0)}" />

<style>
    .barcode-page-wrapper {
        background-color: #F8FAFC;
        min-height: calc(100vh - 70px);
        padding-bottom: 40px;
    }

    /* Page Header */
    .barcode-header-row {
        display: flex;
        align-items: flex-end;
        justify-content: space-between;
        margin-bottom: 24px;
        flex-wrap: wrap;
        gap: 16px;
    }
    .barcode-page-title {
        font-weight: 700;
        color: #0F172A;
        font-size: 24px;
        letter-spacing: -0.02em;
        margin-bottom: 4px;
    }
    .barcode-breadcrumb {
        font-size: 13px;
        color: #64748B;
        margin-bottom: 0;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .btn-create-code {
        background: linear-gradient(135deg, #FC8019 0%, #E66F0F 100%);
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
        box-shadow: 0 4px 14px rgba(252, 128, 25, 0.28);
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        text-decoration: none;
    }
    .btn-create-code:hover {
        transform: translateY(-1px);
        box-shadow: 0 6px 18px rgba(252, 128, 25, 0.38);
        background: linear-gradient(135deg, #FF8E2E 0%, #E66F0F 100%);
    }

    /* KPI Cards Grid */
    .barcode-kpi-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
        gap: 18px;
        margin-bottom: 24px;
    }
    .barcode-kpi-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        padding: 18px 20px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04);
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    .barcode-kpi-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(15, 23, 42, 0.08);
    }
    .barcode-kpi-top {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 12px;
    }
    .barcode-kpi-icon {
        width: 42px;
        height: 42px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
    }
    .barcode-kpi-icon.total { background: #EEF2FF; color: #4F46E5; }
    .barcode-kpi-icon.container { background: #EFF6FF; color: #2563EB; }
    .barcode-kpi-icon.shipment { background: #ECFDF5; color: #10B981; }
    .barcode-kpi-icon.scans { background: #FFF7ED; color: #EA580C; }

    .barcode-kpi-label {
        font-size: 11.5px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.6px;
        color: #64748B;
        margin-bottom: 4px;
    }
    .barcode-kpi-value {
        font-size: 24px;
        font-weight: 800;
        color: #0F172A;
        letter-spacing: -0.02em;
        line-height: 1.2;
    }
    .barcode-kpi-sub {
        font-size: 12px;
        color: #64748B;
        margin-top: 6px;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    /* Filter Toolbar */
    .barcode-filter-toolbar {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        padding: 14px 18px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03);
        margin-bottom: 22px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 14px;
    }
    .barcode-search-wrap {
        position: relative;
        flex: 1;
        min-width: 260px;
        max-width: 440px;
    }
    .barcode-search-wrap i.search-icon {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #94A3B8;
        font-size: 15px;
        pointer-events: none;
    }
    .barcode-search-input {
        width: 100%;
        padding: 9px 36px 9px 38px;
        border: 1px solid #E2E8F0;
        border-radius: 8px;
        font-size: 13.5px;
        outline: none;
        background: #F8FAFC;
        color: #0F172A;
        transition: all 0.15s ease;
    }
    .barcode-search-input:focus {
        background: #FFFFFF;
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .barcode-search-clear {
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
        display: none;
    }
    .barcode-search-clear:hover { color: #0F172A; }

    /* Main Table / Grid Container */
    .barcode-main-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 14px;
        padding: 22px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03);
        margin-bottom: 24px;
    }
    .barcode-main-head {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 18px;
        flex-wrap: wrap;
        gap: 12px;
    }
    .barcode-main-title {
        font-size: 16px;
        font-weight: 700;
        color: #0F172A;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    /* Barcode Grid Card */
    .barcode-grid-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        padding: 16px;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03);
    }
    .barcode-grid-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 24px rgba(15, 23, 42, 0.08);
        border-color: #CBD5E1;
    }

    .barcode-entity-badge {
        font-size: 12px;
        font-weight: 700;
        color: #0F172A;
        background: #F1F5F9;
        border: 1px solid #E2E8F0;
        padding: 4px 9px;
        border-radius: 6px;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .barcode-type-pill {
        font-size: 11px;
        font-weight: 700;
        padding: 3px 8px;
        border-radius: 6px;
        text-transform: uppercase;
        letter-spacing: 0.4px;
    }
    .barcode-type-pill.Code128 {
        background: #EFF6FF;
        color: #2563EB;
        border: 1px solid #DBEAFE;
    }
    .barcode-type-pill.QR {
        background: #FFF2EB;
        color: #FC8019;
        border: 1px solid #FFE0D1;
    }

    /* Barcode Display Frame */
    .barcode-display-frame {
        background: #FAFBFD;
        border: 1px solid #E2E8F0;
        border-radius: 10px;
        padding: 14px 10px;
        min-height: 140px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        margin: 12px 0;
        position: relative;
    }
    .barcode-img-box {
        height: 95px;
        width: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
    }
    .barcode-img-box img {
        max-height: 92px;
        max-width: 100%;
        object-fit: contain;
        display: block;
        margin: 0 auto;
    }
    .barcode-val-badge {
        margin-top: 8px;
        background: #FFFFFF;
        border: 1px solid #CBD5E1;
        padding: 3px 10px;
        border-radius: 6px;
        font-size: 11.5px;
        font-weight: 700;
        color: #0F172A;
        font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        cursor: pointer;
        transition: all 0.15s ease;
    }
    .barcode-val-badge:hover {
        background: #FFF2EB;
        color: #FC8019;
        border-color: #FED7AA;
    }

    /* Card Actions */
    .barcode-card-footer {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding-top: 10px;
        border-top: 1px solid #F1F5F9;
        gap: 8px;
    }
    .btn-card-action {
        width: 32px;
        height: 32px;
        border-radius: 8px;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        color: #64748B;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        transition: all 0.15s ease;
        text-decoration: none;
        cursor: pointer;
    }
    .btn-card-action:hover {
        background: #F1F5F9;
        color: #0F172A;
        border-color: #CBD5E1;
    }
    .btn-card-action.btn-print:hover {
        background: #EFF6FF;
        color: #2563EB;
        border-color: #BFDBFE;
    }
    .btn-card-action.btn-download:hover {
        background: #ECFDF5;
        color: #059669;
        border-color: #A7F3D0;
    }
    .btn-card-action.btn-delete:hover {
        background: #FEF2F2;
        color: #DC2626;
        border-color: #FECACA;
    }

    /* Batch Print Bar */
    .nl-batchprint-bar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        flex-wrap: wrap;
        background: linear-gradient(135deg, #FFF7ED 0%, #FFEDD5 100%);
        border: 1px solid #FED7AA;
        border-radius: 14px;
        padding: 16px 22px;
        margin: 0 0 24px 0;
        box-shadow: 0 1px 3px rgba(249, 115, 22, 0.08);
    }
    .nl-batchprint-bar strong { display: block; font-size: 14px; color: #0F172A; font-weight: 700; }
    .nl-batchprint-bar span { font-size: 12.5px; color: #9A5B21; }
    .nl-batchprint-btn {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        height: 40px;
        padding: 0 20px;
        border-radius: 10px;
        background: #FC8019;
        color: #FFFFFF;
        text-decoration: none;
        font-size: 13px;
        font-weight: 600;
        white-space: nowrap;
        box-shadow: 0 2px 8px rgba(252, 128, 25, 0.28);
        transition: all 0.15s ease;
    }
    .nl-batchprint-btn:hover {
        background: #E8730F;
        color: #FFFFFF;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.38);
    }

    /* Scan Audit Trail */
    .nl-scanlog-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 14px;
        padding: 22px;
        margin: 0 0 24px 0;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03);
    }
    .nl-scanlog-head {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: 16px;
        margin-bottom: 16px;
    }
    .nl-scanlog-head h3 { margin: 0 0 4px 0; font-size: 16px; font-weight: 700; color: #0F172A; }
    .nl-scanlog-head p { margin: 0; font-size: 12.5px; color: #64748B; }
    .nl-scanlog-count {
        flex: none;
        background: #FFF7ED;
        color: #C2410C;
        border: 1px solid #FED7AA;
        border-radius: 50px;
        padding: 5px 14px;
        font-size: 12px;
        font-weight: 600;
        white-space: nowrap;
    }
    .nl-scanlog-scroll {
        overflow-x: auto;
        max-height: 420px;
        overflow-y: auto;
        border-radius: 10px;
        border: 1px solid #F1F5F9;
    }
    .nl-scanlog-table { width: 100%; border-collapse: collapse; font-size: 12.5px; }
    .nl-scanlog-table thead th {
        position: sticky;
        top: 0;
        background: #F8FAFC;
        color: #64748B;
        text-align: left;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        padding: 11px 16px;
        border-bottom: 1px solid #E2E8F0;
        white-space: nowrap;
    }
    .nl-scanlog-table tbody td {
        padding: 12px 16px;
        border-bottom: 1px solid #F1F5F9;
        color: #334155;
        white-space: nowrap;
    }
    .nl-scanlog-table tbody tr:hover { background: #FFFBF6; }
    .nl-scanlog-chip {
        display: inline-block;
        background: #EFF6FF;
        color: #1D4ED8;
        border: 1px solid #DBEAFE;
        border-radius: 50px;
        padding: 3px 11px;
        font-size: 11.5px;
        font-weight: 600;
    }

    /* Suppress card tools completely */
    .nl-card-tools,
    .no-card-tools .nl-card-tools,
    [data-no-tools="true"] .nl-card-tools,
    .barcode-grid-card .nl-card-tools,
    .barcode-main-card .nl-card-tools,
    .nl-scanlog-card .nl-card-tools {
        display: none !important;
    }
</style>

<!-- Load JS Libraries for Barcode/QR Generation -->
<script src="https://cdn.jsdelivr.net/npm/jsbarcode@3.11.5/dist/JsBarcode.all.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/qrcode.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>

<div class="barcode-page-wrapper">
    <div class="container-fluid py-4">

        <!-- Page Header -->
        <div class="barcode-header-row">
            <div>
                <h1 class="barcode-page-title">Barcode &amp; Traceability Registry</h1>
                <p class="barcode-breadcrumb">
                    <span>Dashboard</span>
                    <i class="ti ti-chevron-right" style="font-size: 11px;"></i>
                    <span>Tracking &amp; Scanning</span>
                    <i class="ti ti-chevron-right" style="font-size: 11px;"></i>
                    <span style="color: #0F172A; font-weight: 500;">Manage Barcodes (FR8.1 &ndash; FR8.6)</span>
                </p>
            </div>
            <div>
                <button type="button" class="btn-create-code" data-bs-toggle="modal" data-bs-target="#generateBarcodeModal">
                    <i class="ti ti-qrcode"></i> Generate New Code
                </button>
            </div>
        </div>

        <!-- Session Alerts -->
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center justify-content-between mb-4 shadow-sm" style="border-radius: 10px; border: 1px solid #FECACA; background: #FEF2F2; color: #991B1B;">
                <div class="d-flex align-items-center gap-2">
                    <i class="ti ti-alert-triangle fs-5 text-danger"></i>
                    <span>${sessionScope.errorMessage}</span>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success alert-dismissible fade show d-flex align-items-center justify-content-between mb-4 shadow-sm" style="border-radius: 10px; border: 1px solid #BBF7D0; background: #F0FDF4; color: #166534;">
                <div class="d-flex align-items-center gap-2">
                    <i class="ti ti-circle-check fs-5 text-success"></i>
                    <span>${sessionScope.successMessage}</span>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>

        <!-- Executive KPI Metrics Grid -->
        <div class="barcode-kpi-grid">
            <!-- Card 1: Total Codes -->
            <div class="barcode-kpi-card" data-no-tools="true">
                <div class="barcode-kpi-top">
                    <div>
                        <div class="barcode-kpi-label">Active Barcodes</div>
                        <div class="barcode-kpi-value"><fmt:formatNumber value="${totalCount}" type="number"/></div>
                    </div>
                    <div class="barcode-kpi-icon total">
                        <i class="ti ti-qrcode"></i>
                    </div>
                </div>
                <div class="barcode-kpi-sub">
                    <span class="badge" style="background: #EEF2FF; color: #4F46E5; font-size: 11px;">100% Unique</span>
                    <span>Across fleet registry</span>
                </div>
            </div>

            <!-- Card 2: Container Fleet Tags -->
            <div class="barcode-kpi-card" data-no-tools="true">
                <div class="barcode-kpi-top">
                    <div>
                        <div class="barcode-kpi-label">Containers Tagged</div>
                        <div class="barcode-kpi-value" style="color: #2563EB;"><fmt:formatNumber value="${cntContainer}" type="number"/></div>
                    </div>
                    <div class="barcode-kpi-icon container">
                        <i class="ti ti-container"></i>
                    </div>
                </div>
                <div class="barcode-kpi-sub">
                    <span class="badge" style="background: #EFF6FF; color: #2563EB; font-size: 11px;">Asset Tags</span>
                    <span>Port &amp; vessel units</span>
                </div>
            </div>

            <!-- Card 3: Shipments Tagged -->
            <div class="barcode-kpi-card" data-no-tools="true">
                <div class="barcode-kpi-top">
                    <div>
                        <div class="barcode-kpi-label">Shipments &amp; Cargo</div>
                        <div class="barcode-kpi-value" style="color: #10B981;"><fmt:formatNumber value="${cntShipment}" type="number"/></div>
                    </div>
                    <div class="barcode-kpi-icon shipment">
                        <i class="ti ti-truck-delivery"></i>
                    </div>
                </div>
                <div class="barcode-kpi-sub">
                    <span class="badge" style="background: #ECFDF5; color: #10B981; font-size: 11px;">Waybills</span>
                    <span>Consignments tracked</span>
                </div>
            </div>

            <!-- Card 4: Audit Scans -->
            <div class="barcode-kpi-card" data-no-tools="true">
                <div class="barcode-kpi-top">
                    <div>
                        <div class="barcode-kpi-label">Dock Scan Events</div>
                        <div class="barcode-kpi-value" style="color: #EA580C;"><fmt:formatNumber value="${recentScans.size()}" type="number"/></div>
                    </div>
                    <div class="barcode-kpi-icon scans">
                        <i class="ti ti-scan"></i>
                    </div>
                </div>
                <div class="barcode-kpi-sub">
                    <span class="badge" style="background: #FFF7ED; color: #EA580C; font-size: 11px;">Recent Log</span>
                    <span>Terminal verifications</span>
                </div>
            </div>
        </div>

        <!-- Filter & Search Toolbar -->
        <div class="barcode-filter-toolbar" data-no-tools="true">
            <!-- Search Input -->
            <div class="barcode-search-wrap">
                <i class="ti ti-search search-icon"></i>
                <input type="text" id="barcodeSearchInput" value="${selectedSearch}" class="barcode-search-input" placeholder="Search by entity #, barcode value, type..." onkeyup="onBarcodeSearchKeyUp(event)">
                <button type="button" class="barcode-search-clear" id="barcodeSearchClearBtn" onclick="clearBarcodeSearch()">
                    <i class="ti ti-x"></i>
                </button>
            </div>

            <!-- Category & Actions Form -->
            <form method="GET" action="${pageContext.request.contextPath}/barcodes" class="d-flex align-items-center flex-wrap gap-2 m-0" id="barcodeFilterForm">
                <input type="hidden" name="search" id="barcodeFormSearch" value="${selectedSearch}">
                <div style="min-width: 200px;">
                    <select name="category" class="form-select" onchange="submitBarcodeFilter()" style="border-radius: 8px; font-size: 13px; padding: 8px 14px;">
                        <option value="All" ${selectedCategory == 'All' ? 'selected' : ''}>All Categories (${totalCount})</option>
                        <c:forEach var="cat" items="${categoryCounts}">
                            <option value="${cat.key}" ${selectedCategory == cat.key ? 'selected' : ''}>${cat.key} (${cat.value})</option>
                        </c:forEach>
                    </select>
                </div>

                <button type="submit" class="btn btn-nlog d-inline-flex align-items-center gap-1" style="border-radius: 8px; font-size: 13px; padding: 8px 16px;">
                    <i class="ti ti-filter"></i> Apply
                </button>

                <c:if test="${not empty selectedSearch or (not empty selectedCategory and selectedCategory ne 'All')}">
                    <a href="${pageContext.request.contextPath}/barcodes" class="btn btn-outline-secondary d-inline-flex align-items-center gap-1" style="border-radius: 8px; font-size: 13px; padding: 8px 14px;" title="Reset Filters">
                        <i class="ti ti-rotate"></i> Reset
                    </a>
                </c:if>
            </form>
        </div>

        <!-- Barcodes Full-Width Grid Card -->
        <div class="barcode-main-card" data-no-tools="true">
            <div class="barcode-main-head">
                <h3 class="barcode-main-title">
                    <i class="ti ti-barcode" style="color: #FC8019;"></i>
                    <span>Generated Codes Library</span>
                    <span class="badge rounded-pill bg-light text-muted fw-normal" style="font-size: 11px; margin-left: 4px;" id="barcodeVisibleCount">${totalCount} Total Catalog</span>
                </h3>
                <div class="text-muted small">
                    Page <strong>${currentPage}</strong> of <strong>${totalPages}</strong>
                </div>
            </div>

            <!-- Cards Responsive Grid -->
            <div class="row g-3" id="barcodeCardsGrid">
                <c:forEach var="code" items="${barcodeList}">
                    <%-- Ensure image path has a clean leading slash --%>
                    <c:set var="rawImg" value="${code.imagePath}" />
                    <c:set var="cleanImgPath" value="${empty rawImg ? '' : (rawImg.startsWith('/') ? rawImg : '/'.concat(rawImg))}" />

                    <div class="col-xxl-3 col-lg-4 col-md-6 col-12 barcode-col-item"
                         data-entity="${fn:toLowerCase(code.entityType)}"
                         data-entity-id="${code.entityId}"
                         data-code-val="${fn:toLowerCase(code.barcodeValue)}"
                         data-code-type="${code.barcodeType}">

                        <div class="barcode-grid-card h-100" id="card-${code.barcodeId}" data-no-tools="true">
                            <!-- Card Header -->
                            <div>
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <div class="barcode-entity-badge">
                                        <c:choose>
                                            <c:when test="${code.entityType == 'Container'}">
                                                <i class="ti ti-container text-primary"></i>
                                            </c:when>
                                            <c:when test="${code.entityType == 'Shipment'}">
                                                <i class="ti ti-truck-delivery text-success"></i>
                                            </c:when>
                                            <c:when test="${code.entityType == 'Stock'}">
                                                <i class="ti ti-boxes text-warning"></i>
                                            </c:when>
                                            <c:when test="${code.entityType == 'ComplianceDocument'}">
                                                <i class="ti ti-file-certificate text-info"></i>
                                            </c:when>
                                            <c:when test="${code.entityType == 'Invoice'}">
                                                <i class="ti ti-receipt text-indigo" style="color: #6366F1;"></i>
                                            </c:when>
                                            <c:when test="${code.entityType == 'Claim'}">
                                                <i class="ti ti-shield-alert text-danger"></i>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="ti ti-tag text-secondary"></i>
                                            </c:otherwise>
                                        </c:choose>
                                        <span>${code.entityType} #${code.entityId}</span>
                                    </div>
                                    <span class="barcode-type-pill ${code.barcodeType}">
                                        ${code.barcodeType == 'Code128' ? 'Code 128' : 'QR Code'}
                                    </span>
                                </div>

                                <!-- Center Barcode Display Frame -->
                                <div class="barcode-display-frame">
                                    <div class="barcode-img-box">
                                        <c:choose>
                                            <%-- Render real image when path available --%>
                                            <c:when test="${not empty cleanImgPath and cleanImgPath != '/CLIENT_RENDERED'}">
                                                <img src="${pageContext.request.contextPath}${cleanImgPath}?v=2" 
                                                     alt="${code.barcodeValue}" 
                                                     class="barcode-img"
                                                     onerror="handleBarcodeImgError(this)" 
                                                     loading="lazy">
                                                <%-- Resilient Fallback vector (hidden until onerror) --%>
                                                <div class="fallback-barcode" style="display: none; width: 100%; justify-content: center; align-items: center;">
                                                    <c:choose>
                                                        <c:when test="${code.barcodeType == 'Code128'}">
                                                            <svg class="barcode-render" jsbarcode-value="${code.barcodeValue}" jsbarcode-width="1.5" jsbarcode-height="46" jsbarcode-fontSize="12"></svg>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="qr-render" data-value="${code.barcodeValue}"></div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:when>
                                            <c:when test="${code.barcodeType == 'Code128'}">
                                                <svg class="barcode-render" jsbarcode-value="${code.barcodeValue}" jsbarcode-width="1.5" jsbarcode-height="46" jsbarcode-fontSize="12"></svg>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="qr-render" data-value="${code.barcodeValue}"></div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <!-- Click-to-copy Barcode Value Chip -->
                                    <div class="barcode-val-badge" onclick="copyBarcodeVal('${code.barcodeValue}', this)" title="Click to copy ${code.barcodeValue}">
                                        <span>${code.barcodeValue}</span>
                                        <i class="ti ti-copy" style="font-size: 13px;"></i>
                                    </div>
                                </div>
                            </div>

                            <!-- Card Footer Actions -->
                            <div class="barcode-card-footer">
                                <small class="text-muted d-flex align-items-center gap-1" style="font-size: 11px;">
                                    <i class="ti ti-clock"></i>
                                    <fmt:formatDate value="${code.generatedAt}" pattern="dd MMM, HH:mm" />
                                </small>
                                <div class="d-flex align-items-center gap-1">
                                    <!-- Print Thermal Sticker -->
                                    <a class="btn-card-action btn-print" 
                                       href="${pageContext.request.contextPath}/barcodes/label?barcodeId=${code.barcodeId}" 
                                       target="_blank" 
                                       title="Print Physical Thermal Label">
                                        <i class="ti ti-printer"></i>
                                    </a>
                                    <!-- Download PNG -->
                                    <button type="button" class="btn-card-action btn-download" 
                                            onclick="downloadCode('card-${code.barcodeId}', '${code.barcodeValue}')" 
                                            title="Download Barcode as PNG">
                                        <i class="ti ti-download"></i>
                                    </button>
                                    <!-- Delete (Admin) -->
                                    <button type="button" class="btn-card-action btn-delete" 
                                            onclick="confirmDeleteBarcode(${code.barcodeId}, '${code.entityType} #${code.entityId}')" 
                                            title="Delete Barcode Record">
                                        <i class="ti ti-trash"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty barcodeList}">
                    <div class="col-12 text-center py-5">
                        <div style="width: 60px; height: 60px; background: #F1F5F9; border-radius: 14px; display: inline-flex; align-items: center; justify-content: center; color: #94A3B8; font-size: 28px; margin-bottom: 12px;">
                            <i class="ti ti-qrcode-off"></i>
                        </div>
                        <h5 class="fw-bold text-dark mb-1">No Barcodes Found</h5>
                        <p class="text-muted small mb-0">No barcodes match the active search term or category criteria.</p>
                    </div>
                </c:if>
            </div>

            <!-- Client Filter Empty State (hidden by default) -->
            <div id="barcodeClientEmptyState" class="text-center py-5" style="display: none;">
                <div style="width: 56px; height: 56px; background: #F1F5F9; border-radius: 12px; display: inline-flex; align-items: center; justify-content: center; color: #94A3B8; font-size: 26px; margin-bottom: 12px;">
                    <i class="ti ti-search-off"></i>
                </div>
                <h5 class="fw-bold text-dark mb-1">No Matching Barcodes</h5>
                <p class="text-muted small mb-3">No registered barcodes on this page match your search query.</p>
                <button type="button" class="btn btn-sm btn-outline-secondary" onclick="clearBarcodeSearch()" style="border-radius: 8px;">
                    <i class="ti ti-rotate me-1"></i> Clear Search
                </button>
            </div>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="nl-pagination-wrapper mt-4 pt-3 border-top">
                    <div class="nl-pagination-info">
                        <span>Page <strong>${currentPage}</strong> of <strong>${totalPages}</strong> &mdash; ${totalCount} barcodes</span>
                    </div>
                    <div class="nl-pagination-nav">
                        <c:if test="${currentPage > 1}">
                            <a class="nl-page-btn nl-page-nav-btn" href="?search=${selectedSearch}&category=${selectedCategory}&page=${currentPage - 1}">
                                <i class="ti ti-chevron-left me-1"></i> Prev
                            </a>
                        </c:if>
                        <c:forEach begin="${currentPage - 2 > 1 ? currentPage - 2 : 1}" end="${currentPage + 2 < totalPages ? currentPage + 2 : totalPages}" var="p">
                            <a class="nl-page-btn nl-page-num ${p == currentPage ? 'active' : ''}" href="?search=${selectedSearch}&category=${selectedCategory}&page=${p}">${p}</a>
                        </c:forEach>
                        <c:if test="${currentPage < totalPages}">
                            <a class="nl-page-btn nl-page-nav-btn" href="?search=${selectedSearch}&category=${selectedCategory}&page=${currentPage + 1}">
                                Next <i class="ti ti-chevron-right ms-1"></i>
                            </a>
                        </c:if>
                    </div>
                </div>
            </c:if>
        </div>

        <!-- FR8.4: Batch Label Sheet Banner -->
        <c:if test="${not empty barcodeList}">
            <div class="nl-batchprint-bar" data-no-tools="true">
                <div class="d-flex align-items-center gap-3">
                    <div style="width: 44px; height: 44px; background: rgba(252, 128, 25, 0.15); border-radius: 10px; display: flex; align-items: center; justify-content: center; color: #FC8019; font-size: 22px;">
                        <i class="ti ti-printer"></i>
                    </div>
                    <div>
                        <strong>Batch Thermal Label Sheet</strong>
                        <span>Print all ${barcodeList.size()} labels currently listed onto a continuous A4 sticker sheet ready for dock affixing.</span>
                    </div>
                </div>
                <a class="nl-batchprint-btn" target="_blank"
                   href="${pageContext.request.contextPath}/barcodes/label?batch=1&amp;search=${selectedSearch}&amp;category=${selectedCategory}&amp;page=${currentPage}&amp;pageSize=${pageSize}">
                    <i class="ti ti-printer"></i> Print Batch Sheet
                </a>
            </div>
        </c:if>

        <!-- FR8.5: Scan Audit Trail -->
        <div class="nl-scanlog-card" data-no-tools="true">
            <div class="nl-scanlog-head">
                <div class="d-flex align-items-center gap-2">
                    <div style="width: 38px; height: 38px; background: #FFF7ED; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #EA580C; font-size: 18px;">
                        <i class="ti ti-scan"></i>
                    </div>
                    <div>
                        <h3 class="mb-0">Scan Audit Trail</h3>
                        <p>Most recent physical scans across dock terminals, checkpoints, and handheld scanners.</p>
                    </div>
                </div>
                <span class="nl-scanlog-count">${recentScans.size()} Scans Recorded</span>
            </div>

            <c:choose>
                <c:when test="${empty recentScans}">
                    <div class="text-center py-4 text-muted">
                        <i class="ti ti-scan" style="font-size: 32px; display: block; margin-bottom: 8px; color: #CBD5E1;"></i>
                        <p class="mb-0" style="font-size: 13px;">No barcode scans recorded yet. Scans from the handheld dock terminal will appear here automatically.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="nl-scanlog-scroll">
                        <table class="nl-scanlog-table">
                            <thead>
                                <tr>
                                    <th>Scanned At</th>
                                    <th>Barcode Value</th>
                                    <th>Entity Reference</th>
                                    <th>Scanned By</th>
                                    <th>Checkpoint / Location</th>
                                    <th>Scanner Device</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="sc" items="${recentScans}">
                                    <tr>
                                        <td><fmt:formatDate value="${sc.scannedAt}" pattern="dd MMM yyyy, HH:mm"/></td>
                                        <td><code>${sc.barcodeValue}</code></td>
                                        <td><span class="nl-scanlog-chip">${sc.entityType} #${sc.entityId}</span></td>
                                        <td><strong>${empty sc.username ? '&mdash;' : sc.username}</strong></td>
                                        <td><i class="ti ti-map-pin text-muted me-1"></i>${empty sc.location ? 'Dock / Checkpoint' : sc.location}</td>
                                        <td><span class="badge bg-light text-dark border"><i class="ti ti-device-mobile me-1"></i>${empty sc.device ? 'Terminal 1' : sc.device}</span></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

    </div>
</div>

<!-- Generate New Barcode Modal -->
<div class="modal fade" id="generateBarcodeModal" tabindex="-1" aria-labelledby="genBarcodeModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width: 480px;">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px; overflow: hidden;">
            <div class="modal-header text-white" style="background: linear-gradient(135deg, #0F172A 0%, #1E293B 100%); border-bottom: none; padding: 18px 22px;">
                <div class="d-flex align-items-center gap-3">
                    <div style="width: 40px; height: 40px; background: rgba(252, 128, 25, 0.2); border: 1px solid rgba(252, 128, 25, 0.4); border-radius: 10px; display: flex; align-items: center; justify-content: center; color: #FC8019; font-size: 20px;">
                        <i class="ti ti-qrcode"></i>
                    </div>
                    <div>
                        <h5 class="modal-title fw-bold mb-0 text-white" id="genBarcodeModalLabel">Generate New Code</h5>
                        <small style="color: #94A3B8; font-size: 12px;">Create scannable 1D or 2D code for fleet tracking</small>
                    </div>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <form action="<c:url value='/barcodes'/>" method="POST">
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label text-dark fw-semibold" style="font-size: 13.5px;">Entity Type <span class="text-danger">*</span></label>
                        <select name="entityType" id="genEntityTypeSelect" class="form-select no-custom-select" required onchange="onEntityTypeChange(this.value)" style="border-radius: 8px; font-size: 13.5px;">
                            <option value="Container" selected>Container</option>
                            <option value="Shipment">Shipment</option>
                            <option value="Stock">Stock Inventory</option>
                            <option value="ComplianceDocument">Compliance Document</option>
                            <option value="Invoice">Invoice</option>
                            <option value="Claim">Claim</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <label class="form-label text-dark fw-semibold mb-0" style="font-size: 13.5px;">
                                Entity Record <span class="text-danger">*</span>
                            </label>
                            <span id="entityLoadingSpinner" class="spinner-border spinner-border-sm text-primary d-none" role="status" style="width: 1rem; height: 1rem;"></span>
                        </div>
                        <select name="entityId" id="genEntityIdSelect" class="form-select no-custom-select" required onchange="onEntityIdSelected(this)" style="border-radius: 8px; font-size: 13.5px;">
                            <option value="" disabled selected>-- Select Container --</option>
                            <c:set var="unassignedCount" value="0" />
                            <c:set var="assignedCount" value="0" />
                            <c:forEach var="ent" items="${defaultEntities}">
                                <c:choose>
                                    <c:when test="${!ent.hasBarcode}"><c:set var="unassignedCount" value="${unassignedCount + 1}" /></c:when>
                                    <c:otherwise><c:set var="assignedCount" value="${assignedCount + 1}" /></c:otherwise>
                                </c:choose>
                            </c:forEach>
                            <c:if test="${unassignedCount > 0}">
                                <optgroup label="★ Ready for Barcode (Unassigned)">
                                    <c:forEach var="ent" items="${defaultEntities}">
                                        <c:if test="${!ent.hasBarcode}">
                                            <option value="${ent.id}" data-has-barcode="false" data-barcode-val="">
                                                ★ ${ent.label} (Unassigned)
                                            </option>
                                        </c:if>
                                    </c:forEach>
                                </optgroup>
                            </c:if>
                            <c:if test="${assignedCount > 0}">
                                <optgroup label="Already Barcoded">
                                    <c:forEach var="ent" items="${defaultEntities}">
                                        <c:if test="${ent.hasBarcode}">
                                            <option value="${ent.id}" data-has-barcode="true" data-barcode-val="${ent.barcodeValue}">
                                                ${ent.label} [Barcoded: ${ent.barcodeValue}]
                                            </option>
                                        </c:if>
                                    </c:forEach>
                                </optgroup>
                            </c:if>
                        </select>
                        <div id="entityAlreadyBarcodedWarning" class="alert alert-warning py-1 px-2 mt-2 d-none" style="font-size: 12px; border-radius: 6px;">
                            <i class="ti ti-alert-triangle me-1"></i>
                            <span>This entity already carries barcode <strong id="warnBarcodeVal"></strong>. Submitting will redirect to view/reprint that label.</span>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label class="form-label text-dark fw-semibold" style="font-size: 13.5px;">Format (FR8.2) <span class="text-danger">*</span></label>
                        <select name="barcodeType" class="form-select" required style="border-radius: 8px; font-size: 13.5px;">
                            <option value="Code128">1D Barcode (Code128)</option>
                            <option value="QR" selected>2D QR Code</option>
                        </select>
                    </div>

                    <button type="submit" class="btn-create-code w-100 justify-content-center py-2" style="border-radius: 8px; font-size: 14px;">
                        <i class="ti ti-qrcode me-1"></i> Generate Code
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Delete Barcode Confirm Modal -->
<div class="modal fade" id="deleteBarcodeModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 14px;">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold"><i class="ti ti-alert-triangle" style="color:#DC2626;"></i> Delete Barcode?</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p class="mb-0">Are you sure you want to permanently delete the barcode for <strong id="deleteBarcodeLabel"></strong>? This also removes its scan history. This cannot be undone.</p>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius:8px;">Cancel</button>
                <form method="POST" action="${pageContext.request.contextPath}/barcodes">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="barcodeId" id="deleteBarcodeId">
                    <input type="hidden" name="returnQs" id="deleteBarcodeReturnQs">
                    <button type="submit" class="btn btn-danger" style="border-radius:8px;"><i class="ti ti-trash"></i> Yes, Delete</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        // Render 1D Barcodes
        if (window.JsBarcode) {
            try {
                JsBarcode(".barcode-render").init();
            } catch (e) {
                console.warn("JsBarcode init warning:", e);
            }
        }

        // Render QR Codes
        if (window.QRCode) {
            document.querySelectorAll('.qr-render').forEach(function(el) {
                if (!el.hasChildNodes()) {
                    let val = el.getAttribute('data-value');
                    try {
                        new QRCode(el, {
                            text: val,
                            width: 100,
                            height: 100,
                            colorDark: "#0F172A",
                            colorLight: "#FFFFFF",
                            correctLevel: QRCode.CorrectLevel.M
                        });
                    } catch (e) {
                        console.warn("QRCode init warning:", e);
                    }
                }
            });
        }
    });

    // Handle missing or 404 barcode image gracefully by switching to vector renderer
    window.handleBarcodeImgError = function(img) {
        if (!img) return;
        img.style.display = 'none';
        const fallback = img.nextElementSibling;
        if (fallback) {
            fallback.style.display = 'flex';
            const svg = fallback.querySelector('svg.barcode-render');
            if (svg && window.JsBarcode) {
                try { JsBarcode(svg).init(); } catch (e) { console.warn(e); }
            }
            const qr = fallback.querySelector('.qr-render');
            if (qr && window.QRCode && !qr.hasChildNodes()) {
                try {
                    new QRCode(qr, {
                        text: qr.getAttribute('data-value'),
                        width: 100,
                        height: 100,
                        colorDark: "#0F172A",
                        colorLight: "#FFFFFF",
                        correctLevel: QRCode.CorrectLevel.M
                    });
                } catch (e) { console.warn(e); }
            }
        }
    };

    // Fast client-side instant filtering as user types
    window.onBarcodeSearchKeyUp = function(e) {
        const query = (document.getElementById('barcodeSearchInput').value || '').trim().toLowerCase();
        const clearBtn = document.getElementById('barcodeSearchClearBtn');
        if (clearBtn) clearBtn.style.display = query.length > 0 ? 'block' : 'none';

        if (e && e.key === 'Enter') {
            submitBarcodeFilter();
            return;
        }

        const items = document.querySelectorAll('#barcodeCardsGrid .barcode-col-item');
        let visibleCount = 0;

        items.forEach(item => {
            const entity = item.dataset.entity || '';
            const entityId = item.dataset.entityId || '';
            const codeVal = item.dataset.codeVal || '';
            const codeType = (item.dataset.codeType || '').toLowerCase();

            const match = !query || 
                entity.includes(query) || 
                entityId.includes(query) || 
                codeVal.includes(query) || 
                codeType.includes(query);

            if (match) {
                item.style.display = '';
                visibleCount++;
            } else {
                item.style.display = 'none';
            }
        });

        const emptyState = document.getElementById('barcodeClientEmptyState');
        if (emptyState) {
            emptyState.style.display = (visibleCount === 0 && items.length > 0) ? 'block' : 'none';
        }
    };

    window.clearBarcodeSearch = function() {
        const input = document.getElementById('barcodeSearchInput');
        if (input) input.value = '';
        onBarcodeSearchKeyUp();
        // If server query was present, reload clean
        if (window.location.search.includes('search=')) {
            submitBarcodeFilter();
        }
    };

    window.submitBarcodeFilter = function() {
        const query = (document.getElementById('barcodeSearchInput').value || '').trim();
        document.getElementById('barcodeFormSearch').value = query;
        document.getElementById('barcodeFilterForm').submit();
    };

    // Click to copy barcode value with visual feedback
    window.copyBarcodeVal = function(val, badge) {
        if (!val) return;
        if (navigator.clipboard) {
            navigator.clipboard.writeText(val).then(() => showCopyFeedback(badge)).catch(() => fallbackCopy(val, badge));
        } else {
            fallbackCopy(val, badge);
        }
    };

    function fallbackCopy(val, badge) {
        const ta = document.createElement('textarea');
        ta.value = val;
        document.body.appendChild(ta);
        ta.select();
        document.execCommand('copy');
        document.body.removeChild(ta);
        showCopyFeedback(badge);
    }

    function showCopyFeedback(badge) {
        if (!badge) return;
        const orig = badge.innerHTML;
        badge.innerHTML = '<span class="text-success fw-bold"><i class="ti ti-check me-1"></i>Copied</span>';
        setTimeout(() => { badge.innerHTML = orig; }, 1800);
    }

    // Delete barcode confirm dialog
    window.confirmDeleteBarcode = function(barcodeId, label) {
        document.getElementById('deleteBarcodeLabel').textContent = label;
        document.getElementById('deleteBarcodeId').value = barcodeId;
        document.getElementById('deleteBarcodeReturnQs').value = window.location.search.replace(/^\?/, '');
        var modal = bootstrap.Modal.getOrCreateInstance(document.getElementById('deleteBarcodeModal'));
        modal.show();
    };

    // FR8.1/FR8.2 Modal Dynamic Dropdown: Fetch entities dynamically on Entity Type change
    window.onEntityTypeChange = function(entityType) {
        const select = document.getElementById('genEntityIdSelect');
        const spinner = document.getElementById('entityLoadingSpinner');
        const warning = document.getElementById('entityAlreadyBarcodedWarning');
        if (warning) warning.classList.add('d-none');
        if (!select) return;

        select.innerHTML = '<option value="" disabled selected>Loading ' + entityType + ' records...</option>';
        select.disabled = true;
        if (spinner) spinner.classList.remove('d-none');

        const contextPath = '${pageContext.request.contextPath}';
        fetch(contextPath + '/barcodes?action=getEntities&type=' + encodeURIComponent(entityType))
            .then(res => res.json())
            .then(data => {
                select.innerHTML = '';
                if (!data || data.length === 0) {
                    select.innerHTML = '<option value="" disabled selected>No records found for ' + entityType + '</option>';
                    select.disabled = true;
                    return;
                }

                const defaultOpt = document.createElement('option');
                defaultOpt.value = '';
                defaultOpt.disabled = true;
                defaultOpt.selected = true;
                defaultOpt.textContent = '-- Select ' + entityType + ' --';
                select.appendChild(defaultOpt);

                let unassignedGroup = document.createElement('optgroup');
                unassignedGroup.label = '★ Ready for Barcode (Unassigned)';
                let assignedGroup = document.createElement('optgroup');
                assignedGroup.label = 'Already Barcoded';

                data.forEach(item => {
                    const opt = document.createElement('option');
                    opt.value = item.id;
                    opt.setAttribute('data-has-barcode', item.hasBarcode);
                    opt.setAttribute('data-barcode-val', item.barcodeValue || '');

                    if (!item.hasBarcode) {
                        opt.textContent = '★ ' + item.label + ' (Unassigned)';
                        unassignedGroup.appendChild(opt);
                    } else {
                        opt.textContent = item.label + ' [Barcoded: ' + item.barcodeValue + ']';
                        assignedGroup.appendChild(opt);
                    }
                });

                if (unassignedGroup.children.length > 0) {
                    select.appendChild(unassignedGroup);
                }
                if (assignedGroup.children.length > 0) {
                    select.appendChild(assignedGroup);
                }
                select.disabled = false;
            })
            .catch(err => {
                console.error('Error fetching entities:', err);
                select.innerHTML = '<option value="" disabled selected>Error loading ' + entityType + ' records</option>';
                select.disabled = true;
            })
            .finally(() => {
                if (spinner) spinner.classList.add('d-none');
            });
    };

    window.onEntityIdSelected = function(sel) {
        const warning = document.getElementById('entityAlreadyBarcodedWarning');
        const warnVal = document.getElementById('warnBarcodeVal');
        if (!sel || !warning) return;
        const selectedOpt = sel.options[sel.selectedIndex];
        if (selectedOpt && selectedOpt.getAttribute('data-has-barcode') === 'true') {
            const bVal = selectedOpt.getAttribute('data-barcode-val');
            if (warnVal) warnVal.textContent = bVal;
            warning.classList.remove('d-none');
        } else {
            warning.classList.add('d-none');
        }
    };

    // FR8.6 Print / Export Logic
    window.downloadCode = function(cardId, val) {
        const element = document.getElementById(cardId);
        if (!element || !window.html2canvas) return;
        html2canvas(element, { scale: 2 }).then(canvas => {
            let link = document.createElement('a');
            link.download = 'Barcode_' + val + '.png';
            link.href = canvas.toDataURL("image/png");
            link.click();
        });
    };
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
