<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<%
    // Ensure products list is populated even under direct JSP dispatch
    if (request.getAttribute("products") == null) {
        try {
            com.nlogistic.dao.ProductDAO pDao = new com.nlogistic.dao.ProductDAO();
            request.setAttribute("products", pDao.getAllProducts());
        } catch (Exception ignored) {}
    }

    java.util.List<com.nlogistic.model.Product> prodList = (java.util.List<com.nlogistic.model.Product>) request.getAttribute("products");
    int totalProducts = (prodList != null) ? prodList.size() : 0;
    double totalVal = 0.0;
    double totalCst = 0.0;
    java.util.Set<String> categories = new java.util.TreeSet<String>();
    if (prodList != null) {
        for (com.nlogistic.model.Product p : prodList) {
            totalVal += p.getUnitPrice();
            totalCst += p.getUnitCost();
            if (p.getCategory() != null && !p.getCategory().trim().isEmpty()) {
                categories.add(p.getCategory().trim());
            }
        }
    }
    request.setAttribute("kpiTotalProducts", totalProducts);
    request.setAttribute("kpiTotalCategories", categories.size());
    request.setAttribute("kpiTotalValue", totalVal);
    request.setAttribute("kpiTotalCost", totalCst);
    request.setAttribute("categoriesSet", categories);
%>

