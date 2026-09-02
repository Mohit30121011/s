<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="hideSidebar" value="true" scope="request" />
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* Add Custom styles for registration to match image */
    .reg-title {
        font-size: 20px;
        font-weight: 700;
        color: #282C3F;
    }
    .back-btn {
        border: 1px solid #E5E7EB;
        background: #fff;
        color: #6B7280;
        font-size: 13px;
        font-weight: 500;
        padding: 8px 16px;
        border-radius: 8px;
        text-decoration: none;
    }
    .back-btn:hover {
        background: #F9FAFB;
        color: #4B5563;
    }
    .reg-card {
        background: #fff;
        border: 1px solid #E5E7EB;
        border-radius: 12px;
        padding: 24px;
        margin-top: 24px;
    }
    .reg-card-title {
        font-size: 18px;
        font-weight: 700;
        margin-bottom: 4px;
    }
    .reg-card-subtitle {
        font-size: 13px;
        color: #6B7280;
        margin-bottom: 24px;
    }
    .account-type-box {
        border: 1px solid #E5E7EB;
        border-radius: 12px;
        padding: 16px;
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 16px;
        transition: all 0.2s;
        height: 100%;
    }
    .account-type-box.active {
        border-color: #FC8019;
        background: #FFFBF9;
    }
    .icon-wrapper {
        width: 48px;
        height: 48px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
    }
    .company-icon {
        background: #FFF0E5;
        color: #FC8019;
    }
    .customer-icon {
        background: #F3F4F6;
        color: #6B7280;
    }
    .account-details h6 {
        margin: 0;
        font-weight: 600;
        font-size: 14px;
        color: #282C3F;
    }
    .account-details small {
        color: #6B7280;
        font-size: 12px;
    }
    .radio-circle {
        width: 20px;
        height: 20px;
        border-radius: 50%;
        border: 2px solid #D1D5DB;
        margin-left: auto;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .account-type-box.active .radio-circle {
        border-color: #FC8019;
    }
    .account-type-box.active .radio-circle::after {
        content: '';
        width: 10px;
        height: 10px;
        border-radius: 50%;
        background: #FC8019;
    }
    
    .section-divider {
        display: flex;
        align-items: center;
        text-align: center;
        color: #282C3F;
        font-weight: 600;
        font-size: 14px;
        margin: 32px 0;
    }
    .section-divider::before, .section-divider::after {
        content: '';
        flex: 1;
        border-bottom: 1px solid #E5E7EB;
    }
    .section-divider::before {
        margin-right: 16px;
    }
    .section-divider::after {
        margin-left: 16px;
    }
    
    .form-group label {
        font-size: 12px;
        font-weight: 600;
        color: #4B5563;
        margin-bottom: 8px;
    }
    .form-group label span {
        color: #EF4444;
    }
    
    .input-icon-wrapper {
        position: relative;
    }
    .input-icon-wrapper i {
        position: absolute;
        left: 12px;
        top: 50%;
        transform: translateY(-50%);
        color: #9CA3AF;
        font-size: 14px;
    }
    .input-icon-wrapper input, .input-icon-wrapper select {
        padding-left: 36px;
        font-size: 13px;
        border: 1px solid #E5E7EB;
        border-radius: 8px;
        height: 42px;
    }
    .input-icon-wrapper input:focus, .input-icon-wrapper select:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 2px rgba(252, 128, 25, 0.1);
        outline: none;
    }
    .eye-icon {
        position: absolute;
        right: 12px;
        left: auto !important;
        cursor: pointer;
    }
    
    .terms-checkbox {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 13px;
        color: #4B5563;
    }
    .terms-checkbox a {
        color: #FC8019;
        text-decoration: none;
    }
    
    .btn-cancel {
        background: #fff;
        border: 1px solid #E5E7EB;
        color: #4B5563;
        font-weight: 500;
        padding: 10px 24px;
        border-radius: 8px;
        font-size: 14px;
    }
    .btn-submit {
        background: #FC8019;
        border: 1px solid #FC8019;
        color: #fff;
        font-weight: 500;
        padding: 10px 24px;
        border-radius: 8px;
        font-size: 14px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .btn-submit:hover {
        background: #E87010;
        color: #fff;
    }
</style>

<div class="d-flex justify-content-between align-items-start mb-2">
    <div>
        <h4 class="reg-title mb-1">Registration</h4>
        <div class="custom-breadcrumb mb-0">
            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <i class="fa-solid fa-chevron-right custom-breadcrumb-separator"></i>
            <a href="#">Registration</a>
            <i class="fa-solid fa-chevron-right custom-breadcrumb-separator"></i>
            <span class="active">Create Account</span>
        </div>
    </div>
    <a href="${pageContext.request.contextPath}/dashboard" class="back-btn">
        <i class="fa-solid fa-arrow-left me-2"></i> Back to Dashboard
    </a>
</div>

<div class="reg-card">
    <h5 class="reg-card-title">Create Your Account</h5>
    <p class="reg-card-subtitle">Choose your account type and fill in the details to get started</p>
    
    <div class="row g-4 mb-4">
        <div class="col-md-6">
            <div class="account-type-box active" onclick="switchTab('company', event)">
                <div class="icon-wrapper company-icon">
                    <i class="fa-regular fa-building"></i>
                </div>
                <div class="account-details">
                    <h6>Company Account</h6>
                    <small>For logistics companies</small>
                </div>
                <div class="radio-circle"></div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="account-type-box" onclick="switchTab('customer', event)">
                <div class="icon-wrapper customer-icon">
                    <i class="fa-regular fa-user"></i>
                </div>
                <div class="account-details">
                    <h6>Customer Account</h6>
                    <small>For businesses / individuals</small>
                </div>
                <div class="radio-circle"></div>
            </div>
        </div>
    </div>
    
    <div class="section-divider" id="formDividerTitle">Company Registration Details</div>
    
    <form action="${pageContext.request.contextPath}/register" method="POST" id="regForm" enctype="multipart/form-data">
        <input type="hidden" name="type" value="company" id="accountTypeInput">
        
        <div class="row g-4" id="companyFields">
            <div class="col-md-4 form-group">
                <label id="nameLabel">Company Name <span>*</span></label>
                <div class="input-icon-wrapper">
                    <i class="fa-solid fa-building-lock"></i>
                    <input type="text" name="companyName" class="form-control" placeholder="Enter name" required>
                </div>
            </div>
            <div class="col-md-4 form-group">
                <label id="emailLabel">Company Email <span>*</span></label>
                <div class="input-icon-wrapper">
                    <i class="fa-regular fa-envelope"></i>
                    <input type="email" name="email" class="form-control" placeholder="Enter email" required>
                </div>
            </div>
            <div class="col-md-4 form-group">
                <label>Username <span>*</span></label>
                <div class="input-icon-wrapper">
                    <i class="fa-regular fa-id-badge"></i>
                    <input type="text" name="username" class="form-control" placeholder="Enter username" required>
                </div>
            </div>
            <div class="col-md-4 form-group company-only">
                <label>Contact Person <span>*</span></label>
                <div class="input-icon-wrapper">
                    <i class="fa-regular fa-user"></i>
                    <input type="text" name="contactPerson" class="form-control" placeholder="Enter contact person name" required>
                </div>
            </div>
            
            <div class="col-md-4 form-group">
                <label>Phone Number <span>*</span></label>
                <div class="input-icon-wrapper">
                    <i class="fa-solid fa-phone"></i>
                    <input type="text" name="phone" class="form-control" placeholder="Enter phone number" required>
                </div>
            </div>
            <div class="col-md-4 form-group company-only">
                <label>GST Number <span>*</span></label>
                <div class="input-icon-wrapper">
                    <i class="fa-regular fa-file-lines"></i>
                    <input type="text" name="gstNo" class="form-control" placeholder="Enter GST number" required>
                </div>
            </div>
            <div class="col-md-4 form-group company-only">
                <label>License Number <span>*</span></label>
                <div class="input-icon-wrapper">
                    <i class="fa-regular fa-id-card"></i>
                    <input type="text" name="licenseNo" class="form-control" placeholder="Enter License / Reg No" required>
                </div>
            </div>
            <div class="col-md-4 form-group">
                <label>KYC Document <span>*</span></label>
                <div class="input-icon-wrapper">
                    <i class="fa-solid fa-file-arrow-up"></i>
                    <input type="file" name="kycDoc" class="form-control" style="padding: 6px 16px 6px 40px;" accept=".pdf,.jpg,.png" required>
                </div>
            </div>
            
            <div class="col-md-4 form-group">
                <label id="addressLabel">Company Address <span>*</span></label>
                <div class="input-icon-wrapper">
                    <i class="fa-solid fa-location-dot"></i>
                    <input type="text" name="address" class="form-control" placeholder="Enter complete address" required>
                </div>
            </div>
            <div class="col-md-4 form-group">
                <label>City <span>*</span></label>
                <div class="input-icon-wrapper">
                    <i class="fa-solid fa-city"></i>
                    <input type="text" name="city" class="form-control" placeholder="Enter city" required>
                </div>
            </div>
            <div class="col-md-4 form-group">
                <label>State <span>*</span></label>
                <div class="input-icon-wrapper">
                    <select name="state" class="form-control" required style="padding-left: 12px; appearance: auto;">
                        <option value="" disabled selected>Select state</option>
                        <option value="MH">Maharashtra</option>
                        <option value="KA">Karnataka</option>
                        <option value="DL">Delhi</option>
                    </select>
                </div>
            </div>
            
            <div class="col-md-4 form-group">
                <label>PIN Code <span>*</span></label>
                <div class="input-icon-wrapper">
                    <i class="fa-solid fa-hashtag"></i>
                    <input type="text" name="pinCode" class="form-control" placeholder="Enter PIN code" required>
                </div>
            </div>
            <div class="col-md-4 form-group">
                <label>Create Password <span>*</span></label>
                <div class="input-icon-wrapper">
                    <i class="fa-solid fa-lock"></i>
                    <input type="password" name="password" class="form-control" placeholder="Create a strong password" required>
                    <i class="fa-regular fa-eye-slash eye-icon" onclick="togglePwd(this)"></i>
                </div>
            </div>
            <div class="col-md-4 form-group">
                <label>Confirm Password <span>*</span></label>
                <div class="input-icon-wrapper">
                    <i class="fa-solid fa-lock"></i>
                    <input type="password" name="confirmPassword" class="form-control" placeholder="Confirm password" required>
                    <i class="fa-regular fa-eye-slash eye-icon" onclick="togglePwd(this)"></i>
                </div>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-center mt-4 pt-3">
            <div class="terms-checkbox">
                <input type="checkbox" required id="terms" style="width: 16px; height: 16px; accent-color: #FC8019;">
                <label for="terms" class="mb-0">I agree to the <a href="#">Terms & Conditions</a> and <a href="#">Privacy Policy</a></label>
            </div>
            <div class="d-flex gap-3">
                <button type="button" class="btn btn-cancel">Cancel</button>
                <button type="submit" class="btn btn-submit" id="submitBtn">
                    <i class="fa-solid fa-user-plus"></i> Register Company
                </button>
            </div>
        </div>
    </form>
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
    
    function switchTab(type, e) {
        const boxes = document.querySelectorAll('.account-type-box');
        boxes.forEach(box => box.classList.remove('active'));
        
        const icons = document.querySelectorAll('.icon-wrapper');
        
        if (e && e.currentTarget) {
            e.currentTarget.classList.add('active');
        } else {
            // fallback if event not passed correctly
            if(type === 'company') boxes[0].classList.add('active');
            else boxes[1].classList.add('active');
        }
        document.getElementById('accountTypeInput').value = type;
        
        const title = document.getElementById('formDividerTitle');
        const submitBtn = document.getElementById('submitBtn');
        const companyOnlyFields = document.querySelectorAll('.company-only');
        const customerOnlyFields = document.querySelectorAll('.customer-only');
        const nameLabel = document.getElementById('nameLabel');
        const emailLabel = document.getElementById('emailLabel');
        const addressLabel = document.getElementById('addressLabel');
        
        if (type === 'company') {
            icons[0].className = 'icon-wrapper company-icon';
            icons[1].className = 'icon-wrapper customer-icon';
            title.innerText = 'Company Registration Details';
            submitBtn.innerHTML = '<i class="fa-solid fa-user-plus"></i> Register Company';
            
            companyOnlyFields.forEach(el => {
                el.style.display = 'block';
                const input = el.querySelector('input');
                if (input) input.required = true;
            });
            customerOnlyFields.forEach(el => {
                el.style.display = 'none';
                const input = el.querySelector('input');
                if (input) input.required = false;
            });
            nameLabel.innerHTML = 'Company Name <span>*</span>';
            emailLabel.innerHTML = 'Company Email <span>*</span>';
            addressLabel.innerHTML = 'Company Address <span>*</span>';
        } else {
            icons[1].className = 'icon-wrapper company-icon';
            icons[0].className = 'icon-wrapper customer-icon';
            title.innerText = 'Customer Registration Details';
            submitBtn.innerHTML = '<i class="fa-solid fa-user-plus"></i> Register Customer';
            
            companyOnlyFields.forEach(el => {
                el.style.display = 'none';
                const input = el.querySelector('input');
                if (input) input.required = false;
            });
            customerOnlyFields.forEach(el => {
                el.style.display = 'block';
                const input = el.querySelector('input');
                if (input) input.required = true;
            });
            nameLabel.innerHTML = 'Full Name <span>*</span>';
            emailLabel.innerHTML = 'Email Address <span>*</span>';
            addressLabel.innerHTML = 'Residential Address <span>*</span>';
        }
    }
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
