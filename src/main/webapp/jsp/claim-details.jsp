<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Resilient self-load: allows direct access (e.g. bookmark) without breaking.
    if (request.getAttribute("claim") == null && request.getParameter("claimId") != null) {
        try {
            int __claimId = Integer.parseInt(request.getParameter("claimId"));
            com.nlogistic.dao.ClaimDAO __dao = new com.nlogistic.dao.ClaimDAO();
            com.nlogistic.model.Claim __claim = __dao.getClaimById(__claimId);
            if (__claim != null) {
                request.setAttribute("claim", __claim);
                request.setAttribute("history", __dao.getClaimHistory(__claimId));
                request.setAttribute("documents", __dao.getClaimDocuments(__claimId));
                com.nlogistic.model.User __u = (com.nlogistic.model.User) session.getAttribute("user");
                int __roleId = (__u != null) ? (session.getAttribute("roleId") != null ? (Integer) session.getAttribute("roleId") : __u.getRoleId()) : 5;
                request.setAttribute("roleId", __roleId);
                request.setAttribute("customerId", session.getAttribute("customerId"));
            }
        } catch (Exception __ignored) {}
    }
%>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    .dashboard-container { padding: 24px; max-width: 1200px; margin: 0 auto; }
    .breadcrumb-back { display: inline-flex; align-items: center; gap: 6px; color: #64748B; font-size: 13px; text-decoration: none; margin-bottom: 14px; }
    .breadcrumb-back:hover { color: #FC8019; }
    .page-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px; flex-wrap: wrap; gap: 16px; }
    .page-title h1 { font-size: 22px; font-weight: 700; color: #0F172A; margin: 0 0 6px 0; }
    .page-title p { color: #64748B; margin: 0; font-size: 13.5px; }

    .status-pill { display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; border-radius: 50px; font-size: 12.5px; font-weight: 700; white-space: nowrap; }
    .status-pill.filed { background: #FFFBEB; color: #D97706; border: 1px solid #FDE68A; }
    .waiting-banner { display: flex; align-items: center; gap: 10px; background: #FFFBEB; border: 1px solid #FDE68A; color: #92400E; border-radius: 12px; padding: 12px 18px; font-size: 13.5px; font-weight: 500; margin-top: 16px; }
    .status-pill.review { background: #EFF6FF; color: #2563EB; border: 1px solid #BFDBFE; }
    .status-pill.approved { background: #F3E8FF; color: #9333EA; border: 1px solid #E9D5FF; }
    .status-pill.rejected { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }
    .status-pill.settled { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }

    .detail-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 20px; align-items: start; }
    @media (max-width: 900px) { .detail-grid { grid-template-columns: 1fr; } }

    .card-panel { background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 14px; padding: 20px 22px; margin-bottom: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.03); }
    .card-panel h3 { font-size: 14.5px; font-weight: 700; color: #0F172A; margin: 0 0 16px 0; display: flex; align-items: center; gap: 8px; }
    .card-panel h3 i { color: #FC8019; }

    .info-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px 20px; }
    .info-item .label { font-size: 11px; font-weight: 600; color: #94A3B8; text-transform: uppercase; letter-spacing: 0.4px; margin-bottom: 4px; }
    .info-item .value { font-size: 14px; font-weight: 600; color: #1E293B; }
    .desc-block { background: #F8FAFC; border: 1px solid #F1F5F9; border-radius: 10px; padding: 14px 16px; font-size: 13.5px; color: #334155; line-height: 1.6; margin-top: 16px; }

    .amount-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #F1F5F9; font-size: 13.5px; }
    .amount-row:last-child { border-bottom: none; }
    .amount-row .lbl { color: #64748B; }
    .amount-row .val { font-weight: 700; color: #0F172A; }

    .timeline { position: relative; padding-left: 26px; }
    .timeline::before { content: ''; position: absolute; left: 8px; top: 4px; bottom: 4px; width: 2px; background: #E2E8F0; }
    .timeline-item { position: relative; padding-bottom: 20px; }
    .timeline-item:last-child { padding-bottom: 0; }
    .timeline-dot { position: absolute; left: -26px; top: 2px; width: 18px; height: 18px; border-radius: 50%; background: #FFF; border: 2px solid #FC8019; display: flex; align-items: center; justify-content: center; }
    .timeline-dot i { font-size: 9px; color: #FC8019; }
    .timeline-status { font-weight: 700; font-size: 13px; color: #0F172A; }
    .timeline-meta { font-size: 11.5px; color: #94A3B8; margin: 2px 0 4px 0; }
    .timeline-remark { font-size: 12.5px; color: #475569; background: #F8FAFC; border-radius: 8px; padding: 8px 10px; }

    .doc-list { display: flex; flex-direction: column; gap: 10px; }
    .doc-item { display: flex; align-items: center; justify-content: space-between; gap: 10px; padding: 10px 12px; border: 1px solid #F1F5F9; border-radius: 10px; background: #F8FAFC; }
    .doc-item .doc-info { display: flex; align-items: center; gap: 10px; min-width: 0; }
    .doc-item .doc-icon { width: 34px; height: 34px; border-radius: 9px; background: #FFF0E5; color: #FC8019; display: flex; align-items: center; justify-content: center; font-size: 15px; flex-shrink: 0; }
    .doc-item .doc-name { font-size: 12.5px; font-weight: 600; color: #1E293B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 160px; }
    .doc-item .doc-type { font-size: 11px; color: #94A3B8; }
    .doc-item a.doc-download { color: #FC8019; font-size: 16px; flex-shrink: 0; }

    .btn-add-container {
        background: #FC8019; color: #FFFFFF !important; border: none; padding: 9px 18px; border-radius: 8px;
        font-weight: 600; font-size: 12.5px; display: inline-flex; align-items: center; gap: 8px; cursor: pointer;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25); transition: all 0.18s ease; text-decoration: none;
    }
    .btn-add-container:hover { background: #E66F0F; }

    .action-bar { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 4px; }
    .btn-claim-action { border-radius: 50px; font-size: 12.5px; font-weight: 700; padding: 8px 18px; display: inline-flex; align-items: center; gap: 6px; cursor: pointer; transition: all 0.2s ease; border: 1.5px solid transparent; }
    .btn-claim-review { background: #FFFFFF; border-color: #BFDBFE; color: #2563EB !important; }
    .btn-claim-review:hover { background: #EFF6FF; }
    .btn-claim-approve { background: #10B981 !important; color: #FFFFFF !important; box-shadow: 0 2px 6px rgba(16,185,129,0.22); }
    .btn-claim-approve:hover { background: #059669 !important; }
    .btn-claim-reject { background: #FFFFFF; border-color: #FCA5A5; color: #DC2626 !important; }
    .btn-claim-reject:hover { background: #FEF2F2; }
    .btn-claim-settle { background: #FC8019 !important; color: #FFFFFF !important; box-shadow: 0 2px 6px rgba(252,128,25,0.22); }
    .btn-claim-settle:hover { background: #E66F0F !important; }

    .select-wrapper { position: relative; width: 100%; }
    .select-wrapper::after {
        content: ''; position: absolute; right: 16px; top: 50%; transform: translateY(-50%); width: 14px; height: 14px;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2364748B' stroke-width='2.2'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E");
        background-size: contain; background-repeat: no-repeat; pointer-events: none;
    }
    .form-select-custom, .select-wrapper select {
        appearance: none; -webkit-appearance: none; width: 100%; height: 42px; padding: 0 38px 0 16px;
        border: 1.5px solid #E2E8F0; border-radius: 10px; font-size: 13px; color: #1E293B; background-color: #FFFFFF; outline: none; transition: all 0.2s ease;
    }
    .form-select-custom:focus, .select-wrapper select:focus { border-color: #FC8019; box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12); }
    .modal-form-group { margin-bottom: 16px; text-align: left; }
    .modal-form-label { display: block; font-size: 12.5px; font-weight: 600; color: #475569; margin-bottom: 6px; }
    .modal-form-input { width: 100%; padding: 0 16px; height: 42px; border: 1.5px solid #E2E8F0; border-radius: 10px; font-size: 13px; color: #1E293B; background-color: #FFFFFF; outline: none; box-sizing: border-box; }
    .modal-form-input:focus { border-color: #FC8019; box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12); }

    .nl-modal-backdrop {
        position: fixed; inset: 0; background: rgba(15, 23, 42, 0.45); backdrop-filter: blur(5px); -webkit-backdrop-filter: blur(5px);
        display: flex; align-items: center; justify-content: center; z-index: 9999999; padding: 20px; opacity: 0;
        transition: opacity 0.2s ease; pointer-events: none;
    }
    .nl-modal-backdrop.show { opacity: 1; pointer-events: auto; }
    .nl-modal-dialog {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 20px; box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.25);
        max-width: 460px; width: 100%; padding: 28px 26px 22px; text-align: left; position: relative;
        transform: scale(0.92) translateY(12px); transition: transform 0.25s ease;
    }
    .nl-modal-backdrop.show .nl-modal-dialog { transform: scale(1) translateY(0); }
    .nl-modal-close { position: absolute; top: 16px; right: 16px; background: #F1F5F9; border: none; width: 30px; height: 30px; border-radius: 50px; display: flex; align-items: center; justify-content: center; color: #64748B; cursor: pointer; font-size: 15px; }
    .nl-modal-close:hover { background: #E2E8F0; color: #0F172A; }
    .nl-modal-title { font-size: 17px; font-weight: 700; color: #0F172A; margin-bottom: 16px; }
    .nl-modal-actions { display: flex; align-items: center; justify-content: flex-end; gap: 12px; margin-top: 8px; }
    .nl-modal-btn { padding: 9px 22px; border-radius: 50px; font-size: 13px; font-weight: 600; cursor: pointer; border: none; }
    .nl-modal-btn.cancel { background: #F1F5F9; color: #475569; border: 1px solid #E2E8F0; }
    .nl-modal-btn.confirm.primary { background: #FC8019 !important; color: #FFFFFF !important; }
    .nl-modal-btn.confirm.success { background: #10B981 !important; color: #FFFFFF !important; }
    .nl-modal-btn.confirm.danger { background: #DC2626 !important; color: #FFFFFF !important; }
    .empty-mini { text-align: center; padding: 24px 10px; color: #94A3B8; font-size: 12.5px; }
</style>

<div class="dashboard-container">
    <a class="breadcrumb-back" href="${pageContext.request.contextPath}/claims"><i class="ti ti-arrow-left"></i> Back to Claims</a>

    <c:choose>
    <c:when test="${empty claim}">
        <div class="card-panel" style="text-align:center; padding:60px 20px;">
            <i class="ti ti-file-off" style="font-size:32px; color:#CBD5E1; display:block; margin-bottom:12px;"></i>
            Claim not found.
        </div>
    </c:when>
    <c:otherwise>

    <c:if test="${not empty sessionScope.successMessage}">
        <div style="background:#ECFDF5;border:1px solid #A7F3D0;color:#065F46;border-radius:12px;padding:12px 16px;margin-bottom:16px;font-size:13.5px;">
            <i class="ti ti-circle-check"></i> ${sessionScope.successMessage}
        </div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div style="background:#FEF2F2;border:1px solid #FECACA;color:#991B1B;border-radius:12px;padding:12px 16px;margin-bottom:16px;font-size:13.5px;">
            <i class="ti ti-alert-triangle"></i> ${sessionScope.errorMessage}
        </div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <div class="page-header">
        <div class="page-title">
            <h1>Claim #${claim.claimId} &mdash; ${claim.claimType}</h1>
            <p>Filed <fmt:formatDate value="${claim.filedDate}" pattern="dd MMM yyyy, HH:mm"/> for Shipment SHP-${claim.shipmentId}</p>
        </div>
        <c:choose>
            <c:when test="${claim.status == 'Filed'}"><span class="status-pill filed"><i class="ti ti-file-alert"></i> Filed</span></c:when>
            <c:when test="${claim.status == 'Under Review'}"><span class="status-pill review"><i class="ti ti-search"></i> Under Review</span></c:when>
            <c:when test="${claim.status == 'Approved'}"><span class="status-pill approved"><i class="ti ti-thumb-up"></i> Approved</span></c:when>
            <c:when test="${claim.status == 'Rejected'}"><span class="status-pill rejected"><i class="ti ti-x"></i> Rejected</span></c:when>
            <c:when test="${claim.status == 'Settled'}"><span class="status-pill settled"><i class="ti ti-circle-check"></i> Settled</span></c:when>
        </c:choose>
    </div>

    <!-- Role-based action bar -->
    <c:if test="${(roleId == 1 || roleId == 2 || roleId == 3) && claim.status == 'Filed'}">
        <div class="action-bar">
            <form method="post" action="${pageContext.request.contextPath}/claims">
                <input type="hidden" name="action" value="review">
                <input type="hidden" name="claimId" value="${claim.claimId}">
                <input type="hidden" name="remarks" value="Taken under review">
                <button type="submit" class="btn-claim-action btn-claim-review"><i class="ti ti-search"></i> Move to Under Review</button>
            </form>
        </div>
    </c:if>
    <c:if test="${(roleId == 1 || roleId == 2 || roleId == 4) && claim.status == 'Under Review'}">
        <div class="action-bar">
            <button type="button" class="btn-claim-action btn-claim-approve" onclick="openModal('approveModal')"><i class="ti ti-thumb-up"></i> Approve</button>
            <button type="button" class="btn-claim-action btn-claim-reject" onclick="openModal('rejectModal')"><i class="ti ti-x"></i> Reject</button>
        </div>
    </c:if>
    <c:if test="${(roleId == 1 || roleId == 2 || roleId == 4) && claim.status == 'Approved'}">
        <div class="action-bar">
            <form method="post" action="${pageContext.request.contextPath}/claims">
                <input type="hidden" name="action" value="settle">
                <input type="hidden" name="claimId" value="${claim.claimId}">
                <button type="submit" class="btn-claim-action btn-claim-settle"><i class="ti ti-circle-check"></i> Settle Claim</button>
            </form>
        </div>
    </c:if>

    <!-- Clarity banner: explain whose turn it is when the current viewer has no action available -->
    <c:if test="${claim.status == 'Filed' && roleId != 1 && roleId != 2 && roleId != 3}">
        <div class="waiting-banner"><i class="ti ti-clock"></i> Waiting on Operations staff or Admin to move this claim to <strong>Under Review</strong>.</div>
    </c:if>
    <c:if test="${claim.status == 'Under Review' && roleId != 1 && roleId != 2 && roleId != 4}">
        <div class="waiting-banner"><i class="ti ti-clock"></i> Waiting on Finance staff or Admin to <strong>Approve</strong> or <strong>Reject</strong> this claim.</div>
    </c:if>
    <c:if test="${claim.status == 'Approved' && roleId != 1 && roleId != 2 && roleId != 4}">
        <div class="waiting-banner"><i class="ti ti-clock"></i> Waiting on Finance staff or Admin to <strong>Settle</strong> this claim (posts the credit note and P&amp;L cost).</div>
    </c:if>

    <div class="detail-grid" style="margin-top:20px;">
        <div>
            <div class="card-panel">
                <h3><i class="ti ti-info-circle"></i> Claim Information</h3>
                <div class="info-grid">
                    <div class="info-item"><div class="label">Customer</div><div class="value"><c:choose><c:when test="${not empty claim.customerName}">${claim.customerName}</c:when><c:otherwise>Customer #${claim.customerId}</c:otherwise></c:choose></div></div>
                    <div class="info-item"><div class="label">Shipment</div><div class="value">SHP-${claim.shipmentId}</div></div>
                    <div class="info-item"><div class="label">Container</div><div class="value">${not empty claim.containerNumber ? claim.containerNumber : (claim.containerId != null ? claim.containerId : '—')}</div></div>
                    <div class="info-item"><div class="label">Product</div><div class="value">${not empty claim.productName ? claim.productName : (claim.productId != null ? claim.productId : '—')}</div></div>
                    <div class="info-item"><div class="label">Incident Date</div><div class="value"><fmt:formatDate value="${claim.incidentDate}" pattern="dd MMM yyyy"/></div></div>
                    <div class="info-item"><div class="label">Loss Reason</div><div class="value">${not empty claim.reasonName ? claim.reasonName : '—'}</div></div>
                </div>
                <div class="desc-block">${claim.description}</div>
            </div>

            <div class="card-panel">
                <h3><i class="ti ti-history"></i> Status History</h3>
                <c:choose>
                    <c:when test="${empty history}">
                        <div class="empty-mini">No status changes recorded yet.</div>
                    </c:when>
                    <c:otherwise>
                        <div class="timeline">
                            <c:forEach var="h" items="${history}">
                                <div class="timeline-item">
                                    <div class="timeline-dot"><i class="ti ti-point-filled"></i></div>
                                    <div class="timeline-status">${not empty h.previousStatus ? h.previousStatus.concat(' → ') : ''}${h.newStatus}</div>
                                    <div class="timeline-meta">
                                        <fmt:formatDate value="${h.changedAt}" pattern="dd MMM yyyy, HH:mm"/>
                                        <c:if test="${not empty h.changerName}"> &middot; by ${h.changerName}</c:if>
                                    </div>
                                    <c:if test="${not empty h.remarks}"><div class="timeline-remark">${h.remarks}</div></c:if>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div>
            <div class="card-panel">
                <h3><i class="ti ti-cash"></i> Amounts</h3>
                <div class="amount-row"><span class="lbl">Claimed Amount</span><span class="val">&#8377;<fmt:formatNumber value="${claim.claimedAmount}" groupingUsed="true" maxFractionDigits="0"/></span></div>
                <div class="amount-row"><span class="lbl">Approved Amount</span><span class="val">
                    <c:choose>
                        <c:when test="${claim.approvedAmount > 0}">&#8377;<fmt:formatNumber value="${claim.approvedAmount}" groupingUsed="true" maxFractionDigits="0"/></c:when>
                        <c:otherwise>&mdash;</c:otherwise>
                    </c:choose>
                </span></div>
            </div>

            <div class="card-panel">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
                    <h3 style="margin:0;"><i class="ti ti-paperclip"></i> Evidence Documents</h3>
                    <button type="button" class="btn-add-container" onclick="openModal('addDocModal')"><i class="ti ti-plus"></i> Add</button>
                </div>
                <c:choose>
                    <c:when test="${empty documents}">
                        <div class="empty-mini">No documents attached yet.</div>
                    </c:when>
                    <c:otherwise>
                        <div class="doc-list">
                            <c:forEach var="d" items="${documents}">
                                <div class="doc-item">
                                    <div class="doc-info">
                                        <div class="doc-icon"><i class="ti ti-file"></i></div>
                                        <div>
                                            <div class="doc-name">${d.filePath}</div>
                                            <div class="doc-type">${d.docType}</div>
                                        </div>
                                    </div>
                                    <a class="doc-download" title="Download" target="_blank"
                                       href="${pageContext.request.contextPath}/download?path=${d.filePath}"><i class="ti ti-download"></i></a>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- Approve Modal -->
    <div id="approveModal" class="nl-modal-backdrop" style="display:none;">
        <div class="nl-modal-dialog">
            <button type="button" class="nl-modal-close" onclick="closeModal('approveModal')"><i class="ti ti-x"></i></button>
            <div class="nl-modal-title">Approve Claim #${claim.claimId}</div>
            <form method="post" action="${pageContext.request.contextPath}/claims">
                <input type="hidden" name="action" value="approve">
                <input type="hidden" name="claimId" value="${claim.claimId}">
                <div class="modal-form-group">
                    <label class="modal-form-label">Approved Amount (&#8377;) *</label>
                    <input type="number" step="0.01" name="approvedAmount" class="modal-form-input" value="${claim.claimedAmount}" required>
                </div>
                <div class="modal-form-group">
                    <label class="modal-form-label">Remarks *</label>
                    <textarea name="remarks" class="modal-form-input" style="height:auto;padding:10px 16px;" rows="2" required></textarea>
                </div>
                <div class="nl-modal-actions">
                    <button type="button" class="nl-modal-btn cancel" onclick="closeModal('approveModal')">Cancel</button>
                    <button type="submit" class="nl-modal-btn confirm success">Approve</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Reject Modal -->
    <div id="rejectModal" class="nl-modal-backdrop" style="display:none;">
        <div class="nl-modal-dialog">
            <button type="button" class="nl-modal-close" onclick="closeModal('rejectModal')"><i class="ti ti-x"></i></button>
            <div class="nl-modal-title">Reject Claim #${claim.claimId}</div>
            <form method="post" action="${pageContext.request.contextPath}/claims">
                <input type="hidden" name="action" value="reject">
                <input type="hidden" name="claimId" value="${claim.claimId}">
                <div class="modal-form-group">
                    <label class="modal-form-label">Rejection Reason *</label>
                    <textarea name="remarks" class="modal-form-input" style="height:auto;padding:10px 16px;" rows="3" required></textarea>
                </div>
                <div class="nl-modal-actions">
                    <button type="button" class="nl-modal-btn cancel" onclick="closeModal('rejectModal')">Cancel</button>
                    <button type="submit" class="nl-modal-btn confirm danger">Reject</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Add Document Modal -->
    <div id="addDocModal" class="nl-modal-backdrop" style="display:none;">
        <div class="nl-modal-dialog">
            <button type="button" class="nl-modal-close" onclick="closeModal('addDocModal')"><i class="ti ti-x"></i></button>
            <div class="nl-modal-title">Add Evidence Document</div>
            <form method="post" action="${pageContext.request.contextPath}/claims" enctype="multipart/form-data">
                <input type="hidden" name="action" value="addDoc">
                <input type="hidden" name="claimId" value="${claim.claimId}">
                <div class="modal-form-group">
                    <label class="modal-form-label">Document Type *</label>
                    <div class="select-wrapper">
                        <select name="docType" class="form-select-custom" required>
                            <option value="Photo Evidence">Photo Evidence</option>
                            <option value="Inspection Report">Inspection Report</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                </div>
                <div class="modal-form-group">
                    <label class="modal-form-label">Upload File *</label>
                    <input type="file" name="evidenceFile" class="modal-form-input" accept=".pdf,.jpg,.jpeg,.png,.doc,.docx" required>
                    <small style="color:#64748B;font-size:11.5px;">PDF, JPG, PNG or DOC — max 15 MB.</small>
                </div>
                <div class="nl-modal-actions">
                    <button type="button" class="nl-modal-btn cancel" onclick="closeModal('addDocModal')">Cancel</button>
                    <button type="submit" class="nl-modal-btn confirm primary">Add Document</button>
                </div>
            </form>
        </div>
    </div>

    </c:otherwise>
    </c:choose>
</div>

<script>
    function openModal(id) {
        const modal = document.getElementById(id);
        modal.style.display = 'flex';
        requestAnimationFrame(() => modal.classList.add('show'));
    }
    function closeModal(id) {
        const modal = document.getElementById(id);
        modal.classList.remove('show');
        setTimeout(() => { modal.style.display = 'none'; }, 200);
    }
    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('.nl-modal-backdrop').forEach(function(modal) {
            modal.addEventListener('click', function(e) { if (e.target === this) closeModal(this.id); });
        });
    });
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
