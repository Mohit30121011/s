<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Self-contained resilient controller logic: supports direct JSP access or servlet forwarding
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        if (action != null) {
            try {
                com.nlogistic.dao.VesselDAO vDao = new com.nlogistic.dao.VesselDAO();
                if ("add".equals(action)) {
                    String name = request.getParameter("vesselName");
                    String imo = request.getParameter("imoNumber");
                    String capStr = request.getParameter("capacityTeu");
                    int cap = 0;
                    if (capStr != null && !capStr.trim().isEmpty()) {
                        try { cap = Integer.parseInt(capStr.trim()); } catch(Exception ignored) {}
                    }
                    vDao.addVessel(name != null ? name.trim() : "", imo != null ? imo.trim() : "", cap);
                    session.setAttribute("successMessage", "Vessel \"" + (name != null ? name.trim() : "") + "\" registered to maritime fleet successfully.");
                } else if ("edit".equals(action)) {
                    String vIdStr = request.getParameter("vesselId");
                    String name = request.getParameter("vesselName");
                    String imo = request.getParameter("imoNumber");
                    String capStr = request.getParameter("capacityTeu");
                    if (vIdStr != null) {
                        int vId = Integer.parseInt(vIdStr);
                        int cap = 0;
                        if (capStr != null && !capStr.trim().isEmpty()) {
                            try { cap = Integer.parseInt(capStr.trim()); } catch(Exception ignored) {}
                        }
                        try (java.sql.Connection conn = com.nlogistic.util.DBConnectionManager.getConnection();
                             java.sql.PreparedStatement ps = conn.prepareStatement(
                                "UPDATE vessels SET vessel_name = ?, imo_number = ?, capacity_teu = ? WHERE vessel_id = ?")) {
                            ps.setString(1, name != null ? name.trim() : "");
                            ps.setString(2, imo != null ? imo.trim() : "");
                            ps.setInt(3, cap);
                            ps.setInt(4, vId);
                            ps.executeUpdate();
                            session.setAttribute("successMessage", "Vessel #VSL-" + vId + " details updated successfully.");
                        }
                    }
                } else if ("delete".equals(action)) {
                    String vIdStr = request.getParameter("vesselId");
                    if (vIdStr != null) {
                        int vId = Integer.parseInt(vIdStr);
                        try (java.sql.Connection conn = com.nlogistic.util.DBConnectionManager.getConnection();
                             java.sql.PreparedStatement ps = conn.prepareStatement("DELETE FROM vessels WHERE vessel_id = ?")) {
                            ps.setInt(1, vId);
                            ps.executeUpdate();
                            session.setAttribute("successMessage", "Vessel #VSL-" + vId + " decommissioned and removed from fleet.");
                        }
                    }
                }
            } catch(Exception ex) {
                ex.printStackTrace();
                session.setAttribute("errorMessage", "Operation failed: " + ex.getMessage());
            }
            response.sendRedirect(request.getRequestURI());
            return;
        }
    }

    if (request.getAttribute("vessels") == null) {
        com.nlogistic.dao.VesselDAO vDao = new com.nlogistic.dao.VesselDAO();
        java.util.List<com.nlogistic.model.Vessel> vList = vDao.getAllVessels();
        request.setAttribute("vessels", vList);
    }

    // Compute live KPI metrics
    java.util.List<com.nlogistic.model.Vessel> allVessels = (java.util.List<com.nlogistic.model.Vessel>) request.getAttribute("vessels");
    int totalFleetCount = (allVessels != null) ? allVessels.size() : 0;
    long totalTeuCapacity = 0;
    int ulcvCount = 0; // >= 14,000 TEU
    int panamaxCount = 0;

    if (allVessels != null) {
        for (com.nlogistic.model.Vessel v : allVessels) {
            int cap = v.getCapacityTeu();
            totalTeuCapacity += cap;
            if (cap >= 14000) {
                ulcvCount++;
            } else if (cap >= 3000) {
                panamaxCount++;
            }
        }
    }
    long avgCapacity = (totalFleetCount > 0) ? (totalTeuCapacity / totalFleetCount) : 0;

    request.setAttribute("totalFleetCount", totalFleetCount);
    request.setAttribute("totalTeuCapacity", totalTeuCapacity);
    request.setAttribute("avgCapacity", avgCapacity);
    request.setAttribute("ulcvCount", ulcvCount);
%>

