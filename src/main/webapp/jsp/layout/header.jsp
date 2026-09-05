<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>N Logistic</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <!-- TomSelect CSS -->
    <link href="https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/css/tom-select.bootstrap5.min.css" rel="stylesheet">
    <!-- Google Fonts: Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
/* ==========================================
           N LOGISTIC — ENTERPRISE DESIGN SYSTEM TOKENS
           ========================================== */
        :root {
            /* Primary Brand Palette */
            --nl-primary: #FC8019;
            --nl-primary-hover: #E66F0F;
            --nl-primary-subtle: #FFF2EB;
            --nl-primary-soft: #FFF9F5;
            --nl-primary-border: #FFD4C2;

            /* Backgrounds & Surfaces */
            --nl-bg: #E5EBF2;
            --nl-surface: #FFFFFF;
            --nl-surface-hover: #FAFAFA;
            --nl-surface-subtle: #F9FAFB;

            /* Subtle Borders (Enterprise Standard) */
            --nl-border: #E7E9ED;
            --nl-border-subtle: #F0F2F5;
            --nl-border-hover: #D8DCE3;
            --nl-border-focus: #FC8019;

            /* Typography Hierarchy */
            --nl-text: #1F2937;
            --nl-text-secondary: #4B5563;
            --nl-text-muted: #64748B;
            --nl-text-light: #94A3B8;

            /* Status Colors */
            --nl-success: #10B981;
            --nl-success-bg: #ECFDF5;
            --nl-success-border: #A7F3D0;
            --nl-warning: #F59E0B;
            --nl-warning-bg: #FFFBEB;
            --nl-warning-border: #FDE68A;
            --nl-danger: #EF4444;
            --nl-danger-bg: #FEF2F2;
            --nl-danger-border: #FECACA;
            --nl-info: #3B82F6;
            --nl-info-bg: #EFF6FF;
            --nl-info-border: #BFDBFE;

            /* Elevation & Soft Shadows */
            --nl-shadow-xs: 0 1px 2px rgba(15, 23, 42, 0.03);
            --nl-shadow-card: 0 2px 8px rgba(15, 23, 42, 0.04), 0 1px 2px rgba(15, 23, 42, 0.02);
            --nl-shadow-hover: 0 6px 16px rgba(15, 23, 42, 0.07), 0 2px 4px rgba(15, 23, 42, 0.03);
            --nl-shadow-modal: 0 16px 40px rgba(15, 23, 42, 0.12), 0 4px 12px rgba(15, 23, 42, 0.06);

            /* Radii Scale */
            --nl-radius-xs: 6px;
            --nl-radius-sm: 8px;
            --nl-radius-md: 12px;
            --nl-radius-lg: 16px;
            --nl-radius-pill: 9999px;

            /* Spacing Scale */
            --nl-pad-card: 20px 24px;
            --nl-pad-card-compact: 16px 20px;
            --nl-pad-header: 16px 24px;
        }

        body,
        .main-wrapper,
        .content-area {
            background-color: var(--nl-bg) !important;
            color: var(--nl-text) !important;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif !important;
            -webkit-font-smoothing: antialiased;
        }

        /* 1. Global Cards & Panels */
        .card,
        .nl-card,
        .card-panel,
        .table-card,
        .chart-card,
        .filter-card {
            background-color: var(--nl-surface) !important;
            border: 1px solid var(--nl-border) !important;
            box-shadow: var(--nl-shadow-card) !important;
            border-radius: var(--nl-radius-md) !important;
            transition: box-shadow 180ms ease, transform 180ms ease, border-color 180ms ease;
        }

        .card.border-0 {
            border: 1px solid var(--nl-border) !important;
        }
        .card.shadow-sm,
        .card.shadow {
            box-shadow: var(--nl-shadow-card) !important;
        }
        .card.rounded-4 {
            border-radius: var(--nl-radius-md) !important;
        }

        /* Interactive Card Hover */
        .card.interactive-card:hover,
        .nl-card-hover:hover {
            transform: translateY(-1px);
            box-shadow: var(--nl-shadow-hover) !important;
            border-color: var(--nl-border-hover) !important;
        }

        /* 2. Standardized Card Headers */
        .card-header,
        .nl-card-header {
            background-color: transparent !important;
            border-bottom: 1px solid var(--nl-border-subtle) !important;
            padding: var(--nl-pad-header) !important;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .card-title,
        .nl-card-title {
            font-size: 15px !important;
            font-weight: 600 !important;
            color: var(--nl-text) !important;
            margin: 0 !important;
            letter-spacing: -0.2px;
        }

        .card-body,
        .nl-card-body {
            padding: var(--nl-pad-card) !important;
        }

        /* 3. Global KPI Cards */
        .kpi-card {
            background: var(--nl-surface) !important;
            border: 1px solid var(--nl-border) !important;
            box-shadow: var(--nl-shadow-card) !important;
            border-radius: var(--nl-radius-md) !important;
            padding: 20px 22px !important;
            display: flex;
            align-items: center;
            gap: 16px;
            height: 100%;
            transition: transform 180ms ease, box-shadow 180ms ease, border-color 180ms ease;
        }

        .kpi-card:hover {
            transform: translateY(-1px);
            box-shadow: var(--nl-shadow-hover) !important;
            border-color: var(--nl-border-hover) !important;
        }

        .kpi-icon-wrap {
            width: 46px;
            height: 46px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            flex-shrink: 0;
        }
        .kpi-icon-wrap.orange { background: var(--nl-primary-subtle); color: var(--nl-primary); }
        .kpi-icon-wrap.blue   { background: var(--nl-info-bg); color: var(--nl-info); }
        .kpi-icon-wrap.green  { background: var(--nl-success-bg); color: var(--nl-success); }
        .kpi-icon-wrap.yellow { background: var(--nl-warning-bg); color: var(--nl-warning); }
        .kpi-icon-wrap.red    { background: var(--nl-danger-bg); color: var(--nl-danger); }

        .kpi-label {
            font-size: 12.5px !important;
            color: var(--nl-text-muted) !important;
            font-weight: 500 !important;
            margin-bottom: 4px;
        }
        .kpi-val {
            font-size: 24px !important;
            font-weight: 700 !important;
            color: var(--nl-text) !important;
            line-height: 1.1;
        }

        /* 4. Global Data Tables */
        .table {
            margin-bottom: 0 !important;
            color: var(--nl-text) !important;
            vertical-align: middle;
        }

        .table thead th {
            background-color: var(--nl-surface-subtle) !important;
            color: var(--nl-text-muted) !important;
            font-size: 11.5px !important;
            font-weight: 600 !important;
            text-transform: uppercase !important;
            letter-spacing: 0.6px !important;
            padding: 12px 18px !important;
            border-bottom: 1px solid var(--nl-border) !important;
            border-top: none !important;
            white-space: nowrap;
        }

        .table tbody td {
            padding: 14px 18px !important;
            border-bottom: 1px solid var(--nl-border-subtle) !important;
            border-top: none !important;
            font-size: 13.5px !important;
            color: var(--nl-text) !important;
        }

        .table-hover tbody tr:hover td {
            background-color: #FAFCFE !important;
        }

        /* ==========================================================================
           5. GLOBAL PILL-SHAPED INPUT BOXES & ORANGE ACTIVE FOCUS
           ========================================================================== */
        .form-control,
        .form-select,
        .form-control-custom,
        .form-select-custom,
        .nl-form-control,
        .ts-control,
        input[type="text"],
        input[type="email"],
        input[type="password"],
        input[type="number"],
        input[type="tel"],
        input[type="search"],
        input[type="date"],
        input[type="datetime-local"],
        select.form-control,
        select.form-select {
            border: 1.5px solid #E2E8F0 !important;
            border-radius: 50px !important;
            padding: 10px 20px;
            font-size: 13.5px !important;
            color: #0F172A !important;
            background-color: #FFFFFF !important;
            transition: all 0.2s ease !important;
            min-height: 44px !important;
            outline: none !important;
        }

        
        /* Inputs with lead icons */
        .nl-text-input,
        .nl-form-control,
        .has-lead-icon input,
        .input-icon-wrap input {
            padding-left: 46px !important;
            padding-right: 44px !important;
        }

        /* Hover State */
        .form-control:hover,
        .form-select:hover,
        .form-control-custom:hover,
        .form-select-custom:hover,
        .nl-form-control:hover,
        .ts-control:hover,
        input[type="text"]:hover,
        input[type="email"]:hover,
        input[type="password"]:hover,
        input[type="number"]:hover,
        input[type="tel"]:hover,
        input[type="search"]:hover,
        input[type="date"]:hover {
            border-color: #CBD5E1 !important;
        }

        /* Active / Focus State: Vibrant Orange Border + Soft Orange Glow */
        .form-control:focus,
        .form-control:active,
        .form-select:focus,
        .form-select:active,
        .form-control-custom:focus,
        .form-control-custom:active,
        .form-select-custom:focus,
        .form-select-custom:active,
        .nl-form-control:focus,
        .nl-form-control:active,
        .ts-control.focus,
        .ts-wrapper.focus .ts-control,
        input[type="text"]:focus,
        input[type="text"]:active,
        input[type="email"]:focus,
        input[type="email"]:active,
        input[type="password"]:focus,
        input[type="password"]:active,
        input[type="number"]:focus,
        input[type="number"]:active,
        input[type="tel"]:focus,
        input[type="tel"]:active,
        input[type="search"]:focus,
        input[type="search"]:active,
        input[type="date"]:focus,
        input[type="date"]:active {
            border-color: #FC8019 !important;
            box-shadow: 0 0 0 3.5px rgba(252, 128, 25, 0.16) !important;
            outline: none !important;
            background-color: #FFFFFF !important;
        }

        /* TomSelect Pill Styling */
        .ts-wrapper.single .ts-control {
            border-radius: 50px !important;
            padding-left: 20px !important;
            padding-right: 36px !important;
            min-height: 44px !important;
            display: flex !important;
            align-items: center !important;
        }
        .ts-dropdown {
            border-radius: 16px !important;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1) !important;
            border: 1px solid #E2E8F0 !important;
            overflow: hidden !important;
            margin-top: 6px !important;
        }

        /* Multiline textarea pill-rounded */
        textarea.form-control,
        textarea.form-control-custom,
        textarea.nl-form-control {
            border-radius: 20px !important;
            padding: 14px 20px !important;
        }

                /* ==========================================================================
           6. GLOBAL PILL-SHAPED BUTTONS & REFINED SUBTLE HOVER ANIMATIONS
           ========================================================================== */
        .btn,
        button.btn,
        a.btn,
        .btn-primary,
        .btn-orange,
        .btn-secondary,
        .btn-outline-secondary,
        .btn-outline-primary,
        .btn-success,
        .btn-danger,
        .btn-info,
        .btn-light,
        .btn-cancel,
        .btn-confirm,
        .btn-submit,
        .btn-save,
        .btn-allocate,
        .btn-add-container,
        .btn-apply,
        .btn-book,
        .btn-reset,
        .btn-primary-custom,
        .btn-outline-custom,
        .btn-outline-nlog,
        .btn-nlog,
        .btn-dropdown-pill {
            border-radius: 50px !important;
            transition: transform 0.18s ease, box-shadow 0.18s ease, background-color 0.18s ease, border-color 0.18s ease, color 0.18s ease !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            gap: 7px !important;
            position: relative !important;
        }

        /* Subtle Hover Elevation (-1px gentle lift) */
        .btn:hover:not(:disabled),
        button.btn:hover:not(:disabled),
        a.btn:hover,
        .btn-primary:hover:not(:disabled),
        .btn-orange:hover:not(:disabled),
        .btn-secondary:hover,
        .btn-outline-secondary:hover,
        .btn-outline-primary:hover,
        .btn-success:hover:not(:disabled),
        .btn-danger:hover:not(:disabled),
        .btn-cancel:hover,
        .btn-confirm:hover:not(:disabled),
        .btn-submit:hover:not(:disabled),
        .btn-save:hover:not(:disabled),
        .btn-allocate:hover:not(:disabled),
        .btn-add-container:hover:not(:disabled),
        .btn-apply:hover:not(:disabled),
        .btn-book:hover:not(:disabled),
        .btn-primary-custom:hover:not(:disabled),
        .btn-outline-custom:hover,
        .btn-outline-nlog:hover,
        .btn-nlog:hover:not(:disabled) {
            transform: translateY(-1px) !important;
        }

        /* Active Click Press */
        .btn:active:not(:disabled),
        button.btn:active:not(:disabled),
        a.btn:active {
            transform: translateY(0) !important;
        }

        /* Very subtle icon micro-interaction */
        .btn i,
        button.btn i,
        a.btn i {
            transition: transform 0.18s ease !important;
        }
        .btn:hover:not(:disabled) i,
        button.btn:hover:not(:disabled) i,
        a.btn:hover i {
            transform: scale(1.05);
        }

        /* Primary / Orange Buttons: Gentle Swiggy Orange with subtle shadow */
        .btn-primary,
        .btn-orange,
        .btn-confirm,
        .btn-submit,
        .btn-primary-custom,
        .btn-nlog {
            background: linear-gradient(135deg, #FC8019 0%, #FF6600 100%) !important;
            border: 1px solid transparent !important;
            color: #FFFFFF !important;
            font-weight: 600 !important;
            box-shadow: 0 2px 6px rgba(252, 128, 25, 0.20) !important;
        }
        .btn-primary:hover:not(:disabled),
        .btn-orange:hover:not(:disabled),
        .btn-confirm:hover:not(:disabled),
        .btn-submit:hover:not(:disabled),
        .btn-primary-custom:hover:not(:disabled),
        .btn-nlog:hover:not(:disabled) {
            background: linear-gradient(135deg, #F97316 0%, #EA580C 100%) !important;
            box-shadow: 0 4px 12px rgba(252, 128, 25, 0.26) !important;
            color: #FFFFFF !important;
        }

        /* Secondary / Cancel / Outline Buttons */
        .btn-secondary,
        .btn-outline-secondary,
        .btn-cancel,
        .btn-outline-custom,
        .btn-outline-nlog {
            background: #FFFFFF !important;
            border: 1px solid #E2E8F0 !important;
            color: #475569 !important;
            font-weight: 500 !important;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.03) !important;
        }
        .btn-secondary:hover,
        .btn-outline-secondary:hover,
        .btn-cancel:hover,
        .btn-outline-custom:hover,
        .btn-outline-nlog:hover {
            background: #F8FAFC !important;
            border-color: #CBD5E1 !important;
            color: #0F172A !important;
            box-shadow: 0 2px 6px rgba(15, 23, 42, 0.06) !important;
        }

        /* Danger Buttons */
        .btn-danger {
            background: #EF4444 !important;
            border: 1px solid transparent !important;
            color: #FFFFFF !important;
            font-weight: 600 !important;
            box-shadow: 0 2px 6px rgba(239, 68, 68, 0.20) !important;
        }
        .btn-danger:hover:not(:disabled) {
            background: #DC2626 !important;
            box-shadow: 0 4px 10px rgba(239, 68, 68, 0.26) !important;
            color: #FFFFFF !important;
        }

        /* Success Buttons */
        .btn-success {
            background: #10B981 !important;
            border: 1px solid transparent !important;
            color: #FFFFFF !important;
            font-weight: 600 !important;
            box-shadow: 0 2px 6px rgba(16, 185, 129, 0.20) !important;
        }
        .btn-success:hover:not(:disabled) {
            background: #059669 !important;
            box-shadow: 0 4px 10px rgba(16, 185, 129, 0.26) !important;
            color: #FFFFFF !important;
        }

        /* Exceptions for icon-only & close buttons */
        .btn-close {
            border-radius: 50% !important;
            width: 30px !important;
            height: 30px !important;
            padding: 0 !important;
        }
        .btn-icon, .btn-icon-action {
            border-radius: 50% !important;
            width: 34px !important;
            height: 34px !important;
            padding: 0 !important;
        }

        /* 7. Global Modals */
        .modal-content {
            background-color: var(--nl-surface) !important;
            border: 1px solid var(--nl-border) !important;
            border-radius: var(--nl-radius-lg) !important;
            box-shadow: var(--nl-shadow-modal) !important;
            overflow: hidden;
        }

        .modal-header {
            padding: 18px 24px !important;
            border-bottom: 1px solid var(--nl-border-subtle) !important;
            background-color: var(--nl-surface) !important;
        }

        .modal-header .modal-title {
            font-size: 16px !important;
            font-weight: 700 !important;
            color: var(--nl-text) !important;
        }

        .modal-body {
            padding: 24px !important;
        }

        .modal-footer {
            padding: 16px 24px !important;
            border-top: 1px solid var(--nl-border-subtle) !important;
            background-color: var(--nl-surface-subtle) !important;
        }

        /* 8. Top Header Standard */
        .top-header {
            overflow: visible !important;
            height: 70px !important;
            background: #FFFFFF !important;
            border-bottom: 1px solid var(--nl-border) !important;
            box-shadow: var(--nl-shadow-xs) !important;
            padding: 0 32px !important;
            position: sticky !important;
            top: 0 !important;
            z-index: 999 !important;
        }

        :root {
            --brand-orange: #FC8019;
            --brand-orange-light: #FFF0E5;
            --text-dark: #282C3F;
            --text-muted: #686B78;
            --bg-light: #E5EBF2;
            --border-color: #E5E7EB;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-light);
            color: var(--text-dark);
            margin: 0;
        }

                /* Hide scrollbar for sidebar */
        .sidebar::-webkit-scrollbar {
            display: none;
        }
        .sidebar {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }

        /* Sidebar Styling */
        .sidebar {
            width: 260px;
            background: #fff;
            border-right: 1px solid var(--border-color);
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            overflow-y: auto;
            z-index: 1000;
        }
        
        .brand-logo {
            padding: 24px 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            border-bottom: 1px solid var(--border-color);
            margin-bottom: 16px;
        }
        
        .brand-logo .icon-box {
            background: var(--brand-orange);
            color: white;
            width: 36px;
            height: 36px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 20px;
            transform: rotate(45deg);
        }
        
        .brand-logo .icon-box span {
            transform: rotate(-45deg);
        }

        .brand-logo h5 {
            margin: 0;
            font-weight: 800;
            font-size: 16px;
            color: var(--text-dark);
            letter-spacing: 0.5px;
        }
        
        .brand-logo small {
            font-size: 11px;
            color: #9CA3AF;
            display: block;
        }

        .nav-section {
            padding: 0 16px;
        }

        .nav-item {
            margin-bottom: 8px;
        }

        .nav-link {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 12px 16px;
            color: #4B5563;
            border-radius: 12px;
            font-weight: 500;
            font-size: 14px;
            text-decoration: none;
            transition: all 0.2s ease;
        }
        
        .nav-link i.main-icon {
            font-size: 18px;
            width: 20px;
            text-align: center;
            color: #6B7280;
        }

        .nav-link:hover {
            background: #F9FAFB;
        }

        .nav-link.active-group {
            background: #FFF4ED;
            color: var(--brand-orange);
        }
        
        .nav-link.active-group i.main-icon {
            color: var(--brand-orange);
        }
        
        .nav-link .caret {
            margin-left: auto;
            font-size: 12px;
            color: var(--text-muted);
            transition: transform 0.3s ease;
        }
        
        /* Rotate caret when menu is open */
        .nav-link[aria-expanded="true"] .caret {
            transform: rotate(180deg);
        }
        
        .nav-link.active-group .caret {
            color: var(--brand-orange);
        }

        

        @keyframes fadeInSubnav {
            from { opacity: 0; transform: translateY(-4px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .sub-nav {
            list-style: none;
            padding-left: 52px;
            margin: 4px 0 16px 0;
        }

        .sub-nav li a {
            display: block;
            padding: 10px 0;
            color: #6B7280;
            font-size: 13.5px;
            text-decoration: none;
            position: relative;
        }
        
        .sub-nav li a::before {
            content: '•';
            position: absolute;
            left: -20px;
            font-size: 18px;
            color: #D1D5DB;
            top: 50%;
            transform: translateY(-50%);
        }

        .sub-nav li a:hover {
            color: var(--text-dark);
        }

        .sub-nav li a.active {
            color: var(--brand-orange);
            font-weight: 600;
        }
        
        .sub-nav li a.active::before {
            color: var(--brand-orange);
        }

        .help-card {
            margin: 32px 16px 20px 16px;
            padding: 20px 16px;
            background: #FFFBF9;
            border-radius: 16px;
            border: 1px solid #FFEBE0;
        }
        
        .help-card .help-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 8px;
        }
        
        .help-card .icon {
            color: var(--brand-orange);
            font-size: 24px;
        }
        
        .help-card h6 {
            margin: 0;
            font-weight: 700;
            color: var(--text-dark);
            font-size: 14px;
        }
        
        .help-card p {
            font-size: 12px;
            color: #6B7280;
            margin-bottom: 16px;
            line-height: 1.5;
        }
        
        .help-card .btn-support {
            display: block;
            width: 100%;
            text-align: center;
            background: #fff;
            color: var(--brand-orange);
            border: 1px solid #FFEBE0;
            border-radius: 8px;
            padding: 10px 0;
            font-weight: 600;
            font-size: 13px;
            text-decoration: none;
            transition: all 0.2s;
        }
        
        .help-card .btn-support:hover {
            border-color: var(--brand-orange);
            background: #FFF4ED;
        }

        /* Main Content Layout */
        .main-wrapper {
            margin-left: 260px;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* Top Header */
        .top-header {
            overflow: visible !important;
            height: 72px;
            background: #fff;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 32px;
            position: sticky;
            top: 0;
            z-index: 999;
        }

        /* ==========================================================================
           OMNIBOX GLOBAL SEARCH BAR & SUGGESTION PALETTE
           ========================================================================== */
        .search-bar {
            overflow: visible !important;
            position: relative;
            width: 420px;
            transition: width 0.25s cubic-bezier(0.16, 1, 0.3, 1);
        }
        .search-bar.is-focused {
            width: 480px;
        }

        .search-bar i.search-icon {
            position: absolute;
            left: 18px;
            top: 50%;
            transform: translateY(-50%);
            color: #94A3B8;
            font-size: 16px;
            pointer-events: none;
            transition: color 0.15s ease;
            z-index: 2;
        }
        .search-bar.is-focused i.search-icon {
            color: #FC8019;
        }

        .search-bar input {
            width: 100%;
            height: 44px;
            padding: 10px 68px 10px 44px !important;
            border: 1.5px solid #E2E8F0 !important;
            border-radius: 50px !important;
            font-size: 13.5px !important;
            font-weight: 500;
            color: #0F172A !important;
            background: #F8FAFC !important;
            outline: none !important;
            transition: all 0.2s ease !important;
        }
        .search-bar input:focus {
            background: #FFFFFF !important;
            border-color: #FC8019 !important;
            box-shadow: 0 0 0 3.5px rgba(252, 128, 25, 0.16) !important;
        }

        .search-clear-btn {
            position: absolute;
            right: 36px;
            top: 50%;
            transform: translateY(-50%);
            background: #E2E8F0;
            border: none;
            border-radius: 50%;
            width: 18px;
            height: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #64748B;
            font-size: 11px;
            cursor: pointer;
            padding: 0;
            transition: all 0.15s ease;
            z-index: 3;
        }
        .search-clear-btn:hover {
            background: #CBD5E1;
            color: #0F172A;
        }

        .search-bar .shortcut {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 11px;
            background: #FFFFFF;
            border: 1px solid #CBD5E1;
            color: #64748B;
            padding: 2px 7px;
            border-radius: 6px;
            font-weight: 700;
            pointer-events: none;
            line-height: 1.2;
            z-index: 2;
            box-shadow: 0 1px 2px rgba(0,0,0,0.04);
        }

        /* Omnibox Floating Suggestion Palette */
        .nl-search-dropdown {
            position: absolute;
            top: calc(100% + 8px);
            left: 0;
            width: 100%;
            min-width: 480px;
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 16px;
            box-shadow: 0 16px 40px rgba(15, 23, 42, 0.14);
            z-index: 1050;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            animation: omniboxFadeIn 0.18s cubic-bezier(0.16, 1, 0.3, 1) both;
        }

        @keyframes omniboxFadeIn {
            0% { opacity: 0; transform: translateY(-6px); }
            100% { opacity: 1; transform: translateY(0); }
        }

        .nl-search-header-hint {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 9px 16px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #94A3B8;
            background: #FAFAFA;
            border-bottom: 1px solid #F1F5F9;
        }
        .nl-search-header-hint span {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .nl-search-results-list {
            max-height: 330px;
            overflow-y: auto;
            padding: 6px;
            scroll-behavior: smooth;
        }
        .nl-search-results-list::-webkit-scrollbar {
            width: 5px;
        }
        .nl-search-results-list::-webkit-scrollbar-thumb {
            background: #CBD5E1;
            border-radius: 10px;
        }

        .nl-search-group-header {
            font-size: 10px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            color: #94A3B8;
            padding: 8px 12px 4px;
        }

        .nl-search-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 8px 12px;
            border-radius: 10px;
            cursor: pointer;
            text-decoration: none;
            color: #0F172A;
            transition: all 0.12s ease;
            margin-bottom: 2px;
        }
        .nl-search-item:hover,
        .nl-search-item.active-item {
            background: #FFF7ED;
            text-decoration: none;
            color: #0F172A;
        }

        .nl-search-item-left {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 0;
            flex: 1;
        }
        .nl-search-item-icon {
            width: 32px;
            height: 32px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 17px;
            flex-shrink: 0;
            transition: transform 0.15s ease;
        }
        .nl-search-item:hover .nl-search-item-icon,
        .nl-search-item.active-item .nl-search-item-icon {
            transform: scale(1.08);
        }

        .nl-search-item-icon.orange { background: #FFF2EB; color: #FC8019; }
        .nl-search-item-icon.blue   { background: #EFF6FF; color: #2563EB; }
        .nl-search-item-icon.green  { background: #ECFDF5; color: #059669; }
        .nl-search-item-icon.purple { background: #FAF5FF; color: #7C3AED; }
        .nl-search-item-icon.red    { background: #FEF2F2; color: #DC2626; }
        .nl-search-item-icon.slate  { background: #F1F5F9; color: #475569; }

        .nl-search-item-content {
            min-width: 0;
            flex: 1;
        }
        .nl-search-item-title {
            font-size: 13px;
            font-weight: 600;
            color: #0F172A;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            line-height: 1.25;
        }
        .nl-search-mark {
            background: #FEF08A;
            color: #854D0E;
            font-weight: 700;
            padding: 0 1px;
            border-radius: 2px;
        }
        .nl-search-item-sub {
            font-size: 11.5px;
            color: #64748B;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            margin-top: 1px;
        }

        .nl-search-item-right {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-shrink: 0;
            margin-left: 12px;
        }
        .nl-search-item-badge {
            font-size: 10.5px;
            font-weight: 600;
            padding: 2px 7px;
            border-radius: 5px;
            background: #F1F5F9;
            color: #475569;
        }
        .nl-search-item.active-item .nl-search-item-badge {
            background: #FFEDD5;
            color: #C2410C;
        }
        .nl-search-item i.item-arrow {
            font-size: 13px;
            color: #94A3B8;
            transition: transform 0.15s ease, color 0.15s ease;
        }
        .nl-search-item:hover i.item-arrow,
        .nl-search-item.active-item i.item-arrow {
            color: #FC8019;
            transform: translateX(2px);
        }

        .nl-search-empty {
            padding: 28px 16px;
            text-align: center;
            color: #64748B;
            font-size: 13px;
        }
        .nl-search-empty i {
            font-size: 26px;
            color: #94A3B8;
            margin-bottom: 8px;
            display: block;
        }

        .nl-search-footer-bar {
            background: #F8FAFC;
            border-top: 1px solid #F1F5F9;
            padding: 8px 16px;
            display: flex;
            align-items: center;
            gap: 16px;
            font-size: 11px;
            color: #64748B;
        }
        .nl-search-footer-bar kbd {
            background: #FFFFFF;
            border: 1px solid #CBD5E1;
            box-shadow: 0 1px 1px rgba(0,0,0,0.05);
            padding: 1px 5px;
            border-radius: 4px;
            font-family: inherit;
            font-size: 10px;
            font-weight: 700;
            color: #334155;
        }

        .header-actions {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .header-icon {
            position: relative;
            color: var(--text-muted, #64748B);
            font-size: 19px;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 34px;
            height: 34px;
            border-radius: 8px;
            transition: all 0.2s ease;
        }
        .header-icon:hover {
            color: var(--text-main, #0F172A);
            background: #F1F5F9;
        }
        
        .badge-notification {
            position: absolute;
            top: -3px;
            right: -5px;
            background: #FC8019 !important;
            color: #FFFFFF !important;
            font-size: 10px !important;
            font-weight: 700 !important;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif !important;
            line-height: 1 !important;
            min-width: 18px !important;
            height: 18px !important;
            padding: 0 4px !important;
            border-radius: 9px !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            text-align: center !important;
            border: 2px solid #FFFFFF !important;
            box-shadow: 0 2px 4px rgba(252, 128, 25, 0.4) !important;
            pointer-events: none !important;
            box-sizing: border-box !important;
            white-space: nowrap !important;
            letter-spacing: -0.02em !important;
        }
        
        .notif-bell-wrap { position: relative; }
        .notif-dropdown-panel {
            position: absolute;
            top: calc(100% + 14px);
            right: -10px;
            width: 410px;
            max-height: 520px;
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 16px;
            box-shadow: 0 20px 45px -10px rgba(15, 23, 42, 0.18), 0 0 0 1px rgba(15, 23, 42, 0.05);
            z-index: 999999;
            display: none;
            flex-direction: column;
            overflow: hidden;
            animation: notifPanelFadeIn 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        }
        @keyframes notifPanelFadeIn {
            from { opacity: 0; transform: translateY(-8px) scale(0.98); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
        .notif-dropdown-panel.show { display: flex; }
        .notif-dropdown-header {
            padding: 16px 18px;
            background: #FAFAFC;
            border-bottom: 1px solid #E2E8F0;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .notif-head-title {
            font-size: 14px;
            font-weight: 700;
            color: #0F172A;
            letter-spacing: -0.01em;
        }
        .notif-badge-pill {
            font-size: 11px;
            font-weight: 700;
            color: #FC8019;
            background: #FFF7ED;
            border: 1px solid #FFEDD5;
            padding: 2px 8px;
            border-radius: 20px;
        }
        .notif-mark-read-btn {
            background: transparent;
            border: none;
            font-size: 12px;
            font-weight: 600;
            color: #64748B;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 4px;
            transition: color 0.15s ease;
            padding: 4px 6px;
            border-radius: 6px;
        }
        .notif-mark-read-btn:hover {
            color: #FC8019;
            background: rgba(252, 128, 25, 0.06);
        }
        .notif-dropdown-list {
            padding: 10px;
            overflow-y: auto;
            max-height: 380px;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .notif-dropdown-list::-webkit-scrollbar { width: 5px; }
        .notif-dropdown-list::-webkit-scrollbar-thumb {
            background: #CBD5E1;
            border-radius: 4px;
        }
        .notif-card-item {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            padding: 12px 14px;
            border-radius: 12px;
            text-decoration: none;
            color: inherit;
            background: #FFFFFF;
            border: 1px solid #F1F5F9;
            transition: all 0.18s ease;
            position: relative;
        }
        .notif-card-item:hover {
            background: #F8FAFC;
            border-color: #E2E8F0;
            box-shadow: 0 4px 12px -2px rgba(15, 23, 42, 0.06);
            transform: translateY(-1px);
        }
        .notif-card-icon {
            width: 38px;
            height: 38px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 17px;
            flex-shrink: 0;
            margin-top: 1px;
        }
        .notif-card-icon.warning {
            background: #FFFBEB;
            color: #D97706;
            border: 1px solid #FDE68A;
        }
        .notif-card-icon.danger {
            background: #FEF2F2;
            color: #DC2626;
            border: 1px solid #FECACA;
        }
        .notif-card-icon.info {
            background: #EFF6FF;
            color: #2563EB;
            border: 1px solid #BFDBFE;
        }
        .notif-card-icon.success {
            background: #ECFDF5;
            color: #059669;
            border: 1px solid #A7F3D0;
        }
        .notif-card-body {
            flex: 1;
            min-width: 0;
        }
        .notif-meta-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            margin-bottom: 3px;
        }
        .notif-cat-tag {
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            padding: 1px 7px;
            border-radius: 6px;
        }
        .notif-cat-tag.compliance {
            background: #FEF3C7;
            color: #92400E;
        }
        .notif-cat-tag.billing {
            background: #FEE2E2;
            color: #991B1B;
        }
        .notif-cat-tag.claims {
            background: #DBEAFE;
            color: #1E40AF;
        }
        .notif-cat-tag.general {
            background: #F1F5F9;
            color: #475569;
        }
        .notif-time-text {
            font-size: 11px;
            font-weight: 600;
            color: #64748B;
        }
        .notif-item-title {
            font-size: 13px;
            font-weight: 700;
            color: #1E293B;
            line-height: 1.35;
            margin-bottom: 3px;
        }
        .notif-item-msg {
            font-size: 12px;
            color: #475569;
            line-height: 1.45;
            word-break: break-word;
        }
        .notif-action-arrow {
            display: inline-flex;
            align-items: center;
            gap: 3px;
            font-size: 11.5px;
            font-weight: 700;
            color: #FC8019;
            margin-top: 4px;
            transition: gap 0.15s ease;
        }
        .notif-card-item:hover .notif-action-arrow {
            gap: 6px;
        }
        .notif-empty {
            padding: 36px 20px;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }
        .notif-empty-icon {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: #F1F5F9;
            color: #94A3B8;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            margin-bottom: 12px;
        }
        .notif-empty-title {
            font-size: 13.5px;
            font-weight: 700;
            color: #1E293B;
            margin-bottom: 4px;
        }
        .notif-empty-sub {
            font-size: 12px;
            color: #64748B;
            max-width: 250px;
            line-height: 1.4;
        }
        .notif-dropdown-footer {
            padding: 10px 16px;
            background: #FAFAFC;
            border-top: 1px solid #E2E8F0;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .notif-footer-link {
            font-size: 11.5px;
            font-weight: 600;
            color: #64748B;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: color 0.15s ease;
        }
        .notif-footer-link:hover { color: #FC8019; }

        /* Sidebar Alerts Dropdown Panel */
        .sidebar-alerts-menu {
            list-style: none;
            padding: 0;
            margin: 4px 0 10px 0;
            animation: fadeInSubnav 0.2s ease-in-out;
        }
        .sidebar-alerts-box {
            background: #FAFAFC;
            border: 1px solid #E5E7EB;
            border-radius: 12px;
            padding: 10px;
            max-height: 380px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .sidebar-alerts-box::-webkit-scrollbar { width: 4px; }
        .sidebar-alerts-box::-webkit-scrollbar-thumb { background: #CBD5E1; border-radius: 4px; }
        .sidebar-alerts-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-bottom: 8px;
            border-bottom: 1px solid #E5E7EB;
        }
        .sidebar-alerts-header-left {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .sidebar-alerts-title {
            font-size: 11px;
            font-weight: 700;
            color: #374151;
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }
        .sidebar-alerts-pill {
            font-size: 10px;
            font-weight: 700;
            color: #FC8019;
            background: #FFF7ED;
            border: 1px solid #FFEDD5;
            padding: 1px 6px;
            border-radius: 12px;
        }
        .sidebar-alerts-read-btn {
            background: transparent;
            border: none;
            font-size: 11px;
            font-weight: 600;
            color: #64748B;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 3px;
            padding: 2px 5px;
            border-radius: 4px;
            transition: all 0.15s ease;
        }
        .sidebar-alerts-read-btn:hover {
            color: #FC8019;
            background: rgba(252, 128, 25, 0.08);
        }
        .sidebar-alerts-list {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .sidebar-alert-card {
            display: flex;
            flex-direction: column;
            gap: 5px;
            padding: 9px 10px;
            border-radius: 10px;
            background: #FFFFFF;
            border: 1px solid #F1F5F9;
            text-decoration: none;
            color: inherit;
            transition: all 0.18s ease;
        }
        .sidebar-alert-card:hover {
            background: #F8FAFC;
            border-color: #FED7AA;
            box-shadow: 0 2px 8px rgba(15, 23, 42, 0.05);
            transform: translateY(-1px);
        }
        .sidebar-alert-card-top {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .sidebar-alert-card-top .notif-card-icon {
            width: 26px;
            height: 26px;
            font-size: 13px;
            border-radius: 6px;
            margin-top: 0;
        }
        .sidebar-alert-card-meta {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex: 1;
            min-width: 0;
        }
        .sidebar-alert-card-content {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }
        .sidebar-alert-card-content .notif-item-title {
            font-size: 11.5px;
            font-weight: 700;
            color: #1E293B;
            line-height: 1.3;
            margin-bottom: 2px;
        }
        .sidebar-alert-card-content .notif-item-msg {
            font-size: 11px;
            color: #475569;
            line-height: 1.35;
        }
        .sidebar-alert-card-content .notif-action-arrow {
            font-size: 10.5px;
            margin-top: 2px;
        }
        .sidebar-alert-empty {
            padding: 16px 8px;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 4px;
        }
        .sidebar-alert-empty-icon {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #F1F5F9;
            color: #94A3B8;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            margin-bottom: 2px;
        }
        .sidebar-alert-empty-title {
            font-size: 11.5px;
            font-weight: 700;
            color: #1E293B;
        }
        .sidebar-alert-empty-sub {
            font-size: 10.5px;
            color: #64748B;
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 12px;
            border-left: 1px solid var(--border-color);
            padding-left: 20px;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
        }

        .avatar {
            width: 36px;
            height: 36px;
            background: var(--brand-orange);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 14px;
        }
        
        .user-info h6 {
            margin: 0;
            font-size: 14px;
            font-weight: 600;
        }
        
        .user-info small {
            font-size: 11px;
            color: var(--text-muted);
        }

        /* Page Content */
        .content-area {
            padding: 32px;
            flex: 1;
        }
        
        /* Global Breadcrumb fix */
        .custom-breadcrumb {
            font-size: 13px;
            color: var(--text-muted);
            margin-bottom: 32px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .custom-breadcrumb a {
            color: var(--text-muted);
            text-decoration: none;
        }
        .custom-breadcrumb .active {
            color: var(--brand-orange);
        }
        .custom-breadcrumb-separator {
            font-size: 10px;
        }
    
        /* === PIXEL-PERFECT SIDEBAR CSS === */
        .sidebar {
            width: 275px;
            background: #FFFFFF;
            border-right: 1px solid #E5E7EB;
            height: 100vh;
            position: fixed;
            top: 0;
            left: 0;
            overflow-y: auto;
            overflow-x: hidden;
            padding: 20px 16px;
            z-index: 1000;
        }

        .sidebar::-webkit-scrollbar {
            width: 4px;
        }
        .sidebar::-webkit-scrollbar-thumb {
            background: #E5E7EB;
            border-radius: 4px;
        }

        .main-wrapper {
            margin-left: 275px;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .brand-logo-container {
            padding: 4px 0 20px 0;
            border-bottom: 1px solid #F3F4F6;
            margin-bottom: 16px;
        }

        .logo-circle {
            width: 42px;
            height: 42px;
            background: #FC8019;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #FFFFFF;
            font-weight: 800;
            font-size: 21px;
            box-shadow: 0 4px 10px rgba(252, 128, 25, 0.25);
            flex-shrink: 0;
        }

        .brand-title {
            font-weight: 800;
            font-size: 15px;
            letter-spacing: 0.5px;
            color: #111827;
            line-height: 1.2;
        }

        .brand-subtitle {
            font-size: 11px;
            color: #9CA3AF;
            display: block;
            font-weight: 500;
            line-height: 1.2;
            margin-top: 2px;
        }

        .sidebar-collapse-btn {
            background: #FFFFFF;
            border: 1px solid #E5E7EB;
            width: 32px;
            height: 32px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #6B7280;
            cursor: pointer;
            transition: all 0.2s;
            font-size: 16px;
            flex-shrink: 0;
        }

        .sidebar-collapse-btn:hover {
            background: #F9FAFB;
            color: #111827;
            border-color: #D1D5DB;
        }

        .dashboard-link {
            border-radius: 12px !important;
            padding: 12px 16px !important;
            color: #374151;
            font-weight: 500;
            transition: all 0.2s ease;
        }

        .dashboard-link i.main-icon {
            color: #4B5563;
        }

        .dashboard-link:hover,
        .dashboard-link.active {
            background: #FFF5EE !important;
            color: #FC8019 !important;
            font-weight: 600 !important;
        }

        .dashboard-link:hover i.main-icon,
        .dashboard-link.active i.main-icon {
            color: #FC8019 !important;
        }

        .sidebar-section-header {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 18px 8px 8px 8px;
            font-size: 11px;
            font-weight: 700;
            color: #4B5563;
            letter-spacing: 0.8px;
            text-transform: uppercase;
        }

        .sidebar-section-header::after {
            content: '';
            flex: 1;
            height: 1px;
            background: #E5E7EB;
        }

        .nav-link {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 10px 14px;
            color: #374151;
            border-radius: 10px;
            font-weight: 500;
            font-size: 14px;
            text-decoration: none;
            transition: all 0.2s ease;
        }

        .nav-link:hover {
            background-color: #F9FAFB;
            color: #FC8019;
        }

        .nav-link.active,
        .nav-link.active-group {
            color: #FC8019;
            font-weight: 600;
        }

        .nav-link i.main-icon {
            font-size: 19px;
            color: #4B5563;
            transition: color 0.2s ease;
            width: 22px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            stroke-width: 1.75;
            flex-shrink: 0;
        }

        .nav-link:hover i.main-icon,
        .nav-link.active i.main-icon,
        .nav-link.active-group i.main-icon {
            color: #FC8019 !important;
        }

        .nav-link .caret {
            margin-left: auto;
            font-size: 14px;
            color: #6B7280;
            transition: transform 0.25s ease;
            flex-shrink: 0;
        }

        .nav-link[aria-expanded="true"] .caret {
            transform: rotate(180deg);
        }

        .nav-link.active-group .caret {
            color: #FC8019;
        }

        .sub-nav {
            list-style: none;
            padding-left: 48px;
            margin: 2px 0 8px 0;
            animation: fadeInSubnav 0.2s ease-in-out;
        }

        .sub-nav li a {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 6px 0;
            color: #4B5563;
            font-size: 13.5px;
            text-decoration: none;
            transition: color 0.15s ease;
        }

        .sub-nav li a::before {
            content: '•';
            color: #D1D5DB;
            font-size: 16px;
            line-height: 0;
            transition: color 0.15s ease;
        }

        .sub-nav li a:hover,
        .sub-nav li a.active {
            color: #FC8019;
            font-weight: 500;
        }

        .sub-nav li a.active::before {
            color: #FC8019;
        }

        .badge-alerts {
            background: #FFF0E6;
            color: #FC8019;
            font-weight: 700;
            font-size: 11px;
            padding: 2px 8px;
            border-radius: 20px;
            margin-left: auto;
        }

        .help-card {
            margin: 24px 0 14px 0;
            padding: 16px;
            background: #FFF9F6;
            border-radius: 16px;
            border: 1px solid #FFE8DD;
        }

        .help-icon-circle {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: #FFF0E6;
            color: #FC8019;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            flex-shrink: 0;
        }

        .help-title {
            font-weight: 700;
            font-size: 13.5px;
            color: #111827;
        }

        .help-subtitle {
            font-size: 11px;
            color: #6B7280;
            display: block;
            margin-top: 1px;
        }

        .btn-support {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            width: 100%;
            background: #FFFFFF;
            color: #FC8019;
            border: 1px solid #FFD4C2;
            border-radius: 10px;
            padding: 9px 0;
            font-weight: 600;
            font-size: 13px;
            text-decoration: none;
            transition: all 0.2s ease;
            margin-top: 10px;
        }

        .btn-support:hover {
            background: #FC8019;
            color: #FFFFFF;
            border-color: #FC8019;
        }

        .dark-mode-card {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 14px;
            background: #FFFFFF;
            border: 1px solid #E5E7EB;
            border-radius: 12px;
            margin-bottom: 24px;
        }

        .dark-mode-text {
            font-size: 13px;
            font-weight: 500;
            color: #374151;
        }

        .form-check-input:checked {
            background-color: #FC8019;
            border-color: #FC8019;
        }

    
        /* TomSelect Theme Integration & Glitch Prevention */
        select.tomselected,
        .tomselected {
            display: none !important;
        }

        .ts-wrapper,
        .ts-wrapper.form-control,
        .ts-wrapper.form-select,
        .ts-wrapper.form-control-custom,
        .ts-wrapper.form-select-custom,
        .ts-wrapper.nl-form-control {
            width: 100% !important;
            border: none !important;
            padding: 0 !important;
            background: transparent !important;
            background-image: none !important;
            box-shadow: none !important;
            min-height: auto !important;
        }

        .ts-control {
            border: 1px solid #E2E5EA !important;
            border-radius: 8px !important;
            padding: 10px 14px !important;
            font-size: 13.5px !important;
            color: #1F2937 !important;
            background-color: #FFFFFF !important;
            min-height: 42px !important;
            box-shadow: none !important;
            transition: border-color 0.15s ease, box-shadow 0.15s ease !important;
        }

        .ts-control.focus,
        .ts-wrapper.focus .ts-control {
            border-color: #FC8019 !important;
            box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12) !important;
        }

        .ts-dropdown {
            border: 1px solid #E7E9ED !important;
            border-radius: 10px !important;
            box-shadow: 0 10px 25px rgba(15, 23, 42, 0.08), 0 4px 10px rgba(15, 23, 42, 0.04) !important;
            padding: 6px !important;
            background: #FFFFFF !important;
            margin-top: 4px !important;
            z-index: 100000000 !important;
            scrollbar-width: none !important;
            -ms-overflow-style: none !important;
        }

        .ts-dropdown .ts-dropdown-content {
            max-height: 340px !important;
            overflow-y: auto !important;
            scrollbar-width: none !important;
            -ms-overflow-style: none !important;
        }

        .ts-dropdown::-webkit-scrollbar,
        .ts-dropdown .ts-dropdown-content::-webkit-scrollbar {
            display: none !important;
            width: 0 !important;
            height: 0 !important;
            background: transparent !important;
        }

        .ts-dropdown .option {
            padding: 8px 12px !important;
            font-size: 13.5px !important;
            border-radius: 6px !important;
            color: #374151 !important;
            transition: all 0.12s ease !important;
        }

        .ts-dropdown .option:hover,
        .ts-dropdown .option.active {
            background-color: #FFF2EB !important;
            color: #FC8019 !important;
            font-weight: 600 !important;
        }

        /* ==========================================
           ENTERPRISE PAGINATION (SWIGGY ORANGE THEME)
           ========================================== */
        .nl-pagination-wrapper {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 16px;
            padding: 16px 24px;
            background: #FFFFFF;
            border-top: 1px solid #F1F3F6;
        }

        .nl-pagination-info {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 13px;
            color: #64748B;
        }

        .nl-pagination-info strong {
            color: #1F2937;
            font-weight: 700;
        }

        .nl-page-size-select {
            padding: 4px 14px !important;
            font-size: 12.5px !important;
            font-weight: 600 !important;
            border-radius: 50px !important;
            border: 1.5px solid #E2E8F0 !important;
            background-color: #FFFFFF !important;
            color: #374151 !important;
            cursor: pointer;
            outline: none;
            transition: border-color 0.15s ease, box-shadow 0.15s ease;
        }
                
        /* ==========================================================================
           GLOBAL AUTO-FLIP (DROPUP) FOR EDGE / VIEWPORT COLLISION DETECTION
           ========================================================================== */
        .ts-dropdown.ts-dropup {
            margin-top: 0 !important;
            margin-bottom: 4px !important;
            border-radius: 12px !important;
            box-shadow: 0 -10px 25px -5px rgba(0, 0, 0, 0.12), 0 -8px 10px -6px rgba(0, 0, 0, 0.08) !important;
            animation: dropUpIn 0.18s cubic-bezier(0.16, 1, 0.3, 1) !important;
        }
        .ts-dropdown.ts-dropup.nl-page-size-ts,
        .nl-page-size-ts .ts-dropdown.ts-dropup {
            border-radius: 10px !important;
            margin-top: 0 !important;
            margin-bottom: 4px !important;
            box-shadow: 0 -8px 24px rgba(0, 0, 0, 0.14) !important;
        }
        @keyframes dropUpIn {
            from { opacity: 0; transform: translateY(6px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* ==========================================================================
           GLOBAL PAGINATION ROWS-PER-PAGE TOMSELECT DROPDOWN
           ========================================================================== */
        .ts-wrapper.nl-page-size-ts {
            width: 72px !important;
            min-width: 72px !important;
            max-width: 76px !important;
            margin: 0 !important;
            display: inline-block !important;
            vertical-align: middle !important;
            border: none !important;
            background: transparent !important;
            padding: 0 !important;
        }
        .ts-wrapper.nl-page-size-ts .ts-control {
            height: 30px !important;
            min-height: 30px !important;
            padding: 2px 22px 2px 10px !important;
            font-size: 12.5px !important;
            font-weight: 600 !important;
            border-radius: 8px !important;
            border: 1.5px solid #E2E8F0 !important;
            background-color: #FFFFFF !important;
            color: #0F172A !important;
            cursor: pointer !important;
            display: flex !important;
            align-items: center !important;
            box-shadow: none !important;
            transition: all 0.15s ease !important;
        }
        .ts-wrapper.nl-page-size-ts:hover .ts-control {
            border-color: #CBD5E1 !important;
        }
        .ts-wrapper.nl-page-size-ts.focus .ts-control,
        .ts-wrapper.nl-page-size-ts.dropdown-active .ts-control {
            border-color: #FC8019 !important;
            box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.16) !important;
        }
        .ts-wrapper.nl-page-size-ts .ts-dropdown {
            width: 72px !important;
            min-width: 72px !important;
            max-width: 76px !important;
            border-radius: 10px !important;
            border: 1px solid #E2E8F0 !important;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12) !important;
            padding: 4px !important;
            margin-top: 4px !important;
            z-index: 100000000 !important;
            background: #FFFFFF !important;
        }
        .ts-wrapper.nl-page-size-ts .ts-dropdown .option {
            padding: 5px 8px !important;
            font-size: 12px !important;
            font-weight: 600 !important;
            border-radius: 6px !important;
            color: #334155 !important;
            text-align: center !important;
            cursor: pointer !important;
            transition: all 0.15s ease !important;
        }
        .ts-wrapper.nl-page-size-ts .ts-dropdown .option:hover,
        .ts-wrapper.nl-page-size-ts .ts-dropdown .option.active {
            background: #FFF3EA !important;
            color: #FC8019 !important;
        }
        .ts-wrapper.nl-page-size-ts .ts-dropdown .option.selected {
            background: #FC8019 !important;
            color: #FFFFFF !important;
        }

        .nl-page-size-select:focus {
            border-color: #FC8019 !important;
            box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.16) !important;
        }
                /* ==========================================================================
           GLOBAL PAGINATION ROWS-PER-PAGE TOMSELECT DROPDOWN
           ========================================================================== */
        .ts-wrapper.nl-page-size-ts {
            width: 72px !important;
            min-width: 72px !important;
            max-width: 76px !important;
            margin: 0 !important;
            display: inline-block !important;
            vertical-align: middle !important;
            border: none !important;
            background: transparent !important;
            padding: 0 !important;
        }
        .ts-wrapper.nl-page-size-ts .ts-control {
            height: 30px !important;
            min-height: 30px !important;
            padding: 2px 22px 2px 10px !important;
            font-size: 12.5px !important;
            font-weight: 600 !important;
            border-radius: 8px !important;
            border: 1.5px solid #E2E8F0 !important;
            background-color: #FFFFFF !important;
            color: #0F172A !important;
            cursor: pointer !important;
            display: flex !important;
            align-items: center !important;
            box-shadow: none !important;
            transition: all 0.15s ease !important;
        }
        .ts-wrapper.nl-page-size-ts:hover .ts-control {
            border-color: #CBD5E1 !important;
        }
        .ts-wrapper.nl-page-size-ts.focus .ts-control,
        .ts-wrapper.nl-page-size-ts.dropdown-active .ts-control {
            border-color: #FC8019 !important;
            box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.16) !important;
        }
        .ts-wrapper.nl-page-size-ts .ts-dropdown {
            width: 72px !important;
            min-width: 72px !important;
            max-width: 76px !important;
            border-radius: 10px !important;
            border: 1px solid #E2E8F0 !important;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12) !important;
            padding: 4px !important;
            margin-top: 4px !important;
            z-index: 100000000 !important;
            background: #FFFFFF !important;
        }
        .ts-wrapper.nl-page-size-ts .ts-dropdown .option {
            padding: 5px 8px !important;
            font-size: 12px !important;
            font-weight: 600 !important;
            border-radius: 6px !important;
            color: #334155 !important;
            text-align: center !important;
            cursor: pointer !important;
            transition: all 0.15s ease !important;
        }
        .ts-wrapper.nl-page-size-ts .ts-dropdown .option:hover,
        .ts-wrapper.nl-page-size-ts .ts-dropdown .option.active {
            background: #FFF3EA !important;
            color: #FC8019 !important;
        }
        .ts-wrapper.nl-page-size-ts .ts-dropdown .option.selected {
            background: #FC8019 !important;
            color: #FFFFFF !important;
        }

        .nl-page-size-select:focus {
            border-color: #FC8019 !important;
            box-shadow: 0 0 0 2px rgba(252, 128, 25, 0.12) !important;
        }

        /* Swiggy Orange Custom Theme Select (Zero-Bug, 100% Reliable Native Component) */
        .form-select-custom,
        select.form-select.no-custom-select,
        select.form-select-custom.no-custom-select {
            height: 40px !important;
            border: 1px solid #E2E8F0 !important;
            border-radius: 8px !important;
            padding: 8px 36px 8px 14px !important;
            font-size: 13.5px !important;
            font-weight: 500 !important;
            color: #1F2937 !important;
            background-color: #FFFFFF !important;
            appearance: none !important;
            -webkit-appearance: none !important;
            -moz-appearance: none !important;
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23FC8019' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e") !important;
            background-repeat: no-repeat !important;
            background-position: right 14px center !important;
            background-size: 12px 10px !important;
            transition: border-color 0.15s ease, box-shadow 0.15s ease !important;
            cursor: pointer !important;
            outline: none !important;
        }
        .form-select-custom:focus,
        select.form-select.no-custom-select:focus,
        select.form-select-custom.no-custom-select:focus {
            border-color: #FC8019 !important;
            box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12) !important;
            outline: none !important;
        }

        .nl-pagination-nav {
            display: flex;
            align-items: center;
            gap: 6px;
            list-style: none;
            margin: 0;
            padding: 0;
        }

        /* ============================================================
           GLOBAL CIRCULAR & PILL ENTERPRISE PAGINATION
           ============================================================ */
        .nl-pagination-nav,
        .pagination,
        .pagination-container {
            display: flex;
            align-items: center;
            gap: 6px;
            list-style: none;
            margin: 0;
            padding: 0;
        }

        /* Default Pill-shaped navigation buttons (< Prev, Next >) */
        .nl-page-btn,
        .pagination .page-link,
        .page-item .page-link,
        .pagination-container button {
            min-width: 36px;
            height: 36px;
            padding: 0 16px;
            border-radius: 50px !important;
            border: 1.5px solid #E2E8F0;
            background: #FFFFFF;
            color: #4B5563;
            font-size: 13px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 5px;
            cursor: pointer;
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            user-select: none;
            text-decoration: none;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.03);
        }

        /* Pure Circular for Numeric Page Buttons (1, 2, 3, 4, 5, 11...) */
        .nl-page-btn.nl-page-num,
        .nl-page-btn:not(:has(i)):not(:has(svg)):not(.nl-page-nav-btn),
        .pagination .page-item:not(:first-child):not(:last-child) .page-link,
        .pagination-container button:not(:first-child):not(:last-child) {
            width: 36px !important;
            min-width: 36px !important;
            max-width: 36px !important;
            height: 36px !important;
            padding: 0 !important;
            border-radius: 50% !important;
        }

        /* Explicit Nav Buttons (< Prev, Next >) */
        .nl-page-btn.nl-page-nav-btn,
        .nl-page-btn:has(i),
        .nl-page-btn:has(svg),
        .pagination .page-item:first-child .page-link,
        .pagination .page-item:last-child .page-link {
            border-radius: 50px !important;
            padding: 0 16px !important;
            width: auto !important;
            min-width: 36px !important;
        }

        .nl-page-btn:hover:not(.disabled):not(.active),
        .pagination .page-link:hover,
        .pagination-container button:hover:not(:disabled) {
            background: #FFF0E5;
            color: #FC8019;
            border-color: #FED7AA;
            transform: translateY(-1px);
            box-shadow: 0 4px 10px rgba(252, 128, 25, 0.15);
        }

        .nl-page-btn.active,
        .pagination .page-item.active .page-link,
        .pagination-container button.active {
            background: #FC8019 !important;
            color: #FFFFFF !important;
            border-color: #FC8019 !important;
            font-weight: 700 !important;
            box-shadow: 0 2px 8px rgba(252, 128, 25, 0.35) !important;
            cursor: default;
        }

        .nl-page-btn.disabled,
        .pagination .page-item.disabled .page-link,
        .pagination-container button:disabled {
            opacity: 0.45;
            cursor: not-allowed;
            pointer-events: none;
            background: #F8FAFC;
            color: #94A3B8;
            border-color: #E2E8F0;
            box-shadow: none;
        }

        .nl-page-ellipsis,
        .pagination .page-item span.page-link {
            min-width: 28px;
            height: 36px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #94A3B8;
            font-size: 14px;
            font-weight: 700;
        }

        .ts-wrapper.single .ts-control:after {
            border-color: #6B7280 transparent transparent transparent !important;
            right: 14px !important;
        }

        /* Remove default number input spinner toggle buttons across all browsers */
        input[type="number"]::-webkit-outer-spin-button,
        input[type="number"]::-webkit-inner-spin-button {
            -webkit-appearance: none !important;
            margin: 0 !important;
        }
        input[type="number"] {
            -moz-appearance: textfield !important;
            appearance: textfield !important;
        }


    
        /* Global Circular User Profile & Tenant Avatars */
        .avatar,
        .user-avatar,
        .customer-avatar,
        .company-avatar,
        .user-profile .avatar,
        .top-header .avatar {
            border-radius: 50% !important;
            overflow: hidden !important;
        }


        /* ==========================================================
           MODERN CHART SURFACES  (presentation only — no data logic)
           Paired with /assets/js/nl-chart-theme.js
           ========================================================== */
        .chart-card,
        .nl-chart-card {
            position: relative;
        }
        /* Subtle brand wash behind every chart panel */
        .chart-card::before,
        .nl-chart-card::before {
            content: "";
            position: absolute;
            inset: 0 0 auto 0;
            height: 120px;
            background: linear-gradient(180deg, rgba(252, 128, 25, 0.045) 0%, rgba(252, 128, 25, 0) 100%);
            border-radius: var(--nl-radius-md) var(--nl-radius-md) 0 0;
            pointer-events: none;
        }
        .chart-card > *,
        .nl-chart-card > * { position: relative; z-index: 1; }

        /* Canvases: crisp, never squashed, never overflowing their card */
        .chart-card canvas,
        .nl-chart-card canvas,
        .card-body > canvas,
        .chart-wrap > canvas,
        .chart-wrap-sm > canvas,
        .status-canvas-wrap > canvas {
            max-width: 100% !important;
            display: block;
        }

        /* Default responsive height when a page gives a canvas no wrapper */
        .nl-chart-box {
            position: relative;
            width: 100%;
            height: 300px;
        }
        .nl-chart-box-sm { height: 220px; }
        .nl-chart-box-lg { height: 380px; }

        /* Chart panel headers — tighter, more editorial */
        .chart-card .card-header,
        .nl-chart-card .card-header {
            background: transparent !important;
            border-bottom: 1px solid var(--nl-border-subtle) !important;
        }
        .chart-card .card-header h5,
        .chart-card .card-header h6,
        .nl-chart-card .card-header h5,
        .nl-chart-card .card-header h6 {
            font-weight: 700;
            letter-spacing: -0.01em;
            color: var(--nl-text);
            margin: 0;
        }

        /* Legend chips rendered as HTML next to charts */
        .nl-chart-legend {
            display: flex;
            flex-wrap: wrap;
            gap: 8px 18px;
            padding: 10px 2px 0;
        }
        .nl-chart-legend span {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            font-size: 11.5px;
            font-weight: 600;
            color: var(--nl-text-secondary);
        }
        .nl-chart-legend span::before {
            content: "";
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: currentColor;
        }

        /* Empty-state overlay for charts with no rows yet */
        .nl-chart-empty {
            position: absolute;
            inset: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 6px;
            color: var(--nl-text-light);
            font-size: 12.5px;
            font-weight: 600;
            background: var(--nl-surface);
            border-radius: var(--nl-radius-sm);
        }

        @media (max-width: 767.98px) {
            .nl-chart-box { height: 240px; }
            .nl-chart-box-lg { height: 280px; }
        }


        /* ==========================================================
           CARD TOOLBAR — Export + Fullscreen on every card
           Paired with /assets/js/nl-card-tools.js
           ========================================================== */
        .nl-card-tools {
            display: inline-flex;
            gap: 4px;
            align-items: center;
            margin-left: auto;
            flex-shrink: 0;
        }
        .nl-card-anchor { position: relative; }
        .no-card-tools .nl-card-tools,
        [data-no-tools="true"] .nl-card-tools,
        .stats-container ~ .nl-card-tools,
        .card-panel:has(.stats-container) .nl-card-tools {
            display: none !important;
        }
        .nl-card-tools-floating {
            position: absolute;
            top: 12px;
            right: 12px;
            z-index: 3;
        }
        .nl-card-tool {
            width: 28px;
            height: 28px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: var(--nl-radius-xs, 6px);
            border: 1px solid transparent;
            background: transparent;
            color: var(--nl-text-light, #94A3B8);
            cursor: pointer;
            font-size: 15px;
            line-height: 1;
            padding: 0;
            transition: background 140ms ease, color 140ms ease, border-color 140ms ease;
        }
        .nl-card-tool:hover {
            background: var(--nl-primary-subtle, #FFF2EB);
            border-color: var(--nl-primary-border, #FFD4C2);
            color: var(--nl-primary, #FC8019);
        }
        .nl-card-tool:focus-visible {
            outline: 2px solid var(--nl-primary, #FC8019);
            outline-offset: 1px;
        }

        /* Fallback "maximised" mode when the Fullscreen API is unavailable */
        .nl-card-maximised {
            position: fixed !important;
            inset: 16px !important;
            z-index: 10000 !important;
            margin: 0 !important;
            overflow: auto !important;
            box-shadow: var(--nl-shadow-modal, 0 16px 40px rgba(15,23,42,.18)) !important;
        }
        body.nl-card-maximised-open { overflow: hidden; }

        /* Native fullscreen: cards are transparent by default, so paint a ground */
        .card:fullscreen, .nl-card:fullscreen, .card-panel:fullscreen,
        .chart-card:fullscreen, .table-card:fullscreen, .nl-chart-card:fullscreen {
            background: var(--nl-surface, #FFFFFF);
            padding: 24px;
            overflow: auto;
        }
        .card:fullscreen canvas, .chart-card:fullscreen canvas,
        .nl-chart-card:fullscreen canvas, .card-panel:fullscreen canvas {
            max-height: 78vh !important;
        }

        @media print { .nl-card-tools { display: none !important; } }

    </style>
</head>
<body>
    <c:if test="${empty requestScope.hideSidebar and not empty sessionScope.user}">
        <aside class="sidebar">
        <!-- Brand Header -->
        <div class="brand-logo-container d-flex align-items-center justify-content-between">
            <div class="d-flex align-items-center gap-3">
                <div class="logo-circle">
                    <span>N</span>
                </div>
                <div>
                    <div class="brand-title">N LOGISTIC</div>
                    <span class="brand-subtitle">Global Logistics Solution</span>
                </div>
            </div>
            <button class="sidebar-collapse-btn" title="Collapse Sidebar">
                <i class="ti ti-chevrons-left"></i>
            </button>
        </div>

        <div class="nav-section">
        <c:choose>

        <%-- ============================================================
             ROLE 5 - DEDICATED CUSTOMER PORTAL (CLAUDE.md S6.1.1)
             Every internal operations, finance, stock, pricing, barcode
             and governance menu is suppressed entirely.
             ============================================================ --%>
        <c:when test="${sessionScope.user.roleId == 5}">

            <div class="nav-item mb-2">
                <a href="${pageContext.request.contextPath}/dashboard" class="nav-link dashboard-link">
                    <i class="ti ti-smart-home main-icon"></i>
                    <span>My Dashboard</span>
                </a>
            </div>

            <div class="sidebar-section-header">
                <span>SHIPPING &amp; CARGO</span>
            </div>

            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/containers" class="nav-link ${pageContext.request.requestURI.contains('/containers') ? 'active' : ''}">
                    <i class="ti ti-box main-icon"></i>
                    <span>Container Catalog</span>
                </a>
            </div>
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/shipments/create" class="nav-link ${pageContext.request.requestURI.contains('/create') ? 'active' : ''}">
                    <i class="ti ti-plus main-icon"></i>
                    <span>Book Shipment</span>
                </a>
            </div>
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/shipments" class="nav-link ${pageContext.request.requestURI.endsWith('/shipments') ? 'active' : ''}">
                    <i class="ti ti-truck main-icon"></i>
                    <span>My Shipments</span>
                </a>
            </div>
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/shipments/tracking" class="nav-link ${pageContext.request.requestURI.contains('/tracking') ? 'active' : ''}">
                    <i class="ti ti-map-pin main-icon"></i>
                    <span>Live Tracking</span>
                </a>
            </div>

            <div class="sidebar-section-header">
                <span>BILLING &amp; CLAIMS</span>
            </div>

            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/invoices" class="nav-link ${pageContext.request.requestURI.contains('/invoices') ? 'active' : ''}">
                    <i class="ti ti-receipt main-icon"></i>
                    <span>Invoices &amp; Payments</span>
                </a>
            </div>
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/claims" class="nav-link ${pageContext.request.requestURI.contains('/claims') ? 'active' : ''}">
                    <i class="ti ti-shield main-icon"></i>
                    <span>Loss &amp; Damage Claims</span>
                </a>
            </div>
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/compliance" class="nav-link ${pageContext.request.requestURI.contains('/compliance') ? 'active' : ''}">
                    <i class="ti ti-file-check main-icon"></i>
                    <span>My Documents</span>
                </a>
            </div>

            <!-- Customer Alerts -->
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/alerts" class="nav-link ${pageContext.request.requestURI.contains('/alerts') ? 'active' : ''}">
                    <i class="ti ti-bell main-icon"></i>
                    <span>Alerts</span>
                    <span class="badge-alerts" id="sidebarCustAlertsBadge" style="display:none;">0</span>
                </a>
            </div>
        </c:when>

        <%-- ============================================================
             ROLES 1-4 - INTERNAL MANAGEMENT CONSOLE
             ============================================================ --%>
        <c:otherwise>

            <!-- Dashboard Link (Top Pill Card) -->
            <c:if test="${empty sessionScope.user || sessionScope.user.hasPermission('dashboard')}">
            <div class="nav-item mb-2">
                <a href="${pageContext.request.contextPath}/dashboard" class="nav-link dashboard-link">
                    <i class="ti ti-smart-home main-icon"></i>
                    <span>Dashboard</span>
                </a>
            </div>
            </c:if>

            <!-- SECTION 1: OPERATIONS -->
            <c:if test="${sessionScope.user.hasPermission('shipments') || sessionScope.user.hasPermission('tracking')}">
            <div class="sidebar-section-header">
                <span>OPERATIONS</span>
            </div>
            </c:if>

            <!-- Shipments Dropdown -->
            <c:if test="${sessionScope.user.hasPermission('shipments')}">
            <div class="nav-item">
                <a href="javascript:void(0);" data-target="shipmentsSubmenu" class="nav-link sidebar-dropdown-toggle ${pageContext.request.requestURI.contains('/shipment') || pageContext.request.requestURI.contains('/finance') ? 'active' : 'collapsed'}">
                    <i class="ti ti-truck main-icon"></i>
                    <span>Shipments</span>
                    <i class="ti ti-chevron-down caret"></i>
                </a>
                <ul class="sub-nav" id="shipmentsSubmenu" style="${pageContext.request.requestURI.contains('/shipment') || pageContext.request.requestURI.contains('/finance') ? 'display: block;' : 'display: none;'}">
                    <li><a href="${pageContext.request.contextPath}/shipments" class="${pageContext.request.requestURI.endsWith('/shipments') || pageContext.request.requestURI.contains('/shipments.jsp') ? 'active' : ''}">All Shipments</a></li>
                    <%-- Finance staff do not create bookings --%>
                    <c:if test="${sessionScope.user.roleId <= 3}">
                        <li><a href="${pageContext.request.contextPath}/shipments/create" class="${pageContext.request.requestURI.contains('/create') ? 'active' : ''}">Create Shipment</a></li>
                    </c:if>
                    <c:if test="${sessionScope.user.hasPermission('tracking')}">
                        <li><a href="${pageContext.request.contextPath}/shipments/tracking" class="${pageContext.request.requestURI.contains('/tracking') ? 'active' : ''}">Live Tracking</a></li>
                    </c:if>
                    <%-- Cost structure and margins: Admins + Finance only + PLG permission --%>
                    <c:if test="${(sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2 || sessionScope.user.roleId == 4) && sessionScope.user.hasPermission('plg')}">
                        <li><a href="${pageContext.request.contextPath}/finance/profit-loss" class="${pageContext.request.requestURI.contains('/profit-loss') ? 'active' : ''}">Profit &amp; Loss Analytics</a></li>
                    </c:if>
                </ul>
            </div>
            </c:if>

            <!-- Containers Dropdown -->
            <c:if test="${sessionScope.user.hasPermission('tracking')}">
            <div class="nav-item">
                <a href="javascript:void(0);" data-target="containersSubmenu" class="nav-link sidebar-dropdown-toggle collapsed">
                    <i class="ti ti-box main-icon"></i>
                    <span>Containers</span>
                    <i class="ti ti-chevron-down caret"></i>
                </a>
                <ul class="sub-nav" id="containersSubmenu" style="display: none;">
                    <li><a href="${pageContext.request.contextPath}/containers">All Containers</a></li>
                    <%-- Pricing engine internals are hidden from Operations --%>
                    <c:if test="${(sessionScope.user.roleId <= 2 || sessionScope.user.roleId == 4) && sessionScope.user.hasPermission('settings')}">
                        <li><a href="${pageContext.request.contextPath}/pricing">Pricing &amp; Rate Governance</a></li>
                        <li><a href="${pageContext.request.contextPath}/predictive-graph">Predictive Pricing Graph</a></li>
                    </c:if>
                </ul>
            </div>

            <!-- Vessels -->
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/jsp/vessels.jsp" class="nav-link">
                    <i class="ti ti-ship main-icon"></i>
                    <span>Vessels</span>
                </a>
            </div>

            <!-- Ports -->
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/ports" class="nav-link">
                    <i class="ti ti-anchor main-icon"></i>
                    <span>Ports</span>
                </a>
            </div>
            </c:if>


            <!-- SECTION 2: MANAGEMENT -->
            <c:if test="${sessionScope.user.hasPermission('claims') || sessionScope.user.hasPermission('compliance') || sessionScope.user.hasPermission('invoicing') || sessionScope.user.hasPermission('inventory') || (sessionScope.user.roleId == 1 && sessionScope.user.hasPermission('users'))}">
            <div class="sidebar-section-header">
                <span>MANAGEMENT</span>
            </div>
            </c:if>

            <!-- Approvals Dropdown (Super Admin Only) -->
            <c:if test="${sessionScope.user.roleId == 1 && sessionScope.user.hasPermission('users')}">
            <div class="nav-item">
                <a href="javascript:void(0);" data-target="approvalsSubmenu" class="nav-link sidebar-dropdown-toggle collapsed">
                    <i class="ti ti-clipboard-check main-icon"></i>
                    <span>Approvals</span>
                    <i class="ti ti-chevron-down caret"></i>
                </a>
                <ul class="sub-nav" id="approvalsSubmenu" style="display: none;">
                    <li><a href="${pageContext.request.contextPath}/admin/companies">Company</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/customers">Customer</a></li>
                </ul>
            </div>
            </c:if>

            <!-- Claims Management -->
            <c:if test="${sessionScope.user.hasPermission('claims')}">
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/claims" class="nav-link ${pageContext.request.requestURI.contains('/claims') ? 'active' : ''}">
                    <i class="ti ti-shield main-icon"></i>
                    <span>Claims Management</span>
                </a>
            </div>
            </c:if>

            <!-- Compliance & Billing Dropdown -->
            <c:if test="${sessionScope.user.hasPermission('compliance') || sessionScope.user.hasPermission('invoicing')}">
            <div class="nav-item">
                <a href="javascript:void(0);" data-target="complianceSubmenu" class="nav-link sidebar-dropdown-toggle collapsed">
                    <i class="ti ti-shield-check main-icon"></i>
                    <span>Compliance &amp; Billing</span>
                    <i class="ti ti-chevron-down caret"></i>
                </a>
                <ul class="sub-nav" id="complianceSubmenu" style="display: none;">
                    <%-- Document handling is an Operations duty --%>
                    <c:if test="${sessionScope.user.roleId <= 3 && sessionScope.user.hasPermission('compliance')}">
                        <li><a href="${pageContext.request.contextPath}/compliance">Government Compliance</a></li>
                    </c:if>
                    <%-- Billing is an Admin/Finance duty --%>
                    <c:if test="${(sessionScope.user.roleId <= 2 || sessionScope.user.roleId == 4) && sessionScope.user.hasPermission('invoicing')}">
                        <li><a href="${pageContext.request.contextPath}/billing">Billing &amp; Invoices</a></li>
                        <li><a href="${pageContext.request.contextPath}/invoices">Invoices &amp; Statements</a></li>
                    </c:if>
                </ul>
            </div>
            </c:if>

            <%-- Stock, inventory and dock scanning: Admins + Operations only --%>
            <c:if test="${sessionScope.user.roleId <= 3 && sessionScope.user.hasPermission('inventory')}">
            <!-- Stock & Inventory Dropdown -->
            <div class="nav-item">
                <a href="javascript:void(0);" data-target="stockSubmenu" class="nav-link sidebar-dropdown-toggle collapsed">
                    <i class="ti ti-packages main-icon"></i>
                    <span>Stock &amp; Inventory</span>
                    <i class="ti ti-chevron-down caret"></i>
                </a>
                <ul class="sub-nav" id="stockSubmenu" style="display: none;">
                    <li><a href="${pageContext.request.contextPath}/upload-stock">Upload / Manage Stock</a></li>
                    <li><a href="${pageContext.request.contextPath}/inventory/products">Product Catalog</a></li>
                    <li><a href="${pageContext.request.contextPath}/inventory/stock">Stock Overview</a></li>
                    <li><a href="${pageContext.request.contextPath}/ledger">Inventory Ledger</a></li>
                </ul>
            </div>
            </c:if>

            <!-- Tracking & Scanning Dropdown -->
            <c:if test="${sessionScope.user.roleId <= 3 && sessionScope.user.hasPermission('tracking')}">
            <div class="nav-item">
                <a href="javascript:void(0);" data-target="barcodeSubmenu" class="nav-link sidebar-dropdown-toggle collapsed">
                    <i class="ti ti-barcode main-icon"></i>
                    <span>Tracking &amp; Scanning</span>
                    <i class="ti ti-chevron-down caret"></i>
                </a>
                <ul class="sub-nav" id="barcodeSubmenu" style="display: none;">
                    <li><a href="${pageContext.request.contextPath}/barcodes">Manage Barcodes</a></li>
                    <li><a href="${pageContext.request.contextPath}/scan-barcode">Scan Barcodes</a></li>
                </ul>
            </div>
            </c:if>

            <!-- SECTION 3: INSIGHTS & CONFIGURATION -->
            <c:if test="${sessionScope.user.hasPermission('dashboard') || sessionScope.user.hasPermission('users') || sessionScope.user.hasPermission('settings')}">
            <div class="sidebar-section-header">
                <span>INSIGHTS &amp; CONFIGURATION</span>
            </div>
            </c:if>

            <%-- The 5 analytical engines are managerial decision support --%>
            <c:if test="${sessionScope.user.roleId <= 2 && sessionScope.user.hasPermission('dashboard')}">
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/analytics" class="nav-link ${pageContext.request.requestURI.contains('/analytics') ? 'active' : ''}">
                    <i class="ti ti-chart-pie main-icon"></i>
                    <span>Analytics</span>
                </a>
            </div>
            </c:if>

            <!-- Alerts -->
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/alerts" class="nav-link ${pageContext.request.requestURI.contains('/alerts') ? 'active' : ''}">
                    <i class="ti ti-bell main-icon"></i>
                    <span>Alerts</span>
                    <span class="badge-alerts" id="sidebarAlertsBadge" style="display:none;">0</span>
                </a>
            </div>

            <!-- Staff & Roles Governance -->
            <c:if test="${(sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2) && sessionScope.user.hasPermission('users')}">
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/admin/users" class="nav-link">
                    <i class="ti ti-users main-icon"></i>
                    <span>Users &amp; Roles</span>
                </a>
            </div>

            <!-- Security & Audit Trail Governance (FR1.9) -->
            <div class="nav-item">
                <a href="javascript:void(0);" data-target="auditSubmenu" class="nav-link sidebar-dropdown-toggle collapsed">
                    <i class="ti ti-history main-icon"></i>
                    <span>Audit Logs</span>
                    <i class="ti ti-chevron-down caret"></i>
                </a>
                <ul class="sub-nav" id="auditSubmenu" style="display: none;">
                    <li><a href="${pageContext.request.contextPath}/admin/audit-logs">Logins &amp; Security</a></li>
                </ul>
            </div>
            </c:if>

            <c:if test="${sessionScope.user.hasPermission('settings')}">
            <!-- Settings -->
            <div class="nav-item">
                <a href="#" class="nav-link">
                    <i class="ti ti-settings main-icon"></i>
                    <span>Settings</span>
                </a>
            </div>
            </c:if>
        </c:otherwise>
        </c:choose>
        </div>

        <!-- Need Help? Card -->
        <div class="help-card">
            <div class="d-flex align-items-center gap-3">
                <div class="help-icon-circle">
                    <i class="ti ti-headset"></i>
                </div>
                <div>
                    <div class="help-title">Need Help?</div>
                    <span class="help-subtitle">Our support team is<br>available 24/7</span>
                </div>
            </div>
            <a href="#" class="btn-support">
                <span>Contact Support</span>
                <i class="ti ti-arrow-right"></i>
            </a>
        </div>

        <!-- Dark Mode Toggle Card -->
        <div class="dark-mode-card">
            <div class="d-flex align-items-center gap-2">
                <i class="ti ti-moon text-muted fs-5"></i>
                <span class="dark-mode-text">Dark Mode</span>
            </div>
            <div class="form-check form-switch mb-0">
                <input class="form-check-input" type="checkbox" id="darkModeSwitch" style="cursor: pointer;">
            </div>
        </div>

<script>
// Zero-Conflict Sidebar Controller (Active Link Detection + Accordion Toggle)
document.addEventListener('DOMContentLoaded', function() {
    let path = window.location.pathname;
    let links = Array.from(document.querySelectorAll('.sidebar a'));
    
    // 1. Highlight ONLY the active link matching the current URL
    let isDashboard = (path.endsWith('/dashboard') || path.endsWith('/dashboard.jsp') || path.endsWith('/NLogistic/') || path.endsWith('/NLogistic'));
    let dashLink = document.querySelector('.sidebar .dashboard-link');
    
    if (isDashboard && dashLink) {
        dashLink.classList.add('active');
    } else {
        if (dashLink) dashLink.classList.remove('active');
        
        let activeLink = links.find(link => {
            let href = link.getAttribute('href');
            return href && href !== '#' && href !== 'javascript:void(0);' && !link.classList.contains('dashboard-link') && path === href;
        });
        
        if (!activeLink) {
            activeLink = links.find(link => {
                let href = link.getAttribute('href');
                return href && href !== '#' && href !== 'javascript:void(0);' && !link.classList.contains('dashboard-link') && href !== '/NLogistic/' && path.startsWith(href);
            });
        }

        if (activeLink) {
            activeLink.classList.add('active');
            let parentSub = activeLink.closest('.sub-nav');
            if (parentSub) {
                parentSub.style.display = 'block';
                let parentToggle = document.querySelector('.sidebar a[data-target="' + parentSub.id + '"]');
                if (parentToggle) {
                    parentToggle.classList.remove('collapsed');
                    parentToggle.classList.add('active-group');
                    parentToggle.setAttribute('aria-expanded', 'true');
                }
            }
        }
    }

    // 2. Smooth Accordion Toggle Handler
    document.querySelectorAll('.sidebar .sidebar-dropdown-toggle').forEach(function(toggle) {
        toggle.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            let targetId = this.getAttribute('data-target');
            let target = document.getElementById(targetId);
            
            if (target) {
                let isOpen = (target.style.display === 'block');
                
                if (isOpen) {
                    // Close this submenu
                    target.style.display = 'none';
                    this.classList.add('collapsed');
                    this.setAttribute('aria-expanded', 'false');
                } else {
                    // Accordion: Close other open submenus
                    document.querySelectorAll('.sidebar .sub-nav').forEach(function(other) {
                        if (other.id !== targetId) {
                            other.style.display = 'none';
                            let otherToggle = document.querySelector('.sidebar a[data-target="' + other.id + '"]');
                            if (otherToggle) {
                                otherToggle.classList.add('collapsed');
                                otherToggle.setAttribute('aria-expanded', 'false');
                            }
                        }
                    });
                    
                    // Open clicked submenu
                    target.style.display = 'block';
                    this.classList.remove('collapsed');
                    this.setAttribute('aria-expanded', 'true');
                }
            }
        });
    });
});
</script>
    </aside>
    </c:if>

    <!-- Main Wrapper -->
    <main class="main-wrapper" style="<c:if test='${not empty requestScope.hideSidebar or empty sessionScope.user}'>margin-left: 0 !important; width: 100% !important; min-height: 100vh !important;</c:if>">

        <c:if test="${empty requestScope.hideTopHeader and empty requestScope.hideSidebar and not empty sessionScope.user}">
        <!-- Top Navbar -->
        <header class="top-header">
            <div class="search-bar" id="globalOmniboxWrap">
                <i class="ti ti-search search-icon"></i>
                <input type="text" id="globalOmniboxInput" placeholder="Search shipments, routes, containers, actions..." autocomplete="off" spellcheck="false">
                <button type="button" class="search-clear-btn" id="globalOmniboxClear" title="Clear search" style="display: none;">
                    <i class="ti ti-x"></i>
                </button>
                <span class="shortcut" id="globalOmniboxShortcut" title="Press / to search">/</span>

                <!-- Suggestion Dropdown Palette -->
                <div class="nl-search-dropdown" id="globalOmniboxDropdown" style="display: none;">
                    <div class="nl-search-header-hint">
                        <span><i class="ti ti-command"></i> Quick Navigation &amp; Actions</span>
                        <span>ESC to close</span>
                    </div>
                    <div class="nl-search-results-list" id="globalOmniboxResults"></div>
                    <div class="nl-search-footer-bar">
                        <span><kbd>&uarr;</kbd> <kbd>&darr;</kbd> Navigate</span>
                        <span><kbd>&crarr;</kbd> Open</span>
                        <span><kbd>ESC</kbd> Close</span>
                    </div>
                </div>
            </div>

            <div class="header-actions">
                <c:if test="${not empty sessionScope.user}">
                <div class="notif-bell-wrap" id="notifBellWrap">
                    <div class="header-icon" title="Notifications" id="notifBellIcon" onclick="toggleNotifDropdown(event)">
                        <i class="ti ti-bell"></i>
                        <div class="badge-notification" id="notifBadge" style="display:none;">0</div>
                    </div>
                    <div class="notif-dropdown-panel" id="notifDropdownPanel">
                        <div class="notif-dropdown-header">
                            <div class="d-flex align-items-center gap-2">
                                <span class="notif-head-title">Notifications</span>
                                <span class="notif-badge-pill" id="notifCountPill">0 New</span>
                            </div>
                            <button type="button" class="notif-mark-read-btn" onclick="markAllNotificationsRead(event)" title="Mark all notifications as read">
                                <i class="ti ti-checks"></i> Mark all read
                            </button>
                        </div>
                        <div class="notif-dropdown-list" id="notifDropdownList">
                            <div class="notif-empty">
                                <div class="notif-empty-icon"><i class="ti ti-bell-off"></i></div>
                                <div class="notif-empty-title">All Caught Up</div>
                                <div class="notif-empty-sub">No pending alerts, compliance expirations, or actions.</div>
                            </div>
                        </div>
                        <div class="notif-dropdown-footer">
                            <a href="${pageContext.request.contextPath}/alerts" class="notif-footer-link" style="color:#FC8019; font-weight:700;"><i class="ti ti-list-details"></i> View All Alerts Page</a>
                            <a href="${pageContext.request.contextPath}/compliance" class="notif-footer-link"><i class="ti ti-shield-check"></i> Compliance</a>
                        </div>
                    </div>
                </div>
                </c:if>
                <div class="header-icon" title="Help and Documentation">
                    <i class="ti ti-help"></i>
                </div>

                <c:if test="${not empty sessionScope.user}">
                    <a href="${pageContext.request.contextPath}/logout" class="user-profile" title="Click to Logout">
                        <div class="avatar">${sessionScope.user.username.length() >= 2 ? sessionScope.user.username.substring(0, 2).toUpperCase() : sessionScope.user.username.toUpperCase()}</div>
                        <div class="user-info">
                            <h6>${sessionScope.user.username}</h6>
                            <small>Logout</small>
                        </div>
                    </a>
                </c:if>
                <c:if test="${empty sessionScope.user}">
                    <a href="${pageContext.request.contextPath}/login" class="user-profile">
                        <div class="avatar">?</div>
                        <div class="user-info">
                            <h6>Guest</h6>
                            <small>Login</small>
                        </div>
                    </a>
                </c:if>
            </div>
        </header>
        </c:if>

<script>
(function() {
    const ctx = '${pageContext.request.contextPath}';

    // ---- Notification bell: poll /notifications every 30s (JSON), render dropdown ----
    function escapeHtml(str) {
        if (str == null) return '';
        return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    let dismissedNotifIds = new Set();
    try {
        const stored = sessionStorage.getItem('nl_dismissed_notifs');
        if (stored) dismissedNotifIds = new Set(JSON.parse(stored));
    } catch(e) {}

    window.markAllNotificationsRead = function(e) {
        if (e) e.stopPropagation();
        const badge = document.getElementById('notifBadge');
        const pill = document.getElementById('notifCountPill');
        const list = document.getElementById('notifDropdownList');
        const sbBadges = [document.getElementById('sidebarAlertsBadge'), document.getElementById('sidebarCustAlertsBadge')].filter(Boolean);
        const sbPills = [document.getElementById('sidebarAlertsPill'), document.getElementById('sidebarCustAlertsPill')].filter(Boolean);
        const sbLists = [document.getElementById('sidebarAlertsList'), document.getElementById('sidebarCustAlertsList')].filter(Boolean);

        if (window._currentNotifs && window._currentNotifs.length > 0) {
            window._currentNotifs.forEach(function(n) { dismissedNotifIds.add(n.id); });
            try { sessionStorage.setItem('nl_dismissed_notifs', JSON.stringify(Array.from(dismissedNotifIds))); } catch(err) {}
        }
        if (badge) badge.style.display = 'none';
        if (pill) pill.textContent = '0 New';
        sbBadges.forEach(function(b) { b.style.display = 'none'; b.textContent = '0'; });
        sbPills.forEach(function(p) { p.textContent = '0'; });

        if (list) {
            list.innerHTML = 
                '<div class="notif-empty">' +
                    '<div class="notif-empty-icon" style="background:#ECFDF5; color:#059669;"><i class="ti ti-circle-check"></i></div>' +
                    '<div class="notif-empty-title">All Caught Up</div>' +
                    '<div class="notif-empty-sub">All alerts have been marked as read.</div>' +
                '</div>';
        }
        const sbEmptyHtml = 
            '<div class="sidebar-alert-empty">' +
                '<div class="sidebar-alert-empty-icon" style="background:#ECFDF5; color:#059669;"><i class="ti ti-circle-check"></i></div>' +
                '<div class="sidebar-alert-empty-title">All Caught Up</div>' +
                '<div class="sidebar-alert-empty-sub">All alerts marked as read.</div>' +
            '</div>';
        sbLists.forEach(function(l) { l.innerHTML = sbEmptyHtml; });

        fetch(ctx + '/notifications?action=markAllRead', { credentials: 'same-origin' }).catch(function() {});
    };

    function renderNotifications(notifs) {
        const badge = document.getElementById('notifBadge');
        const pill = document.getElementById('notifCountPill');
        const list = document.getElementById('notifDropdownList');
        const sbBadges = [document.getElementById('sidebarAlertsBadge'), document.getElementById('sidebarCustAlertsBadge')].filter(Boolean);
        const sbPills = [document.getElementById('sidebarAlertsPill'), document.getElementById('sidebarCustAlertsPill')].filter(Boolean);
        const sbLists = [document.getElementById('sidebarAlertsList'), document.getElementById('sidebarCustAlertsList')].filter(Boolean);

        window._currentNotifs = notifs || [];
        const activeNotifs = (notifs || []).filter(function(n) { return !dismissedNotifIds.has(n.id); });
        const countText = activeNotifs.length > 9 ? '9+' : String(activeNotifs.length);

        if (activeNotifs.length === 0) {
            if (badge) badge.style.display = 'none';
            if (pill) pill.textContent = '0 New';
            sbBadges.forEach(function(b) { b.style.display = 'none'; b.textContent = '0'; });
            sbPills.forEach(function(p) { p.textContent = '0'; });

            if (list) {
                list.innerHTML = 
                    '<div class="notif-empty">' +
                        '<div class="notif-empty-icon"><i class="ti ti-bell-off"></i></div>' +
                        '<div class="notif-empty-title">All Caught Up</div>' +
                        '<div class="notif-empty-sub">No pending alerts, compliance expirations, or actions.</div>' +
                    '</div>';
            }
            const sbEmptyHtml = 
                '<div class="sidebar-alert-empty">' +
                    '<div class="sidebar-alert-empty-icon"><i class="ti ti-bell-off"></i></div>' +
                    '<div class="sidebar-alert-empty-title">All Caught Up</div>' +
                    '<div class="sidebar-alert-empty-sub">No pending alerts.</div>' +
                '</div>';
            sbLists.forEach(function(l) { l.innerHTML = sbEmptyHtml; });
            return;
        }

        if (badge) {
            badge.style.display = 'flex';
            badge.textContent = countText;
        }
        if (pill) pill.textContent = activeNotifs.length + ' New';

        sbBadges.forEach(function(b) {
            b.style.display = 'inline-block';
            b.textContent = countText;
        });
        sbPills.forEach(function(p) { p.textContent = String(activeNotifs.length); });

        if (list) {
            list.innerHTML = activeNotifs.map(function(n) {
                const link = n.link ? (ctx + n.link) : '#';
                const typeClass = escapeHtml(n.type || 'info');
                const iconClass = escapeHtml(n.icon || 'ti ti-bell');
                const cat = escapeHtml(n.category || 'General');
                const catClass = cat.toLowerCase();
                const timeAgo = escapeHtml(n.timeAgo || '');

                return '<a class="notif-card-item" href="' + link + '">' +
                       '  <div class="notif-card-icon ' + typeClass + '">' +
                       '    <i class="' + iconClass + '"></i>' +
                       '  </div>' +
                       '  <div class="notif-card-body">' +
                       '    <div class="notif-meta-row">' +
                       '      <span class="notif-cat-tag ' + catClass + '">' + cat + '</span>' +
                       (timeAgo ? '      <span class="notif-time-text">' + timeAgo + '</span>' : '') +
                       '    </div>' +
                       '    <div class="notif-item-title">' + escapeHtml(n.title) + '</div>' +
                       '    <div class="notif-item-msg">' + escapeHtml(n.message) + '</div>' +
                       '    <div class="notif-action-arrow">Review now <i class="ti ti-arrow-right"></i></div>' +
                       '  </div>' +
                       '</a>';
            }).join('');
        }

        if (sbLists.length > 0) {
            const sbHtml = activeNotifs.map(function(n) {
                const link = n.link ? (ctx + n.link) : '#';
                const typeClass = escapeHtml(n.type || 'info');
                const iconClass = escapeHtml(n.icon || 'ti ti-bell');
                const cat = escapeHtml(n.category || 'General');
                const catClass = cat.toLowerCase();
                const timeAgo = escapeHtml(n.timeAgo || '');

                return '<a class="sidebar-alert-card" href="' + link + '">' +
                       '  <div class="sidebar-alert-card-top">' +
                       '    <div class="notif-card-icon ' + typeClass + '">' +
                       '      <i class="' + iconClass + '"></i>' +
                       '    </div>' +
                       '    <div class="sidebar-alert-card-meta">' +
                       '      <span class="notif-cat-tag ' + catClass + '">' + cat + '</span>' +
                       (timeAgo ? '      <span class="notif-time-text">' + timeAgo + '</span>' : '') +
                       '    </div>' +
                       '  </div>' +
                       '  <div class="sidebar-alert-card-content">' +
                       '    <div class="notif-item-title">' + escapeHtml(n.title) + '</div>' +
                       '    <div class="notif-item-msg">' + escapeHtml(n.message) + '</div>' +
                       '    <div class="notif-action-arrow">Review now <i class="ti ti-arrow-right"></i></div>' +
                       '  </div>' +
                       '</a>';
            }).join('');
            sbLists.forEach(function(l) { l.innerHTML = sbHtml; });
        }
    }
    window.pollNotifications = function(onComplete) {
        fetch(ctx + '/notifications?_t=' + Date.now(), { credentials: 'same-origin', cache: 'no-store' })
            .then(function(res) { return res.ok ? res.json() : []; })
            .then(function(data) {
                renderNotifications(data);
                if (typeof window.onNotificationsPolled === 'function') {
                    try { window.onNotificationsPolled(data); } catch(err) { console.warn(err); }
                }
                if (typeof onComplete === 'function') onComplete(data);
            })
            .catch(function(err) {
                if (typeof onComplete === 'function') onComplete([]);
            });
    };
    window.toggleNotifDropdown = function(e) {
        if (e) e.stopPropagation();
        const panel = document.getElementById('notifDropdownPanel');
        if (!panel) return;
        panel.classList.toggle('show');
        if (panel.classList.contains('show')) window.pollNotifications();
    };
    document.addEventListener('click', function(e) {
        const wrap = document.getElementById('notifBellWrap');
        const panel = document.getElementById('notifDropdownPanel');
        if (wrap && panel && panel.classList.contains('show') && !wrap.contains(e.target)) {
            panel.classList.remove('show');
        }
    });
    // Auto-poll every 15s so notifications arrive and leave dynamically in background
    window.pollNotifications();
    setInterval(window.pollNotifications, 15000);

    const OMNIBOX_DATA = [
        // Shipments Module
        {
            title: "All Shipments",
            url: ctx + "/shipments",
            category: "Shipments & Logistics",
            subtitle: "View, filter and manage all ocean cargo shipments",
            keywords: "shipment shipments all list active booked ocean freight cargo shi",
            icon: "ti ti-package",
            color: "orange",
            badge: "Page"
        },
        {
            title: "Live Shipment Tracking",
            url: ctx + "/shipments/tracking",
            category: "Shipments & Logistics",
            subtitle: "Interactive vessel positions, real-time status & ETA telemetry",
            keywords: "live tracking track eta location map status shipment gps vessel shi",
            icon: "ti ti-navigation",
            color: "blue",
            badge: "Live"
        },
        {
            title: "Create New Shipment",
            url: ctx + "/shipments/create",
            category: "Shipments & Logistics",
            subtitle: "Book new containerized cargo shipment with route config",
            keywords: "create shipment new booking book add shipment cargo freight shi",
            icon: "ti ti-plus",
            color: "green",
            badge: "Action"
        },
        {
            title: "Shipment Financial Drilldown",
            url: ctx + "/shipments/drilldown",
            category: "Shipments & Logistics",
            subtitle: "Unit economics, cargo loss attribution & financial audit",
            keywords: "shipment drilldown financial loss profit audit margin revenue cost shi",
            icon: "ti ti-file-analytics",
            color: "purple",
            badge: "Audit"
        },

        // Analytics & Deep Sections (Top Shipping Routes & Top Loss Reasons)
        {
            title: "Top Shipping Routes",
            url: ctx + "/dashboard#top-routes-card",
            category: "Analytics & Widgets",
            subtitle: "Busiest global maritime shipping corridors & shipment share",
            keywords: "top shipping routes top routes busiest route shipping routes ocean transit rou top",
            icon: "ti ti-route",
            color: "orange",
            badge: "Widget",
            isAnchor: true,
            targetId: "top-routes-card"
        },
        {
            title: "Top Loss Reasons & P&L Analytics",
            url: ctx + "/finance/profit-loss",
            category: "Analytics & Widgets",
            subtitle: "Root-cause loss breakdown: Weather, Delays, Sea Traffic, Damaged Product",
            keywords: "top loss reasons loss reasons profit loss financial analytics damages delays weather sea traffic los top rea",
            icon: "ti ti-alert-triangle",
            color: "red",
            badge: "Finance"
        },
        {
            title: "Containers Overview Widget",
            url: ctx + "/dashboard#containers-overview-card",
            category: "Analytics & Widgets",
            subtitle: "Fleet breakdown: Dry, Reefer, Open Top, Flat Rack, Tank",
            keywords: "containers overview widget dashboard fleet share con",
            icon: "ti ti-chart-pie",
            color: "blue",
            badge: "Widget",
            isAnchor: true,
            targetId: "containers-overview-card"
        },
        {
            title: "Recent System Alerts",
            url: ctx + "/dashboard#recent-alerts-card",
            category: "Analytics & Widgets",
            subtitle: "Real-time audit log events, security warnings & status alerts",
            keywords: "alerts recent alerts audit log notifications security warnings",
            icon: "ti ti-bell",
            color: "orange",
            badge: "Widget",
            isAnchor: true,
            targetId: "recent-alerts-card"
        },

        // Containers & Operations
        {
            title: "Container Master Catalog",
            url: ctx + "/containers",
            category: "Containers & Operations",
            subtitle: "Container master fleet catalog, ISO dimensions & tare weights",
            keywords: "container containers catalog master fleet dry reefer tank flat rack con",
            icon: "ti ti-box",
            color: "blue",
            badge: "Catalog"
        },
        {
            title: "Allocate Container",
            url: ctx + "/allocate-container",
            category: "Containers & Operations",
            subtitle: "Dynamic pricing algorithm, seasonal multipliers & cargo capacity allocation",
            keywords: "allocate container allocation assign booking cargo capacity pricing con",
            icon: "ti ti-truck-loading",
            color: "orange",
            badge: "Pricing"
        },
        {
            title: "Inventory Movement Ledger",
            url: ctx + "/ledger",
            category: "Containers & Operations",
            subtitle: "Tamper-evident append-only ledger of container check-ins & releases",
            keywords: "ledger inventory movement history audit stock gate checkin release inv leg",
            icon: "ti ti-book",
            color: "purple",
            badge: "Ledger"
        },

        // Governance & Administration
        {
            title: "Company Approvals",
            url: ctx + "/admin/companies",
            category: "Administration",
            subtitle: "Super Admin verification & activation portal for new companies",
            keywords: "approvals approve company pending verification activate super admin app comp",
            icon: "ti ti-shield-check",
            color: "green",
            badge: "Super Admin"
        },
        {
            title: "Customer Approvals",
            url: ctx + "/admin/users",
            category: "Administration",
            subtitle: "Super Admin customer account clearance & KYC verification portal",
            keywords: "customer approvals customer verify activate approve user client onboarding kyc super admin cus",
            icon: "ti ti-user-check",
            color: "orange",
            badge: "Super Admin"
        },
        {
            title: "Audit Logs (Logins & Security)",
            url: ctx + "/admin/audit-logs",
            category: "Administration",
            subtitle: "Forensic audit trail of all logins, logouts, password resets and security events (FR1.9)",
            keywords: "audit logs security logins logouts forensic history authentication trail fr1.9",
            icon: "ti ti-history",
            color: "orange",
            badge: "Admin"
        },
        {
            title: "User Management & RBAC",
            url: ctx + "/users",
            category: "Administration",
            subtitle: "Manage staff accounts, user permissions and access control roles",
            keywords: "users user management staff rbac roles permissions accounts user",
            icon: "ti ti-users",
            color: "purple",
            badge: "Admin"
        },
        {
            title: "Executive Dashboard",
            url: ctx + "/dashboard",
            category: "Overview",
            subtitle: "Main enterprise command center and logistics telemetry",
            keywords: "dashboard home main executive kpi overview telemetry dash",
            icon: "ti ti-dashboard",
            color: "blue",
            badge: "Home"
        },
        {
            title: "My Account Profile",
            url: ctx + "/profile",
            category: "Account",
            subtitle: "User credentials, security password settings & personal preferences",
            keywords: "profile account settings password security user info prof",
            icon: "ti ti-user",
            color: "slate",
            badge: "Profile"
        }
    ];

    /* ------------------------------------------------------------------
       RBAC omnibox filter (CLAUDE.md S6.1.2).
       The command palette indexes every route in the app, so without this
       a Customer could search "profit" and jump straight to the P&L page.
       These rules mirror AuthenticationFilter.isAllowed() exactly - the
       server still enforces them; this only stops forbidden routes from
       ever being offered.
       ------------------------------------------------------------------ */
    (function filterOmniboxByRole() {
        if (typeof OMNIBOX_DATA === 'undefined') return;

        var role = parseInt('${sessionScope.user.roleId}', 10);
        if (isNaN(role)) return;

        var SUPER_ADMIN = 1, COMPANY_ADMIN = 2, OPERATIONS = 3, FINANCE = 4, CUSTOMER = 5;

        function allowed(url) {
            // Strip the context path and any query/hash so we compare bare routes.
            var path = String(url || '').replace(ctx, '').split('?')[0].split('#')[0];

            if (path.indexOf('/admin') === 0 || path.indexOf('/jsp/admin') === 0) {
                return role === SUPER_ADMIN;
            }
            if (path.indexOf('/dashboard/executive') === 0 || path.indexOf('/executive') === 0
                    || path.indexOf('/analytics') === 0) {
                return role <= COMPANY_ADMIN;
            }
            if (path.indexOf('/finance') === 0 || path.indexOf('/drilldown') > -1
                    || path.indexOf('/profit-loss') > -1) {
                return role === SUPER_ADMIN || role === COMPANY_ADMIN || role === FINANCE;
            }
            if (path.indexOf('/pricing') === 0 || path.indexOf('/predictive-graph') === 0) {
                return role <= COMPANY_ADMIN || role === FINANCE;
            }
            if (path.indexOf('/upload-stock') === 0 || path.indexOf('/stock') === 0
                    || path.indexOf('/manual-stock') === 0 || path.indexOf('/adjust-stock') === 0
                    || path.indexOf('/inventory') === 0 || path.indexOf('/ledger') === 0
                    || path.indexOf('/barcodes') === 0 || path.indexOf('/scan-barcode') === 0
                    || path.indexOf('/allocate') === 0) {
                return role <= OPERATIONS;
            }
            if (path.indexOf('/vessel') === 0 || path.indexOf('/ports') === 0
                    || path.indexOf('/customers') === 0) {
                return role <= FINANCE;
            }
            if (path.indexOf('/billing') === 0 || path.indexOf('/generate-invoice') === 0) {
                return role <= COMPANY_ADMIN || role === FINANCE;
            }
            if (path.indexOf('/invoices') === 0 || path.indexOf('/view-invoice') === 0) {
                return role !== OPERATIONS;
            }
            if (path.indexOf('/shipments/create') === 0) {
                return role !== FINANCE;
            }
            return true;
        }

        for (var i = OMNIBOX_DATA.length - 1; i >= 0; i--) {
            if (!allowed(OMNIBOX_DATA[i].url)) {
                OMNIBOX_DATA.splice(i, 1);
            }
        }
    })();

    function initOmnibox() {

        const wrap = document.getElementById('globalOmniboxWrap');
        const input = document.getElementById('globalOmniboxInput');
        const dropdown = document.getElementById('globalOmniboxDropdown');
        const results = document.getElementById('globalOmniboxResults');
        const clearBtn = document.getElementById('globalOmniboxClear');
        const shortcut = document.getElementById('globalOmniboxShortcut');

        if (!input || !dropdown) return;

        let activeIndex = -1;
        let currentFilteredItems = [];

        // Global '/' key listener to focus search
        document.addEventListener('keydown', function(e) {
            if (e.key === '/' && document.activeElement !== input) {
                const tag = document.activeElement ? document.activeElement.tagName.toLowerCase() : '';
                if (tag !== 'input' && tag !== 'textarea' && tag !== 'select') {
                    e.preventDefault();
                    input.focus();
                    input.select();
                }
            }
        });

        // Focus & Blur
                input.addEventListener('click', function() {
            wrap.classList.add('is-focused');
            renderSuggestions(input.value.trim());
            dropdown.style.setProperty('display', 'flex', 'important');
        });

        input.addEventListener('focus', function() {
            wrap.classList.add('is-focused');
            renderSuggestions(input.value.trim());
            dropdown.style.setProperty('display', 'flex', 'important');
        });

        // Input handler
        input.addEventListener('input', function() {
            const query = input.value.trim();
            if (query.length > 0) {
                clearBtn.style.display = 'flex';
                shortcut.style.display = 'none';
            } else {
                clearBtn.style.display = 'none';
                shortcut.style.display = 'block';
            }
            renderSuggestions(query);
            dropdown.style.setProperty('display', 'flex', 'important');
        });

        // Clear button
        clearBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            input.value = '';
            clearBtn.style.display = 'none';
            shortcut.style.display = 'block';
            input.focus();
            renderSuggestions('');
        });

        // Keyboard navigation inside dropdown
        input.addEventListener('keydown', function(e) {
            const items = results.querySelectorAll('.nl-search-item');
            if (items.length === 0) return;

            if (e.key === 'ArrowDown') {
                e.preventDefault();
                activeIndex = (activeIndex + 1) % items.length;
                updateActiveItem(items);
            } else if (e.key === 'ArrowUp') {
                e.preventDefault();
                activeIndex = (activeIndex - 1 + items.length) % items.length;
                updateActiveItem(items);
            } else if (e.key === 'Enter') {
                e.preventDefault();
                if (activeIndex >= 0 && activeIndex < currentFilteredItems.length) {
                    selectOmniboxItem(currentFilteredItems[activeIndex]);
                } else if (items.length > 0) {
                    selectOmniboxItem(currentFilteredItems[0]);
                }
            } else if (e.key === 'Escape') {
                dropdown.style.setProperty('display', 'none', 'important');
                wrap.classList.remove('is-focused');
                input.blur();
            }
        });

        // Close when clicking outside
        document.addEventListener('click', function(e) {
            if (!wrap.contains(e.target)) {
                dropdown.style.setProperty('display', 'none', 'important');
                wrap.classList.remove('is-focused');
            }
        });

        function updateActiveItem(itemElements) {
            itemElements.forEach((el, i) => {
                if (i === activeIndex) {
                    el.classList.add('active-item');
                    el.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
                } else {
                    el.classList.remove('active-item');
                }
            });
        }

        function highlightMatch(text, query) {
            if (!query) return text;
            const regex = new RegExp('(' + escapeRegex(query) + ')', 'gi');
            return text.replace(regex, '<mark class="nl-search-mark">$1</mark>');
        }

        function escapeRegex(str) {
            return str.split('').map(function(ch) {
                return ('\\^$*+?.()|{}[]'.indexOf(ch) !== -1) ? '\\' + ch : ch;
            }).join('');
        }

        function renderSuggestions(query) {
            activeIndex = -1;
            results.innerHTML = '';
            const q = query.toLowerCase();

            if (!q) {
                // Show featured navigation when input is empty
                currentFilteredItems = OMNIBOX_DATA.slice(0, 8);
            } else {
                currentFilteredItems = OMNIBOX_DATA.filter(item => {
                    return item.title.toLowerCase().includes(q) ||
                           item.keywords.toLowerCase().includes(q) ||
                           item.subtitle.toLowerCase().includes(q) ||
                           item.category.toLowerCase().includes(q);
                });

                // Sort: items whose title starts with query come first
                currentFilteredItems.sort((a, b) => {
                    const aStarts = a.title.toLowerCase().startsWith(q);
                    const bStarts = b.title.toLowerCase().startsWith(q);
                    if (aStarts && !bStarts) return -1;
                    if (!aStarts && bStarts) return 1;
                    return 0;
                });
            }

            if (currentFilteredItems.length === 0) {
                results.innerHTML = '<div class="nl-search-empty"><i class="ti ti-search-off"></i>No results found for "<strong>' + escapeHtml(query) + '</strong>"</div>';
                return;
            }

            // Group by category
            const groups = {};
            currentFilteredItems.forEach(item => {
                if (!groups[item.category]) groups[item.category] = [];
                groups[item.category].push(item);
            });

            let globalIdx = 0;
            for (const category in groups) {
                const groupTitle = document.createElement('div');
                groupTitle.className = 'nl-search-group-header';
                groupTitle.textContent = category;
                results.appendChild(groupTitle);

                groups[category].forEach(item => {
                    const itemEl = document.createElement('div');
                    itemEl.className = 'nl-search-item';
                    itemEl.dataset.index = globalIdx;

                    const highlightedTitle = highlightMatch(item.title, query);
                    const highlightedSub = highlightMatch(item.subtitle, query);

                    itemEl.innerHTML = 
                        '<div class="nl-search-item-left">' +
                            '<div class="nl-search-item-icon ' + item.color + '">' +
                                '<i class="' + item.icon + '"></i>' +
                            '</div>' +
                            '<div class="nl-search-item-content">' +
                                '<div class="nl-search-item-title">' + highlightedTitle + '</div>' +
                                '<div class="nl-search-item-sub">' + highlightedSub + '</div>' +
                            '</div>' +
                        '</div>' +
                        '<div class="nl-search-item-right">' +
                            '<span class="nl-search-item-badge">' + item.badge + '</span>' +
                            '<i class="ti ti-chevron-right item-arrow"></i>' +
                        '</div>';

                    itemEl.addEventListener('click', function(e) {
                        e.preventDefault();
                        selectOmniboxItem(item);
                    });

                    results.appendChild(itemEl);
                    globalIdx++;
                });
            }
        }

        function selectOmniboxItem(item) {
            dropdown.style.setProperty('display', 'none', 'important');
            wrap.classList.remove('is-focused');
            input.blur();

            if (item.isAnchor && item.targetId) {
                const isDashboard = window.location.pathname.endsWith('/dashboard') || window.location.pathname.endsWith('/dashboard/');
                if (isDashboard) {
                    const el = document.getElementById(item.targetId);
                    if (el) {
                        el.scrollIntoView({ behavior: 'smooth', block: 'center' });
                        el.classList.add('highlight-target');
                        setTimeout(() => el.classList.remove('highlight-target'), 2400);
                        history.pushState(null, null, '#' + item.targetId);
                        return;
                    }
                }
            }

            // Normal page navigation
            window.location.href = item.url;
        }

        function escapeHtml(str) {
            return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initOmnibox);
    } else {
        initOmnibox();
    }
})();

    /* Global Auto-Classifier for Circular Page Numbers & Pill Prev/Next */
    function autoClassifyPagination() {
        document.querySelectorAll('.nl-page-btn, .pagination .page-link, .page-item .page-link, .pagination-container button').forEach(function(btn) {
            var text = (btn.textContent || '').trim();
            if (/^\d+$/.test(text)) {
                btn.classList.add('nl-page-num');
                btn.classList.remove('nl-page-nav-btn');
            } else if (text.toLowerCase().indexOf('prev') !== -1 || text.toLowerCase().indexOf('next') !== -1 || btn.querySelector('i, svg')) {
                btn.classList.add('nl-page-nav-btn');
                btn.classList.remove('nl-page-num');
            }
        });
    }
    document.addEventListener('DOMContentLoaded', function() {
        autoClassifyPagination();
        var observer = new MutationObserver(function() {
            autoClassifyPagination();
        });
        observer.observe(document.body, { childList: true, subtree: true });
    });

</script>


        <!-- Form Area / Main Content Area -->
        <div class="content-area" <c:if test="${not empty requestScope.hideSidebar or empty sessionScope.user}">style="padding: 0 !important; width: 100% !important; min-height: 100vh !important;"</c:if>>
