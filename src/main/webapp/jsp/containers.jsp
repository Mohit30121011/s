<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<div class="container-fluid py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="mb-1" style="font-weight: 700; color: #1a1a1a;">Container Master Catalog</h2>
            <p class="text-muted mb-0">Browse and allocate shipping containers</p>
        </div>
        
        <!-- Filter Form -->
        <form action="<c:url value='/containers'/>" method="GET" class="d-flex">
            <select name="status" class="form-select me-2" onchange="this.form.submit()" style="width: 200px; border-radius: 8px;">
                <option value="All" ${statusFilter == 'All' ? 'selected' : ''}>All Statuses</option>
                <option value="Available" ${statusFilter == 'Available' ? 'selected' : ''}>Available</option>
                <option value="Allocated" ${statusFilter == 'Allocated' ? 'selected' : ''}>Allocated</option>
                <option value="In-Transit" ${statusFilter == 'In-Transit' ? 'selected' : ''}>In-Transit</option>
                <option value="Under Maintenance" ${statusFilter == 'Under Maintenance' ? 'selected' : ''}>Under Maintenance</option>
            </select>
            <button class="btn btn-primary" type="button" style="border-radius: 8px;"><i class="fa-solid fa-filter"></i></button>
        </form>
    </div>

    <!-- Container Grid -->
    <div class="row g-4">
        <c:forEach var="container" items="${containers}">
            <div class="col-12 col-md-6 col-lg-4 col-xl-3">
                <div class="card h-100 shadow-sm border-0" style="border-radius: 12px; overflow: hidden; transition: transform 0.2s;">
                    <!-- Container Image Placeholder -->
                    <div style="height: 180px; background-color: #f1f5f9; display: flex; justify-content: center; align-items: center; border-bottom: 1px solid #e2e8f0; position: relative;">
                        <c:choose>
                            <c:when test="${not empty container.imageUrl}">
                                <img src="${container.imageUrl}" alt="Container" style="width: 100%; height: 100%; object-fit: cover;">
                            </c:when>
                            <c:otherwise>
                                <i class="fa-solid fa-box-open" style="font-size: 64px; color: #94a3b8;"></i>
                            </c:otherwise>
                        </c:choose>
                        
                        <!-- Status Badge -->
                        <span class="badge ${container.status == 'Available' ? 'bg-success' : (container.status == 'Allocated' ? 'bg-primary' : (container.status == 'In-Transit' ? 'bg-info text-dark' : 'bg-secondary'))}" 
                              style="position: absolute; top: 12px; right: 12px; font-size: 12px; padding: 6px 10px; border-radius: 6px;">
                            ${container.status}
                        </span>
                    </div>
                    
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="card-title mb-0" style="font-weight: 700; color: #0f172a;">${container.containerNumber}</h5>
                            <span class="badge bg-light text-dark border border-secondary" style="font-size: 13px;">${container.size}</span>
                        </div>
                        
                        <div class="mb-3">
                            <span class="badge" style="background-color: #e0e7ff; color: #4338ca; font-weight: 600; padding: 6px 10px;">
                                <i class="fa-solid fa-truck-container me-1"></i> ${container.type}
                            </span>
                        </div>

                        <ul class="list-unstyled mb-4" style="font-size: 14px; color: #475569;">
                            <li class="mb-2 d-flex justify-content-between">
                                <span><i class="fa-solid fa-weight-hanging me-2 text-muted"></i>Tare Weight</span>
                                <span style="font-weight: 600;"><fmt:formatNumber value="${container.tareWeightKg}" maxFractionDigits="0"/> kg</span>
                            </li>
                            <li class="mb-2 d-flex justify-content-between">
                                <span><i class="fa-solid fa-boxes-stacked me-2 text-muted"></i>Goods Capacity</span>
                                <span style="font-weight: 600;"><fmt:formatNumber value="${container.goodsCapacityKg}" maxFractionDigits="0"/> kg</span>
                            </li>
                            <li class="d-flex justify-content-between">
                                <span><i class="fa-solid fa-cube me-2 text-muted"></i>Volume</span>
                                <span style="font-weight: 600;"><fmt:formatNumber value="${container.goodsCapacityCbm}" maxFractionDigits="2"/> CBM</span>
                            </li>
                        </ul>
                        
                        <!-- Action Button (FR3.3 / FR3.4 Booking entry point) -->
                        <c:choose>
                            <c:when test="${container.status == 'Available'}">
                                <a href="<c:url value='/allocate?containerId=${container.containerId}'/>" class="btn btn-outline-primary w-100" style="border-radius: 8px; font-weight: 600;">
                                    Allocate Container
                                </a>
                            </c:when>
                            <c:otherwise>
                                <button class="btn btn-light w-100 text-muted" style="border-radius: 8px; font-weight: 600;" disabled>
                                    Not Available
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
    
    <!-- Pagination -->
    <c:if test="${totalPages > 1}">
        <nav aria-label="Container pagination" class="mt-5">
            <ul class="pagination justify-content-center">
                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                    <a class="page-link" href="?page=${currentPage - 1}&status=${statusFilter}">Previous</a>
                </li>
                
                <%-- Simple pagination display --%>
                <c:forEach begin="1" end="${totalPages > 10 ? 10 : totalPages}" var="i">
                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                        <a class="page-link" href="?page=${i}&status=${statusFilter}">${i}</a>
                    </li>
                </c:forEach>
                
                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                    <a class="page-link" href="?page=${currentPage + 1}&status=${statusFilter}">Next</a>
                </li>
            </ul>
        </nav>
    </c:if>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />
