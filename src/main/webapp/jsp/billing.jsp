<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/layout/header.jsp" />

<div class="container-fluid mt-4 mb-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2><i class="bi bi-receipt me-2 text-primary"></i>Billing & Invoicing</h2>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#generateInvoiceModal"><i class="bi bi-plus-lg"></i> Generate Invoice</button>
    </div>
    
    <c:if test="${param.success == 'true'}">
        <div class="alert alert-success alert-dismissible fade show">Action completed successfully! <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
    </c:if>
    <c:if test="${param.error == 'true'}">
        <div class="alert alert-danger alert-dismissible fade show">Failed to perform action! <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
    </c:if>

    <div class="card shadow-sm border-0">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>Invoice ID</th>
                            <th>Dates</th>
                            <th>Customer / Shipment</th>
                            <th>Amounts</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="inv" items="${invoices}">
                            <tr>
                                <td><strong>#${inv.invoiceId}</strong></td>
                                <td>
                                    <small>Issued: ${inv.invoiceDate}<br>Due: <span class="text-danger">${inv.dueDate}</span></small>
                                </td>
                                <td>Cust: #${inv.customerId} | Ship: #${inv.shipmentId}</td>
                                <td>
                                    <small class="text-muted">Sub: $${inv.subtotalAmount} | Tax: $${inv.taxAmount}</small><br>
                                    <strong>Total: $${inv.totalAmount}</strong><br>
                                    <span class="text-success">Paid: $${inv.paidAmount}</span>
                                </td>
                                <td>
                                    <span class="badge ${inv.paymentStatus == 'Paid' ? 'bg-success' : (inv.paymentStatus == 'Partial' ? 'bg-info' : 'bg-danger')}">
                                        ${inv.paymentStatus}
                                    </span>
                                </td>
                                <td>
                                    <c:if test="${inv.paymentStatus != 'Paid' && inv.paymentStatus != 'Void'}">
                                        <button class="btn btn-sm btn-success" data-bs-toggle="modal" data-bs-target="#paymentModal${inv.invoiceId}"><i class="bi bi-currency-dollar"></i> Pay</button>
                                        
                                        <!-- Record Payment Modal -->
                                        <div class="modal fade" id="paymentModal${inv.invoiceId}" tabindex="-1">
                                            <div class="modal-dialog">
                                                <div class="modal-content">
                                                    <form action="${pageContext.request.contextPath}/billing/pay" method="POST">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title">Record Payment for Invoice #${inv.invoiceId}</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <input type="hidden" name="invoiceId" value="${inv.invoiceId}">
                                                            <div class="alert alert-info">Balance Due: <strong>$${inv.totalAmount - inv.paidAmount}</strong></div>
                                                            <div class="mb-3">
                                                                <label class="form-label">Amount Paid ($)</label>
                                                                <input type="number" step="0.01" max="${inv.totalAmount - inv.paidAmount}" class="form-control" name="amountPaid" required>
                                                            </div>
                                                            <div class="mb-3">
                                                                <label class="form-label">Payment Mode</label>
                                                                <select class="form-select" name="paymentMode" required>
                                                                    <option>Bank Transfer</option>
                                                                    <option>Card</option>
                                                                    <option>UPI</option>
                                                                    <option>Cheque</option>
                                                                </select>
                                                            </div>
                                                            <div class="mb-3">
                                                                <label class="form-label">Transaction Reference</label>
                                                                <input type="text" class="form-control" name="transactionRef" placeholder="e.g. TXN123456" required>
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                                            <button type="submit" class="btn btn-success">Record Payment</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Generate Invoice Modal -->
<div class="modal fade" id="generateInvoiceModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/billing/generate" method="POST">
                <div class="modal-header">
                    <h5 class="modal-title">Generate New Invoice</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p class="text-muted small">The billing engine will automatically calculate freight charges and taxes based on the pricing rules for the shipment's container.</p>
                    <div class="mb-3">
                        <label class="form-label">Customer</label>
                        <select class="form-select" name="customerId" required>
                            <c:forEach var="c" items="${customers}">
                                <option value="${c.customerId}">${c.customerName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Shipment</label>
                        <select class="form-select" name="shipmentId" required>
                            <c:forEach var="s" items="${shipments}">
                                <option value="${s.shipmentId}">Shipment #${s.shipmentId} (Route: ${s.originPort} -> ${s.destPort})</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="bi bi-magic"></i> Auto-Generate Invoice</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />
