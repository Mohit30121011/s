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
            --nl-bg: #F8F9FB;
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

        body {
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

        /* 5. Global Form Controls */
        .form-control,
        .form-select {
            border: 1px solid #E2E5EA !important;
            border-radius: var(--nl-radius-sm) !important;
            padding: 9px 14px !important;
            font-size: 13.5px !important;
            color: var(--nl-text) !important;
            background-color: var(--nl-surface) !important;
            transition: border-color 150ms ease, box-shadow 150ms ease;
        }

        .form-control:hover,
        .form-select:hover {
            border-color: #D5D9DF !important;
        }

        .form-control:focus,
        .form-select:focus {
            border-color: var(--nl-primary) !important;
            box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12) !important;
            outline: none !important;
        }

        /* 6. Global Buttons */
        .btn-primary,
        .btn-orange {
            background-color: var(--nl-primary) !important;
            border-color: var(--nl-primary) !important;
            color: #FFFFFF !important;
            border-radius: 10px !important;
            padding: 8px 18px !important;
            font-size: 13.5px !important;
            font-weight: 600 !important;
            box-shadow: 0 1px 2px rgba(252, 128, 25, 0.15) !important;
            transition: all 150ms ease !important;
        }

        .btn-primary:hover,
        .btn-orange:hover {
            background-color: var(--nl-primary-hover) !important;
            border-color: var(--nl-primary-hover) !important;
            transform: translateY(-0.5px);
            box-shadow: 0 3px 8px rgba(252, 128, 25, 0.25) !important;
        }

        .btn-secondary,
        .btn-outline-secondary {
            background-color: var(--nl-surface) !important;
            border: 1px solid var(--nl-border) !important;
            color: var(--nl-text-secondary) !important;
            border-radius: 10px !important;
            padding: 8px 16px !important;
            font-size: 13.5px !important;
            font-weight: 500 !important;
            transition: all 150ms ease !important;
        }

        .btn-secondary:hover,
        .btn-outline-secondary:hover {
            background-color: var(--nl-surface-subtle) !important;
            border-color: var(--nl-border-hover) !important;
            color: var(--nl-text) !important;
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
            --bg-light: #F9FAFB;
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

        .search-bar {
            position: relative;
            width: 400px;
        }
        
        .search-bar i {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #9CA3AF;
        }
        
        .search-bar input {
            width: 100%;
            padding: 10px 16px 10px 40px;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            font-size: 14px;
            background: #F9FAFB;
            outline: none;
        }
        
        .search-bar .shortcut {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 11px;
            background: #E5E7EB;
            padding: 2px 6px;
            border-radius: 4px;
            color: var(--text-muted);
        }

        .header-actions {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .header-icon {
            position: relative;
            color: var(--text-muted);
            font-size: 18px;
            cursor: pointer;
        }
        
        .badge-notification {
            position: absolute;
            top: -6px;
            right: -6px;
            background: var(--brand-orange);
            color: white;
            font-size: 10px;
            width: 16px;
            height: 16px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            border: 2px solid white;
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

    </style>
</head>
<body>
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
            <!-- Dashboard Link (Top Pill Card) -->
            <div class="nav-item mb-2">
                <a href="${pageContext.request.contextPath}/dashboard" class="nav-link dashboard-link">
                    <i class="ti ti-smart-home main-icon"></i>
                    <span>Dashboard</span>
                </a>
            </div>

            <!-- SECTION 1: OPERATIONS -->
            <div class="sidebar-section-header">
                <span>OPERATIONS</span>
            </div>

            <!-- Shipments Dropdown -->
            <div class="nav-item">
                <a href="javascript:void(0);" data-target="shipmentsSubmenu" class="nav-link sidebar-dropdown-toggle collapsed">
                    <i class="ti ti-truck main-icon"></i>
                    <span>Shipments</span>
                    <i class="ti ti-chevron-down caret"></i>
                </a>
                <ul class="sub-nav" id="shipmentsSubmenu" style="display: none;">
                    <li><a href="${pageContext.request.contextPath}/shipments">All Shipments</a></li>
                    <li><a href="${pageContext.request.contextPath}/shipments/create">Create Shipment</a></li>
                    <li><a href="${pageContext.request.contextPath}/shipments/tracking">Live Tracking</a></li>
                </ul>
            </div>

            <!-- Containers Dropdown -->
            <div class="nav-item">
                <a href="javascript:void(0);" data-target="containersSubmenu" class="nav-link sidebar-dropdown-toggle collapsed">
                    <i class="ti ti-box main-icon"></i>
                    <span>Containers</span>
                    <i class="ti ti-chevron-down caret"></i>
                </a>
                <ul class="sub-nav" id="containersSubmenu" style="display: none;">
                    <li><a href="${pageContext.request.contextPath}/containers">All Containers</a></li>
                </ul>
            </div>

            <!-- Vessels Dropdown -->
            <div class="nav-item">
                <a href="javascript:void(0);" data-target="vesselsSubmenu" class="nav-link sidebar-dropdown-toggle collapsed">
                    <i class="ti ti-ship main-icon"></i>
                    <span>Vessels</span>
                    <i class="ti ti-chevron-down caret"></i>
                </a>
                <ul class="sub-nav" id="vesselsSubmenu" style="display: none;">
                    <li><a href="${pageContext.request.contextPath}/vessels">All Vessels</a></li>
                </ul>
            </div>

            <!-- Customers -->
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/customers" class="nav-link">
                    <i class="ti ti-users main-icon"></i>
                    <span>Customers</span>
                </a>
            </div>

            <!-- Ports -->
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/ports" class="nav-link">
                    <i class="ti ti-anchor main-icon"></i>
                    <span>Ports</span>
                </a>
            </div>

            <!-- Tracking -->
            <div class="nav-item">
                <a href="#" class="nav-link">
                    <i class="ti ti-map-pin main-icon"></i>
                    <span>Tracking</span>
                </a>
            </div>

            <!-- SECTION 2: MANAGEMENT -->
            <div class="sidebar-section-header">
                <span>MANAGEMENT</span>
            </div>

            <!-- Approvals Dropdown (Super Admin Only) -->
            <c:if test="${sessionScope.user.roleId == 1}">
            <div class="nav-item">
                <a href="javascript:void(0);" data-target="approvalsSubmenu" class="nav-link sidebar-dropdown-toggle collapsed">
                    <i class="ti ti-clipboard-check main-icon"></i>
                    <span>Approvals</span>
                    <i class="ti ti-chevron-down caret"></i>
                </a>
                <ul class="sub-nav" id="approvalsSubmenu" style="display: none;">
                    <li><a href="${pageContext.request.contextPath}/admin/companies">Company</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/users">Users</a></li>
                </ul>
            </div>
            </c:if>

            <!-- Claims Management -->
            <div class="nav-item">
                <a href="#" class="nav-link">
                    <i class="ti ti-shield main-icon"></i>
                    <span>Claims Management</span>
                </a>
            </div>

            <!-- Compliance & Billing Dropdown -->
            <div class="nav-item">
                <a href="javascript:void(0);" data-target="complianceSubmenu" class="nav-link sidebar-dropdown-toggle collapsed">
                    <i class="ti ti-shield-check main-icon"></i>
                    <span>Compliance & Billing</span>
                    <i class="ti ti-chevron-down caret"></i>
                </a>
                <ul class="sub-nav" id="complianceSubmenu" style="display: none;">
                    <li><a href="${pageContext.request.contextPath}/compliance">Government Compliance</a></li>
                    <li><a href="${pageContext.request.contextPath}/billing">Billing & Invoices</a></li>
                </ul>
            </div>

            <!-- Stock & Inventory Dropdown -->
            <div class="nav-item">
                <a href="javascript:void(0);" data-target="stockSubmenu" class="nav-link sidebar-dropdown-toggle collapsed">
                    <i class="ti ti-packages main-icon"></i>
                    <span>Stock & Inventory</span>
                    <i class="ti ti-chevron-down caret"></i>
                </a>
                <ul class="sub-nav" id="stockSubmenu" style="display: none;">
                    <li><a href="${pageContext.request.contextPath}/upload-stock">Upload / Manage Stock</a></li>
                    <li><a href="${pageContext.request.contextPath}/ledger">Inventory Ledger</a></li>
                </ul>
            </div>

            <!-- Tracking & Scanning Dropdown -->
            <div class="nav-item">
                <a href="javascript:void(0);" data-target="barcodeSubmenu" class="nav-link sidebar-dropdown-toggle collapsed">
                    <i class="ti ti-barcode main-icon"></i>
                    <span>Tracking & Scanning</span>
                    <i class="ti ti-chevron-down caret"></i>
                </a>
                <ul class="sub-nav" id="barcodeSubmenu" style="display: none;">
                    <li><a href="${pageContext.request.contextPath}/barcodes">Manage Barcodes</a></li>
                    <li><a href="${pageContext.request.contextPath}/scan-barcode">Scan Barcodes</a></li>
                </ul>
            </div>

            <!-- SECTION 3: INSIGHTS & CONFIGURATION -->
            <div class="sidebar-section-header">
                <span>INSIGHTS & CONFIGURATION</span>
            </div>

            <!-- Analytics -->
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/analytics" class="nav-link ${pageContext.request.requestURI.contains('/analytics') ? 'active' : ''}">
                    <i class="ti ti-chart-pie main-icon"></i>
                    <span>Analytics</span>
                </a>
            </div>

            <!-- Alerts -->
            <div class="nav-item">
                <a href="#" class="nav-link">
                    <i class="ti ti-bell main-icon"></i>
                    <span>Alerts</span>
                    <span class="badge-alerts">12</span>
                </a>
            </div>

            <!-- Settings -->
            <div class="nav-item">
                <a href="#" class="nav-link">
                    <i class="ti ti-settings main-icon"></i>
                    <span>Settings</span>
                </a>
            </div>
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

    <!-- Main Wrapper -->
    <main class="main-wrapper" <c:if test="${not empty requestScope.hideSidebar}">style="margin-left: 0;"</c:if>>

        <c:if test="${empty requestScope.hideTopHeader}">
        <!-- Top Navbar -->
        <header class="top-header">
            <div class="search-bar">
                <i class="ti ti-search"></i>
                <input type="text" placeholder="Search shipments, containers, vessels...">
                <span class="shortcut">/</span>
            </div>

            <div class="header-actions">
                <div class="header-icon" title="Notifications">
                    <i class="ti ti-bell"></i>
                    <div class="badge-notification">3</div>
                </div>
                <div class="header-icon" title="Help and Documentation">
                    <i class="ti ti-help"></i>
                </div>

                <c:if test="${not empty sessionScope.user}">
                    <a href="${pageContext.request.contextPath}/logout" class="user-profile" title="Click to Logout">
                        <div class="avatar">${sessionScope.user.username.substring(0, 2).toUpperCase()}</div>
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

        <!-- Form Area / Main Content Area -->
        <div class="content-area">
