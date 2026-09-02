<%@ page language="java" contentType="text/html; charset=UTF-8" session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<!-- Chart.js CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
    :root {
        --purple-brand: #8b5cf6;
        --orange-brand: #FC8019;
        --green-brand: #10b981;
        --red-brand: #ef4444;
        --blue-brand: #3b82f6;
        --border-color: #E5E7EB;
        --bg-surface: #FFFFFF;
        --text-main: #111827;
        --text-sub: #6B7280;
    }

    body {
        background-color: #F9FAFB;
    }

    .dashboard-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 24px;
    }

    .page-title {
        font-size: 24px;
        font-weight: 700;
        color: var(--text-main);
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .page-title i {
        font-size: 14px;
        color: var(--text-sub);
        font-weight: 400;
        cursor: help;
    }

    .breadcrumb {
        font-size: 13px;
        color: var(--text-sub);
        margin-top: 4px;
    }

    .breadcrumb span {
        color: var(--orange-brand);
    }

    .header-actions {
        display: flex;
        gap: 12px;
    }

    .btn-outline-custom {
        background: white;
        border: 1px solid var(--border-color);
        border-radius: 8px;
        padding: 8px 16px;
        font-size: 14px;
        font-weight: 500;
        color: var(--text-main);
        display: flex;
        align-items: center;
        gap: 8px;
        transition: all 0.2s;
    }

    .btn-outline-custom:hover {
        background: #F3F4F6;
    }

    .btn-icon {
        padding: 8px 12px;
    }

    /* Filter Bar */
    .filter-bar {
        background: var(--bg-surface);
        border: 1px solid var(--border-color);
        border-radius: 12px;
        padding: 16px 24px;
        display: flex;
        align-items: center;
        gap: 24px;
        margin-bottom: 24px;
    }

    .filter-group {
        flex: 1;
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    .filter-label {
        font-size: 12px;
        font-weight: 500;
        color: var(--text-sub);
    }

    .filter-input-wrap {
        display: flex;
        align-items: center;
        gap: 12px;
        border: 1px solid var(--border-color);
        border-radius: 8px;
        padding: 8px 12px;
        background: white;
    }

    .filter-input-wrap i {
        color: var(--text-sub);
        font-size: 14px;
    }

    .filter-input-wrap select, .filter-input-wrap input {
        border: none;
        outline: none;
        font-size: 14px;
        font-weight: 500;
        color: var(--text-main);
        width: 100%;
        background: transparent;
    }

    .btn-reset {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 14px;
        font-weight: 500;
        color: var(--text-main);
        background: white;
        border: 1px solid var(--border-color);
        border-radius: 8px;
        padding: 10px 20px;
        cursor: pointer;
        transition: all 0.2s;
        margin-top: 22px; /* align with inputs */
    }

    .btn-reset:hover {
        background: #F3F4F6;
    }

    /* KPI Cards */
    .kpi-row {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 24px;
        margin-bottom: 24px;
    }

    .kpi-card {
        background: var(--bg-surface);
        border: 1px solid var(--border-color);
        border-radius: 16px;
        padding: 24px;
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }

    .kpi-left {
        display: flex;
        gap: 16px;
    }

    .kpi-icon {
        width: 48px;
        height: 48px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        color: white;
        flex-shrink: 0;
    }

    .kpi-icon.purple { background: var(--purple-brand); }
    .kpi-icon.orange { background: var(--orange-brand); }
    .kpi-icon.green { background: var(--green-brand); }

    .kpi-title {
        font-size: 14px;
        font-weight: 600;
        color: var(--text-main);
        margin-bottom: 4px;
    }

    .kpi-subtitle {
        font-size: 12px;
        color: var(--text-sub);
        margin-bottom: 12px;
    }

    .kpi-value {
        font-size: 24px;
        font-weight: 700;
        color: var(--text-main);
        margin-bottom: 8px;
    }

    .kpi-trend {
        font-size: 13px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 4px;
    }
    .kpi-trend span { color: var(--text-sub); font-weight: 400; font-size: 12px;}

    .trend-up { color: var(--green-brand); }
    .trend-down { color: var(--red-brand); }

    .kpi-sparkline {
        width: 100px;
        height: 50px;
        align-self: center;
    }

    /* Charts Row */
    .charts-row {
        display: grid;
        grid-template-columns: 2fr 1fr;
        gap: 24px;
        margin-bottom: 24px;
    }

    .chart-card {
        background: var(--bg-surface);
        border: 1px solid var(--border-color);
        border-radius: 16px;
        padding: 24px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }

    .card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
    }

    .card-title {
        font-size: 16px;
        font-weight: 600;
        color: var(--text-main);
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .card-title i { font-size: 14px; color: var(--text-sub); font-weight: 400; cursor: help; }
    
    .card-subtitle {
        font-size: 12px;
        color: var(--text-sub);
        margin-top: 4px;
    }

    .toggle-group {
        display: flex;
        border: 1px solid var(--border-color);
        border-radius: 8px;
        overflow: hidden;
    }

    .toggle-btn {
        padding: 6px 12px;
        font-size: 12px;
        font-weight: 500;
        color: var(--text-sub);
        background: white;
        border: none;
        border-right: 1px solid var(--border-color);
        cursor: pointer;
    }
    .toggle-btn:last-child { border-right: none; }
    .toggle-btn.active { color: var(--orange-brand); background: #FFF7ED; }

    /* Custom Table */
    .table-container {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0 16px;
        margin-top: -16px; /* offset spacing */
    }

    .table-container th {
        font-size: 12px;
        font-weight: 500;
        color: var(--text-sub);
        text-align: left;
        padding: 0 24px 8px 24px;
        border-bottom: 1px solid var(--border-color);
    }

    .table-container td {
        background: var(--bg-surface);
        padding: 20px 24px;
        font-size: 14px;
        color: var(--text-main);
        font-weight: 500;
    }
    
    /* Simulate rounded rows */
    .table-container tr td:first-child { border-top-left-radius: 12px; border-bottom-left-radius: 12px; border-left: 1px solid var(--border-color); border-top: 1px solid var(--border-color); border-bottom: 1px solid var(--border-color); }
    .table-container tr td:last-child { border-top-right-radius: 12px; border-bottom-right-radius: 12px; border-right: 1px solid var(--border-color); border-top: 1px solid var(--border-color); border-bottom: 1px solid var(--border-color); }
    .table-container tr td:not(:first-child):not(:last-child) { border-top: 1px solid var(--border-color); border-bottom: 1px solid var(--border-color); }
    
    .table-container tr:hover td { background: #F9FAFB; cursor: pointer; }

    /* Progress Bar */
    .progress-bar-wrap {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    
    .progress-track {
        flex: 1;
        height: 6px;
        background: #F3F4F6;
        border-radius: 3px;
        overflow: hidden;
    }

    .progress-fill {
        height: 100%;
        border-radius: 3px;
    }

    .progress-fill.green { background: var(--green-brand); }
    .progress-fill.red { background: var(--red-brand); }

    .chart-legend {
        display: flex;
        flex-direction: column;
        gap: 12px;
        margin-top: 24px;
    }

    .legend-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        font-size: 12px;
        color: var(--text-main);
    }
    .legend-left { display: flex; align-items: center; gap: 8px; }
    .legend-dot { width: 8px; height: 8px; border-radius: 50%; }
    .legend-right { display: flex; gap: 16px; font-weight: 500;}
    .legend-pct { color: var(--text-sub); width: 40px; text-align: right;}

    .loss-total {
        text-align: center;
        margin-top: -120px;
        margin-bottom: 90px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        pointer-events: none;
    }
    .loss-total-label { font-size: 12px; font-weight: 500; color: var(--text-main); }
    .loss-total-val { font-size: 16px; font-weight: 700; color: var(--text-main); }

    .bottom-hint {
        font-size: 12px;
        color: var(--text-sub);
        display: flex;
        align-items: center;
        gap: 6px;
        padding-top: 16px;
        border-top: 1px solid var(--border-color);
        margin-top: 16px;
    }

</style>

<div class="main-content">
    <div class="dashboard-header">
        <div>
            <div class="page-title">Profit & Loss Analytics <i class="fa-solid fa-circle-info"></i></div>
            <div class="breadcrumb">Dashboard > Finance > <span>Profit & Loss</span></div>
        </div>
        <div class="header-actions">
            <button class="btn-outline-custom"><i class="fa-solid fa-download"></i> Export</button>
            <button class="btn-outline-custom btn-icon"><i class="fa-solid fa-ellipsis-vertical"></i></button>
        </div>
    </div>

    <!-- Filter Bar -->
    <div class="filter-bar">
        <div class="filter-group">
            <div class="filter-label">Company</div>
            <div class="filter-input-wrap">
                <i class="fa-regular fa-building"></i>
                <select class="form-select-custom">
                    <option>All Companies</option>
                </select>
            </div>
        </div>
        <div class="filter-group">
            <div class="filter-label">Route (Origin - Destination)</div>
            <div class="filter-input-wrap">
                <i class="fa-solid fa-route"></i>
                <select class="form-select-custom">
                    <option>All Routes</option>
                </select>
            </div>
        </div>
        <div class="filter-group">
            <div class="filter-label">Date Range</div>
            <div class="filter-input-wrap">
                <i class="fa-regular fa-calendar"></i>
                <input type="text" value="01 Apr 2025 - 31 May 2025" readonly>
            </div>
        </div>
        <button class="btn-reset"><i class="fa-solid fa-arrow-rotate-left"></i> Reset Filters</button>
    </div>

    <!-- KPI Cards -->
    <div class="kpi-row">
        <!-- Revenue -->
        <div class="kpi-card">
            <div class="kpi-left">
                <div class="kpi-icon purple"><i class="fa-solid fa-dollar-sign"></i></div>
                <div>
                    <div class="kpi-title">Total Revenue</div>
                    <div class="kpi-subtitle">Freight + Service Charges</div>
                    <div class="kpi-value">$ <fmt:formatNumber value="${kpi.totalRevenue}" type="number" maxFractionDigits="0"/></div>
                    <div class="kpi-trend trend-up"><i class="fa-solid fa-arrow-up"></i> Live Data</div>
                </div>
            </div>
            <div class="kpi-sparkline">
                <svg viewBox="0 0 100 50" preserveAspectRatio="none">
                    <path d="M 0 40 L 20 30 L 40 35 L 60 15 L 80 25 L 100 5" fill="none" stroke="var(--purple-brand)" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
                    <circle cx="100" cy="5" r="4" fill="white" stroke="var(--purple-brand)" stroke-width="2"/>
                </svg>
            </div>
        </div>
        <!-- Cost -->
        <div class="kpi-card">
            <div class="kpi-left">
                <div class="kpi-icon orange"><i class="fa-solid fa-wallet"></i></div>
                <div>
                    <div class="kpi-title">Total Cost</div>
                    <div class="kpi-subtitle">Fuel, Port, Customs, Penalties</div>
                    <div class="kpi-value">$ <fmt:formatNumber value="${kpi.totalCost}" type="number" maxFractionDigits="0"/></div>
                    <div class="kpi-trend trend-up" style="color: var(--orange-brand);"><i class="fa-solid fa-arrow-up"></i> Live Data</div>
                </div>
            </div>
            <div class="kpi-sparkline">
                <svg viewBox="0 0 100 50" preserveAspectRatio="none">
                    <path d="M 0 45 L 20 40 L 40 42 L 60 25 L 80 30 L 100 10" fill="none" stroke="var(--orange-brand)" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
                    <circle cx="100" cy="10" r="4" fill="white" stroke="var(--orange-brand)" stroke-width="2"/>
                </svg>
            </div>
        </div>
        <!-- Net Profit -->
        <div class="kpi-card">
            <div class="kpi-left">
                <div class="kpi-icon green"><i class="fa-solid fa-arrow-trend-up"></i></div>
                <div>
                    <div class="kpi-title">Net Profit / Loss</div>
                    <div class="kpi-subtitle">Revenue - Cost</div>
                    <div class="kpi-value" style="color: ${kpi.netProfitLoss >= 0 ? 'var(--green-brand)' : 'var(--red-brand)'};">
                        $ <fmt:formatNumber value="${kpi.netProfitLoss}" type="number" maxFractionDigits="0"/>
                    </div>
                    <div class="kpi-trend trend-up"><i class="fa-solid fa-arrow-up"></i> Live Data</div>
                </div>
            </div>
            <div class="kpi-sparkline">
                <svg viewBox="0 0 100 50" preserveAspectRatio="none">
                    <path d="M 0 35 L 20 25 L 40 30 L 60 10 L 80 15 L 100 5" fill="none" stroke="var(--green-brand)" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
                    <circle cx="100" cy="5" r="4" fill="white" stroke="var(--green-brand)" stroke-width="2"/>
                </svg>
            </div>
        </div>
    </div>

    <!-- Charts -->
    <div class="charts-row">
        <!-- Area Chart -->
        <div class="chart-card">
            <div class="card-header">
                <div>
                    <div class="card-title">Net Profit / Loss Trend <i class="fa-solid fa-circle-info"></i></div>
                    <div class="card-subtitle">All values in USD</div>
                </div>
                <div style="display: flex; gap: 12px; align-items: center;">
                    <div class="toggle-group">
                        <button class="toggle-btn active">Monthly</button>
                        <button class="toggle-btn">Quarterly</button>
                        <button class="toggle-btn">Yearly</button>
                    </div>
                    <button class="btn-outline-custom btn-icon"><i class="fa-solid fa-ellipsis-vertical"></i></button>
                </div>
            </div>
            <div style="height: 300px; position: relative;">
                <canvas id="trendChart"></canvas>
            </div>
        </div>

        <!-- Donut Chart -->
        <div class="chart-card">
            <div class="card-header">
                <div class="card-title">Loss Reason Breakdown <i class="fa-solid fa-circle-info"></i></div>
                <div class="toggle-group">
                    <button class="toggle-btn active">By Cost</button>
                    <button class="toggle-btn">By Shipments</button>
                </div>
            </div>
            <div style="display: flex; gap: 24px;">
                <div style="width: 180px; height: 180px; position: relative;">
                    <canvas id="donutChart"></canvas>
                    <div class="loss-total">
                        <div class="loss-total-label">Total Loss</div>
                        <div class="loss-total-val">$ 420,540</div>
                    </div>
                </div>
                <div class="chart-legend" style="flex: 1; margin-top: 0;">
                    <div class="legend-item">
                        <div class="legend-left"><div class="legend-dot" style="background: #FC8019;"></div> Traffic in Sea</div>
                        <div class="legend-right"><div>$120,450</div><div class="legend-pct">(28.6%)</div></div>
                    </div>
                    <div class="legend-item">
                        <div class="legend-left"><div class="legend-dot" style="background: #3B82F6;"></div> Weather</div>
                        <div class="legend-right"><div>$84,230</div><div class="legend-pct">(20.0%)</div></div>
                    </div>
                    <div class="legend-item">
                        <div class="legend-left"><div class="legend-dot" style="background: #8B5CF6;"></div> Delay</div>
                        <div class="legend-right"><div>$72,680</div><div class="legend-pct">(17.3%)</div></div>
                    </div>
                    <div class="legend-item">
                        <div class="legend-left"><div class="legend-dot" style="background: #EAB308;"></div> Dock Allocation</div>
                        <div class="legend-right"><div>$48,910</div><div class="legend-pct">(11.6%)</div></div>
                    </div>
                    <div class="legend-item">
                        <div class="legend-left"><div class="legend-dot" style="background: #06B6D4;"></div> Regulatory Hold</div>
                        <div class="legend-right"><div>$36,420</div><div class="legend-pct">(8.7%)</div></div>
                    </div>
                    <div class="legend-item">
                        <div class="legend-left"><div class="legend-dot" style="background: #EC4899;"></div> War / Disruption</div>
                        <div class="legend-right"><div>$24,300</div><div class="legend-pct">(5.8%)</div></div>
                    </div>
                    <div class="legend-item">
                        <div class="legend-left"><div class="legend-dot" style="background: #EF4444;"></div> Ship Issue</div>
                        <div class="legend-right"><div>$18,220</div><div class="legend-pct">(4.3%)</div></div>
                    </div>
                    <div class="legend-item">
                        <div class="legend-left"><div class="legend-dot" style="background: #78716C;"></div> Damaged Product</div>
                        <div class="legend-right"><div>$15,330</div><div class="legend-pct">(3.7%)</div></div>
                    </div>
                </div>
            </div>
            <div class="bottom-hint">
                <i class="fa-solid fa-arrow-pointer"></i> Click on any segment to view affected shipments
            </div>
        </div>
    </div>

    <!-- Table Section -->
    <div class="chart-card">
        <div class="card-header" style="margin-bottom: 32px;">
            <div class="card-title">Profit & Loss Summary <i class="fa-solid fa-circle-info"></i></div>
            <div style="display: flex; gap: 12px;">
                <button class="btn-outline-custom"><i class="fa-solid fa-download"></i> Export</button>
                <button class="btn-outline-custom btn-icon"><i class="fa-solid fa-ellipsis-vertical"></i></button>
            </div>
        </div>

        <table class="table-container">
            <thead>
                <tr>
                    <th>Company</th>
                    <th>Total Revenue<br><span style="font-size: 11px; font-weight: 400;">Freight + Service</span></th>
                    <th>Total Cost<br><span style="font-size: 11px; font-weight: 400;">All Costs</span></th>
                    <th>Net Profit / Loss</th>
                    <th style="width: 150px;">Profit Margin</th>
                    <th>vs Previous Period</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td style="font-weight: 600;">Global Freight Ltd.</td>
                    <td>$ 1,245,600</td>
                    <td>$ 892,300</td>
                    <td style="color: var(--green-brand); font-weight: 600;">$ 353,300</td>
                    <td>
                        <div class="progress-bar-wrap">
                            <span style="font-size: 13px;">28.4%</span>
                            <div class="progress-track"><div class="progress-fill green" style="width: 70%;"></div></div>
                        </div>
                    </td>
                    <td class="trend-up"><i class="fa-solid fa-arrow-up"></i> 21.8%</td>
                    <td style="color: var(--text-sub); text-align: right;"><i class="fa-solid fa-chevron-right"></i></td>
                </tr>
                <tr>
                    <td style="font-weight: 600;">Oceanic Shipping Co.</td>
                    <td>$ 785,450</td>
                    <td>$ 612,120</td>
                    <td style="color: var(--green-brand); font-weight: 600;">$ 173,330</td>
                    <td>
                        <div class="progress-bar-wrap">
                            <span style="font-size: 13px;">22.1%</span>
                            <div class="progress-track"><div class="progress-fill green" style="width: 55%;"></div></div>
                        </div>
                    </td>
                    <td class="trend-up"><i class="fa-solid fa-arrow-up"></i> 16.3%</td>
                    <td style="color: var(--text-sub); text-align: right;"><i class="fa-solid fa-chevron-right"></i></td>
                </tr>
                <tr>
                    <td style="font-weight: 600;">Blue Horizon Logistics</td>
                    <td>$ 419,750</td>
                    <td>$ 535,000</td>
                    <td style="color: var(--red-brand); font-weight: 600;">-$ 115,250</td>
                    <td>
                        <div class="progress-bar-wrap">
                            <span style="font-size: 13px;">-27.5%</span>
                            <div class="progress-track"><div class="progress-fill red" style="width: 65%;"></div></div>
                        </div>
                    </td>
                    <td class="trend-down"><i class="fa-solid fa-arrow-down"></i> 8.7%</td>
                    <td style="color: var(--text-sub); text-align: right;"><i class="fa-solid fa-chevron-right"></i></td>
                </tr>
                <tr>
                    <td style="font-weight: 600;">Swift Marine Lines</td>
                    <td>$ 312,800</td>
                    <td>$ 245,600</td>
                    <td style="color: var(--green-brand); font-weight: 600;">$ 67,200</td>
                    <td>
                        <div class="progress-bar-wrap">
                            <span style="font-size: 13px;">21.5%</span>
                            <div class="progress-track"><div class="progress-fill green" style="width: 50%;"></div></div>
                        </div>
                    </td>
                    <td class="trend-up"><i class="fa-solid fa-arrow-up"></i> 9.4%</td>
                    <td style="color: var(--text-sub); text-align: right;"><i class="fa-solid fa-chevron-right"></i></td>
                </tr>
            </tbody>
        </table>
    </div>

</div>

<script>
  document.addEventListener("DOMContentLoaded", function() {
      
      const trendDataRaw = [
          <c:forEach var="t" items="${monthlyTrend}" varStatus="status">
              { label: '${t.monthYear}', value: ${t.profitLossAmount} }
          </c:forEach>
      ];
      
      const donutDataRaw = [
          <c:forEach var="d" items="${lossBreakdown}" varStatus="status">
              { label: '${d.reasonName}', value: ${d.totalImpact} }
          </c:forEach>
      ];

      // If no data, provide fallback
      if (trendDataRaw.length === 0) {
          trendDataRaw.push({label: 'No Data', value: 0});
      }

      // Trend Chart Initialization
      const ctxTrend = document.getElementById('trendChart').getContext('2d');
      
      // Create gradient for positive profit
      let gradientGreen = ctxTrend.createLinearGradient(0, 0, 0, 300);
      gradientGreen.addColorStop(0, 'rgba(16, 185, 129, 0.4)');
      gradientGreen.addColorStop(1, 'rgba(16, 185, 129, 0.0)');
      
      let gradientRed = ctxTrend.createLinearGradient(0, 0, 0, 300);
      gradientRed.addColorStop(0, 'rgba(239, 68, 68, 0.0)');
      gradientRed.addColorStop(1, 'rgba(239, 68, 68, 0.4)');
      
      // Map data
      const tLabels = trendDataRaw.map(d => d.label);
      const profitData = trendDataRaw.map((d, i) => {
          if (d.value >= 0) return d.value;
          // Connecting line logic for smooth visual
          if (i > 0 && trendDataRaw[i-1].value >= 0) return d.value; 
          return null;
      });
      const lossData = trendDataRaw.map((d, i) => {
          if (d.value < 0) return d.value;
          if (i > 0 && trendDataRaw[i-1].value < 0) return d.value;
          return null;
      });

      const trendChart = new Chart(ctxTrend, {
          type: 'line',
          data: {
              labels: tLabels,
              datasets: [{
                  label: 'Profit',
                  data: profitData,
                  borderColor: '#10b981',
                  backgroundColor: gradientGreen,
                  borderWidth: 2,
                  pointBackgroundColor: '#10b981',
                  pointBorderColor: '#fff',
                  pointBorderWidth: 2,
                  pointRadius: 6,
                  fill: true,
                  tension: 0.4
              },
              {
                  label: 'Loss',
                  data: lossData,
                  borderColor: '#ef4444',
                  backgroundColor: gradientRed,
                  borderWidth: 2,
                  pointBackgroundColor: '#ef4444',
                  pointBorderColor: '#fff',
                  pointBorderWidth: 2,
                  pointRadius: 6,
                  fill: true,
                  tension: 0.4
              }]
          },
          options: {
              responsive: true,
              maintainAspectRatio: false,
              plugins: {
                  legend: { display: false },
                  tooltip: { backgroundColor: '#111827', padding: 12 }
              },
              scales: {
                  y: {
                      beginAtZero: true,
                      grid: { color: '#F3F4F6', drawBorder: false },
                      ticks: { color: '#9CA3AF', font: { size: 11 }, callback: function(value) {
                          if (value >= 1000) return (value / 1000) + 'K';
                          if (value <= -1000) return (value / 1000) + 'K';
                          return value;
                      }}
                  },
                  x: {
                      grid: { display: false, drawBorder: false },
                      ticks: { color: '#9CA3AF', font: { size: 11 } }
                  }
              }
          }
      });
  
      // Donut Chart Initialization
      const ctxDonut = document.getElementById('donutChart').getContext('2d');
      const dLabels = donutDataRaw.map(d => d.label);
      const dVals = donutDataRaw.map(d => d.value);
      
      const donutChart = new Chart(ctxDonut, {
          type: 'doughnut',
          data: {
              labels: dLabels.length > 0 ? dLabels : ['No Data'],
              datasets: [{
                  data: dVals.length > 0 ? dVals : [1],
                  backgroundColor: ['#FC8019', '#3B82F6', '#8B5CF6', '#EAB308', '#06B6D4', '#EC4899', '#EF4444'],
                  borderWidth: 0,
                  hoverOffset: 4
              }]
          },
          options: {
              responsive: true,
              maintainAspectRatio: false,
              cutout: '70%',
              plugins: {
                  legend: { display: false },
                  tooltip: {
                      backgroundColor: '#111827',
                      padding: 10,
                      callbacks: {
                          label: function(context) {
                              let label = context.label || '';
                              if (label) {
                                  label += ': ';
                              }
                              if (context.parsed !== null) {
                                  label += new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }).format(context.parsed);
                              }
                              return label;
                          }
                      }
                  }
              }
          }
      });
  });
</script>
<jsp:include page="/jsp/layout/footer.jsp" />
