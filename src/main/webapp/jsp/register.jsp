<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="hideSidebar" value="true" scope="request" />
<c:set var="hideTopHeader" value="true" scope="request" />
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* Reset & Clean Full-Page Canvas */
    body {
        background-color: #F1F5F9 !important;
        margin: 0 !important;
        padding: 0 !important;
        overflow-x: hidden !important;
    }
    .main-wrapper {
        margin-left: 0 !important;
        width: 100% !important;
        min-height: 100vh !important;
        background: #F1F5F9 !important;
    }
    .content-area {
        padding: 0 !important;
        margin: 0 !important;
        width: 100% !important;
    }

    /* Page Container */
    .nl-reg-canvas {
        min-height: 100vh;
        width: 100%;
        background: #F1F5F9;
        padding: 40px 24px 60px;
        display: flex;
        flex-direction: column;
        align-items: center;
    }
    .nl-reg-shell {
        width: 100%;
        max-width: 1080px;
        animation: fadeInUp 0.5s cubic-bezier(0.16, 1, 0.3, 1) both;
    }

    @keyframes fadeInUp {
        0% { opacity: 0; transform: translateY(20px); }
        100% { opacity: 1; transform: translateY(0); }
    }

    /* Top Navigation Header */
    .nl-reg-top-bar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 24px;
        width: 100%;
    }
    .nl-reg-brand {
        display: flex;
        align-items: center;
        gap: 12px;
        text-decoration: none;
    }
    .nl-brand-badge {
        width: 42px;
        height: 42px;
        background: linear-gradient(135deg, #FC8019 0%, #FF6600 100%);
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #FFFFFF;
        font-size: 22px;
        font-weight: 900;
        box-shadow: 0 4px 14px rgba(252, 128, 25, 0.35);
    }
    .nl-brand-title {
        font-size: 19px;
        font-weight: 800;
        color: #0F172A;
        line-height: 1.1;
    }
    .nl-brand-subtitle {
        font-size: 11.5px;
        color: #64748B;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    .nl-back-to-login {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        color: #475569;
        font-size: 13px;
        font-weight: 600;
        padding: 9px 18px;
        border-radius: 50px !important;
        text-decoration: none;
        transition: all 0.2s ease;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
    }
    .nl-back-to-login:hover {
        background: #FFF9F5;
        border-color: #FC8019;
        color: #FC8019;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.12);
    }

    /* Main Registration Card */
    .nl-reg-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 18px;
        padding: 38px 44px;
        box-shadow: 0 10px 30px rgba(15, 23, 42, 0.05);
    }

    /* Card Header */
    .nl-reg-header {
        margin-bottom: 28px;
    }
    .nl-eyebrow-tag {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: #FFF2EB;
        color: #FC8019;
        font-size: 11.5px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        padding: 5px 12px;
        border-radius: 20px;
        margin-bottom: 10px;
    }
    .nl-reg-heading {
        font-size: 26px;
        font-weight: 800;
        color: #0F172A;
        letter-spacing: -0.5px;
        margin-bottom: 4px;
    }
    .nl-reg-subheading {
        font-size: 13.5px;
        color: #64748B;
    }

    /* Account Type Switcher Cards */
    .nl-type-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 16px;
        margin-bottom: 30px;
    }
    .nl-type-card {
        border: 2px solid #E2E8F0;
        border-radius: 14px;
        padding: 18px 20px;
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 16px;
        transition: all 0.2s ease;
        background: #FFFFFF;
        position: relative;
    }
    .nl-type-card:hover {
        border-color: #CBD5E1;
        background: #F8FAFC;
    }
    .nl-type-card.active {
        border-color: #FC8019;
        background: #FFFBF8;
        box-shadow: 0 6px 18px rgba(252, 128, 25, 0.12);
    }
    .nl-type-icon {
        width: 48px;
        height: 48px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 22px;
        flex-shrink: 0;
        transition: all 0.2s ease;
    }
    .nl-type-card.active .nl-type-icon.company {
        background: #FFF2EB;
        color: #FC8019;
    }
    .nl-type-card:not(.active) .nl-type-icon.company {
        background: #F1F5F9;
        color: #64748B;
    }
    .nl-type-card.active .nl-type-icon.customer {
        background: #EFF6FF;
        color: #2563EB;
    }
    .nl-type-card:not(.active) .nl-type-icon.customer {
        background: #F1F5F9;
        color: #64748B;
    }
    .nl-type-info {
        flex: 1;
    }
    .nl-type-title {
        font-size: 15px;
        font-weight: 700;
        color: #0F172A;
        margin-bottom: 2px;
    }
    .nl-type-desc {
        font-size: 12px;
        color: #64748B;
        line-height: 1.35;
    }
    .nl-type-radio {
        width: 22px;
        height: 22px;
        border-radius: 50%;
        border: 2px solid #CBD5E1;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s ease;
        flex-shrink: 0;
    }
    .nl-type-card.active .nl-type-radio {
        border-color: #FC8019;
    }
    .nl-type-card.active .nl-type-radio::after {
        content: "";
        width: 10px;
        height: 10px;
        border-radius: 50%;
        background: #FC8019;
    }

    /* Section Subheadings */
    .nl-section-header {
        display: flex;
        align-items: center;
        gap: 10px;
        margin: 22px 0 16px;
        padding-bottom: 8px;
        border-bottom: 1px solid #F1F5F9;
    }
    .nl-section-badge-icon {
        width: 28px;
        height: 28px;
        border-radius: 6px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 15px;
    }
    .nl-section-badge-icon.orange { background: #FFF2EB; color: #FC8019; }
    .nl-section-badge-icon.blue   { background: #EFF6FF; color: #2563EB; }
    .nl-section-title {
        font-size: 14px;
        font-weight: 700;
        color: #1E293B;
    }

    /* Form Fields Grid */
    .nl-fields-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 18px 24px;
    }
    .nl-fields-grid.full-width {
        grid-column: span 2;
    }
    .nl-field-box {
        display: flex;
        flex-direction: column;
    }
    .nl-field-box.span-2 {
        grid-column: span 2;
    }
    .nl-field-box label {
        font-size: 12.5px;
        font-weight: 600;
        color: #334155;
        margin-bottom: 7px;
    }
    .nl-field-box label span.req {
        color: #FC8019;
        margin-left: 2px;
    }
    .nl-input-wrap {
        position: relative;
        display: flex;
        align-items: center;
    }
    .nl-input-wrap i.lead-icon {
        position: absolute;
        left: 14px;
        color: #94A3B8;
        font-size: 17px;
        pointer-events: none;
        transition: color 0.15s ease;
        z-index: 2;
    }
    .nl-form-control {
        width: 100%;
        height: 46px;
        padding-left: 44px !important;
        padding-right: 14px;
        font-size: 13.5px;
        font-weight: 500;
        color: #0F172A;
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        border-radius: 50px !important;
        transition: all 0.15s ease;
        outline: none;
    }
    
    /* Dynamic Validation Styling */
    .nl-form-control.is-valid-input {
        border-color: #10B981 !important;
        background: #F0FDF4 !important;
    }
    .nl-form-control.is-invalid-input {
        border-color: #EF4444 !important;
        background: #FEF2F2 !important;
    }
    .nl-validation-hint {
        font-size: 11.5px;
        margin-top: 5px;
        display: flex;
        align-items: center;
        gap: 5px;
        line-height: 1.3;
    }
    .nl-validation-hint.muted { color: #64748B; }
    .nl-validation-hint.success { color: #059669; font-weight: 600; }
    .nl-validation-hint.error { color: #DC2626; font-weight: 600; }
    @keyframes spinLoader { to { transform: rotate(360deg); } }
    .spin { animation: spinLoader 0.9s linear infinite; display: inline-block; }

    .nl-form-control:focus {
        background: #FFFFFF;
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.14);
    }
    .nl-input-wrap:focus-within i.lead-icon {
        color: #FC8019;
    }

    /* Custom File Input Styling */
    .nl-file-input-wrap {
        display: flex;
        align-items: center;
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        border-radius: 50px !important;
        height: 46px;
        padding: 4px 20px 4px 44px;
        position: relative;
        cursor: pointer;
        transition: all 0.15s ease;
    }
    .nl-file-input-wrap:hover {
        border-color: #CBD5E1;
        background: #FFFFFF;
    }
    .nl-file-input-wrap input[type="file"] {
        position: absolute;
        inset: 0;
        opacity: 0;
        cursor: pointer;
        width: 100%;
        height: 100%;
        z-index: 3;
    }
    .nl-file-label-text {
        font-size: 12.5px;
        color: #64748B;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        flex: 1;
    }
    .nl-file-badge {
        background: #FFF2EB;
        color: #FC8019;
        font-size: 11px;
        font-weight: 700;
        padding: 4px 10px;
        border-radius: 6px;
        margin-left: 8px;
        flex-shrink: 0;
    }

    /* Password Eye Toggle */
    .nl-pwd-toggle {
        position: absolute;
        right: 12px;
        background: transparent;
        border: none;
        color: #94A3B8;
        font-size: 17px;
        cursor: pointer;
        padding: 2px 4px;
        z-index: 2;
        transition: color 0.15s ease;
    }
    .nl-pwd-toggle:hover {
        color: #FC8019;
    }

    /* Super Admin Approval Notice Callout  */
    .nl-approval-notice {
        margin-top: 24px;
        padding: 14px 18px;
        background: #FFFBEB;
        border: 1px solid #FDE68A;
        border-radius: 12px;
        display: flex;
        align-items: flex-start;
        gap: 12px;
        font-size: 13px;
        color: #92400E;
        line-height: 1.5;
    }
    .nl-approval-notice i {
        font-size: 18px;
        color: #D97706;
        flex-shrink: 0;
        margin-top: 2px;
    }

    /* Bottom Action Bar */
    .nl-reg-footer {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-top: 28px;
        padding-top: 22px;
        border-top: 1px solid #F1F5F9;
        flex-wrap: wrap;
        gap: 16px;
    }
    .nl-terms-checkbox {
        display: flex;
        align-items: center;
        gap: 9px;
        font-size: 13px;
        color: #475569;
        cursor: pointer;
    }
    .nl-terms-checkbox input[type="checkbox"] {
        accent-color: #FC8019;
        width: 17px;
        height: 17px;
        cursor: pointer;
    }
    .nl-terms-checkbox a {
        color: #FC8019;
        font-weight: 600;
        text-decoration: none;
    }
    .nl-terms-checkbox a:hover {
        text-decoration: underline;
    }

    .nl-btn-group {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .nl-btn-cancel {
        background: #FFFFFF;
        border: 1px solid #CBD5E1;
        color: #475569;
        font-size: 13.5px;
        font-weight: 600;
        padding: 10px 22px;
        border-radius: 50px !important;
        text-decoration: none;
        transition: all 0.15s ease;
        display: inline-flex;
        align-items: center;
    }
    .nl-btn-cancel:hover {
        background: #F8FAFC;
        border-color: #94A3B8;
        color: #0F172A;
    }
    .nl-btn-submit {
        background: linear-gradient(135deg, #FC8019 0%, #FF6600 100%);
        border: none;
        color: #FFFFFF;
        font-size: 14px;
        font-weight: 700;
        padding: 10px 28px;
        border-radius: 50px !important;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        box-shadow: 0 4px 14px rgba(252, 128, 25, 0.32);
        transition: all 0.2s ease;
    }
    .nl-btn-submit:hover {
        background: linear-gradient(135deg, #E87010 0%, #E65100 100%);
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(252, 128, 25, 0.42);
    }

    /* Alerts */
    .nl-reg-alert {
        display: flex;
        align-items: flex-start;
        gap: 10px;
        padding: 12px 16px;
        border-radius: 10px;
        font-size: 13px;
        margin-bottom: 24px;
    }
    .nl-reg-alert.danger {
        background: #FEF2F2;
        border: 1px solid #FCA5A5;
        color: #991B1B;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .nl-reg-canvas {
            padding: 24px 16px;
        }
        .nl-reg-card {
            padding: 24px 18px;
        }
        .nl-type-grid {
            grid-template-columns: 1fr;
        }
        .nl-fields-grid {
            grid-template-columns: 1fr;
        }
        .nl-field-box.span-2 {
            grid-column: span 1;
        }
        .nl-reg-footer {
            flex-direction: column;
            align-items: stretch;
        }
        .nl-btn-group {
            flex-direction: column;
            width: 100%;
        }
        .nl-btn-cancel, .nl-btn-submit {
            width: 100%;
            justify-content: center;
        }
    }
</style>

<div class="nl-reg-canvas">
    <div class="nl-reg-shell">
        <!-- Top Navigation Bar -->
        <div class="nl-reg-top-bar">
            <a href="<c:url value='/'/>" class="nl-reg-brand">
                <div class="nl-brand-badge">N</div>
                <div>
                    <div class="nl-brand-title">N LOGISTIC</div>
                    <div class="nl-brand-subtitle">Enterprise Logistics Solution</div>
                </div>
            </a>
            <a href="<c:url value='/login'/>" class="nl-back-to-login">
                <i class="ti ti-arrow-left"></i> Back to Sign In
            </a>
        </div>

        <!-- Registration Form Card -->
        <div class="nl-reg-card">
            <!-- Header -->
            <div class="nl-reg-header">
                <div class="nl-eyebrow-tag">
                    <i class="ti ti-user-plus" id="submitBtnIcon"></i> Organization Onboarding
                </div>
                <h1 class="nl-reg-heading">Create Your Enterprise Account</h1>
                <p class="nl-reg-subheading">Select your profile below. All company accounts are verified and approved by the Super Admin before activation.</p>
            </div>

            <!-- Error Notification -->
            <c:if test="${not empty errorMessage}">
                <div class="nl-reg-alert danger">
                    <i class="ti ti-alert-circle fs-5" style="color: #DC2626; flex-shrink: 0; margin-top: 1px;"></i>
                    <div>${errorMessage}</div>
                </div>
            </c:if>

            <!-- Account Type Selector Cards  -->
            
            <!-- Client-side Error Banner -->
            <div class="nl-reg-alert danger" id="clientAlert" style="display: none;">
                <i class="ti ti-alert-circle fs-5" style="color: #DC2626; flex-shrink: 0; margin-top: 1px;"></i>
                <div id="clientAlertText">Please correct the highlighted errors.</div>
            </div>

            <div class="nl-type-grid">
                <div class="nl-type-card active" id="companyCard" onclick="switchAccountType('company')">
                    <div class="nl-type-icon company">
                        <i class="ti ti-building-warehouse"></i>
                    </div>
                    <div class="nl-type-info">
                        <div class="nl-type-title">Company Account</div>
                        <div class="nl-type-desc">For logistics operators, freight forwarders &amp; shipping lines</div>
                    </div>
                    <div class="nl-type-radio"></div>
                </div>

                <div class="nl-type-card" id="customerCard" onclick="switchAccountType('customer')">
                    <div class="nl-type-icon customer">
                        <i class="ti ti-user-circle"></i>
                    </div>
                    <div class="nl-type-info">
                        <div class="nl-type-title">Customer Account</div>
                        <div class="nl-type-desc">For cargo owners, commercial shippers &amp; consignees</div>
                    </div>
                    <div class="nl-type-radio"></div>
                </div>
            </div>

            <!-- Registration Form -->
            <form action="<c:url value='/register'/>" method="POST" enctype="multipart/form-data" id="registerForm" onsubmit="return validateRegisterForm(event)">
                <input type="hidden" name="type" id="accountTypeInput" value="company">

                <!-- SECTION 1: ORGANIZATION / PROFILE DETAILS -->
                <div class="nl-section-header">
                    <div class="nl-section-badge-icon orange" id="sec1Icon">
                        <i class="ti ti-building"></i>
                    </div>
                    <div class="nl-section-title" id="sec1Title">Company Information</div>
                </div>

                <div class="nl-fields-grid">
                    <!-- Company Name / Full Name -->
                    <div class="nl-field-box">
                        <label id="nameLabel" for="inputName">Company Name <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-building lead-icon" id="nameLeadIcon"></i>
                            <input type="text" id="inputName" name="companyName" class="nl-form-control" placeholder="e.g. Apex Global Logistics Ltd" required minlength="3" maxlength="150">
                        </div>
                    </div>

                    <!-- Trade License / Reg No (Company Only - ) -->
                    <div class="nl-field-box company-field">
                        <label for="inputLicense">License / Registration Number <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-license lead-icon"></i>
                            <input type="text" id="inputLicense" name="licenseNo" class="nl-form-control" placeholder="e.g. REG-2026-MUM-8910" required minlength="3" maxlength="50" style="text-transform: uppercase;">
                        </div>
                    </div>

                    <!-- GST / Tax ID (Company Only - ) -->
                    <div class="nl-field-box company-field">
                        <label for="inputGst">GST / Tax ID <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-receipt lead-icon"></i>
                            <input type="text" id="inputGst" name="gstNo" class="nl-form-control" placeholder="e.g. 27AAAAA0000A1Z5" required minlength="5" maxlength="50" style="text-transform: uppercase;">
                        </div>
                    </div>

                    <!-- KYC Document Upload (Customer Only - ) -->
                    <div class="nl-field-box customer-field" style="display: none;">
                        <label for="inputKyc">KYC Document Upload <span class="req">*</span></label>
                        <div class="nl-file-input-wrap">
                            <i class="ti ti-file-upload lead-icon" style="position: absolute; left: 14px;"></i>
                            <input type="file" id="inputKyc" name="kycDoc" accept=".pdf,.jpg,.png" onchange="handleKycFileName(this)">
                            <span class="nl-file-label-text" id="kycFileNameText">Choose PDF, JPG, or PNG (ID / Certificate)</span>
                            <span class="nl-file-badge">Browse</span>
                        </div>
                    </div>

                    <!-- Registered Address  -->
                    <div class="nl-field-box" id="addressFieldBox">
                        <label id="addressLabel" for="inputAddress">Registered Company Address <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-map-pin lead-icon"></i>
                            <input type="text" id="inputAddress" name="address" class="nl-form-control" placeholder="Complete address (Street, City, State, Postal Code)" required minlength="5" maxlength="255">
                        </div>
                    </div>
                </div>

                <!-- SECTION 2: ADMIN CONTACT & CREDENTIALS  -->
                <div class="nl-section-header" style="margin-top: 28px;">
                    <div class="nl-section-badge-icon blue">
                        <i class="ti ti-user-check"></i>
                    </div>
                    <div class="nl-section-title" id="sec2Title">Admin Contact &amp; Account Credentials</div>
                </div>

                <div class="nl-fields-grid">

                    <!-- Contact Email -->
                    <div class="nl-field-box">
                        <label id="emailLabel" for="inputEmail">Admin Work Email <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-mail lead-icon"></i>
                            <input type="email" id="inputEmail" name="email" class="nl-form-control" placeholder="admin@company.com" required>
                        </div>
                    </div>

                    <!-- Contact Phone -->
                    <div class="nl-field-box">
                        <label for="inputPhone">Admin Contact Phone <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-phone lead-icon"></i>
                            <input type="tel" id="inputPhone" name="phone" class="nl-form-control" placeholder="+91 98201 12345" required minlength="8" maxlength="20">
                        </div>
                    </div>

                    <!-- Username -->
                    <div class="nl-field-box">
                        <label for="inputUsername">Admin Username <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-user lead-icon"></i>
                            <input type="text" id="inputUsername" name="username" class="nl-form-control" placeholder="Choose login username" required minlength="3" maxlength="50" autocomplete="username">
                        </div>
                    </div>

                    <!-- Create Password -->
                    <div class="nl-field-box">
                        <label for="inputPassword">Create Password <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-lock lead-icon"></i>
                            <input type="password" id="inputPassword" name="password" class="nl-form-control" placeholder="Minimum 8 characters" required minlength="8" maxlength="100" autocomplete="new-password" oninput="handlePasswordInput()">
                            <button type="button" class="nl-pwd-toggle" onclick="toggleRegPassword('inputPassword', this)" title="Show/Hide">
                                <i class="ti ti-eye-off"></i>
                            </button>
                        </div>
                        <div class="nl-validation-hint muted" id="pwdLengthHint">
                            <i class="ti ti-info-circle"></i> Minimum 8 characters required
                        </div>
                    </div>

                    <!-- Confirm Password -->
                    <div class="nl-field-box">
                        <label for="inputConfirmPassword">Confirm Password <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-lock-check lead-icon"></i>
                            <input type="password" id="inputConfirmPassword" name="confirmPassword" class="nl-form-control" placeholder="Re-enter password" required minlength="8" maxlength="100" autocomplete="new-password" oninput="handleConfirmPasswordInput()">
                            <button type="button" class="nl-pwd-toggle" onclick="toggleRegPassword('inputConfirmPassword', this)" title="Show/Hide">
                                <i class="ti ti-eye-off"></i>
                            </button>
                        </div>
                        <div class="nl-validation-hint muted" id="pwdMatchHint">
                            <i class="ti ti-lock"></i> Re-enter to confirm password match
                        </div>
                    </div>
                </div>

                <!-- Super Admin Approval Requirement Notice  -->
                <div class="nl-approval-notice" id="approvalNotice">
                    <i class="ti ti-shield-alert"></i>
                    <div>
                        <strong>Super Admin Approval Required:</strong> As required by system governance, company registration creates an account with <strong>Pending</strong> status. Terminal access will be activated once verified and approved by the Super Admin.
                    </div>
                </div>

                <!-- Footer Bar -->
                <div class="nl-reg-footer">
                    <label class="nl-terms-checkbox">
                        <input type="checkbox" id="termsAgree" required checked>
                        <span>I agree to the <a href="javascript:void(0);">Terms &amp; Conditions</a> and <a href="javascript:void(0);">Privacy Policy</a></span>
                    </label>

                    <div class="nl-btn-group">
                        <a href="<c:url value='/login'/>" class="nl-btn-cancel">Cancel</a>
                        <button type="submit" class="nl-btn-submit" id="submitRegBtn">
                            <i class="ti ti-user-plus" id="submitBtnIcon"></i>
                            <span id="submitBtnText">Register Company</span>
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // Password Visibility Toggle
    function toggleRegPassword(id, btn) {
        const input = document.getElementById(id);
        const icon = btn.querySelector('i');
        if (input.type === 'password') {
            input.type = 'text';
            icon.className = 'ti ti-eye';
        } else {
            input.type = 'password';
            icon.className = 'ti ti-eye-off';
        }
    }

    // KYC File Name Display
    function handleKycFileName(input) {
        const textSpan = document.getElementById('kycFileNameText');
        if (input.files && input.files[0]) {
            textSpan.textContent = input.files[0].name;
            textSpan.style.color = '#0F172A';
            textSpan.style.fontWeight = '600';
        } else {
            textSpan.textContent = 'Choose PDF, JPG, or PNG (ID / Certificate)';
            textSpan.style.color = '#64748B';
            textSpan.style.fontWeight = 'normal';
        }
    }

    // Strict  /  Account Type Switcher
    function switchAccountType(type) {
        const compCard = document.getElementById('companyCard');
        const custCard = document.getElementById('customerCard');
        const accountTypeInput = document.getElementById('accountTypeInput');
        const companyFields = document.querySelectorAll('.company-field');
        const customerFields = document.querySelectorAll('.customer-field');
        const nameLabel = document.getElementById('nameLabel');
        const nameLeadIcon = document.getElementById('nameLeadIcon');
        const nameInput = document.getElementById('inputName');
        const emailLabel = document.getElementById('emailLabel');
        const addressLabel = document.getElementById('addressLabel');
        const sec1Title = document.getElementById('sec1Title');
        const sec1Icon = document.getElementById('sec1Icon');
        const sec2Title = document.getElementById('sec2Title');
        const submitBtnText = document.getElementById('submitBtnText');
        const approvalNotice = document.getElementById('approvalNotice');
        const kycInput = document.getElementById('inputKyc');

        if (type === 'company') {
            compCard.classList.add('active');
            custCard.classList.remove('active');
            accountTypeInput.value = 'company';

            // Show company-only fields (license, gst, contact person) and require them
            companyFields.forEach(f => {
                f.style.display = 'flex';
                const inp = f.querySelector('input');
                if (inp) inp.required = true;
            });

            // Hide customer-only fields (kyc upload)
            customerFields.forEach(f => {
                f.style.display = 'none';
            });
            if (kycInput) kycInput.required = false;

            nameLabel.innerHTML = 'Company Name <span class="req">*</span>';
            nameLeadIcon.className = 'ti ti-building lead-icon';
            nameInput.placeholder = 'e.g. Apex Global Logistics Ltd';
            emailLabel.innerHTML = 'Admin Work Email <span class="req">*</span>';
            addressLabel.innerHTML = 'Registered Company Address <span class="req">*</span>';

            sec1Title.textContent = 'Company Information';
            sec1Icon.className = 'nl-section-badge-icon orange';
            sec1Icon.innerHTML = '<i class="ti ti-building"></i>';
            sec2Title.textContent = 'Admin Contact & Account Credentials';
            submitBtnText.textContent = 'Register Company';

            // Show Super Admin Approval Notice
            approvalNotice.style.display = 'flex';
            approvalNotice.innerHTML = '<i class="ti ti-shield-alert"></i><div><strong>Super Admin Approval Required:</strong> As required by system governance, company registration creates an account with <strong>Pending</strong> status. Terminal access will be activated once verified and approved by the Super Admin.</div>';
        } else {
            custCard.classList.add('active');
            compCard.classList.remove('active');
            accountTypeInput.value = 'customer';

            // Hide company-only fields (license, gst, contact person)
            companyFields.forEach(f => {
                f.style.display = 'none';
                const inp = f.querySelector('input');
                if (inp) inp.required = false;
            });

            // Show customer-only fields (kyc upload) and require them
            customerFields.forEach(f => {
                f.style.display = 'flex';
            });
            if (kycInput) kycInput.required = true;

            nameLabel.innerHTML = 'Full Legal Name <span class="req">*</span>';
            nameLeadIcon.className = 'ti ti-user lead-icon';
            nameInput.placeholder = 'e.g. Rahul Sharma';
            emailLabel.innerHTML = 'Personal / Work Email <span class="req">*</span>';
            addressLabel.innerHTML = 'Residential / Delivery Address <span class="req">*</span>';

            sec1Title.textContent = 'Customer Profile & KYC';
            sec1Icon.className = 'nl-section-badge-icon blue';
            sec1Icon.innerHTML = '<i class="ti ti-user-circle"></i>';
            sec2Title.textContent = 'Login Credentials';
            submitBtnText.textContent = 'Register Customer';

            // Update notice for customer
            approvalNotice.style.display = 'flex';
            approvalNotice.innerHTML = '<i class="ti ti-info-circle" style="color: #2563EB;"></i><div style="color: #1E40AF;"><strong>Customer Verification:</strong> KYC documents uploaded will be verified by the compliance department before your customer portal access is activated.</div>';
        }
    }

    // Real-Time Password Length Validation
    function handlePasswordInput() {
        const pwdInput = document.getElementById('inputPassword');
        const lengthHint = document.getElementById('pwdLengthHint');
        const val = pwdInput.value;

        if (val.length === 0) {
            pwdInput.classList.remove('is-valid-input', 'is-invalid-input');
            lengthHint.className = 'nl-validation-hint muted';
            lengthHint.innerHTML = '<i class="ti ti-info-circle"></i> Minimum 8 characters required';
        } else if (val.length < 8) {
            pwdInput.classList.add('is-invalid-input');
            pwdInput.classList.remove('is-valid-input');
            lengthHint.className = 'nl-validation-hint error';
            lengthHint.innerHTML = '<i class="ti ti-alert-triangle"></i> Too short: ' + val.length + '/8 characters';
        } else {
            pwdInput.classList.add('is-valid-input');
            pwdInput.classList.remove('is-invalid-input');
            lengthHint.className = 'nl-validation-hint success';
            lengthHint.innerHTML = '<i class="ti ti-check"></i> Password length requirement met (' + val.length + ' chars)';
        }

        const confirmInput = document.getElementById('inputConfirmPassword');
        if (confirmInput.value.length > 0) {
            handleConfirmPasswordInput();
        }
    }

    // Real-Time Confirm Password Matching
    function handleConfirmPasswordInput() {
        const pwdInput = document.getElementById('inputPassword');
        const confirmInput = document.getElementById('inputConfirmPassword');
        const matchHint = document.getElementById('pwdMatchHint');
        const pwd = pwdInput.value;
        const confirmPwd = confirmInput.value;

        if (confirmPwd.length === 0) {
            confirmInput.classList.remove('is-valid-input', 'is-invalid-input');
            matchHint.className = 'nl-validation-hint muted';
            matchHint.innerHTML = '<i class="ti ti-lock"></i> Re-enter to confirm password match';
            return;
        }

        if (pwd === confirmPwd) {
            confirmInput.classList.add('is-valid-input');
            confirmInput.classList.remove('is-invalid-input');
            matchHint.className = 'nl-validation-hint success';
            matchHint.innerHTML = '<i class="ti ti-circle-check" style="color: #059669;"></i> Passwords match perfectly!';
        } else {
            confirmInput.classList.add('is-invalid-input');
            confirmInput.classList.remove('is-valid-input');
            matchHint.className = 'nl-validation-hint error';
            matchHint.innerHTML = '<i class="ti ti-alert-circle" style="color: #DC2626;"></i> Passwords do not match';
        }
    }

    // Comprehensive Pre-Submission Validation
    function validateRegisterForm(e) {
        const clientAlert = document.getElementById('clientAlert');
        const clientAlertText = document.getElementById('clientAlertText');
        const pwdInput = document.getElementById('inputPassword');
        const confirmInput = document.getElementById('inputConfirmPassword');
        const pwd = pwdInput.value;
        const confirmPwd = confirmInput.value;

        if (!pwd || pwd.length < 8) {
            e.preventDefault();
            clientAlert.style.display = 'flex';
            clientAlertText.textContent = 'Password must be at least 8 characters long.';
            pwdInput.focus();
            pwdInput.classList.add('is-invalid-input');
            return false;
        }

        if (pwd !== confirmPwd) {
            e.preventDefault();
            clientAlert.style.display = 'flex';
            clientAlertText.textContent = 'Create Password and Confirm Password do not match. Please verify.';
            confirmInput.focus();
            confirmInput.classList.add('is-invalid-input');
            return false;
        }

        const phoneInput = document.getElementById('inputPhone');
        const phoneDigits = phoneInput.value.replace(/[^0-9]/g, '');
        if (phoneDigits.length < 8) {
            e.preventDefault();
            clientAlert.style.display = 'flex';
            clientAlertText.textContent = 'Please enter a valid phone number with at least 8 digits.';
            phoneInput.focus();
            phoneInput.classList.add('is-invalid-input');
            return false;
        }

        const accountType = document.getElementById('accountTypeInput').value;
        if (accountType === 'customer') {
            const kycInput = document.getElementById('inputKyc');
            if (!kycInput.files || kycInput.files.length === 0) {
                e.preventDefault();
                clientAlert.style.display = 'flex';
                clientAlertText.textContent = 'Please select and upload a valid KYC Document (PDF, JPG, PNG).';
                kycInput.focus();
                return false;
            }
        }

        const terms = document.getElementById('termsAgree');
        if (!terms.checked) {
            e.preventDefault();
            clientAlert.style.display = 'flex';
            clientAlertText.textContent = 'You must agree to the Terms & Conditions and Privacy Policy.';
            terms.focus();
            return false;
        }

        const submitBtn = document.getElementById('submitRegBtn');
        const submitBtnIcon = document.getElementById('submitBtnIcon');
        const submitBtnText = document.getElementById('submitBtnText');
        submitBtn.disabled = true;
        if (submitBtnIcon) submitBtnIcon.className = 'ti ti-loader-2 spin';
        submitBtnText.textContent = 'Submitting Registration...';

        clientAlert.style.display = 'none';
        return true;
    }

</script>

<jsp:include page="/jsp/layout/footer.jsp" />
