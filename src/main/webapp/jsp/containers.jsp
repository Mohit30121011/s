<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />


<style>
:root {
    --primary: #EA580C;
    --primary-light: #FFEDD5;
    --success: #16A34A;
    --success-light: #DCFCE7;
    --info: #2563EB;
    --info-light: #DBEAFE;
    --warning: #D97706;
    --warning-light: #FEF3C7;
    --card: #FFFFFF;
    --border: #E2E8F0;
    --text-main: #0F172A;
    --text-sub: #64748B;
}
.btn-theme {
    background: var(--primary);
    color: #fff;
    border: none;
    padding: 10px 16px;
    border-radius: 8px;
    font-weight: 500;
    font-size: 14px;
    transition: 0.2s;
}
.btn-theme:hover { background: #c2410c; color: #fff; }
.btn-outline-theme {
    background: transparent;
    color: var(--primary);
    border: 1px solid var(--primary);
    padding: 10px 16px;
    border-radius: 8px;
    font-weight: 500;
    font-size: 14px;
    transition: 0.2s;
}
.btn-outline-theme:hover { background: var(--primary); color: #fff; }
.badge-custom {
    padding: 6px 12px;
    border-radius: 20px;
    font-weight: 600;
    font-size: 11px;
}
.bg-available { background: var(--success-light); color: var(--success); }
.bg-allocated { background: var(--primary-light); color: var(--primary); }
.bg-transit { background: var(--info-light); color: var(--info); }
.bg-maint { background: var(--warning-light); color: var(--warning); }
.cont-card {
    border: 1px solid var(--border);
    border-radius: 12px;
    background: var(--card);
    overflow: hidden;
    transition: transform 0.2s, box-shadow 0.2s;
}
.cont-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 25px rgba(0,0,0,0.05);
}
.img-wrap {
    height: 180px;
    background: #F8FAFC;
    display: flex;
    justify-content: center;
    align-items: center;
    border-bottom: 1px solid var(--border);
    position: relative;
}
</style>

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
            <button class="btn-theme" type="button" style="border-radius: 8px;"><i class="fi fi-rr-filter"></i></button>
        </form>
    </div>

    <!-- Container Grid -->
    <div class="row g-4">
        <c:forEach var="container" items="${containers}">
            <div class="col-12 col-md-6 col-lg-4 col-xl-3">
                <div class="cont-card h-100">
                    <!-- Container Image Placeholder -->
                    <div class="img-wrap">
                        <c:choose>
                            <c:when test="${not empty container.imageUrl}">
                                <img src="${container.imageUrl}" alt="Container" style="width: 100%; height: 100%; object-fit: cover;">
                            </c:when>
                            <c:otherwise>
                                <i class="fi fi-rr-box-alt" style="font-size: 64px; color: #CBD5E1;"></i>
                            </c:otherwise>
                        </c:choose>
                        
                        <!-- Status Badge -->
                        <span class="badge ${container.status == 'Available' ? 'bg-available' : (container.status == 'Allocated' ? 'bg-allocated' : (container.status == 'In-Transit' ? 'bg-transit' : 'bg-maint'))}" 
                              class="badge-custom" style="position: absolute; top: 12px; right: 12px;">
                            ${container.status}
                        </span>
                    </div>
                    
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="card-title mb-0" style="font-weight: 700; color: #0f172a;">${container.containerNumber}</h5>
                            <span class="badge-custom bg-light text-dark border" style="font-size: 13px;">${container.size}</span>
                        </div>
                        
                        <div class="mb-3">
                            <span class="badge" class="badge-custom bg-light text-dark border">
                                <i class="fi fi-rr-truck-side me-1"></i> ${container.type}
                            </span>
                        </div>

                        <ul class="list-unstyled mb-4" style="font-size: 14px; color: #475569;">
                            <li class="mb-2 d-flex justify-content-between">
                                <span><i class="fi fi-rr-scale me-2 text-muted"></i>Tare Weight</span>
                                <span style="font-weight: 600;"><fmt:formatNumber value="${container.tareWeightKg}" maxFractionDigits="0"/> kg</span>
                            </li>
                            <li class="mb-2 d-flex justify-content-between">
                                <span><i class="fi fi-rr-boxes me-2 text-muted"></i>Goods Capacity</span>
                                <span style="font-weight: 600;"><fmt:formatNumber value="${container.goodsCapacityKg}" maxFractionDigits="0"/> kg</span>
                            </li>
                            <li class="d-flex justify-content-between">
                                <span><i class="fi fi-rr-box me-2 text-muted"></i>Volume</span>
                                <span style="font-weight: 600;"><fmt:formatNumber value="${container.goodsCapacityCbm}" maxFractionDigits="2"/> CBM</span>
                            </li>
                        </ul>
                        
                        <!-- Action Button (FR3.3 / FR3.4 Booking entry point) -->
                        <c:choose>
                            <c:when test="${container.status == 'Available'}">
                                <a href="<c:url value='/allocate?containerId=${container.containerId}'/>" class="btn-outline-theme w-100">
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
