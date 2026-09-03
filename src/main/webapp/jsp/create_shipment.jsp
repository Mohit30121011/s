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
</style>


<div class="page-title">
    <h2>Create New Shipment</h2>
    <div class="custom-breadcrumb d-flex align-items-center">
        <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <i class="fa-solid fa-angle-right custom-breadcrumb-separator"></i>
        <a href="${pageContext.request.contextPath}/shipments">Shipments</a>
        <i class="fa-solid fa-angle-right custom-breadcrumb-separator"></i>
        <span class="active">New</span>
    </div>
</div>

<c:if test="${not empty sessionScope.errorMessage || param.error == 'true'}">
    <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert" style="border-radius: 10px; border: 1px solid #FECACA; background: #FEF2F2; color: #991B1B; font-size: 14px; font-weight: 500;">
        <i class="ti ti-alert-circle me-2" style="font-size: 17px; vertical-align: -2px;"></i>
        ${not empty sessionScope.errorMessage ? sessionScope.errorMessage : 'Failed to book shipment. Please ensure cargo weight and volume do not exceed container capacity.'}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <c:remove var="errorMessage" scope="session"/>
</c:if>

<form action="${pageContext.request.contextPath}/shipments/save" method="POST">
    <div class="card-custom">
        <div class="card-header-custom">
            <i class="fa-regular fa-file-lines"></i>
            <h5>Shipment Details</h5>
        </div>

        <div class="row g-4">
            <!-- Customer -->
            <div class="col-md-6">
                <label class="form-label">Customer <span class="required">*</span></label>
                <div class="select-wrapper">
                    <select class="form-select-custom form-select" name="customerId" required>
                        <option value="" disabled selected>Search and select customer</option>
                        <c:forEach var="cust" items="${customers}">
                            <option value="${cust.customerId}">${cust.customerName} (CUST-${cust.customerId})</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <!-- Container -->
            <div class="col-md-6">
                <label class="form-label">Container ID <span class="required">*</span></label>
                <div class="select-wrapper">
                    <select class="form-select-custom form-select" name="containerId" required>
                        <option value="" disabled selected>Search and select container</option>
                        <c:forEach var="cont" items="${containers}">
                            <option value="${cont.containerId}">${cont.containerNumber} (${cont.type})</option>
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
                        <option value="" disabled selected>Select Origin Port</option>
                        <c:forEach var="port" items="${ports}">
                            <option value="${port.portId}">${port.portName}, ${port.country}</option>
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
                        <option value="" disabled selected>Select Destination Port</option>
                        <c:forEach var="port" items="${ports}">
                            <option value="${port.portId}">${port.portName}, ${port.country}</option>
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
                        <option value="" disabled selected>Select Vessel</option>
                        <c:forEach var="ves" items="${vessels}">
                            <option value="${ves.vesselId}">${ves.vesselName} (Capacity: ${ves.capacityTeu})</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <!-- Booking Date -->
            <div class="col-md-6">
                <label class="form-label">Cargo Description <span class="required">*</span></label>
                <input type="text" class="form-control-custom form-control" name="cargoDesc" placeholder="e.g. Electronics, Textiles" required>
            </div>
        </div>

        <!-- Financials Section (Since the backend requires it for the save) -->
        <div class="section-title">Cargo & Financials</div>
        <div class="row g-4">
            <div class="col-md-3">
                <label class="form-label">Weight (kg) <span class="required">*</span></label>
                <input type="number" step="0.01" class="form-control-custom form-control" name="cargoWeight" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">Volume (CBM) <span class="required">*</span></label>
                <input type="number" step="0.01" class="form-control-custom form-control" name="cargoVolume" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">Declared Value ($) <span class="required">*</span></label>
                <input type="number" step="0.01" class="form-control-custom form-control" name="cargoValue" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">Freight Cost ($) <span class="required">*</span></label>
                <input type="number" step="0.01" class="form-control-custom form-control" name="freightCost" required>
            </div>
        </div>

        <style>
            .card-custom {
                background: #fff; border-radius: 12px; border: 1px solid var(--border-color);
                box-shadow: 0 1px 3px rgba(0,0,0,0.05); padding: 32px;
            }
            .card-header-custom {
                display: flex; align-items: center; gap: 12px; padding-bottom: 24px;
                border-bottom: 1px solid var(--border-color); margin-bottom: 32px;
            }
            .card-header-custom i { color: var(--brand-orange); font-size: 20px; }
            .card-header-custom h5 { margin: 0; font-weight: 600; font-size: 18px; }
            .form-label { font-weight: 600; font-size: 13px; margin-bottom: 8px; }
            .required { color: var(--brand-orange); }
            .form-select-custom, .form-control-custom {
                width: 100%; padding: 12px 16px; border: 1px solid var(--border-color);
                border-radius: 8px; font-size: 14px; background: #fff;
            }
            .select-wrapper { position: relative; }
            /* Removed the ::after double caret CSS here! */
            
            .section-title { font-size: 14px; font-weight: 700; margin: 32px 0 16px 0; }
            .route-container { display: flex; align-items: center; gap: 16px; margin-bottom: 24px; }
            .route-col { flex: 1; }
            .route-arrow {
                display: flex; align-items: center; justify-content: center;
                padding-top: 24px; color: var(--brand-orange); font-weight: bold;
            }
            .route-arrow .line {
                width: 24px; height: 2px;
                background-image: linear-gradient(to right, transparent 50%, var(--brand-orange) 50%);
                background-size: 8px 100%;
            }
            .route-arrow .circle {
                width: 32px; height: 32px; border-radius: 50%;
                background: var(--brand-orange-light); display: flex;
                align-items: center; justify-content: center; margin: 0 8px;
            }
            .form-actions { margin-top: 40px; display: flex; justify-content: flex-end; gap: 16px; }
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
        </style>

        <div class="form-actions border-top mt-5 pt-4">
            <a href="${pageContext.request.contextPath}/shipments" class="btn btn-cancel" style="text-decoration:none;">Cancel</a>
            <button type="submit" class="btn btn-confirm">
                <i class="fa-solid fa-lock" style="font-size: 12px;"></i> Confirm & Book Shipment
            </button>
        </div>

    </div>
