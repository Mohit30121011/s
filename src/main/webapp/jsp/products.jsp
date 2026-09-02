<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/layout/header.jsp" />

<div class="container-fluid mt-4 mb-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2><i class="bi bi-box me-2 text-primary"></i>Product Catalog</h2>
        <div>
            <a href="${pageContext.request.contextPath}/inventory/stock" class="btn btn-outline-info me-2"><i class="bi bi-boxes"></i> Manage Stock</a>
            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addProductModal"><i class="bi bi-plus-lg"></i> Add Product</button>
        </div>
    </div>
    
    <c:if test="${param.success == 'true'}">
        <div class="alert alert-success alert-dismissible fade show">Product added successfully! <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
    </c:if>
    <c:if test="${param.error == 'true'}">
        <div class="alert alert-danger alert-dismissible fade show">Failed to add product! <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
    </c:if>

    <div class="card shadow-sm border-0">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>Product Name</th>
                            <th>Category</th>
                            <th>HSN Code</th>
                            <th>UOM</th>
                            <th>Unit Cost</th>
                            <th>Unit Price</th><th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${products}">
                            <tr>
                                <td>#${p.productId}</td>
                                <td><strong>${p.productName}</strong></td>
                                <td><span class="badge bg-secondary">${p.category}</span></td>
                                <td>${p.hsnCode}</td>
                                <td>${p.unitOfMeasure}</td>
                                <td>$${p.unitCost}</td>
                                <td><strong class="text-success">$${p.unitPrice}</strong></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Add Product Modal -->
<div class="modal fade" id="addProductModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/inventory/product/add" method="POST">
                <div class="modal-header">
                    <h5 class="modal-title">Add New Product</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Product Name</label>
                        <input type="text" class="form-control" name="productName" required>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Category</label>
                            <input type="text" class="form-control" name="category" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">HSN Code</label>
                            <input type="text" class="form-control" name="hsnCode" required>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label class="form-label">UOM (e.g. box, kg)</label>
                            <input type="text" class="form-control" name="unitOfMeasure" required>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label">Unit Cost ($)</label>
                            <input type="number" step="0.01" class="form-control" name="unitCost" required>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label">Unit Price ($)</label>
                            <input type="number" step="0.01" class="form-control" name="unitPrice" required>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Product</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />
