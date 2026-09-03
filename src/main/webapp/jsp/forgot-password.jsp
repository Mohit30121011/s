<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="hideSidebar" value="true" scope="request" />
<c:set var="hideTopHeader" value="true" scope="request" />
<jsp:include page="/jsp/layout/header.jsp" />

<div class="auth-container">
    <div class="auth-box shadow-sm">
        <h3 class="auth-title">Forgot Password</h3>
        <p class="auth-subtitle">Enter your email address to receive a password reset link.</p>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger"><i class="fa-solid fa-circle-exclamation me-2"></i>${errorMessage}</div>
        </c:if>
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success"><i class="fa-solid fa-circle-check me-2"></i>${successMessage}</div>
        </c:if>

        <form action="<c:url value='/forgot-password'/>" method="POST">  
            <div class="form-group mb-4">
                <label>Email Address</label>
                <div class="input-icon-wrapper">
                    <i class="fa-regular fa-envelope main-icon"></i>
                    <input type="email" name="email" required placeholder="Enter your registered email">
                </div>
            </div>
            
            <button type="submit" class="btn btn-primary w-100 mb-3" style="font-weight: 600; padding: 12px;">
                Send Reset Link
            </button>
        </form>
        
        <div class="auth-footer text-center mt-4">
            <p>Remembered your password? <a href="<c:url value='/login'/>">Sign in</a></p>
        </div>
    </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />
