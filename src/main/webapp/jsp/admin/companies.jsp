<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/jsp/layout/header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-4">
    <h4 class="mb-0 fw-bold">Company Approvals</h4>
    <div class="custom-breadcrumb mb-0">
        <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <i class="fa-solid fa-chevron-right custom-breadcrumb-separator mx-2"></i>
        <span class="active">Company Approvals</span>
    </div>
</div>

<c:if test="${not empty sessionScope.successMessage}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="fa-solid fa-circle-check me-2"></i>${sessionScope.successMessage}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    <c:remove var="successMessage" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.errorMessage}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="fa-solid fa-circle-exclamation me-2"></i>${sessionScope.errorMessage}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    <c:remove var="errorMessage" scope="session"/>
</c:if>

<div class="card border-0 shadow-sm rounded-4">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="bg-light text-muted" style="font-size: 13px; text-transform: uppercase;">
                    <tr>
                        <th class="py-3 ps-4 border-0 rounded-start">Company Name</th>
                        <th class="py-3 border-0">Email</th>
                        <th class="py-3 border-0">Phone</th>
                        <th class="py-3 border-0">GST / PAN</th>
                        <th class="py-3 border-0">Address</th>
                        <th class="py-3 border-0 text-end pe-4 rounded-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty pendingCompanies}">
                            <tr>
                                <td colspan="6" class="text-center py-5 text-muted">
                                    <i class="fa-solid fa-inbox fs-2 mb-3 text-light-gray"></i>
                                    <p class="mb-0">No pending company approvals.</p>
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="company" items="${pendingCompanies}">
                                <tr>
                                    <td class="ps-4 fw-medium text-dark">${company.companyName}</td>
                                    <td>${company.contactEmail}</td>
                                    <td>${company.contactPhone}</td>
                                    <td>
                                        <span class="d-block small text-muted">GST: ${company.gstNo}</span>
                                        <span class="d-block small text-muted">PAN: ${company.licenseNo}</span>
                                    </td>
                                    <td><small class="text-muted">${company.address}</small></td>
                                    <td class="text-end pe-4">
                                        <form action="${pageContext.request.contextPath}/admin/companies" method="POST" class="d-inline">
                                            <input type="hidden" name="companyId" value="${company.companyId}">
                                            <button type="submit" name="action" value="accept" class="btn btn-sm btn-success rounded-circle me-1" title="Accept" style="width: 32px; height: 32px;">
                                                <i class="fa-solid fa-check"></i>
                                            </button>
                                            <button type="submit" name="action" value="reject" class="btn btn-sm btn-danger rounded-circle" title="Reject" style="width: 32px; height: 32px;">
                                                <i class="fa-solid fa-xmark"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />
