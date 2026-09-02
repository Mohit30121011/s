<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/jsp/layout/header.jsp" />

<div class="row justify-content-center">
    <div class="col-md-8">
        <div class="card shadow border-0 mt-4">
            <div class="card-body p-5">
                <h3 class="text-center mb-4">Registration Portal</h3>
                
                <ul class="nav nav-pills nav-justified mb-4" id="regTab" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" data-bs-toggle="pill" data-bs-target="#company" type="button">Register as Company</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" data-bs-toggle="pill" data-bs-target="#customer" type="button">Register as Customer</button>
                    </li>
                </ul>
 
                <div class="tab-content">
                    <!-- Company Form -->
                    <div class="tab-pane fade show active" id="company">
                        <form action="<c:url value='/register'/>" method="POST">
                            <input type="hidden" name="type" value="company">
                            <div class="row g-3">
                                <div class="col-md-6"><label class="form-label">Company Name</label><input type="text" name="companyName" class="form-control" required></div>
                                <div class="col-md-6"><label class="form-label">License Number</label><input type="text" name="licenseNo" class="form-control" required></div>
                                <div class="col-md-6"><label class="form-label">GST Number</label><input type="text" name="gstNo" class="form-control" required></div>
                                <div class="col-md-6"><label class="form-label">Contact Email</label><input type="email" name="email" class="form-control" required></div>
                                <div class="col-md-6"><label class="form-label">Password</label><input type="password" name="password" class="form-control" required></div>
                                <div class="col-md-6"><label class="form-label">Contact Phone</label><input type="text" name="phone" class="form-control" required></div>
                                <div class="col-12"><label class="form-label">Registered Address</label><textarea name="address" class="form-control" rows="2" required></textarea></div>
                                <div class="col-12"><button type="submit" class="btn btn-success w-100">Submit Company Registration</button></div>
                            </div>
                        </form>
                    </div>
                    
                    <!-- Customer Form -->
                    <div class="tab-pane fade" id="customer">
                        <form action="<c:url value='/register'/>" method="POST">
                            <input type="hidden" name="type" value="customer">
                            <div class="row g-3">
                                <div class="col-md-6"><label class="form-label">Full Name</label><input type="text" name="customerName" class="form-control" required></div>
                                <div class="col-md-6"><label class="form-label">Email Address</label><input type="email" name="email" class="form-control" required></div>
                                <div class="col-md-6"><label class="form-label">Password</label><input type="password" name="password" class="form-control" required></div>
                                <div class="col-md-6"><label class="form-label">Phone Number</label><input type="text" name="phone" class="form-control" required></div>
                                <div class="col-12"><label class="form-label">Shipping Address</label><textarea name="address" class="form-control" rows="2" required></textarea></div>
                                <div class="col-12"><button type="submit" class="btn btn-primary w-100">Submit Customer Registration</button></div>
                            </div>
                        </form>
                    </div>
                </div>
                
                <div class="text-center mt-4">
                    <small>Already registered? <a href="<c:url value='/login'/>">Login here</a></small>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />
