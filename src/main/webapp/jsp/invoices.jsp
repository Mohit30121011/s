<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    .page-title { font-weight: 700; color: #1e293b; font-size: 24px; }
    .breadcrumb-text { font-size: 13px; color: #64748b; }
    
    .status-badge {
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 11px;
        font-weight: 700;
        letter-spacing: 0.5px;
        text-transform: uppercase;
    }
    .status-Unpaid { background: #fee2e2; color: #ef4444; }
    .status-Paid { background: #dcfce7; color: #10b981; }
    .status-Partial { background: #fef3c7; color: #f59e0b; }
    .status-Overdue { background: #fce7f3; color: #ec4899; }
</style>

<div class="container-fluid py-4" style="background-color: #fafafa; min-height: 100vh;">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="page-title mb-1">Billing & Invoices</h1>
            <div class="breadcrumb-text">Dashboard &nbsp;>&nbsp; Finance &nbsp;>&nbsp; Invoices</div>
        </div>
        <button class="btn btn-nlog" data-bs-toggle="modal" data-bs-target="#generateInvoiceModal">
            <i class="fa-solid fa-plus me-2"></i> Generate New Invoice
        </button>
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

    <!-- Invoices Table -->
    <div class="card shadow-sm border-0" style="border-radius: 12px;">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="bg-light">
                        <tr>
                            <th class="text-muted fw-bold border-0 px-4 py-3" style="font-size: 13px;">Invoice #</th>
                            <th class="text-muted fw-bold border-0 py-3" style="font-size: 13px;">Customer</th>
                            <th class="text-muted fw-bold border-0 py-3" style="font-size: 13px;">Shipment Detail</th>
                            <th class="text-muted fw-bold border-0 py-3" style="font-size: 13px;">Amount</th>
                            <th class="text-muted fw-bold border-0 py-3" style="font-size: 13px;">Status</th>
                            <th class="text-muted fw-bold border-0 py-3" style="font-size: 13px;">Due Date</th>
                            <th class="text-muted fw-bold border-0 px-4 py-3 text-end" style="font-size: 13px;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="inv" items="${invoices}">
                            <tr>
                                <td class="px-4 py-3 fw-bold text-dark">INV-${inv.invoiceId}</td>
                                <td class="py-3 fw-bold">${inv.customerName}</td>
                                <td class="py-3 text-muted" style="font-size: 13px;">
                                    <i class="fa-solid fa-box text-primary me-1"></i> #${inv.shipmentId} - ${inv.cargoDesc}
                                </td>
                                <td class="py-3">
                                    <div class="fw-bold">₹<fmt:formatNumber value="${inv.totalAmount}" pattern="#,##0.00"/></div>
                                    <div class="text-muted" style="font-size: 11px;">Paid: ₹${inv.paidAmount}</div>
                                </td>
                                <td class="py-3">
                                    <span class="status-badge status-${inv.paymentStatus}">${inv.paymentStatus}</span>
                                </td>
                                <td class="py-3 text-muted" style="font-size: 13px;">
                                    <fmt:formatDate value="${inv.dueDate}" pattern="dd MMM yyyy" />
                                </td>
                                <td class="px-4 py-3 text-end">
                                    <button class="btn btn-sm btn-outline-primary" onclick="viewInvoice(${inv.invoiceId})" title="View PDF">
                                        <i class="fa-solid fa-file-pdf"></i>
                                    </button>
                                    <c:if test="${inv.paymentStatus ne 'Paid'}">
                                        <button class="btn btn-sm btn-success ms-1" data-bs-toggle="modal" data-bs-target="#paymentModal" 
                                                onclick="setupPayment(${inv.invoiceId}, ${inv.totalAmount - inv.paidAmount})" title="Record Payment">
                                            <i class="fa-solid fa-indian-rupee-sign"></i> Pay
                                        </button>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty invoices}">
                            <tr>
                                <td colspan="7" class="text-center py-5 text-muted">No invoices generated yet.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Generate Invoice Modal -->
<div class="modal fade" id="generateInvoiceModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content border-0 shadow" style="border-radius: 12px;">
            <div class="modal-header border-bottom-0 pb-0">
                <h5 class="modal-title fw-bold">Generate Invoice</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="<c:url value='/generate-invoice'/>" method="POST">
                <div class="modal-body">
                    <p class="text-muted small mb-4">Select an un-invoiced shipment to generate a new bill.</p>
                    
                    <div class="mb-3">
                        <label class="form-label text-muted fw-bold" style="font-size: 13px;">Select Shipment</label>
                        <select name="shipmentData" class="form-select" required>
                            <option value="" disabled selected>Choose...</option>
                            <c:forEach var="ship" items="${eligibleShipments}">
                                <!-- Pass composite value to avoid extra DB lookups in simple flow -->
                                <option value="${ship.shipmentId}|${ship.customerId}|${ship.cost}">
                                    #${ship.shipmentId} - ${ship.customerName} (₹${ship.cost})
                                </option>
                            </c:forEach>
                        </select>
                        <c:if test="${empty eligibleShipments}">
                            <small class="text-danger mt-1 d-block">All shipments are currently invoiced.</small>
                        </c:if>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label text-muted fw-bold" style="font-size: 13px;">Due Date</label>
                        <input type="date" name="dueDate" class="form-control" required>
                    </div>
                </div>
                <div class="modal-footer border-top-0 pt-0">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-nlog" ${empty eligibleShipments ? 'disabled' : ''}>Generate & Save</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Record Payment Modal -->
<div class="modal fade" id="paymentModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content border-0 shadow" style="border-radius: 12px;">
            <div class="modal-header border-bottom-0 pb-0">
                <h5 class="modal-title fw-bold">Record Payment</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="<c:url value='/record-payment'/>" method="POST">
                <input type="hidden" name="invoiceId" id="payInvoiceId">
                <div class="modal-body">
                    <div class="alert bg-light border-0 mb-4">
                        <div class="d-flex justify-content-between">
                            <span class="text-muted">Remaining Balance:</span>
                            <span class="fw-bold text-danger fs-5">₹<span id="payBalance"></span></span>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label text-muted fw-bold" style="font-size: 13px;">Amount Paid (₹)</label>
                        <input type="number" step="0.01" name="amountPaid" id="amountPaidInput" class="form-control" required>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label text-muted fw-bold" style="font-size: 13px;">Payment Method</label>
                        <select name="paymentMode" class="form-select" required>
                            <option value="Bank Transfer">Bank Transfer (NEFT/RTGS)</option>
                            <option value="Card">Credit/Debit Card</option>
                            <option value="UPI">UPI</option>
                            <option value="Cheque">Cheque</option>
                        </select>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label text-muted fw-bold" style="font-size: 13px;">Transaction Ref Number</label>
                        <input type="text" name="transactionRef" class="form-control" placeholder="e.g. UTR Number" required>
                    </div>
                </div>
                <div class="modal-footer border-top-0 pt-0">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-success">Confirm Payment</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function setupPayment(invoiceId, balance) {
        document.getElementById('payInvoiceId').value = invoiceId;
        document.getElementById('payBalance').innerText = parseFloat(balance).toFixed(2);
        document.getElementById('amountPaidInput').value = parseFloat(balance).toFixed(2);
        document.getElementById('amountPaidInput').max = balance;
    }
    
    function viewInvoice(invoiceId) {
        window.open('${pageContext.request.contextPath}/view-invoice?id=' + invoiceId, '_blank');
    }
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
