<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Self-contained resilient controller logic: supports direct JSP access or servlet forwarding
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        String compIdStr = request.getParameter("companyId");
        if (compIdStr != null && action != null) {
            try {
                int compId = Integer.parseInt(compIdStr);
                com.nlogistic.dao.CompanyDAO cDao = new com.nlogistic.dao.CompanyDAO();
                if ("accept".equals(action)) {
                    cDao.updateCompanyStatus(compId, "Active");
                    try (java.sql.Connection conn = com.nlogistic.util.DBConnectionManager.getConnection();
                         java.sql.PreparedStatement ps = conn.prepareStatement("UPDATE users SET status = 'Active' WHERE company_id = ?")) {
                        ps.setInt(1, compId);
                        ps.executeUpdate();
                    } catch(Exception ex) { ex.printStackTrace(); }
                    session.setAttribute("successMessage", "Company Approved & Activated Successfully.");
                } else if ("reject".equals(action)) {
                    cDao.updateCompanyStatus(compId, "Suspended");
                    session.setAttribute("errorMessage", "Company Rejected / Suspended.");
                }
            } catch(Exception ex) { ex.printStackTrace(); }
            response.sendRedirect(request.getRequestURI());
            return;
        }
    }

    if (request.getAttribute("allCompanies") == null) {
        com.nlogistic.dao.CompanyDAO cDao = new com.nlogistic.dao.CompanyDAO();
        java.util.List<com.nlogistic.model.Company> allComps = cDao.getAllCompanies();
        java.util.List<com.nlogistic.model.Company> pendComps = cDao.getPendingCompanies();
        int pendingCount = (pendComps != null) ? pendComps.size() : 0;
        int activeCount = 0;
        int suspendedCount = 0;
        int totalCount = (allComps != null) ? allComps.size() : 0;

        if (allComps != null) {
            for (com.nlogistic.model.Company c : allComps) {
                if ("Active".equalsIgnoreCase(c.getApprovalStatus())) {
                    activeCount++;
                } else if ("Suspended".equalsIgnoreCase(c.getApprovalStatus()) || "Rejected".equalsIgnoreCase(c.getApprovalStatus())) {
                    suspendedCount++;
                }
            }
        }

        request.setAttribute("allCompanies", allComps);
        request.setAttribute("pendingCompanies", pendComps);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("activeCount", activeCount);
        request.setAttribute("suspendedCount", suspendedCount);
        request.setAttribute("totalCount", totalCount);
    }
%>

