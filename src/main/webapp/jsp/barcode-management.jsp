<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    .page-title { font-weight: 700; color: #1e293b; font-size: 24px; }
    .breadcrumb-text { font-size: 13px; color: #64748b; }
    .barcode-card { background: #fff; border-radius: 12px; border: 1px solid #e2e8f0; text-align: center; padding: 20px; }
</style>

<!-- Load JS Libraries for Barcode/QR Generation -->
<script src="https://cdn.jsdelivr.net/npm/jsbarcode@3.11.5/dist/JsBarcode.all.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>

<div class="container-fluid py-4" style="background-color: #fafafa; min-height: 100vh;">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="page-title mb-1">Barcode Management</h1>
            <div class="breadcrumb-text">Dashboard &nbsp;>&nbsp; Barcodes &nbsp;>&nbsp; Generate & Print (FR8.1, FR8.2, FR8.6)</div>
        </div>
    </div>

    <!-- Alerts -->
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger shadow-sm border-0 mb-4" style="border-radius: 8px;">
            <i class="fa-solid fa-triangle-exclamation me-2"></i> ${sessionScope.errorMessage}
            <c:remove var="errorMessage" scope="session"/>
        </div>
    </c:if>
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success shadow-sm border-0 mb-4" style="border-radius: 8px;">
            <i class="fa-solid fa-circle-check me-2"></i> ${sessionScope.successMessage}
            <c:remove var="successMessage" scope="session"/>
        </div>
    </c:if>

    <div class="row g-4">
        <!-- Generation Form -->
        <div class="col-lg-4">
            <div class="card shadow-sm border-0 h-100" style="border-radius: 12px;">
                <div class="card-body p-4">
                    <h5 class="fw-bold mb-4">Generate New Code</h5>
                    <form action="<c:url value='/barcodes'/>" method="POST">
                        <div class="mb-3">
                            <label class="form-label text-muted fw-bold" style="font-size: 14px;">Entity Type</label>
                            <select name="entityType" class="form-select" required>
                                <option value="Shipment">Shipment</option>
                                <option value="Container">Container</option>
                                <option value="Stock">Stock Inventory</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-muted fw-bold" style="font-size: 14px;">Entity ID (e.g. Shipment #101)</label>
                            <input type="number" name="entityId" class="form-control" required placeholder="Enter ID number">
                        </div>
                        <div class="mb-4">
                            <label class="form-label text-muted fw-bold" style="font-size: 14px;">Format (FR8.2)</label>
                            <select name="barcodeType" class="form-select" required>
                                <option value="Code128">1D Barcode (Code128)</option>
                                <option value="QR">2D QR Code</option>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-nlog w-100 py-2">
                            <i class="fa-solid fa-qrcode me-2"></i> Generate Code
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Generated History -->
        <div class="col-lg-8">
            <div class="card shadow-sm border-0 h-100" style="border-radius: 12px;">
                <div class="card-body p-4">
                    <h5 class="fw-bold mb-4">Generated Codes Library</h5>
                    
                    <div class="row g-3">
                        <c:forEach var="code" items="${barcodeList}">
                            <div class="col-md-4">
                                <div class="barcode-card" id="card-${code.barcodeId}">
                                    <h6 class="text-muted mb-3" style="font-size: 13px;">${code.entityType} #${code.entityId}</h6>
                                    
                                    <div class="d-flex justify-content-center align-items-center" style="min-height: 120px; margin-bottom: 15px;">
                                        <c:choose>
                                            <c:when test="${code.barcodeType == 'Code128'}">
                                                <svg class="barcode-render" jsbarcode-value="${code.barcodeValue}" jsbarcode-width="1.5" jsbarcode-height="50" jsbarcode-fontSize="14"></svg>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="qr-render" data-value="${code.barcodeValue}"></div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    
                                    <div class="d-flex justify-content-between mt-3">
                                        <small class="text-muted" style="font-size: 11px;"><i class="fa-regular fa-clock me-1"></i><fmt:formatDate value="${code.generatedAt}" pattern="dd MMM" /></small>
                                        <button class="btn btn-sm btn-outline-primary" style="font-size: 11px;" onclick="downloadCode('card-${code.barcodeId}', '${code.barcodeValue}')">
                                            <i class="fa-solid fa-download"></i> Print
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                        <c:if test="${empty barcodeList}">
                            <div class="col-12 text-center text-muted py-5">No barcodes generated yet.</div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        // Render all 1D Barcodes
        JsBarcode(".barcode-render").init();

        // Render all QR Codes
        document.querySelectorAll('.qr-render').forEach(function(el) {
            let val = el.getAttribute('data-value');
            new QRCode(el, {
                text: val,
                width: 100,
                height: 100,
                colorDark : "#000000",
                colorLight : "#ffffff",
                correctLevel : QRCode.CorrectLevel.H
            });
        });
    });

    // FR8.6 Print / Export Logic
    function downloadCode(cardId, val) {
        const element = document.getElementById(cardId);
        html2canvas(element, { scale: 2 }).then(canvas => {
            let link = document.createElement('a');
            link.download = 'Barcode_' + val + '.png';
            link.href = canvas.toDataURL("image/png");
            link.click();
        });
    }
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
