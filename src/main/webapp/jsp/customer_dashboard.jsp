<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/jsp/layout/customer_header.jsp" />

<div class="container-fluid p-0">
    <h3 class="fw-bold mb-4">Welcome back, ${sessionScope.username}!</h3>
    <p class="text-muted mb-4">What would you like to do today?</p>
    
    <div class="row g-4">
        <!-- Book Shipment Card -->
        <div class="col-md-6 col-lg-4">
            <div class="card h-100 text-center" style="transition: transform 0.2s;">
                <div class="card-body p-5">
                    <div class="rounded-circle bg-orange bg-opacity-10 d-inline-flex align-items-center justify-content-center mb-4" style="width: 80px; height: 80px; background-color: #FFEDD5;">
                        <i class="fa-solid fa-ship" style="font-size: 32px; color: #FC8019;"></i>
                    </div>
                    <h5 class="fw-bold">Book Shipment</h5>
                    <p class="text-muted mb-4">Create a new shipment request to transport your goods globally.</p>
                    <a href="${pageContext.request.contextPath}/shipments/create" class="btn text-white w-100 rounded-3" style="background-color: #FC8019;">Start Booking</a>
                </div>
            </div>
        </div>
        
        <!-- Book Container Card -->
        <div class="col-md-6 col-lg-4">
            <div class="card h-100 text-center" style="transition: transform 0.2s;">
                <div class="card-body p-5">
                    <div class="rounded-circle bg-primary bg-opacity-10 d-inline-flex align-items-center justify-content-center mb-4" style="width: 80px; height: 80px; background-color: #E0E7FF;">
                        <i class="fa-solid fa-box" style="font-size: 32px; color: #4F46E5;"></i>
                    </div>
                    <h5 class="fw-bold">Book Container</h5>
                    <p class="text-muted mb-4">Reserve empty shipping containers for your upcoming cargo.</p>
                    <a href="${pageContext.request.contextPath}/containers" class="btn text-white w-100 rounded-3" style="background-color: #4F46E5;">Reserve Now</a>
                </div>
            </div>
        </div>
    </div>
</div>

</div> <!-- Close main-content from header -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>