<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Claims Management | N Logistic</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">N Logistic</a>
        <span class="navbar-text text-white ms-auto">Claims Management (Module 7) | Welcome, ${sessionScope.username}</span>
    </div>
</nav>
<div class="container">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>Claims & Damages</h2>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#fileClaimModal">File New Claim</button>
    </div>

    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success">${sessionScope.successMessage}</div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger">${sessionScope.errorMessage}</div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <!-- Status Filter -->
    <form class="row g-2 mb-3" method="get" action="${pageContext.request.contextPath}/claims">
        <div class="col-auto">
            <select name="statusFilter" class="form-select">
                <option value="">All Statuses</option>
                <option value="Filed">Filed</option>
                <option value="Under Review">Under Review</option>
                <option value="Approved">Approved</option>
                <option value="Rejected">Rejected</option>
                <option value="Settled">Settled</option>
            </select>
        </div>
        <div class="col-auto"><button type="submit" class="btn btn-outline-secondary">Filter</button></div>
    </form>

    <div class="card shadow-sm">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>Claim ID</th><th>Shipment</th><th>Type</th><th>Incident Date</th>
                            <th>Claimed</th><th>Approved</th><th>Status</th><th>Filed</th><th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="c" items="${claims}">
                            <tr>
                                <td>#${c.claimId}</td>
                                <td>#${c.shipmentId}</td>
                                <td>${c.claimType}</td>
                                <td><fmt:formatDate value="${c.incidentDate}" pattern="yyyy-MM-dd"/></td>
                                <td>$${c.claimedAmount}</td>
                                <td>$${c.approvedAmount}</td>
                                <td>
                                    <span class="badge 
                                        ${c.status == 'Filed' ? 'bg-warning text-dark' : ''}
                                        ${c.status == 'Under Review' ? 'bg-info' : ''}
                                        ${c.status == 'Approved' ? 'bg-primary' : ''}
                                        ${c.status == 'Rejected' ? 'bg-danger' : ''}
                                        ${c.status == 'Settled' ? 'bg-success' : ''}
                                    ">${c.status}</span>
                                </td>
                                <td><fmt:formatDate value="${c.filedDate}" pattern="yyyy-MM-dd"/></td>
                                <td>
                                    <c:if test="${c.status == 'Filed'}">
                                        <button class="btn btn-sm btn-outline-info" onclick="openReviewModal(${c.claimId}, ${c.claimedAmount})">Review</button>
                                    </c:if>
                                    <c:if test="${c.status == 'Approved'}">
                                        <form action="${pageContext.request.contextPath}/claims" method="post" class="d-inline">
                                            <input type="hidden" name="action" value="settle">
                                            <input type="hidden" name="claimId" value="${c.claimId}">
                                            <button type="submit" class="btn btn-sm btn-outline-success">Settle</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${c.status == 'Filed' || c.status == 'Under Review'}">
                                        <form action="${pageContext.request.contextPath}/claims" method="post" class="d-inline">
                                            <input type="hidden" name="action" value="reject">
                                            <input type="hidden" name="claimId" value="${c.claimId}">
                                            <input type="hidden" name="remarks" value="Rejected by admin">
                                            <button type="submit" class="btn btn-sm btn-outline-danger">Reject</button>
                                        </form>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty claims}">
                            <tr><td colspan="9" class="text-center text-muted">No claims found.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- File Claim Modal - ALL SRS fields included (FR7.2) -->
<div class="modal fade" id="fileClaimModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/claims" method="post">
                <div class="modal-header"><h5 class="modal-title">File Loss/Damage Claim (FR7.1)</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                <div class="modal-body">
                    <input type="hidden" name="action" value="file">
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label>Shipment ID *</label>
                            <input type="number" name="shipmentId" class="form-control" required>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label>Container ID</label>
                            <input type="number" name="containerId" class="form-control" placeholder="Optional">
                        </div>
                        <div class="col-md-4 mb-3">
                            <label>Product ID</label>
                            <input type="number" name="productId" class="form-control" placeholder="Optional">
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label>Customer ID *</label>
                            <input type="number" name="customerId" class="form-control" required>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label>Claim Type *</label>
                            <select name="claimType" class="form-select" required>
                                <option value="Damage">Damage</option>
                                <option value="Loss">Loss</option>
                                <option value="Shortage">Shortage</option>
                            </select>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label>Incident Date *</label>
                            <input type="date" name="incidentDate" class="form-control" required>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label>Claimed Amount ($) *</label>
                            <input type="number" step="0.01" name="claimedAmount" class="form-control" required>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label>Loss Reason</label>
                            <select name="reasonId" class="form-select">
                                <option value="">-- None --</option>
                                <option value="1">Traffic in Sea</option>
                                <option value="2">Weather</option>
                                <option value="3">Delay</option>
                                <option value="4">Dock Allocation</option>
                                <option value="5">Government Legal</option>
                                <option value="6">War</option>
                                <option value="7">Ship Issue</option>
                                <option value="8">Damaged Product</option>
                            </select>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label>Description *</label>
                        <textarea name="description" class="form-control" rows="3" required></textarea>
                    </div>
                </div>
                <div class="modal-footer"><button type="submit" class="btn btn-primary">File Claim</button></div>
            </form>
        </div>
    </div>
</div>

<!-- Review Claim Modal -->
<div class="modal fade" id="reviewModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/claims" method="post">
                <div class="modal-header"><h5 class="modal-title">Review & Approve Claim</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                <div class="modal-body">
                    <input type="hidden" name="action" value="review">
                    <input type="hidden" name="claimId" id="reviewClaimId">
                    <div class="mb-3">
                        <label>Requested Amount ($)</label>
                        <input type="text" id="reviewRequestedAmount" class="form-control" readonly>
                    </div>
                    <div class="mb-3">
                        <label>Approved Amount ($) *</label>
                        <input type="number" step="0.01" name="approvedAmount" id="reviewApprovedAmount" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label>Review Remarks *</label>
                        <textarea name="remarks" class="form-control" rows="2" required></textarea>
                    </div>
                </div>
                <div class="modal-footer"><button type="submit" class="btn btn-success">Approve</button></div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function openReviewModal(claimId, reqAmount) {
        document.getElementById('reviewClaimId').value = claimId;
        document.getElementById('reviewRequestedAmount').value = reqAmount;
        document.getElementById('reviewApprovedAmount').value = reqAmount;
        new bootstrap.Modal(document.getElementById('reviewModal')).show();
    }
</script>
</body>
</html>
