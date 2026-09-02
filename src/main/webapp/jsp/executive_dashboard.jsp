<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Executive Analytics Dashboard | N Logistic</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { background-color: #f8f9fa; }
        .card { border-radius: 12px; border: none; box-shadow: 0 4px 6px rgba(0,0,0,0.05); margin-bottom: 20px; }
        .stat-icon { font-size: 2rem; color: #0d6efd; opacity: 0.8; }
        .kpi-title { font-size: 0.9rem; color: #6c757d; text-transform: uppercase; font-weight: 600; }
        .kpi-value { font-size: 1.8rem; font-weight: 700; color: #212529; }
    </style>
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">N Logistic</a>
        <span class="navbar-text text-white ms-auto">
            Executive Analytics (Module 6) | Welcome, ${sessionScope.username}
        </span>
    </div>
</nav>

<div class="container-fluid px-4">
    <h2 class="mb-4">Executive Analytics Dashboard</h2>
    
    <!-- KPI Row -->
    <div class="row">
        <div class="col-md-3">
            <div class="card p-3">
                <div class="d-flex justify-content-between">
                    <div>
                        <div class="kpi-title">Total Revenue</div>
                        <div class="kpi-value">$${summary.totalRevenue}</div>
                    </div>
                    <div class="stat-icon">💵</div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card p-3">
                <div class="d-flex justify-content-between">
                    <div>
                        <div class="kpi-title">Net Profit</div>
                        <div class="kpi-value">$${summary.netProfit}</div>
                    </div>
                    <div class="stat-icon">📈</div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card p-3">
                <div class="d-flex justify-content-between">
                    <div>
                        <div class="kpi-title">Active Shipments</div>
                        <div class="kpi-value">${summary.activeShipments}</div>
                    </div>
                    <div class="stat-icon">🚢</div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card p-3">
                <div class="d-flex justify-content-between">
                    <div>
                        <div class="kpi-title">Overdue Invoices</div>
                        <div class="kpi-value text-danger">${summary.overdueInvoices} ($${summary.overdueReceivables})</div>
                    </div>
                    <div class="stat-icon">⚠️</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Charts Row -->
    <div class="row">
        <div class="col-md-4">
            <div class="card p-3">
                <h5 class="mb-3">ABC Classification (Pareto)</h5>
                <div style="position: relative; height: 300px; width: 100%;">
                    <canvas id="abcChart"></canvas>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card p-3">
                <h5 class="mb-3">Top Loss Reasons</h5>
                <div style="position: relative; height: 300px; width: 100%;">
                    <canvas id="lossChart"></canvas>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card p-3">
                <h5 class="mb-3">Container Utilization</h5>
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span>Total: <b>${utilization.totalContainers}</b></span>
                    <span class="badge bg-success">Utilization: ${utilization.utilizationRatePct}%</span>
                </div>
                <div style="position: relative; height: 260px; width: 100%;">
                    <canvas id="containerChart"></canvas>
                </div>
            </div>
        </div>
    </div>

    <!-- Tables Row -->
    <div class="row">
        <div class="col-md-6">
            <div class="card p-3 h-100">
                <h5 class="mb-3">Customer Profitability Analysis</h5>
                <div class="table-responsive">
                    <table class="table table-sm table-hover">
                        <thead class="table-light">
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
                                    <td class="${cp.netProfit >= 0 ? 'text-success' : 'text-danger'}">$${cp.netProfit}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="card p-3 h-100">
                <h5 class="mb-3">Stock Valuation</h5>
                <div class="d-flex justify-content-between mb-2">
                    <small class="text-muted">Avg Inventory Turnover Ratio: <b>${turnover.avgTurnoverRatio}</b></small>
                    <small class="text-muted">Avg Days in Inventory: <b>${turnover.avgDaysInInventory}</b></small>
                </div>
                <div class="table-responsive">
                    <table class="table table-sm table-hover">
                        <thead class="table-light">
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
</div>

    <!-- Additional Tables Row -->
    <div class="row mt-4">
        <div class="col-md-6">
            <div class="card p-3 h-100">
                <h5 class="mb-3">Active Shipments</h5>
                <div class="table-responsive">
                    <table class="table table-sm table-hover">
                        <thead class="table-light">
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
                                    <td><span class="badge bg-info">${as.status}</span></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="card p-3 h-100">
                <h5 class="mb-3">Sales Trend Analysis</h5>
                <div class="table-responsive">
                    <table class="table table-sm table-hover">
                        <thead class="table-light">
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
                                        <c:if test="${st.trendLabel == 'Growing'}"><span class="badge bg-success">Growing</span></c:if>
                                        <c:if test="${st.trendLabel == 'Declining'}"><span class="badge bg-danger">Declining</span></c:if>
                                        <c:if test="${st.trendLabel == 'Stable'}"><span class="badge bg-secondary">Stable</span></c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

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
                datasets: [{ data: abcData, backgroundColor: ['#198754', '#ffc107', '#dc3545'] }]
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
                datasets: [{ label: 'Financial Impact ($)', data: lossData, backgroundColor: '#dc3545' }]
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
                datasets: [{ data: [${utilization.inUseContainers}, ${utilization.idleContainers}], backgroundColor: ['#0d6efd', '#6c757d'] }]
            },
            options: { responsive: true, maintainAspectRatio: false }
        });
    }
</script>
</body>
</html>

