<%@ page language="java" contentType="text/html; charset=UTF-8" session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
.custom-breadcrumb a { color: #6c757d; text-decoration: none; font-size: 14px; }
.custom-breadcrumb a:hover { color: #EA580C; }
.custom-breadcrumb .active { color: #EA580C; font-weight: 500; font-size: 14px; }
.custom-breadcrumb-separator { color: #dee2e6; font-size: 10px; }
</style>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h4 class="mb-0 fw-bold">Customers Directory</h4>
    <div class="d-flex align-items-center gap-3">
        <div class="custom-breadcrumb mb-0">
            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <i class="fa-solid fa-chevron-right custom-breadcrumb-separator mx-2"></i>
            <span class="active">Customers</span>
        </div>
    </div>
</div>

<div class="card border-0 shadow-sm rounded-4">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="bg-light text-muted" style="font-size: 13px; text-transform: uppercase;">
                    <tr>
                        <th class="py-3 ps-4 border-0 rounded-start">Customer ID</th>
                        <th class="py-3 border-0">Name</th>
                        <th class="py-3 border-0">Address</th>
                        <th class="py-3 border-0">Credit Limit</th>
                        <th class="py-3 pe-4 border-0 rounded-end text-end">Registered Date</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty customers}">
                            <c:forEach var="customer" items="${customers}">
                                <tr>
                                    <td class="ps-4 fw-medium text-muted">#${customer.customerId}</td>
                                    <td class="fw-bold text-dark">
                                        <div class="d-flex align-items-center">
                                            <div class="rounded-circle bg-light d-flex align-items-center justify-content-center me-3" style="width: 36px; height: 36px;">
                                                <i class="fa-solid fa-user text-secondary"></i>
                                            </div>
                                            ${customer.customerName}
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty customer.address}">
                                                ${customer.address}
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted fst-italic">Not Provided</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25 px-2 py-1 rounded-3">
                                            $ <fmt:formatNumber value="${customer.creditLimit}" pattern="#,##0.00" />
                                        </span>
                                    </td>
                                    <td class="text-end pe-4 text-muted">
                                        <c:choose>
                                            <c:when test="${not empty customer.createdAt}">
                                                <fmt:formatDate value="${customer.createdAt}" pattern="MMM dd, yyyy" />
                                            </c:when>
                                            <c:otherwise>
                                                N/A
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="5" class="text-center py-5 text-muted">
                                    <div class="rounded-circle bg-light d-inline-flex align-items-center justify-content-center mb-3" style="width: 64px; height: 64px;">
                                        <i class="fa-solid fa-users text-secondary fs-3"></i>
                                    </div>
                                    <h6 class="fw-medium text-dark">No Customers Found</h6>
                                    <p class="mb-0 small">There are currently no registered customers in the system.</p>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />