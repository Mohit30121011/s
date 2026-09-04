<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    /* ==========================================================================
       STOCK MANAGEMENT & LEDGER THEME (SWIGGY ORANGE ENTERPRISE)
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

    .custom-alert { border-radius: 12px; padding: 14px 18px; font-size: 13.5px; font-weight: 500; display: flex; align-items: center; gap: 10px; margin-bottom: 16px; }
    .custom-alert.success { background: #ECFDF5; border: 1px solid #A7F3D0; color: #065F46; }
    .custom-alert.danger { background: #FEF2F2; border: 1px solid #FECACA; color: #991B1B; }

    .stock-panel {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 16px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04); overflow: hidden; height: 100%;
    }
    .stock-panel-header {
        padding: 16px 22px; border-bottom: 1px solid #F1F5F9; display: flex; align-items: center; gap: 10px;
        background: #F8FAFC;
    }
    .stock-panel-header .panel-icon { width: 34px; height: 34px; border-radius: 9px; display: flex; align-items: center; justify-content: center; font-size: 17px; }
    .stock-panel-header h5 { margin: 0; font-weight: 700; font-size: 15px; color: #0F172A; }

    .stock-table { width: 100%; border-collapse: collapse; margin: 0; }
    .stock-table th { background: #F8FAFC; padding: 12px 18px; font-size: 11px; font-weight: 700; color: #64748B; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid #E2E8F0; text-align: left; }
    .stock-table td { padding: 12px 18px; border-bottom: 1px solid #F1F5F9; vertical-align: middle; font-size: 13px; color: #1E293B; }
    .stock-table tr:hover td { background-color: #FAFAFA; }
    .stock-qty-value { font-weight: 700; color: #FC8019; }

    .btn-approval-delete {
        background: #FFFFFF; border: 1.5px solid #FECACA; color: #DC2626 !important; padding: 6px 14px; border-radius: 50px;
        font-size: 11.5px; font-weight: 600; display: inline-flex; align-items: center; gap: 5px; cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); box-shadow: 0 1px 2px rgba(220, 38, 38, 0.05);
    }
    .btn-approval-delete:hover { background: #FEF2F2; border-color: #EF4444; color: #B91C1C !important; transform: translateY(-1px); box-shadow: 0 4px 10px rgba(239, 68, 68, 0.18); }

    .ledger-type-pill { display: inline-flex; align-items: center; gap: 4px; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 700; }
    .ledger-type-pill.in { background: #ECFDF5; color: #059669; border: 1px solid #A7F3D0; }
    .ledger-type-pill.out { background: #FEF2F2; color: #DC2626; border: 1px solid #FECACA; }
    .ledger-type-pill.adj { background: #FFFBEB; color: #D97706; border: 1px solid #FDE68A; }

    /* Select wrapper (design system) */
    .select-wrapper { position: relative; width: 100%; }
    .select-wrapper::after {
        content: ''; position: absolute; right: 14px; top: 50%; transform: translateY(-50%); width: 14px; height: 14px;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2364748B' stroke-width='2.2'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E");
        background-size: contain; background-repeat: no-repeat; pointer-events: none;
    }
    .select-wrapper select, .form-select-custom { appearance: none; -webkit-appearance: none; padding-right: 38px !important; }

    /* Modal customization */
    .modal-content-custom { border-radius: 14px; border: 1px solid #E2E8F0; box-shadow: 0 16px 40px rgba(15, 23, 42, 0.12); overflow: hidden; }
    .modal-header-custom { padding: 20px 24px; border-bottom: 1px solid #F1F3F6; display: flex; align-items: center; justify-content: space-between; }
    .modal-btn-submit { background: #FC8019; color: #FFFFFF; border: none; padding: 9px 22px; border-radius: 8px; font-weight: 600; font-size: 13.5px; transition: background-color 0.15s ease; }
    .modal-btn-submit:hover { background: #E67012; }
    .modal-btn-danger { background: #DC2626; color: #FFFFFF; border: none; padding: 9px 22px; border-radius: 8px; font-weight: 600; font-size: 13.5px; transition: background-color 0.15s ease; }
    .modal-btn-danger:hover { background: #B91C1C; }
    .empty-stock-box { padding: 40px 24px; text-align: center; }
    .empty-stock-icon { width: 56px; height: 56px; border-radius: 16px; background: #F1F5F9; color: #94A3B8; font-size: 26px; display: flex; align-items: center; justify-content: center; margin: 0 auto 14px; }
</style>

<div class="container-fluid py-2 mb-5">
    <div class="catalog-header">
        <div>
            <h2 class="catalog-title"><i class="ti ti-stack-2" style="color:#FC8019; margin-right:8px;"></i>Stock Management &amp; Ledger</h2>
            <p class="catalog-subtitle">Track current stock levels, adjustments, and inventory movement history</p>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/inventory/products" class="btn-outline-nl"><i class="ti ti-package"></i> Products</a>
            <button class="btn-add-container" data-bs-toggle="modal" data-bs-target="#uploadCsvModal" type="button"><i class="ti ti-cloud-upload"></i> Upload Stock (CSV)</button>
        </div>
    </div>

    <c:if test="${param.success == 'true'}">
        <div class="custom-alert success"><i class="ti ti-circle-check" style="font-size:18px;"></i><span>Stock uploaded/adjusted successfully!</span></div>
    </c:if>
    <c:if test="${param.error == 'true'}">
        <div class="custom-alert danger"><i class="ti ti-circle-x" style="font-size:18px;"></i><span>Failed to process stock!</span></div>
    </c:if>

    <!-- Upload CSV Modal -->
    <div class="modal fade" id="uploadCsvModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content modal-content-custom">
                <form action="${pageContext.request.contextPath}/inventory/stock/upload" method="POST" enctype="multipart/form-data">
                    <div class="modal-header modal-header-custom">
                        <div class="d-flex align-items-center gap-2">
                            <div style="width: 36px; height: 36px; background: #FFF0E5; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #FC8019; font-size: 18px;">
                                <i class="ti ti-cloud-upload"></i>
                            </div>
                            <h5 class="modal-title mb-0" style="font-weight:700; font-size:16px;">Bulk Upload Stock</h5>
                        </div>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <p class="text-muted small mb-3">Upload a CSV file containing: <code>ProductId, WarehouseLocation, Quantity, UnitCost, BatchNo, ExpiryDate</code></p>
                        <div class="mb-3">
                            <label class="form-label" style="font-weight:600; font-size:13px;">Select CSV File</label>
                            <input type="file" class="form-control" name="stockCsv" accept=".csv" required style="border-radius:8px; font-size:13.5px;">
                        </div>
                    </div>
                    <div class="modal-footer border-top-0 pt-0 px-4 pb-4">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius:8px; font-weight:500;">Cancel</button>
                        <button type="submit" class="modal-btn-submit"><i class="ti ti-upload"></i> Upload</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <!-- Current Stock -->
        <div class="col-md-6">
            <div class="stock-panel">
                <div class="stock-panel-header">
                    <div class="panel-icon" style="background:#FFF0E5; color:#FC8019;"><i class="ti ti-layers-intersect"></i></div>
                    <h5>Current Stock Levels</h5>
                </div>
                <div class="table-responsive">
                    <table class="stock-table">
                        <thead>
                            <tr>
                                <th>Product</th>
                                <th>Location</th>
                                <th>Qty On Hand</th>
                                <th style="text-align:center;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="s" items="${stocks}">
                                <tr>
                                    <td><strong>${s.productName}</strong><br><small class="text-muted">Batch: ${s.batchNo}</small></td>
                                    <td>${s.warehouseLocation}</td>
                                    <td><span class="stock-qty-value">${s.quantityOnHand}</span></td>
                                    <td style="text-align:center;">
                                        <button class="btn-approval-delete" type="button" data-bs-toggle="modal" data-bs-target="#adjustModal${s.stockId}">
                                            <i class="ti ti-adjustments"></i> Adjust
                                        </button>
                                    </td>
                                </tr>

                                <!-- Adjust Modal -->
                                <div class="modal fade" id="adjustModal${s.stockId}" tabindex="-1">
                                    <div class="modal-dialog">
                                        <div class="modal-content modal-content-custom">
                                            <form action="${pageContext.request.contextPath}/inventory/stock/adjust" method="POST">
                                                <div class="modal-header modal-header-custom">
                                                    <div class="d-flex align-items-center gap-2">
                                                        <div style="width: 36px; height: 36px; background: #FEF2F2; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #DC2626; font-size: 18px;">
                                                            <i class="ti ti-adjustments"></i>
                                                        </div>
                                                        <h5 class="modal-title mb-0" style="font-weight:700; font-size:16px;">Adjust Stock: ${s.productName}</h5>
                                                    </div>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body p-4">
                                                    <input type="hidden" name="stockId" value="${s.stockId}">
                                                    <input type="hidden" name="productId" value="${s.productId}">
                                                    <p class="mb-3">Current Qty: <strong class="stock-qty-value">${s.quantityOnHand}</strong></p>
                                                    <div class="mb-3">
                                                        <label class="form-label" style="font-weight:600; font-size:13px;">New Total Quantity (after adjustment)</label>
                                                        <input type="number" step="0.01" class="form-control" name="newQty" required style="border-radius:8px; font-size:13.5px;">
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label" style="font-weight:600; font-size:13px;">Reason (Mandatory)</label>
                                                        <input type="text" class="form-control" name="reason" placeholder="e.g. Damage, Audit Discrepancy" required style="border-radius:8px; font-size:13.5px;">
                                                    </div>
                                                </div>
                                                <div class="modal-footer border-top-0 pt-0 px-4 pb-4">
                                                    <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius:8px; font-weight:500;">Cancel</button>
                                                    <button type="submit" class="modal-btn-danger">Confirm Adjustment</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                            <c:if test="${empty stocks}">
                                <tr><td colspan="4">
                                    <div class="empty-stock-box">
                                        <div class="empty-stock-icon"><i class="ti ti-box-off"></i></div>
                                        <p style="color:#94A3B8; font-size:13px; margin:0;">No stock records available.</p>
                                    </div>
                                </td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Inventory Ledger -->
        <div class="col-md-6">
            <div class="stock-panel">
                <div class="stock-panel-header">
                    <div class="panel-icon" style="background:#EFF6FF; color:#2563EB;"><i class="ti ti-notebook"></i></div>
                    <h5>Inventory Ledger</h5>
                </div>
                <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                    <table class="stock-table">
                        <thead style="position: sticky; top: 0; z-index: 1;">
                            <tr>
                                <th>Date</th>
                                <th>Type</th>
                                <th>Product</th>
                                <th>Qty</th>
                                <th>Ref</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="l" items="${ledger}">
                                <tr>
                                    <td>${l.transactionDate}</td>
                                    <td>
                                        <span class="ledger-type-pill ${l.transactionType == 'IN' ? 'in' : (l.transactionType == 'OUT' ? 'out' : 'adj')}">
                                            ${l.transactionType}
                                        </span>
                                    </td>
                                    <td>${l.productName}</td>
                                    <td>${l.quantity}</td>
                                    <td class="text-muted small">${l.referenceType} #${l.referenceId}</td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty ledger}">
                                <tr><td colspan="5">
                                    <div class="empty-stock-box">
                                        <div class="empty-stock-icon"><i class="ti ti-notebook-off"></i></div>
                                        <p style="color:#94A3B8; font-size:13px; margin:0;">No ledger entries available.</p>
                                    </div>
                                </td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />
