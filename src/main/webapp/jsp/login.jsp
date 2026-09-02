<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="hideSidebar" value="true" scope="request" />
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    .login-wrapper {
        display: flex;
        align-items: center;
        justify-content: center;
        min-height: calc(100vh - 120px);
    }
    .login-card {
        background: #fff;
        border: 1px solid #E5E7EB;
        border-radius: 16px;
        padding: 40px;
        width: 100%;
        max-width: 450px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.03);
    }
    .login-card-title {
        font-size: 24px;
        font-weight: 800;
        color: #282C3F;
        margin-bottom: 8px;
        text-align: center;
    }
    .login-card-subtitle {
        font-size: 14px;
        color: #6B7280;
        text-align: center;
        margin-bottom: 32px;
    }
    .form-group label {
        font-size: 13px;
        font-weight: 600;
        color: #4B5563;
        margin-bottom: 8px;
    }
    .input-icon-wrapper {
        position: relative;
        margin-bottom: 20px;
    }
    .input-icon-wrapper i.main-icon {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #9CA3AF;
        font-size: 15px;
    }
    .input-icon-wrapper input {
        padding-left: 40px;
        font-size: 14px;
        border: 1px solid #E5E7EB;
        border-radius: 8px;
        height: 48px;
        width: 100%;
        background: #F9FAFB;
    }
    .input-icon-wrapper input:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.1);
        outline: none;
        background: #fff;
    }
    .eye-icon {
        position: absolute;
        right: 14px;
        top: 50%;
        transform: translateY(-50%);
        cursor: pointer;
        color: #9CA3AF;
    }
    .btn-submit {
        background: #FC8019;
        border: 1px solid #FC8019;
        color: #fff;
        font-weight: 600;
        padding: 12px;
        border-radius: 8px;
        font-size: 15px;
        width: 100%;
        transition: all 0.2s;
    }
    .btn-submit:hover {
        background: #E87010;
        color: #fff;
    }
    .register-link {
        text-align: center;
        margin-top: 24px;
        font-size: 14px;
        color: #6B7280;
    }
    .register-link a {
        color: #FC8019;
        font-weight: 600;
        text-decoration: none;
    }
    .register-link a:hover {
        text-decoration: underline;
    }
</style>

<div class="login-wrapper">
    <div class="login-card">
        <h3 class="login-card-title">Welcome Back</h3>
        <p class="login-card-subtitle">Sign in to your N Logistic account</p>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger" style="font-size: 13px; border-radius: 8px;">
                <i class="fa-solid fa-circle-exclamation me-2"></i>${errorMessage}
            </div>
        </c:if>
        <c:if test="${not empty successMessage}"> 
            <div class="alert alert-success" style="font-size: 13px; border-radius: 8px;">
                <i class="fa-solid fa-circle-check me-2"></i>${successMessage}
            </div>
        </c:if>

        <form action="<c:url value='/login'/>" method="POST">  
            <div class="form-group">
                <label>Username / Email</label>
                <div class="input-icon-wrapper">
                    <i class="fa-regular fa-user main-icon"></i>
                    <input type="text" name="username" required placeholder="Enter your username or email">
                </div>
            </div>
            
            <div class="form-group">
                <div class="d-flex justify-content-between">
                    <label>Password</label>
                    <a href="<c:url value='/forgot-password'/>" style="font-size: 12px; color: #FC8019; text-decoration: none; font-weight: 500;">Forgot Password?</a>
                </div>
                <div class="input-icon-wrapper">
                    <i class="fa-solid fa-lock main-icon"></i>
                    <input type="password" name="password" required placeholder="Enter your password">
                    <i class="fa-regular fa-eye-slash eye-icon" onclick="togglePwd(this)"></i>
                </div>
            </div>
            
            <button type="submit" class="btn-submit mt-2">
                Sign In
            </button>

            <div class="register-link">
                Don't have an account? <a href="<c:url value='/register'/>">Register here</a>
            </div>
        </form>
    </div>
</div>

<script>
    function togglePwd(icon) {
        let input = icon.previousElementSibling;
        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.remove('fa-eye-slash');
            icon.classList.add('fa-eye');
        } else {
            input.type = 'password';
            icon.classList.remove('fa-eye');
            icon.classList.add('fa-eye-slash');
        }
    }
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
