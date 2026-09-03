<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<div class="container-fluid py-4">
    <div class="mb-4 text-center">
        <h2 style="font-weight: 800; color: #1a1a1a;">Pricing & Booking Summary</h2>
        <p class="text-muted">Review your cargo allocation and dynamic price breakdown before confirming.</p>
    </div>

    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="card shadow-lg border-0" style="border-radius: 16px; overflow: hidden;">
                
                <div class="card-body p-5">
                    <!-- Allocation Info -->
                    <div class="d-flex align-items-center mb-4 p-3 bg-light rounded" style="border-left: 4px solid #4338ca;">
                        <i class="fa-solid fa-truck-fast fs-3 text-primary me-3"></i>
                        <div>
                            <h5 class="mb-0 fw-bold">Cargo: ${cargoDesc}</h5>
                            <span class="text-muted small">Container: ${container.containerNumber} (${container.size} ${container.type})</span>
                        </div>
                        <div class="ms-auto text-end">
                            <div class="small text-muted">Weight / Vol</div>
                            <div class="fw-bold">${cargoWeight} kg / ${cargoVolume} CBM</div>
                        </div>
                    </div>
                    
                    <hr class="my-4">

                    <!-- Dynamic Pricing (FR3.5) Breakdown -->
                    <h5 class="fw-bold mb-4"><i class="fa-solid fa-calculator text-muted me-2"></i>Dynamic Price Breakdown</h5>
                    
                    <ul class="list-group list-group-flush mb-4">
                        <li class="list-group-item d-flex justify-content-between align-items-center px-0 py-3">
                            <div>
                                <span class="fw-bold text-dark">Base Price</span>
                                <div class="small text-muted">Standard rate for ${container.size} ${container.type}</div>
                            </div>
                            <span class="fs-5">$<fmt:formatNumber value="${pricingRule.basePrice}" maxFractionDigits="2"/></span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between align-items-center px-0 py-3">
                            <div>
                                <span class="fw-bold text-dark">Seasonal Multiplier</span>
                                <div class="small text-muted">Adjustment based on current season/weather trends</div>
                            </div>
                            <span class="fs-5 text-warning">x <fmt:formatNumber value="${pricingRule.seasonalMultiplier}" maxFractionDigits="2"/></span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between align-items-center px-0 py-3">
                            <div>
                                <span class="fw-bold text-dark">Demand Multiplier</span>
                                <div class="small text-muted">Driven by Demand Forecasting Algorithm (Section 5.5)</div>
                            </div>
                            <span class="fs-5 text-danger">x <fmt:formatNumber value="${pricingRule.demandMultiplier}" maxFractionDigits="2"/></span>
                        </li>
                    </ul>

                    <div class="p-4 rounded mb-4" style="background: linear-gradient(135deg, #1e293b, #0f172a); color: white;">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h4 class="mb-0 text-uppercase" style="letter-spacing: 1px; font-weight: 300;">Final Price</h4>
                                <div class="small text-white-50">Formula: Base × Seasonal × Demand</div>
                            </div>
                            <h2 class="mb-0 fw-bold text-success">$<fmt:formatNumber value="${finalPrice}" maxFractionDigits="2"/></h2>
                        </div>
                    </div>

                    <form action="<c:url value='/book'/>" method="POST">
                        <input type="hidden" name="containerId" value="${container.containerId}">
                        <input type="hidden" name="cargoWeight" value="${cargoWeight}">
                        <input type="hidden" name="cargoVolume" value="${cargoVolume}">
                        <input type="hidden" name="cargoDesc" value="${cargoDesc}">
                        <input type="hidden" name="finalPrice" value="${finalPrice}">
                        <input type="hidden" name="origin" value="${origin}">
                        <input type="hidden" name="destination" value="${destination}">
                        
                        <button type="submit" class="btn btn-primary w-100 py-3 shadow" style="border-radius: 12px; font-weight: 700; font-size: 18px;">
                            <i class="fa-solid fa-check-circle me-2"></i> Confirm Booking
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />
