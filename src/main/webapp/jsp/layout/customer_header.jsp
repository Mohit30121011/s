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
    <style>
        :root {
            --primary: #FC8019;
            --sidebar-width: 250px;
            --header-height: 60px;
        }
        body { background-color: #F8FAFC; }
        .sidebar {
            width: var(--sidebar-width);
            height: 100vh;
            position: fixed;
            left: 0; top: 0;
            background: #fff;
            border-right: 1px solid #E2E8F0;
            z-index: 1000;
        }
        .main-content {
            margin-left: var(--sidebar-width);
            padding: 20px;
        }
        .topbar {
            height: var(--header-height);
            background: #fff;
            border-bottom: 1px solid #E2E8F0;
            display: flex;
            align-items: center;
            justify-content: flex-end;
            padding: 0 20px;
        }
        .nav-link {
            color: #64748B;
            padding: 12px 20px;
            font-weight: 500;
        }
        .nav-link:hover, .nav-link.active {
            color: var(--primary);
            background: #FFEDD5;
        }
        .nav-link i { width: 24px; text-align: center; margin-right: 10px; }
        .brand {
            height: var(--header-height);
            display: flex;
            align-items: center;
            padding: 0 20px;
            border-bottom: 1px solid #E2E8F0;
            font-weight: 700;
            font-size: 1.2rem;
            color: #0F172A;
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