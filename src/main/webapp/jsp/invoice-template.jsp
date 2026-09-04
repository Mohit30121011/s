<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
if (request.getAttribute("invoice") == null && request.getParameter("id") != null) {
    try {
        int invId = Integer.parseInt(request.getParameter("id").trim());
        com.nlogistic.dao.BillingDAO bdao = new com.nlogistic.dao.BillingDAO();
        com.nlogistic.model.Invoice inv = bdao.getInvoiceById(invId);
        if (inv != null) {
            request.setAttribute("invoice", inv);
            request.setAttribute("lineItems", inv.getLineItems());
            request.setAttribute("payments", inv.getPayments());
        }
    } catch (Exception ignored) {}
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tax Invoice INV-${invoice.invoiceId} &bull; NLogistic</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Outfit:wght@600;700;800&family=Libre+Barcode+128&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root {
            --nl-primary: #FC8019;
            --nl-dark: #1F2937;
            --text-dark: #1C1C1C;
            --text-muted: #6B7280;
            --border-color: #E5E7EB;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: #F3F4F6;
            color: var(--text-dark);
            margin: 0;
            padding: 30px 15px;
        }

        .invoice-wrapper {
            max-width: 860px;
            margin: 0 auto;
            background: #FFFFFF;
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
            border: 1px solid var(--border-color);
            padding: 40px 48px;
        }

        .action-bar {
            max-width: 860px;
            margin: 0 auto 20px auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .btn-print {
            background-color: var(--nl-primary);
            color: #FFFFFF;
            border: none;
            padding: 10px 24px;
            font-weight: 700;
            border-radius: 8px;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 0.9rem;
            transition: all 0.15s ease-in-out;
        }
        .btn-print:hover {
            background-color: #E66F0F;
            transform: translateY(-1px);
        }
        .btn-back {
            background: #FFFFFF;
            border: 1px solid var(--border-color);
            color: var(--text-dark);
            padding: 9px 18px;
            font-weight: 600;
            border-radius: 8px;
            text-decoration: none;
            font-size: 0.88rem;
        }

        .invoice-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 2px solid #F3F4F6;
            padding-bottom: 24px;
            margin-bottom: 28px;
        }
        .brand-title {
            font-family: 'Outfit', sans-serif;
            font-size: 1.8rem;
            font-weight: 800;
            color: var(--nl-dark);
            display: flex;
            align-items: center;
            gap: 10px;
            margin: 0;
        }
        .brand-title span {
            color: var(--nl-primary);
        }
        .company-details {
            font-size: 0.8rem;
            color: var(--text-muted);
            line-height: 1.5;
            margin-top: 6px;
        }

        .invoice-meta {
            text-align: right;
        }
        .invoice-meta h2 {
            font-family: 'Outfit', sans-serif;
            font-weight: 800;
            font-size: 1.5rem;
            color: var(--text-dark);
            margin: 0 0 6px 0;
            letter-spacing: -0.01em;
        }
        .invoice-id-tag {
            color: var(--nl-primary);
            font-weight: 700;
        }
        .meta-row {
            font-size: 0.82rem;
            color: var(--text-muted);
            margin-bottom: 3px;
        }
        .meta-row strong {
            color: var(--text-dark);
        }

        .status-stamp {
            display: inline-block;
            margin-top: 8px;
            padding: 4px 14px;
            border-radius: 6px;
            font-size: 0.78rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .status-paid { background: #DCFCE7; color: #16A34A; border: 1px solid #86EFAC; }
        .status-partial { background: #FEF3C7; color: #D97706; border: 1px solid #FCD34D; }
        .status-overdue { background: #FEE2E2; color: #DC2626; border: 1px solid #FCA5A5; }
        .status-unpaid { background: #F3F4F6; color: #4B5563; border: 1px solid #D1D5DB; }

        .parties-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            background: #FAFAFA;
            border: 1px solid var(--border-color);
            border-radius: 10px;
            padding: 18px 24px;
            margin-bottom: 28px;
        }
        .party-block h4 {
            font-family: 'Outfit', sans-serif;
            font-weight: 700;
            font-size: 0.92rem;
            color: var(--text-dark);
            margin: 0 0 8px 0;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .party-block p {
            margin: 0;
            font-size: 0.84rem;
            color: var(--text-muted);
            line-height: 1.5;
        }
        .party-block p strong {
            color: var(--text-dark);
        }

        .items-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 24px;
        }
        .items-table th {
            background-color: #F9FAFB;
            color: var(--text-muted);
            font-size: 0.74rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            padding: 12px 16px;
            border-top: 1px solid var(--border-color);
            border-bottom: 2px solid var(--border-color);
            text-align: left;
        }
        .items-table td {
            padding: 14px 16px;
            font-size: 0.86rem;
            border-bottom: 1px solid var(--border-color);
            color: var(--text-dark);
        }
        .items-table .text-right {
            text-align: right;
        }

        .summary-container {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 28px;
        }
        .payment-info {
            width: 50%;
            font-size: 0.8rem;
            color: var(--text-muted);
            line-height: 1.5;
        }
        .payment-info strong {
            color: var(--text-dark);
        }
        .totals-table {
            width: 42%;
            border-collapse: collapse;
        }
        .totals-table td {
            padding: 6px 0;
            font-size: 0.86rem;
        }
        .totals-table .amount {
            text-align: right;
            font-weight: 600;
            color: var(--text-dark);
        }
        .totals-table tr.grand-total td {
            padding-top: 12px;
            border-top: 2px solid var(--text-dark);
            font-family: 'Outfit', sans-serif;
            font-weight: 800;
            font-size: 1.15rem;
            color: var(--nl-primary);
        }
        .totals-table tr.balance-due td {
            padding-top: 8px;
            font-weight: 700;
            color: #DC2626;
        }

        .barcode-section {
            border-top: 1px dashed var(--border-color);
            padding-top: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .barcode-code {
            font-family: 'Libre Barcode 128', cursive;
            font-size: 46px;
            line-height: 1;
            color: var(--text-dark);
        }
        .barcode-sub {
            font-size: 0.68rem;
            color: var(--text-muted);
            letter-spacing: 1px;
            font-weight: 600;
        }

        @media print {
            body { background: #FFFFFF; padding: 0; }
            .action-bar { display: none; }
            .invoice-wrapper { border: none; box-shadow: none; padding: 0; width: 100%; max-width: 100%; }
        }
    </style>
</head>
<body>

    <div class="action-bar">
        <a href="${pageContext.request.contextPath}/billing" class="btn-back">
            <i class="fa-solid fa-arrow-left me-1"></i> Back to Billing
        </a>
        <button class="btn-print" onclick="window.print()">
            <i class="fa-solid fa-print"></i> Print / Download PDF
        </button>
    </div>

    <c:choose>
    <c:when test="${empty invoice}">
        <div class="invoice-wrapper" style="text-align:center; padding:80px 20px; color:#6B7280;">
            <i class="fa-solid fa-file-circle-exclamation" style="font-size:32px; display:block; margin-bottom:12px;"></i>
            Invoice not found.
        </div>
    </c:when>
    <c:otherwise>
    <div class="invoice-wrapper">

        <div class="invoice-header">
            <div>
                <h1 class="brand-title">
                    <i class="fa-solid fa-cube" style="color:var(--nl-primary);"></i> NLogistic<span>ERP</span>
                </h1>
                <div class="company-details">
                    <strong>NLogistic Global Integrated Port Terminal</strong><br>
                    Plot 104, Export Harbor Zone, JNPT Hub, MH - 400707<br>
                    GSTIN: 27AABCN8912P1ZV &bull; PAN: AABCN8912P<br>
                    Email: finance@nlogistic.com &bull; Support: +91 22 4580 9000
                </div>
            </div>
            <div class="invoice-meta">
                <h2>TAX INVOICE</h2>
                <div class="meta-row"><strong>Invoice #:</strong> <span class="invoice-id-tag">INV-${invoice.invoiceId}</span></div>
                <div class="meta-row"><strong>Invoice Date:</strong> <fmt:formatDate value="${invoice.invoiceDate}" pattern="dd MMM yyyy"/></div>
                <div class="meta-row"><strong>Payment Due:</strong> <fmt:formatDate value="${invoice.dueDate}" pattern="dd MMM yyyy"/></div>

                <c:choose>
                    <c:when test="${invoice.paymentStatus == 'Paid'}">
                        <span class="status-stamp status-paid"><i class="fa-solid fa-check"></i> Paid in Full</span>
                    </c:when>
                    <c:when test="${invoice.paymentStatus == 'Partial'}">
                        <span class="status-stamp status-partial"><i class="fa-solid fa-clock"></i> Partially Paid</span>
                    </c:when>
                    <c:when test="${invoice.paymentStatus == 'Overdue'}">
                        <span class="status-stamp status-overdue"><i class="fa-solid fa-triangle-exclamation"></i> Overdue</span>
                    </c:when>
                    <c:otherwise>
                        <span class="status-stamp status-unpaid"><i class="fa-solid fa-hourglass-start"></i> Payment Due</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="parties-grid">
            <div class="party-block">
                <h4>Billed To (Customer):</h4>
                <p>
                    <strong>${invoice.customerName}</strong><br>
                    Customer ID: CUST-${invoice.customerId}<br>
                    Email: ${invoice.customerEmail}<br>
                    Phone: ${not empty invoice.customerPhone ? invoice.customerPhone : '+91 (0) Direct Account'}
                </p>
            </div>
            <div class="party-block">
                <h4>Shipment &amp; Movement Logistics:</h4>
                <p>
                    <strong>Shipment Reference:</strong> #${invoice.shipmentId}<br>
                    <strong>Cargo Description:</strong> ${invoice.cargoDescription}<br>
                    <strong>Origin &bull; Destination:</strong> ${invoice.originPort} &rarr; ${invoice.destinationPort}<br>
                    <strong>Compliance Clearance:</strong> Verified &amp; Cleared
                </p>
            </div>
        </div>

        <table class="items-table">
            <thead>
                <tr>
                    <th style="width: 8%;">#</th>
                    <th style="width: 52%;">Description of Service / Freight</th>
                    <th class="text-right" style="width: 12%;">Qty</th>
                    <th class="text-right" style="width: 14%;">Rate (&#8377;)</th>
                    <th class="text-right" style="width: 14%;">Amount (&#8377;)</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="item" items="${lineItems}" varStatus="status">
                    <tr>
                        <td>${status.count}</td>
                        <td><strong>${item.description}</strong></td>
                        <td class="text-right">${item.quantity}</td>
                        <td class="text-right"><fmt:formatNumber value="${item.unitPrice}" minFractionDigits="2"/></td>
                        <td class="text-right fw-bold"><fmt:formatNumber value="${item.lineTotal}" minFractionDigits="2"/></td>
                    </tr>
                </c:forEach>
                <c:if test="${empty lineItems}">
                    <tr>
                        <td>1</td>
                        <td><strong>Standard Freight &amp; Handling Service</strong></td>
                        <td class="text-right">1</td>
                        <td class="text-right"><fmt:formatNumber value="${invoice.subtotalAmount}" minFractionDigits="2"/></td>
                        <td class="text-right fw-bold"><fmt:formatNumber value="${invoice.subtotalAmount}" minFractionDigits="2"/></td>
                    </tr>
                </c:if>
            </tbody>
        </table>

        <div class="summary-container">
            <div class="payment-info">
                <strong>Bank Remittance Details:</strong><br>
                Beneficiary: NLogistic Freight &amp; Supply Chain Ltd.<br>
                Bank: HDFC Bank &bull; A/C: 50200089123400<br>
                IFSC: HDFC0000240 &bull; Branch: JNPT Port Commercial<br>
                UPI ID: payments@nlogistic

                <c:if test="${not empty payments}">
                    <div style="margin-top: 14px; font-size: 0.76rem;">
                        <strong>Recorded Payment Logs:</strong>
                        <ul style="padding-left: 18px; margin: 4px 0 0;">
                            <c:forEach var="p" items="${payments}">
                                <li><fmt:formatDate value="${p.paymentDate}" pattern="dd MMM yyyy"/>: &#8377;<fmt:formatNumber value="${p.amountPaid}" minFractionDigits="2"/> via ${p.paymentMode} (${p.transactionRef})</li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>
            </div>

            <table class="totals-table">
                <tr>
                    <td>Subtotal:</td>
                    <td class="amount">&#8377;<fmt:formatNumber value="${invoice.subtotalAmount}" minFractionDigits="2"/></td>
                </tr>
                <tr>
                    <td>Tax / GST:</td>
                    <td class="amount">&#8377;<fmt:formatNumber value="${invoice.taxAmount}" minFractionDigits="2"/></td>
                </tr>
                <tr class="grand-total">
                    <td>Total Invoiced:</td>
                    <td class="amount">&#8377;<fmt:formatNumber value="${invoice.totalAmount}" minFractionDigits="2"/></td>
                </tr>
                <tr>
                    <td>Amount Paid:</td>
                    <td class="amount" style="color: #16A34A;">&#8377;<fmt:formatNumber value="${invoice.paidAmount}" minFractionDigits="2"/></td>
                </tr>
                <tr class="balance-due">
                    <td>Balance Outstanding:</td>
                    <td class="amount">&#8377;<fmt:formatNumber value="${invoice.balanceDue}" minFractionDigits="2"/></td>
                </tr>
            </table>
        </div>

        <div class="barcode-section">
            <div>
                <div class="barcode-code">*INV-${invoice.invoiceId}*</div>
                <div class="barcode-sub">CODE128 SCANNABLE &bull; ENTITY: INVOICE #${invoice.invoiceId}</div>
            </div>
            <div style="text-align: right; font-size: 0.74rem; color: var(--text-muted);">
                Authorized Signatory for NLogistic ERP<br>
                <strong>Finance &amp; Accounts Division</strong>
            </div>
        </div>

    </div>
    </c:otherwise>
    </c:choose>

</body>
</html>
