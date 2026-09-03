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

    /* Filter Row */
    .filter-card {
        background: #fff; border-radius: 12px; border: 1px solid var(--border-color);
        padding: 16px; margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between;
    }
    
    .filter-search {
        position: relative;
        width: 400px;
    }
    .filter-search .search-icon {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--text-muted);
        font-size: 14px;
        pointer-events: none;
    }
    .filter-search input {
        width: 100%;
        padding: 10px 36px 10px 38px;
        border: 1px solid var(--border-color);
        border-radius: 8px;
        font-size: 13.5px;
        outline: none;
        background: #FFFFFF;
        color: var(--text-dark);
        transition: border-color 0.2s, box-shadow 0.2s;
    }
    .filter-search input:focus {
        border-color: var(--brand-orange);
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .filter-search .clear-icon {
        position: absolute;
        right: 12px;
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

    /* Action Button */
    .btn-book {
        background: var(--brand-orange); color: white; border: none; padding: 10px 20px;
        border-radius: 8px; font-size: 13px; font-weight: 600; display: inline-flex;
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
        <a href="${pageContext.request.contextPath}/shipments/create" class="btn-book">
            <i class="fa-solid fa-plus"></i> Book Shipment
        </a>
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
                        <td style="font-family: monospace; color: var(--brand-orange);">${s.containerNumber}</td>
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
                            <div style="display: flex; gap: 8px; justify-content: center;">
                                <a href="${pageContext.request.contextPath}/shipments/edit?id=${s.shipmentId}" class="btn-icon-action edit" title="Edit Shipment">
                                    <i class="ti ti-pencil"></i>
                                </a>
                                <button class="btn-icon-action delete" data-bs-toggle="modal" data-bs-target="#deleteModal${s.shipmentId}" title="Delete Shipment">
                                    <i class="ti ti-trash"></i>
                                </button>
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
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>


<script>
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('shipmentSearchInput');
    const searchBtn = document.getElementById('searchBtn');
    const clearBtn = document.getElementById('clearSearchBtn');
    const table = document.querySelector('.tracking-table tbody');

    if (!table) return;

    function performSearch() {
        const query = searchInput.value.toLowerCase().trim();
        const rows = table.querySelectorAll('tr:not(.no-results-row)');
        let visibleCount = 0;

        rows.forEach(function(row) {
            const cells = Array.from(row.querySelectorAll('td')).slice(0, 6);
            const rowText = cells.map(td => td.textContent.toLowerCase()).join(' ');
            
            if (!query || rowText.includes(query)) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });

        if (query.length > 0) {
            clearBtn.classList.remove('d-none');
        } else {
            clearBtn.classList.add('d-none');
        }

        let noResults = document.getElementById('noSearchResultsRow');
        if (visibleCount === 0 && rows.length > 0) {
            if (!noResults) {
                noResults = document.createElement('tr');
                noResults.id = 'noSearchResultsRow';
                noResults.className = 'no-results-row';
                noResults.innerHTML = '<td colspan="7" style="text-align: center; padding: 48px; color: var(--text-muted);">' +
                    '<i class="fa-solid fa-magnifying-glass" style="font-size: 28px; color: #D1D5DB; margin-bottom: 12px; display: block;"></i>' +
                    'No shipments matching "' + searchInput.value + '"</td>';
                table.appendChild(noResults);
            } else {
                noResults.style.display = '';
                noResults.querySelector('td').innerHTML = '<i class="fa-solid fa-magnifying-glass" style="font-size: 28px; color: #D1D5DB; margin-bottom: 12px; display: block;"></i>No shipments matching "' + searchInput.value + '"';
            }
        } else if (noResults) {
            noResults.style.display = 'none';
        }
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

    if (searchBtn) {
        searchBtn.addEventListener('click', performSearch);
    }

    if (clearBtn) {
        clearBtn.addEventListener('click', function() {
            searchInput.value = '';
            performSearch();
            searchInput.focus();
        });
    }
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
}
</script>

<jsp:include page="/jsp/layout/footer.jsp" />




