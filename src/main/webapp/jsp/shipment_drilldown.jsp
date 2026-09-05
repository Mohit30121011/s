<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%-- Data is supplied exclusively by FinanceServlet (/finance/shipment-drilldown).
     The previous inline fallback loaded any shipment id with no ownership check. --%>
<jsp:include page="/jsp/layout/header.jsp" />
<!-- Flaticons UIcons -->
<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-regular-rounded/css/uicons-regular-rounded.css'>
<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-solid-rounded/css/uicons-solid-rounded.css'>

<style>
    :root {
        --text-main: #1F2937;
        --text-muted: #6B7280;
        --border-color: #E5E7EB;
        --bg-surface: #FFFFFF;
        --red-main: #EF4444;
        --red-light: #FEE2E2;
        --green-main: #10B981;
        --green-light: #D1FAE5;
        --orange-main: #FC8019;
        --orange-light: #FFEDD5;
        --orange-brand: #FC8019;
    }

    body { background-color: #F9FAFB; }
    
    .main-content {
        padding: 24px 32px;
        max-width: 1400px;
        margin: 0 auto;
    }

    /* Header */
    .dashboard-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 24px;
    }
    
    .breadcrumb-nav {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 13px;
        color: var(--text-muted);
        margin-bottom: 8px;
    }
    
    .breadcrumb-nav a {
        color: var(--text-muted);
        text-decoration: none;
    }
    .breadcrumb-nav .active {
        color: var(--orange-brand);
        font-weight: 500;
    }

    .page-title-wrap {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .back-btn {
        color: var(--text-main);
        font-size: 18px;
        text-decoration: none;
    }

    .page-title {
        font-size: 24px;
        font-weight: 700;
        color: var(--text-main);
        margin: 0;
    }

    /* Shipment Meta Card */
    .shipment-card {
        background: var(--bg-surface);
        border-radius: 16px;
        padding: 24px 32px;
        margin-bottom: 24px;
        display: flex;
        flex-wrap: wrap;
        gap: 32px;
        align-items: center;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }
    
    .meta-col {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }
    .meta-label {
        font-size: 12px;
        color: var(--text-muted);
    }
    .meta-value {
        font-size: 14px;
        font-weight: 600;
        color: var(--text-main);
    }
    .shipment-id-value {
        font-size: 20px;
        font-weight: 700;
    }
    
    .badge-delayed {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: var(--red-light);
        color: var(--red-main);
        padding: 4px 10px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 600;
        margin-top: 4px;
    }
    .badge-status {
        display: inline-flex;
        background: var(--orange-light);
        color: var(--orange-brand);
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 600;
        border: 1px solid rgba(252, 128, 25, 0.2);
    }

    /* Route Timeline */
    .route-timeline {
        display: flex;
        align-items: center;
        justify-content: center;
        flex: 1;
        padding: 0 40px;
    }
    .port-node {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 4px;
    }
    .port-node-title {
        font-size: 12px;
        font-weight: 600;
        color: var(--text-main);
    }
    .port-node-country {
        font-size: 11px;
        color: var(--text-muted);
    }
    .node-icon {
        width: 16px;
        height: 16px;
        background: var(--orange-brand);
        border: 3px solid #FFF;
        box-shadow: 0 0 0 2px var(--orange-light);
        border-radius: 50%;
        margin-top: 8px;
    }
    .timeline-line {
        flex: 1;
        height: 2px;
        background: repeating-linear-gradient(90deg, var(--orange-brand) 0, var(--orange-brand) 6px, transparent 6px, transparent 12px);
        margin: 24px 16px 0;
        position: relative;
    }
    .timeline-ship {
        position: absolute;
        top: -24px;
        left: 50%;
        transform: translateX(-50%);
        color: var(--orange-brand);
        font-size: 18px;
    }

    /* Two Column Layout */
    .grid-container {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 24px;
    }
    
    .panel-card {
        background: var(--bg-surface);
        border-radius: 16px;
        padding: 24px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }
    
    .panel-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 24px;
        padding-bottom: 16px;
        border-bottom: 1px solid var(--border-color);
    }
    .panel-title {
        font-size: 18px;
        font-weight: 700;
        margin: 0;
    }
    .panel-subtitle {
        font-size: 13px;
        color: var(--text-muted);
        margin-top: 4px;
    }
    
    
    .btn-outline-custom {
        padding: 8px 16px;
        border: 1px solid var(--border-color);
        background: white;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 8px;
    }

    .btn-outline {
        padding: 6px 12px;
        border: 1px solid var(--border-color);
        background: white;
        border-radius: 8px;
        font-size: 13px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 8px;
        cursor: pointer;
    }

    /* Financial Breakdown */
    .finance-grid {
        display: grid;
        grid-template-columns: 1fr 1px 1.2fr;
        gap: 32px;
    }
    .finance-list {
        display: flex;
        flex-direction: column;
        gap: 16px;
    }
    .finance-item {
        display: flex;
        justify-content: space-between;
        font-size: 13px;
        color: var(--text-main);
    }
    .finance-item.total {
        font-weight: 700;
        font-size: 14px;
        margin-top: 16px;
        padding-top: 16px;
        border-top: 1px solid var(--border-color);
    }
    .total-rev { color: var(--green-main); }
    .total-cost { color: var(--red-main); }
    
    .section-title {
        font-size: 12px;
        font-weight: 700;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .title-rev { color: var(--green-main); }
    .title-cost { color: var(--red-main); }
    
    .finance-divider {
        width: 1px;
        background: var(--border-color);
    }
    
    /* Net Loss Box */
    .net-loss-box {
        margin-top: 24px;
        background: var(--red-light);
        border: 1px solid rgba(239, 68, 68, 0.2);
        border-radius: 12px;
        padding: 24px;
        display: flex;
        justify-content: space-between;
        align-items: flex-end;
    }
    .net-loss-label {
        font-size: 12px;
        font-weight: 700;
        color: var(--text-muted);
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 8px;
    }
    .net-loss-value {
        font-size: 32px;
        font-weight: 800;
        color: var(--red-main);
        line-height: 1;
    }
    .net-loss-sub {
        font-size: 12px;
        color: var(--text-muted);
        margin-top: 8px;
    }
    .net-loss-icon {
        width: 48px;
        height: 48px;
        background: white;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--red-main);
        font-size: 20px;
        box-shadow: 0 2px 4px rgba(239, 68, 68, 0.1);
    }

    /* Reasons Cards */
    .reasons-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 12px;
        margin-bottom: 24px;
    }
    .reason-card {
        border: 1px solid var(--border-color);
        border-radius: 12px;
        padding: 16px 8px;
        text-align: center;
        cursor: pointer;
        position: relative;
        transition: all 0.2s;
        background: white;
    }
    .reason-card:hover {
        border-color: #D1D5DB;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }
    .reason-card.selected {
        border-color: var(--red-main);
        background: var(--red-light);
    }
    .reason-icon {
        font-size: 20px;
        color: var(--text-main);
        margin-bottom: 8px;
    }
    .reason-name {
        font-size: 11px;
        font-weight: 500;
        color: var(--text-main);
        line-height: 1.2;
    }
    .reason-checkbox {
        position: absolute;
        top: -6px;
        right: -6px;
        width: 16px;
        height: 16px;
        background: var(--red-main);
        color: white;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 9px;
        opacity: 0;
        transform: scale(0.8);
        transition: all 0.2s;
    }
    .reason-card.selected .reason-checkbox {
        opacity: 1;
        transform: scale(1);
    }
    
    /* Custom Reason input */
    .input-label {
        font-size: 13px;
        font-weight: 600;
        color: var(--text-main);
        margin-bottom: 8px;
        display: block;
    }
    .custom-input {
        width: 100%;
        padding: 10px 16px;
        border: 1px solid var(--border-color);
        border-radius: 8px;
        font-size: 14px;
        outline: none;
    }
    .custom-tags {
        display: flex;
        gap: 8px;
        margin-top: 12px;
        flex-wrap: wrap;
    }
    .tag {
        background: var(--red-light);
        color: var(--red-main);
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 500;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .tag i { cursor: pointer; }
    
    .remarks-input {
        width: 100%;
        border: 1px solid var(--border-color);
        border-radius: 8px;
        padding: 12px;
        font-size: 13px;
        resize: none;
        height: 80px;
        outline: none;
        margin-top: 24px;
    }
    
    .action-row {
        display: flex;
        gap: 16px;
        margin-top: 24px;
    }
    .btn-save {
        flex: 1;
        background: var(--orange-brand);
        color: white;
        border: none;
        border-radius: 8px;
        padding: 12px;
        font-weight: 600;
        font-size: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        cursor: pointer;
    }
    .btn-cancel {
        padding: 12px 32px;
        background: white;
        border: 1px solid var(--border-color);
        border-radius: 8px;
        font-weight: 600;
        font-size: 14px;
        cursor: pointer;
    }
</style>

<div class="main-content" id="drilldownContent">
    <div class="dashboard-header">
        <div>
            <div class="breadcrumb-nav">
                <a href="#">Dashboard</a> <i class="fa-solid fa-chevron-right" style="font-size:10px"></i>
                <a href="#">Finance</a> <i class="fa-solid fa-chevron-right" style="font-size:10px"></i>
                <a href="${pageContext.request.contextPath}/finance/profit-loss">Profit & Loss</a> <i class="fa-solid fa-chevron-right" style="font-size:10px"></i>
                <span class="active">Shipment Financial Drill-Down</span>
            </div>
            <div class="page-title-wrap">
                <a href="${pageContext.request.contextPath}/finance/profit-loss" class="back-btn"><i class="fa-solid fa-arrow-left"></i></a>
                <h1 class="page-title">Shipment Financial Drill-Down</h1>
            </div>
        </div>
        <button class="btn-outline-custom" onclick="exportDrilldown()"><i class="fa-solid fa-download"></i> Export</button>
    </div>

    <!-- Shipment Meta Card -->
    <div class="shipment-card">
        <div class="meta-col" style="min-width: 150px;">
            <div class="meta-label">Shipment ID</div>
            <div class="shipment-id-value">SHP-${drilldown.shipmentId}</div>
            <div class="badge-delayed"><i class="fa-solid fa-triangle-exclamation"></i> Delayed by 4 Days</div>
        </div>
        
        <div class="meta-col">
            <div class="meta-label">Customer</div>
            <div class="meta-value">${drilldown.customerName}</div>
        </div>
        
        <div class="meta-col">
            <div class="meta-label">Vessel</div>
            <div class="meta-value">${drilldown.vesselName}</div>
        </div>
        
        <div class="meta-col">
            <div class="meta-label">Container ID</div>
            <div class="meta-value">${drilldown.containerNumber}</div>
        </div>
        
        <div class="route-timeline">
            <div class="port-node">
                <div class="port-node-title">${drilldown.originPortName}</div>
                <div class="port-node-country">${drilldown.originCountry}</div>
                <div class="node-icon"></div>
            </div>
            <div class="timeline-line">
                <i class="fa-solid fa-ship timeline-ship"></i>
            </div>
            <div class="port-node">
                <div class="port-node-title">${drilldown.destinationPortName}</div>
                <div class="port-node-country">${drilldown.destinationCountry}</div>
                <div class="node-icon"></div>
            </div>
        </div>
        
        <div class="meta-col">
            <div class="meta-label">Status</div>
            <div class="badge-status">${drilldown.status}</div>
        </div>
        
        <div class="meta-col">
            <div class="meta-label">Expected</div>
            <div class="meta-value">${drilldown.expectedDate}</div>
        </div>
        
        <div class="meta-col">
            <div class="meta-label">Actual</div>
            <div class="meta-value">${drilldown.actualDate}</div>
        </div>
    </div>

    <div class="grid-container">
        <!-- 1. Financial Breakdown -->
        <div class="panel-card">
            <div class="panel-header">
                <div>
                    <h2 class="panel-title">1. Financial Breakdown</h2>
                    <div class="panel-subtitle">All amounts in USD</div>
                </div>
                <button class="btn-outline"><i class="fa-regular fa-eye"></i> View Full Invoice</button>
            </div>
            
            <div class="finance-grid">
                <!-- REVENUE -->
                <div class="finance-list">
                    <div class="section-title title-rev"><i class="fa-solid fa-arrow-trend-up"></i> REVENUE</div>
                    
                    <div class="finance-item">
                        <span>Freight Charges</span>
                        <span><fmt:formatNumber value="${drilldown.totalRevenue * 0.85}" type="currency" currencySymbol="$"/></span>
                    </div>
                    <div class="finance-item">
                        <span>Service Charges</span>
                        <span><fmt:formatNumber value="${drilldown.totalRevenue * 0.12}" type="currency" currencySymbol="$"/></span>
                    </div>
                    <div class="finance-item">
                        <span>Documentation Fees</span>
                        <span><fmt:formatNumber value="${drilldown.totalRevenue * 0.03}" type="currency" currencySymbol="$"/></span>
                    </div>
                    
                    <div class="finance-item total total-rev">
                        <span>Total Revenue</span>
                        <span><fmt:formatNumber value="${drilldown.totalRevenue}" type="currency" currencySymbol="$"/></span>
                    </div>
                </div>
                
                <div class="finance-divider"></div>
                
                <!-- COST -->
                <div class="finance-list">
                    <div class="section-title title-cost"><i class="fa-solid fa-circle-exclamation"></i> COST</div>
                    
                    <div class="finance-item">
                        <span>Fuel Cost</span>
                        <span><fmt:formatNumber value="${drilldown.totalCost * 0.40}" type="currency" currencySymbol="$"/></span>
                    </div>
                    <div class="finance-item">
                        <span>Port Charges</span>
                        <span><fmt:formatNumber value="${drilldown.totalCost * 0.13}" type="currency" currencySymbol="$"/></span>
                    </div>
                    <div class="finance-item">
                        <span>Customs & Clearance</span>
                        <span><fmt:formatNumber value="${drilldown.totalCost * 0.05}" type="currency" currencySymbol="$"/></span>
                    </div>
                    <div class="finance-item">
                        <span>Terminal Handling</span>
                        <span><fmt:formatNumber value="${drilldown.totalCost * 0.06}" type="currency" currencySymbol="$"/></span>
                    </div>
                    <div class="finance-item">
                        <span>Storage Charges</span>
                        <span><fmt:formatNumber value="${drilldown.totalCost * 0.08}" type="currency" currencySymbol="$"/></span>
                    </div>
                    <div class="finance-item">
                        <span>Penalty Charges</span>
                        <span><fmt:formatNumber value="${drilldown.totalCost * 0.03}" type="currency" currencySymbol="$"/></span>
                    </div>
                    <div class="finance-item">
                        <span>Claims & Compensation</span>
                        <span><fmt:formatNumber value="${drilldown.totalCost * 0.25}" type="currency" currencySymbol="$"/></span>
                    </div>
                    
                    <div class="finance-item total total-cost">
                        <span>Total Cost</span>
                        <span><fmt:formatNumber value="${drilldown.totalCost}" type="currency" currencySymbol="$"/></span>
                    </div>
                </div>
            </div>
            
            <!-- Net Loss Box -->
            <div class="net-loss-box">
                <div>
                    <div class="net-loss-label">NET LOSS</div>
                    <div class="net-loss-value">
                        <c:if test="${drilldown.netLoss < 0}">-</c:if><fmt:formatNumber value="${drilldown.netLoss < 0 ? -drilldown.netLoss : drilldown.netLoss}" type="currency" currencySymbol="$"/>
                    </div>
                    <div class="net-loss-sub">Total Revenue - Total Cost</div>
                </div>
                <div class="net-loss-icon">
                    <i class="fa-solid fa-arrow-trend-down"></i>
                </div>
            </div>
        </div>

        <!-- 2. Assign Loss Reasons -->
                <form id="auditForm" method="POST" action="${pageContext.request.contextPath}/finance/shipment-drilldown/save">
        <input type="hidden" name="shipmentId" value="${drilldown.shipmentId}" />
        <div class="panel-card">
            <div class="panel-header">
                <div>
                    <h2 class="panel-title">2. Assign Loss Reasons</h2>
                    <div class="panel-subtitle">Select all that apply to this shipment loss</div>
                </div>
                <i class="fa-solid fa-circle-info" style="color: var(--text-muted); cursor:pointer;"></i>
            </div>
            
            <div class="input-label">Standard Loss Reasons</div>
            <div class="reasons-grid">
                <c:forEach var="reason" items="${allLossReasons}">
                    <c:set var="isSelected" value="false" />
                    <c:forEach var="assignedId" items="${drilldown.assignedReasonIds}">
                        <c:if test="${assignedId == reason.reasonId}">
                            <c:set var="isSelected" value="true" />
                        </c:if>
                    </c:forEach>
                    
                    <c:set var="flaticonClass" value="fi fi-rr-interrogation" />
                    <!-- Map DB reason names to cool Flaticons -->
                    <c:choose>
                        <c:when test="${reason.reasonName == 'Traffic in Sea'}"><c:set var="flaticonClass" value="fi fi-rr-ship-side" /></c:when>
                        <c:when test="${reason.reasonName == 'Weather'}"><c:set var="flaticonClass" value="fi fi-rr-cloud-hail" /></c:when>
                        <c:when test="${reason.reasonName == 'Delay'}"><c:set var="flaticonClass" value="fi fi-rr-time-quarter-to" /></c:when>
                        <c:when test="${reason.reasonName == 'Dock Allocation'}"><c:set var="flaticonClass" value="fi fi-rr-anchor" /></c:when>
                        <c:when test="${reason.reasonName == 'Regulatory Hold'}"><c:set var="flaticonClass" value="fi fi-rr-shield-exclamation" /></c:when>
                        <c:when test="${reason.reasonName == 'War / Disruption'}"><c:set var="flaticonClass" value="fi fi-rr-flame" /></c:when>
                        <c:when test="${reason.reasonName == 'Ship Issue'}"><c:set var="flaticonClass" value="fi fi-rr-settings-sliders" /></c:when>
                        <c:when test="${reason.reasonName == 'Damaged Product'}"><c:set var="flaticonClass" value="fi fi-rr-box-open" /></c:when>
                    </c:choose>

                    <div class="reason-card ${isSelected ? 'selected' : ''}" onclick="toggleReason(this, ${reason.reasonId})">
                        <input type="checkbox" name="reasonIds" value="${reason.reasonId}" id="chk_${reason.reasonId}" style="display:none;" ${isSelected ? 'checked' : ''} />
                        <div class="reason-checkbox"><i class="fa-solid fa-check"></i></div>
                        <div class="reason-icon"><i class="${flaticonClass}"></i></div>
                        <div class="reason-name">${reason.reasonName}</div>
                    </div>
                </c:forEach>
            </div>
            
            <div class="input-label" style="margin-top:24px;">Add Custom Reason</div>
            <select class="custom-input">
                <option>Select or add custom reason(s)</option>
                <option>Congestion at Port</option>
                <option>Equipment Breakdown</option>
            </select>
            <div class="custom-tags">
                <span class="tag">Congestion at Port <i class="fa-solid fa-xmark"></i></span>
                <span class="tag">Equipment Breakdown <i class="fa-solid fa-xmark"></i></span>
            </div>
            
            <div class="input-label" style="margin-top:24px;">Additional Remarks <span style="color:var(--text-muted); font-weight:400;">(Optional)</span></div>
            <textarea class="remarks-input" placeholder="Enter any additional notes about this financial loss..."></textarea>
            
            <div class="action-row">
                <button type="submit" class="btn-save"><i class="fa-regular fa-file-lines"></i> Save Financial Audit</button>
                <button type="button" class="btn-cancel" onclick="window.history.back()">Cancel</button>
            </div>
        </div>
        </form>
    </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
<script>
    function toggleReason(elem, id) {
        elem.classList.toggle('selected');
        var chk = document.getElementById('chk_' + id);
        if(chk) chk.checked = elem.classList.contains('selected');
    }
    
    function exportDrilldown() {
        const element = document.getElementById('drilldownContent');
        const opt = {
            margin:       0.2,
            filename:     'Shipment_Drilldown_SHP-${drilldown.shipmentId}.pdf',
            image:        { type: 'jpeg', quality: 0.98 },
            html2canvas:  { scale: 2, useCORS: true, logging: false },
            jsPDF:        { unit: 'in', format: 'letter', orientation: 'landscape' }
        };
        html2pdf().set(opt).from(element).save();
    }
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
