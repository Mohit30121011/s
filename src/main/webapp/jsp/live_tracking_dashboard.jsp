<%@ page language="java" contentType="text/html; charset=UTF-8" session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    .page-header-flex {
        display: flex;
        justify-content: space-between;
        align-items: flex-end;
        margin-bottom: 24px;
    }

    .card-panel {
        background: #FFFFFF;
        border-radius: 14px;
        border: 1px solid var(--nl-border);
        box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
        padding: 24px 28px;
        margin-bottom: 24px;
    }

    .no-card-tools .nl-card-tools,
    [data-no-tools="true"] .nl-card-tools,
    .stats-container ~ .nl-card-tools,
    .card-panel:has(.stats-container) .nl-card-tools {
        display: none !important;
    }

    /* Redesigned Premium Tracking KPI Strip */
    .tracking-kpi-strip {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
        align-items: center;
    }
    .tracking-kpi-chip {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 7px 14px 7px 9px;
        border-radius: 12px;
        background: #FFFFFF;
        border: 1.5px solid #E5E7EB;
        cursor: pointer;
        transition: all 0.22s cubic-bezier(0.16, 1, 0.3, 1);
        user-select: none;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
    }
    .tracking-kpi-chip:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
    }
    .kpi-chip-icon {
        width: 34px;
        height: 34px;
        border-radius: 9px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 17px;
        flex-shrink: 0;
        transition: transform 0.2s ease;
    }
    .tracking-kpi-chip:hover .kpi-chip-icon {
        transform: scale(1.1);
    }
    .kpi-chip-body {
        display: flex;
        flex-direction: column;
    }
    .kpi-chip-label {
        font-size: 10px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        color: #64748B;
        line-height: 1.1;
        margin-bottom: 2px;
        white-space: nowrap;
    }
    .kpi-chip-num {
        font-size: 18px;
        font-weight: 800;
        line-height: 1;
        letter-spacing: -0.4px;
    }

    /* Light Theme Semantic Variants */
    .tracking-kpi-chip.kpi-active {
        background: linear-gradient(135deg, #FFFFFF 0%, #FFF8F3 100%);
        border-color: rgba(252, 128, 25, 0.28);
    }
    .tracking-kpi-chip.kpi-active .kpi-chip-icon {
        background: rgba(252, 128, 25, 0.12);
        color: #FC8019;
    }
    .tracking-kpi-chip.kpi-active .kpi-chip-num {
        color: #FC8019;
    }
    .tracking-kpi-chip.kpi-active:hover,
    .tracking-kpi-chip.kpi-active.is-filtered {
        border-color: #FC8019;
        box-shadow: 0 4px 14px rgba(252, 128, 25, 0.22);
    }

    .tracking-kpi-chip.kpi-transit {
        background: linear-gradient(135deg, #FFFFFF 0%, #F0F6FF 100%);
        border-color: rgba(37, 99, 235, 0.25);
    }
    .tracking-kpi-chip.kpi-transit .kpi-chip-icon {
        background: rgba(37, 99, 235, 0.1);
        color: #2563EB;
    }
    .tracking-kpi-chip.kpi-transit .kpi-chip-num {
        color: #2563EB;
    }
    .tracking-kpi-chip.kpi-transit:hover,
    .tracking-kpi-chip.kpi-transit.is-filtered {
        border-color: #2563EB;
        box-shadow: 0 4px 14px rgba(37, 99, 235, 0.2);
    }

    .tracking-kpi-chip.kpi-customs {
        background: linear-gradient(135deg, #FFFFFF 0%, #FFFBF0 100%);
        border-color: rgba(217, 119, 6, 0.25);
    }
    .tracking-kpi-chip.kpi-customs .kpi-chip-icon {
        background: rgba(217, 119, 6, 0.1);
        color: #D97706;
    }
    .tracking-kpi-chip.kpi-customs .kpi-chip-num {
        color: #D97706;
    }
    .tracking-kpi-chip.kpi-customs:hover,
    .tracking-kpi-chip.kpi-customs.is-filtered {
        border-color: #D97706;
        box-shadow: 0 4px 14px rgba(217, 119, 6, 0.2);
    }

    .tracking-kpi-chip.kpi-delayed {
        background: linear-gradient(135deg, #FFFFFF 0%, #FEF2F2 100%);
        border-color: rgba(220, 38, 38, 0.25);
    }
    .tracking-kpi-chip.kpi-delayed .kpi-chip-icon {
        background: rgba(220, 38, 38, 0.1);
        color: #DC2626;
    }
    .tracking-kpi-chip.kpi-delayed .kpi-chip-num {
        color: #DC2626;
    }
    .tracking-kpi-chip.kpi-delayed:hover,
    .tracking-kpi-chip.kpi-delayed.is-filtered {
        border-color: #DC2626;
        box-shadow: 0 4px 14px rgba(220, 38, 38, 0.2);
    }

    /* Dark Mode Theme Rules - Unified Sleek Graphite Tokens */
    [data-theme="dark"] .tracking-kpi-chip {
        background: #141E28 !important;
        border: 1px solid #243445 !important;
        box-shadow: 0 4px 14px rgba(0, 0, 0, 0.35), inset 0 1px 0 rgba(255, 255, 255, 0.05) !important;
    }
    [data-theme="dark"] .tracking-kpi-chip:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 18px rgba(0, 0, 0, 0.5) !important;
    }
    [data-theme="dark"] .kpi-chip-label {
        color: #94A3B8 !important;
    }

    [data-theme="dark"] .tracking-kpi-chip.kpi-active .kpi-chip-icon {
        background: rgba(252, 128, 25, 0.15) !important;
        border: 1px solid rgba(252, 128, 25, 0.35) !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .tracking-kpi-chip.kpi-active .kpi-chip-num {
        color: #FC8019 !important;
    }
    [data-theme="dark"] .tracking-kpi-chip.kpi-active:hover,
    [data-theme="dark"] .tracking-kpi-chip.kpi-active.is-filtered {
        border-color: #FC8019 !important;
        box-shadow: 0 4px 18px rgba(252, 128, 25, 0.25), inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
    }

    [data-theme="dark"] .tracking-kpi-chip.kpi-transit .kpi-chip-icon {
        background: rgba(59, 130, 246, 0.15) !important;
        border: 1px solid rgba(59, 130, 246, 0.35) !important;
        color: #60A5FA !important;
    }
    [data-theme="dark"] .tracking-kpi-chip.kpi-transit .kpi-chip-num {
        color: #60A5FA !important;
    }
    [data-theme="dark"] .tracking-kpi-chip.kpi-transit:hover,
    [data-theme="dark"] .tracking-kpi-chip.kpi-transit.is-filtered {
        border-color: #3B82F6 !important;
        box-shadow: 0 4px 18px rgba(59, 130, 246, 0.25), inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
    }

    [data-theme="dark"] .tracking-kpi-chip.kpi-customs .kpi-chip-icon {
        background: rgba(245, 158, 11, 0.15) !important;
        border: 1px solid rgba(245, 158, 11, 0.35) !important;
        color: #FBBF24 !important;
    }
    [data-theme="dark"] .tracking-kpi-chip.kpi-customs .kpi-chip-num {
        color: #FBBF24 !important;
    }
    [data-theme="dark"] .tracking-kpi-chip.kpi-customs:hover,
    [data-theme="dark"] .tracking-kpi-chip.kpi-customs.is-filtered {
        border-color: #F59E0B !important;
        box-shadow: 0 4px 18px rgba(245, 158, 11, 0.25), inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
    }

    [data-theme="dark"] .tracking-kpi-chip.kpi-delayed .kpi-chip-icon {
        background: rgba(239, 68, 68, 0.15) !important;
        border: 1px solid rgba(239, 68, 68, 0.35) !important;
        color: #F87171 !important;
    }
    [data-theme="dark"] .tracking-kpi-chip.kpi-delayed .kpi-chip-num {
        color: #F87171 !important;
    }
    [data-theme="dark"] .tracking-kpi-chip.kpi-delayed:hover,
    [data-theme="dark"] .tracking-kpi-chip.kpi-delayed.is-filtered {
        border-color: #EF4444 !important;
        box-shadow: 0 4px 18px rgba(239, 68, 68, 0.25), inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
    }

    /* Filter Row */
    /* Filter Row - Clean seamless bar without clunky card container */
    .filter-card {
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        padding: 0 !important;
        margin-bottom: 24px;
        display: flex;
        align-items: center;
        gap: 14px;
        flex-wrap: wrap;
    }
    .filter-search {
        position: relative;
        flex: 1;
        min-width: 240px;
    }
    .filter-search i {
        position: absolute;
        left: 16px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--nl-text-muted);
        font-size: 15px;
        pointer-events: none;
    }
    .filter-search input {
        width: 100%;
        padding: 10px 18px 10px 44px;
        border: 1.5px solid #E2E5EA;
        border-radius: 50px !important;
        font-size: 13.5px;
        outline: none;
        background: #FFFFFF;
        color: var(--nl-text);
        transition: border-color 0.15s ease, box-shadow 0.15s ease;
    }
    .filter-search input:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3.5px rgba(252, 128, 25, 0.14);
    }
    .filter-select {
        min-width: 170px;
    }
    .filter-select select {
        padding: 10px 36px 10px 18px;
        border: 1.5px solid #E2E5EA;
        border-radius: 50px !important;
        font-size: 13px;
        font-weight: 500;
        background: #FFFFFF;
        color: #374151;
        outline: none;
        cursor: pointer;
        width: 100%;
        min-height: 42px;
        transition: border-color 0.15s ease, box-shadow 0.15s ease;
    }
    .filter-select select:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3.5px rgba(252, 128, 25, 0.14);
    }
    .filter-reset-btn {
        width: 42px;
        height: 42px;
        border-radius: 50% !important;
        border: 1.5px solid #E2E5EA;
        background: #FFFFFF;
        color: var(--nl-text-muted);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 16px;
        cursor: pointer;
        transition: all 0.15s ease;
        margin-left: auto;
    }
    .filter-reset-btn:hover {
        background: #F8FAFC;
        color: var(--nl-primary);
        border-color: #CBD5E1;
    }

    /* Dark Mode Enhancements */
    [data-theme="dark"] .card-panel {
        background: #101820 !important;
        border-color: #22303A !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .stats-icon-box {
        background: rgba(252, 128, 25, 0.18) !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .filter-card {
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        padding: 0 !important;
    }
    [data-theme="dark"] .filter-search input {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .filter-search i {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .filter-select select {
        background-color: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .filter-reset-btn {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .filter-reset-btn:hover {
        background: #1C2A37 !important;
        border-color: #FC8019 !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .table-panel {
        background: #101820 !important;
        border-color: #22303A !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .table-header {
        border-bottom-color: #1A252E !important;
    }
    [data-theme="dark"] .tracking-table th {
        background: #151F28 !important;
        border-color: #22303A !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .tracking-table td {
        border-bottom-color: #1A252E !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .tracking-table tbody tr:hover {
        background-color: rgba(255, 255, 255, 0.04) !important;
    }
    [data-theme="dark"] .vessel-name-cell {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .btn-tracking-details {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .btn-tracking-details:hover {
        background: #FC8019 !important;
        border-color: #FC8019 !important;
        color: #FFFFFF !important;
    }
    [data-theme="dark"] .page-header-flex .btn-light {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .page-header-flex .btn-light:hover {
        background: #1C2A37 !important;
        border-color: #FC8019 !important;
        color: #FC8019 !important;
    }

    /* Data Table */
    .table-panel {
        background: #FFFFFF;
        border-radius: 14px;
        border: 1px solid var(--nl-border);
        box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
        overflow: hidden;
        margin-bottom: 24px;
    }
    .table-header {
        padding: 16px 24px;
        border-bottom: 1px solid #F1F3F6;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 20px;
    }
    .table-title {
        font-size: 17px;
        font-weight: 700;
        color: var(--nl-text);
        margin-bottom: 2px;
    }
    .table-subtitle {
        font-size: 12.5px;
        color: var(--nl-text-muted);
    }

    .tracking-table {
        width: 100%;
        border-collapse: collapse;
    }
    .tracking-table th {
        font-size: 12px;
        color: #64748B;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.4px;
        padding: 12px 20px;
        border-bottom: 1px solid #E2E8F0;
        background: #F8FAFC;
        text-align: left;
    }
    
    /* Action Pill Button with Hover Highlight */
    .btn-tracking-details {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 16px;
        border-radius: 50px;
        font-size: 12px;
        font-weight: 600;
        color: #475569;
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        text-decoration: none;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);
        cursor: pointer;
    }
    .btn-tracking-details i {
        font-size: 11px;
        color: #94A3B8;
        transition: transform 0.2s ease, color 0.2s ease;
    }
    .btn-tracking-details:hover {
        background: #FC8019 !important;
        border-color: transparent !important;
        color: #FFFFFF !important;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.32);
        text-decoration: none;
    }
    .btn-tracking-details:hover i {
        color: #FFFFFF !important;
        transform: translateX(2px);
    }
    .btn-tracking-details:active {
        transform: translateY(0);
        box-shadow: 0 1px 3px rgba(252, 128, 25, 0.2);
    }
    .tracking-row:hover .btn-tracking-details {
        border-color: #CBD5E1;
        background: #FFFFFF;
        color: #0F172A;
    }
    .tracking-row:hover .btn-tracking-details:hover {
        background: #FC8019 !important;
        color: #FFFFFF !important;
        border-color: transparent !important;
    }

    .tracking-table td {
        padding: 14px 20px;
        font-size: 13.5px;
        color: var(--nl-text);
        border-bottom: 1px solid #F1F3F6;
        vertical-align: middle;
    }
    .tracking-table tbody tr {
        cursor: pointer;
        transition: background-color 0.15s ease;
    }
    .tracking-table tbody tr:hover {
        background-color: #FFF9F5;
    }
    .tracking-table tbody tr:last-child td {
        border-bottom: none;
    }

    .shipment-id-cell {
        font-weight: 600;
        color: #FC8019;
    }
    .vessel-name-cell {
        font-weight: 500;
        color: #374151;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    /* Status Badges */
    .status-badge {
        padding: 5px 12px;
        border-radius: 20px;
        font-weight: 600;
        font-size: 12px;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        white-space: nowrap;
    }

    /* =========================================================
       DARK THEME COMPLETE OVERRIDES FOR LIVE TRACKING
       ========================================================= */
    [data-theme="dark"] .page-header-flex .btn-light {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .page-header-flex .btn-light:hover {
        background: #1C2A37 !important;
        border-color: #FC8019 !important;
        color: #FC8019 !important;
    }

    [data-theme="dark"] .card-panel {
        background: #101820 !important;
        border-color: #22303A !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .stats-icon-box {
        background: rgba(252, 128, 25, 0.18) !important;
        color: #FC8019 !important;
    }
    [data-theme="dark"] .stats-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .stats-subtitle {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .stat-label {
        color: #94A3B8 !important;
    }

    [data-theme="dark"] .filter-card {
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        padding: 0 !important;
    }
    [data-theme="dark"] .filter-search input {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .filter-search i {
        color: #94A3B8 !important;
    }
    /* Filter Select Pill Styling & Inner/Outer Border Removal */
    .filter-select .ts-wrapper,
    .filter-select .ts-wrapper.form-select,
    .filter-select .ts-wrapper.form-select-custom,
    .filter-select .ts-wrapper.single,
    [data-theme="dark"] .filter-select .ts-wrapper,
    [data-theme="dark"] .filter-select .ts-wrapper.form-select,
    [data-theme="dark"] .filter-select .ts-wrapper.form-select-custom,
    [data-theme="dark"] .filter-select .ts-wrapper.single {
        border: none !important;
        border-width: 0 !important;
        background: transparent !important;
        background-color: transparent !important;
        box-shadow: none !important;
        outline: none !important;
        padding: 0 !important;
        margin: 0 !important;
    }
    .filter-select {
        width: 175px;
        min-width: 175px;
        max-width: 175px;
    }
    .filter-select .ts-wrapper,
    .filter-select .ts-wrapper.single {
        width: 100% !important;
        min-width: 100% !important;
        max-width: 100% !important;
    }
    .filter-select .ts-control,
    .filter-select .ts-wrapper.single .ts-control,
    .filter-select .ts-wrapper.single.focus .ts-control,
    .filter-select .ts-wrapper.single.input-active .ts-control,
    .filter-select .ts-wrapper.single.dropdown-active .ts-control {
        height: 42px !important;
        min-height: 42px !important;
        max-height: 42px !important;
        padding: 0 34px 0 16px !important;
        border-radius: 50px !important;
        border: 1.5px solid #E2E5EA !important;
        background: #FFFFFF !important;
        color: #374151 !important;
        display: flex !important;
        align-items: center !important;
        box-shadow: none !important;
        box-sizing: border-box !important;
        overflow: hidden !important;
        cursor: pointer !important;
    }
    .filter-select .ts-control .item,
    .filter-select .ts-wrapper.single .ts-control .item,
    [data-theme="dark"] .filter-select .ts-control .item,
    [data-theme="dark"] .filter-select .ts-wrapper.single .ts-control .item {
        border: none !important;
        border-width: 0 !important;
        background: transparent !important;
        background-color: transparent !important;
        box-shadow: none !important;
        outline: none !important;
        padding: 0 !important;
        margin: 0 !important;
        line-height: 38px !important;
        height: 38px !important;
        max-height: 38px !important;
        font-size: 13px !important;
        white-space: nowrap !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
    }

    /* Auto-hide placeholder and selected item text on click/focus so input box is clean for typing */
    .filter-search input:focus::placeholder,
    .filter-select .ts-control input:focus::placeholder,
    .filter-select .ts-wrapper.focus .ts-control input::placeholder,
    .filter-select .ts-wrapper.input-active .ts-control input::placeholder,
    .filter-select .ts-wrapper.dropdown-active .ts-control input::placeholder {
        color: transparent !important;
        opacity: 0 !important;
    }
    .filter-select .ts-wrapper.single.focus .ts-control .item,
    .filter-select .ts-wrapper.single.input-active .ts-control .item,
    .filter-select .ts-wrapper.single.dropdown-active .ts-control .item,
    [data-theme="dark"] .filter-select .ts-wrapper.single.focus .ts-control .item,
    [data-theme="dark"] .filter-select .ts-wrapper.single.input-active .ts-control .item,
    [data-theme="dark"] .filter-select .ts-wrapper.single.dropdown-active .ts-control .item {
        opacity: 0 !important;
        visibility: hidden !important;
        display: none !important;
    }

    .filter-select .ts-control input,
    .filter-select .ts-control > input,
    .filter-select .ts-wrapper .ts-control input,
    .filter-select .ts-wrapper.single.input-active .ts-control input,
    [data-theme="dark"] .filter-select .ts-control input,
    [data-theme="dark"] .filter-select .ts-control > input,
    [data-theme="dark"] .filter-select .ts-wrapper .ts-control input,
    [data-theme="dark"] .filter-select .ts-wrapper.single.input-active .ts-control input {
        border: none !important;
        border-width: 0 !important;
        outline: none !important;
        box-shadow: none !important;
        background: transparent !important;
        background-color: transparent !important;
        min-height: 0 !important;
        height: 38px !important;
        max-height: 38px !important;
        line-height: 38px !important;
        padding: 0 !important;
        margin: 0 !important;
        font-size: 13px !important;
        color: #374151 !important;
        caret-color: #FC8019 !important;
    }
    .filter-select .ts-wrapper.single.focus .ts-control input,
    .filter-select .ts-wrapper.single.input-active .ts-control input,
    .filter-select .ts-wrapper.single.dropdown-active .ts-control input {
        flex: 1 1 auto !important;
        min-width: 60px !important;
        width: 100% !important;
        opacity: 1 !important;
        visibility: visible !important;
    }
    [data-theme="dark"] .filter-select .ts-control input,
    [data-theme="dark"] .filter-select .ts-wrapper.single.focus .ts-control input,
    [data-theme="dark"] .filter-select .ts-wrapper.single.input-active .ts-control input,
    [data-theme="dark"] .filter-select .ts-wrapper.single.dropdown-active .ts-control input {
        color: #F8FAFC !important;
        caret-color: #FC8019 !important;
    }

    [data-theme="dark"] .filter-select select,
    [data-theme="dark"] .filter-select .ts-control,
    [data-theme="dark"] .filter-select .ts-wrapper.single .ts-control,
    [data-theme="dark"] .filter-select .ts-wrapper.single.focus .ts-control,
    [data-theme="dark"] .filter-select .ts-wrapper.single.input-active .ts-control,
    [data-theme="dark"] .filter-select .ts-wrapper.single.dropdown-active .ts-control {
        background-color: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #F8FAFC !important;
        box-shadow: none !important;
    }
    .filter-select .ts-wrapper.focus .ts-control,
    .filter-select .ts-wrapper.dropdown-active .ts-control,
    [data-theme="dark"] .filter-select .ts-wrapper.focus .ts-control,
    [data-theme="dark"] .filter-select .ts-wrapper.dropdown-active .ts-control {
        border-color: #FC8019 !important;
        box-shadow: none !important;
    }
    [data-theme="dark"] .filter-select .ts-control .item {
        color: #F8FAFC !important;
    }

    /* Clean Dropdown Options (No Muddy Brown) */
    [data-theme="dark"] .filter-select .ts-dropdown {
        background: #151F28 !important;
        border: 1px solid #2D3F4D !important;
        box-shadow: 0 12px 30px rgba(0, 0, 0, 0.5) !important;
        border-radius: 12px !important;
        padding: 6px !important;
    }
    [data-theme="dark"] .filter-select .ts-dropdown .option {
        color: #94A3B8 !important;
        font-size: 13px !important;
        font-weight: 500 !important;
        padding: 8px 12px !important;
        border-radius: 8px !important;
        background: transparent !important;
        transition: all 0.12s ease !important;
    }
    [data-theme="dark"] .filter-select .ts-dropdown .option:hover,
    [data-theme="dark"] .filter-select .ts-dropdown .option.active,
    [data-theme="dark"] .filter-select .ts-dropdown .active {
        background: #1E2D3D !important;
        background-color: #1E2D3D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .filter-select .ts-dropdown .option.selected {
        background: #FC8019 !important;
        background-color: #FC8019 !important;
        color: #FFFFFF !important;
        font-weight: 700 !important;
    }
    [data-theme="dark"] .filter-select .ts-dropdown .option.selected:hover,
    [data-theme="dark"] .filter-select .ts-dropdown .option.selected.active {
        background: #E66F0F !important;
        background-color: #E66F0F !important;
        color: #FFFFFF !important;
    }
    /* Eliminate ugly olive search highlight (Brand Orange) */
    .filter-select .ts-dropdown .highlight,
    [data-theme="dark"] .filter-select .ts-dropdown .highlight,
    [data-theme="dark"] .ts-dropdown .highlight {
        background: rgba(252, 128, 25, 0.22) !important;
        color: #FC8019 !important;
        font-weight: 700 !important;
        border-radius: 3px !important;
        padding: 1px 3px !important;
    }
    [data-theme="dark"] .filter-select .ts-dropdown .option.selected .highlight {
        background: transparent !important;
        color: #FFFFFF !important;
        text-decoration: underline !important;
    }
    [data-theme="dark"] .filter-reset-btn {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .filter-reset-btn:hover {
        background: #1C2A37 !important;
        border-color: #FC8019 !important;
        color: #FC8019 !important;
    }

    [data-theme="dark"] .table-panel {
        background: #101820 !important;
        border-color: #22303A !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .table-header {
        background: #101820 !important;
        border-bottom-color: #1A252E !important;
    }
    [data-theme="dark"] .table-title {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .table-subtitle {
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .table-responsive {
        background: #101820 !important;
    }
    [data-theme="dark"] .tracking-table {
        background: #101820 !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .tracking-table th {
        background: #151F28 !important;
        border-color: #22303A !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .tracking-table td {
        background: transparent !important;
        border-bottom-color: #1A252E !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .tracking-table tbody tr {
        background: transparent !important;
    }
    [data-theme="dark"] .tracking-table tbody tr:hover,
    [data-theme="dark"] .tracking-row:hover {
        background-color: rgba(255, 255, 255, 0.04) !important;
    }
    [data-theme="dark"] .tracking-table td span {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .customer-name-cell,
    [data-theme="dark"] .tracking-table td span.customer-name-cell,
    [data-theme="dark"] .tracking-table td span[style*="color: #1F2937"] {
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .eta-cell,
    [data-theme="dark"] .tracking-table td[style*="color: #374151"] {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .tracking-table td span.shipment-id-cell {
        color: #FC8019 !important;
    }
    [data-theme="dark"] .status-badge.status-booked,
    [data-theme="dark"] .status-badge:has(.ti-bookmark),
    [data-theme="dark"] .status-badge[style*="background: #F8FAFC"],
    [data-theme="dark"] .status-badge[style*="background: #F1F5F9"] {
        background: rgba(148, 163, 184, 0.16) !important;
        border-color: rgba(148, 163, 184, 0.3) !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .tracking-table td div {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .vessel-name-cell {
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .btn-tracking-details,
    [data-theme="dark"] .tracking-row:hover .btn-tracking-details {
        background: #151F28 !important;
        border-color: #2D3F4D !important;
        color: #CBD5E1 !important;
    }
    [data-theme="dark"] .btn-tracking-details:hover,
    [data-theme="dark"] .tracking-row:hover .btn-tracking-details:hover {
        background: #FC8019 !important;
        border-color: #FC8019 !important;
        color: #FFFFFF !important;
    }

    /* Status Badges in Dark Mode */
    [data-theme="dark"] .status-badge {
        background: rgba(148, 163, 184, 0.16) !important;
        border-color: rgba(148, 163, 184, 0.3) !important;
        color: #94A3B8 !important;
    }
    [data-theme="dark"] .status-badge:has(.ti-circle-check) {
        background: rgba(16, 185, 129, 0.18) !important;
        border-color: rgba(16, 185, 129, 0.35) !important;
        color: #34D399 !important;
    }
    [data-theme="dark"] .status-badge:has(.ti-navigation) {
        background: rgba(59, 130, 246, 0.18) !important;
        border-color: rgba(59, 130, 246, 0.35) !important;
        color: #60A5FA !important;
    }
    [data-theme="dark"] .status-badge:has(.ti-clock) {
        background: rgba(245, 158, 11, 0.18) !important;
        border-color: rgba(245, 158, 11, 0.35) !important;
        color: #FBBF24 !important;
    }
    [data-theme="dark"] .status-badge:has(.ti-anchor) {
        background: rgba(139, 92, 246, 0.18) !important;
        border-color: rgba(139, 92, 246, 0.35) !important;
        color: #C084FC !important;
    }
    [data-theme="dark"] .status-badge:has(.ti-box) {
        background: rgba(16, 185, 129, 0.18) !important;
        border-color: rgba(16, 185, 129, 0.35) !important;
        color: #34D399 !important;
    }
    [data-theme="dark"] .status-badge:has(.ti-alert-triangle) {
        background: rgba(239, 68, 68, 0.18) !important;
        border-color: rgba(239, 68, 68, 0.35) !important;
        color: #F87171 !important;
    }
    /* Refined Pagination Page Size Dropdown */
    .ts-wrapper.nl-page-size-ts .ts-control .item,
    [data-theme="dark"] .ts-wrapper.nl-page-size-ts .ts-control .item {
        border: none !important;
        border-width: 0 !important;
        background: transparent !important;
        box-shadow: none !important;
        outline: none !important;
        padding: 0 !important;
        margin: 0 !important;
    }
    [data-theme="dark"] .ts-wrapper.nl-page-size-ts .ts-dropdown {
        background: #151F28 !important;
        border: 1px solid #2D3F4D !important;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.5) !important;
        padding: 4px !important;
        border-radius: 10px !important;
    }
    [data-theme="dark"] .ts-wrapper.nl-page-size-ts .ts-dropdown .option {
        color: #94A3B8 !important;
        font-size: 12px !important;
        font-weight: 500 !important;
        padding: 6px 8px !important;
        border-radius: 6px !important;
        background: transparent !important;
        transition: all 0.15s ease !important;
    }
    [data-theme="dark"] .ts-wrapper.nl-page-size-ts .ts-dropdown .option:hover,
    [data-theme="dark"] .ts-wrapper.nl-page-size-ts .ts-dropdown .option.active {
        background: #1E2D3D !important;
        color: #F8FAFC !important;
    }
    [data-theme="dark"] .ts-wrapper.nl-page-size-ts .ts-dropdown .option.selected {
        background: #FC8019 !important;
        color: #FFFFFF !important;
        font-weight: 700 !important;
    }
    [data-theme="dark"] .ts-wrapper.nl-page-size-ts .ts-dropdown .option.selected:hover,
    [data-theme="dark"] .ts-wrapper.nl-page-size-ts .ts-dropdown .option.selected.active {
        background: #E66F0F !important;
        color: #FFFFFF !important;
    }
</style>

<div class="page-header-flex">
    <div>
        <h2 style="font-weight: 700; margin-bottom: 6px; color: var(--nl-text); font-size: 24px;">Live Shipment Tracking</h2>
        <div class="custom-breadcrumb d-flex align-items-center" style="margin-bottom: 0; font-size: 13px; color: var(--nl-text-muted);">
            <a href="${pageContext.request.contextPath}/dashboard" style="color: var(--nl-text-muted); text-decoration: none;">Dashboard</a>
            <i class="ti ti-chevron-right mx-2" style="font-size: 11px;"></i>
            <a href="${pageContext.request.contextPath}/shipments" style="color: var(--nl-text-muted); text-decoration: none;">Shipments</a>
            <i class="ti ti-chevron-right mx-2" style="font-size: 11px;"></i>
            <span style="color: var(--nl-primary); font-weight: 600;">Live Tracking</span>
        </div>
    </div>
    <a href="${pageContext.request.contextPath}/shipments" class="btn btn-light" style="border: 1px solid var(--nl-border); font-weight: 600; font-size: 13px; border-radius: 8px; background: #fff; padding: 9px 18px; color: #4B5563;">
        <i class="ti ti-arrow-left me-1"></i> Back to Shipments
    </a>
</div>

<!-- Interactive Live Filter Bar -->
<div class="filter-card">
    <div class="filter-search">
        <i class="ti ti-search"></i>
        <input type="text" id="searchInput" placeholder="Search by shipment ID, port, vessel...">
    </div>
    <div class="filter-select">
        <select id="statusFilter" class="filter-dropdown-select">
            <option value="" selected>All Statuses</option>
            <option value="Booked">Booked</option>
            <option value="Container Allocated">Container Allocated</option>
            <option value="Departed">Departed</option>
            <option value="In Transit">In Transit</option>
            <option value="Customs Hold">Customs Hold</option>
            <option value="Arrived">Arrived</option>
            <option value="Delivered">Delivered</option>
        </select>
    </div>
    <div class="filter-select">
        <select id="vesselFilter" class="filter-dropdown-select">
            <option value="" selected>All Vessels</option>
            <c:forEach var="v" items="${vessels}">
                <option value="${v.vesselName}">${v.vesselName}</option>
            </c:forEach>
        </select>
    </div>
    <button class="filter-reset-btn" id="resetFiltersBtn" title="Reset Filters" type="button">
        <i class="ti ti-rotate"></i>
    </button>
</div>

<!-- Table Card -->
<div class="table-panel">
    <div class="table-header">
        <div>
            <div class="table-title">Active Monitoring Fleet</div>
            <div class="table-subtitle">Live tracking updates, vessel assignments, and estimated arrival milestones</div>
        </div>
        <div class="tracking-kpi-strip">
            <div class="tracking-kpi-chip kpi-active" data-status-filter="" title="Click to show all active shipments">
                <div class="kpi-chip-icon"><i class="ti ti-box"></i></div>
                <div class="kpi-chip-body">
                    <span class="kpi-chip-label">Active Shipments</span>
                    <span class="kpi-chip-num">${not empty activeCount ? activeCount : 0}</span>
                </div>
            </div>
            <div class="tracking-kpi-chip kpi-transit" data-status-filter="In Transit" title="Click to filter by In Transit">
                <div class="kpi-chip-icon"><i class="ti ti-ship"></i></div>
                <div class="kpi-chip-body">
                    <span class="kpi-chip-label">In Transit</span>
                    <span class="kpi-chip-num">${not empty inTransitCount ? inTransitCount : 0}</span>
                </div>
            </div>
            <div class="tracking-kpi-chip kpi-customs" data-status-filter="Customs Hold" title="Click to filter by Customs Hold">
                <div class="kpi-chip-icon"><i class="ti ti-shield-lock"></i></div>
                <div class="kpi-chip-body">
                    <span class="kpi-chip-label">Customs Hold</span>
                    <span class="kpi-chip-num">${not empty customsHoldCount ? customsHoldCount : 0}</span>
                </div>
            </div>
            <div class="tracking-kpi-chip kpi-delayed" data-status-filter="Delayed" title="Click to filter by Delayed">
                <div class="kpi-chip-icon"><i class="ti ti-alert-triangle"></i></div>
                <div class="kpi-chip-body">
                    <span class="kpi-chip-label">Delayed</span>
                    <span class="kpi-chip-num">${not empty delayedCount ? delayedCount : 0}</span>
                </div>
            </div>
        </div>
    </div>

    <div class="table-responsive">
        <table class="tracking-table" id="trackingTable">
            <thead>
                <tr>
                    <th style="padding-left: 24px;">Shipment</th>
                    <th>Customer</th>
                    <th>Shipping Route</th>
                    <th>Assigned Vessel</th>
                    <th>Status</th>
                    <th>ETA</th>
                    <th>Last Updated</th>
                    <th style="padding-right: 24px; text-align: right;">Action</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="shipment" items="${shipments}">
                    <tr class="tracking-row" 
                        data-id="SHP-${shipment.shipmentId}"
                        data-status="${shipment.status}"
                        data-vessel="${shipment.vesselName}"
                        onclick="window.location.href='${pageContext.request.contextPath}/shipments/tracking/detail?id=SHP-${shipment.shipmentId}'">
                        <td style="padding-left: 24px;">
                            <span class="shipment-id-cell">#SHP-${shipment.shipmentId}</span>
                        </td>
                        <td>
                            <span class="customer-name-cell" style="font-weight: 600;">${shipment.customerName}</span>
                        </td>
                        <td>
                            <div style="display: flex; align-items: center; gap: 8px; font-weight: 500;">
                                <span>${shipment.originPort}</span>
                                <i class="ti ti-arrow-right" style="color: #FC8019; font-size: 14px;"></i>
                                <span>${shipment.destPort}</span>
                            </div>
                        </td>
                        <td>
                            <div class="vessel-name-cell">
                                <i class="ti ti-ship" style="color: #64748B; font-size: 15px;"></i>
                                <span>${not empty shipment.vesselName ? shipment.vesselName : 'Ocean Vessel'}</span>
                            </div>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${shipment.status == 'Delivered'}">
                                    <span class="status-badge" style="background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0;">
                                        <i class="ti ti-circle-check"></i> Delivered
                                    </span>
                                </c:when>
                                <c:when test="${shipment.status == 'In Transit'}">
                                    <span class="status-badge" style="background: #EFF6FF; color: #2563EB; border: 1px solid #BFDBFE;">
                                        <i class="ti ti-navigation"></i> In Transit
                                    </span>
                                </c:when>
                                <c:when test="${shipment.status == 'Customs Hold'}">
                                    <span class="status-badge" style="background: #FFF7ED; color: #EA580C; border: 1px solid #FED7AA;">
                                        <i class="ti ti-clock"></i> Customs Hold
                                    </span>
                                </c:when>
                                <c:when test="${shipment.status == 'Departed'}">
                                    <span class="status-badge" style="background: #F5F3FF; color: #7C3AED; border: 1px solid #DDD6FE;">
                                        <i class="ti ti-anchor"></i> Departed
                                    </span>
                                </c:when>
                                <c:when test="${shipment.status == 'Container Allocated'}">
                                    <span class="status-badge" style="background: #F0FDF4; color: #16A34A; border: 1px solid #BBF7D0;">
                                        <i class="ti ti-box"></i> Allocated
                                    </span>
                                </c:when>
                                <c:when test="${shipment.status == 'Delayed'}">
                                    <span class="status-badge" style="background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA;">
                                        <i class="ti ti-alert-triangle"></i> Delayed
                                    </span>
                                </c:when>
                                <c:when test="${shipment.status == 'Booked'}">
                                    <span class="status-badge status-booked" style="background: #F1F5F9; color: #475569; border: 1px solid #CBD5E1;">
                                        <i class="ti ti-bookmark"></i> Booked
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-badge" style="background: #F8FAFC; color: #475569; border: 1px solid #E2E8F0;">
                                        ${shipment.status}
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="eta-cell" style="color: #374151; font-weight: 500;">
                            <c:choose>
                                <c:when test="${not empty shipment.eta}">
                                    <fmt:formatDate value="${shipment.eta}" pattern="MMM dd, yyyy" />
                                </c:when>
                                <c:otherwise><span style="color: #9CA3AF;">Pending</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td style="color: #64748B; font-size: 13px;">
                            <c:choose>
                                <c:when test="${not empty shipment.updatedAt}">
                                    <fmt:formatDate value="${shipment.updatedAt}" pattern="MMM dd, hh:mm a" />
                                </c:when>
                                <c:otherwise><span style="color: #9CA3AF;">N/A</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td style="padding-right: 24px; text-align: right;">
                            <a href="${pageContext.request.contextPath}/shipments/tracking/detail?id=SHP-${shipment.shipmentId}" class="btn-tracking-details" onclick="event.stopPropagation();">
                                <span>Details</span>
                                <i class="ti ti-arrow-right"></i>
                            </a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <!-- Enterprise Theme Pagination Bar -->
    <div class="nl-pagination-wrapper" id="trackingPagination">
        <div class="nl-pagination-info">
            <span>Showing <strong id="trackingPageStart">1</strong> to <strong id="trackingPageEnd">10</strong> of <strong id="trackingTotalRows">0</strong> shipments</span>
            <div class="d-inline-flex align-items-center gap-2 ms-2">
                <span style="color: #94A3B8; font-size: 12.5px;">Rows per page:</span>
                <select id="trackingPageSize" class="nl-page-size-select no-custom-select">
                    <option value="10" selected>10</option>
                    <option value="25">25</option>
                    <option value="50">50</option>
                    <option value="100">100</option>
                </select>
            </div>
        </div>
        <div class="nl-pagination-nav" id="trackingPageNav">
            <!-- Dynamically generated buttons -->
        </div>
    </div>
</div>

<div style="font-size: 12.5px; color: var(--nl-text-muted); margin-bottom: 40px; display: flex; align-items: center; gap: 6px;">
    <i class="ti ti-info-circle" style="color: #FC8019;"></i> Click any shipment row to inspect live GPS checkpoint events, milestone progression, and movement audit logs.
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    const searchInput = document.getElementById('searchInput');
    const statusFilter = document.getElementById('statusFilter');
    const vesselFilter = document.getElementById('vesselFilter');
    const resetBtn = document.getElementById('resetFiltersBtn');
    const allRows = Array.from(document.querySelectorAll('.tracking-row'));
    const pageSizeSelect = document.getElementById('trackingPageSize');
    const pageNav = document.getElementById('trackingPageNav');
    const pageStartEl = document.getElementById('trackingPageStart');
    const pageEndEl = document.getElementById('trackingPageEnd');
    const totalRowsEl = document.getElementById('trackingTotalRows');
    const tableBody = document.querySelector('#trackingTable tbody');

    let currentPage = 1;
    let pageSize = parseInt(pageSizeSelect ? pageSizeSelect.value : 10, 10);
    let matchingRows = [];

    function updatePagination() {
        const total = matchingRows.length;
        const totalPages = Math.ceil(total / pageSize) || 1;

        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        const startIndex = total === 0 ? 0 : (currentPage - 1) * pageSize;
        const endIndex = Math.min(startIndex + pageSize, total);

        if (pageStartEl) pageStartEl.textContent = total === 0 ? '0' : (startIndex + 1);
        if (pageEndEl) pageEndEl.textContent = endIndex;
        if (totalRowsEl) totalRowsEl.textContent = total;

        allRows.forEach(row => { row.style.display = 'none'; });

        for (let i = startIndex; i < endIndex; i++) {
            if (matchingRows[i]) {
                matchingRows[i].style.display = '';
            }
        }

        renderPageButtons(totalPages);
    }

    function renderPageButtons(totalPages) {
        if (!pageNav) return;
        pageNav.innerHTML = '';

        if (totalPages <= 1 && matchingRows.length <= pageSize) {
            return;
        }

        const prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'nl-page-btn nl-page-nav-btn' + (currentPage === 1 ? ' disabled' : '');
        prevBtn.innerHTML = '<i class="ti ti-chevron-left"></i> Prev';
        prevBtn.addEventListener('click', function(e) {
            e.preventDefault();
            if (currentPage > 1) {
                currentPage--;
                updatePagination();
            }
        });
        pageNav.appendChild(prevBtn);

        let pages = [];
        if (totalPages <= 7) {
            for (let i = 1; i <= totalPages; i++) pages.push(i);
        } else {
            if (currentPage <= 4) {
                pages = [1, 2, 3, 4, 5, '...', totalPages];
            } else if (currentPage >= totalPages - 3) {
                pages = [1, '...', totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1, totalPages];
            } else {
                pages = [1, '...', currentPage - 1, currentPage, currentPage + 1, '...', totalPages];
            }
        }

        pages.forEach(p => {
            if (p === '...') {
                const ellipsis = document.createElement('span');
                ellipsis.className = 'nl-page-ellipsis';
                ellipsis.textContent = '…';
                pageNav.appendChild(ellipsis);
            } else {
                const btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'nl-page-btn nl-page-num' + (p === currentPage ? ' active' : '');
                btn.textContent = p;
                btn.addEventListener('click', function(e) {
                    e.preventDefault();
                    if (currentPage !== p) {
                        currentPage = p;
                        updatePagination();
                    }
                });
                pageNav.appendChild(btn);
            }
        });

        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'nl-page-btn nl-page-nav-btn' + (currentPage === totalPages ? ' disabled' : '');
        nextBtn.innerHTML = 'Next <i class="ti ti-chevron-right"></i>';
        nextBtn.addEventListener('click', function(e) {
            e.preventDefault();
            if (currentPage < totalPages) {
                currentPage++;
                updatePagination();
            }
        });
        pageNav.appendChild(nextBtn);
    }

    function filterRows() {
        const query = searchInput ? searchInput.value.toLowerCase().trim() : '';
        const selectedStatus = statusFilter ? statusFilter.value.toLowerCase().trim() : '';
        const selectedVessel = vesselFilter ? vesselFilter.value.toLowerCase().trim() : '';
        matchingRows = [];

        allRows.forEach(row => {
            const rowText = row.textContent.toLowerCase();
            const rowStatus = (row.dataset.status || '').toLowerCase();
            const rowVessel = (row.dataset.vessel || '').toLowerCase();

            const matchesQuery = !query || rowText.includes(query);
            const matchesStatus = !selectedStatus || rowStatus === selectedStatus;
            const matchesVessel = !selectedVessel || rowVessel === selectedVessel;

            if (matchesQuery && matchesStatus && matchesVessel) {
                matchingRows.push(row);
            }
        });

        let noResults = document.getElementById('trackingNoResultsRow');
        if (matchingRows.length === 0 && allRows.length > 0) {
            if (!noResults && tableBody) {
                noResults = document.createElement('tr');
                noResults.id = 'trackingNoResultsRow';
                noResults.innerHTML = '<td colspan="8" style="text-align: center; padding: 48px; color: var(--nl-text-muted);">' +
                    '<i class="ti ti-radar" style="font-size: 28px; color: #D1D5DB; margin-bottom: 12px; display: block;"></i>' +
                    'No tracking shipments found matching current filters</td>';
                tableBody.appendChild(noResults);
            } else if (noResults) {
                noResults.style.display = '';
            }
        } else if (noResults) {
            noResults.style.display = 'none';
        }

        currentPage = 1;
        updatePagination();
    }

    if (pageSizeSelect) {
        pageSizeSelect.addEventListener('change', function() {
            pageSize = parseInt(this.value, 10);
            currentPage = 1;
            updatePagination();
        });
    }

    if (searchInput) {
        searchInput.addEventListener('input', filterRows);
    }
    if (statusFilter) {
        statusFilter.addEventListener('change', filterRows);
    }
    if (vesselFilter) {
        vesselFilter.addEventListener('change', filterRows);
    }

    // Interactive KPI Chips click filtering
    const kpiChips = document.querySelectorAll('.tracking-kpi-chip');
    kpiChips.forEach(chip => {
        chip.addEventListener('click', function() {
            const filterVal = this.getAttribute('data-status-filter');
            if (statusFilter) {
                statusFilter.value = filterVal;
                if (statusFilter.tomselect) statusFilter.tomselect.setValue(filterVal);
                filterRows();
            }
            kpiChips.forEach(c => c.classList.remove('is-filtered'));
            if (filterVal) {
                this.classList.add('is-filtered');
            }
        });
    });

    if (resetBtn) {
        resetBtn.addEventListener('click', function() {
            if (searchInput) searchInput.value = '';
            if (statusFilter) {
                statusFilter.value = '';
                if (statusFilter.tomselect) statusFilter.tomselect.setValue('');
            }
            if (vesselFilter) {
                vesselFilter.value = '';
                if (vesselFilter.tomselect) vesselFilter.tomselect.setValue('');
            }
            kpiChips.forEach(c => c.classList.remove('is-filtered'));
            filterRows();
        });
    }

    filterRows();
});
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
