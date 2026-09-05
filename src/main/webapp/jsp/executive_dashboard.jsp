<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* ==========================================================================
       EXECUTIVE ANALYTICS DASHBOARD THEME (SWIGGY ORANGE ENTERPRISE)
       ========================================================================== */
    .exec-page-container { padding: 0 4px 40px; }

    .custom-breadcrumb { display: flex; align-items: center; gap: 8px; font-size: 13px; color: #64748B; margin-bottom: 16px; }
    .custom-breadcrumb a { color: #64748B; text-decoration: none; transition: color 0.15s ease; }
    .custom-breadcrumb a:hover { color: #FC8019; }
    .custom-breadcrumb i { font-size: 11px; color: #94A3B8; }
    .custom-breadcrumb .current { color: #FC8019; font-weight: 600; }

    .exec-page-header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; flex-wrap: wrap; gap: 16px; }
    .exec-page-title { font-weight: 700; color: #0F172A; margin-bottom: 4px; font-size: 24px; letter-spacing: -0.3px; }
    .exec-page-subtitle { color: #64748B; margin-bottom: 0; font-size: 13.5px; }

    /* KPI Grid (reuses global .kpi-card / .kpi-icon-wrap / .kpi-label / .kpi-val from header.jsp) */
    .kpi-grid-exec { display: grid; grid-template-columns: repeat(4, 1fr); gap: 18px; margin-bottom: 24px; }
    @media (max-width: 1200px) { .kpi-grid-exec { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 640px) { .kpi-grid-exec { grid-template-columns: 1fr; } }

    .kpi-val.danger-val { color: #DC2626 !important; }

    /* Section / Card Titles */
    .section-card-title {
        font-size: 15px; font-weight: 700; color: #0F172A; margin: 0;
        display: flex; align-items: center; gap: 8px; letter-spacing: -0.1px;
    }
    .section-card-title i { color: #FC8019; font-size: 16px; }
    .section-card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; flex-wrap: wrap; gap: 10px; }

    /* Themed Pill Badges (replace bootstrap bg-* badges) */
    .badge-nl { display: inline-flex; align-items: center; gap: 5px; padding: 4px 11px; border-radius: 50px; font-size: 11.5px; font-weight: 700; white-space: nowrap; }
    .badge-nl-success { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }
    .badge-nl-danger  { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }
    .badge-nl-warning { background: #FFFBEB; color: #D97706; border: 1px solid #FDE68A; }
    .badge-nl-info    { background: #EFF6FF; color: #2563EB; border: 1px solid #BFDBFE; }
    .badge-nl-slate   { background: #F1F5F9; color: #475569; border: 1px solid #E2E8F0; }
    .badge-nl-orange  { background: #FFF2EB; color: #FC8019; border: 1px solid #FFD4C2; }

    /* Utilization metric row */
    .util-metric-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; font-size: 13.5px; color: #475569; }
    .util-metric-row b { color: #0F172A; }

    /* Table card polish */
    .exec-table-card .table { font-size: 13.5px; }
    .exec-table-card .table-responsive { border-radius: 10px; overflow: hidden; }
    .profit-positive { color: #059669 !important; font-weight: 600; }
    .profit-negative { color: #DC2626 !important; font-weight: 600; }

    /* ===== Filter Bar (FR6.2 - Company / Route / Category / Date Range) ===== */
    .filters-bar-wrap { margin-bottom: 20px; }
    .filters-bar-inner {
        display: flex; align-items: center; justify-content: space-between;
        background: #fff; border: 1px solid #E2E8F0; border-radius: 12px;
        padding: 0 6px 0 0; overflow: hidden; box-shadow: 0 1px 4px rgba(0,0,0,0.04); flex-wrap: wrap;
    }
    .filters-left { display: flex; align-items: center; flex: 1; overflow: hidden; flex-wrap: wrap; }
    .filter-field { padding: 10px 18px; min-width: 0; flex: 1; cursor: pointer; }
    .filter-field-label {
        font-size: 11px; font-weight: 600; color: #64748B; text-transform: uppercase;
        letter-spacing: 0.5px; margin-bottom: 4px; display: flex; align-items: center; gap: 5px; white-space: nowrap;
    }
    .filter-field-label i { font-size: 11px; color: #FC8019; }
    .filter-select-custom { width: 100%; border: none; outline: none; background: transparent; font-size: 13px; font-weight: 500; color: #0F172A; cursor: pointer; appearance: none; -webkit-appearance: none; padding: 0; }
    .filter-divider { width: 1px; height: 36px; background: #E2E8F0; flex-shrink: 0; }
    .filters-right { display: flex; align-items: center; gap: 6px; padding: 6px 12px; border-left: 1px solid #E2E8F0; margin-left: 6px; flex-shrink: 0; }
    .filter-btn-reset, .filter-btn-apply {
        display: inline-flex; align-items: center; gap: 5px; padding: 8px 14px; border-radius: 8px;
        font-size: 13px; font-weight: 500; cursor: pointer; border: none; text-decoration: none; transition: all 0.18s; white-space: nowrap;
    }
    .filter-btn-reset { background: #F1F5F9; color: #64748B; }
    .filter-btn-reset:hover { background: #E2E8F0; color: #0F172A; }
    .filter-btn-apply { background: #FC8019; color: #fff; }
    .filter-btn-apply:hover { background: #E67312; }
    .filter-field:hover { background: #FAFAFA; }
    .filter-date-range-wrap { display: flex; align-items: center; gap: 4px; }
    .filter-date-input { border: none; outline: none; background: transparent; font-size: 12px; font-weight: 500; color: #0F172A; width: 110px; cursor: pointer; padding: 0; }
    .date-sep { color: #64748B; font-size: 12px; flex-shrink: 0; }
</style>

<div class="exec-page-container">

    <!-- Breadcrumb -->
    <div class="custom-breadcrumb">
        <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <i class="ti ti-chevron-right"></i>
        <span class="current">Executive Analytics</span>
    </div>

    <div class="exec-page-header">
        <div>
            <h2 class="exec-page-title">Executive Analytics Dashboard</h2>
            <p class="exec-page-subtitle">Module 6 &mdash; Consolidated financial, operational &amp; inventory intelligence</p>
        </div>
    </div>

    <!-- Filter Bar (FR6.2 - Company / Route / Category / Date Range) -->
    <form action="${pageContext.request.contextPath}/dashboard/executive" method="GET" class="filters-bar-wrap">
        <div class="filters-bar-inner">
            <div class="filters-left">
                <div class="filter-field" style="min-width:200px;">
                    <div class="filter-field-label"><i class="ti ti-calendar"></i> Date Range</div>
                    <div class="filter-date-range-wrap">
                        <input type="date" name="dateFrom" class="filter-date-input" value="${not empty filterDateFrom ? filterDateFrom : ''}">
                        <span class="date-sep">&#x2014;</span>
                        <input type="date" name="dateTo" class="filter-date-input" value="${not empty filterDateTo ? filterDateTo : ''}">
                    </div>
                </div>
                <div class="filter-divider"></div>
                <div class="filter-field">
                    <div class="filter-field-label"><i class="ti ti-building"></i> Company</div>
                    <select class="filter-select-custom" name="company">
                        <option value="">All Companies</option>
                        <c:forEach var="co" items="${companies}">
                            <option value="${co[0]}" <c:if test="${filterCompany == co[0]}">selected</c:if>>${co[1]}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="filter-divider"></div>
                <div class="filter-field">
                    <div class="filter-field-label"><i class="ti ti-route"></i> Route</div>
                    <select class="filter-select-custom" name="route">
                        <option value="">All Routes</option>
                        <c:forEach var="rt" items="${routes}">
                            <option value="${rt[0]}" <c:if test="${filterRoute == rt[0]}">selected</c:if>>${rt[1]}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="filter-divider"></div>
                <div class="filter-field">
                    <div class="filter-field-label"><i class="ti ti-tags"></i> Category</div>
                    <select class="filter-select-custom" name="category">
                        <option value="">All Categories</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat}" <c:if test="${filterCategory == cat}">selected</c:if>>${cat}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            <div class="filters-right">
                <a href="${pageContext.request.contextPath}/dashboard/executive" class="filter-btn-reset" title="Reset Filters">
                    <i class="ti ti-refresh"></i><span>Reset</span>
                </a>
                <button type="submit" class="filter-btn-apply">
                    <i class="ti ti-search"></i><span>Apply</span>
                </button>
            </div>
        </div>
    </form>

    <!-- KPI Row -->
    <div class="kpi-grid-exec">
        <div class="kpi-card">
            <div class="kpi-icon-wrap orange"><i class="ti ti-currency-dollar"></i></div>
            <div>
                <div class="kpi-label">Total Revenue</div>
                <div class="kpi-val">$${summary.totalRevenue}</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon-wrap green"><i class="ti ti-trending-up"></i></div>
            <div>
                <div class="kpi-label">Net Profit</div>
                <div class="kpi-val">$${summary.netProfit}</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon-wrap blue"><i class="ti ti-truck"></i></div>
            <div>
                <div class="kpi-label">Active Shipments</div>
                <div class="kpi-val">${summary.activeShipments}</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon-wrap red"><i class="ti ti-alert-triangle"></i></div>
            <div>
                <div class="kpi-label">Overdue Invoices</div>
                <div class="kpi-val danger-val">${summary.overdueInvoices} ($${summary.overdueReceivables})</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon-wrap green"><i class="ti ti-percentage"></i></div>
            <div>
                <div class="kpi-label">Gross Profit Margin</div>
                <div class="kpi-val"><fmt:formatNumber value="${grossMarginPct}" maxFractionDigits="1"/>%</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon-wrap yellow"><i class="ti ti-clock-check"></i></div>
            <div>
                <div class="kpi-label">On-Time Delivery</div>
                <div class="kpi-val"><fmt:formatNumber value="${onTimeDeliveryPct}" maxFractionDigits="1"/>%</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon-wrap orange"><i class="ti ti-building-warehouse"></i></div>
            <div>
                <div class="kpi-label">Total Inventory Value</div>
                <div class="kpi-val">$${totalInventoryValue}</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon-wrap blue"><i class="ti ti-refresh"></i></div>
            <div>
                <div class="kpi-label">Inventory Turnover Ratio</div>
                <div class="kpi-val">${turnoverRatio}</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon-wrap red"><i class="ti ti-file-alert"></i></div>
            <div>
                <div class="kpi-label">Pending Claims</div>
                <div class="kpi-val danger-val">${pendingClaimsCount}</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon-wrap green"><i class="ti ti-map-pin"></i></div>
            <div>
                <div class="kpi-label">Top Trade Route</div>
                <div class="kpi-val" style="font-size:16px;">${topRoute.routeName}</div>
            </div>
        </div>
    </div>

    <!-- Charts Row -->
    <div class="row g-4 mb-2">
        <div class="col-md-4">
            <div class="chart-card p-3 h-100">
                <div class="section-card-header">
                    <h3 class="section-card-title"><i class="ti ti-chart-pie-2"></i> ABC Classification (Pareto)</h3>
                </div>
                <div style="position: relative; height: 300px; width: 100%;">
                    <canvas id="abcChart"></canvas>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="chart-card p-3 h-100">
                <div class="section-card-header">
                    <h3 class="section-card-title"><i class="ti ti-alert-circle"></i> Top Loss Reasons</h3>
                </div>
                <div style="position: relative; height: 300px; width: 100%;">
                    <canvas id="lossChart"></canvas>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="chart-card p-3 h-100">
                <div class="section-card-header">
                    <h3 class="section-card-title"><i class="ti ti-box"></i> Container Utilization</h3>
                </div>
                <div class="util-metric-row">
                    <span>Total: <b>${utilization.totalContainers}</b></span>
                    <span class="badge-nl badge-nl-success"><i class="ti ti-gauge"></i> Utilization: ${utilization.utilizationRatePct}%</span>
                </div>
                <div style="position: relative; height: 260px; width: 100%;">
                    <canvas id="containerChart"></canvas>
                </div>
            </div>
        </div>
    </div>

    <!-- Tables Row -->
    <div class="row g-4 mb-2">
        <div class="col-md-6">
            <div class="chart-card exec-table-card p-3 h-100">
                <div class="section-card-header">
                    <h3 class="section-card-title"><i class="ti ti-users"></i> Customer Profitability Analysis</h3>
                </div>
                <div class="table-responsive">
                    <table class="table table-sm table-hover">
                        <thead>
                            <tr>
                                <th>Customer</th>
                                <th>Revenue</th>
                                <th>Cost</th>
                                <th>Net Profit</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="cp" items="${customerProfitabilities}">
                                <tr>
                                    <td>${cp.customerName}</td>
                                    <td>$${cp.totalRevenue}</td>
                                    <td>$${cp.totalCost}</td>
                                    <td class="${cp.netProfit >= 0 ? 'profit-positive' : 'profit-negative'}">$${cp.netProfit}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="chart-card exec-table-card p-3 h-100">
                <div class="section-card-header">
                    <h3 class="section-card-title"><i class="ti ti-building-warehouse"></i> Stock Valuation</h3>
                </div>
                <div class="util-metric-row">
                    <span>Avg Inventory Turnover Ratio: <b>${turnover.avgTurnoverRatio}</b></span>
                    <span>Avg Days in Inventory: <b>${turnover.avgDaysInInventory}</b></span>
                </div>
                <div class="table-responsive">
                    <table class="table table-sm table-hover">
                        <thead>
                            <tr>
                                <th>Product</th>
                                <th>Category</th>
                                <th>Qty on Hand</th>
                                <th>Total Value</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="sv" items="${stockValuations}">
                                <tr>
                                    <td>${sv.productName}</td>
                                    <td>${sv.category}</td>
                                    <td>${sv.totalQuantityOnHand}</td>
                                    <td>$${sv.totalInventoryValuation}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Additional Tables Row -->
    <div class="row g-4 mt-0">
        <div class="col-md-6">
            <div class="chart-card exec-table-card p-3 h-100">
                <div class="section-card-header">
                    <h3 class="section-card-title"><i class="ti ti-truck-delivery"></i> Active Shipments</h3>
                </div>
                <div class="table-responsive">
                    <table class="table table-sm table-hover">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Customer</th>
                                <th>Route</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="as" items="${activeShipments}">
                                <tr>
                                    <td>#${as.shipmentId}</td>
                                    <td>${as.customerName}</td>
                                    <td>${as.originPort} &rarr; ${as.destinationPort}</td>
                                    <td><span class="badge-nl badge-nl-info"><i class="ti ti-ship"></i> ${as.status}</span></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="chart-card exec-table-card p-3 h-100">
                <div class="section-card-header">
                    <h3 class="section-card-title"><i class="ti ti-chart-arrows"></i> Demand Forecast</h3>
                </div>
                <div class="table-responsive">
                    <table class="table table-sm table-hover">
                        <thead>
                            <tr>
                                <th>Period</th>
                                <th>Container Type</th>
                                <th>Forecasted Demand</th>
                                <th>Forecasted Price</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="df" items="${demandForecast}">
                                <tr>
                                    <td>${df.forecastPeriod}</td>
                                    <td>${df.containerType}</td>
                                    <td>${df.forecastedDemand}</td>
                                    <td>$${df.forecastedPrice}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="chart-card exec-table-card p-3 h-100">
                <div class="section-card-header">
                    <h3 class="section-card-title"><i class="ti ti-chart-line"></i> Sales Trend Analysis</h3>
                </div>
                <div class="table-responsive">
                    <table class="table table-sm table-hover">
                        <thead>
                            <tr>
                                <th>Product ID</th>
                                <th>Actual Sales</th>
                                <th>Moving Avg</th>
                                <th>Trend</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="st" items="${salesTrends}">
                                <tr>
                                    <td>${st.productId}</td>
                                    <td>${st.actualSales}</td>
                                    <td>${st.movingAvg}</td>
                                    <td>
                                        <c:if test="${st.trendLabel == 'Growing'}"><span class="badge-nl badge-nl-success"><i class="ti ti-arrow-up-right"></i> Growing</span></c:if>
                                        <c:if test="${st.trendLabel == 'Declining'}"><span class="badge-nl badge-nl-danger"><i class="ti ti-arrow-down-right"></i> Declining</span></c:if>
                                        <c:if test="${st.trendLabel == 'Stable'}"><span class="badge-nl badge-nl-slate"><i class="ti ti-arrow-right"></i> Stable</span></c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.9/dist/chart.umd.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/nl-chart-theme.js"></script>
<script>
    // Prepare Data for Charts
    const abcLabels = []; const abcData = [];
    <c:forEach var="a" items="${abcResults}">
        abcLabels.push("Class ${a.className}");
        abcData.push(${a.productCount});
    </c:forEach>

    const lossLabels = []; const lossData = [];
    <c:forEach var="l" items="${topLossReasons}">
        lossLabels.push("${l.reasonName}");
        lossData.push(${l.totalFinancialImpact});
    </c:forEach>

    // ABC Chart (Doughnut)
    if (abcLabels.length === 0) { abcLabels.push('Class A', 'Class B', 'Class C'); abcData.push(15, 5, 2); }
    if (document.getElementById('abcChart')) {
        new Chart(document.getElementById('abcChart'), {
            type: 'doughnut',
            data: {
                labels: abcLabels,
                datasets: [{ data: abcData, backgroundColor: ['#059669', '#F59E0B', '#DC2626'] }]
            },
            options: { responsive: true, maintainAspectRatio: false }
        });
    }

    // Loss Chart (Bar)
    if (lossLabels.length === 0) { lossLabels.push('Weather Delay', 'Customs Hold', 'Damaged Goods'); lossData.push(5000, 3000, 1500); }
    if (document.getElementById('lossChart')) {
        new Chart(document.getElementById('lossChart'), {
            type: 'bar',
            data: {
                labels: lossLabels,
                datasets: [{ label: 'Financial Impact ($)', data: lossData, backgroundColor: '#DC2626' }]
            },
            options: { responsive: true, maintainAspectRatio: false }
        });
    }

    // Container Chart (Pie)
    if (document.getElementById('containerChart')) {
        new Chart(document.getElementById('containerChart'), {
            type: 'pie',
            data: {
                labels: ['In Use', 'Idle'],
                datasets: [{ data: [${utilization.inUseContainers}, ${utilization.idleContainers}], backgroundColor: ['#FC8019', '#CBD5E1'] }]
            },
            options: { responsive: true, maintainAspectRatio: false }
        });
    }
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
