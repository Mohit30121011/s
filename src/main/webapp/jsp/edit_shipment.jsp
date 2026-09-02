<%@ page language="java" contentType="text/html; charset=UTF-8" session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/layout/header.jsp" />

<div class="page-title">
    <h2>Edit Shipment #${shipment.shipmentId}</h2>
    <div class="custom-breadcrumb d-flex align-items-center">
        <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <i class="fa-solid fa-angle-right custom-breadcrumb-separator"></i>
        <a href="${pageContext.request.contextPath}/shipments">Shipments</a>
        <i class="fa-solid fa-angle-right custom-breadcrumb-separator"></i>
        <span class="active">Edit</span>
    </div>
</div>

<form action="${pageContext.request.contextPath}/shipments/updateFull" method="POST">
    <input type="hidden" name="shipmentId" value="${shipment.shipmentId}">
    
    <div class="card-custom">
        <div class="card-header-custom">
            <i class="fa-solid fa-pen-to-square"></i>
            <h5>Update Shipment Details</h5>
        </div>

        <div class="row g-4">
            <!-- Customer -->
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

            <!-- Container -->
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

        <div class="section-title">Route Configuration</div>

        <div class="route-container">
            <div class="route-col">
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
            
            <div class="route-arrow">
                <div class="line"></div>
                <div class="circle"><i class="fa-solid fa-arrow-right"></i></div>
                <div class="line"></div>
            </div>
            
            <div class="route-col">
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

        <div class="row g-4 mt-2">
            <!-- Vessel -->
            <div class="col-md-6">
                <label class="form-label">Vessel <span class="required">*</span></label>
                <div class="select-wrapper">
                    <select class="form-select-custom form-select" name="vesselId" required>
                        <option value="" disabled>Select Vessel</option>
                        <c:forEach var="ves" items="${vessels}">
                            <option value="${ves.vesselId}" <c:if test="${ves.vesselId == shipment.vesselId}">selected</c:if>>
                                ${ves.vesselName} (Capacity: ${ves.capacityTeu})
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <!-- Cargo Description -->
            <div class="col-md-6">
                <label class="form-label">Cargo Description <span class="required">*</span></label>
                <input type="text" class="form-control-custom form-control" name="cargoDesc" value="${shipment.cargoDescription}" required>
            </div>
        </div>

        <!-- Financials Section -->
        <div class="section-title">Cargo & Financials</div>
        <div class="row g-4">
            <div class="col-md-3">
                <label class="form-label">Weight (kg) <span class="required">*</span></label>
                <input type="number" step="0.01" class="form-control-custom form-control" name="cargoWeight" value="${shipment.cargoWeightKg}" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">Volume (CBM) <span class="required">*</span></label>
                <input type="number" step="0.01" class="form-control-custom form-control" name="cargoVolume" value="${shipment.cargoVolumeCbm}" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">Declared Value ($) <span class="required">*</span></label>
                <input type="number" step="0.01" class="form-control-custom form-control" name="cargoValue" value="${shipment.cargoDeclaredValue}" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">Freight Cost ($) <span class="required">*</span></label>
                <input type="number" step="0.01" class="form-control-custom form-control" name="freightCost" value="${shipment.freightCost}" required>
            </div>
        </div>
        
        <div class="row g-4 mt-2">
            <div class="col-md-3">
                <label class="form-label">Insurance Cost ($)</label>
                <input type="number" step="0.01" class="form-control-custom form-control" name="insuranceCost" value="${shipment.insuranceCost}">
            </div>
            <div class="col-md-3">
                <label class="form-label">Other Charges ($)</label>
                <input type="number" step="0.01" class="form-control-custom form-control" name="otherCharges" value="${shipment.otherCharges}">
            </div>
            <div class="col-md-6">
                <label class="form-label">Current Status</label>
                <select class="form-select-custom form-select" name="status" style="border-color: var(--brand-orange);">
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

        <style>
            .card-custom { background: #fff; border-radius: 12px; border: 1px solid var(--border-color); box-shadow: 0 1px 3px rgba(0,0,0,0.05); padding: 32px; }
            .card-header-custom { display: flex; align-items: center; gap: 12px; padding-bottom: 24px; border-bottom: 1px solid var(--border-color); margin-bottom: 32px; }
            .card-header-custom i { color: #0d6efd; font-size: 20px; }
            .card-header-custom h5 { margin: 0; font-weight: 600; font-size: 18px; }
            .form-label { font-weight: 600; font-size: 13px; margin-bottom: 8px; }
            .required { color: var(--brand-orange); }
            .form-select-custom, .form-control-custom { width: 100%; padding: 12px 16px; border: 1px solid var(--border-color); border-radius: 8px; font-size: 14px; background: #fff; }
            .select-wrapper { position: relative; }
            .section-title { font-size: 14px; font-weight: 700; margin: 32px 0 16px 0; }
            .route-container { display: flex; align-items: center; gap: 16px; margin-bottom: 24px; }
            .route-col { flex: 1; }
            .route-arrow { display: flex; align-items: center; justify-content: center; padding-top: 24px; color: var(--brand-orange); font-weight: bold; }
            .route-arrow .line { width: 24px; height: 2px; background-image: linear-gradient(to right, transparent 50%, var(--brand-orange) 50%); background-size: 8px 100%; }
            .route-arrow .circle { width: 32px; height: 32px; border-radius: 50%; background: var(--brand-orange-light); display: flex; align-items: center; justify-content: center; margin: 0 8px; }
            .form-actions { margin-top: 40px; display: flex; justify-content: flex-end; gap: 16px; }
            .btn-cancel { background: #fff; border: 1px solid var(--border-color); color: var(--text-dark); padding: 12px 24px; border-radius: 8px; font-weight: 600; font-size: 14px; }
            .btn-confirm { background: #0d6efd; border: 1px solid #0d6efd; color: #fff; padding: 12px 24px; border-radius: 8px; font-weight: 600; font-size: 14px; display: flex; align-items: center; gap: 8px; }
            .btn-confirm:hover { background: #0b5ed7; color: #fff; opacity: 0.9; }
            
            .ts-control { border: 1px solid var(--border-color); border-radius: 8px; padding: 10px 16px; font-size: 14px; background: #fff; box-shadow: none !important; }
            .ts-control.focus { border-color: var(--brand-orange); box-shadow: 0 0 0 0.25rem rgba(252, 128, 25, 0.25) !important; }
            .ts-dropdown { border-radius: 12px; border: 1px solid #E5E7EB; box-shadow: 0 10px 25px rgba(0,0,0,0.1); margin-top: 8px; overflow: hidden; }
            .ts-dropdown .ts-dropdown-content::-webkit-scrollbar { display: none; }
            .ts-dropdown .ts-dropdown-content { -ms-overflow-style: none; scrollbar-width: none; padding: 8px 0; }
            .ts-dropdown .option { padding: 10px 16px; font-size: 14px; color: var(--text-dark); transition: background-color 0.2s; }
            .ts-dropdown .option:hover, .ts-dropdown .option.active { background-color: var(--brand-orange-light); color: var(--brand-orange); font-weight: 600; }
        </style>

        <div class="form-actions border-top mt-5 pt-4">
            <a href="${pageContext.request.contextPath}/shipments" class="btn btn-cancel" style="text-decoration:none;">Cancel</a>
            <button type="submit" class="btn btn-confirm">
                <i class="fa-solid fa-save"></i> Save Changes
            </button>
        </div>

    </div>
</form>

<link href="https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/css/tom-select.bootstrap5.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/js/tom-select.complete.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('.form-select-custom').forEach((el) => {
            new TomSelect(el, { create: false, sortField: { field: "text", direction: "asc" }, dropdownParent: 'body' });
        });
    });
</script>
<jsp:include page="/jsp/layout/footer.jsp" />

