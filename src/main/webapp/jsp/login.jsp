<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="hideSidebar" value="true" scope="request" />
<c:set var="hideTopHeader" value="true" scope="request" />
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* Reset and Layout Root */
    body {
        background-color: #0F172A !important;
        margin: 0 !important;
        padding: 0 !important;
        overflow-x: hidden !important;
    }
    .main-wrapper {
        margin-left: 0 !important;
        width: 100% !important;
        min-height: 100vh !important;
        background: #0F172A !important;
    }
    .content-area {
        padding: 0 !important;
        margin: 0 !important;
        width: 100% !important;
    }

    /* Split-Screen Authentication Container */
    .nl-auth-split-wrapper {
        display: flex;
        min-height: 100vh;
        width: 100%;
        background: #0B1120;
    }

    /* ===================================================
       LEFT HERO SHOWCASE PANEL (55% Desktop)
       =================================================== */
    .nl-auth-hero-panel {
        flex: 1.15;
        background: radial-gradient(circle at 10% 20%, rgba(252, 128, 25, 0.12) 0%, transparent 40%),
                    radial-gradient(circle at 90% 80%, rgba(37, 99, 235, 0.12) 0%, transparent 45%),
                    linear-gradient(135deg, #090E1A 0%, #0F172A 60%, #131E36 100%);
        padding: 56px 64px;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        position: relative;
        overflow: hidden;
        border-right: 1px solid rgba(255, 255, 255, 0.08);
    }

    /* Ambient Subtle Grid Pattern */
    .nl-auth-hero-panel::before {
        content: "";
        position: absolute;
        inset: 0;
        background-image: linear-gradient(rgba(255, 255, 255, 0.03) 1px, transparent 1px),
                          linear-gradient(90deg, rgba(255, 255, 255, 0.03) 1px, transparent 1px);
        background-size: 36px 36px;
        pointer-events: none;
    }

    /* Top Brand Bar */
    .nl-hero-brand {
        position: relative;
        z-index: 2;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .nl-brand-box {
        display: flex;
        align-items: center;
        gap: 14px;
        text-decoration: none;
    }
    .nl-brand-logo-mark {
        width: 44px;
        height: 44px;
        background: linear-gradient(135deg, #FC8019 0%, #FF6600 100%);
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 6px 18px rgba(252, 128, 25, 0.35);
        color: #FFFFFF;
        font-size: 22px;
        font-weight: 900;
        letter-spacing: -0.5px;
    }
    .nl-brand-text-name {
        font-size: 20px;
        font-weight: 800;
        letter-spacing: -0.3px;
        color: #FFFFFF;
        line-height: 1.1;
    }
    .nl-brand-text-sub {
        font-size: 11.5px;
        color: #94A3B8;
        letter-spacing: 0.5px;
        text-transform: uppercase;
        font-weight: 600;
    }
    .nl-version-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: rgba(255, 255, 255, 0.06);
        border: 1px solid rgba(255, 255, 255, 0.12);
        color: #E2E8F0;
        font-size: 12px;
        font-weight: 600;
        padding: 5px 12px;
        border-radius: 20px;
        backdrop-filter: blur(8px);
    }
    .nl-version-badge .pulse-circle {
        width: 7px;
        height: 7px;
        background: #10B981;
        border-radius: 50%;
        box-shadow: 0 0 8px #10B981;
    }

    /* Hero Center Content */
    .nl-hero-center {
        position: relative;
        z-index: 2;
        margin: 40px 0;
        max-width: 620px;
    }
    .nl-hero-pill {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: rgba(252, 128, 25, 0.12);
        border: 1px solid rgba(252, 128, 25, 0.3);
        color: #FC8019;
        font-size: 12px;
        font-weight: 700;
        padding: 6px 14px;
        border-radius: 20px;
        margin-bottom: 20px;
        letter-spacing: 0.3px;
        text-transform: uppercase;
    }
    .nl-hero-title {
        font-size: 38px;
        font-weight: 800;
        line-height: 1.2;
        color: #F8FAFC;
        letter-spacing: -0.8px;
        margin-bottom: 16px;
    }
    .nl-hero-title span {
        background: linear-gradient(135deg, #FC8019 0%, #FF9E4A 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
    }
    .nl-hero-desc {
        font-size: 15.5px;
        color: #94A3B8;
        line-height: 1.6;
        margin-bottom: 32px;
    }

    /* Feature Pillars */
    .nl-feature-cards {
        display: flex;
        flex-direction: column;
        gap: 16px;
        margin-bottom: 36px;
    }
    .nl-feat-item {
        display: flex;
        align-items: flex-start;
        gap: 16px;
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(255, 255, 255, 0.06);
        border-radius: 12px;
        padding: 14px 18px;
        backdrop-filter: blur(6px);
        transition: all 0.2s ease;
    }
    .nl-feat-item:hover {
        background: rgba(255, 255, 255, 0.06);
        border-color: rgba(252, 128, 25, 0.3);
        transform: translateX(4px);
    }
    .nl-feat-icon {
        width: 38px;
        height: 38px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 19px;
        flex-shrink: 0;
    }
    .nl-feat-icon.orange { background: rgba(252, 128, 25, 0.15); color: #FC8019; }
    .nl-feat-icon.blue   { background: rgba(37, 99, 235, 0.15); color: #60A5FA; }
    .nl-feat-icon.green  { background: rgba(16, 185, 129, 0.15); color: #34D399; }
    .nl-feat-title {
        font-size: 14px;
        font-weight: 700;
        color: #F1F5F9;
        margin-bottom: 2px;
    }
    .nl-feat-desc {
        font-size: 12.5px;
        color: #94A3B8;
        line-height: 1.4;
    }

    /* Live Telemetry Card */
    .nl-telemetry-strip {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 12px;
        background: rgba(15, 23, 42, 0.7);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 14px;
        padding: 16px 20px;
        backdrop-filter: blur(12px);
    }
    .nl-stat-box {
        text-align: center;
        border-right: 1px solid rgba(255, 255, 255, 0.08);
        padding: 0 10px;
    }
    .nl-stat-box:last-child {
        border-right: none;
    }
    .nl-stat-val {
        font-size: 22px;
        font-weight: 800;
        color: #FFFFFF;
        line-height: 1.1;
    }
    .nl-stat-lbl {
        font-size: 11px;
        font-weight: 600;
        color: #94A3B8;
        text-transform: uppercase;
        letter-spacing: 0.4px;
        margin-top: 4px;
    }

    /* Hero Footer */
    .nl-hero-footer {
        position: relative;
        z-index: 2;
        font-size: 12px;
        color: #64748B;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    /* ===================================================
       RIGHT AUTHENTICATION FORM PANEL (45% Desktop)
       =================================================== */
    .nl-auth-form-panel {
        flex: 0.95;
        background: #E5EBF2;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 40px 32px;
    }
    .nl-auth-card {
        background: #FFFFFF;
        width: 100%;
        max-width: 460px;
        border-radius: 20px;
        padding: 40px 36px;
        box-shadow: 0 20px 40px rgba(15, 23, 42, 0.08), 0 1px 3px rgba(15, 23, 42, 0.04);
        border: 1px solid #E2E8F0;
        position: relative;
    }

    /* Mobile Brand (Hidden on desktop) */
    .nl-mobile-brand {
        display: none;
        align-items: center;
        justify-content: center;
        gap: 10px;
        margin-bottom: 24px;
    }

    .nl-auth-header {
        text-align: center;
        margin-bottom: 26px;
    }
    .nl-auth-icon-badge {
        width: 50px;
        height: 50px;
        background: #FFF2EB;
        border-radius: 14px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        color: #FC8019;
        font-size: 24px;
        margin-bottom: 14px;
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.15);
    }
    .nl-auth-title {
        font-size: 26px;
        font-weight: 800;
        color: #1E293B;
        letter-spacing: -0.4px;
        margin-bottom: 6px;
    }
    .nl-auth-subtitle {
        font-size: 13.5px;
        color: #64748B;
        line-height: 1.4;
    }

    /* Quick-Fill Demo Pills */
    .nl-demo-pills-wrap {
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        padding: 10px 14px;
        margin-bottom: 22px;
    }
    .nl-demo-label {
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        color: #64748B;
        margin-bottom: 8px;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .nl-demo-btns {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
    }
    .nl-demo-btn {
        background: #FFFFFF;
        border: 1px solid #CBD5E1;
        color: #334155;
        font-size: 12px;
        font-weight: 600;
        padding: 4px 11px;
        border-radius: 6px;
        cursor: pointer;
        transition: all 0.15s ease;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
    .nl-demo-btn:hover {
        background: #FFF2EB;
        border-color: #FC8019;
        color: #FC8019;
        transform: translateY(-1px);
    }
    .nl-demo-btn i {
        font-size: 13px;
    }

    /* Form Fields */
    .nl-field-group {
        margin-bottom: 18px;
    }
    .nl-field-label {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 13px;
        font-weight: 600;
        color: #334155;
        margin-bottom: 7px;
    }
    .nl-forgot-link {
        font-size: 12px;
        font-weight: 600;
        color: #FC8019;
        text-decoration: none;
        transition: color 0.15s ease;
    }
    .nl-forgot-link:hover {
        color: #E87010;
        text-decoration: underline;
    }
    .nl-input-wrap {
        position: relative;
        display: flex;
        align-items: center;
    }
    .nl-input-icon {
        position: absolute;
        left: 14px;
        color: #94A3B8;
        font-size: 17px;
        pointer-events: none;
        transition: color 0.15s ease;
    }
    .nl-input {
        width: 100%;
        height: 46px;
        padding: 0 42px 0 42px;
        font-size: 14px;
        font-weight: 500;
        color: #1E293B;
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        border-radius: 10px;
        transition: all 0.15s ease;
        outline: none;
    }
    .nl-input:focus {
        background: #FFFFFF;
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.15);
    }
    .nl-input:focus + .nl-input-icon,
    .nl-input-wrap:focus-within .nl-input-icon {
        color: #FC8019;
    }
    .nl-eye-btn {
        position: absolute;
        right: 12px;
        background: transparent;
        border: none;
        color: #94A3B8;
        font-size: 18px;
        cursor: pointer;
        padding: 4px 6px;
        border-radius: 6px;
        transition: color 0.15s ease;
    }
    .nl-eye-btn:hover {
        color: #FC8019;
    }

    /* Remember Checkbox */
    .nl-remember-wrap {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 22px;
        font-size: 13px;
        color: #475569;
        cursor: pointer;
        user-select: none;
    }
    .nl-remember-wrap input[type="checkbox"] {
        accent-color: #FC8019;
        width: 16px;
        height: 16px;
        cursor: pointer;
    }

    /* Submit Button */
    .nl-btn-signin {
        width: 100%;
        height: 48px;
        background: linear-gradient(135deg, #FC8019 0%, #FF6600 100%);
        border: none;
        border-radius: 10px;
        color: #FFFFFF;
        font-size: 15px;
        font-weight: 700;
        letter-spacing: 0.2px;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        cursor: pointer;
        transition: all 0.2s ease;
        box-shadow: 0 6px 18px rgba(252, 128, 25, 0.28);
    }
    .nl-btn-signin:hover {
        background: linear-gradient(135deg, #E87010 0%, #E65100 100%);
        transform: translateY(-2px);
        box-shadow: 0 8px 24px rgba(252, 128, 25, 0.38);
    }
    .nl-btn-signin:active {
        transform: translateY(0);
    }

    /* Alerts */
    .nl-auth-alert {
        display: flex;
        align-items: flex-start;
        gap: 10px;
        padding: 12px 14px;
        border-radius: 10px;
        font-size: 13px;
        margin-bottom: 18px;
    }
    .nl-auth-alert.danger {
        background: #FEF2F2;
        border: 1px solid #FCA5A5;
        color: #991B1B;
    }
    .nl-auth-alert.success {
        background: #ECFDF5;
        border: 1px solid #A7F3D0;
        color: #065F46;
    }

    /* Footer & Register Link */
    .nl-auth-card-footer {
        margin-top: 24px;
        padding-top: 20px;
        border-top: 1px solid #F1F5F9;
        text-align: center;
    }
    .nl-register-text {
        font-size: 13px;
        color: #64748B;
    }
    .nl-register-link {
        font-weight: 700;
        color: #FC8019;
        text-decoration: none;
        transition: color 0.15s ease;
    }
    .nl-register-link:hover {
        color: #E87010;
        text-decoration: underline;
    }

    .nl-security-badge {
        margin-top: 14px;
        font-size: 11.5px;
        color: #94A3B8;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 5px;
    }

    /* ===================================================
       RESPONSIVE BREAKPOINTS
       =================================================== */
    @media (max-width: 1024px) {
        .nl-auth-hero-panel {
            display: none !important;
        }
        .nl-auth-form-panel {
            flex: 1;
            min-height: 100vh;
            padding: 30px 16px;
        }
        .nl-mobile-brand {
            display: flex;
        }
    }
</style>

<div class="nl-auth-split-wrapper">
    <!-- LEFT HERO SHOWCASE PANEL -->
    <div class="nl-auth-hero-panel">
        <!-- Top Brand Bar -->
        <div class="nl-hero-brand">
            <a href="<c:url value='/'/>" class="nl-brand-box">
                <div class="nl-brand-logo-mark">N</div>
                <div>
                    <div class="nl-brand-text-name">N LOGISTIC</div>
                    <div class="nl-brand-text-sub">Global Logistics Solution</div>
                </div>
            </a>
            <div class="nl-version-badge">
                <span class="pulse-circle"></span> Enterprise v2.4 Live
            </div>
        </div>

        <!-- Center Hero Content -->
        <div class="nl-hero-center">
            <div class="nl-hero-pill">
                <i class="ti ti-shield-check"></i> ISO 9001 &amp; CT-PAT Certified
            </div>
            <h1 class="nl-hero-title">
                Next-Gen Freight Orchestration &amp; <span>Global Telemetry.</span>
            </h1>
            <p class="nl-hero-desc">
                Centralized enterprise portal for international shipping operations. Monitor multimodal container movements, AIS vessel tracking, and dynamic pricing across active global corridors.
            </p>

            <!-- Feature Highlights -->
            <div class="nl-feature-cards">
                <div class="nl-feat-item">
                    <div class="nl-feat-icon orange">
                        <i class="ti ti-ship"></i>
                    </div>
                    <div>
                        <div class="nl-feat-title">Live AIS Vessel &amp; Container Tracking</div>
                        <div class="nl-feat-desc">Sub-second telemetry and precision ETA tracking across 30+ international sea ports.</div>
                    </div>
                </div>

                <div class="nl-feat-item">
                    <div class="nl-feat-icon blue">
                        <i class="ti ti-timeline"></i>
                    </div>
                    <div>
                        <div class="nl-feat-title">Checkpoint Automation &amp; Audit Logs</div>
                        <div class="nl-feat-desc">Tamper-proof milestone recording with instant dispatch and customs clearance notifications.</div>
                    </div>
                </div>

                <div class="nl-feat-item">
                    <div class="nl-feat-icon green">
                        <i class="ti ti-trending-up"></i>
                    </div>
                    <div>
                        <div class="nl-feat-title">AI Dynamic Pricing Engine</div>
                        <div class="nl-feat-desc">Seasonal surge multipliers and real-time route capacity demand calculations.</div>
                    </div>
                </div>
            </div>

            <!-- Telemetry Stats Strip -->
            <div class="nl-telemetry-strip">
                <div class="nl-stat-box">
                    <div class="nl-stat-val">30</div>
                    <div class="nl-stat-lbl">Global Ports</div>
                </div>
                <div class="nl-stat-box">
                    <div class="nl-stat-val">300+</div>
                    <div class="nl-stat-lbl">Active Containers</div>
                </div>
                <div class="nl-stat-box">
                    <div class="nl-stat-val">99.9%</div>
                    <div class="nl-stat-lbl">Tracking Uptime</div>
                </div>
            </div>
        </div>

        <!-- Hero Footer -->
        <div class="nl-hero-footer">
            <div>&copy; 2026 N Logistic Maritime Systems Inc. All rights reserved.</div>
            <div class="d-flex align-items-center gap-3">
                <span>Privacy Policy</span>
                <span>&bull;</span>
                <span>Terms of Service</span>
            </div>
        </div>
    </div>

    <!-- RIGHT AUTHENTICATION FORM PANEL -->
    <div class="nl-auth-form-panel">
        <div class="nl-auth-card">
            <!-- Mobile Brand Header -->
            <div class="nl-mobile-brand">
                <div class="nl-brand-logo-mark" style="width: 36px; height: 36px; font-size: 18px;">N</div>
                <div class="nl-brand-text-name" style="color: #0F172A; font-size: 18px;">N LOGISTIC</div>
            </div>

            <!-- Card Header -->
            <div class="nl-auth-header">
                <div class="nl-auth-icon-badge">
                    <i class="ti ti-lock-access"></i>
                </div>
                <h2 class="nl-auth-title">Welcome Back</h2>
                <p class="nl-auth-subtitle">Sign in to your N Logistic enterprise account to manage fleet operations.</p>
            </div>

            <!-- Quick-Fill Demo Account Pills -->
            <div class="nl-demo-pills-wrap">
                <div class="nl-demo-label">
                    <span><i class="ti ti-bolt text-warning me-1"></i> 1-Click Quick Demo Login</span>
                    <span style="font-size: 10px; color: #94A3B8;">Auto-fill</span>
                </div>
                <div class="nl-demo-btns">
                    <button type="button" class="nl-demo-btn" onclick="fillCredentials('superadmin', 'admin123')">
                        <i class="ti ti-shield-lock"></i> Super Admin
                    </button>
                    <button type="button" class="nl-demo-btn" onclick="fillCredentials('customer1', 'pass123')">
                        <i class="ti ti-user"></i> Customer
                    </button>
                    <button type="button" class="nl-demo-btn" onclick="fillCredentials('staff1', 'pass123')">
                        <i class="ti ti-briefcase"></i> Staff
                    </button>
                </div>
            </div>

            <!-- Feedback Notifications -->
            <c:if test="${not empty errorMessage}">
                <div class="nl-auth-alert danger">
                    <i class="ti ti-alert-circle fs-5" style="color: #DC2626;"></i>
                    <div>${errorMessage}</div>
                </div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="nl-auth-alert success">
                    <i class="ti ti-circle-check fs-5" style="color: #059669;"></i>
                    <div>${successMessage}</div>
                </div>
            </c:if>

            <!-- Authentication Form -->
            <form action="<c:url value='/login'/>" method="POST" id="loginForm">
                <!-- Username Field -->
                <div class="nl-field-group">
                    <label class="nl-field-label" for="loginUsername">Username / Email</label>
                    <div class="nl-input-wrap">
                        <i class="ti ti-user nl-input-icon"></i>
                        <input type="text" id="loginUsername" name="username" class="nl-input" required placeholder="Enter username or email address" autocomplete="username">
                    </div>
                </div>

                <!-- Password Field -->
                <div class="nl-field-group">
                    <div class="nl-field-label">
                        <label for="loginPassword" style="margin: 0;">Password</label>
                        <a href="<c:url value='/forgot-password'/>" class="nl-forgot-link">Forgot Password?</a>
                    </div>
                    <div class="nl-input-wrap">
                        <i class="ti ti-lock nl-input-icon"></i>
                        <input type="password" id="loginPassword" name="password" class="nl-input" required placeholder="Enter your account password" autocomplete="current-password">
                        <button type="button" class="nl-eye-btn" onclick="togglePasswordVisibility()" title="Toggle password visibility">
                            <i class="ti ti-eye-off" id="eyeIcon"></i>
                        </button>
                    </div>
                </div>

                <!-- Remember Device Option -->
                <label class="nl-remember-wrap">
                    <input type="checkbox" name="rememberMe" checked>
                    <span>Remember this workstation for 30 days</span>
                </label>

                <!-- Submit Button -->
                <button type="submit" class="nl-btn-signin" id="submitBtn">
                    <span>Sign In to Terminal</span>
                    <i class="ti ti-arrow-right"></i>
                </button>

                <!-- Footer & Register Link -->
                <div class="nl-auth-card-footer">
                    <div class="nl-register-text">
                        Don't have an enterprise account? 
                        <a href="<c:url value='/register'/>" class="nl-register-link">Register here &rarr;</a>
                    </div>
                    <div class="nl-security-badge">
                        <i class="ti ti-shield-lock" style="color: #10B981;"></i>
                        <span>256-Bit SSL Encrypted Enterprise Terminal</span>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function togglePasswordVisibility() {
        const pwdInput = document.getElementById('loginPassword');
        const eyeIcon = document.getElementById('eyeIcon');
        if (pwdInput.type === 'password') {
            pwdInput.type = 'text';
            eyeIcon.classList.remove('ti-eye-off');
            eyeIcon.classList.add('ti-eye');
        } else {
            pwdInput.type = 'password';
            eyeIcon.classList.remove('ti-eye');
            eyeIcon.classList.add('ti-eye-off');
        }
    }

    function fillCredentials(user, pass) {
        const uInput = document.getElementById('loginUsername');
        const pInput = document.getElementById('loginPassword');
        uInput.value = user;
        pInput.value = pass;
        
        // Highlight inputs briefly
        uInput.style.borderColor = '#FC8019';
        pInput.style.borderColor = '#FC8019';
        setTimeout(() => {
            uInput.style.borderColor = '#E2E8F0';
            pInput.style.borderColor = '#E2E8F0';
        }, 800);
    }
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