</form>

<style>
    /* Custom Tom Select Styling */
    .ts-control {
        border: 1px solid var(--border-color);
        border-radius: 8px;
        padding: 10px 16px;
        font-size: 14px;
        background: #fff;
        box-shadow: none !important;
    }
    .ts-control.focus {
        border-color: var(--brand-orange);
        box-shadow: 0 0 0 0.25rem rgba(252, 128, 25, 0.25) !important;
    }
    .ts-dropdown {
        border-radius: 12px;
        border: 1px solid #E5E7EB;
        box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        margin-top: 8px;
        overflow: hidden;
    }
    /* Hide scrollbar in the dropdown */
    .ts-dropdown .ts-dropdown-content::-webkit-scrollbar {
        display: none;
    }
    .ts-dropdown .ts-dropdown-content {
        -ms-overflow-style: none;
        scrollbar-width: none;
        padding: 8px 0;
    }
    .ts-dropdown .option {
        padding: 10px 16px;
        font-size: 14px;
        color: var(--text-dark);
        transition: background-color 0.2s;
    }
    .ts-dropdown .option:hover, .ts-dropdown .option.active {
        background-color: var(--brand-orange-light);
        color: var(--brand-orange);
        font-weight: 600;
    }
    .ts-wrapper.single .ts-control:after {
        border-color: var(--text-muted) transparent transparent transparent;
        border-width: 5px 5px 0 5px;
        right: 16px;
    }
</style>
<link href="https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/css/tom-select.bootstrap5.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/js/tom-select.complete.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('.form-select-custom').forEach((el) => {
            new TomSelect(el, {
                create: false,
                sortField: {
                    field: "text",
                    direction: "asc"
                },
                dropdownParent: 'body'
            });
        });
    });
</script>
<jsp:include page="/jsp/layout/footer.jsp" />




