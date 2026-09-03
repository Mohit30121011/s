<%@ page language="java" contentType="text/html; charset=UTF-8" session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* Tracking Specific Styles */
    .page-header-flex { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
    
    .card-panel {
        background: #fff; border-radius: 12px; border: 1px solid var(--border-color);
        box-shadow: 0 1px 3px rgba(0,0,0,0.02); padding: 24px; margin-bottom: 24px;
    }
    
    .badge-delayed {
        background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA;
        padding: 6px 16px; border-radius: 20px; font-weight: 600; font-size: 13px;
        display: inline-flex; align-items: center; gap: 8px;
    }
    
    .summary-grid {
        display: grid; grid-template-columns: repeat(5, 1fr); gap: 24px; margin-top: 24px;
    }
    .summary-item { font-size: 13px; }
    .summary-label { color: var(--text-muted); margin-bottom: 4px; display: block; }
    .summary-value { font-weight: 600; color: var(--text-dark); display: flex; align-items: center; gap: 6px; }

    /* Timeline Stepper */
    .timeline-container { padding: 40px 20px 20px 20px; }
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
    .stepper-item.active::before {
        background: linear-gradient(to right, #10B981 50%, #E5E7EB 50%); /* Transition from green to grey */
    }
    /* Special case if active is not Customs Hold but standard progress */
    .stepper-item.active-orange::before { background: #10B981; }

    .step-circle {
        width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center;
        background: #fff; position: relative; z-index: 1; border: 2px solid #E5E7EB; color: #9CA3AF; font-size: 16px; margin-bottom: 16px;
    }
    .stepper-item.completed .step-circle {
        background: #10B981; border-color: #10B981; color: white;
    }
    .stepper-item.active-orange .step-circle {
        width: 60px; height: 60px; border: 2px solid #FFEBE0; background: #fff;
        color: var(--brand-orange); font-size: 24px; transform: translateY(-10px);
        box-shadow: 0 0 0 4px #FFF8F5; /* Halo effect */
    }
    .stepper-item.active-orange .step-circle-inner {
        width: 48px; height: 48px; border-radius: 50%; border: 2px solid var(--brand-orange);
        display: flex; align-items: center; justify-content: center;
    }
    
    .step-text { text-align: center; font-size: 12px; }
    .step-title { font-weight: 700; color: var(--text-dark); margin-bottom: 4px; font-size: 13px; }
    .step-date { color: var(--text-muted); }
    .stepper-item.active-orange .step-title { color: var(--brand-orange); }

    /* Panels Grid */
    .panels-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 24px; margin-bottom: 24px; }
    
    .panel-header { display: flex; align-items: center; gap: 8px; margin-bottom: 20px; font-weight: 700; font-size: 15px; }
    .panel-header i { color: var(--brand-orange); font-size: 18px; }

    /* Form specific */
    .btn-action {
        background: var(--brand-orange); color: white; border: none; padding: 10px 24px;
        border-radius: 8px; font-weight: 600; display: inline-flex; align-items: center; gap: 8px;
    }
    
    /* Table styling */
    .audit-table th { font-weight: 600; color: var(--text-muted); font-size: 12px; text-transform: uppercase; padding: 12px 16px; border-bottom: 1px solid var(--border-color); }
    .audit-table td { padding: 16px; font-size: 13px; vertical-align: middle; border-bottom: 1px solid var(--border-color); }
    .audit-table tr:last-child td { border-bottom: none; }
    
    .status-icon-small {
        width: 24px; height: 24px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center;
        background: #10B981; color: white; font-size: 10px; margin-right: 8px;
    }
    .status-icon-small.orange { background: #fff; border: 1px solid var(--brand-orange); color: var(--brand-orange); }
    
    .user-tag {
        display: inline-flex; align-items: center; gap: 8px; font-weight: 500;
    }
    .user-avatar {
        width: 24px; height: 24px; border-radius: 50%; background: #FDE68A; color: #D97706;
        display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 700;
    }
    .user-avatar.brand { background: var(--brand-orange-light); color: var(--brand-orange); }
</style>

<div class="page-header-flex">
    <div>
        <h2 style="font-weight: 700; margin-bottom: 8px; color: var(--text-dark);">Live Shipment Tracking</h2>
        <div class="custom-breadcrumb d-flex align-items-center" style="margin-bottom: 0;">
            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <i class="fa-solid fa-angle-right custom-breadcrumb-separator"></i>
            <a href="${pageContext.request.contextPath}/shipments">Shipments</a>
            <i class="fa-solid fa-angle-right custom-breadcrumb-separator"></i>
            <a href="${pageContext.request.contextPath}/shipments/tracking">Live Tracking</a>
            <i class="fa-solid fa-angle-right custom-breadcrumb-separator"></i>
            <span class="active">SHP-${shipment.shipmentId}</span>
        </div>
    </div>
    <a href="${pageContext.request.contextPath}/shipments" class="btn btn-light" style="border: 1px solid var(--border-color); font-weight: 600; font-size: 13px; border-radius: 8px;">
        <i class="fa-solid fa-arrow-left me-2"></i> Back to Shipments
    </a>
</div>

<!-- Top Summary Card -->
<div class="card-panel">
    <div class="d-flex justify-content-between align-items-start border-bottom pb-4 mb-4">
        <div class="d-flex align-items-center gap-3">
            <div style="width: 48px; height: 48px; background: var(--brand-orange); border-radius: 12px; display: flex; align-items: center; justify-content: center; color: white; font-size: 24px;">
                <i class="fa-solid fa-box"></i>
            </div>
            <div>
                <h4 style="margin: 0; font-weight: 800; color: var(--text-dark);">Shipment #SHP-${shipment.shipmentId}</h4>
            </div>
        </div>
        <c:choose>
            <c:when test="${not empty shipment.delayDays && shipment.delayDays > 0}">
                <div class="badge-delayed">
                    <i class="ti ti-alert-triangle"></i> Delayed by ${shipment.delayDays} Days
                </div>
            </c:when>
            <c:when test="${shipment.status == 'Delivered'}">
                <div class="status-badge" style="background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; padding: 6px 16px; border-radius: 20px; font-weight: 600; font-size: 13px;">
                    <i class="ti ti-circle-check me-1"></i> Delivered Successfully
                </div>
            </c:when>
            <c:when test="${shipment.status == 'In Transit'}">
                <div class="status-badge" style="background: #EFF6FF; color: #2563EB; border: 1px solid #BFDBFE; padding: 6px 16px; border-radius: 20px; font-weight: 600; font-size: 13px;">
                    <i class="ti ti-navigation me-1"></i> In Transit &bull; On Schedule
                </div>
            </c:when>
            <c:when test="${shipment.status == 'Customs Hold'}">
                <div class="status-badge" style="background: #FFF7ED; color: #EA580C; border: 1px solid #FED7AA; padding: 6px 16px; border-radius: 20px; font-weight: 600; font-size: 13px;">
                    <i class="ti ti-clock me-1"></i> Customs Hold
                </div>
            </c:when>
            <c:otherwise>
                <div class="status-badge" style="background: #F8FAFC; color: #475569; border: 1px solid #E2E8F0; padding: 6px 16px; border-radius: 20px; font-weight: 600; font-size: 13px;">
                    ${shipment.status}
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    
    <div class="summary-grid">
        <div class="summary-item">
            <span class="summary-label">Customer</span>
            <span class="summary-value">${shipment.customerName}</span>
        </div>
        <div class="summary-item">
            <span class="summary-label">Origin</span>
            <span class="summary-value">${shipment.originPort}</span>
        </div>
        <div class="summary-item">
            <span class="summary-label">Destination</span>
            <span class="summary-value">${shipment.destPort}</span>
        </div>
        <div class="summary-item">
            <span class="summary-label">Vessel</span>
            <span class="summary-value">${shipment.vesselName}</span>
        </div>
        <div class="summary-item">
            <span class="summary-label">Container ID</span>
            <span class="summary-value">
                ${shipment.containerNumber} <i class="fa-regular fa-copy" style="color: var(--text-muted); cursor: pointer;"></i>
            </span>
            <div style="font-size: 11px; color: var(--text-muted); margin-top: 4px;">
                Expected: <fmt:formatDate value="${shipment.expectedArrivalDate != null ? shipment.expectedArrivalDate : shipment.eta}" pattern="dd MMM yyyy" />
                <c:if test="${shipment.actualArrivalDate != null}">
                    &nbsp;|&nbsp; Actual: <fmt:formatDate value="${shipment.actualArrivalDate}" pattern="dd MMM yyyy" />
                </c:if>
            </div>
        </div>
    </div>
</div>

<!-- Timeline Tracker Card -->
<div class="card-panel">
    <div class="timeline-container">
        <c:set var="sIdx" value="0" />
        <c:choose>
            <c:when test="${shipment.status == 'Booked'}"><c:set var="sIdx" value="1" /></c:when>
            <c:when test="${shipment.status == 'Container Allocated'}"><c:set var="sIdx" value="2" /></c:when>
            <c:when test="${shipment.status == 'Departed'}"><c:set var="sIdx" value="3" /></c:when>
            <c:when test="${shipment.status == 'In Transit' || shipment.status == 'Delayed'}"><c:set var="sIdx" value="4" /></c:when>
            <c:when test="${shipment.status == 'Customs Hold'}"><c:set var="sIdx" value="5" /></c:when>
            <c:when test="${shipment.status == 'Arrived'}"><c:set var="sIdx" value="6" /></c:when>
            <c:when test="${shipment.status == 'Delivered'}"><c:set var="sIdx" value="7" /></c:when>
        </c:choose>

        <div class="stepper-wrapper">
            <!-- Step 1: Booked -->
            <div class="stepper-item ${sIdx >= 1 ? 'completed' : ''} ${sIdx == 1 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 1}"><div class="step-circle-inner"></c:if>
                    <i class="fa-solid ${sIdx > 1 ? 'fa-check' : 'fa-clipboard'}"></i>
                    <c:if test="${sIdx == 1}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title" style="${sIdx > 1 ? 'color: var(--text-dark);' : ''}">Booked</div>
                    <div class="step-date">${shipment.bookingDate}<br>10:30 AM</div>
                </div>
            </div>

            <!-- Step 2: Container Allocated -->
            <div class="stepper-item ${sIdx >= 2 ? 'completed' : ''} ${sIdx == 2 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 2}"><div class="step-circle-inner"></c:if>
                    <i class="fa-solid ${sIdx > 2 ? 'fa-check' : 'fa-box'}"></i>
                    <c:if test="${sIdx == 2}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title" style="${sIdx > 2 ? 'color: var(--text-dark);' : ''}">Container Allocated</div>
                    <div class="step-date">${sIdx >= 2 ? shipment.bookingDate : 'Expected'}<br>${sIdx >= 2 ? '02:15 PM' : ''}</div>
                </div>
            </div>

            <!-- Step 3: Departed -->
            <div class="stepper-item ${sIdx >= 3 ? 'completed' : ''} ${sIdx == 3 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 3}"><div class="step-circle-inner"></c:if>
                    <i class="fa-solid ${sIdx > 3 ? 'fa-check' : 'fa-anchor'}"></i>
                    <c:if test="${sIdx == 3}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title" style="${sIdx > 3 ? 'color: var(--text-dark);' : ''}">Departed</div>
                    <div class="step-date">${sIdx >= 3 ? '21 May 2025' : 'Expected'}<br>${sIdx >= 3 ? '08:45 AM' : ''}</div>
                </div>
            </div>

            <!-- Step 4: In Transit -->
            <div class="stepper-item ${sIdx >= 4 ? 'completed' : ''} ${sIdx == 4 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 4}"><div class="step-circle-inner"></c:if>
                    <i class="fa-solid ${sIdx > 4 ? 'fa-check' : 'fa-route'}"></i>
                    <c:if test="${sIdx == 4}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title" style="${sIdx > 4 ? 'color: var(--text-dark);' : ''}">In Transit</div>
                    <div class="step-date">${sIdx >= 4 ? '21 May 2025' : 'Expected'}<br>${sIdx >= 4 ? '09:30 AM' : ''}</div>
                </div>
            </div>

            <!-- Step 5: Customs Hold -->
            <div class="stepper-item ${sIdx >= 5 ? 'completed' : ''} ${sIdx == 5 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 5}"><div class="step-circle-inner"></c:if>
                    <i class="fa-solid ${sIdx > 5 ? 'fa-check' : 'fa-ship'}"></i>
                    <c:if test="${sIdx == 5}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title" style="${sIdx > 5 ? 'color: var(--text-dark);' : ''}">Customs Hold</div>
                    <div class="step-date">${sIdx == 5 ? 'Current Status' : (sIdx > 5 ? '08 Jun 2025' : 'Expected')}</div>
                </div>
            </div>

            <!-- Step 6: Arrived -->
            <div class="stepper-item ${sIdx >= 6 ? 'completed' : ''} ${sIdx == 6 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 6}"><div class="step-circle-inner"></c:if>
                    <i class="fa-solid ${sIdx > 6 ? 'fa-check' : 'fa-house'}"></i>
                    <c:if test="${sIdx == 6}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title" style="${sIdx > 6 ? 'color: var(--text-dark);' : ''}">Arrived</div>
                    <div class="step-date">Expected<br>10 Jun 2025</div>
                </div>
            </div>

            <!-- Step 7: Delivered -->
            <div class="stepper-item ${sIdx >= 7 ? 'completed' : ''} ${sIdx == 7 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 7}"><div class="step-circle-inner"></c:if>
                    <i class="fa-solid ${sIdx > 7 ? 'fa-check' : 'fa-clipboard-check'}"></i>
                    <c:if test="${sIdx == 7}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title" style="${sIdx > 7 ? 'color: var(--text-dark);' : ''}">Delivered</div>
                    <div class="step-date">Expected<br>10 Jun 2025</div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="panels-grid">
    <!-- Form Panel -->
    <div class="card-panel" style="margin-bottom: 0;">
        <div class="panel-header">
            <i class="fa-solid fa-pen-to-square"></i> Record Next Checkpoint
        </div>
        <form>
            <div class="row g-4">
                <div class="col-md-5">
                    <label style="font-weight: 600; font-size: 13px; margin-bottom: 8px;">Next Status <span style="color: red;">*</span></label>
                    <select class="form-select form-select-custom" style="padding: 10px 16px; border-radius: 8px; font-size: 13px;">
                        <option value="" disabled selected>Select next status</option>
                        <option>Cleared Customs</option>
                        <option>Arrived</option>
                        <option>Delivered</option>
                    </select>
                </div>
                <div class="col-md-7">
                    <label style="font-weight: 600; font-size: 13px; margin-bottom: 8px;">Status Remarks <span style="color: red;">*</span></label>
                    <textarea class="form-control" rows="2" placeholder="Enter status remarks, location, document reference, etc." style="border-radius: 8px; font-size: 13px; resize: none;"></textarea>
                    <div style="text-align: right; font-size: 11px; color: var(--text-muted); margin-top: 4px;">0 / 500</div>
                </div>
            </div>
            <div class="mt-4">
                <button type="button" class="btn-action">Record Checkpoint <i class="fa-solid fa-arrow-right"></i></button>
            </div>
        </form>
    </div>

    <!-- Summary Panel -->
    <div class="card-panel" style="margin-bottom: 0;">
        <div class="panel-header" style="color: var(--text-dark);">
            Shipment Summary
        </div>
        
        <div class="d-flex justify-content-between border-bottom py-2" style="font-size: 13px;">
            <div style="color: var(--text-muted);"><i class="fa-regular fa-calendar me-2"></i> Booking Date</div>
            <div style="font-weight: 500;">${shipment.bookingDate}</div>
        </div>
        <div class="d-flex justify-content-between border-bottom py-2 mt-2" style="font-size: 13px;">
            <div style="color: var(--text-muted);"><i class="fa-solid fa-box me-2"></i> Container ID</div>
            <div style="font-weight: 500;">${shipment.containerNumber}</div>
        </div>
        <div class="d-flex justify-content-between border-bottom py-2 mt-2" style="font-size: 13px;">
            <div style="color: var(--text-muted);"><i class="fa-solid fa-ship me-2"></i> Vessel</div>
            <div style="font-weight: 500;">${shipment.vesselName}</div>
        </div>
        <div class="d-flex justify-content-between border-bottom py-2 mt-2" style="font-size: 13px;">
            <div style="color: var(--text-muted);"><i class="fa-solid fa-location-dot me-2"></i> Origin Port</div>
            <div style="font-weight: 500;">Shanghai Port, China</div>
        </div>
        <div class="d-flex justify-content-between py-2 mt-2" style="font-size: 13px;">
            <div style="color: var(--text-muted);"><i class="fa-regular fa-flag me-2"></i> Destination Port</div>
            <div style="font-weight: 500;">Los Angeles Port, USA</div>
        </div>
    </div>
</div>

<!-- Audit Log -->
<div class="card-panel">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div class="panel-header" style="margin-bottom: 0;">
            <i class="fa-regular fa-file-lines"></i> Audit Log
        </div>
        <div class="d-flex gap-3" style="color: var(--text-muted);">
            <i class="fa-solid fa-magnifying-glass" style="cursor: pointer;"></i>
            <i class="fa-solid fa-filter" style="cursor: pointer;"></i>
            <i class="fa-solid fa-download" style="cursor: pointer;"></i>
        </div>
    </div>

    <div class="table-responsive">
        <table class="table audit-table">
            <thead>
                <tr>
                    <th style="width: 20%;">Status</th>
                    <th style="width: 20%;">Timestamp</th>
                    <th style="width: 20%;">Recorded By</th>
                    <th style="width: 40%;">Remarks</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><div class="status-icon-small"><i class="fa-solid fa-check"></i></div> <span style="font-weight: 600;">Booked</span></td>
                    <td>${shipment.bookingDate}, 10:30 AM</td>
                    <td><div class="user-tag"><div class="user-avatar brand">SK</div> Suresh Kumar</div></td>
                    <td>Shipment booked by sales team.</td>
                </tr>
                <tr>
                    <td><div class="status-icon-small"><i class="fa-solid fa-check"></i></div> <span style="font-weight: 600;">Container Allocated</span></td>
                    <td>${shipment.bookingDate}, 02:15 PM</td>
                    <td><div class="user-tag"><div class="user-avatar">PR</div> Priya Reddy</div></td>
                    <td>Container ${shipment.containerNumber} allocated.</td>
                </tr>
                <tr>
                    <td><div class="status-icon-small"><i class="fa-solid fa-check"></i></div> <span style="font-weight: 600;">Departed</span></td>
                    <td>21 May 2025, 08:45 AM</td>
                    <td><div class="user-tag"><div class="user-avatar brand">AM</div> Arvind Mehta</div></td>
                    <td>Vessel departed from Shanghai Port.</td>
                </tr>
                <tr>
                    <td><div class="status-icon-small"><i class="fa-solid fa-check"></i></div> <span style="font-weight: 600;">In Transit</span></td>
                    <td>21 May 2025, 09:30 AM</td>
                    <td><div class="user-tag"><div class="user-avatar brand">AM</div> Arvind Mehta</div></td>
                    <td>Shipment is in transit.</td>
                </tr>
                <tr>
                    <td><div class="status-icon-small orange"><i class="fa-solid fa-ship"></i></div> <span style="font-weight: 600; color: var(--text-dark);">Customs Hold</span></td>
                    <td>08 Jun 2025, 11:20 AM</td>
                    <td><div class="user-tag"><div class="user-avatar">NJ</div> Neha Joshi</div></td>
                    <td>Shipment is on hold at Long Beach Customs for documentation.</td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />











