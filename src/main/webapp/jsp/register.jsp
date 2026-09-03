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
        max-width: 1100px;
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
        border-radius: 9px;
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
        margin-bottom: 32px;
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

    /* Section Divider */
    .nl-form-divider {
        display: flex;
        align-items: center;
        gap: 16px;
        margin: 10px 0 28px;
    }
    .nl-divider-line {
        flex: 1;
        height: 1px;
        background: #E2E8F0;
    }
    .nl-divider-title {
        font-size: 13px;
        font-weight: 700;
        color: #475569;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    /* Form Fields Grid */
    .nl-fields-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 20px;
    }
    .nl-field-box {
        display: flex;
        flex-direction: column;
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
        height: 44px;
        padding-left: 44px !important;
        padding-right: 14px;
        font-size: 13.5px;
        font-weight: 500;
        color: #0F172A;
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        border-radius: 9px;
        transition: all 0.15s ease;
        outline: none;
    }
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
        border-radius: 9px;
        height: 44px;
        padding: 4px 10px 4px 44px;
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
        padding: 3px 8px;
        border-radius: 5px;
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

    /* Bottom Action Bar */
    .nl-reg-footer {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-top: 32px;
        padding-top: 24px;
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
        border-radius: 9px;
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
        padding: 10px 26px;
        border-radius: 9px;
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
    @media (max-width: 992px) {
        .nl-fields-grid {
            grid-template-columns: repeat(2, 1fr);
        }
    }
    @media (max-width: 768px) {
        .nl-reg-canvas {
            padding: 24px 16px;
        }
        .nl-reg-card {
            padding: 26px 20px;
        }
        .nl-type-grid {
            grid-template-columns: 1fr;
        }
        .nl-fields-grid {
            grid-template-columns: 1fr;
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
                    <i class="ti ti-user-plus"></i> Organization Onboarding
                </div>
                <h1 class="nl-reg-heading">Create Your Enterprise Account</h1>
                <p class="nl-reg-subheading">Choose your account type and fill in the verified registration credentials to get started.</p>
            </div>

            <!-- Error Notification -->
            <c:if test="${not empty errorMessage}">
                <div class="nl-reg-alert danger">
                    <i class="ti ti-alert-circle fs-5" style="color: #DC2626;"></i>
                    <div>${errorMessage}</div>
                </div>
            </c:if>

            <!-- Account Type Selector Cards -->
            <div class="nl-type-grid">
                <div class="nl-type-card active" onclick="switchAccountType('company', this)">
                    <div class="nl-type-icon company">
                        <i class="ti ti-building-warehouse"></i>
                    </div>
                    <div class="nl-type-info">
                        <div class="nl-type-title">Company Account</div>
                        <div class="nl-type-desc">For logistics companies, freight forwarders &amp; fleet operators</div>
                    </div>
                    <div class="nl-type-radio"></div>
                </div>

                <div class="nl-type-card" onclick="switchAccountType('customer', this)">
                    <div class="nl-type-icon customer">
                        <i class="ti ti-user-circle"></i>
                    </div>
                    <div class="nl-type-info">
                        <div class="nl-type-title">Customer Account</div>
                        <div class="nl-type-desc">For commercial shippers, consignees &amp; individual businesses</div>
                    </div>
                    <div class="nl-type-radio"></div>
                </div>
            </div>

            <!-- Registration Form -->
            <form action="<c:url value='/register'/>" method="POST" enctype="multipart/form-data" id="registerForm">
                <input type="hidden" name="type" id="accountTypeInput" value="company">

                <!-- Section Divider -->
                <div class="nl-form-divider">
                    <div class="nl-divider-line"></div>
                    <div class="nl-divider-title" id="formDividerTitle">
                        <i class="ti ti-building" style="color: #FC8019;"></i> Company Registration Details
                    </div>
                    <div class="nl-divider-line"></div>
                </div>

                <!-- 3-Column Inputs Grid -->
                <div class="nl-fields-grid">
                    <!-- Name Field -->
                    <div class="nl-field-box">
                        <label id="nameLabel" for="inputName">Company Name <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-building lead-icon"></i>
                            <input type="text" id="inputName" name="companyName" class="nl-form-control" placeholder="Enter registered company name" required>
                        </div>
                    </div>

                    <!-- Email Field -->
                    <div class="nl-field-box">
                        <label id="emailLabel" for="inputEmail">Company Email <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-mail lead-icon"></i>
                            <input type="email" id="inputEmail" name="email" class="nl-form-control" placeholder="corporate@company.com" required>
                        </div>
                    </div>

                    <!-- Username Field -->
                    <div class="nl-field-box">
                        <label for="inputUsername">Admin Username <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-user lead-icon"></i>
                            <input type="text" id="inputUsername" name="username" class="nl-form-control" placeholder="Choose admin username" required autocomplete="username">
                        </div>
                    </div>

                    <!-- Contact Person -->
                    <div class="nl-field-box">
                        <label for="inputContact">Contact Person <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-id lead-icon"></i>
                            <input type="text" id="inputContact" name="contactPerson" class="nl-form-control" placeholder="Full name of representative" required>
                        </div>
                    </div>

                    <!-- Phone Number -->
                    <div class="nl-field-box">
                        <label for="inputPhone">Phone Number <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-phone lead-icon"></i>
                            <input type="tel" id="inputPhone" name="phone" class="nl-form-control" placeholder="+1 (555) 000-0000" required>
                        </div>
                    </div>

                    <!-- GST / Tax Number (Company Only) -->
                    <div class="nl-field-box company-only">
                        <label for="inputGst">GST / Tax Number <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-receipt lead-icon"></i>
                            <input type="text" id="inputGst" name="gstNo" class="nl-form-control" placeholder="e.g. 27AAAAA0000A1Z5" required>
                        </div>
                    </div>

                    <!-- License / Reg Number (Company Only) -->
                    <div class="nl-field-box company-only">
                        <label for="inputLicense">Trade License / Reg No <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-license lead-icon"></i>
                            <input type="text" id="inputLicense" name="licenseNo" class="nl-form-control" placeholder="Official Registration No." required>
                        </div>
                    </div>

                    <!-- KYC Document Upload -->
                    <div class="nl-field-box">
                        <label for="inputKyc">KYC Document / Certificate <span class="req">*</span></label>
                        <div class="nl-file-input-wrap">
                            <i class="ti ti-file-upload lead-icon" style="position: absolute; left: 14px;"></i>
                            <input type="file" id="inputKyc" name="kycDoc" accept=".pdf,.jpg,.png" required onchange="handleKycFileName(this)">
                            <span class="nl-file-label-text" id="kycFileNameText">Choose PDF, JPG, or PNG</span>
                            <span class="nl-file-badge">Browse</span>
                        </div>
                    </div>

                    <!-- Company Address -->
                    <div class="nl-field-box">
                        <label id="addressLabel" for="inputAddress">Company Address <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-map-pin lead-icon"></i>
                            <input type="text" id="inputAddress" name="address" class="nl-form-control" placeholder="Street address, building, suite" required>
                        </div>
                    </div>

                    <!-- City -->
                    <div class="nl-field-box">
                        <label for="inputCity">City <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-building-community lead-icon"></i>
                            <input type="text" id="inputCity" name="city" class="nl-form-control" placeholder="Enter city" required>
                        </div>
                    </div>

                    <!-- State Dropdown -->
                    <div class="nl-field-box">
                        <label for="inputState">State / Province <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-map lead-icon"></i>
                            <select id="inputState" name="state" class="form-select form-select-custom no-custom-select nl-form-control" required style="padding-left: 44px !important;">
                                <option value="" disabled selected>Select state / province</option>
                                <option value="MH">Maharashtra</option>
                                <option value="KA">Karnataka</option>
                                <option value="DL">Delhi</option>
                                <option value="TN">Tamil Nadu</option>
                                <option value="GJ">Gujarat</option>
                                <option value="WB">West Bengal</option>
                                <option value="OTHER">Other / International</option>
                            </select>
                        </div>
                    </div>

                    <!-- PIN / Postal Code -->
                    <div class="nl-field-box">
                        <label for="inputPin">PIN / Postal Code <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-hash lead-icon"></i>
                            <input type="text" id="inputPin" name="pinCode" class="nl-form-control" placeholder="e.g. 400001" required>
                        </div>
                    </div>

                    <!-- Password -->
                    <div class="nl-field-box">
                        <label for="inputPassword">Create Password <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-lock lead-icon"></i>
                            <input type="password" id="inputPassword" name="password" class="nl-form-control" placeholder="Minimum 8 characters" required autocomplete="new-password">
                            <button type="button" class="nl-pwd-toggle" onclick="toggleRegPassword('inputPassword', this)" title="Show/Hide">
                                <i class="ti ti-eye-off"></i>
                            </button>
                        </div>
                    </div>

                    <!-- Confirm Password -->
                    <div class="nl-field-box">
                        <label for="inputConfirmPassword">Confirm Password <span class="req">*</span></label>
                        <div class="nl-input-wrap">
                            <i class="ti ti-lock-check lead-icon"></i>
                            <input type="password" id="inputConfirmPassword" name="confirmPassword" class="nl-form-control" placeholder="Re-enter password" required autocomplete="new-password">
                            <button type="button" class="nl-pwd-toggle" onclick="toggleRegPassword('inputConfirmPassword', this)" title="Show/Hide">
                                <i class="ti ti-eye-off"></i>
                            </button>
                        </div>
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
                            <i class="ti ti-user-plus"></i>
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
            textSpan.textContent = 'Choose PDF, JPG, or PNG';
            textSpan.style.color = '#64748B';
            textSpan.style.fontWeight = 'normal';
        }
    }

    // Switch between Company Account and Customer Account
    function switchAccountType(type, cardEl) {
        document.querySelectorAll('.nl-type-card').forEach(c => c.classList.remove('active'));
        if (cardEl) {
            cardEl.classList.add('active');
        }
        document.getElementById('accountTypeInput').value = type;

        const title = document.getElementById('formDividerTitle');
        const submitText = document.getElementById('submitBtnText');
        const companyOnlyFields = document.querySelectorAll('.company-only');
        const nameLabel = document.getElementById('nameLabel');
        const emailLabel = document.getElementById('emailLabel');
        const addressLabel = document.getElementById('addressLabel');
        const nameInput = document.getElementById('inputName');

        if (type === 'company') {
            title.innerHTML = '<i class="ti ti-building" style="color: #FC8019;"></i> Company Registration Details';
            submitText.textContent = 'Register Company';

            companyOnlyFields.forEach(el => {
                el.style.display = 'flex';
                const inp = el.querySelector('input');
                if (inp) inp.required = true;
            });

            nameLabel.innerHTML = 'Company Name <span class="req">*</span>';
            emailLabel.innerHTML = 'Company Email <span class="req">*</span>';
            addressLabel.innerHTML = 'Company Address <span class="req">*</span>';
            nameInput.placeholder = 'Enter registered company name';
        } else {
            title.innerHTML = '<i class="ti ti-user" style="color: #2563EB;"></i> Customer Profile Details';
            submitText.textContent = 'Register Customer';

            companyOnlyFields.forEach(el => {
                el.style.display = 'none';
                const inp = el.querySelector('input');
                if (inp) inp.required = false;
            });

            nameLabel.innerHTML = 'Full Legal Name <span class="req">*</span>';
            emailLabel.innerHTML = 'Personal / Work Email <span class="req">*</span>';
            addressLabel.innerHTML = 'Billing / Residential Address <span class="req">*</span>';
            nameInput.placeholder = 'Enter full legal name';
        }
    }
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
