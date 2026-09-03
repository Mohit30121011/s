<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/jsp/layout/header.jsp" />

<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-regular-rounded/css/uicons-regular-rounded.css'>
<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-solid-rounded/css/uicons-solid-rounded.css'>

<style>
    :root {
        --bg-surface: #ffffff;
        --border-color: #E5E7EB;
        --text-main: #111827;
        --text-sub: #6B7280;
        --primary: #F97316;
        --primary-light: #FFEDD5;
        --success: #10B981;
        --success-light: #D1FAE5;
        --danger: #EF4444;
        --danger-light: #FEE2E2;
        --warning: #F59E0B;
        --warning-light: #FEF3C7;
        --info: #8B5CF6;
        --info-light: #EDE9FE;
    }
    body { background-color: #F9FAFB; }
    .dashboard-container { padding: 24px; max-width: 1400px; margin: 0 auto; }
    
    .page-header { margin-bottom: 24px; }
    .page-title h1 { font-size: 24px; font-weight: 700; color: var(--text-main); margin: 0 0 4px 0; }
    .page-title p { color: var(--text-sub); margin: 0; font-size: 14px; }
    .page-title p span { color: var(--primary); font-weight: 500; }
    
    /* Filters Bar */
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    .gauge-canvas-wrap { width: 200px; height: 100px; position: relative; overflow: hidden; flex-shrink: 0; }
    .gauge-canvas-wrap canvas { display: block; }
    .gauge-text { text-align: center; margin-top: 6px; }
    .gauge-val { font-size: 28px; font-weight: 700; color: var(--text-main); line-height: 1.2; }
    .gauge-sub { font-size: 12px; color: var(--text-sub); margin-top: 2px; }
    .gauge-labels { display: flex; justify-content: space-between; width: 200px; margin-top: 6px; font-size: 11px; color: var(--text-sub); }
    
    /* ===== Filter Bar ===== */
    .filters-bar-wrap {
        margin-bottom: 24px;
    }
    .filters-bar-inner {
        display: flex;
        align-items: center;
        justify-content: space-between;
        background: #fff;
        border: 1px solid var(--border-color);
        border-radius: 12px;
        padding: 0 6px 0 0;
        overflow: hidden;
        box-shadow: 0 1px 4px rgba(0,0,0,0.04);
    }
    .filters-left {
        display: flex;
        align-items: center;
        flex: 1;
        overflow: hidden;
    }
    .filter-field {
        padding: 10px 18px;
        min-width: 0;
        flex: 1;
        cursor: pointer;
    }
    .filter-field-label {
        font-size: 11px;
        font-weight: 600;
        color: var(--text-sub);
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 4px;
        display: flex;
        align-items: center;
        gap: 5px;
        white-space: nowrap;
    }
    .filter-field-label i {
        font-size: 11px;
        color: var(--primary);
    }
    .filter-date-btn {
        display: flex;
        align-items: center;
        justify-content: space-between;
        font-size: 13px;
        font-weight: 500;
        color: var(--text-main);
        white-space: nowrap;
        gap: 8px;
        background: none;
        border: none;
        padding: 0;
        cursor: pointer;
        width: 100%;
    }
    .filter-date-btn i { color: var(--text-sub); font-size: 11px; flex-shrink: 0; }
    .filter-date-btn span { overflow: hidden; text-overflow: ellipsis; }
    .filter-select-custom {
        width: 100%;
        border: none;
        outline: none;
        background: transparent;
        font-size: 13px;
        font-weight: 500;
        color: var(--text-main);
        cursor: pointer;
        appearance: none;
        -webkit-appearance: none;
        padding: 0;
    }
    .filter-select-custom:focus { outline: none; }
    .filter-divider {
        width: 1px;
        height: 36px;
        background: var(--border-color);
        flex-shrink: 0;
    }
    .filters-right {
        display: flex;
        align-items: center;
        gap: 6px;
        padding: 6px 0 6px 12px;
        border-left: 1px solid var(--border-color);
        margin-left: 6px;
        flex-shrink: 0;
    }
    .filter-btn-reset, .filter-btn-apply, .filter-btn-export {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 8px 14px;
        border-radius: 8px;
        font-size: 13px;
        font-weight: 500;
        cursor: pointer;
        border: none;
        text-decoration: none;
        transition: all 0.18s;
        white-space: nowrap;
    }
    .filter-btn-reset {
        background: #F3F4F6;
        color: var(--text-sub);
    }
    .filter-btn-reset:hover { background: #E5E7EB; color: var(--text-main); }
    .filter-btn-apply {
        background: var(--primary);
        color: #fff;
    }
    .filter-btn-apply:hover { background: #EA580C; }
    .filter-btn-export {
        background: #FFF7ED;
        color: var(--primary);
        border: 1px solid #FED7AA;
    }
    .filter-btn-export:hover { background: var(--primary-light); }
    .filter-field:hover { background: #FAFAFA; }

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
    .charts-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 24px; margin-bottom: 24px; }
    .charts-grid-3 { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 24px; }
    .charts-grid-half { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px; }
    
    .chart-card { background: var(--bg-surface); border: 1px solid var(--border-color); border-radius: 12px; padding: 20px; display: flex; flex-direction: column; position: relative; }
    .chart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
    .chart-title { font-size: 16px; font-weight: 600; color: var(--text-main); margin: 0; }
    
    .chart-actions { display: flex; gap: 8px; align-items: center; }
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
        display: flex; align-items: center; gap: 4px;
    }
    .filter-date-input {
        border: none; outline: none; background: transparent;
        font-size: 12px; font-weight: 500; color: var(--text-main);
        width: 110px; cursor: pointer; padding: 0;
    }
    .filter-date-input::-webkit-calendar-picker-indicator {
        opacity: 0.4; cursor: pointer; width: 12px; height: 12px;
    }
    .date-sep { color: var(--text-sub); font-size: 12px; flex-shrink: 0; }

    </style>

<div class="dashboard-container">
    <div class="page-header">
        <div class="page-title">
            <h1>Analytics Dashboard</h1>
            <p>Dashboard > <span>Analytics</span></p>
        </div>
    </div>
    
    <form action="${pageContext.request.contextPath}/analytics" method="GET" class="filters-bar-wrap">
        <div class="filters-bar-inner">
            <div class="filters-left">
                <!-- Date Range -->
                <div class="filter-field" style="min-width:200px;">
                    <div class="filter-field-label"><i class="fi fi-rr-calendar"></i> Date Range</div>
                    <div class="filter-date-range-wrap">
                        <input type="date" name="dateFrom" class="filter-date-input"
                               value="${not empty filterDateFrom ? filterDateFrom : ''}"
                               placeholder="From">
                        <span class="date-sep">&#x2014;</span>
                        <input type="date" name="dateTo" class="filter-date-input"
                               value="${not empty filterDateTo ? filterDateTo : ''}"
                               placeholder="To">
                    </div>
                </div>
                <div class="filter-divider"></div>
                <!-- Company -->
                <div class="filter-field">
                    <div class="filter-field-label"><i class="fi fi-rr-building"></i> Company</div>
                    <select class="filter-select-custom" name="company">
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
                    <select class="filter-select-custom" name="route">
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
                    <select class="filter-select-custom" name="category">
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
                <button type="submit" class="filter-btn-apply">
                    <i class="fi fi-rr-search"></i>
                    <span>Apply</span>
                </button>
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
                <div class="kpi-trend trend-up"><i class="fi fi-rr-arrow-small-up"></i> 12% <span class="trend-text">vs Apr 2025</span></div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-green"><i class="fi fi-rr-usd-circle"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Total Revenue</div>
                <div class="kpi-val">&#8377; ${String.format("%,.0f", totalRevenue != null ? totalRevenue : 0)}</div>
                <div class="kpi-trend trend-up"><i class="fi fi-rr-arrow-small-up"></i> 18% <span class="trend-text">vs Apr 2025</span></div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-red"><i class="fi fi-rr-calculator"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Total Cost</div>
                <div class="kpi-val">&#8377; ${String.format("%,.0f", totalCost != null ? totalCost : 0)}</div>
                <div class="kpi-trend trend-down" style="color:var(--danger)"><i class="fi fi-rr-arrow-small-up"></i> 9% <span class="trend-text">vs Apr 2025</span></div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-purple"><i class="fi fi-rr-chart-line-up"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Net Profit</div>
                <div class="kpi-val">&#8377; ${String.format("%,.0f", netProfit != null ? netProfit : 0)}</div>
                <div class="kpi-trend trend-up"><i class="fi fi-rr-arrow-small-up"></i> 32% <span class="trend-text">vs Apr 2025</span></div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-yellow"><i class="fi fi-rr-time-check"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">On-time Delivery</div>
                <div class="kpi-val">${onTimePct != null ? onTimePct : 0}%</div>
                <div class="kpi-trend trend-down"><i class="fi fi-rr-arrow-small-down"></i> 4.2% <span class="trend-text">vs Apr 2025</span></div>
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
                    <i class="fi fi-rr-menu-dots-vertical" style="color:var(--text-sub); margin-left:8px; cursor:pointer;"></i>
                </div>
            </div>
            <div class="chart-body">
                <canvas id="plChart"></canvas>
            </div>
        </div>
        
        <div class="chart-card">
            <div class="chart-header">
                <h3 class="chart-title">Top Loss Reasons</h3>
                <i class="fi fi-rr-download" style="color:var(--text-sub); cursor:pointer;"></i>
            </div>
            <div class="chart-body">
                <canvas id="lossChart"></canvas>
            </div>
        </div>
    </div>
    
    <div class="charts-grid-3">
        <div class="chart-card">
            <div class="chart-header">
                <h3 class="chart-title">Container Utilization</h3>
                <i class="fi fi-rr-menu-dots-vertical" style="color:var(--text-sub); cursor:pointer;"></i>
            </div>
            <div class="chart-body" style="min-height: 180px;">
                <div class="gauge-wrapper">
                    <div class="gauge-canvas-wrap">
                        <canvas id="utilizationChart"></canvas>
                    </div>
                    <div class="gauge-text">
                        <div class="gauge-val"><c:out value="${not empty utilizationPct ? utilizationPct : '76.4'}"/>%</div>
                        <div class="gauge-sub">Utilization Rate</div>
                    </div>
                    <div class="gauge-labels">
                        <span>0%</span>
                        <span>100%</span>
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
                <i class="fi fi-rr-menu-dots-vertical" style="color:var(--text-sub); cursor:pointer;"></i>
            </div>
            <div class="chart-body" style="min-height: 180px;">
                <canvas id="stockChart"></canvas>
            </div>
            <div class="metric-row">
                <div class="metric-item">
                    <div class="metric-item-label">Current Value</div>
                    <div class="metric-item-val">&#8377; 42,15,600</div>
                </div>
                <div class="metric-item" style="text-align:right">
                    <div class="metric-item-trend"><i class="fi fi-rr-arrow-small-up"></i> 14% vs Apr 2025</div>
                </div>
            </div>
        </div>
        
        <div class="chart-card">
            <div class="chart-header">
                <h3 class="chart-title">ABC Classification Summary</h3>
                <i class="fi fi-rr-menu-dots-vertical" style="color:var(--text-sub); cursor:pointer;"></i>
            </div>
            <div class="chart-body" style="min-height: 180px;">
                <canvas id="abcChart"></canvas>
            </div>
            <a href="#" class="link-arrow">View Full ABC Analysis &rarr;</a>
        </div>
    </div>
    
    <div class="charts-grid-half">
        <div class="chart-card">
            <div class="chart-header">
                <h3 class="chart-title">Demand Forecast (Next 3 Months)</h3>
                <div class="chart-actions">
                    <select class="form-select-custom" style="padding:4px 24px 4px 8px; font-size:12px; height:auto; line-height:1.2; border:1px solid var(--border-color); border-radius:6px;"><option>All Categories</option></select>
                    <i class="fi fi-rr-menu-dots-vertical" style="color:var(--text-sub); margin-left:8px; cursor:pointer;"></i>
                </div>
            </div>
            <div class="chart-body" style="min-height:220px;">
                <canvas id="demandChart"></canvas>
            </div>
        </div>
        
        <div style="display:flex; flex-direction:column; gap:24px;">
            <div class="chart-card" style="flex: 1; padding: 16px 20px;">
                <div class="chart-header" style="margin-bottom:8px;">
                    <h3 class="chart-title">Inventory Turnover Ratio</h3>
                    <i class="fi fi-rr-menu-dots-vertical" style="color:var(--text-sub); cursor:pointer;"></i>
                </div>
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                    <div style="display:flex; align-items:center; gap:16px;">
                        <div style="width:48px; height:48px; background:var(--info-light); color:var(--info); border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:20px;">
                            <i class="fi fi-rr-refresh"></i>
                        </div>
                        <div>
                            <div style="font-size:28px; font-weight:700; color:var(--text-main); line-height:1; margin-bottom:4px;">5.42</div>
                            <div style="font-size:12px; color:var(--text-sub);">Times</div>
                        </div>
                    </div>
                    <div class="metric-item-trend"><i class="fi fi-rr-arrow-small-up"></i> 0.82 vs Apr 2025</div>
                </div>
                <div style="display:flex; justify-content:space-between; border-top:1px solid var(--border-color); padding-top:12px;">
                    <div>
                        <div style="font-size:11px; color:var(--text-sub); margin-bottom:2px;">Cost of Goods Sold</div>
                        <div style="font-size:14px; font-weight:600; color:var(--text-main);">&#8377; 32,80,500</div>
                    </div>
                    <div style="text-align:right">
                        <div style="font-size:11px; color:var(--text-sub); margin-bottom:2px;">Avg Inventory Value</div>
                        <div style="font-size:14px; font-weight:600; color:var(--text-main);">&#8377; 6,05,800</div>
                    </div>
                </div>
            </div>
            
            <div class="chart-card" style="flex: 1; padding: 16px 20px;">
                <div class="chart-header" style="margin-bottom:12px;">
                    <h3 class="chart-title">Invoice Aging</h3>
                    <i class="fi fi-rr-download" style="color:var(--text-sub); cursor:pointer;"></i>
                </div>
                <div style="display:flex; font-size:11px; color:var(--text-sub); gap:16px; margin-bottom:8px; justify-content:center;">
                    <span style="display:flex; align-items:center; gap:4px;"><span style="width:8px; height:8px; border-radius:50%; background:#10B981;"></span> 0 - 30 Days</span>
                    <span style="display:flex; align-items:center; gap:4px;"><span style="width:8px; height:8px; border-radius:50%; background:#FBBF24;"></span> 31 - 60 Days</span>
                    <span style="display:flex; align-items:center; gap:4px;"><span style="width:8px; height:8px; border-radius:50%; background:#F97316;"></span> 61 - 90 Days</span>
                    <span style="display:flex; align-items:center; gap:4px;"><span style="width:8px; height:8px; border-radius:50%; background:#EF4444;"></span> > 90 Days</span>
                </div>
                <div style="height:24px; border-radius:4px; display:flex; overflow:hidden; margin-bottom:12px;">
                    <div style="width:55%; background:#10B981; display:flex; align-items:center; justify-content:center; color:white; font-size:11px; font-weight:600;">55%</div>
                    <div style="width:20%; background:#FBBF24; display:flex; align-items:center; justify-content:center; color:white; font-size:11px; font-weight:600;">20%</div>
                    <div style="width:15%; background:#F97316; display:flex; align-items:center; justify-content:center; color:white; font-size:11px; font-weight:600;">15%</div>
                    <div style="width:10%; background:#EF4444; display:flex; align-items:center; justify-content:center; color:white; font-size:11px; font-weight:600;">10%</div>
                </div>
                <div style="display:flex; justify-content:space-between; border-top:1px solid var(--border-color); padding-top:12px;">
                    <div>
                        <div style="font-size:11px; color:var(--text-sub); margin-bottom:2px;">Total Outstanding</div>
                        <div style="font-size:14px; font-weight:600; color:var(--text-main);">&#8377; 15,94,750</div>
                    </div>
                    <div style="text-align:right">
                        <div style="font-size:11px; color:var(--text-sub); margin-bottom:2px;">Overdue Amount</div>
                        <div style="font-size:14px; font-weight:600; color:var(--danger);">&#8377; 2,39,450 <span style="font-weight:normal">(25%)</span></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
    // Inject backend data into JS
    var plgDataJson = ${not empty plgJson ? plgJson : '[]'};

    // Profit & Loss Trend (Line Chart)
    var plChartInstance = new Chart(document.getElementById('plChart'), {
        type: 'line',
        data: {
            labels: plgDataJson.length > 0 ? plgDataJson.map(function(d){return d.month;}) : ['01 May','06 May','11 May','16 May','21 May','26 May','31 May'],
            datasets: [
                {
                    label: 'Profit (\u20B9)',
                    data: plgDataJson.length > 0 ? plgDataJson.map(function(d){return d.revenue/100000;}) : [0, 10, 20, 10, 15, 10, 25],
                    borderColor: '#10B981',
                    backgroundColor: 'rgba(16, 185, 129, 0.1)',
                    borderWidth: 2,
                    tension: 0.4,
                    fill: true,
                    pointRadius: 0
                },
                {
                    label: 'Loss (\u20B9)',
                    data: plgDataJson.length > 0 ? plgDataJson.map(function(d){return -Math.round(d.cost/1000);}) : [0, -5, -5, -25, -10, -15, -5],
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

    // Top Loss Reasons (Doughnut)
    new Chart(document.getElementById('lossChart'), {
        type: 'doughnut',
        data: {
            labels: ['Delay', 'Traffic in Sea', 'Weather', 'Dock Allocation', 'Regulatory Hold', 'Ship Issue', 'War / Disruption'],
            datasets: [{
                data: [215600, 178500, 132000, 115300, 96800, 58900, 47100],
                backgroundColor: ['#EF4444', '#F97316', '#F59E0B', '#10B981', '#3B82F6', '#6366F1', '#8B5CF6'],
                borderWidth: 0,
                cutout: '70%'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'right', labels: { usePointStyle: true, padding: 12, boxWidth: 6, font: {size:10},
                    generateLabels: function(chart) {
                        const data = chart.data;
                        if (data.labels.length && data.datasets.length) {
                            return data.labels.map((label, i) => {
                                const val = data.datasets[0].data[i];
                                const total = data.datasets[0].data.reduce((a, b) => a + b, 0);
                                const percent = ((val / total) * 100).toFixed(1) + '%';
                                const formattedVal = '\u20B9 ' + val.toLocaleString('en-IN');
                                return {
                                    text: label + '           ' + formattedVal + ' (' + percent + ')',
                                    fillStyle: data.datasets[0].backgroundColor[i],
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

                ctx.font = "500 12px Inter, sans-serif";
                ctx.textBaseline = "middle";
                ctx.textAlign = "center";
                ctx.fillStyle = "#6B7280";
                ctx.fillText("Total Loss", centerX, centerY - 10);
                
                ctx.font = "700 16px Inter, sans-serif";
                ctx.fillStyle = "#111827";
                ctx.fillText("\u20B9 8,45,200", centerX, centerY + 10);
                ctx.save();
            }
        }]
    });

    // Container Utilization (Gauge / Half Doughnut)
    const utilPct = parseFloat('${not empty utilizationPct ? utilizationPct : "76.4"}') || 76.4;
    new Chart(document.getElementById('utilizationChart'), {
        type: 'doughnut',
        data: {
            datasets: [{
                data: [utilPct, 100 - utilPct],
                backgroundColor: ['#F97316', '#F3F4F6'],
                borderWidth: 0,
                circumference: 180,
                rotation: 270,
                cutout: '80%'
            }]
        },
        options: {
            responsive: false,
            animation: false,
            plugins: { legend: { display: false }, tooltip: { enabled: false } },
            layout: { padding: 0 }
        }
    });

    // Stock Valuation (Line)
    new Chart(document.getElementById('stockChart'), {
        type: 'line',
        data: {
            labels: ['01 May', '05', '11 May', '15', '21 May', '25', '31 May'],
            datasets: [{
                data: [12, 18, 22, 28, 35, 42, 45],
                borderColor: '#10B981',
                backgroundColor: 'rgba(16, 185, 129, 0.1)',
                borderWidth: 2,
                tension: 0.1,
                fill: true,
                pointRadius: 0
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: { ticks: { callback: function(val) { return '\u20B9 ' + val + 'L'; }, font: {size:10} }, grid: { color: '#F3F4F6' }, border: { display: false }, min: 0, max: 50 },
                x: { grid: { display: false }, ticks: { font: {size:10} }, border: { display: false } }
            }
        }
    });

    // ABC Classification Summary (Doughnut)
    new Chart(document.getElementById('abcChart'), {
        type: 'doughnut',
        data: {
            labels: ['A - High Value', 'B - Medium Value', 'C - Low Value'],
            datasets: [{
                data: [212, 415, 620],
                backgroundColor: ['#10B981', '#F59E0B', '#EF4444'],
                borderWidth: 0,
                cutout: '75%'
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: {
                legend: { position: 'right', labels: { usePointStyle: true, padding: 16, boxWidth: 8, font: {size:11},
                    generateLabels: function(chart) {
                        const data = chart.data;
                        return data.labels.map((label, i) => {
                            const val = data.datasets[0].data[i];
                            const total = 1247;
                            const percent = ((val / total) * 100).toFixed(1) + '%';
                            return {
                                text: label + ' (' + percent + ')',
                                fillStyle: data.datasets[0].backgroundColor[i],
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

                ctx.font = "500 11px Inter, sans-serif";
                ctx.textBaseline = "middle";
                ctx.textAlign = "center";
                ctx.fillStyle = "#6B7280";
                ctx.fillText("Total Items", centerX, centerY - 10);
                
                ctx.font = "700 18px Inter, sans-serif";
                ctx.fillStyle = "#111827";
                ctx.fillText("1,247", centerX, centerY + 10);
                ctx.save();
            }
        }]
    });

    // Demand Forecast (Bar)
    new Chart(document.getElementById('demandChart'), {
        type: 'bar',
        data: {
            labels: ['Dec 2024', 'Jan 2025', 'Feb 2025', 'Mar 2025', 'Apr 2025', 'May 2025', 'Jun 2025', 'Jul 2025'],
            datasets: [
                {
                    label: 'Historical Demand',
                    data: [1400, 1500, 1300, 1600, 1550, null, null, null],
                    backgroundColor: '#9CA3AF',
                    barThickness: 32,
                    borderRadius: 2
                },
                {
                    label: 'Forecasted Demand',
                    data: [null, null, null, null, null, 1700, 1650, 1800],
                    backgroundColor: 'rgba(249, 115, 22, 0.1)',
                    borderColor: '#F97316',
                    borderWidth: {top: 2, right: 2, bottom: 2, left: 2},
                    borderSkipped: false,
                    barThickness: 32,
                    borderRadius: 2,
                    borderDash: [4, 4]
                }
            ]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { position: 'top', align: 'start', labels: { usePointStyle: true, boxWidth: 8, font: {size: 11} } } },
            scales: {
                y: { ticks: { callback: function(val) { return val >= 1000 ? (val/1000) + 'K' : val; }, font: {size:10} }, grid: { color: '#F3F4F6' }, border: { display: false }, min: 0, max: 2000 },
                x: { stacked: true, grid: { display: false }, ticks: { font: {size:10} }, border: { display: false } }
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

        var periodDatasets = {
            day:     { labels: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'],
                       profit: [4,8,12,6,10,5,9], loss: [-2,-4,-3,-8,-3,-2,-5] },
            week:    { labels: ['Wk 1','Wk 2','Wk 3','Wk 4'],
                       profit: [22,18,30,25], loss: [-10,-8,-15,-12] },
            month:   { labels: safeJson.length > 0 ? safeJson.map(function(d){return d.month;}) : ['May 2025'],
                       profit: safeJson.length > 0 ? safeJson.map(function(d){return Math.round(d.revenue/1000);}) : [10],
                       loss:   safeJson.length > 0 ? safeJson.map(function(d){return -Math.round(d.cost/1000);}) : [-5] },
            quarter: { labels: ['Q1 2025','Q2 2025','Q3 2025','Q4 2025'],
                       profit: [65,80,72,90], loss: [-30,-25,-35,-20] },
            year:    { labels: ['2022','2023','2024','2025'],
                       profit: [180,220,260,290], loss: [-90,-80,-100,-75] }
        };

        var d = periodDatasets[period] || periodDatasets['month'];
        chart.data.labels = d.labels;
        chart.data.datasets[0].data = d.profit;
        chart.data.datasets[1].data = d.loss;
        chart.update();
    }

</script>
</body>
</html>
