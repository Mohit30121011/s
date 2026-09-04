<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<%
    // Resilient self-contained fallback: ensure rules and auditHistory are populated even if accessed directly
    if (request.getAttribute("rules") == null || request.getAttribute("auditHistory") == null) {
        try {
            com.nlogistic.dao.PricingRuleDAO pDao = new com.nlogistic.dao.PricingRuleDAO();
            if (request.getAttribute("rules") == null) {
                request.setAttribute("rules", pDao.getAllPricingRules());
            }
            if (request.getAttribute("auditHistory") == null) {
                request.setAttribute("auditHistory", pDao.getAuditHistory());
            }
        } catch (Exception ignored) {}
    }

    // Compute live KPI metrics
    java.util.List<com.nlogistic.model.PricingRule> rList = (java.util.List<com.nlogistic.model.PricingRule>) request.getAttribute("rules");
    java.util.List<com.nlogistic.model.PricingAudit> aList = (java.util.List<com.nlogistic.model.PricingAudit>) request.getAttribute("auditHistory");

    int totalRulesCount = (rList != null) ? rList.size() : 0;
    double maxBasePrice = 0.0;
    double sumFinalPrice = 0.0;
    if (rList != null) {
        for (com.nlogistic.model.PricingRule r : rList) {
            if (r.getBasePrice() > maxBasePrice) maxBasePrice = r.getBasePrice();
            sumFinalPrice += r.getFinalPrice();
        }
    }
    double avgFinalPrice = (totalRulesCount > 0) ? (sumFinalPrice / totalRulesCount) : 0.0;
    int totalAuditCount = (aList != null) ? aList.size() : 0;

    request.setAttribute("kpiTotalRules", totalRulesCount);
    request.setAttribute("kpiMaxBasePrice", maxBasePrice);
    request.setAttribute("kpiAvgFinalPrice", avgFinalPrice);
    request.setAttribute("kpiTotalAudit", totalAuditCount);
%>