<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* ==========================================================================
       MARITIME FLEET & VESSEL GOVERNANCE THEME (SWIGGY ORANGE ENTERPRISE)
       ========================================================================== */
    .vessels-page-container {
        padding: 0 4px 40px;
    }
    .custom-breadcrumb {
        display: flex; align-items: center; gap: 8px; font-size: 13px; color: #64748B; margin-bottom: 16px;
    }
    .custom-breadcrumb a { color: #64748B; text-decoration: none; transition: color 0.15s ease; }
    .custom-breadcrumb a:hover { color: #FC8019; }
    .custom-breadcrumb i { font-size: 11px; color: #94A3B8; }
    .custom-breadcrumb .current { color: #FC8019; font-weight: 600; }

    /* Telemetry Header Card */
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

    .btn-add-vessel {
        background: #FC8019; color: #FFFFFF; border: none; font-weight: 600; font-size: 13.5px;
        padding: 10px 22px; border-radius: 50px; display: inline-flex; align-items: center; gap: 8px;
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.28); transition: all 0.2s ease; cursor: pointer; text-decoration: none;
    }
    .btn-add-vessel:hover {
        background: #E67012; color: #FFFFFF; transform: translateY(-1px); box-shadow: 0 6px 16px rgba(252, 128, 25, 0.36);
    }

    /* KPI Grid */
    .kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 18px; margin-bottom: 24px; }
    @media (max-width: 1024px) { .kpi-grid { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 640px) { .kpi-grid { grid-template-columns: 1fr; } }

    .kpi-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 14px; padding: 18px 20px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03); display: flex; align-items: center; justify-content: space-between;
        transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
    }
    .kpi-card:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,0,0,0.06); border-color: #CBD5E1; }
    .kpi-label { font-size: 12px; font-weight: 600; color: #64748B; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.4px; }
    .kpi-value { font-size: 24px; font-weight: 800; color: #0F172A; line-height: 1; }
    .kpi-icon-pill { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 22px; flex-shrink: 0; }
    .kpi-icon-pill.blue { background: #EFF6FF; color: #2563EB; }
    .kpi-icon-pill.green { background: #ECFDF5; color: #059669; }
    .kpi-icon-pill.orange { background: #FFF0E5; color: #FC8019; }
    .kpi-icon-pill.amber { background: #FFFBEB; color: #D97706; }

    /* Toolbar: Filters & Real-Time Search */
    .vessels-toolbar {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 14px 14px 0 0; padding: 16px 24px;
        display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 16px; border-bottom: 1px solid #F1F5F9;
    }
    .toolbar-left { display: flex; align-items: center; gap: 14px; flex-wrap: wrap; flex: 1; }
    
    .table-search-wrap { position: relative; width: 320px; }
    .table-search-wrap i { position: absolute; left: 16px; top: 50%; transform: translateY(-50%); color: #94A3B8; font-size: 15px; }
    .table-search-input {
        width: 100%; height: 42px; padding-left: 42px !important; padding-right: 18px !important;
        border-radius: 50px !important; font-size: 13px !important; border: 1.5px solid #E2E8F0 !important; background: #F8FAFC !important;
        outline: none; transition: all 0.2s ease;
    }
    .table-search-input:focus {
        background: #FFFFFF !important; border-color: #FC8019 !important; box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.14) !important;
    }

    /* Capacity Filter Dropdown Wrap (No awkward text wrapping) */
    .capacity-filter-wrap {
        min-width: 270px !important;
        position: relative !important;
    }
    .capacity-filter-wrap .ts-wrapper,
    .capacity-filter-wrap .ts-control {
        min-width: 270px !important;
        white-space: nowrap !important;
        height: 42px !important;
        min-height: 42px !important;
        display: flex !important;
        align-items: center !important;
        padding-left: 18px !important;
        padding-right: 36px !important;
    }
    .capacity-filter-wrap .ts-control .item {
        white-space: nowrap !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
        font-size: 13px !important;
        font-weight: 600 !important;
        color: #1E293B !important;
        line-height: 1 !important;
    }
    .ts-dropdown {
        min-width: 280px !important;
        white-space: nowrap !important;
    }
    .ts-dropdown .option {
        white-space: nowrap !important;
        font-size: 13px !important;
        padding: 10px 18px !important;
    }

    .toolbar-count-badge {
        font-size: 12.5px; font-weight: 600; color: #64748B; background: #F8FAFC; border: 1px solid #E2E8F0;
        padding: 6px 14px; border-radius: 50px; display: inline-flex; align-items: center; gap: 6px;
    }

    /* Table Panel */
    .vessels-table-panel {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-top: none; border-radius: 0 0 16px 16px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04); overflow: hidden;
    }
    .vessels-table { width: 100%; border-collapse: collapse; margin: 0; }
    .vessels-table th {
        background: #F8FAFC; padding: 14px 20px; font-size: 11.5px; font-weight: 700; color: #64748B;
        text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid #E2E8F0; text-align: left;
    }
    .vessels-table th i { margin-right: 4px; color: #94A3B8; font-size: 13px; }
    .vessels-table td {
        padding: 16px 20px; border-bottom: 1px solid #F1F5F9; vertical-align: middle;
        font-size: 13.5px; color: #1E293B; transition: background-color 0.12s ease;
    }
    .vessel-row:hover td { background-color: #FAFAFA; }

    /* Vessel Cell Avatar & Info */
    .vessel-cell { display: flex; align-items: center; gap: 14px; }
    .vessel-avatar {
        width: 42px; height: 42px; border-radius: 12px; background: #FFF0E5;
        color: #FC8019; font-size: 20px; display: flex; align-items: center; justify-content: center;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.18); flex-shrink: 0;
    }
    .vessel-name-title { font-size: 14px; font-weight: 700; color: #0F172A; line-height: 1.3; }
    .vessel-meta-badge { font-size: 11.5px; color: #64748B; font-weight: 500; display: flex; align-items: center; gap: 4px; margin-top: 2px; }

    /* IMO Monospace Badge */
    .imo-badge {
        font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
        font-size: 12px; font-weight: 600; padding: 4px 10px; border-radius: 6px;
        background: #F1F5F9; color: #334155; border: 1px solid #E2E8F0; display: inline-flex; align-items: center; gap: 5px;
    }

    /* Vessel Class Badges */
    .class-pill {
        font-size: 12px; font-weight: 700; padding: 4px 12px; border-radius: 50px; display: inline-flex; align-items: center; gap: 5px;
    }
    .class-pill.ulcv { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }
    .class-pill.post-panamax { background: #FFFBEB; color: #D97706; border: 1px solid #FDE68A; }
    .class-pill.panamax { background: #EFF6FF; color: #2563EB; border: 1px solid #BFDBFE; }
    .class-pill.feeder { background: #F8FAFC; color: #475569; border: 1px solid #CBD5E1; }

    /* Capacity Progress Bar */
    .capacity-wrapper { min-width: 140px; }
    .capacity-text { font-size: 13.5px; font-weight: 700; color: #0F172A; margin-bottom: 4px; display: flex; justify-content: space-between; align-items: center; }
    .capacity-bar-track { width: 100%; height: 6px; background: #F1F5F9; border-radius: 50px; overflow: hidden; }
    .capacity-bar-fill { height: 100%; background: linear-gradient(90deg, #FC8019, #F59E0B); border-radius: 50px; transition: width 0.4s ease; }

    /* Operational Status Pill */
    .status-pill {
        display: inline-flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 700;
        padding: 5px 12px; border-radius: 50px;
    }
    .status-pill.active { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }
    .status-pill-dot { width: 7px; height: 7px; border-radius: 50%; background: #059669; box-shadow: 0 0 0 2px rgba(5, 150, 105, 0.2); }

    /* Action Buttons */
    .actions-flex { display: flex; align-items: center; justify-content: flex-end; gap: 8px; }
    .btn-action-icon {
        width: 34px; height: 34px; border-radius: 8px; border: 1px solid #E2E8F0; background: #FFFFFF;
        color: #64748B; display: inline-flex; align-items: center; justify-content: center; font-size: 15px;
        transition: all 0.15s ease; cursor: pointer; text-decoration: none;
    }
    .btn-action-icon:hover { border-color: #CBD5E1; background: #F8FAFC; color: #0F172A; }
    .btn-action-icon.edit:hover { border-color: #FC8019; color: #FC8019; background: #FFF0E5; }
    .btn-action-icon.delete:hover { border-color: #DC2626; color: #DC2626; background: #FEF2F2; }

    /* Empty State */
    .empty-state-box { padding: 64px 20px; text-align: center; display: none; }
    .empty-state-icon {
        width: 64px; height: 64px; border-radius: 50%; background: #FFF0E5; color: #FC8019;
        display: inline-flex; align-items: center; justify-content: center; font-size: 28px; margin-bottom: 16px;
    }
    .empty-state-title { font-size: 16px; font-weight: 700; color: #0F172A; margin-bottom: 6px; }
    .empty-state-desc { font-size: 13.5px; color: #64748B; max-width: 420px; margin: 0 auto 16px; }

    /* Pagination Bar */
    .pagination-bar {
        padding: 16px 24px; display: flex; align-items: center; justify-content: space-between;
        background: #FFFFFF; border-top: 1px solid #F1F5F9; font-size: 13px; color: #64748B;
    }
    .page-btn {
        background: #FFFFFF; border: 1.5px solid #E2E8F0; color: #475569; font-size: 12.5px;
        font-weight: 600; padding: 6px 14px; border-radius: 8px; cursor: pointer; transition: all 0.15s ease;
    }
    .page-btn:hover:not(:disabled) { border-color: #FC8019; color: #FC8019; background: #FFF0E5; }
    .page-btn:disabled { opacity: 0.5; cursor: not-allowed; }
    .page-numbers-wrap { display: flex; align-items: center; gap: 6px; }
    .page-num-pill {
        width: 32px; height: 32px; display: inline-flex; align-items: center; justify-content: center;
        border-radius: 8px; font-weight: 700; font-size: 12.5px; cursor: pointer; border: 1px solid transparent;
        color: #64748B; transition: all 0.15s ease;
    }
    .page-num-pill:hover { background: #F1F5F9; color: #0F172A; }
    .page-num-pill.active { background: #FC8019; color: #FFFFFF; box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25); }

    /* ==========================================================================
       ENTERPRISE MODAL STYLING (ADD / EDIT / DELETE)
       ========================================================================== */
    .custom-modal-backdrop {
        position: fixed; inset: 0; background: rgba(15, 23, 42, 0.45);
        backdrop-filter: blur(4px); -webkit-backdrop-filter: blur(4px);
        z-index: 1050; display: none; align-items: center; justify-content: center; padding: 20px;
    }
    .custom-modal-dialog {
        background: #FFFFFF; border-radius: 20px; width: 100%; max-width: 520px;
        box-shadow: 0 20px 40px -15px rgba(0,0,0,0.2); border: 1px solid #E2E8F0;
        overflow: hidden; transform: translateY(15px); opacity: 0;
        transition: transform 0.22s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.22s ease;
    }
    .custom-modal-backdrop.show .custom-modal-dialog { transform: translateY(0); opacity: 1; }
    
    .modal-hero-header {
        padding: 24px 28px 18px; border-bottom: 1px solid #F1F5F9;
        display: flex; align-items: flex-start; justify-content: space-between; gap: 16px;
    }
    .modal-hero-icon {
        width: 46px; height: 46px; border-radius: 12px; background: #FFF0E5; color: #FC8019;
        display: flex; align-items: center; justify-content: center; font-size: 22px; flex-shrink: 0;
        box-shadow: 0 2px 8px rgba(252, 128, 25, 0.2);
    }
    .modal-hero-icon.danger {
        background: #FEF2F2; color: #DC2626; box-shadow: 0 2px 8px rgba(220, 38, 38, 0.2);
    }
    .modal-hero-title { font-size: 18px; font-weight: 700; color: #0F172A; margin: 0 0 3px 0; letter-spacing: -0.2px; }
    .modal-hero-desc { font-size: 13px; color: #64748B; margin: 0; line-height: 1.4; }
    .btn-modal-close {
        background: transparent; border: none; font-size: 20px; color: #94A3B8; cursor: pointer;
        padding: 4px; border-radius: 6px; display: flex; align-items: center; justify-content: center;
        transition: color 0.15s ease, background-color 0.15s ease;
    }
    .btn-modal-close:hover { color: #0F172A; background-color: #F1F5F9; }

    .modal-form-body { padding: 22px 28px; }
    .field-group { margin-bottom: 18px; }
    .field-label {
        font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px; display: block;
    }

    /* Absolute Input + Lead Icon (Bulletproof No-Overlap Styling) */
    .field-input-wrap {
        position: relative !important;
        width: 100% !important;
    }
    .field-input-wrap i {
        position: absolute !important;
        left: 18px !important;
        top: 50% !important;
        transform: translateY(-50%) !important;
        color: #94A3B8 !important;
        font-size: 18px !important;
        z-index: 5 !important;
        pointer-events: none !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        width: 20px !important;
        height: 20px !important;
    }
    .field-input-wrap input.field-input,
    .field-input-wrap input,
    input.field-input {
        padding-left: 50px !important;
        padding-right: 20px !important;
        border-radius: 50px !important;
        height: 48px !important;
        min-height: 48px !important;
        font-size: 13.5px !important;
        border: 1.5px solid #E2E8F0 !important;
        background: #FFFFFF !important;
        color: #0F172A !important;
        width: 100% !important;
        outline: none !important;
        transition: all 0.2s ease !important;
        box-sizing: border-box !important;
    }
    .field-input-wrap input.field-input:focus,
    .field-input-wrap input:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3.5px rgba(252, 128, 25, 0.16) !important;
    }
    .field-helper { font-size: 11.5px; color: #94A3B8; margin-top: 5px; }

    /* Quick Preset Chips */
    .preset-chips-wrap { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 8px; }
    .preset-chip {
        font-size: 11px; font-weight: 600; padding: 4px 10px; border-radius: 50px;
        background: #F8FAFC; border: 1px solid #E2E8F0; color: #64748B; cursor: pointer;
        transition: all 0.15s ease;
    }
    .preset-chip:hover { border-color: #FC8019; color: #FC8019; background: #FFF0E5; }

    .modal-form-footer {
        padding: 16px 28px 24px; display: flex; align-items: center; justify-content: flex-end; gap: 10px;
        border-top: 1px solid #F1F5F9;
    }
    .btn-modal-cancel {
        background: #FFFFFF; border: 1.5px solid #E2E8F0; padding: 9px 20px; border-radius: 50px;
        font-size: 13px; font-weight: 600; color: #475569; cursor: pointer; transition: all 0.15s ease;
    }
    .btn-modal-cancel:hover { background: #F8FAFC; border-color: #CBD5E1; color: #0F172A; }
    .btn-modal-submit {
        background: #FC8019; border: none; padding: 10px 24px; border-radius: 50px;
        font-size: 13px; font-weight: 600; color: #FFFFFF; cursor: pointer; display: inline-flex;
        align-items: center; gap: 6px; box-shadow: 0 4px 12px rgba(252, 128, 25, 0.28); transition: all 0.2s ease;
    }
    .btn-modal-submit:hover {
        background: #E67012; transform: translateY(-1px); box-shadow: 0 6px 16px rgba(252, 128, 25, 0.36);
    }
    .btn-modal-danger {
        background: #DC2626; border: none; padding: 10px 24px; border-radius: 50px;
        font-size: 13px; font-weight: 600; color: #FFFFFF; cursor: pointer; display: inline-flex;
        align-items: center; gap: 6px; box-shadow: 0 4px 12px rgba(220, 38, 38, 0.28); transition: all 0.2s ease;
    }
    .btn-modal-danger:hover {
        background: #B91C1C; transform: translateY(-1px); box-shadow: 0 6px 16px rgba(220, 38, 38, 0.36);
    }
</style>

<div class="vessels-page-container">
    
    <!-- Custom Breadcrumbs -->
    <div class="custom-breadcrumb">
        <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <i class="ti ti-chevron-right"></i>
        <span>Maritime Operations</span>
        <i class="ti ti-chevron-right"></i>
        <span class="current">Vessels Registry</span>
    </div>

    <!-- Telemetry Header Card -->
    <div class="telemetry-header-card">
        <div class="telemetry-header-left">
            <div class="telemetry-icon-box">
                <i class="ti ti-ship"></i>
            </div>
            <div>
                <h1 class="telemetry-title">Maritime Vessels &amp; Fleet Directory</h1>
                <p class="telemetry-subtitle">
                    Manage carrier vessels, IMO compliance registry, TEU payload capacities, and global maritime deployments.
                </p>
            </div>
        </div>
        <div class="d-flex align-items-center gap-3">
            <span class="toolbar-count-badge">
                <i class="ti ti-anchor" style="color: #FC8019;"></i> Active Fleet: ${totalFleetCount} Carriers
            </span>
            <button type="button" class="btn-add-vessel" onclick="openAddVesselModal()">
                <i class="ti ti-plus"></i> Register New Vessel
            </button>
        </div>
    </div>

    <!-- Flash Messages -->
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success d-flex align-items-center justify-content-between mb-4" style="border-radius: 12px; background: #ECFDF5; border: 1px solid #A7F3D0; color: #065F46; padding: 14px 20px;">
            <div class="d-flex align-items-center gap-2">
                <i class="ti ti-circle-check" style="font-size: 18px; color: #059669;"></i>
                <span style="font-size: 13.5px; font-weight: 500;">${sessionScope.successMessage}</span>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger d-flex align-items-center justify-content-between mb-4" style="border-radius: 12px; background: #FEF2F2; border: 1px solid #FECACA; color: #991B1B; padding: 14px 20px;">
            <div class="d-flex align-items-center gap-2">
                <i class="ti ti-alert-circle" style="font-size: 18px; color: #DC2626;"></i>
                <span style="font-size: 13.5px; font-weight: 500;">${sessionScope.errorMessage}</span>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <!-- 4-KPI Metric Cards Grid -->
    <div class="kpi-grid">
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Active Fleet Size</div>
                <div class="kpi-value" style="color: #2563EB;">${totalFleetCount}</div>
            </div>
            <div class="kpi-icon-pill blue">
                <i class="ti ti-ship"></i>
            </div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Total Fleet Capacity</div>
                <div class="kpi-value" style="color: #059669;">
                    <fmt:formatNumber value="${totalTeuCapacity}" pattern="#,###" /> <span style="font-size: 14px; font-weight: 600; color: #64748B;">TEU</span>
                </div>
            </div>
            <div class="kpi-icon-pill green">
                <i class="ti ti-box-seam"></i>
            </div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Average Carrier Payload</div>
                <div class="kpi-value" style="color: #FC8019;">
                    <fmt:formatNumber value="${avgCapacity}" pattern="#,###" /> <span style="font-size: 14px; font-weight: 600; color: #64748B;">TEU</span>
                </div>
            </div>
            <div class="kpi-icon-pill orange">
                <i class="ti ti-chart-arrows-vertical"></i>
            </div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Ultra Large Fleet (ULCV)</div>
                <div class="kpi-value" style="color: #D97706;">${ulcvCount}</div>
            </div>
            <div class="kpi-icon-pill amber">
                <i class="ti ti-award"></i>
            </div>
        </div>
    </div>

    <!-- Toolbar: Search & Filter -->
    <div class="vessels-toolbar">
        <div class="toolbar-left">
            <!-- Search Box -->
            <div class="table-search-wrap">
                <i class="ti ti-search"></i>
                <input type="text" id="vesselSearchInput" class="table-search-input" placeholder="Search vessels by name, IMO, or ID..." oninput="handleFilter()">
            </div>

            <!-- Capacity Tier Filter (Wrapped in capacity-filter-wrap with no text wrapping) -->
            <div class="capacity-filter-wrap">
                <select id="capacityFilter" class="form-select-custom" onchange="handleFilter()">
                    <option value="ALL">All Vessel Classes</option>
                    <option value="FEEDER">Feeder (&lt; 3,000 TEU)</option>
                    <option value="PANAMAX">Panamax (3,000 - 10,000 TEU)</option>
                    <option value="POST_PANAMAX">Post-Panamax (10,000 - 14,000 TEU)</option>
                    <option value="ULCV">Ultra Large (&gt;= 14,000 TEU)</option>
                </select>
            </div>
        </div>

        <div class="d-flex align-items-center gap-2">
            <span class="toolbar-count-badge" id="showingCountBadge">
                <i class="ti ti-list"></i> Showing ${totalFleetCount} Vessels
            </span>
        </div>
    </div>

    <!-- Vessels Table Panel -->
    <div class="vessels-table-panel">
        <div class="table-responsive">
            <table class="vessels-table" id="vesselsTable">
                <thead>
                    <tr>
                        <th style="padding-left: 24px; width: 110px;"><i class="ti ti-hash"></i> Vessel ID</th>
                        <th><i class="ti ti-ship"></i> Vessel &amp; Identity</th>
                        <th><i class="ti ti-shield-check"></i> IMO Number</th>
                        <th><i class="ti ti-category"></i> Classification</th>
                        <th style="width: 200px;"><i class="ti ti-box-seam"></i> Capacity (TEU)</th>
                        <th><i class="ti ti-activity"></i> Status</th>
                        <th style="padding-right: 24px; text-align: right;"><i class="ti ti-settings"></i> Actions</th>
                    </tr>
                </thead>
                <tbody id="vesselsTableBody">
                    <c:forEach var="v" items="${vessels}">
                        <tr class="vessel-row"
                            data-id="${v.vesselId}"
                            data-name="${v.vesselName}"
                            data-imo="${v.imoNumber}"
                            data-capacity="${v.capacityTeu}"
                            data-search="${v.vesselName.toLowerCase()} ${v.imoNumber.toLowerCase()} vsl-${v.vesselId} ${v.vesselId}">
                            
                            <!-- Vessel ID -->
                            <td style="padding-left: 24px;">
                                <span class="imo-badge" style="background: #F8FAFC; color: #64748B;">
                                    VSL-${v.vesselId}
                                </span>
                            </td>

                            <!-- Vessel Name & Avatar -->
                            <td>
                                <div class="vessel-cell">
                                    <div class="vessel-avatar">
                                        <i class="ti ti-ship"></i>
                                    </div>
                                    <div>
                                        <div class="vessel-name-title">${v.vesselName}</div>
                                        <div class="vessel-meta-badge">
                                            <i class="ti ti-world"></i> International Carrier
                                        </div>
                                    </div>
                                </div>
                            </td>

                            <!-- IMO Number -->
                            <td>
                                <span class="imo-badge">
                                    <i class="ti ti-shield-check" style="color: #059669; font-size: 13px;"></i>
                                    ${v.imoNumber}
                                </span>
                            </td>

                            <!-- Classification Pill -->
                            <td>
                                <c:choose>
                                    <c:when test="${v.capacityTeu >= 14000}">
                                        <span class="class-pill ulcv" title="Ultra Large Container Vessel">
                                            <i class="ti ti-award"></i> Ultra Large (ULCV)
                                        </span>
                                    </c:when>
                                    <c:when test="${v.capacityTeu >= 10000}">
                                        <span class="class-pill post-panamax" title="Post-Panamax Container Carrier">
                                            <i class="ti ti-anchor"></i> Post-Panamax
                                        </span>
                                    </c:when>
                                    <c:when test="${v.capacityTeu >= 3000}">
                                        <span class="class-pill panamax" title="Panamax Class Carrier">
                                            <i class="ti ti-compass"></i> Panamax Class
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="class-pill feeder" title="Feedermax Regional Vessel">
                                            <i class="ti ti-sailboat"></i> Feedermax
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <!-- Capacity Progress & Value -->
                            <td>
                                <div class="capacity-wrapper">
                                    <div class="capacity-text">
                                        <span><fmt:formatNumber value="${v.capacityTeu}" pattern="#,###" /></span>
                                        <span style="font-size: 11px; color: #64748B; font-weight: 500;">TEU</span>
                                    </div>
                                    <c:set var="capPercent" value="${(v.capacityTeu / 24000.0) * 100.0}" />
                                    <div class="capacity-bar-track" title="${v.capacityTeu} TEU payload rating">
                                        <div class="capacity-bar-fill" style="width: ${capPercent > 100 ? 100 : (capPercent < 15 ? 15 : capPercent)}%;"></div>
                                    </div>
                                </div>
                            </td>

                            <!-- Status -->
                            <td>
                                <span class="status-pill active">
                                    <span class="status-pill-dot"></span> In Service
                                </span>
                            </td>

                            <!-- Actions -->
                            <td style="padding-right: 24px; text-align: right;">
                                <div class="actions-flex">
                                    <button type="button" class="btn-action-icon edit" title="Edit Vessel Details"
                                            onclick="openEditVesselModal('${v.vesselId}', '${v.vesselName}', '${v.imoNumber}', '${v.capacityTeu}')">
                                        <i class="ti ti-edit"></i>
                                    </button>
                                    <button type="button" class="btn-action-icon delete" title="Decommission Vessel"
                                            onclick="openDeleteVesselModal('${v.vesselId}', '${v.vesselName}', '${v.imoNumber}')">
                                        <i class="ti ti-trash"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <!-- Empty State Box -->
        <div class="empty-state-box" id="emptyStateBox">
            <div class="empty-state-icon">
                <i class="ti ti-ship-off"></i>
            </div>
            <h3 class="empty-state-title" id="emptyStateTitle">No Vessels Found</h3>
            <p class="empty-state-desc" id="emptyStateDesc">
                No maritime carrier records matched your current query. Try adjusting your search keywords or capacity filter.
            </p>
            <button type="button" class="btn-modal-cancel" onclick="resetFilters()">
                <i class="ti ti-reload me-1"></i> Reset Filters
            </button>
        </div>

        <!-- Pagination Bar -->
        <div class="pagination-bar" id="vesselsPagination">
            <div id="pageInfoText">Showing page 1 of 1</div>
            <div class="d-flex align-items-center gap-2">
                <button type="button" class="page-btn" id="prevPageBtn" onclick="changePage(-1)">
                    <i class="ti ti-chevron-left me-1"></i> Previous
                </button>
                <div class="page-numbers-wrap" id="pageNumbersWrap"></div>
                <button type="button" class="page-btn" id="nextPageBtn" onclick="changePage(1)">
                    Next <i class="ti ti-chevron-right ms-1"></i>
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ==========================================================================
     REVAMPED ENTERPRISE MODAL: REGISTER NEW VESSEL
     ========================================================================== -->
<div class="custom-modal-backdrop" id="addVesselModal">
    <div class="custom-modal-dialog">
        <div class="modal-hero-header">
            <div class="d-flex align-items-center gap-3">
                <div class="modal-hero-icon">
                    <i class="ti ti-ship"></i>
                </div>
                <div>
                    <h3 class="modal-hero-title">Register New Vessel</h3>
                    <p class="modal-hero-desc">Add a commercial carrier to the global maritime logistics registry.</p>
                </div>
            </div>
            <button type="button" class="btn-modal-close" onclick="closeAddVesselModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/jsp/vessels.jsp" id="addVesselForm">
            <input type="hidden" name="action" value="add">
            <div class="modal-form-body">
                <!-- Vessel Name -->
                <div class="field-group">
                    <label class="field-label">Vessel Official Name <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-ship"></i>
                        <input type="text" class="field-input" name="vesselName" id="addVesselName" required placeholder="e.g. CMA CGM Jacques Saadé">
                    </div>
                    <div class="field-helper">Registered vessel commercial name as listed on maritime bill of lading.</div>
                </div>

                <!-- IMO Number -->
                <div class="field-group">
                    <label class="field-label">IMO Registration Number <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-shield-check"></i>
                        <input type="text" class="field-input" name="imoNumber" id="addImoNumber" required placeholder="e.g. IMO9839179" style="font-family: monospace; text-transform: uppercase;">
                    </div>
                    <div class="field-helper">Official 7-digit IMO carrier identifier allocated by IHS Markit.</div>
                </div>

                <!-- Capacity TEU -->
                <div class="field-group">
                    <label class="field-label">Cargo Capacity (TEU) <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-box-seam"></i>
                        <input type="number" class="field-input" name="capacityTeu" id="addCapacityTeu" required min="100" max="30000" placeholder="e.g. 18000">
                    </div>
                    <!-- Quick Preset Chips -->
                    <div class="preset-chips-wrap">
                        <span class="preset-chip" onclick="setCapacityPreset('addCapacityTeu', 2500)">Feeder (2,500)</span>
                        <span class="preset-chip" onclick="setCapacityPreset('addCapacityTeu', 6500)">Panamax (6,500)</span>
                        <span class="preset-chip" onclick="setCapacityPreset('addCapacityTeu', 12000)">Post-Panamax (12,000)</span>
                        <span class="preset-chip" onclick="setCapacityPreset('addCapacityTeu', 20000)">ULCV (20,000)</span>
                    </div>
                </div>
            </div>
            <div class="modal-form-footer">
                <button type="button" class="btn-modal-cancel" onclick="closeAddVesselModal()">Cancel</button>
                <button type="submit" class="btn-modal-submit">
                    <i class="ti ti-check"></i> Register Vessel
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ==========================================================================
     REVAMPED ENTERPRISE MODAL: EDIT VESSEL DETAILS
     ========================================================================== -->
<div class="custom-modal-backdrop" id="editVesselModal">
    <div class="custom-modal-dialog">
        <div class="modal-hero-header">
            <div class="d-flex align-items-center gap-3">
                <div class="modal-hero-icon">
                    <i class="ti ti-edit"></i>
                </div>
                <div>
                    <h3 class="modal-hero-title">Edit Vessel Details</h3>
                    <p class="modal-hero-desc">Update registry credentials, IMO number, or payload capacity.</p>
                </div>
            </div>
            <button type="button" class="btn-modal-close" onclick="closeEditVesselModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/jsp/vessels.jsp" id="editVesselForm">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="vesselId" id="editVesselId">
            <div class="modal-form-body">
                <!-- Vessel Name -->
                <div class="field-group">
                    <label class="field-label">Vessel Official Name <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-ship"></i>
                        <input type="text" class="field-input" name="vesselName" id="editVesselName" required>
                    </div>
                </div>

                <!-- IMO Number -->
                <div class="field-group">
                    <label class="field-label">IMO Registration Number <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-shield-check"></i>
                        <input type="text" class="field-input" name="imoNumber" id="editImoNumber" required style="font-family: monospace; text-transform: uppercase;">
                    </div>
                </div>

                <!-- Capacity TEU -->
                <div class="field-group">
                    <label class="field-label">Cargo Capacity (TEU) <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-box-seam"></i>
                        <input type="number" class="field-input" name="capacityTeu" id="editCapacityTeu" required min="100" max="30000">
                    </div>
                    <!-- Quick Preset Chips -->
                    <div class="preset-chips-wrap">
                        <span class="preset-chip" onclick="setCapacityPreset('editCapacityTeu', 2500)">Feeder (2,500)</span>
                        <span class="preset-chip" onclick="setCapacityPreset('editCapacityTeu', 6500)">Panamax (6,500)</span>
                        <span class="preset-chip" onclick="setCapacityPreset('editCapacityTeu', 12000)">Post-Panamax (12,000)</span>
                        <span class="preset-chip" onclick="setCapacityPreset('editCapacityTeu', 20000)">ULCV (20,000)</span>
                    </div>
                </div>
            </div>
            <div class="modal-form-footer">
                <button type="button" class="btn-modal-cancel" onclick="closeEditVesselModal()">Cancel</button>
                <button type="submit" class="btn-modal-submit">
                    <i class="ti ti-check"></i> Update Vessel
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ==========================================================================
     REVAMPED ENTERPRISE MODAL: CONFIRM DECOMMISSION / DELETE
     ========================================================================== -->
<div class="custom-modal-backdrop" id="deleteVesselModal">
    <div class="custom-modal-dialog">
        <div class="modal-hero-header">
            <div class="d-flex align-items-center gap-3">
                <div class="modal-hero-icon danger">
                    <i class="ti ti-alert-triangle"></i>
                </div>
                <div>
                    <h3 class="modal-hero-title">Decommission Carrier?</h3>
                    <p class="modal-hero-desc">Confirm permanent removal of this vessel from operational logistics.</p>
                </div>
            </div>
            <button type="button" class="btn-modal-close" onclick="closeDeleteVesselModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/jsp/vessels.jsp" id="deleteVesselForm">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="vesselId" id="deleteVesselId">
            <div class="modal-form-body">
                <p style="font-size: 13.5px; color: #475569; line-height: 1.5; margin-bottom: 0;">
                    Are you sure you want to permanently decommission and delete <strong id="deleteVesselNameDisplay" style="color: #0F172A;"></strong> (<span id="deleteVesselImoDisplay" style="font-family: monospace;"></span>)?
                    This carrier will no longer be available for shipment scheduling or container manifest assignments.
                </p>
            </div>
            <div class="modal-form-footer">
                <button type="button" class="btn-modal-cancel" onclick="closeDeleteVesselModal()">Cancel</button>
                <button type="submit" class="btn-modal-danger">
                    <i class="ti ti-trash"></i> Yes, Decommission
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ==========================================================================
     FRONTEND CONTROLLER & SEARCH / FILTER / PAGINATION JS
     ========================================================================== -->
<script>
    let allVesselRows = [];
    let matchingVesselRows = [];
    let currentPage = 1;
    const pageSize = 10;

    document.addEventListener('DOMContentLoaded', function() {
        allVesselRows = Array.from(document.querySelectorAll('.vessel-row'));
        handleFilter();
    });

    function handleFilter() {
        const query = (document.getElementById('vesselSearchInput').value || '').trim().toLowerCase();
        const tier = document.getElementById('capacityFilter').value;

        matchingVesselRows = [];

        allVesselRows.forEach(row => {
            const searchData = row.getAttribute('data-search') || '';
            const cap = parseInt(row.getAttribute('data-capacity') || '0', 10);

            // Tier Match
            let matchesTier = true;
            if (tier === 'FEEDER') {
                matchesTier = (cap < 3000);
            } else if (tier === 'PANAMAX') {
                matchesTier = (cap >= 3000 && cap < 10000);
            } else if (tier === 'POST_PANAMAX') {
                matchesTier = (cap >= 10000 && cap < 14000);
            } else if (tier === 'ULCV') {
                matchesTier = (cap >= 14000);
            }

            // Search Query Match
            const matchesQuery = !query || searchData.includes(query);

            if (matchesTier && matchesQuery) {
                matchingVesselRows.push(row);
            }
        });

        currentPage = 1;
        renderPage();
    }

    function renderPage() {
        const table = document.getElementById('vesselsTable');
        const emptyState = document.getElementById('emptyStateBox');
        const pagination = document.getElementById('vesselsPagination');
        const countBadge = document.getElementById('showingCountBadge');

        const totalMatches = matchingVesselRows.length;
        countBadge.innerHTML = '<i class="ti ti-list"></i> Showing ' + totalMatches + ' of ' + allVesselRows.length + ' Vessels';

        if (totalMatches === 0) {
            table.style.display = 'none';
            emptyState.style.display = 'block';
            pagination.style.display = 'none';
            allVesselRows.forEach(row => row.style.display = 'none');
            return;
        }

        table.style.display = 'table';
        emptyState.style.display = 'none';
        pagination.style.display = 'flex';

        const totalPages = Math.ceil(totalMatches / pageSize);
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        const startIndex = (currentPage - 1) * pageSize;
        const endIndex = startIndex + pageSize;

        allVesselRows.forEach(row => row.style.display = 'none');
        matchingVesselRows.slice(startIndex, endIndex).forEach(row => {
            row.style.display = '';
        });

        // Update pagination text
        document.getElementById('pageInfoText').textContent = 
            'Showing ' + (startIndex + 1) + ' - ' + Math.min(endIndex, totalMatches) + ' of ' + totalMatches + ' Vessels (Page ' + currentPage + ' of ' + totalPages + ')';

        document.getElementById('prevPageBtn').disabled = (currentPage <= 1);
        document.getElementById('nextPageBtn').disabled = (currentPage >= totalPages);

        // Build Page Numbers
        const numbersWrap = document.getElementById('pageNumbersWrap');
        numbersWrap.innerHTML = '';
        
        let startPage = Math.max(1, currentPage - 2);
        let endPage = Math.min(totalPages, startPage + 4);
        if (endPage - startPage < 4) {
            startPage = Math.max(1, endPage - 4);
        }

        for (let i = startPage; i <= endPage; i++) {
            const btn = document.createElement('div');
            btn.className = 'page-num-pill' + (i === currentPage ? ' active' : '');
            btn.textContent = i;
            btn.onclick = (function(pageNum) {
                return function() {
                    currentPage = pageNum;
                    renderPage();
                };
            })(i);
            numbersWrap.appendChild(btn);
        }
    }

    function changePage(delta) {
        currentPage += delta;
        renderPage();
    }

    function resetFilters() {
        document.getElementById('vesselSearchInput').value = '';
        const capSelect = document.getElementById('capacityFilter');
        if (capSelect.tomselect) {
            capSelect.tomselect.setValue('ALL');
        } else {
            capSelect.value = 'ALL';
        }
        handleFilter();
    }

    function setCapacityPreset(inputId, value) {
        const input = document.getElementById(inputId);
        if (input) {
            input.value = value;
            input.focus();
        }
    }

    // Modal Handlers
    function openAddVesselModal() {
        const modal = document.getElementById('addVesselModal');
        modal.style.display = 'flex';
        setTimeout(() => modal.classList.add('show'), 10);
        document.getElementById('addVesselName').focus();
    }

    function closeAddVesselModal() {
        const modal = document.getElementById('addVesselModal');
        modal.classList.remove('show');
        setTimeout(() => modal.style.display = 'none', 200);
    }

    function openEditVesselModal(id, name, imo, capacity) {
        document.getElementById('editVesselId').value = id;
        document.getElementById('editVesselName').value = name;
        document.getElementById('editImoNumber').value = imo;
        document.getElementById('editCapacityTeu').value = capacity;

        const modal = document.getElementById('editVesselModal');
        modal.style.display = 'flex';
        setTimeout(() => modal.classList.add('show'), 10);
        document.getElementById('editVesselName').focus();
    }

    function closeEditVesselModal() {
        const modal = document.getElementById('editVesselModal');
        modal.classList.remove('show');
        setTimeout(() => modal.style.display = 'none', 200);
    }

    function openDeleteVesselModal(id, name, imo) {
        document.getElementById('deleteVesselId').value = id;
        document.getElementById('deleteVesselNameDisplay').textContent = name;
        document.getElementById('deleteVesselImoDisplay').textContent = imo;

        const modal = document.getElementById('deleteVesselModal');
        modal.style.display = 'flex';
        setTimeout(() => modal.classList.add('show'), 10);
    }

    function closeDeleteVesselModal() {
        const modal = document.getElementById('deleteVesselModal');
        modal.classList.remove('show');
        setTimeout(() => modal.style.display = 'none', 200);
    }

    // Close modal on escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeAddVesselModal();
            closeEditVesselModal();
            closeDeleteVesselModal();
        }
    });

    // Close modal on backdrop click
    ['addVesselModal', 'editVesselModal', 'deleteVesselModal'].forEach(id => {
        const modal = document.getElementById(id);
        if (modal) {
            modal.addEventListener('click', function(e) {
                if (e.target === modal) {
                    if (id === 'addVesselModal') closeAddVesselModal();
                    if (id === 'editVesselModal') closeEditVesselModal();
                    if (id === 'deleteVesselModal') closeDeleteVesselModal();
                }
            });
        }
    });
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
