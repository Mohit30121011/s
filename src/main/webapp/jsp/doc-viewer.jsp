<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%-- MVC2 (SRS 10.2): DocumentViewServlet (/compliance-document) loads the document
     and performs the ownership + review-permission checks. --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Compliance Document Verification - ${doc != null ? doc.docNumber : 'Document Viewer'}</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Outfit:wght@600;700;800&family=Libre+Barcode+128&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root {
            --nl-primary: #FC8019;
            --nl-secondary: #1F2937;
            --nl-dark: #111827;
            --color-success: #16B364;
            --color-warning: #FFB300;
            --color-danger: #EF4444;
            --bg-body: #F4F5F7;
            --border-color: #E2E8F0;
        }

        body {
            background-color: var(--bg-body);
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            color: #1E293B;
            padding: 30px 20px;
        }

        .action-bar { max-width: 900px; margin: 0 auto 20px auto; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; }

        .btn-nl-outline {
            background: #FFFFFF; border: 1px solid var(--border-color); color: var(--nl-secondary); font-weight: 600; font-size: 0.85rem;
            padding: 8px 16px; border-radius: 8px; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; transition: all 0.2s;
        }
        .btn-nl-outline:hover { background: #F8FAFC; border-color: var(--nl-primary); color: var(--nl-primary); }

        .btn-nl-primary {
            background: var(--nl-primary); border: none; color: #FFFFFF; font-weight: 600; font-size: 0.85rem; padding: 8px 18px;
            border-radius: 8px; display: inline-flex; align-items: center; gap: 8px; cursor: pointer; transition: all 0.2s;
        }
        .btn-nl-primary:hover { background: #E66F0F; color: #FFFFFF; }

        .certificate-container {
            max-width: 900px; margin: 0 auto; background: #FFFFFF; border: 2px solid #CBD5E1; border-radius: 16px;
            padding: 40px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08); position: relative; overflow: hidden;
        }

        .watermark {
            position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%) rotate(-30deg);
            font-size: 6rem; font-family: 'Outfit', sans-serif; font-weight: 800; color: rgba(252, 128, 25, 0.05);
            pointer-events: none; white-space: nowrap; text-transform: uppercase; letter-spacing: 10px; z-index: 1;
        }

        .cert-header { border-bottom: 2px solid var(--nl-secondary); padding-bottom: 20px; margin-bottom: 25px; display: flex; justify-content: space-between; align-items: center; position: relative; z-index: 2; flex-wrap: wrap; gap: 12px; }

        .cert-logo { font-family: 'Outfit', sans-serif; font-size: 1.8rem; font-weight: 800; color: var(--nl-primary); letter-spacing: -0.03em; }
        .cert-logo span { color: var(--nl-secondary); }

        .cert-badge { display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; border-radius: 20px; font-size: 0.8rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; }
        .badge-approved { background: rgba(22, 179, 100, 0.12); color: #0E8045; border: 1px solid rgba(22, 179, 100, 0.3); }
        .badge-pending { background: rgba(255, 179, 0, 0.15); color: #B45309; border: 1px solid rgba(255, 179, 0, 0.4); }
        .badge-expired { background: rgba(239, 68, 68, 0.12); color: #DC2626; border: 1px solid rgba(239, 68, 68, 0.3); }
        .badge-rejected { background: rgba(239, 68, 68, 0.12); color: #DC2626; border: 1px solid rgba(239, 68, 68, 0.3); }

        .cert-title-block { text-align: center; margin-bottom: 30px; position: relative; z-index: 2; }
        .cert-main-title { font-family: 'Outfit', sans-serif; font-size: 1.5rem; font-weight: 700; color: var(--nl-dark); margin: 0; text-transform: uppercase; letter-spacing: 0.5px; }
        .cert-sub-title { color: #64748B; font-size: 0.85rem; margin-top: 4px; }

        .details-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 30px; position: relative; z-index: 2; }

        .detail-card { background: #F8FAFC; border: 1px solid var(--border-color); border-radius: 12px; padding: 20px; }
        .detail-card-title { font-family: 'Outfit', sans-serif; font-weight: 700; font-size: 0.95rem; color: var(--nl-secondary); margin-bottom: 14px; display: flex; align-items: center; gap: 8px; border-bottom: 1px dashed var(--border-color); padding-bottom: 8px; }

        .data-row { display: flex; justify-content: space-between; align-items: center; padding: 7px 0; font-size: 0.84rem; }
        .data-label { color: #64748B; font-weight: 500; }
        .data-val { font-weight: 600; color: #1E293B; text-align: right; }

        .attestation-box {
            background: linear-gradient(135deg, rgba(31, 41, 55, 0.04) 0%, rgba(252, 128, 25, 0.06) 100%);
            border: 1px solid rgba(252, 128, 25, 0.18); border-radius: 12px; padding: 20px; display: flex; align-items: center; gap: 20px; margin-bottom: 30px; position: relative; z-index: 2;
        }
        .attestation-seal {
            width: 70px; height: 70px; border-radius: 50%; background: #FFFFFF; border: 2px dashed var(--nl-primary);
            display: flex; align-items: center; justify-content: center; color: var(--nl-primary); font-size: 1.8rem; flex-shrink: 0; box-shadow: 0 4px 10px rgba(0,0,0,0.05);
        }

        .barcode-section { text-align: center; margin-top: 25px; padding-top: 20px; border-top: 1px solid var(--border-color); position: relative; z-index: 2; }
        .barcode-font { font-family: 'Libre Barcode 128', cursive; font-size: 3.5rem; color: #1E293B; line-height: 1; }

        @media print {
            body { background: #FFFFFF; padding: 0; }
            .action-bar { display: none; }
            .certificate-container { border: none; box-shadow: none; padding: 0; max-width: 100%; }
        }
    </style>
</head>
<body>

    <div class="action-bar">
        <a href="${pageContext.request.contextPath}/compliance" class="btn-nl-outline">
            <i class="fa-solid fa-arrow-left"></i> Back to Compliance Dashboard
        </a>
        <div style="display:flex; gap:10px;">
            <button class="btn-nl-outline" onclick="window.print()">
                <i class="fa-solid fa-print"></i> Print Certificate
            </button>
            <c:if test="${not empty doc.filePath}">
                <a class="btn-nl-outline" href="${pageContext.request.contextPath}/${doc.filePath}" download>
                    <i class="fa-solid fa-download"></i> Download
                </a>
            </c:if>
            <%-- FR5.2: approve / reject is an Admin + Operations decision --%>
            <c:if test="${canReview and not empty doc}">
                <c:if test="${doc.status != 'Approved'}">
                    <button type="button" class="btn-nl-primary" style="background:#16B364;"
                            onclick="openReview('Approved')">
                        <i class="fa-solid fa-circle-check"></i> Approve Document
                    </button>
                </c:if>
                <c:if test="${doc.status != 'Rejected'}">
                    <button type="button" class="btn-nl-outline" style="border-color:#EF4444; color:#EF4444;"
                            onclick="openReview('Rejected')">
                        <i class="fa-solid fa-circle-xmark"></i> Reject Document
                    </button>
                </c:if>
            </c:if>
        </div>
    </div>

    <c:choose>
    <c:when test="${empty doc}">
        <div class="certificate-container" style="text-align:center; padding:80px 20px; color:#6B7280;">
            <i class="fa-solid fa-file-circle-exclamation" style="font-size:32px; display:block; margin-bottom:12px;"></i>
            Document not found.
        </div>
    </c:when>
    <c:otherwise>
    <div class="certificate-container">
        <div class="watermark">${doc.status}</div>

        <div class="cert-header">
            <div>
                <div class="cert-logo">NLogistic<span>Portal</span></div>
                <small class="text-muted">Global Government Regulatory Compliance &amp; Maritime Port Verification Bureau</small>
            </div>
            <div>
                <c:choose>
                    <c:when test="${doc.status == 'Approved'}">
                        <div class="cert-badge badge-approved"><i class="fa-solid fa-circle-check"></i> Approved &amp; Active</div>
                    </c:when>
                    <c:when test="${doc.status == 'Pending' || doc.status == 'Under Review'}">
                        <div class="cert-badge badge-pending"><i class="fa-solid fa-hourglass-half"></i> Verification Pending</div>
                    </c:when>
                    <c:when test="${doc.status == 'Expired'}">
                        <div class="cert-badge badge-expired"><i class="fa-solid fa-triangle-exclamation"></i> Document Expired</div>
                    </c:when>
                    <c:otherwise>
                        <div class="cert-badge badge-rejected"><i class="fa-solid fa-circle-xmark"></i> ${doc.status}</div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="cert-title-block">
            <h1 class="cert-main-title">${doc.docType}</h1>
            <div class="cert-sub-title">Official Electronic Regulatory Filing Record &bull; Compliance Verification Registry</div>
        </div>

        <div class="details-grid">
            <div class="detail-card">
                <div class="detail-card-title"><i class="fa-solid fa-file-contract"></i> Regulatory Parameters</div>
                <div class="data-row"><span class="data-label">Document Number:</span><span class="data-val" style="color:var(--nl-primary);">${doc.docNumber}</span></div>
                <div class="data-row"><span class="data-label">Document Classification:</span><span class="data-val">${doc.docType}</span></div>
                <div class="data-row"><span class="data-label">Issuing Authority:</span><span class="data-val">${doc.issuingAuthority}</span></div>
                <div class="data-row"><span class="data-label">Issue Date:</span><span class="data-val"><fmt:formatDate value="${doc.issueDate}" pattern="dd MMM yyyy"/></span></div>
                <div class="data-row">
                    <span class="data-label">Expiry / Renewal Date:</span>
                    <span class="data-val" style="color: ${doc.status == 'Expired' ? '#DC2626' : '#16B364'};">
                        <c:choose>
                            <c:when test="${doc.expiryDate != null}"><fmt:formatDate value="${doc.expiryDate}" pattern="dd MMM yyyy"/></c:when>
                            <c:otherwise>Permanent (No Expiry)</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="data-row"><span class="data-label">Server Storage Path:</span><span class="data-val" style="font-family: monospace; font-size: 0.78rem;">${doc.filePath}</span></div>
            </div>

            <div class="detail-card">
                <div class="detail-card-title"><i class="fa-solid fa-ship"></i> Bound Shipment Manifest</div>
                <div class="data-row"><span class="data-label">Shipment Reference:</span><span class="data-val">Shipment #${doc.shipmentId}</span></div>
                <div class="data-row"><span class="data-label">Cargo Manifest:</span><span class="data-val">${not empty doc.cargoDescription ? doc.cargoDescription : 'Commercial Freight'}</span></div>
                <div class="data-row"><span class="data-label">Customer / Consignee:</span><span class="data-val">${not empty doc.customerName ? doc.customerName : 'Registered Account'}</span></div>
                <div class="data-row"><span class="data-label">Origin Port:</span><span class="data-val">${not empty doc.originPort ? doc.originPort : 'Port Authority'}</span></div>
                <div class="data-row"><span class="data-label">Destination Port:</span><span class="data-val">${not empty doc.destinationPort ? doc.destinationPort : 'Discharge Terminal'}</span></div>
                <div class="data-row"><span class="data-label">Audited By (Staff):</span><span class="data-val">${not empty doc.uploaderName ? doc.uploaderName : 'Operations Officer'}</span></div>
            </div>
        </div>

        <div class="attestation-box">
            <div class="attestation-seal"><i class="fa-solid fa-stamp"></i></div>
            <div>
                <h6 style="font-weight:700; margin-bottom:4px; color:#0F172A; font-size: 0.95rem;">Port Regulatory &amp; Departure Clearance Precondition</h6>
                <p style="color:#64748B; margin-bottom:0; font-size: 0.8rem; line-height: 1.4;">
                    <c:choose>
                        <c:when test="${doc.status == 'Approved'}">
                            This document is verified by customs and port regulatory authorities. Precondition status for shipment departure is satisfied.
                        </c:when>
                        <c:otherwise>
                            <strong>RESTRICTION ACTIVE:</strong> This document requires administrative approval or renewal before vessel departure clearance can be granted.
                        </c:otherwise>
                    </c:choose>
                </p>
            </div>
        </div>

        <div class="barcode-section">
            <div class="barcode-font">*DOC-${doc.docId}-${doc.docNumber}*</div>
            <small class="text-muted">DOC-ID: ${doc.docId} &bull; CRYPTOGRAPHIC VERIFICATION SERIAL: SHA256-${doc.docNumber}</small>
        </div>
    </div>
    </c:otherwise>
    </c:choose>

    <%-- The document itself, not just its metadata --%>
    <c:if test="${not empty doc}">
        <div class="certificate-container" style="margin-top:18px;">
            <div class="detail-card-title" style="margin-bottom:12px;">
                <i class="fa-solid fa-file-lines"></i> Document Preview
            </div>
            <c:choose>
                <c:when test="${empty doc.filePath}">
                    <div style="padding:40px; text-align:center; color:#94A3B8; background:#F8FAFC; border:1px dashed #CBD5E1; border-radius:10px;">
                        <i class="fa-solid fa-file-circle-question" style="font-size:26px; display:block; margin-bottom:10px;"></i>
                        No file was attached when this document was recorded.
                    </div>
                </c:when>
                <c:when test="${fn:toLowerCase(doc.filePath).endsWith('.pdf')}">
                    <iframe src="${pageContext.request.contextPath}/${doc.filePath}"
                            style="width:100%; height:640px; border:1px solid #E2E8F0; border-radius:10px;"
                            title="Compliance document"></iframe>
                </c:when>
                <c:otherwise>
                    <img src="${pageContext.request.contextPath}/${doc.filePath}"
                         alt="Compliance document"
                         style="max-width:100%; border:1px solid #E2E8F0; border-radius:10px;">
                </c:otherwise>
            </c:choose>
        </div>
    </c:if>

    <c:if test="${canReview and not empty doc}">
        <!-- Review confirmation (branded, never window.confirm) -->
        <div id="reviewOverlay"
             style="display:none; position:fixed; inset:0; background:rgba(15,23,42,.45); z-index:9999; align-items:center; justify-content:center;">
            <div style="background:#fff; border-radius:14px; width:min(440px,92vw); padding:26px; box-shadow:0 16px 40px rgba(15,23,42,.18);">
                <h5 id="reviewTitle" style="font-weight:800; margin:0 0 8px; color:#0F172A;"></h5>
                <p id="reviewBody" style="color:#64748B; font-size:.88rem; line-height:1.5;"></p>
                <form method="POST" action="${pageContext.request.contextPath}/compliance/review">
                    <input type="hidden" name="docId" value="${doc.docId}">
                    <input type="hidden" name="status" id="reviewStatus">
                    <div style="display:flex; gap:10px; justify-content:flex-end; margin-top:18px;">
                        <button type="button" class="btn-nl-outline" onclick="closeReview()">Cancel</button>
                        <button type="submit" class="btn-nl-primary" id="reviewConfirmBtn"></button>
                    </div>
                </form>
            </div>
        </div>
        <script>
            function openReview(status) {
                document.getElementById('reviewStatus').value = status;
                var approving = (status === 'Approved');
                document.getElementById('reviewTitle').textContent =
                    approving ? 'Approve this document?' : 'Reject this document?';
                document.getElementById('reviewBody').textContent = approving
                    ? 'Marking DOC-${doc.docId} as Approved counts towards the departure clearance precondition for Shipment #${doc.shipmentId}.'
                    : 'Marking DOC-${doc.docId} as Rejected will block Shipment #${doc.shipmentId} from departing until a valid document is supplied.';
                var btn = document.getElementById('reviewConfirmBtn');
                btn.textContent = approving ? 'Yes, Approve' : 'Yes, Reject';
                btn.style.background = approving ? '#16B364' : '#EF4444';
                document.getElementById('reviewOverlay').style.display = 'flex';
            }
            function closeReview() {
                document.getElementById('reviewOverlay').style.display = 'none';
            }
        </script>
    </c:if>
</body>
</html>