<style>
    /* ==========================================================================
       PRICING RULES & RATE GOVERNANCE THEME (SWIGGY ORANGE ENTERPRISE)
       ========================================================================== */
    .pricing-governance-container {
        padding: 0 4px 40px;
    }

    /* Breadcrumbs */
    .custom-breadcrumb {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 13px;
        color: #64748B;
        margin-bottom: 16px;
    }
    .custom-breadcrumb a {
        color: #64748B;
        text-decoration: none;
        transition: color 0.15s ease;
    }
    .custom-breadcrumb a:hover {
        color: #FC8019;
    }
    .custom-breadcrumb i {
        font-size: 11px;
        color: #94A3B8;
    }
    .custom-breadcrumb .current {
        color: #FC8019;
        font-weight: 600;
    }

    /* Page Hero Header */
    .governance-header-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 16px;
        padding: 24px 28px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04);
        margin-bottom: 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 20px;
    }
    .governance-header-left {
        display: flex;
        align-items: center;
        gap: 16px;
    }
    .governance-icon-box {
        width: 52px;
        height: 52px;
        border-radius: 14px;
        background: linear-gradient(135deg, #FFF0E5 0%, #FFE4D6 100%);
        border: 1px solid #FFD4C2;
        color: #FC8019;
        font-size: 26px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        box-shadow: 0 2px 8px rgba(252, 128, 25, 0.15);
    }
    .governance-title {
        font-size: 22px;
        font-weight: 800;
        color: #0F172A;
        letter-spacing: -0.4px;
        margin-bottom: 4px;
    }
    .governance-desc {
        font-size: 13.5px;
        color: #64748B;
        margin: 0;
    }

    /* Action Button to Predictive Graph */
    .btn-predictive-nav {
        background: linear-gradient(135deg, #FC8019 0%, #F59E0B 100%);
        color: #FFFFFF !important;
        height: 42px;
        padding: 0 22px;
        border-radius: 50px;
        font-size: 13.5px;
        font-weight: 700;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        text-decoration: none;
        border: none;
        box-shadow: 0 4px 14px rgba(252, 128, 25, 0.28);
        transition: all 0.2s ease;
        cursor: pointer;
    }
    .btn-predictive-nav:hover {
        transform: translateY(-1px);
        box-shadow: 0 6px 20px rgba(252, 128, 25, 0.38);
        color: #FFFFFF !important;
    }

    /* KPI Cards Grid */
    .governance-kpi-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 28px;
    }
    @media (max-width: 1024px) {
        .governance-kpi-grid { grid-template-columns: repeat(2, 1fr); }
    }
    @media (max-width: 640px) {
        .governance-kpi-grid { grid-template-columns: 1fr; }
    }

    .kpi-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 16px;
        padding: 20px 22px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04);
        display: flex;
        align-items: center;
        justify-content: space-between;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    .kpi-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(15, 23, 42, 0.06);
    }
    .kpi-label {
        font-size: 11.5px;
        font-weight: 700;
        color: #64748B;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 6px;
    }
    .kpi-value {
        font-size: 24px;
        font-weight: 800;
        color: #0F172A;
        line-height: 1.1;
    }
    .kpi-subtext {
        font-size: 11.5px;
        color: #94A3B8;
        margin-top: 4px;
    }
    .kpi-icon-pill {
        width: 44px;
        height: 44px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        flex-shrink: 0;
    }
    .kpi-icon-pill.orange { background: #FFF0E5; color: #FC8019; }
    .kpi-icon-pill.green { background: #ECFDF5; color: #059669; }
    .kpi-icon-pill.amber { background: #FFFBEB; color: #D97706; }
    .kpi-icon-pill.blue { background: #EFF6FF; color: #2563EB; }

    /* Governance Panels (Tables) */
    .governance-panel {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 16px;
        box-shadow: 0 1px 4px rgba(15, 23, 42, 0.04);
        overflow: hidden;
        margin-bottom: 32px;
    }

    /* Toolbar Header */
    .governance-toolbar {
        padding: 16px 24px;
        border-bottom: 1px solid #F1F5F9;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 16px;
        background: #FFFFFF;
    }
    .toolbar-title-box {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .toolbar-title-icon {
        width: 36px;
        height: 36px;
        border-radius: 10px;
        background: #FFF0E5;
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 18px;
    }
    .toolbar-title-text {
        font-size: 15.5px;
        font-weight: 800;
        color: #0F172A;
    }
    .toolbar-subtitle-text {
        font-size: 12px;
        color: #64748B;
    }

    .toolbar-controls {
        display: flex;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
    }
    .governance-search-box {
        position: relative;
        width: 260px;
    }
    .governance-search-box i {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #94A3B8;
        font-size: 15px;
        pointer-events: none;
    }
    .governance-search-input {
        width: 100%;
        height: 38px;
        border-radius: 50px;
        border: 1.5px solid #E2E8F0;
        padding: 0 16px 0 38px;
        font-size: 12.5px;
        font-weight: 500;
        color: #1E293B;
        background: #FFFFFF;
        outline: none;
        transition: all 0.2s ease;
    }
    .governance-search-input:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .records-count-badge {
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

    /* Table Styles */
    .governance-table {
        width: 100%;
        border-collapse: collapse;
        margin: 0;
    }
    .governance-table th {
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
    .governance-table th.sortable-th {
        cursor: pointer;
        user-select: none;
        transition: color 0.15s ease;
    }
    .governance-table th.sortable-th:hover {
        color: #FC8019;
    }
    .governance-table th.sortable-th i {
        font-size: 11px;
        margin-left: 4px;
        color: #94A3B8;
    }
    .governance-table td {
        padding: 14px 20px;
        border-bottom: 1px solid #F1F5F9;
        vertical-align: middle;
        font-size: 13.5px;
        color: #1E293B;
    }
    .governance-table tr:last-child td {
        border-bottom: none;
    }
    .governance-table tr:hover td {
        background: #FBFDFE;
    }

    /* Badges & Cell Components */
    .id-tag {
        display: inline-block;
        font-family: monospace;
        font-size: 11.5px;
        font-weight: 700;
        color: #475569;
        background: #F1F5F9;
        padding: 3px 8px;
        border-radius: 6px;
        border: 1px solid #E2E8F0;
    }
    .profile-pill {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        font-weight: 700;
        color: #0F172A;
    }
    .profile-avatar {
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
    .multiplier-tag {
        font-size: 12px;
        font-weight: 700;
        padding: 3px 9px;
        border-radius: 6px;
        display: inline-block;
    }
    .multiplier-tag.seasonal { background: #FFFBEB; color: #B45309; border: 1px solid #FDE68A; }
    .multiplier-tag.demand { background: #FFF0E5; color: #EA580C; border: 1px solid #FFD4C2; }
    .multiplier-tag.surcharge { background: #EFF6FF; color: #1D4ED8; border: 1px solid #BFDBFE; }

    .final-price-pill {
        font-size: 14px;
        font-weight: 800;
        color: #059669;
        background: #ECFDF5;
        border: 1px solid #A7F3D0;
        padding: 4px 12px;
        border-radius: 50px;
        display: inline-flex;
        align-items: center;
        gap: 4px;
    }

    /* Action Buttons */
    .btn-adjust-rate {
        height: 34px;
        padding: 0 14px;
        border-radius: 50px;
        border: 1.5px solid #FFD4C2;
        background: #FFFFFF;
        color: #FC8019;
        font-size: 12.5px;
        font-weight: 700;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        cursor: pointer;
        transition: all 0.15s ease;
    }
    .btn-adjust-rate:hover {
        background: #FFF0E5;
        border-color: #FC8019;
        transform: translateY(-1px);
    }

    /* Audit Table Specifics */
    .price-strike {
        color: #94A3B8;
        text-decoration: line-through;
        font-size: 13px;
    }
    .price-updated {
        color: #059669;
        font-weight: 800;
        font-size: 13.5px;
    }
    .variance-badge {
        font-size: 11.5px;
        font-weight: 700;
        padding: 3px 8px;
        border-radius: 50px;
        display: inline-flex;
        align-items: center;
        gap: 3px;
    }
    .variance-badge.up { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }
    .variance-badge.down { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }
    .variance-badge.same { background: #F1F5F9; color: #64748B; border: 1px solid #E2E8F0; }

    .reason-text {
        color: #475569;
        font-size: 12.5px;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .reason-text i { color: #FC8019; font-size: 13px; flex-shrink: 0; }
    .officer-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        font-size: 12.5px;
        font-weight: 600;
        color: #334155;
    }
    .officer-badge i { color: #059669; }

    /* Pagination Footer */
    .nl-pagination-wrapper {
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 16px;
        padding: 16px 24px;
        background: #FFFFFF;
        border-top: 1px solid #F1F5F9;
    }
    .nl-pagination-info {
        display: flex;
        align-items: center;
        gap: 12px;
        font-size: 13px;
        color: #64748B;
    }
    .nl-pagination-info strong {
        color: #0F172A;
        font-weight: 700;
    }
    .nl-pagination-nav {
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .nl-page-btn {
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
        padding: 0 8px;
        cursor: pointer;
        transition: all 0.15s ease;
    }
    .nl-page-btn:hover:not(.disabled):not(.active) {
        border-color: #CBD5E1;
        background: #F8FAFC;
        color: #0F172A;
    }
    .nl-page-btn.active {
        background: #FC8019;
        border-color: #FC8019;
        color: #FFFFFF;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25);
    }
    .nl-page-btn.disabled {
        opacity: 0.45;
        cursor: not-allowed;
    }

    /* Modal Styling */
    .adjust-modal-header {
        background: linear-gradient(135deg, #1E293B 0%, #0F172A 100%);
        padding: 20px 24px;
        border-radius: 16px 16px 0 0;
        color: #FFFFFF;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .adjust-modal-title {
        font-size: 17px;
        font-weight: 800;
        color: #FFFFFF;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .adjust-modal-title i { color: #FC8019; }
    .adjust-modal-body {
        padding: 24px;
        background: #FFFFFF;
    }
    .adjust-modal-footer {
        padding: 16px 24px;
        background: #F8FAFC;
        border-top: 1px solid #E2E8F0;
        border-radius: 0 0 16px 16px;
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 12px;
    }
</style>

<div class="pricing-governance-container">
    <!-- Breadcrumb -->
    <div class="custom-breadcrumb">
        <a href="${pageContext.request.contextPath}/dashboard"><i class="ti ti-smart-home"></i> Dashboard</a>
        <i class="ti ti-chevron-right"></i>
        <span>Pricing &amp; Governance</span>
        <i class="ti ti-chevron-right"></i>
        <span class="current">Rate Catalog &amp; Audit Trail</span>
    </div>

    <!-- Header Card -->
    <div class="governance-header-card">
        <div class="governance-header-left">
            <div class="governance-icon-box">
                <i class="ti ti-calculator"></i>
            </div>
            <div>
                <h1 class="governance-title">Pricing Rules &amp; Rate Governance</h1>
                <p class="governance-desc">
                    Active freight rate profiles, dynamic multiplier policies, and immutable price-change audit logs (FR3.5 / FR3.7)
                </p>
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/predictive-graph" class="btn-predictive-nav">
            <i class="ti ti-chart-line"></i> Advance Predictive Graph
        </a>
    </div>

    <!-- 4 KPI Metric Cards -->
    <div class="governance-kpi-grid">
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Active Pricing Profiles</div>
                <div class="kpi-value">${kpiTotalRules}</div>
                <div class="kpi-subtext">Configured Container Profiles</div>
            </div>
            <div class="kpi-icon-pill orange"><i class="ti ti-box"></i></div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Average Final Rate</div>
                <div class="kpi-value" style="color: #059669;">
                    $<fmt:formatNumber value="${kpiAvgFinalPrice}" pattern="#,##0.00"/>
                </div>
                <div class="kpi-subtext">All active routes &amp; profiles</div>
            </div>
            <div class="kpi-icon-pill green"><i class="ti ti-currency-dollar"></i></div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Highest Base Tariff</div>
                <div class="kpi-value" style="color: #D97706;">
                    $<fmt:formatNumber value="${kpiMaxBasePrice}" pattern="#,##0.00"/>
                </div>
                <div class="kpi-subtext">Peak tier standard rate</div>
            </div>
            <div class="kpi-icon-pill amber"><i class="ti ti-trending-up"></i></div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Total Audit Adjustments</div>
                <div class="kpi-value" style="color: #2563EB;">${kpiTotalAudit}</div>
                <div class="kpi-subtext">Historical FR3.7 log events</div>
            </div>
            <div class="kpi-icon-pill blue"><i class="ti ti-history"></i></div>
        </div>
    </div>

    <!-- TABLE 1: Active Freight Pricing Rules -->
    <div class="governance-panel">
        <div class="governance-toolbar">
            <div class="toolbar-title-box">
                <div class="toolbar-title-icon"><i class="ti ti-table"></i></div>
                <div>
                    <div class="toolbar-title-text">Active Freight Pricing Rules</div>
                    <div class="toolbar-subtitle-text">Baseline container prices, seasonal factors, and dynamic demand multipliers</div>
                </div>
            </div>
            <div class="toolbar-controls">
                <div class="governance-search-box">
                    <i class="ti ti-search"></i>
                    <input type="text" id="rulesSearchInput" class="governance-search-input" placeholder="Search profile, size, price...">
                </div>
                <div class="records-count-badge" id="rulesCountBadge">
                    <i class="ti ti-list"></i> Showing ${rules.size()} of ${rules.size()} Rules
                </div>
            </div>
        </div>

        <div class="table-responsive">
            <table class="governance-table" id="rulesTable">
                <thead>
                    <tr>
                        <th class="sortable-th" data-col="0" data-type="num" style="width: 80px;">ID <i class="ti ti-selector"></i></th>
                        <th class="sortable-th" data-col="1" data-type="text">Container Profile <i class="ti ti-selector"></i></th>
                        <th class="sortable-th" data-col="2" data-type="num">Base Price <i class="ti ti-selector"></i></th>
                        <th>Seasonal</th>
                        <th>Demand</th>
                        <th>Surcharges</th>
                        <th class="sortable-th" data-col="6" data-type="num">Final Price <i class="ti ti-selector"></i></th>
                        <th class="sortable-th" data-col="7" data-type="text">Valid Until <i class="ti ti-selector"></i></th>
                        <c:if test="${sessionScope.user.roleId <= 2}">
                            <th style="text-align: right;">Action</th>
                        </c:if>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="r" items="${rules}">
                        <tr>
                            <td><span class="id-tag">#PR-${r.pricingId}</span></td>
                            <td>
                                <div class="profile-pill">
                                    <span class="profile-avatar"><i class="ti ti-box-seam"></i></span>
                                    <span>${r.containerSize} ${r.containerType}</span>
                                </div>
                            </td>
                            <td><strong>$<fmt:formatNumber value="${r.basePrice}" maxFractionDigits="2"/></strong></td>
                            <td><span class="multiplier-tag seasonal">&times; <fmt:formatNumber value="${r.seasonalMultiplier}" maxFractionDigits="2"/></span></td>
                            <td><span class="multiplier-tag demand">&times; <fmt:formatNumber value="${r.demandMultiplier}" maxFractionDigits="2"/></span></td>
                            <td><span class="multiplier-tag surcharge">+$<fmt:formatNumber value="${r.surcharges}" maxFractionDigits="2"/></span></td>
                            <td>
                                <span class="final-price-pill">
                                    <i class="ti ti-check"></i> $<fmt:formatNumber value="${r.finalPrice}" maxFractionDigits="2"/>
                                </span>
                            </td>
                            <td>
                                <span style="color: #64748B; font-size: 13px;">
                                    <i class="ti ti-calendar" style="color: #94A3B8;"></i> <fmt:formatDate value="${r.validTo}" pattern="dd MMM yyyy"/>
                                </span>
                            </td>
                            <c:if test="${sessionScope.user.roleId <= 2}">
                                <td style="text-align: right;">
                                    <button type="button" class="btn-adjust-rate" onclick="openAdjustModal(${r.pricingId}, '${r.containerSize} ${r.containerType}', ${r.basePrice})">
                                        <i class="ti ti-pencil"></i> Adjust Rate
                                    </button>
                                </td>
                            </c:if>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty rules}">
                        <tr><td colspan="9" style="text-align: center; color: #94A3B8; padding: 32px;">No pricing rules configured yet.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <div class="nl-pagination-wrapper" id="rulesPagination">
            <div class="nl-pagination-info">
                <span>Showing <strong id="rulesPageStart">1</strong> to <strong id="rulesPageEnd">10</strong> of <strong id="rulesTotalRows">0</strong> records</span>
                <div class="d-inline-flex align-items-center gap-2 ms-2">
                    <span style="color: #94A3B8; font-size: 12.5px;">Rows per page:</span>
                    <select id="rulesPageSize" class="nl-page-size-select no-custom-select" onchange="rulesPager.setPageSize(this.value)">
                        <option value="10" selected>10</option>
                        <option value="25">25</option>
                        <option value="50">50</option>
                    </select>
                </div>
            </div>
            <div class="nl-pagination-nav" id="rulesPageNav"></div>
        </div>
    </div>

    <!-- TABLE 2: Price Change Audit Trail (FR3.7) -->
    <div class="governance-panel">
        <div class="governance-toolbar">
            <div class="toolbar-title-box">
                <div class="toolbar-title-icon"><i class="ti ti-clock-hour-4"></i></div>
                <div>
                    <div class="toolbar-title-text">Price Change Audit Trail (FR3.7)</div>
                    <div class="toolbar-subtitle-text">Immutable historical log of all price updates, old vs new values, reasons, and responsible officers</div>
                </div>
            </div>
            <div class="toolbar-controls">
                <div class="governance-search-box">
                    <i class="ti ti-search"></i>
                    <input type="text" id="auditSearchInput" class="governance-search-input" placeholder="Search reason, officer, profile...">
                </div>
                <div class="records-count-badge" id="auditCountBadge">
                    <i class="ti ti-history"></i> Showing ${auditHistory.size()} of ${auditHistory.size()} Logs
                </div>
            </div>
        </div>

        <div class="table-responsive">
            <table class="governance-table" id="auditTable">
                <thead>
                    <tr>
                        <th class="sortable-th" data-col="0" data-type="num" style="width: 90px;">Audit ID <i class="ti ti-selector"></i></th>
                        <th class="sortable-th" data-col="1" data-type="text">Container Profile <i class="ti ti-selector"></i></th>
                        <th>Previous Price</th>
                        <th class="sortable-th" data-col="3" data-type="num">Updated Price <i class="ti ti-selector"></i></th>
                        <th>Rate Variance</th>
                        <th>Reason for Adjustment</th>
                        <th class="sortable-th" data-col="6" data-type="text">Changed By <i class="ti ti-selector"></i></th>
                        <th class="sortable-th" data-col="7" data-type="text" style="text-align: right;">Timestamp <i class="ti ti-selector"></i></th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="a" items="${auditHistory}">
                        <c:set var="diff" value="${a.newPrice - a.oldPrice}"/>
                        <tr>
                            <td><span class="id-tag">#AUD-${a.auditId}</span></td>
                            <td>
                                <div class="profile-pill">
                                    <span class="profile-avatar"><i class="ti ti-box"></i></span>
                                    <span>${a.containerProfile}</span>
                                </div>
                            </td>
                            <td><span class="price-strike">$<fmt:formatNumber value="${a.oldPrice}" maxFractionDigits="2"/></span></td>
                            <td><span class="price-updated">$<fmt:formatNumber value="${a.newPrice}" maxFractionDigits="2"/></span></td>
                            <td>
                                <c:choose>
                                    <c:when test="${diff > 0}">
                                        <span class="variance-badge up"><i class="ti ti-arrow-up-right"></i> +$<fmt:formatNumber value="${diff}" maxFractionDigits="2"/></span>
                                    </c:when>
                                    <c:when test="${diff < 0}">
                                        <span class="variance-badge down"><i class="ti ti-arrow-down-right"></i> -$<fmt:formatNumber value="${-diff}" maxFractionDigits="2"/></span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="variance-badge same"><i class="ti ti-minus"></i> $0.00</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="reason-text" title="${a.reason}">
                                    <i class="ti ti-quote"></i>
                                    <span>${a.reason}</span>
                                </div>
                            </td>
                            <td>
                                <span class="officer-badge">
                                    <i class="ti ti-user-check"></i> ${a.changedByName}
                                </span>
                            </td>
                            <td style="text-align: right; white-space: nowrap;">
                                <span style="color: #64748B; font-size: 13px;">
                                    <i class="ti ti-clock" style="color: #94A3B8;"></i> <fmt:formatDate value="${a.changedAt}" pattern="dd MMM yyyy, HH:mm"/>
                                </span>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty auditHistory}">
                        <tr><td colspan="8" style="text-align: center; color: #94A3B8; padding: 32px;">No price adjustments logged yet.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <div class="nl-pagination-wrapper" id="auditPagination">
            <div class="nl-pagination-info">
                <span>Showing <strong id="auditPageStart">1</strong> to <strong id="auditPageEnd">10</strong> of <strong id="auditTotalRows">0</strong> records</span>
                <div class="d-inline-flex align-items-center gap-2 ms-2">
                    <span style="color: #94A3B8; font-size: 12.5px;">Rows per page:</span>
                    <select id="auditPageSize" class="nl-page-size-select no-custom-select" onchange="auditPager.setPageSize(this.value)">
                        <option value="10" selected>10</option>
                        <option value="25">25</option>
                        <option value="50">50</option>
                    </select>
                </div>
            </div>
            <div class="nl-pagination-nav" id="auditPageNav"></div>
        </div>
    </div>
</div>

<!-- Adjust Freight Rate Modal (FR3.7 ?" with mandatory reason) -->
<div class="modal fade" id="adjustPriceModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 16px; border: none; overflow: hidden; box-shadow: 0 20px 40px rgba(0,0,0,0.15);">
            <form action="${pageContext.request.contextPath}/pricing/updatePrice" method="POST">
                <input type="hidden" name="pricingId" id="adjustPricingId">
                <div class="adjust-modal-header">
                    <h5 class="adjust-modal-title" id="adjustModalTitle">
                        <i class="ti ti-pencil"></i> Adjust Freight Rate
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="adjust-modal-body">
                    <div style="background: #FFF9F5; border: 1px solid #FFD4C2; border-radius: 10px; padding: 12px 16px; margin-bottom: 20px; display: flex; align-items: center; gap: 12px;">
                        <i class="ti ti-info-circle" style="color: #FC8019; font-size: 20px;"></i>
                        <span style="font-size: 13px; color: #7C2D12;">Target Profile: <strong id="adjustModalProfile">Container Rate</strong></span>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" style="font-weight: 700; font-size: 13px; color: #334155;">New Base Freight Price ($) <span style="color: #DC2626;">*</span></label>
                        <div style="position: relative;">
                            <span style="position: absolute; left: 14px; top: 50%; transform: translateY(-50%); font-weight: 700; color: #64748B;">$</span>
                            <input type="number" step="0.01" name="basePrice" id="adjustBasePrice" class="form-control" required style="padding-left: 28px; height: 42px; border-radius: 8px; border: 1.5px solid #E2E8F0; font-weight: 700; font-size: 15px;">
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" style="font-weight: 700; font-size: 13px; color: #334155;">Mandatory Reason (FR3.7 Compliance Audit) <span style="color: #DC2626;">*</span></label>
                        <textarea name="reason" class="form-control" required rows="3" placeholder="e.g. Q3 bunker fuel adjustment, transatlantic route congestion surcharge" style="border-radius: 8px; border: 1.5px solid #E2E8F0; font-size: 13px; resize: none;"></textarea>
                    </div>
                </div>
                <div class="adjust-modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius: 50px; font-weight: 600; padding: 8px 18px;">Cancel</button>
                    <button type="submit" class="btn" style="background: #FC8019; color: #FFFFFF; border-radius: 50px; font-weight: 700; padding: 8px 22px; box-shadow: 0 4px 12px rgba(252,128,25,0.25);">
                        <i class="ti ti-check"></i> Commit &amp; Log Audit
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function makeTablePager(tableId, searchInputId, paginationPrefix) {
    const table = document.getElementById(tableId);
    if (!table) return null;
    const tbody = table.querySelector('tbody');
    const allRows = Array.from(tbody.querySelectorAll('tr:not([id="emptyRow"])'));
    let filtered = allRows.slice();
    let pageSize = 10;
    let currentPage = 1;
    let sortCol = -1;
    let sortDir = 1;

    function applySearch() {
        const q = (document.getElementById(searchInputId).value || '').trim().toLowerCase();
        filtered = allRows.filter(function(tr) {
            return !q || tr.textContent.toLowerCase().includes(q);
        });
        currentPage = 1;
        render();
    }

    function applySort(col, type) {
        if (sortCol === col) {
            sortDir = -sortDir;
        } else {
            sortCol = col;
            sortDir = 1;
        }
        table.querySelectorAll('.sortable-th').forEach(function(th) { th.classList.remove('sorted-asc', 'sorted-desc'); });
        const th = table.querySelector('.sortable-th[data-col="' + col + '"]');
        if (th) th.classList.add(sortDir === 1 ? 'sorted-asc' : 'sorted-desc');
        filtered.sort(function(a, b) {
            let av = a.children[col].textContent.trim(), bv = b.children[col].textContent.trim();
            if (type === 'num') {
                av = parseFloat(av.replace(/[^0-9.-]/g, '')) || 0;
                bv = parseFloat(bv.replace(/[^0-9.-]/g, '')) || 0;
                return (av - bv) * sortDir;
            }
            return av.localeCompare(bv) * sortDir;
        });
        render();
    }

    function render() {
        allRows.forEach(function(tr) { tr.style.display = 'none'; });
        const total = filtered.length;
        const totalPages = Math.max(1, Math.ceil(total / pageSize));
        if (currentPage > totalPages) currentPage = totalPages;
        const start = (currentPage - 1) * pageSize;
        const end = Math.min(start + pageSize, total);
        for (let i = start; i < end; i++) filtered[i].style.display = '';

        const pageStartEl = document.getElementById(paginationPrefix + 'PageStart');
        const pageEndEl = document.getElementById(paginationPrefix + 'PageEnd');
        const totalRowsEl = document.getElementById(paginationPrefix + 'TotalRows');
        if (pageStartEl) pageStartEl.textContent = total === 0 ? 0 : start + 1;
        if (pageEndEl) pageEndEl.textContent = end;
        if (totalRowsEl) totalRowsEl.textContent = total;

        const countBadge = document.getElementById(paginationPrefix + 'CountBadge');
        if (countBadge) {
            countBadge.innerHTML = '<i class="ti ti-list"></i> Showing ' + total + ' of ' + allRows.length + ' Records';
        }

        const nav = document.getElementById(paginationPrefix + 'PageNav');
        if (nav) {
            nav.innerHTML = '';
            function btn(label, page, disabled, active) {
                const b = document.createElement('button');
                b.type = 'button';
                b.className = 'nl-page-btn' + (active ? ' active' : '') + (disabled ? ' disabled' : '');
                b.textContent = label;
                if (!disabled) b.onclick = function() { currentPage = page; render(); };
                return b;
            }
            nav.appendChild(btn('Prev', currentPage - 1, currentPage <= 1, false));
            for (let p = 1; p <= totalPages; p++) {
                if (totalPages > 7 && p !== 1 && p !== totalPages && Math.abs(p - currentPage) > 1) {
                    if (p === 2 || p === totalPages - 1) { const s = document.createElement('span'); s.textContent = '...'; s.style.padding = '0 4px'; s.style.color = '#94A3B8'; nav.appendChild(s); }
                    continue;
                }
                nav.appendChild(btn(String(p), p, false, p === currentPage));
            }
            nav.appendChild(btn('Next', currentPage + 1, currentPage >= totalPages, false));
        }
    }

    const searchEl = document.getElementById(searchInputId);
    if (searchEl) searchEl.addEventListener('input', applySearch);

    table.querySelectorAll('.sortable-th').forEach(function(th) {
        th.addEventListener('click', function() { applySort(parseInt(th.dataset.col, 10), th.dataset.type); });
    });

    render();
    return {
        setPageSize: function(n) { pageSize = parseInt(n, 10); currentPage = 1; render(); }
    };
}

var rulesPager, auditPager;
document.addEventListener('DOMContentLoaded', function() {
    rulesPager = makeTablePager('rulesTable', 'rulesSearchInput', 'rules');
    auditPager = makeTablePager('auditTable', 'auditSearchInput', 'audit');
});

function openAdjustModal(pricingId, profile, basePrice) {
    document.getElementById('adjustPricingId').value = pricingId;
    document.getElementById('adjustBasePrice').value = basePrice;
    const profEl = document.getElementById('adjustModalProfile');
    if (profEl) profEl.textContent = profile;
    const modalEl = document.getElementById('adjustPriceModal');
    if (modalEl && typeof bootstrap !== 'undefined') {
        const modal = new bootstrap.Modal(modalEl);
        modal.show();
    }
}
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
