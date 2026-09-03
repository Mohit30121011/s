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
        
        <!-- Filter Form & Actions -->
        <div class="d-flex align-items-center">
            <form action="<c:url value='/containers'/>" method="GET" class="d-flex me-3">
                <select name="status" class="form-select me-2" onchange="this.form.submit()" style="width: 200px; border-radius: 8px;">
                    <option value="All" ${statusFilter == 'All' ? 'selected' : ''}>All Statuses</option>
                    <option value="Available" ${statusFilter == 'Available' ? 'selected' : ''}>Available</option>
                    <option value="Allocated" ${statusFilter == 'Allocated' ? 'selected' : ''}>Allocated</option>
                    <option value="In-Transit" ${statusFilter == 'In-Transit' ? 'selected' : ''}>In-Transit</option>
                    <option value="Under Maintenance" ${statusFilter == 'Under Maintenance' ? 'selected' : ''}>Under Maintenance</option>
                </select>
                <button class="btn btn-primary" type="button" style="border-radius: 8px;"><i class="fa-solid fa-filter"></i></button>
            </form>
            <c:if test="${sessionScope.user.roleId <= 3}">
                <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#addContainerModal" style="border-radius: 8px;">
                    <i class="fa-solid fa-plus me-2"></i>Add Container
                </button>
            </c:if>
        </div>
    </div>

    <!-- Container Grid -->
    <div class="row g-4">
        <c:forEach var="container" items="${containers}">
            <div class="col-12 col-md-6 col-lg-4 col-xl-3">
                <div class="card h-100" style="border-radius: 12px; transition: transform 0.2s;">
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
                        <div class="d-flex justify-content-between gap-2 mt-3">
                            <c:choose>
                                <c:when test="${container.status == 'Available'}">
                                    <a href="<c:url value='/allocate?containerId=${container.containerId}'/>" class="btn btn-outline-primary w-100" style="border-radius: 8px; font-weight: 600;">
                                        Allocate
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <button class="btn btn-light w-100 text-muted" style="border-radius: 8px; font-weight: 600;" disabled>
                                        Not Available
                                    </button>
                                </c:otherwise>
                            </c:choose>
                            <c:if test="${sessionScope.user.roleId <= 3}">
                                <div class="dropdown">
                                    <button class="btn btn-light border dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false" style="border-radius: 8px;">
                                        <i class="fa-solid fa-ellipsis-vertical"></i>
                                    </button>
                                    <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                                        <li><a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#updateContainerModal${container.containerId}"><i class="ti ti-pencil me-2 text-primary"></i>Update</a></li>
                                        <li><hr class="dropdown-divider"></li>
                                        <li><a class="dropdown-item text-danger" href="javascript:void(0)" onclick="if(confirm('Delete Container?')) { document.getElementById('deleteForm${container.containerId}').submit(); }"><i class="ti ti-trash me-2"></i>Delete</a></li>
                                    </ul>
                                </div>
                                <form id="deleteForm${container.containerId}" action="<c:url value='/containers/delete'/>" method="POST" style="display:none;">
                                    <input type="hidden" name="id" value="${container.containerId}">
                                </form>
                                
                                <!-- Update Container Modal -->
                                <div class="modal fade" id="updateContainerModal${container.containerId}" tabindex="-1" aria-hidden="true">
                                    <div class="modal-dialog">
                                        <div class="modal-content" style="border-radius: 12px; border: none;">
                                            <div class="modal-header border-bottom-0">
                                                <h5 class="modal-title fw-bold">Update ${container.containerNumber}</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                            </div>
                                            <form action="<c:url value='/containers/update'/>" method="POST">
                                                <div class="modal-body">
                                                    <input type="hidden" name="containerId" value="${container.containerId}">
                                                    
                                                    <div class="mb-3">
                                                        <label class="form-label text-muted fw-bold">Status</label>
                                                        <select name="status" class="form-select" required>
                                                            <option value="Available" ${container.status == 'Available' ? 'selected' : ''}>Available</option>
                                                            <option value="Under Maintenance" ${container.status == 'Under Maintenance' ? 'selected' : ''}>Under Maintenance</option>
                                                            <option value="In-Transit" ${container.status == 'In-Transit' ? 'selected' : ''}>In-Transit</option>
                                                            <option value="Allocated" ${container.status == 'Allocated' ? 'selected' : ''}>Allocated</option>
                                                        </select>
                                                    </div>
                                                    
                                                    <div class="mb-3">
                                                        <label class="form-label text-muted fw-bold">Current Port</label>
                                                        <select name="portId" class="form-select" required>
                                                            <c:forEach var="port" items="${ports}">
                                                                <option value="${port.portId}" ${container.currentPortId == port.portId ? 'selected' : ''}>${port.portName} (${port.country})</option>
                                                            </c:forEach>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="modal-footer border-top-0 pt-0">
                                                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                                                    <button type="submit" class="btn btn-primary" style="background-color: #1434A4;">Update</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                        </div>
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

<!-- Add Container Modal -->
<div class="modal fade" id="addContainerModal" tabindex="-1" aria-labelledby="addContainerModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content" style="border-radius: 12px; border: none;">
            <div class="modal-header border-bottom-0 pb-0">
                <h5 class="modal-title fw-bold" id="addContainerModalLabel">Add New Container</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="<c:url value='/containers/add'/>" method="POST">
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label text-muted fw-bold" style="font-size: 13px;">Container Number</label>
                            <input type="text" name="containerNumber" class="form-control" required placeholder="e.g. CONT1234567">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-muted fw-bold" style="font-size: 13px;">Current Port</label>
                            <select name="portId" class="form-select" required>
                                <c:forEach var="port" items="${ports}">
                                    <option value="${port.portId}">${port.portName} (${port.country})</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-muted fw-bold" style="font-size: 13px;">Type</label>
                            <select name="type" class="form-select" required>
                                <option value="Dry Van">Dry Van</option>
                                <option value="Reefer">Reefer</option>
                                <option value="Open Top">Open Top</option>
                                <option value="Flat Rack">Flat Rack</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-muted fw-bold" style="font-size: 13px;">Size</label>
                            <select name="size" class="form-select" required>
                                <option value="20ft">20ft</option>
                                <option value="40ft">40ft</option>
                                <option value="45ft">45ft</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label text-muted fw-bold" style="font-size: 13px;">Tare Weight (Kg)</label>
                            <input type="number" step="0.1" name="tareWeightKg" class="form-control" required value="2200">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label text-muted fw-bold" style="font-size: 13px;">Max Gross (Kg)</label>
                            <input type="number" step="0.1" name="maxGrossWeightKg" class="form-control" required value="24000">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label text-muted fw-bold" style="font-size: 13px;">Capacity (Kg)</label>
                            <input type="number" step="0.1" name="goodsCapacityKg" class="form-control" required value="21800">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label text-muted fw-bold" style="font-size: 13px;">Capacity (CBM)</label>
                            <input type="number" step="0.1" name="goodsCapacityCbm" class="form-control" required value="33.2">
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-top-0 pt-0">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-nlog">Add Container</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />
