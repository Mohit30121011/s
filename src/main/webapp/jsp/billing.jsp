<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-regular-rounded/css/uicons-regular-rounded.css'>
<link rel='stylesheet' href='https://cdn-uicons.flaticon.com/2.1.0/uicons-solid-rounded/css/uicons-solid-rounded.css'>

<link href="https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/css/tom-select.bootstrap5.min.css" rel="stylesheet">
  <style>
    :root {
        --bg-surface: #ffffff;
        --border-color: #E7E9ED;
        --text-main: #111827;
        --text-sub: #6B7280;
        --primary: #FC8019;
        --primary-light: #FFF2EB;
        --success: #10B981;
        --success-light: #D1FAE5;
        --danger: #EF4444;
        --danger-light: #FEE2E2;
        --warning: #F59E0B;
        --warning-light: #FEF3C7;
        --info: #3B82F6;
        --info-light: #DBEAFE;
    }
    body {
        background-color: #F9FAFB;
    }
    .dashboard-container {
        padding: 24px;
        max-width: 1400px;
        margin: 0 auto;
    }
    
    .page-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 24px;
    }
    .page-title h1 {
        font-size: 24px;
        font-weight: 700;
        color: var(--text-main);
        margin: 0 0 8px 0;
    }
    .page-title p {
        color: var(--text-sub);
        margin: 0;
        font-size: 14px;
    }
    
    .btn-custom {
        padding: 10px 20px;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 500;
        border: none;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        transition: all 0.2s;
    }
    .btn-primary-custom {
        background-color: var(--primary);
        color: white;
    }
    .btn-primary-custom:hover {
        background-color: #FC8019;
    }
    .btn-outline {
        background-color: white;
        border: 1px solid var(--border-color);
        color: var(--text-main);
    }
    .btn-outline:hover {
        background-color: #F9FAFB;
    }

    .kpi-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        gap: 20px;
        margin-bottom: 32px;
    }
    .kpi-card {
        background: var(--bg-surface);
        border: 1px solid var(--border-color);
        border-radius: 12px;
        padding: 20px;
        display: flex;
        align-items: center;
        gap: 16px;
    }
    .kpi-icon {
        width: 48px;
        height: 48px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
    }
    .kpi-icon.icon-docs { background: var(--primary-light); color: var(--primary); }
    .kpi-icon.icon-approved { background: var(--success-light); color: var(--success); }
    .kpi-icon.icon-review { background: var(--warning-light); color: var(--warning); }
    .kpi-icon.icon-rejected { background: var(--danger-light); color: var(--danger); }
    .kpi-icon.icon-expiring { background: #F3E8FF; color: #9333EA; }
    
    .kpi-icon.icon-inv { background: #F3E8FF; color: #9333EA; }
    .kpi-icon.icon-amount { background: var(--success-light); color: var(--success); }

    .kpi-data { flex: 1; }
    .kpi-title {
        color: var(--text-sub);
        font-size: 13px;
        font-weight: 500;
        margin-bottom: 4px;
    }
    .kpi-val {
        color: var(--text-main);
        font-size: 24px;
        font-weight: 700;
        line-height: 1.2;
    }
    .kpi-sub {
        color: var(--text-sub);
        font-size: 12px;
        margin-top: 4px;
    }

    .section-title-wrap {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 16px;
    }
    .section-title {
        font-size: 18px;
        font-weight: 600;
        color: var(--text-main);
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .section-subtitle {
        color: var(--text-sub);
        font-size: 13px;
        margin-top: 4px;
    }

    .table-card {
        background: var(--bg-surface);
        border: 1px solid var(--border-color);
        border-radius: 12px;
        padding: 0;
        overflow: visible;
        margin-bottom: 32px;
    }
    table {
        width: 100%;
        border-collapse: collapse;
    }
    th {
        background: #F9FAFB;
        padding: 12px 20px;
        text-align: left;
        font-size: 12px;
        font-weight: 600;
        color: var(--text-sub);
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border-bottom: 1px solid var(--border-color);
    }
    td {
        padding: 16px 20px;
        border-bottom: 1px solid var(--border-color);
        font-size: 14px;
        color: var(--text-main);
        vertical-align: middle;
    }
    tr:last-child td {
        border-bottom: none;
    }
    
    .status-badge {
        padding: 4px 10px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 500;
        display: inline-block;
    }
    .status-approved { background: var(--success-light); color: var(--success); }
    .status-review { background: var(--warning-light); color: var(--warning); }
    .status-rejected { background: var(--danger-light); color: var(--danger); }
    
    .status-paid { background: var(--success-light); color: var(--success); }
    .status-unpaid { background: var(--danger-light); color: var(--danger); }
    .status-partial { background: var(--warning-light); color: var(--warning); }
    .status-overdue { background: #FEE2E2; color: #B91C1C; }

    .action-cell {
        display: flex;
        gap: 8px;
        align-items: center;
    }
    .btn-icon {
        width: 32px;
        height: 32px;
        border-radius: 6px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: 1px solid var(--border-color);
        background: white;
        color: var(--text-sub);
        cursor: pointer;
        transition: all 0.2s;
    }
    .btn-icon:hover {
        background: #F9FAFB;
        color: var(--text-main);
    }
    .btn-view { color: var(--info); border-color: var(--info-light); background: var(--info-light); }
    .btn-edit { color: var(--warning); border-color: var(--warning-light); background: var(--warning-light); }
    
    .dropdown-container {
        position: relative;
    }
    .dropdown-menu-custom {
        position: absolute;
        right: 0;
        top: 100%;
        margin-top: 4px;
        background: white;
        border: 1px solid var(--border-color);
        border-radius: 8px;
        box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -1px rgba(0,0,0,0.06);
        min-width: 150px;
        z-index: 9999;
        display: none;
        padding: 4px;
    }
    .dropdown-menu-custom.show {
        display: block;
    }
    .dropdown-item {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 12px;
        color: var(--text-main);
        text-decoration: none;
        font-size: 13px;
        border-radius: 4px;
    }
    .dropdown-item:hover {
        background: #F3F4F6;
        color: var(--text-main);
    }
    .text-danger { color: var(--danger) !important; }

    /* Modal Styles */
    .modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0,0,0,0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 99999;
        opacity: 0;
        pointer-events: none;
        transition: opacity 0.2s;
    }
    .modal-overlay.active {
        opacity: 1;
        pointer-events: auto;
    }
    .modal-content {
        background: white;
        border-radius: 12px;
        width: 100%;
        max-width: 500px;
        padding: 24px;
        box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
        transform: translateY(20px);
        transition: transform 0.2s;
    }
    .modal-overlay.active .modal-content {
        transform: translateY(0);
    }
    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
    }
    .modal-header h3 {
        margin: 0;
        font-size: 18px;
        font-weight: 600;
    }
    .modal-close {
        background: none;
        border: none;
        font-size: 20px;
        color: var(--text-sub);
        cursor: pointer;
    }
    .form-group {
        margin-bottom: 16px;
    }
    .form-group label {
        display: block;
        font-size: 13px;
        font-weight: 500;
        margin-bottom: 6px;
        color: var(--text-main);
    }
    .form-control {
        width: 100%;
        padding: 10px 12px;
        border: 1px solid var(--border-color);
        border-radius: 6px;
        font-size: 14px;
    }
    .form-control:focus {
        outline: none;
        border-color: var(--primary);
        box-shadow: 0 0 0 3px var(--primary-light);
    }
    .modal-actions {
        display: flex;
        justify-content: flex-end;
        gap: 12px;
        margin-top: 24px;
    }

    .pagination-container {
        display: flex;
        justify-content: flex-end;
        gap: 8px;
        margin-top: 16px;
    }
    .pagination-container button {
        border: 1px solid var(--border-color);
        background: #fff;
        padding: 6px 12px;
        border-radius: 6px;
        cursor: pointer;
        font-size: 14px;
        color: var(--text-main);
        transition: all 0.2s;
    }
    .pagination-container button:hover:not(:disabled) {
        background: var(--primary-light);
        color: var(--primary);
        border-color: var(--primary);
    }
    .pagination-container button.active {
        background: var(--primary);
        color: #fff;
        border-color: var(--primary);
    }
    .pagination-container button:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    .payment-mode-fields { margin-top: 4px; }
    .qr-box {
        background: var(--primary-light);
        border: 1px dashed var(--primary);
        border-radius: 10px;
        padding: 16px;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 8px;
        margin-bottom: 16px;
    }
    .qr-pattern {
        width: 140px;
        height: 140px;
        background:
            repeating-linear-gradient(0deg, #111827 0 6px, transparent 6px 12px),
            repeating-linear-gradient(90deg, #111827 0 6px, transparent 6px 12px);
        background-blend-mode: multiply;
        background-color: #fff;
        border: 6px solid #111827;
        border-radius: 6px;
    }
    .qr-caption {
        font-size: 12px;
        color: var(--text-sub);
        font-weight: 500;
    }
</style>

</style>

<div class="dashboard-container">
    <div class="page-header">
        <div class="page-title">
            <h1>Billing & Invoices</h1>
            <p>Generate invoices, record payments and track billing status.</p>
        </div>
    </div>
    
    
    <div class="kpi-grid">
        <div class="kpi-card">
            <div class="kpi-icon icon-inv"><i class="fi fi-rr-file-invoice-dollar"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Total Invoices</div>
                <div class="kpi-val">${invTotal}</div>
                <div class="kpi-sub">All Time</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-amount"><i class="fi fi-rr-sack-dollar"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Total Amount</div>
                <div class="kpi-val">&#8377;<fmt:formatNumber value="${invTotalAmount}" groupingUsed="true" maxFractionDigits="0"/></div>
                <div class="kpi-sub">All Time</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-approved"><i class="fi fi-rr-badge-check"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Paid Amount</div>
                <div class="kpi-val">&#8377;<fmt:formatNumber value="${invPaidAmount}" groupingUsed="true" maxFractionDigits="0"/></div>
                <div class="kpi-sub"><fmt:formatNumber value="${invTotalAmount > 0 ? (invPaidAmount/invTotalAmount)*100 : 0}" maxFractionDigits="0"/>% of total</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon icon-rejected"><i class="fi fi-rr-money-bill-wave"></i></div>
            <div class="kpi-data">
                <div class="kpi-title">Outstanding Amount</div>
                <div class="kpi-val">&#8377;<fmt:formatNumber value="${invTotalAmount - invPaidAmount}" groupingUsed="true" maxFractionDigits="0"/></div>
                <div class="kpi-sub"><fmt:formatNumber value="${invTotalAmount > 0 ? ((invTotalAmount - invPaidAmount)/invTotalAmount)*100 : 0}" maxFractionDigits="0"/>% of total</div>
            </div>
        </div>
    </div>

    
    <div class="card" style="padding: 16px;">
        
    <div class="section-title-wrap">
        <div>
            <div class="section-title"><i class="fi fi-sr-document-signed" style="color:var(--primary)"></i> Invoices</div>
        </div>
        <div>
            <button class="btn-custom btn-primary-custom" onclick="openModal('invoiceModal')"><i class="fi fi-rr-plus"></i> Generate New Invoice</button>
        </div>
    </div>
    <table id="invoiceTable">
        <thead>
            <tr>
                <th>Invoice No.</th>
                <th>Shipment ID</th>
                <th>Customer</th>
                <th>Invoice Date</th>
                <th>Due Date</th>
                <th>Total Amount</th>
                <th>Paid Amount</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <c:if test="${empty invoices}">
                <tr>
                    <td colspan="9" style="text-align: center; padding: 40px; color: var(--text-sub);">
                        <i class="fi fi-rr-file-invoice-dollar" style="font-size: 32px; display: block; margin-bottom: 12px; color: #D1D5DB;"></i>
                        No invoices found in the database.
                    </td>
                </tr>
            </c:if>
            <c:forEach var="inv" items="${invoices}">
                <tr>
                    <td><strong>INV-${inv.invoiceId}</strong></td>
                    <td>SHP-${inv.shipmentId}</td>
                    <td>
                        <c:forEach var="c" items="${customers}">
                            <c:if test="${c.customerId == inv.customerId}">${c.customerName}</c:if>
                        </c:forEach>
                    </td>
                    <td><fmt:formatDate value="${inv.invoiceDate}" pattern="dd MMM yyyy" /></td>
                    <td><fmt:formatDate value="${inv.dueDate}" pattern="dd MMM yyyy" /></td>
                    <td>&#8377;<fmt:formatNumber value="${inv.totalAmount}" groupingUsed="true" maxFractionDigits="0"/></td>
                    <td>&#8377;<fmt:formatNumber value="${inv.paidAmount}" groupingUsed="true" maxFractionDigits="0"/></td>
                    <td>
                        <c:choose>
                            <c:when test="${inv.paymentStatus == 'Paid'}"><span class="status-badge status-paid">Paid</span></c:when>
                            <c:when test="${inv.paymentStatus == 'Partial'}"><span class="status-badge status-partial">Partial</span></c:when>
                            <c:when test="${inv.paymentStatus == 'Overdue'}"><span class="status-badge status-overdue">Overdue</span></c:when>
                            <c:otherwise><span class="status-badge status-unpaid">Unpaid</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <div class="action-cell">
                            <button class="btn-icon btn-view" title="View Invoice" onclick="window.open('${pageContext.request.contextPath}/invoices?id=${inv.invoiceId}&action=view', '_blank')"><i class="fi fi-rr-eye"></i></button>
                            <button class="btn-icon btn-edit" title="Record Payment" onclick="document.getElementById('payInvoiceId').value='${inv.invoiceId}'; openModal('paymentModal');"><i class="fi fi-rr-coins"></i></button>
                            <div class="dropdown-container">
                                <button class="btn-icon action-dropdown" onclick="toggleDropdown(this)"><i class="fi fi-rr-menu-dots-vertical"></i></button>
                                <div class="dropdown-menu-custom">
                                    <a href="${pageContext.request.contextPath}/invoices?id=${inv.invoiceId}&action=print" target="_blank" class="dropdown-item"><i class="fi fi-rr-download"></i> Print / Download</a>
                                </div>
                            </div>
                        </div>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    </div>

    
    <!-- Generate Invoice Modal -->
    <div class="modal-overlay" id="invoiceModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Generate New Invoice</h3>
                <button class="modal-close" onclick="closeModal('invoiceModal')"><i class="fi fi-rr-cross"></i></button>
            </div>
            <form action="${pageContext.request.contextPath}/billing/generate" method="post">
                <div class="form-group">
                    <label>Customer</label>
                    <select name="customerId" class="form-control form-select-custom" required>
                        <option value="">Select Customer...</option>
                        <c:forEach var="c" items="${customers}">
                            <option value="${c.customerId}">${c.customerName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label>Shipment</label>
                    <select name="shipmentId" class="form-control form-select-custom" required>
                        <option value="">Select Shipment...</option>
                        <c:forEach var="s" items="${shipments}">
                            <option value="${s.shipmentId}">SHP-${s.shipmentId}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn-custom btn-outline" onclick="closeModal('invoiceModal')">Cancel</button>
                    <button type="submit" class="btn-custom btn-primary-custom">Generate Invoice</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Record Payment Modal -->
    <div class="modal-overlay" id="paymentModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Record Payment</h3>
                <button class="modal-close" onclick="closeModal('paymentModal')"><i class="fi fi-rr-cross"></i></button>
            </div>
            <form action="${pageContext.request.contextPath}/billing/pay" method="post" id="paymentForm" onsubmit="return preparePaymentSubmit();">
                <input type="hidden" name="invoiceId" id="payInvoiceId">
                <input type="hidden" name="transactionRef" id="transactionRefHidden">
                <div class="form-group">
                    <label>Amount Paid (&#8377;)</label>
                    <input type="number" step="0.01" name="amountPaid" class="form-control" required placeholder="0.00">
                </div>
                <div class="form-group">
                    <label>Payment Mode</label>
                    <select name="paymentMode" id="paymentModeSelect" class="form-control" style="width:100%;" required onchange="onPaymentModeChange()">
                        <option value="UPI">UPI</option>
                        <option value="Card">Card</option>
                        <option value="Cheque">Cheque</option>
                        <option value="Netbanking">Netbanking</option>
                        <option value="Bank Transfer">Bank Transfer</option>
                        <option value="Cash">Cash</option>
                    </select>
                </div>

                <!-- UPI: instant QR code -->
                <div class="payment-mode-fields" id="fields-UPI">
                    <div class="qr-box" id="upiQrBox">
                        <div class="qr-pattern" id="upiQrPattern"></div>
                        <div class="qr-caption">Scan to pay via any UPI app</div>
                    </div>
                    <div class="form-group">
                        <label>UPI Reference / VPA</label>
                        <input type="text" id="upiRef" class="form-control" placeholder="e.g. 9876543210@upi">
                    </div>
                </div>

                <!-- Card -->
                <div class="payment-mode-fields" id="fields-Card" style="display:none;">
                    <div class="form-group">
                        <label>Card Holder Name</label>
                        <input type="text" id="cardHolder" class="form-control" placeholder="e.g. R. Sharma">
                    </div>
                    <div style="display:flex; gap:16px;">
                        <div class="form-group" style="flex:1;">
                            <label>Card Number (last 4 digits)</label>
                            <input type="text" id="cardLast4" maxlength="4" pattern="[0-9]{4}" class="form-control" placeholder="1234">
                        </div>
                        <div class="form-group" style="flex:1;">
                            <label>Card Network</label>
                            <select id="cardNetwork" class="form-control">
                                <option value="Visa">Visa</option>
                                <option value="Mastercard">Mastercard</option>
                                <option value="RuPay">RuPay</option>
                                <option value="Amex">Amex</option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- Cheque -->
                <div class="payment-mode-fields" id="fields-Cheque" style="display:none;">
                    <div class="form-group">
                        <label>Cheque Number</label>
                        <input type="text" id="chequeNumber" class="form-control" placeholder="e.g. 004521">
                    </div>
                    <div class="form-group">
                        <label>Bearer Name</label>
                        <input type="text" id="bearerName" class="form-control" placeholder="e.g. Company Bank Pvt Ltd">
                    </div>
                </div>

                <!-- Netbanking -->
                <div class="payment-mode-fields" id="fields-Netbanking" style="display:none;">
                    <div class="form-group">
                        <label>Bank</label>
                        <select id="netbankBank" class="form-control">
                            <option value="HDFC Bank">HDFC Bank</option>
                            <option value="ICICI Bank">ICICI Bank</option>
                            <option value="State Bank of India">State Bank of India</option>
                            <option value="Axis Bank">Axis Bank</option>
                            <option value="Kotak Mahindra Bank">Kotak Mahindra Bank</option>
                        </select>
                    </div>
                </div>

                <!-- Bank Transfer / Cash: plain reference -->
                <div class="payment-mode-fields" id="fields-Other" style="display:none;">
                    <div class="form-group">
                        <label>Transaction Reference</label>
                        <input type="text" id="plainTxnRef" class="form-control" placeholder="e.g. TXN-12345">
                    </div>
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn-custom btn-outline" onclick="closeModal('paymentModal')">Cancel</button>
                    <button type="submit" class="btn-custom btn-primary-custom">Record Payment</button>
                </div>
            </form>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.9/dist/chart.umd.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/nl-chart-theme.js"></script>
<script src="https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/js/tom-select.complete.min.js"></script>
<script>

    function paginateTable(tableId, rowsPerPage) {
        const table = document.getElementById(tableId);
        if (!table) return;
        const tbody = table.querySelector('tbody');
        const rows = tbody.querySelectorAll('tr');
        if (rows.length === 0) return;

        const totalPages = Math.ceil(rows.length / rowsPerPage);
        let currentPage = 1;
        
        let pager = table.parentNode.querySelector('.pagination-container');
        if (!pager) {
            pager = document.createElement('div');
            pager.className = 'pagination-container';
            table.parentNode.insertBefore(pager, table.nextSibling);
        }

        function render() {
            rows.forEach((row, index) => {
                row.style.display = (index >= (currentPage - 1) * rowsPerPage && index < currentPage * rowsPerPage) ? '' : 'none';
            });

            pager.innerHTML = '';
            if (totalPages <= 1) return;
            
            const prevBtn = document.createElement('button');
            prevBtn.innerHTML = '&laquo;';
            prevBtn.disabled = currentPage === 1;
            prevBtn.onclick = () => { currentPage--; render(); };
            pager.appendChild(prevBtn);

            for (let i = 1; i <= totalPages; i++) {
                const btn = document.createElement('button');
                btn.textContent = i;
                if (i === currentPage) btn.classList.add('active');
                btn.onclick = () => { currentPage = i; render(); };
                pager.appendChild(btn);
            }

            const nextBtn = document.createElement('button');
            nextBtn.innerHTML = '&raquo;';
            nextBtn.disabled = currentPage === totalPages;
            nextBtn.onclick = () => { currentPage++; render(); };
            pager.appendChild(nextBtn);
        }
        
        render();
    }


    function toggleDropdown(btn) {
        document.querySelectorAll('.dropdown-menu-custom').forEach(menu => {
            if (menu !== btn.nextElementSibling) menu.classList.remove('show');
        });
        btn.nextElementSibling.classList.toggle('show');
    }
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.action-dropdown')) {
            document.querySelectorAll('.dropdown-menu-custom').forEach(menu => menu.classList.remove('show'));
        }
    });

    function openModal(id) {
        document.getElementById(id).classList.add('active');
        if (id === 'paymentModal') { onPaymentModeChange(); }
    }
    function closeModal(id) { document.getElementById(id).classList.remove('active'); }

    // FR5.7 / README2: dynamic payment mode fields (UPI QR, Cheque, Card, Netbanking)
    function onPaymentModeChange() {
        var mode = document.getElementById('paymentModeSelect').value;
        var groups = { 'UPI': 'fields-UPI', 'Card': 'fields-Card', 'Cheque': 'fields-Cheque', 'Netbanking': 'fields-Netbanking' };
        ['fields-UPI', 'fields-Card', 'fields-Cheque', 'fields-Netbanking', 'fields-Other'].forEach(function(id) {
            document.getElementById(id).style.display = 'none';
        });
        var targetId = groups[mode] || 'fields-Other';
        document.getElementById(targetId).style.display = 'block';
        if (mode === 'UPI') {
            generateQrPattern();
        }
    }

    function generateQrPattern() {
        var el = document.getElementById('upiQrPattern');
        var invId = document.getElementById('payInvoiceId').value || '0';
        var seed = parseInt(invId, 10) + Date.now();
        function rand() { seed = (seed * 9301 + 49297) % 233280; return seed / 233280; }
        var size = 10, cell = 14;
        var canvas = document.createElement('canvas');
        canvas.width = size * cell; canvas.height = size * cell;
        var ctx = canvas.getContext('2d');
        ctx.fillStyle = '#fff'; ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.fillStyle = '#111827';
        for (var r = 0; r < size; r++) {
            for (var c = 0; c < size; c++) {
                if (rand() > 0.5) ctx.fillRect(c * cell, r * cell, cell, cell);
            }
        }
        // Finder-pattern corners for a QR-like look
        [[0,0],[size-3,0],[0,size-3]].forEach(function(p) {
            ctx.fillStyle = '#111827';
            ctx.fillRect(p[0]*cell, p[1]*cell, cell*3, cell*3);
            ctx.fillStyle = '#fff';
            ctx.fillRect(p[0]*cell+cell*0.5, p[1]*cell+cell*0.5, cell*2, cell*2);
            ctx.fillStyle = '#111827';
            ctx.fillRect(p[0]*cell+cell, p[1]*cell+cell, cell, cell);
        });
        el.innerHTML = '';
        canvas.style.width = '100%'; canvas.style.height = '100%'; canvas.style.borderRadius = '4px';
        el.appendChild(canvas);
        document.getElementById('upiRef').value = 'UPI' + invId + Date.now().toString().slice(-6) + '@nlogistic';
    }

    function preparePaymentSubmit() {
        var mode = document.getElementById('paymentModeSelect').value;
        var ref = '';
        if (mode === 'UPI') {
            var vpa = document.getElementById('upiRef').value.trim();
            ref = 'UPI-' + (vpa || 'REF' + Date.now());
        } else if (mode === 'Card') {
            var holder = document.getElementById('cardHolder').value.trim();
            var last4 = document.getElementById('cardLast4').value.trim();
            var net = document.getElementById('cardNetwork').value;
            if (!last4) { alert('Please enter the last 4 digits of the card.'); return false; }
            ref = 'CARD-' + net + '-XXXX' + last4 + (holder ? (' (' + holder + ')') : '');
        } else if (mode === 'Cheque') {
            var chq = document.getElementById('chequeNumber').value.trim();
            var bearer = document.getElementById('bearerName').value.trim();
            if (!chq) { alert('Please enter the cheque number.'); return false; }
            ref = 'CHQ-' + chq + (bearer ? (' / Bearer: ' + bearer) : '');
        } else if (mode === 'Netbanking') {
            var bank = document.getElementById('netbankBank').value;
            ref = 'NB-' + bank.replace(/\s+/g, '') + '-' + Date.now().toString().slice(-8);
        } else {
            var plain = document.getElementById('plainTxnRef').value.trim();
            if (!plain) { alert('Please enter a transaction reference.'); return false; }
            ref = plain;
        }
        document.getElementById('transactionRefHidden').value = ref;
        return true;
    }
    
    document.querySelectorAll('.form-select-custom').forEach((el) => {
        if (!el.tomselect) {
            new TomSelect(el, {
                create: false,
                sortField: { field: "text", direction: "asc" }
            });
        }
    });

    window.addEventListener('click', function(e) {
        if (e.target.classList.contains('modal-overlay')) {
            e.target.classList.remove('active');
        }
    });

    paginateTable('invoiceTable', 15);
</script>

<%-- Export + Fullscreen controls on every card --%>
<script src="${pageContext.request.contextPath}/assets/js/nl-card-tools.js"></script>
</body>
</html>