<style>
    /* ==========================================================================
       PRODUCT CATALOG THEME (SWIGGY ORANGE ENTERPRISE)
       ========================================================================== */
    .products-container {
        padding: 0 4px 40px;
    }

    /* Breadcrumbs */
    .custom-breadcrumb {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 13px;
        color: #64748B;
        margin-bottom: 16px;
    }
    .custom-breadcrumb a {
        color: #64748B;
        text-decoration: none;
        transition: color 0.15s ease;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
    .custom-breadcrumb a:hover {
        color: #FC8019;
    }
    .custom-breadcrumb .sep {
        color: #CBD5E1;
        font-size: 11px;
    }
    .custom-breadcrumb .current {
        color: #0F172A;
        font-weight: 600;
    }

    /* Catalog Header */
    .catalog-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-end;
        margin-bottom: 24px;
        flex-wrap: wrap;
        gap: 16px;
    }
    .catalog-title {
        font-weight: 800;
        color: #0F172A;
        margin-bottom: 4px;
        font-size: 24px;
        letter-spacing: -0.02em;
    }
    .catalog-subtitle {
        color: #64748B;
        margin-bottom: 0;
        font-size: 13.5px;
    }

    .btn-add-product {
        background: #FC8019;
        color: #FFFFFF !important;
        border: none;
        padding: 10px 20px;
        border-radius: 8px;
        font-weight: 600;
        font-size: 13.5px;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        cursor: pointer;
        box-shadow: 0 2px 8px rgba(252, 128, 25, 0.28);
        transition: all 0.18s ease;
        text-decoration: none;
    }
    .btn-add-product:hover {
        background: #E67012;
        transform: translateY(-1px);
        box-shadow: 0 4px 14px rgba(252, 128, 25, 0.38);
    }

    .btn-outline-nl {
        background: #FFFFFF;
        color: #475569 !important;
        border: 1.5px solid #E2E8F0;
        padding: 9px 20px;
        border-radius: 8px;
        font-weight: 600;
        font-size: 13.5px;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        cursor: pointer;
        transition: all 0.18s ease;
        text-decoration: none;
    }
    .btn-outline-nl:hover {
        background: #F8FAFC;
        border-color: #CBD5E1;
        color: #0F172A !important;
    }

    /* KPI Cards */
    .kpi-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 18px;
        margin-bottom: 24px;
    }
    @media (max-width: 1024px) { .kpi-grid { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 640px) { .kpi-grid { grid-template-columns: 1fr; } }
    .kpi-card {
        background: #FFFFFF;
        border: 1px solid var(--nl-border);
        border-radius: 14px;
        padding: 18px 20px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03);
        display: flex;
        align-items: center;
        justify-content: space-between;
        transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
    }
    .kpi-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(15, 23, 42, 0.06);
        border-color: #CBD5E1;
    }
    .kpi-label {
        font-size: 12px;
        font-weight: 600;
        color: #64748B;
        margin-bottom: 6px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    .kpi-value {
        font-size: 26px;
        font-weight: 800;
        color: #0F172A;
        line-height: 1;
        letter-spacing: -0.02em;
    }
    .kpi-icon-pill {
        width: 46px;
        height: 46px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 22px;
        flex-shrink: 0;
    }
    .kpi-icon-pill.orange { background: #FFF2EB; color: #FC8019; }
    .kpi-icon-pill.green { background: #ECFDF5; color: #059669; }
    .kpi-icon-pill.blue { background: #EFF6FF; color: #2563EB; }
    .kpi-icon-pill.amber { background: #FFFBEB; color: #D97706; }

    /* Alerts */
    .custom-alert {
        border-radius: 12px;
        padding: 14px 18px;
        font-size: 13.5px;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 18px;
    }
    .custom-alert.success { background: #ECFDF5; border: 1px solid #A7F3D0; color: #065F46; }
    .custom-alert.danger { background: #FEF2F2; border: 1px solid #FECACA; color: #991B1B; }
    .custom-alert.warning { background: #FFFBEB; border: 1px solid #FDE68A; color: #92400E; }

    /* Filter Bar Card */
    .filter-bar-card {
        background: #FFFFFF;
        border-radius: 12px;
        border: 1px solid var(--nl-border);
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03);
        padding: 14px 18px;
        margin-bottom: 20px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 14px;
        flex-wrap: wrap;
    }
    .filter-left {
        display: flex;
        align-items: center;
        gap: 12px;
        flex: 1;
        flex-wrap: wrap;
        min-width: 280px;
    }
    .filter-search-box {
        position: relative;
        flex: 1;
        min-width: 240px;
    }
    .filter-search-box i.search-icon {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #94A3B8;
        font-size: 15px;
        pointer-events: none;
    }
    .filter-search-box input {
        width: 100%;
        padding: 9px 36px 9px 38px;
        border: 1px solid #E2E5EA;
        border-radius: 8px;
        font-size: 13.5px;
        outline: none;
        background: #FFFFFF;
        color: #1E293B;
        transition: border-color 0.15s ease, box-shadow 0.15s ease;
    }
    .filter-search-box input:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .search-clear-btn {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        color: #94A3B8;
        cursor: pointer;
        display: none;
        font-size: 14px;
    }
    .search-clear-btn:hover {
        color: #0F172A;
    }
    .filter-category-select {
        min-width: 180px;
        height: 40px;
        border: 1px solid #E2E5EA;
        border-radius: 8px;
        padding: 0 14px;
        font-size: 13.5px;
        color: #1E293B;
        outline: none;
        background-color: #FFFFFF;
    }
    .filter-category-select:focus {
        border-color: #FC8019;
        box-shadow: 0 0 0 3px rgba(252, 128, 25, 0.12);
    }
    .records-count-badge {
        font-size: 12.5px;
        font-weight: 600;
        color: #64748B;
        background: #F8FAFC;
        border: 1px solid #E2E8F0;
        border-radius: 20px;
        padding: 6px 14px;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        white-space: nowrap;
    }

    /* Table Panel */
    .product-table-panel {
        background: #FFFFFF;
        border: 1px solid var(--nl-border);
        border-radius: 16px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04);
        overflow: hidden;
    }
    .product-table {
        width: 100%;
        border-collapse: collapse;
        margin: 0;
    }
    .product-table th {
        background: #F8FAFC;
        padding: 14px 20px;
        font-size: 11.5px;
        font-weight: 700;
        color: #64748B;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border-bottom: 1px solid #E2E8F0;
        text-align: left;
    }
    .product-table th i {
        margin-right: 4px;
        color: #94A3B8;
        font-size: 13px;
    }
    .product-table td {
        padding: 14px 20px;
        border-bottom: 1px solid #F1F5F9;
        vertical-align: middle;
        font-size: 13.5px;
        color: #1E293B;
    }
    .product-row:hover td {
        background-color: #FAFAFA;
    }
    .product-id-chip {
        font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
        font-size: 12.5px;
        color: #64748B;
        font-weight: 700;
    }
    .category-pill {
        background: #F1F5F9;
        color: #475569;
        border: 1px solid #E2E8F0;
        font-weight: 600;
        font-size: 11.5px;
        padding: 4px 10px;
        border-radius: 20px;
        display: inline-flex;
        align-items: center;
        gap: 4px;
    }
    .price-value {
        font-weight: 700;
        color: #059669;
    }
    .cost-value {
        font-weight: 600;
        color: #64748B;
    }

    .actions-flex {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
    }
    .btn-action-edit {
        background: #FFFFFF;
        border: 1.5px solid #BFDBFE;
        color: #2563EB !important;
        padding: 6px 14px;
        border-radius: 50px;
        font-size: 11.5px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        cursor: pointer;
        transition: all 0.18s ease;
        box-shadow: 0 1px 2px rgba(37, 99, 235, 0.05);
    }
    .btn-action-edit:hover {
        background: #EFF6FF;
        border-color: #3B82F6;
        color: #1D4ED8 !important;
        transform: translateY(-1px);
        box-shadow: 0 4px 10px rgba(37, 99, 235, 0.15);
    }
    .btn-action-delete {
        background: #FFFFFF;
        border: 1.5px solid #FECACA;
        color: #DC2626 !important;
        padding: 6px 14px;
        border-radius: 50px;
        font-size: 11.5px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        cursor: pointer;
        transition: all 0.18s ease;
        box-shadow: 0 1px 2px rgba(220, 38, 38, 0.05);
    }
    .btn-action-delete:hover {
        background: #FEF2F2;
        border-color: #EF4444;
        color: #B91C1C !important;
        transform: translateY(-1px);
        box-shadow: 0 4px 10px rgba(239, 68, 68, 0.18);
    }

    /* Custom Pagination */
    .table-pagination-footer {
        padding: 16px 20px;
        background: #FFFFFF;
        border-top: 1px solid #F1F5F9;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 12px;
    }
    .pagination-info {
        font-size: 13px;
        color: #64748B;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .pagination-page-size {
        border: 1px solid #E2E8F0;
        border-radius: 6px;
        padding: 4px 8px;
        font-size: 12px;
        color: #0F172A;
        background: #FFFFFF;
    }
    .pagination-nav {
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .page-btn {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 6px;
        min-width: 32px;
        height: 32px;
        padding: 0 8px;
        font-size: 12.5px;
        font-weight: 600;
        color: #475569;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.15s ease;
    }
    .page-btn:hover:not(.disabled) {
        background: #F8FAFC;
        border-color: #CBD5E1;
        color: #0F172A;
    }
    .page-btn.active {
        background: #FC8019;
        border-color: #FC8019;
        color: #FFFFFF;
        box-shadow: 0 2px 6px rgba(252, 128, 25, 0.3);
    }
    .page-btn.disabled {
        opacity: 0.4;
        cursor: not-allowed;
    }

    /* Modal Customization */
    .modal-content-custom {
        border-radius: 14px;
        border: 1px solid #E2E8F0;
        box-shadow: 0 16px 40px rgba(15, 23, 42, 0.12);
        overflow: hidden;
    }
    .modal-header-custom {
        padding: 20px 24px;
        border-bottom: 1px solid #F1F3F6;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .modal-btn-submit {
        background: #FC8019;
        color: #FFFFFF;
        border: none;
        padding: 10px 24px;
        border-radius: 8px;
        font-weight: 600;
        font-size: 13.5px;
        transition: background-color 0.15s ease;
    }
    .modal-btn-submit:hover { background: #E67012; }
    .modal-btn-danger {
        background: #DC2626;
        color: #FFFFFF;
        border: none;
        padding: 10px 24px;
        border-radius: 8px;
        font-weight: 600;
        font-size: 13.5px;
        transition: background-color 0.15s ease;
    }
    .modal-btn-danger:hover { background: #B91C1C; }
    .empty-catalog-box {
        padding: 60px 24px;
        text-align: center;
    }
    .empty-catalog-icon {
        width: 68px;
        height: 68px;
        border-radius: 20px;
        background: #F1F5F9;
        color: #94A3B8;
        font-size: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 18px;
    }
</style>

<div class="container-fluid products-container">
    <!-- Breadcrumb -->
    <div class="custom-breadcrumb">
        <a href="${pageContext.request.contextPath}/inventory/products"><i class="ti ti-packages"></i> Stock &amp; Inventory</a>
        <span class="sep"><i class="ti ti-chevron-right"></i></span>
        <span class="current">Product Catalog</span>
    </div>

    <!-- Catalog Header -->
    <div class="catalog-header">
        <div>
            <h2 class="catalog-title"><i class="ti ti-package" style="color:#FC8019; margin-right:8px;"></i>Product Catalog</h2>
            <p class="catalog-subtitle">Manage product master data, pricing, inventory valuation, and HSN classifications</p>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/inventory/stock" class="btn-outline-nl"><i class="ti ti-stack-2"></i> Manage Stock</a>
            <button class="btn-add-product" data-bs-toggle="modal" data-bs-target="#addProductModal" type="button"><i class="ti ti-plus"></i> Add Product</button>
        </div>
    </div>

    <!-- Feedback Alerts -->
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

    <!-- KPI Summary Grid -->
    <div class="kpi-grid">
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Total Products</div>
                <div class="kpi-value">${kpiTotalProducts}</div>
            </div>
            <div class="kpi-icon-pill orange"><i class="ti ti-package"></i></div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Categories</div>
                <div class="kpi-value" style="color:#2563EB;">${kpiTotalCategories}</div>
            </div>
            <div class="kpi-icon-pill blue"><i class="ti ti-category"></i></div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Catalog Price Value</div>
                <div class="kpi-value" style="color:#059669;">$<fmt:formatNumber value="${kpiTotalValue}" maxFractionDigits="2"/></div>
            </div>
            <div class="kpi-icon-pill green"><i class="ti ti-currency-dollar"></i></div>
        </div>
        <div class="kpi-card">
            <div>
                <div class="kpi-label">Total Unit Cost</div>
                <div class="kpi-value" style="color:#D97706;">$<fmt:formatNumber value="${kpiTotalCost}" maxFractionDigits="2"/></div>
            </div>
            <div class="kpi-icon-pill amber"><i class="ti ti-receipt"></i></div>
        </div>
    </div>

    <!-- Search & Category Filter Bar -->
    <div class="filter-bar-card">
        <div class="filter-left">
            <div class="filter-search-box">
                <i class="ti ti-search search-icon"></i>
                <input type="text" id="productSearchInput" placeholder="Search product name, category, HSN code...">
                <button type="button" id="clearProductSearchBtn" class="search-clear-btn" title="Clear Search">&times;</button>
            </div>
            <select id="categoryFilterSelect" class="filter-category-select">
                <option value="">All Categories (${kpiTotalCategories})</option>
                <c:forEach var="cat" items="${categoriesSet}">
                    <option value="${fn:toLowerCase(cat)}">${cat}</option>
                </c:forEach>
            </select>
        </div>
        <div class="records-count-badge" id="productCountBadge">
            <i class="ti ti-list"></i> Showing ${kpiTotalProducts} of ${kpiTotalProducts} Products
        </div>
    </div>

    <!-- Product Table Panel -->
    <div class="product-table-panel">
        <div class="table-responsive">
            <table class="product-table" id="productsTable">
                <thead>
                    <tr>
                        <th style="width: 100px;"><i class="ti ti-hash"></i>ID</th>
                        <th><i class="ti ti-tag"></i>Product Name</th>
                        <th><i class="ti ti-category"></i>Category</th>
                        <th><i class="ti ti-file-certificate"></i>HSN Code</th>
                        <th><i class="ti ti-ruler-2"></i>UOM</th>
                        <th><i class="ti ti-coin"></i>Unit Cost</th>
                        <th><i class="ti ti-currency-dollar"></i>Unit Price</th>
                        <th style="text-align:center; width: 180px;"><i class="ti ti-settings"></i>Action</th>
                    </tr>
                </thead>
                <tbody id="productsTbody">
                    <c:forEach var="p" items="${products}">
                        <tr class="product-row" 
                            data-search="${fn:toLowerCase(p.productName)} ${fn:toLowerCase(p.category)} ${fn:toLowerCase(p.hsnCode)}"
                            data-category="${fn:toLowerCase(p.category)}">
                            <td class="product-id-chip">#${p.productId}</td>
                            <td><strong style="color: #0F172A;">${p.productName}</strong></td>
                            <td><span class="category-pill"><i class="ti ti-tag" style="font-size: 11px;"></i> ${p.category}</span></td>
                            <td style="font-family: monospace; font-size: 12.5px;">${p.hsnCode}</td>
                            <td><span class="badge bg-light text-secondary border">${p.unitOfMeasure}</span></td>
                            <td class="cost-value">$<fmt:formatNumber value="${p.unitCost}" minFractionDigits="2" maxFractionDigits="2"/></td>
                            <td><strong class="price-value">$<fmt:formatNumber value="${p.unitPrice}" minFractionDigits="2" maxFractionDigits="2"/></strong></td>
                            <td>
                                <div class="actions-flex">
                                    <button type="button" class="btn-action-edit btn-edit-product"
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
                                    <button type="button" class="btn-action-delete btn-delete-product"
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
            <p style="color:#94A3B8; font-size:13.5px;">No products matching your search or category filter criteria.</p>
        </div>

        <!-- Custom Pagination Footer -->
        <div class="table-pagination-footer" id="paginationFooter">
            <div class="pagination-info">
                <span>Showing <strong id="pageStart">1</strong> to <strong id="pageEnd">10</strong> of <strong id="totalRecords">${kpiTotalProducts}</strong> products</span>
                <span class="ms-2">|</span>
                <span class="ms-2">Rows per page:</span>
                <select id="pageSizeSelect" class="pagination-page-size">
                    <option value="10" selected>10</option>
                    <option value="25">25</option>
                    <option value="50">50</option>
                    <option value="100">100</option>
                </select>
            </div>
            <div class="pagination-nav" id="paginationNav"></div>
        </div>
    </div>
</div>

<!-- Add Product Modal -->
<div class="modal fade" id="addProductModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content modal-content-custom">
            <form action="${pageContext.request.contextPath}/inventory/product/add" method="POST">
                <div class="modal-header modal-header-custom">
                    <div class="d-flex align-items-center gap-2">
                        <div style="width: 38px; height: 38px; background: #FFF2EB; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #FC8019; font-size: 20px;">
                            <i class="ti ti-plus"></i>
                        </div>
                        <h5 class="modal-title mb-0" style="font-weight:700; font-size:16px;">Add New Product</h5>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label" style="font-weight:600; font-size:13px;">Product Name <span style="color:#FC8019;">*</span></label>
                        <input type="text" class="form-control" name="productName" required placeholder="e.g. Industrial Ball Bearings" style="border-radius:8px; font-size:13.5px;">
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Category <span style="color:#FC8019;">*</span></label>
                            <input type="text" class="form-control" name="category" required placeholder="e.g. Machinery" style="border-radius:8px; font-size:13.5px;">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">HSN Code <span style="color:#FC8019;">*</span></label>
                            <input type="text" class="form-control" name="hsnCode" required placeholder="e.g. 8482.10" style="border-radius:8px; font-size:13.5px;">
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">UOM <span style="color:#FC8019;">*</span></label>
                            <input type="text" class="form-control" name="unitOfMeasure" required placeholder="box, kg, pcs" style="border-radius:8px; font-size:13.5px;">
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Unit Cost ($) <span style="color:#FC8019;">*</span></label>
                            <input type="number" step="0.01" min="0" class="form-control" name="unitCost" required placeholder="0.00" style="border-radius:8px; font-size:13.5px;">
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Unit Price ($) <span style="color:#FC8019;">*</span></label>
                            <input type="number" step="0.01" min="0" class="form-control" name="unitPrice" required placeholder="0.00" style="border-radius:8px; font-size:13.5px;">
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-top-0 pt-0 px-4 pb-4">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius:8px; font-weight:500;">Cancel</button>
                    <button type="submit" class="modal-btn-submit">Add Product</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Edit Product Modal -->
<div class="modal fade" id="editProductModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content modal-content-custom">
            <form action="${pageContext.request.contextPath}/inventory/product/update" method="POST">
                <input type="hidden" name="productId" id="editProductId">
                <div class="modal-header modal-header-custom">
                    <div class="d-flex align-items-center gap-2">
                        <div style="width: 38px; height: 38px; background: #EFF6FF; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #2563EB; font-size: 20px;">
                            <i class="ti ti-edit"></i>
                        </div>
                        <h5 class="modal-title mb-0" style="font-weight:700; font-size:16px;">Edit Product</h5>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label" style="font-weight:600; font-size:13px;">Product Name <span style="color:#FC8019;">*</span></label>
                        <input type="text" class="form-control" name="productName" id="editProductName" required style="border-radius:8px; font-size:13.5px;">
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Category <span style="color:#FC8019;">*</span></label>
                            <input type="text" class="form-control" name="category" id="editCategory" required style="border-radius:8px; font-size:13.5px;">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">HSN Code <span style="color:#FC8019;">*</span></label>
                            <input type="text" class="form-control" name="hsnCode" id="editHsnCode" required style="border-radius:8px; font-size:13.5px;">
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">UOM <span style="color:#FC8019;">*</span></label>
                            <input type="text" class="form-control" name="unitOfMeasure" id="editUnitOfMeasure" required style="border-radius:8px; font-size:13.5px;">
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Unit Cost ($) <span style="color:#FC8019;">*</span></label>
                            <input type="number" step="0.01" min="0" class="form-control" name="unitCost" id="editUnitCost" required style="border-radius:8px; font-size:13.5px;">
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Unit Price ($) <span style="color:#FC8019;">*</span></label>
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
<div class="modal fade" id="deleteProductModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content modal-content-custom">
            <form action="${pageContext.request.contextPath}/inventory/product/delete" method="POST">
                <input type="hidden" name="productId" id="deleteProductId">
                <div class="modal-body text-center py-4">
                    <div style="width: 60px; height: 60px; border-radius: 18px; background: #FEF2F2; border: 1px solid #FECACA; color: #DC2626; font-size: 28px; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px;">
                        <i class="ti ti-trash"></i>
                    </div>
                    <p class="mb-1 fs-5" style="font-weight:700; color:#0F172A;">Delete this product?</p>
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

<!-- Interactive JS: Edit/Delete modals + Search + Category Filter + Client-side Pagination -->
<script>
document.addEventListener('DOMContentLoaded', function() {
    // 1. Modals setup
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

    // 2. Pagination & Search Logic
    var allRows = Array.from(document.querySelectorAll('#productsTbody .product-row'));
    var filteredRows = allRows.slice();
    var currentPage = 1;
    var pageSize = 10;

    var searchInput = document.getElementById('productSearchInput');
    var clearBtn = document.getElementById('clearProductSearchBtn');
    var categorySelect = document.getElementById('categoryFilterSelect');
    var countBadge = document.getElementById('productCountBadge');
    var noResultsEl = document.getElementById('noProductResults');
    var paginationFooter = document.getElementById('paginationFooter');
    var pageSizeSelect = document.getElementById('pageSizeSelect');

    function applyFilters() {
        var query = searchInput ? searchInput.value.toLowerCase().trim() : '';
        var selectedCat = categorySelect ? categorySelect.value.toLowerCase().trim() : '';

        if (clearBtn) {
            clearBtn.style.display = query ? 'block' : 'none';
        }

        filteredRows = allRows.filter(function(row) {
            var searchTxt = row.dataset.search || '';
            var rowCat = row.dataset.category || '';
            var matchesQuery = !query || searchTxt.indexOf(query) !== -1;
            var matchesCat = !selectedCat || rowCat === selectedCat;
            return matchesQuery && matchesCat;
        });

        currentPage = 1;
        renderTable();
    }

    function renderTable() {
        var total = filteredRows.length;
        var totalPages = Math.ceil(total / pageSize) || 1;
        if (currentPage > totalPages) currentPage = totalPages;

        var startIdx = (currentPage - 1) * pageSize;
        var endIdx = Math.min(startIdx + pageSize, total);

        // Hide all rows first
        allRows.forEach(function(r) { r.style.display = 'none'; });

        // Show current page of filtered rows
        for (var i = startIdx; i < endIdx; i++) {
            filteredRows[i].style.display = '';
        }

        // Update badge & info
        if (countBadge) {
            countBadge.innerHTML = '<i class="ti ti-list"></i> Showing ' + total + ' of ' + allRows.length + ' Products';
        }

        var startEl = document.getElementById('pageStart');
        var endEl = document.getElementById('pageEnd');
        var totalEl = document.getElementById('totalRecords');
        if (startEl) startEl.textContent = total === 0 ? 0 : (startIdx + 1);
        if (endEl) endEl.textContent = endIdx;
        if (totalEl) totalEl.textContent = total;

        // Toggle No Results
        if (noResultsEl) {
            noResultsEl.classList.toggle('d-none', total > 0);
        }
        if (paginationFooter) {
            paginationFooter.style.display = total > 0 ? 'flex' : 'none';
        }

        renderPaginationControls(totalPages);
    }

    function renderPaginationControls(totalPages) {
        var nav = document.getElementById('paginationNav');
        if (!nav) return;
        nav.innerHTML = '';

        if (totalPages <= 1) return;

        // Prev Button
        var prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'page-btn' + (currentPage === 1 ? ' disabled' : '');
        prevBtn.innerHTML = '<i class="ti ti-chevron-left"></i>';
        prevBtn.addEventListener('click', function() {
            if (currentPage > 1) {
                currentPage--;
                renderTable();
            }
        });
        nav.appendChild(prevBtn);

        // Number buttons
        for (var p = 1; p <= totalPages; p++) {
            (function(pageNum) {
                var btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'page-btn' + (pageNum === currentPage ? ' active' : '');
                btn.textContent = pageNum;
                btn.addEventListener('click', function() {
                    currentPage = pageNum;
                    renderTable();
                });
                nav.appendChild(btn);
            })(p);
        }

        // Next Button
        var nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'page-btn' + (currentPage === totalPages ? ' disabled' : '');
        nextBtn.innerHTML = '<i class="ti ti-chevron-right"></i>';
        nextBtn.addEventListener('click', function() {
            if (currentPage < totalPages) {
                currentPage++;
                renderTable();
            }
        });
        nav.appendChild(nextBtn);
    }

    if (searchInput) searchInput.addEventListener('input', applyFilters);
    if (clearBtn) clearBtn.addEventListener('click', function() {
        searchInput.value = '';
        applyFilters();
    });
    if (categorySelect) categorySelect.addEventListener('change', applyFilters);
    if (pageSizeSelect) pageSizeSelect.addEventListener('change', function() {
        pageSize = parseInt(this.value) || 10;
        currentPage = 1;
        renderTable();
    });

    renderTable();
});
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
