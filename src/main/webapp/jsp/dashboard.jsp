<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/jsp/layout/header.jsp" />

<c:if test="${not empty requestScope.errorMessage}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="fa-solid fa-circle-exclamation me-2"></i>${requestScope.errorMessage}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<div class="row">
    <!-- Welcome Panel -->
    <div class="col-12 mb-4">
        <div class="card shadow-sm border-0 bg-primary text-white">
            <div class="card-body p-4">
                <h2 class="fw-bold">Welcome back, ${sessionScope.user.username}!</h2>
                <p class="mb-0">Access your logistics operations and analytics from this central hub.</p>
            </div>
        </div>
    </div>
</div>
 
<div class="row g-4">
    <!-- Check Roles to display relevant cards -->
    <c:choose>
        <c:when test="${sessionScope.roleId == 5}">
            <!-- Customer Dashboard -->
            <div class="col-md-4">
                <div class="card shadow-sm h-100 border-0 border-start border-4 border-success">
                    <div class="card-body text-center">
                        <i class="bi bi-box-seam fs-1 text-success mb-2"></i>
                        <h5>My Shipments</h5>
                        <p class="text-muted small">Track your active bookings and cargo status.</p>
                        <a href="<c:url value='/shipments'/>" class="btn btn-outline-success btn-sm">View All</a>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card shadow-sm h-100 border-0 border-start border-4 border-warning">
                    <div class="card-body text-center">
                        <i class="bi bi-receipt fs-1 text-warning mb-2"></i>
                        <h5>Billing & Invoices</h5>
                        <p class="text-muted small">View your pending and paid invoices.</p>
                        <a href="<c:url value='/invoices'/>" class="btn btn-outline-warning btn-sm">View Billing</a>
                    </div>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <!-- Company / Admin Dashboard -->
            <div class="col-md-3">
                <div class="card shadow-sm h-100 border-0 border-start border-4 border-primary">
                    <div class="card-body text-center">
                        <i class="bi bi-truck fs-1 text-primary mb-2"></i>
                        <h5>Manage Shipments</h5>
                        <p class="text-muted small">Create and update container movements.</p>
                        <a href="<c:url value='/shipments'/>" class="btn btn-outline-primary btn-sm">Manage</a>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card shadow-sm h-100 border-0 border-start border-4 border-info">
                    <div class="card-body text-center">
                        <i class="bi bi-archive fs-1 text-info mb-2"></i>
                        <h5>Container Allocation</h5>
                        <p class="text-muted small">View inventory and allocate containers.</p>
                        <a href="<c:url value='/containers'/>" class="btn btn-outline-info btn-sm">Allocate</a>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card shadow-sm h-100 border-0 border-start border-4 border-danger">
                    <div class="card-body text-center">
                        <i class="bi bi-graph-up-arrow fs-1 text-danger mb-2"></i>
                        <h5>Analytics (PLG)</h5>
                        <p class="text-muted small">View Profit & Loss and sales trends.</p>
                        <a href="<c:url value='/analytics'/>" class="btn btn-outline-danger btn-sm">View Dashboard</a>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card shadow-sm h-100 border-0 border-start border-4 border-secondary">
                    <div class="card-body text-center">
                        <i class="bi bi-upc-scan fs-1 text-secondary mb-2"></i>
                        <h5>Barcode Scanner</h5>
                        <p class="text-muted small">Scan entries to quickly load records.</p>
                        <a href="<c:url value='/scanner'/>" class="btn btn-outline-secondary btn-sm">Scan Now</a>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />
