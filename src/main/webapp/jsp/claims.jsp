<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Ensure data is available if accessed directly without going through servlet
    if (request.getAttribute("claims") == null) {
        com.nlogistic.model.User __u = (com.nlogistic.model.User) session.getAttribute("user");
        if (__u != null) {
            com.nlogistic.dao.ClaimDAO __claimDao = new com.nlogistic.dao.ClaimDAO();
            int __roleId = session.getAttribute("roleId") != null ? (int) session.getAttribute("roleId") : __u.getRoleId();
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
            request.setAttribute("stats", __claimDao.getClaimStats(__roleId == 5 ? __customerId : null));
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

    /* KPI Cards */
    .kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; margin-bottom: 24px; }
    .kpi-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 14px; padding: 16px 18px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03); display: flex; align-items: center; justify-content: space-between;
        transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease; cursor: pointer; text-decoration: none;
    }
    .kpi-card:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,0,0,0.06); border-color: #CBD5E1; }
    .kpi-card.active-kpi { border-color: #FC8019; box-shadow: 0 0 0 2px rgba(252, 128, 25, 0.2); }
    .kpi-label { font-size: 11.5px; font-weight: 600; color: #64748B; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.4px; }
    .kpi-value { font-size: 23px; font-weight: 800; color: #0F172A; line-height: 1; }
    .kpi-subtext { font-size: 11px; color: #94A3B8; margin-top: 4px; font-weight: 500; }
    .kpi-icon-pill { width: 40px; height: 40px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 19px; flex-shrink: 0; }
    .kpi-icon-pill.amber { background: #FFFBEB; color: #D97706; }
    .kpi-icon-pill.blue { background: #EFF6FF; color: #2563EB; }
    .kpi-icon-pill.green { background: #ECFDF5; color: #059669; }
    .kpi-icon-pill.red { background: #FEF2F2; color: #DC2626; }
    .kpi-icon-pill.purple { background: #F3E8FF; color: #9333EA; }
    .kpi-icon-pill.slate { background: #F1F5F9; color: #475569; }
    .kpi-icon-pill.orange { background: #FFF3EA; color: #FC8019; }

    /* Toolbar */
    .toolbar-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 14px 14px 0 0; padding: 14px 20px;
        display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 14px; border-bottom: 1px solid #F1F5F9;
    }
    .nav-tabs-pill { display: flex; align-items: center; gap: 6px; background: #F8FAFC; padding: 4px; border-radius: 50px; border: 1px solid #E2E8F0; flex-wrap: wrap; }
    .tab-pill-btn {
        background: transparent; border: none; padding: 7px 14px; border-radius: 50px; font-size: 12.5px; font-weight: 600;
        color: #64748B; cursor: pointer; transition: all 0.2s ease; display: flex; align-items: center; gap: 6px; text-decoration: none;
    }
    .tab-pill-btn:hover { color: #0F172A; }
    .tab-pill-btn.active { background: #FFFFFF; color: #FC8019; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08); font-weight: 700; }
    .tab-count-badge {
        background: #E2E8F0; color: #475569; font-size: 11px; font-weight: 700; padding: 1px 7px; border-radius: 50px;
        transition: all 0.2s ease;
    }
    .tab-pill-btn.active .tab-count-badge { background: #FFF3EA; color: #FC8019; }

    .toolbar-actions { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
    .search-wrap { position: relative; width: 260px; }
    .search-wrap i.search-icon { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #94A3B8; font-size: 15px; pointer-events: none; }
    .search-input {
        width: 100%; height: 38px; border-radius: 50px; border: 1.5px solid #E2E8F0; padding: 0 34px 0 38px;
        font-size: 12.5px; color: #1E293B; background: #FFFFFF; outline: none; transition: all 0.2s ease;
    }
    .search-input:focus { border-color: #FC8019; box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12); }
    .search-clear { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); background: none; border: none; color: #94A3B8; cursor: pointer; display: none; font-size: 14px; }
    .search-clear:hover { color: #0F172A; }

        /* Type Filter Custom Dropdown (Signature Pill Style) */
    .claim-type-filter-wrap {
        min-width: 145px !important;
        position: relative !important;
    }
    .claim-type-filter-wrap .ts-wrapper {
        min-width: 145px !important;
        width: 100% !important;
        position: relative !important;
        border: none !important;
        padding: 0 !important;
        background: transparent !important;
    }
    .claim-type-filter-wrap .ts-control {
        min-width: 145px !important;
        height: 38px !important;
        min-height: 38px !important;
        border-radius: 50px !important;
        border: 1.5px solid #E2E8F0 !important;
        background-color: #FFFFFF !important;
        padding: 0 34px 0 16px !important;
        display: flex !important;
        align-items: center !important;
        box-shadow: none !important;
        cursor: pointer !important;
        transition: all 0.2s ease !important;
    }
    .claim-type-filter-wrap .ts-wrapper:hover .ts-control {
        border-color: #CBD5E1 !important;
    }
    .claim-type-filter-wrap .ts-wrapper.focus .ts-control,
    .claim-type-filter-wrap .ts-wrapper.dropdown-active .ts-control {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12) !important;
    }
    .claim-type-filter-wrap .ts-control .item {
        white-space: nowrap !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
        font-size: 13px !important;
        font-weight: 600 !important;
        color: #1E293B !important;
        line-height: 1 !important;
        padding: 0 !important;
        margin: 0 !important;
    }
    .claim-type-filter-wrap .ts-wrapper.single .ts-control:after {
        content: '' !important;
        display: block !important;
        position: absolute !important;
        right: 14px !important;
        top: 50% !important;
        transform: translateY(-50%) !important;
        width: 10px !important;
        height: 6px !important;
        border: none !important;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23FC8019' stroke-linecap='round' stroke-linejoin='round' stroke-width='2.2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
        background-repeat: no-repeat !important;
        background-position: center !important;
        background-size: contain !important;
        transition: transform 0.2s ease !important;
        pointer-events: none !important;
        margin-top: 0 !important;
    }
    .claim-type-filter-wrap .ts-wrapper.single.dropdown-active .ts-control:after {
        transform: translateY(-50%) rotate(180deg) !important;
        margin-top: 0 !important;
    }
    .ts-dropdown.claim-type-ts,
    .claim-type-filter-wrap .ts-dropdown {
        min-width: 155px !important;
        border-radius: 12px !important;
        box-shadow: 0 10px 25px rgba(15, 23, 42, 0.12), 0 4px 10px rgba(15, 23, 42, 0.06) !important;
        border: 1px solid #E2E8F0 !important;
        padding: 6px !important;
        margin-top: 6px !important;
        background: #FFFFFF !important;
        z-index: 100000000 !important;
    }
    .ts-dropdown.claim-type-ts .option,
    .claim-type-filter-wrap .ts-dropdown .option {
        padding: 9px 14px !important;
        font-size: 13px !important;
        font-weight: 500 !important;
        color: #334155 !important;
        border-radius: 8px !important;
        cursor: pointer !important;
        transition: all 0.15s ease !important;
        display: flex !important;
        align-items: center !important;
    }
    .ts-dropdown.claim-type-ts .option:hover,
    .ts-dropdown.claim-type-ts .option.active,
    .claim-type-filter-wrap .ts-dropdown .option:hover,
    .claim-type-filter-wrap .ts-dropdown .option.active {
        background-color: #FFF3EA !important;
        color: #FC8019 !important;
        font-weight: 600 !important;
    }
    .ts-dropdown.claim-type-ts .option.selected,
    .claim-type-filter-wrap .ts-dropdown .option.selected {
        background-color: #FC8019 !important;
        color: #FFFFFF !important;
        font-weight: 600 !important;
    }

    .table-counter-badge {
        font-size: 12px; font-weight: 600; color: #64748B; background: #F8FAFC; border: 1px solid #E2E8F0;
        padding: 5px 12px; border-radius: 50px; display: inline-flex; align-items: center; gap: 5px; white-space: nowrap;
    }

    /* Table */
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

    /* Modern Pagination Bar */
    .pagination-bar {
        padding: 14px 24px; border-top: 1px solid #F1F5F9;
        display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 14px;
        background: #FFFFFF;
    }
    .page-info-wrap { display: flex; align-items: center; gap: 14px; flex-wrap: wrap; }
    .page-size-wrap { display: flex; align-items: center; gap: 8px; font-size: 12.5px; color: #64748B; font-weight: 500; }
    .page-size-select {
        height: 32px; padding: 0 8px; border-radius: 8px; border: 1.5px solid #E2E8F0;
        background: #FFFFFF; font-size: 12px; font-weight: 600; color: #1E293B; outline: none; cursor: pointer;
    }
    .page-size-select:focus { border-color: #FC8019; }
    .page-info { font-size: 12.5px; color: #64748B; font-weight: 500; }

    .pagination-controls { display: flex; align-items: center; gap: 6px; }
    .page-btn {
        height: 34px; padding: 0 14px; border-radius: 50px; border: 1.5px solid #E2E8F0;
        background: #FFFFFF; color: #475569; font-size: 12px; font-weight: 600;
        cursor: pointer; display: inline-flex; align-items: center; justify-content: center;
        transition: all 0.15s ease;
    }
    .page-btn:hover:not(:disabled) { background: #FFF3EA; color: #FC8019; border-color: #FC8019; }
    .page-btn:disabled { opacity: 0.45; cursor: not-allowed; }
    .page-numbers-wrap { display: flex; align-items: center; gap: 4px; }
    .page-num {
        width: 34px; height: 34px; border-radius: 50%; border: 1.5px solid #E2E8F0;
        background: #FFFFFF; color: #475569; font-size: 12px; font-weight: 600;
        cursor: pointer; display: inline-flex; align-items: center; justify-content: center;
        transition: all 0.15s ease;
    }
    .page-num:hover:not(.active) { background: #FFF3EA; color: #FC8019; border-color: #FC8019; }
    .page-num.active { background: #FC8019 !important; color: #FFFFFF !important; border-color: #FC8019 !important; font-weight: 700; box-shadow: 0 2px 8px rgba(252, 128, 25, 0.3); }

    .empty-state-card { padding: 60px 24px; text-align: center; background: #FFFFFF; }
    .empty-state-icon-box {
        width: 64px; height: 64px; border-radius: 18px; background: #F8FAFC; border: 1px solid #E2E8F0;
        color: #94A3B8; font-size: 28px; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px;
    }
    .empty-state-title { font-size: 16px; font-weight: 700; color: #0F172A; margin-bottom: 6px; }
    .empty-state-desc { font-size: 13px; color: #64748B; margin-bottom: 16px; }

    /* Select / form controls in modal */
    .select-wrapper { position: relative; width: 100%; }
    .select-wrapper:has(.ts-wrapper)::after,
    .select-wrapper.has-tomselect::after { display: none !important; }
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

    <!-- KPI Dashboard (100% Real Database Queries) -->
    <div class="kpi-grid">
        <div class="kpi-card" onclick="filterByStatusTab('')">
            <div>
                <div class="kpi-label">Total Claims</div>
                <div class="kpi-value">${stats.total}</div>
                <div class="kpi-subtext">&#8377;<fmt:formatNumber value="${stats.totalClaimed}" pattern="#,##0.00"/> Claimed</div>
            </div>
            <div class="kpi-icon-pill slate"><i class="ti ti-file-stack"></i></div>
        </div>
        <div class="kpi-card" onclick="filterByStatusTab('Filed')">
            <div>
                <div class="kpi-label">Filed</div>
                <div class="kpi-value">${stats.filed}</div>
                <div class="kpi-subtext">Awaiting Ops Review</div>
            </div>
            <div class="kpi-icon-pill amber"><i class="ti ti-file-alert"></i></div>
        </div>
        <div class="kpi-card" onclick="filterByStatusTab('Under Review')">
            <div>
                <div class="kpi-label">Under Review</div>
                <div class="kpi-value">${stats.underReview}</div>
                <div class="kpi-subtext">In Investigation</div>
            </div>
            <div class="kpi-icon-pill blue"><i class="ti ti-search"></i></div>
        </div>
        <div class="kpi-card" onclick="filterByStatusTab('Approved')">
            <div>
                <div class="kpi-label">Approved</div>
                <div class="kpi-value">${stats.approved}</div>
                <div class="kpi-subtext">Pending Settlement</div>
            </div>
            <div class="kpi-icon-pill purple"><i class="ti ti-thumb-up"></i></div>
        </div>
        <div class="kpi-card" onclick="filterByStatusTab('Rejected')">
            <div>
                <div class="kpi-label">Rejected</div>
                <div class="kpi-value">${stats.rejected}</div>
                <div class="kpi-subtext">Declined by Finance</div>
            </div>
            <div class="kpi-icon-pill red"><i class="ti ti-x"></i></div>
        </div>
        <div class="kpi-card" onclick="filterByStatusTab('Settled')">
            <div>
                <div class="kpi-label">Settled</div>
                <div class="kpi-value">${stats.settled}</div>
                <div class="kpi-subtext">&#8377;<fmt:formatNumber value="${stats.totalApproved}" pattern="#,##0.00"/> Paid Out</div>
            </div>
            <div class="kpi-icon-pill green"><i class="ti ti-circle-check"></i></div>
        </div>
    </div>

    <!-- Toolbar / status filter tabs + Live Search + Type Filter -->
    <div class="toolbar-card">
        <div class="nav-tabs-pill">
            <button type="button" class="tab-pill-btn active" data-status="" onclick="filterByStatusTab('')">
                All <span class="tab-count-badge">${stats.total}</span>
            </button>
            <button type="button" class="tab-pill-btn" data-status="Filed" onclick="filterByStatusTab('Filed')">
                Filed <span class="tab-count-badge">${stats.filed}</span>
            </button>
            <button type="button" class="tab-pill-btn" data-status="Under Review" onclick="filterByStatusTab('Under Review')">
                Under Review <span class="tab-count-badge">${stats.underReview}</span>
            </button>
            <button type="button" class="tab-pill-btn" data-status="Approved" onclick="filterByStatusTab('Approved')">
                Approved <span class="tab-count-badge">${stats.approved}</span>
            </button>
            <button type="button" class="tab-pill-btn" data-status="Rejected" onclick="filterByStatusTab('Rejected')">
                Rejected <span class="tab-count-badge">${stats.rejected}</span>
            </button>
            <button type="button" class="tab-pill-btn" data-status="Settled" onclick="filterByStatusTab('Settled')">
                Settled <span class="tab-count-badge">${stats.settled}</span>
            </button>
        </div>

        <div class="toolbar-actions">
            <!-- Search Bar -->
            <div class="search-wrap">
                <i class="ti ti-search search-icon"></i>
                <input type="text" id="claimsSearchInput" class="search-input" placeholder="Search claims, shipments, customers..." oninput="handleFilter()" autocomplete="off">
                <button type="button" id="searchClearBtn" class="search-clear" onclick="clearSearch()">&times;</button>
            </div>

                        <!-- Type Filter Custom Dropdown -->
            <div class="claim-type-filter-wrap">
                <select id="claimTypeFilter" class="form-select-custom no-custom-select" onchange="handleFilter()">
                    <option value="ALL">All Types</option>
                    <option value="Damage">Damage</option>
                    <option value="Loss">Loss</option>
                    <option value="Shortage">Shortage</option>
                </select>
            </div>

            <!-- Count Badge -->
            <div id="showingCountBadge" class="table-counter-badge">
                <i class="ti ti-list"></i> Showing ${claims.size()} Claims
            </div>
        </div>
    </div>

    <!-- Claims Table Panel -->
    <div class="table-panel">
        <table class="claims-table" id="claimsTable">
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
            <tbody id="claimsTableBody">
                <c:forEach var="cl" items="${claims}">
                    <tr class="claim-row"
                        data-id="${cl.claimId}"
                        data-status="${cl.status}"
                        data-type="${cl.claimType}"
                        data-search="#${cl.claimId} SHP-${cl.shipmentId} ${cl.claimType} ${cl.customerName} ${cl.status} ${cl.claimedAmount} ${cl.description}"
                        onclick="if(!event.target.closest('.actions-flex')) window.location='${pageContext.request.contextPath}/claims?action=view&claimId=${cl.claimId}';">
                        <td><strong>#${cl.claimId}</strong></td>
                        <td>SHP-${cl.shipmentId}</td>
                        <td>${cl.claimType}</td>
                        <td><fmt:formatDate value="${cl.incidentDate}" pattern="dd MMM yyyy"/></td>
                        <c:if test="${roleId != 5}"><td><c:out value="${empty cl.customerName ? 'Customer #'.concat(cl.customerId) : cl.customerName}"/></td></c:if>
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

        <!-- Empty State (Shown when 0 claims match search/filter) -->
        <div class="empty-state-card" id="claimsEmptyState" style="display: none;">
            <div class="empty-state-icon-box"><i class="ti ti-file-off"></i></div>
            <div class="empty-state-title">No Claims Found</div>
            <div class="empty-state-desc" id="emptyStateDesc">No cargo claims match your current filter or search criteria.</div>
            <button type="button" class="page-btn" style="background:#FFF3EA; color:#FC8019; border-color:#FC8019;" onclick="resetFilters()">
                <i class="ti ti-refresh me-1"></i> Reset Filters
            </button>
        </div>

        <!-- Modern Pagination Bar -->
        <div class="pagination-bar" id="claimsPagination">
            <div class="page-info-wrap">
                <div class="page-size-wrap">
                    <span>Rows per page:</span>
                    <select id="claimsPageSize" class="nl-page-size-select" onchange="changeClaimsPageSize(this.value)">
                        <option value="5">5</option>
                        <option value="10" selected>10</option>
                        <option value="25">25</option>
                        <option value="50">50</option>
                        <option value="ALL">All</option>
                    </select>
                </div>
                <div class="page-info" id="pageInfoText">Showing 1 to 10 of ${claims.size()} claims</div>
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
                    <input type="number" name="productId" id="fileProductId" class="modal-form-input" placeholder="Optional (e.g. 1)">
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
    /* ==========================================================================
       MODAL CONTROLLER
       ========================================================================== */
    function openModal(id) {
        const modal = document.getElementById(id);
        if (!modal) return;
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
        if (!modal) return;
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
            if (custField && ${roleId != 5 ? 'true' : 'false'}) custField.value = '';
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

    /* ==========================================================================
       FRONTEND PAGINATION, SEARCH & FILTER CONTROLLER
       ========================================================================== */
    let allClaimRows = [];
    let matchingClaimRows = [];
    let currentStatusFilter = '';
    let currentPage = 1;
    let pageSize = 10;

    document.addEventListener('DOMContentLoaded', function() {
        allClaimRows = Array.from(document.querySelectorAll('#claimsTableBody .claim-row'));

        // Initialize custom TomSelect on Claim Type filter
        initClaimTypeSelect();

        // Check if there is a statusFilter from server request
        const urlParams = new URLSearchParams(window.location.search);
        const initialStatus = urlParams.get('statusFilter');
        if (initialStatus) {
            currentStatusFilter = initialStatus;
            updateActiveStatusTab(initialStatus);
        }

        handleFilter();

        // Form submit validation
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

        // Custom confirm submit
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

        // Modal backdrop click
        document.querySelectorAll('.nl-modal-backdrop').forEach(function(modal) {
            modal.addEventListener('click', function(e) {
                if (e.target === this) {
                    this.classList.remove('show');
                    setTimeout(() => { this.style.display = 'none'; }, 200);
                }
            });
        });

        // ESC key closes modals
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                document.querySelectorAll('.nl-modal-backdrop.show').forEach(function(modal) {
                    modal.classList.remove('show');
                    setTimeout(() => { modal.style.display = 'none'; }, 200);
                });
            }
        });
    });

    function filterByStatusTab(status) {
        currentStatusFilter = status;
        updateActiveStatusTab(status);
        handleFilter();
    }

    function updateActiveStatusTab(status) {
        document.querySelectorAll('.nav-tabs-pill .tab-pill-btn').forEach(btn => {
            const btnStatus = btn.getAttribute('data-status') || '';
            if (btnStatus.toLowerCase() === status.toLowerCase()) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        });
    }

        function handleFilter() {
        const query = (document.getElementById('claimsSearchInput').value || '').trim().toLowerCase();
        const typeSelect = document.getElementById('claimTypeFilter');
        let selectedType = 'ALL';
        if (typeSelect) {
            selectedType = (typeSelect.tomselect ? typeSelect.tomselect.getValue() : typeSelect.value) || 'ALL';
        }
        const clearBtn = document.getElementById('searchClearBtn');

        if (clearBtn) {
            clearBtn.style.display = query ? 'block' : 'none';
        }

        matchingClaimRows = [];

        allClaimRows.forEach(row => {
            const searchData = (row.getAttribute('data-search') || '').toLowerCase();
            const rowStatus = (row.getAttribute('data-status') || '').trim();
            const rowType = (row.getAttribute('data-type') || '').trim();

            // Status Match
            const matchesStatus = !currentStatusFilter || (rowStatus.toLowerCase() === currentStatusFilter.toLowerCase());

            // Type Match
            const matchesType = (selectedType === 'ALL' || rowType.toLowerCase() === selectedType.toLowerCase());

            // Search Query Match
            const matchesQuery = !query || searchData.includes(query);

            if (matchesStatus && matchesType && matchesQuery) {
                matchingClaimRows.push(row);
            }
        });

        currentPage = 1;
        renderPage();
    }

    function renderPage() {
        const table = document.getElementById('claimsTable');
        const emptyState = document.getElementById('claimsEmptyState');
        const pagination = document.getElementById('claimsPagination');
        const countBadge = document.getElementById('showingCountBadge');

        const totalMatches = matchingClaimRows.length;
        countBadge.innerHTML = '<i class="ti ti-list"></i> Showing ' + totalMatches + ' of ' + allClaimRows.length + ' Claims';

        if (totalMatches === 0) {
            table.style.display = 'none';
            emptyState.style.display = 'block';
            pagination.style.display = 'none';
            allClaimRows.forEach(row => row.style.display = 'none');
            return;
        }

        table.style.display = 'table';
        emptyState.style.display = 'none';
        pagination.style.display = 'flex';

        let effectivePageSize = (pageSize === 'ALL' || pageSize >= 9999) ? totalMatches : pageSize;
        const totalPages = Math.max(1, Math.ceil(totalMatches / effectivePageSize));

        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        // Hide all rows first
        allClaimRows.forEach(row => row.style.display = 'none');

        // Show matching slice
        const start = (currentPage - 1) * effectivePageSize;
        const end = Math.min(start + effectivePageSize, totalMatches);

        for (let i = start; i < end; i++) {
            matchingClaimRows[i].style.display = '';
        }

        // Update Info Text
        document.getElementById('pageInfoText').innerText = 'Showing ' + (start + 1) + ' to ' + end + ' of ' + totalMatches + ' claims';

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
            btn.className = 'page-num' + (p === currentPage ? ' active' : '');
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

    function changeClaimsPageSize(val) {
        if (val === 'ALL') {
            pageSize = 999999;
        } else {
            pageSize = parseInt(val, 10) || 10;
        }
        currentPage = 1;
        renderPage();
    }

        function clearSearch() {
        const input = document.getElementById('claimsSearchInput');
        input.value = '';
        handleFilter();
        input.focus();
    }

    function initClaimTypeSelect() {
        const typeSelect = document.getElementById('claimTypeFilter');
        if (!typeSelect) return;
        if (typeof TomSelect !== 'undefined') {
            if (!typeSelect.tomselect) {
                new TomSelect(typeSelect, {
                    create: false,
                    maxItems: 1,
                    allowEmptyOption: false,
                    controlInput: null,
                    placeholder: 'All Types',
                    onInitialize: function() {
                        this.wrapper.classList.add('claim-type-ts-wrap');
                        this.dropdown.classList.add('claim-type-ts');
                        if (typeof this.positionDropdown === 'function') {
                            this.on('dropdown_open', () => this.positionDropdown());
                        }
                    },
                    onChange: function(val) {
                        handleFilter();
                    }
                });
            }
        } else {
            setTimeout(initClaimTypeSelect, 50);
        }
    }

    function resetFilters() {
        document.getElementById('claimsSearchInput').value = '';
        const typeSelect = document.getElementById('claimTypeFilter');
        if (typeSelect) {
            if (typeSelect.tomselect) {
                typeSelect.tomselect.setValue('ALL');
            } else {
                typeSelect.value = 'ALL';
            }
        }
        currentStatusFilter = '';
        updateActiveStatusTab('');
        handleFilter();
    }
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
