<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="theme-color" content="#FC8019">
    <title>N-Logistic | Secure Mobile Payment</title>
    <!-- Tabler Icons & Inter Font -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500;700&display=swap" rel="stylesheet">
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            -webkit-tap-highlight-color: transparent;
        }
        body {
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #F4F6F9;
            color: #1E293B;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: flex-start;
            padding: 16px;
        }
        .mobile-container {
            width: 100%;
            max-width: 420px;
            background: #FFFFFF;
            border-radius: 28px;
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.08);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            position: relative;
        }
        /* Top Brand Bar */
        .merchant-header {
            background: linear-gradient(135deg, #101820 0%, #1A2530 100%);
            color: #FFFFFF;
            padding: 24px 20px 20px;
            text-align: center;
            position: relative;
        }
        .merchant-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.15);
            padding: 4px 12px;
            border-radius: 50px;
            font-size: 11px;
            font-weight: 600;
            letter-spacing: 0.3px;
            color: #E2E8F0;
            margin-bottom: 12px;
        }
        .merchant-badge i {
            color: #10B981;
            font-size: 14px;
        }
        .merchant-title {
            font-size: 16px;
            font-weight: 700;
            letter-spacing: -0.2px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        .merchant-sub {
            font-size: 12px;
            color: #94A3B8;
            margin-top: 2px;
        }
        /* Amount Banner */
        .amount-card {
            background: #FFFFFF;
            padding: 24px 20px;
            text-align: center;
            border-bottom: 1px dashed #E2E8F0;
        }
        .amount-label {
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: #64748B;
            margin-bottom: 6px;
        }
        .amount-value {
            font-size: 34px;
            font-weight: 800;
            color: #0F172A;
            letter-spacing: -1px;
            display: flex;
            align-items: baseline;
            justify-content: center;
            gap: 4px;
        }
        .amount-currency {
            font-size: 20px;
            font-weight: 700;
            color: #64748B;
        }
        .amount-inr-note {
            display: inline-block;
            margin-top: 6px;
            background: #FEF3C7;
            color: #92400E;
            font-size: 12px;
            font-weight: 700;
            padding: 3px 10px;
            border-radius: 20px;
        }

        /* Order Summary List */
        .summary-list {
            padding: 18px 20px;
            background: #F8FAFC;
        }
        .summary-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 7px 0;
            font-size: 13px;
        }
        .summary-row .label {
            color: #64748B;
            font-weight: 500;
        }
        .summary-row .val {
            color: #1E293B;
            font-weight: 600;
            font-family: 'JetBrains Mono', monospace;
            font-size: 12.5px;
        }

        /* UPI Payment Options */
        .payment-options {
            padding: 20px;
        }
        .section-title {
            font-size: 12px;
            font-weight: 700;
            color: #64748B;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            margin-bottom: 12px;
        }
        .app-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
            margin-bottom: 18px;
        }
        .app-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
            padding: 10px 6px;
            background: #F8FAFC;
            border: 1.5px solid #E2E8F0;
            border-radius: 14px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .app-item.active {
            border-color: #FC8019;
            background: #FFF7ED;
        }
        .app-icon {
            width: 38px;
            height: 38px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            font-weight: 700;
            color: #FFFFFF;
        }
        .app-icon.gpay { background: linear-gradient(135deg, #4285F4, #34A853); }
        .app-icon.phonepe { background: linear-gradient(135deg, #5F259F, #7C3AED); }
        .app-icon.paytm { background: linear-gradient(135deg, #00BAF2, #002970); }
        .app-icon.bhim { background: linear-gradient(135deg, #F58220, #00A651); }
        .app-name {
            font-size: 11px;
            font-weight: 600;
            color: #334155;
        }

        /* Bank Select */
        .bank-strip {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 14px;
            background: #FFFFFF;
            border: 1.5px solid #E2E8F0;
            border-radius: 14px;
            margin-bottom: 20px;
        }
        .bank-icon {
            width: 36px;
            height: 36px;
            border-radius: 8px;
            background: #EFF6FF;
            color: #1D4ED8;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }
        .bank-info {
            flex: 1;
        }
        .bank-name {
            font-size: 13px;
            font-weight: 700;
            color: #0F172A;
        }
        .bank-acc {
            font-size: 11px;
            color: #64748B;
        }

        /* Pay Button */
        .btn-pay-now {
            width: 100%;
            background: linear-gradient(135deg, #FC8019 0%, #E06C11 100%);
            color: #FFFFFF;
            border: none;
            padding: 16px;
            border-radius: 16px;
            font-size: 15px;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            cursor: pointer;
            box-shadow: 0 8px 24px rgba(252, 128, 25, 0.35);
            transition: transform 0.15s, box-shadow 0.15s;
        }
        .btn-pay-now:active {
            transform: scale(0.98);
        }
        .btn-pay-now:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }

        /* PIN Modal */
        .pin-modal {
            position: fixed;
            inset: 0;
            background: rgba(15, 23, 42, 0.7);
            backdrop-filter: blur(4px);
            display: none;
            align-items: flex-end;
            justify-content: center;
            z-index: 9999;
        }
        .pin-sheet {
            background: #FFFFFF;
            width: 100%;
            max-width: 420px;
            border-top-left-radius: 28px;
            border-top-right-radius: 28px;
            padding: 24px 20px 32px;
            text-align: center;
            animation: slideUp 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }
        @keyframes slideUp {
            from { transform: translateY(100%); }
            to { transform: translateY(0); }
        }
        .pin-dots {
            display: flex;
            justify-content: center;
            gap: 16px;
            margin: 20px 0 24px;
        }
        .pin-dot {
            width: 16px;
            height: 16px;
            border-radius: 50%;
            border: 2px solid #CBD5E1;
            transition: all 0.15s;
        }
        .pin-dot.filled {
            background: #FC8019;
            border-color: #FC8019;
            transform: scale(1.1);
        }
        .keypad {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 12px;
        }
        .key-btn {
            background: #F8FAFC;
            border: 1px solid #E2E8F0;
            padding: 16px;
            border-radius: 16px;
            font-size: 20px;
            font-weight: 700;
            color: #0F172A;
            cursor: pointer;
        }
        .key-btn:active {
            background: #E2E8F0;
        }

        /* Success Overlay */
        .success-overlay {
            position: absolute;
            inset: 0;
            background: #FFFFFF;
            display: none;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 24px;
            text-align: center;
            z-index: 1000;
        }
        .checkmark-circle {
            width: 90px;
            height: 90px;
            border-radius: 50%;
            background: #DCFCE7;
            color: #16A34A;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            margin-bottom: 20px;
            animation: popIn 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }
        @keyframes popIn {
            from { transform: scale(0); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }
        .success-title {
            font-size: 22px;
            font-weight: 800;
            color: #0F172A;
            margin-bottom: 8px;
        }
        .success-desc {
            font-size: 13.5px;
            color: #64748B;
            line-height: 1.5;
            margin-bottom: 20px;
        }
        .success-card {
            background: #F8FAFC;
            border: 1px solid #E2E8F0;
            border-radius: 16px;
            padding: 16px;
            width: 100%;
            margin-bottom: 24px;
            font-size: 13px;
            text-align: left;
        }
        .security-footer {
            font-size: 11px;
            color: #94A3B8;
            text-align: center;
            margin-top: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
        }
    </style>
</head>
<body>

<div class="mobile-container">
    <c:choose>
        <c:when test="${not empty error}">
            <div style="padding: 40px 20px; text-align: center;">
                <div style="width: 70px; height: 70px; border-radius: 50%; background: #FEE2E2; color: #DC2626; display: flex; align-items: center; justify-content: center; font-size: 32px; margin: 0 auto 16px;">
                    <i class="ti ti-alert-triangle"></i>
                </div>
                <h3 style="font-size: 18px; color: #1E293B; margin-bottom: 8px;">Invalid Transaction</h3>
                <p style="font-size: 13px; color: #64748B;">${error}</p>
            </div>
        </c:when>
        <c:otherwise>
            <!-- Header -->
            <div class="merchant-header">
                <div class="merchant-badge">
                    <i class="ti ti-shield-check-filled"></i> Verified Logistics Gateway
                </div>
                <div class="merchant-title">
                    <i class="ti ti-container" style="color: #FC8019;"></i> N-LOGISTIC SHIPPING
                </div>
                <div class="merchant-sub">Global Container &amp; Freight Services</div>
            </div>

            <!-- Amount Card -->
            <div class="amount-card">
                <div class="amount-label">Total Payable Amount</div>
                <div class="amount-value">
                    <span class="amount-currency">$</span>
                    <span><fmt:formatNumber value="${txn.amount}" minFractionDigits="2" maxFractionDigits="2"/></span>
                </div>
                <div class="amount-inr-note">
                    ≈ ₹<fmt:formatNumber value="${txn.amount * 84.0}" minFractionDigits="2" maxFractionDigits="2"/> INR (18% GST Incl.)
                </div>
            </div>

            <!-- Summary List -->
            <div class="summary-list">
                <div class="summary-row">
                    <span class="label">Reference ID</span>
                    <span class="val">${txn.txnId}</span>
                </div>
                <div class="summary-row">
                    <span class="label">Container Spec</span>
                    <span class="val">Container #${txn.getParam('containerId')}</span>
                </div>
                <div class="summary-row">
                    <span class="label">Cargo Desc</span>
                    <span class="val">${txn.getParam('cargoDesc')}</span>
                </div>
            </div>

            <!-- Payment Options -->
            <div class="payment-options">
                <div class="section-title">Select UPI App</div>
                <div class="app-grid">
                    <div class="app-item active" onclick="selectApp(this, 'GPay')">
                        <div class="app-icon gpay"><i class="ti ti-brand-google"></i></div>
                        <span class="app-name">GPay</span>
                    </div>
                    <div class="app-item" onclick="selectApp(this, 'PhonePe')">
                        <div class="app-icon phonepe"><i class="ti ti-bolt"></i></div>
                        <span class="app-name">PhonePe</span>
                    </div>
                    <div class="app-item" onclick="selectApp(this, 'Paytm')">
                        <div class="app-icon paytm"><i class="ti ti-wallet"></i></div>
                        <span class="app-name">Paytm</span>
                    </div>
                    <div class="app-item" onclick="selectApp(this, 'BHIM')">
                        <div class="app-icon bhim"><i class="ti ti-cash"></i></div>
                        <span class="app-name">BHIM</span>
                    </div>
                </div>

                <div class="section-title">Paying From</div>
                <div class="bank-strip">
                    <div class="bank-icon"><i class="ti ti-building-bank"></i></div>
                    <div class="bank-info">
                        <div class="bank-name">HDFC Bank Salary A/C</div>
                        <div class="bank-acc">&bull;&bull;&bull;&bull; 4892 &bull; Available: $18,450.00</div>
                    </div>
                    <i class="ti ti-circle-check-filled" style="color: #10B981; font-size: 20px;"></i>
                </div>

                <button type="button" class="btn-pay-now" id="btnTriggerPin" onclick="openPinModal()">
                    <i class="ti ti-lock"></i>
                    <span>Pay $<fmt:formatNumber value="${txn.amount}" minFractionDigits="2" maxFractionDigits="2"/> Now</span>
                </button>

                <div class="security-footer">
                    <i class="ti ti-lock"></i> 256-bit SSL Encrypted &bull; NPCI Verified UPI
                </div>
            </div>

            <!-- UPI PIN Simulator Sheet -->
            <div class="pin-modal" id="pinModal">
                <div class="pin-sheet">
                    <div style="font-size: 15px; font-weight: 700; color: #1E293B;">Enter 4-Digit UPI PIN</div>
                    <div style="font-size: 12px; color: #64748B; margin-top: 2px;">Simulating Payment to N-Logistic Shipping</div>
                    
                    <div class="pin-dots">
                        <div class="pin-dot" id="dot1"></div>
                        <div class="pin-dot" id="dot2"></div>
                        <div class="pin-dot" id="dot3"></div>
                        <div class="pin-dot" id="dot4"></div>
                    </div>

                    <div class="keypad">
                        <button type="button" class="key-btn" onclick="pressKey('1')">1</button>
                        <button type="button" class="key-btn" onclick="pressKey('2')">2</button>
                        <button type="button" class="key-btn" onclick="pressKey('3')">3</button>
                        <button type="button" class="key-btn" onclick="pressKey('4')">4</button>
                        <button type="button" class="key-btn" onclick="pressKey('5')">5</button>
                        <button type="button" class="key-btn" onclick="pressKey('6')">6</button>
                        <button type="button" class="key-btn" onclick="pressKey('7')">7</button>
                        <button type="button" class="key-btn" onclick="pressKey('8')">8</button>
                        <button type="button" class="key-btn" onclick="pressKey('9')">9</button>
                        <button type="button" class="key-btn" onclick="closePinModal()" style="font-size: 14px; color: #64748B;">Cancel</button>
                        <button type="button" class="key-btn" onclick="pressKey('0')">0</button>
                        <button type="button" class="key-btn" onclick="deleteKey()"><i class="ti ti-backspace"></i></button>
                    </div>
                </div>
            </div>

            <!-- Success Overlay -->
            <div class="success-overlay" id="successOverlay">
                <div class="checkmark-circle">
                    <i class="ti ti-check"></i>
                </div>
                <div class="success-title">Payment Approved!</div>
                <div class="success-desc">
                    Your freight payment of <strong>$<fmt:formatNumber value="${txn.amount}" minFractionDigits="2" maxFractionDigits="2"/></strong> has been successfully authorized and confirmed.
                </div>
                <div class="success-card">
                    <div style="display: flex; justify-content: space-between; margin-bottom: 8px;">
                        <span style="color: #64748B;">UPI Ref No:</span>
                        <strong id="successUpiRef" style="font-family: monospace;">UPI/2026/982314</strong>
                    </div>
                    <div style="display: flex; justify-content: space-between; margin-bottom: 8px;">
                        <span style="color: #64748B;">Shipment ID:</span>
                        <strong id="successShipmentId" style="color: #FC8019;">Generating...</strong>
                    </div>
                    <div style="display: flex; justify-content: space-between;">
                        <span style="color: #64748B;">Status:</span>
                        <span style="color: #16A34A; font-weight: 700;">CONFIRMED</span>
                    </div>
                </div>
                <div style="background: #EFF6FF; border: 1px solid #BFDBFE; color: #1D4ED8; font-size: 12.5px; font-weight: 600; padding: 12px 16px; border-radius: 12px; width: 100%;">
                    <i class="ti ti-device-laptop me-1"></i> Look at your desktop screen! Your booking has automatically updated.
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script>
    var currentPin = "";
    var txnId = "${txn.txnId}";
    var selectedAppName = "GPay";

    function selectApp(el, app) {
        document.querySelectorAll('.app-item').forEach(function(item) { item.classList.remove('active'); });
        el.classList.add('active');
        selectedAppName = app;
    }

    function openPinModal() {
        currentPin = "";
        updatePinDots();
        document.getElementById('pinModal').style.display = 'flex';
    }

    function closePinModal() {
        document.getElementById('pinModal').style.display = 'none';
    }

    function pressKey(num) {
        if (currentPin.length < 4) {
            currentPin += num;
            updatePinDots();
            if (currentPin.length === 4) {
                setTimeout(submitPayment, 250);
            }
        }
    }

    function deleteKey() {
        if (currentPin.length > 0) {
            currentPin = currentPin.substring(0, currentPin.length - 1);
            updatePinDots();
        }
    }

    function updatePinDots() {
        for (var i = 1; i <= 4; i++) {
            var dot = document.getElementById('dot' + i);
            if (dot) {
                if (i <= currentPin.length) {
                    dot.classList.add('filled');
                } else {
                    dot.classList.remove('filled');
                }
            }
        }
    }

    function submitPayment() {
        closePinModal();
        var btn = document.getElementById('btnTriggerPin');
        if (btn) {
            btn.disabled = true;
            btn.innerHTML = '<i class="ti ti-loader ti-spin"></i> Authorizing with Bank...';
        }

        var params = new URLSearchParams();
        params.append('txn', txnId);
        params.append('paymentMethod', 'UPI (' + selectedAppName + ')');

        fetch('${pageContext.request.contextPath}/payment/pay-mock', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params.toString()
        })
        .then(function(res) { return res.json(); })
        .then(function(data) {
            if (data.success) {
                if (navigator.vibrate) { navigator.vibrate([120, 60, 120]); }
                document.getElementById('successOverlay').style.display = 'flex';
                document.getElementById('successShipmentId').innerText = '#SHP-' + (data.shipmentId || 'CONFIRMED');
                document.getElementById('successUpiRef').innerText = 'UPI/2026/' + Math.floor(100000 + Math.random() * 900000);
            } else {
                alert('Payment failed: ' + (data.error || 'Unknown error'));
                if (btn) {
                    btn.disabled = false;
                    btn.innerHTML = '<i class="ti ti-lock"></i> Retry Payment';
                }
            }
        })
        .catch(function(err) {
            alert('Network error communicating with payment gateway: ' + err);
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = '<i class="ti ti-lock"></i> Retry Payment';
            }
        });
    }

    <c:if test="${txn.status == 'SUCCESS'}">
        document.getElementById('successOverlay').style.display = 'flex';
        document.getElementById('successShipmentId').innerText = '#SHP-${txn.generatedShipmentId}';
    </c:if>
</script>

</body>
</html>
