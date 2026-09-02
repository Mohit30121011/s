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
        position: relative; width: 400px;
    }
    .filter-search i { position: absolute; left: 16px; top: 50%; transform: translateY(-50%); color: var(--text-muted); font-size: 14px; }
    .filter-search input {
        width: 100%; padding: 10px 16px 10px 40px; border: 1px solid var(--border-color);
        border-radius: 8px; font-size: 13px; outline: none; background: #F9FAFB; transition: border-color 0.2s;
    }
    .filter-search input:focus { border-color: var(--brand-orange); }

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
        background: transparent; border: none; font-size: 14px; padding: 6px; border-radius: 6px;
        transition: background 0.2s; cursor: pointer;
    }
    .btn-icon-action:hover { background: #F3F4F6; }
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

    <!-- Filter & Action Row -->
    <div class="filter-card">
        <div class="filter-search">
            <i class="fa-solid fa-magnifying-glass"></i>
            <input type="text" placeholder="Search by ID, Customer, Container, or Route...">
        </div>
        <a href="${pageContext.request.contextPath}/shipments/create" class="btn-book">
            <i class="fa-solid fa-plus"></i> Book Shipment
        </a>
    </div>

    <!-- Table Card -->
    <div class="card-panel" style="padding: 0; overflow: hidden;">
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
                                <a href="${pageContext.request.contextPath}/shipments/edit?id=${s.shipmentId}" class="btn-icon-action" style="color: #0d6efd; text-decoration: none;" title="Edit Shipment">
                                    <i class="fa-solid fa-pen"></i>
                                </a>
                                <button class="btn-icon-action" style="color: #dc3545;" data-bs-toggle="modal" data-bs-target="#deleteModal${s.shipmentId}" title="Delete Shipment">
                                    <i class="fa-solid fa-trash"></i>
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
                    <div class="modal fade" id="deleteModal${s.shipmentId}" tabindex="-1">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content">
                                <form action="${pageContext.request.contextPath}/shipments/delete" method="POST">
                                    <div class="modal-header" style="border-bottom: none; padding-bottom: 0;">
                                        <h5 class="modal-title text-danger"><i class="fa-solid fa-triangle-exclamation me-2"></i> Confirm Deletion</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>
                                    <div class="modal-body">
                                        <input type="hidden" name="shipmentId" value="${s.shipmentId}">
                                        <p style="font-size: 14px; color: var(--text-dark); margin-bottom: 0;">
                                            Are you sure you want to permanently delete Shipment <strong>#${s.shipmentId}</strong>? 
                                            This action cannot be undone and will erase all tracking history.
                                        </p>
                                    </div>
                                    <div class="modal-footer" style="background: #F9FAFB; border-top: none;">
                                        <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius: 8px; font-weight: 500;">Cancel</button>
                                        <button type="submit" class="btn" style="background: var(--red-brand); color: white; border-radius: 8px; font-weight: 600;">Delete Permanently</button>
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
let sortDirections = [true, true, true, true, true];

function sortTable(columnIndex) {
    const table = document.querySelector(".table tbody");
    const rows = Array.from(table.querySelectorAll("tr"));
    
    // Toggle direction
    const isAscending = sortDirections[columnIndex];
    sortDirections[columnIndex] = !isAscending;

    rows.sort((rowA, rowB) => {
        let valA = rowA.children[columnIndex].innerText.trim();
        let valB = rowB.children[columnIndex].innerText.trim();

        // Special handling for ID (remove #)
        if (columnIndex === 0) {
            valA = parseInt(valA.replace('#', '')) || 0;
            valB = parseInt(valB.replace('#', '')) || 0;
            return isAscending ? valA - valB : valB - valA;
        }

        // String comparison
        return isAscending ? valA.localeCompare(valB) : valB.localeCompare(valA);
    });

    // Re-append sorted rows
    rows.forEach(row => table.appendChild(row));
}
</script>
<jsp:include page="/jsp/layout/footer.jsp" />




