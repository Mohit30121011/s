<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/jsp/layout/header.jsp" />

<div class="row justify-content-center">
    <div class="col-md-5">
        <div class="card shadow border-0 mt-5">
            <div class="card-body p-5">
                <h3 class="text-center mb-4">Account Login</h3>
                
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger">${errorMessage}</div>
                </c:if>
                <c:if test="${not empty successMessage}">
                    <div class="alert alert-success">${successMessage}</div>
                </c:if>
 
                <form action="<c:url value='/login'/>" method="POST">
                    <div class="mb-3">
                        <label class="form-label">Username</label>
                        <input type="text" name="username" class="form-control" required placeholder="Enter your username">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Password</label>
                        <input type="password" name="password" class="form-control" required placeholder="Enter your password">
                    </div>
                    <button type="submit" class="btn btn-primary w-100 mb-3">Sign In</button>
                    
                    <div class="text-center">
                        <small>Don't have an account? <a href="<c:url value='/register'/>">Register here</a></small>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />
