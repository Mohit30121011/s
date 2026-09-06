<%@ page language="java" contentType="text/html; charset=UTF-8" session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    :root {
        --text-dark: #1E293B;
        --text-muted: #64748B;
        --border-color: #E2E8F0;
        --brand-orange: #FC8019;
        --brand-orange-light: rgba(252, 128, 25, 0.12);
    }
    [data-theme="dark"] {
        --text-dark: #F8FAFC !important;
        --text-muted: #94A3B8 !important;
        --border-color: #22303A !important;
    }

    /* Page Header */
    .page-header-flex {
        display: flex;
        justify-content: space-between;
        align-items: flex-end;
        margin-bottom: 24px;
    }
    .btn-back-fleet {
        border: 1.5px solid #E2E8F0;
        font-weight: 600;
        font-size: 13px;
        border-radius: 50px !important;
        background: #FFFFFF;
        color: #374151;
        padding: 9px 20px;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        text-decoration: none;
        transition: all 0.2s ease;
    }
    .btn-back-fleet:hover {
        background: #F8FAFC;
        border-color: #FC8019;
        color: #FC8019;
    }

    /* Card Panels */
    .card-panel {
        background: #FFFFFF;
        border-radius: 16px;
        border: 1px solid var(--border-color);
        box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
        padding: 24px;
        margin-bottom: 24px;
        transition: background 0.2s ease, border-color 0.2s ease;
    }
    /* Completely remove top-right fullscreen & download buttons from cards */
    .card-panel .nl-card-tools,
    .nl-card-tools,
    .nl-card-tool {
        display: none !important;
        visibility: hidden !important;
        opacity: 0 !important;
        pointer-events: none !important;
    }

    /* Summary Grid */
    .summary-grid {
        display: grid;
        grid-template-columns: repeat(5, 1fr);
        gap: 24px;
        margin-top: 20px;
    }
    @media (max-width: 992px) {
        .summary-grid { grid-template-columns: repeat(2, 1fr); }
    }
    .summary-item { font-size: 13px; }
    .summary-label {
        color: var(--text-muted);
        margin-bottom: 6px;
        display: block;
        font-size: 11.5px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    .summary-value {
        font-weight: 600;
        color: var(--text-dark);
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 14px;
    }

    /* Status Pills */
    .status-badge-lg {
        padding: 7px 18px;
        border-radius: 50px;
        font-weight: 600;
        font-size: 13px;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        letter-spacing: 0.2px;
    }
    .badge-booked { background: #F1F5F9; color: #475569; border: 1px solid #CBD5E1; }
    .badge-allocated { background: #F0FDF4; color: #16A34A; border: 1px solid #BBF7D0; }
    .badge-departed { background: #F5F3FF; color: #7C3AED; border: 1px solid #DDD6FE; }
    .badge-intransit { background: #EFF6FF; color: #2563EB; border: 1px solid #BFDBFE; }
    .badge-customs { background: #FFF7ED; color: #EA580C; border: 1px solid #FED7AA; }
    .badge-arrived { background: #F0FDFA; color: #0D9488; border: 1px solid #99F6E4; }
    .badge-delivered { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }
    .badge-delayed { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }

    /* Timeline Stepper */
    .timeline-container { padding: 24px 16px 16px 16px; }
    .stepper-wrapper {
        display: flex;
        justify-content: space-between;
        position: relative;
        width: 100%;
        margin: 0 auto;
    }
    .stepper-item {
        position: relative;
        display: flex;
        flex-direction: column;
        align-items: center;
        flex: 1;
    }
    .stepper-item::before {
        content: '';
        position: absolute;
        top: 21px;
        left: -50%;
        width: 100%;
        height: 3px;
        background: #E5E7EB;
        z-index: 0;
    }
    .stepper-item:first-child::before { display: none; }
    .stepper-item.completed::before,
    .stepper-item.active-orange::before {
        background: #10B981 !important;
    }

    .step-circle {
        width: 42px;
        height: 42px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #FFFFFF;
        position: relative;
        z-index: 1;
        border: 2px solid #E5E7EB;
        color: #9CA3AF;
        font-size: 16px;
        margin-bottom: 14px;
        transition: all 0.2s ease;
    }
    .stepper-item.completed .step-circle {
        background: #10B981;
        border-color: #10B981;
        color: #FFFFFF;
    }
    .stepper-item.active-orange .step-circle {
        width: 58px;
        height: 58px;
        border: 2px solid #FFEBE0;
        background: #FFFFFF;
        color: #FC8019;
        font-size: 22px;
        transform: translateY(-8px);
        box-shadow: 0 0 0 4px #FFF8F5;
    }
    .stepper-item.active-orange .step-circle-inner {
        width: 44px;
        height: 44px;
        border-radius: 50%;
        border: 2px solid #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .step-text { text-align: center; font-size: 12px; }
    .step-title {
        font-weight: 700;
        color: var(--text-dark);
        margin-bottom: 4px;
        font-size: 13px;
    }
    .step-date { color: var(--text-muted); font-size: 11.5px; }
    .stepper-item.active-orange .step-title { color: #FC8019; }

    /* Panels Grid */
    .panels-grid {
        display: grid;
        grid-template-columns: 1.8fr 1.2fr;
        gap: 24px;
        margin-bottom: 24px;
    }
    @media (max-width: 992px) {
        .panels-grid { grid-template-columns: 1fr; }
    }

    .panel-header {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 20px;
    }
    .panel-header-icon {
        width: 36px;
        height: 36px;
        border-radius: 10px;
        background: rgba(252, 128, 25, 0.12);
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 18px;
    }
    .panel-title {
        font-weight: 700;
        font-size: 16px;
        color: var(--text-dark);
        line-height: 1.2;
    }
    .panel-subtitle {
        font-size: 12px;
        color: var(--text-muted);
        margin-top: 2px;
    }

    /* Record Checkpoint Form Styles */
    .field-label {
        font-weight: 600;
        font-size: 13px;
        margin-bottom: 0;
        color: var(--text-dark);
        display: flex;
        align-items: center;
    }
    .current-status-tag {
        font-size: 12px;
        color: var(--text-muted);
        display: inline-flex;
        align-items: center;
        gap: 4px;
    }
    .current-status-tag strong {
        color: var(--text-dark);
        font-weight: 600;
    }
    .char-count-pill {
        font-size: 11px;
        font-weight: 600;
        color: var(--text-muted);
        background: #F1F5F9;
        padding: 2px 9px;
        border-radius: 12px;
        border: 1px solid #E2E8F0;
    }
    .checkpoint-select-wrap .ts-wrapper,
    .checkpoint-select-wrap .ts-control {
        border-radius: 12px !important;
        min-height: 44px !important;
        height: 44px !important;
        font-size: 13.5px !important;
    }
    .checkpoint-status-select {
        height: 44px;
        border-radius: 12px;
        padding: 0 16px;
        border: 1.5px solid #E2E8F0;
        font-size: 13.5px;
        background: #FFFFFF;
        color: var(--text-dark);
        outline: none;
    }
    .checkpoint-remarks-textarea {
        border-radius: 12px !important;
        font-size: 13px !important;
        resize: none !important;
        border: 1.5px solid #E2E8F0 !important;
        padding: 12px 16px !important;
        transition: border-color 0.2s ease, box-shadow 0.2s ease !important;
        height: 132px !important;
        min-height: 132px !important;
        max-height: 132px !important;
        box-sizing: border-box !important;
        background: #FFFFFF;
        color: var(--text-dark);
    }
    .checkpoint-remarks-textarea:focus {
        border-color: #FC8019 !important;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.15) !important;
    }

    /* Symmetric Solid State Transition Strip */
    .transition-pill-strip {
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        padding: 0 14px;
        height: 44px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 8px;
        box-sizing: border-box;
    }
    .transition-pill-item {
        display: flex;
        align-items: center;
        gap: 8px;
        flex: 1;
        min-width: 0;
    }
    .transition-pill-item.curr {
        justify-content: flex-start;
    }
    .transition-pill-item.next {
        justify-content: flex-end;
    }
    .transition-pill-label {
        font-size: 10.5px;
        font-weight: 700;
        text-transform: uppercase;
        color: var(--text-muted);
        letter-spacing: 0.5px;
        white-space: nowrap;
    }
    .transition-pill-val {
        font-size: 12px !important;
        font-weight: 600 !important;
        padding: 4px 12px !important;
        border-radius: 50px !important;
        white-space: nowrap !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
        display: inline-block !important;
    }
    .transition-pill-item.curr .transition-pill-val {
        background: #E2E8F0 !important;
        color: #475569 !important;
    }
    .transition-pill-item.next .transition-pill-val {
        background: rgba(252, 128, 25, 0.14) !important;
        color: #FC8019 !important;
        border: 1px solid rgba(252, 128, 25, 0.35) !important;
        font-weight: 700 !important;
        padding: 5px 16px !important;
    }
    .transition-arrow-badge {
        width: 26px;
        height: 26px;
        border-radius: 50%;
        background: rgba(252, 128, 25, 0.12);
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 13px;
        flex-shrink: 0;
    }

    /* Checkpoint Form Footer Action Bar */
    .checkpoint-divider {
        margin: 20px 0 16px 0;
        border-top: 1px solid var(--border-color);
    }
    .checkpoint-form-footer {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 16px;
        flex-wrap: wrap;
    }
    .checkpoint-attribution-pill {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        font-size: 12.5px;
        color: var(--text-muted);
        padding: 8px 16px;
        background: #F8FAFC;
        border-radius: 50px;
        border: 1px solid #E2E8F0;
    }
    .checkpoint-attribution-pill strong {
        color: var(--text-dark);
        font-weight: 600;
    }

    /* Pill Shaped Action Button */
    .btn-record-checkpoint {
        background: #FC8019 !important;
        color: #FFFFFF !important;
        border: none !important;
        padding: 12px 32px !important;
        border-radius: 50px !important;
        font-weight: 600 !important;
        font-size: 14px !important;
        display: inline-flex !important;
        align-items: center !important;
        gap: 10px !important;
        box-shadow: 0 4px 14px rgba(252, 128, 25, 0.35) !important;
        cursor: pointer !important;
        transition: all 0.2s ease !important;
        text-decoration: none !important;
    }
    .btn-record-checkpoint:hover {
        background: #EA580C !important;
        transform: translateY(-1px) !important;
        box-shadow: 0 6px 18px rgba(252, 128, 25, 0.45) !important;
    }

    /* Shipment Summary Card */
    .summary-meta-list {
        display: flex;
        flex-direction: column;
    }
    .summary-meta-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 0;
        border-bottom: 1px solid var(--border-color);
        font-size: 13px;
    }
    .summary-meta-row.no-border { border-bottom: none; }
    .summary-meta-label {
        color: var(--text-muted);
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .summary-meta-value {
        font-weight: 600;
        color: var(--text-dark);
    }

    /* Checkpoint Audit Trail Table */
    .events-count-badge {
        background: #F1F5F9;
        color: #475569;
        font-weight: 600;
        padding: 6px 14px;
        border-radius: 50px;
        font-size: 12px;
        border: 1px solid #E2E8F0;
    }
    .audit-table th {
        font-weight: 600;
        color: var(--text-muted);
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        padding: 14px 16px;
        border-bottom: 1px solid var(--border-color);
        background: #F8FAFC;
    }
    .audit-table td {
        padding: 14px 16px;
        font-size: 13.5px;
        vertical-align: middle;
        border-bottom: 1px solid var(--border-color);
    }
    .status-icon-small {
        width: 24px;
        height: 24px;
        border-radius: 50%;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        background: #10B981;
        color: white;
        font-size: 11px;
        margin-right: 8px;
    }
    .user-tag {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        font-weight: 500;
    }
    .user-avatar.brand {
        width: 26px;
        height: 26px;
        border-radius: 50%;
        background: rgba(252, 128, 25, 0.15);
        color: #FC8019;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 11px;
        font-weight: 700;
    }

    /* ==========================================================================
       DARK MODE OVERRIDES (PREMIUM ENTERPRISE SPEC)
       ========================================================================== */
    [data-theme="dark"] .card-panel {
        background: #101820 !important;
        border-color: #22303A !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .btn-back-fleet {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .btn-back-fleet:hover {
        background: #1C2A37 !important;
        border-color: #FC8019 !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .panel-header-icon {
        background: rgba(252, 128, 25, 0.18) !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .panel-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .panel-subtitle {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .field-label {
        color: #F8FAFC !important;
    }

    /* Stepper in Dark Mode - Premium Elevated Milestones */
    [data-theme="dark"] .stepper-item::before {
        background: #253342 !important;
        height: 3px !important;
    }
    [data-theme="dark"] .stepper-item.completed::before {
        background: #10B981 !important;
        box-shadow: 0 0 10px rgba(16, 185, 129, 0.4) !important;
    }
    [data-theme="dark"] .stepper-item.active-orange::before {
        background: linear-gradient(90deg, #10B981 0%, #FC8019 100%) !important;
        box-shadow: 0 0 10px rgba(252, 128, 25, 0.4) !important;
    }

    /* Pending Step Circles in Dark Mode */
    [data-theme="dark"] .step-circle {
        background: #18232F !important;
        border: 2px solid #33475B !important;
        color: #94A3B8 !important;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3), inset 0 1px 0 rgba(255, 255, 255, 0.08) !important;
    }
    [data-theme="dark"] .step-circle i {
        color: #94A3B8 !important;
        font-size: 17px !important;
    }

    /* Completed Step Circles in Dark Mode */
    [data-theme="dark"] .stepper-item.completed .step-circle {
        background: linear-gradient(135deg, #10B981, #059669) !important;
        border: 2px solid #34D399 !important;
        color: #FFFFFF !important;
        box-shadow: 0 0 16px rgba(16, 185, 129, 0.45), inset 0 1px 0 rgba(255, 255, 255, 0.3) !important;
    }
    [data-theme="dark"] .stepper-item.completed .step-circle i {
        color: #FFFFFF !important;
        font-weight: 700 !important;
    }

    /* Active Orange Step Circle in Dark Mode - Sleek & Refined */
    [data-theme="dark"] .stepper-item.active-orange .step-circle {
        width: 52px !important;
        height: 52px !important;
        background: #151F28 !important;
        border: 2px solid #FC8019 !important;
        color: #FC8019 !important;
        transform: translateY(-5px) !important;
        box-shadow: 0 0 0 4px rgba(252, 128, 25, 0.14), 0 6px 16px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .stepper-item.active-orange .step-circle-inner {
        width: 38px !important;
        height: 38px !important;
        border: 1.5px solid rgba(252, 128, 25, 0.35) !important;
        background: rgba(252, 128, 25, 0.12) !important;
        box-shadow: none !important;
    }
    [data-theme="dark"] .stepper-item.active-orange .step-circle-inner i {
        color: #FC8019 !important;
        font-size: 18px !important;
        filter: none !important;
    }

    /* Step Typography in Dark Mode */
    [data-theme="dark"] .step-title {
        color: #CBD5E1 !important;
        font-weight: 600 !important;
        font-size: 13px !important;
    }
    [data-theme="dark"] .stepper-item.completed .step-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .stepper-item.active-orange .step-title {
        color: #FC8019 !important;
        font-weight: 700 !important;
        text-shadow: none !important;
    }
    [data-theme="dark"] .step-date {
        color: #94A3B8 !important;
        font-size: 12px !important;
        font-weight: 500 !important;
    }
    [data-theme="dark"] .stepper-item.completed .step-date {
        color: #34D399 !important;
        font-weight: 600 !important;
    }
    [data-theme="dark"] .stepper-item.active-orange .step-date {
        color: #FC8019 !important;
        font-weight: 600 !important;
    }

    /* Badges in Dark Mode */
    [data-theme="dark"] .badge-booked { background: #1E293B !important; color: #94A3B8 !important; border-color: #334155 !important; }
    [data-theme="dark"] .badge-allocated { background: rgba(22, 163, 74, 0.16) !important; color: #4ADE80 !important; border-color: rgba(22, 163, 74, 0.35) !important; }
    [data-theme="dark"] .badge-departed { background: rgba(124, 58, 237, 0.16) !important; color: #C084FC !important; border-color: rgba(124, 58, 237, 0.35) !important; }
    [data-theme="dark"] .badge-intransit { background: rgba(37, 99, 235, 0.16) !important; color: #60A5FA !important; border-color: rgba(37, 99, 235, 0.35) !important; }
    [data-theme="dark"] .badge-customs { background: rgba(234, 88, 12, 0.16) !important; color: #FB923C !important; border-color: rgba(234, 88, 12, 0.35) !important; }
    [data-theme="dark"] .badge-arrived { background: rgba(13, 148, 136, 0.16) !important; color: #2DD4BF !important; border-color: rgba(13, 148, 136, 0.35) !important; }
    [data-theme="dark"] .badge-delivered { background: rgba(16, 185, 129, 0.16) !important; color: #34D399 !important; border-color: rgba(16, 185, 129, 0.35) !important; }
    [data-theme="dark"] .badge-delayed { background: rgba(220, 38, 38, 0.16) !important; color: #F87171 !important; border-color: rgba(220, 38, 38, 0.35) !important; }

    /* Record Checkpoint Elements in Dark Mode */
    [data-theme="dark"] .checkpoint-status-select,
    [data-theme="dark"] .checkpoint-select-wrap .ts-control {
        background: #151F28 !important;
        border: 1.5px solid #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .checkpoint-select-wrap .ts-control .item {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .checkpoint-select-wrap .ts-dropdown {
        background: #151F28 !important;
        border: 1px solid #2D3F4D !important;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.5) !important;
    }
    [data-theme="dark"] .checkpoint-select-wrap .ts-dropdown .option {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .checkpoint-select-wrap .ts-dropdown .option:hover,
    [data-theme="dark"] .checkpoint-select-wrap .ts-dropdown .option.active {
        background: #1E2D3D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .checkpoint-select-wrap .ts-dropdown .option.selected {
        background: #FC8019 !important;
        color: #FFFFFF !important;
    }
    [data-theme="dark"] .checkpoint-remarks-textarea {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .checkpoint-remarks-textarea::placeholder {
        color: #64748B !important;
    }
    [data-theme="dark"] .transition-pill-strip {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
    }
    [data-theme="dark"] .transition-pill-item.curr .transition-pill-val {
        background: #1E293B !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .transition-pill-item.next .transition-pill-val {
        background: rgba(252, 128, 25, 0.18) !important;
        color: #FC8019 !important;
        border-color: rgba(252, 128, 25, 0.35) !important;
    }
    [data-theme="dark"] .current-status-tag strong {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .char-count-pill {
        background: #151F28 !important;
        color: #94A3B8 !important;
        border-color: #2D3F4D !important;
    }
    [data-theme="dark"] .checkpoint-attribution-pill {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .checkpoint-attribution-pill strong {
        color: #F8FAFC !important;
    }

    /* Summary Meta List in Dark Mode */
    [data-theme="dark"] .summary-meta-row {
        border-bottom-color: #1E293B !important;
    }
    [data-theme="dark"] .summary-meta-label {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .summary-meta-value {
        color: #F8FAFC !important;
    }

    /* Audit Table in Dark Mode */
    [data-theme="dark"] .events-count-badge {
        background: #151F28 !important;
        color: #94A3B8 !important;
        border-color: #2D3F4D !important;
    }
    [data-theme="dark"] .audit-table th {
        background: #151F28 !important;
        border-color: #22303A !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .audit-table td {
        border-bottom-color: #1A252E !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .audit-table tbody tr:hover {
        background-color: rgba(255, 255, 255, 0.03) !important;
    }
    [data-theme="dark"] .audit-table .status-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .audit-table .date-text {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .audit-table .staff-name {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .audit-table .remarks-text {
        color: #CBD5E1 !important;
    }

    /* Container Physical Asset & Traceability Barcode Cards */
    .container-asset-card, .barcode-tracking-card {
        background: #FFFFFF;
        border-radius: 16px;
        border: 1px solid var(--border-color);
        box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
        padding: 24px;
        transition: background 0.2s ease, border-color 0.2s ease;
    }
    [data-theme="dark"] .container-asset-card,
    [data-theme="dark"] .barcode-tracking-card {
        background: #16202A !important;
        border-color: #22303A !important;
    }
    .container-hero-wrapper {
        position: relative;
        border-radius: 12px;
        overflow: hidden;
        height: 200px;
        background: #0F172A;
        margin-bottom: 18px;
    }
    .container-hero-img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.4s ease;
    }
    .container-hero-wrapper:hover .container-hero-img {
        transform: scale(1.03);
    }
    .container-overlay-badge {
        padding: 6px 14px;
        border-radius: 50px;
        font-size: 11.5px;
        font-weight: 700;
        letter-spacing: 0.5px;
        backdrop-filter: blur(8px);
    }
    .container-spec-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 12px;
    }
    @media (max-width: 576px) {
        .container-spec-grid {
            grid-template-columns: repeat(2, 1fr);
        }
    }
    .container-spec-box {
        background: #F8FAFC;
        border: 1px solid var(--border-color);
        border-radius: 10px;
        padding: 10px 12px;
    }
    [data-theme="dark"] .container-spec-box {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
    }
    .container-spec-label {
        font-size: 11px;
        font-weight: 600;
        text-transform: uppercase;
        color: var(--text-muted);
        letter-spacing: 0.4px;
        margin-bottom: 3px;
        display: flex;
        align-items: center;
        gap: 4px;
    }
    .container-spec-val {
        font-size: 13px;
        font-weight: 700;
        color: var(--text-dark);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .barcode-display-box {
        background: #F8FAFC;
        border: 1.5px dashed #CBD5E1;
        border-radius: 12px;
        padding: 16px;
        text-align: center;
        margin-bottom: 16px;
    }
    [data-theme="dark"] .barcode-display-box {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
    }
    .barcode-pill {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        font-family: 'JetBrains Mono', 'Fira Code', monospace;
        font-weight: 700;
        font-size: 14.5px;
        padding: 7px 18px;
        border-radius: 50px;
        background: #FFFFFF;
        border: 1px solid #CBD5E1;
        color: var(--text-dark);
        letter-spacing: 0.5px;
    }
    [data-theme="dark"] .barcode-pill {
        background: #0F172A !important;
        border-color: #334155 !important;
    }
</style>

<div class="page-header-flex">
    <div>
        <h2 style="font-weight: 700; margin-bottom: 6px; color: var(--text-dark); font-size: 24px;">Live Shipment Tracking</h2>
        <div class="custom-breadcrumb d-flex align-items-center" style="margin-bottom: 0; font-size: 13px;">
            <a href="${pageContext.request.contextPath}/dashboard" style="color: var(--text-muted); text-decoration: none;">Dashboard</a>
            <i class="ti ti-chevron-right mx-2" style="font-size: 11px; color: var(--text-muted);"></i>
            <a href="${pageContext.request.contextPath}/shipments" style="color: var(--text-muted); text-decoration: none;">Shipments</a>
            <i class="ti ti-chevron-right mx-2" style="font-size: 11px; color: var(--text-muted);"></i>
            <a href="${pageContext.request.contextPath}/shipments/tracking" style="color: var(--text-muted); text-decoration: none;">Live Tracking</a>
            <i class="ti ti-chevron-right mx-2" style="font-size: 11px; color: var(--text-muted);"></i>
            <span style="color: var(--brand-orange); font-weight: 600;">#SHP-${shipment.shipmentId}</span>
        </div>
    </div>
    <a href="${pageContext.request.contextPath}/shipments/tracking" class="btn-back-fleet">
        <i class="ti ti-arrow-left"></i> Back to Tracking Fleet
    </a>
</div>

<!-- Success / Error Alert Banners -->
<c:if test="${not empty sessionScope.successMessage}">
    <div class="alert alert-success d-flex align-items-center mb-4" role="alert" style="border-radius: 12px; border-left: 5px solid #16a34a; background: rgba(22, 163, 74, 0.12); color: #15803d;">
        <i class="ti ti-circle-check me-2" style="font-size: 20px;"></i>
        <div style="font-weight: 500; font-size: 13.5px;">${sessionScope.successMessage}</div>
        <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    <c:remove var="successMessage" scope="session" />
</c:if>
<c:if test="${not empty sessionScope.errorMessage}">
    <div class="alert alert-danger d-flex align-items-center mb-4" role="alert" style="border-radius: 12px; border-left: 5px solid #dc2626; background: rgba(220, 38, 38, 0.12); color: #b91c1c;">
        <i class="ti ti-alert-circle me-2" style="font-size: 20px;"></i>
        <div style="font-weight: 500; font-size: 13.5px;">${sessionScope.errorMessage}</div>
        <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    <c:remove var="errorMessage" scope="session" />
</c:if>

<!-- Top Summary Card -->
<div class="card-panel no-card-tools" data-no-tools="true">
    <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-3" style="border-color: var(--border-color) !important;">
        <div class="d-flex align-items-center gap-3">
            <div style="width: 48px; height: 48px; background: rgba(252, 128, 25, 0.14); border-radius: 14px; display: flex; align-items: center; justify-content: center; color: #FC8019; font-size: 24px;">
                <i class="ti ti-package"></i>
            </div>
            <div>
                <h4 style="margin: 0; font-weight: 800; color: var(--text-dark); font-size: 20px;">Shipment #SHP-${shipment.shipmentId}</h4>
                <div style="font-size: 12.5px; color: var(--text-muted); margin-top: 2px;">Created on <fmt:formatDate value="${shipment.bookingDate}" pattern="MMM dd, yyyy" /></div>
            </div>
        </div>
        <div>
            <c:choose>
                <c:when test="${not empty shipment.delayDays && shipment.delayDays > 0}">
                    <span class="status-badge-lg badge-delayed">
                        <i class="ti ti-alert-triangle"></i> Delayed by ${shipment.delayDays} Days
                    </span>
                </c:when>
                <c:when test="${shipment.status == 'Booked'}">
                    <span class="status-badge-lg badge-booked">
                        <i class="ti ti-bookmark"></i> Booked
                    </span>
                </c:when>
                <c:when test="${shipment.status == 'Container Allocated'}">
                    <span class="status-badge-lg badge-allocated">
                        <i class="ti ti-box"></i> Container Allocated
                    </span>
                </c:when>
                <c:when test="${shipment.status == 'Departed'}">
                    <span class="status-badge-lg badge-departed">
                        <i class="ti ti-anchor"></i> Departed
                    </span>
                </c:when>
                <c:when test="${shipment.status == 'In Transit'}">
                    <span class="status-badge-lg badge-intransit">
                        <i class="ti ti-navigation"></i> In Transit &bull; On Schedule
                    </span>
                </c:when>
                <c:when test="${shipment.status == 'Customs Hold'}">
                    <span class="status-badge-lg badge-customs">
                        <i class="ti ti-shield"></i> Customs Hold
                    </span>
                </c:when>
                <c:when test="${shipment.status == 'Arrived'}">
                    <span class="status-badge-lg badge-arrived">
                        <i class="ti ti-building-warehouse"></i> Arrived
                    </span>
                </c:when>
                <c:when test="${shipment.status == 'Delivered'}">
                    <span class="status-badge-lg badge-delivered">
                        <i class="ti ti-circle-check"></i> Delivered
                    </span>
                </c:when>
                <c:otherwise>
                    <span class="status-badge-lg badge-booked">
                        ${shipment.status}
                    </span>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <div class="summary-grid">
        <div class="summary-item">
            <span class="summary-label">Customer</span>
            <span class="summary-value"><i class="ti ti-building" style="color: #64748B;"></i> ${shipment.customerName}</span>
        </div>
        <div class="summary-item">
            <span class="summary-label">Origin Port</span>
            <span class="summary-value"><i class="ti ti-map-pin" style="color: #FC8019;"></i> ${shipment.originPort}</span>
        </div>
        <div class="summary-item">
            <span class="summary-label">Destination Port</span>
            <span class="summary-value"><i class="ti ti-flag" style="color: #10B981;"></i> ${shipment.destPort}</span>
        </div>
        <div class="summary-item">
            <span class="summary-label">Assigned Vessel</span>
            <span class="summary-value"><i class="ti ti-ship" style="color: #64748B;"></i> ${not empty shipment.vesselName ? shipment.vesselName : 'Ocean Vessel'}</span>
        </div>
        <div class="summary-item">
            <span class="summary-label">Container ID</span>
            <span class="summary-value">
                <c:choose>
                    <c:when test="${shipment.status == 'Booked'}">
                        <span class="badge" style="background: rgba(245, 158, 11, 0.15); color: #D97706; border: 1px solid rgba(245, 158, 11, 0.35); font-size: 11.5px; padding: 4px 10px; border-radius: 6px; font-weight: 600;">
                            <i class="ti ti-clock me-1"></i> Pending Allocation by Operations
                        </span>
                    </c:when>
                    <c:otherwise>
                        <i class="ti ti-box" style="color: #FC8019;"></i> <strong style="font-family: monospace;">#${shipment.containerNumber}</strong>
                    </c:otherwise>
                </c:choose>
            </span>
            <div style="font-size: 11.5px; color: var(--text-muted); margin-top: 4px; display: flex; align-items: center; gap: 4px; flex-wrap: wrap;">
                <span style="color: var(--text-muted);">ETA:</span>
                <c:choose>
                    <c:when test="${not empty shipment.expectedArrivalDate}">
                        <strong style="color: var(--text-dark);"><fmt:formatDate value="${shipment.expectedArrivalDate}" pattern="MMM dd, yyyy" /></strong>
                    </c:when>
                    <c:when test="${not empty shipment.eta}">
                        <strong style="color: var(--text-dark);"><fmt:formatDate value="${shipment.eta}" pattern="MMM dd, yyyy" /></strong>
                    </c:when>
                    <c:otherwise>
                        <strong style="color: var(--text-dark);"><fmt:formatDate value="${shipment.bookingDate}" pattern="MMM dd, yyyy" /></strong>
                    </c:otherwise>
                </c:choose>
                <c:if test="${shipment.actualArrivalDate != null}">
                    <span style="color: #94A3B8;">&bull;</span>
                    <span style="color: #059669; font-weight: 600;">
                        <i class="ti ti-check"></i> Arr: <fmt:formatDate value="${shipment.actualArrivalDate}" pattern="MMM dd, yyyy" />
                    </span>
                </c:if>
            </div>
        </div>
    </div>
</div>

<!-- Timeline Tracker Card (SRS FR2.2 & FR2.4) -->
<div class="card-panel no-card-tools" data-no-tools="true">
    <div class="timeline-container">
        <c:set var="sIdx" value="1" />
        <c:choose>
            <c:when test="${shipment.status == 'Booked'}"><c:set var="sIdx" value="1" /></c:when>
            <c:when test="${shipment.status == 'Container Allocated'}"><c:set var="sIdx" value="2" /></c:when>
            <c:when test="${shipment.status == 'Departed'}"><c:set var="sIdx" value="3" /></c:when>
            <c:when test="${shipment.status == 'In Transit'}"><c:set var="sIdx" value="4" /></c:when>
            <c:when test="${shipment.status == 'Customs Hold'}"><c:set var="sIdx" value="5" /></c:when>
            <c:when test="${shipment.status == 'Arrived'}"><c:set var="sIdx" value="6" /></c:when>
            <c:when test="${shipment.status == 'Delivered'}"><c:set var="sIdx" value="7" /></c:when>
            <c:when test="${shipment.status == 'Delayed'}"><c:set var="sIdx" value="4" /></c:when>
        </c:choose>

        <div class="stepper-wrapper">
            <!-- Step 1: Booked -->
            <div class="stepper-item ${sIdx >= 1 ? 'completed' : ''} ${sIdx == 1 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 1}"><div class="step-circle-inner"></c:if>
                    <i class="ti ${sIdx > 1 ? 'ti-check' : 'ti-clipboard-text'}"></i>
                    <c:if test="${sIdx == 1}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title">Booked</div>
                    <div class="step-date"><fmt:formatDate value="${shipment.bookingDate}" pattern="MMM dd, yyyy" /></div>
                </div>
            </div>

            <!-- Step 2: Container Allocated -->
            <div class="stepper-item ${sIdx >= 2 ? 'completed' : ''} ${sIdx == 2 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 2}"><div class="step-circle-inner"></c:if>
                    <i class="ti ${sIdx > 2 ? 'ti-check' : 'ti-box'}"></i>
                    <c:if test="${sIdx == 2}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title">Container Allocated</div>
                    <div class="step-date">${sIdx >= 2 ? 'Allocated' : 'Pending Operations'}</div>
                </div>
            </div>

            <!-- Step 3: Departed -->
            <div class="stepper-item ${sIdx >= 3 ? 'completed' : ''} ${sIdx == 3 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 3}"><div class="step-circle-inner"></c:if>
                    <i class="ti ${sIdx > 3 ? 'ti-check' : 'ti-anchor'}"></i>
                    <c:if test="${sIdx == 3}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title">Departed</div>
                    <div class="step-date">${sIdx >= 3 ? 'Departed' : 'Pending'}</div>
                </div>
            </div>

            <!-- Step 4: In Transit -->
            <div class="stepper-item ${sIdx >= 4 ? 'completed' : ''} ${sIdx == 4 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 4}"><div class="step-circle-inner"></c:if>
                    <i class="ti ${sIdx > 4 ? 'ti-check' : 'ti-navigation'}"></i>
                    <c:if test="${sIdx == 4}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title">In Transit</div>
                    <div class="step-date">${sIdx >= 4 ? 'En Route' : 'Pending'}</div>
                </div>
            </div>

            <!-- Step 5: Customs Hold -->
            <div class="stepper-item ${sIdx >= 5 ? 'completed' : ''} ${sIdx == 5 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 5}"><div class="step-circle-inner"></c:if>
                    <i class="ti ${sIdx > 5 ? 'ti-check' : 'ti-shield'}"></i>
                    <c:if test="${sIdx == 5}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title">Customs Hold</div>
                    <div class="step-date">${sIdx == 5 ? 'Inspection' : (sIdx > 5 ? 'Cleared' : 'Optional')}</div>
                </div>
            </div>

            <!-- Step 6: Arrived -->
            <div class="stepper-item ${sIdx >= 6 ? 'completed' : ''} ${sIdx == 6 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 6}"><div class="step-circle-inner"></c:if>
                    <i class="ti ${sIdx > 6 ? 'ti-check' : 'ti-building-warehouse'}"></i>
                    <c:if test="${sIdx == 6}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title">Arrived</div>
                    <div class="step-date">${sIdx >= 6 ? 'At Port' : 'Expected'}</div>
                </div>
            </div>

            <!-- Step 7: Delivered -->
            <div class="stepper-item ${sIdx >= 7 ? 'completed' : ''} ${sIdx == 7 ? 'active-orange' : ''}">
                <div class="step-circle">
                    <c:if test="${sIdx == 7}"><div class="step-circle-inner"></c:if>
                    <i class="ti ${sIdx == 7 ? 'ti-circle-check' : 'ti-circle-check'}"></i>
                    <c:if test="${sIdx == 7}"></div></c:if>
                </div>
                <div class="step-text">
                    <div class="step-title">Delivered</div>
                    <div class="step-date">${sIdx == 7 ? 'Completed' : 'Final'}</div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Container Physical Asset & Live Traceability Barcode Section -->
<div class="row g-4 mb-4">
    <!-- Left: Container Physical Asset Card -->
    <div class="col-lg-7 col-md-12">
        <div class="container-asset-card h-100 no-card-tools" data-no-tools="true">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div class="d-flex align-items-center gap-2">
                    <div style="width: 36px; height: 36px; border-radius: 10px; background: rgba(252, 128, 25, 0.12); color: #FC8019; display: flex; align-items: center; justify-content: center; font-size: 18px;">
                        <i class="ti ti-container"></i>
                    </div>
                    <div>
                        <div style="font-weight: 700; font-size: 15px; color: var(--text-dark);">Physical Container Asset</div>
                        <div style="font-size: 11.5px; color: var(--text-muted);">Allocated hardware unit &amp; cargo payload specifications</div>
                    </div>
                </div>
                <c:choose>
                    <c:when test="${not empty shipment.containerNumber && shipment.status != 'Booked'}">
                        <span class="badge bg-success" style="font-size: 11.5px; padding: 6px 12px; border-radius: 50px;">
                            <i class="ti ti-circle-check me-1"></i> Allocated Unit
                        </span>
                    </c:when>
                    <c:otherwise>
                        <span class="badge bg-warning text-dark" style="font-size: 11.5px; padding: 6px 12px; border-radius: 50px;">
                            <i class="ti ti-clock-pause me-1"></i> Allocation Pending
                        </span>
                    </c:otherwise>
                </c:choose>
            </div>

            <c:choose>
                <%-- Allocated Container with Real Image & Specifications --%>
                <c:when test="${not empty shipment.containerNumber && shipment.status != 'Booked'}">
                    <div class="container-hero-wrapper">
                        <img src="${shipment.containerImage}" alt="Container ${shipment.containerNumber}" class="container-hero-img" onerror="this.src='https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=900&q=80'">
                        <div style="position: absolute; top: 12px; left: 12px; right: 12px; display: flex; justify-content: space-between; align-items: center; z-index: 2;">
                            <span class="container-overlay-badge" style="background: rgba(16, 185, 129, 0.9); color: #FFFFFF; box-shadow: 0 2px 8px rgba(16, 185, 129, 0.4);">
                                <i class="ti ti-circle-check me-1"></i> Physical Asset Assigned
                            </span>
                            <span class="container-overlay-badge" style="background: rgba(15, 23, 42, 0.85); color: #FFFFFF; border: 1px solid rgba(255,255,255,0.2);">
                                <i class="ti ti-box me-1"></i> ${shipment.containerSize} &bull; ${shipment.containerType}
                            </span>
                        </div>
                        <div style="position: absolute; bottom: 12px; left: 14px; right: 14px; display: flex; justify-content: space-between; align-items: flex-end; z-index: 2;">
                            <div style="background: rgba(0,0,0,0.7); backdrop-filter: blur(8px); padding: 6px 14px; border-radius: 8px; color: #FFFFFF;">
                                <div style="font-size: 10px; text-transform: uppercase; letter-spacing: 0.5px; opacity: 0.8;">ISO Container Identifier</div>
                                <div style="font-weight: 800; font-size: 16px; font-family: 'JetBrains Mono', monospace; letter-spacing: 1px;">
                                    ${shipment.containerNumber}
                                </div>
                            </div>
                            <div style="background: rgba(0,0,0,0.7); backdrop-filter: blur(8px); padding: 6px 12px; border-radius: 8px; color: #FFFFFF; font-size: 12px;">
                                <i class="ti ti-map-pin text-warning me-1"></i> ${shipment.originPort} &rarr; ${shipment.destPort}
                            </div>
                        </div>
                    </div>

                    <!-- Technical Specifications Grid -->
                    <div class="container-spec-grid">
                        <div class="container-spec-box">
                            <div class="container-spec-label"><i class="ti ti-hash"></i> Container Serial</div>
                            <div class="container-spec-val" style="font-family: 'JetBrains Mono', monospace;">${shipment.containerNumber}</div>
                        </div>
                        <div class="container-spec-box">
                            <div class="container-spec-label"><i class="ti ti-category"></i> Equipment Type</div>
                            <div class="container-spec-val">${shipment.containerSize} ${shipment.containerType}</div>
                        </div>
                        <div class="container-spec-box">
                            <div class="container-spec-label"><i class="ti ti-weight"></i> Tare Weight</div>
                            <div class="container-spec-val"><fmt:formatNumber value="${shipment.tareWeightKg}" maxFractionDigits="0"/> kg</div>
                        </div>
                        <div class="container-spec-box">
                            <div class="container-spec-label"><i class="ti ti-scale"></i> Max Payload</div>
                            <div class="container-spec-val"><fmt:formatNumber value="${shipment.goodsCapacityKg}" maxFractionDigits="0"/> kg</div>
                        </div>
                        <div class="container-spec-box">
                            <div class="container-spec-label"><i class="ti ti-box-model-2"></i> Cargo Weight</div>
                            <div class="container-spec-val" style="color: #FC8019;"><fmt:formatNumber value="${shipment.cargoWeight}" maxFractionDigits="0"/> kg</div>
                        </div>
                        <div class="container-spec-box">
                            <div class="container-spec-label"><i class="ti ti-file-description"></i> Manifest Cargo</div>
                            <div class="container-spec-val" title="${shipment.cargoDescription}">${empty shipment.cargoDescription ? 'Standard Freight' : shipment.cargoDescription}</div>
                        </div>
                    </div>
                </c:when>

                <%-- Pending Allocation State --%>
                <c:otherwise>
                    <div class="text-center p-4" style="background: linear-gradient(135deg, rgba(252, 128, 25, 0.04) 0%, rgba(59, 130, 246, 0.04) 100%); border: 1.5px dashed rgba(252, 128, 25, 0.35); border-radius: 12px; margin-bottom: 18px;">
                        <div style="width: 54px; height: 54px; border-radius: 50%; background: rgba(252, 128, 25, 0.12); color: #FC8019; display: flex; align-items: center; justify-content: center; font-size: 24px; margin: 0 auto 12px;">
                            <i class="ti ti-clock-pause"></i>
                        </div>
                        <h6 style="font-weight: 700; color: var(--text-dark); margin-bottom: 6px;">Container Allocation in Progress</h6>
                        <p style="font-size: 12.5px; color: var(--text-muted); max-width: 440px; margin: 0 auto 12px; line-height: 1.5;">
                            Booking confirmed. Terminal Operations at <strong>${shipment.originPort}</strong> will inspect and assign a physical <strong>${shipment.containerSize} ${shipment.containerType}</strong> unit prior to vessel loading.
                        </p>
                        <div class="d-inline-flex align-items-center gap-2 px-3 py-1 rounded-pill" style="background: #FFFFFF; border: 1px solid var(--border-color); font-size: 11.5px; font-weight: 600; color: #FC8019;">
                            <span class="spinner-grow spinner-grow-sm text-warning" role="status" style="width: 8px; height: 8px;"></span>
                            Stage: Booking Confirmed &bull; Yard Allocation Queued
                        </div>
                    </div>

                    <div class="container-spec-grid">
                        <div class="container-spec-box">
                            <div class="container-spec-label"><i class="ti ti-category"></i> Requested Size</div>
                            <div class="container-spec-val">${shipment.containerSize}</div>
                        </div>
                        <div class="container-spec-box">
                            <div class="container-spec-label"><i class="ti ti-box"></i> Requested Type</div>
                            <div class="container-spec-val">${shipment.containerType}</div>
                        </div>
                        <div class="container-spec-box">
                            <div class="container-spec-label"><i class="ti ti-anchor"></i> Allocation Port</div>
                            <div class="container-spec-val">${shipment.originPort}</div>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Right: Shipment Scannable Barcode & QR Card -->
    <div class="col-lg-5 col-md-12">
        <div class="barcode-tracking-card h-100 no-card-tools" data-no-tools="true">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div class="d-flex align-items-center gap-2">
                    <div style="width: 36px; height: 36px; border-radius: 10px; background: rgba(59, 130, 246, 0.12); color: #3B82F6; display: flex; align-items: center; justify-content: center; font-size: 18px;">
                        <i class="ti ti-qrcode"></i>
                    </div>
                    <div>
                        <div style="font-weight: 700; font-size: 15px; color: var(--text-dark);">Traceability Barcode</div>
                        <div style="font-size: 11.5px; color: var(--text-muted);">Scannable optical token for handheld terminals</div>
                    </div>
                </div>
                <span class="badge bg-primary" style="font-size: 11px; padding: 5px 10px; border-radius: 50px;">
                    <i class="ti ti-scan me-1"></i> Scannable
                </span>
            </div>

            <!-- Barcode and QR Visual Box -->
            <div class="barcode-display-box">
                <div class="d-flex justify-content-center align-items-center mb-3">
                    <div id="shipmentQrCanvas" style="width: 120px; height: 120px; background: #FFFFFF; padding: 6px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); display: flex; align-items: center; justify-content: center;"></div>
                </div>

                <div class="text-center mb-3" style="background: #FFFFFF; padding: 6px; border-radius: 8px; display: inline-block; max-width: 100%; box-shadow: 0 1px 4px rgba(0,0,0,0.05);">
                    <svg id="shipment1DBarcode" style="max-width: 100%; height: 42px;"></svg>
                </div>

                <div>
                    <div class="barcode-pill">
                        <i class="ti ti-barcode text-primary"></i>
                        <span>SHP-${shipment.shipmentId}</span>
                        <button type="button" class="btn btn-sm btn-link text-decoration-none p-0 ms-1" onclick="navigator.clipboard.writeText('SHP-${shipment.shipmentId}'); alert('Shipment ID copied: SHP-${shipment.shipmentId}');" title="Copy to clipboard">
                            <i class="ti ti-copy" style="font-size: 15px; color: #FC8019;"></i>
                        </button>
                    </div>
                </div>
            </div>

            <!-- Action buttons -->
            <div class="d-flex flex-column gap-2 mt-auto">
                <a href="${pageContext.request.contextPath}/scan-barcode?value=SHP-${shipment.shipmentId}" class="btn btn-outline-primary w-100" style="border-radius: 50px; font-weight: 600; font-size: 13px; padding: 9px 16px;">
                    <i class="ti ti-scan me-1"></i> Scan with Handheld Barcode Scanner
                </a>
                <button type="button" onclick="window.print()" class="btn btn-light w-100" style="border-radius: 50px; font-size: 12.5px; font-weight: 600; border: 1px solid var(--border-color); padding: 8px 16px;">
                    <i class="ti ti-printer me-1"></i> Print Waybill / Barcode Label
                </button>
            </div>
        </div>
    </div>
</div>

<div class="panels-grid">
    <%-- FR2.3: Operations and Admins (Super Admin Role 1, Company Admin Role 2, Ops Role 3) record checkpoints. --%>
    <c:if test="${sessionScope.user.roleId <= 3 || sessionScope.roleId <= 3 || sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2 || sessionScope.user.roleId == 3 || sessionScope.roleId == 1 || sessionScope.roleId == 2 || sessionScope.roleId == 3 || sessionScope.user.hasPermission('tracking')}">
    <!-- Live Form Panel: Record Next Checkpoint -->
    <div class="card-panel record-checkpoint-card no-card-tools" data-no-tools="true" style="margin-bottom: 0;">
        <div class="panel-header">
            <div class="panel-header-icon">
                <i class="ti ti-circle-plus"></i>
            </div>
            <div>
                <div class="panel-title">Record Next Checkpoint</div>
                <div class="panel-subtitle">Update milestone progression and live dispatch remarks</div>
            </div>
        </div>
        <form action="${pageContext.request.contextPath}/shipments/updateStatus" method="POST" id="checkpointForm">
            <input type="hidden" name="shipmentId" value="${shipment.shipmentId}">
            <input type="hidden" name="redirectUrl" value="${pageContext.request.contextPath}/shipments/tracking/detail?id=SHP-${shipment.shipmentId}">
            
            <div class="row g-3">
                <div class="col-md-6">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <label class="form-label field-label mb-0">
                            <i class="ti ti-flag-3 text-warning me-1"></i> Next Milestone <span style="color: #FC8019;">*</span>
                        </label>
                        <span class="current-status-tag">
                            <i class="ti ti-point-filled text-success"></i> Current: <strong>${shipment.status}</strong>
                        </span>
                    </div>
                    <c:choose>
                        <c:when test="${shipment.status == 'Delivered'}">
                            <%-- Final state: hide dropdown, show completion banner only --%>
                            <div class="d-flex align-items-center py-3 px-3 mt-1" style="border-radius: 12px; font-size: 13px; background: rgba(16,185,129,0.12); color: #059669; border: 1px solid rgba(16,185,129,0.3); font-weight: 600;">
                                <i class="ti ti-circle-check me-2" style="font-size: 18px;"></i>
                                <span>Shipment fully delivered &mdash; all milestones complete.</span>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="checkpoint-select-wrap">
                                <select name="status" id="checkpointStatusSelect" class="form-select form-select-custom checkpoint-status-select" required>
                                    <option value="" disabled <c:if test="${empty shipment.status}">selected</c:if>>Select milestone checkpoint</option>
                                    <option value="Container Allocated" <c:if test="${shipment.status == 'Booked'}">selected</c:if>>Container Allocated</option>
                                    <option value="Departed" <c:if test="${shipment.status == 'Container Allocated'}">selected</c:if>>Departed</option>
                                    <option value="In Transit" <c:if test="${shipment.status == 'Departed'}">selected</c:if>>In Transit</option>
                                    <option value="Customs Hold" <c:if test="${shipment.status == 'Customs Hold'}">selected</c:if>>Customs Hold</option>
                                    <option value="Delayed" <c:if test="${shipment.status == 'Delayed'}">selected</c:if>>Delayed</option>
                                    <option value="Arrived" <c:if test="${shipment.status == 'In Transit'}">selected</c:if>>Arrived</option>
                                    <option value="Delivered" <c:if test="${shipment.status == 'Arrived'}">selected</c:if>>Delivered</option>
                                </select>
                            </div>
                            <div class="transition-pill-strip mt-2">
                                <div class="transition-pill-item curr">
                                    <span class="transition-pill-label">Current</span>
                                    <span class="transition-pill-val">${shipment.status}</span>
                                </div>
                                <div class="transition-arrow-badge">
                                    <i class="ti ti-arrow-right"></i>
                                </div>
                                <div class="transition-pill-item next">
                                    <span class="transition-pill-label">Next</span>
                                    <span class="transition-pill-val" id="previewBadge">Select Next</span>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="col-md-6">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <label class="form-label field-label mb-0">
                            <i class="ti ti-notes text-warning me-1"></i> Remarks & Location <span style="color: #FC8019;">*</span>
                        </label>
                        <span id="charCount" class="char-count-pill">0 / 500</span>
                    </div>
                    <textarea name="remarks" id="statusRemarks" class="form-control checkpoint-remarks-textarea" maxlength="500" placeholder="e.g. Vessel cleared port terminal pier 4, cargo dispatched for customs check..." required></textarea>
                </div>
            </div>
            
            <div class="checkpoint-divider"></div>
            <div class="checkpoint-form-footer">
                <div class="checkpoint-attribution-pill">
                    <i class="ti ti-lock-check text-success" style="font-size: 16px;"></i>
                    <span style="font-size: 12px; font-weight: 500;">Verified &amp; Secured Entry</span>
                </div>
                <div class="checkpoint-actions">
                    <button type="submit" class="btn-record-checkpoint">
                        <i class="ti ti-circle-plus"></i>
                        <span>Record Checkpoint</span>
                        <i class="ti ti-arrow-right"></i>
                    </button>
                </div>
            </div>
        </form>
    </div>
    </c:if>

    <!-- Summary Panel (Real Database Data) -->
    <div class="card-panel shipment-summary-card no-card-tools" data-no-tools="true" style="margin-bottom: 0;">
        <div class="panel-header">
            <div class="panel-header-icon">
                <i class="ti ti-notes"></i>
            </div>
            <div>
                <div class="panel-title">Shipment Summary</div>
                <div class="panel-subtitle">Core routing specifications and vessel log</div>
            </div>
        </div>

        <div class="summary-meta-list">
            <div class="summary-meta-row">
                <div class="summary-meta-label"><i class="ti ti-calendar" style="color: #64748B;"></i> Booking Date</div>
                <div class="summary-meta-value"><fmt:formatDate value="${shipment.bookingDate}" pattern="MMM dd, yyyy" /></div>
            </div>
            <div class="summary-meta-row">
                <div class="summary-meta-label"><i class="ti ti-box" style="color: #64748B;"></i> Container ID</div>
                <div class="summary-meta-value">
                    <c:choose>
                        <c:when test="${shipment.status == 'Booked'}">
                            <span class="badge" style="background: rgba(245, 158, 11, 0.15); color: #D97706; border: 1px solid rgba(245, 158, 11, 0.35); font-size: 11px; padding: 4px 8px; border-radius: 6px; font-weight: 600;">
                                <i class="ti ti-clock me-1"></i> Pending Allocation
                            </span>
                        </c:when>
                        <c:otherwise>
                            <span style="font-family: monospace; font-weight: 700; color: var(--brand-orange);">#${shipment.containerNumber}</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="summary-meta-row">
                <div class="summary-meta-label"><i class="ti ti-ship" style="color: #64748B;"></i> Vessel</div>
                <div class="summary-meta-value">${not empty shipment.vesselName ? shipment.vesselName : 'Ocean Vessel'}</div>
            </div>
            <div class="summary-meta-row">
                <div class="summary-meta-label"><i class="ti ti-map-pin" style="color: #FC8019;"></i> Origin Port</div>
                <div class="summary-meta-value">${shipment.originPort}</div>
            </div>
            <div class="summary-meta-row no-border">
                <div class="summary-meta-label"><i class="ti ti-flag" style="color: #10B981;"></i> Destination Port</div>
                <div class="summary-meta-value">${shipment.destPort}</div>
            </div>
        </div>
    </div>
</div>

<%-- Internal audit trail: who recorded each checkpoint. Customers see
     their progress timeline above, not staff attribution. --%>
<c:if test="${sessionScope.user.roleId != 5}">
<!-- Audit Log (100% Real DB container_movements Data) -->
<div class="card-panel no-card-tools" data-no-tools="true">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div class="panel-header" style="margin-bottom: 0;">
            <div class="panel-header-icon">
                <i class="ti ti-history"></i>
            </div>
            <div>
                <div class="panel-title">Checkpoint Audit Trail</div>
                <div class="panel-subtitle">Chronological ledger of confirmed transit updates</div>
            </div>
        </div>
        <span class="events-count-badge">
            ${fn:length(logs)} events logged
        </span>
    </div>

    <div class="table-responsive">
        <table class="table audit-table" id="auditTable">
            <thead>
                <tr>
                    <th style="width: 22%;">Milestone Status</th>
                    <th style="width: 22%;">Recorded At</th>
                    <th style="width: 22%;">Attributed Staff</th>
                    <th style="width: 34%;">Checkpoint Remarks & Location</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="log" items="${logs}">
                    <tr class="audit-row">
                        <td>
                            <div class="d-flex align-items-center">
                                <div class="status-icon-small">
                                    <i class="ti ti-check"></i>
                                </div>
                                <span class="status-title" style="font-weight: 600; color: #1F2937;">${log.status}</span>
                            </div>
                        </td>
                        <td class="date-text" style="color: #64748B; font-weight: 500;">
                            <fmt:formatDate value="${log.updatedAt}" pattern="MMM dd, yyyy, hh:mm a" />
                        </td>
                        <td>
                            <div class="user-tag">
                                <div class="user-avatar brand">
                                    <c:choose>
                                        <c:when test="${not empty log.updatedBy}">
                                            ${fn:toUpperCase(fn:substring(log.updatedBy, 0, 2))}
                                        </c:when>
                                        <c:otherwise>OP</c:otherwise>
                                    </c:choose>
                                </div>
                                <span class="staff-name" style="font-weight: 600; color: #374151;">${not empty log.updatedBy ? log.updatedBy : 'System Operator'}</span>
                            </div>
                        </td>
                        <td class="remarks-text" style="color: #4B5563;">
                            ${not empty log.checkpointLocation ? log.checkpointLocation : 'Checkpoint reached and verified.'}
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty logs}">
                    <tr id="noAuditLogsRow">
                        <td colspan="4" style="text-align: center; color: var(--text-muted); padding: 36px;">
                            <i class="ti ti-info-circle mb-2" style="font-size: 26px; display: block; color: #FC8019;"></i>
                            No tracking checkpoints logged yet for this shipment. Record the first milestone above!
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <!-- Enterprise Pagination for Audit Trail -->
    <div class="nl-pagination-wrapper" id="auditPagination" style="margin-top: 18px;">
        <div class="nl-pagination-info">
            <span>Showing <strong id="auditPageStart">1</strong> to <strong id="auditPageEnd">5</strong> of <strong id="auditTotalRows">${fn:length(logs)}</strong> events</span>
            <div class="d-inline-flex align-items-center gap-2 ms-2">
                <span style="color: #94A3B8; font-size: 12.5px;">Rows per page:</span>
                <select id="auditPageSize" class="nl-page-size-select no-custom-select">
                    <option value="5" selected>5</option>
                    <option value="10">10</option>
                    <option value="25">25</option>
                </select>
            </div>
        </div>
        <div class="nl-pagination-nav" id="auditPageNav">
            <!-- Dynamically generated pagination buttons -->
        </div>
    </div>
</div>
</c:if>

<script>
document.addEventListener("DOMContentLoaded", function() {
    // 1. Textarea character counter
    const remarksInput = document.getElementById('statusRemarks');
    const charCount = document.getElementById('charCount');
    if (remarksInput && charCount) {
        remarksInput.addEventListener('input', function() {
            charCount.textContent = this.value.length + ' / 500';
        });
    }

    // 2. Next milestone transition preview
    const statusSelect = document.getElementById('checkpointStatusSelect');
    const previewBadge = document.getElementById('previewBadge');
    function updatePreview() {
        if (!statusSelect || !previewBadge) return;
        const selOption = statusSelect.options[statusSelect.selectedIndex];
        previewBadge.textContent = selOption && selOption.value ? selOption.text : 'Select Next';
    }
    if (statusSelect) {
        statusSelect.addEventListener('change', updatePreview);
        updatePreview();
    }

    // 3. Custom Enterprise Pagination for Audit Trail
    const auditRows = Array.from(document.querySelectorAll('.audit-row'));
    const auditPageSizeSelect = document.getElementById('auditPageSize');
    const auditPageNav = document.getElementById('auditPageNav');
    const auditPageStartEl = document.getElementById('auditPageStart');
    const auditPageEndEl = document.getElementById('auditPageEnd');
    const auditTotalRowsEl = document.getElementById('auditTotalRows');
    const auditPaginationWrapper = document.getElementById('auditPagination');

    let auditCurrentPage = 1;
    let auditPageSize = parseInt(auditPageSizeSelect ? auditPageSizeSelect.value : 5, 10);

    function updateAuditPagination() {
        const total = auditRows.length;
        if (total === 0) {
            if (auditPaginationWrapper) auditPaginationWrapper.style.display = 'none';
            return;
        } else {
            if (auditPaginationWrapper) auditPaginationWrapper.style.display = 'flex';
        }

        const totalPages = Math.ceil(total / auditPageSize) || 1;
        if (auditCurrentPage > totalPages) auditCurrentPage = totalPages;
        if (auditCurrentPage < 1) auditCurrentPage = 1;

        const startIndex = (auditCurrentPage - 1) * auditPageSize;
        const endIndex = Math.min(startIndex + auditPageSize, total);

        if (auditPageStartEl) auditPageStartEl.textContent = total === 0 ? '0' : (startIndex + 1);
        if (auditPageEndEl) auditPageEndEl.textContent = endIndex;
        if (auditTotalRowsEl) auditTotalRowsEl.textContent = total;

        auditRows.forEach((row, idx) => {
            row.style.display = (idx >= startIndex && idx < endIndex) ? '' : 'none';
        });

        renderAuditPageButtons(totalPages);
    }

    function renderAuditPageButtons(totalPages) {
        if (!auditPageNav) return;
        auditPageNav.innerHTML = '';

        if (totalPages <= 1 && auditRows.length <= auditPageSize) {
            return;
        }

        const prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'nl-page-btn nl-page-nav-btn' + (auditCurrentPage === 1 ? ' disabled' : '');
        prevBtn.innerHTML = '<i class="ti ti-chevron-left"></i> Prev';
        prevBtn.addEventListener('click', function(e) {
            e.preventDefault();
            if (auditCurrentPage > 1) {
                auditCurrentPage--;
                updateAuditPagination();
            }
        });
        auditPageNav.appendChild(prevBtn);

        for (let i = 1; i <= totalPages; i++) {
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'nl-page-btn nl-page-num' + (i === auditCurrentPage ? ' active' : '');
            btn.textContent = i;
            btn.addEventListener('click', function(e) {
                e.preventDefault();
                if (auditCurrentPage !== i) {
                    auditCurrentPage = i;
                    updateAuditPagination();
                }
            });
            auditPageNav.appendChild(btn);
        }

        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'nl-page-btn nl-page-nav-btn' + (auditCurrentPage === totalPages ? ' disabled' : '');
        nextBtn.innerHTML = 'Next <i class="ti ti-chevron-right"></i>';
        nextBtn.addEventListener('click', function(e) {
            e.preventDefault();
            if (auditCurrentPage < totalPages) {
                auditCurrentPage++;
                updateAuditPagination();
            }
        });
        auditPageNav.appendChild(nextBtn);
    }

    if (auditPageSizeSelect) {
        auditPageSizeSelect.addEventListener('change', function() {
            auditPageSize = parseInt(this.value, 10);
            auditCurrentPage = 1;
            updateAuditPagination();
        });
    }

    updateAuditPagination();
});
</script>

<!-- QR Code and JsBarcode libraries for Live Shipment Tracking -->
<script src="${pageContext.request.contextPath}/assets/js/qrcode.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/jsbarcode@3.11.0/dist/JsBarcode.all.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    const codeVal = 'SHP-${shipment.shipmentId}';
    
    // 1. Render QR Code
    const qrContainer = document.getElementById('shipmentQrCanvas');
    if (qrContainer) {
        if (typeof QRCode !== 'undefined') {
            try {
                new QRCode(qrContainer, {
                    text: codeVal,
                    width: 108,
                    height: 108,
                    colorDark: "#0F172A",
                    colorLight: "#FFFFFF",
                    correctLevel: (typeof QRCode.CorrectLevel !== 'undefined') ? QRCode.CorrectLevel.M : 0
                });
            } catch (err) {
                console.warn('QR Code init fallback:', err);
                qrContainer.innerHTML = '<img src="https://api.qrserver.com/v1/create-qr-code/?size=108x108&data=' + encodeURIComponent(codeVal) + '" alt="QR" style="width:108px;height:108px;border-radius:4px;"/>';
            }
        } else {
            qrContainer.innerHTML = '<img src="https://api.qrserver.com/v1/create-qr-code/?size=108x108&data=' + encodeURIComponent(codeVal) + '" alt="QR" style="width:108px;height:108px;border-radius:4px;"/>';
        }
    }
    
    // 2. Render 1D Barcode with JsBarcode
    const svg1D = document.getElementById('shipment1DBarcode');
    if (svg1D && typeof JsBarcode !== 'undefined') {
        try {
            JsBarcode(svg1D, codeVal, {
                format: "CODE128",
                lineColor: "#0F172A",
                width: 1.6,
                height: 38,
                displayValue: false,
                margin: 2
            });
        } catch (e) {
            console.warn('JsBarcode init error:', e);
        }
    }
});
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
