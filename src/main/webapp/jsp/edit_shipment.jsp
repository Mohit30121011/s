<%@ page language="java" contentType="text/html; charset=UTF-8" session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* Hide up/down arrows (number spinners) on number inputs */
    input[type="number"]::-webkit-outer-spin-button,
    input[type="number"]::-webkit-inner-spin-button {
        -webkit-appearance: none !important;
        margin: 0 !important;
    }
    input[type="number"] {
        -moz-appearance: textfield !important;
        appearance: textfield !important;
    }

    /* Bulletproof Dropdown Chevron Arrows */
    .select-wrapper {
        position: relative !important;
        width: 100% !important;
        display: block !important;
    }
    .select-wrapper::after {
        content: "" !important;
        position: absolute !important;
        right: 20px !important;
        top: 50% !important;
        transform: translateY(-50%) !important;
        width: 12px !important;
        height: 8px !important;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%2364748B' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
        background-repeat: no-repeat !important;
        background-size: contain !important;
        pointer-events: none !important;
        z-index: 99 !important;
    }
    .select-wrapper:focus-within::after {
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23FC8019' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
    }

    /* Prevent any outer wrapper from rendering double/nested borders */
    .ts-wrapper,
    .ts-wrapper.single,
    .ts-wrapper.form-select-custom,
    .ts-wrapper.form-select,
    .select-wrapper .ts-wrapper,
    .select-wrapper .ts-wrapper.single,
    .select-wrapper .ts-wrapper.form-select-custom,
    .select-wrapper .ts-wrapper.form-select {
        width: 100% !important;
        border: none !important;
        outline: none !important;
        background: transparent !important;
        padding: 0 !important;
        box-shadow: none !important;
        border-radius: 0 !important;
    }

    /* Single authoritative pill border container */
    .select-wrapper .ts-control,
    .select-wrapper .ts-wrapper.single .ts-control,
    select.form-select-custom:not(.tomselected) {
        width: 100% !important;
        border: 1.5px solid #E2E8F0 !important;
        border-radius: 50px !important;
        padding: 11px 44px 11px 20px !important;
        font-size: 13.5px !important;
        color: #0F172A !important;
        background-color: #FFFFFF !important;
        min-height: 44px !important;
        display: flex !important;
        align-items: center !important;
        cursor: pointer !important;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.02) !important;
        transition: border-color 0.2s ease, box-shadow 0.2s ease !important;
        outline: none !important;
    }

    /* Inner input and items must NEVER have their own borders, outlines or backgrounds */
    .select-wrapper .ts-control input,
    .select-wrapper .ts-control > input,
    .select-wrapper .ts-control .item,
    .ts-control input,
    .ts-control > input {
        border: none !important;
        outline: none !important;
        box-shadow: none !important;
        background: transparent !important;
        padding: 0 !important;
        margin: 0 !important;
        font-size: 13.5px !important;
    }

    .select-wrapper .ts-control.focus,
    .select-wrapper .ts-wrapper.single.focus .ts-control,
    .select-wrapper .ts-wrapper.single.input-active .ts-control,
    .select-wrapper .ts-wrapper.single.dropdown-active .ts-control,
    select.form-select-custom:not(.tomselected):focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3.5px rgba(252, 128, 25, 0.16) !important;
        outline: none !important;
    }
    .select-wrapper .ts-wrapper.single .ts-control:after {
        display: none !important;
    }

    .page-title-box {
        margin-bottom: 24px;
    }
    .page-title-box h2 {
        font-size: 24px;
        font-weight: 700;
        color: var(--nl-text);
        margin-bottom: 4px;
        letter-spacing: -0.3px;
    }
    .custom-breadcrumb {
        font-size: 13px;
        color: var(--nl-text-muted);
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .custom-breadcrumb a {
        color: var(--nl-text-muted);
        text-decoration: none;
        transition: color 0.15s;
    }
    .custom-breadcrumb a:hover {
        color: var(--nl-primary);
    }
    .custom-breadcrumb .active {
        color: var(--nl-primary);
        font-weight: 600;
    }

    .edit-card {
        background: #FFFFFF;
        border: 1px solid var(--nl-border);
        border-radius: 14px;
        box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
        padding: 32px;
        margin-bottom: 32px;
        transition: background 0.2s ease, border-color 0.2s ease, box-shadow 0.2s ease;
    }

    .card-header-bar {
        display: flex;
        align-items: center;
        gap: 14px;
        padding-bottom: 20px;
        border-bottom: 1px solid #F1F3F6;
        margin-bottom: 28px;
    }

    .header-icon-badge {
        width: 42px;
        height: 42px;
        border-radius: 10px;
        background: #FFF2EB;
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        flex-shrink: 0;
    }

    .header-title-text h5 {
        margin: 0;
        font-weight: 700;
        font-size: 17px;
        color: var(--nl-text);
    }

    .header-title-text small {
        font-size: 12px;
        color: var(--nl-text-muted);
    }

    .section-divider {
        display: flex;
        align-items: center;
        gap: 12px;
        margin: 32px 0 20px 0;
    }

    .section-tag {
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.6px;
        color: #4B5563;
        background: #F3F4F6;
        padding: 4px 12px;
        border-radius: 6px;
    }

    .section-line {
        flex: 1;
        height: 1px;
        background: #E5E7EB;
    }

    .form-label {
        font-weight: 600;
        font-size: 13px;
        color: #374151;
        margin-bottom: 8px;
        display: block;
    }

    .required {
        color: #FC8019;
        font-weight: 700;
    }

    .form-control-custom {
        width: 100%;
        padding: 11px 20px;
        border: 1.5px solid #E2E8F0;
        border-radius: 50px !important;
        font-size: 13.5px;
        background: #FFFFFF;
        color: #0F172A;
        min-height: 44px;
        transition: all 0.2s ease;
    }
    .form-select-custom {
        width: 100%;
        padding: 11px 42px 11px 20px;
        border: 1.5px solid #E2E8F0;
        border-radius: 50px !important;
        font-size: 13.5px;
        background-color: #FFFFFF;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%2364748B' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e");
        background-repeat: no-repeat;
        background-position: right 18px center;
        background-size: 12px 10px;
        appearance: none;
        -webkit-appearance: none;
        color: #0F172A;
        min-height: 44px;
        cursor: pointer;
        transition: all 0.2s ease;
    }

    .form-control-custom:focus,
    .form-select-custom:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3.5px rgba(252, 128, 25, 0.16) !important;
        outline: none;
    }

    .route-flex-row {
        display: flex;
        align-items: center;
        gap: 16px;
    }

    .route-flex-col {
        flex: 1;
    }

    .route-arrow-badge {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        background: #FFF2EB;
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 16px;
        flex-shrink: 0;
        margin-top: 24px;
        border: 1px solid #FFD4C2;
    }

    .form-actions-bar {
        margin-top: 36px;
        padding-top: 24px;
        border-top: 1px solid #F1F3F6;
        display: flex;
        justify-content: flex-end;
        align-items: center;
        gap: 14px;
    }

    .btn-cancel {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        color: #475569;
        padding: 10px 24px;
        border-radius: 50px;
        font-weight: 500;
        font-size: 13.5px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        text-decoration: none;
        transition: transform 0.18s ease, box-shadow 0.18s ease, background-color 0.18s ease;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.03);
    }
    .btn-cancel:hover {
        background: #F8FAFC;
        border-color: #CBD5E1;
        color: #0F172A;
        transform: translateY(-1px);
        box-shadow: 0 2px 6px rgba(15, 23, 42, 0.06);
    }

    .btn-confirm {
        background: linear-gradient(135deg, #FC8019 0%, #FF6600 100%);
        border: 1px solid transparent;
        color: #FFFFFF !important;
        padding: 10px 26px;
        border-radius: 50px;
        font-weight: 600;
        font-size: 13.5px;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        cursor: pointer;
        transition: transform 0.18s ease, box-shadow 0.18s ease, background-color 0.18s ease;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.20);
    }
    .btn-confirm:hover {
        background: linear-gradient(135deg, #F97316 0%, #EA580C 100%);
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.26);
        color: #FFFFFF !important;
    }
    .btn-confirm i {
        transition: transform 0.18s ease;
    }
    .btn-confirm:hover i {
        transform: scale(1.06);
    }

    /* ==========================================================================
       DARK MODE OVERRIDES (PREMIUM ENTERPRISE SPEC)
       ========================================================================== */
    [data-theme="dark"] .edit-card {
        background: #101820 !important;
        border-color: #22303A !important;
        color: #F8FAFC !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .card-header-bar {
        border-bottom-color: #1A252E !important;
    }
    [data-theme="dark"] .header-icon-badge {
        background: rgba(252, 128, 25, 0.18) !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .header-title-text h5 {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .header-title-text small {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .section-tag {
        background: #151F28 !important;
        color: #94A3B8 !important;
        border: 1px solid #22303A !important;
    }
    [data-theme="dark"] .section-line {
        background: #1A252E !important;
    }
    [data-theme="dark"] .form-label {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .form-control-custom,
    [data-theme="dark"] .select-wrapper .ts-control,
    [data-theme="dark"] .select-wrapper .ts-wrapper.single .ts-control,
    [data-theme="dark"] select.form-select-custom:not(.tomselected),
    [data-theme="dark"] .ts-control {
        background-color: #151F28 !important;
        border-color: #22303A !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .select-wrapper .ts-control input,
    [data-theme="dark"] .select-wrapper .ts-control .item,
    [data-theme="dark"] .ts-control input,
    [data-theme="dark"] .ts-control .item {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .form-control-custom::placeholder {
        color: #64748B !important;
    }
    [data-theme="dark"] .ts-dropdown {
        background-color: #151F28 !important;
        border-color: #22303A !important;
        color: #F8FAFC !important;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5) !important;
    }
    [data-theme="dark"] .ts-dropdown .option {
        color: #CBD5E1 !important;
        border-bottom-color: #1A252E !important;
    }
    [data-theme="dark"] .ts-dropdown .option:hover,
    [data-theme="dark"] .ts-dropdown .active {
        background-color: #1C2A37 !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .ts-dropdown .option.selected {
        background-color: #FC8019 !important;
        color: #FFFFFF !important;
    }
    [data-theme="dark"] .route-arrow-badge {
        background: rgba(252, 128, 25, 0.18) !important;
        border-color: rgba(252, 128, 25, 0.35) !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .form-actions-bar {
        border-top-color: #1A252E !important;
    }
    [data-theme="dark"] .btn-cancel {
        background: #151F28 !important;
        border-color: #22303A !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .btn-cancel:hover {
        background: #1C2A37 !important;
        border-color: #2D3F4D !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .select-wrapper::after {
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%2394A3B8' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
    }
    [data-theme="dark"] .page-title-box h2 {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .custom-breadcrumb,
    [data-theme="dark"] .custom-breadcrumb a {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .custom-breadcrumb a:hover {
        color: #FC8019 !important;
    }
</style>

<div class="page-title-box">
    <h2>Edit Shipment #${shipment.shipmentId}</h2>
    <div class="custom-breadcrumb">
        <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <i class="ti ti-chevron-right" style="font-size: 11px;"></i>
        <a href="${pageContext.request.contextPath}/shipments">Shipments</a>
        <i class="ti ti-chevron-right" style="font-size: 11px;"></i>
        <span class="active">Edit #${shipment.shipmentId}</span>
    </div>
</div>

<form action="${pageContext.request.contextPath}/shipments/updateFull" method="POST">
    <input type="hidden" name="shipmentId" value="${shipment.shipmentId}">

    <div class="edit-card">
        <div class="card-header-bar">
            <div class="header-icon-badge">
                <i class="ti ti-edit"></i>
            </div>
            <div class="header-title-text">
                <h5>Update Shipment Details</h5>
                <small>Configure routing, cargo specifications, and operational status</small>
            </div>
        </div>

        <!-- 1. Customer & Container -->
        <div class="section-divider" style="margin-top: 0;">
            <span class="section-tag">Customer & Container</span>
            <div class="section-line"></div>
        </div>

        <div class="row g-4">
            <div class="col-md-6">
                <label class="form-label">Customer <span class="required">*</span></label>
                <div class="select-wrapper">
                    <select class="form-select-custom form-select" name="customerId" required>
                        <option value="" disabled>Search and select customer</option>
                        <c:forEach var="cust" items="${customers}">
                            <option value="${cust.customerId}" <c:if test="${cust.customerId == shipment.customerId}">selected</c:if>>
                                ${cust.customerName} (CUST-${cust.customerId})
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="col-md-6">
                <label class="form-label">Container ID <span class="required">*</span></label>
                <div class="select-wrapper">
                    <select class="form-select-custom form-select" name="containerId" required>
                        <option value="" disabled>Search and select container</option>
                        <c:forEach var="cont" items="${containers}">
                            <option value="${cont.containerId}" <c:if test="${cont.containerId == shipment.containerId}">selected</c:if>>
                                ${cont.containerNumber} (${cont.type})
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>
        </div>

        <!-- 2. Route & Vessel -->
        <div class="section-divider">
            <span class="section-tag">Route & Vessel Configuration</span>
            <div class="section-line"></div>
        </div>

        <div class="route-flex-row mb-3">
            <div class="route-flex-col">
                <label class="form-label">Origin Port (Point A) <span class="required">*</span></label>
                <div class="select-wrapper">
                    <select class="form-select-custom form-select" name="originPortId" required>
                        <option value="" disabled>Select Origin Port</option>
                        <c:forEach var="port" items="${ports}">
                            <option value="${port.portId}" <c:if test="${port.portId == shipment.originPortId}">selected</c:if>>
                                ${port.portName}, ${port.country}
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="route-arrow-badge" title="Shipping Route">
                <i class="ti ti-arrow-right"></i>
            </div>

            <div class="route-flex-col">
                <label class="form-label">Destination Port (Point B) <span class="required">*</span></label>
                <div class="select-wrapper">
                    <select class="form-select-custom form-select" name="destPortId" required>
                        <option value="" disabled>Select Destination Port</option>
                        <c:forEach var="port" items="${ports}">
                            <option value="${port.portId}" <c:if test="${port.portId == shipment.destinationPortId}">selected</c:if>>
                                ${port.portName}, ${port.country}
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>
        </div>

        <div class="row g-4 mt-1">
            <div class="col-md-6">
                <label class="form-label">Vessel <span class="required">*</span></label>
                <div class="select-wrapper">
                    <select class="form-select-custom form-select" name="vesselId" required>
                        <option value="" disabled>Select Vessel</option>
                        <c:forEach var="ves" items="${vessels}">
                            <option value="${ves.vesselId}" <c:if test="${ves.vesselId == shipment.vesselId}">selected</c:if>>
                                ${ves.vesselName} (Capacity: ${ves.capacityTeu} TEU)
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="col-md-6">
                <label class="form-label">Cargo Description <span class="required">*</span></label>
                <input type="text" class="form-control-custom" name="cargoDesc" value="${shipment.cargoDescription}" placeholder="e.g. Electronics, Auto Parts..." required>
            </div>
        </div>

        <!-- 3. Cargo & Financials -->
        <div class="section-divider">
            <span class="section-tag">Cargo & Financial Specifications</span>
            <div class="section-line"></div>
        </div>

        <div class="row g-4">
            <div class="col-md-3">
                <label class="form-label">Weight (kg) <span class="required">*</span></label>
                <input type="number" step="0.01" class="form-control-custom" name="cargoWeight" value="${shipment.cargoWeightKg}" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">Volume (CBM) <span class="required">*</span></label>
                <input type="number" step="0.01" class="form-control-custom" name="cargoVolume" value="${shipment.cargoVolumeCbm}" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">Declared Value ($) <span class="required">*</span></label>
                <input type="number" step="0.01" class="form-control-custom" name="cargoValue" value="${shipment.cargoDeclaredValue}" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">Freight Cost ($) <span class="required">*</span></label>
                <input type="number" step="0.01" class="form-control-custom" name="freightCost" value="${shipment.freightCost}" required>
            </div>
        </div>

        <div class="row g-4 mt-2">
            <div class="col-md-3">
                <label class="form-label">Insurance Cost ($)</label>
                <input type="number" step="0.01" class="form-control-custom" name="insuranceCost" value="${shipment.insuranceCost}">
            </div>
            <div class="col-md-3">
                <label class="form-label">Other Charges ($)</label>
                <input type="number" step="0.01" class="form-control-custom" name="otherCharges" value="${shipment.otherCharges}">
            </div>
            <div class="col-md-6">
                <label class="form-label">Current Lifecycle Status <span class="required">*</span></label>
                <div class="select-wrapper">
                    <select class="form-select-custom form-select" name="status" required>
                        <option value="Booked" <c:if test="${shipment.status == 'Booked'}">selected</c:if>>Booked</option>
                        <option value="Container Allocated" <c:if test="${shipment.status == 'Container Allocated'}">selected</c:if>>Container Allocated</option>
                        <option value="Departed" <c:if test="${shipment.status == 'Departed'}">selected</c:if>>Departed</option>
                        <option value="In Transit" <c:if test="${shipment.status == 'In Transit'}">selected</c:if>>In Transit</option>
                        <option value="Customs Hold" <c:if test="${shipment.status == 'Customs Hold'}">selected</c:if>>Customs Hold</option>
                        <option value="Arrived" <c:if test="${shipment.status == 'Arrived'}">selected</c:if>>Arrived</option>
                        <option value="Delivered" <c:if test="${shipment.status == 'Delivered'}">selected</c:if>>Delivered</option>
                    </select>
                </div>
            </div>
        </div>

        <!-- Form Actions -->
        <div class="form-actions-bar">
            <a href="${pageContext.request.contextPath}/shipments" class="btn-cancel">Cancel</a>
            <button type="submit" class="btn-confirm">
                <i class="ti ti-device-floppy"></i>
                <span>Save Changes</span>
            </button>
        </div>

    </div>
</form>

<jsp:include page="/jsp/layout/footer.jsp" />
