<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<div class="container-fluid py-4">
    <div class="mb-4">
        <a href="<c:url value='/containers'/>" class="text-decoration-none text-muted mb-2 d-inline-block">
            <i class="fa-solid fa-arrow-left me-2"></i> Back to Catalog
        </a>
        <h2 style="font-weight: 700; color: #1a1a1a;">Allocate Container</h2>
        <p class="text-muted">Enter cargo details to validate capacity and generate pricing.</p>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger shadow-sm border-0 mb-4" style="border-radius: 8px;">
            <i class="fa-solid fa-triangle-exclamation me-2"></i> ${errorMessage}
        </div>
    </c:if>

    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success shadow-sm border-0 mb-4" style="border-radius: 8px;">
            <i class="fa-solid fa-circle-check me-2"></i> ${sessionScope.successMessage}
            <c:remove var="successMessage" scope="session"/>
        </div>
    </c:if>

    <div class="row g-4">
        <!-- Left Column: Container Details -->
        <div class="col-lg-4">
            <div class="card shadow-sm border-0 h-100" style="border-radius: 12px; overflow: hidden;">
                <div style="height: 200px; background-color: #f8fafc; display: flex; justify-content: center; align-items: center; border-bottom: 1px solid #e2e8f0;">
                    <c:choose>
                        <c:when test="${not empty container.imageUrl}">
                            <img src="${container.imageUrl}" alt="Container" style="width: 100%; height: 100%; object-fit: cover;">
                        </c:when>
                        <c:otherwise>
                            <i class="fa-solid fa-box-open" style="font-size: 80px; color: #94a3b8;"></i>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="card-body p-4">
                    <h4 class="mb-1" style="font-weight: 700;">${container.containerNumber}</h4>
                    <p class="text-muted mb-4"><span class="badge bg-light text-dark border me-2">${container.size}</span> ${container.type}</p>
                    
                    <h6 class="text-uppercase text-muted mb-3" style="font-size: 12px; font-weight: 700; letter-spacing: 1px;">Capacity Limits</h6>
                    
                    <div class="mb-3">
                        <div class="d-flex justify-content-between mb-1" style="font-size: 14px;">
                            <span class="text-muted">Max Weight</span>
                            <span style="font-weight: 600;"><fmt:formatNumber value="${container.goodsCapacityKg}" maxFractionDigits="0"/> kg</span>
                        </div>
                        <div class="progress" style="height: 8px; border-radius: 4px;">
                            <div id="weightProgressBar" class="progress-bar bg-primary" role="progressbar" style="width: 0%;"></div>
                        </div>
                    </div>
                    
                    <div class="mb-4">
                        <div class="d-flex justify-content-between mb-1" style="font-size: 14px;">
                            <span class="text-muted">Max Volume</span>
                            <span style="font-weight: 600;"><fmt:formatNumber value="${container.goodsCapacityCbm}" maxFractionDigits="2"/> CBM</span>
                        </div>
                        <div class="progress" style="height: 8px; border-radius: 4px;">
                            <div id="volumeProgressBar" class="progress-bar bg-info" role="progressbar" style="width: 0%;"></div>
                        </div>
                    </div>

                    <div class="alert bg-light border-0 p-3" style="border-radius: 8px; font-size: 13px;">
                        <i class="fa-solid fa-circle-info text-primary me-2"></i> 
                        Allocation will be blocked if cargo weight or volume exceeds these limits.
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Column: Cargo Input Form -->
        <div class="col-lg-8">
            <div class="card shadow-sm border-0" style="border-radius: 12px;">
                <div class="card-body p-4 p-lg-5">
                    <h5 class="mb-4" style="font-weight: 700;">Cargo & Routing Details</h5>
                    
                    <form action="<c:url value='/allocate'/>" method="POST">
                        <input type="hidden" name="containerId" value="${container.containerId}">
                        <input type="hidden" id="maxWeight" value="${container.goodsCapacityKg}">
                        <input type="hidden" id="maxVolume" value="${container.goodsCapacityCbm}">

                        <div class="row g-4 mb-4">
                            <div class="col-md-12">
                                <label class="form-label text-muted" style="font-weight: 600; font-size: 14px;">Cargo Description</label>
                                <input type="text" class="form-control" name="cargoDesc" value="${cargoDesc}" required placeholder="e.g. Electronics, Garments, Auto Parts" style="padding: 12px; border-radius: 8px;">
                            </div>
                            
                            <div class="col-md-6">
                                <label class="form-label text-muted" style="font-weight: 600; font-size: 14px;">Total Weight (kg)</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light"><i class="fa-solid fa-weight-hanging text-muted"></i></span>
                                    <input type="number" step="0.01" class="form-control" id="cargoWeight" name="cargoWeight" value="${cargoWeight}" required placeholder="0.00" style="padding: 12px;">
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <label class="form-label text-muted" style="font-weight: 600; font-size: 14px;">Total Volume (CBM)</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light"><i class="fa-solid fa-cube text-muted"></i></span>
                                    <input type="number" step="0.01" class="form-control" id="cargoVolume" name="cargoVolume" value="${cargoVolume}" required placeholder="0.00" style="padding: 12px;">
                                </div>
                            </div>
                        </div>

                        <hr class="my-4" style="border-color: #e2e8f0;">
                        <h5 class="mb-4" style="font-weight: 700;">Route</h5>

                        <div class="row g-4 mb-5">
                            <div class="col-md-6">
                                <label class="form-label text-muted" style="font-weight: 600; font-size: 14px;">Origin Port (Point A)</label>
                                <select name="origin" class="form-select" required style="padding: 12px; border-radius: 8px;">
                                    <option value="" disabled selected>Select Origin</option>
                                    <option value="1">Port of Shanghai (CNSHG)</option>
                                    <option value="2">Port of Singapore (SGSIN)</option>
                                    <option value="3">Port of Los Angeles (USLAX)</option>
                                    <option value="4">Port of Rotterdam (NLRTM)</option>
                                    <option value="5">Port of Mumbai (INBOM)</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label text-muted" style="font-weight: 600; font-size: 14px;">Destination Port (Point B)</label>
                                <select name="destination" class="form-select" required style="padding: 12px; border-radius: 8px;">
                                    <option value="" disabled selected>Select Destination</option>
                                    <option value="1">Port of Shanghai (CNSHG)</option>
                                    <option value="2">Port of Singapore (SGSIN)</option>
                                    <option value="3">Port of Los Angeles (USLAX)</option>
                                    <option value="4">Port of Rotterdam (NLRTM)</option>
                                    <option value="5">Port of Mumbai (INBOM)</option>
                                </select>
                            </div>
                        </div>

                        <div class="d-flex justify-content-end">
                            <button type="submit" id="btnSubmit" class="btn btn-primary px-5 py-3" style="font-weight: 700; border-radius: 8px; font-size: 16px;">
                                Validate & Calculate Price <i class="fa-solid fa-arrow-right ms-2"></i>
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- JavaScript to power the dynamic progress bars -->
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const inputWeight = document.getElementById("cargoWeight");
        const inputVolume = document.getElementById("cargoVolume");
        const maxWeight = parseFloat(document.getElementById("maxWeight").value) || 1;
        const maxVolume = parseFloat(document.getElementById("maxVolume").value) || 1;
        
        const barWeight = document.getElementById("weightProgressBar");
        const barVolume = document.getElementById("volumeProgressBar");
        const btnSubmit = document.getElementById("btnSubmit");

        function updateBars() {
            let w = parseFloat(inputWeight.value) || 0;
            let v = parseFloat(inputVolume.value) || 0;

            let wPercent = (w / maxWeight) * 100;
            let vPercent = (v / maxVolume) * 100;

            // Cap at 100 for visual sake, but color red if exceeded
            barWeight.style.width = Math.min(wPercent, 100) + "%";
            barVolume.style.width = Math.min(vPercent, 100) + "%";

            if (wPercent > 100) {
                barWeight.classList.remove("bg-primary");
                barWeight.classList.add("bg-danger");
            } else {
                barWeight.classList.add("bg-primary");
                barWeight.classList.remove("bg-danger");
            }

            if (vPercent > 100) {
                barVolume.classList.remove("bg-info");
                barVolume.classList.add("bg-danger");
            } else {
                barVolume.classList.add("bg-info");
                barVolume.classList.remove("bg-danger");
            }
            
            // Optional: disable button instantly if overloaded, though server-side still validates.
            if (wPercent > 100 || vPercent > 100) {
                btnSubmit.classList.add("btn-danger");
                btnSubmit.classList.remove("btn-primary");
                btnSubmit.innerHTML = 'Capacity Exceeded <i class="fa-solid fa-ban ms-2"></i>';
            } else {
                btnSubmit.classList.add("btn-primary");
                btnSubmit.classList.remove("btn-danger");
                btnSubmit.innerHTML = 'Validate & Calculate Price <i class="fa-solid fa-arrow-right ms-2"></i>';
            }
        }

        inputWeight.addEventListener("input", updateBars);
        inputVolume.addEventListener("input", updateBars);
        
        // Trigger once on load in case of re-rendering with values
        updateBars();
    });
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
