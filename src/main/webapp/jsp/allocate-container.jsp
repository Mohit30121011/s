<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* Allocate Container Theme (Swiggy Orange Enterprise) */
    .allocate-back-link {
        color: #64748B;
        text-decoration: none;
        font-size: 13px;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        margin-bottom: 10px;
        transition: color 0.15s ease;
    }
    .allocate-back-link:hover { color: #FC8019; }
    .allocate-page-title {
        font-weight: 800;
        color: #0F172A;
        font-size: 24px;
        letter-spacing: -0.3px;
        margin-bottom: 4px;
    }
    .allocate-page-subtitle {
        color: #64748B;
        font-size: 13.5px;
        margin: 0;
    }

    .custom-alert { border-radius: 12px; padding: 14px 18px; font-size: 13.5px; font-weight: 500; display: flex; align-items: center; gap: 10px; margin-bottom: 20px; }
    .custom-alert.success { background: #ECFDF5; border: 1px solid #A7F3D0; color: #065F46; }
    .custom-alert.danger { background: #FEF2F2; border: 1px solid #FECACA; color: #991B1B; }

    /* Left Column: Container Details Card */
    .allocate-details-card {
        background: #FFFFFF;
        border: 1px solid var(--nl-border);
        border-radius: 14px;
        box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
        overflow: hidden;
        height: 100%;
    }
    .allocate-image-banner {
        height: 200px;
        background: linear-gradient(135deg, #1E293B 0%, #0F172A 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        border-bottom: 1px solid var(--nl-border);
    }
    .allocate-image-banner img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
    .allocate-image-fallback {
        color: #FC8019;
        font-size: 64px;
    }
    .allocate-details-body {
        padding: 22px 24px;
    }
    .allocate-container-number {
        font-weight: 700;
        color: #0F172A;
        font-size: 18px;
        margin-bottom: 6px;
        font-family: 'Inter', monospace;
    }
    .allocate-type-pill {
        background: #F1F5F9;
        color: #475569;
        border: 1px solid #E2E8F0;
        font-weight: 600;
        font-size: 11.5px;
        padding: 3px 9px;
        border-radius: 6px;
        display: inline-flex;
        align-items: center;
        margin-right: 8px;
    }
    .allocate-type-text {
        color: #64748B;
        font-size: 13px;
    }
    .allocate-section-heading {
        text-transform: uppercase;
        color: #94A3B8;
        font-size: 11.5px;
        font-weight: 700;
        letter-spacing: 0.6px;
        margin: 18px 0 14px 0;
    }
    .capacity-row {
        display: flex;
        justify-content: space-between;
        margin-bottom: 6px;
        font-size: 13px;
    }
    .capacity-row .capacity-label { color: #64748B; }
    .capacity-row .capacity-value { font-weight: 700; color: #0F172A; }
    .capacity-progress-track {
        height: 8px;
        border-radius: 4px;
        background: #F1F5F9;
        overflow: hidden;
    }
    .capacity-progress-fill {
        height: 100%;
        border-radius: 4px;
        transition: width 0.25s ease, background-color 0.25s ease;
        background: #FC8019;
    }
    .capacity-progress-fill.volume { background: #2563EB; }
    .capacity-progress-fill.exceeded { background: #DC2626 !important; }

    .allocate-info-note {
        background: #FFF9F5;
        border: 1px solid #FFD4C2;
        border-radius: 10px;
        padding: 12px 14px;
        font-size: 12.5px;
        color: #7C2D12;
        display: flex;
        align-items: flex-start;
        gap: 8px;
        margin-top: 16px;
    }
    .allocate-info-note i { color: #FC8019; font-size: 15px; margin-top: 1px; }

    /* Right Column: Cargo Form Card */
    .allocate-form-card {
        background: #FFFFFF;
        border: 1px solid var(--nl-border);
        border-radius: 14px;
        box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
    }
    .allocate-form-body {
        padding: 28px 32px;
    }
    .allocate-form-title {
        font-weight: 700;
        color: #0F172A;
        font-size: 16px;
        margin-bottom: 22px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .allocate-form-title i { color: #FC8019; }

    .allocate-form-label {
        color: #475569;
        font-weight: 600;
        font-size: 13px;
        margin-bottom: 6px;
        display: block;
    }
    .allocate-input-group {
        position: relative;
    }
    .allocate-input-group i {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #94A3B8;
        font-size: 15px;
        pointer-events: none;
    }
    .allocate-input-group input {
        padding-left: 38px !important;
    }
    .form-input-themed {
        width: 100%;
        padding: 11px 14px;
        border-radius: 10px;
        border: 1.5px solid #E2E8F0;
        font-size: 13.5px;
        color: #1E293B;
        outline: none;
        transition: all 0.2s ease;
    }
    .form-input-themed:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }

    .allocate-divider {
        border: none;
        border-top: 1px dashed #E2E8F0;
        margin: 28px 0 22px 0;
    }

    .btn-validate-price {
        background: #FC8019;
        color: #FFFFFF !important;
        border: none;
        padding: 13px 32px;
        border-radius: 10px;
        font-weight: 700;
        font-size: 15px;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        cursor: pointer;
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.28);
        transition: all 0.18s ease;
    }
    .btn-validate-price:hover {
        background: #E66F0F;
        transform: translateY(-1px);
        box-shadow: 0 6px 16px rgba(252, 128, 25, 0.38);
    }
    .btn-validate-price.danger-state {
        background: #DC2626;
        box-shadow: 0 4px 12px rgba(220, 38, 38, 0.28);
    }
    .btn-validate-price.danger-state:hover {
        background: #B91C1C;
    }

    /* Select Wrapper (identical across pages) */
    .select-wrapper {
        position: relative;
        width: 100%;
    }
    .select-wrapper::after {
        content: '';
        position: absolute;
        right: 16px;
        top: 50%;
        transform: translateY(-50%);
        width: 14px;
        height: 14px;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2364748B' stroke-width='2.2'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E");
        background-size: contain;
        background-repeat: no-repeat;
        pointer-events: none;
    }
    .form-select-custom, .select-wrapper select {
        appearance: none;
        -webkit-appearance: none;
        width: 100%;
        height: 44px;
        padding: 0 38px 0 16px;
        border: 1.5px solid #E2E8F0;
        border-radius: 10px;
        font-size: 13.5px;
        color: #1E293B;
        background-color: #FFFFFF;
        outline: none;
        transition: all 0.2s ease;
    }
    .form-select-custom:focus, .select-wrapper select:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
</style>

<div class="container-fluid py-4">
    <div class="mb-4">
        <a href="<c:url value='/containers'/>" class="allocate-back-link">
            <i class="ti ti-arrow-left"></i> Back to Catalog
        </a>
        <h2 class="allocate-page-title">Allocate Container</h2>
        <p class="allocate-page-subtitle">Enter cargo details to validate capacity and generate pricing.</p>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="custom-alert danger">
            <i class="ti ti-alert-triangle" style="font-size: 18px;"></i>
            <span>${errorMessage}</span>
        </div>
    </c:if>

    <c:if test="${not empty sessionScope.successMessage}">
        <div class="custom-alert success">
            <i class="ti ti-circle-check" style="font-size: 18px;"></i>
            <span>${sessionScope.successMessage}</span>
        </div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>

    <div class="row g-4">
        <!-- Left Column: Container Details -->
        <div class="col-lg-4">
            <div class="allocate-details-card">
                <div class="allocate-image-banner">
                    <c:choose>
                        <c:when test="${not empty container.imageUrl}">
                            <img src="${container.imageUrl}" alt="Container">
                        </c:when>
                        <c:otherwise>
                            <i class="ti ti-box allocate-image-fallback"></i>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="allocate-details-body">
                    <div class="allocate-container-number">${container.containerNumber}</div>
                    <div class="mb-3">
                        <span class="allocate-type-pill">${container.size}</span>
                        <span class="allocate-type-text">${container.type}</span>
                    </div>

                    <div class="allocate-section-heading">Capacity Limits</div>

                    <div class="mb-3">
                        <div class="capacity-row">
                            <span class="capacity-label">Max Weight</span>
                            <span class="capacity-value"><fmt:formatNumber value="${container.goodsCapacityKg}" maxFractionDigits="0"/> kg</span>
                        </div>
                        <div class="capacity-progress-track">
                            <div id="weightProgressBar" class="capacity-progress-fill" style="width: 0%;"></div>
                        </div>
                    </div>

                    <div class="mb-2">
                        <div class="capacity-row">
                            <span class="capacity-label">Max Volume</span>
                            <span class="capacity-value"><fmt:formatNumber value="${container.goodsCapacityCbm}" maxFractionDigits="2"/> CBM</span>
                        </div>
                        <div class="capacity-progress-track">
                            <div id="volumeProgressBar" class="capacity-progress-fill volume" style="width: 0%;"></div>
                        </div>
                    </div>

                    <div class="allocate-info-note">
                        <i class="ti ti-info-circle"></i>
                        <span>Allocation will be blocked if cargo weight or volume exceeds these limits.</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Column: Cargo Input Form -->
        <div class="col-lg-8">
            <div class="allocate-form-card">
                <div class="allocate-form-body">
                    <div class="allocate-form-title">
                        <i class="ti ti-clipboard-list"></i> Cargo &amp; Routing Details
                    </div>

                    <form action="<c:url value='/allocate'/>" method="POST">
                        <input type="hidden" name="containerId" value="${container.containerId}">
                        <input type="hidden" id="maxWeight" value="${container.goodsCapacityKg}">
                        <input type="hidden" id="maxVolume" value="${container.goodsCapacityCbm}">

                        <div class="row g-4 mb-4">
                            <%-- GAP-M3-02: staff book on behalf of a shipper. Without this the
                                 booking reached /book with no customer at all. --%>
                            <c:if test="${sessionScope.user.roleId <= 3}">
                            <div class="col-md-12">
                                <label class="allocate-form-label">Customer / Shipper <span style="color:#FC8019;">*</span></label>
                                <div class="select-wrapper">
                                    <select name="customerId" class="form-input-themed" required>
                                        <option value="" disabled selected>Select customer account</option>
                                        <c:forEach var="cust" items="${customers}">
                                            <option value="${cust.customerId}" ${param.customerId == cust.customerId ? 'selected' : ''}>${cust.customerName} (CUST-${cust.customerId})</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                            </c:if>
                            <div class="col-md-12">
                                <label class="allocate-form-label">Cargo Description</label>
                                <input type="text" class="form-input-themed" name="cargoDesc" value="${cargoDesc}" required placeholder="e.g. Electronics, Garments, Auto Parts">
                            </div>

                            <div class="col-md-6">
                                <label class="allocate-form-label">Total Weight (kg)</label>
                                <div class="allocate-input-group">
                                    <i class="ti ti-weight"></i>
                                    <input type="number" step="0.01" class="form-input-themed" id="cargoWeight" name="cargoWeight" value="${cargoWeight}" required placeholder="0.00">
                                </div>
                            </div>

                            <div class="col-md-6">
                                <label class="allocate-form-label">Total Volume (CBM)</label>
                                <div class="allocate-input-group">
                                    <i class="ti ti-cube"></i>
                                    <input type="number" step="0.01" class="form-input-themed" id="cargoVolume" name="cargoVolume" value="${cargoVolume}" required placeholder="0.00">
                                </div>
                            </div>
                        </div>

                        <hr class="allocate-divider">
                        <div class="allocate-form-title">
                            <i class="ti ti-route"></i> Route
                        </div>

                        <div class="row g-4 mb-5">
                            <div class="col-md-6">
                                <label class="allocate-form-label">Origin Port (Point A)</label>
                                <div class="select-wrapper">
                                    <select name="origin" class="form-select-custom no-custom-select" required>
                                        <option value="" disabled ${empty origin ? 'selected' : ''}>Select Origin</option>
                                        <c:forEach var="port" items="${ports}">
                                            <option value="${port.portId}" ${origin == port.portId ? 'selected' : ''}>${port.portName} (${port.portCode})</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="allocate-form-label">Destination Port (Point B)</label>
                                <div class="select-wrapper">
                                    <select name="destination" class="form-select-custom no-custom-select" required>
                                        <option value="" disabled ${empty destination ? 'selected' : ''}>Select Destination</option>
                                        <c:forEach var="port" items="${ports}">
                                            <option value="${port.portId}" ${destination == port.portId ? 'selected' : ''}>${port.portName} (${port.portCode})</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <div class="d-flex justify-content-end">
                            <button type="submit" id="btnSubmit" class="btn-validate-price">
                                <span>Validate &amp; Calculate Price</span> <i class="ti ti-arrow-right"></i>
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
                barWeight.classList.add("exceeded");
            } else {
                barWeight.classList.remove("exceeded");
            }

            if (vPercent > 100) {
                barVolume.classList.add("exceeded");
            } else {
                barVolume.classList.remove("exceeded");
            }

            // Optional: disable button instantly if overloaded, though server-side still validates.
            if (wPercent > 100 || vPercent > 100) {
                btnSubmit.classList.add("danger-state");
                btnSubmit.innerHTML = '<span>Capacity Exceeded</span> <i class="ti ti-ban"></i>';
            } else {
                btnSubmit.classList.remove("danger-state");
                btnSubmit.innerHTML = '<span>Validate &amp; Calculate Price</span> <i class="ti ti-arrow-right"></i>';
            }
        }

        inputWeight.addEventListener("input", updateBars);
        inputVolume.addEventListener("input", updateBars);

        // Trigger once on load in case of re-rendering with values
        updateBars();
    });
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
