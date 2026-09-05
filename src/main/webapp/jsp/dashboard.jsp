<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />
<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-regular-rounded/css/uicons-regular-rounded.css'>
<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-solid-rounded/css/uicons-solid-rounded.css'>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.9/dist/chart.umd.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/nl-chart-theme.js"></script>
<style>
:root {
    --primary: #FC8019; --primary-light: #FFF2EB; --primary-mid: #FFD4C2;
    --success: #10B981; --success-light: #ECFDF5;
    --danger: #EF4444; --danger-light: #FEF2F2;
    --warning: #F59E0B; --warning-light: #FFFBEB;
    --info: #3B82F6; --info-light: #EFF6FF;
    --purple: #8B5CF6; --purple-light: #F5F3FF;
    --text-main: #1F2937; --text-sub: #64748B; --border: #E7E9ED;
    --bg: #F1F3F7; --card: #FFFFFF;
}
body { background: var(--bg); font-family: 'Inter', sans-serif; }
.dash-wrap { padding: 0; max-width: 100%; margin: 0; }

/* Page Header */
.dash-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
.dash-header-left h1 { font-size: 22px; font-weight: 700; color: var(--text-main); margin: 0 0 2px; }
.dash-header-left p { font-size: 13px; color: var(--text-sub); margin: 0; }
.dash-header-right { display: flex; align-items: center; gap: 12px; }
.date-badge { display: flex; align-items: center; gap: 8px; padding: 8px 14px; border: 1px solid var(--border); border-radius: 8px; background: #fff; font-size: 13px; font-weight: 500; color: var(--text-main); cursor: pointer; }
.date-badge i { color: var(--text-sub); }
.btn-new-ship { display: inline-flex; align-items: center; gap: 8px; padding: 9px 16px; background: var(--primary); color: #fff; border: none; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; text-decoration: none; transition: background 0.2s; }
.btn-new-ship:hover { background: #FC8019; color: #fff; }

/* KPI Grid */
.kpi-row { display: grid; grid-template-columns: repeat(5, 1fr); gap: 16px; margin-bottom: 24px; }
.kpi-card { background: var(--card); border: 1px solid var(--border); box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04); border-radius: 12px; padding: 18px 20px; display: flex; align-items: center; gap: 16px; transition: transform 180ms ease, box-shadow 180ms ease, border-color 180ms ease; }
.kpi-card:hover { transform: translateY(-1px); box-shadow: 0 5px 16px rgba(15, 23, 42, 0.07); border-color: #D8DCE3; }
.kpi-icon-wrap { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 22px; flex-shrink: 0; }
.kpi-icon-wrap.orange { background: #FFF7ED; color: var(--primary); }
.kpi-icon-wrap.blue   { background: #EFF6FF; color: var(--info); }
.kpi-icon-wrap.green  { background: #ECFDF5; color: var(--success); }
.kpi-icon-wrap.yellow { background: #FFFBEB; color: var(--warning); }
.kpi-icon-wrap.red    { background: #FEF2F2; color: var(--danger); }
.kpi-body { flex: 1; min-width: 0; }
.kpi-label { font-size: 12px; color: var(--text-sub); font-weight: 500; margin-bottom: 4px; }
.kpi-val { font-size: 26px; font-weight: 700; color: var(--text-main); line-height: 1.1; }
.kpi-sub { font-size: 11px; color: var(--text-sub); margin-top: 3px; }
.kpi-delta { font-size: 11px; font-weight: 600; }
.kpi-delta.up { color: var(--success); }
.kpi-delta.down { color: var(--danger); }

/* Grid layouts */
.grid-3col { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 16px; margin-bottom: 24px; align-items: stretch; }
.grid-2col { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px; align-items: stretch; }
.grid-3col-side { display: grid; grid-template-columns: 1.05fr 1.25fr 1.2fr; gap: 16px; margin-bottom: 24px; align-items: stretch; }
.grid-3col .card, .grid-2col .card, .grid-3col-side .card { height: 100%; display: flex; flex-direction: column; }
.grid-3col .card-body, .grid-2col .card-body, .grid-3col-side .card-body { flex: 1; display: flex; flex-direction: column; }

/* Cards */
.card { background: var(--card); border: 1px solid var(--border); box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04); border-radius: 12px; overflow: hidden; }
.card-header { display: flex; align-items: center; justify-content: space-between; padding: 16px 20px; border-bottom: 1px solid #F0F2F5; background: transparent; }
.card-title { font-size: 15px; font-weight: 600; color: var(--text-main); margin: 0; letter-spacing: -0.2px; }
.card-action { font-size: 12.5px; color: var(--primary); font-weight: 500; text-decoration: none; cursor: pointer; }
.card-action:hover { color: #E66F0F; text-decoration: underline; }
.card-body { padding: 18px 20px; }

/* Period Select */
.period-select { font-size: 12px; border: 1px solid var(--border); border-radius: 6px; padding: 4px 8px; color: var(--text-sub); background: #fff; cursor: pointer; outline: none; }

/* Chart containers */
.nl-dash-empty {
    display: flex; flex-direction: column; align-items: center; justify-content: center;
    height: 100%; min-height: 140px; width: 100%; gap: 6px; text-align: center;
    color: var(--nl-text-light, #94A3B8);
}
.nl-dash-empty i { font-size: 26px; opacity: .55; margin-bottom: 2px; }
.nl-dash-empty-title { font-size: 13px; font-weight: 700; color: var(--nl-text-muted, #64748B); }
.nl-dash-empty-sub { font-size: 11.5px; font-weight: 500; line-height: 1.45; max-width: 240px; }
.chart-wrap { position: relative; height: 260px; flex: 1; }
.chart-wrap-sm { position: relative; height: 200px; }

/* Shipments by Status Layout Fix */
.status-chart-wrap { display: flex; align-items: center; gap: 14px; padding: 6px 0; }
.status-canvas-wrap { width: 135px; height: 135px; flex-shrink: 0; position: relative; }
.status-legend { flex: 1; min-width: 0; }
.status-legend-item { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; font-size: 12px; }
.legend-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.legend-label { font-size: 12px; color: var(--text-sub); flex: 1; min-width: 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.legend-cnt-wrap { display: inline-flex; align-items: baseline; gap: 4px; flex-shrink: 0; margin-left: auto; white-space: nowrap; }
.legend-cnt { font-size: 12px; font-weight: 600; color: var(--text-main); }
.legend-pct { font-size: 10.5px; color: var(--text-sub); }

/* Custom Sleek Scrollbar */
.scrollable-card-body { max-height: 310px; overflow-y: auto; padding-right: 10px; }
.scrollable-card-body::-webkit-scrollbar { width: 5px; }
.scrollable-card-body::-webkit-scrollbar-track { background: transparent; }
.scrollable-card-body::-webkit-scrollbar-thumb { background: #E5E7EB; border-radius: 4px; }
.scrollable-card-body::-webkit-scrollbar-thumb:hover { background: #D1D5DB; }

/* Recent Shipments */
.ship-list { list-style: none; padding: 0; margin: 0; }
.ship-item { display: flex; align-items: center; gap: 12px; padding: 11px 0; border-bottom: 1px solid var(--border); }
.ship-item:last-child { border-bottom: none; }
.ship-icon { width: 36px; height: 36px; border-radius: 8px; background: var(--primary-light); display: flex; align-items: center; justify-content: center; color: var(--primary); font-size: 16px; flex-shrink: 0; }
.ship-info { flex: 1; min-width: 0; }
.ship-id { font-size: 13px; font-weight: 600; color: var(--text-main); }
.ship-sub { font-size: 11px; color: var(--text-sub); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.ship-badge { font-size: 10px; font-weight: 600; padding: 3px 8px; border-radius: 20px; flex-shrink: 0; }
.badge-transit  { background: var(--info-light); color: var(--info); }
.badge-delivered{ background: var(--success-light); color: var(--success); }
.badge-pending  { background: var(--warning-light); color: var(--warning); }
.badge-hold     { background: var(--danger-light); color: var(--danger); }
.badge-booked   { background: var(--purple-light); color: var(--purple); }
.badge-arrived  { background: #F0FDF4; color: #16A34A; }
.badge-departed { background: #EFF6FF; color: #2563EB; }
.badge-cancelled{ background: #F3F4F6; color: #6B7280; }
.ship-arrow { color: var(--border); font-size: 12px; }

/* Top Routes */
.route-table { width: 100%; border-collapse: collapse; }
.route-table th { font-size: 11px; font-weight: 600; color: var(--text-sub); text-transform: uppercase; letter-spacing: 0.4px; padding: 0 0 10px; text-align: left; }
.route-table th:last-child { text-align: right; }
.route-table td { padding: 9px 0; border-top: 1px solid var(--border); font-size: 13px; vertical-align: middle; }
.route-name { font-weight: 500; color: var(--text-main); font-size: 13px; }
.route-bar-wrap { width: 80px; }
.route-bar { height: 4px; border-radius: 4px; background: var(--primary); }
.route-pct { font-size: 12px; color: var(--text-sub); text-align: right; }
.view-all-link { display: block; text-align: center; font-size: 13px; color: var(--primary); font-weight: 500; padding: 14px 0 4px; text-decoration: none; }
.view-all-link:hover { text-decoration: underline; }

/* Modern Container Overview Cards (Swiggy Orange Design System) */
.container-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
}
.cont-card {
    background: #FFFFFF;
    border: 1px solid #E5E7EB;
    border-radius: 10px;
    padding: 10px 12px;
    transition: all 0.2s ease;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    position: relative;
    overflow: hidden;
}
.cont-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 16px rgba(15, 23, 42, 0.06);
}
.cont-card.flat-rack { background: #FFFDFB; border-color: #FED7AA; }
.cont-card.flat-rack:hover { border-color: #FC8019; }
.cont-card.dry       { background: #F8FAFF; border-color: #DBEAFE; }
.cont-card.dry:hover { border-color: #3B82F6; }
.cont-card.reefer    { background: #F0F9FF; border-color: #BAE6FD; }
.cont-card.reefer:hover { border-color: #0284C7; }
.cont-card.open-top  { background: #F0FDF4; border-color: #BBF7D0; }
.cont-card.open-top:hover { border-color: #10B981; }
.cont-card.tank      { background: #FAF5FF; border-color: #E9D5FF; }
.cont-card.tank:hover { border-color: #8B5CF6; }

.cont-card-top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 6px;
}
.cont-icon-wrap {
    width: 28px;
    height: 28px;
    border-radius: 7px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 15px;
}
.cont-share-badge {
    font-size: 10.5px;
    font-weight: 700;
    padding: 1px 6px;
    border-radius: 5px;
    background: #FFFFFF;
    border: 1px solid rgba(0, 0, 0, 0.08);
    color: #4B5563;
}
.cont-type-title {
    font-size: 11.5px;
    font-weight: 600;
    color: #64748B;
    margin-bottom: 1px;
}
.cont-val-number {
    font-size: 20px;
    font-weight: 800;
    color: #0F172A;
    line-height: 1.1;
}
.cont-prog-track {
    height: 4px;
    background: rgba(0, 0, 0, 0.05);
    border-radius: 99px;
    overflow: hidden;
    margin-top: 6px;
    margin-bottom: 4px;
}
.cont-prog-bar {
    height: 100%;
    border-radius: 99px;
}
.cont-status-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 10.5px;
    color: #64748B;
}
.cont-status-pill {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    color: #10B981;
    font-weight: 600;
}

/* Alerts */
.alert-list { list-style: none; padding: 0; margin: 0; }
.alert-item { display: flex; align-items: flex-start; gap: 12px; padding: 11px 0; border-bottom: 1px solid var(--border); }
.alert-item:last-child { border-bottom: none; }
.alert-icon { width: 32px; height: 32px; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 14px; flex-shrink: 0; margin-top: 1px; }
.alert-icon.warn  { background: var(--warning-light); color: var(--warning); }
.alert-icon.danger{ background: var(--danger-light); color: var(--danger); }
.alert-icon.info  { background: var(--info-light); color: var(--info); }
.alert-icon.success{ background: var(--success-light); color: var(--success); }
.alert-body { flex: 1; }
.alert-msg { font-size: 12px; font-weight: 600; color: var(--text-main); }
.alert-detail { font-size: 11px; color: var(--text-sub); margin-top: 2px; }
.alert-time { font-size: 11px; color: var(--text-sub); flex-shrink: 0; white-space: nowrap; }

/* Scrollable lists */
.scrollable-card-body { max-height: 310px; overflow-y: auto; padding-right: 8px; }




/* Responsive Grid Enhancements */
@media (max-width: 1200px) {
    .kpi-row { grid-template-columns: repeat(3, 1fr) !important; }
}
@media (max-width: 992px) {
    .grid-3col, .grid-2col, .grid-3col-side { grid-template-columns: 1fr !important; }
}
@media (max-width: 640px) {
    .kpi-row { grid-template-columns: 1fr !important; }
    .dash-header { flex-direction: column; align-items: flex-start; gap: 12px; }
    .dash-header-right { width: 100%; justify-content: space-between; }
}

.period-select,
.date-badge-form select {
    appearance: none;
    -webkit-appearance: none;
    -moz-appearance: none;
    background-color: #FFFFFF !important;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%236B7280' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E") !important;
    background-repeat: no-repeat !important;
    background-position: right 10px center !important;
    background-size: 13px !important;
    border: 1px solid #E2E5EA !important;
    border-radius: 8px !important;
    padding: 6px 30px 6px 12px !important;
    font-size: 12.5px !important;
    font-weight: 500 !important;
    color: #4B5563 !important;
    cursor: pointer !important;
    outline: none !important;
    transition: all 0.15s ease !important;
}

.period-select:hover,
.date-badge-form select:hover {
    border-color: #D1D5DB !important;
    background-color: #F9FAFB !important;
}

.period-select:focus,
.date-badge-form select:focus {
    border-color: #FC8019 !important;
    box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12) !important;
}

.date-badge-form select {
    border-radius: 20px !important;
    padding: 7px 32px 7px 14px !important;
    font-size: 13px !important;
    font-weight: 600 !important;
    background-position: right 12px center !important;
}

/* Premium Subtle Dropdowns (No glaring solid colors) */
.btn-dropdown {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: #FFFFFF;
    border: 1px solid #E2E5EA;
    border-radius: 8px;
    padding: 6px 12px;
    font-size: 12.5px;
    font-weight: 500;
    color: #4B5563;
    cursor: pointer;
    transition: all 0.15s ease;
}
.btn-dropdown:hover {
    background: #F9FAFB;
    border-color: #D1D5DB;
    color: #1F2937;
}
.btn-dropdown:focus,
.btn-dropdown[aria-expanded="true"] {
    border-color: #D1D5DB;
    box-shadow: 0 2px 6px rgba(15, 23, 42, 0.06);
    background: #FFFFFF;
}
.btn-dropdown i {
    font-size: 12px;
    color: #6B7280;
    transition: transform 0.2s ease;
}
.btn-dropdown[aria-expanded="true"] i {
    transform: rotate(180deg);
}

.btn-dropdown-pill {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: #FFFFFF;
    border: 1px solid #E2E5EA;
    border-radius: 20px;
    padding: 7px 16px;
    font-size: 13px;
    font-weight: 600;
    color: #374151;
    cursor: pointer;
    transition: all 0.15s ease;
}
.btn-dropdown-pill:hover {
    background: #F9FAFB;
    border-color: #D1D5DB;
    color: #111827;
}
.btn-dropdown-pill:focus,
.btn-dropdown-pill[aria-expanded="true"] {
    border-color: #D1D5DB;
    box-shadow: 0 2px 6px rgba(15, 23, 42, 0.06);
    background: #FFFFFF;
}
.btn-dropdown-pill i {
    font-size: 13px;
    color: #6B7280;
    transition: transform 0.2s ease;
}
.btn-dropdown-pill[aria-expanded="true"] i {
    transform: rotate(180deg);
}

.dropdown-menu {
    border: 1px solid #E7E9ED !important;
    border-radius: 12px !important;
    box-shadow: 0 10px 25px rgba(15, 23, 42, 0.08), 0 4px 10px rgba(15, 23, 42, 0.04) !important;
    padding: 6px !important;
    background: #FFFFFF !important;
    min-width: 145px !important;
    margin-top: 6px !important;
}

.dropdown-item {
    font-size: 13px !important;
    font-weight: 500 !important;
    color: #4B5563 !important;
    padding: 7px 12px !important;
    border-radius: 8px !important;
    display: flex !important;
    align-items: center !important;
    justify-content: space-between !important;
    transition: all 120ms ease !important;
}

.dropdown-item:hover {
    background-color: #F8F9FA !important;
    color: #111827 !important;
}

.dropdown-item.active,
.dropdown-item:active {
    background-color: #FFF7ED !important;
    color: #FC8019 !important;
    font-weight: 600 !important;
}

.dropdown-item.active::after {
    content: "✓";
    font-size: 12px;
    font-weight: 700;
    color: #FC8019;
    margin-left: 8px;
}

</style>

<div class="dash-wrap">
    <!-- Page Header -->
    <div class="dash-header">
        <div class="dash-header-left">

<c:if test="${not empty sessionScope.errorMessage}">
    <div class="nl-alert-banner error" style="border-radius:12px; margin-bottom:20px; display:flex; align-items:flex-start; gap:10px; padding:14px 16px; background:#FEF2F2; border:1px solid #FECACA; color:#991B1B;">
        <i class="ti ti-alert-circle" style="flex-shrink:0; margin-top:1px;"></i>
        <div style="font-size:13.5px; font-weight:500;">${sessionScope.errorMessage}</div>
    </div>
    <c:remove var="errorMessage" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.successMessage}">
    <div class="nl-alert-banner success" style="border-radius:12px; margin-bottom:20px; display:flex; align-items:flex-start; gap:10px; padding:14px 16px; background:#ECFDF5; border:1px solid #A7F3D0; color:#065F46;">
        <i class="ti ti-circle-check" style="flex-shrink:0; margin-top:1px;"></i>
        <div style="font-size:13.5px; font-weight:500;">${sessionScope.successMessage}</div>
    </div>
    <c:remove var="successMessage" scope="session"/>
</c:if>
<h1>Dashboard</h1>
            <p>Welcome back! Here's what's happening with your logistics operations.</p>
        </div>
        <div class="dash-header-right">
            <div class="dropdown d-inline-block me-3">
                <button class="btn-dropdown-pill" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                    <span>
                        <c:choose>
                            <c:when test="${currentPeriod == 'today'}">Today</c:when>
                            <c:when test="${currentPeriod == 'week'}">This Week</c:when>
                            <c:when test="${currentPeriod == 'month'}">This Month</c:when>
                            <c:otherwise>All Time</c:otherwise>
                        </c:choose>
                    </span>
                    <i class="ti ti-chevron-down"></i>
                </button>
                <ul class="dropdown-menu dropdown-menu-end shadow-sm">
                    <li><a class="dropdown-item ${empty currentPeriod || currentPeriod == 'all' ? 'active' : ''}" href="${pageContext.request.contextPath}/dashboard?period=all&trendPeriod=${currentTrendPeriod}">All Time</a></li>
                    <li><a class="dropdown-item ${currentPeriod == 'today' ? 'active' : ''}" href="${pageContext.request.contextPath}/dashboard?period=today&trendPeriod=${currentTrendPeriod}">Today</a></li>
                    <li><a class="dropdown-item ${currentPeriod == 'week' ? 'active' : ''}" href="${pageContext.request.contextPath}/dashboard?period=week&trendPeriod=${currentTrendPeriod}">This Week</a></li>
                    <li><a class="dropdown-item ${currentPeriod == 'month' ? 'active' : ''}" href="${pageContext.request.contextPath}/dashboard?period=month&trendPeriod=${currentTrendPeriod}">This Month</a></li>
                </ul>
            </div>
            
        </div>
    </div>

    <!-- KPI Cards -->
    <div class="kpi-row">
        <div class="kpi-card">
            <div class="kpi-icon-wrap orange"><i class="fi fi-rr-box"></i></div>
            <div class="kpi-body">
                <div class="kpi-label">Total Shipments</div>
                <div class="kpi-val">${totalShipments}</div>
                <div class="kpi-sub">All Time</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon-wrap blue"><i class="fi fi-rr-ship"></i></div>
            <div class="kpi-body">
                <div class="kpi-label">Active Shipments</div>
                <div class="kpi-val">${activeShipments}</div>
                <div class="kpi-sub">In Transit</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon-wrap green"><i class="fi fi-rr-check-circle"></i></div>
            <div class="kpi-body">
                <div class="kpi-label">Delivered</div>
                <div class="kpi-val">${deliveredShipments}</div>
                <div class="kpi-sub">All Time</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon-wrap yellow"><i class="fi fi-rr-clock"></i></div>
            <div class="kpi-body">
                <div class="kpi-label">Pending</div>
                <div class="kpi-val">${pendingShipments}</div>
                <div class="kpi-sub">Awaiting</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon-wrap red"><i class="fi fi-rr-calendar-exclamation"></i></div>
            <div class="kpi-body">
                <div class="kpi-label">On Hold / Cancelled</div>
                <div class="kpi-val">${overdueShipments}</div>
                <div class="kpi-sub">Needs Attention</div>
            </div>
        </div>
    </div>

    <!-- Row 2: Trend + Doughnut + Recent -->
    <div class="grid-3col-side">
        <!-- Shipment Overview -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Shipment Overview</h3>
                <div class="dropdown">
                    <button class="btn-dropdown" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <span>
                            <c:choose>
                                <c:when test="${currentTrendPeriod == 'month'}">This Month</c:when>
                                <c:when test="${currentTrendPeriod == 'year'}">This Year</c:when>
                                <c:otherwise>This Week</c:otherwise>
                            </c:choose>
                        </span>
                        <i class="ti ti-chevron-down"></i>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow-sm">
                        <li><a class="dropdown-item ${empty currentTrendPeriod || currentTrendPeriod == 'week' ? 'active' : ''}" href="${pageContext.request.contextPath}/dashboard?period=${currentPeriod}&trendPeriod=week">This Week</a></li>
                        <li><a class="dropdown-item ${currentTrendPeriod == 'month' ? 'active' : ''}" href="${pageContext.request.contextPath}/dashboard?period=${currentPeriod}&trendPeriod=month">This Month</a></li>
                        <li><a class="dropdown-item ${currentTrendPeriod == 'year' ? 'active' : ''}" href="${pageContext.request.contextPath}/dashboard?period=${currentPeriod}&trendPeriod=year">This Year</a></li>
                    </ul>
                </div>
            </div>
            <div class="card-body">
                <div class="chart-wrap"><canvas id="trendChart"></canvas></div>
            </div>
        </div>

        <!-- Shipments by Status -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Shipments by Status</h3>
            </div>
            <div class="card-body">
                <div class="status-chart-wrap">
                    <div class="status-canvas-wrap"><canvas id="statusChart"></canvas></div>
                    <div class="status-legend" id="statusLegend"></div>
                </div>
            </div>
        </div>

        <!-- Recent Shipments -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Recent Shipments</h3>
                
            </div>
            <div class="card-body scrollable-card-body" style="padding-top:8px;">
                <c:if test="${empty recentShipments}">
                    <div class="nl-dash-empty" style="height:180px;">
                        <i class="ti ti-package-off"></i>
                        <div class="nl-dash-empty-title">No shipments yet</div>
                        <div class="nl-dash-empty-sub">Your most recent bookings will be listed here.</div>
                    </div>
                </c:if>
                <ul class="ship-list">
                    <c:forEach var="s" items="${recentShipments}">
                    <li class="ship-item">
                        <div class="ship-icon"><i class="fi fi-rr-box"></i></div>
                        <div class="ship-info">
                            <div class="ship-id">${s.id}</div>
                            <div class="ship-sub">${s.customer} &bull; ${s.route}</div>
                        </div>
                        <c:set var="badgeClass" value="badge-cancelled"/>
                        <c:if test="${s.status == 'In Transit'}"><c:set var="badgeClass" value="badge-transit"/></c:if>
                        <c:if test="${s.status == 'Delivered'}"><c:set var="badgeClass" value="badge-delivered"/></c:if>
                        <c:if test="${s.status == 'Booked'}"><c:set var="badgeClass" value="badge-booked"/></c:if>
                        <c:if test="${s.status == 'Arrived'}"><c:set var="badgeClass" value="badge-arrived"/></c:if>
                        <c:if test="${s.status == 'Departed'}"><c:set var="badgeClass" value="badge-departed"/></c:if>
                        <c:if test="${s.status == 'Customs Hold'}"><c:set var="badgeClass" value="badge-hold"/></c:if>
                        <span class="ship-badge ${badgeClass}">${s.status}</span>
                        <i class="fi fi-rr-angle-right ship-arrow"></i>
                    </li>
                    </c:forEach>
                </ul>
            </div>
        </div>
    </div>

    <!-- Row 3: Routes + Containers + Alerts -->
    <div class="grid-3col">
        <!-- Top Routes -->
        <div class="card" id="top-routes-card">
            <div class="card-header">
                <h3 class="card-title">Top Shipping Routes</h3>
                <div class="dropdown">
                    <button class="btn-dropdown" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <span>All Time</span>
                        <i class="ti ti-chevron-down"></i>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow-sm">
                        <li><a class="dropdown-item active" href="javascript:void(0);">All Time</a></li>
                        <li><a class="dropdown-item" href="javascript:void(0);">This Month</a></li>
                        <li><a class="dropdown-item" href="javascript:void(0);">This Year</a></li>
                    </ul>
                </div>
            </div>
            <div class="card-body scrollable-card-body" style="padding-top:12px;">
                <c:if test="${empty topRoutes}">
                    <div class="nl-dash-empty" style="height:160px;">
                        <i class="ti ti-route-off"></i>
                        <div class="nl-dash-empty-title">No routes yet</div>
                        <div class="nl-dash-empty-sub">Your busiest trade lanes will appear here.</div>
                    </div>
                </c:if>
                <table class="route-table" <c:if test="${empty topRoutes}">style="display:none;"</c:if>>
                    <thead>
                        <tr>
                            <th>Route</th>
                            <th>Shipments</th>
                            <th></th>
                            <th>%</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${topRoutes}">
                        <tr>
                            <td class="route-name">${r.route}</td>
                            <td style="color:var(--text-sub); padding-right:10px;">${r.cnt}</td>
                            <td class="route-bar-wrap">
                                <div class="route-bar" style="width:${r.pct > 5 ? r.pct : 5}%"></div>
                            </td>
                            <td class="route-pct">${r.pct}%</td>
                        </tr>
                        </c:forEach>
                    </tbody>
                </table>
                
            </div>
        </div>

        <!-- Containers Overview (Revamped Visual Design) -->
        <div class="card no-card-tools" data-no-tools="true">
            <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; gap: 8px;">
                <div style="display: flex; align-items: center; gap: 8px; min-width: 0; flex: 1;">
                    <div style="width: 32px; height: 32px; background: #FFF2EB; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #FC8019; font-size: 17px; flex-shrink: 0;">
                        <i class="ti ti-packages"></i>
                    </div>
                    <div style="min-width: 0;">
                        <h3 class="card-title" style="margin: 0; font-size: 14px; font-weight: 700; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Containers Overview</h3>
                        <div style="font-size: 11px; color: var(--text-sub); white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                            <c:choose>
                                <c:when test="${sessionScope.user.roleId == 5}">Available to book, by type</c:when>
                                <c:otherwise>Active fleet inventory by type</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                <div style="display: flex; align-items: center; gap: 6px; flex-shrink: 0;">
                    <span style="background: #FFF2EB; color: #FC8019; font-weight: 700; font-size: 11px; padding: 3px 8px; border-radius: 20px; border: 1px solid #FFD4C2; white-space: nowrap;">Total: ${totalContainers}</span>
                    <a href="${pageContext.request.contextPath}/containers" title="View Container Catalog" style="color: #64748B; font-size: 15px; padding: 2px 4px; display: inline-flex; align-items: center; text-decoration: none; transition: color 0.15s ease;" onmouseover="this.style.color='#FC8019'" onmouseout="this.style.color='#64748B'">
                        <i class="ti ti-arrow-right"></i>
                    </a>
                </div>
            </div>
            <div class="card-body" style="padding: 12px 16px 14px; display: flex; flex-direction: column; justify-content: space-between; overflow: visible;">
                <div class="container-grid">
                    <c:forEach var="ct" items="${containerTypes}">
                        <c:set var="cardTheme" value="dry" />
                        <c:set var="iconClass" value="ti ti-box" />
                        <c:set var="themeColor" value="#3B82F6" />
                        <c:set var="iconBg" value="#EFF6FF" />

                        <c:if test="${ct.key == 'Flat Rack'}">
                            <c:set var="cardTheme" value="flat-rack" />
                            <c:set var="iconClass" value="ti ti-truck-loading" />
                            <c:set var="themeColor" value="#FC8019" />
                            <c:set var="iconBg" value="#FFF2EB" />
                        </c:if>
                        <c:if test="${ct.key == 'Reefer'}">
                            <c:set var="cardTheme" value="reefer" />
                            <c:set var="iconClass" value="ti ti-snowflake" />
                            <c:set var="themeColor" value="#0284C7" />
                            <c:set var="iconBg" value="#E0F2FE" />
                        </c:if>
                        <c:if test="${ct.key == 'Open Top'}">
                            <c:set var="cardTheme" value="open-top" />
                            <c:set var="iconClass" value="ti ti-package-export" />
                            <c:set var="themeColor" value="#059669" />
                            <c:set var="iconBg" value="#DCFCE7" />
                        </c:if>
                        <c:if test="${ct.key == 'Tank'}">
                            <c:set var="cardTheme" value="tank" />
                            <c:set var="iconClass" value="ti ti-cylinder" />
                            <c:set var="themeColor" value="#7C3AED" />
                            <c:set var="iconBg" value="#F3E8FF" />
                        </c:if>

                        <c:set var="sharePct" value="${totalContainers > 0 ? (ct.value * 100.0 / totalContainers) : 0}" />

                        <div class="cont-card ${cardTheme}">
                            <div class="cont-card-top">
                                <div class="cont-icon-wrap" style="background: ${iconBg}; color: ${themeColor};">
                                    <i class="${iconClass}"></i>
                                </div>
                                <span class="cont-share-badge"><fmt:formatNumber value="${sharePct}" maxFractionDigits="1" />%</span>
                            </div>

                            <div>
                                <div class="cont-type-title">${ct.key}</div>
                                <div class="cont-val-number">${ct.value}</div>
                            </div>

                            <div>
                                <div class="cont-prog-track">
                                    <div class="cont-prog-bar" style="width: ${sharePct}%; background: ${themeColor};"></div>
                                </div>
                                <div class="cont-status-row">
                                    <span class="cont-status-pill"><i class="ti ti-circle-check"></i> Active</span>
                                    <span style="font-weight: 600; color: #1F2937;">${ct.value} units</span>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div style="margin-top: 10px; padding: 8px 12px; background: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 8px; display: flex; align-items: center; justify-content: space-between;">
                    <div style="font-size: 11.5px; color: #64748B;">
                        <i class="ti ti-info-circle" style="color: #FC8019; margin-right: 4px;"></i> Monitored across all <strong>30</strong> ports
                    </div>
                    <a href="${pageContext.request.contextPath}/containers" style="font-size: 11.5px; color: #FC8019; font-weight: 600; text-decoration: none;">
                        Manage Catalog &rarr;
                    </a>
                </div>
            </div>
        </div>


        <!-- Alerts & Notifications -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Alerts &amp; Notifications</h3>
                
            </div>
            <div class="card-body scrollable-card-body" style="padding-top:8px;">
                <ul class="alert-list">
                    <c:forEach var="al" items="${alerts}" varStatus="loop">
                    <li class="alert-item">
                        <c:set var="alertClass" value="info"/>
                        <c:set var="alertIcon"  value="bell"/>
                        <c:if test="${loop.index == 0}"><c:set var="alertClass" value="warn"/><c:set var="alertIcon" value="triangle-warning"/></c:if>
                        <c:if test="${loop.index == 1}"><c:set var="alertClass" value="danger"/><c:set var="alertIcon" value="circle-xmark"/></c:if>
                        <c:if test="${loop.index == 2}"><c:set var="alertClass" value="info"/><c:set var="alertIcon" value="info"/></c:if>
                        <c:if test="${loop.index == 3}"><c:set var="alertClass" value="success"/><c:set var="alertIcon" value="check-circle"/></c:if>
                        <div class="alert-icon ${alertClass}">
                            <i class="fi fi-rr-${alertIcon}"></i>
                        </div>
                        <div class="alert-body">
                            <div class="alert-msg">${al.action} — ${al.entity}</div>
                            <div class="alert-detail"><c:out value="${al.detail}" escapeXml="true"/></div>
                        </div>
                        <div class="alert-time">${al.time}</div>
                    </li>
                    </c:forEach>
                    <c:if test="${empty alerts}">
                        <li class="alert-item">
                            <div class="alert-icon info"><i class="fi fi-rr-info"></i></div>
                            <div class="alert-body"><div class="alert-msg">No recent alerts</div></div>
                        </li>
                    </c:if>
                </ul>
            </div>
        </div>
    </div>
</div>

<script>
var trendJson   = ${not empty trendJson  ? trendJson  : '[]'};
var statusJson  = ${not empty statusJson ? statusJson : '[]'};

var STATUS_COLORS = {
    'In Transit':           '#3B82F6',
    'Delivered':            '#10B981',
    'Booked':               '#8B5CF6',
    'Container Allocated':  '#F59E0B',
    'Departed':             '#0EA5E9',
    'Customs Hold':         '#EF4444',
    'Arrived':              '#14B8A6',
    'Cancelled':            '#9CA3AF'
};

/**
 * Replaces a chart canvas with a centred empty state. Used wherever the
 * account genuinely has no rows, so the dashboard never shows placeholder
 * numbers that look like real activity.
 */
function nlShowEmpty(canvas, icon, title, subtitle) {
    if (!canvas || !canvas.parentNode) return;
    var box = document.createElement('div');
    box.className = 'nl-dash-empty';
    box.innerHTML = '<i class="ti ' + icon + '"></i>'
                  + '<div class="nl-dash-empty-title">' + title + '</div>'
                  + '<div class="nl-dash-empty-sub">' + subtitle + '</div>';
    canvas.parentNode.replaceChild(box, canvas);
}

// --- Trend Chart ---
(function() {
    var trendCanvas = document.getElementById('trendChart');
    if (!trendCanvas) return;

    // No invented numbers: an account with no shipments gets an empty state.
    if (!trendJson.length) {
        nlShowEmpty(trendCanvas, 'ti-chart-line', 'No shipment activity yet',
                    'Your booking trend will appear here once you book a shipment.');
        return;
    }

    var labels = trendJson.map(function(d){return d.d;});
    var data   = trendJson.map(function(d){return d.cnt;});
    new Chart(trendCanvas, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: 'Shipments',
                data: data,
                borderColor: '#FC8019',
                backgroundColor: 'rgba(249,115,22,0.1)',
                borderWidth: 2, tension: 0.4, fill: true, pointRadius: 4,
                pointBackgroundColor: '#FC8019', pointBorderColor: '#fff', pointBorderWidth: 2
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: { beginAtZero: true, ticks: { stepSize: 1, font: {size:10} }, grid: { color: '#F3F4F6' }, border: { display: false } },
                x: { grid: { display: false }, ticks: { font: {size:10} }, border: { display: false } }
            }
        }
    });
})();

// --- Status Doughnut Chart ---
(function() {
    if (!statusJson.length) return;
    var labels = statusJson.map(function(d){return d.status;});
    var data   = statusJson.map(function(d){return d.cnt;});
    var colors = labels.map(function(l){return STATUS_COLORS[l] || '#9CA3AF';});
    var total  = data.reduce(function(a,b){return a+b;}, 0);

    var statusCanvas = document.getElementById('statusChart');
    if (!statusCanvas || !statusJson.length) {
        if (statusCanvas) {
            nlShowEmpty(statusCanvas, 'ti-chart-donut', 'No shipments yet', '');
        }
        var legendEl = document.getElementById('statusLegend');
        if (legendEl && !statusJson.length) {
            legendEl.innerHTML = '<div class="nl-dash-empty-sub" style="padding:4px 0;">'
                               + 'Status breakdown appears once you have shipments.</div>';
        }
    }
    if (statusCanvas && statusJson.length)
    new Chart(statusCanvas, {
        type: 'doughnut',
        data: { labels: labels, datasets: [{ data: data, backgroundColor: colors, borderWidth: 0, cutout: '72%' }] },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { display: false }, tooltip: { enabled: true } }
        },
        plugins: [{
            id: 'centerLabel',
            beforeDraw: function(chart) {
                var ctx = chart.ctx, ca = chart.chartArea;
                var cx = (ca.left + ca.right)/2, cy = (ca.top + ca.bottom)/2;
                ctx.save();
                ctx.font = '700 22px Inter, sans-serif'; ctx.fillStyle = '#111827';
                ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
                ctx.fillText(total, cx, cy - 8);
                ctx.font = '500 11px Inter, sans-serif'; ctx.fillStyle = '#6B7280';
                ctx.fillText('Total', cx, cy + 12);
                ctx.restore();
            }
        }]
    });

    // Build legend
    var legend = document.getElementById('statusLegend');
    statusJson.forEach(function(d) {
        var pct = ((d.cnt / total) * 100).toFixed(0);
        var color = STATUS_COLORS[d.status] || '#9CA3AF';
        var item = document.createElement('div');
        item.className = 'status-legend-item';
        item.innerHTML = '<div class="legend-dot" style="background:' + color + '"></div>' +
            '<span class="legend-label" title="' + d.status + '">' + d.status + '</span>' +
            '<div class="legend-cnt-wrap">' +
                '<span class="legend-cnt">' + d.cnt + '</span>' +
                '<span class="legend-pct">(' + pct + '%)</span>' +
            '</div>';
        legend.appendChild(item);
    });
})();
</script>

<style>
    @keyframes targetHighlightPulse {
        0% { box-shadow: 0 0 0 0 rgba(252, 128, 25, 0.6) !important; border-color: #FC8019 !important; }
        40% { box-shadow: 0 0 0 8px rgba(252, 128, 25, 0.25) !important; border-color: #FC8019 !important; transform: translateY(-2px); }
        100% { box-shadow: var(--shadow-sm) !important; border-color: var(--border-color) !important; transform: translateY(0); }
    }
    .highlight-target {
        animation: targetHighlightPulse 2s cubic-bezier(0.16, 1, 0.3, 1) !important;
    }
</style>
<script>
    function handleDashboardHashHighlight() {
        if (window.location.hash) {
            const targetId = window.location.hash.substring(1);
            const el = document.getElementById(targetId);
            if (el) {
                setTimeout(() => {
                    el.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    el.classList.add('highlight-target');
                    setTimeout(() => el.classList.remove('highlight-target'), 2400);
                }, 150);
            }
        }
    }
    window.addEventListener('DOMContentLoaded', handleDashboardHashHighlight);
    window.addEventListener('hashchange', handleDashboardHashHighlight);
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
</body>
</html>
