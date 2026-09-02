<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Master Data Management - N Logistic</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container-fluid">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">N Logistic</a>
            <div class="collapse navbar-collapse">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/logout">Logout</a></li>
                </ul>
            </div>
        </div>
    </nav>
    <div class="container mt-4">
        <h2>Master Data Management (Admin)</h2>
        <ul class="nav nav-tabs mt-4" id="myTab" role="tablist">
            <li class="nav-item"><a class="nav-link active" id="ports-tab" data-bs-toggle="tab" href="#ports" role="tab">Ports</a></li>
            <li class="nav-item"><a class="nav-link" id="vessels-tab" data-bs-toggle="tab" href="#vessels" role="tab">Vessels</a></li>
            <li class="nav-item"><a class="nav-link" id="companies-tab" data-bs-toggle="tab" href="#companies" role="tab">Companies</a></li>
            <li class="nav-item"><a class="nav-link" id="users-tab" data-bs-toggle="tab" href="#users" role="tab">Users</a></li>
            <li class="nav-item"><a class="nav-link" id="lr-tab" data-bs-toggle="tab" href="#lr" role="tab">Loss Reasons</a></li>
        </ul>
        <div class="tab-content bg-white p-4 border border-top-0" id="myTabContent">
            <!-- Ports Tab -->
            <div class="tab-pane fade show active" id="ports" role="tabpanel">
                <h4>Ports</h4>
                <form action="${pageContext.request.contextPath}/master-data/port/add" method="post" class="row g-3 mb-4">
                    <div class="col-auto"><input type="text" name="name" class="form-control" placeholder="Port Name" required></div>
                    <div class="col-auto"><input type="text" name="code" class="form-control" placeholder="Code" required></div>
                    <div class="col-auto"><input type="text" name="country" class="form-control" placeholder="Country" required></div>
                    <div class="col-auto"><input type="number" step="0.0001" name="lat" class="form-control" placeholder="Lat" required></div>
                    <div class="col-auto"><input type="number" step="0.0001" name="lng" class="form-control" placeholder="Lng" required></div>
                    <div class="col-auto"><button type="submit" class="btn btn-primary">Add Port</button></div>
                </form>
                <table class="table table-bordered">
                    <tr><th>ID</th><th>Name</th><th>Code</th><th>Country</th><th>Action</th></tr>
                    <c:forEach var="p" items="${ports}">
                        <tr>
                            <td>${p.portId}</td><td>${p.portName}</td><td>${p.portCode}</td><td>${p.country}</td>
                            <td>
                                <form action="${pageContext.request.contextPath}/master-data/port/delete" method="post" style="display:inline;">
                                    <input type="hidden" name="id" value="${p.portId}">
                                    <button type="submit" class="btn btn-sm btn-danger">Delete</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </table>
            </div>
            <!-- Vessels Tab -->
            <div class="tab-pane fade" id="vessels" role="tabpanel">
                <h4>Vessels</h4>
                <form action="${pageContext.request.contextPath}/master-data/vessel/add" method="post" class="row g-3 mb-4">
                    <div class="col-auto"><input type="text" name="name" class="form-control" placeholder="Vessel Name" required></div>
                    <div class="col-auto"><input type="text" name="imo" class="form-control" placeholder="IMO Number" required></div>
                    <div class="col-auto"><input type="number" name="capacity" class="form-control" placeholder="Capacity TEU" required></div>
                    <div class="col-auto"><button type="submit" class="btn btn-primary">Add Vessel</button></div>
                </form>
                <table class="table table-bordered">
                    <tr><th>ID</th><th>Name</th><th>IMO</th><th>Capacity</th><th>Action</th></tr>
                    <c:forEach var="v" items="${vessels}">
                        <tr>
                            <td>${v.vesselId}</td><td>${v.vesselName}</td><td>${v.imoNumber}</td><td>${v.capacityTeu}</td>
                            <td>
                                <form action="${pageContext.request.contextPath}/master-data/vessel/delete" method="post" style="display:inline;">
                                    <input type="hidden" name="id" value="${v.vesselId}">
                                    <button type="submit" class="btn btn-sm btn-danger">Delete</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </table>
            </div>
            <!-- Other lists simplified for brevity, just delete buttons -->
            <div class="tab-pane fade" id="companies" role="tabpanel">
                <h4>Companies</h4>
                <table class="table table-bordered">
                    <tr><th>ID</th><th>Name</th><th>License</th><th>Status</th><th>Action</th></tr>
                    <c:forEach var="c" items="${companies}">
                        <tr>
                            <td>${c.companyId}</td><td>${c.companyName}</td><td>${c.licenseNo}</td><td>${c.approvalStatus}</td>
                            <td>
                                <form action="${pageContext.request.contextPath}/master-data/company/delete" method="post" style="display:inline;">
                                    <input type="hidden" name="id" value="${c.companyId}">
                                    <button type="submit" class="btn btn-sm btn-danger">Delete</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </table>
            </div>
            <div class="tab-pane fade" id="users" role="tabpanel">
                <h4>Users</h4>
                <table class="table table-bordered">
                    <tr><th>ID</th><th>Username</th><th>Role</th><th>Status</th><th>Action</th></tr>
                    <c:forEach var="u" items="${users}">
                        <tr>
                            <td>${u.userId}</td><td>${u.username}</td><td>${u.roleId}</td><td>${u.status}</td>
                            <td>
                                <form action="${pageContext.request.contextPath}/master-data/user/delete" method="post" style="display:inline;">
                                    <input type="hidden" name="id" value="${u.userId}">
                                    <button type="submit" class="btn btn-sm btn-danger">Delete</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </table>
            </div>
             <div class="tab-pane fade" id="lr" role="tabpanel">
                <h4>Loss Reasons</h4>
                <form action="${pageContext.request.contextPath}/master-data/lossreason/add" method="post" class="row g-3 mb-4">
                    <div class="col-auto"><input type="text" name="code" class="form-control" placeholder="Code" required></div>
                    <div class="col-auto"><input type="text" name="name" class="form-control" placeholder="Name" required></div>
                    <div class="col-auto"><input type="text" name="desc" class="form-control" placeholder="Desc" required></div>
                    <div class="col-auto"><button type="submit" class="btn btn-primary">Add</button></div>
                </form>
                <table class="table table-bordered">
                    <tr><th>ID</th><th>Code</th><th>Name</th><th>Action</th></tr>
                    <c:forEach var="l" items="${lossReasons}">
                        <tr>
                            <td>${l.reasonId}</td><td>${l.reasonCode}</td><td>${l.reasonName}</td>
                            <td>
                                <form action="${pageContext.request.contextPath}/master-data/lossreason/delete" method="post" style="display:inline;">
                                    <input type="hidden" name="id" value="${l.reasonId}">
                                    <button type="submit" class="btn btn-sm btn-danger">Delete</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </table>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>