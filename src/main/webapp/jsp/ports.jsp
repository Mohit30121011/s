<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Self-contained resilient controller logic: supports direct JSP access or servlet forwarding
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        if (action != null) {
            try {
                com.nlogistic.dao.PortDAO pDao = new com.nlogistic.dao.PortDAO();
                if ("add".equalsIgnoreCase(action)) {
                    String name = request.getParameter("portName");
                    String code = request.getParameter("portCode");
                    String country = request.getParameter("country");
                    String latStr = request.getParameter("latitude");
                    String lngStr = request.getParameter("longitude");

                    double lat = 0.0;
                    double lng = 0.0;
                    if (latStr != null && !latStr.trim().isEmpty()) {
                        try { lat = Double.parseDouble(latStr.trim()); } catch (Exception ignored) {}
                    }
                    if (lngStr != null && !lngStr.trim().isEmpty()) {
                        try { lng = Double.parseDouble(lngStr.trim()); } catch (Exception ignored) {}
                    }

                    if (name != null && !name.trim().isEmpty()) {
                        pDao.addPort(name.trim(), code != null ? code.trim().toUpperCase() : "", country != null ? country.trim() : "", lat, lng);
                        session.setAttribute("successMessage", "Port \"" + name.trim() + "\" registered successfully to international directory.");
                    } else {
                        session.setAttribute("errorMessage", "Port official name is required.");
                    }
                } else if ("edit".equalsIgnoreCase(action) || "update".equalsIgnoreCase(action)) {
                    String pIdStr = request.getParameter("portId");
                    String name = request.getParameter("portName");
                    String code = request.getParameter("portCode");
                    String country = request.getParameter("country");
                    String latStr = request.getParameter("latitude");
                    String lngStr = request.getParameter("longitude");

                    if (pIdStr != null && !pIdStr.trim().isEmpty()) {
                        int pId = Integer.parseInt(pIdStr.trim());
                        double lat = 0.0;
                        double lng = 0.0;
                        if (latStr != null && !latStr.trim().isEmpty()) {
                            try { lat = Double.parseDouble(latStr.trim()); } catch (Exception ignored) {}
                        }
                        if (lngStr != null && !lngStr.trim().isEmpty()) {
                            try { lng = Double.parseDouble(lngStr.trim()); } catch (Exception ignored) {}
                        }

                        if (name != null && !name.trim().isEmpty()) {
                            pDao.updatePort(pId, name.trim(), code != null ? code.trim().toUpperCase() : "", country != null ? country.trim() : "", lat, lng);
                            session.setAttribute("successMessage", "Port #PRT-" + pId + " (" + name.trim() + ") credentials updated successfully.");
                        } else {
                            session.setAttribute("errorMessage", "Port name cannot be empty.");
                        }
                    }
                } else if ("delete".equalsIgnoreCase(action)) {
                    String pIdStr = request.getParameter("portId");
                    if (pIdStr != null && !pIdStr.trim().isEmpty()) {
                        int pId = Integer.parseInt(pIdStr.trim());
                        pDao.deletePort(pId);
                        session.setAttribute("successMessage", "Port #PRT-" + pId + " decommissioned and removed from directory.");
                    }
                }
            } catch (Exception ex) {
                ex.printStackTrace();
                session.setAttribute("errorMessage", "Operation failed: " + ex.getMessage());
            }
            response.sendRedirect(request.getRequestURI());
            return;
        }
    }

    if (request.getAttribute("ports") == null) {
        com.nlogistic.dao.PortDAO pDao = new com.nlogistic.dao.PortDAO();
        java.util.List<com.nlogistic.model.Port> pList = pDao.getAllPorts();
        request.setAttribute("ports", pList);
    }

    // Compute live KPI metrics
    java.util.List<com.nlogistic.model.Port> allPorts = (java.util.List<com.nlogistic.model.Port>) request.getAttribute("ports");
    int totalPortsCount = (allPorts != null) ? allPorts.size() : 0;
    java.util.Set<String> uniqueCountries = new java.util.HashSet<String>();
    int geotaggedCount = 0;

    if (allPorts != null) {
        for (com.nlogistic.model.Port p : allPorts) {
            if (p.getCountry() != null && !p.getCountry().trim().isEmpty()) {
                uniqueCountries.add(p.getCountry().trim());
            }
            if (p.getLatitude() != 0.0 || p.getLongitude() != 0.0) {
                geotaggedCount++;
            }
        }
    }
    int distinctCountriesCount = uniqueCountries.size();
    int activeHubsCount = totalPortsCount;

    request.setAttribute("totalPortsCount", totalPortsCount);
    request.setAttribute("distinctCountriesCount", distinctCountriesCount);
    request.setAttribute("geotaggedCount", geotaggedCount);
    request.setAttribute("activeHubsCount", activeHubsCount);
%>

