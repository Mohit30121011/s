<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>N Logistic - Welcome</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts: Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #F9FAFB;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
        }
        .splash-card {
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
            padding: 48px;
            text-align: center;
            max-width: 500px;
            width: 100%;
        }
        .brand-icon {
            background: #FC8019;
            color: white;
            width: 64px;
            height: 64px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 32px;
            transform: rotate(45deg);
            margin: 0 auto 32px auto;
        }
        .brand-icon span {
            transform: rotate(-45deg);
        }
        h1 {
            font-weight: 800;
            color: #282C3F;
            margin-bottom: 8px;
        }
        p {
            color: #6B7280;
            margin-bottom: 32px;
        }
        .btn-primary-custom {
            background: #FC8019;
            border: none;
            color: white;
            padding: 12px 24px;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            width: 100%;
            margin-bottom: 16px;
        }
        .btn-primary-custom:hover {
            background: #E87010;
            color: white;
        }
        .btn-secondary-custom {
            background: #fff;
            border: 1px solid #E5E7EB;
            color: #4B5563;
            padding: 12px 24px;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            width: 100%;
        }
        .btn-secondary-custom:hover {
            background: #F9FAFB;
            color: #282C3F;
        }
    </style>
</head>
<body>
    <div class="splash-card">
        <div class="brand-icon">
            <span>N</span>
        </div>
        <h1>N LOGISTIC</h1>
        <p>Global Logistics Solution</p>
        
        <a href="<%= request.getContextPath() %>/login" class="btn-primary-custom">
            <i class="fa-solid fa-right-to-bracket me-2"></i> Login to Account
        </a>
        <a href="<%= request.getContextPath() %>/register" class="btn-secondary-custom">
            <i class="fa-solid fa-user-plus me-2"></i> Create New Account
        </a>
    </div>
</body>
</html>
