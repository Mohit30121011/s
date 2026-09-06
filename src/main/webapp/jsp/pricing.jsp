<%-- MVC2 (SRS 10.2): PricingServlet (/pricing) supplies rules, audit history
     and the booking quote. --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<%-- MVC2 (SRS 10.2): PricingServlet (/pricing) supplies rules, audit history
     and the booking quote. --%>
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

    /* Page Hero Header - Clean transparent container */
    .governance-header-card {
        background: transparent !important;
        border: none !important;
        border-radius: 0 !important;
        padding: 4px 0 20px 0 !important;
        box-shadow: none !important;
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

    /* Suppress card toolbar (Export/Fullscreen icons) */
    .nl-card-tools,
    .no-card-tools .nl-card-tools,
    [data-no-tools="true"] .nl-card-tools {
        display: none !important;
    }

    /* Standard Tracking Table Styling (Matching All Shipments) */
    .tracking-table,
    .governance-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
        margin: 0;
    }
    .tracking-table th,
    .governance-table th {
        font-size: 12px;
        color: #64748B;
        font-weight: 600;
        padding: 16px 24px;
        border-bottom: 1px solid #E2E8F0;
        text-align: left;
        background: #F9FAFB;
        vertical-align: middle;
        white-space: nowrap;
    }
    .tracking-table th:first-child,
    .governance-table th:first-child { border-top-left-radius: 8px; }
    .tracking-table th:last-child,
    .governance-table th:last-child { border-top-right-radius: 8px; }

    .tracking-table th.sortable-th,
    .governance-table th.sortable-th {
        cursor: pointer;
        user-select: none;
        transition: color 0.15s ease;
    }
    .tracking-table th.sortable-th:hover,
    .governance-table th.sortable-th:hover {
        color: #FC8019;
    }
    .tracking-table th.sortable-th i,
    .governance-table th.sortable-th i {
        font-size: 11px;
        margin-left: 4px;
        color: #94A3B8;
    }

    .tracking-table td,
    .governance-table td {
        padding: 16px 24px;
        font-size: 14px;
        color: #1E293B;
        font-weight: 500;
        border-bottom: 1px solid #E2E8F0;
        vertical-align: middle;
        background: transparent;
        transition: background-color 0.15s ease;
    }
    .tracking-table tbody tr,
    .governance-table tbody tr {
        transition: background-color 0.15s ease;
    }
    .tracking-table tbody tr:hover,
    .governance-table tbody tr:hover {
        background-color: #F9FAFB;
        cursor: pointer;
    }
    .tracking-table tbody tr:last-child td,
    .governance-table tbody tr:last-child td {
        border-bottom: none;
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
        height: 36px;
        padding: 0 16px;
        border-radius: 50px;
        border: 1.5px solid #FFD4C2;
        background: #FFF2EB;
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
        background: #FC8019;
        border-color: #FC8019;
        color: #FFFFFF !important;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.25);
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
    .nl-page-size-select {
        height: 32px;
        border-radius: 50px;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        color: #475569;
        font-size: 12.5px;
        font-weight: 600;
        padding: 0 16px;
        outline: none;
        cursor: pointer;
        transition: all 0.15s ease;
    }
    .nl-page-size-select:focus {
        border-color: #FC8019;
    }

    .kpi-value.kpi-val-green { color: #059669; }
    .kpi-value.kpi-val-amber { color: #D97706; }
    .kpi-value.kpi-val-blue { color: #2563EB; }

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

    /* ==========================================================================
       DYNAMIC PRICING BREAKDOWN & BOOKING SUMMARY (FR3.5)
       ========================================================================== */
    .booking-summary-wrapper {
        max-width: 1140px;
        margin: 0 auto;
        padding-bottom: 30px;
    }
    .booking-header-card {
        background: #FFFFFF;
        border: 1px solid var(--nl-border);
        border-radius: 14px;
        padding: 24px 28px;
        margin-bottom: 24px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 16px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04);
    }
    .booking-header-left {
        display: flex;
        align-items: center;
        gap: 16px;
    }
    .booking-header-icon {
        width: 52px;
        height: 52px;
        border-radius: 12px;
        background: #FFF2EB;
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 26px;
        flex-shrink: 0;
    }
    .booking-header-title {
        font-size: 22px;
        font-weight: 800;
        color: #0F172A;
        letter-spacing: -0.02em;
        margin-bottom: 4px;
    }
    .booking-header-subtitle {
        font-size: 13.5px;
        color: #64748B;
        margin: 0;
    }
    .booking-status-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: #ECFDF5;
        border: 1px solid #A7F3D0;
        color: #065F46;
        font-size: 13px;
        font-weight: 700;
        padding: 7px 14px;
        border-radius: 20px;
    }
    .summary-card {
        background: #FFFFFF;
        border: 1px solid var(--nl-border);
        border-radius: 14px;
        box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
        overflow: hidden;
        height: 100%;
        display: flex;
        flex-direction: column;
    }
    .summary-card-header {
        padding: 18px 24px;
        background: #FAFAFA;
        border-bottom: 1px solid var(--nl-border);
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .summary-card-title {
        font-size: 15px;
        font-weight: 700;
        color: #0F172A;
        display: flex;
        align-items: center;
        gap: 8px;
        margin: 0;
    }
    .summary-card-title i {
        color: #FC8019;
        font-size: 18px;
    }
    .summary-card-body {
        padding: 24px;
        flex: 1;
    }
    .spec-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 0;
        border-bottom: 1px solid #F1F5F9;
        font-size: 13.5px;
    }
    .spec-item:last-child {
        border-bottom: none;
    }
    .spec-item-label {
        color: #64748B;
        display: flex;
        align-items: center;
        gap: 8px;
        font-weight: 500;
    }
    .spec-item-value {
        font-weight: 700;
        color: #0F172A;
    }
    .spec-utilization-bar {
        height: 6px;
        border-radius: 3px;
        background: #E2E8F0;
        margin-top: 6px;
        overflow: hidden;
    }
    .spec-utilization-fill {
        height: 100%;
        border-radius: 3px;
        background: #FC8019;
    }
    .route-visual-box {
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        padding: 18px;
        margin-top: 18px;
    }
    .route-step {
        display: flex;
        align-items: flex-start;
        gap: 12px;
    }
    .route-step-circle {
        width: 30px;
        height: 30px;
        border-radius: 50%;
        background: #FFF2EB;
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 13px;
        font-weight: 800;
        flex-shrink: 0;
        margin-top: 2px;
    }
    .route-step-circle.dest {
        background: #EFF6FF;
        color: #2563EB;
    }
    .route-step-line {
        width: 2px;
        height: 24px;
        background: #CBD5E1;
        margin-left: 14px;
    }
    .route-step-label {
        font-size: 11px;
        font-weight: 700;
        color: #94A3B8;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    .route-step-port {
        font-size: 14px;
        font-weight: 700;
        color: #0F172A;
    }
    .breakdown-table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 20px;
    }
    .breakdown-table tr {
        border-bottom: 1px dashed #E2E8F0;
    }
    .breakdown-table tr:last-child {
        border-bottom: none;
    }
    .breakdown-table td {
        padding: 13px 0;
        vertical-align: middle;
    }
    .breakdown-line-name {
        font-size: 14px;
        font-weight: 700;
        color: #0F172A;
    }
    .breakdown-line-desc {
        font-size: 12px;
        color: #64748B;
        margin-top: 2px;
    }
    .breakdown-line-val {
        text-align: right;
        font-size: 15px;
        font-weight: 700;
        color: #0F172A;
    }
    .multiplier-badge-seasonal {
        background: #FFFBEB;
        color: #D97706;
        border: 1px solid #FDE68A;
        padding: 4px 10px;
        border-radius: 6px;
        font-weight: 700;
        font-size: 13.5px;
        display: inline-block;
    }
    .multiplier-badge-demand {
        background: #FEF2F2;
        color: #DC2626;
        border: 1px solid #FECACA;
        padding: 4px 10px;
        border-radius: 6px;
        font-weight: 700;
        font-size: 13.5px;
        display: inline-block;
    }
    .surcharge-badge {
        background: #EFF6FF;
        color: #2563EB;
        border: 1px solid #BFDBFE;
        padding: 4px 10px;
        border-radius: 6px;
        font-weight: 700;
        font-size: 13.5px;
        display: inline-block;
    }
    .booking-bill-preview {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px;
        padding: 14px 16px; margin: 14px 0 16px 0;
    }
    .booking-bill-preview .bbp-title {
        font-size: 12px; font-weight: 700; color: #0F172A; text-transform: uppercase;
        letter-spacing: 0.04em; margin-bottom: 10px;
    }
    .booking-bill-preview .bbp-row {
        display: flex; justify-content: space-between; align-items: baseline; gap: 12px;
        font-size: 13px; color: #475569; padding: 5px 0;
    }
    .booking-bill-preview .bbp-row strong { color: #0F172A; font-weight: 600; }
    .booking-bill-preview .bbp-total {
        border-top: 1px solid #E2E8F0; margin-top: 6px; padding-top: 10px; font-size: 14px;
    }
    .booking-bill-preview .bbp-total strong { color: #FC8019; font-weight: 800; font-size: 16px; }
    .booking-bill-preview .bbp-note { font-size: 11.5px; color: #94A3B8; margin-top: 8px; }
    .hero-price-card {
        background: linear-gradient(135deg, #0F172A 0%, #1E293B 100%);
        border: 1.5px solid #334155;
        border-radius: 12px;
        padding: 22px 24px;
        color: #FFFFFF;
        margin-bottom: 22px;
        position: relative;
        overflow: hidden;
    }
    .hero-price-card::after {
        content: '';
        position: absolute;
        right: -20px;
        bottom: -20px;
        width: 120px;
        height: 120px;
        background: radial-gradient(circle, rgba(252, 128, 25, 0.25) 0%, transparent 70%);
        pointer-events: none;
    }
    .hero-price-tag {
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        color: #94A3B8;
        margin-bottom: 4px;
    }
    .hero-price-formula {
        font-size: 12px;
        color: #94A3B8;
        margin-bottom: 6px;
    }
    .hero-price-value {
        font-size: 34px;
        font-weight: 800;
        color: #10B981;
        letter-spacing: -0.02em;
        line-height: 1.1;
    }
    .btn-confirm-booking-cta {
        width: 100%;
        background: linear-gradient(135deg, #FC8019 0%, #E66F0F 100%);
        color: #FFFFFF !important;
        border: none;
        border-radius: 10px;
        padding: 14px 24px;
        font-size: 16px;
        font-weight: 700;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        box-shadow: 0 4px 14px rgba(252, 128, 25, 0.35);
        transition: all 0.18s ease;
        cursor: pointer;
    }
    .btn-confirm-booking-cta:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(252, 128, 25, 0.45);
    }
    .btn-back-allocation {
        width: 100%;
        background: #FFFFFF;
        color: #64748B !important;
        border: 1.5px solid #E2E8F0;
        border-radius: 10px;
        padding: 11px 20px;
        font-size: 14px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        margin-top: 10px;
        text-decoration: none;
        transition: all 0.15s ease;
    }
    .btn-back-allocation:hover {
        background: #F8FAFC;
        border-color: #CBD5E1;
        color: #0F172A !important;
    }

    /* ==========================================================================
       ENTERPRISE DARK THEME COMPATIBILITY FOR PRICING & RATE GOVERNANCE
       ========================================================================== */
    [data-theme="dark"] .pricing-governance-container {
        color: #F8FAFC;
    }

    /* Breadcrumbs in Dark Mode */
    [data-theme="dark"] .custom-breadcrumb a {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .custom-breadcrumb a:hover {
        color: #FC8019 !important;
    }
    [data-theme="dark"] .custom-breadcrumb i {
        color: #64748B !important;
    }
    [data-theme="dark"] .custom-breadcrumb span {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .custom-breadcrumb .current {
        color: #FC8019 !important;
    }

    /* Page Header */
    [data-theme="dark"] .governance-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .governance-desc {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .governance-icon-box {
        background: rgba(252, 128, 25, 0.16) !important;
        border-color: rgba(252, 128, 25, 0.3) !important;
        color: #FC8019 !important;
        box-shadow: 0 2px 10px rgba(252, 128, 25, 0.2) !important;
    }

    /* Buttons in Dark Mode */
    [data-theme="dark"] .btn-adjust-rate {
        background: #151F28 !important;
        border-color: #334756 !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .btn-adjust-rate:hover {
        background: #1E293B !important;
        border-color: #FC8019 !important;
        color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.18) !important;
    }
    [data-theme="dark"] .btn-predictive-nav {
        box-shadow: 0 4px 16px rgba(252, 128, 25, 0.35) !important;
    }

    /* 4 KPI Metric Cards in Dark Mode */
    [data-theme="dark"] .kpi-card {
        background: #101820 !important;
        border: 1px solid #22303A !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .kpi-card:hover {
        box-shadow: 0 8px 25px rgba(0, 0, 0, 0.45) !important;
        border-color: #2D3F4D !important;
    }
    [data-theme="dark"] .kpi-label {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .kpi-value {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .kpi-value.kpi-val-green {
        color: #34D399 !important;
    }
    [data-theme="dark"] .kpi-value.kpi-val-amber {
        color: #FBBF24 !important;
    }
    [data-theme="dark"] .kpi-value.kpi-val-blue {
        color: #60A5FA !important;
    }
    [data-theme="dark"] .kpi-subtext {
        color: #64748B !important;
    }

    /* KPI Icon Badges in Dark Mode */
    [data-theme="dark"] .kpi-icon-pill.orange {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FB923C !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .kpi-icon-pill.green {
        background: rgba(16, 185, 129, 0.16) !important;
        color: #34D399 !important;
        border: 1px solid rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .kpi-icon-pill.amber {
        background: rgba(245, 158, 11, 0.16) !important;
        color: #FBBF24 !important;
        border: 1px solid rgba(245, 158, 11, 0.3) !important;
    }
    [data-theme="dark"] .kpi-icon-pill.blue {
        background: rgba(59, 130, 246, 0.16) !important;
        color: #60A5FA !important;
        border: 1px solid rgba(59, 130, 246, 0.3) !important;
    }

    /* Table Panels (Matching All Shipments) in Dark Mode */
    [data-theme="dark"] .tracking-card,
    [data-theme="dark"] .governance-panel {
        background: #101820 !important;
        border: 1px solid #22303A !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .governance-toolbar {
        background: #101820 !important;
        border-bottom: 1px solid #22303A !important;
    }
    [data-theme="dark"] .toolbar-title-text {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .toolbar-subtitle-text {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .toolbar-title-icon {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FC8019 !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .governance-search-box i {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .governance-search-input {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .governance-search-input:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.18) !important;
    }
    [data-theme="dark"] .records-count-badge {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #94A3B8 !important;
    }

    /* Table Rows, Cells & Typography (Matching All Shipments) in Dark Mode */
    [data-theme="dark"] .tracking-table th,
    [data-theme="dark"] .governance-table th {
        background-color: #0E151C !important;
        color: #94A3B8 !important;
        border-bottom: 1px solid #22303A !important;
    }
    [data-theme="dark"] .tracking-table td,
    [data-theme="dark"] .governance-table td {
        background-color: transparent !important;
        color: #F8FAFC !important;
        border-bottom: 1px solid #22303A !important;
    }
    [data-theme="dark"] .tracking-table tbody tr:hover,
    [data-theme="dark"] .governance-table tbody tr:hover {
        background-color: rgba(255, 255, 255, 0.03) !important;
    }
    [data-theme="dark"] .tracking-table tbody tr:last-child td,
    [data-theme="dark"] .governance-table tbody tr:last-child td {
        border-bottom: none !important;
    }

    [data-theme="dark"] .sortable-th:hover {
        color: #FC8019 !important;
    }
    [data-theme="dark"] .sortable-th i {
        color: #64748B !important;
    }
    [data-theme="dark"] .sortable-th.sorted-asc,
    [data-theme="dark"] .sortable-th.sorted-desc {
        color: #FC8019 !important;
    }
    [data-theme="dark"] .sortable-th.sorted-asc i,
    [data-theme="dark"] .sortable-th.sorted-desc i {
        color: #FC8019 !important;
    }

    /* Badges & Icons in Table Cells in Dark Mode */
    [data-theme="dark"] .id-tag {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .profile-pill {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .profile-avatar {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FC8019 !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .multiplier-tag.seasonal {
        background: rgba(245, 158, 11, 0.16) !important;
        color: #FBBF24 !important;
        border: 1px solid rgba(245, 158, 11, 0.3) !important;
    }
    [data-theme="dark"] .multiplier-tag.demand {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FB923C !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .multiplier-tag.surcharge {
        background: rgba(59, 130, 246, 0.16) !important;
        color: #60A5FA !important;
        border: 1px solid rgba(59, 130, 246, 0.3) !important;
    }
    [data-theme="dark"] .final-price-pill {
        background: rgba(16, 185, 129, 0.16) !important;
        color: #34D399 !important;
        border: 1px solid rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .price-strike {
        color: #64748B !important;
    }
    [data-theme="dark"] .price-updated {
        color: #34D399 !important;
    }
    [data-theme="dark"] .variance-badge.up {
        background: rgba(16, 185, 129, 0.16) !important;
        color: #34D399 !important;
        border: 1px solid rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .variance-badge.down {
        background: rgba(239, 68, 68, 0.16) !important;
        color: #F87171 !important;
        border: 1px solid rgba(239, 68, 68, 0.3) !important;
    }
    [data-theme="dark"] .variance-badge.same {
        background: #151F28 !important;
        color: #94A3B8 !important;
        border: 1px solid #2D3F4D !important;
    }
    [data-theme="dark"] .reason-text {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .reason-text i {
        color: #FC8019 !important;
    }
    [data-theme="dark"] .officer-badge {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .officer-badge i {
        color: #34D399 !important;
    }

    /* Pagination Footer in Dark Mode */
    [data-theme="dark"] .nl-pagination-wrapper {
        background: #101820 !important;
        border-top: 1px solid #22303A !important;
    }
    [data-theme="dark"] .nl-pagination-info {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .nl-pagination-info strong {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .nl-page-btn {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .nl-page-btn:hover:not(.disabled):not(.active) {
        background: #1E293B !important;
        border-color: #FC8019 !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .nl-page-btn.active {
        background: #FC8019 !important;
        border-color: #FC8019 !important;
        color: #FFFFFF !important;
    }
    [data-theme="dark"] .nl-page-size-select {
        background-color: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }

    /* Modal Styling in Dark Mode */
    [data-theme="dark"] #adjustPriceModal .modal-content {
        background: #101820 !important;
        border: 1px solid #22303A !important;
        color: #F8FAFC !important;
        box-shadow: 0 20px 50px rgba(0, 0, 0, 0.6) !important;
    }
    [data-theme="dark"] .adjust-modal-header {
        background: #151F28 !important;
        border-bottom: 1px solid #22303A !important;
    }
    [data-theme="dark"] .adjust-modal-body {
        background: #101820 !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .adjust-modal-body div[style*="background: #FFF9F5"],
    [data-theme="dark"] .adjust-modal-body div[style*="background:#FFF9F5"] {
        background: rgba(252, 128, 25, 0.12) !important;
        border-color: rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .adjust-modal-body span[style*="color: #7C2D12"],
    [data-theme="dark"] .adjust-modal-body span[style*="color:#7C2D12"] {
        color: #FDBA74 !important;
    }
    [data-theme="dark"] .adjust-modal-body label {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .adjust-modal-body .form-control {
        background-color: #151F28 !important;
        border: 1px solid #334756 !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .adjust-modal-body .form-control:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.22) !important;
    }
    [data-theme="dark"] .adjust-modal-footer {
        background: #151F28 !important;
        border-top: 1px solid #22303A !important;
    }
    [data-theme="dark"] .adjust-modal-footer .btn-light {
        background: #1E293B !important;
        border-color: #334756 !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .adjust-modal-footer .btn-light:hover {
        background: #253346 !important;
        color: #F8FAFC !important;
    }

    /* Booking Summary (FR3.5) in Dark Mode */
    [data-theme="dark"] .booking-header-card {
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
    }
    [data-theme="dark"] .booking-header-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .booking-header-subtitle {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .booking-header-icon {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FC8019 !important;
        border: 1px solid rgba(252, 128, 25, 0.3) !important;
    }
    [data-theme="dark"] .booking-status-badge {
        background: rgba(16, 185, 129, 0.16) !important;
        color: #34D399 !important;
        border-color: rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .summary-card {
        background: #101820 !important;
        border-color: #22303A !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .summary-card-header {
        background: #151F28 !important;
        border-bottom-color: #22303A !important;
    }
    [data-theme="dark"] .summary-card-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .spec-item {
        border-bottom-color: #22303A !important;
    }
    [data-theme="dark"] .spec-item-label {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .spec-item-value {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .route-visual-box {
        background: #151F28 !important;
        border-color: #22303A !important;
    }
    [data-theme="dark"] .route-step-circle {
        background: rgba(252, 128, 25, 0.16) !important;
        color: #FB923C !important;
    }
    [data-theme="dark"] .route-step-circle.dest {
        background: rgba(59, 130, 246, 0.16) !important;
        color: #60A5FA !important;
    }
    [data-theme="dark"] .route-step-port {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .route-step-line {
        background: #334756 !important;
    }
    [data-theme="dark"] .breakdown-table tr {
        border-bottom-color: #22303A !important;
    }
    [data-theme="dark"] .breakdown-line-name {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .breakdown-line-desc {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .breakdown-line-val {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .booking-bill-preview {
        background: #151F28 !important;
        border-color: #22303A !important;
    }
    [data-theme="dark"] .booking-bill-preview .bbp-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .booking-bill-preview .bbp-row {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .booking-bill-preview .bbp-row strong {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .booking-bill-preview .bbp-total {
        border-top-color: #22303A !important;
    }
    [data-theme="dark"] .btn-back-allocation {
        background: #151F28 !important;
        border-color: #334756 !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .btn-back-allocation:hover {
        background: #1E293B !important;
        color: #F8FAFC !important;
    }

</style>

<div class="pricing-governance-container">
    <c:choose>
        <c:when test="${not empty finalPrice}">
            <!-- PRICING & BOOKING SUMMARY (FR3.5) -->
            <div class="booking-summary-wrapper">
                <!-- Breadcrumbs -->
                <div class="custom-breadcrumb mb-3">
                    <a href="${pageContext.request.contextPath}/containers"><i class="ti ti-layout-grid"></i> Containers</a>
                    <span class="sep"><i class="ti ti-chevron-right"></i></span>
                    <a href="${pageContext.request.contextPath}/allocate?containerId=${container.containerId}">Allocate Cargo</a>
                    <span class="sep"><i class="ti ti-chevron-right"></i></span>
                    <span class="current">Pricing &amp; Booking Summary</span>
                </div>

                <!-- Page Header Card -->
                <div class="booking-header-card">
                    <div class="booking-header-left">
                        <div class="booking-header-icon">
                            <i class="ti ti-receipt-2"></i>
                        </div>
                        <div>
                            <div class="booking-header-title">Pricing &amp; Booking Summary</div>
                            <p class="booking-header-subtitle">Review your verified cargo allocation and dynamic rate governance breakdown (FR3.5)</p>
                        </div>
                    </div>
                    <div>
                        <span class="booking-status-badge">
                            <i class="ti ti-shield-check"></i> Capacity Preconditions Passed (FR3.4)
                        </span>
                    </div>
                </div>

                <div class="row g-4">
                    <!-- Left: Cargo & Routing Specifications -->
                    <div class="col-lg-5">
                        <div class="summary-card">
                            <div class="summary-card-header">
                                <h6 class="summary-card-title">
                                    <i class="ti ti-box"></i> Cargo &amp; Container Specs
                                </h6>
                                <span class="profile-pill">${container.size} ${container.type}</span>
                            </div>
                            <div class="summary-card-body">
                                <div class="spec-item">
                                    <span class="spec-item-label"><i class="ti ti-hash"></i> Container No.</span>
                                    <span class="spec-item-value" style="font-family: monospace; font-size: 14px;">#${container.containerNumber}</span>
                                </div>
                                <div class="spec-item">
                                    <span class="spec-item-label"><i class="ti ti-file-description"></i> Cargo Description</span>
                                    <span class="spec-item-value">${cargoDesc}</span>
                                </div>
                                <div class="spec-item" style="flex-direction: column; align-items: stretch;">
                                    <div class="d-flex justify-content-between">
                                        <span class="spec-item-label"><i class="ti ti-weight"></i> Weight Allocation</span>
                                        <span class="spec-item-value"><fmt:formatNumber value="${cargoWeight}" maxFractionDigits="2"/> / <fmt:formatNumber value="${container.goodsCapacityKg}" maxFractionDigits="2"/> kg</span>
                                    </div>
                                    <div class="spec-utilization-bar">
                                        <div class="spec-utilization-fill" style="width: ${Math.min(100.0, (cargoWeight / (container.goodsCapacityKg > 0 ? container.goodsCapacityKg : 1.0)) * 100.0)}%;"></div>
                                    </div>
                                </div>
                                <div class="spec-item" style="flex-direction: column; align-items: stretch;">
                                    <div class="d-flex justify-content-between">
                                        <span class="spec-item-label"><i class="ti ti-cube"></i> Volume Allocation</span>
                                        <span class="spec-item-value"><fmt:formatNumber value="${cargoVolume}" maxFractionDigits="2"/> / <fmt:formatNumber value="${container.goodsCapacityCbm}" maxFractionDigits="2"/> CBM</span>
                                    </div>
                                    <div class="spec-utilization-bar">
                                        <div class="spec-utilization-fill" style="width: ${Math.min(100.0, (cargoVolume / (container.goodsCapacityCbm > 0 ? container.goodsCapacityCbm : 1.0)) * 100.0)}%; background: #2563EB;"></div>
                                    </div>
                                </div>

                                <!-- Route Visualization -->
                                <div class="route-visual-box">
                                    <div class="route-step">
                                        <div class="route-step-circle"><i class="ti ti-map-pin"></i></div>
                                        <div>
                                            <div class="route-step-label">Origin Port (Point A)</div>
                                            <div class="route-step-port">
                                                <c:choose>
                                                    <c:when test="${not empty originPort}">${originPort.portName} (${originPort.country})</c:when>
                                                    <c:otherwise>Port #${origin}</c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="route-step-line"></div>
                                    <div class="route-step">
                                        <div class="route-step-circle dest"><i class="ti ti-anchor"></i></div>
                                        <div>
                                            <div class="route-step-label">Destination Port (Point B)</div>
                                            <div class="route-step-port">
                                                <c:choose>
                                                    <c:when test="${not empty destPort}">${destPort.portName} (${destPort.country})</c:when>
                                                    <c:otherwise>Port #${destination}</c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right: Dynamic Pricing Breakdown & Booking Confirmation -->
                    <div class="col-lg-7">
                        <div class="summary-card">
                            <div class="summary-card-header">
                                <h6 class="summary-card-title">
                                    <i class="ti ti-calculator"></i> Dynamic Rate Calculation (FR3.5)
                                </h6>
                                <span class="badge bg-light text-muted border px-2 py-1" style="font-size: 11px;">Algorithm Sec 5.5</span>
                            </div>
                            <div class="summary-card-body">
                                <table class="breakdown-table">
                                    <tbody>
                                        <tr>
                                            <td>
                                                <div class="breakdown-line-name">Commercial Base Rate</div>
                                                <div class="breakdown-line-desc">Standard tariff for ${container.size} ${container.type} profile</div>
                                            </td>
                                            <td class="breakdown-line-val">
                                                $<fmt:formatNumber value="${pricingRule.basePrice}" minFractionDigits="2" maxFractionDigits="2"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div class="breakdown-line-name">Seasonal Multiplier</div>
                                                <div class="breakdown-line-desc">Peak season demand / weather adjustment factor</div>
                                            </td>
                                            <td class="breakdown-line-val">
                                                <span class="multiplier-badge-seasonal">× <fmt:formatNumber value="${pricingRule.seasonalMultiplier}" minFractionDigits="2" maxFractionDigits="2"/></span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div class="breakdown-line-name">Demand Multiplier</div>
                                                <div class="breakdown-line-desc">Real-time demand surge index (Predictive Engine)</div>
                                            </td>
                                            <td class="breakdown-line-val">
                                                <span class="multiplier-badge-demand">× <fmt:formatNumber value="${pricingRule.demandMultiplier}" minFractionDigits="2" maxFractionDigits="2"/></span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div class="breakdown-line-name">Port &amp; Environmental Surcharges</div>
                                                <div class="breakdown-line-desc">Terminal handling (THC) &amp; low-sulfur bunker charge</div>
                                            </td>
                                            <td class="breakdown-line-val">
                                                <span class="surcharge-badge">+$<fmt:formatNumber value="${pricingRule.surcharges}" minFractionDigits="2" maxFractionDigits="2"/></span>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>

                                <!-- Hero Final Price Card -->
                                <div class="hero-price-card">
                                    <div class="hero-price-tag"><i class="ti ti-tag me-1"></i> Total Calculated Freight Rate</div>
                                    <div class="hero-price-formula">Formula: [Base ($<fmt:formatNumber value="${pricingRule.basePrice}" maxFractionDigits="0"/>) × Seasonal (<fmt:formatNumber value="${pricingRule.seasonalMultiplier}" maxFractionDigits="2"/>) × Demand (<fmt:formatNumber value="${pricingRule.demandMultiplier}" maxFractionDigits="2"/>)] + Surcharges ($<fmt:formatNumber value="${pricingRule.surcharges}" maxFractionDigits="0"/>)</div>
                                    <div class="hero-price-value">$<fmt:formatNumber value="${finalPrice}" minFractionDigits="2" maxFractionDigits="2"/></div>
                                </div>

                                <%-- What the invoice will actually say.
                                     The rate above is the freight only, while the invoice adds
                                     18% GST - so a customer accepted one number and was billed
                                     another. generate_invoice now bills exactly this freight,
                                     and this panel shows the same arithmetic up front. --%>
                                <div class="booking-bill-preview">
                                    <div class="bbp-title"><i class="ti ti-receipt"></i> What you will be invoiced</div>
                                    <div class="bbp-row">
                                        <span>Freight (rate calculated above)</span>
                                        <strong>$<fmt:formatNumber value="${finalPrice}" minFractionDigits="2" maxFractionDigits="2"/></strong>
                                    </div>
                                    <div class="bbp-row">
                                        <span>GST @ 18%</span>
                                        <strong>$<fmt:formatNumber value="${finalPrice * 0.18}" minFractionDigits="2" maxFractionDigits="2"/></strong>
                                    </div>
                                    <div class="bbp-row bbp-total">
                                        <span>Invoice total</span>
                                        <strong>$<fmt:formatNumber value="${finalPrice * 1.18}" minFractionDigits="2" maxFractionDigits="2"/></strong>
                                    </div>
                                    <div class="bbp-note">This is the amount that will appear on your invoice. Payable within 30 days.</div>
                                </div>

                                <!-- Booking Action Form: Initiates Payment Gateway -->
                                <form id="bookingDataForm">
                                    <input type="hidden" name="containerId" value="${container.containerId}">
                                    <input type="hidden" name="cargoWeight" value="${cargoWeight}">
                                    <input type="hidden" name="cargoVolume" value="${cargoVolume}">
                                    <input type="hidden" name="cargoDesc" value="${cargoDesc}">
                                    <input type="hidden" name="finalPrice" value="${finalPrice}">
                                    <input type="hidden" name="origin" value="${origin}">
                                    <input type="hidden" name="destination" value="${destination}">
                                    <input type="hidden" name="vesselId" value="${vesselId}">
                                    <input type="hidden" name="customerId" value="${customerId}">
                                    <input type="hidden" name="cargoValue" value="${cargoValue}">
                                    
                                    <button type="button" class="btn-confirm-booking-cta" id="btnOpenPaymentGateway" onclick="launchPaymentGateway()">
                                        <i class="ti ti-credit-card"></i> Proceed to Payment &amp; Allocate Container
                                    </button>
                                </form>

                                <a href="${pageContext.request.contextPath}/allocate?containerId=${container.containerId}" class="btn-back-allocation">
                                    <i class="ti ti-arrow-left"></i> Modify Cargo Specifications
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- ========================================================================= -->
            <!-- N-LOGISTIC ENTERPRISE MOCK PAYMENT GATEWAY MODAL (CROSS-DEVICE SYNC)       -->
            <!-- ========================================================================= -->
            <div class="modal fade" id="nlogisticPaymentModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static" data-bs-keyboard="false">
                <div class="modal-dialog modal-dialog-centered modal-xl">
                    <div class="modal-content payment-modal-content">
                        
                        <!-- Modal Header -->
                        <div class="payment-modal-header">
                            <div class="d-flex align-items-center gap-3">
                                <div class="payment-brand-icon">
                                    <i class="ti ti-shield-lock-filled"></i>
                                </div>
                                <div>
                                    <div class="payment-brand-title">N-LOGISTIC SECURE CHECKOUT</div>
                                    <div class="payment-brand-sub">
                                        <span id="displayTxnRef">Order Ref: Generating...</span> &bull; 256-bit TLS Encrypted
                                    </div>
                                </div>
                            </div>
                            <div class="d-flex align-items-center gap-3">
                                <div class="payment-header-amount">
                                    <span class="label">Total Amount:</span>
                                    <span class="val">$<fmt:formatNumber value="${finalPrice * 1.18}" minFractionDigits="2" maxFractionDigits="2"/></span>
                                </div>
                                <button type="button" class="btn-close btn-close-white" onclick="closePaymentGateway()"></button>
                            </div>
                        </div>

                        <!-- Modal Body: 2-Column Grid -->
                        <div class="payment-modal-body">
                            <div class="row g-0">
                                <!-- Left Column: Order Breakdown & Protection -->
                                <div class="col-lg-5 payment-summary-col">
                                    <div class="payment-col-title">
                                        <i class="ti ti-receipt-2"></i> Shipment &amp; Invoice Breakdown
                                    </div>

                                    <div class="order-spec-card">
                                        <div class="order-spec-row">
                                            <span class="text-muted">Allocated Asset</span>
                                            <strong>Container #${container.containerId} (${container.type} ${container.size})</strong>
                                        </div>
                                        <div class="order-spec-row">
                                            <span class="text-muted">Origin &rarr; Destination</span>
                                            <strong>${not empty originPort ? originPort.portName : 'Origin Port'} &rarr; ${not empty destPort ? destPort.portName : 'Destination Port'}</strong>
                                        </div>
                                        <div class="order-spec-row">
                                            <span class="text-muted">Cargo Payload</span>
                                            <span>${cargoDesc} (${cargoWeight} kg / ${cargoVolume} CBM)</span>
                                        </div>
                                    </div>

                                    <div class="payment-calc-list">
                                        <div class="calc-row">
                                            <span>Base Ocean Freight Tariff</span>
                                            <span>$<fmt:formatNumber value="${finalPrice - 270.0 > 0 ? finalPrice - 270.0 : finalPrice}" minFractionDigits="2" maxFractionDigits="2"/></span>
                                        </div>
                                        <div class="calc-row">
                                            <span>Port &amp; Environmental Surcharges</span>
                                            <span>$270.00</span>
                                        </div>
                                        <div class="calc-row">
                                            <span>Calculated Freight Total</span>
                                            <strong>$<fmt:formatNumber value="${finalPrice}" minFractionDigits="2" maxFractionDigits="2"/></strong>
                                        </div>
                                        <div class="calc-row">
                                            <span>Goods &amp; Services Tax (GST @ 18%)</span>
                                            <span>$<fmt:formatNumber value="${finalPrice * 0.18}" minFractionDigits="2" maxFractionDigits="2"/></span>
                                        </div>
                                        <div class="calc-divider"></div>
                                        <div class="calc-row calc-total">
                                            <span>Net Payable Invoice Total</span>
                                            <span class="total-highlight">$<fmt:formatNumber value="${finalPrice * 1.18}" minFractionDigits="2" maxFractionDigits="2"/></span>
                                        </div>
                                        <div class="calc-inr-equiv">
                                            &approx; &#8377;<fmt:formatNumber value="${finalPrice * 1.18 * 84.0}" minFractionDigits="2" maxFractionDigits="2"/> INR
                                        </div>
                                    </div>

                                    <div class="security-guarantee-box">
                                        <div class="sec-item"><i class="ti ti-lock-check"></i> PCI DSS Compliant</div>
                                        <div class="sec-item"><i class="ti ti-shield-check"></i> NPCI Certified UPI</div>
                                        <div class="sec-item"><i class="ti ti-certificate"></i> Escrow Secured</div>
                                    </div>
                                </div>

                                <!-- Right Column: Payment Options & Interactive Tabs -->
                                <div class="col-lg-7 payment-interactive-col">
                                    <!-- Tabs Navigation -->
                                    <div class="payment-tabs-header">
                                        <button type="button" class="tab-btn active" onclick="switchPayTab('upi')">
                                            <i class="ti ti-qrcode"></i>
                                            <span>UPI / QR Scan</span>
                                            <span class="tab-badge">Instant Sync</span>
                                        </button>
                                        <button type="button" class="tab-btn" onclick="switchPayTab('card')">
                                            <i class="ti ti-credit-card"></i>
                                            <span>Credit / Debit Card</span>
                                        </button>
                                        <button type="button" class="tab-btn" onclick="switchPayTab('netbank')">
                                            <i class="ti ti-building-bank"></i>
                                            <span>Net Banking</span>
                                        </button>
                                    </div>

                                    <!-- Tab 1: UPI / QR Code -->
                                    <div class="tab-pane-content" id="tabPaneUpi">
                                        <div class="qr-scan-zone">
                                            <div class="qr-box-wrapper">
                                                <div class="qr-corner top-left"></div>
                                                <div class="qr-corner top-right"></div>
                                                <div class="qr-corner bottom-left"></div>
                                                <div class="qr-corner bottom-right"></div>
                                                <div class="qr-scan-line"></div>
                                                <img id="gwQrImage" src="" alt="Scan to Pay via UPI" class="qr-image-tag">
                                                <div id="qrLoadingSpinner" class="qr-spinner-overlay">
                                                    <div class="spinner-border text-warning" role="status"></div>
                                                    <span class="mt-2 text-muted font-monospace" style="font-size: 11px;">Generating Dynamic QR...</span>
                                                </div>
                                            </div>

                                            <div class="qr-instructions">
                                                <h6>Scan with Any Phone Camera or UPI App</h6>
                                                <p>Works with Google Pay, PhonePe, Paytm, BHIM or mobile browser.</p>
                                                
                                                <div class="mobile-direct-link-box">
                                                    <i class="ti ti-device-mobile"></i>
                                                    <span class="label">Direct Mobile URL:</span>
                                                    <a id="gwMobileDirectLink" href="#" target="_blank" class="mobile-link-text">Open Mobile Simulator &nearr;</a>
                                                    <button type="button" class="btn-copy-url" onclick="copyMobileUrl()" title="Copy Mobile Link">
                                                        <i class="ti ti-copy"></i>
                                                    </button>
                                                </div>

                                                <!-- Instant Demo Trigger -->
                                                <div class="mt-3">
                                                    <button type="button" class="btn-demo-pay" id="btnDesktopDemoPay" onclick="triggerMockPayment('UPI_QR (Desktop Simulation)')">
                                                        <i class="ti ti-bolt"></i> Simulate Instant Payment (Desktop Test Mode)
                                                    </button>
                                                </div>

                                                <div class="live-listener-status">
                                                    <span class="radar-pulse"></span>
                                                    <span>Listening for mobile approval in real time...</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Tab 2: Credit / Debit Card -->
                                    <div class="tab-pane-content d-none" id="tabPaneCard">
                                        <div class="card-payment-container">
                                            <div class="interactive-card-mock">
                                                <div class="card-chip"></div>
                                                <div class="card-number-display" id="mockCardNum">•••• •••• •••• 4242</div>
                                                <div class="card-meta-row">
                                                    <div>
                                                        <div class="card-meta-label">CARD HOLDER</div>
                                                        <div class="card-meta-val" id="mockCardHolder">${sessionScope.user.username != null ? sessionScope.user.username : 'AYUSH SINGH'}</div>
                                                    </div>
                                                    <div>
                                                        <div class="card-meta-label">EXPIRES</div>
                                                        <div class="card-meta-val" id="mockCardExp">12/28</div>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="row g-3 mt-1">
                                                <div class="col-12">
                                                    <label class="form-label font-weight-bold" style="font-size: 12px;">Card Number</label>
                                                    <input type="text" class="form-control form-control-custom" id="inputCardNumber" value="4532 8921 4452 4242" maxlength="19" oninput="updateMockCardNum(this.value)">
                                                </div>
                                                <div class="col-md-6">
                                                    <label class="form-label font-weight-bold" style="font-size: 12px;">Expiry (MM/YY)</label>
                                                    <input type="text" class="form-control form-control-custom" id="inputCardExp" value="12/28" maxlength="5" oninput="updateMockCardExp(this.value)">
                                                </div>
                                                <div class="col-md-6">
                                                    <label class="form-label font-weight-bold" style="font-size: 12px;">CVV / CVC</label>
                                                    <input type="password" class="form-control form-control-custom" id="inputCardCvv" value="892" maxlength="4">
                                                </div>
                                            </div>

                                            <button type="button" class="btn-pay-action mt-4" onclick="triggerMockPayment('Credit Card (Visa / Master)')">
                                                <i class="ti ti-lock"></i> Authorize &amp; Pay $<fmt:formatNumber value="${finalPrice * 1.18}" minFractionDigits="2" maxFractionDigits="2"/>
                                            </button>
                                        </div>
                                    </div>

                                    <!-- Tab 3: Net Banking -->
                                    <div class="tab-pane-content d-none" id="tabPaneNetbank">
                                        <div class="netbanking-container">
                                            <div class="text-muted mb-3" style="font-size: 13px;">Select your bank to authenticate through corporate netbanking:</div>
                                            <div class="bank-grid">
                                                <div class="bank-card active" onclick="selectBank(this, 'HDFC')">
                                                    <div class="bank-icon-circle"><i class="ti ti-building-bank"></i></div>
                                                    <span>HDFC Bank</span>
                                                </div>
                                                <div class="bank-card" onclick="selectBank(this, 'ICICI')">
                                                    <div class="bank-icon-circle"><i class="ti ti-building-bank"></i></div>
                                                    <span>ICICI Bank</span>
                                                </div>
                                                <div class="bank-card" onclick="selectBank(this, 'SBI')">
                                                    <div class="bank-icon-circle"><i class="ti ti-building-bank"></i></div>
                                                    <span>State Bank of India</span>
                                                </div>
                                                <div class="bank-card" onclick="selectBank(this, 'AXIS')">
                                                    <div class="bank-icon-circle"><i class="ti ti-building-bank"></i></div>
                                                    <span>Axis Bank</span>
                                                </div>
                                            </div>

                                            <button type="button" class="btn-pay-action mt-4" onclick="triggerMockPayment('Net Banking')">
                                                <i class="ti ti-lock"></i> Authorize with Selected Bank
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Full Success Overlay Inside Modal -->
                        <div class="payment-success-overlay" id="paymentSuccessOverlay">
                            <div class="success-celebration-box">
                                <div class="success-icon-anim">
                                    <i class="ti ti-circle-check-filled"></i>
                                </div>
                                <h3 class="success-heading">Payment Verified &amp; Booking Confirmed!</h3>
                                <p class="success-subheading">
                                    Freight authorization completed successfully. Your shipment is officially booked &mdash; container allocation is underway by Operations Dispatch.
                                </p>

                                <div class="success-receipt-card">
                                    <div class="receipt-row">
                                        <span class="r-label">Shipment Tracking ID</span>
                                        <strong class="r-val" id="resShipmentTag" style="color: #FC8019; font-size: 16px;">#SHP-PND</strong>
                                    </div>
                                    <div class="receipt-row">
                                        <span class="r-label">Invoice Reference</span>
                                        <strong class="r-val" id="resInvoiceTag">INV-PND (PAID)</strong>
                                    </div>
                                    <div class="receipt-row">
                                        <span class="r-label">Payment Mode</span>
                                        <span class="r-val" id="resMethodTag">UPI QR Code</span>
                                    </div>
                                    <div class="receipt-row">
                                        <span class="r-label">Container Allocation</span>
                                        <span class="r-val" style="color: #D97706; font-weight: 600; font-size: 13px;">
                                            <i class="ti ti-clock me-1"></i> Pending Operations Dispatch
                                        </span>
                                    </div>
                                    <div class="receipt-row">
                                        <span class="r-label">Amount Paid</span>
                                        <strong class="r-val text-success">$<fmt:formatNumber value="${finalPrice * 1.18}" minFractionDigits="2" maxFractionDigits="2"/></strong>
                                    </div>
                                </div>

                                <div class="success-nav-actions">
                                    <a id="btnNavLiveTracking" href="${pageContext.request.contextPath}/shipments" class="btn-success-action primary">
                                        <i class="ti ti-map-pin"></i> Track Shipment Live
                                    </a>
                                    <a href="${pageContext.request.contextPath}/shipments" class="btn-success-action secondary">
                                        <i class="ti ti-truck-delivery"></i> View in My Shipments
                                    </a>
                                    <a href="${pageContext.request.contextPath}/invoices" class="btn-success-action secondary">
                                        <i class="ti ti-receipt"></i> View Invoices &amp; Payments
                                    </a>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>

            <!-- Styles for Mock Payment Gateway Modal -->
            <style>
                .payment-modal-content {
                    border-radius: 24px;
                    border: none;
                    overflow: hidden;
                    box-shadow: 0 25px 60px rgba(0, 0, 0, 0.25);
                    background: #FFFFFF;
                    position: relative;
                }
                [data-theme="dark"] .payment-modal-content {
                    background: #101820;
                    border: 1px solid #22303A;
                }
                .payment-modal-header {
                    background: linear-gradient(135deg, #101820 0%, #1A2530 100%);
                    color: #FFFFFF;
                    padding: 20px 28px;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                }
                .payment-brand-icon {
                    width: 44px;
                    height: 44px;
                    border-radius: 12px;
                    background: rgba(252, 128, 25, 0.2);
                    color: #FC8019;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 24px;
                }
                .payment-brand-title {
                    font-size: 16px;
                    font-weight: 800;
                    letter-spacing: 0.5px;
                }
                .payment-brand-sub {
                    font-size: 12px;
                    color: #94A3B8;
                }
                .payment-header-amount {
                    text-align: right;
                }
                .payment-header-amount .label {
                    display: block;
                    font-size: 11px;
                    text-transform: uppercase;
                    color: #94A3B8;
                    font-weight: 600;
                }
                .payment-header-amount .val {
                    font-size: 20px;
                    font-weight: 800;
                    color: #10B981;
                }

                .payment-modal-body {
                    padding: 0;
                }
                .payment-summary-col {
                    background: #F8FAFC;
                    padding: 30px;
                    border-right: 1px solid #E2E8F0;
                }
                [data-theme="dark"] .payment-summary-col {
                    background: #151F28;
                    border-color: #22303A;
                }
                .payment-col-title {
                    font-size: 14px;
                    font-weight: 700;
                    color: #1E293B;
                    margin-bottom: 18px;
                    display: flex;
                    align-items: center;
                    gap: 8px;
                }
                [data-theme="dark"] .payment-col-title {
                    color: #F8FAFC;
                }
                .order-spec-card {
                    background: #FFFFFF;
                    border: 1px solid #E2E8F0;
                    border-radius: 14px;
                    padding: 16px;
                    margin-bottom: 20px;
                }
                [data-theme="dark"] .order-spec-card {
                    background: #101820;
                    border-color: #22303A;
                }
                .order-spec-row {
                    display: flex;
                    flex-direction: column;
                    margin-bottom: 10px;
                    font-size: 12.5px;
                }
                .order-spec-row:last-child { margin-bottom: 0; }
                .order-spec-row strong { color: #1E293B; }
                [data-theme="dark"] .order-spec-row strong { color: #F8FAFC; }

                .payment-calc-list {
                    background: #FFFFFF;
                    border: 1px solid #E2E8F0;
                    border-radius: 14px;
                    padding: 18px;
                    margin-bottom: 20px;
                }
                [data-theme="dark"] .payment-calc-list {
                    background: #101820;
                    border-color: #22303A;
                }
                .calc-row {
                    display: flex;
                    justify-content: space-between;
                    font-size: 13px;
                    padding: 6px 0;
                    color: #475569;
                }
                [data-theme="dark"] .calc-row { color: #94A3B8; }
                .calc-divider {
                    height: 1px;
                    background: #E2E8F0;
                    margin: 10px 0;
                }
                [data-theme="dark"] .calc-divider { background: #22303A; }
                .calc-total {
                    font-size: 14.5px;
                    font-weight: 700;
                    color: #0F172A;
                }
                [data-theme="dark"] .calc-total { color: #F8FAFC; }
                .total-highlight {
                    color: #FC8019;
                    font-size: 18px;
                    font-weight: 800;
                }
                .calc-inr-equiv {
                    font-size: 12px;
                    color: #059669;
                    font-weight: 600;
                    text-align: right;
                    margin-top: 2px;
                }

                .security-guarantee-box {
                    display: flex;
                    justify-content: space-between;
                    font-size: 11.5px;
                    color: #64748B;
                    padding: 10px;
                }

                /* Interactive Column */
                .payment-interactive-col {
                    padding: 30px;
                    background: #FFFFFF;
                }
                [data-theme="dark"] .payment-interactive-col {
                    background: #101820;
                }
                .payment-tabs-header {
                    display: flex;
                    gap: 10px;
                    border-bottom: 2px solid #E2E8F0;
                    padding-bottom: 14px;
                    margin-bottom: 24px;
                }
                [data-theme="dark"] .payment-tabs-header {
                    border-color: #22303A;
                }
                .tab-btn {
                    background: none;
                    border: none;
                    font-size: 13.5px;
                    font-weight: 600;
                    color: #64748B;
                    padding: 8px 14px;
                    border-radius: 10px;
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    cursor: pointer;
                    transition: all 0.2s;
                }
                .tab-btn:hover {
                    color: #FC8019;
                    background: #FFF7ED;
                }
                [data-theme="dark"] .tab-btn:hover {
                    background: #1A2530;
                }
                .tab-btn.active {
                    color: #FC8019;
                    background: #FFF7ED;
                }
                [data-theme="dark"] .tab-btn.active {
                    background: #1A2530;
                }
                .tab-badge {
                    background: #DCFCE7;
                    color: #16A34A;
                    font-size: 10px;
                    font-weight: 700;
                    padding: 2px 8px;
                    border-radius: 50px;
                }

                /* QR Zone */
                .qr-scan-zone {
                    display: flex;
                    gap: 28px;
                    align-items: center;
                }
                @media (max-width: 768px) {
                    .qr-scan-zone { flex-direction: column; text-align: center; }
                }
                .qr-box-wrapper {
                    position: relative;
                    width: 220px;
                    height: 220px;
                    padding: 12px;
                    background: #FFFFFF;
                    border-radius: 20px;
                    box-shadow: 0 8px 30px rgba(0, 0, 0, 0.08);
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    border: 1px solid #E2E8F0;
                    flex-shrink: 0;
                }
                .qr-image-tag {
                    width: 100%;
                    height: 100%;
                    border-radius: 12px;
                    display: block;
                }
                .qr-corner {
                    position: absolute;
                    width: 16px;
                    height: 16px;
                    border: 3px solid #FC8019;
                }
                .qr-corner.top-left { top: 6px; left: 6px; border-right: none; border-bottom: none; border-top-left-radius: 8px; }
                .qr-corner.top-right { top: 6px; right: 6px; border-left: none; border-bottom: none; border-top-right-radius: 8px; }
                .qr-corner.bottom-left { bottom: 6px; left: 6px; border-right: none; border-top: none; border-bottom-left-radius: 8px; }
                .qr-corner.bottom-right { bottom: 6px; right: 6px; border-left: none; border-top: none; border-bottom-right-radius: 8px; }
                
                .qr-scan-line {
                    position: absolute;
                    left: 12px;
                    right: 12px;
                    height: 2px;
                    background: linear-gradient(90deg, transparent, #FC8019, transparent);
                    animation: scanAnim 2.2s ease-in-out infinite;
                    pointer-events: none;
                }
                @keyframes scanAnim {
                    0% { top: 12px; opacity: 0; }
                    50% { opacity: 1; }
                    100% { top: 200px; opacity: 0; }
                }

                .qr-spinner-overlay {
                    position: absolute;
                    inset: 0;
                    background: rgba(255, 255, 255, 0.9);
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                    border-radius: 20px;
                }

                .qr-instructions h6 {
                    font-size: 15px;
                    font-weight: 700;
                    color: #1E293B;
                    margin-bottom: 6px;
                }
                [data-theme="dark"] .qr-instructions h6 { color: #F8FAFC; }
                .qr-instructions p {
                    font-size: 13px;
                    color: #64748B;
                    line-height: 1.4;
                    margin-bottom: 12px;
                }
                .mobile-direct-link-box {
                    background: #F8FAFC;
                    border: 1px solid #E2E8F0;
                    border-radius: 10px;
                    padding: 8px 12px;
                    font-size: 12px;
                    display: flex;
                    align-items: center;
                    gap: 8px;
                }
                [data-theme="dark"] .mobile-direct-link-box {
                    background: #151F28;
                    border-color: #22303A;
                }
                .mobile-link-text {
                    color: #FC8019;
                    font-weight: 600;
                    text-decoration: underline;
                    flex: 1;
                    overflow: hidden;
                    text-overflow: ellipsis;
                    white-space: nowrap;
                }
                .btn-copy-url {
                    background: none;
                    border: none;
                    color: #64748B;
                    cursor: pointer;
                    padding: 4px;
                }
                .btn-demo-pay {
                    background: #FEF3C7;
                    border: 1px solid #FCD34D;
                    color: #B45309;
                    font-size: 13px;
                    font-weight: 700;
                    padding: 10px 18px;
                    border-radius: 12px;
                    width: 100%;
                    cursor: pointer;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    gap: 8px;
                    transition: all 0.2s;
                }
                .btn-demo-pay:hover {
                    background: #FDE68A;
                }

                .live-listener-status {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    font-size: 12px;
                    color: #059669;
                    font-weight: 600;
                    margin-top: 14px;
                }
                .radar-pulse {
                    width: 10px;
                    height: 10px;
                    border-radius: 50%;
                    background: #10B981;
                    box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7);
                    animation: pulseRing 1.6s infinite;
                }
                @keyframes pulseRing {
                    0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
                    70% { transform: scale(1); box-shadow: 0 0 0 8px rgba(16, 185, 129, 0); }
                    100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
                }

                /* Interactive Card UI */
                .interactive-card-mock {
                    background: linear-gradient(135deg, #1E293B 0%, #0F172A 100%);
                    color: #FFFFFF;
                    border-radius: 16px;
                    padding: 22px;
                    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
                    margin-bottom: 18px;
                }
                .card-chip {
                    width: 38px;
                    height: 28px;
                    border-radius: 6px;
                    background: linear-gradient(135deg, #FCD34D, #D97706);
                    margin-bottom: 20px;
                }
                .card-number-display {
                    font-family: 'JetBrains Mono', monospace;
                    font-size: 18px;
                    letter-spacing: 3px;
                    margin-bottom: 20px;
                }
                .card-meta-row {
                    display: flex;
                    justify-content: space-between;
                }
                .card-meta-label {
                    font-size: 9px;
                    color: #94A3B8;
                    letter-spacing: 0.8px;
                }
                .card-meta-val {
                    font-size: 13px;
                    font-weight: 700;
                    letter-spacing: 0.5px;
                }
                .btn-pay-action {
                    width: 100%;
                    background: linear-gradient(135deg, #FC8019 0%, #E06C11 100%);
                    color: #FFFFFF;
                    border: none;
                    padding: 14px;
                    border-radius: 14px;
                    font-size: 15px;
                    font-weight: 700;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    gap: 8px;
                    cursor: pointer;
                    box-shadow: 0 8px 24px rgba(252, 128, 25, 0.35);
                }

                /* NetBanking Grid */
                .bank-grid {
                    display: grid;
                    grid-template-columns: repeat(2, 1fr);
                    gap: 12px;
                }
                .bank-card {
                    display: flex;
                    align-items: center;
                    gap: 10px;
                    padding: 12px 14px;
                    border: 1.5px solid #E2E8F0;
                    border-radius: 12px;
                    cursor: pointer;
                    font-size: 13px;
                    font-weight: 600;
                    color: #334155;
                    transition: all 0.2s;
                }
                [data-theme="dark"] .bank-card {
                    border-color: #22303A;
                    color: #F8FAFC;
                }
                .bank-card.active {
                    border-color: #FC8019;
                    background: #FFF7ED;
                }
                [data-theme="dark"] .bank-card.active {
                    background: #1A2530;
                }
                .bank-icon-circle {
                    width: 32px;
                    height: 32px;
                    border-radius: 50%;
                    background: #EFF6FF;
                    color: #2563EB;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }

                /* Success Overlay */
                .payment-success-overlay {
                    position: absolute;
                    inset: 0;
                    background: #FFFFFF;
                    display: none;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                    padding: 40px;
                    z-index: 1050;
                    animation: fadeIn 0.3s ease;
                }
                [data-theme="dark"] .payment-success-overlay {
                    background: #101820;
                }
                @keyframes fadeIn {
                    from { opacity: 0; transform: scale(0.98); }
                    to { opacity: 1; transform: scale(1); }
                }
                .success-celebration-box {
                    max-width: 520px;
                    width: 100%;
                    text-align: center;
                }
                .success-icon-anim {
                    font-size: 72px;
                    color: #10B981;
                    margin-bottom: 12px;
                    animation: popScale 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
                }
                @keyframes popScale {
                    0% { transform: scale(0); }
                    100% { transform: scale(1); }
                }
                .success-heading {
                    font-size: 24px;
                    font-weight: 800;
                    color: #0F172A;
                    margin-bottom: 8px;
                }
                [data-theme="dark"] .success-heading { color: #F8FAFC; }
                .success-subheading {
                    font-size: 14px;
                    color: #64748B;
                    line-height: 1.5;
                    margin-bottom: 24px;
                }
                .success-receipt-card {
                    background: #F8FAFC;
                    border: 1px solid #E2E8F0;
                    border-radius: 16px;
                    padding: 18px 24px;
                    margin-bottom: 28px;
                    text-align: left;
                }
                [data-theme="dark"] .success-receipt-card {
                    background: #151F28;
                    border-color: #22303A;
                }
                .receipt-row {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    padding: 8px 0;
                    font-size: 13.5px;
                }
                .receipt-row:not(:last-child) {
                    border-bottom: 1px dashed #E2E8F0;
                }
                [data-theme="dark"] .receipt-row:not(:last-child) {
                    border-bottom-color: #22303A;
                }
                .r-label { color: #64748B; font-weight: 500; }
                .r-val { color: #1E293B; font-weight: 700; font-family: 'JetBrains Mono', monospace; }
                [data-theme="dark"] .r-val { color: #F8FAFC; }

                .success-nav-actions {
                    display: flex;
                    flex-direction: column;
                    gap: 10px;
                }
                .btn-success-action {
                    padding: 13px 20px;
                    border-radius: 12px;
                    font-weight: 700;
                    font-size: 14px;
                    text-decoration: none;
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    gap: 8px;
                    transition: all 0.2s;
                }
                .btn-success-action.primary {
                    background: linear-gradient(135deg, #FC8019 0%, #E06C11 100%);
                    color: #FFFFFF;
                    box-shadow: 0 8px 20px rgba(252, 128, 25, 0.3);
                }
                .btn-success-action.secondary {
                    background: #F1F5F9;
                    color: #334155;
                    border: 1px solid #E2E8F0;
                }
                [data-theme="dark"] .btn-success-action.secondary {
                    background: #1A2530;
                    color: #F8FAFC;
                    border-color: #2D3F4D;
                }
            </style>

            <!-- Script for Mock Payment Gateway & Cross-Device Polling -->
            <script>
                var activeTxnId = null;
                var pollInterval = null;
                var paymentModalInstance = null;

                function launchPaymentGateway() {
                    var modalEl = document.getElementById('nlogisticPaymentModal');
                    if (!modalEl) return;

                    if (!paymentModalInstance) {
                        paymentModalInstance = new bootstrap.Modal(modalEl);
                    }
                    paymentModalInstance.show();

                    // Reset state
                    document.getElementById('paymentSuccessOverlay').style.display = 'none';
                    document.getElementById('qrLoadingSpinner').style.display = 'flex';
                    document.getElementById('gwQrImage').src = '';
                    document.getElementById('displayTxnRef').innerText = 'Order Ref: Initializing...';

                    // Collect booking form parameters
                    var form = document.getElementById('bookingDataForm');
                    var formData = new FormData(form);
                    var params = new URLSearchParams();
                    formData.forEach(function(val, key) { params.append(key, val); });

                    // Initiate payment transaction
                    fetch('${pageContext.request.contextPath}/payment/initiate', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: params.toString()
                    })
                    .then(function(res) { return res.json(); })
                    .then(function(data) {
                        if (data.success) {
                            activeTxnId = data.txnId;
                            document.getElementById('displayTxnRef').innerText = 'Order Ref: ' + activeTxnId;
                            
                            // Load QR code image
                            var qrImg = document.getElementById('gwQrImage');
                            qrImg.onload = function() {
                                document.getElementById('qrLoadingSpinner').style.display = 'none';
                            };
                            qrImg.src = data.qrUrl;

                            // Set direct mobile link
                            var mLink = document.getElementById('gwMobileDirectLink');
                            mLink.href = data.mobilePayUrl;

                            // Start polling for cross-device approval
                            startPollingPaymentStatus();
                        } else {
                            alert('Could not initialize gateway: ' + (data.error || 'Server error'));
                        }
                    })
                    .catch(function(err) {
                        console.error(err);
                        alert('Network error initializing payment gateway: ' + err);
                    });
                }

                function closePaymentGateway() {
                    stopPollingPaymentStatus();
                    if (paymentModalInstance) {
                        paymentModalInstance.hide();
                    }
                }

                function switchPayTab(tabName) {
                    document.querySelectorAll('.payment-tabs-header .tab-btn').forEach(function(b) { b.classList.remove('active'); });
                    document.querySelectorAll('.tab-pane-content').forEach(function(p) { p.classList.add('d-none'); });

                    if (tabName === 'upi') {
                        document.querySelectorAll('.payment-tabs-header .tab-btn')[0].classList.add('active');
                        document.getElementById('tabPaneUpi').classList.remove('d-none');
                    } else if (tabName === 'card') {
                        document.querySelectorAll('.payment-tabs-header .tab-btn')[1].classList.add('active');
                        document.getElementById('tabPaneCard').classList.remove('d-none');
                    } else if (tabName === 'netbank') {
                        document.querySelectorAll('.payment-tabs-header .tab-btn')[2].classList.add('active');
                        document.getElementById('tabPaneNetbank').classList.remove('d-none');
                    }
                }

                function selectBank(el, bank) {
                    document.querySelectorAll('.bank-card').forEach(function(c) { c.classList.remove('active'); });
                    el.classList.add('active');
                }

                function updateMockCardNum(val) {
                    document.getElementById('mockCardNum').innerText = val || '•••• •••• •••• 4242';
                }

                function updateMockCardExp(val) {
                    document.getElementById('mockCardExp').innerText = val || '12/28';
                }

                function copyMobileUrl() {
                    var mLink = document.getElementById('gwMobileDirectLink');
                    if (mLink && mLink.href) {
                        navigator.clipboard.writeText(mLink.href).then(function() {
                            alert('Mobile payment URL copied! You can paste it into your phone browser or test tab.');
                        });
                    }
                }

                function startPollingPaymentStatus() {
                    stopPollingPaymentStatus();
                    pollInterval = setInterval(function() {
                        if (!activeTxnId) return;

                        fetch('${pageContext.request.contextPath}/payment/status?txn=' + encodeURIComponent(activeTxnId))
                        .then(function(res) { return res.json(); })
                        .then(function(data) {
                            if (data.status === 'SUCCESS') {
                                stopPollingPaymentStatus();
                                onPaymentSuccess(data);
                            }
                        })
                        .catch(function(e) {
                            console.log('Poll poll error:', e);
                        });
                    }, 1500);
                }

                function stopPollingPaymentStatus() {
                    if (pollInterval) {
                        clearInterval(pollInterval);
                        pollInterval = null;
                    }
                }

                function triggerMockPayment(methodName) {
                    if (!activeTxnId) {
                        alert('No active transaction initialized.');
                        return;
                    }

                    var params = new URLSearchParams();
                    params.append('txn', activeTxnId);
                    params.append('paymentMethod', methodName || 'UPI_QR');

                    fetch('${pageContext.request.contextPath}/payment/pay-mock', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: params.toString()
                    })
                    .then(function(res) { return res.json(); })
                    .then(function(data) {
                        if (data.success) {
                            stopPollingPaymentStatus();
                            onPaymentSuccess(data, methodName);
                        } else {
                            alert('Payment processing failed: ' + (data.error || 'Unknown error'));
                        }
                    })
                    .catch(function(err) {
                        alert('Error submitting payment: ' + err);
                    });
                }

                function onPaymentSuccess(data, method) {
                    var overlay = document.getElementById('paymentSuccessOverlay');
                    if (overlay) {
                        document.getElementById('resShipmentTag').innerText = '#SHP-' + (data.shipmentId || 'CONFIRMED');
                        document.getElementById('resInvoiceTag').innerText = 'INV-' + (data.invoiceId || 'PAID') + ' (PAID)';
                        document.getElementById('resMethodTag').innerText = method || data.method || 'UPI / QR Code';

                        // Set tracking direct button link
                        var trackBtn = document.getElementById('btnNavLiveTracking');
                        if (trackBtn && data.shipmentId) {
                            trackBtn.href = '${pageContext.request.contextPath}/shipments/tracking/detail?id=SHP-' + data.shipmentId;
                        }

                        overlay.style.display = 'flex';
                    }
                }
            </script>
        </c:when>
        <c:otherwise>

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
        <div class="d-flex align-items-center gap-2 flex-wrap">
            <%-- FR3.5 / SRS 5.5: recalibrate demand multipliers from the forecast --%>
            <c:if test="${sessionScope.user.roleId <= 2}">
                <form method="POST" action="${pageContext.request.contextPath}/pricing/syncDemand" class="m-0">
                    <button type="submit" class="btn-adjust-rate"
                            title="Recompute every demand multiplier from the latest demand forecast">
                        <i class="ti ti-refresh"></i> Recalibrate Demand Multipliers
                    </button>
                </form>
            </c:if>
            <a href="${pageContext.request.contextPath}/predictive-graph" class="btn-predictive-nav">
                <i class="ti ti-chart-line"></i> Advance Predictive Graph
            </a>
        </div>
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
                <div class="kpi-value kpi-val-green">
                    $<fmt:formatNumber value="${kpiAvgFinalPrice}" pattern="#,##0.00"/>
                </div>
                <div class="kpi-subtext">All active routes &amp; profiles</div>
            </div>
            <div class="kpi-icon-pill green"><i class="ti ti-currency-dollar"></i></div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Highest Base Tariff</div>
                <div class="kpi-value kpi-val-amber">
                    $<fmt:formatNumber value="${kpiMaxBasePrice}" pattern="#,##0.00"/>
                </div>
                <div class="kpi-subtext">Peak tier standard rate</div>
            </div>
            <div class="kpi-icon-pill amber"><i class="ti ti-trending-up"></i></div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Total Audit Adjustments</div>
                <div class="kpi-value kpi-val-blue">${kpiTotalAudit}</div>
                <div class="kpi-subtext">Historical FR3.7 log events</div>
            </div>
            <div class="kpi-icon-pill blue"><i class="ti ti-history"></i></div>
        </div>
    </div>

    <!-- TABLE 1: Active Freight Pricing Rules -->
    <div class="governance-panel card tracking-card no-card-tools" data-no-tools="true" style="padding: 0; overflow: hidden; border-radius: 16px;">
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

        <div class="table-responsive tracking-table-responsive">
            <table class="governance-table tracking-table" id="rulesTable">
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
    <div class="governance-panel card tracking-card no-card-tools" data-no-tools="true" style="padding: 0; overflow: hidden; border-radius: 16px;">
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

        <div class="table-responsive tracking-table-responsive">
            <table class="governance-table tracking-table" id="auditTable">
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


        </c:otherwise>
    </c:choose>
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
        if (!document.getElementById('rulesTable')) return;
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
