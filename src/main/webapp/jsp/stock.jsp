<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/layout/header.jsp" />

<div class="container-fluid mt-4 mb-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2><i class="bi bi-boxes me-2 text-primary"></i>Stock Management & Ledger</h2>
        <div>
            <a href="${pageContext.request.contextPath}/inventory/products" class="btn btn-outline-secondary me-2"><i class="bi bi-box"></i> Products</a>
            <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#uploadCsvModal"><i class="bi bi-cloud-upload"></i> Upload Stock (CSV)</button>
        </div>
    </div>
    
    <c:if test="${param.success == 'true'}">
        <div class="alert alert-success alert-dismissible fade show">Stock uploaded/adjusted successfully! <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
    </c:if>
    <c:if test="${param.error == 'true'}">
        <div class="alert alert-danger alert-dismissible fade show">Failed to process stock! <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
    </c:if>

    <!-- Upload CS
    V Modal -->
    <div class="modal fade" id="uploadCsvModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">   
                <form action="${pageContext.request.contextPath}/inventory/stock/upload" method="POST" enctype="multipart/form-data">
                    <div class="modal-header">
                        <h5 class="modal-title">Bulk Upload Stock</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <p class="text-muted small mb-3">Upload a CSV file containing: <code>ProductId, WarehouseLocation, Quantity, UnitCost, BatchNo, ExpiryDate</code></p>
                        <div class="mb-3">
                            <label class="form-label">Select CSV File</label>
                            <input type="file" class="form-control" name="stockCsv" accept=".csv" required>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success"><i class="bi bi-upload"></i> Upload</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="row">
        <!-- Current Stock -->
        <div class="col-md-6 mb-4">
            <div class="card shadow-sm border-0 h-100">
                <div class="card-header bg-white border-bottom">
                    <h5 class="mb-0"><i class="bi bi-stack me-2"></i>Current Stock Levels</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Product</th>
                                    <th>Location</th>
                                    <th>Qty On Hand</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="s" items="${stocks}">
                                    <tr>
                                        <td><strong>${s.productName}</strong><br><small class="text-muted">Batch: ${s.batchNo}</small></td>
                                        <td>${s.warehouseLocation}</td>
                                        <td><strong class="text-primary">${s.quantityOnHand}</strong></td>
                                        <td>
                                            <button class="btn btn-sm btn-outline-danger" data-bs-toggle="modal" data-bs-target="#adjustModal${s.stockId}">
                                                Adjust
                                            </button>
                                        </td>
                                    </tr>
                                    
                                    <!-- Adjust Modal -->
                                    <div class="modal fade" id="adjustModal${s.stockId}" tabindex="-1">
                                        <div class="modal-dialog">
                                            <div class="modal-content">
                                                <form action="${pageContext.request.contextPath}/inventory/stock/adjust" method="POST">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title">Adjust Stock: ${s.productName}</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <input type="hidden" name="stockId" value="${s.stockId}">
                                                        <input type="hidden" name="productId" value="${s.productId}">
                                                        <p class="mb-3">Current Qty: <strong>${s.quantityOnHand}</strong></p>
                                                        <div class="mb-3">
                                                            <label class="form-label">New Total Quantity (after adjustment)</label>
                                                            <input type="number" step="0.01" class="form-control" name="newQty" required>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label">Reason (Mandatory)</label>
                                                            <input type="text" class="form-control" name="reason" placeholder="e.g. Damage, Audit Discrepancy" required>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                                        <button type="submit" class="btn btn-danger">Confirm Adjustment</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Inventory Ledger -->
        <div class="col-md-6 mb-4">
            <div class="card shadow-sm border-0 h-100">
                <div class="card-header bg-white border-bottom">
                    <h5 class="mb-0"><i class="bi bi-journal-text me-2"></i>Inventory Ledger</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                        <table class="table table-hover table-sm align-middle mb-0">
                            <thead class="table-light" style="position: sticky; top: 0;">
                                <tr>
                                    <th>Date</th>
                                    <th>Type</th>
                                    <th>Product</th>
                                    <th>Qty</th>
                                    <th>Ref</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="l" items="${ledger}">
                                    <tr>
                                        <td>${l.transactionDate}</td>
                                        <td>
                                            <span class="badge ${l.transactionType == 'IN' ? 'bg-success' : (l.transactionType == 'OUT' ? 'bg-danger' : 'bg-warning')}">
                                                ${l.transactionType}
                                            </span>
                                        </td>
                                        <td>${l.productName}</td>
                                        <td>${l.quantity}</td>
                                        <td class="text-muted small">${l.referenceType} #${l.referenceId}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />
