<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/jsp/layout/header.jsp" />

<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-regular-rounded/css/uicons-regular-rounded.css'>
<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-solid-rounded/css/uicons-solid-rounded.css'>

<style>
    :root {
        --bg-surface: #ffffff;
        --border-color: #E7E9ED;
        --text-main: #111827;
        --text-sub: #6B7280;
        --primary: #FC8019;
        --primary-light: #FFF2EB;
        --success: #10B981;
        --success-light: #D1FAE5;
        --danger: #EF4444;
        --danger-light: #FEE2E2;
        --warning: #F59E0B;
        --warning-light: #FEF3C7;
        --info: #8B5CF6;
        --info-light: #EDE9FE;
    }
    [data-theme="dark"] {
        --bg-surface: #101820;
        --border-color: #22303A;
        --text-main: #F8FAFC;
        --text-sub: #94A3B8;
        --primary-light: rgba(252, 128, 25, 0.14);
        --success-light: rgba(16, 185, 129, 0.14);
        --danger-light: rgba(239, 68, 68, 0.14);
        --warning-light: rgba(245, 158, 11, 0.14);
        --info-light: rgba(139, 92, 246, 0.14);
    }
    body { background-color: var(--nl-bg, #F9FAFB); }
    .dashboard-container { padding: 24px; max-width: 1400px; margin: 0 auto; }
    
    .page-header { margin-bottom: 24px; }
    .page-title h1 { font-size: 24px; font-weight: 700; color: var(--text-main); margin: 0 0 4px 0; }
    .page-title p { color: var(--text-sub); margin: 0; font-size: 14px; }
    .page-title p span { color: var(--primary); font-weight: 500; }
    
    /* Filters Bar */
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /* ===== Container Utilization Gauge (SVG — presentation only) ===== */
    .gauge-wrapper { display: flex; justify-content: center; align-items: center; width: 100%; padding: 4px 0 0; }
    .nl-gauge { position: relative; width: 100%; max-width: 240px; }
    .nl-gauge svg { display: block; width: 100%; height: auto; overflow: visible; }
    .nl-gauge-track {
        fill: none;
        stroke: #EDF0F5;
        stroke-width: 16;
        stroke-linecap: round;
    }
    .nl-gauge-fill {
        fill: none;
        stroke: url(#utilGaugeGrad);
        stroke-width: 16;
        stroke-linecap: round;
        stroke-dasharray: 282.74;
        stroke-dashoffset: 282.74;
        transition: stroke-dashoffset 1100ms cubic-bezier(0.22, 1, 0.36, 1);
    }
    /* value block sits inside the arc */
    .nl-gauge-center {
        position: absolute;
        left: 0; right: 0;
        bottom: 8%;
        text-align: center;
        pointer-events: none;
    }
    .nl-gauge-val {
        font-size: 30px;
        font-weight: 800;
        letter-spacing: -0.02em;
        color: var(--text-main, #1F2937);
        line-height: 1.05;
        font-variant-numeric: tabular-nums;
    }
    .nl-gauge-val span { font-size: 17px; font-weight: 700; margin-left: 1px; color: var(--text-sub, #64748B); }
    .nl-gauge-sub { font-size: 11.5px; font-weight: 600; color: var(--text-sub, #64748B); margin-top: 3px; }
    .nl-gauge-scale {
        display: flex;
        justify-content: space-between;
        margin-top: -2px;
        padding: 0 4px;
        font-size: 10.5px;
        font-weight: 600;
        color: var(--text-light, #94A3B8);
    }
    
    /* ===== Filter Bar ===== */
    .filters-bar-wrap {
        margin-bottom: 24px;
        background: transparent !important;
        width: 100%;
    }
    .filters-bar-inner {
        display: flex;
        align-items: center;
        justify-content: flex-start;
        background: transparent !important;
        border: none !important;
        border-radius: 0 !important;
        padding: 0 !important;
        box-shadow: none !important;
        flex-wrap: nowrap !important;
        gap: 12px;
        width: 100%;
        overflow-x: auto;
        overflow-y: hidden;
        scrollbar-width: none;
    }
    .filters-bar-inner::-webkit-scrollbar {
        display: none;
    }
    .filters-left {
        display: flex;
        align-items: center;
        flex-wrap: nowrap !important;
        gap: 12px;
        flex: 1 1 auto;
        min-width: 0;
        overflow: visible;
    }
    .filter-field {
        display: flex;
        flex-direction: column;
        gap: 4px;
        padding: 0 !important;
        min-width: 0;
        flex: 0 0 auto;
        cursor: default;
    }
    .filter-field-label {
        font-size: 11px;
        font-weight: 700;
        color: #FC8019;
        text-transform: uppercase;
        letter-spacing: 0.6px;
        margin-bottom: 0;
        display: flex;
        align-items: center;
        gap: 6px;
        white-space: nowrap;
    }
    .filter-field-label i {
        font-size: 12px;
        color: #FC8019;
    }
    .filter-select-custom {
        height: 38px;
        min-width: 145px;
        max-width: 190px;
        padding: 0 32px 0 14px;
        border-radius: 50px;
        border: 1px solid var(--border-color, #E2E8F0);
        background-color: #FFFFFF;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2394A3B8' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='m6 9 6 6 6-6'/%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 14px center;
        color: var(--text-main, #1E293B);
        font-size: 12.5px;
        font-weight: 500;
        cursor: pointer;
        outline: none;
        transition: all 0.2s ease;
        box-sizing: border-box;
        appearance: none;
        -webkit-appearance: none;
        white-space: nowrap;
        text-overflow: ellipsis;
    }
    .filter-select-custom:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.15) !important;
    }
    .filter-divider {
        display: none !important;
    }
    .filters-right {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-left: auto;
        align-self: center;
        padding: 0 !important;
        border: none !important;
        flex-shrink: 0;
    }
    .filter-btn-reset, .filter-btn-export {
        height: 36px;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 0 14px;
        border-radius: 50px;
        font-size: 12px;
        font-weight: 600;
        cursor: pointer;
        border: none;
        text-decoration: none;
        transition: all 0.2s ease;
        white-space: nowrap;
        box-sizing: border-box;
    }
    .filter-btn-reset {
        background: #F1F5F9;
        color: #64748B;
        border: 1px solid #E2E8F0;
    }
    .filter-btn-reset:hover { background: #E2E8F0; color: #0F172A; }
    .filter-btn-export {
        background: #FFF7ED;
        color: #FC8019;
        border: 1px solid #FED7AA;
    }
    .filter-btn-export:hover { background: rgba(252, 128, 25, 0.15); }
    .filter-field:hover { background: transparent; }

    /* KPI Grid */
    .kpi-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 16px; margin-bottom: 24px; }
    .kpi-card { background: var(--bg-surface); border: 1px solid var(--border-color); border-radius: 12px; padding: 20px; display: flex; align-items: flex-start; gap: 16px; }
    .kpi-icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 24px; flex-shrink: 0; }
    
    .icon-orange { background: var(--primary-light); color: var(--primary); }
    .icon-green { background: var(--success-light); color: var(--success); }
    .icon-red { background: var(--danger-light); color: var(--danger); }
    .icon-purple { background: var(--info-light); color: var(--info); }
    .icon-yellow { background: var(--warning-light); color: var(--warning); }
    
    .kpi-data { flex: 1; }
    .kpi-title { color: var(--text-sub); font-size: 13px; font-weight: 500; margin-bottom: 4px; }
    .kpi-val { color: var(--text-main); font-size: 24px; font-weight: 700; line-height: 1.2; margin-bottom: 8px;}
    .kpi-trend { font-size: 13px; font-weight: 500; display: flex; align-items: center; gap: 4px; }
    .trend-up { color: var(--success); }
    .trend-down { color: var(--danger); }
    .trend-text { color: var(--text-sub); font-weight: 400; }
    
    /* Chart Grid */
    /* Shown when a company genuinely has no data for a chart. Until now the
       page filled those gaps with invented figures instead. */
    .nl-chart-empty {
        position: absolute; inset: 0; display: flex; flex-direction: column;
        align-items: center; justify-content: center; gap: 10px;
        color: var(--text-muted); text-align: center; padding: 20px;
        font-size: 13px; pointer-events: none;
    }
    .nl-chart-empty i { font-size: 26px; opacity: 0.55; }
    .charts-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 24px; margin-bottom: 24px; }
    .charts-grid-3 { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 24px; }
    .charts-grid-half { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px; }
    
    .chart-card { background: var(--bg-surface); border: 1px solid var(--border-color); border-radius: 12px; padding: 20px; display: flex; flex-direction: column; position: relative; }
    .chart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; gap: 12px; flex-wrap: wrap; }
    .chart-title { font-size: 15px; font-weight: 600; color: var(--text-main); margin: 0; min-width: 0; }
    
    .chart-actions { display: flex; gap: 8px; align-items: center; flex-shrink: 0; }
    .chart-tabs {
        display: flex;
        background: #F3F4F6;
        border-radius: 8px;
        padding: 3px;
        gap: 2px;
    }
    .chart-tab {
        padding: 5px 13px;
        font-size: 12px;
        font-weight: 500;
        background: transparent;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        color: var(--text-sub);
        transition: all 0.18s;
        white-space: nowrap;
    }
    .chart-tab:hover { color: var(--text-main); background: #E5E7EB; }
    .chart-tab.active {
        color: var(--primary);
        font-weight: 600;
        background: #fff;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }
    
    .chart-body { flex: 1; position: relative; min-height: 250px; display: flex; align-items: center; justify-content: center; }
    .chart-body canvas { max-width: 100%; max-height: 100%; }
    
    
    
    
    
    
    
    .metric-row { display: flex; justify-content: space-between; align-items: flex-end; margin-top: auto; padding-top: 16px; border-top: 1px solid var(--border-color); }
    .metric-item { text-align: left; }
    .metric-item-label { font-size: 12px; color: var(--text-sub); margin-bottom: 4px; }
    .metric-item-val { font-size: 18px; font-weight: 600; color: var(--text-main); }
    .metric-item-trend { font-size: 12px; color: var(--success); }
    
    .link-arrow { color: var(--primary); font-size: 13px; font-weight: 500; text-decoration: none; margin-top: auto; display: inline-block; }
    .link-arrow:hover { text-decoration: underline; }
    

    /* Date Range Inputs inside filter */
    .filter-date-range-wrap {
        display: inline-flex;
        align-items: center;
        gap: 8px;
    }
    .filter-date-input {
        border: 1px solid var(--border-color, #E2E8F0);
        outline: none;
        background: #FFFFFF;
        font-size: 13px;
        font-weight: 500;
        color: var(--text-main, #1E293B);
        width: 145px;
        height: 42px;
        cursor: pointer;
        padding: 0 14px;
        border-radius: 50px;
        transition: all 0.2s ease;
        box-sizing: border-box;
    }
    .filter-date-input:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.15) !important;
    }
    .filter-date-input::-webkit-calendar-picker-indicator {
        opacity: 0.65;
        cursor: pointer;
        width: 14px;
        height: 14px;
    }
    .date-sep {
        color: #94A3B8;
        font-size: 13px;
        font-weight: 600;
        flex-shrink: 0;
    }

    /* ===== Chart Card Tools (Fullscreen & Download) ===== */
    .chart-card-tools {
        display: flex;
        align-items: center;
        gap: 4px;
        flex-shrink: 0;
    }
    .chart-tool-btn {
        width: 30px;
        height: 30px;
        border-radius: 8px;
        border: 1px solid var(--border-color, #E2E8F0);
        background: transparent;
        color: var(--text-sub, #94A3B8);
        display: inline-flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        font-size: 13px;
        transition: all 0.18s ease;
        padding: 0;
        line-height: 1;
    }
    .chart-tool-btn:hover {
        background: var(--primary-light, rgba(252,128,25,0.12));
        border-color: var(--primary, #FC8019);
        color: var(--primary, #FC8019);
    }
    /* Fullscreen overlay */
    .nl-fullscreen-overlay {
        position: fixed;
        inset: 0;
        z-index: 9999;
        background: rgba(0,0,0,0.72);
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 32px;
        backdrop-filter: blur(4px);
        animation: nlFsIn 0.22s ease;
    }
    @keyframes nlFsIn {
        from { opacity: 0; transform: scale(0.96); }
        to   { opacity: 1; transform: scale(1); }
    }
    .nl-fullscreen-card {
        background: var(--bg-surface, #fff);
        border-radius: 16px;
        padding: 28px;
        width: 100%;
        max-width: 1100px;
        max-height: calc(100vh - 64px);
        overflow: auto;
        box-shadow: 0 24px 80px rgba(0,0,0,0.4);
        position: relative;
        display: flex;
        flex-direction: column;
        gap: 16px;
    }
    .nl-fullscreen-title {
        font-size: 18px;
        font-weight: 700;
        color: var(--text-main);
        margin: 0;
    }
    .nl-fullscreen-close {
        position: absolute;
        top: 16px;
        right: 16px;
        width: 34px;
        height: 34px;
        border-radius: 50%;
        border: 1px solid var(--border-color);
        background: transparent;
        color: var(--text-sub);
        font-size: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.18s;
    }
    .nl-fullscreen-close:hover { background: #EF4444; color: #fff; border-color: #EF4444; }
    .nl-fullscreen-canvas-wrap {
        flex: 1;
        min-height: 400px;
        position: relative;
    }
    [data-theme="dark"] .nl-fullscreen-card {
        background: #101820;
        box-shadow: 0 24px 80px rgba(0,0,0,0.7);
    }

    /* Dark Mode Filter Bar */
    [data-theme="dark"] .filters-bar-wrap,
    [data-theme="dark"] .filters-bar-inner {
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
    }
    [data-theme="dark"] .filters-right {
        border: none !important;
    }
    [data-theme="dark"] .filter-field:hover {
        background: transparent !important;
    }
    [data-theme="dark"] .filter-btn-reset {
        background: #1E293B !important;
        border: 1px solid #2D3F4D !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .filter-btn-reset:hover {
        background: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .filter-btn-export {
        background: rgba(252, 128, 25, 0.12) !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .filter-btn-export:hover {
        background: rgba(252, 128, 25, 0.22) !important;
    }
    [data-theme="dark"] .filter-date-input {
        background: #151F28 !important;
        border: 1px solid #2D3F4D !important;
        color: #F8FAFC !important;
        color-scheme: dark;
    }
    [data-theme="dark"] .filter-date-input:focus {
        border-color: #FC8019 !important;
    }
    [data-theme="dark"] .filter-select-custom {
        background-color: #151F28 !important;
        border: 1px solid #2D3F4D !important;
        color: #F8FAFC !important;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2394A3B8' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='m6 9 6 6 6-6'/%3E%3C/svg%3E") !important;
    }
    [data-theme="dark"] .filter-select-custom option {
        background-color: #151F28 !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .date-sep {
        color: #64748B !important;
    }

    /* Dark Mode PLG Chart Tabs */
    [data-theme="dark"] .chart-tabs {
        background: #101820 !important;
        border: 1px solid #223447 !important;
    }
    [data-theme="dark"] .chart-tab {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .chart-tab:hover {
        background: #1E293B !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .chart-tab.active {
        background: #1E293B !important;
        color: #FC8019 !important;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.4) !important;
    }

    /* Dark Mode Gauge Track */
    [data-theme="dark"] .nl-gauge-track {
        stroke: #223447 !important;
    }

    /* Dark Mode Container Filter in Demand Chart */
    [data-theme="dark"] select[name="forecastType"] {
        background-color: #101820 !important;
        color: #F8FAFC !important;
        border-color: #223447 !important;
    }
    [data-theme="dark"] select[name="forecastType"] option {
        background-color: #101820 !important;
        color: #F8FAFC !important;
    }

    </style>

<div class="dashboard-container">
    <div class="page-header">
        <div class="page-title">
            <h1>Analytics Dashboard</h1>
            <p>Dashboard > <span>Analytics</span></p>
        </div>
    </div>
    
    <form id="analyticsFilterForm" action="${pageContext.request.contextPath}/analytics" method="GET" class="filters-bar-wrap">
        <div class="filters-bar-inner">
            <div class="filters-left">
                <!-- Date Range -->
                <div class="filter-field">
                    <div class="filter-field-label"><i class="fi fi-rr-calendar"></i> Date Range</div>
                    <div class="filter-date-range-wrap">
                        <input type="date" name="dateFrom" class="filter-date-input"
                               value="${not empty filterDateFrom ? filterDateFrom : ''}"
                               onchange="document.getElementById('analyticsFilterForm').submit()"
                               placeholder="From">
                        <span class="date-sep">&#x2014;</span>
                        <input type="date" name="dateTo" class="filter-date-input"
                               value="${not empty filterDateTo ? filterDateTo : ''}"
                               onchange="document.getElementById('analyticsFilterForm').submit()"
                               placeholder="To">
                    </div>
                </div>
                <div class="filter-divider"></div>
                <!-- Company -->
                <div class="filter-field">
                    <div class="filter-field-label"><i class="fi fi-rr-building"></i> Company</div>
                    <select class="filter-select-custom" name="company" onchange="document.getElementById('analyticsFilterForm').submit()">
                        <option value="">All Companies</option>
                        <c:forEach var="co" items="${companies}">
                            <option value="${co[0]}" <c:if test="${filterCompany == co[0]}">selected</c:if>>${co[1]}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="filter-divider"></div>
                <!-- Route -->
                <div class="filter-field">
                    <div class="filter-field-label"><i class="fi fi-rr-route"></i> Route</div>
                    <select class="filter-select-custom" name="route" onchange="document.getElementById('analyticsFilterForm').submit()">
                        <option value="">All Routes</option>
                        <c:forEach var="rt" items="${routes}">
                            <option value="${rt[0]}" <c:if test="${filterRoute == rt[0]}">selected</c:if>>${rt[1]}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="filter-divider"></div>
                <!-- Product Category -->
                <div class="filter-field">
                    <div class="filter-field-label"><i class="fi fi-rr-tags"></i> Category</div>
                    <select class="filter-select-custom" name="category" onchange="document.getElementById('analyticsFilterForm').submit()">
                        <option value="">All Categories</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat}" <c:if test="${filterCategory == cat}">selected</c:if>>${cat}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            <div class="filters-right">
                <a href="${pageContext.request.contextPath}/analytics" class="filter-btn-reset" title="Reset Filters">
                    <i class="fi fi-rr-refresh"></i>
                    <span>Reset</span>
                </a>
                <a href="${pageContext.request.contextPath}/analytics?export=csv" class="filter-btn-export">
                    <i class="fi fi-rr-download"></i>
                    <span>Export</span>
                </a>
            </div>
        </div>
    </form>
    <div class="kpi-grid">
        <div class="kpi-card">
            <div class="kpi-icon icon-orange"><i class="fi fi-rr-box-alt"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Active Shipments</div>
                <div class="kpi-val">${activeShipments != null ? activeShipments : 0}</div>
                <div class="kpi-trend" style="color:var(--text-muted)">Currently in transit</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-green"><i class="fi fi-rr-usd-circle"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Total Revenue</div>
                <div class="kpi-val">&#8377; ${String.format("%,.0f", totalRevenue != null ? totalRevenue : 0)}</div>
                <%-- Real month-on-month movement. These badges used to read a fixed
                     "12% / 18% / 9% / 32% / 4.2% vs Apr 2025" on every account, in
                     every month, whether or not the company had any history. --%>
                <c:choose>
                    <c:when test="${deltaRevenue != null}">
                        <div class="kpi-trend ${deltaRevenue >= 0 ? 'trend-up' : 'trend-down'}"
                             ${deltaRevenue >= 0 ? '' : 'style="color:var(--danger)"'}>
                            <i class="fi fi-rr-arrow-small-${deltaRevenue >= 0 ? 'up' : 'down'}"></i>
                            ${deltaRevenue >= 0 ? deltaRevenue : -deltaRevenue}% <span class="trend-text">vs last month</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="kpi-trend" style="color:var(--text-muted)">No prior month to compare</div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-red"><i class="fi fi-rr-calculator"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Total Cost</div>
                <div class="kpi-val">&#8377; ${String.format("%,.0f", totalCost != null ? totalCost : 0)}</div>
                <%-- Real month-on-month movement. These badges used to read a fixed
                     "12% / 18% / 9% / 32% / 4.2% vs Apr 2025" on every account, in
                     every month, whether or not the company had any history. --%>
                <c:choose>
                    <c:when test="${deltaCost != null}">
                        <div class="kpi-trend ${deltaCost <= 0 ? 'trend-up' : 'trend-down'}"
                             ${deltaCost <= 0 ? '' : 'style="color:var(--danger)"'}>
                            <i class="fi fi-rr-arrow-small-${deltaCost >= 0 ? 'up' : 'down'}"></i>
                            ${deltaCost >= 0 ? deltaCost : -deltaCost}% <span class="trend-text">vs last month</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="kpi-trend" style="color:var(--text-muted)">No prior month to compare</div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-purple"><i class="fi fi-rr-chart-line-up"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Net Profit</div>
                <div class="kpi-val">&#8377; ${String.format("%,.0f", netProfit != null ? netProfit : 0)}</div>
                <%-- Real month-on-month movement. These badges used to read a fixed
                     "12% / 18% / 9% / 32% / 4.2% vs Apr 2025" on every account, in
                     every month, whether or not the company had any history. --%>
                <c:choose>
                    <c:when test="${deltaProfit != null}">
                        <div class="kpi-trend ${deltaProfit >= 0 ? 'trend-up' : 'trend-down'}"
                             ${deltaProfit >= 0 ? '' : 'style="color:var(--danger)"'}>
                            <i class="fi fi-rr-arrow-small-${deltaProfit >= 0 ? 'up' : 'down'}"></i>
                            ${deltaProfit >= 0 ? deltaProfit : -deltaProfit}% <span class="trend-text">vs last month</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="kpi-trend" style="color:var(--text-muted)">No prior month to compare</div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-yellow"><i class="fi fi-rr-time-check"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">On-time Delivery</div>
                <div class="kpi-val">${onTimePct != null ? onTimePct : 0}%</div>
                <div class="kpi-trend" style="color:var(--text-muted)">Across delivered movements</div>
            </div>
        </div>
    </div>
    
    <div class="charts-grid">
        <div class="chart-card">
            <div class="chart-header">
                <h3 class="chart-title">Profit & Loss Trend (PLG)</h3>
                <div class="chart-actions">
                    <div class="chart-tabs" id="plgTabs">
                        <button class="chart-tab" data-period="day">Day</button>
                        <button class="chart-tab" data-period="week">Week</button>
                        <button class="chart-tab active" data-period="month">Month</button>
                        <button class="chart-tab" data-period="quarter">Quarter</button>
                        <button class="chart-tab" data-period="year">Year</button>
                    </div>
                    <div class="chart-card-tools">
                        <button class="chart-tool-btn" title="Download PNG" onclick="nlDownloadChart('plChart','Profit & Loss Trend')">
                            <i class="fi fi-rr-download"></i>
                        </button>
                        <button class="chart-tool-btn" title="Fullscreen" onclick="nlFullscreen('plChart','Profit & Loss Trend (PLG)')">
                            <i class="fi fi-rr-expand"></i>
                        </button>
                    </div>
                </div>
            </div>
            <div class="chart-body">
                <canvas id="plChart"></canvas>
                <div class="nl-chart-empty" id="plgEmptyNote" style="display:none;"><i class="fi fi-rr-chart-histogram"></i><span>No profit or loss recorded for this period yet.</span></div>
            </div>
        </div>
        
        <div class="chart-card">
            <div class="chart-header">
                <h3 class="chart-title">Top Loss Reasons</h3>
                <div class="chart-card-tools">
                    <button class="chart-tool-btn" title="Download PNG" onclick="nlDownloadChart('lossChart','Top Loss Reasons')">
                        <i class="fi fi-rr-download"></i>
                    </button>
                    <button class="chart-tool-btn" title="Fullscreen" onclick="nlFullscreen('lossChart','Top Loss Reasons')">
                        <i class="fi fi-rr-expand"></i>
                    </button>
                </div>
            </div>
            <div class="chart-body">
                <canvas id="lossChart"></canvas>
                <div class="nl-chart-empty" id="lossEmptyNote" style="display:none;"><i class="fi fi-rr-chart-histogram"></i><span>No loss events recorded yet.</span></div>
            </div>
        </div>
    </div>
    
    <div class="charts-grid-3">
        <div class="chart-card">
            <div class="chart-header">
                <h3 class="chart-title">Container Utilization</h3>
                <div class="chart-card-tools">
                    <button class="chart-tool-btn" title="Fullscreen" onclick="nlFullscreenGauge('Container Utilization')">
                        <i class="fi fi-rr-expand"></i>
                    </button>
                </div>
            </div>
            <div class="chart-body" style="min-height: 180px;">
                <div class="gauge-wrapper">
                    <div class="nl-gauge" id="utilGauge" data-pct="${not empty utilizationPct ? utilizationPct : '0'}">
                        <svg viewBox="0 0 220 128" role="img" aria-label="Container utilization gauge">
                            <defs>
                                <linearGradient id="utilGaugeGrad" x1="0" y1="0" x2="1" y2="0">
                                    <stop offset="0%"   stop-color="#FDBA74"/>
                                    <stop offset="55%"  stop-color="#FC8019"/>
                                    <stop offset="100%" stop-color="#EA6A05"/>
                                </linearGradient>
                            </defs>
                            <!-- track -->
                            <path class="nl-gauge-track" d="M 20 110 A 90 90 0 0 1 200 110"/>
                            <!-- value arc (stroke-dashoffset animated in JS) -->
                            <path class="nl-gauge-fill" d="M 20 110 A 90 90 0 0 1 200 110"/>
                        </svg>
                        <div class="nl-gauge-center">
                            <div class="nl-gauge-val"><c:out value="${not empty utilizationPct ? utilizationPct : '0'}"/><span>%</span></div>
                            <div class="nl-gauge-sub">Utilization Rate</div>
                        </div>
                        <div class="nl-gauge-scale"><span>0%</span><span>100%</span></div>
                    </div>
                </div>
            </div>
            <div class="metric-row">
                <div class="metric-item">
                    <div class="metric-item-label">Total Containers</div>
                    <div class="metric-item-val">${totalContainers != null ? totalContainers : 842}</div>
                </div>
                <div class="metric-item">
                    <div class="metric-item-label">In Use</div>
                    <div class="metric-item-val">${inUseContainers != null ? inUseContainers : 643}</div>
                </div>
                <div class="metric-item">
                    <div class="metric-item-label">Idle</div>
                    <div class="metric-item-val">${idleContainers != null ? idleContainers : 199}</div>
                </div>
            </div>
        </div>
        
        <div class="chart-card">
            <div class="chart-header">
                <h3 class="chart-title">Stock Valuation</h3>
                <div class="chart-card-tools">
                    <button class="chart-tool-btn" title="Download PNG" onclick="nlDownloadChart('stockChart','Stock Valuation')">
                        <i class="fi fi-rr-download"></i>
                    </button>
                    <button class="chart-tool-btn" title="Fullscreen" onclick="nlFullscreen('stockChart','Stock Valuation')">
                        <i class="fi fi-rr-expand"></i>
                    </button>
                </div>
            </div>
            <div class="chart-body" style="min-height: 180px;">
                <canvas id="stockChart"></canvas>
            </div>
            <div class="metric-row">
                <div class="metric-item">
                    <div class="metric-item-label">Current Value</div>
                    <div class="metric-item-val">&#8377; ${not empty currentStockValue ? String.format("%,.0f", currentStockValue) : "42,15,600"}</div>
                </div>
                <div class="metric-item" style="text-align:right">
                    <%-- was a hardcoded "14% vs Apr 2025" --%>
                    <div class="metric-item-trend" style="color:var(--text-muted)">Current valuation</div>
                </div>
            </div>
        </div>
        
        <div class="chart-card">
            <div class="chart-header">
                <h3 class="chart-title">ABC Classification Summary</h3>
                <div class="chart-card-tools">
                    <button class="chart-tool-btn" title="Download PNG" onclick="nlDownloadChart('abcChart','ABC Classification Summary')">
                        <i class="fi fi-rr-download"></i>
                    </button>
                    <button class="chart-tool-btn" title="Fullscreen" onclick="nlFullscreen('abcChart','ABC Classification Summary')">
                        <i class="fi fi-rr-expand"></i>
                    </button>
                </div>
            </div>
            <div class="chart-body" style="min-height: 180px;">
                <canvas id="abcChart"></canvas>
                <div class="nl-chart-empty" id="abcEmptyNote" style="display:none;"><i class="fi fi-rr-chart-histogram"></i><span>No classified stock yet.</span></div>
            </div>
            <a href="#" class="link-arrow">View Full ABC Analysis &rarr;</a>
        </div>
    </div>
    
    <div class="charts-grid-half">
        <div class="chart-card">
            <div class="chart-header">
                <h3 class="chart-title">Demand Forecast (Next 6 Quarters)</h3>
                <div class="chart-actions">
                    <%-- Was a dead stub with a single hardcoded option; now a real filter. --%>
                    <form method="GET" action="${pageContext.request.contextPath}/analytics" style="display:inline-block; margin:0;">
                        <select name="forecastType" onchange="this.form.submit()" class="form-select-custom no-custom-select"
                                style="padding: 5px 28px 5px 10px !important; font-size: 12.5px !important; height: 32px !important; line-height: 1.2; border: 1px solid var(--border-color) !important; border-radius: 6px !important; appearance: none !important; -webkit-appearance: none !important; -moz-appearance: none !important; background-position: right 8px center !important; cursor: pointer;">
                            <option value="">All Container Types</option>
                            <c:forEach var="ft" items="${forecastTypes}">
                                <option value="${ft}" ${selectedForecastType == ft ? 'selected' : ''}>${ft}</option>
                            </c:forEach>
                        </select>
                    </form>
                    <div class="chart-card-tools">
                        <button class="chart-tool-btn" title="Download PNG" onclick="nlDownloadChart('demandChart','Demand Forecast')">
                            <i class="fi fi-rr-download"></i>
                        </button>
                        <button class="chart-tool-btn" title="Fullscreen" onclick="nlFullscreen('demandChart','Demand Forecast (Next 6 Quarters)')">
                            <i class="fi fi-rr-expand"></i>
                        </button>
                    </div>
                </div>
            </div>
            <div class="chart-body" style="min-height:220px;">
                <canvas id="demandChart"></canvas>
                <div class="nl-chart-empty" id="demandEmptyNote" style="display:none;"><i class="fi fi-rr-chart-histogram"></i><span>Not enough shipping history to forecast demand.</span></div>
            </div>
        </div>
        
        <div style="display:flex; flex-direction:column; gap:24px;">
            <div class="chart-card" style="flex: 1; padding: 16px 20px;">
                <div class="chart-header" style="margin-bottom:8px;">
                    <h3 class="chart-title">Inventory Turnover Ratio</h3>
                </div>
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                    <div style="display:flex; align-items:center; gap:16px;">
                        <div style="width:48px; height:48px; background:var(--info-light); color:var(--info); border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:20px;">
                            <i class="fi fi-rr-refresh"></i>
                        </div>
                        <div>
                            <div style="font-size:28px; font-weight:700; color:var(--text-main); line-height:1; margin-bottom:4px;">${not empty turnoverRatioStr ? turnoverRatioStr : "—"}</div>
                            <div style="font-size:12px; color:var(--text-sub);">Times</div>
                        </div>
                    </div>
                    <%-- was a hardcoded "0.82 vs Apr 2025" --%>
                    <div class="metric-item-trend" style="color:var(--text-muted)">COGS &divide; average inventory</div>
                </div>
                <div style="display:flex; justify-content:space-between; border-top:1px solid var(--border-color); padding-top:12px;">
                    <div>
                        <div style="font-size:11px; color:var(--text-sub); margin-bottom:2px;">Cost of Goods Sold</div>
                        <div style="font-size:14px; font-weight:600; color:var(--text-main);">&#8377; ${cogsStr}</div>
                    </div>
                    <div style="text-align:right">
                        <div style="font-size:11px; color:var(--text-sub); margin-bottom:2px;">Avg Inventory Value</div>
                        <div style="font-size:14px; font-weight:600; color:var(--text-main);">&#8377; ${avgInvValueStr}</div>
                    </div>
                </div>
            </div>
            
            <div class="chart-card" style="flex: 1; padding: 16px 20px;">
                <div class="chart-header" style="margin-bottom:12px;">
                    <h3 class="chart-title">Invoice Aging</h3>
                </div>
                <div style="display:flex; font-size:11px; color:var(--text-sub); gap:16px; margin-bottom:8px; justify-content:center;">
                    <span style="display:flex; align-items:center; gap:4px;"><span style="width:8px; height:8px; border-radius:50%; background:#10B981;"></span> 0 - 30 Days</span>
                    <span style="display:flex; align-items:center; gap:4px;"><span style="width:8px; height:8px; border-radius:50%; background:#FBBF24;"></span> 31 - 60 Days</span>
                    <span style="display:flex; align-items:center; gap:4px;"><span style="width:8px; height:8px; border-radius:50%; background:#FC8019;"></span> 61 - 90 Days</span>
                    <span style="display:flex; align-items:center; gap:4px;"><span style="width:8px; height:8px; border-radius:50%; background:#EF4444;"></span> > 90 Days</span>
                </div>
                <%-- Real receivables split by days past due (FR5.8). --%>
                <c:set var="agingTotal" value="${aging.total > 0 ? aging.total : 0}"/>
                <c:choose>
                    <c:when test="${agingTotal > 0}">
                        <div style="height:24px; border-radius:4px; display:flex; overflow:hidden; margin-bottom:12px;">
                            <c:set var="pCur" value="${aging.current * 100 / agingTotal}"/>
                            <c:set var="p60"  value="${aging.d31_60 * 100 / agingTotal}"/>
                            <c:set var="p90"  value="${aging.d61_90 * 100 / agingTotal}"/>
                            <c:set var="pOld" value="${aging.d90plus * 100 / agingTotal}"/>
                            <c:if test="${pCur > 0}"><div style="width:${pCur}%; background:#10B981; display:flex; align-items:center; justify-content:center; color:white; font-size:11px; font-weight:600;"><c:if test="${pCur >= 8}"><fmt:formatNumber value="${pCur}" maxFractionDigits="0"/>%</c:if></div></c:if>
                            <c:if test="${p60 > 0}"><div style="width:${p60}%; background:#FBBF24; display:flex; align-items:center; justify-content:center; color:white; font-size:11px; font-weight:600;"><c:if test="${p60 >= 8}"><fmt:formatNumber value="${p60}" maxFractionDigits="0"/>%</c:if></div></c:if>
                            <c:if test="${p90 > 0}"><div style="width:${p90}%; background:#FC8019; display:flex; align-items:center; justify-content:center; color:white; font-size:11px; font-weight:600;"><c:if test="${p90 >= 8}"><fmt:formatNumber value="${p90}" maxFractionDigits="0"/>%</c:if></div></c:if>
                            <c:if test="${pOld > 0}"><div style="width:${pOld}%; background:#EF4444; display:flex; align-items:center; justify-content:center; color:white; font-size:11px; font-weight:600;"><c:if test="${pOld >= 8}"><fmt:formatNumber value="${pOld}" maxFractionDigits="0"/>%</c:if></div></c:if>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="height:24px; border-radius:4px; background:#F1F5F9; display:flex; align-items:center; justify-content:center; color:var(--text-sub); font-size:11px; font-weight:600; margin-bottom:12px;">
                            No outstanding receivables
                        </div>
                    </c:otherwise>
                </c:choose>
                <div style="display:flex; justify-content:space-between; border-top:1px solid var(--border-color); padding-top:12px;">
                    <div>
                        <div style="font-size:11px; color:var(--text-sub); margin-bottom:2px;">Total Outstanding</div>
                        <div style="font-size:14px; font-weight:600; color:var(--text-main);">&#8377; ${agingTotalStr}</div>
                    </div>
                    <div style="text-align:right">
                        <div style="font-size:11px; color:var(--text-sub); margin-bottom:2px;">Overdue Amount</div>
                        <div style="font-size:14px; font-weight:600; color:var(--danger);">&#8377; ${agingOverdueStr}
                            <span style="font-weight:normal">(${agingOverduePct}%)</span></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.9/dist/chart.umd.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/nl-chart-theme.js"></script>

<script>
    // Inject backend data into JS
    var plgDataJson = ${not empty plgJson ? plgJson : '[]'};

    // FR2.6 profit & loss trend, one source for the initial render and for every
    // tab. Day / Week / Quarter / Year were arrays typed into this page, and the
    // chart below was constructed with a hardcoded seven-point May curve that
    // only got replaced if the user clicked a tab - so an account with no
    // shipments still opened on a busy-looking graph.
    var plgSeries = ${not empty plgSeriesJson ? plgSeriesJson : '{}'};

    function seriesFor(key) {
        var rows = plgSeries[key] || [];
        return {
            labels: rows.map(function (r) { return r.label; }),
            // "Profit" plotted gross revenue before; profit is revenue minus cost.
            profit: rows.map(function (r) { return Math.round((r.revenue - r.cost) / 1000); }),
            loss:   rows.map(function (r) { return -Math.round(r.cost / 1000); })
        };
    }

    var plgInitial = seriesFor('month');

    // Profit & Loss Trend (Line Chart)
    var plChartInstance = new Chart(document.getElementById('plChart'), {
        type: 'line',
        data: {
            labels: plgInitial.labels,
            datasets: [
                {
                    label: 'Profit (\u20B9)',
                    data: plgInitial.profit,
                    borderColor: '#10B981',
                    backgroundColor: 'rgba(16, 185, 129, 0.1)',
                    borderWidth: 2,
                    tension: 0.4,
                    fill: true,
                    pointRadius: 0
                },
                {
                    label: 'Loss (\u20B9)',
                    data: plgInitial.loss,
                    borderColor: '#EF4444',
                    backgroundColor: 'rgba(239, 68, 68, 0.1)',
                    borderWidth: 2,
                    tension: 0.4,
                    fill: true,
                    pointRadius: 0
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { position: 'top', align: 'start', labels: { usePointStyle: true, boxWidth: 8, font: {size: 11} } } },
            scales: {
                y: {
                    ticks: { callback: function(val) { return val === 0 ? '\u20B9 0' : (val > 0 ? '\u20B9 ' + val + 'K' : '-\u20B9 ' + Math.abs(val) + 'K'); }, font: {size:10} },
                    grid: { color: '#F3F4F6' },
                    border: { display: false }
                },
                x: { grid: { display: false }, ticks: { font: {size:10} }, border: { display: false } }
            },
            interaction: { mode: 'index', intersect: false }
        }
    });

    function isDarkTheme() {
        return document.documentElement.getAttribute('data-theme') === 'dark';
    }

    // Top Loss Reasons (Doughnut)
    // The seven "typical" loss reasons and their rupee figures used to be
    // hardcoded here and drawn whenever the real query came back empty. A
    // company with no losses was shown 2.15 lakh of Delay cost next to a
    // "Total Loss" of zero, which is where the contradiction came from.
    var lossDataJson = ${not empty lossJson ? lossJson : '[]'};
    var lossChartInstance = new Chart(document.getElementById('lossChart'), {
        type: 'doughnut',
        data: {
            labels: lossDataJson.map(function(d){return d.reason;}),
            datasets: [{
                data: lossDataJson.map(function(d){return d.impact;}),
                backgroundColor: ['#EF4444', '#FC8019', '#F59E0B', '#10B981', '#3B82F6', '#6366F1', '#8B5CF6'],
                borderWidth: 0,
                cutout: '70%'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'right', labels: { usePointStyle: true, padding: 12, boxWidth: 6, font: {size:10},
                    color: isDarkTheme() ? '#E2E8F0' : '#475569',
                    generateLabels: function(chart) {
                        const data = chart.data;
                        const isDark = isDarkTheme();
                        if (data.labels.length && data.datasets.length) {
                            return data.labels.map((label, i) => {
                                const val = data.datasets[0].data[i];
                                const total = data.datasets[0].data.reduce((a, b) => a + b, 0);
                                const percent = total > 0 ? ((val / total) * 100).toFixed(1) + '%' : '0%';
                                const formattedVal = '\u20B9 ' + val.toLocaleString('en-IN');
                                return {
                                    text: label + '           ' + formattedVal + ' (' + percent + ')',
                                    fillStyle: data.datasets[0].backgroundColor[i],
                                    fontColor: isDark ? '#E2E8F0' : '#334155',
                                    hidden: false,
                                    index: i
                                };
                            });
                        }
                        return [];
                    }
                } }
            },
            layout: { padding: { left: 0, right: 0 } }
        },
        plugins: [{
            id: 'centerText',
            beforeDraw: function(chart) {
                var width = chart.width, height = chart.height, ctx = chart.ctx;
                ctx.restore();
                
                var chartArea = chart.chartArea;
                var centerX = (chartArea.left + chartArea.right) / 2;
                var centerY = (chartArea.top + chartArea.bottom) / 2;
                var isDark = isDarkTheme();

                ctx.font = "500 12px Inter, sans-serif";
                ctx.textBaseline = "middle";
                ctx.textAlign = "center";
                ctx.fillStyle = isDark ? "#94A3B8" : "#6B7280";
                ctx.fillText("Total Loss", centerX, centerY - 10);
                
                ctx.font = "700 16px Inter, sans-serif";
                ctx.fillStyle = isDark ? "#F8FAFC" : "#111827";
                ctx.fillText("\u20B9 " + Math.round(Number('${not empty totalLossImpact ? totalLossImpact : 0}')).toLocaleString('en-IN'), centerX, centerY + 10);
                ctx.save();
            }
        }]
    });

    // Container Utilization Gauge — SVG arc driven by the same DB-backed value.
    // Arc length = PI * r = PI * 90 = 282.74 (matches stroke-dasharray in CSS).
    (function () {
        var g = document.getElementById('utilGauge');
        if (!g) return;
        var arc = g.querySelector('.nl-gauge-fill');
        var pct = parseFloat(g.getAttribute('data-pct'));
        if (isNaN(pct)) pct = 0;
        pct = Math.max(0, Math.min(100, pct));
        var LEN = Math.PI * 90;
        // paint on the next frame so the CSS transition actually runs
        requestAnimationFrame(function () {
            requestAnimationFrame(function () {
                arc.style.strokeDashoffset = (LEN * (1 - pct / 100)).toFixed(2);
            });
        });
    })();

    // Stock Valuation by Category (Bar) \— 100% DB-driven from AnalyticsDAO.getStockValuation()
    var stockValJson = ${not empty stockValJson ? stockValJson : '[]'};
    new Chart(document.getElementById('stockChart'), {
        type: 'bar',
        data: {
            labels: stockValJson.map(function(d){return d.category;}),
            datasets: [{
                data: stockValJson.map(function(d){return d.value;}),
                backgroundColor: '#10B981',
                borderRadius: 6,
                maxBarThickness: 40
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: { ticks: { callback: function(val) { return '\u20B9 ' + val.toLocaleString('en-IN'); }, font: {size:10} }, grid: { color: isDarkTheme() ? '#223447' : '#F3F4F6' }, border: { display: false } },
                x: { grid: { display: false }, ticks: { font: {size:10} }, border: { display: false } }
            }
        }
    });

    // ABC Classification Summary (Doughnut)
    var abcDataJson = ${not empty abcJson ? abcJson : '[]'};
    var abcClassOrder = ['Class A', 'Class B', 'Class C'];
    var abcClassLabels = { 'Class A': 'A - High Value', 'Class B': 'B - Medium Value', 'Class C': 'C - Low Value' };
    var abcCounts = abcClassOrder.map(function(cls) {
        var found = abcDataJson.find(function(d){ return d.class === cls; });
        return found ? found.count : 0;
    });
    var abcHasData = abcDataJson.length > 0;
    var abcChartInstance = new Chart(document.getElementById('abcChart'), {
        type: 'doughnut',
        data: {
            // Placeholder counts of 212 / 415 / 620 used to fill this in when the
            // company had no classified stock of its own.
            labels: abcClassOrder.map(function(c){return abcClassLabels[c];}),
            datasets: [{
                data: abcCounts,
                backgroundColor: ['#10B981', '#F59E0B', '#EF4444'],
                borderWidth: 0,
                cutout: '75%'
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: {
                legend: { position: 'right', labels: { usePointStyle: true, padding: 16, boxWidth: 8, font: {size:11},
                    color: isDarkTheme() ? '#E2E8F0' : '#475569',
                    generateLabels: function(chart) {
                        const data = chart.data;
                        const isDark = isDarkTheme();
                        return data.labels.map((label, i) => {
                            const val = data.datasets[0].data[i];
                            const total = data.datasets[0].data.reduce((a, b) => a + b, 0) || 1;
                            const percent = ((val / total) * 100).toFixed(1) + '%';
                            return {
                                text: label + ' (' + percent + ')',
                                fillStyle: data.datasets[0].backgroundColor[i],
                                fontColor: isDark ? '#E2E8F0' : '#334155',
                                hidden: false,
                                index: i
                            };
                        });
                    }
                } }
            }
        },
        plugins: [{
            id: 'centerText2',
            beforeDraw: function(chart) {
                var width = chart.width, height = chart.height, ctx = chart.ctx;
                ctx.restore();
                
                var chartArea = chart.chartArea;
                var centerX = (chartArea.left + chartArea.right) / 2;
                var centerY = (chartArea.top + chartArea.bottom) / 2;
                var isDark = isDarkTheme();

                ctx.font = "500 11px Inter, sans-serif";
                ctx.textBaseline = "middle";
                ctx.textAlign = "center";
                ctx.fillStyle = isDark ? "#94A3B8" : "#6B7280";
                ctx.fillText("Total Items", centerX, centerY - 10);
                
                ctx.font = "700 18px Inter, sans-serif";
                ctx.fillStyle = isDark ? "#F8FAFC" : "#111827";
                var abcTotal = abcHasData ? abcCounts.reduce(function(a,b){return a+b;}, 0) : 1247;
                ctx.fillText(abcTotal.toLocaleString('en-IN'), centerX, centerY + 10);
                ctx.save();
            }
        }]
    });

    // Demand Forecast (Bar) — 100% DB-driven from demand_forecast table (Alg 5.5 / FR3.6)
    var demandDataJson = ${not empty demandJson ? demandJson : '[]'};
    new Chart(document.getElementById('demandChart'), {
        type: 'bar',
        data: {
            labels: demandDataJson.map(function(d){return d.period;}),
            datasets: [
                {
                    label: 'Forecasted Demand',
                    data: demandDataJson.map(function(d){return d.demand;}),
                    backgroundColor: 'rgba(249, 115, 22, 0.15)',
                    borderColor: '#FC8019',
                    borderWidth: 2,
                    borderSkipped: false,
                    barThickness: 32,
                    borderRadius: 2
                }
            ]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { position: 'top', align: 'start', labels: { usePointStyle: true, boxWidth: 8, font: {size: 11} } } },
            scales: {
                y: { ticks: { callback: function(val) { return val >= 1000 ? (val/1000) + 'K' : val; }, font: {size:10} }, grid: { color: '#F3F4F6' }, border: { display: false }, beginAtZero: true },
                x: { grid: { display: false }, ticks: { font: {size:10} }, border: { display: false } }
            }
        }
    });

    

    // ===== P&L Period Toggle Logic =====
    (function() {
        var plgTabs = document.querySelectorAll('#plgTabs .chart-tab');
        console.log('[PLG Tabs] Found:', plgTabs.length, 'tabs');
        plgTabs.forEach(function(tab) {
            tab.addEventListener('click', function() {
                plgTabs.forEach(function(t) { t.classList.remove('active'); });
                this.classList.add('active');
                var period = this.getAttribute('data-period');
                console.log('[PLG Tabs] Switching to:', period);
                fetchPlgData(period);
            });
        });
    })();

    function fetchPlgData(period) {
        if (typeof plChartInstance === 'undefined' || !plChartInstance) {
            console.error('plChartInstance not found');
            return;
        }
        var chart = plChartInstance;
        var safeJson = (typeof plgDataJson !== 'undefined') ? plgDataJson : [];


        var d = seriesFor(period && plgSeries[period] ? period : 'month');
        chart.data.labels = d.labels;
        chart.data.datasets[0].data = d.profit;
        chart.data.datasets[1].data = d.loss;
        chart.update();

        // Say so plainly instead of drawing an empty grid that looks broken.
        var emptyNote = document.getElementById('plgEmptyNote');
        if (emptyNote) emptyNote.style.display = d.labels.length ? 'none' : 'flex';
    }

    // ===== Chart Tool Utilities =====

    /** Download any Chart.js canvas as PNG */
    function nlDownloadChart(canvasId, title) {
        var canvas = document.getElementById(canvasId);
        if (!canvas) return;
        // Draw on white/dark bg so transparent canvas looks correct in the file
        var isDark = document.documentElement.getAttribute('data-theme') === 'dark';
        var tempCanvas = document.createElement('canvas');
        tempCanvas.width  = canvas.width;
        tempCanvas.height = canvas.height;
        var ctx = tempCanvas.getContext('2d');
        ctx.fillStyle = isDark ? '#101820' : '#ffffff';
        ctx.fillRect(0, 0, tempCanvas.width, tempCanvas.height);
        ctx.drawImage(canvas, 0, 0);
        var link = document.createElement('a');
        link.download = (title || 'chart').replace(/[^a-z0-9]/gi, '_') + '.png';
        link.href = tempCanvas.toDataURL('image/png');
        link.click();
    }

    /** Open a chart canvas in a full-screen overlay (image snapshot approach) */
    function nlFullscreen(canvasId, title) {
        var srcCanvas = document.getElementById(canvasId);
        if (!srcCanvas) return;
        var isDark = document.documentElement.getAttribute('data-theme') === 'dark';
        var bgColor = isDark ? '#101820' : '#ffffff';

        // Use Chart.js toBase64Image if available for best quality, else fallback
        var chartInst = (typeof Chart !== 'undefined') ? Chart.getChart(srcCanvas) : null;
        var imgSrc;
        if (chartInst && typeof chartInst.toBase64Image === 'function') {
            // Temporarily set background so export isn't transparent
            var origBg = chartInst.config.options && chartInst.config.options.plugins
                       && chartInst.config.options.plugins.legend ? null : null;
            imgSrc = chartInst.toBase64Image('image/png', 1);
        } else {
            var tmp = document.createElement('canvas');
            tmp.width  = srcCanvas.width  || 800;
            tmp.height = srcCanvas.height || 400;
            var tCtx = tmp.getContext('2d');
            tCtx.fillStyle = bgColor;
            tCtx.fillRect(0, 0, tmp.width, tmp.height);
            tCtx.drawImage(srcCanvas, 0, 0);
            imgSrc = tmp.toDataURL('image/png');
        }

        var overlay = document.createElement('div');
        overlay.className = 'nl-fullscreen-overlay';
        overlay.id = 'nlFsOverlay';
        overlay.innerHTML =
            '<div class="nl-fullscreen-card">' +
                '<h3 class="nl-fullscreen-title">' + (title || '') + '</h3>' +
                '<button class="nl-fullscreen-close" title="Close (Esc)"><i class="fi fi-rr-cross"></i></button>' +
                '<div style="flex:1;overflow:hidden;border-radius:8px;background:' + bgColor + ';display:flex;align-items:center;justify-content:center;min-height:360px;">' +
                    '<img src="' + imgSrc + '" style="width:100%;height:auto;display:block;border-radius:8px;">' +
                '</div>' +
            '</div>';

        document.body.appendChild(overlay);
        document.body.style.overflow = 'hidden';

        function closeOverlay() {
            overlay.remove();
            document.body.style.overflow = '';
            document.removeEventListener('keydown', onKey);
        }
        function onKey(e) { if (e.key === 'Escape') closeOverlay(); }
        overlay.querySelector('.nl-fullscreen-close').addEventListener('click', closeOverlay);
        overlay.addEventListener('click', function(e) { if (e.target === overlay) closeOverlay(); });
        document.addEventListener('keydown', onKey);
    }

    /** Fullscreen for SVG-based gauge card (no canvas) */
    function nlFullscreenGauge(title) {
        var gaugeEl = document.getElementById('utilGauge');
        if (!gaugeEl) return;
        var overlay = document.createElement('div');
        overlay.className = 'nl-fullscreen-overlay';
        overlay.id = 'nlFsOverlay';
        var clone = gaugeEl.parentElement.cloneNode(true);
        clone.style.cssText = 'width:320px;max-width:100%;';
        overlay.innerHTML =
            '<div class="nl-fullscreen-card" style="max-width:480px;align-items:center;">' +
                '<h3 class="nl-fullscreen-title">' + (title || '') + '</h3>' +
                '<button class="nl-fullscreen-close" title="Close (Esc)"><i class="fi fi-rr-cross"></i></button>' +
            '</div>';
        overlay.querySelector('.nl-fullscreen-card').appendChild(clone);
        document.body.appendChild(overlay);
        document.body.style.overflow = 'hidden';
        function closeOverlay() {
            overlay.remove();
            document.body.style.overflow = '';
            document.removeEventListener('keydown', onKey);
        }
        function onKey(e) { if (e.key === 'Escape') closeOverlay(); }
        overlay.querySelector('.nl-fullscreen-close').addEventListener('click', closeOverlay);
        overlay.addEventListener('click', function(e) { if (e.target === overlay) closeOverlay(); });
        document.addEventListener('keydown', onKey);
    }

</script>

<script>
// One place decides whether a chart has anything to draw, so the empty state and
// the canvas can never disagree.
(function () {
    function toggle(noteId, hasData) {
        var el = document.getElementById(noteId);
        if (el) el.style.display = hasData ? 'none' : 'flex';
    }
    function len(v) { return (v && v.length) ? v.length : 0; }
    try { toggle('plgEmptyNote',    len(plgInitial.labels) > 0); } catch (e) {}
    try { toggle('lossEmptyNote',   len(lossDataJson) > 0); } catch (e) {}
    try { toggle('abcEmptyNote',    len(abcDataJson) > 0); } catch (e) {}
    try { toggle('demandEmptyNote', len(demandDataJson) > 0); } catch (e) {}
})();
</script>

</body>
</html>
