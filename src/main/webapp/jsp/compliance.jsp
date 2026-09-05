<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:include page="/jsp/layout/header.jsp" />

<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-regular-rounded/css/uicons-regular-rounded.css'>
<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-solid-rounded/css/uicons-solid-rounded.css'>


  <style>
    :root {
        --bg-surface: #ffffff;
        --border-color: #E7E9ED;
        --text-main: #111827;
        --text-sub: #6B7280;
        --primary: #FC8019;
        --primary-light: #FFF2EB;
        --success: #10B981;
        --success-light: #D1FAE5;
        --danger: #EF4444;
        --danger-light: #FEE2E2;
        --warning: #F59E0B;
        --warning-light: #FEF3C7;
        --info: #3B82F6;
        --info-light: #DBEAFE;
    }
    body {
        background-color: #F9FAFB;
    }
    .dashboard-container {
        padding: 24px;
        max-width: 1400px;
        margin: 0 auto;
    }
    
    .page-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 24px;
    }
    .page-title h1 {
        font-size: 24px;
        font-weight: 700;
        color: var(--text-main);
        margin: 0 0 8px 0;
    }
    .page-title p {
        color: var(--text-sub);
        margin: 0;
        font-size: 14px;
    }
    
    .btn-custom {
        padding: 10px 20px;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 500;
        border: none;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        transition: all 0.2s;
    }
    .btn-primary-custom {
        background-color: var(--primary);
        color: white;
    }
    .btn-primary-custom:hover {
        background-color: #FC8019;
    }
    .btn-outline {
        background-color: white;
        border: 1px solid var(--border-color);
        color: var(--text-main);
    }
    .btn-outline:hover {
        background-color: #F9FAFB;
    }

    .kpi-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        gap: 20px;
        margin-bottom: 32px;
    }
    .kpi-card {
        background: var(--bg-surface);
        border: 1px solid var(--border-color);
        border-radius: 12px;
        padding: 20px;
        display: flex;
        align-items: center;
        gap: 16px;
    }
    .kpi-icon {
        width: 48px;
        height: 48px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
    }
    .kpi-icon.icon-docs { background: var(--primary-light); color: var(--primary); }
    .kpi-icon.icon-approved { background: var(--success-light); color: var(--success); }
    .kpi-icon.icon-review { background: var(--warning-light); color: var(--warning); }
    .kpi-icon.icon-rejected { background: var(--danger-light); color: var(--danger); }
    .kpi-icon.icon-expiring { background: #F3E8FF; color: #9333EA; }
    
    .kpi-icon.icon-inv { background: #F3E8FF; color: #9333EA; }
    .kpi-icon.icon-amount { background: var(--success-light); color: var(--success); }

    .kpi-data { flex: 1; }
    .kpi-title {
        color: var(--text-sub);
        font-size: 13px;
        font-weight: 500;
        margin-bottom: 4px;
    }
    .kpi-val {
        color: var(--text-main);
        font-size: 24px;
        font-weight: 700;
        line-height: 1.2;
    }
    .kpi-sub {
        color: var(--text-sub);
        font-size: 12px;
        margin-top: 4px;
    }

    .section-title-wrap {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 16px;
    }
    .section-title {
        font-size: 18px;
        font-weight: 600;
        color: var(--text-main);
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .section-subtitle {
        color: var(--text-sub);
        font-size: 13px;
        margin-top: 4px;
    }

    .table-card {
        background: var(--bg-surface);
        border: 1px solid var(--border-color);
        border-radius: 12px;
        padding: 0;
        overflow: visible;
        margin-bottom: 32px;
    }
    table {
        width: 100%;
        border-collapse: collapse;
    }
    th {
        background: #F9FAFB;
        padding: 12px 20px;
        text-align: left;
        font-size: 12px;
        font-weight: 600;
        color: var(--text-sub);
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border-bottom: 1px solid var(--border-color);
    }
    td {
        padding: 16px 20px;
        border-bottom: 1px solid var(--border-color);
        font-size: 14px;
        color: var(--text-main);
        vertical-align: middle;
    }
    tr:last-child td {
        border-bottom: none;
    }
    
    .status-badge {
        padding: 4px 10px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 500;
        display: inline-block;
    }
    .status-approved { background: var(--success-light); color: var(--success); }
    .status-review { background: var(--warning-light); color: var(--warning); }
    .status-rejected { background: var(--danger-light); color: var(--danger); }
    
    .status-paid { background: var(--success-light); color: var(--success); }
    .status-unpaid { background: var(--danger-light); color: var(--danger); }
    .status-partial { background: var(--warning-light); color: var(--warning); }

    .action-cell {
        display: flex;
        gap: 8px;
        align-items: center;
    }
    .btn-icon {
        width: 32px;
        height: 32px;
        border-radius: 6px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: 1px solid var(--border-color);
        background: white;
        color: var(--text-sub);
        cursor: pointer;
        transition: all 0.2s;
    }
    .btn-icon:hover {
        background: #F9FAFB;
        color: var(--text-main);
    }
    .btn-view { color: var(--info); border-color: var(--info-light); background: var(--info-light); }
    .btn-edit { color: var(--warning); border-color: var(--warning-light); background: var(--warning-light); }
    
    .dropdown-container {
        position: relative;
    }
    .dropdown-menu-custom {
        position: absolute;
        right: 0;
        top: 100%;
        margin-top: 4px;
        background: white;
        border: 1px solid var(--border-color);
        border-radius: 8px;
        box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -1px rgba(0,0,0,0.06);
        min-width: 150px;
        z-index: 9999;
        display: none;
        padding: 4px;
    }
    .dropdown-menu-custom.show {
        display: block;
    }
    .dropdown-item {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 12px;
        color: var(--text-main);
        text-decoration: none;
        font-size: 13px;
        border-radius: 4px;
    }
    .dropdown-item:hover {
        background: #F3F4F6;
        color: var(--text-main);
    }
    .text-danger { color: var(--danger) !important; }

    /* Modal Styles */
    .modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0,0,0,0.5);
        display: none;
        align-items: center;
        justify-content: center;
        z-index: 99999;
        opacity: 0;
        visibility: hidden;
        pointer-events: none;
        transition: opacity 0.2s;
    }
    .modal-overlay.active {
        display: flex !important;
        opacity: 1 !important;
        visibility: visible !important;
        pointer-events: auto !important;
    }
    .modal-overlay:not(.active) {
        display: none !important;
        visibility: hidden !important;
        pointer-events: none !important;
    }
    .modal-overlay:not(.active) * {
        pointer-events: none !important;
    }
    .modal-content {
        background: white;
        border-radius: 12px;
        width: 100%;
        max-width: 500px;
        padding: 24px;
        box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
        transform: translateY(20px);
        transition: transform 0.2s;
    }
    .modal-overlay.active .modal-content {
        transform: translateY(0);
    }
    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
    }
    .modal-header h3 {
        margin: 0;
        font-size: 18px;
        font-weight: 600;
    }
    .modal-close {
        background: none;
        border: none;
        font-size: 20px;
        color: var(--text-sub);
        cursor: pointer;
    }
    .form-group {
        margin-bottom: 16px;
    }
    .form-group label {
        display: block;
        font-size: 13px;
        font-weight: 500;
        margin-bottom: 6px;
        color: var(--text-main);
    }
    .form-control {
        width: 100%;
        padding: 10px 12px;
        border: 1px solid var(--border-color);
        border-radius: 6px;
        font-size: 14px;
    }
        /* Modal Select Wrapper & Swiggy Orange Custom Native Select */
    .select-wrapper {
        position: relative;
        width: 100%;
    }
    .select-wrapper select.form-select-custom,
    select.form-select-custom.no-custom-select {
        appearance: none;
        -webkit-appearance: none;
        -moz-appearance: none;
        width: 100%;
        height: 42px;
        padding: 0 38px 0 14px;
        border: 1.5px solid #E2E8F0;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 500;
        color: #1F2937;
        background-color: #FFFFFF;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23FC8019' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
        background-repeat: no-repeat !important;
        background-position: right 14px center !important;
        background-size: 12px 10px !important;
        cursor: pointer;
        outline: none;
        transition: border-color 0.15s ease, box-shadow 0.15s ease;
        box-sizing: border-box;
    }
    .select-wrapper select.form-select-custom:focus,
    select.form-select-custom.no-custom-select:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12) !important;
        outline: none !important;
    }

    .form-control:focus {
        outline: none;
        border-color: var(--primary);
        box-shadow: 0 0 0 3px var(--primary-light);
    }
    .modal-actions {
        display: flex;
        justify-content: flex-end;
        gap: 12px;
        margin-top: 24px;
    }

    .pagination-container {
        display: flex;
        justify-content: flex-end;
        gap: 8px;
        margin-top: 16px;
    }
    .pagination-container button {
        border: 1px solid var(--border-color);
        background: #fff;
        padding: 6px 12px;
        border-radius: 6px;
        cursor: pointer;
        font-size: 14px;
        color: var(--text-main);
        transition: all 0.2s;
    }
    .pagination-container button:hover:not(:disabled) {
        background: var(--primary-light);
        color: var(--primary);
        border-color: var(--primary);
    }
    .pagination-container button.active {
        background: var(--primary);
        color: #fff;
        border-color: var(--primary);
    }
    .pagination-container button:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    .expiry-alert-banner {
        background: #F3E8FF;
        border: 1px solid #E9D5FF;
        border-radius: 12px;
        padding: 14px 18px;
        margin-bottom: 24px;
    }
    .expiry-alert-head {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 14px;
        color: #6B21A8;
    }
    .expiry-alert-toggle {
        margin-left: auto;
        color: #9333EA;
        cursor: pointer;
        font-size: 13px;
        font-weight: 500;
        text-decoration: underline;
    }
    .expiry-alert-list {
        margin-top: 12px;
        border-top: 1px solid #E9D5FF;
        padding-top: 10px;
    }
    .expiry-alert-row {
        display: flex;
        justify-content: space-between;
        padding: 6px 0;
        font-size: 13px;
        color: #4C1D95;
    }
