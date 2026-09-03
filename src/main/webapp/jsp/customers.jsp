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
    <h4 class="mb-0 fw-bold">Customers Directory</h4>
    <div class="d-flex align-items-center gap-3">
        <div class="custom-breadcrumb mb-0">
            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <i class="fa-solid fa-chevron-right custom-breadcrumb-separator mx-2"></i>
            <span class="active">Customers</span>
        </div>
        <button class="btn btn-sm text-white px-3" style="background-color: #EA580C; border-radius: 8px;" data-bs-toggle="modal" data-bs-target="#addCustomerModal">
            <i class="fa-solid fa-plus me-2"></i> Add Customer
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
                        <th class="py-3 ps-4 border-0 rounded-start">Customer ID</th>
                        <th class="py-3 border-0">Name</th>
                        <th class="py-3 border-0">Address</th>
                        <th class="py-3 border-0">Credit Limit</th>
                        <th class="py-3 pe-4 border-0 rounded-end text-end">Registered Date</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty customers}">
                            <c:forEach var="customer" items="${customers}">
                                <tr>
                                    <td class="ps-4 fw-medium text-muted">#${customer.customerId}</td>
                                    <td class="fw-bold text-dark">
                                        <div class="d-flex align-items-center">
                                            <div class="rounded-circle bg-light d-flex align-items-center justify-content-center me-3" style="width: 36px; height: 36px;">
                                                <i class="fa-solid fa-user text-secondary"></i>
                                            </div>
                                            ${customer.customerName}
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty customer.address}">
                                                ${customer.address}
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted fst-italic">Not Provided</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25 px-2 py-1 rounded-3">
                                            $ <fmt:formatNumber value="${customer.creditLimit}" pattern="#,##0.00" />
                                        </span>
                                    </td>
                                    <td class="text-end pe-4 text-muted">
                                        <c:choose>
                                            <c:when test="${not empty customer.createdAt}">
                                                <fmt:formatDate value="${customer.createdAt}" pattern="MMM dd, yyyy" />
                                            </c:when>
                                            <c:otherwise>
                                                N/A
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
                                        <i class="fa-solid fa-users text-secondary fs-3"></i>
                                    </div>
                                    <h6 class="fw-medium text-dark">No Customers Found</h6>
                                    <p class="mb-0 small">There are currently no registered customers in the system.</p>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>


<!-- Add Customer Modal -->
<div class="modal fade" id="addCustomerModal" tabindex="-1" aria-labelledby="addCustomerModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header border-bottom-0 pb-0">
        <h5 class="modal-title" id="addCustomerModalLabel">Add New Customer</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <form action="${pageContext.request.contextPath}/customers" method="POST">
          <input type="hidden" name="action" value="add">
          <div class="modal-body">
              <div class="mb-3">
                  <label class="form-label text-muted small fw-medium">Customer Name</label>
                  <input type="text" class="form-control" name="customerName" required placeholder="e.g. Acme Corp">
              </div>
              <div class="mb-3">
                  <label class="form-label text-muted small fw-medium">Address</label>
                  <input type="text" class="form-control" name="address" required placeholder="e.g. 123 Logistics Way, NY">
              </div>
              <div class="mb-3">
                  <label class="form-label text-muted small fw-medium">Customer Login Email</label>
                  <input type="email" class="form-control" name="email" required placeholder="e.g. customer@example.com">
              </div>
              <div class="mb-3">
                  <label class="form-label text-muted small fw-medium">Customer Login Password</label>
                  <input type="password" class="form-control" name="password" required placeholder="Enter temporary password">
              </div>
              <div class="mb-3">
                  <label class="form-label text-muted small fw-medium">KYC Document Path</label>
                  <input type="text" class="form-control" name="kycDocPath" placeholder="e.g. /docs/kyc/customer_abc.pdf">
              </div>
              <div class="mb-3">
                  <label class="form-label text-muted small fw-medium">Credit Limit ($)</label>
                  <input type="number" class="form-control" name="creditLimit" required placeholder="e.g. 50000" step="0.01">
              </div>
          </div>
          <div class="modal-footer border-top-0 pt-0">
            <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
            <button type="submit" class="btn text-white" style="background-color: #EA580C;">Save Customer</button>
          </div>
      </form>
    </div>
  </div>
</div>

<jsp:include page="/jsp/layout/footer.jsp" />