<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    .page-title { font-weight: 700; color: #1e293b; font-size: 24px; }
    .breadcrumb-text { font-size: 13px; color: #64748b; }
    
    .badge-in { background-color: #ecfdf5; color: #10b981; padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: 600;}
    .badge-out { background-color: #fef2f2; color: #ef4444; padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: 600;}
    .badge-adj { background-color: #fffbeb; color: #f59e0b; padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: 600;}
</style>

<div class="container-fluid py-4" style="background-color: #fafafa; min-height: 100vh;">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="page-title mb-1">Stock & Inventory Ledger</h1>
            <div class="breadcrumb-text">Dashboard &nbsp;>&nbsp; Stock & Inventory &nbsp;>&nbsp; Inventory Ledger</div>
        </div>
        <div>
            <button class="btn btn-outline-secondary bg-white"><i class="fa-solid fa-print me-2"></i> Print Ledger</button>
        </div>
    </div>

    <!-- Ledger Table -->
    <div class="card shadow-sm border-0" style="border-radius: 12px;">
        <div class="card-body p-4">
            <h5 class="fw-bold mb-4"><i class="fa-solid fa-book-open text-primary me-2"></i> Inventory Movement History</h5>
            <p class="text-muted small mb-4">This ledger records every single change (IN/OUT) to the inventory, including bulk uploads, manual entries, and write-offs.</p>
            
            <div class="table-responsive">
                <table class="table align-middle text-nowrap mb-0" style="font-size: 14px;">
                    <thead class="text-muted" style="background-color: #f8fafc;">
                        <tr>
                            <th class="fw-normal border-0 rounded-start">Date & Time</th>
                            <th class="fw-normal border-0">Product Name</th>
                            <th class="fw-normal border-0 text-center">Type</th>
                            <th class="fw-normal border-0 text-end">Quantity</th>
                            <th class="fw-normal border-0 text-end">Unit Cost (₹)</th>
                            <th class="fw-normal border-0 rounded-end">Reference / Remarks</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="entry" items="${ledgerList}">
                            <tr>
                                <td><fmt:formatDate value="${entry.date}" pattern="dd MMM yyyy, hh:mm a" /></td>
                                <td class="fw-bold text-dark">${entry.productName} <br><small class="text-muted fw-normal">HSN: ${entry.hsnCode}</small></td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${entry.type == 'IN'}"><span class="badge-in"><i class="fa-solid fa-arrow-down me-1"></i> IN</span></c:when>
                                        <c:when test="${entry.type == 'OUT'}"><span class="badge-out"><i class="fa-solid fa-arrow-up me-1"></i> OUT</span></c:when>
                                        <c:otherwise><span class="badge-adj"><i class="ti ti-pencil me-1"></i> ADJ</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="fw-bold text-end 
                                    <c:if test="${entry.type == 'IN'}">text-success</c:if>
                                    <c:if test="${entry.type == 'OUT'}">text-danger</c:if>
                                ">
                                    <c:if test="${entry.type == 'IN'}">+</c:if>
                                    <c:if test="${entry.type == 'OUT'}">-</c:if>
                                    ${entry.quantity}
                                </td>
                                <td class="text-end text-muted">₹ ${entry.unitCost}</td>
                                <td class="text-muted"><i class="fa-solid fa-tag me-2"></i>${entry.reference}</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty ledgerList}">
                            <tr><td colspan="6" class="text-center py-4 text-muted">No ledger entries found.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />
