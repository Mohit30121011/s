<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="hideSidebar" value="true" scope="request" />
<c:set var="hideTopHeader" value="true" scope="request" />
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* ===================================================
       ROOT SPLIT-SCREEN RESET & HIGH-PERFORMANCE ANIMATIONS
       =================================================== */
    body {
        background-color: #0B1120 !important;
        margin: 0 !important;
        padding: 0 !important;
        overflow-x: hidden !important;
    }
    .main-wrapper {
        margin-left: 0 !important;
        width: 100% !important;
        min-height: 100vh !important;
        background: #0B1120 !important;
    }
    .content-area {
        padding: 0 !important;
        margin: 0 !important;
        width: 100% !important;
    }

    /* Keyframe Animations */
    @keyframes fadeInUp {
        0% {
            opacity: 0;
            transform: translateY(24px);
        }
        100% {
            opacity: 1;
            transform: translateY(0);
        }
    }

    @keyframes fadeInRight {
        0% {
            opacity: 0;
            transform: translateX(30px);
        }
        100% {
            opacity: 1;
            transform: translateX(0);
        }
    }

    @keyframes floatOrb1 {
        0%, 100% {
            transform: translate(0, 0) scale(1);
        }
        50% {
            transform: translate(-30px, 20px) scale(1.08);
        }
    }

    @keyframes floatOrb2 {
        0%, 100% {
            transform: translate(0, 0) scale(1);
        }
        50% {
            transform: translate(25px, -25px) scale(1.06);
        }
    }

    @keyframes beaconPulse {
        0% {
            box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7);
        }
        70% {
            box-shadow: 0 0 0 8px rgba(16, 185, 129, 0);
        }
        100% {
            box-shadow: 0 0 0 0 rgba(16, 185, 129, 0);
        }
    }

    @keyframes shimmerBtn {
        0% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
        100% { background-position: 0% 50%; }
    }

    /* Pure Split Layout (No card inside container) */
    .nl-split-container {
        display: flex;
        min-height: 100vh;
        width: 100%;
    }

    /* ===================================================
       LEFT HERO SPLIT (Dark Slate Showcase with Ambient FX)
       =================================================== */
    .nl-split-left {
        flex: 1.15;
        background: linear-gradient(145deg, #070C18 0%, #0F172A 55%, #151F38 100%);
        padding: 50px 60px;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        position: relative;
        overflow: hidden;
        border-right: 1px solid rgba(255, 255, 255, 0.08);
    }

    /* Ambient Glowing Orbs */
    .nl-ambient-orb-1 {
        position: absolute;
        width: 380px;
        height: 380px;
        top: -80px;
        left: -80px;
        background: radial-gradient(circle, rgba(252, 128, 25, 0.18) 0%, transparent 70%);
        border-radius: 50%;
        filter: blur(50px);
        pointer-events: none;
        animation: floatOrb1 10s ease-in-out infinite;
    }
    .nl-ambient-orb-2 {
        position: absolute;
        width: 440px;
        height: 440px;
        bottom: -100px;
        right: -80px;
        background: radial-gradient(circle, rgba(37, 99, 235, 0.18) 0%, transparent 70%);
        border-radius: 50%;
        filter: blur(60px);
        pointer-events: none;
        animation: floatOrb2 12s ease-in-out infinite;
    }

    /* Subtle Geometric Grid */
    .nl-split-left::before {
        content: "";
        position: absolute;
        inset: 0;
        background-image: linear-gradient(rgba(255, 255, 255, 0.035) 1px, transparent 1px),
                          linear-gradient(90deg, rgba(255, 255, 255, 0.035) 1px, transparent 1px);
        background-size: 32px 32px;
        pointer-events: none;
        z-index: 1;
    }

    /* Left Header Brand */
    .nl-hero-nav {
        position: relative;
        z-index: 2;
        display: flex;
        align-items: center;
        justify-content: space-between;
        animation: fadeInUp 0.7s cubic-bezier(0.16, 1, 0.3, 1) both;
    }
    .nl-brand-link {
        display: flex;
        align-items: center;
        gap: 14px;
        text-decoration: none;
    }
    .nl-brand-gem {
        width: 46px;
        height: 46px;
        background: linear-gradient(135deg, #FC8019 0%, #FF6600 100%);
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 8px 24px rgba(252, 128, 25, 0.4);
        color: #FFFFFF;
        font-size: 24px;
        font-weight: 900;
        letter-spacing: -0.5px;
        transition: transform 0.3s ease;
    }
    .nl-brand-link:hover .nl-brand-gem {
        transform: rotate(6deg) scale(1.05);
    }
    .nl-brand-name {
        font-size: 21px;
        font-weight: 800;
        letter-spacing: -0.3px;
        color: #FFFFFF;
        line-height: 1.1;
    }
    .nl-brand-sub {
        font-size: 11px;
        color: #94A3B8;
        letter-spacing: 0.8px;
        text-transform: uppercase;
        font-weight: 600;
    }
    .nl-status-pill {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: rgba(255, 255, 255, 0.06);
        border: 1px solid rgba(255, 255, 255, 0.12);
        color: #E2E8F0;
        font-size: 12px;
        font-weight: 600;
        padding: 6px 14px;
        border-radius: 20px;
        backdrop-filter: blur(10px);
    }
    .nl-pulse-beacon {
        width: 8px;
        height: 8px;
        background: #10B981;
        border-radius: 50%;
        animation: beaconPulse 2s infinite;
    }

    /* Left Hero Main Content */
    .nl-hero-body {
        position: relative;
        z-index: 2;
        margin: 40px 0;
        max-width: 620px;
    }
    .nl-hero-badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: rgba(252, 128, 25, 0.12);
        border: 1px solid rgba(252, 128, 25, 0.32);
        color: #FC8019;
        font-size: 12px;
        font-weight: 700;
        padding: 6px 14px;
        border-radius: 20px;
        margin-bottom: 20px;
        letter-spacing: 0.4px;
        text-transform: uppercase;
        animation: fadeInUp 0.7s 0.1s cubic-bezier(0.16, 1, 0.3, 1) both;
    }
    .nl-hero-heading {
        font-size: 40px;
        font-weight: 800;
        line-height: 1.18;
        color: #F8FAFC;
        letter-spacing: -0.9px;
        margin-bottom: 16px;
        animation: fadeInUp 0.7s 0.2s cubic-bezier(0.16, 1, 0.3, 1) both;
    }
    .nl-hero-heading span {
        background: linear-gradient(135deg, #FC8019 0%, #FF9E4A 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
    }
    .nl-hero-description {
        font-size: 15.5px;
        color: #94A3B8;
        line-height: 1.6;
        margin-bottom: 34px;
        animation: fadeInUp 0.7s 0.3s cubic-bezier(0.16, 1, 0.3, 1) both;
    }

    /* Feature Cards with Hover Effects */
    .nl-features-stack {
        display: flex;
        flex-direction: column;
        gap: 14px;
        margin-bottom: 36px;
        animation: fadeInUp 0.7s 0.4s cubic-bezier(0.16, 1, 0.3, 1) both;
    }
    .nl-feature-item {
        display: flex;
        align-items: flex-start;
        gap: 16px;
        background: rgba(255, 255, 255, 0.035);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 12px;
        padding: 15px 18px;
        backdrop-filter: blur(8px);
        transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
    }
    .nl-feature-item:hover {
        background: rgba(255, 255, 255, 0.07);
        border-color: rgba(252, 128, 25, 0.4);
        transform: translateX(6px);
    }
    .nl-feature-icon {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        flex-shrink: 0;
        transition: transform 0.25s ease;
    }
    .nl-feature-item:hover .nl-feature-icon {
        transform: scale(1.1);
    }
    .nl-feature-icon.orange { background: rgba(252, 128, 25, 0.16); color: #FC8019; }
    .nl-feature-icon.blue   { background: rgba(37, 99, 235, 0.16); color: #60A5FA; }
    .nl-feature-icon.emerald{ background: rgba(16, 185, 129, 0.16); color: #34D399; }
    .nl-feature-title {
        font-size: 14px;
        font-weight: 700;
        color: #F1F5F9;
        margin-bottom: 3px;
    }
    .nl-feature-text {
        font-size: 12.5px;
        color: #94A3B8;
        line-height: 1.45;
    }

    /* Live Telemetry Metric Strip */
    .nl-telemetry-panel {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 12px;
        background: rgba(15, 23, 42, 0.75);
        border: 1px solid rgba(255, 255, 255, 0.12);
        border-radius: 14px;
        padding: 16px 20px;
        backdrop-filter: blur(14px);
        animation: fadeInUp 0.7s 0.5s cubic-bezier(0.16, 1, 0.3, 1) both;
    }
    .nl-tele-col {
        text-align: center;
        border-right: 1px solid rgba(255, 255, 255, 0.08);
        padding: 0 10px;
    }
    .nl-tele-col:last-child {
        border-right: none;
    }
    .nl-tele-number {
        font-size: 24px;
        font-weight: 800;
        color: #FFFFFF;
        line-height: 1.1;
    }
    .nl-tele-label {
        font-size: 11px;
        font-weight: 600;
        color: #94A3B8;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-top: 4px;
    }

    /* Left Hero Footer */
    .nl-hero-bottom {
        position: relative;
        z-index: 2;
        font-size: 12px;
        color: #64748B;
        display: flex;
        justify-content: space-between;
        align-items: center;
        animation: fadeInUp 0.7s 0.6s cubic-bezier(0.16, 1, 0.3, 1) both;
    }

    /* ===================================================
       RIGHT FORM SPLIT (Pure White Seamless Canvas)
       =================================================== */
    .nl-split-right {
        flex: 1;
        background: #FFFFFF !important;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        padding: 50px 48px;
        position: relative;
        overflow-y: auto;
    }

    /* Inner Form Centering Wrapper (No nested card border/box) */
    .nl-form-container {
        width: 100%;
        max-width: 440px;
        animation: fadeInRight 0.8s cubic-bezier(0.16, 1, 0.3, 1) both;
    }

    /* Mobile Brand (Shown on small screens) */
    .nl-compact-brand {
        display: none;
        align-items: center;
        justify-content: center;
        gap: 12px;
        margin-bottom: 28px;
    }

    /* Form Header */
    .nl-form-header {
        margin-bottom: 28px;
    }
    .nl-form-icon-circle {
        width: 52px;
        height: 52px;
        background: #FFF2EB;
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #FC8019;
        font-size: 26px;
        margin-bottom: 16px;
        box-shadow: 0 4px 14px rgba(252, 128, 25, 0.16);
        transition: transform 0.3s ease;
    }
    .nl-form-icon-circle:hover {
        transform: scale(1.08) rotate(5deg);
    }
    .nl-form-title {
        font-size: 28px;
        font-weight: 800;
        color: #0F172A;
        letter-spacing: -0.5px;
        margin-bottom: 6px;
    }
    .nl-form-subtitle {
        font-size: 14px;
        color: #64748B;
        line-height: 1.45;
    }

    /* 1-Click Quick Demo Account Bar */
    .nl-demo-box {
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        padding: 12px 14px;
        margin-bottom: 24px;
        transition: border-color 0.2s ease;
    }
    .nl-demo-box:hover {
        border-color: #CBD5E1;
    }
    .nl-demo-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.6px;
        color: #64748B;
        margin-bottom: 8px;
    }
    .nl-demo-group {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
    }
    .nl-demo-chip {
        background: #FFFFFF;
        border: 1px solid #CBD5E1;
        color: #334155;
        font-size: 12px;
        font-weight: 600;
        padding: 5px 12px;
        border-radius: 7px;
        cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .nl-demo-chip:hover {
        background: #FFF2EB;
        border-color: #FC8019;
        color: #FC8019;
        transform: translateY(-2px);
        box-shadow: 0 4px 10px rgba(252, 128, 25, 0.15);
    }
    .nl-demo-chip:active {
        transform: scale(0.96);
    }

    /* Input Field Elements */
    .nl-input-group {
        margin-bottom: 20px;
    }
    .nl-label-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 13px;
        font-weight: 600;
        color: #1E293B;
        margin-bottom: 8px;
    }
    .nl-link-orange {
        font-size: 12px;
        font-weight: 600;
        color: #FC8019;
        text-decoration: none;
        transition: color 0.15s ease;
    }
    .nl-link-orange:hover {
        color: #E87010;
        text-decoration: underline;
    }

    .nl-input-box {
        position: relative;
        display: flex;
        align-items: center;
    }
    .nl-input-lead-icon {
        position: absolute;
        left: 14px;
        color: #94A3B8;
        font-size: 18px;
        pointer-events: none;
        transition: color 0.2s ease, transform 0.2s ease;
    }
    .nl-text-input {
        width: 100%;
        height: 48px;
        padding: 0 44px 0 44px;
        font-size: 14.5px;
        font-weight: 500;
        color: #0F172A;
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        border-radius: 10px;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        outline: none;
    }
    .nl-text-input:focus {
        background: #FFFFFF;
        border-color: #FC8019;
        box-shadow: 0 0 0 3.5px rgba(252, 128, 25, 0.15);
    }
    .nl-input-box:focus-within .nl-input-lead-icon {
        color: #FC8019;
        transform: scale(1.1);
    }
    .nl-password-toggle-btn {
        position: absolute;
        right: 12px;
        background: transparent;
        border: none;
        color: #94A3B8;
        font-size: 19px;
        cursor: pointer;
        padding: 4px 6px;
        border-radius: 6px;
        transition: all 0.2s ease;
    }
    .nl-password-toggle-btn:hover {
        color: #FC8019;
        transform: scale(1.1);
    }

    /* Remember Workstation Checkbox */
    .nl-checkbox-wrapper {
        display: flex;
        align-items: center;
        gap: 9px;
        margin-bottom: 24px;
        font-size: 13.5px;
        color: #475569;
        cursor: pointer;
        user-select: none;
    }
    .nl-checkbox-wrapper input[type="checkbox"] {
        accent-color: #FC8019;
        width: 17px;
        height: 17px;
        cursor: pointer;
    }

    /* High-Impact Submit Button */
    .nl-submit-cta {
        width: 100%;
        height: 50px;
        background: linear-gradient(135deg, #FC8019 0%, #FF6600 100%);
        background-size: 200% auto;
        border: none;
        border-radius: 10px;
        color: #FFFFFF;
        font-size: 15.5px;
        font-weight: 700;
        letter-spacing: 0.2px;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        cursor: pointer;
        transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
        box-shadow: 0 6px 20px rgba(252, 128, 25, 0.32);
    }
    .nl-submit-cta:hover {
        transform: translateY(-2px);
        box-shadow: 0 10px 26px rgba(252, 128, 25, 0.42);
        animation: shimmerBtn 2.5s infinite;
    }
    .nl-submit-cta:hover i {
        transform: translateX(4px);
    }
    .nl-submit-cta i {
        transition: transform 0.2s ease;
        font-size: 17px;
    }
    .nl-submit-cta:active {
        transform: translateY(0);
        box-shadow: 0 4px 12px rgba(252, 128, 25, 0.25);
    }

    /* Feedback Alert Banners */
    .nl-alert-banner {
        display: flex;
        align-items: flex-start;
        gap: 12px;
        padding: 13px 16px;
        border-radius: 10px;
        font-size: 13px;
        margin-bottom: 20px;
        animation: fadeInUp 0.4s ease;
    }
    .nl-alert-banner.danger {
        background: #FEF2F2;
        border: 1px solid #FCA5A5;
        color: #991B1B;
    }
    .nl-alert-banner.success {
        background: #ECFDF5;
        border: 1px solid #A7F3D0;
        color: #065F46;
    }

    /* Clean Bottom Footer */
    .nl-form-footer {
        margin-top: 28px;
        padding-top: 22px;
        border-top: 1px solid #F1F5F9;
        text-align: center;
    }
    .nl-register-hint {
        font-size: 13.5px;
        color: #64748B;
    }
    .nl-register-action {
        font-weight: 700;
        color: #FC8019;
        text-decoration: none;
        transition: color 0.15s ease;
    }
    .nl-register-action:hover {
        color: #E87010;
        text-decoration: underline;
    }
    .nl-security-seal {
        margin-top: 16px;
        font-size: 12px;
        color: #94A3B8;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
    }

    /* ===================================================
       RESPONSIVE COLLAPSE FOR TABLET & MOBILE
       =================================================== */
    @media (max-width: 1024px) {
        .nl-split-left {
            display: none !important;
        }
        .nl-split-right {
            flex: 1;
            min-height: 100vh;
            padding: 40px 24px;
        }
        .nl-compact-brand {
            display: flex;
        }
    }
</style>

<div class="nl-split-container">
    <!-- LEFT HERO SHOWCASE SPLIT (55% Width) -->
    <div class="nl-split-left">
        <div class="nl-ambient-orb-1"></div>
        <div class="nl-ambient-orb-2"></div>

        <!-- Top Navigation Brand Bar -->
        <div class="nl-hero-nav">
            <a href="<c:url value='/'/>" class="nl-brand-link">
                <div class="nl-brand-gem">N</div>
                <div>
                    <div class="nl-brand-name">N LOGISTIC</div>
                    <div class="nl-brand-sub">Global Logistics Solution</div>
                </div>
            </a>
            <div class="nl-status-pill">
                <span class="nl-pulse-beacon"></span>
                <span>Enterprise v2.4 Live</span>
            </div>
        </div>

        <!-- Center Hero Content -->
        <div class="nl-hero-body">
            <div class="nl-hero-badge">
                <i class="ti ti-shield-check"></i> ISO 9001 &amp; CT-PAT Certified Platform
            </div>
            <h1 class="nl-hero-heading">
                Next-Gen Freight Orchestration &amp; <span>Global Telemetry.</span>
            </h1>
            <p class="nl-hero-description">
                Centralized enterprise terminal for international container logistics. Orchestrate multimodal shipments, track AIS vessels, and manage dynamic pricing across active global corridors.
            </p>

            <!-- Feature Showcase Cards -->
            <div class="nl-features-stack">
                <div class="nl-feature-item">
                    <div class="nl-feature-icon orange">
                        <i class="ti ti-ship"></i>
                    </div>
                    <div>
                        <div class="nl-feature-title">Live AIS Vessel &amp; Container Telemetry</div>
                        <div class="nl-feature-text">Real-time GPS tracking with precision ETA milestone calculations across 30+ international ports.</div>
                    </div>
                </div>

                <div class="nl-feature-item">
                    <div class="nl-feature-icon blue">
                        <i class="ti ti-timeline"></i>
                    </div>
                    <div>
                        <div class="nl-feature-title">Automated Checkpoint Verification</div>
                        <div class="nl-feature-text">Instant transition tracking from customs clearance to final port gate-in with tamper-proof audit trails.</div>
                    </div>
                </div>

                <div class="nl-feature-item">
                    <div class="nl-feature-icon emerald">
                        <i class="ti ti-trending-up"></i>
                    </div>
                    <div>
                        <div class="nl-feature-title">AI Dynamic Pricing &amp; Demand Engine</div>
                        <div class="nl-feature-text">Seasonal multipliers and predictive route demand forecasting algorithms.</div>
                    </div>
                </div>
            </div>

            <!-- Real-Time Metrics Strip -->
            <div class="nl-telemetry-panel">
                <div class="nl-tele-col">
                    <div class="nl-tele-number">30</div>
                    <div class="nl-tele-label">Global Ports</div>
                </div>
                <div class="nl-tele-col">
                    <div class="nl-tele-number">300+</div>
                    <div class="nl-tele-label">Active Containers</div>
                </div>
                <div class="nl-tele-col">
                    <div class="nl-tele-number">99.9%</div>
                    <div class="nl-tele-label">Tracking Uptime</div>
                </div>
            </div>
        </div>

        <!-- Left Hero Footer -->
        <div class="nl-hero-bottom">
            <div>&copy; 2026 N Logistic Maritime Systems Inc. All rights reserved.</div>
            <div class="d-flex align-items-center gap-3">
                <span>Privacy Shield</span>
                <span>&bull;</span>
                <span>Terms of Service</span>
            </div>
        </div>
    </div>

    <!-- RIGHT SEAMLESS SPLIT (Pure White, No Container Inside Container) -->
    <div class="nl-split-right">
        <div class="nl-form-container">
            <!-- Mobile Brand Header -->
            <div class="nl-compact-brand">
                <div class="nl-brand-gem" style="width: 40px; height: 40px; font-size: 20px;">N</div>
                <div>
                    <div class="nl-brand-name" style="color: #0F172A; font-size: 19px;">N LOGISTIC</div>
                    <div class="nl-brand-sub" style="color: #64748B;">Global Logistics Solution</div>
                </div>
            </div>

            <!-- Form Header -->
            <div class="nl-form-header">
                <div class="nl-form-icon-circle">
                    <i class="ti ti-lock-access"></i>
                </div>
                <h2 class="nl-form-title">Welcome Back</h2>
                <p class="nl-form-subtitle">Sign in to your N Logistic enterprise account to manage fleet operations.</p>
            </div>

            <!-- 1-Click Quick Demo Login Bar -->
            <div class="nl-demo-box">
                <div class="nl-demo-header">
                    <span><i class="ti ti-bolt text-warning me-1"></i> 1-Click Quick Demo Login</span>
                    <span style="font-size: 10px; color: #94A3B8;">Auto-Fill</span>
                </div>
                <div class="nl-demo-group">
                    <button type="button" class="nl-demo-chip" onclick="applyDemoCredentials('superadmin', 'admin123')">
                        <i class="ti ti-shield-lock" style="color: #FC8019;"></i> Super Admin
                    </button>
                    <button type="button" class="nl-demo-chip" onclick="applyDemoCredentials('customer1', 'pass123')">
                        <i class="ti ti-user" style="color: #2563EB;"></i> Customer
                    </button>
                    <button type="button" class="nl-demo-chip" onclick="applyDemoCredentials('staff1', 'pass123')">
                        <i class="ti ti-briefcase" style="color: #059669;"></i> Staff
                    </button>
                </div>
            </div>

            <!-- Alerts -->
            <c:if test="${not empty errorMessage}">
                <div class="nl-alert-banner danger">
                    <i class="ti ti-alert-circle fs-5" style="color: #DC2626; flex-shrink: 0; margin-top: 1px;"></i>
                    <div>${errorMessage}</div>
                </div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="nl-alert-banner success">
                    <i class="ti ti-circle-check fs-5" style="color: #059669; flex-shrink: 0; margin-top: 1px;"></i>
                    <div>${successMessage}</div>
                </div>
            </c:if>

            <!-- Authentication Form -->
            <form action="<c:url value='/login'/>" method="POST" id="authLoginForm">
                <!-- Username / Email Field -->
                <div class="nl-input-group">
                    <div class="nl-label-row">
                        <label for="inputUsername">Username / Email</label>
                    </div>
                    <div class="nl-input-box">
                        <i class="ti ti-user nl-input-lead-icon"></i>
                        <input type="text" id="inputUsername" name="username" class="nl-text-input" required placeholder="Enter username or email address" autocomplete="username">
                    </div>
                </div>

                <!-- Password Field -->
                <div class="nl-input-group">
                    <div class="nl-label-row">
                        <label for="inputPassword">Password</label>
                        <a href="<c:url value='/forgot-password'/>" class="nl-link-orange">Forgot Password?</a>
                    </div>
                    <div class="nl-input-box">
                        <i class="ti ti-lock nl-input-lead-icon"></i>
                        <input type="password" id="inputPassword" name="password" class="nl-text-input" required placeholder="Enter account password" autocomplete="current-password">
                        <button type="button" class="nl-password-toggle-btn" onclick="togglePasswordVisibility()" title="Toggle password visibility">
                            <i class="ti ti-eye-off" id="eyeToggleIcon"></i>
                        </button>
                    </div>
                </div>

                <!-- Remember Device Option -->
                <label class="nl-checkbox-wrapper">
                    <input type="checkbox" name="rememberMe" checked>
                    <span>Remember this workstation for 30 days</span>
                </label>

                <!-- Submit CTA Button -->
                <button type="submit" class="nl-submit-cta" id="loginSubmitBtn">
                    <span>Sign In to Terminal</span>
                    <i class="ti ti-arrow-right"></i>
                </button>

                <!-- Footer Links -->
                <div class="nl-form-footer">
                    <div class="nl-register-hint">
                        Don't have an enterprise account? 
                        <a href="<c:url value='/register'/>" class="nl-register-action">Register here &rarr;</a>
                    </div>
                    <div class="nl-security-seal">
                        <i class="ti ti-shield-lock" style="color: #10B981;"></i>
                        <span>256-Bit SSL Encrypted Enterprise Terminal</span>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // Show/Hide Password Toggle
    function togglePasswordVisibility() {
        const input = document.getElementById('inputPassword');
        const icon = document.getElementById('eyeToggleIcon');
        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.remove('ti-eye-off');
            icon.classList.add('ti-eye');
        } else {
            input.type = 'password';
            icon.classList.remove('ti-eye');
            icon.classList.add('ti-eye-off');
        }
    }

    // 1-Click Quick Demo Autofill with feedback animation
    function applyDemoCredentials(u, p) {
        const uEl = document.getElementById('inputUsername');
        const pEl = document.getElementById('inputPassword');
        uEl.value = u;
        pEl.value = p;

        uEl.style.borderColor = '#FC8019';
        pEl.style.borderColor = '#FC8019';
        uEl.style.background = '#FFF9F5';
        pEl.style.background = '#FFF9F5';

        setTimeout(() => {
            uEl.style.borderColor = '#E2E8F0';
            pEl.style.borderColor = '#E2E8F0';
            uEl.style.background = '#F8FAFC';
            pEl.style.background = '#F8FAFC';
        }, 700);
    }
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
