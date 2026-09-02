<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/layout/header.jsp" />

<div class="container-fluid mt-4 mb-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2><i class="bi bi-box-seam me-2 text-primary"></i>Container Allocation</h2>
        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Back to Dashboard</a>
    </div>
    
    <c:if test="${param.success == 'true'}">
        <div class="alert alert-success alert-dismissible fade show">Container updated successfully! <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
    </c:if>
    <c:if test="${param.error == 'true'}">
        <div class="alert alert-danger alert-dismissible fade show">Failed to update container! <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
    </c:if>

    <div class="card shadow-sm border-0">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>Container Number</th>
                            <th>Type</th>
                            <th>Size</th>
                            <th>Status</th>
                            <th>Current Port</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="c" items="${containers}">
                            <tr>
                                <td><strong>${c.containerNumber}</strong></td>
                                <td>${c.type}</td>
                                <td>${c.size}</td>
                                <td>
                                    <span class="badge ${c.status == 'Available' ? 'bg-success' : (c.status == 'In-Transit' ? 'bg-primary' : 'bg-warning')}">
                                        ${c.status}
                                    </span>
                                </td>
                                <td>${c.imageUrl}</td>
                                <td>
                                    <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#editModal${c.containerId}">
                                        <i class="bi bi-pencil-square"></i> Edit
                                    </button>
                                </td>
                            </tr>
                            
                            <!-- Edit Modal -->
                            <div class="modal fade" id="editModal${c.containerId}" tabindex="-1">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <form action="${pageContext.request.contextPath}/containers/update" method="POST">
                                            <div class="modal-header">
                                                <h5 class="modal-title">Update Container ${c.containerNumber}</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                            </div>
                                            <div class="modal-body">
                                                <input type="hidden" name="containerId" value="${c.containerId}">
                                                
                                                <div class="mb-3">
                                                    <label class="form-label">Status</label>
                                                    <select class="form-select" name="status">
                                                        <option value="Available" ${c.status == 'Available' ? 'selected' : ''}>Available</option>
                                                        <option value="In-Transit" ${c.status == 'In-Transit' ? 'selected' : ''}>In-Transit</option>
                                                        <option value="Under Maintenance" ${c.status == 'Under Maintenance' ? 'selected' : ''}>Under Maintenance</option>
                                                    </select>
                                                </div>
                                                
                                                <div class="mb-3">
                                                    <label class="form-label">Current Port</label>
                                                    <select class="form-select" name="portId">
                                                        <c:forEach var="p" items="${ports}">
                                                            <option value="${p.portId}" ${c.currentPortId == p.portId ? 'selected' : ''}>${p.portName} (${p.country})</option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="modal-footer">
                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                                <button type="submit" class="btn btn-primary">Save changes</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />
