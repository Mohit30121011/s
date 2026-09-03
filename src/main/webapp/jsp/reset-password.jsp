<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="hideSidebar" value="true" scope="request" />
<c:set var="hideTopHeader" value="true" scope="request" />
<jsp:include page="/jsp/layout/header.jsp" />

<div class="auth-container">
    <div class="auth-box shadow-sm">
        <h3 class="auth-title">Reset Password</h3>
        <p class="auth-subtitle">Create a new, strong password for your account.</p>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger"><i class="fa-solid fa-circle-exclamation me-2"></i>${errorMessage}</div>
        </c:if>

        <form action="<c:url value='/reset-password'/>" method="POST">  
            <input type="hidden" name="token" value="${token}">
            
            <div class="form-group mb-3">
                <label>New Password</label>
                <div class="input-icon-wrapper">
                    <i class="fa-solid fa-lock main-icon"></i>
                    <input type="password" name="password" required placeholder="Enter new password">
                </div>
            </div>
            
            <div class="form-group mb-4">
                <label>Confirm New Password</label>
                <div class="input-icon-wrapper">
                    <i class="fa-solid fa-lock main-icon"></i>
                    <input type="password" name="confirmPassword" required placeholder="Confirm new password">
                </div>
            </div>
            
            <button type="submit" class="btn btn-primary w-100 mb-3" style="font-weight: 600; padding: 12px;">
                Reset Password
            </button>
        </form>
    </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />
