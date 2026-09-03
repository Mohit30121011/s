<%@ page language="java" contentType="text/html; charset=UTF-8" session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    .page-header-flex {
        display: flex;
        justify-content: space-between;
        align-items: flex-end;
        margin-bottom: 24px;
    }

    .card-panel {
        background: #FFFFFF;
        border-radius: 14px;
        border: 1px solid var(--nl-border);
        box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
        padding: 24px 28px;
        margin-bottom: 24px;
    }

    /* Top Stats Card */
    .stats-container {
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 24px;
    }
    .stats-left {
        display: flex;
        align-items: center;
        gap: 16px;
        flex: 2;
        min-width: 280px;
    }
    .stats-icon-box {
        width: 54px;
        height: 54px;
        background: #FFF2EB;
        color: #FC8019;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 26px;
        flex-shrink: 0;
    }
    .stats-title {
        font-size: 20px;
        font-weight: 700;
        color: var(--nl-text);
        margin-bottom: 2px;
        letter-spacing: -0.3px;
    }
    .stats-subtitle {
        font-size: 13px;
        color: var(--nl-text-muted);
    }

    .stats-items {
        display: flex;
        gap: 36px;
        flex-wrap: wrap;
        justify-content: flex-end;
    }
    .stat-block {
        display: flex;
        flex-direction: column;
    }
    .stat-label {
        font-size: 12px;
        color: var(--nl-text-muted);
        font-weight: 600;
        margin-bottom: 4px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    .stat-value {
        font-size: 26px;
        font-weight: 800;
        color: var(--nl-text);
        line-height: 1;
    }
    .stat-value.primary { color: #FC8019; }
    .stat-value.blue { color: #2563EB; }
    .stat-value.amber { color: #D97706; }
    .stat-value.danger { color: #DC2626; }

    /* Filter Row */
    .filter-card {
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
    .filter-search {
        position: relative;
        flex: 1;
        min-width: 240px;
    }
    .filter-search i {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--nl-text-muted);
        font-size: 14px;
        pointer-events: none;
    }
    .filter-search input {
        width: 100%;
        padding: 9px 16px 9px 38px;
        border: 1px solid #E2E5EA;
        border-radius: 8px;
        font-size: 13.5px;
        outline: none;
        background: #FFFFFF;
        color: var(--nl-text);
        transition: border-color 0.15s ease, box-shadow 0.15s ease;
    }
    .filter-search input:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .filter-select {
        min-width: 170px;
    }
    .filter-select select {
        padding: 9px 14px;
        border: 1px solid #E2E5EA;
        border-radius: 8px;
        font-size: 13.5px;
        background: #FFFFFF;
        color: #374151;
        outline: none;
        cursor: pointer;
        width: 100%;
        transition: border-color 0.15s ease;
    }
    .filter-select select:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .filter-reset-btn {
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
        margin-left: auto;
    }
    .filter-reset-btn:hover {
        background: #F8FAFC;
        color: var(--nl-primary);
        border-color: #CBD5E1;
    }

    /* Data Table */
    .table-panel {
        background: #FFFFFF;
        border-radius: 14px;
        border: 1px solid var(--nl-border);
        box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
        overflow: hidden;
        margin-bottom: 24px;
    }
    .table-header {
        padding: 20px 24px 16px 24px;
        border-bottom: 1px solid #F1F3F6;
    }
    .table-title {
        font-size: 17px;
        font-weight: 700;
        color: var(--nl-text);
        margin-bottom: 2px;
    }
    .table-subtitle {
        font-size: 12.5px;
        color: var(--nl-text-muted);
    }

    .tracking-table {
        width: 100%;
        border-collapse: collapse;
    }
    .tracking-table th {
        font-size: 12px;
        color: #64748B;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.4px;
        padding: 12px 20px;
        border-bottom: 1px solid #E2E8F0;
        background: #F8FAFC;
        text-align: left;
    }
    
    /* Action Pill Button with Hover Highlight */
    .btn-tracking-details {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 16px;
        border-radius: 50px;
        font-size: 12px;
        font-weight: 600;
        color: #475569;
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        text-decoration: none;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);
        cursor: pointer;
    }
    .btn-tracking-details i {
        font-size: 11px;
        color: #94A3B8;
        transition: transform 0.2s ease, color 0.2s ease;
    }
    .btn-tracking-details:hover {
        background: #FC8019 !important;
        border-color: transparent !important;
        color: #FFFFFF !important;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.32);
        text-decoration: none;
    }
    .btn-tracking-details:hover i {
        color: #FFFFFF !important;
        transform: translateX(2px);
    }
    .btn-tracking-details:active {
        transform: translateY(0);
        box-shadow: 0 1px 3px rgba(252, 128, 25, 0.2);
    }
    .tracking-row:hover .btn-tracking-details {
        border-color: #CBD5E1;
        background: #FFFFFF;
        color: #0F172A;
    }
    .tracking-row:hover .btn-tracking-details:hover {
        background: #FC8019 !important;
        color: #FFFFFF !important;
        border-color: transparent !important;
    }

    .tracking-table td {
        padding: 14px 20px;
        font-size: 13.5px;
        color: var(--nl-text);
        border-bottom: 1px solid #F1F3F6;
        vertical-align: middle;
    }
    .tracking-table tbody tr {
        cursor: pointer;
        transition: background-color 0.15s ease;
    }
    .tracking-table tbody tr:hover {
        background-color: #FFF9F5;
    }
    .tracking-table tbody tr:last-child td {
        border-bottom: none;
    }

    .shipment-id-cell {
        font-weight: 600;
        color: #FC8019;
    }
    .vessel-name-cell {
        font-weight: 500;
        color: #374151;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    /* Status Badges */
    .status-badge {
        padding: 5px 12px;
        border-radius: 20px;
        font-weight: 600;
        font-size: 12px;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        white-space: nowrap;
    }
</style>

<div class="page-header-flex">
    <div>
        <h2 style="font-weight: 700; margin-bottom: 6px; color: var(--nl-text); font-size: 24px;">Live Shipment Tracking</h2>
        <div class="custom-breadcrumb d-flex align-items-center" style="margin-bottom: 0; font-size: 13px; color: var(--nl-text-muted);">
            <a href="${pageContext.request.contextPath}/dashboard" style="color: var(--nl-text-muted); text-decoration: none;">Dashboard</a>
            <i class="ti ti-chevron-right mx-2" style="font-size: 11px;"></i>
            <a href="${pageContext.request.contextPath}/shipments" style="color: var(--nl-text-muted); text-decoration: none;">Shipments</a>
            <i class="ti ti-chevron-right mx-2" style="font-size: 11px;"></i>
            <span style="color: var(--nl-primary); font-weight: 600;">Live Tracking</span>
        </div>
    </div>
    <a href="${pageContext.request.contextPath}/shipments" class="btn btn-light" style="border: 1px solid var(--nl-border); font-weight: 600; font-size: 13px; border-radius: 8px; background: #fff; padding: 9px 18px; color: #4B5563;">
        <i class="ti ti-arrow-left me-1"></i> Back to Shipments
    </a>
</div>

<!-- Top Stats Card (100% Real Database Analytics) -->
<div class="card-panel">
    <div class="stats-container">
        <div class="stats-left">
            <div class="stats-icon-box">
                <i class="ti ti-radar"></i>
            </div>
            <div>
                <div class="stats-title">Real-Time Logistics Telemetry</div>
                <div class="stats-subtitle"><strong style="color: var(--nl-text);">${not empty activeCount ? activeCount : 0}</strong> active shipments currently being monitored</div>
            </div>
        </div>
        <div class="stats-items">
            <div class="stat-block">
                <span class="stat-label">Active Shipments</span>
                <span class="stat-value primary">${not empty activeCount ? activeCount : 0}</span>
            </div>
            <div class="stat-block">
                <span class="stat-label">In Transit</span>
                <span class="stat-value blue">${not empty inTransitCount ? inTransitCount : 0}</span>
            </div>
            <div class="stat-block">
                <span class="stat-label">Customs Hold</span>
                <span class="stat-value amber">${not empty customsHoldCount ? customsHoldCount : 0}</span>
            </div>
            <div class="stat-block">
                <span class="stat-label">Delayed</span>
                <span class="stat-value danger">${not empty delayedCount ? delayedCount : 0}</span>
            </div>
        </div>
    </div>
</div>

<!-- Interactive Live Filter Bar -->
<div class="filter-card">
    <div class="filter-search">
        <i class="ti ti-search"></i>
        <input type="text" id="searchInput" placeholder="Search by shipment ID, port, vessel...">
    </div>
    <div class="filter-select">
        <select id="statusFilter" class="form-select form-select-custom">
            <option value="" selected>All Statuses</option>
            <option value="Booked">Booked</option>
            <option value="Container Allocated">Container Allocated</option>
            <option value="Departed">Departed</option>
            <option value="In Transit">In Transit</option>
            <option value="Customs Hold">Customs Hold</option>
            <option value="Arrived">Arrived</option>
            <option value="Delivered">Delivered</option>
        </select>
    </div>
    <div class="filter-select">
        <select id="vesselFilter" class="form-select form-select-custom">
            <option value="" selected>All Vessels</option>
            <c:forEach var="v" items="${vessels}">
                <option value="${v.vesselName}">${v.vesselName}</option>
            </c:forEach>
        </select>
    </div>
    <button class="filter-reset-btn" id="resetFiltersBtn" title="Reset Filters" type="button">
        <i class="ti ti-rotate"></i>
    </button>
</div>

<!-- Table Card -->
<div class="table-panel">
    <div class="table-header">
        <div class="table-title">Active Monitoring Fleet</div>
        <div class="table-subtitle">Live tracking updates, vessel assignments, and estimated arrival milestones</div>
    </div>

    <div class="table-responsive">
        <table class="tracking-table" id="trackingTable">
            <thead>
                <tr>
                    <th style="padding-left: 24px;">Shipment</th>
                    <th>Customer</th>
                    <th>Shipping Route</th>
                    <th>Assigned Vessel</th>
                    <th>Status</th>
                    <th>ETA</th>
                    <th>Last Updated</th>
                    <th style="padding-right: 24px; text-align: right;">Action</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="shipment" items="${shipments}">
                    <tr class="tracking-row" 
                        data-id="SHP-${shipment.shipmentId}"
                        data-status="${shipment.status}"
                        data-vessel="${shipment.vesselName}"
                        onclick="window.location.href='${pageContext.request.contextPath}/shipments/tracking/detail?id=SHP-${shipment.shipmentId}'">
                        <td style="padding-left: 24px;">
                            <span class="shipment-id-cell">#SHP-${shipment.shipmentId}</span>
                        </td>
                        <td>
                            <span style="font-weight: 600; color: #1F2937;">${shipment.customerName}</span>
                        </td>
                        <td>
                            <div style="display: flex; align-items: center; gap: 8px; font-weight: 500;">
                                <span>${shipment.originPort}</span>
                                <i class="ti ti-arrow-right" style="color: #FC8019; font-size: 14px;"></i>
                                <span>${shipment.destPort}</span>
                            </div>
                        </td>
                        <td>
                            <div class="vessel-name-cell">
                                <i class="ti ti-ship" style="color: #64748B; font-size: 15px;"></i>
                                <span>${not empty shipment.vesselName ? shipment.vesselName : 'Ocean Vessel'}</span>
                            </div>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${shipment.status == 'Delivered'}">
                                    <span class="status-badge" style="background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0;">
                                        <i class="ti ti-circle-check"></i> Delivered
                                    </span>
                                </c:when>
                                <c:when test="${shipment.status == 'In Transit'}">
                                    <span class="status-badge" style="background: #EFF6FF; color: #2563EB; border: 1px solid #BFDBFE;">
                                        <i class="ti ti-navigation"></i> In Transit
                                    </span>
                                </c:when>
                                <c:when test="${shipment.status == 'Customs Hold'}">
                                    <span class="status-badge" style="background: #FFF7ED; color: #EA580C; border: 1px solid #FED7AA;">
                                        <i class="ti ti-clock"></i> Customs Hold
                                    </span>
                                </c:when>
                                <c:when test="${shipment.status == 'Departed'}">
                                    <span class="status-badge" style="background: #F5F3FF; color: #7C3AED; border: 1px solid #DDD6FE;">
                                        <i class="ti ti-anchor"></i> Departed
                                    </span>
                                </c:when>
                                <c:when test="${shipment.status == 'Container Allocated'}">
                                    <span class="status-badge" style="background: #F0FDF4; color: #16A34A; border: 1px solid #BBF7D0;">
                                        <i class="ti ti-box"></i> Allocated
                                    </span>
                                </c:when>
                                <c:when test="${shipment.status == 'Delayed'}">
                                    <span class="status-badge" style="background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA;">
                                        <i class="ti ti-alert-triangle"></i> Delayed
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-badge" style="background: #F8FAFC; color: #475569; border: 1px solid #E2E8F0;">
                                        ${shipment.status}
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td style="color: #374151; font-weight: 500;">
                            <c:choose>
                                <c:when test="${not empty shipment.eta}">
                                    <fmt:formatDate value="${shipment.eta}" pattern="MMM dd, yyyy" />
                                </c:when>
                                <c:otherwise><span style="color: #9CA3AF;">Pending</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td style="color: #64748B; font-size: 13px;">
                            <c:choose>
                                <c:when test="${not empty shipment.updatedAt}">
                                    <fmt:formatDate value="${shipment.updatedAt}" pattern="MMM dd, hh:mm a" />
                                </c:when>
                                <c:otherwise><span style="color: #9CA3AF;">N/A</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td style="padding-right: 24px; text-align: right;">
                            <a href="${pageContext.request.contextPath}/shipments/tracking/detail?id=SHP-${shipment.shipmentId}" class="btn-tracking-details" onclick="event.stopPropagation();">
                                <span>Details</span>
                                <i class="ti ti-arrow-right"></i>
                            </a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <!-- Enterprise Theme Pagination Bar -->
    <div class="nl-pagination-wrapper" id="trackingPagination">
        <div class="nl-pagination-info">
            <span>Showing <strong id="trackingPageStart">1</strong> to <strong id="trackingPageEnd">10</strong> of <strong id="trackingTotalRows">0</strong> shipments</span>
            <div class="d-inline-flex align-items-center gap-2 ms-2">
                <span style="color: #94A3B8; font-size: 12.5px;">Rows per page:</span>
                <select id="trackingPageSize" class="nl-page-size-select no-custom-select">
                    <option value="10" selected>10</option>
                    <option value="25">25</option>
                    <option value="50">50</option>
                    <option value="100">100</option>
                </select>
            </div>
        </div>
        <div class="nl-pagination-nav" id="trackingPageNav">
            <!-- Dynamically generated buttons -->
        </div>
    </div>
</div>

<div style="font-size: 12.5px; color: var(--nl-text-muted); margin-bottom: 40px; display: flex; align-items: center; gap: 6px;">
    <i class="ti ti-info-circle" style="color: #FC8019;"></i> Click any shipment row to inspect live GPS checkpoint events, milestone progression, and movement audit logs.
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    const searchInput = document.getElementById('searchInput');
    const statusFilter = document.getElementById('statusFilter');
    const vesselFilter = document.getElementById('vesselFilter');
    const resetBtn = document.getElementById('resetFiltersBtn');
    const allRows = Array.from(document.querySelectorAll('.tracking-row'));
    const pageSizeSelect = document.getElementById('trackingPageSize');
    const pageNav = document.getElementById('trackingPageNav');
    const pageStartEl = document.getElementById('trackingPageStart');
    const pageEndEl = document.getElementById('trackingPageEnd');
    const totalRowsEl = document.getElementById('trackingTotalRows');
    const tableBody = document.querySelector('#trackingTable tbody');

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

        allRows.forEach(row => { row.style.display = 'none'; });

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

    function filterRows() {
        const query = searchInput ? searchInput.value.toLowerCase().trim() : '';
        const selectedStatus = statusFilter ? statusFilter.value.toLowerCase().trim() : '';
        const selectedVessel = vesselFilter ? vesselFilter.value.toLowerCase().trim() : '';
        matchingRows = [];

        allRows.forEach(row => {
            const rowText = row.textContent.toLowerCase();
            const rowStatus = (row.dataset.status || '').toLowerCase();
            const rowVessel = (row.dataset.vessel || '').toLowerCase();

            const matchesQuery = !query || rowText.includes(query);
            const matchesStatus = !selectedStatus || rowStatus === selectedStatus;
            const matchesVessel = !selectedVessel || rowVessel === selectedVessel;

            if (matchesQuery && matchesStatus && matchesVessel) {
                matchingRows.push(row);
            }
        });

        let noResults = document.getElementById('trackingNoResultsRow');
        if (matchingRows.length === 0 && allRows.length > 0) {
            if (!noResults && tableBody) {
                noResults = document.createElement('tr');
                noResults.id = 'trackingNoResultsRow';
                noResults.innerHTML = '<td colspan="8" style="text-align: center; padding: 48px; color: var(--nl-text-muted);">' +
                    '<i class="ti ti-radar" style="font-size: 28px; color: #D1D5DB; margin-bottom: 12px; display: block;"></i>' +
                    'No tracking shipments found matching current filters</td>';
                tableBody.appendChild(noResults);
            } else if (noResults) {
                noResults.style.display = '';
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
        searchInput.addEventListener('input', filterRows);
    }
    if (statusFilter) {
        statusFilter.addEventListener('change', filterRows);
    }
    if (vesselFilter) {
        vesselFilter.addEventListener('change', filterRows);
    }

    if (resetBtn) {
        resetBtn.addEventListener('click', function() {
            if (searchInput) searchInput.value = '';
            if (statusFilter) {
                statusFilter.value = '';
                if (statusFilter.tomselect) statusFilter.tomselect.setValue('');
            }
            if (vesselFilter) {
                vesselFilter.value = '';
                if (vesselFilter.tomselect) vesselFilter.tomselect.setValue('');
            }
            filterRows();
        });
    }

    filterRows();
});
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
