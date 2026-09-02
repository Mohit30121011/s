<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/layout/header.jsp" />

<div class="container-fluid mt-4 mb-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2><i class="bi bi-file-earmark-check me-2 text-primary"></i>Compliance & Documentation</h2>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#uploadDocModal"><i class="bi bi-upload"></i> Upload Document</button>
    </div>
    
    <c:if test="${param.success == 'true'}">
        <div class="alert alert-success alert-dismissible fade show">Action completed successfully! <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
    </c:if>
    <c:if test="${param.error == 'true'}">
        <div class="alert alert-danger alert-dismissible fade show">Failed to perform action! <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
    </c:if>

    <div class="card shadow-sm border-0">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>Doc ID</th>
                            <th>Shipment</th>
                            <th>Document Info</th>
                            <th>Dates</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="d" items="${documents}">
                            <tr>
                                <td>#${d.docId}</td>
                                <td>Shipment #${d.shipmentId}</td>
                                <td>
                                    <strong>${d.docType}</strong><br>
                                    <small class="text-muted">${d.docNumber} (${d.issuingAuthority})</small>
                                </td>
                                <td>
                                    <small>Issued: ${d.issueDate}<br>Expiry: <span class="text-danger">${d.expiryDate}</span></small>
                                </td>
                                <td>
                                    <span class="badge ${d.status == 'Approved' ? 'bg-success' : (d.status == 'Rejected' ? 'bg-danger' : 'bg-warning')}">
                                        ${d.status}
                                    </span>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/${d.filePath}" target="_blank" class="btn btn-sm btn-outline-info" title="View File"><i class="bi bi-eye"></i></a>
                                    <c:if test="${d.status == 'Pending'}">
                                        <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#reviewModal${d.docId}"><i class="bi bi-check-circle"></i> Review</button>
                                        
                                        <!-- Review Modal -->
                                        <div class="modal fade" id="reviewModal${d.docId}" tabindex="-1">
                                            <div class="modal-dialog">
                                                <div class="modal-content">
                                                    <form action="${pageContext.request.contextPath}/compliance/review" method="POST">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title">Review Document #${d.docId}</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <input type="hidden" name="docId" value="${d.docId}">
                                                            <p>Reviewing <strong>${d.docType}</strong> for Shipment #${d.shipmentId}</p>
                                                            <div class="mb-3">
                                                                <label class="form-label">Decision</label>
                                                                <select class="form-select" name="status" required>
                                                                    <option value="Approved">Approve</option>
                                                                    <option value="Rejected">Reject</option>
                                                                </select>
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                                            <button type="submit" class="btn btn-primary">Submit Decision</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Upload Document Modal -->
<div class="modal fade" id="uploadDocModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/compliance/upload" method="POST" enctype="multipart/form-data">
                <div class="modal-header">
                    <h5 class="modal-title">Upload Compliance Document</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Shipment</label>
                            <select class="form-select" name="shipmentId" required>
                                <c:forEach var="s" items="${shipments}">
                                    <option value="${s.shipmentId}">Shipment #${s.shipmentId} (Container: ${s.containerNumber})</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Document Type</label>
                            <select class="form-select" name="docType" required>
                                <option>Customs Declaration</option>
                                <option>Import License</option>
                                <option>Export License</option>
                                <option>Certificate of Origin</option>
                                <option>Insurance</option>
                                <option>Inspection</option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Document Number</label>
                            <input type="text" class="form-control" name="docNumber" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Issuing Authority</label>
                            <input type="text" class="form-control" name="issuingAuthority" required>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Issue Date</label>
                            <input type="date" class="form-control" name="issueDate" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Expiry Date</label>
                            <input type="date" class="form-control" name="expiryDate" required>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Document File (PDF/Image)</label>
                        <input type="file" class="form-control" name="docFile">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="bi bi-upload"></i> Upload</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />
