<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Portal - NLogistic</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script>
        (function() {
            var savedTheme = localStorage.getItem('nlogistic-theme') || 'light';
            document.documentElement.setAttribute('data-theme', savedTheme);
        })();
    </script>
    <style>
        :root {
            --primary: #FC8019;
            --sidebar-width: 250px;
            --header-height: 60px;
            --bg: #F8FAFC;
            --surface: #FFFFFF;
            --border: #E2E8F0;
            --text: #0F172A;
            --text-muted: #64748B;
        }
        [data-theme="dark"] {
            --bg: #080D12;
            --surface: #0A0F14;
            --border: #22303A;
            --text: #F8FAFC;
            --text-muted: #94A3B8;
        }
        body { background-color: var(--bg); color: var(--text); }
        [data-theme="dark"] .card {
            background-color: #101820 !important;
            border-color: #22303A !important;
            color: #F8FAFC !important;
        }
        [data-theme="dark"] .card .text-muted {
            color: #94A3B8 !important;
        }
        [data-theme="dark"] .table {
            color: #F8FAFC !important;
            border-color: #22303A !important;
        }
        [data-theme="dark"] .table th {
            background-color: #0E151C !important;
            color: #94A3B8 !important;
            border-bottom-color: #22303A !important;
        }
        [data-theme="dark"] .table td {
            background-color: transparent !important;
            color: #F8FAFC !important;
            border-bottom-color: #22303A !important;
        }
        .sidebar {
            width: var(--sidebar-width);
            height: 100vh;
            position: fixed;
            left: 0; top: 0;
            background: var(--surface);
            border-right: 1px solid var(--border);
            z-index: 1000;
        }
        .main-content {
            margin-left: var(--sidebar-width);
            padding: 20px;
        }
        .topbar {
            height: var(--header-height);
            background: var(--surface);
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: flex-end;
            padding: 0 20px;
        }
        .nav-link {
            color: var(--text-muted);
            padding: 12px 20px;
            font-weight: 500;
        }
        .nav-link:hover, .nav-link.active {
            color: var(--primary);
            background: rgba(252, 128, 25, 0.12);
        }
        .nav-link i { width: 24px; text-align: center; margin-right: 10px; }
        .brand {
            height: var(--header-height);
            display: flex;
            align-items: center;
            padding: 0 20px;
            border-bottom: 1px solid var(--border);
            font-weight: 700;
            font-size: 1.2rem;
            color: var(--text);
        }
        .brand-icon {
            background: var(--primary);
            color: #fff;
            width: 30px; height: 30px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin-right: 10px;
        }
    </style>
</head>
<body>

<div class="sidebar">
    <div class="brand">
        <div class="brand-icon">N</div> N LOGISTIC
    </div>
    <div class="py-3">
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-link active">
            <i class="fa-solid fa-house"></i> Dashboard Home
        </a>
        <a href="${pageContext.request.contextPath}/shipments/create" class="nav-link">
            <i class="fa-solid fa-ship"></i> Book Shipment
        </a>
        <a href="${pageContext.request.contextPath}/containers" class="nav-link">
            <i class="fa-solid fa-box"></i> Book Container
        </a>
        <a href="${pageContext.request.contextPath}/shipments" class="nav-link">
            <i class="fa-solid fa-truck"></i> My Shipments
        </a>
        <a href="${pageContext.request.contextPath}/invoices" class="nav-link">
            <i class="fa-solid fa-receipt"></i> My Invoices
        </a>
    </div>
</div>

<div class="main-content">
    <div class="topbar mb-4">
        <div class="d-flex align-items-center">
            <span class="me-3 fw-medium">${sessionScope.username}</span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-outline-danger">Logout</a>
        </div>
    </div>