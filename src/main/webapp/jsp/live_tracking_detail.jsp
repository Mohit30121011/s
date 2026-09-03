<%@ page language="java" contentType="text/html; charset=UTF-8" session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* Tracking Specific Styles */
    .page-header-flex { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }

    .card-panel {
        background: #fff; border-radius: 14px; border: 1px solid var(--border-color);
        box-shadow: 0 2px 6px rgba(15, 23, 42, 0.03); padding: 24px; margin-bottom: 24px;
    }

    .badge-delayed {
        background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA;
        padding: 6px 16px; border-radius: 20px; font-weight: 600; font-size: 13px;
        display: inline-flex; align-items: center; gap: 8px;
    }

    .summary-grid {
        display: grid; grid-template-columns: repeat(5, 1fr); gap: 24px; margin-top: 20px;
    }
    @media (max-width: 992px) {
        .summary-grid { grid-template-columns: repeat(2, 1fr); }
    }
    .summary-item { font-size: 13px; }
    .summary-label { color: var(--text-muted); margin-bottom: 6px; display: block; font-size: 12px; font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px; }
    .summary-value { font-weight: 600; color: var(--text-dark); display: flex; align-items: center; gap: 6px; font-size: 14px; }

    /* Timeline Stepper */
    .timeline-container { padding: 30px 20px 20px 20px; }
    .stepper-wrapper {
        display: flex; justify-content: space-between; position: relative; width: 100%; margin: 0 auto;
    }
    .stepper-item {
        position: relative; display: flex; flex-direction: column; align-items: center; flex: 1;
    }
    .stepper-item::before {
        content: ''; position: absolute; top: 20px; left: -50%; width: 100%; height: 3px; background: #E5E7EB; z-index: 0;
    }
    .stepper-item:first-child::before { display: none; }

    .stepper-item.completed::before { background: #10B981; }
    .stepper-item.active-orange::before { background: #10B981; }

    .step-circle {
        width: 42px; height: 42px; border-radius: 50%; display: flex; align-items: center; justify-content: center;
        background: #fff; position: relative; z-index: 1; border: 2px solid #E5E7EB; color: #9CA3AF; font-size: 16px; margin-bottom: 14px;
        transition: all 0.2s ease;
    }
    .stepper-item.completed .step-circle {
        background: #10B981; border-color: #10B981; color: white;
    }
    .stepper-item.active-orange .step-circle {
        width: 58px; height: 58px; border: 2px solid #FFEBE0; background: #fff;
        color: var(--brand-orange); font-size: 22px; transform: translateY(-8px);
        box-shadow: 0 0 0 4px #FFF8F5;
    }
    .stepper-item.active-orange .step-circle-inner {
        width: 44px; height: 44px; border-radius: 50%; border: 2px solid var(--brand-orange);
        display: flex; align-items: center; justify-content: center;
    }

    .step-text { text-align: center; font-size: 12px; }
    .step-title { font-weight: 700; color: var(--text-dark); margin-bottom: 4px; font-size: 13px; }
    .step-date { color: var(--text-muted); font-size: 11.5px; }
    .stepper-item.active-orange .step-title { color: var(--brand-orange); }

    /* Panels Grid */
    .panels-grid { display: grid; grid-template-columns: 1.8fr 1.2fr; gap: 24px; margin-bottom: 24px; }
    @media (max-width: 992px) {
        .panels-grid { grid-template-columns: 1fr; }
    }

    .panel-header { display: flex; align-items: center; gap: 8px; margin-bottom: 20px; font-weight: 700; font-size: 16px; color: var(--text-dark); }
    .panel-header i { color: var(--brand-orange); font-size: 18px; }

    /* Form specific */
    .btn-action {
        background: var(--brand-orange); color: white; border: none; padding: 11px 24px;
        border-radius: 8px; font-weight: 600; font-size: 13.5px; display: inline-flex; align-items: center; gap: 8px;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25); cursor: pointer; transition: all 0.2s ease;
    }
    .btn-action:hover {
        background: #e06908;
        transform: translateY(-1px);
        box-shadow: 0 4px 10px rgba(252, 128, 25, 0.35);
    }

    /* Table styling */
    .audit-table th { font-weight: 600; color: var(--text-muted); font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; padding: 14px 16px; border-bottom: 1px solid var(--border-color); background: #F8FAFC; }
    .audit-table td { padding: 14px 16px; font-size: 13.5px; vertical-align: middle; border-bottom: 1px solid var(--border-color); }
    .audit-table tr:last-child td { border-bottom: none; }

    .status-icon-small {
        width: 24px; height: 24px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center;
        background: #10B981; color: white; font-size: 11px; margin-right: 8px;
    }
    .status-icon-small.orange { background: #fff; border: 1px solid var(--brand-orange); color: var(--brand-orange); }

    .user-tag {
        display: inline-flex; align-items: center; gap: 8px; font-weight: 500;
    }
    .user-avatar {
        width: 26px; height: 26px; border-radius: 50%; background: #FDE68A; color: #D97706;
        display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 700;
    }
    .user-avatar.brand { background: var(--brand-orange-light); color: var(--brand-orange); }
</style>

<div class="page-header-flex">
    <div>
        <h2 style="font-weight: 700; margin-bottom: 6px; color: var(--text-dark); font-size: 24px;">Live Shipment Tracking</h2>
        <div class="custom-breadcrumb d-flex align-items-center" style="margin-bottom: 0; font-size: 13px;">
            <a href="${pageContext.request.contextPath}/dashboard" style="color: var(--text-muted); text-decoration: none;">Dashboard</a>
            <i class="ti ti-chevron-right mx-2" style="font-size: 11px; color: var(--text-muted);"></i>
            <a href="${pageContext.request.contextPath}/shipments" style="color: var(--text-muted); text-decoration: none;">Shipments</a>
            <i class="ti ti-chevron-right mx-2" style="font-size: 11px; color: var(--text-muted);"></i>
            <a href="${pageContext.request.contextPath}/shipments/tracking" style="color: var(--text-muted); text-decoration: none;">Live Tracking</a>
            <i class="ti ti-chevron-right mx-2" style="font-size: 11px; color: var(--text-muted);"></i>
            <span style="color: var(--brand-orange); font-weight: 600;">#SHP-${shipment.shipmentId}</span>
        </div>
    </div>
    <a href="${pageContext.request.contextPath}/shipments/tracking" class="btn btn-light" style="border: 1px solid var(--border-color); font-weight: 600; font-size: 13px; border-radius: 8px; background: #fff; padding: 9px 18px;">
        <i class="ti ti-arrow-left me-1"></i> Back to Tracking Fleet
    </a>
</div>

<!-- Success / Error Alert Banners -->
<c:if test="${not empty sessionScope.successMessage}">
    <div class="alert alert-success d-flex align-items-center mb-4" role="alert" style="border-radius: 10px; border-left: 5px solid #16a34a; background: #f0fdf4; color: #166534;">
        <i class="ti ti-circle-check me-2" style="font-size: 20px;"></i>
        <div style="font-weight: 500; font-size: 13.5px;">${sessionScope.successMessage}</div>
        <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    <c:remove var="successMessage" scope="session" />
</c:if>
<c:if test="${not empty sessionScope.errorMessage}">
    <div class="alert alert-danger d-flex align-items-center mb-4" role="alert" style="border-radius: 10px; border-left: 5px solid #dc2626; background: #fef2f2; color: #991b1b;">
        <i class="ti ti-alert-circle me-2" style="font-size: 20px;"></i>
        <div style="font-weight: 500; font-size: 13.5px;">${sessionScope.errorMessage}</div>
        <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    <c:remove var="errorMessage" scope="session" />
</c:if>

<!-- Top Summary Card -->
<div class="card-panel">
    <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-3">
        <div class="d-flex align-items-center gap-3">
            <div style="width: 48px; height: 48px; background: #FFF2EB; border-radius: 12px; display: flex; align-items: center; justify-content: center; color: var(--brand-orange); font-size: 24px;">
                <i class="ti ti-package"></i>
            </div>
            <div>
                <h4 style="margin: 0; font-weight: 800; color: var(--text-dark); font-size: 20px;">Shipment #SHP-${shipment.shipmentId}</h4>
                <div style="font-size: 12px; color: var(--text-muted); margin-top: 2px;">Created on <fmt:formatDate value="${shipment.bookingDate}" pattern="MMM dd, yyyy" /></div>
            </div>
        </div>
        <div>
            <c:choose>
                <c:when test="${not empty shipment.delayDays && shipment.delayDays > 0}">
                    <div class="badge-delayed">
                        <i class="ti ti-alert-triangle"></i> Delayed by ${shipment.delayDays} Days
                    </div>
                </c:when>
                <c:when test="${shipment.status == 'Delivered'}">
                    <div style="background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; padding: 6px 16px; border-radius: 20px; font-weight: 600; font-size: 13px; display: inline-flex; align-items: center; gap: 6px;">
                        <i class="ti ti-circle-check"></i> Delivered
                    </div>
                </c:when>
                <c:when test="${shipment.status == 'In Transit'}">
                    <div style="background: #EFF6FF; color: #2563EB; border: 1px solid #BFDBFE; padding: 6px 16px; border-radius: 20px; font-weight: 600; font-size: 13px; display: inline-flex; align-items: center; gap: 6px;">
                        <i class="ti ti-navigation"></i> In Transit &bull; On Schedule
                    </div>
                </c:when>
                <c:when test="${shipment.status == 'Customs Hold'}">
                    <div style="background: #FFF7ED; color: #EA580C; border: 1px solid #FED7AA; padding: 6px 16px; border-radius: 20px; font-weight: 600; font-size: 13px; display: inline-flex; align-items: center; gap: 6px;">
                        <i class="ti ti-clock"></i> Customs Hold
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="background: #F8FAFC; color: #475569; border: 1px solid #E2E8F0; padding: 6px 16px; border-radius: 20px; font-weight: 600; font-size: 13px;">
                        ${shipment.status}
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <div class="summary-grid">
        <div class="summary-item">
            <span class="summary-label">Customer</span>
            <span class="summary-value"><i class="ti ti-building" style="color: #64748B;"></i> ${shipment.customerName}</span>
        </div>
        <div class="summary-item">
            <span class="summary-label">Origin Port</span>
            <span class="summary-value"><i class="ti ti-map-pin" style="color: #FC8019;"></i> ${shipment.originPort}</span>
        </div>
        <div class="summary-item">
            <span class="summary-label">Destination Port</span>
            <span class="summary-value"><i class="ti ti-flag" style="color: #10B981;"></i> ${shipment.destPort}</span>
        </div>
        <div class="summary-item">
            <span class="summary-label">Assigned Vessel</span>
            <span class="summary-value"><i class="ti ti-ship" style="color: #64748B;"></i> ${not empty shipment.vesselName ? shipment.vesselName : 'Ocean Vessel'}</span>
        </div>
        <div class="summary-item">
            <span class="summary-label">Container ID</span>
            <span class="summary-value">
                <i class="ti ti-box" style="color: #64748B;"></i> ${shipment.containerNumber}
            </span>
            <div style="font-size: 11px; color: var(--text-muted); margin-top: 4px;">
                ETA: <fmt:formatDate value="${shipment.expectedArrivalDate != null ? shipment.expectedArrivalDate : shipment.eta}" pattern="dd MMM yyyy" />
                <c:if test="${shipment.actualArrivalDate != null}">
                    &nbsp;|&nbsp; Arr: <fmt:formatDate value="${shipment.actualArrivalDate}" pattern="dd MMM yyyy" />
                </c:if>
            </div>
        </div>
    </div>
</div>

<!-- Timeline Tracker Card (SRS FR2.2 & FR2.4) -->
<div class="card-panel">
    <div class="timeline-container">
        <c:set var="sIdx" value="1" />
        <c:choose>
            <c:when test="${shipment.status == 'Booked'}"><c:set var="sIdx" value="1" /></c:when>
            <c:when test="${shipment.status == 'Container Allocated'}"><c:set var="sIdx" value="2" /></c:when>
            <c:when test="${shipment.status == 'Departed'}"><c:set var="sIdx" value="3" /></c:when>
            <c:when test="${shipment.status == 'In Transit'}"><c:set var="sIdx" value="4" /></c:when>
            <c:when test="${shipment.status == 'Customs Hold'}"><c:set var="sIdx" value="5" /></c:when>
            <c:when test="${shipment.status == 'Arrived'}"><c:set var="sIdx" value="6" /></c:when>
            <c:when test="${shipment.status == 'Delivered'}"><c:set var="sIdx" value="7" /></c:when>
            <c:when test="${shipment.status == 'Delayed'}"><c:set var="sIdx" value="4" /></c:when>
        </c:choose>

        <div class="stepper-wrapper">
            <!-- Step 1: Booked -->
            <div class="stepper-item ${sIdx >= 1 ? 'completed' : ''} ${sIdx == 1 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 1}"><div class="step-circle-inner"></c:if>
                    <i class="ti ${sIdx > 1 ? 'ti-check' : 'ti-clipboard-text'}"></i>
                    <c:if test="${sIdx == 1}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title" style="${sIdx > 1 ? 'color: var(--text-dark);' : ''}">Booked</div>
                    <div class="step-date"><fmt:formatDate value="${shipment.bookingDate}" pattern="MMM dd, yyyy" /></div>
                </div>
            </div>

            <!-- Step 2: Container Allocated -->
            <div class="stepper-item ${sIdx >= 2 ? 'completed' : ''} ${sIdx == 2 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 2}"><div class="step-circle-inner"></c:if>
                    <i class="ti ${sIdx > 2 ? 'ti-check' : 'ti-box'}"></i>
                    <c:if test="${sIdx == 2}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title" style="${sIdx > 2 ? 'color: var(--text-dark);' : ''}">Container Allocated</div>
                    <div class="step-date">${sIdx >= 2 ? 'Allocated' : 'Pending'}</div>
                </div>
            </div>

            <!-- Step 3: Departed -->
            <div class="stepper-item ${sIdx >= 3 ? 'completed' : ''} ${sIdx == 3 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 3}"><div class="step-circle-inner"></c:if>
                    <i class="ti ${sIdx > 3 ? 'ti-check' : 'ti-anchor'}"></i>
                    <c:if test="${sIdx == 3}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title" style="${sIdx > 3 ? 'color: var(--text-dark);' : ''}">Departed</div>
                    <div class="step-date">${sIdx >= 3 ? 'Departed' : 'Pending'}</div>
                </div>
            </div>

            <!-- Step 4: In Transit -->
            <div class="stepper-item ${sIdx >= 4 ? 'completed' : ''} ${sIdx == 4 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 4}"><div class="step-circle-inner"></c:if>
                    <i class="ti ${sIdx > 4 ? 'ti-check' : 'ti-navigation'}"></i>
                    <c:if test="${sIdx == 4}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title" style="${sIdx > 4 ? 'color: var(--text-dark);' : ''}">In Transit</div>
                    <div class="step-date">${sIdx >= 4 ? 'En Route' : 'Pending'}</div>
                </div>
            </div>

            <!-- Step 5: Customs Hold -->
            <div class="stepper-item ${sIdx >= 5 ? 'completed' : ''} ${sIdx == 5 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 5}"><div class="step-circle-inner"></c:if>
                    <i class="ti ${sIdx > 5 ? 'ti-check' : 'ti-shield'}"></i>
                    <c:if test="${sIdx == 5}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title" style="${sIdx > 5 ? 'color: var(--text-dark);' : ''}">Customs Hold</div>
                    <div class="step-date">${sIdx == 5 ? 'Inspection' : (sIdx > 5 ? 'Cleared' : 'Optional')}</div>
                </div>
            </div>

            <!-- Step 6: Arrived -->
            <div class="stepper-item ${sIdx >= 6 ? 'completed' : ''} ${sIdx == 6 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 6}"><div class="step-circle-inner"></c:if>
                    <i class="ti ${sIdx > 6 ? 'ti-check' : 'ti-building-warehouse'}"></i>
                    <c:if test="${sIdx == 6}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title" style="${sIdx > 6 ? 'color: var(--text-dark);' : ''}">Arrived</div>
                    <div class="step-date">${sIdx >= 6 ? 'At Port' : 'Expected'}</div>
                </div>
            </div>

            <!-- Step 7: Delivered -->
            <div class="stepper-item ${sIdx >= 7 ? 'completed' : ''} ${sIdx == 7 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 7}"><div class="step-circle-inner"></c:if>
                    <i class="ti ${sIdx == 7 ? 'ti-check' : 'ti-circle-check'}"></i>
                    <c:if test="${sIdx == 7}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title" style="${sIdx == 7 ? 'color: #10B981;' : ''}">Delivered</div>
                    <div class="step-date">${sIdx == 7 ? 'Completed' : 'Final'}</div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="panels-grid">
    <!-- Live Form Panel: Record Next Checkpoint -->
    <div class="card-panel" style="margin-bottom: 0;">
        <div class="panel-header">
            <i class="ti ti-edit"></i> Record Next Checkpoint
        </div>
        <form action="${pageContext.request.contextPath}/shipments/updateStatus" method="POST" id="checkpointForm">
            <input type="hidden" name="shipmentId" value="${shipment.shipmentId}">
            <input type="hidden" name="redirectUrl" value="${pageContext.request.contextPath}/shipments/tracking/detail?id=SHP-${shipment.shipmentId}">
            <div class="row g-3">
                <div class="col-md-5">
                    <label class="form-label" style="font-weight: 600; font-size: 13px; margin-bottom: 6px;">Next Checkpoint Status <span style="color: #FC8019;">*</span></label>
                    <select name="status" class="form-select form-select-custom" required style="padding: 10px 14px; border-radius: 8px; font-size: 13.5px; border: 1px solid #E2E8F0;">
                        <option value="" disabled>Select next status</option>
                        <option value="Container Allocated" <c:if test="${shipment.status == 'Booked'}">selected</c:if>>Container Allocated</option>
                        <option value="Departed" <c:if test="${shipment.status == 'Container Allocated'}">selected</c:if>>Departed</option>
                        <option value="In Transit" <c:if test="${shipment.status == 'Departed'}">selected</c:if>>In Transit</option>
                        <option value="Customs Hold" <c:if test="${shipment.status == 'In Transit'}">selected</c:if>>Customs Hold</option>
                        <option value="Arrived" <c:if test="${shipment.status == 'Customs Hold'}">selected</c:if>>Arrived</option>
                        <option value="Delivered" <c:if test="${shipment.status == 'Arrived'}">selected</c:if>>Delivered</option>
                    </select>
                </div>
                <div class="col-md-7">
                    <label class="form-label" style="font-weight: 600; font-size: 13px; margin-bottom: 6px;">Status Remarks & Location <span style="color: #FC8019;">*</span></label>
                    <textarea name="remarks" id="statusRemarks" class="form-control" rows="2" maxlength="500" placeholder="e.g. Vessel cleared port terminal pier 4, cargo dispatched..." style="border-radius: 8px; font-size: 13px; resize: none; border: 1px solid #E2E8F0;" required></textarea>
                    <div style="display: flex; justify-content: space-between; font-size: 11px; color: var(--text-muted); margin-top: 4px;">
                        <span>Attributed to your staff login session</span>
                        <span id="charCount">0 / 500</span>
                    </div>
                </div>
            </div>
            <div class="mt-4">
                <button type="submit" class="btn-action">
                    <i class="ti ti-circle-plus"></i> Record Checkpoint <i class="ti ti-arrow-right"></i>
                </button>
            </div>
        </form>
    </div>

    <!-- Summary Panel (Real Database Data) -->
    <div class="card-panel" style="margin-bottom: 0;">
        <div class="panel-header" style="color: var(--text-dark);">
            <i class="ti ti-notes"></i> Shipment Summary
        </div>

        <div class="d-flex justify-content-between border-bottom py-2" style="font-size: 13px;">
            <div style="color: var(--text-muted);"><i class="ti ti-calendar me-2"></i> Booking Date</div>
            <div style="font-weight: 600;"><fmt:formatDate value="${shipment.bookingDate}" pattern="MMM dd, yyyy" /></div>
        </div>
        <div class="d-flex justify-content-between border-bottom py-2 mt-2" style="font-size: 13px;">
            <div style="color: var(--text-muted);"><i class="ti ti-box me-2"></i> Container ID</div>
            <div style="font-weight: 600;">${shipment.containerNumber}</div>
        </div>
        <div class="d-flex justify-content-between border-bottom py-2 mt-2" style="font-size: 13px;">
            <div style="color: var(--text-muted);"><i class="ti ti-ship me-2"></i> Vessel</div>
            <div style="font-weight: 600;">${not empty shipment.vesselName ? shipment.vesselName : 'Ocean Vessel'}</div>
        </div>
        <div class="d-flex justify-content-between border-bottom py-2 mt-2" style="font-size: 13px;">
            <div style="color: var(--text-muted);"><i class="ti ti-map-pin me-2"></i> Origin Port</div>
            <div style="font-weight: 600;">${shipment.originPort}</div>
        </div>
        <div class="d-flex justify-content-between py-2 mt-2" style="font-size: 13px;">
            <div style="color: var(--text-muted);"><i class="ti ti-flag me-2"></i> Destination Port</div>
            <div style="font-weight: 600;">${shipment.destPort}</div>
        </div>
    </div>
</div>

<!-- Audit Log (100% Real DB container_movements Data) -->
<div class="card-panel">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div class="panel-header" style="margin-bottom: 0;">
            <i class="ti ti-history"></i> Checkpoint Audit Trail
        </div>
        <span class="badge" style="background: #F1F5F9; color: #475569; font-weight: 600; padding: 6px 12px; border-radius: 8px;">
            ${fn:length(logs)} events logged
        </span>
    </div>

    <div class="table-responsive">
        <table class="table audit-table">
            <thead>
                <tr>
                    <th style="width: 22%;">Milestone Status</th>
                    <th style="width: 22%;">Recorded At</th>
                    <th style="width: 22%;">Attributed Staff</th>
                    <th style="width: 34%;">Checkpoint Remarks & Location</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="log" items="${logs}">
                    <tr>
                        <td>
                            <div class="d-flex align-items-center">
                                <div class="status-icon-small">
                                    <i class="ti ti-check"></i>
                                </div>
                                <span style="font-weight: 600; color: #1F2937;">${log.status}</span>
                            </div>
                        </td>
                        <td style="color: #64748B; font-weight: 500;">
                            <fmt:formatDate value="${log.updatedAt}" pattern="MMM dd, yyyy, hh:mm a" />
                        </td>
                        <td>
                            <div class="user-tag">
                                <div class="user-avatar brand">
                                    <c:choose>
                                        <c:when test="${not empty log.updatedBy}">
                                            ${fn:substring(log.updatedBy, 0, 2).toUpperCase()}
                                        </c:when>
                                        <c:otherwise>OP</c:otherwise>
                                    </c:choose>
                                </div>
                                <span style="font-weight: 600; color: #374151;">${not empty log.updatedBy ? log.updatedBy : 'System Operator'}</span>
                            </div>
                        </td>
                        <td style="color: #4B5563;">
                            ${not empty log.checkpointLocation ? log.checkpointLocation : 'Checkpoint reached and verified.'}
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty logs}">
                    <tr>
                        <td colspan="4" style="text-align: center; color: var(--text-muted); padding: 32px;">
                            <i class="ti ti-info-circle mb-1" style="font-size: 22px; display: block;"></i>
                            No tracking checkpoints logged yet for this shipment. Record the first milestone above!
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    const remarksInput = document.getElementById('statusRemarks');
    const charCount = document.getElementById('charCount');
    if (remarksInput && charCount) {
        remarksInput.addEventListener('input', function() {
            charCount.textContent = this.value.length + ' / 500';
        });
    }
});
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