<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* ==========================================================================
       COMPANY APPROVALS & TENANT GOVERNANCE THEME (SWIGGY ORANGE ENTERPRISE)
       ========================================================================== */
    .approvals-page-container {
        padding: 0 4px 40px;
    }
    .custom-breadcrumb {
        display: flex; align-items: center; gap: 8px; font-size: 13px; color: #64748B; margin-bottom: 16px;
    }
    .custom-breadcrumb a { color: #64748B; text-decoration: none; transition: color 0.15s ease; }
    .custom-breadcrumb a:hover { color: #FC8019; }
    .custom-breadcrumb i { font-size: 11px; color: #94A3B8; }
    .custom-breadcrumb .current { color: #FC8019; font-weight: 600; }

    .telemetry-header-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 16px; padding: 24px 28px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04); margin-bottom: 24px;
        display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 20px;
    }
    .telemetry-header-left { display: flex; align-items: center; gap: 16px; }
    .telemetry-icon-box {
        width: 52px; height: 52px; border-radius: 14px;
        background: #FFF0E5;
        display: flex; align-items: center; justify-content: center; color: #FC8019; font-size: 26px;
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.15); flex-shrink: 0;
    }
    .telemetry-title { font-size: 20px; font-weight: 700; color: #0F172A; margin: 0 0 4px 0; letter-spacing: -0.3px; }
    .telemetry-subtitle { font-size: 13.5px; color: #64748B; margin: 0; }

    .kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 18px; margin-bottom: 24px; }
    @media (max-width: 1024px) { .kpi-grid { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 640px) { .kpi-grid { grid-template-columns: 1fr; } }

    .kpi-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 14px; padding: 18px 20px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03); display: flex; align-items: center; justify-content: space-between;
        transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
    }
    .kpi-card:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,0,0,0.06); border-color: #CBD5E1; }
    .kpi-label { font-size: 12.5px; font-weight: 600; color: #64748B; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.4px; }
    .kpi-value { font-size: 26px; font-weight: 800; color: #0F172A; line-height: 1; }
    .kpi-icon-pill { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 22px; flex-shrink: 0; }
    .kpi-icon-pill.amber { background: #FFFBEB; color: #D97706; }
    .kpi-icon-pill.green { background: #ECFDF5; color: #059669; }
    .kpi-icon-pill.red { background: #FEF2F2; color: #DC2626; }
    .kpi-icon-pill.blue { background: #EFF6FF; color: #2563EB; }

    .approvals-toolbar {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 14px 14px 0 0; padding: 16px 24px;
        display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 16px; border-bottom: 1px solid #F1F5F9;
    }
    .nav-tabs-pill { display: flex; align-items: center; gap: 8px; background: #F8FAFC; padding: 4px; border-radius: 50px; border: 1px solid #E2E8F0; }
    .tab-pill-btn {
        background: transparent; border: none; padding: 7px 18px; border-radius: 50px; font-size: 13px; font-weight: 600;
        color: #64748B; cursor: pointer; transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); display: flex; align-items: center; gap: 6px;
    }
    .tab-pill-btn:hover { color: #0F172A; }
    .tab-pill-btn.active { background: #FFFFFF; color: #FC8019; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08); }
    .tab-counter { font-size: 11px; font-weight: 700; padding: 2px 7px; border-radius: 50px; background: #F1F5F9; color: #475569; }
    .tab-pill-btn.active .tab-counter { background: #FFF0E5; color: #FC8019; }

    .table-search-wrap { position: relative; width: 300px; }
    .table-search-wrap i { position: absolute; left: 16px; top: 50%; transform: translateY(-50%); color: #94A3B8; font-size: 15px; }
    .table-search-input { width: 100%; height: 40px; padding-left: 42px !important; padding-right: 18px !important; border-radius: 50px !important; font-size: 13px !important; border: 1.5px solid #E2E8F0 !important; background: #F8FAFC !important; }
    .table-search-input:focus { background: #FFFFFF !important; border-color: #FC8019 !important; box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.16) !important; }

    .approvals-table-panel { background: #FFFFFF; border: 1px solid #E2E8F0; border-top: none; border-radius: 0 0 16px 16px; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04); overflow: hidden; }
    .approvals-table { width: 100%; border-collapse: collapse; margin: 0; }
    .approvals-table th { background: #F8FAFC; padding: 14px 20px; font-size: 11.5px; font-weight: 700; color: #64748B; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid #E2E8F0; text-align: left; }
    .approvals-table th i { margin-right: 4px; color: #94A3B8; font-size: 13px; }
    .approvals-table td { padding: 16px 20px; border-bottom: 1px solid #F1F5F9; vertical-align: middle; font-size: 13.5px; color: #1E293B; transition: background-color 0.12s ease; }
    .company-row:hover td { background-color: #FAFAFA; }

    .company-cell { display: flex; align-items: center; gap: 14px; }
    .company-avatar {
        width: 42px; height: 42px; border-radius: 12px; background: #FC8019;
        color: #FFFFFF; font-weight: 700; font-size: 15px; display: flex; align-items: center; justify-content: center;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25); flex-shrink: 0; letter-spacing: 0.5px;
    }
    .company-info-wrap { min-width: 0; }
    .company-name-title { font-weight: 700; color: #0F172A; font-size: 14px; margin-bottom: 2px; }
    .company-meta-badge { font-size: 11px; color: #64748B; display: inline-flex; align-items: center; gap: 4px; }

    .contact-cell { display: flex; flex-direction: column; gap: 4px; }
    .contact-link { display: inline-flex; align-items: center; gap: 6px; color: #475569; font-size: 12.5px; text-decoration: none; transition: color 0.15s ease; }
    .contact-link:hover { color: #FC8019; }
    .contact-link i { font-size: 13px; color: #94A3B8; }

    .tax-badge-wrap { display: flex; flex-direction: column; gap: 5px; }
    .tax-chip {
        font-size: 11.5px; font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
        background: #F1F5F9; border: 1px solid #E2E8F0; padding: 3px 8px; border-radius: 6px; color: #334155;
        font-weight: 600; display: inline-flex; align-items: center; gap: 6px; width: fit-content;
    }
    .tax-chip-label { font-size: 10px; color: #64748B; text-transform: uppercase; font-family: inherit; font-weight: 700; }

    .status-pill { display: inline-flex; align-items: center; gap: 6px; padding: 5px 12px; border-radius: 50px; font-size: 12px; font-weight: 600; }
    .status-pill.pending { background: #FFFBEB; color: #D97706; border: 1px solid #FDE68A; }
    .status-pill.active { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }
    .status-pill.suspended { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }

    .actions-flex { display: flex; align-items: center; justify-content: flex-end; gap: 8px; }
    .btn-approval-accept {
        background: #10B981 !important; border: 1px solid #10B981 !important; color: #FFFFFF !important;
        padding: 7px 18px; border-radius: 50px; font-size: 12.5px; font-weight: 700; display: inline-flex; align-items: center; gap: 6px;
        cursor: pointer; transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); box-shadow: 0 2px 6px rgba(16, 185, 129, 0.22);
    }
    .btn-approval-accept:hover { background: #059669; transform: translateY(-1px); box-shadow: 0 5px 14px rgba(16, 185, 129, 0.35); }
    .btn-approval-accept i { font-size: 13px; transition: transform 0.2s ease; }
    .btn-approval-accept:hover i { transform: scale(1.15); }

    .btn-approval-reject {
        background: #FFFFFF; border: 1.5px solid #FCA5A5; color: #DC2626 !important; padding: 7px 18px; border-radius: 50px;
        font-size: 12.5px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); box-shadow: 0 1px 2px rgba(220, 38, 38, 0.05);
    }
    .btn-approval-reject:hover { background: #FEF2F2; border-color: #EF4444; color: #B91C1C !important; transform: translateY(-1px); box-shadow: 0 4px 10px rgba(239, 68, 68, 0.18); }
    .btn-approval-reject i { font-size: 13px; transition: transform 0.2s ease; }
    .btn-approval-reject:hover i { transform: scale(1.15); }

    .empty-caught-up-card { padding: 60px 24px; text-align: center; background: #FFFFFF; }
    .empty-shield-icon-box {
        width: 68px; height: 68px; border-radius: 20px; background: #ECFDF5; border: 1px solid #A7F3D0;
        color: #059669; font-size: 32px; display: flex; align-items: center; justify-content: center; margin: 0 auto 18px;
        box-shadow: 0 8px 24px rgba(16, 185, 129, 0.15);
    }
    .empty-caught-up-title { font-size: 17px; font-weight: 700; color: #0F172A; margin-bottom: 6px; }
    .empty-caught-up-desc { font-size: 13.5px; color: #64748B; max-width: 440px; margin: 0 auto 20px; line-height: 1.5; }
    .btn-view-all-tenants {
        background: #FFFFFF; border: 1.5px solid #E2E8F0; color: #475569; padding: 9px 24px; border-radius: 50px;
        font-size: 13px; font-weight: 600; display: inline-flex; align-items: center; gap: 8px; cursor: pointer; text-decoration: none; transition: all 0.2s ease;
    }
    .btn-view-all-tenants:hover { background: #F8FAFC; border-color: #CBD5E1; color: #0F172A; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(15, 23, 42, 0.08); }

    .custom-alert { border-radius: 12px; padding: 14px 18px; font-size: 13.5px; font-weight: 500; display: flex; align-items: center; gap: 10px; margin-bottom: 20px; }
    .custom-alert.success { background: #ECFDF5; border: 1px solid #A7F3D0; color: #065F46; }
    .custom-alert.danger { background: #FEF2F2; border: 1px solid #FECACA; color: #991B1B; }

    /* Custom Modern Confirmation Modal */
    .nl-modal-backdrop {
        position: fixed; inset: 0; background: rgba(15, 23, 42, 0.45);
        backdrop-filter: blur(5px); -webkit-backdrop-filter: blur(5px);
        display: flex; align-items: center; justify-content: center;
        z-index: 9999999; padding: 20px; opacity: 0;
        transition: opacity 0.2s cubic-bezier(0.16, 1, 0.3, 1); pointer-events: none;
    }
    .nl-modal-backdrop.show { opacity: 1; pointer-events: auto; }
    .nl-modal-dialog {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 24px;
        box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.25); max-width: 440px; width: 100%;
        padding: 32px 28px 24px; text-align: center; position: relative;
        transform: scale(0.92) translateY(12px); transition: transform 0.25s cubic-bezier(0.16, 1, 0.3, 1);
    }
    .nl-modal-backdrop.show .nl-modal-dialog { transform: scale(1) translateY(0); }
    .nl-modal-close {
        position: absolute; top: 18px; right: 18px; background: #F1F5F9; border: none;
        width: 32px; height: 32px; border-radius: 50px; display: flex; align-items: center;
        justify-content: center; color: #64748B; cursor: pointer; font-size: 16px; transition: all 0.15s ease;
    }
    .nl-modal-close:hover { background: #E2E8F0; color: #0F172A; }
    .nl-modal-icon-box {
        width: 60px; height: 60px; border-radius: 18px; margin: 0 auto 18px;
        display: flex; align-items: center; justify-content: center; font-size: 28px;
    }
    .nl-modal-icon-box.danger { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }
    .nl-modal-icon-box.success { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }
    .nl-modal-title { font-size: 19px; font-weight: 700; color: #0F172A; margin-bottom: 8px; letter-spacing: -0.3px; }
    .nl-modal-desc { font-size: 13.5px; color: #64748B; line-height: 1.5; margin: 0 0 24px 0; }
    .nl-modal-actions { display: flex; align-items: center; justify-content: center; gap: 12px; }
    .nl-modal-btn {
        padding: 9px 24px; border-radius: 50px; font-size: 13px; font-weight: 600;
        cursor: pointer; transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); border: none;
        display: inline-flex; align-items: center; gap: 6px;
    }
    .nl-modal-btn.cancel { background: #F1F5F9; color: #475569; border: 1px solid #E2E8F0; }
    .nl-modal-btn.cancel:hover { background: #E2E8F0; color: #0F172A; }
    .nl-modal-btn.confirm.danger { background: #DC2626 !important; color: #FFFFFF !important; box-shadow: 0 4px 12px rgba(220, 38, 38, 0.28); }
    .nl-modal-btn.confirm.danger:hover { background: #B91C1C !important; transform: translateY(-1px); }
    .nl-modal-btn.confirm.success { background: #10B981 !important; color: #FFFFFF !important; box-shadow: 0 4px 12px rgba(16, 185, 129, 0.28); }
    .nl-modal-btn.confirm.success:hover { background: #059669 !important; transform: translateY(-1px); }

</style>

<div class="approvals-page-container">

    <!-- Breadcrumb -->
    <div class="custom-breadcrumb">
        <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <i class="ti ti-chevron-right"></i>
        <span>Management</span>
        <i class="ti ti-chevron-right"></i>
        <span class="current">Company Approvals</span>
    </div>

    <!-- Alert Notifications -->
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="custom-alert success">
            <i class="ti ti-circle-check" style="font-size: 18px;"></i>
            <span>${sessionScope.successMessage}</span>
        </div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="custom-alert danger">
            <i class="ti ti-circle-x" style="font-size: 18px;"></i>
            <span>${sessionScope.errorMessage}</span>
        </div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <!-- Top Telemetry Header -->
    <div class="telemetry-header-card">
        <div class="telemetry-header-left">
            <div class="telemetry-icon-box">
                <i class="ti ti-shield-check"></i>
            </div>
            <div>
                <h4 class="telemetry-title">Company Approvals &amp; Tenant Governance</h4>
                <p class="telemetry-subtitle">Super Admin regulatory verification portal for B2B corporate registrations and freight licenses</p>
            </div>
        </div>
        <div>
            <span class="badge" style="background: #FFF0E5; color: #FC8019; font-weight: 700; font-size: 12px; padding: 7px 16px; border-radius: 50px; border: 1px solid #FED7AA;">
                <i class="ti ti-lock-access me-1"></i> Super Admin Clearance Required
            </span>
        </div>
    </div>

    <!-- 4 KPI Summary Cards -->
    <div class="kpi-grid">
        <div class="kpi-card" onclick="filterByTab('Pending')" style="cursor: pointer;">
            <div>
                <div class="kpi-label">Pending Approval</div>
                <div class="kpi-value" style="color: #D97706;">${not empty pendingCount ? pendingCount : 0}</div>
            </div>
            <div class="kpi-icon-pill amber">
                <i class="ti ti-clock-hour-4"></i>
            </div>
        </div>
        <div class="kpi-card" onclick="filterByTab('Active')" style="cursor: pointer;">
            <div>
                <div class="kpi-label">Active Verified</div>
                <div class="kpi-value" style="color: #059669;">${not empty activeCount ? activeCount : 0}</div>
            </div>
            <div class="kpi-icon-pill green">
                <i class="ti ti-circle-check"></i>
            </div>
        </div>
        <div class="kpi-card" onclick="filterByTab('Suspended')" style="cursor: pointer;" title="Click to view Suspended &amp; Rejected Companies">
            <div>
                <div class="kpi-label">Suspended / Rejected</div>
                <div class="kpi-value" style="color: #DC2626;">${not empty suspendedCount ? suspendedCount : 0}</div>
            </div>
            <div class="kpi-icon-pill red">
                <i class="ti ti-ban"></i>
            </div>
        </div>
        <div class="kpi-card" onclick="filterByTab('All')" style="cursor: pointer;">
            <div>
                <div class="kpi-label">Total Registered Tenants</div>
                <div class="kpi-value" style="color: #2563EB;">${not empty totalCount ? totalCount : 0}</div>
            </div>
            <div class="kpi-icon-pill blue">
                <i class="ti ti-building-community"></i>
            </div>
        </div>
    </div>

    <!-- Toolbar: Filter Tabs & Real-Time Search -->
    <div class="approvals-toolbar">
        <div class="nav-tabs-pill">
            <button type="button" class="tab-pill-btn active" id="tabPendingBtn" onclick="filterByTab('Pending')">
                <i class="ti ti-clock"></i> Pending Review
                <span class="tab-counter">${not empty pendingCount ? pendingCount : 0}</span>
            </button>
            <button type="button" class="tab-pill-btn" id="tabActiveBtn" onclick="filterByTab('Active')">
                <i class="ti ti-circle-check"></i> Active Companies
                <span class="tab-counter">${not empty activeCount ? activeCount : 0}</span>
            </button>
            <button type="button" class="tab-pill-btn" id="tabSuspendedBtn" onclick="filterByTab('Suspended')">
                <i class="ti ti-ban"></i> Suspended &amp; Rejected
                <span class="tab-counter" style="color: #DC2626; background: #FEF2F2;">${not empty suspendedCount ? suspendedCount : 0}</span>
            </button>
            <button type="button" class="tab-pill-btn" id="tabAllBtn" onclick="filterByTab('All')">
                <i class="ti ti-list"></i> All Tenants
                <span class="tab-counter">${not empty totalCount ? totalCount : 0}</span>
            </button>
        </div>

        <div class="table-search-wrap">
            <i class="ti ti-search"></i>
            <input type="text" id="companySearchInput" class="table-search-input form-control" placeholder="Search company, GST, license, email..." oninput="handleCompanySearch()">
        </div>
    </div>

    <!-- Table Container -->
    <div class="approvals-table-panel">
        <div class="table-responsive">
            <table class="approvals-table" id="companiesTable">
                <thead>
                    <tr>
                        <th style="padding-left: 24px;"><i class="ti ti-building"></i> Company Name</th>
                        <th><i class="ti ti-file-certificate"></i> GST / License No</th>
                        <th><i class="ti ti-address-book"></i> Contact Info</th>
                        <th><i class="ti ti-map-pin"></i> Registered Address</th>
                        <th><i class="ti ti-activity"></i> Status</th>
                        <th style="padding-right: 24px; text-align: right;"><i class="ti ti-settings"></i> Action</th>
                    </tr>
                </thead>
                <tbody id="companiesTableBody">
                    <c:forEach var="comp" items="${allCompanies}">
                        <tr class="company-row" 
                            data-status="${comp.approvalStatus}" 
                            data-search="${comp.companyName.toLowerCase()} ${comp.gstNo.toLowerCase()} ${comp.licenseNo.toLowerCase()} ${comp.contactEmail.toLowerCase()} ${comp.contactPhone} ${comp.address.toLowerCase()}">
                            
                            <!-- Company Name + Avatar -->
                            <td style="padding-left: 24px;">
                                <div class="company-cell">
                                    <div class="company-avatar">
                                        <c:set var="initials" value="${comp.companyName.substring(0, comp.companyName.length() >= 2 ? 2 : 1).toUpperCase()}" />
                                        ${initials}
                                    </div>
                                    <div class="company-info-wrap">
                                        <div class="company-name-title">${comp.companyName}</div>
                                        <div class="company-meta-badge">
                                            <i class="ti ti-hash"></i> CMP-${comp.companyId}
                                        </div>
                                    </div>
                                </div>
                            </td>

                            <!-- GST / PAN / License -->
                            <td>
                                <div class="tax-badge-wrap">
                                    <div class="tax-chip" title="GST / Tax Identification">
                                        <span class="tax-chip-label">GST</span>
                                        <span>${not empty comp.gstNo ? comp.gstNo : 'N/A'}</span>
                                    </div>
                                    <div class="tax-chip" title="Company License / Registration">
                                        <span class="tax-chip-label">LIC</span>
                                        <span>${not empty comp.licenseNo ? comp.licenseNo : 'N/A'}</span>
                                    </div>
                                </div>
                            </td>

                            <!-- Contact Details -->
                            <td>
                                <div class="contact-cell">
                                    <a href="mailto:${comp.contactEmail}" class="contact-link" title="Send Email">
                                        <i class="ti ti-mail"></i>
                                        <span>${comp.contactEmail}</span>
                                    </a>
                                    <a href="tel:${comp.contactPhone}" class="contact-link" title="Call Phone">
                                        <i class="ti ti-phone"></i>
                                        <span>${comp.contactPhone}</span>
                                    </a>
                                </div>
                            </td>

                            <!-- Address -->
                            <td style="max-width: 260px;">
                                <div style="display: flex; align-items: flex-start; gap: 6px; font-size: 13px; color: #475569; line-height: 1.4;">
                                    <i class="ti ti-map-pin" style="color: #94A3B8; font-size: 14px; margin-top: 2px; flex-shrink: 0;"></i>
                                    <span>${comp.address}</span>
                                </div>
                            </td>

                            <!-- Status Badge -->
                            <td>
                                <c:choose>
                                    <c:when test="${comp.approvalStatus == 'Pending'}">
                                        <span class="status-pill pending">
                                            <i class="ti ti-clock"></i> Pending Review
                                        </span>
                                    </c:when>
                                    <c:when test="${comp.approvalStatus == 'Active'}">
                                        <span class="status-pill active">
                                            <i class="ti ti-circle-check"></i> Approved
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-pill suspended">
                                            <i class="ti ti-ban"></i> Suspended
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <!-- Actions -->
                            <td style="padding-right: 24px; text-align: right;">
                                <c:choose>
                                    <c:when test="${comp.approvalStatus == 'Pending'}">
                                        <div class="actions-flex">
                                            <!-- Approve Button -->
                                            <form  method="POST" class="d-inline m-0">
                                                <input type="hidden" name="companyId" value="${comp.companyId}">
                                                <input type="hidden" name="action" value="accept">
                                                <button type="submit" class="btn-approval-accept" title="Approve and activate company">
                                                    <i class="ti ti-check"></i> Approve
                                                </button>
                                            </form>
                                            <!-- Reject Button -->
                                            <form  method="POST" class="d-inline m-0">
                                                <input type="hidden" name="companyId" value="${comp.companyId}">
                                                <input type="hidden" name="action" value="reject">
                                                <button type="button" class="btn-approval-reject" title="Reject registration" onclick="showCustomConfirm({title: 'Reject Company Registration?', desc: 'Are you sure you want to reject this enterprise tenant registration?', icon: 'ti ti-x', type: 'danger', confirmText: 'Yes, Reject', form: this.form});">
                                                    <i class="ti ti-x"></i> Reject
                                                </button>
                                            </form>
                                        </div>
                                    </c:when>
                                    <c:when test="${comp.approvalStatus == 'Active'}">
                                        <form  method="POST" class="d-inline m-0">
                                            <input type="hidden" name="companyId" value="${comp.companyId}">
                                            <input type="hidden" name="action" value="reject">
                                            <button type="button" class="btn-approval-reject" title="Suspend verified company" onclick="showCustomConfirm({title: 'Suspend Enterprise Tenant?', desc: 'Are you sure you want to suspend this company? All associated operations and user accounts will be deactivated.', icon: 'ti ti-ban', type: 'danger', confirmText: 'Yes, Suspend Company', form: this.form});" style="padding: 5px 14px; font-size: 11.5px;">
                                                <i class="ti ti-ban"></i> Suspend
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <form  method="POST" class="d-inline m-0">
                                            <input type="hidden" name="companyId" value="${comp.companyId}">
                                            <input type="hidden" name="action" value="accept">
                                            <button type="button" class="btn-approval-accept" title="Reactivate company" onclick="showCustomConfirm({title: 'Reactivate Enterprise Tenant?', desc: 'Are you sure you want to restore and reactivate this company account?', icon: 'ti ti-reload', type: 'success', confirmText: 'Yes, Reactivate', form: this.form});" style="padding: 5px 14px; font-size: 11.5px;">
                                                <i class="ti ti-reload"></i> Reactivate
                                            </button>
                                        </form>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <!-- Modern Empty State (shown if tab has 0 records) -->
        <div id="emptyStateBox" class="empty-caught-up-card" style="display: none;">
            <div class="empty-shield-icon-box">
                <i class="ti ti-shield-check"></i>
            </div>
            <div class="empty-caught-up-title" id="emptyStateTitle">All Caught Up!</div>
            <p class="empty-caught-up-desc" id="emptyStateDesc">
                There are currently no pending company registration requests requiring Super Admin verification. All corporate onboarding is up to date.
            </p>
            <button type="button" class="btn-view-all-tenants" onclick="filterByTab('All')">
                <i class="ti ti-list"></i> View All Registered Tenants
            </button>
        </div>
    </div>

    <!-- Custom Action Confirmation Modal -->
    <div id="nlCustomConfirmModal" class="nl-modal-backdrop" style="display: none;">
        <div class="nl-modal-dialog">
            <button type="button" class="nl-modal-close" onclick="closeCustomConfirmModal()" aria-label="Close">
                <i class="ti ti-x"></i>
            </button>
            <div class="nl-modal-icon-box danger" id="nlConfirmIconBox">
                <i class="ti ti-alert-triangle" id="nlConfirmIcon"></i>
            </div>
            <h5 class="nl-modal-title" id="nlConfirmTitle">Confirm Action</h5>
            <p class="nl-modal-desc" id="nlConfirmDesc">Are you sure you want to proceed with this action?</p>
            <div class="nl-modal-actions">
                <button type="button" class="nl-modal-btn cancel" onclick="closeCustomConfirmModal()">Cancel</button>
                <button type="button" class="nl-modal-btn confirm danger" id="nlConfirmSubmitBtn">Confirm</button>
            </div>
        </div>
    </div>

</div>

<script>

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
        requestAnimationFrame(() => {
            modal.classList.add('show');
        });
    }

    function closeCustomConfirmModal() {
        const modal = document.getElementById('nlCustomConfirmModal');
        modal.classList.remove('show');
        setTimeout(() => {
            modal.style.display = 'none';
            pendingFormToSubmit = null;
        }, 200);
    }

    document.addEventListener('DOMContentLoaded', function() {
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

        const modal = document.getElementById('nlCustomConfirmModal');
        if (modal) {
            modal.addEventListener('click', function(e) {
                if (e.target === this) closeCustomConfirmModal();
            });
        }

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') closeCustomConfirmModal();
        });
    });

    let currentTab = 'Pending';

    function filterByTab(tab) {
        currentTab = tab;

        document.getElementById('tabPendingBtn').classList.toggle('active', tab === 'Pending');
        document.getElementById('tabActiveBtn').classList.toggle('active', tab === 'Active');
        if (document.getElementById('tabSuspendedBtn')) {
            document.getElementById('tabSuspendedBtn').classList.toggle('active', tab === 'Suspended');
        }
        document.getElementById('tabAllBtn').classList.toggle('active', tab === 'All');

        applyFilters();
    }

    function handleCompanySearch() {
        applyFilters();
    }

    function applyFilters() {
        const query = document.getElementById('companySearchInput').value.trim().toLowerCase();
        const rows = document.querySelectorAll('.company-row');
        let visibleCount = 0;

        rows.forEach(row => {
            const status = row.getAttribute('data-status');
            const searchData = row.getAttribute('data-search') || '';

            const matchesTab = (currentTab === 'All') || (currentTab === 'Suspended' ? (status === 'Suspended' || status === 'Rejected') : (status === currentTab));
            const matchesQuery = !query || searchData.includes(query);

            if (matchesTab && matchesQuery) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });

        const table = document.getElementById('companiesTable');
        const emptyState = document.getElementById('emptyStateBox');
        const emptyTitle = document.getElementById('emptyStateTitle');
        const emptyDesc = document.getElementById('emptyStateDesc');

        if (visibleCount === 0) {
            table.style.display = 'none';
            emptyState.style.display = 'block';

            if (query) {
                emptyTitle.textContent = 'No Companies Found';
                emptyDesc.textContent = 'No company records matched your search query "' + query + '". Try adjusting your keywords.';
            } else if (currentTab === 'Pending') {
                emptyTitle.textContent = 'All Caught Up!';
                emptyDesc.textContent = 'There are currently no pending company registration requests requiring Super Admin verification. All corporate onboarding is up to date.';
            } else if (currentTab === 'Active') {
                emptyTitle.textContent = 'No Active Companies';
                emptyDesc.textContent = 'There are currently no companies with Active approval status in the system.';
            } else if (currentTab === 'Suspended') {
                emptyTitle.textContent = 'No Suspended or Rejected Companies';
                emptyDesc.textContent = 'Good news! There are currently no suspended or rejected company accounts in the system.';
            } else {
                emptyTitle.textContent = 'No Company Records';
                emptyDesc.textContent = 'No registered companies found in the database.';
            }
        } else {
            table.style.display = 'table';
            emptyState.style.display = 'none';
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        filterByTab('Pending');
    });
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
