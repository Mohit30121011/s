<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    .page-title { font-weight: 700; color: #1e293b; font-size: 24px; }
    .breadcrumb-text { font-size: 13px; color: #64748b; }
    
    #reader {
        width: 100%;
        border-radius: 12px;
        overflow: hidden;
        border: 2px dashed #cbd5e1;
    }
    
    .scanner-container {
        position: relative;
        background: #f8fafc;
        padding: 20px;
        border-radius: 12px;
        text-align: center;
    }
</style>

<!-- HTML5 QR Code Scanner Library -->
<script src="https://unpkg.com/html5-qrcode"></script>

<div class="container-fluid py-4" style="background-color: #fafafa; min-height: 100vh;">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="page-title mb-1">Scan Barcodes</h1>
            <div class="breadcrumb-text">Dashboard &nbsp;>&nbsp; Barcodes &nbsp;>&nbsp; Scan & Verify (FR8.4, FR8.5)</div>
        </div>
    </div>

    <!-- Alerts -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger shadow-sm border-0 mb-4" style="border-radius: 8px;">
            <i class="fa-solid fa-triangle-exclamation me-2"></i> ${errorMessage}
        </div>
    </c:if>
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success shadow-sm border-0 mb-4" style="border-radius: 8px;">
            <i class="fa-solid fa-circle-check me-2"></i> ${successMessage}
        </div>
    </c:if>

    <div class="row g-4">
        <!-- Scanner Area -->
        <div class="col-lg-5">
            <div class="card shadow-sm border-0 h-100" style="border-radius: 12px;">
                <div class="card-body p-4">
                    <h5 class="fw-bold mb-4"><i class="fa-solid fa-camera me-2 text-primary"></i> Scan using Camera</h5>
                    
                    <div class="scanner-container mb-4">
                        <div id="reader"></div>
                    </div>
                    
                    <div class="text-center text-muted mb-4 fw-bold">OR</div>
                    
                    <h5 class="fw-bold mb-3"><i class="fa-solid fa-barcode me-2 text-primary"></i> Manual Entry / Scanner Gun</h5>
                    <form action="<c:url value='/scan-barcode'/>" method="POST" id="manualScanForm">
                        <div class="mb-3">
                            <input type="text" name="barcodeValue" id="barcodeValue" class="form-control form-control-lg" placeholder="Scan or type barcode here..." required autofocus>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-muted fw-bold" style="font-size: 13px;">Location (FR8.5)</label>
                            <select name="scanLocation" class="form-select">
                                <option value="Warehouse Entry Gate">Warehouse Entry Gate</option>
                                <option value="Dispatch Area">Dispatch Area</option>
                                <option value="Port Terminal 1">Port Terminal 1</option>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-nlog w-100 py-2">
                            <i class="fa-solid fa-magnifying-glass me-2"></i> Verify Code
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Result Area -->
        <div class="col-lg-7">
            <div class="card shadow-sm border-0 h-100" style="border-radius: 12px;">
                <div class="card-body p-4 p-lg-5 text-center d-flex flex-column justify-content-center align-items-center">
                    <c:choose>
                        <c:when test="${not empty entityDetails}">
                            <!-- Success Result (FR8.4) -->
                            <div class="mb-4">
                                <div class="bg-success text-white rounded-circle d-flex align-items-center justify-content-center mx-auto mb-3" style="width: 80px; height: 80px; font-size: 40px;">
                                    <i class="fa-solid fa-check"></i>
                                </div>
                                <h3 class="fw-bold text-success">Valid Code</h3>
                                <p class="text-muted">Barcode <strong>${scannedBarcode}</strong> verified and logged successfully.</p>
                            </div>
                            
                            <div class="card bg-light border-0 w-100 text-start">
                                <div class="card-body p-4">
                                    <h6 class="text-uppercase text-muted fw-bold mb-3" style="font-size: 12px; letter-spacing: 1px;">Entity Details</h6>
                                    
                                    <div class="d-flex justify-content-between mb-2">
                                        <span class="text-muted">Type:</span>
                                        <span class="fw-bold">${entityType}</span>
                                    </div>
                                    <div class="d-flex justify-content-between mb-2">
                                        <span class="text-muted">System ID:</span>
                                        <span class="fw-bold">#${entityId}</span>
                                    </div>
                                    <hr>
                                    <div class="d-flex justify-content-between">
                                        <span class="text-muted">Information:</span>
                                        <span class="fw-bold text-primary">${entityDetails}</span>
                                    </div>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <!-- Waiting State -->
                            <img src="${pageContext.request.contextPath}/assets/img/scan-placeholder.png" onerror="this.src=''" alt="" style="width: 150px; opacity: 0.5;" class="mb-4">
                            <h4 class="text-muted fw-bold mb-2">Ready to Scan</h4>
                            <p class="text-muted mb-0" style="max-width: 300px;">Use your camera or a barcode scanner gun to scan a label. The details will appear here.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // Initialize HTML5 QR Code Scanner
    document.addEventListener("DOMContentLoaded", function() {
        const html5QrCode = new Html5Qrcode("reader");
        const qrCodeSuccessCallback = (decodedText, decodedResult) => {
            // Stop scanning
            html5QrCode.stop().then((ignore) => {
                // Populate the hidden form and submit it automatically
                document.getElementById('barcodeValue').value = decodedText;
                document.getElementById('manualScanForm').submit();
            }).catch((err) => {
                console.log(err);
            });
        };
        const config = { fps: 10, qrbox: { width: 250, height: 250 } };
        
        // Start scanner (Will ask for camera permission)
        html5QrCode.start({ facingMode: "environment" }, config, qrCodeSuccessCallback)
        .catch(err => {
            document.getElementById('reader').innerHTML = '<div class="alert alert-warning m-0">Camera access denied or no camera found. Use Manual Entry below.</div>';
        });
    });
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
