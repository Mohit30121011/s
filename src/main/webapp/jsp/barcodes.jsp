<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Barcode Tracking | N Logistic</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/jsbarcode@3.11.0/dist/JsBarcode.all.min.js"></script>
</head>
<body class="bg-light">
<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">N Logistic</a>
        <span class="navbar-text text-white ms-auto">Barcode Tracking (Module 8) | Welcome, ${sessionScope.username}</span>
    </div>
</nav>
<div class="container">
    <h2 class="mb-4">Barcode Tracking System</h2>

    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success">${sessionScope.successMessage}</div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger">${sessionScope.errorMessage}</div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <div class="row">
        <div class="col-md-6 mb-4">
            <div class="card shadow-sm h-100">
                <div class="card-header bg-primary text-white">Generate Barcode (FR8.1)</div>
                <div class="card-body">
                    <form action="${pageContext.request.contextPath}/barcodes" method="post">
                        <input type="hidden" name="action" value="generate">
                        <div class="mb-3">
                            <label>Entity Type</label>
                            <select name="entityType" class="form-select" required>
                                <option value="Shipment">Shipment</option>
                                <option value="Container">Container</option>
                                <option value="Stock">Stock</option>
                                <option value="ComplianceDocument">Compliance Document</option>
                                <option value="Invoice">Invoice</option>
                                <option value="Claim">Claim</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label>Entity ID</label>
                            <input type="number" name="entityId" class="form-control" required placeholder="e.g. 1">
                        </div>
                        <button type="submit" class="btn btn-primary w-100">Generate</button>
                    </form>
                </div>
            </div>
        </div>
        <div class="col-md-6 mb-4">
            <div class="card shadow-sm h-100">
                <div class="card-header bg-success text-white">Scan Barcode Simulator (FR8.3)</div>
                <div class="card-body">
                    <form action="${pageContext.request.contextPath}/barcodes" method="post">
                        <input type="hidden" name="action" value="scan">
                        <div class="mb-3">
                            <label>Barcode Value</label>
                            <input type="text" name="barcodeValue" class="form-control" required placeholder="Scan or Type Barcode...">
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label>Scan Location / Checkpoint</label>
                                <input type="text" name="scanLocation" class="form-control" required placeholder="e.g. Port of Origin">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label>Module Context</label>
                                <select name="moduleContext" class="form-select">
                                    <option value="General">General</option>
                                    <option value="Stock">Stock / Inventory</option>
                                    <option value="Container Allocation">Container Allocation</option>
                                    <option value="Compliance">Compliance</option>
                                    <option value="Billing">Billing</option>
                                </select>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-success w-100">Simulate Scan</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <ul class="nav nav-tabs" id="myTab" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active" id="registry-tab" data-bs-toggle="tab" data-bs-target="#registry" type="button" role="tab">Barcode Registry</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="logs-tab" data-bs-toggle="tab" data-bs-target="#logs" type="button" role="tab">Scan History Logs</button>
        </li>
    </ul>
    
    <div class="tab-content border border-top-0 p-3 bg-white" id="myTabContent">
        <div class="tab-pane fade show active" id="registry" role="tabpanel">
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead class="table-light">
                        <tr><th>ID</th><th>Barcode Value</th><th>Visual</th><th>Type</th><th>Entity</th><th>Generated At</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach var="b" items="${barcodes}">
                            <tr>
                                <td>${b.barcodeId}</td>
                                <td><strong>${b.barcodeValue}</strong></td>
                                <td><svg class="barcode-svg" data-value="${b.barcodeValue}"></svg></td>
                                <td><span class="badge bg-secondary">${b.barcodeType}</span></td>
                                <td>${b.entityType} #${b.entityId}</td>
                                <td><fmt:formatDate value="${b.generatedAt}" pattern="yyyy-MM-dd HH:mm"/></td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty barcodes}">
                            <tr><td colspan="6" class="text-center text-muted">No barcodes generated yet.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
        <div class="tab-pane fade" id="logs" role="tabpanel">
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead class="table-light">
                        <tr><th>Scan ID</th><th>Barcode ID</th><th>Location</th><th>Module</th><th>Scanned By</th><th>Time</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach var="log" items="${scanLogs}">
                            <tr>
                                <td>${log.scanId}</td>
                                <td>Barcode #${log.barcodeId}</td>
                                <td>${log.scanLocation}</td>
                                <td><span class="badge bg-info">${log.moduleContext}</span></td>
                                <td>User #${log.scannedBy}</td>
                                <td><fmt:formatDate value="${log.scannedAt}" pattern="yyyy-MM-dd HH:mm"/></td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty scanLogs}">
                            <tr><td colspan="6" class="text-center text-muted">No scan events logged yet.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.querySelectorAll('.barcode-svg').forEach(function(svg) {
        let val = svg.getAttribute('data-value');
        if (val) { JsBarcode(svg, val, { height: 40, displayValue: false }); }
    });
</script>
</body>
</html>