<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* ==========================================================================
       GLOBAL PORTS & HARBOR TERMINAL DIRECTORY (SWIGGY ORANGE ENTERPRISE)
       ========================================================================== */
    .ports-page-container {
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
        width: 54px; height: 54px; border-radius: 14px;
        background: linear-gradient(135deg, #FFF3EA 0%, #FFE6D5 100%);
        border: 1.5px solid rgba(252, 128, 25, 0.25);
        display: flex; align-items: center; justify-content: center;
        color: #FC8019; font-size: 26px; flex-shrink: 0;
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.12);
    }
    .telemetry-title { font-size: 22px; font-weight: 700; color: #0F172A; margin: 0 0 4px; letter-spacing: -0.02em; }
    .telemetry-desc { font-size: 13px; color: #64748B; margin: 0; }
    .telemetry-actions { display: flex; align-items: center; gap: 12px; }

    .btn-register-primary {
        background: linear-gradient(135deg, #FC8019 0%, #E66A00 100%);
        color: #FFFFFF !important; font-weight: 600; font-size: 13.5px;
        padding: 10px 22px; border-radius: 50px; border: none;
        display: inline-flex; align-items: center; gap: 8px;
        box-shadow: 0 4px 14px rgba(252, 128, 25, 0.3);
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); cursor: pointer; text-decoration: none;
    }
    .btn-register-primary:hover {
        transform: translateY(-1px);
        box-shadow: 0 6px 20px rgba(252, 128, 25, 0.4);
        color: #FFFFFF !important;
    }
    .btn-register-primary:active { transform: translateY(0); }

    /* KPI Cards Grid */
    .kpi-grid {
        display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 18px; margin-bottom: 24px;
    }
    .kpi-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 14px; padding: 20px 22px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03); transition: transform 0.2s ease, box-shadow 0.2s ease;
        position: relative; overflow: hidden;
    }
    .kpi-card:hover {
        transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.06); border-color: #CBD5E1;
    }
    .kpi-card-inner { display: flex; align-items: center; justify-content: space-between; }
    .kpi-label { font-size: 12.5px; font-weight: 600; color: #64748B; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.04em; }
    .kpi-value { font-size: 26px; font-weight: 800; color: #0F172A; line-height: 1; letter-spacing: -0.03em; }
    .kpi-badge {
        display: inline-flex; align-items: center; gap: 5px; font-size: 11.5px; font-weight: 600;
        padding: 3px 8px; border-radius: 20px; margin-top: 8px;
    }
    .kpi-badge-orange { background: #FFF3EA; color: #FC8019; border: 1px solid rgba(252, 128, 25, 0.2); }
    .kpi-badge-blue { background: #EFF6FF; color: #2563EB; border: 1px solid rgba(37, 99, 235, 0.2); }
    .kpi-badge-green { background: #ECFDF5; color: #059669; border: 1px solid rgba(5, 150, 105, 0.2); }
    .kpi-badge-purple { background: #F5F3FF; color: #7C3AED; border: 1px solid rgba(124, 58, 237, 0.2); }

    .kpi-icon-wrap {
        width: 46px; height: 46px; border-radius: 12px; display: flex; align-items: center; justify-content: center;
        font-size: 22px; flex-shrink: 0;
    }
    .kpi-icon-orange { background: #FFF3EA; color: #FC8019; }
    .kpi-icon-blue { background: #EFF6FF; color: #2563EB; }
    .kpi-icon-green { background: #ECFDF5; color: #059669; }
    .kpi-icon-purple { background: #F5F3FF; color: #7C3AED; }

    /* Directory Main Card & Toolbar */
    .ports-main-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 16px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03); overflow: hidden;
    }
    .toolbar-bar {
        padding: 18px 24px; border-bottom: 1px solid #F1F5F9;
        display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 14px;
        background: #FFFFFF;
    }
    .toolbar-left { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; flex: 1; }

    .table-search-box {
        position: relative; min-width: 280px; max-width: 400px; flex: 1;
    }
    .table-search-box i {
        position: absolute; left: 16px; top: 50%; transform: translateY(-50%);
        color: #94A3B8; font-size: 15px; pointer-events: none;
    }
    .table-search-input {
        width: 100%; height: 42px; padding: 0 16px 0 42px; border-radius: 50px;
        border: 1.5px solid #E2E8F0; font-size: 13px; font-weight: 500; color: #1E293B;
        background-color: #F8FAFC; outline: none; transition: all 0.2s ease;
    }
    .table-search-input:focus {
        background-color: #FFFFFF; border-color: #FC8019; box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.14);
    }

    /* Country Filter Dropdown Wrap (No awkward text wrapping) */
    .country-filter-wrap {
        min-width: 250px !important;
        position: relative !important;
    }
    .country-filter-wrap .ts-wrapper,
    .country-filter-wrap .ts-control {
        min-width: 250px !important;
        white-space: nowrap !important;
        height: 42px !important;
        border-radius: 50px !important;
        border: 1.5px solid #E2E8F0 !important;
        background-color: #F8FAFC !important;
        padding-left: 18px !important;
        padding-right: 36px !important;
    }
    .country-filter-wrap .ts-control .item {
        white-space: nowrap !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
        font-size: 13px !important;
        font-weight: 600 !important;
        color: #1E293B !important;
        line-height: 1 !important;
    }
    .ts-dropdown {
        min-width: 260px !important;
        white-space: nowrap !important;
    }
    .ts-dropdown .option {
        white-space: nowrap !important;
        font-size: 13px !important;
        padding: 10px 18px !important;
    }

    .toolbar-count-badge {
        font-size: 12.5px; font-weight: 600; color: #64748B; background: #F1F5F9;
        padding: 6px 14px; border-radius: 50px; display: inline-flex; align-items: center; gap: 6px;
    }
    .btn-reset-filter {
        height: 40px; padding: 0 16px; border-radius: 50px; border: 1.5px solid #E2E8F0;
        background: #FFFFFF; color: #64748B; font-size: 13px; font-weight: 600;
        display: inline-flex; align-items: center; gap: 6px; cursor: pointer; transition: all 0.15s ease;
    }
    .btn-reset-filter:hover {
        background: #FFF3EA; color: #FC8019; border-color: #FC8019;
    }

    /* Enterprise Table Styling */
    .enterprise-table {
        width: 100%; border-collapse: separate; border-spacing: 0; margin: 0;
    }
    .enterprise-table thead th {
        background: #F8FAFC; color: #475569; font-size: 11.5px; font-weight: 700;
        text-transform: uppercase; letter-spacing: 0.05em; padding: 14px 20px;
        border-bottom: 1.5px solid #E2E8F0; border-top: none;
    }
    .enterprise-table tbody tr {
        transition: background-color 0.15s ease;
    }
    .enterprise-table tbody tr:hover {
        background-color: #FFFBF7 !important;
    }
    .enterprise-table tbody td {
        padding: 16px 20px; vertical-align: middle; border-bottom: 1px solid #F1F5F9;
        font-size: 13.5px; color: #1E293B;
    }

    /* Table Badges & Elements */
    .port-id-badge {
        font-family: 'JetBrains Mono', 'Fira Code', monospace; font-size: 12px; font-weight: 700;
        color: #FC8019; background: #FFF3EA; padding: 4px 10px; border-radius: 6px;
        border: 1px solid rgba(252, 128, 25, 0.25); display: inline-block;
    }
    .port-icon-avatar {
        width: 38px; height: 38px; border-radius: 10px;
        background: linear-gradient(135deg, #FFF3EA 0%, #FFE6D5 100%);
        border: 1px solid rgba(252, 128, 25, 0.2);
        color: #FC8019; display: flex; align-items: center; justify-content: center;
        font-size: 18px; flex-shrink: 0;
    }
    .port-name-main { font-weight: 700; color: #0F172A; font-size: 14px; margin-bottom: 3px; }
    .port-code-badge {
        font-family: monospace; font-size: 11px; font-weight: 700;
        color: #475569; background: #F1F5F9; padding: 2px 7px; border-radius: 4px;
        border: 1px solid #CBD5E1; letter-spacing: 0.05em;
    }

    .coords-badge {
        font-family: 'JetBrains Mono', monospace; font-size: 12px; font-weight: 600;
        color: #334155; background: #F8FAFC; padding: 5px 10px; border-radius: 6px;
        border: 1px solid #E2E8F0; display: inline-flex; align-items: center; gap: 5px;
    }
    .coords-badge i { color: #FC8019; font-size: 13px; }

    .country-cell {
        display: inline-flex; align-items: center; gap: 8px; font-weight: 600; color: #334155;
    }
    .country-cell i { color: #2563EB; font-size: 15px; }

    /* Operational Status Badge */
    .badge-status-operational {
        background: #ECFDF5; color: #059669; border: 1px solid rgba(5, 150, 105, 0.2);
        font-size: 11.5px; font-weight: 700; padding: 4px 10px; border-radius: 50px;
        display: inline-flex; align-items: center; gap: 6px; text-transform: uppercase; letter-spacing: 0.03em;
    }
    .pulse-dot {
        width: 7px; height: 7px; border-radius: 50%; background-color: #10B981;
        box-shadow: 0 0 0 2px rgba(16, 185, 129, 0.25);
        animation: pulseAnimation 2s infinite ease-in-out;
    }
    @keyframes pulseAnimation {
        0% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.5); }
        70% { box-shadow: 0 0 0 5px rgba(16, 185, 129, 0); }
        100% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
    }

    /* Actions Button Group */
    .actions-group { display: flex; align-items: center; gap: 8px; justify-content: flex-end; }
    .action-btn {
        width: 32px; height: 32px; border-radius: 8px; border: 1px solid transparent;
        display: inline-flex; align-items: center; justify-content: center;
        font-size: 14px; cursor: pointer; transition: all 0.15s ease; background: transparent;
    }
    .action-btn-edit { color: #FC8019; background: #FFF3EA; border-color: rgba(252, 128, 25, 0.2); }
    .action-btn-edit:hover { background: #FC8019; color: #FFFFFF; }
    .action-btn-delete { color: #DC2626; background: #FEF2F2; border-color: rgba(220, 38, 38, 0.2); }
    .action-btn-delete:hover { background: #DC2626; color: #FFFFFF; }

    /* Empty State */
    .empty-state-box {
        padding: 60px 20px; text-align: center;
    }
    .empty-state-icon {
        width: 70px; height: 70px; border-radius: 20px; background: #FFF3EA; color: #FC8019;
        display: inline-flex; align-items: center; justify-content: center; font-size: 32px; margin-bottom: 16px;
    }
    .empty-state-title { font-size: 17px; font-weight: 700; color: #0F172A; margin-bottom: 6px; }
    .empty-state-desc { font-size: 13.5px; color: #64748B; max-width: 420px; margin: 0 auto 20px; }

    /* Modern Pagination */
    .pagination-bar {
        padding: 16px 24px; border-top: 1px solid #F1F5F9;
        display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 14px;
        background: #FFFFFF;
    }
    .page-info { font-size: 13px; color: #64748B; font-weight: 500; }
    .pagination-controls { display: flex; align-items: center; gap: 6px; }
    .page-btn {
        height: 36px; padding: 0 14px; border-radius: 50px; border: 1.5px solid #E2E8F0;
        background: #FFFFFF; color: #475569; font-size: 12.5px; font-weight: 600;
        cursor: pointer; display: inline-flex; align-items: center; justify-content: center;
        transition: all 0.15s ease;
    }
    .page-btn:hover:not(:disabled) {
        background: #FFF3EA; color: #FC8019; border-color: #FC8019;
    }
    .page-btn:disabled { opacity: 0.45; cursor: not-allowed; }
    .page-numbers-wrap { display: flex; align-items: center; gap: 4px; }
    .page-num {
        width: 36px; height: 36px; border-radius: 50%; border: 1.5px solid #E2E8F0;
        background: #FFFFFF; color: #475569; font-size: 12.5px; font-weight: 600;
        cursor: pointer; display: inline-flex; align-items: center; justify-content: center;
        transition: all 0.15s ease;
    }
    .page-num:hover { border-color: #FC8019; color: #FC8019; }
    .page-num.active { background: #FC8019; color: #FFFFFF; border-color: #FC8019; font-weight: 700; }

    /* ==========================================================================
       ENTERPRISE MODALS STYLING (MATCHING EXACT SWIGGY ORANGE THEME)
       ========================================================================== */
    .custom-modal-backdrop {
        position: fixed; inset: 0; background: rgba(15, 23, 42, 0.55);
        backdrop-filter: blur(4px); z-index: 1050; display: none;
        align-items: center; justify-content: center; padding: 16px;
    }
    .custom-modal-backdrop.show { display: flex; }
    .custom-modal-dialog {
        background: #FFFFFF; border-radius: 20px; width: 100%; max-width: 520px;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); border: 1px solid #E2E8F0;
        overflow: hidden; animation: modalFadeIn 0.2s ease-out;
    }
    @keyframes modalFadeIn {
        from { opacity: 0; transform: scale(0.96) translateY(8px); }
        to { opacity: 1; transform: scale(1) translateY(0); }
    }
    .modal-hero-header {
        padding: 22px 28px; border-bottom: 1px solid #F1F5F9;
        display: flex; align-items: center; justify-content: space-between;
    }
    .modal-hero-icon {
        width: 44px; height: 44px; border-radius: 12px;
        background: #FFF3EA; color: #FC8019; font-size: 22px;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .modal-hero-icon.danger {
        background: #FEF2F2; color: #DC2626;
    }
    .modal-hero-title { font-size: 17px; font-weight: 700; color: #0F172A; margin: 0; }
    .modal-hero-desc { font-size: 12.5px; color: #64748B; margin: 2px 0 0; }
    .btn-modal-close {
        background: transparent; border: none; font-size: 24px; color: #94A3B8;
        cursor: pointer; line-height: 1; padding: 4px; border-radius: 6px;
        transition: color 0.15s ease;
    }
    .btn-modal-close:hover { color: #0F172A; }

    .modal-form-body { padding: 24px 28px; }
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
    .preset-chip:hover {
        background: #FFF3EA; color: #FC8019; border-color: #FC8019;
    }

    .modal-form-footer {
        padding: 16px 28px 24px; display: flex; align-items: center; justify-content: flex-end; gap: 10px;
    }
    .btn-modal-cancel {
        padding: 10px 20px; border-radius: 50px; border: 1.5px solid #E2E8F0;
        background: #FFFFFF; color: #64748B; font-weight: 600; font-size: 13px;
        cursor: pointer; transition: all 0.15s ease;
    }
    .btn-modal-cancel:hover { background: #F8FAFC; color: #334155; }
    .btn-modal-submit {
        padding: 10px 24px; border-radius: 50px; border: none;
        background: linear-gradient(135deg, #FC8019 0%, #E66A00 100%);
        color: #FFFFFF; font-weight: 600; font-size: 13.5px;
        cursor: pointer; display: inline-flex; align-items: center; gap: 8px;
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.25);
        transition: all 0.15s ease;
    }
    .btn-modal-submit:hover {
        box-shadow: 0 6px 18px rgba(252, 128, 25, 0.35); transform: translateY(-1px);
    }
    .btn-modal-danger {
        padding: 10px 24px; border-radius: 50px; border: none;
        background: linear-gradient(135deg, #EF4444 0%, #DC2626 100%);
        color: #FFFFFF; font-weight: 600; font-size: 13.5px;
        cursor: pointer; display: inline-flex; align-items: center; gap: 8px;
        box-shadow: 0 4px 12px rgba(220, 38, 38, 0.25);
        transition: all 0.15s ease;
    }
    .btn-modal-danger:hover {
        box-shadow: 0 6px 18px rgba(220, 38, 38, 0.35); transform: translateY(-1px);
    }
</style>

<div class="ports-page-container">
    <!-- Breadcrumb -->
    <div class="custom-breadcrumb">
        <a href="${pageContext.request.contextPath}/dashboard"><i class="ti ti-smart-home me-1"></i> Dashboard</a>
        <i class="ti ti-chevron-right"></i>
        <span>Maritime Infrastructure</span>
        <i class="ti ti-chevron-right"></i>
        <span class="current">Ports Directory</span>
    </div>

    <!-- Alert Messages (Toast style) -->
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success alert-dismissible fade show rounded-4 border-0 shadow-sm d-flex align-items-center mb-4" role="alert" style="background-color: #ECFDF5; border-left: 4px solid #10B981 !important;">
            <i class="ti ti-circle-check text-success fs-4 me-3"></i>
            <div class="text-success fw-medium flex-grow-1">${sessionScope.successMessage}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>

    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show rounded-4 border-0 shadow-sm d-flex align-items-center mb-4" role="alert" style="background-color: #FEF2F2; border-left: 4px solid #EF4444 !important;">
            <i class="ti ti-alert-triangle text-danger fs-4 me-3"></i>
            <div class="text-danger fw-medium flex-grow-1">${sessionScope.errorMessage}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <!-- Telemetry Header Card -->
    <div class="telemetry-header-card">
        <div class="telemetry-header-left">
            <div class="telemetry-icon-box">
                <i class="ti ti-anchor"></i>
            </div>
            <div>
                <h2 class="telemetry-title">Global Ports & Harbors Directory</h2>
                <p class="telemetry-desc">
                    Comprehensive registry of international maritime shipping terminals, UN/LOCODE coordinates, and geographical gateways.
                </p>
            </div>
        </div>
        <div class="telemetry-actions">
            <span class="badge-status-operational me-2">
                <span class="pulse-dot"></span> ${totalPortsCount} Global Terminals Active
            </span>
            <button type="button" class="btn-register-primary" onclick="openAddPortModal()">
                <i class="ti ti-plus"></i> Add Port
            </button>
        </div>
    </div>

    <!-- 4 KPI Telemetry Cards -->
    <div class="kpi-grid">
        <!-- 1. Total Ports -->
        <div class="kpi-card">
            <div class="kpi-card-inner">
                <div>
                    <div class="kpi-label">Total Ports</div>
                    <div class="kpi-value">${totalPortsCount}</div>
                    <div class="kpi-badge kpi-badge-orange">
                        <i class="ti ti-anchor"></i> Registered Hubs
                    </div>
                </div>
                <div class="kpi-icon-wrap kpi-icon-orange">
                    <i class="ti ti-building-carousel"></i>
                </div>
            </div>
        </div>

        <!-- 2. Sovereign Jurisdictions -->
        <div class="kpi-card">
            <div class="kpi-card-inner">
                <div>
                    <div class="kpi-label">Countries Covered</div>
                    <div class="kpi-value">${distinctCountriesCount}</div>
                    <div class="kpi-badge kpi-badge-blue">
                        <i class="ti ti-world"></i> Sovereign Reach
                    </div>
                </div>
                <div class="kpi-icon-wrap kpi-icon-blue">
                    <i class="ti ti-world"></i>
                </div>
            </div>
        </div>

        <!-- 3. Geotagged Gateways -->
        <div class="kpi-card">
            <div class="kpi-card-inner">
                <div>
                    <div class="kpi-label">Geocoded Ports</div>
                    <div class="kpi-value">${geotaggedCount}</div>
                    <div class="kpi-badge kpi-badge-green">
                        <i class="ti ti-map-pin"></i> GPS Calibrated
                    </div>
                </div>
                <div class="kpi-icon-wrap kpi-icon-green">
                    <i class="ti ti-map-pin"></i>
                </div>
            </div>
        </div>

        <!-- 4. Active Commercial Hubs -->
        <div class="kpi-card">
            <div class="kpi-card-inner">
                <div>
                    <div class="kpi-label">Operational Status</div>
                    <div class="kpi-value">100%</div>
                    <div class="kpi-badge kpi-badge-purple">
                        <i class="ti ti-check"></i> High Availability
                    </div>
                </div>
                <div class="kpi-icon-wrap kpi-icon-purple">
                    <i class="ti ti-route"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Ports Table Card -->
    <div class="ports-main-card">
        <!-- Search & Filter Toolbar -->
        <div class="toolbar-bar">
            <div class="toolbar-left">
                <!-- Search Box -->
                <div class="table-search-box">
                    <i class="ti ti-search"></i>
                    <input type="text" id="portSearchInput" class="table-search-input" placeholder="Search ports by name, code, country, or PRT ID..." oninput="handleFilter()">
                </div>

                <!-- Country Filter Dropdown (Custom non-breaking wrap) -->
                <div class="country-filter-wrap">
                    <select id="countryFilter" class="form-select-custom" onchange="handleFilter()">
                        <option value="ALL">All Countries / Territories</option>
                        <c:forEach var="port" items="${ports}">
                            <c:if test="${not empty port.country}">
                                <option value="${port.country}">${port.country}</option>
                            </c:if>
                        </c:forEach>
                    </select>
                </div>

                <!-- Reset Filter -->
                <button type="button" class="btn-reset-filter" onclick="resetFilters()" title="Reset Filters">
                    <i class="ti ti-rotate"></i> Reset
                </button>
            </div>

            <!-- Visible Count Badge -->
            <div class="toolbar-count-badge" id="showingCountBadge">
                <i class="ti ti-list"></i> Showing ${totalPortsCount} of ${totalPortsCount} Ports
            </div>
        </div>

        <!-- Table Container -->
        <div class="table-responsive">
            <table class="enterprise-table" id="portsTable">
                <thead>
                    <tr>
                        <th style="width: 110px;">Port ID</th>
                        <th>Harbor Port & Code</th>
                        <th style="width: 220px;">Country / Sovereign Territory</th>
                        <th style="width: 260px;">Geographical Coordinates</th>
                        <th style="width: 160px;">Operational Status</th>
                        <th style="width: 110px; text-align: right;">Actions</th>
                    </tr>
                </thead>
                <tbody id="portsTableBody">
                    <c:choose>
                        <c:when test="${not empty ports}">
                            <c:forEach var="p" items="${ports}">
                                <tr class="port-row" 
                                    data-search="prt-${p.portId} ${p.portName.toLowerCase()} ${p.portCode.toLowerCase()} ${p.country.toLowerCase()}"
                                    data-country="${p.country}"
                                    data-id="${p.portId}"
                                    data-name="${p.portName}"
                                    data-code="${p.portCode}"
                                    data-lat="${p.latitude}"
                                    data-lng="${p.longitude}">
                                    
                                    <!-- Port ID -->
                                    <td>
                                        <span class="port-id-badge">PRT-${p.portId}</span>
                                    </td>

                                    <!-- Port Name & Code -->
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="port-icon-avatar">
                                                <i class="ti ti-anchor"></i>
                                            </div>
                                            <div>
                                                <div class="port-name-main">${p.portName}</div>
                                                <div>
                                                    <span class="port-code-badge" title="UN/LOCODE / Terminal Identifier">
                                                        <c:out value="${p.portCode}" default="N/A" />
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </td>

                                    <!-- Country -->
                                    <td>
                                        <div class="country-cell">
                                            <i class="ti ti-world"></i>
                                            <span><c:out value="${p.country}" default="International" /></span>
                                        </div>
                                    </td>

                                    <!-- Coordinates -->
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.latitude != 0.0 || p.longitude != 0.0}">
                                                <span class="coords-badge" title="GPS Coordinates">
                                                    <i class="ti ti-map-pin"></i>
                                                    <fmt:formatNumber value="${p.latitude}" pattern="##0.0000" />&deg;, 
                                                    <fmt:formatNumber value="${p.longitude}" pattern="##0.0000" />&deg;
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted small fst-italic">
                                                    <i class="ti ti-map-pin-off me-1"></i> Not Geotagged
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Operational Status -->
                                    <td>
                                        <span class="badge-status-operational">
                                            <span class="pulse-dot"></span> Operational
                                        </span>
                                    </td>

                                    <!-- Actions (Edit & Delete) -->
                                    <td>
                                        <div class="actions-group">
                                            <button type="button" class="action-btn action-btn-edit" 
                                                    onclick="openEditPortModal(${p.portId}, '${p.portName}', '${p.portCode}', '${p.country}', ${p.latitude}, ${p.longitude})" 
                                                    title="Edit Port">
                                                <i class="ti ti-pencil"></i>
                                            </button>
                                            <button type="button" class="action-btn action-btn-delete" 
                                                    onclick="openDeletePortModal(${p.portId}, '${p.portName}', '${p.portCode}')" 
                                                    title="Decommission Port">
                                                <i class="ti ti-trash"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                    </c:choose>
                </tbody>
            </table>

            <!-- Empty State Box -->
            <div class="empty-state-box" id="emptyStateBox" style="display: ${empty ports ? 'block' : 'none'};">
                <div class="empty-state-icon">
                    <i class="ti ti-anchor-off"></i>
                </div>
                <h4 class="empty-state-title">No Maritime Ports Found</h4>
                <p class="empty-state-desc">
                    No international harbor ports match your current search query or country filter. Try adjusting your search or add a new port.
                </p>
                <button type="button" class="btn-register-primary" onclick="openAddPortModal()">
                    <i class="ti ti-plus"></i> Register New Port
                </button>
            </div>
        </div>

        <!-- Modern Pagination Bar -->
        <div class="pagination-bar" id="portsPagination">
            <div class="page-info" id="pageInfoText">
                Showing page 1 of 1
            </div>
            <div class="pagination-controls">
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
     REVAMPED ENTERPRISE MODAL: REGISTER NEW PORT
     ========================================================================== -->
<div class="custom-modal-backdrop" id="addPortModal">
    <div class="custom-modal-dialog">
        <div class="modal-hero-header">
            <div class="d-flex align-items-center gap-3">
                <div class="modal-hero-icon">
                    <i class="ti ti-anchor"></i>
                </div>
                <div>
                    <h3 class="modal-hero-title">Register New Port</h3>
                    <p class="modal-hero-desc">Add an international commercial harbor or container terminal gateway.</p>
                </div>
            </div>
            <button type="button" class="btn-modal-close" onclick="closeAddPortModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/jsp/ports.jsp" id="addPortForm">
            <input type="hidden" name="action" value="add">
            <div class="modal-form-body">
                <!-- Port Name -->
                <div class="field-group">
                    <label class="field-label">Port Official Name <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-anchor"></i>
                        <input type="text" class="field-input" name="portName" id="addPortName" required placeholder="e.g. Jawaharlal Nehru Port (JNPT)">
                    </div>
                    <div class="field-helper">Official commercial harbor or terminal facility designation.</div>
                </div>

                <!-- Port Code -->
                <div class="field-group">
                    <label class="field-label">Port Code (UN/LOCODE) <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-barcode"></i>
                        <input type="text" class="field-input" name="portCode" id="addPortCode" required placeholder="e.g. INNSA" style="font-family: monospace; text-transform: uppercase;">
                    </div>
                    <div class="field-helper">Standard international 3-5 alphanumeric identifier assigned to maritime terminals.</div>
                </div>

                <!-- Country -->
                <div class="field-group">
                    <label class="field-label">Sovereign Country / Territory <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-world"></i>
                        <input type="text" class="field-input" name="country" id="addCountry" required placeholder="e.g. India">
                    </div>
                    <div class="field-helper">Country or sovereign jurisdiction where the harbor terminal operates.</div>
                </div>

                <!-- Coordinates (Lat & Lng) -->
                <div class="row">
                    <div class="col-md-6">
                        <div class="field-group">
                            <label class="field-label">Latitude (&deg; N/S)</label>
                            <div class="field-input-wrap input-icon-wrap has-lead-icon">
                                <i class="ti ti-map-pin"></i>
                                <input type="number" step="any" class="field-input" name="latitude" id="addLatitude" placeholder="e.g. 18.949900">
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="field-group">
                            <label class="field-label">Longitude (&deg; E/W)</label>
                            <div class="field-input-wrap input-icon-wrap has-lead-icon">
                                <i class="ti ti-compass"></i>
                                <input type="number" step="any" class="field-input" name="longitude" id="addLongitude" placeholder="e.g. 72.951200">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Quick Preset Chips -->
                <div class="field-helper mb-1">Quick Harbor Presets:</div>
                <div class="preset-chips-wrap">
                    <span class="preset-chip" onclick="setPortPreset('JNPT (Mumbai)', 'INNSA', 'India', 18.9499, 72.9512)">JNPT Mumbai</span>
                    <span class="preset-chip" onclick="setPortPreset('Port of Singapore', 'SGSIN', 'Singapore', 1.2902, 103.8519)">Singapore</span>
                    <span class="preset-chip" onclick="setPortPreset('Port of Rotterdam', 'NLRTM', 'Netherlands', 51.9244, 4.4777)">Rotterdam</span>
                    <span class="preset-chip" onclick="setPortPreset('Jebel Ali Port', 'AEJEA', 'United Arab Emirates', 25.0113, 55.0617)">Dubai</span>
                </div>
            </div>
            <div class="modal-form-footer">
                <button type="button" class="btn-modal-cancel" onclick="closeAddPortModal()">Cancel</button>
                <button type="submit" class="btn-modal-submit">
                    <i class="ti ti-check"></i> Save Port
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ==========================================================================
     REVAMPED ENTERPRISE MODAL: EDIT PORT DETAILS
     ========================================================================== -->
<div class="custom-modal-backdrop" id="editPortModal">
    <div class="custom-modal-dialog">
        <div class="modal-hero-header">
            <div class="d-flex align-items-center gap-3">
                <div class="modal-hero-icon">
                    <i class="ti ti-pencil"></i>
                </div>
                <div>
                    <h3 class="modal-hero-title">Edit Port Details</h3>
                    <p class="modal-hero-desc">Update commercial harbor name, UN/LOCODE, territory, or GPS coordinates.</p>
                </div>
            </div>
            <button type="button" class="btn-modal-close" onclick="closeEditPortModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/jsp/ports.jsp" id="editPortForm">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="portId" id="editPortId">
            <div class="modal-form-body">
                <!-- Port Name -->
                <div class="field-group">
                    <label class="field-label">Port Official Name <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-anchor"></i>
                        <input type="text" class="field-input" name="portName" id="editPortName" required>
                    </div>
                </div>

                <!-- Port Code -->
                <div class="field-group">
                    <label class="field-label">Port Code (UN/LOCODE) <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-barcode"></i>
                        <input type="text" class="field-input" name="portCode" id="editPortCode" required style="font-family: monospace; text-transform: uppercase;">
                    </div>
                </div>

                <!-- Country -->
                <div class="field-group">
                    <label class="field-label">Sovereign Country / Territory <span style="color: #DC2626;">*</span></label>
                    <div class="field-input-wrap input-icon-wrap has-lead-icon">
                        <i class="ti ti-world"></i>
                        <input type="text" class="field-input" name="country" id="editCountry" required>
                    </div>
                </div>

                <!-- Coordinates (Lat & Lng) -->
                <div class="row">
                    <div class="col-md-6">
                        <div class="field-group">
                            <label class="field-label">Latitude (&deg; N/S)</label>
                            <div class="field-input-wrap input-icon-wrap has-lead-icon">
                                <i class="ti ti-map-pin"></i>
                                <input type="number" step="any" class="field-input" name="latitude" id="editLatitude">
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="field-group">
                            <label class="field-label">Longitude (&deg; E/W)</label>
                            <div class="field-input-wrap input-icon-wrap has-lead-icon">
                                <i class="ti ti-compass"></i>
                                <input type="number" step="any" class="field-input" name="longitude" id="editLongitude">
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-form-footer">
                <button type="button" class="btn-modal-cancel" onclick="closeEditPortModal()">Cancel</button>
                <button type="submit" class="btn-modal-submit">
                    <i class="ti ti-check"></i> Update Port
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ==========================================================================
     REVAMPED ENTERPRISE MODAL: DECOMMISSION / DELETE PORT
     ========================================================================== -->
<div class="custom-modal-backdrop" id="deletePortModal">
    <div class="custom-modal-dialog">
        <div class="modal-hero-header">
            <div class="d-flex align-items-center gap-3">
                <div class="modal-hero-icon danger">
                    <i class="ti ti-alert-triangle"></i>
                </div>
                <div>
                    <h3 class="modal-hero-title">Decommission Port?</h3>
                    <p class="modal-hero-desc">Confirm permanent removal of this port from maritime directory.</p>
                </div>
            </div>
            <button type="button" class="btn-modal-close" onclick="closeDeletePortModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/jsp/ports.jsp" id="deletePortForm">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="portId" id="deletePortId">
            <div class="modal-form-body">
                <p style="font-size: 13.5px; color: #475569; line-height: 1.5; margin-bottom: 0;">
                    Are you sure you want to permanently decommission and delete <strong id="deletePortNameDisplay" style="color: #0F172A;"></strong> (<span id="deletePortCodeDisplay" style="font-family: monospace;"></span>)?
                    Maritime carriers and container terminals referencing this hub will be affected.
                </p>
            </div>
            <div class="modal-form-footer">
                <button type="button" class="btn-modal-cancel" onclick="closeDeletePortModal()">Cancel</button>
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
    let allPortRows = [];
    let matchingPortRows = [];
    let currentPage = 1;
    const pageSize = 10;

    document.addEventListener('DOMContentLoaded', function() {
        allPortRows = Array.from(document.querySelectorAll('.port-row'));
        deduplicateCountryFilter();
        handleFilter();
    });

    // Populate country dropdown without duplicate entries
    function deduplicateCountryFilter() {
        const select = document.getElementById('countryFilter');
        if (!select) return;

        const countries = new Set();
        allPortRows.forEach(row => {
            const c = (row.getAttribute('data-country') || '').trim();
            if (c) countries.add(c);
        });

        const sortedCountries = Array.from(countries).sort();
        select.innerHTML = '<option value="ALL">All Countries / Territories</option>';
        sortedCountries.forEach(c => {
            const opt = document.createElement('option');
            opt.value = c;
            opt.textContent = c;
            select.appendChild(opt);
        });

        // Initialize TomSelect if available
        if (typeof TomSelect !== 'undefined' && !select.tomselect) {
            new TomSelect(select, {
                create: false,
                maxItems: 1,
                allowEmptyOption: false,
                placeholder: 'Filter by Country...',
                onChange: function() {
                    handleFilter();
                }
            });
        }
    }

    function handleFilter() {
        const query = (document.getElementById('portSearchInput').value || '').trim().toLowerCase();
        const countrySelect = document.getElementById('countryFilter');
        const selectedCountry = countrySelect ? countrySelect.value : 'ALL';

        matchingPortRows = [];

        allPortRows.forEach(row => {
            const searchData = (row.getAttribute('data-search') || '').toLowerCase();
            const rowCountry = (row.getAttribute('data-country') || '').trim();

            // Country Match
            const matchesCountry = (selectedCountry === 'ALL' || rowCountry.toLowerCase() === selectedCountry.toLowerCase());

            // Search Query Match
            const matchesQuery = !query || searchData.includes(query);

            if (matchesCountry && matchesQuery) {
                matchingPortRows.push(row);
            }
        });

        currentPage = 1;
        renderPage();
    }

    function renderPage() {
        const table = document.getElementById('portsTable');
        const emptyState = document.getElementById('emptyStateBox');
        const pagination = document.getElementById('portsPagination');
        const countBadge = document.getElementById('showingCountBadge');

        const totalMatches = matchingPortRows.length;
        countBadge.innerHTML = '<i class="ti ti-list"></i> Showing ' + totalMatches + ' of ' + allPortRows.length + ' Ports';

        if (totalMatches === 0) {
            table.style.display = 'none';
            emptyState.style.display = 'block';
            pagination.style.display = 'none';
            allPortRows.forEach(row => row.style.display = 'none');
            return;
        }

        table.style.display = 'table';
        emptyState.style.display = 'none';
        pagination.style.display = 'flex';

        const totalPages = Math.ceil(totalMatches / pageSize);
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        // Hide all rows first
        allPortRows.forEach(row => row.style.display = 'none');

        // Show slice
        const start = (currentPage - 1) * pageSize;
        const end = Math.min(start + pageSize, totalMatches);

        for (let i = start; i < end; i++) {
            matchingPortRows[i].style.display = '';
        }

        // Update Info Text
        document.getElementById('pageInfoText').innerText = 'Showing ' + (start + 1) + ' to ' + end + ' of ' + totalMatches + ' Ports';

        // Update Prev / Next buttons
        document.getElementById('prevPageBtn').disabled = (currentPage === 1);
        document.getElementById('nextPageBtn').disabled = (currentPage === totalPages);

        // Render Page Number Buttons
        renderPaginationNumbers(totalPages);
    }

    function renderPaginationNumbers(totalPages) {
        const wrap = document.getElementById('pageNumbersWrap');
        wrap.innerHTML = '';

        if (totalPages <= 1) return;

        let startPage = Math.max(1, currentPage - 2);
        let endPage = Math.min(totalPages, currentPage + 2);

        if (currentPage <= 3) {
            endPage = Math.min(5, totalPages);
        }
        if (currentPage >= totalPages - 2) {
            startPage = Math.max(1, totalPages - 4);
        }

        for (let p = startPage; p <= endPage; p++) {
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'page-num nl-page-num' + (p === currentPage ? ' active' : '');
            btn.innerText = p;
            btn.onclick = (function(pageNum) {
                return function() {
                    currentPage = pageNum;
                    renderPage();
                };
            })(p);
            wrap.appendChild(btn);
        }
    }

    function changePage(delta) {
        currentPage += delta;
        renderPage();
    }

    function resetFilters() {
        document.getElementById('portSearchInput').value = '';
        const cSelect = document.getElementById('countryFilter');
        if (cSelect.tomselect) {
            cSelect.tomselect.setValue('ALL');
        } else {
            cSelect.value = 'ALL';
        }
        handleFilter();
    }

    // Modal Operations
    function openAddPortModal() {
        document.getElementById('addPortForm').reset();
        document.getElementById('addPortModal').classList.add('show');
    }
    function closeAddPortModal() {
        document.getElementById('addPortModal').classList.remove('show');
    }

    function setPortPreset(name, code, country, lat, lng) {
        document.getElementById('addPortName').value = name;
        document.getElementById('addPortCode').value = code;
        document.getElementById('addCountry').value = country;
        document.getElementById('addLatitude').value = lat;
        document.getElementById('addLongitude').value = lng;
    }

    function openEditPortModal(id, name, code, country, lat, lng) {
        document.getElementById('editPortId').value = id;
        document.getElementById('editPortName').value = name || '';
        document.getElementById('editPortCode').value = code || '';
        document.getElementById('editCountry').value = country || '';
        document.getElementById('editLatitude').value = (lat !== undefined && lat !== 0) ? lat : '';
        document.getElementById('editLongitude').value = (lng !== undefined && lng !== 0) ? lng : '';
        document.getElementById('editPortModal').classList.add('show');
    }
    function closeEditPortModal() {
        document.getElementById('editPortModal').classList.remove('show');
    }

    function openDeletePortModal(id, name, code) {
        document.getElementById('deletePortId').value = id;
        document.getElementById('deletePortNameDisplay').innerText = name || ('PRT-' + id);
        document.getElementById('deletePortCodeDisplay').innerText = code || '';
        document.getElementById('deletePortModal').classList.add('show');
    }
    function closeDeletePortModal() {
        document.getElementById('deletePortModal').classList.remove('show');
    }

    // Backdrop click to close modals
    window.addEventListener('click', function(e) {
        ['addPortModal', 'editPortModal', 'deletePortModal'].forEach(mId => {
            const modal = document.getElementById(mId);
            if (e.target === modal) {
                modal.classList.remove('show');
            }
        });
    });

    // ESC key closes modals
    window.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            ['addPortModal', 'editPortModal', 'deletePortModal'].forEach(mId => {
                const modal = document.getElementById(mId);
                if (modal && modal.classList.contains('show')) {
                    modal.classList.remove('show');
                }
            });
        }
    });
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
