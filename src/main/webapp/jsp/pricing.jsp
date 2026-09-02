<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/layout/header.jsp" />

<div class="container-fluid mt-4 mb-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2><i class="bi bi-tags me-2 text-success"></i>Dynamic Pricing Rules</h2>
        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back to Dashboard</a>
    </div>
    
    <c:if test="${param.success == 'true'}">
        <div class="alert alert-success alert-dismissible fade show">Pricing multipliers updated successfully! <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
    </c:if>
    <c:if test="${param.error == 'true'}">
        <div class="alert alert-danger alert-dismissible fade show">Failed to update pricing! <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
    </c:if>

    <div class="card shadow-sm border-0">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>Container Specs</th>
                            <th>Route ID</th>
                            <th>Base Price</th>
                            <th>Seasonal Mult.</th>
                            <th>Demand Mult.</th>
                            <th>Final Price</th>
                            <th>Valid Until</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${rules}">
                            <tr>
                                <td><strong>${r.containerType}</strong> (${r.containerSize})</td>
                                <td>#${r.routeId}</td>
                                <td>$${r.basePrice}</td>
                                <td><span class="badge bg-info text-dark">x${r.seasonalMultiplier}</span></td>
                                <td><span class="badge bg-warning text-dark">x${r.demandMultiplier}</span></td>
                                <td><strong class="text-success">$${r.finalPrice}</strong></td>
                                <td>${r.validTo}</td>
                                <td>
                                    <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#editPriceModal${r.pricingId}">
                                        <i class="bi bi-sliders"></i> Adjust
                                    </button>
                                </td>
                            </tr>
                            
                            <!-- Edit Modal -->
                            <div class="modal fade" id="editPriceModal${r.pricingId}" tabindex="-1">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <form action="${pageContext.request.contextPath}/pricing/update" method="POST">
                                            <div class="modal-header">
                                                <h5 class="modal-title">Adjust Multipliers for ${r.containerType}</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                            </div>
                                            <div class="modal-body">
                                                <input type="hidden" name="pricingId" value="${r.pricingId}">
                                                
                                                <p class="text-muted small mb-4">Base Price: <strong>$${r.basePrice}</strong></p>
                                                
                                                <div class="mb-3">
                                                    <label class="form-label">Seasonal Multiplier (e.g. 1.10 for +10%)</label>
                                                    <input type="number" step="0.01" class="form-control" name="seasonalMultiplier" value="${r.seasonalMultiplier}" required>
                                                </div>
                                                
                                                <div class="mb-3">
                                                    <label class="form-label">Demand Multiplier (e.g. 1.25 for +25%)</label>
                                                    <input type="number" step="0.01" class="form-control" name="demandMultiplier" value="${r.demandMultiplier}" required>
                                                </div>
                                            </div>
                                            <div class="modal-footer">
                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                                <button type="submit" class="btn btn-primary">Save changes</button>
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

<jsp:include page="/jsp/layout/footer.jsp" />
