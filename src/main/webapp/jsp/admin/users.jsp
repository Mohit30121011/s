<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/jsp/layout/header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-4">
    <h4 class="mb-0 fw-bold">User Approvals</h4>
    <div class="custom-breadcrumb mb-0">
        <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <i class="fa-solid fa-chevron-right custom-breadcrumb-separator mx-2"></i>
        <span class="active">User Approvals</span>
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

<div class="card">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="bg-light text-muted" style="font-size: 13px; text-transform: uppercase;">
                    <tr>
                        <th class="py-3 ps-4 border-0 rounded-start">Username / Name</th>
                        <th class="py-3 border-0">Email</th>
                        <th class="py-3 border-0">Phone</th>
                        <th class="py-3 border-0">Role</th>
                        <th class="py-3 border-0 text-end pe-4 rounded-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty pendingUsers}">
                            <tr>
                                <td colspan="5" class="text-center py-5 text-muted">
                                    <i class="fa-solid fa-inbox fs-2 mb-3 text-light-gray"></i>
                                    <p class="mb-0">No pending user approvals.</p>
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="u" items="${pendingUsers}">
                                <tr>
                                    <td class="ps-4 fw-medium text-dark">
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="avatar shadow-sm" style="width: 32px; height: 32px; font-size: 12px;">
                                                ${u.username.substring(0, 2).toUpperCase()}
                                            </div>
                                            ${u.username}
                                        </div>
                                    </td>
                                    <td>${u.email}</td>
                                    <td>${u.phone}</td>
                                    <td>
                                        <span class="badge bg-secondary opacity-75 fw-normal rounded-pill px-3">
                                            <c:choose>
                                                <c:when test="${u.roleId == 2}">Company Admin</c:when>
                                                <c:when test="${u.roleId == 5}">Customer</c:when>
                                                <c:otherwise>Role ${u.roleId}</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </td>
                                    <td class="text-end pe-4">
                                        <form action="${pageContext.request.contextPath}/admin/users" method="POST" class="d-inline">
                                            <input type="hidden" name="userId" value="${u.userId}">
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
