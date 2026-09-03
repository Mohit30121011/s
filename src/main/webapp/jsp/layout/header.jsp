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
            background: #FFF5EE !important;
            color: #FC8019 !important;
            font-weight: 600 !important;
            border-radius: 12px !important;
            padding: 12px 16px !important;
        }

        .dashboard-link i.main-icon {
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

<link href="https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/css/tom-select.bootstrap5.min.css" rel="stylesheet">
<style>
    /* Custom Tom Select Styling */
    .ts-control {
        border: 1px solid var(--border-color) !important;
        border-radius: 8px !important;
        padding: 10px 16px !important;
        font-size: 13px !important;
        background: #fff !important;
        box-shadow: none !important;
    }
    .ts-control.focus {
        border-color: var(--brand-orange) !important;
        box-shadow: 0 0 0 0.25rem rgba(252, 128, 25, 0.25) !important;
    }
    .ts-dropdown {
        border-radius: 12px !important;
        border: 1px solid #E5E7EB !important;
        box-shadow: 0 10px 25px rgba(0,0,0,0.1) !important;
        margin-top: 8px !important;
        overflow: hidden !important;
    }
    .ts-dropdown .ts-dropdown-content::-webkit-scrollbar { display: none !important; }
    .ts-dropdown .ts-dropdown-content { -ms-overflow-style: none !important; scrollbar-width: none !important; padding: 8px 0 !important; }
    .ts-dropdown .option {
        padding: 10px 16px !important; font-size: 13px !important; color: var(--text-dark) !important; transition: background-color 0.2s !important;
    }
    .ts-dropdown .option:hover, .ts-dropdown .option.active {
        background-color: var(--brand-orange-light) !important; color: var(--brand-orange) !important; font-weight: 600 !important;
    }
    .ts-wrapper.single .ts-control:after {
        border-color: var(--text-muted) transparent transparent transparent !important;
        border-width: 5px 5px 0 5px !important;
        right: 16px !important;
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
            background: #FFF5EE !important;
            color: #FC8019 !important;
            font-weight: 600 !important;
            border-radius: 12px !important;
            padding: 12px 16px !important;
        }

        .dashboard-link i.main-icon {
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
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>

    <c:if test="${empty requestScope.hideSidebar}">
    <!-- Sidebar -->
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
    
    // 1. Highlight active child link and expand its parent
    let activeLink = links.find(link => {
        let href = link.getAttribute('href');
        return href && href !== '#' && href !== 'javascript:void(0);' && path === href;
    });
    
    if (!activeLink) {
        activeLink = links.find(link => {
            let href = link.getAttribute('href');
            return href && href !== '#' && href !== 'javascript:void(0);' && href !== '/NLogistic/' && path.startsWith(href);
        });
    }

    if (activeLink && !activeLink.classList.contains('dashboard-link')) {
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

    <!-- Main Content -->
    <main class="main-wrapper" <c:if test="${not empty requestScope.hideSidebar}">style="margin-left: 0;"</c:if>>
        
        <c:if test="${empty requestScope.hideSidebar}">
        <!-- Top Header -->
        <header class="top-header">
            <div class="header-left">
                <i class="fa-solid fa-bars fs-5 text-muted me-3" style="cursor: pointer;"></i>
                <div class="search-bar d-inline-block">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" placeholder="Search shipments, containers, vessels...">
                    <span class="shortcut">/</span>
                </div>
            </div>
            
            <div class="header-actions">
                <div class="header-icon">
                    <i class="fa-regular fa-bell"></i>
                    <div class="badge-notification">3</div>
                </div>
                <div class="header-icon">
                    <i class="fa-regular fa-circle-question"></i>
                </div>
                
                <c:if test="${not empty sessionScope.user}">
                    <a href="${pageContext.request.contextPath}/logout" class="user-profile">
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

        <!-- Form Area -->
        <div class="content-area">








