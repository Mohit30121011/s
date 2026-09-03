<%@ page language="java" contentType="text/html; charset=UTF-8" session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
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

    .form-control-custom,
    .form-select-custom {
        width: 100%;
        padding: 10px 14px;
        border: 1px solid #E2E5EA;
        border-radius: 8px;
        font-size: 13.5px;
        background: #FFFFFF;
        color: #1F2937;
        transition: border-color 0.15s ease, box-shadow 0.15s ease;
    }

    .form-control-custom:focus,
    .form-select-custom:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12) !important;
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
        border: 1px solid #E2E5EA;
        color: #4B5563;
        padding: 10px 22px;
        border-radius: 10px;
        font-weight: 600;
        font-size: 13.5px;
        text-decoration: none;
        transition: all 0.15s ease;
    }

    .btn-cancel:hover {
        background: #F9FAFB;
        border-color: #D1D5DB;
        color: #111827;
    }

    .btn-confirm {
        background: #FC8019;
        border: 1px solid #FC8019;
        color: #FFFFFF;
        padding: 10px 24px;
        border-radius: 10px;
        font-weight: 600;
        font-size: 13.5px;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25);
        transition: all 0.15s ease;
        cursor: pointer;
    }

    .btn-confirm:hover {
        background: #E66F0F;
        border-color: #E66F0F;
        color: #FFFFFF;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.35);
    }

    /* TomSelect Theme Integration */
    .ts-control {
        border: 1px solid #E2E5EA !important;
        border-radius: 8px !important;
        padding: 10px 14px !important;
        font-size: 13.5px !important;
        background: #FFFFFF !important;
    }
    .ts-control.focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12) !important;
    }
    .ts-dropdown {
        border-radius: 10px !important;
        border: 1px solid #E7E9ED !important;
        box-shadow: 0 10px 25px rgba(15, 23, 42, 0.08) !important;
        overflow: hidden !important;
    }
    .ts-dropdown .option:hover,
    .ts-dropdown .option.active {
        background-color: #FFF2EB !important;
        color: #FC8019 !important;
        font-weight: 600 !important;
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
                <select class="form-select-custom form-select" name="customerId" required>
                    <option value="" disabled>Search and select customer</option>
                    <c:forEach var="cust" items="${customers}">
                        <option value="${cust.customerId}" <c:if test="${cust.customerId == shipment.customerId}">selected</c:if>>
                            ${cust.customerName} (CUST-${cust.customerId})
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="col-md-6">
                <label class="form-label">Container ID <span class="required">*</span></label>
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

        <!-- 2. Route & Vessel -->
        <div class="section-divider">
            <span class="section-tag">Route & Vessel Configuration</span>
            <div class="section-line"></div>
        </div>

        <div class="route-flex-row mb-3">
            <div class="route-flex-col">
                <label class="form-label">Origin Port (Point A) <span class="required">*</span></label>
                <select class="form-select-custom form-select" name="originPortId" required>
                    <option value="" disabled>Select Origin Port</option>
                    <c:forEach var="port" items="${ports}">
                        <option value="${port.portId}" <c:if test="${port.portId == shipment.originPortId}">selected</c:if>>
                            ${port.portName}, ${port.country}
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="route-arrow-badge" title="Shipping Route">
                <i class="ti ti-arrow-right"></i>
            </div>

            <div class="route-flex-col">
                <label class="form-label">Destination Port (Point B) <span class="required">*</span></label>
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

        <div class="row g-4 mt-1">
            <div class="col-md-6">
                <label class="form-label">Vessel <span class="required">*</span></label>
                <select class="form-select-custom form-select" name="vesselId" required>
                    <option value="" disabled>Select Vessel</option>
                    <c:forEach var="ves" items="${vessels}">
                        <option value="${ves.vesselId}" <c:if test="${ves.vesselId == shipment.vesselId}">selected</c:if>>
                            ${ves.vesselName} (Capacity: ${ves.capacityTeu} TEU)
                        </option>
                    </c:forEach>
                </select>
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
                <select class="form-select-custom form-select" name="status" style="border-color: #E2E5EA;">
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