</style>

<div class="dashboard-container">
    <div class="page-header">
        <div class="page-title">
            <h1>Government Compliance</h1>
            <p>Upload, manage and track compliance documents for shipments.</p>
        </div>
    </div>

    <c:if test="${not empty expiringDocs}">
    <div class="expiry-alert-banner">
        <div class="expiry-alert-head">
            <i class="fi fi-rr-bell" style="color:#9333EA;"></i>
            <strong>${fn:length(expiringDocs)} compliance document<c:if test="${fn:length(expiringDocs) != 1}">s</c:if> expiring within 15 days</strong>
            <span class="expiry-alert-toggle" onclick="var el=document.getElementById('expiryAlertList'); el.style.display = (el.style.display==='none'?'block':'none');">Show details</span>
        </div>
        <div id="expiryAlertList" class="expiry-alert-list" style="display:none;">
            <c:forEach var="ed" items="${expiringDocs}">
                <div class="expiry-alert-row">
                    <span><strong>DOC-${ed.docId}</strong> &middot; ${ed.docType} &middot; SHP-${ed.shipmentId}</span>
                    <span>Expires <fmt:formatDate value="${ed.expiryDate}" pattern="dd MMM yyyy"/></span>
                </div>
            </c:forEach>
        </div>
    </div>
    </c:if>

    <div class="kpi-grid">
        <div class="kpi-card">
            <div class="kpi-icon icon-docs"><i class="fi fi-rr-document"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Total Documents</div>
                <div class="kpi-val">${docTotal}</div>
                <div class="kpi-sub">All Time</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-approved"><i class="fi fi-rr-check-circle"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Approved</div>
                <div class="kpi-val">${docApproved}</div>
                <div class="kpi-sub"><fmt:formatNumber value="${docTotal > 0 ? (docApproved/docTotal)*100 : 0}" maxFractionDigits="0"/>% of total</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-review"><i class="fi fi-rr-time-fast"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Under Review</div>
                <div class="kpi-val">${docReview}</div>
                <div class="kpi-sub"><fmt:formatNumber value="${docTotal > 0 ? (docReview/docTotal)*100 : 0}" maxFractionDigits="0"/>% of total</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-rejected"><i class="fi fi-rr-cross-circle"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Rejected</div>
                <div class="kpi-val">${docRejected}</div>
                <div class="kpi-sub"><fmt:formatNumber value="${docTotal > 0 ? (docRejected/docTotal)*100 : 0}" maxFractionDigits="0"/>% of total</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-expiring"><i class="fi fi-rr-calendar-clock"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Expiring Soon</div>
                <div class="kpi-val">${docExpiring}</div>
                <div class="kpi-sub">Next 15 days</div>
            </div>
        </div>
    </div>

    
    <div class="card" style="padding: 16px;">
        
    <div class="section-title-wrap">
        <div>
            <div class="section-title"><i class="fi fi-sr-document" style="color:var(--primary)"></i> Document Repository</div>
        </div>
        <div>
            <button class="btn-custom btn-primary-custom" onclick="openModal('uploadModal')"><i class="fi fi-rr-upload"></i> Upload New Document</button>
        </div>
    </div>
    
    <table id="docsTable">
        <thead>
            <tr>
                <th>Document ID</th>
                <th>Shipment ID</th>
                <th>Document Type</th>
                <th>Uploaded On</th>
                <th>Uploaded By</th>
                <th>Status</th>
                <th>Expiry Date</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <c:if test="${empty documents}">
                <tr>
                    <td colspan="8" style="text-align: center; padding: 40px; color: var(--text-sub);">
                        <i class="fi fi-rr-document" style="font-size: 32px; display: block; margin-bottom: 12px; color: #D1D5DB;"></i>
                        No compliance documents found in the database.
                    </td>
                </tr>
            </c:if>
            <c:forEach var="doc" items="${documents}">
                <tr>
                    <td><strong>DOC-${doc.docId}</strong></td>
                    <td>SHP-${doc.shipmentId}</td>
                    <td>${doc.docType}</td>
                    <td>${doc.issueDate}</td>
                    <td>User #${doc.uploadedBy}</td>
                    <td>
                        <c:choose>
                            <c:when test="${doc.status == 'Approved'}"><span class="status-badge status-approved">${doc.status}</span></c:when>
                            <c:when test="${doc.status == 'Rejected'}"><span class="status-badge status-rejected">${doc.status}</span></c:when>
                            <c:otherwise><span class="status-badge status-review">${doc.status}</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td>${doc.expiryDate}</td>
                    <td>
                        <div class="action-cell">
                            <%-- View & Verify: opens the document with Approve/Reject for staff --%>
                            <button class="btn-icon btn-view"
                                    title="${sessionScope.user.roleId <= 3 ? 'View &amp; Review Document' : 'View Document'}"
                                    onclick="window.open('${pageContext.request.contextPath}/compliance-document?id=${doc.docId}', '_blank')"><i class="fi fi-rr-eye"></i></button>
                            <%-- Quick status change + delete: Admins and Operations only --%>
                            <c:if test="${sessionScope.user.roleId <= 3}">
                                <button class="btn-icon btn-edit" title="Update Status" onclick="document.getElementById('updateDocId').value='${doc.docId}'; document.getElementById('updateDocStatus').value='${doc.status}'; openModal('docUpdateModal');"><i class="fi fi-rr-edit"></i></button>
                            </c:if>
                            <div class="dropdown-container">
                                <button class="btn-icon action-dropdown" onclick="toggleDropdown(this)"><i class="fi fi-rr-menu-dots-vertical"></i></button>
                                <div class="dropdown-menu-custom">
                                    <a href="${pageContext.request.contextPath}/${doc.filePath}" download class="dropdown-item"><i class="fi fi-rr-download"></i> Download</a>
                                    <c:if test="${sessionScope.user.roleId <= 2}">
                                        <a href="#" class="dropdown-item text-danger" onclick="document.getElementById('deleteDocId').value='${doc.docId}'; openModal('docDeleteModal'); return false;"><i class="fi fi-rr-trash"></i> Delete</a>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    </div>

    
    <!-- Upload Document Modal -->
    <div class="modal-overlay" id="uploadModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Upload New Document</h3>
                <button class="modal-close" onclick="closeModal('uploadModal')"><i class="fi fi-rr-cross"></i></button>
            </div>
            <form action="${pageContext.request.contextPath}/compliance/upload" method="post" enctype="multipart/form-data">
                <div class="form-group">
                    <label>Related Shipment</label>
                    <div class="select-wrapper">
                        <select name="shipmentId" class="form-select form-select-custom no-custom-select" required>
                        <option value="">Select Shipment...</option>
                        <c:forEach var="s" items="${shipments}">
                            <option value="${s.shipmentId}">SHP-${s.shipmentId}</option>
                        </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label>Document Type</label>
                    <div class="select-wrapper">
                        <select name="docType" class="form-select form-select-custom no-custom-select" required>
                        <option value="">Select Type...</option>
                        <option value="Customs Declaration">Customs Declaration</option>
                        <option value="Import License">Import License</option>
                        <option value="Export License">Export License</option>
                        <option value="Certificate of Origin">Certificate of Origin</option>
                        <option value="Insurance">Insurance</option>
                        <option value="Inspection">Inspection</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label>Document Number</label>
                    <input type="text" name="docNumber" class="form-control" required placeholder="e.g. CUS-2024-8899">
                </div>
                <div class="form-group">
                    <label>Issuing Authority</label>
                    <input type="text" name="issuingAuthority" class="form-control" required placeholder="e.g. US Customs">
                </div>
                <div style="display:flex; gap:16px;">
                    <div class="form-group" style="flex:1;">
                        <label>Issue Date</label>
                        <input type="date" name="issueDate" class="form-control" required>
                    </div>
                    <div class="form-group" style="flex:1;">
                        <label>Expiry Date</label>
                        <input type="date" name="expiryDate" class="form-control" required>
                    </div>
                </div>
                <div class="form-group">
                    <label>File Attachment (PDF/Image)</label>
                    <input type="file" name="docFile" class="form-control" required>
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn-custom btn-outline" onclick="closeModal('uploadModal')">Cancel</button>
                    <button type="submit" class="btn-custom btn-primary-custom">Upload</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Update Document Status Modal -->
    <div class="modal-overlay" id="docUpdateModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Update Document Status</h3>
                <button class="modal-close" onclick="closeModal('docUpdateModal')"><i class="fi fi-rr-cross"></i></button>
            </div>
            <form action="${pageContext.request.contextPath}/compliance/review" method="post">
                <input type="hidden" name="docId" id="updateDocId">
                <div class="form-group">
                    <label>New Status</label>
                    <div class="select-wrapper">
                        <select name="status" id="updateDocStatus" class="form-select form-select-custom no-custom-select" style="width:100%;" required>
                        <option value="Under Review">Under Review</option>
                        <option value="Approved">Approved</option>
                        <option value="Rejected">Rejected</option>
                        </select>
                    </div>
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn-custom btn-outline" onclick="closeModal('docUpdateModal')">Cancel</button>
                    <button type="submit" class="btn-custom btn-primary-custom">Update Status</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Delete Document Confirm Modal -->
    <div class="modal-overlay" id="docDeleteModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Delete Document</h3>
                <button class="modal-close" onclick="closeModal('docDeleteModal')"><i class="fi fi-rr-cross"></i></button>
            </div>
            <p style="color:var(--text-sub); font-size:14px; margin:0 0 8px;">This will permanently delete this compliance document record. This action cannot be undone.</p>
            <form action="${pageContext.request.contextPath}/compliance/delete" method="post">
                <input type="hidden" name="docId" id="deleteDocId">
                <div class="modal-actions">
                    <button type="button" class="btn-custom btn-outline" onclick="closeModal('docDeleteModal')">Cancel</button>
                    <button type="submit" class="btn-custom" style="background:var(--danger); color:#fff;">Delete</button>
                </div>
            </form>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.9/dist/chart.umd.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/nl-chart-theme.js"></script>

