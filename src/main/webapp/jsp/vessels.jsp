<%@ page language="java" contentType="text/html; charset=UTF-8" session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/layout/header.jsp" />

<div class="content-header d-flex justify-content-between align-items-center mb-4">
    <div>
        <h2 class="mb-1">All Vessels</h2>
        <div class="text-muted small">
            <span>Dashboard</span> <i class="fa-solid fa-chevron-right mx-2" style="font-size: 10px;"></i> 
            <span>Vessels</span> <i class="fa-solid fa-chevron-right mx-2" style="font-size: 10px;"></i> 
            <span class="text-orange">All Vessels</span>
        </div>
    </div>
    <button class="btn btn-orange" data-bs-toggle="modal" data-bs-target="#addVesselModal">
        <i class="fa-solid fa-plus me-2"></i> Add Vessel
    </button>
</div>

<c:if test="${not empty sessionScope.successMessage}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="fa-solid fa-circle-check me-2"></i> ${sessionScope.successMessage}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    <c:remove var="successMessage" scope="session"/>
</c:if>

<div class="card card-custom">
    <div class="table-responsive">
        <table class="table mb-0 table-hover align-middle">
            <thead>
                <tr>
                    <th scope="col" style="padding-left: 24px; min-width: 80px;">ID</th>
                    <th scope="col">Vessel Name</th>
                    <th scope="col">IMO Number</th>
                    <th scope="col">Capacity (TEU)</th>
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