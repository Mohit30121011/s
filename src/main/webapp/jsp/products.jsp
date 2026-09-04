<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* ==========================================================================
       PRODUCT CATALOG THEME (SWIGGY ORANGE ENTERPRISE)
       ========================================================================== */
    .catalog-header {
        display: flex; justify-content: space-between; align-items: flex-end;
        margin-bottom: 24px; flex-wrap: wrap; gap: 16px;
    }
    .catalog-title { font-weight: 700; color: #0F172A; margin-bottom: 4px; font-size: 24px; }
    .catalog-subtitle { color: #94A3B8; margin-bottom: 0; font-size: 13px; }

    .btn-add-container {
        background: #FC8019; color: #FFFFFF !important; border: none; padding: 9px 20px;
        border-radius: 8px; font-weight: 600; font-size: 13.5px; display: inline-flex; align-items: center;
        gap: 8px; cursor: pointer; box-shadow: 0 2px 6px rgba(252, 128, 25, 0.25); transition: all 0.18s ease; text-decoration: none;
    }
    .btn-add-container:hover { background: #E67012; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(252, 128, 25, 0.35); }

    .btn-outline-nl {
        background: #FFFFFF; color: #475569 !important; border: 1px solid #E2E8F0; padding: 9px 20px;
        border-radius: 8px; font-weight: 600; font-size: 13.5px; display: inline-flex; align-items: center;
        gap: 8px; cursor: pointer; transition: all 0.18s ease; text-decoration: none;
    }
    .btn-outline-nl:hover { background: #F8FAFC; border-color: #CBD5E1; color: #0F172A !important; }

    /* KPI Cards */
    .kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 18px; margin-bottom: 24px; }
    @media (max-width: 1024px) { .kpi-grid { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 640px) { .kpi-grid { grid-template-columns: 1fr; } }
    .kpi-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 14px; padding: 18px 20px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.03); display: flex; align-items: center; justify-content: space-between;
        transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
    }
    .kpi-card:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,0,0,0.06); border-color: #CBD5E1; }
    .kpi-label { font-size: 12.5px; font-weight: 600; color: #64748B; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.4px; }
    .kpi-value { font-size: 26px; font-weight: 800; color: #0F172A; line-height: 1; }
    .kpi-icon-pill { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 22px; flex-shrink: 0; }
    .kpi-icon-pill.orange { background: #FFF0E5; color: #FC8019; }
    .kpi-icon-pill.green { background: #ECFDF5; color: #059669; }
    .kpi-icon-pill.blue { background: #EFF6FF; color: #2563EB; }
    .kpi-icon-pill.amber { background: #FFFBEB; color: #D97706; }

    /* Alerts */
    .custom-alert { border-radius: 12px; padding: 14px 18px; font-size: 13.5px; font-weight: 500; display: flex; align-items: center; gap: 10px; margin-bottom: 16px; }
    .custom-alert.success { background: #ECFDF5; border: 1px solid #A7F3D0; color: #065F46; }
    .custom-alert.danger { background: #FEF2F2; border: 1px solid #FECACA; color: #991B1B; }
    .custom-alert.warning { background: #FFFBEB; border: 1px solid #FDE68A; color: #92400E; }
    .custom-alert .alert-close { margin-left: auto; background: none; border: none; color: inherit; opacity: 0.6; cursor: pointer; }
    .custom-alert .alert-close:hover { opacity: 1; }

    /* Filter Bar */
    .filter-bar-card {
        background: #FFFFFF; border-radius: 12px; border: 1px solid #E2E8F0; box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03);
        padding: 14px 18px; margin-bottom: 20px; display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
    }
    .filter-search-box { position: relative; flex: 1; min-width: 240px; }
    .filter-search-box i.search-icon { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #94A3B8; font-size: 15px; pointer-events: none; }
    .filter-search-box input {
        width: 100%; padding: 9px 36px 9px 38px; border: 1px solid #E2E5EA; border-radius: 8px; font-size: 13.5px;
        outline: none; background: #FFFFFF; color: #1E293B; transition: border-color 0.15s ease, box-shadow 0.15s ease;
    }
    .filter-search-box input:focus { border-color: #FC8019; box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12); }

    /* Table */
    .product-table-panel { background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 16px; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04); overflow: hidden; }
    .product-table { width: 100%; border-collapse: collapse; margin: 0; }
    .product-table th { background: #F8FAFC; padding: 14px 20px; font-size: 11.5px; font-weight: 700; color: #64748B; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid #E2E8F0; text-align: left; }
    .product-table th i { margin-right: 4px; color: #94A3B8; font-size: 13px; }
    .product-table td { padding: 14px 20px; border-bottom: 1px solid #F1F5F9; vertical-align: middle; font-size: 13.5px; color: #1E293B; }
    .product-row:hover td { background-color: #FAFAFA; }
    .product-id-chip { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace; font-size: 12px; color: #64748B; font-weight: 600; }
    .category-pill { background: #F1F5F9; color: #475569; border: 1px solid #E2E8F0; font-weight: 600; font-size: 11.5px; padding: 3px 10px; border-radius: 20px; display: inline-flex; align-items: center; gap: 4px; }
    .price-value { font-weight: 700; color: #059669; }

    .actions-flex { display: flex; align-items: center; justify-content: center; gap: 8px; }
    .btn-approval-edit {
        background: #FFFFFF; border: 1.5px solid #BFDBFE; color: #2563EB !important; padding: 6px 14px; border-radius: 50px;
        font-size: 11.5px; font-weight: 600; display: inline-flex; align-items: center; gap: 5px; cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); box-shadow: 0 1px 2px rgba(37, 99, 235, 0.05);
    }
    .btn-approval-edit:hover { background: #EFF6FF; border-color: #3B82F6; color: #1D4ED8 !important; transform: translateY(-1px); box-shadow: 0 4px 10px rgba(37, 99, 235, 0.15); }
    .btn-approval-delete {
        background: #FFFFFF; border: 1.5px solid #FECACA; color: #DC2626 !important; padding: 6px 14px; border-radius: 50px;
        font-size: 11.5px; font-weight: 600; display: inline-flex; align-items: center; gap: 5px; cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); box-shadow: 0 1px 2px rgba(220, 38, 38, 0.05);
    }
    .btn-approval-delete:hover { background: #FEF2F2; border-color: #EF4444; color: #B91C1C !important; transform: translateY(-1px); box-shadow: 0 4px 10px rgba(239, 68, 68, 0.18); }

    /* Select wrapper */
    .select-wrapper { position: relative; width: 100%; }
    .select-wrapper::after {
        content: ''; position: absolute; right: 16px; top: 50%; transform: translateY(-50%); width: 14px; height: 14px;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2364748B' stroke-width='2.2'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E");
        background-size: contain; background-repeat: no-repeat; pointer-events: none;
    }
    .form-select-custom, .select-wrapper select {
        appearance: none; -webkit-appearance: none; width: 100%; height: 42px; padding: 0 38px 0 16px;
        border: 1.5px solid #E2E8F0; border-radius: 8px; font-size: 13px; color: #1E293B; background-color: #FFFFFF; outline: none; transition: all 0.2s ease;
    }
    .form-select-custom:focus, .select-wrapper select:focus { border-color: #FC8019; box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12); }

    /* Modal Customization */
    .modal-content-custom { border-radius: 14px; border: 1px solid #E2E8F0; box-shadow: 0 16px 40px rgba(15, 23, 42, 0.12); overflow: hidden; }
    .modal-header-custom { padding: 20px 24px; border-bottom: 1px solid #F1F3F6; display: flex; align-items: center; justify-content: space-between; }
    .modal-btn-submit {
        background: #FC8019; color: #FFFFFF; border: none; padding: 9px 22px; border-radius: 8px; font-weight: 600;
        font-size: 13.5px; transition: background-color 0.15s ease;
    }
    .modal-btn-submit:hover { background: #E67012; }
    .modal-btn-danger {
        background: #DC2626; color: #FFFFFF; border: none; padding: 9px 22px; border-radius: 8px; font-weight: 600;
        font-size: 13.5px; transition: background-color 0.15s ease;
    }
    .modal-btn-danger:hover { background: #B91C1C; }
    .empty-catalog-box { padding: 60px 24px; text-align: center; }
    .empty-catalog-icon { width: 68px; height: 68px; border-radius: 20px; background: #F1F5F9; color: #94A3B8; font-size: 32px; display: flex; align-items: center; justify-content: center; margin: 0 auto 18px; }
</style>

<div class="container-fluid py-2 mb-5">
    <div class="catalog-header">
        <div>
            <h2 class="catalog-title"><i class="ti ti-package" style="color:#FC8019; margin-right:8px;"></i>Product Catalog</h2>
            <p class="catalog-subtitle">Manage product master data, pricing and HSN classifications</p>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/inventory/stock" class="btn-outline-nl"><i class="ti ti-stack-2"></i> Manage Stock</a>
            <button class="btn-add-container" data-bs-toggle="modal" data-bs-target="#addProductModal" type="button"><i class="ti ti-plus"></i> Add Product</button>
        </div>
    </div>

    <c:if test="${param.success == 'true'}">
        <div class="custom-alert success"><i class="ti ti-circle-check" style="font-size:18px;"></i><span>Product added successfully!</span></div>
    </c:if>
    <c:if test="${param.success == 'updated'}">
        <div class="custom-alert success"><i class="ti ti-circle-check" style="font-size:18px;"></i><span>Product updated successfully!</span></div>
    </c:if>
    <c:if test="${param.success == 'deleted'}">
        <div class="custom-alert success"><i class="ti ti-circle-check" style="font-size:18px;"></i><span>Product deleted successfully!</span></div>
    </c:if>
    <c:if test="${param.error == 'true'}">
        <div class="custom-alert danger"><i class="ti ti-circle-x" style="font-size:18px;"></i><span>Failed to add product!</span></div>
    </c:if>
    <c:if test="${param.error == 'delete_failed'}">
        <div class="custom-alert danger"><i class="ti ti-circle-x" style="font-size:18px;"></i><span>Failed to delete product! (It may be referenced by stock or sales records.)</span></div>
    </c:if>
    <c:if test="${param.error == 'negative_values'}">
        <div class="custom-alert warning"><i class="ti ti-alert-triangle" style="font-size:18px;"></i><span>Unit Cost and Unit Price must not be negative!</span></div>
    </c:if>
    <c:if test="${param.error == 'invalid_input'}">
        <div class="custom-alert danger"><i class="ti ti-circle-x" style="font-size:18px;"></i><span>Invalid input provided. Please check the form and try again.</span></div>
    </c:if>

    <!-- KPI Summary -->
    <c:set var="totalValue" value="${0}"/>
    <c:set var="totalCost" value="${0}"/>
    <c:set var="catList" value=","/>
    <c:set var="catCount" value="${0}"/>
    <c:forEach var="pk" items="${products}">
        <c:set var="totalValue" value="${totalValue + pk.unitPrice}"/>
        <c:set var="totalCost" value="${totalCost + pk.unitCost}"/>
        <c:if test="${not fn:contains(catList, concat(',', concat(pk.category, ',')))}">
            <c:set var="catCount" value="${catCount + 1}"/>
            <c:set var="catList" value="${catList}${pk.category},"/>
        </c:if>
    </c:forEach>
    <div class="kpi-grid">
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Total Products</div>
                <div class="kpi-value">${fn:length(products)}</div>
            </div>
            <div class="kpi-icon-pill orange"><i class="ti ti-package"></i></div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Categories</div>
                <div class="kpi-value" style="color:#2563EB;">${catCount}</div>
            </div>
            <div class="kpi-icon-pill blue"><i class="ti ti-category"></i></div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Catalog Value</div>
                <div class="kpi-value" style="color:#059669;">$<fmt:formatNumber value="${totalValue}" maxFractionDigits="2"/></div>
            </div>
            <div class="kpi-icon-pill green"><i class="ti ti-currency-dollar"></i></div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Total Unit Cost</div>
                <div class="kpi-value" style="color:#D97706;">$<fmt:formatNumber value="${totalCost}" maxFractionDigits="2"/></div>
            </div>
            <div class="kpi-icon-pill amber"><i class="ti ti-receipt"></i></div>
        </div>
    </div>

    <!-- Search Filter -->
    <div class="filter-bar-card">
        <div class="filter-search-box">
            <i class="ti ti-search search-icon"></i>
            <input type="text" id="productSearchInput" placeholder="Search by product name, category, HSN code...">
        </div>
    </div>

    <div class="product-table-panel">
        <div class="table-responsive">
            <table class="product-table" id="productsTable">
                <thead>
                    <tr>
                        <th><i class="ti ti-hash"></i>ID</th>
                        <th><i class="ti ti-tag"></i>Product Name</th>
                        <th><i class="ti ti-category"></i>Category</th>
                        <th><i class="ti ti-file-certificate"></i>HSN Code</th>
                        <th><i class="ti ti-ruler-2"></i>UOM</th>
                        <th><i class="ti ti-coin"></i>Unit Cost</th>
                        <th><i class="ti ti-currency-dollar"></i>Unit Price</th>
                        <th style="text-align:center;"><i class="ti ti-settings"></i>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${products}">
                        <tr class="product-row" data-search="${fn:toLowerCase(p.productName)} ${fn:toLowerCase(p.category)} ${fn:toLowerCase(p.hsnCode)}">
                            <td class="product-id-chip">#${p.productId}</td>
                            <td><strong>${p.productName}</strong></td>
                            <td><span class="category-pill">${p.category}</span></td>
                            <td>${p.hsnCode}</td>
                            <td>${p.unitOfMeasure}</td>
                            <td>$${p.unitCost}</td>
                            <td><strong class="price-value">$${p.unitPrice}</strong></td>
                            <td>
                                <div class="actions-flex">
                                    <button type="button" class="btn-approval-edit btn-edit-product"
                                            data-id="${p.productId}"
                                            data-name="<c:out value='${p.productName}'/>"
                                            data-category="<c:out value='${p.category}'/>"
                                            data-hsn="<c:out value='${p.hsnCode}'/>"
                                            data-uom="<c:out value='${p.unitOfMeasure}'/>"
                                            data-cost="${p.unitCost}"
                                            data-price="${p.unitPrice}"
                                            title="Edit Product">
                                        <i class="ti ti-edit"></i> Edit
                                    </button>
                                    <button type="button" class="btn-approval-delete btn-delete-product"
                                            data-id="${p.productId}"
                                            data-name="<c:out value='${p.productName}'/>"
                                            title="Delete Product">
                                        <i class="ti ti-trash"></i> Delete
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        <c:if test="${empty products}">
            <div class="empty-catalog-box">
                <div class="empty-catalog-icon"><i class="ti ti-package-off"></i></div>
                <h5 style="font-weight:700; color:#1F2937;">No Products Found</h5>
                <p style="color:#94A3B8; font-size:13.5px;">Get started by adding your first product to the catalog.</p>
            </div>
        </c:if>
        <div id="noProductResults" class="empty-catalog-box d-none">
            <div class="empty-catalog-icon"><i class="ti ti-search-off"></i></div>
            <h5 style="font-weight:700; color:#1F2937;">No Matching Products</h5>
            <p style="color:#94A3B8; font-size:13.5px;">No products matching your search criteria.</p>
        </div>
    </div>
</div>

<!-- Add Product Modal -->
<div class="modal fade" id="addProductModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content modal-content-custom">
            <form action="${pageContext.request.contextPath}/inventory/product/add" method="POST">
                <div class="modal-header modal-header-custom">
                    <div class="d-flex align-items-center gap-2">
                        <div style="width: 36px; height: 36px; background: #FFF0E5; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #FC8019; font-size: 18px;">
                            <i class="ti ti-plus"></i>
                        </div>
                        <h5 class="modal-title mb-0" style="font-weight:700; font-size:16px;">Add New Product</h5>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label" style="font-weight:600; font-size:13px;">Product Name</label>
                        <input type="text" class="form-control" name="productName" required style="border-radius:8px; font-size:13.5px;">
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Category</label>
                            <input type="text" class="form-control" name="category" required style="border-radius:8px; font-size:13.5px;">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">HSN Code</label>
                            <input type="text" class="form-control" name="hsnCode" required style="border-radius:8px; font-size:13.5px;">
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">UOM (e.g. box, kg)</label>
                            <input type="text" class="form-control" name="unitOfMeasure" required style="border-radius:8px; font-size:13.5px;">
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Unit Cost ($)</label>
                            <input type="number" step="0.01" class="form-control" name="unitCost" required style="border-radius:8px; font-size:13.5px;">
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Unit Price ($)</label>
                            <input type="number" step="0.01" class="form-control" name="unitPrice" required style="border-radius:8px; font-size:13.5px;">
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-top-0 pt-0 px-4 pb-4">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius:8px; font-weight:500;">Cancel</button>
                    <button type="submit" class="modal-btn-submit">Save Product</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Edit Product Modal -->
<div class="modal fade" id="editProductModal" tabindex="-1" aria-labelledby="editProductModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content modal-content-custom">
            <form action="${pageContext.request.contextPath}/inventory/product/update" method="POST">
                <input type="hidden" name="productId" id="editProductId">
                <div class="modal-header modal-header-custom">
                    <div class="d-flex align-items-center gap-2">
                        <div style="width: 36px; height: 36px; background: #EFF6FF; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #2563EB; font-size: 18px;">
                            <i class="ti ti-edit"></i>
                        </div>
                        <h5 class="modal-title mb-0" id="editProductModalLabel" style="font-weight:700; font-size:16px;">Edit Product</h5>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label" style="font-weight:600; font-size:13px;">Product Name</label>
                        <input type="text" class="form-control" name="productName" id="editProductName" required style="border-radius:8px; font-size:13.5px;">
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Category</label>
                            <input type="text" class="form-control" name="category" id="editCategory" required style="border-radius:8px; font-size:13.5px;">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">HSN Code</label>
                            <input type="text" class="form-control" name="hsnCode" id="editHsnCode" required style="border-radius:8px; font-size:13.5px;">
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">UOM (e.g. box, kg)</label>
                            <input type="text" class="form-control" name="unitOfMeasure" id="editUnitOfMeasure" required style="border-radius:8px; font-size:13.5px;">
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Unit Cost ($)</label>
                            <input type="number" step="0.01" min="0" class="form-control" name="unitCost" id="editUnitCost" required style="border-radius:8px; font-size:13.5px;">
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Unit Price ($)</label>
                            <input type="number" step="0.01" min="0" class="form-control" name="unitPrice" id="editUnitPrice" required style="border-radius:8px; font-size:13.5px;">
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-top-0 pt-0 px-4 pb-4">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius:8px; font-weight:500;">Cancel</button>
                    <button type="submit" class="modal-btn-submit">Update Product</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Delete Product Confirmation Modal -->
<div class="modal fade" id="deleteProductModal" tabindex="-1" aria-labelledby="deleteProductModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content modal-content-custom">
            <form action="${pageContext.request.contextPath}/inventory/product/delete" method="POST">
                <input type="hidden" name="productId" id="deleteProductId">
                <div class="modal-body text-center py-4">
                    <div style="width: 60px; height: 60px; border-radius: 18px; background: #FEF2F2; border: 1px solid #FECACA; color: #DC2626; font-size: 28px; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px;">
                        <i class="ti ti-trash"></i>
                    </div>
                    <p class="mb-1 fs-5" style="font-weight:700; color:#0F172A;" id="deleteProductModalLabel">Delete this product?</p>
                    <p class="text-muted fw-bold mb-0" id="deleteProductNameText"></p>
                    <small class="text-danger mt-2 d-block">This action cannot be undone.</small>
                </div>
                <div class="modal-footer border-top-0 pt-0 px-4 pb-4 justify-content-center">
                    <button type="button" class="btn btn-light px-4" data-bs-dismiss="modal" style="border-radius:8px; font-weight:500;">Cancel</button>
                    <button type="submit" class="modal-btn-danger px-4">Delete Product</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    var editModalEl = document.getElementById('editProductModal');
    var editModal = editModalEl ? new bootstrap.Modal(editModalEl) : null;

    document.querySelectorAll('.btn-edit-product').forEach(function(btn) {
        btn.addEventListener('click', function() {
            document.getElementById('editProductId').value = this.dataset.id;
            document.getElementById('editProductName').value = this.dataset.name;
            document.getElementById('editCategory').value = this.dataset.category;
            document.getElementById('editHsnCode').value = this.dataset.hsn;
            document.getElementById('editUnitOfMeasure').value = this.dataset.uom;
            document.getElementById('editUnitCost').value = this.dataset.cost;
            document.getElementById('editUnitPrice').value = this.dataset.price;
            if (editModal) editModal.show();
        });
    });

    var deleteModalEl = document.getElementById('deleteProductModal');
    var deleteModal = deleteModalEl ? new bootstrap.Modal(deleteModalEl) : null;

    document.querySelectorAll('.btn-delete-product').forEach(function(btn) {
        btn.addEventListener('click', function() {
            document.getElementById('deleteProductId').value = this.dataset.id;
            document.getElementById('deleteProductNameText').textContent = this.dataset.name + ' (#' + this.dataset.id + ')';
            if (deleteModal) deleteModal.show();
        });
    });

    // Live search filter (additive, non-functional cosmetic enhancement)
    var searchInput = document.getElementById('productSearchInput');
    var noResultsEl = document.getElementById('noProductResults');
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            var query = this.value.toLowerCase().trim();
            var rows = document.querySelectorAll('.product-row');
            var visibleCount = 0;
            rows.forEach(function(row) {
                var haystack = row.dataset.search || '';
                var match = !query || haystack.indexOf(query) !== -1;
                row.style.display = match ? '' : 'none';
                if (match) visibleCount++;
            });
            if (noResultsEl) {
                noResultsEl.classList.toggle('d-none', !(query && visibleCount === 0));
            }
        });
    }
});
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
