<%@ page language="java" contentType="text/html; charset=UTF-8" session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<style>
.custom-breadcrumb a { color: #6c757d; text-decoration: none; font-size: 14px; }
.custom-breadcrumb a:hover { color: #EA580C; }
.custom-breadcrumb .active { color: #EA580C; font-weight: 500; font-size: 14px; }
.custom-breadcrumb-separator { color: #dee2e6; font-size: 10px; }
</style>
<jsp:include page="/jsp/layout/header.jsp" />

<div class="d-flex justify-content-between align-items-center mb-4">
    <h4 class="mb-0 fw-bold">All Vessels</h4>
    <div class="d-flex align-items-center gap-3">
        <div class="custom-breadcrumb mb-0">
            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <i class="fa-solid fa-chevron-right custom-breadcrumb-separator mx-2"></i>
            <span class="active">Vessels</span>
        </div>
        <button class="btn btn-sm text-white px-3" style="background-color: #EA580C; border-radius: 8px;" data-bs-toggle="modal" data-bs-target="#addVesselModal">
            <i class="fa-solid fa-plus me-2"></i> Add Vessel
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

<div class="card border-0 shadow-sm rounded-4">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="bg-light text-muted" style="font-size: 13px; text-transform: uppercase;">
                    <tr>
                        <th class="py-3 ps-4 border-0 rounded-start">ID</th>
                        <th class="py-3 border-0">Vessel Name</th>
                        <th class="py-3 border-0">IMO Number</th>
                        <th class="py-3 pe-4 border-0 rounded-end">Capacity (TEU)</th>
                    </tr>
                </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty vessels}">
                        <c:forEach var="vessel" items="${vessels}">
                            <tr>
                                <td style="padding-left: 24px;">VSL-${vessel.vesselId}</td>
                                <td class="fw-medium text-dark">${vessel.vesselName}</td>
                                <td><span class="badge bg-light text-dark border">${vessel.imoNumber}</span></td>
                                <td>${vessel.capacityTeu} TEU</td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="4" class="text-center py-5 text-muted">
                                <i class="fa-solid fa-ship mb-3" style="font-size: 32px; color: #ddd;"></i>
                                <p class="mb-0">No vessels found in the database.</p>
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
        </div>
    </div>
</div>

<!-- Add Vessel Modal -->
<div class="modal fade" id="addVesselModal" tabindex="-1" aria-labelledby="addVesselModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header border-bottom-0 pb-0">
        <h5 class="modal-title" id="addVesselModalLabel">Add New Vessel</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <form action="${pageContext.request.contextPath}/vessels" method="POST">
          <input type="hidden" name="action" value="add">
          <div class="modal-body">
              <div class="mb-3">
                  <label class="form-label text-muted small fw-medium">Vessel Name</label>
                  <input type="text" class="form-control" name="vesselName" required placeholder="e.g. Ocean Giant">
              </div>
              <div class="mb-3">
                  <label class="form-label text-muted small fw-medium">IMO Number</label>
                  <input type="text" class="form-control" name="imoNumber" required placeholder="e.g. IMO9000001">
              </div>
              <div class="mb-3">
                  <label class="form-label text-muted small fw-medium">Capacity (TEU)</label>
                  <input type="number" class="form-control" name="capacityTeu" required placeholder="e.g. 5000">
              </div>
          </div>
          <div class="modal-footer border-top-0 pt-0">
            <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
            <button type="submit" class="btn btn-orange">Save Vessel</button>
          </div>
      </form>
    </div>
  </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />