<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />
<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-regular-rounded/css/uicons-regular-rounded.css'>
<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-solid-rounded/css/uicons-solid-rounded.css'>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<style>
:root {
    --primary: #FC8019; --primary-light: #FFF2EB; --primary-mid: #FFD4C2;
    --success: #10B981; --success-light: #ECFDF5;
    --danger: #EF4444; --danger-light: #FEF2F2;
    --warning: #F59E0B; --warning-light: #FFFBEB;
    --info: #3B82F6; --info-light: #EFF6FF;
    --purple: #8B5CF6; --purple-light: #F5F3FF;
    --text-main: #1F2937; --text-sub: #64748B; --border: #E7E9ED;
    --bg: #F8F9FB; --card: #FFFFFF;
}
body { background: var(--bg); font-family: 'Inter', sans-serif; }
.dash-wrap { padding: 24px; max-width: 1400px; margin: 0 auto; }

/* Page Header */
.dash-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
.dash-header-left h1 { font-size: 22px; font-weight: 700; color: var(--text-main); margin: 0 0 2px; }
.dash-header-left p { font-size: 13px; color: var(--text-sub); margin: 0; }
.dash-header-right { display: flex; align-items: center; gap: 12px; }
.date-badge { display: flex; align-items: center; gap: 8px; padding: 8px 14px; border: 1px solid var(--border); border-radius: 8px; background: #fff; font-size: 13px; font-weight: 500; color: var(--text-main); cursor: pointer; }
.date-badge i { color: var(--text-sub); }
.btn-new-ship { display: inline-flex; align-items: center; gap: 8px; padding: 9px 16px; background: var(--primary); color: #fff; border: none; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; text-decoration: none; transition: background 0.2s; }
.btn-new-ship:hover { background: #EA580C; color: #fff; }

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
.grid-3col { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 16px; margin-bottom: 16px; }
.grid-2col { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px; }
.grid-3col-side { display: grid; grid-template-columns: 1fr 1fr 1.2fr; gap: 16px; margin-bottom: 16px; }

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
.chart-wrap { position: relative; height: 220px; }
.chart-wrap-sm { position: relative; height: 200px; }

/* Shipments by Status */
.status-chart-wrap { display: flex; align-items: center; gap: 16px; padding: 8px 0; }
.status-canvas-wrap { width: 160px; height: 160px; flex-shrink: 0; }
.status-legend { flex: 1; }
.status-legend-item { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
.legend-dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
.legend-label { font-size: 12px; color: var(--text-sub); flex: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.legend-cnt { font-size: 12px; font-weight: 600; color: var(--text-main); }
.legend-pct { font-size: 11px; color: var(--text-sub); }

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

/* Container Overview */
.container-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.cont-card { background: #F9FAFB; border: 1px solid var(--border); border-radius: 10px; padding: 14px; }
.cont-type { font-size: 11px; color: var(--text-sub); font-weight: 500; margin-bottom: 8px; }
.cont-val { font-size: 22px; font-weight: 700; color: var(--text-main); }
.cont-delta { font-size: 11px; font-weight: 600; color: var(--success); margin-top: 2px; }

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

</style>

<div class="dash-wrap">
    <!-- Page Header -->
    <div class="dash-header">
        <div class="dash-header-left">
            <h1>Dashboard</h1>
            <p>Welcome back! Here's what's happening with your logistics operations.</p>
        </div>
        <div class="dash-header-right">
            <form action="${pageContext.request.contextPath}/dashboard" method="GET" class="date-badge-form" style="display:inline-block; margin-right: 15px;">
                <select name="period" onchange="this.form.submit()" class="period-select" style="padding: 8px 12px; border-radius: 20px; font-weight: 600;">
                    <option value="all" ${currentPeriod == 'all' ? 'selected' : ''}>All Time</option>
                    <option value="today" ${currentPeriod == 'today' ? 'selected' : ''}>Today</option>
                    <option value="week" ${currentPeriod == 'week' ? 'selected' : ''}>This Week</option>
                    <option value="month" ${currentPeriod == 'month' ? 'selected' : ''}>This Month</option>
                </select>
            </form>
            
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
                <form action="${pageContext.request.contextPath}/dashboard" method="GET" style="margin:0;">
                <input type="hidden" name="period" value="${currentPeriod}">
                <select name="trendPeriod" onchange="this.form.submit()" class="period-select">
                    <option value="week" ${currentTrendPeriod == 'week' ? 'selected' : ''}>This Week</option>
                    <option value="month" ${currentTrendPeriod == 'month' ? 'selected' : ''}>This Month</option>
                    <option value="year" ${currentTrendPeriod == 'year' ? 'selected' : ''}>This Year</option>
                </select>
            </form>
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
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Top Shipping Routes</h3>
                <select class="period-select"><option>All Time</option></select>
            </div>
            <div class="card-body scrollable-card-body" style="padding-top:12px;">
                <table class="route-table">
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

        <!-- Containers Overview -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Containers Overview</h3>
                <span class="card-action">Total: ${totalContainers}</span>
            </div>
            <div class="card-body scrollable-card-body" style="padding-top:12px;">
                <div class="container-grid">
                    <c:forEach var="ct" items="${containerTypes}">
                    <div class="cont-card">
                        <div class="cont-type">${ct.key}</div>
                        <div class="cont-val">${ct.value}</div>
                        <div class="cont-delta"><i class="fi fi-rr-arrow-trend-up"></i> Active</div>
                    </div>
                    </c:forEach>
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

// --- Trend Chart ---
(function() {
    var labels = trendJson.length > 0 ? trendJson.map(function(d){return d.d;}) : ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    var data   = trendJson.length > 0 ? trendJson.map(function(d){return d.cnt;}) : [2,4,3,6,5,3,4];
    new Chart(document.getElementById('trendChart'), {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: 'Shipments',
                data: data,
                borderColor: '#F97316',
                backgroundColor: 'rgba(249,115,22,0.1)',
                borderWidth: 2, tension: 0.4, fill: true, pointRadius: 4,
                pointBackgroundColor: '#F97316', pointBorderColor: '#fff', pointBorderWidth: 2
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

    new Chart(document.getElementById('statusChart'), {
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
            '<span class="legend-label">' + d.status + '</span>' +
            '<span class="legend-cnt">' + d.cnt + '</span>&nbsp;' +
            '<span class="legend-pct">(' + pct + '%)</span>';
        legend.appendChild(item);
    });
})();
</script>
<jsp:include page="/jsp/layout/footer.jsp" />
</body>
</html>
