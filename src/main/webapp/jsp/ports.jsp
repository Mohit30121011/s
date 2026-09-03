<%@ page language="java" contentType="text/html; charset=UTF-8" session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/jsp/layout/header.jsp" />

<style>
.custom-breadcrumb a { color: #6c757d; text-decoration: none; font-size: 14px; }
.custom-breadcrumb a:hover { color: #EA580C; }
.custom-breadcrumb .active { color: #EA580C; font-weight: 500; font-size: 14px; }
.custom-breadcrumb-separator { color: #dee2e6; font-size: 10px; }
</style>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h4 class="mb-0 fw-bold">Ports Directory</h4>
    <div class="d-flex align-items-center gap-3">
        <div class="custom-breadcrumb mb-0">
            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <i class="fa-solid fa-chevron-right custom-breadcrumb-separator mx-2"></i>
            <span class="active">Ports</span>
        </div>
        <button class="btn btn-sm text-white px-3" style="background-color: #EA580C; border-radius: 8px;" data-bs-toggle="modal" data-bs-target="#addPortModal">
            <i class="fa-solid fa-plus me-2"></i> Add Port
        </button>
    </div>
</div>

<c:if test="${not empty sessionScope.successMessage}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="fa-solid fa-circle-check me-2"></i> ${sessionScope.successMessage}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    <c:remove var="successMessage" scope="session"/>
</c:if>

<c:if test="${not empty sessionScope.errorMessage}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="fa-solid fa-circle-exclamation me-2"></i> ${sessionScope.errorMessage}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    <c:remove var="errorMessage" scope="session"/>
</c:if>

<div class="card border-0 shadow-sm rounded-4">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="bg-light text-muted" style="font-size: 13px; text-transform: uppercase;">
                    <tr>
                        <th class="py-3 ps-4 border-0 rounded-start">Port ID</th>
                        <th class="py-3 border-0">Port Name</th>
                        <th class="py-3 border-0">Code</th>
                        <th class="py-3 border-0">Country</th>
                        <th class="py-3 pe-4 border-0 rounded-end text-end">Coordinates (Lat, Lng)</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty ports}">
                            <c:forEach var="port" items="${ports}">
                                <tr>
                                    <td class="ps-4 fw-medium text-muted">PRT-${port.portId}</td>
                                    <td class="fw-bold text-dark">
                                        <div class="d-flex align-items-center">
                                            <div class="rounded-circle bg-light d-flex align-items-center justify-content-center me-3" style="width: 36px; height: 36px;">
                                                <i class="fa-solid fa-anchor text-secondary"></i>
                                            </div>
                                            ${port.portName}
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge bg-light text-dark border px-2 py-1 rounded-3">
                                            <c:out value="${port.portCode}" default="N/A" />
                                        </span>
                                    </td>
                                    <td>
                                        <span class="fw-medium text-secondary">
                                            <i class="fa-solid fa-earth-americas me-1 text-muted"></i>
                                            <c:out value="${port.country}" default="Global" />
                                        </span>
                                    </td>
                                    <td class="text-end pe-4 text-muted small">
                                        <c:choose>
                                            <c:when test="${port.latitude != 0.0 || port.longitude != 0.0}">
                                                <span class="badge bg-light text-secondary border">
                                                    <fmt:formatNumber value="${port.latitude}" pattern="##0.0000" />&deg;, 
                                                    <fmt:formatNumber value="${port.longitude}" pattern="##0.0000" />&deg;
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted fst-italic">Not Set</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="5" class="text-center py-5 text-muted">
                                    <div class="rounded-circle bg-light d-inline-flex align-items-center justify-content-center mb-3" style="width: 64px; height: 64px;">
                                        <i class="fa-solid fa-anchor text-secondary fs-3"></i>
                                    </div>
                                    <h6 class="fw-medium text-dark">No Ports Found</h6>
                                    <p class="mb-0 small">There are currently no ports recorded in the database.</p>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Add Port Modal -->
<div class="modal fade" id="addPortModal" tabindex="-1" aria-labelledby="addPortModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header border-bottom-0 pb-0">
        <h5 class="modal-title fw-bold" id="addPortModalLabel">Add New Port</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <form action="${pageContext.request.contextPath}/ports" method="POST">
          <input type="hidden" name="action" value="add">
          <div class="modal-body">
              <div class="mb-3">
                  <label class="form-label text-muted small fw-medium">Port Name</label>
                  <input type="text" class="form-control" name="portName" required placeholder="e.g. Jawaharlal Nehru Port (JNPT)">
              </div>
              <div class="mb-3">
                  <label class="form-label text-muted small fw-medium">Port Code</label>
                  <input type="text" class="form-control" name="portCode" required placeholder="e.g. INNSA">
              </div>
              <div class="mb-3">
                  <label class="form-label text-muted small fw-medium">Country</label>
                  <input type="text" class="form-control" name="country" required placeholder="e.g. India">
              </div>
              <div class="row">
                  <div class="col-md-6 mb-3">
                      <label class="form-label text-muted small fw-medium">Latitude</label>
                      <input type="number" step="any" class="form-control" name="latitude" placeholder="e.g. 18.949900">
                  </div>
                  <div class="col-md-6 mb-3">
                      <label class="form-label text-muted small fw-medium">Longitude</label>
                      <input type="number" step="any" class="form-control" name="longitude" placeholder="e.g. 72.951200">
                  </div>
              </div>
          </div>
          <div class="modal-footer border-top-0 pt-0">
            <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
            <button type="submit" class="btn text-white px-4" style="background-color: #EA580C;">Save Port</button>
          </div>
      </form>
    </div>
  </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />
