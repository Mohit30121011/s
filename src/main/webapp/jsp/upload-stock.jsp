<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
    :root {
        --nlog-orange: #ff6200;
        --nlog-orange-hover: #e65800;
        --nlog-light-orange: #fff0e6;
        --nlog-green: #10b981;
        --nlog-purple: #8b5cf6;
        --nlog-yellow: #f59e0b;
        --card-radius: 12px;
    }

    .page-title { font-weight: 700; color: #1e293b; font-size: 24px; }
    .breadcrumb-text { font-size: 13px; color: #64748b; }

    .stat-card {
        background: #fff;
        border-radius: var(--card-radius);
        padding: 20px;
        display: flex;
        align-items: center;
        border: 1px solid #f1f5f9;
        box-shadow: 0 1px 3px rgba(0,0,0,0.02);
    }
    
    .stat-icon {
        width: 48px;
        height: 48px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        margin-right: 16px;
    }
    .stat-icon.orange { background: var(--nlog-light-orange); color: var(--nlog-orange); }
    .stat-icon.green { background: #ecfdf5; color: var(--nlog-green); }
    .stat-icon.purple { background: #f5f3ff; color: var(--nlog-purple); }
    .stat-icon.yellow { background: #fef3c7; color: var(--nlog-yellow); }

    .stat-value { font-size: 24px; font-weight: 700; color: #0f172a; margin-bottom: 2px; }
    .stat-label { font-size: 13px; color: #64748b; }
    
    .nav-tabs-custom {
        border-bottom: 1px solid #e2e8f0;
        margin-bottom: 24px;
        gap: 30px;
        display: flex;
    }
    .nav-tabs-custom .nav-link {
        color: #64748b;
        font-weight: 600;
        padding: 12px 0;
        border: none;
        background: transparent;
        border-bottom: 3px solid transparent;
        cursor: pointer;
    }
    .nav-tabs-custom .nav-link.active {
        color: var(--nlog-orange);
        border-bottom: 3px solid var(--nlog-orange);
    }

    .btn-nlog {
        background-color: var(--nlog-orange);
        color: white;
        font-weight: 600;
        border: none;
        border-radius: 8px;
        padding: 10px 20px;
    }
    .btn-nlog:hover {
        background-color: var(--nlog-orange-hover);
        color: white;
    }

    .btn-outline-nlog {
        border: 1px solid #cbd5e1;
        color: #475569;
        background: white;
        font-weight: 600;
        border-radius: 8px;
        padding: 10px 20px;
    }
    .btn-outline-nlog:hover { background: #f8fafc; }

    /* Drag & Drop */
    .upload-dropzone {
        border: 2px dashed #cbd5e1;
        border-radius: 12px;
        background-color: #f8fafc;
        padding: 60px 40px;
        text-align: center;
        transition: all 0.3s ease;
        cursor: pointer;
    }
    .upload-dropzone.dragover { border-color: var(--nlog-orange); background-color: var(--nlog-light-orange); }
    .upload-dropzone i { font-size: 48px; color: #94a3b8; margin-bottom: 16px; transition: color 0.3s ease; }
    .upload-dropzone.dragover i { color: var(--nlog-orange); }

    .form-control, .form-select {
        border-color: #e2e8f0;
        padding: 10px 14px;
        border-radius: 8px;
        font-size: 14px;
    }
    .form-control:focus, .form-select:focus {
        border-color: var(--nlog-orange);
        box-shadow: 0 0 0 0.2rem rgba(255, 98, 0, 0.15);
    }
    .form-label { font-size: 13px; font-weight: 600; color: #334155; }
    .required-asterisk { color: var(--nlog-orange); }

    .badge-success { background-color: #ecfdf5; color: #10b981; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600;}
    .badge-failed { background-color: #fef2f2; color: #ef4444; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600;}
</style>

<div class="container-fluid py-4" style="background-color: #fafafa; min-height: 100vh;">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="page-title mb-1">Upload Stock Details</h1>
            <div class="breadcrumb-text">Dashboard &nbsp;>&nbsp; Stock & Inventory &nbsp;>&nbsp; Upload Stock Details</div>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/assets/templates/stock_template.csv" class="btn btn-outline-nlog" download="stock_template.csv">
                <i class="fa-solid fa-download me-2"></i>Download Template
            </a>
            <button class="btn btn-nlog" onclick="switchTab('bulk'); document.getElementById('csvFile').click();">
                <i class="fa-solid fa-cloud-arrow-up me-2"></i>Upload Stock
            </button>
        </div>
    </div>

    <!-- Stat Cards -->
    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon orange"><i class="fa-solid fa-box-open"></i></div>
                <div>
                    <div class="stat-label">Total Products</div>
                    <div class="stat-value">248</div>
                    <div class="stat-label" style="font-size: 11px;">Active Products</div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon green"><i class="fa-solid fa-layer-group"></i></div>
                <div>
                    <div class="stat-label">Total Stock</div>
                    <div class="stat-value">12,850</div>
                    <div class="stat-label" style="font-size: 11px;">CBM in Stock</div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon purple"><i class="fa-solid fa-arrow-up-from-bracket"></i></div>
                <div>
                    <div class="stat-label">Last Upload</div>
                    <div class="stat-value">2,450</div>
                    <div class="stat-label" style="font-size: 11px;">Products Added</div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon yellow"><i class="fa-regular fa-clipboard"></i></div>
                <div>
                    <div class="stat-label">Last Updated</div>
                    <div class="stat-value" style="font-size: 18px; margin-top:6px;">Today, 10:30 AM</div>
                    <div class="stat-label" style="font-size: 11px;">By Super Admin</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Tabs -->
    <div class="nav-tabs-custom">
        <div class="nav-link" onclick="switchTab('manual')" id="tab-manual"><i class="fa-solid fa-plus-square me-2"></i>Manual Entry</div>
        <div class="nav-link active" onclick="switchTab('bulk')" id="tab-bulk"><i class="fa-solid fa-cloud-arrow-up me-2"></i>Bulk Upload</div>
        <div class="nav-link" onclick="switchTab('history')" id="tab-history"><i class="fa-solid fa-clock-rotate-left me-2"></i>Upload History</div>
        <div class="nav-link" onclick="switchTab('overview')" id="tab-overview"><i class="fa-solid fa-chart-simple me-2"></i>Stock Overview</div>
    </div>

    <!-- Alerts -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger shadow-sm border-0 mb-4" style="border-radius: 8px;">
            <i class="fa-solid fa-triangle-exclamation me-2"></i> ${errorMessage}
        </div>
    </c:if>
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success shadow-sm border-0 mb-4" style="border-radius: 8px;">
            <i class="fa-solid fa-circle-check me-2"></i> ${successMessage}
            <c:if test="${not empty errorFilePath}">
                <hr>
                <a href="${pageContext.request.contextPath}/download-errors?file=${errorFilePath}" class="btn btn-sm btn-danger mt-2">
                    <i class="fa-solid fa-download me-1"></i> Download Error Report for Invalid Rows
                </a>
            </c:if>
        </div>
    </c:if>

    <div class="row g-4">
        <!-- Left Area (Forms) -->
        <div class="col-lg-8">
            <div class="card shadow-sm border-0 h-100" style="border-radius: var(--card-radius);">
                
                <!-- Bulk Upload Content (Active by default based on user request) -->
                <div class="card-body p-4 p-lg-5" id="content-bulk">
                    <h5 class="fw-bold mb-1">Bulk Stock Upload</h5>
                    <p class="text-muted small mb-4">Drag and drop your CSV file to upload inventory in bulk.</p>
                    
                    <form action="<c:url value='/upload-stock'/>" method="POST" enctype="multipart/form-data" id="uploadForm">
                        <div class="upload-dropzone mb-4" id="dropzone" onclick="document.getElementById('csvFile').click()">
                            <i class="fa-solid fa-cloud-arrow-up"></i>
                            <h5 class="fw-bold text-dark">Drag & Drop your CSV file here</h5>
                            <p class="text-muted small mb-0">or click to browse from your computer</p>
                            <input type="file" id="csvFile" name="csvFile" accept=".csv" style="display: none;" onchange="handleFileSelect(event)">
                        </div>
                        
                        <div id="fileDisplay" class="alert alert-info d-none d-flex justify-content-between align-items-center" style="border-radius: 8px;">
                            <div><i class="fa-solid fa-file-csv me-2 text-primary fs-4 align-middle"></i> <span id="fileName" class="fw-bold align-middle"></span></div>
                            <button type="button" class="btn-close" onclick="clearFile()"></button>
                        </div>
                        
                        <button type="submit" id="btnUpload" class="btn btn-nlog w-100 py-3 mt-2 fs-6" disabled>
                            Upload & Validate CSV
                        </button>
                    </form>
                </div>

                <!-- Manual Entry Content (Hidden initially) -->
                <div class="card-body p-4 p-lg-5 d-none" id="content-manual">
                    <h5 class="fw-bold mb-1">Manual Stock Entry</h5>
                    <p class="text-muted small mb-4">Add new stock details manually</p>
                    
                    <form action="${pageContext.request.contextPath}/manual-stock" method="POST">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Select Product <span class="required-asterisk">*</span></label>
                                <select class="form-select" name="productId" required>
                                    <option value="">Search and select product</option>
                                    <c:forEach var="prod" items="${productList}">
                                        <option value="${prod.id}">${prod.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Warehouse / Location <span class="required-asterisk">*</span></label>
                                <select class="form-select" name="warehouseLocation" required>
                                    <option value="">Select warehouse / location</option>
                                    <option value="Mumbai WH-1">Mumbai WH-1</option>
                                    <option value="Delhi WH-2">Delhi WH-2</option>
                                    <option value="Bangalore WH-3">Bangalore WH-3</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Quantity <span class="required-asterisk">*</span></label>
                                <input type="number" class="form-control" name="quantity" min="1" step="0.01" placeholder="Enter quantity" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Batch No (Optional)</label>
                                <input type="text" class="form-control" name="batchNo" placeholder="Enter batch number">
                            </div>
                            <div class="col-12">
                                <label class="form-label">Remarks</label>
                                <textarea class="form-control" name="remarks" rows="2" placeholder="Enter any additional remarks (optional)"></textarea>
                            </div>
                        </div>
                        
                        <div class="d-flex justify-content-end gap-3 mt-4">
                            <button type="reset" class="btn btn-outline-nlog px-4">Reset</button>
                            <button type="submit" class="btn btn-nlog px-4"><i class="fa-solid fa-plus me-2"></i>Add to Stock</button>
                        </div>
                    </form>
                </div>

                <!-- Upload History Content (FR4.4) -->
                <div class="card-body p-4 p-lg-5 d-none" id="content-history">
                    <h5 class="fw-bold mb-1">Upload History</h5>
                    <p class="text-muted small mb-4">View the detailed log of all bulk stock uploads</p>
                    
                    <div class="table-responsive">
                        <table class="table align-middle text-nowrap mb-0" style="font-size: 14px;">
                            <thead class="text-muted" style="background-color: #f8fafc;">
                                <tr>
                                    <th class="fw-normal border-0 rounded-start">Date & Time</th>
                                    <th class="fw-normal border-0">File Name</th>
                                    <th class="fw-normal border-0 text-center">Total Rows</th>
                                    <th class="fw-normal border-0 text-center">Status</th>
                                    <th class="fw-normal border-0 rounded-end">Uploaded By</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="hist" items="${fullHistoryList}">
                                    <tr>
                                        <td><fmt:formatDate value="${hist.date}" pattern="dd MMM yyyy, hh:mm a" /></td>
                                        <td><i class="fa-solid fa-file-csv text-primary me-2"></i>${hist.fileName}</td>
                                        <td class="text-center">${hist.total}</td>
                                        <td class="text-center">
                                            <span class="badge-success me-1" title="Success">${hist.success} <i class="fa-solid fa-check"></i></span>
                                            <c:if test="${hist.failed > 0}">
                                                <span class="badge-failed" title="Failed">${hist.failed} <i class="fa-solid fa-xmark"></i></span>
                                            </c:if>
                                        </td>
                                        <td class="text-muted">${hist.user}</td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty fullHistoryList}">
                                    <tr><td colspan="5" class="text-center py-4 text-muted">No upload history available.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Stock Overview Content (FR4.6) -->
                <div class="card-body p-4 p-lg-5 d-none" id="content-overview">
                    <h5 class="fw-bold mb-1">Stock Overview & Adjustments</h5>
                    <p class="text-muted small mb-4">View current stock and manually adjust for damages or write-offs</p>
                    
                    <div class="table-responsive">
                        <table class="table align-middle text-nowrap mb-0" style="font-size: 14px;">
                            <thead class="text-muted" style="background-color: #f8fafc;">
                                <tr>
                                    <th class="fw-normal border-0 rounded-start">Product Name</th>
                                    <th class="fw-normal border-0">Warehouse</th>
                                    <th class="fw-normal border-0 text-end">Qty On Hand</th>
                                    <th class="fw-normal border-0 rounded-end text-center">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="stk" items="${stockList}">
                                    <tr>
                                        <td class="fw-bold text-dark">${stk.productName}</td>
                                        <td>${stk.warehouse}</td>
                                        <td class="fw-bold text-end">${stk.quantity}</td>
                                        <td class="text-center">
                                            <button class="btn btn-sm" style="border: 1px solid #ef4444; color: #ef4444; border-radius: 6px;" onclick="openAdjustModal(${stk.stockId}, '${stk.productName}', ${stk.quantity})">
                                                <i class="fa-solid fa-minus-circle me-1"></i> Write-off
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty stockList}">
                                    <tr><td colspan="4" class="text-center py-4 text-muted">No stock available.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </div>

        <!-- Right Sidebar (Recent Uploads) -->
        <div class="col-lg-4">
            <div class="card shadow-sm border-0 h-100" style="border-radius: var(--card-radius);">
                <div class="card-body p-4">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h6 class="fw-bold mb-0">Recent Stock Uploads</h6>
                        <a href="#" class="text-decoration-none small text-muted">View All</a>
                    </div>
                    
                    <div class="table-responsive">
                        <table class="table table-borderless align-middle text-nowrap" style="font-size: 13px;">
                            <thead class="text-muted" style="border-bottom: 1px solid #f1f5f9;">
                                <tr>
                                    <th class="fw-normal pb-2">Date & Time</th>
                                    <th class="fw-normal pb-2">Products</th>
                                    <th class="fw-normal pb-2">Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="upload" items="${recentUploads}">
                                    <tr>
                                        <td class="pt-3">
                                            <fmt:formatDate value="${upload.date}" pattern="dd MMM yyyy, hh:mm a" />
                                        </td>
                                        <td class="pt-3">${upload.success + upload.failed}</td>
                                        <td class="pt-3">
                                            <c:choose>
                                                <c:when test="${upload.failed == 0}">
                                                    <span class="badge-success">Success</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-failed">Failed (${upload.failed})</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty recentUploads}">
                                    <tr>
                                        <td colspan="3" class="text-center pt-4 text-muted small">No recent uploads found.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Low Stock Alerts -->
    <div class="card shadow-sm border-0 mt-4" style="border-radius: var(--card-radius);">
        <div class="card-body p-4">
            <h6 class="fw-bold mb-4 text-danger"><i class="fa-solid fa-triangle-exclamation me-2"></i>Low Stock Alerts</h6>
            <div class="table-responsive">
                <table class="table align-middle text-nowrap mb-0">
                    <thead class="text-muted" style="background-color: #f8fafc;">
                        <tr>
                            <th class="fw-normal border-0 rounded-start">Product Name</th>
                            <th class="fw-normal border-0">HSN Code</th>
                            <th class="fw-normal border-0">Current Stock</th>
                            <th class="fw-normal border-0">Reorder Level</th>
                            <th class="fw-normal border-0">Status</th>
                            <th class="fw-normal border-0 rounded-end">Action</th>
                        </tr>
                    </thead>
                    <tbody style="border-top: none;">
                        <tr>
                            <td class="fw-bold text-dark">Aluminium Rod</td>
                            <td class="text-muted">76042990</td>
                            <td class="fw-bold">45.50</td>
                            <td class="text-muted">50.00</td>
                            <td><span class="badge-failed" style="background:#fff1f2; color:#be123c;">Low Stock</span></td>
                            <td><button class="btn btn-sm" style="border: 1px solid var(--nlog-orange); color: var(--nlog-orange); border-radius: 6px;">Add Stock</button></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Write-off / Adjust Modal -->
<div class="modal fade" id="adjustModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content" style="border-radius: var(--card-radius); border: none;">
      <div class="modal-header border-0 pb-0">
        <h5 class="modal-title fw-bold text-danger"><i class="fa-solid fa-triangle-exclamation me-2"></i> Stock Write-off</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <form action="${pageContext.request.contextPath}/adjust-stock" method="POST">
          <div class="modal-body pt-3">
              <p class="text-muted small mb-4">Adjust inventory down for <strong id="modalProdName" class="text-dark"></strong>.</p>
              
              <input type="hidden" name="stockId" id="modalStockId">
              
              <div class="mb-3">
                  <label class="form-label">Current Quantity</label>
                  <input type="text" class="form-control bg-light" id="modalMaxQty" readonly>
              </div>
              
              <div class="mb-3">
                  <label class="form-label">Quantity to Remove <span class="required-asterisk">*</span></label>
                  <input type="number" class="form-control" name="adjustmentQuantity" id="adjustmentQuantity" min="0.01" step="0.01" required>
              </div>
              
              <div class="mb-3">
                  <label class="form-label">Reason for Write-off <span class="required-asterisk">*</span></label>
                  <select class="form-select" name="reason" required>
                      <option value="">Select Reason</option>
                      <option value="Damage">Damage</option>
                      <option value="Expiry">Expiry</option>
                      <option value="Lost">Lost</option>
                  </select>
              </div>
          </div>
          <div class="modal-footer border-0 pt-0">
            <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
            <button type="submit" class="btn btn-danger px-4">Confirm Write-off</button>
          </div>
      </form>
    </div>
  </div>
</div>

<script>
    // Tab Switching
    function switchTab(tabName) {
        document.querySelectorAll('.nav-link').forEach(el => el.classList.remove('active'));
        document.getElementById('tab-' + tabName).classList.add('active');
        
        document.getElementById('content-manual').classList.add('d-none');
        document.getElementById('content-bulk').classList.add('d-none');
        document.getElementById('content-overview').classList.add('d-none');
        document.getElementById('content-history').classList.add('d-none');
        
        if (tabName === 'manual') document.getElementById('content-manual').classList.remove('d-none');
        if (tabName === 'bulk') document.getElementById('content-bulk').classList.remove('d-none');
        if (tabName === 'overview') document.getElementById('content-overview').classList.remove('d-none');
        if (tabName === 'history') document.getElementById('content-history').classList.remove('d-none');
    }

    // Modal Logic
    function openAdjustModal(stockId, productName, maxQty) {
        document.getElementById('modalStockId').value = stockId;
        document.getElementById('modalProdName').innerText = productName;
        document.getElementById('modalMaxQty').value = maxQty;
        document.getElementById('adjustmentQuantity').max = maxQty;
        
        new bootstrap.Modal(document.getElementById('adjustModal')).show();
    }

    // Drag and Drop Logic
    const dropzone = document.getElementById('dropzone');
    const fileInput = document.getElementById('csvFile');
    const fileDisplay = document.getElementById('fileDisplay');
    const fileNameSpan = document.getElementById('fileName');
    const btnUpload = document.getElementById('btnUpload');

    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        dropzone.addEventListener(eventName, preventDefaults, false);
    });

    function preventDefaults(e) { e.preventDefault(); e.stopPropagation(); }

    ['dragenter', 'dragover'].forEach(eventName => {
        dropzone.addEventListener(eventName, () => dropzone.classList.add('dragover'), false);
    });

    ['dragleave', 'drop'].forEach(eventName => {
        dropzone.addEventListener(eventName, () => dropzone.classList.remove('dragover'), false);
    });

    dropzone.addEventListener('drop', function(e) {
        let dt = e.dataTransfer;
        let files = dt.files;
        if (files.length > 0 && files[0].name.endsWith('.csv')) {
            fileInput.files = files;
            updateFileDisplay(files[0].name);
        } else {
            alert("Please upload a valid .csv file.");
        }
    }, false);

    function handleFileSelect(e) {
        if (e.target.files.length > 0) updateFileDisplay(e.target.files[0].name);
    }

    function updateFileDisplay(name) {
        fileNameSpan.textContent = name;
        dropzone.classList.add('d-none');
        fileDisplay.classList.remove('d-none');
        btnUpload.disabled = false;
    }

    function clearFile() {
        fileInput.value = '';
        fileNameSpan.textContent = '';
        fileDisplay.classList.add('d-none');
        dropzone.classList.remove('d-none');
        btnUpload.disabled = true;
    }
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
