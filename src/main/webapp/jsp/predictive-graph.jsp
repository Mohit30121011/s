<%
    if (request.getAttribute("auditHistory") == null) {
        try {
            com.nlogistic.dao.PricingRuleDAO pDao = new com.nlogistic.dao.PricingRuleDAO();
            String cType = (String) request.getAttribute("selectedType");
            if (cType == null) cType = request.getParameter("type");
            if (cType == null) cType = "Dry";
            request.setAttribute("auditHistory", pDao.getAuditHistoryByType(cType));
        } catch (Exception ignored) {}
    }
%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<jsp:include page="/jsp/layout/header.jsp" />

<!-- Include Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    // ==========================================
    // PREDICTIVE AUDIT TRAIL PAGINATION & SEARCH
    // ==========================================
    let allAuditRows = [];
    let matchingAuditRows = [];
    let currentAuditPage = 1;
    let auditPageSize = 10;

    function initAuditTable() {
        allAuditRows = Array.from(document.querySelectorAll('#predictiveAuditTbody .audit-row'));
        matchingAuditRows = allAuditRows.slice();
        renderAuditPage();
    }

    function handleAuditSearch() {
        const query = (document.getElementById('predictiveAuditSearch').value || '').trim().toLowerCase();
        const clearBtn = document.getElementById('auditSearchClearBtn');
        if (clearBtn) clearBtn.style.display = query ? 'block' : 'none';

        matchingAuditRows = allAuditRows.filter(row => {
            const s = (row.getAttribute('data-search') || '').toLowerCase();
            return !query || s.includes(query);
        });

        currentAuditPage = 1;
        renderAuditPage();
    }

    function clearAuditSearch() {
        const input = document.getElementById('predictiveAuditSearch');
        if (input) input.value = '';
        handleAuditSearch();
        if (input) input.focus();
    }

    function changeAuditPageSize(val) {
        if (val === 'ALL') {
            auditPageSize = 999999;
        } else {
            auditPageSize = parseInt(val, 10) || 10;
        }
        currentAuditPage = 1;
        renderAuditPage();
    }

    function changeAuditPage(delta) {
        currentAuditPage += delta;
        renderAuditPage();
    }

    function renderAuditPage() {
        allAuditRows.forEach(r => r.style.display = 'none');
        const total = matchingAuditRows.length;
        const totalPages = Math.max(1, Math.ceil(total / auditPageSize));
        if (currentAuditPage > totalPages) currentAuditPage = totalPages;

        const start = (currentAuditPage - 1) * auditPageSize;
        const end = Math.min(start + auditPageSize, total);

        for (let i = start; i < end; i++) {
            matchingAuditRows[i].style.display = '';
        }

        const infoEl = document.getElementById('auditPageInfoText');
        if (infoEl) {
            infoEl.textContent = 'Showing ' + (total === 0 ? 0 : start + 1) + ' to ' + end + ' of ' + total + ' records';
        }

        const badgeEl = document.getElementById('auditCountBadge');
        if (badgeEl) {
            badgeEl.innerHTML = '<i class="ti ti-list"></i> Showing ' + total + ' of ' + allAuditRows.length + ' Logs';
        }

        const prevBtn = document.getElementById('prevAuditPageBtn');
        const nextBtn = document.getElementById('nextAuditPageBtn');
        if (prevBtn) prevBtn.disabled = (currentAuditPage <= 1);
        if (nextBtn) nextBtn.disabled = (currentAuditPage >= totalPages);

        const wrap = document.getElementById('auditPageNumbersWrap');
        if (wrap) {
            wrap.innerHTML = '';
            for (let p = 1; p <= totalPages; p++) {
                if (totalPages > 7 && p !== 1 && p !== totalPages && Math.abs(p - currentAuditPage) > 1) {
                    if (p === 2 || p === totalPages - 1) {
                        const s = document.createElement('span');
                        s.textContent = '...';
                        s.style.padding = '0 4px';
                        s.style.color = '#94A3B8';
                        wrap.appendChild(s);
                    }
                    continue;
                }
                const btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'page-number-btn' + (p === currentAuditPage ? ' active' : '');
                btn.textContent = p;
                btn.onclick = (function(pageNum) {
                    return function() { currentAuditPage = pageNum; renderAuditPage(); };
                })(p);
                wrap.appendChild(btn);
            }
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        initAuditTable();
    });

</script>

