<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics (PLG) - N Logistic</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { background-color: #f4f6f9; font-family: 'Inter', sans-serif; }
        .card { border: none; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.03); margin-bottom: 24px; }
        .card-header { background-color: #fff; border-bottom: 1px solid #f1f4f8; font-weight: 600; padding: 16px 24px; border-radius: 12px 12px 0 0 !important; }
        .chart-container { position: relative; height: 350px; width: 100%; padding: 20px; }
    </style>
</head>
<body>
    <jsp:include page="/jsp/layout/header.jsp" />

    <div class="container my-5">
        <h2 class="mb-4 fw-bold text-dark"><i class="fas fa-chart-line me-2 text-primary"></i>Profit & Loss Analytics</h2>

        <div class="row">
            <!-- Main PLG Chart -->
            <div class="col-lg-8">
                <div class="card h-100">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <span>Revenue vs Cost Trend</span>
                        <span class="badge bg-primary">Monthly</span>
                    </div>
                    <div class="card-body chart-container">
                        <canvas id="plgChart"></canvas>
                    </div>
                </div>
            </div>
            
            <!-- Loss Reasons Chart -->
            <div class="col-lg-4">
                <div class="card h-100">
                    <div class="card-header">
                        <span>Loss Reasons Breakdown</span>
                    </div>
                    <div class="card-body chart-container">
                        <canvas id="reasonChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Data injected by AnalyticsServlet
        const months = ${jsonMonths};
        const revenues = ${jsonRevenues};
        const costs = ${jsonCosts};
        const reasonLabels = ${jsonReasonLabels};
        const reasonData = ${jsonReasonData};

        // 1. Profit Loss Bar Chart
        const plgCtx = document.getElementById('plgChart').getContext('2d');
        new Chart(plgCtx, {
            type: 'bar',
            data: {
                labels: months,
                datasets: [
                    {
                        label: 'Total Revenue ($)',
                        data: revenues,
                        backgroundColor: 'rgba(52, 152, 219, 0.7)',
                        borderColor: 'rgba(41, 128, 185, 1)',
                        borderWidth: 1,
                        borderRadius: 4
                    },
                    {
                        label: 'Total Cost ($)',
                        data: costs,
                        backgroundColor: 'rgba(231, 76, 60, 0.7)',
                        borderColor: 'rgba(192, 57, 43, 1)',
                        borderWidth: 1,
                        borderRadius: 4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'top' },
                    tooltip: { mode: 'index', intersect: false }
                },
                scales: {
                    y: { beginAtZero: true, grid: { borderDash: [2, 4], color: '#e5e7eb' } },
                    x: { grid: { display: false } }
                }
            }
        });

        // 2. Loss Reasons Doughnut Chart
        const reasonCtx = document.getElementById('reasonChart').getContext('2d');
        new Chart(reasonCtx, {
            type: 'doughnut',
            data: {
                labels: reasonLabels,
                datasets: [{
                    data: reasonData,
                    backgroundColor: [
                        '#e74c3c', '#f1c40f', '#e67e22', '#9b59b6', '#34495e', '#95a5a6'
                    ],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '65%',
                plugins: {
                    legend: { position: 'bottom', labels: { boxWidth: 12, padding: 15 } }
                }
            }
        });
    </script>
</body>
</html>
