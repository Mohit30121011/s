<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Resilient self-load: if this JSP is hit without going through ClaimServlet (e.g. a
    // stale bookmark), populate the same attributes the servlet would so the page still renders.
    if (request.getAttribute("claims") == null) {
        com.nlogistic.model.User __u = (com.nlogistic.model.User) session.getAttribute("user");
        if (__u != null) {
            int __roleId = session.getAttribute("roleId") != null ? (Integer) session.getAttribute("roleId") : __u.getRoleId();
            com.nlogistic.dao.ClaimDAO __claimDao = new com.nlogistic.dao.ClaimDAO();
            Integer __customerId = (Integer) session.getAttribute("customerId");
            if (__customerId == null && __roleId == 5) {
                try (java.sql.Connection __c = com.nlogistic.util.DBConnectionManager.getConnection();
                     java.sql.PreparedStatement __ps = __c.prepareStatement("SELECT customer_id FROM CUSTOMERS WHERE user_id = ?")) {
                    __ps.setInt(1, __u.getUserId());
                    try (java.sql.ResultSet __rs = __ps.executeQuery()) {
                        if (__rs.next()) { __customerId = __rs.getInt(1); session.setAttribute("customerId", __customerId); }
                    }
                } catch (Exception __ignored) {}
            }
            java.util.List<com.nlogistic.model.Claim> __claims = (__roleId == 5)
                    ? (__customerId != null ? __claimDao.getClaimsByCustomer(__customerId) : new java.util.ArrayList<com.nlogistic.model.Claim>())
                    : __claimDao.getAllClaims();
            request.setAttribute("claims", __claims);
            request.setAttribute("stats", __claimDao.getClaimStats());
            request.setAttribute("lossReasons", __claimDao.getAllLossReasons());
            request.setAttribute("shipments", __claimDao.getShipmentsForUser(__u.getUserId(), __roleId, __customerId));
            request.setAttribute("roleId", __roleId);
            request.setAttribute("customerId", __customerId);
        }
    }
%>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    .dashboard-container { padding: 24px; max-width: 1400px; margin: 0 auto; }
    .page-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; flex-wrap: wrap; gap: 16px; }
    .page-title h1 { font-size: 24px; font-weight: 700; color: #0F172A; margin: 0 0 6px 0; }
    .page-title p { color: #64748B; margin: 0; font-size: 14px; }

    .btn-add-container {
        background: #FC8019; color: #FFFFFF !important; border: none; padding: 10px 22px; border-radius: 8px;
        font-weight: 600; font-size: 13.5px; display: inline-flex; align-items: center; gap: 8px; cursor: pointer;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25); transition: all 0.18s ease; text-decoration: none;
    }
    .btn-add-container:hover { background: #E66F0F; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(252, 128, 25, 0.35); }

    .kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(190px, 1fr)); gap: 16px; margin-bottom: 24px; }
    .kpi-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 14px; padding: 16px 18px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03); display: flex; align-items: center; justify-content: space-between;
        transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease; cursor: pointer; text-decoration: none;
    }
    .kpi-card:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,0,0,0.06); border-color: #CBD5E1; }
    .kpi-label { font-size: 11.5px; font-weight: 600; color: #64748B; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.4px; }
    .kpi-value { font-size: 23px; font-weight: 800; color: #0F172A; line-height: 1; }
    .kpi-icon-pill { width: 40px; height: 40px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 19px; flex-shrink: 0; }
    .kpi-icon-pill.amber { background: #FFFBEB; color: #D97706; }
    .kpi-icon-pill.blue { background: #EFF6FF; color: #2563EB; }
    .kpi-icon-pill.green { background: #ECFDF5; color: #059669; }
    .kpi-icon-pill.red { background: #FEF2F2; color: #DC2626; }
    .kpi-icon-pill.purple { background: #F3E8FF; color: #9333EA; }
    .kpi-icon-pill.slate { background: #F1F5F9; color: #475569; }

    .toolbar-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 14px 14px 0 0; padding: 14px 20px;
        display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 14px; border-bottom: 1px solid #F1F5F9;
    }
    .nav-tabs-pill { display: flex; align-items: center; gap: 6px; background: #F8FAFC; padding: 4px; border-radius: 50px; border: 1px solid #E2E8F0; flex-wrap: wrap; }
    .tab-pill-btn {
        background: transparent; border: none; padding: 7px 16px; border-radius: 50px; font-size: 12.5px; font-weight: 600;
        color: #64748B; cursor: pointer; transition: all 0.2s ease; display: flex; align-items: center; gap: 6px; text-decoration: none;
    }
    .tab-pill-btn:hover { color: #0F172A; }
    .tab-pill-btn.active { background: #FFFFFF; color: #FC8019; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08); }

    .table-panel { background: #FFFFFF; border: 1px solid #E2E8F0; border-top: none; border-radius: 0 0 16px 16px; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04); overflow: hidden; margin-bottom: 32px; }
    table.claims-table { width: 100%; border-collapse: collapse; margin: 0; }
    .claims-table th { background: #F8FAFC; padding: 13px 18px; font-size: 11px; font-weight: 700; color: #64748B; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid #E2E8F0; text-align: left; }
    .claims-table td { padding: 14px 18px; border-bottom: 1px solid #F1F5F9; vertical-align: middle; font-size: 13.5px; color: #1E293B; }
    .claims-table tr:last-child td { border-bottom: none; }
    .claims-table tr.claim-row:hover td { background-color: #FAFAFA; cursor: pointer; }

    .status-pill { display: inline-flex; align-items: center; gap: 6px; padding: 5px 12px; border-radius: 50px; font-size: 11.5px; font-weight: 600; white-space: nowrap; }
    .status-pill.filed { background: #FFFBEB; color: #D97706; border: 1px solid #FDE68A; }
    .status-pill.review { background: #EFF6FF; color: #2563EB; border: 1px solid #BFDBFE; }
    .status-pill.approved { background: #F3E8FF; color: #9333EA; border: 1px solid #E9D5FF; }
    .status-pill.rejected { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }
    .status-pill.settled { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }

    .actions-flex { display: flex; align-items: center; justify-content: flex-end; gap: 8px; flex-wrap: wrap; }
    .btn-claim-action {
        border-radius: 50px; font-size: 11.5px; font-weight: 700; padding: 6px 14px; display: inline-flex; align-items: center; gap: 5px;
        cursor: pointer; transition: all 0.2s ease; border: 1.5px solid transparent;
    }
    .btn-claim-review { background: #FFFFFF; border-color: #BFDBFE; color: #2563EB !important; }
    .btn-claim-review:hover { background: #EFF6FF; }
    .btn-claim-approve { background: #10B981 !important; color: #FFFFFF !important; box-shadow: 0 2px 6px rgba(16,185,129,0.22); }
    .btn-claim-approve:hover { background: #059669 !important; }
    .btn-claim-reject { background: #FFFFFF; border-color: #FCA5A5; color: #DC2626 !important; }
    .btn-claim-reject:hover { background: #FEF2F2; }
    .btn-claim-settle { background: #FC8019 !important; color: #FFFFFF !important; box-shadow: 0 2px 6px rgba(252,128,25,0.22); }
    .btn-claim-settle:hover { background: #E66F0F !important; }
    .btn-claim-view { background: #FFFFFF; border-color: #E2E8F0; color: #475569 !important; }
    .btn-claim-view:hover { background: #F8FAFC; }

    .empty-state-card { padding: 60px 24px; text-align: center; background: #FFFFFF; }
    .empty-state-icon-box {
        width: 64px; height: 64px; border-radius: 18px; background: #F8FAFC; border: 1px solid #E2E8F0;
        color: #94A3B8; font-size: 28px; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px;
    }
    .empty-state-title { font-size: 16px; font-weight: 700; color: #0F172A; margin-bottom: 6px; }
    .empty-state-desc { font-size: 13px; color: #64748B; }

    /* Select / form controls */
    .select-wrapper { position: relative; width: 100%; }
    .select-wrapper:has(.ts-wrapper)::after,
    .select-wrapper.has-tomselect::after { display: none !important; }
    .nl-modal-dialog .ts-wrapper.form-select-custom .ts-control {
        border: 1.5px solid #E2E8F0 !important;
        border-radius: 10px !important;
        height: 42px !important;
        display: flex !important;
        align-items: center !important;
        padding: 0 38px 0 16px !important;
        font-size: 13px !important;
        color: #1E293B !important;
        box-shadow: none !important;
        background-color: #FFFFFF !important;
    }
    .nl-modal-dialog .ts-wrapper.form-select-custom.focus .ts-control {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12) !important;
    }
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
    .modal-form-input, textarea.modal-form-input {
        width: 100%; padding: 0 16px; height: 42px; border: 1.5px solid #E2E8F0; border-radius: 10px; font-size: 13px;
        color: #1E293B; background-color: #FFFFFF; outline: none; transition: all 0.2s ease; box-sizing: border-box;
    }
    textarea.modal-form-input { height: auto; padding: 12px 16px; resize: vertical; }
    .modal-form-input:focus { border-color: #FC8019; box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12); }
    .row-2 { display: flex; gap: 14px; }
    .row-2 > div { flex: 1; }

    /* Standard modal (form-driven) */
    .nl-modal-backdrop {
        position: fixed; inset: 0; background: rgba(15, 23, 42, 0.45); backdrop-filter: blur(5px); -webkit-backdrop-filter: blur(5px);
        display: flex; align-items: center; justify-content: center; z-index: 9999999; padding: 20px; opacity: 0;
        transition: opacity 0.2s ease; pointer-events: none;
    }
    .nl-modal-backdrop.show { opacity: 1; pointer-events: auto; }
    .nl-modal-dialog {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 20px; box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.25);
        max-width: 460px; width: 100%; padding: 28px 26px 22px; text-align: center; position: relative;
        transform: scale(0.92) translateY(12px); transition: transform 0.25s ease; max-height: 90vh; overflow-y: auto;
    }
    .nl-modal-dialog.wide { max-width: 640px; text-align: left; }
    .nl-modal-backdrop.show .nl-modal-dialog { transform: scale(1) translateY(0); }
    .nl-modal-close {
        position: absolute; top: 16px; right: 16px; background: #F1F5F9; border: none; width: 30px; height: 30px; border-radius: 50px;
        display: flex; align-items: center; justify-content: center; color: #64748B; cursor: pointer; font-size: 15px;
    }
    .nl-modal-close:hover { background: #E2E8F0; color: #0F172A; }
    .nl-modal-icon-box { width: 56px; height: 56px; border-radius: 16px; margin: 0 auto 16px; display: flex; align-items: center; justify-content: center; font-size: 26px; }
    .nl-modal-icon-box.danger { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }
    .nl-modal-icon-box.success { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }
    .nl-modal-title { font-size: 18px; font-weight: 700; color: #0F172A; margin-bottom: 6px; }
    .nl-modal-title.left { text-align: left; }
    .nl-modal-desc { font-size: 13px; color: #64748B; line-height: 1.5; margin: 0 0 20px 0; }
    .nl-modal-actions { display: flex; align-items: center; justify-content: center; gap: 12px; margin-top: 8px; }
    .nl-modal-actions.left { justify-content: flex-end; }
    .nl-modal-btn { padding: 9px 22px; border-radius: 50px; font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.2s ease; border: none; display: inline-flex; align-items: center; gap: 6px; }
    .nl-modal-btn.cancel { background: #F1F5F9; color: #475569; border: 1px solid #E2E8F0; }
    .nl-modal-btn.cancel:hover { background: #E2E8F0; color: #0F172A; }
    .nl-modal-btn.confirm.danger { background: #DC2626 !important; color: #FFFFFF !important; box-shadow: 0 4px 12px rgba(220, 38, 38, 0.28); }
    .nl-modal-btn.confirm.danger:hover { background: #B91C1C !important; }
    .nl-modal-btn.confirm.success { background: #10B981 !important; color: #FFFFFF !important; box-shadow: 0 4px 12px rgba(16, 185, 129, 0.28); }
    .nl-modal-btn.confirm.success:hover { background: #059669 !important; }
    .nl-modal-btn.confirm.primary { background: #FC8019 !important; color: #FFFFFF !important; box-shadow: 0 4px 12px rgba(252,128,25,0.28); }
    .nl-modal-btn.confirm.primary:hover { background: #E66F0F !important; }

    .custom-alert { border-radius: 12px; padding: 14px 18px; font-size: 13.5px; font-weight: 500; display: flex; align-items: center; gap: 10px; margin-bottom: 20px; }
    .custom-alert.success { background: #ECFDF5; border: 1px solid #A7F3D0; color: #065F46; }
    .custom-alert.danger { background: #FEF2F2; border: 1px solid #FECACA; color: #991B1B; }
</style>

<div class="dashboard-container">
    <div class="page-header">
        <div class="page-title">
            <h1>${roleId == 5 ? 'My Claims' : 'Claims &amp; Damages'}</h1>
            <p>${roleId == 5 ? 'Track the status of loss and damage claims you have filed.' : 'File, review, approve and settle cargo loss/damage claims.'}</p>
        </div>
        <button type="button" class="btn-add-container" onclick="openModal('fileClaimModal')"><i class="ti ti-plus"></i> File New Claim</button>
    </div>

    <c:if test="${not empty sessionScope.successMessage}">
        <div class="custom-alert success"><i class="ti ti-circle-check"></i> ${sessionScope.successMessage}</div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="custom-alert danger"><i class="ti ti-alert-triangle"></i> ${sessionScope.errorMessage}</div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <!-- KPI Dashboard -->
    <div class="kpi-grid">
        <a class="kpi-card" href="${pageContext.request.contextPath}/claims">
            <div><div class="kpi-label">Total</div><div class="kpi-value">${stats.total}</div></div>
            <div class="kpi-icon-pill slate"><i class="ti ti-file-stack"></i></div>
        </a>
        <a class="kpi-card" href="${pageContext.request.contextPath}/claims?statusFilter=Filed">
            <div><div class="kpi-label">Filed</div><div class="kpi-value">${stats.filed}</div></div>
            <div class="kpi-icon-pill amber"><i class="ti ti-file-alert"></i></div>
        </a>
        <a class="kpi-card" href="${pageContext.request.contextPath}/claims?statusFilter=Under Review">
            <div><div class="kpi-label">Under Review</div><div class="kpi-value">${stats.underReview}</div></div>
            <div class="kpi-icon-pill blue"><i class="ti ti-search"></i></div>
        </a>
        <a class="kpi-card" href="${pageContext.request.contextPath}/claims?statusFilter=Approved">
            <div><div class="kpi-label">Approved</div><div class="kpi-value">${stats.approved}</div></div>
            <div class="kpi-icon-pill purple"><i class="ti ti-thumb-up"></i></div>
        </a>
        <a class="kpi-card" href="${pageContext.request.contextPath}/claims?statusFilter=Rejected">
            <div><div class="kpi-label">Rejected</div><div class="kpi-value">${stats.rejected}</div></div>
            <div class="kpi-icon-pill red"><i class="ti ti-x"></i></div>
        </a>
        <a class="kpi-card" href="${pageContext.request.contextPath}/claims?statusFilter=Settled">
            <div><div class="kpi-label">Settled</div><div class="kpi-value">${stats.settled}</div></div>
            <div class="kpi-icon-pill green"><i class="ti ti-circle-check"></i></div>
        </a>
    </div>

    <!-- Toolbar / status filter tabs -->
    <div class="toolbar-card">
        <div class="nav-tabs-pill">
            <a class="tab-pill-btn ${empty statusFilter ? 'active' : ''}" href="${pageContext.request.contextPath}/claims">All</a>
            <a class="tab-pill-btn ${statusFilter == 'Filed' ? 'active' : ''}" href="${pageContext.request.contextPath}/claims?statusFilter=Filed">Filed</a>
            <a class="tab-pill-btn ${statusFilter == 'Under Review' ? 'active' : ''}" href="${pageContext.request.contextPath}/claims?statusFilter=Under Review">Under Review</a>
            <a class="tab-pill-btn ${statusFilter == 'Approved' ? 'active' : ''}" href="${pageContext.request.contextPath}/claims?statusFilter=Approved">Approved</a>
            <a class="tab-pill-btn ${statusFilter == 'Rejected' ? 'active' : ''}" href="${pageContext.request.contextPath}/claims?statusFilter=Rejected">Rejected</a>
            <a class="tab-pill-btn ${statusFilter == 'Settled' ? 'active' : ''}" href="${pageContext.request.contextPath}/claims?statusFilter=Settled">Settled</a>
        </div>
    </div>

    <!-- Claims Table -->
    <div class="table-panel">
        <c:choose>
            <c:when test="${empty claims}">
                <div class="empty-state-card">
                    <div class="empty-state-icon-box"><i class="ti ti-file-off"></i></div>
                    <div class="empty-state-title">No claims found</div>
                    <div class="empty-state-desc">${roleId == 5 ? 'You have not filed any claims yet.' : 'No claims match the current filter.'}</div>
                </div>
            </c:when>
            <c:otherwise>
                <table class="claims-table">
                    <thead>
                        <tr>
                            <th>Claim</th>
                            <th>Shipment</th>
                            <th>Type</th>
                            <th>Incident Date</th>
                            <c:if test="${roleId != 5}"><th>Customer</th></c:if>
                            <th>Claimed</th>
                            <th>Approved</th>
                            <th>Status</th>
                            <th style="text-align:right;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="cl" items="${claims}">
                            <tr class="claim-row" onclick="if(!event.target.closest('.actions-flex')) window.location='${pageContext.request.contextPath}/claims?action=view&claimId=${cl.claimId}';">
                                <td><strong>#${cl.claimId}</strong></td>
                                <td>SHP-${cl.shipmentId}</td>
                                <td>${cl.claimType}</td>
                                <td><fmt:formatDate value="${cl.incidentDate}" pattern="dd MMM yyyy"/></td>
                                <c:if test="${roleId != 5}"><td>${cl.customerName}</td></c:if>
                                <td>&#8377;<fmt:formatNumber value="${cl.claimedAmount}" groupingUsed="true" maxFractionDigits="0"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${cl.approvedAmount > 0}">&#8377;<fmt:formatNumber value="${cl.approvedAmount}" groupingUsed="true" maxFractionDigits="0"/></c:when>
                                        <c:otherwise><span style="color:#94A3B8;">&mdash;</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${cl.status == 'Filed'}"><span class="status-pill filed"><i class="ti ti-file-alert"></i> Filed</span></c:when>
                                        <c:when test="${cl.status == 'Under Review'}"><span class="status-pill review"><i class="ti ti-search"></i> Under Review</span></c:when>
                                        <c:when test="${cl.status == 'Approved'}"><span class="status-pill approved"><i class="ti ti-thumb-up"></i> Approved</span></c:when>
                                        <c:when test="${cl.status == 'Rejected'}"><span class="status-pill rejected"><i class="ti ti-x"></i> Rejected</span></c:when>
                                        <c:when test="${cl.status == 'Settled'}"><span class="status-pill settled"><i class="ti ti-circle-check"></i> Settled</span></c:when>
                                        <c:otherwise><span class="status-pill">${cl.status}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="actions-flex">
                                        <a class="btn-claim-action btn-claim-view" href="${pageContext.request.contextPath}/claims?action=view&claimId=${cl.claimId}"><i class="ti ti-eye"></i> View</a>

                                        <c:if test="${(roleId == 1 || roleId == 2 || roleId == 3) && cl.status == 'Filed'}">
                                            <form method="post" action="${pageContext.request.contextPath}/claims" style="display:inline;">
                                                <input type="hidden" name="action" value="review">
                                                <input type="hidden" name="claimId" value="${cl.claimId}">
                                                <input type="hidden" name="remarks" value="Taken under review">
                                                <button type="button" class="btn-claim-action btn-claim-review"
                                                    onclick="showCustomConfirm({title:'Move to Under Review?', desc:'Claim #${cl.claimId} will move to Under Review for Finance evaluation.', icon:'ti ti-search', type:'success', confirmText:'Yes, Start Review', form:this.form})">
                                                    <i class="ti ti-search"></i> Review
                                                </button>
                                            </form>
                                        </c:if>

                                        <c:if test="${(roleId == 1 || roleId == 2 || roleId == 4) && cl.status == 'Under Review'}">
                                            <button type="button" class="btn-claim-action btn-claim-approve" onclick="openApproveModal(${cl.claimId}, ${cl.claimedAmount})"><i class="ti ti-thumb-up"></i> Approve</button>
                                            <button type="button" class="btn-claim-action btn-claim-reject" onclick="openRejectModal(${cl.claimId})"><i class="ti ti-x"></i> Reject</button>
                                        </c:if>

                                        <c:if test="${(roleId == 1 || roleId == 2 || roleId == 4) && cl.status == 'Approved'}">
                                            <form method="post" action="${pageContext.request.contextPath}/claims" style="display:inline;">
                                                <input type="hidden" name="action" value="settle">
                                                <input type="hidden" name="claimId" value="${cl.claimId}">
                                                <button type="button" class="btn-claim-action btn-claim-settle"
                                                    onclick="showCustomConfirm({title:'Settle Claim?', desc:'Claim #${cl.claimId} will be marked Settled and a credit note posted to billing.', icon:'ti ti-circle-check', type:'success', confirmText:'Yes, Settle', form:this.form})">
                                                    <i class="ti ti-circle-check"></i> Settle
                                                </button>
                                            </form>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- File Claim Modal -->
<div id="fileClaimModal" class="nl-modal-backdrop" style="display:none;">
    <div class="nl-modal-dialog wide">
        <button type="button" class="nl-modal-close" onclick="closeModal('fileClaimModal')"><i class="ti ti-x"></i></button>
        <div class="nl-modal-title left">File Loss / Damage Claim</div>
        <form method="post" action="${pageContext.request.contextPath}/claims" id="fileClaimForm">
            <input type="hidden" name="action" value="file">
            <div class="row-2">
                <div class="modal-form-group">
                    <label class="modal-form-label">Shipment *</label>
                    <div class="select-wrapper">
                        <select name="shipmentId" id="fileShipmentSelect" class="form-select-custom" required onchange="syncShipmentCustomer(this)">
                            <option value="">Select shipment...</option>
                            <c:forEach var="s" items="${shipments}">
                                <option value="${s[0]}" data-customer="${s[3]}" data-customername="${s[4]}" data-container="${s[5]}">
                                    SHP-${s[0]} &mdash; <c:out value="${empty s[1] ? 'General Cargo' : s[1]}"/> (<c:out value="${empty s[4] ? 'Customer #'.concat(s[3]) : s[4]}"/>)
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <c:if test="${roleId == 5}">
                    <input type="hidden" name="customerId" id="fileCustomerId" value="${customerId}">
                    <div class="modal-form-group">
                        <label class="modal-form-label">Customer</label>
                        <input type="text" class="modal-form-input" readonly value="My Account (ID: ${customerId})" style="background-color: #F8FAFC; cursor: not-allowed; color: #64748B;">
                    </div>
                </c:if>
                <c:if test="${roleId != 5}">
                    <div class="modal-form-group">
                        <label class="modal-form-label">Customer *</label>
                        <input type="hidden" name="customerId" id="fileCustomerId" required>
                        <input type="text" id="fileCustomerDisplay" class="modal-form-input" readonly placeholder="Auto-filled from selected shipment..." style="background-color: #F8FAFC; cursor: not-allowed; color: #334155; font-weight: 500;">
                    </div>
                </c:if>
            </div>
            <div class="row-2">
                <div class="modal-form-group">
                    <label class="modal-form-label">Container ID</label>
                    <input type="number" name="containerId" id="fileContainerId" class="modal-form-input" placeholder="Auto-filled from shipment (optional)">
                </div>
                <div class="modal-form-group">
                    <label class="modal-form-label">Product ID</label>
                    <input type="number" name="productId" id="fileProductId" class="modal-form-input" placeholder="Optional (e.g. 101)">
                </div>
            </div>
            <div class="row-2">
                <div class="modal-form-group">
                    <label class="modal-form-label">Claim Type *</label>
                    <div class="select-wrapper">
                        <select name="claimType" class="form-select-custom" required>
                            <option value="Damage">Damage</option>
                            <option value="Loss">Loss</option>
                            <option value="Shortage">Shortage</option>
                        </select>
                    </div>
                </div>
                <div class="modal-form-group">
                    <label class="modal-form-label">Incident Date *</label>
                    <input type="date" name="incidentDate" id="fileIncidentDate" class="modal-form-input" required>
                </div>
            </div>
            <div class="row-2">
                <div class="modal-form-group">
                    <label class="modal-form-label">Claimed Amount (&#8377;) *</label>
                    <input type="number" step="0.01" min="1" name="claimedAmount" class="modal-form-input" placeholder="e.g. 15000.00" required>
                </div>
                <div class="modal-form-group">
                    <label class="modal-form-label">Loss Reason</label>
                    <div class="select-wrapper">
                        <select name="reasonId" class="form-select-custom">
                            <option value="">-- None --</option>
                            <c:forEach var="lr" items="${lossReasons}">
                                <option value="${lr.reasonId}">${lr.reasonName}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
            </div>
            <div class="modal-form-group">
                <label class="modal-form-label">Description *</label>
                <textarea name="description" class="modal-form-input" rows="3" required placeholder="Describe the loss or damage details observed..."></textarea>
            </div>
            <div class="nl-modal-actions left">
                <button type="button" class="nl-modal-btn cancel" onclick="closeModal('fileClaimModal')">Cancel</button>
                <button type="submit" class="nl-modal-btn confirm primary">File Claim</button>
            </div>
        </form>
    </div>
</div>

<!-- Approve Claim Modal -->
<div id="approveClaimModal" class="nl-modal-backdrop" style="display:none;">
    <div class="nl-modal-dialog">
        <button type="button" class="nl-modal-close" onclick="closeModal('approveClaimModal')"><i class="ti ti-x"></i></button>
        <div class="nl-modal-icon-box success"><i class="ti ti-thumb-up"></i></div>
        <div class="nl-modal-title">Approve Claim</div>
        <p class="nl-modal-desc">Set the approved payout amount and add a remark for the claim history.</p>
        <form method="post" action="${pageContext.request.contextPath}/claims">
            <input type="hidden" name="action" value="approve">
            <input type="hidden" name="claimId" id="approveClaimId">
            <div class="modal-form-group">
                <label class="modal-form-label">Approved Amount (&#8377;) *</label>
                <input type="number" step="0.01" name="approvedAmount" id="approveAmount" class="modal-form-input" required>
            </div>
            <div class="modal-form-group">
                <label class="modal-form-label">Remarks *</label>
                <textarea name="remarks" class="modal-form-input" rows="2" required placeholder="e.g. Verified against surveyor report"></textarea>
            </div>
            <div class="nl-modal-actions">
                <button type="button" class="nl-modal-btn cancel" onclick="closeModal('approveClaimModal')">Cancel</button>
                <button type="submit" class="nl-modal-btn confirm success">Approve Claim</button>
            </div>
        </form>
    </div>
</div>

<!-- Reject Claim Modal -->
<div id="rejectClaimModal" class="nl-modal-backdrop" style="display:none;">
    <div class="nl-modal-dialog">
        <button type="button" class="nl-modal-close" onclick="closeModal('rejectClaimModal')"><i class="ti ti-x"></i></button>
        <div class="nl-modal-icon-box danger"><i class="ti ti-x"></i></div>
        <div class="nl-modal-title">Reject Claim</div>
        <p class="nl-modal-desc">Provide a reason. This will be recorded in the claim's status history.</p>
        <form method="post" action="${pageContext.request.contextPath}/claims">
            <input type="hidden" name="action" value="reject">
            <input type="hidden" name="claimId" id="rejectClaimId">
            <div class="modal-form-group">
                <label class="modal-form-label">Rejection Reason *</label>
                <textarea name="remarks" class="modal-form-input" rows="3" required placeholder="e.g. Damage not covered under policy terms"></textarea>
            </div>
            <div class="nl-modal-actions">
                <button type="button" class="nl-modal-btn cancel" onclick="closeModal('rejectClaimModal')">Cancel</button>
                <button type="submit" class="nl-modal-btn confirm danger">Reject Claim</button>
            </div>
        </form>
    </div>
</div>

<!-- Generic confirm modal (Review / Settle) -->
<div id="nlCustomConfirmModal" class="nl-modal-backdrop" style="display:none;">
    <div class="nl-modal-dialog">
        <button type="button" class="nl-modal-close" onclick="closeCustomConfirmModal()"><i class="ti ti-x"></i></button>
        <div id="nlConfirmIconBox" class="nl-modal-icon-box success"><i id="nlConfirmIcon" class="ti ti-check"></i></div>
        <div id="nlConfirmTitle" class="nl-modal-title">Confirm Action</div>
        <p id="nlConfirmDesc" class="nl-modal-desc">Are you sure you want to proceed?</p>
        <div class="nl-modal-actions">
            <button type="button" class="nl-modal-btn cancel" onclick="closeCustomConfirmModal()">Cancel</button>
            <button type="button" id="nlConfirmSubmitBtn" class="nl-modal-btn confirm success">Confirm</button>
        </div>
    </div>
</div>

<script>
    function openModal(id) {
        const modal = document.getElementById(id);
        modal.style.display = 'flex';
        requestAnimationFrame(() => modal.classList.add('show'));
        if (id === 'fileClaimModal') {
            const dateInput = document.getElementById('fileIncidentDate');
            if (dateInput && !dateInput.value) {
                dateInput.value = new Date().toISOString().split('T')[0];
            }
            const shipSelect = document.getElementById('fileShipmentSelect');
            if (shipSelect && shipSelect.tomselect) {
                shipSelect.tomselect.sync();
            }
        }
    }
    function closeModal(id) {
        const modal = document.getElementById(id);
        modal.classList.remove('show');
        setTimeout(() => { modal.style.display = 'none'; }, 200);
    }

    function openApproveModal(claimId, claimedAmount) {
        document.getElementById('approveClaimId').value = claimId;
        document.getElementById('approveAmount').value = claimedAmount;
        openModal('approveClaimModal');
    }
    function openRejectModal(claimId) {
        document.getElementById('rejectClaimId').value = claimId;
        openModal('rejectClaimModal');
    }
    function syncShipmentCustomer(sel) {
        const custField = document.getElementById('fileCustomerId');
        const custDisplay = document.getElementById('fileCustomerDisplay');
        const contField = document.getElementById('fileContainerId');
        
        let selectElem = sel && sel.target ? sel.target : (sel || document.getElementById('fileShipmentSelect'));
        if (!selectElem) return;
        
        let val = selectElem.value;
        let opt = null;
        if (selectElem.options && selectElem.selectedIndex >= 0) {
            opt = selectElem.options[selectElem.selectedIndex];
        }
        if (!opt && val) {
            opt = selectElem.querySelector('option[value="' + val + '"]');
        }
        
        if (!opt || !val) {
            if (custField && ${roleId != 5}) custField.value = '';
            if (custDisplay) custDisplay.value = '';
            if (contField) contField.value = '';
            return;
        }
        
        const custId = opt.getAttribute('data-customer') || '';
        const custName = opt.getAttribute('data-customername') || '';
        const contId = opt.getAttribute('data-container') || '';
        
        if (custField) custField.value = custId;
        if (custDisplay) {
            custDisplay.value = custName ? (custName + ' (ID: ' + custId + ')') : ('Customer #' + custId);
        }
        if (contField && contId && contId !== 'null') {
            contField.value = contId;
        }
    }

    let pendingFormToSubmit = null;
    function showCustomConfirm(options) {
        pendingFormToSubmit = options.form;
        document.getElementById('nlConfirmTitle').textContent = options.title || 'Confirm Action';
        document.getElementById('nlConfirmDesc').textContent = options.desc || 'Are you sure you want to proceed?';
        const iconBox = document.getElementById('nlConfirmIconBox');
        iconBox.className = 'nl-modal-icon-box ' + (options.type || 'danger');
        const icon = document.getElementById('nlConfirmIcon');
        icon.className = options.icon || (options.type === 'success' ? 'ti ti-check' : 'ti ti-alert-triangle');
        const confirmBtn = document.getElementById('nlConfirmSubmitBtn');
        confirmBtn.className = 'nl-modal-btn confirm ' + (options.type || 'danger');
        confirmBtn.textContent = options.confirmText || 'Confirm';
        const modal = document.getElementById('nlCustomConfirmModal');
        modal.style.display = 'flex';
        requestAnimationFrame(() => modal.classList.add('show'));
    }
    function closeCustomConfirmModal() {
        const modal = document.getElementById('nlCustomConfirmModal');
        modal.classList.remove('show');
        setTimeout(() => { modal.style.display = 'none'; pendingFormToSubmit = null; }, 200);
    }

    document.addEventListener('DOMContentLoaded', function() {
        const fileForm = document.getElementById('fileClaimForm');
        const shipSelect = document.getElementById('fileShipmentSelect');
        
        if (shipSelect) {
            shipSelect.addEventListener('change', function() { syncShipmentCustomer(this); });
            if (shipSelect.tomselect) {
                shipSelect.tomselect.on('change', function() { syncShipmentCustomer(shipSelect); });
            }
        }
        
        if (fileForm) {
            fileForm.addEventListener('submit', function(e) {
                if (shipSelect && !shipSelect.value) {
                    e.preventDefault();
                    if (shipSelect.tomselect) {
                        shipSelect.tomselect.focus();
                        shipSelect.tomselect.open();
                    } else {
                        shipSelect.focus();
                    }
                    alert('Please select a shipment to file a claim.');
                    return false;
                }
            });
        }

        const submitBtn = document.getElementById('nlConfirmSubmitBtn');
        if (submitBtn) {
            submitBtn.addEventListener('click', function() {
                if (pendingFormToSubmit) {
                    const form = pendingFormToSubmit;
                    closeCustomConfirmModal();
                    form.submit();
                }
            });
        }
        document.querySelectorAll('.nl-modal-backdrop').forEach(function(modal) {
            modal.addEventListener('click', function(e) { if (e.target === this) { this.classList.remove('show'); setTimeout(() => { this.style.display = 'none'; }, 200); } });
        });
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                document.querySelectorAll('.nl-modal-backdrop.show').forEach(function(modal) {
                    modal.classList.remove('show');
                    setTimeout(() => { modal.style.display = 'none'; }, 200);
                });
            }
        });
    });
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
