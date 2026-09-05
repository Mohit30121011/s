<%@ page language="java" contentType="text/html; charset=UTF-8" session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/layout/header.jsp" />
<style>
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
    .select-wrapper .ts-wrapper,
    .select-wrapper .ts-wrapper.single {
        width: 100% !important;
        border: none !important;
        background: transparent !important;
        padding: 0 !important;
        box-shadow: none !important;
    }
    .select-wrapper .ts-control,
    .select-wrapper .ts-wrapper.single .ts-control,
    .select-wrapper .form-select-custom {
        width: 100% !important;
        border: 1.5px solid #E2E8F0 !important;
        border-radius: 50px !important;
        padding: 11px 44px 11px 20px !important;
        font-size: 14px !important;
        color: #0F172A !important;
        background-color: #FFFFFF !important;
        min-height: 44px !important;
        display: flex !important;
        align-items: center !important;
        cursor: pointer !important;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.02) !important;
        transition: border-color 0.2s ease, box-shadow 0.2s ease !important;
    }
    .select-wrapper .ts-control.focus,
    .select-wrapper .ts-wrapper.single.focus .ts-control,
    .select-wrapper .form-select-custom:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3.5px rgba(252, 128, 25, 0.16) !important;
    }
    .select-wrapper .ts-wrapper.single .ts-control:after {
        display: none !important;
    }
</style>


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

<form method="POST" action="${pageContext.request.contextPath}<c:choose><c:when test="${sessionScope.user.roleId == 5}">/shipments/quote</c:when><c:otherwise>/shipments/save</c:otherwise></c:choose>">
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
                    <select class="form-select-custom form-select" name="customerId" required
                            <c:if test="${lockCustomer}">data-locked="true" tabindex="-1"
                            style="pointer-events:none; background:var(--nl-surface-subtle,#F9FAFB);"</c:if>>
                        <%-- Staff pick a customer; a Customer is pinned to their own account. --%>
                        <c:if test="${not lockCustomer}">
                            <option value="" disabled selected>Search and select customer</option>
                        </c:if>
                        <c:forEach var="cust" items="${customers}">
                            <option value="${cust.customerId}" <c:if test="${lockCustomer}">selected</c:if>>${cust.customerName} (CUST-${cust.customerId})</option>
                        </c:forEach>
                    </select>
                    <c:if test="${lockCustomer}">
                        <div style="font-size:11.5px; color:var(--text-sub); margin-top:6px;">
                            <i class="ti ti-lock"></i> Bookings are placed under your own account.
                        </div>
                    </c:if>
                </div>
            </div>

            <!-- Container -->
            <div class="col-md-6">
                <label class="form-label">Container ID <span class="required">*</span></label>
                <div class="select-wrapper">
                    <select class="form-select-custom form-select" name="containerId" required>
                        <%-- Preselected when the user arrived from a catalog card --%>
                        <c:if test="${empty preselectedContainerId}">
                            <option value="" disabled selected>Search and select container</option>
                        </c:if>
                        <c:forEach var="cont" items="${containers}">
                            <option value="${cont.containerId}"
                                <c:if test="${cont.containerId == preselectedContainerId}">selected</c:if>>${cont.containerNumber} (${cont.type})</option>
                        </c:forEach>
                    </select>
                    <c:if test="${not empty preselectedContainer}">
                        <div style="font-size:11.5px; color:var(--text-sub); margin-top:6px;">
                            <i class="ti ti-check"></i>
                            ${preselectedContainer.containerNumber} selected from the catalog
                            &bull; max ${preselectedContainer.maxGrossWeightKg} kg / ${preselectedContainer.goodsCapacityCbm} CBM
                        </div>
                    </c:if>
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
            <%-- Freight rate is internal pricing: staff enter it, customers are quoted it. --%>
            <c:choose>
                <c:when test="${sessionScope.user.roleId == 5}">
                    <input type="hidden" name="freightCost" value="0">
                </c:when>
                <c:otherwise>
                    <div class="col-md-3">
                        <label class="form-label">Freight Cost ($) <span class="required">*</span></label>
                        <input type="number" step="0.01" class="form-control-custom form-control" name="freightCost" required>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
        <c:if test="${sessionScope.user.roleId == 5}">
            <div class="mt-3" style="font-size:12.5px; color:var(--text-sub);">
                <i class="ti ti-info-circle"></i>
                Your freight quote is calculated automatically from the live rate card and
                confirmed on your invoice.
            </div>
        </c:if>

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
                width: 100%; padding: 11px 20px; border: 1.5px solid #E2E8F0;
                border-radius: 50px !important; font-size: 14px; background: #fff;
                min-height: 44px; transition: border-color 0.2s ease, box-shadow 0.2s ease;
                outline: none;
            }
            .form-select-custom:focus, .form-control-custom:focus {
                border-color: #FC8019 !important;
                box-shadow: 0 0 0 3.5px rgba(252, 128, 25, 0.16) !important;
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
    
    /* Custom Tom Select & Dropdown Chevron Styling */
    .form-select-custom {
        background-color: #FFFFFF !important;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%2364748B' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
        background-repeat: no-repeat !important;
        background-position: right 18px center !important;
        background-size: 12px 10px !important;
        padding-right: 42px !important;
        cursor: pointer !important;
    }
    .ts-wrapper.single .ts-control,
    .ts-control {
        border: 1.5px solid #E2E8F0 !important;
        border-radius: 50px !important;
        padding: 11px 42px 11px 20px !important;
        font-size: 14px;
        background-color: #FFFFFF !important;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%2364748B' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
        background-repeat: no-repeat !important;
        background-position: right 18px center !important;
        background-size: 12px 10px !important;
        min-height: 44px;
        display: flex !important;
        align-items: center !important;
        cursor: pointer !important;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.02) !important;
        transition: border-color 0.2s ease, box-shadow 0.2s ease;
    }
    .ts-wrapper.single.input-active .ts-control,
    .ts-wrapper.single.dropdown-active .ts-control,
    .ts-control.focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3.5px rgba(252, 128, 25, 0.16) !important;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23FC8019' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
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




