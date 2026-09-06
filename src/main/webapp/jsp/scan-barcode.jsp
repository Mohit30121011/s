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
    .entity-field-row { padding: 6px 0; border-bottom: 1px dashed #e2e8f0; }
    .entity-field-row:last-child { border-bottom: none; }

    @media print {
        body * { visibility: hidden; }
        #printableResult, #printableResult * { visibility: visible; }
        #printableResult { position: absolute; top: 0; left: 0; width: 100%; padding: 20px; }
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
                            <!-- Success Result (FR8.3 full record retrieval) -->
                            <div id="printableResult" class="w-100">
                                <div class="mb-4">
                                    <div class="bg-success text-white rounded-circle d-flex align-items-center justify-content-center mx-auto mb-3" style="width: 80px; height: 80px; font-size: 40px;">
                                        <i class="fa-solid fa-check"></i>
                                    </div>
                                    <h3 class="fw-bold text-success">Valid Code</h3>
                                    <p class="text-muted">Barcode <strong>${scannedBarcode}</strong> verified and logged successfully (FR8.5).</p>
                                </div>

                                <div class="card bg-light border-0 w-100 text-start shadow-sm overflow-hidden" style="border-radius: 14px;">
                                    <c:choose>
                                        <c:when test="${entityType == 'Shipment'}">
                                            <!-- Modern Delivery Application Tracking View (DHL/FedEx Style) -->
                                            <c:if test="${not empty entityFields['container_photo_url']}">
                                                <div style="position: relative; height: 160px; overflow: hidden; background: #0F172A;">
                                                    <img src="${entityFields['container_photo_url']}" alt="Container Photo" style="width: 100%; height: 100%; object-fit: cover; opacity: 0.78;">
                                                    <div style="position: absolute; inset: 0; background: linear-gradient(180deg, rgba(15,23,42,0.2) 0%, rgba(15,23,42,0.9) 100%);"></div>
                                                    <div style="position: absolute; bottom: 14px; left: 18px; right: 18px; display: flex; justify-content: space-between; align-items: flex-end;">
                                                        <div>
                                                            <span class="badge" style="background: rgba(252, 128, 25, 0.9); color: #fff; font-size: 11px; padding: 4px 10px; border-radius: 50px; font-weight: 700; letter-spacing: 0.5px;">
                                                                <i class="ti ti-box me-1"></i> ${entityFields['Container']}
                                                            </span>
                                                            <div style="color: #FFFFFF; font-size: 15px; font-weight: 700; margin-top: 4px;">
                                                                ${entityFields['Cargo Description']}
                                                            </div>
                                                        </div>
                                                        <span class="badge bg-success px-3 py-1.5" style="border-radius: 50px; font-size: 12px; font-weight: 600;">
                                                            ${entityFields['Status']}
                                                        </span>
                                                    </div>
                                                </div>
                                            </c:if>

                                            <div class="card-body p-4">
                                                <!-- Route Journey Strip -->
                                                <div class="p-3 mb-3" style="background: #FFFFFF; border-radius: 10px; border: 1px solid #E2E8F0; display: flex; align-items: center; justify-content: space-between;">
                                                    <div class="text-start">
                                                        <div class="text-muted small text-uppercase fw-bold" style="font-size: 10.5px;">Origin Port</div>
                                                        <div class="fw-bold text-dark" style="font-size: 14px;"><i class="ti ti-map-pin text-warning me-1"></i>${entityFields['Origin Port']}</div>
                                                    </div>
                                                    <div class="text-center px-3" style="color: #FC8019;">
                                                        <i class="ti ti-ship fs-4"></i>
                                                        <div style="border-top: 2px dashed #CBD5E1; width: 60px; margin: 4px auto 0;"></div>
                                                    </div>
                                                    <div class="text-end">
                                                        <div class="text-muted small text-uppercase fw-bold" style="font-size: 10.5px;">Destination</div>
                                                        <div class="fw-bold text-dark" style="font-size: 14px;"><i class="ti ti-flag text-success me-1"></i>${entityFields['Destination Port']}</div>
                                                    </div>
                                                </div>

                                                <!-- Delivery ETA Countdown & Customer -->
                                                <div class="row g-2 mb-3">
                                                    <div class="col-6">
                                                        <div class="p-2.5 bg-white rounded border text-start" style="border-color: #E2E8F0 !important;">
                                                            <span class="text-muted d-block" style="font-size: 11px; font-weight: 600;">EXPECTED ARRIVAL (ETA)</span>
                                                            <strong class="text-dark" style="font-size: 13.5px;"><i class="ti ti-calendar-time text-primary me-1"></i><fmt:formatDate value="${entityFields['Expected Arrival (ETA)']}" pattern="dd MMM yyyy"/></strong>
                                                        </div>
                                                    </div>
                                                    <div class="col-6">
                                                        <div class="p-2.5 bg-white rounded border text-start" style="border-color: #E2E8F0 !important;">
                                                            <span class="text-muted d-block" style="font-size: 11px; font-weight: 600;">CUSTOMER / SHIPPER</span>
                                                            <strong class="text-dark text-truncate d-block" style="font-size: 13.5px;"><i class="ti ti-user text-muted me-1"></i>${entityFields['Customer']}</strong>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Specifications Grid -->
                                                <div class="p-3 bg-white rounded border mb-3" style="border-color: #E2E8F0 !important;">
                                                    <div class="d-flex justify-content-between py-1 border-bottom" style="font-size: 12.5px;">
                                                        <span class="text-muted">Assigned Container:</span>
                                                        <strong>${entityFields['Container']} (${entityFields['Container Type']})</strong>
                                                    </div>
                                                    <div class="d-flex justify-content-between py-1 border-bottom" style="font-size: 12.5px;">
                                                        <span class="text-muted">Cargo Weight:</span>
                                                        <strong>${entityFields['Cargo Weight']}</strong>
                                                    </div>
                                                    <div class="d-flex justify-content-between py-1" style="font-size: 12.5px;">
                                                        <span class="text-muted">Booking Reference:</span>
                                                        <strong>Shipment ${entityFields['Shipment ID']} (<fmt:formatDate value="${entityFields['Booking Date']}" pattern="dd MMM yyyy"/>)</strong>
                                                    </div>
                                                </div>

                                                <!-- Direct Live Tracking Link -->
                                                <c:if test="${not empty entityFields['shipment_id_raw']}">
                                                    <a href="${pageContext.request.contextPath}/live-tracking?id=${entityFields['shipment_id_raw']}" class="btn w-100 py-2.5 text-white fw-bold d-flex align-items-center justify-content-center gap-2" style="background: linear-gradient(135deg, #FC8019 0%, #EA580C 100%); border-radius: 50px; box-shadow: 0 3px 10px rgba(252,128,25,0.3);">
                                                        <i class="ti ti-radar"></i> View Live Shipment Tracking &amp; Milestones
                                                    </a>
                                                </c:if>
                                            </div>
                                        </c:when>

                                        <c:when test="${entityType == 'Container'}">
                                            <!-- Container Inspection View with Real Photo -->
                                            <c:if test="${not empty entityFields['container_photo_url']}">
                                                <div style="height: 160px; overflow: hidden; background: #0F172A;">
                                                    <img src="${entityFields['container_photo_url']}" alt="Container" style="width: 100%; height: 100%; object-fit: cover;">
                                                </div>
                                            </c:if>
                                            <div class="card-body p-4">
                                                <h6 class="text-uppercase text-muted fw-bold mb-3" style="font-size: 12px; letter-spacing: 1px;">Container #${entityFields['Container Number']} &bull; ${entityFields['Size']} ${entityFields['Type']}</h6>
                                                <c:forEach var="f" items="${entityFields}">
                                                    <c:if test="${f.key != 'container_photo_url'}">
                                                        <div class="d-flex justify-content-between entity-field-row">
                                                            <span class="text-muted">${f.key}:</span>
                                                            <span class="fw-bold text-end">${f.value}</span>
                                                        </div>
                                                    </c:if>
                                                </c:forEach>
                                            </div>
                                        </c:when>

                                        <c:otherwise>
                                            <div class="card-body p-4">
                                                <h6 class="text-uppercase text-muted fw-bold mb-3" style="font-size: 12px; letter-spacing: 1px;">${entityType} Details &nbsp;&bull;&nbsp; System ID #${entityId}</h6>
                                                <c:forEach var="f" items="${entityFields}">
                                                    <div class="d-flex justify-content-between entity-field-row">
                                                        <span class="text-muted">${f.key}:</span>
                                                        <span class="fw-bold text-end">${f.value}</span>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <button type="button" class="btn btn-outline-primary mt-3 no-print" onclick="window.print()" style="border-radius: 50px;">
                                <i class="fa-solid fa-print me-2"></i> Print / Export Label PDF
                            </button>
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
