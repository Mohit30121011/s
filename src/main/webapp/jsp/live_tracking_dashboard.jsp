<%@ page language="java" contentType="text/html; charset=UTF-8" session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* Dashboard specific styling */
    .page-header-flex { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
    
    .card-panel {
        background: #fff; border-radius: 12px; border: 1px solid var(--border-color);
        box-shadow: 0 1px 3px rgba(0,0,0,0.02); padding: 24px; margin-bottom: 24px;
    }

    /* Top Stats Card */
    .stats-container { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; }
    .stats-left { display: flex; align-items: center; gap: 16px; flex: 2; min-width: 300px; }
    .stats-icon-box {
        width: 64px; height: 64px; background: var(--brand-orange); border-radius: 16px;
        display: flex; align-items: center; justify-content: center; color: white; font-size: 28px;
    }
    .stats-title { font-size: 20px; font-weight: 800; color: var(--text-dark); margin-bottom: 4px; }
    .stats-subtitle { font-size: 13px; color: var(--text-muted); }

    .stats-items { display: flex; gap: 48px; flex: 3; justify-content: flex-end; }
    .stat-block { display: flex; flex-direction: column; }
    .stat-label { font-size: 12px; color: var(--text-muted); font-weight: 500; margin-bottom: 4px; }
    .stat-value { font-size: 24px; font-weight: 800; color: var(--text-dark); }
    .stat-value.brand { color: var(--brand-orange); }

    /* Filter Row */
    .filter-card {
        background: #fff; border-radius: 12px; border: 1px solid var(--border-color);
        padding: 16px; margin-bottom: 24px; display: flex; align-items: center; gap: 16px;
    }
    .filter-search {
        position: relative; flex: 1; min-width: 250px;
    }
    .filter-search i { position: absolute; left: 16px; top: 50%; transform: translateY(-50%); color: var(--text-muted); font-size: 14px; }
    .filter-search input {
        width: 100%; padding: 10px 16px 10px 40px; border: 1px solid var(--border-color);
        border-radius: 8px; font-size: 13px; outline: none; background: #F9FAFB;
    }
    .filter-select { width: 180px; }
    .filter-reset { margin-left: auto; color: var(--text-muted); cursor: pointer; padding: 8px; }

    /* Data Table */
    .table-header { margin-bottom: 24px; }
    .table-title { font-size: 18px; font-weight: 700; color: var(--text-dark); margin-bottom: 4px; }
    .table-subtitle { font-size: 13px; color: var(--text-muted); }

    .tracking-table { width: 100%; border-collapse: separate; border-spacing: 0; }
    .tracking-table th {
        font-size: 12px; color: var(--text-muted); font-weight: 500; padding: 12px 16px;
        border-bottom: 1px solid var(--border-color); text-align: left;
    }
    .tracking-table td {
        padding: 16px; font-size: 13px; color: var(--text-dark);
        border-bottom: 1px solid var(--border-color); vertical-align: middle;
    }
    /* Clickable row logic */
    .tracking-table tbody tr { cursor: pointer; transition: background-color 0.2s; }
    .tracking-table tbody tr:hover { background-color: #F9FAFB; }
    .tracking-table tbody tr:last-child td { border-bottom: none; }
    
    .chevron-col { text-align: right; color: var(--text-muted); font-size: 12px; }

    /* Status Badges */
    .status-badge {
        padding: 6px 16px; border-radius: 20px; font-weight: 500; font-size: 12px;
        display: inline-flex; align-items: center; justify-content: center; min-width: 110px;
    }
    .status-orange { background: #FFEBE0; color: var(--brand-orange); }
    .status-green { background: #DCFCE7; color: #16A34A; }
    .status-red { background: #FEE2E2; color: #DC2626; }
</style>

<div class="page-header-flex">
    <div>
        <h2 style="font-weight: 700; margin-bottom: 8px; color: var(--text-dark);">Live Shipment Tracking</h2>
        <div class="custom-breadcrumb d-flex align-items-center" style="margin-bottom: 0;">
            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <i class="fa-solid fa-angle-right custom-breadcrumb-separator"></i>
            <a href="${pageContext.request.contextPath}/shipments">Shipments</a>
            <i class="fa-solid fa-angle-right custom-breadcrumb-separator"></i>
            <span class="active">Live Tracking</span>
        </div>
    </div>
    <a href="${pageContext.request.contextPath}/shipments" class="btn btn-light" style="border: 1px solid var(--border-color); font-weight: 600; font-size: 13px; border-radius: 8px;">
        <i class="fa-solid fa-arrow-left me-2"></i> Back to Shipments
    </a>
</div>

<!-- Top Stats Card -->
<div class="card-panel">
    <div class="stats-container">
        <div class="stats-left">
            <div class="stats-icon-box">
                <i class="fa-solid fa-desktop"></i>
            </div>
            <div>
                <div class="stats-title">Live Shipment Tracking</div>
                <div class="stats-subtitle">12 active shipments currently being monitored</div>
            </div>
        </div>
        <div class="stats-items">
            <div class="stat-block">
                <span class="stat-label">Active Shipments</span>
                <span class="stat-value">24</span>
            </div>
            <div class="stat-block">
                <span class="stat-label">In Transit</span>
                <span class="stat-value">17</span>
            </div>
            <div class="stat-block">
                <span class="stat-label">Customs Hold</span>
                <span class="stat-value brand">3</span>
            </div>
            <div class="stat-block">
                <span class="stat-label">Delayed</span>
                <span class="stat-value brand">4</span>
            </div>
        </div>
    </div>
</div>

<!-- Filter Bar -->
<div class="filter-card">
    <div class="filter-search">
        <i class="fa-solid fa-mobile-screen"></i> <!-- Approximating the icon shown -->
        <input type="text" id="searchInput" placeholder="Search by shipment ID, customer...">
    </div>
    <div class="filter-select">
        <select class="form-select form-select-custom">
            <option value="" selected>All Statuses</option>
            <option value="in-transit">In Transit</option>
            <option value="customs-hold">Customs Hold</option>
            <option value="delayed">Delayed</option>
        </select>
    </div>
    <div class="filter-select">
        <select class="form-select form-select-custom">
            <option value="" selected>All Vessels</option>
            <option value="ocean-giant">Ocean Giant Vessel</option>
            <option value="pacific-trader">Pacific Trader</option>
            <option value="sea-horizon">Sea Horizon</option>
        </select>
    </div>
    <div class="filter-select">
        <select class="form-select form-select-custom">
            <option value="" selected>All Routes</option>
            <option value="sh-la">Shanghai ? Los Angeles</option>
            <option value="nb-rt">Ningbo ? Rotterdam</option>
            <option value="sg-mb">Singapore ? Mumbai</option>
        </select>
    </div>
    <div class="filter-reset">
        <i class="fa-solid fa-rotate-right"></i>
    </div>
</div>

<!-- Table Card -->
<div class="card-panel" style="padding: 24px 0;">
    <div class="table-header" style="padding: 0 24px;">
        <div class="table-title">All Shipments</div>
        <div class="table-subtitle">Monitor current location, milestone and exceptions</div>
    </div>
    
    <table class="tracking-table">
        <thead>
            <tr>
                <th style="padding-left: 24px;">Shipment</th>
                <th>Route</th>
                <th>Vessel</th>
                <th>Status</th>
                <th>ETA</th>
                <th>Updated</th>
                <th style="padding-right: 24px;"></th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="shipment" items="${shipments}">
                <tr onclick="window.location.href='${pageContext.request.contextPath}/shipments/tracking/detail?id=SHP-${shipment.shipmentId}'">
                    <td style="padding-left: 24px; font-weight: 500;">SHP-${shipment.shipmentId}</td>
                    <td>${shipment.originPort} <i class="fa-solid fa-arrow-right mx-1" style="font-size: 10px; color: var(--text-muted);"></i> ${shipment.destPort}</td>
                    <td>Ocean Vessel</td>
                    <td>
                        <c:choose>
                            <c:when test="${shipment.status == 'Delayed'}"><span class="status-badge status-red">${shipment.status}</span></c:when>
                            <c:when test="${shipment.status == 'Customs Hold'}"><span class="status-badge status-orange">${shipment.status}</span></c:when>
                            <c:otherwise><span class="status-badge status-green">${shipment.status}</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td>TBD</td>
                    <td style="color: var(--text-muted);">Just now</td>
                    <td class="chevron-col" style="padding-right: 24px;"><i class="fa-solid fa-chevron-right"></i></td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<div style="font-size: 12px; color: var(--text-muted); margin-bottom: 40px;">
    Click any shipment to open its detailed live tracking timeline.
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    document.getElementById('searchInput').addEventListener('input', function(e) {
        let searchTerm = e.target.value.toLowerCase();
        let rows = document.querySelectorAll('.tracking-table tbody tr');
        
        rows.forEach(row => {
            let text = row.textContent.toLowerCase();
            if (text.includes(searchTerm)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    });
});
</script>
<jsp:include page="/jsp/layout/footer.jsp" />



