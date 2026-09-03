<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<jsp:include page="/jsp/layout/header.jsp" />

<!-- Include Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<div class="container-fluid py-4">
	<div class="d-flex justify-content-between align-items-center mb-4">
		<div>
			<h2 class="mb-1" style="font-weight: 800; color: #1a1a1a;">Advance
				Predictive Graph</h2>
			<p class="text-muted">Demand Forecasting & Price Trends</p>   
		</div>

		<!-- Filter Form -->
		<form action="<c:url value='/predictive-graph'/>" method="GET"
			class="d-flex">
			<select name="type" class="form-select me-2"
				onchange="this.form.submit()"
				style="width: 200px; border-radius: 8px;">
				<option value="Dry" ${selectedType == 'Dry' ? 'selected' : ''}>Dry
					Containers</option>
				<option value="Reefer" ${selectedType == 'Reefer' ? 'selected' : ''}>Reefer
					Containers</option>
				<option value="Open Top"
					${selectedType == 'Open Top' ? 'selected' : ''}>Open Top
					Containers</option>
			</select>
			<button class="btn btn-primary" type="button"            
				style="border-radius: 8px;">      						    
				<i class="fa-solid fa-filter"></i>
			</button>
		</form>   
	</div>         			     

	<c:if test="${not empty sessionScope.successMessage}">
		<div class="alert alert-success shadow-sm border-0 mb-4"  
			style="border-radius: 8px;">
			<i class="fa-solid fa-circle-check me-2"></i>
			${sessionScope.successMessage}  
			<c:remove var="successMessage" scope="session" />
		</div>
	</c:if>

	<div class="row g-4 mb-4">
		<div class="col-lg-8">
			<div class="card shadow-sm border-0 h-100"
				style="border-radius: 12px;">
				<div class="card-body p-4">
					<h5 class="fw-bold mb-4">Forecasted Demand & Price Trend (Next
						6 Periods)</h5>
					<div style="height: 400px;">
						<canvas id="predictiveChart"></canvas>
					</div>
				</div>
			</div>
		</div>

		<div class="col-lg-4">
			<div class="card shadow-sm border-0 h-100"
				style="border-radius: 12px;">
				<div class="card-body p-4">
					<h5 class="fw-bold mb-4">Update Base Price</h5>
					<p class="text-muted small mb-4">Every price change shall be
						logged with old value, new value, reason, timestamp and
						responsible user.</p>

					<form action="<c:url value='/predictive-graph'/>" method="POST">
						<input type="hidden" name="pricingId" value="${pricingId}">
						<input type="hidden" name="containerType" value="${selectedType}">

						<div class="mb-3">
							<label class="form-label text-muted fw-bold small">Current
								Base Price ($)</label> <input type="text" class="form-control bg-light"
								value="${currentBasePrice}" readonly
								style="padding: 12px; border-radius: 8px;">
						</div>

						<div class="mb-3">
							<label class="form-label text-muted fw-bold small">New
								Base Price ($)</label> <input type="number" step="0.01" name="newPrice"
								class="form-control" required placeholder="Enter new price"
								style="padding: 12px; border-radius: 8px;">
						</div>

						<div class="mb-4">
							<label class="form-label text-muted fw-bold small">Reason
								for Change</label>
							<textarea name="reason" class="form-control" required rows="3"
								placeholder="e.g. Due to upcoming peak season"
								style="padding: 12px; border-radius: 8px;"></textarea>
						</div>

						<button type="submit" class="btn btn-dark w-100 py-3"
							style="border-radius: 8px; font-weight: 600;">Update
							Price & Log Audit</button>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>

<script>
	document.addEventListener("DOMContentLoaded",
			function() {
				const ctx = document.getElementById('predictiveChart')
						.getContext('2d');

				const labels = $
				{
					chartLabels
				}
				;
				const demandData = $
				{
					chartDemand
				}
				;
				const priceData = $
				{
					chartPrice
				}
				;

				new Chart(ctx, {
					type : 'line',
					data : {
						labels : labels,
						datasets : [ {
							label : 'Forecasted Demand (Units)',
							data : demandData,
							borderColor : '#4338ca',
							backgroundColor : 'rgba(67, 56, 202, 0.1)',
							borderWidth : 2,
							tension : 0.4,
							yAxisID : 'y'
						}, {
							label : 'Forecasted Price ($)',
							data : priceData,
							borderColor : '#10b981',
							backgroundColor : 'rgba(16, 185, 129, 0.1)',
							borderWidth : 2,
							borderDash : [ 5, 5 ],
							tension : 0.4,
							yAxisID : 'y1'
						} ]
					},
					options : {
						responsive : true,
						maintainAspectRatio : false,
						interaction : {
							mode : 'index',
							intersect : false,
						},
						scales : {
							y : {
								type : 'linear',
								display : true,
								position : 'left',
								title : {
									display : true,
									text : 'Demand'
								}
							},
							y1 : {
								type : 'linear',
								display : true,
								position : 'right',
								title : {
									display : true,
									text : 'Price ($)'   
								},
								grid : {
									drawOnChartArea : false
								}
							}
						}
					}
				});
			});
</script>

<jsp:include page="/jsp/layout/footer.jsp" />
