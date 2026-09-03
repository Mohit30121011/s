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
    </style>
<script>
document.addEventListener("DOMContentLoaded", function() {
    let path = window.location.pathname;
    let links = Array.from(document.querySelectorAll('.sidebar a'));
    
    // Find exact match first
    let activeLink = links.find(link => {
        let href = link.getAttribute('href');
        return href && href !== '#' && path === href;
    });
    
    // Fallback: If no exact match (like /save), match startsWith
    if (!activeLink) {
        activeLink = links.find(link => {
            let href = link.getAttribute('href');
            return href && href !== '#' && href !== '/NLogistic/' && path.startsWith(href);
        });
    }

    if (activeLink) {
        activeLink.classList.add('active');
        let parentCollapse = activeLink.closest('.collapse');
        if (parentCollapse) {
            parentCollapse.classList.add('show');
        }
    }
});
</script>
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
</style>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>

    <c:if test="${empty requestScope.hideSidebar}">
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="brand-logo">
            <div class="icon-box"><span>N</span></div>
            <div>
                <h5>N LOGISTIC</h5>
                <small>Global Logistics Solution</small>
            </div>
        </div>

        <div class="nav-section">
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/dashboard" class="nav-link">
                    <i class="fa-solid fa-house main-icon"></i> Dashboard
                </a>
            </div>
            
            <c:if test="${sessionScope.user.roleId == 1}">
            <div class="nav-item">
                <a href="#approvalsSubmenu" data-bs-toggle="collapse" class="nav-link collapsed">
                    <i class="fa-solid fa-check-to-slot main-icon"></i> Approvals
                    <i class="fa-solid fa-angle-down caret"></i>
                </a>
                <ul class="sub-nav collapse" id="approvalsSubmenu">
                    <li><a href="${pageContext.request.contextPath}/admin/companies">Company</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/users">Users</a></li>
                </ul>
            </div>
            </c:if>
            
            <div class="nav-item">
                <a href="#shipmentsSubmenu" data-bs-toggle="collapse" aria-expanded="true" class="nav-link active-group">
                    <i class="fa-solid fa-truck-fast main-icon"></i> Shipments
                    <i class="fa-solid fa-angle-down caret"></i>
                </a>
                <ul class="sub-nav collapse show" id="shipmentsSubmenu">
                    <li><a href="${pageContext.request.contextPath}/shipments">All Shipments</a></li>
                    <li><a href="${pageContext.request.contextPath}/shipments/create" >Create Shipment</a></li>
                </ul>
            </div>
            
            <div class="nav-item">
                <a href="#containersSubmenu" data-bs-toggle="collapse" class="nav-link collapsed">
                    <i class="fa-solid fa-box main-icon"></i> Containers
                    <i class="fa-solid fa-angle-down caret"></i>
                </a>
                <ul class="sub-nav collapse" id="containersSubmenu">
                    <li><a href="${pageContext.request.contextPath}/containers">All Containers</a></li>
                </ul>
            </div>
            
            <div class="nav-item">
                <a href="#vesselsSubmenu" data-bs-toggle="collapse" class="nav-link collapsed">
                    <i class="fa-solid fa-ship main-icon"></i> Vessels
                    <i class="fa-solid fa-angle-down caret"></i>
                </a>
                <ul class="sub-nav collapse" id="vesselsSubmenu">
                    <li><a href="${pageContext.request.contextPath}/vessels">All Vessels</a></li>
                </ul>
            </div>
            
            <div class="nav-item">
                <a href="#" class="nav-link">
                    <i class="fa-solid fa-user-group main-icon"></i> Customers
                </a>
            </div>
            
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/master-data" class="nav-link">
                    <i class="fa-solid fa-anchor main-icon"></i> Ports
                </a>
            </div>
            
            <div class="nav-item">
                <a href="#" class="nav-link">
                    <i class="fa-solid fa-location-dot main-icon"></i> Tracking
                </a>
            </div>
            
            <div class="nav-item">
                <a href="#complianceSubmenu" data-bs-toggle="collapse" class="nav-link collapsed">
                    <i class="fa-solid fa-shield-check main-icon"></i> Compliance & Billing
                    <i class="fa-solid fa-angle-down caret"></i>
                </a>
                <ul class="sub-nav collapse" id="complianceSubmenu">
                    <li><a href="${pageContext.request.contextPath}/compliance">Government Compliance</a></li>
                    <li><a href="${pageContext.request.contextPath}/billing">Billing & Invoices</a></li>
                </ul>
            </div>
            
            <div class="nav-item">
                <a href="#" class="nav-link">
                    <i class="fa-solid fa-shield-halved main-icon"></i> Claims Management
                </a>
            </div>

            <!-- STOCK & INVENTORY MODULE -->
            <div class="nav-item">
                <a href="#stockSubmenu" data-bs-toggle="collapse" class="nav-link collapsed">
                    <i class="fa-solid fa-boxes-stacked main-icon"></i> Stock & Inventory
                    <i class="fa-solid fa-angle-down caret"></i>
                </a>
                <ul class="sub-nav collapse" id="stockSubmenu">
                    <li><a href="${pageContext.request.contextPath}/upload-stock">Upload / Manage Stock</a></li>
                    <li><a href="${pageContext.request.contextPath}/ledger">Inventory Ledger (FR4.5)</a></li>
                </ul>
            </div>

            <!-- FINANCE MODULE -->
            <div class="nav-item">
                <a href="#financeSubmenu" data-bs-toggle="collapse" class="nav-link collapsed">
                    <i class="fa-solid fa-file-invoice-dollar main-icon"></i> Billing & Finance
                    <i class="fa-solid fa-angle-down caret"></i>
                </a>
                <ul class="sub-nav collapse" id="financeSubmenu">
                    <li><a href="${pageContext.request.contextPath}/finance/profit-loss">Profit & Loss</a></li>
                    <li><a href="${pageContext.request.contextPath}/invoices">Invoices (FR5)</a></li>
                </ul>
            </div>
            
            <!-- TRACKING & SCANNING MODULE (FR8) -->
            <div class="nav-item">
                <a href="#barcodeSubmenu" data-bs-toggle="collapse" class="nav-link collapsed">
                    <i class="fa-solid fa-qrcode main-icon"></i> Tracking & Scanning
                    <i class="fa-solid fa-angle-down caret"></i>
                </a>
                <ul class="sub-nav collapse" id="barcodeSubmenu">
                    <li><a href="${pageContext.request.contextPath}/barcodes">Manage Barcodes (FR8)</a></li>
                    <li><a href="${pageContext.request.contextPath}/scan-barcode">Scan Barcodes</a></li>
                </ul>
            </div>

            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/analytics" class="nav-link ${pageContext.request.requestURI.contains('/analytics') ? 'active' : ''}">
                    <i class="fa-solid fa-chart-pie main-icon"></i> Analytics
                </a>
            </div>

            <div class="nav-item">
                <a href="#" class="nav-link">
                    <i class="fa-regular fa-bell main-icon"></i> Alerts <span style="background: red; color: white; border-radius: 50%; padding: 2px 6px; font-size: 10px; margin-left: 8px;">12</span>
                </a>
            </div>
            
            <div class="nav-item">
                <a href="#" class="nav-link">
                    <i class="fa-solid fa-gear main-icon"></i> Settings
                </a>
            </div>
        </div>

        <div class="help-card">
            <div class="help-header">
                <div class="icon"><i class="fa-solid fa-headset"></i></div>
                <h6>Need Help?</h6>
            </div>
            <p>Our support team is available 24/7</p>
            <a href="#" class="btn-support">Contact Support</a>
        </div>
    
<script>
// Ultimate Fallback for Sidebar Toggles
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.sidebar .nav-link[data-bs-toggle="collapse"]').forEach(function(toggle) {
        toggle.addEventListener('click', function(e) {
            e.preventDefault();
            let targetId = this.getAttribute('href').substring(1);
            let target = document.getElementById(targetId);
            if(target) {
                target.classList.toggle('show');
                this.classList.toggle('collapsed');
                if (target.classList.contains('show')) {
                    this.setAttribute('aria-expanded', 'true');
                } else {
                    this.setAttribute('aria-expanded', 'false');
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