<script>

    function paginateTable(tableId, rowsPerPage) {
        const table = document.getElementById(tableId);
        if (!table) return;
        const tbody = table.querySelector('tbody');
        const rows = tbody.querySelectorAll('tr');
        if (rows.length === 0) return;

        const totalPages = Math.ceil(rows.length / rowsPerPage);
        let currentPage = 1;
        
        let pager = table.parentNode.querySelector('.pagination-container');
        if (!pager) {
            pager = document.createElement('div');
            pager.className = 'pagination-container';
            table.parentNode.insertBefore(pager, table.nextSibling);
        }

        function render() {
            rows.forEach((row, index) => {
                row.style.display = (index >= (currentPage - 1) * rowsPerPage && index < currentPage * rowsPerPage) ? '' : 'none';
            });

            pager.innerHTML = '';
            if (totalPages <= 1) return;
            
            const prevBtn = document.createElement('button');
            prevBtn.innerHTML = '&laquo;';
            prevBtn.disabled = currentPage === 1;
            prevBtn.onclick = () => { currentPage--; render(); };
            pager.appendChild(prevBtn);

            for (let i = 1; i <= totalPages; i++) {
                const btn = document.createElement('button');
                btn.textContent = i;
                if (i === currentPage) btn.classList.add('active');
                btn.onclick = () => { currentPage = i; render(); };
                pager.appendChild(btn);
            }

            const nextBtn = document.createElement('button');
            nextBtn.innerHTML = '&raquo;';
            nextBtn.disabled = currentPage === totalPages;
            nextBtn.onclick = () => { currentPage++; render(); };
            pager.appendChild(nextBtn);
        }
        
        render();
    }


    function toggleDropdown(btn) {
        document.querySelectorAll('.dropdown-menu-custom').forEach(menu => {
            if (menu !== btn.nextElementSibling) menu.classList.remove('show');
        });
        btn.nextElementSibling.classList.toggle('show');
    }
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.action-dropdown')) {
            document.querySelectorAll('.dropdown-menu-custom').forEach(menu => menu.classList.remove('show'));
        }
    });

    function openModal(id) { document.getElementById(id).classList.add('active'); }
    function closeModal(id) { document.getElementById(id).classList.remove('active'); }
    
// Native custom select initialized

    window.addEventListener('click', function(e) {
        if (e.target.classList.contains('modal-overlay')) {
            e.target.classList.remove('active');
        }
    });

    paginateTable('docsTable', 15);
</script>

<%-- Export + Fullscreen controls on every card --%>
<script src="${pageContext.request.contextPath}/assets/js/nl-card-tools.js"></script>
</body>
</html>