<style>
    /* Predictive Graph & Demand Forecasting Theme (Swiggy Orange Enterprise) */
    .predictive-page-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 24px;
        flex-wrap: wrap;
        gap: 16px;
    }
    .predictive-page-title {
        font-weight: 800;
        color: #0F172A;
        font-size: 24px;
        letter-spacing: -0.3px;
        margin-bottom: 4px;
    }
    .predictive-page-subtitle {
        color: #64748B;
        font-size: 13.5px;
        margin: 0;
    }

    .predictive-filter-form {
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .predictive-filter-select-wrap {
        width: 220px;
    }
    .btn-filter-apply {
        width: 40px;
        height: 42px;
        border-radius: 50px;
        border: none;
        background: #FC8019;
        color: #FFFFFF;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 15px;
        cursor: pointer;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25);
        transition: all 0.18s ease;
        flex-shrink: 0;
    }
    .btn-filter-apply:hover {
        background: #E66F0F;
        transform: translateY(-1px);
    }

    .custom-alert { border-radius: 12px; padding: 14px 18px; font-size: 13.5px; font-weight: 500; display: flex; align-items: center; gap: 10px; margin-bottom: 20px; }
    .custom-alert.success { background: #ECFDF5; border: 1px solid #A7F3D0; color: #065F46; }

    /* 4 Executive KPI Cards */
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
    .kpi-value { font-size: 24px; font-weight: 800; color: #0F172A; line-height: 1; }
    .kpi-icon-pill { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 22px; flex-shrink: 0; }
    .kpi-icon-pill.orange { background: #FFF2EB; color: #FC8019; }
    .kpi-icon-pill.amber { background: #FFFBEB; color: #D97706; }
    .kpi-icon-pill.green { background: #ECFDF5; color: #059669; }
    .kpi-icon-pill.blue { background: #EFF6FF; color: #2563EB; }

    .predictive-card {
        background: #FFFFFF;
        border: 1px solid var(--nl-border);
        border-radius: 14px;
        box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
        height: 100%;
    }
    .predictive-card-body {
        padding: 24px;
    }
    .predictive-card-title {
        font-weight: 700;
        color: #0F172A;
        font-size: 15.5px;
        margin-bottom: 20px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .predictive-card-title i { color: #FC8019; }

    .price-update-desc {
        color: #64748B;
        font-size: 12.5px;
        margin-bottom: 20px;
        line-height: 1.5;
    }
    .form-label-muted {
        color: #64748B;
        font-weight: 700;
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: 0.4px;
        margin-bottom: 6px;
        display: block;
    }
    .form-input-themed {
        width: 100%;
        padding: 11px 14px;
        border-radius: 10px;
        border: 1.5px solid #E2E8F0;
        font-size: 13.5px;
        color: #1E293B;
        outline: none;
        transition: all 0.2s ease;
    }
    .form-input-themed:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .form-input-readonly {
        background: #F8FAFC;
        color: #475569;
    }

    .btn-update-price {
        background: #FC8019;
        color: #FFFFFF !important;
        border: none;
        width: 100%;
        padding: 13px 20px;
        border-radius: 10px;
        font-weight: 700;
        font-size: 14px;
        cursor: pointer;
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.28);
        transition: all 0.18s ease;
    }
    .btn-update-price:hover {
        background: #E66F0F;
        transform: translateY(-1px);
        box-shadow: 0 6px 16px rgba(252, 128, 25, 0.38);
    }

    /* Select Wrapper (identical across pages) */
    .select-wrapper {
        position: relative;
        width: 100%;
    }
    .select-wrapper::after {
        content: '';
        position: absolute;
        right: 16px;
        top: 50%;
        transform: translateY(-50%);
        width: 14px;
        height: 14px;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2364748B' stroke-width='2.2'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E");
        background-size: contain;
        background-repeat: no-repeat;
        pointer-events: none;
    }
    .form-select-custom, .select-wrapper select {
        appearance: none;
        -webkit-appearance: none;
        width: 100%;
        height: 42px;
        padding: 0 38px 0 16px;
        border: 1.5px solid #E2E8F0;
        border-radius: 50px;
        font-size: 13px;
        color: #1E293B;
        background-color: #FFFFFF;
        outline: none;
        transition: all 0.2s ease;
    }
    .form-select-custom:focus, .select-wrapper select:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }

    /* ==========================================================================
       PRICE CHANGE AUDIT TRAIL TABLE (SWIGGY ENTERPRISE)
       ========================================================================== */
    .custom-breadcrumb {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 13px;
        color: #64748B;
        margin-bottom: 16px;
    }
    .custom-breadcrumb a { color: #64748B; text-decoration: none; transition: color 0.15s ease; }
    .custom-breadcrumb a:hover { color: #FC8019; }
    .custom-breadcrumb i { font-size: 11px; color: #94A3B8; }
    .custom-breadcrumb .current { color: #FC8019; font-weight: 600; }

    .predictive-audit-panel {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 16px;
        box-shadow: 0 1px 4px rgba(15, 23, 42, 0.04);
        overflow: hidden;
        margin-top: 32px;
        margin-bottom: 24px;
    }
    .predictive-audit-toolbar {
        padding: 18px 24px;
        border-bottom: 1px solid #F1F5F9;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 16px;
        background: #FFFFFF;
    }
    .audit-toolbar-left {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .audit-title-icon {
        width: 40px;
        height: 40px;
        border-radius: 12px;
        background: #FFF0E5;
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        flex-shrink: 0;
    }
    .audit-title-text {
        font-size: 16px;
        font-weight: 800;
        color: #0F172A;
    }
    .audit-subtitle-text {
        font-size: 12.5px;
        color: #64748B;
    }
    .audit-toolbar-right {
        display: flex;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
    }
    .audit-search-wrap {
        position: relative;
        width: 260px;
    }
    .audit-search-wrap i {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #94A3B8;
        font-size: 15px;
        pointer-events: none;
    }
    .audit-search-input {
        width: 100%;
        height: 38px;
        border-radius: 50px;
        border: 1.5px solid #E2E8F0;
        padding: 0 32px 0 38px;
        font-size: 12.5px;
        font-weight: 500;
        color: #1E293B;
        background: #FFFFFF;
        outline: none;
        transition: all 0.2s ease;
    }
    .audit-search-input:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .audit-search-clear {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        color: #94A3B8;
        font-size: 14px;
        cursor: pointer;
        display: none;
    }
    .audit-counter-badge {
        font-size: 12px;
        font-weight: 600;
        color: #64748B;
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        padding: 5px 14px;
        border-radius: 50px;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        white-space: nowrap;
    }

    .predictive-audit-table {
        width: 100%;
        border-collapse: collapse;
        margin: 0;
    }
    .predictive-audit-table th {
        background: #F8FAFC;
        padding: 13px 20px;
        font-size: 11.5px;
        font-weight: 700;
        color: #64748B;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border-bottom: 1px solid #E2E8F0;
        text-align: left;
        white-space: nowrap;
    }
    .predictive-audit-table td {
        padding: 14px 20px;
        border-bottom: 1px solid #F1F5F9;
        vertical-align: middle;
        font-size: 13.5px;
        color: #1E293B;
    }
    .predictive-audit-table tr:hover td {
        background: #FBFDFE;
    }
    .predictive-audit-table tr:last-child td {
        border-bottom: none;
    }

    .audit-id-badge {
        font-family: monospace;
        font-size: 11.5px;
        font-weight: 700;
        color: #475569;
        background: #F1F5F9;
        padding: 3px 8px;
        border-radius: 6px;
        border: 1px solid #E2E8F0;
    }
    .profile-cell {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        font-weight: 700;
        color: #0F172A;
    }
    .profile-icon {
        width: 30px;
        height: 30px;
        border-radius: 8px;
        background: #FFF0E5;
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
    }
    .old-price-val {
        color: #94A3B8;
        text-decoration: line-through;
        font-size: 13px;
    }
    .new-price-val {
        color: #059669;
        font-weight: 800;
        font-size: 14px;
    }
    .variance-pill {
        font-size: 11.5px;
        font-weight: 700;
        padding: 3px 9px;
        border-radius: 50px;
        display: inline-flex;
        align-items: center;
        gap: 3px;
        white-space: nowrap;
    }
    .variance-pill.up { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }
    .variance-pill.down { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }
    .variance-pill.neutral { background: #F1F5F9; color: #64748B; border: 1px solid #E2E8F0; }

    .reason-cell {
        color: #475569;
        font-size: 13px;
        display: flex;
        align-items: center;
        gap: 6px;
        max-width: 320px;
    }
    .reason-cell i { color: #FC8019; font-size: 14px; flex-shrink: 0; }
    .user-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        font-size: 12.5px;
        font-weight: 600;
        color: #334155;
    }
    .user-badge i { color: #059669; }
    .timestamp-val {
        color: #64748B;
        font-size: 12.5px;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }

    .empty-audit-cell {
        padding: 48px 20px !important;
        text-align: center;
    }
    .empty-audit-box {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 8px;
    }
    .empty-audit-icon {
        width: 52px;
        height: 52px;
        border-radius: 50%;
        background: #FFF0E5;
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 24px;
        margin-bottom: 4px;
    }
    .empty-audit-title {
        font-size: 15px;
        font-weight: 700;
        color: #0F172A;
    }
    .empty-audit-desc {
        font-size: 13px;
        color: #64748B;
        max-width: 420px;
    }

    .audit-pagination-bar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 16px;
        padding: 16px 24px;
        background: #FFFFFF;
        border-top: 1px solid #F1F5F9;
    }
    .audit-page-info {
        display: flex;
        align-items: center;
        gap: 12px;
        font-size: 13px;
        color: #64748B;
    }
    .audit-page-nav {
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .btn-page-step {
        height: 32px;
        padding: 0 12px;
        border-radius: 8px;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        color: #475569;
        font-size: 12.5px;
        font-weight: 600;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 4px;
        transition: all 0.15s ease;
    }
    .btn-page-step:hover:not(:disabled) {
        border-color: #CBD5E1;
        background: #F8FAFC;
        color: #0F172A;
    }
    .btn-page-step:disabled {
        opacity: 0.45;
        cursor: not-allowed;
    }
    .page-numbers-wrap {
        display: flex;
        align-items: center;
        gap: 5px;
    }
    .page-number-btn {
        min-width: 32px;
        height: 32px;
        border-radius: 8px;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        color: #475569;
        font-size: 12.5px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.15s ease;
    }
    .page-number-btn:hover {
        border-color: #CBD5E1;
        background: #F8FAFC;
        color: #0F172A;
    }
    .page-number-btn.active {
        background: #FC8019;
        border-color: #FC8019;
        color: #FFFFFF;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25);
    }


    /* ==========================================================================
       PRICE CHANGE AUDIT TRAIL TABLE (SWIGGY ENTERPRISE)
       ========================================================================== */
    .custom-breadcrumb {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 13px;
        color: #64748B;
        margin-bottom: 16px;
    }
    .custom-breadcrumb a { color: #64748B; text-decoration: none; transition: color 0.15s ease; }
    .custom-breadcrumb a:hover { color: #FC8019; }
    .custom-breadcrumb i { font-size: 11px; color: #94A3B8; }
    .custom-breadcrumb .current { color: #FC8019; font-weight: 600; }

    .predictive-audit-panel {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 16px;
        box-shadow: 0 1px 4px rgba(15, 23, 42, 0.04);
        overflow: hidden;
        margin-top: 32px;
        margin-bottom: 24px;
    }
    .predictive-audit-toolbar {
        padding: 18px 24px;
        border-bottom: 1px solid #F1F5F9;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 16px;
        background: #FFFFFF;
    }
    .audit-toolbar-left {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .audit-title-icon {
        width: 40px;
        height: 40px;
        border-radius: 12px;
        background: #FFF0E5;
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        flex-shrink: 0;
    }
    .audit-title-text {
        font-size: 16px;
        font-weight: 800;
        color: #0F172A;
    }
    .audit-subtitle-text {
        font-size: 12.5px;
        color: #64748B;
    }
    .audit-toolbar-right {
        display: flex;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
    }
    .audit-search-wrap {
        position: relative;
        width: 260px;
    }
    .audit-search-wrap i {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #94A3B8;
        font-size: 15px;
        pointer-events: none;
    }
    .audit-search-input {
        width: 100%;
        height: 38px;
        border-radius: 50px;
        border: 1.5px solid #E2E8F0;
        padding: 0 32px 0 38px;
        font-size: 12.5px;
        font-weight: 500;
        color: #1E293B;
        background: #FFFFFF;
        outline: none;
        transition: all 0.2s ease;
    }
    .audit-search-input:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .audit-search-clear {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        color: #94A3B8;
        font-size: 14px;
        cursor: pointer;
        display: none;
    }
    .audit-counter-badge {
        font-size: 12px;
        font-weight: 600;
        color: #64748B;
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        padding: 5px 14px;
        border-radius: 50px;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        white-space: nowrap;
    }

    .predictive-audit-table {
        width: 100%;
        border-collapse: collapse;
        margin: 0;
    }
    .predictive-audit-table th {
        background: #F8FAFC;
        padding: 13px 20px;
        font-size: 11.5px;
        font-weight: 700;
        color: #64748B;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border-bottom: 1px solid #E2E8F0;
        text-align: left;
        white-space: nowrap;
    }
    .predictive-audit-table td {
        padding: 14px 20px;
        border-bottom: 1px solid #F1F5F9;
        vertical-align: middle;
        font-size: 13.5px;
        color: #1E293B;
    }
    .predictive-audit-table tr:hover td {
        background: #FBFDFE;
    }
    .predictive-audit-table tr:last-child td {
        border-bottom: none;
    }

    .audit-id-badge {
        font-family: monospace;
        font-size: 11.5px;
        font-weight: 700;
        color: #475569;
        background: #F1F5F9;
        padding: 3px 8px;
        border-radius: 6px;
        border: 1px solid #E2E8F0;
    }
    .profile-cell {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        font-weight: 700;
        color: #0F172A;
    }
    .profile-icon {
        width: 30px;
        height: 30px;
        border-radius: 8px;
        background: #FFF0E5;
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
    }
    .old-price-val {
        color: #94A3B8;
        text-decoration: line-through;
        font-size: 13px;
    }
    .new-price-val {
        color: #059669;
        font-weight: 800;
        font-size: 14px;
    }
    .variance-pill {
        font-size: 11.5px;
        font-weight: 700;
        padding: 3px 9px;
        border-radius: 50px;
        display: inline-flex;
        align-items: center;
        gap: 3px;
        white-space: nowrap;
    }
    .variance-pill.up { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }
    .variance-pill.down { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }
    .variance-pill.neutral { background: #F1F5F9; color: #64748B; border: 1px solid #E2E8F0; }

    .reason-cell {
        color: #475569;
        font-size: 13px;
        display: flex;
        align-items: center;
        gap: 6px;
        max-width: 320px;
    }
    .reason-cell i { color: #FC8019; font-size: 14px; flex-shrink: 0; }
    .user-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        font-size: 12.5px;
        font-weight: 600;
        color: #334155;
    }
    .user-badge i { color: #059669; }
    .timestamp-val {
        color: #64748B;
        font-size: 12.5px;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }

    .empty-audit-cell {
        padding: 48px 20px !important;
        text-align: center;
    }
    .empty-audit-box {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 8px;
    }
    .empty-audit-icon {
        width: 52px;
        height: 52px;
        border-radius: 50%;
        background: #FFF0E5;
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 24px;
        margin-bottom: 4px;
    }
    .empty-audit-title {
        font-size: 15px;
        font-weight: 700;
        color: #0F172A;
    }
    .empty-audit-desc {
        font-size: 13px;
        color: #64748B;
        max-width: 420px;
    }

    .audit-pagination-bar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 16px;
        padding: 16px 24px;
        background: #FFFFFF;
        border-top: 1px solid #F1F5F9;
    }
    .audit-page-info {
        display: flex;
        align-items: center;
        gap: 12px;
        font-size: 13px;
        color: #64748B;
    }
    .audit-page-nav {
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .btn-page-step {
        height: 32px;
        padding: 0 12px;
        border-radius: 8px;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        color: #475569;
        font-size: 12.5px;
        font-weight: 600;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 4px;
        transition: all 0.15s ease;
    }
    .btn-page-step:hover:not(:disabled) {
        border-color: #CBD5E1;
        background: #F8FAFC;
        color: #0F172A;
    }
    .btn-page-step:disabled {
        opacity: 0.45;
        cursor: not-allowed;
    }
    .page-numbers-wrap {
        display: flex;
        align-items: center;
        gap: 5px;
    }
    .page-number-btn {
        min-width: 32px;
        height: 32px;
        border-radius: 8px;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        color: #475569;
        font-size: 12.5px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.15s ease;
    }
    .page-number-btn:hover {
        border-color: #CBD5E1;
        background: #F8FAFC;
        color: #0F172A;
    }
    .page-number-btn.active {
        background: #FC8019;
        border-color: #FC8019;
        color: #FFFFFF;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25);
    }

</style>

<div class="container-fluid py-4">
	    <!-- Breadcrumbs -->
    <div class="custom-breadcrumb">
        <a href="${pageContext.request.contextPath}/dashboard"><i class="ti ti-smart-home"></i> Dashboard</a>
        <i class="ti ti-chevron-right"></i>
        <span>Pricing &amp; Governance</span>
        <i class="ti ti-chevron-right"></i>
        <span class="current">Advance Predictive Graph</span>
    </div>
    <div class="predictive-page-header">
		<div>
			<h2 class="predictive-page-title">Advance Predictive Graph</h2>
			<p class="predictive-page-subtitle">Demand Forecasting &amp; Price Trends</p>
		</div>

		<!-- Filter Form -->
		<form action="<c:url value='/predictive-graph'/>" method="GET" class="predictive-filter-form">
			<div class="select-wrapper predictive-filter-select-wrap">
				<select name="type" class="form-select-custom no-custom-select" onchange="this.form.submit()">
					<option value="Dry" ${selectedType == 'Dry' ? 'selected' : ''}>Dry Containers</option>
					<option value="Reefer" ${selectedType == 'Reefer' ? 'selected' : ''}>Reefer Containers</option>
					<option value="Open Top" ${selectedType == 'Open Top' ? 'selected' : ''}>Open Top Containers</option>
				</select>
			</div>
			<button class="btn-filter-apply" type="button" title="Apply Filter">
				<i class="ti ti-filter"></i>
			</button>
		</form>
	</div>

	<c:if test="${not empty sessionScope.successMessage}">
		<div class="custom-alert success">
			<i class="ti ti-circle-check" style="font-size: 18px;"></i>
			<span>${sessionScope.successMessage}</span>
		</div>
		<c:remove var="successMessage" scope="session" />
	</c:if>

	<!-- 4 Executive KPI Cards (derived from forecast data already rendered on this page) -->
	<div class="kpi-grid">
		<div class="kpi-card">
			<div>
				<div class="kpi-label">Container Type</div>
				<div class="kpi-value" style="color: #FC8019; font-size: 18px;">${selectedType}</div>
			</div>
			<div class="kpi-icon-pill orange"><i class="ti ti-box"></i></div>
		</div>
		<div class="kpi-card">
			<div>
				<div class="kpi-label">Current Base Price</div>
				<div class="kpi-value" style="color: #0F172A;">$${currentBasePrice}</div>
			</div>
			<div class="kpi-icon-pill blue"><i class="ti ti-currency-dollar"></i></div>
		</div>
		<div class="kpi-card">
			<div>
				<div class="kpi-label">Avg Forecasted Demand</div>
				<div class="kpi-value" id="kpiAvgDemand" style="color: #D97706;">--</div>
			</div>
			<div class="kpi-icon-pill amber"><i class="ti ti-chart-histogram"></i></div>
		</div>
		<div class="kpi-card">
			<div>
				<div class="kpi-label">Avg Forecasted Price</div>
				<div class="kpi-value" id="kpiAvgPrice" style="color: #059669;">--</div>
			</div>
			<div class="kpi-icon-pill green"><i class="ti ti-trending-up"></i></div>
		</div>
	</div>

	<div class="row g-4 mb-4">
		<div class="col-lg-8">
			<div class="predictive-card">
				<div class="predictive-card-body">
					<div class="predictive-card-title">
						<i class="ti ti-chart-line"></i> Forecasted Demand &amp; Price Trend (Next 6 Periods)
					</div>
					<div style="height: 400px;">
						<canvas id="predictiveChart"></canvas>
					</div>
				</div>
			</div>
		</div>

		<div class="col-lg-4">
			<div class="predictive-card">
				<div class="predictive-card-body">
					<div class="predictive-card-title">
						<i class="ti ti-edit"></i> Update Base Price
					</div>
					<p class="price-update-desc">Every price change shall be logged with old value, new value, reason, timestamp and responsible user.</p>

					<form action="<c:url value='/predictive-graph'/>" method="POST">
						<input type="hidden" name="pricingId" value="${pricingId}">
						<input type="hidden" name="containerType" value="${selectedType}">

						<div class="mb-3">
							<label class="form-label-muted">Current Base Price ($)</label>
							<input type="text" class="form-input-themed form-input-readonly" value="${currentBasePrice}" readonly>
						</div>

						<div class="mb-3">
							<label class="form-label-muted">New Base Price ($)</label>
							<input type="number" step="0.01" name="newPrice" class="form-input-themed" required placeholder="Enter new price">
						</div>

						<div class="mb-4">
							<label class="form-label-muted">Reason for Change</label>
							<textarea name="reason" class="form-input-themed" required rows="3" placeholder="e.g. Due to upcoming peak season" style="resize: vertical;"></textarea>
						</div>

						<button type="submit" class="btn-update-price">
							<i class="ti ti-device-floppy"></i> Update Price &amp; Log Audit
						</button>
					</form>
				</div>
			</div>
		</div>
	</div>

    <!-- Price Change Audit Trail & Governance Log (FR3.7) -->
    <div class="predictive-audit-panel">
        <div class="predictive-audit-toolbar">
            <div class="audit-toolbar-left">
                <div class="audit-title-icon"><i class="ti ti-history"></i></div>
                <div>
                    <div class="audit-title-text">Price Change Audit Trail &amp; Rate History</div>
                    <div class="audit-subtitle-text">Immutable historical ledger of rate adjustments, variance, and officer audit records for <strong><c:out value="${empty selectedType ? 'Dry' : selectedType}"/></strong> containers</div>
                </div>
            </div>
            <div class="audit-toolbar-right">
                <div class="audit-search-wrap">
                    <i class="ti ti-search"></i>
                    <input type="text" id="predictiveAuditSearch" class="audit-search-input" placeholder="Search reason, officer, profile..." oninput="handleAuditSearch()">
                    <button type="button" id="auditSearchClearBtn" class="audit-search-clear" onclick="clearAuditSearch()">&times;</button>
                </div>
                <div class="audit-counter-badge" id="auditCountBadge">
                    <i class="ti ti-list"></i> Showing ${auditHistory.size()} of ${auditHistory.size()} Logs
                </div>
            </div>
        </div>

        <div class="table-responsive">
            <table class="predictive-audit-table" id="predictiveAuditTable">
                <thead>
                    <tr>
                        <th style="width: 100px;"><i class="ti ti-hash"></i> Audit ID</th>
                        <th><i class="ti ti-box"></i> Container Profile</th>
                        <th><i class="ti ti-tag"></i> Previous Base Price</th>
                        <th><i class="ti ti-tag-starred"></i> Updated Base Price</th>
                        <th><i class="ti ti-trending-up"></i> Rate Variance</th>
                        <th><i class="ti ti-message-2"></i> Reason for Change</th>
                        <th><i class="ti ti-user"></i> Changed By</th>
                        <th style="text-align: right;"><i class="ti ti-calendar-time"></i> Timestamp</th>
                    </tr>
                </thead>
                <tbody id="predictiveAuditTbody">
                    <c:forEach var="a" items="${auditHistory}">
                        <c:set var="diff" value="${a.newPrice - a.oldPrice}"/>
                        <tr class="audit-row" data-search="${a.auditId} ${a.containerProfile} ${a.reason.toLowerCase()} ${a.changedByName.toLowerCase()}">
                            <td><span class="audit-id-badge">#AUD-${a.auditId}</span></td>
                            <td>
                                <div class="profile-cell">
                                    <span class="profile-icon"><i class="ti ti-box-seam"></i></span>
                                    <span><c:out value="${empty a.containerProfile ? selectedType.concat(' Container') : a.containerProfile}"/></span>
                                </div>
                            </td>
                            <td><span class="old-price-val">$<fmt:formatNumber value="${a.oldPrice}" pattern="#,##0.00"/></span></td>
                            <td><span class="new-price-val">$<fmt:formatNumber value="${a.newPrice}" pattern="#,##0.00"/></span></td>
                            <td>
                                <c:choose>
                                    <c:when test="${diff > 0}">
                                        <span class="variance-pill up"><i class="ti ti-arrow-up-right"></i> +$<fmt:formatNumber value="${diff}" pattern="#,##0.00"/></span>
                                    </c:when>
                                    <c:when test="${diff < 0}">
                                        <span class="variance-pill down"><i class="ti ti-arrow-down-right"></i> -$<fmt:formatNumber value="${-diff}" pattern="#,##0.00"/></span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="variance-pill neutral"><i class="ti ti-minus"></i> $0.00</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="reason-cell" title="<c:out value="${a.reason}"/>">
                                    <i class="ti ti-quote"></i>
                                    <span><c:out value="${empty a.reason ? 'Periodic tariff adjustment' : a.reason}"/></span>
                                </div>
                            </td>
                            <td>
                                <span class="user-badge">
                                    <i class="ti ti-user-check"></i> <c:out value="${empty a.changedByName ? 'system_admin' : a.changedByName}"/>
                                </span>
                            </td>
                            <td style="text-align: right; white-space: nowrap;">
                                <span class="timestamp-val">
                                    <i class="ti ti-clock"></i> <fmt:formatDate value="${a.changedAt}" pattern="dd MMM yyyy, HH:mm"/>
                                </span>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty auditHistory}">
                        <tr id="emptyAuditRow">
                            <td colspan="8" class="empty-audit-cell">
                                <div class="empty-audit-box">
                                    <div class="empty-audit-icon"><i class="ti ti-history"></i></div>
                                    <div class="empty-audit-title">No Price Adjustments Logged Yet</div>
                                    <div class="empty-audit-desc">Use the Update Base Price form above to adjust the tariff rate and generate an immutable audit log trail.</div>
                                </div>
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <div class="audit-pagination-bar" id="auditPaginationBar">
            <div class="audit-page-info">
                <span id="auditPageInfoText">Showing 1 to ${auditHistory.size()} of ${auditHistory.size()} records</span>
                <div class="page-size-wrap ms-3">
                    <span style="color: #94A3B8; font-size: 12.5px;">Rows:</span>
                    <select id="predictiveAuditPageSize" class="nl-page-size-select no-custom-select" onchange="changeAuditPageSize(this.value)">
                        <option value="5">5</option>
                        <option value="10" selected>10</option>
                        <option value="25">25</option>
                        <option value="ALL">All</option>
                    </select>
                </div>
            </div>
            <div class="audit-page-nav">
                <button type="button" class="btn-page-step" id="prevAuditPageBtn" onclick="changeAuditPage(-1)" disabled>
                    <i class="ti ti-chevron-left"></i> Previous
                </button>
                <div class="page-numbers-wrap" id="auditPageNumbersWrap"></div>
                <button type="button" class="btn-page-step" id="nextAuditPageBtn" onclick="changeAuditPage(1)">
                    Next <i class="ti ti-chevron-right"></i>
                </button>
            </div>
        </div>
    </div>

</div>

<script>
	document.addEventListener("DOMContentLoaded",
			function() {
				const ctx = document.getElementById('predictiveChart')
						.getContext('2d');

				const labels = ${chartLabels};
				const demandData = ${chartDemand};
				const priceData = ${chartPrice};

				// Populate KPI cards with derived averages from the forecast series already loaded above
				(function() {
					const avg = (arr) => (arr && arr.length) ? (arr.reduce((a, b) => a + b, 0) / arr.length) : 0;
					const avgDemandEl = document.getElementById('kpiAvgDemand');
					const avgPriceEl = document.getElementById('kpiAvgPrice');
					if (avgDemandEl) avgDemandEl.textContent = Math.round(avg(demandData)).toLocaleString();
					if (avgPriceEl) avgPriceEl.textContent = '$' + avg(priceData).toFixed(2);
				})();

				new Chart(ctx, {
					type : 'line',
					data : {
						labels : labels,
						datasets : [ {
							label : 'Forecasted Demand (Units)',
							data : demandData,
							borderColor : '#FC8019',
							backgroundColor : 'rgba(252, 128, 25, 0.1)',
							borderWidth : 2,
							tension : 0.4,
							yAxisID : 'y'
						}, {
							label : 'Forecasted Price ($)',
							data : priceData,
							borderColor : '#10b981',
							backgroundColor : 'rgba(16, 185, 129, 0.1)',
							borderWidth : 2,
							borderDash : [ 5, 5 ],
							tension : 0.4,
							yAxisID : 'y1'
						} ]
					},
					options : {
						responsive : true,
						maintainAspectRatio : false,
						interaction : {
							mode : 'index',
							intersect : false,
						},
						scales : {
							y : {
								type : 'linear',
								display : true,
								position : 'left',
								title : {
									display : true,
									text : 'Demand'
								}
							},
							y1 : {
								type : 'linear',
								display : true,
								position : 'right',
								title : {
									display : true,
									text : 'Price ($)'
								},
								grid : {
									drawOnChartArea : false
								}
							}
						}
					}
				});
			

    // ==========================================
    // PREDICTIVE AUDIT TRAIL PAGINATION & SEARCH
    // ==========================================
    let allAuditRows = [];
    let matchingAuditRows = [];
    let currentAuditPage = 1;
    let auditPageSize = 10;

    function initAuditTable() {
        allAuditRows = Array.from(document.querySelectorAll('#predictiveAuditTbody .audit-row'));
        matchingAuditRows = allAuditRows.slice();
        renderAuditPage();
    }

    function handleAuditSearch() {
        const query = (document.getElementById('predictiveAuditSearch').value || '').trim().toLowerCase();
        const clearBtn = document.getElementById('auditSearchClearBtn');
        if (clearBtn) clearBtn.style.display = query ? 'block' : 'none';

        matchingAuditRows = allAuditRows.filter(row => {
            const s = (row.getAttribute('data-search') || '').toLowerCase();
            return !query || s.includes(query);
        });

        currentAuditPage = 1;
        renderAuditPage();
    }

    function clearAuditSearch() {
        const input = document.getElementById('predictiveAuditSearch');
        if (input) input.value = '';
        handleAuditSearch();
        if (input) input.focus();
    }

    function changeAuditPageSize(val) {
        if (val === 'ALL') {
            auditPageSize = 999999;
        } else {
            auditPageSize = parseInt(val, 10) || 10;
        }
        currentAuditPage = 1;
        renderAuditPage();
    }

    function changeAuditPage(delta) {
        currentAuditPage += delta;
        renderAuditPage();
    }

    function renderAuditPage() {
        allAuditRows.forEach(r => r.style.display = 'none');
        const total = matchingAuditRows.length;
        const totalPages = Math.max(1, Math.ceil(total / auditPageSize));
        if (currentAuditPage > totalPages) currentAuditPage = totalPages;

        const start = (currentAuditPage - 1) * auditPageSize;
        const end = Math.min(start + auditPageSize, total);

        for (let i = start; i < end; i++) {
            matchingAuditRows[i].style.display = '';
        }

        const infoEl = document.getElementById('auditPageInfoText');
        if (infoEl) {
            infoEl.textContent = 'Showing ' + (total === 0 ? 0 : start + 1) + ' to ' + end + ' of ' + total + ' records';
        }

        const badgeEl = document.getElementById('auditCountBadge');
        if (badgeEl) {
            badgeEl.innerHTML = '<i class="ti ti-list"></i> Showing ' + total + ' of ' + allAuditRows.length + ' Logs';
        }

        const prevBtn = document.getElementById('prevAuditPageBtn');
        const nextBtn = document.getElementById('nextAuditPageBtn');
        if (prevBtn) prevBtn.disabled = (currentAuditPage <= 1);
        if (nextBtn) nextBtn.disabled = (currentAuditPage >= totalPages);

        const wrap = document.getElementById('auditPageNumbersWrap');
        if (wrap) {
            wrap.innerHTML = '';
            for (let p = 1; p <= totalPages; p++) {
                if (totalPages > 7 && p !== 1 && p !== totalPages && Math.abs(p - currentAuditPage) > 1) {
                    if (p === 2 || p === totalPages - 1) {
                        const s = document.createElement('span');
                        s.textContent = '...';
                        s.style.padding = '0 4px';
                        s.style.color = '#94A3B8';
                        wrap.appendChild(s);
                    }
                    continue;
                }
                const btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'page-number-btn' + (p === currentAuditPage ? ' active' : '');
                btn.textContent = p;
                btn.onclick = (function(pageNum) {
                    return function() { currentAuditPage = pageNum; renderAuditPage(); };
                })(p);
                wrap.appendChild(btn);
            }
        }
    }

    initAuditTable();

});
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
