package com.nlogistic.controller;

import com.nlogistic.dao.*;
import com.nlogistic.model.Container;
import com.nlogistic.model.Shipment;
import com.nlogistic.model.User;
import com.nlogistic.util.DBConnectionManager;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;

@WebServlet("/shipments/*")
public class ShipmentServlet extends HttpServlet {

    /**
     * Shipment movement order. Customs Hold sits alongside In Transit rather than
     * after it, because a hold is something that happens during the voyage.
     */
    private static final java.util.List<String> MOVEMENT_FLOW = java.util.Arrays.asList(
            "Booked", "Container Allocated", "Departed", "In Transit", "Customs Hold", "Arrived", "Delivered");

    private static int movementRank(String status) {
        if (status == null) return -1;
        for (int i = 0; i < MOVEMENT_FLOW.size(); i++) {
            if (MOVEMENT_FLOW.get(i).equalsIgnoreCase(status.trim())) {
                // Customs Hold shares In Transit's position.
                return "Customs Hold".equalsIgnoreCase(MOVEMENT_FLOW.get(i)) ? 3 : i;
            }
        }
        return -1;
    }

    /** True once the cargo is considered to have left, which is what FR5.3 protects. */
    private static boolean isAtOrBeyondDeparture(String status) {
        return movementRank(status) >= movementRank("Departed");
    }

    /**
     * @return null when the move is allowed, otherwise why it is not.
     */
    private String checkMovement(String current, String target) {
        if ("Cancelled".equalsIgnoreCase(target)) return null;
        if ("Cancelled".equalsIgnoreCase(current)) return "This shipment was cancelled; its status can no longer change.";
        if ("Delivered".equalsIgnoreCase(current)) return "This shipment is already delivered; its status can no longer change.";

        int from = movementRank(current), to = movementRank(target);
        if (to < 0) return "Unknown status: " + target;
        if (from >= 0 && to < from) {
            return "A shipment cannot move backwards from '" + current + "' to '" + target + "'.";
        }
        return null;
    }

      															  
    private ShipmentDAO shipmentDAO = new ShipmentDAO();
    private PortDAO portDAO = new PortDAO();      				        
    private VesselDAO vesselDAO = new VesselDAO();         
    private ContainerDAO containerDAO = new ContainerDAO();       
    private CustomerDAO customerDAO = new CustomerDAO(); // Need to fetch customers
    private ComplianceDAO complianceDAO = new ComplianceDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/")) {    
            // List Shipments - RBAC scoped: Customers see only their own bookings,
            // company staff only their tenant's (CLAUDE.md S6.2.2).
            request.setAttribute("shipments", shipmentDAO.getShipmentsForRole(
                    com.nlogistic.util.RbacContext.roleId(request),
                    com.nlogistic.util.RbacContext.companyId(request),
                    com.nlogistic.util.RbacContext.customerId(request)));
            request.getRequestDispatcher("/jsp/shipments.jsp").forward(request, response);
                                } else if (pathInfo.equals("/tracking")) {
            // Live Tracking Dashboard View with REAL DB Data
            List<ShipmentDAO.ShipmentDetail> allShipments = shipmentDAO.getShipmentsForRole(
                    com.nlogistic.util.RbacContext.roleId(request),
                    com.nlogistic.util.RbacContext.companyId(request),
                    com.nlogistic.util.RbacContext.customerId(request));
            request.setAttribute("shipments", allShipments);

            int totalCount = allShipments.size();
            long inTransitCount = allShipments.stream().filter(s -> "In Transit".equalsIgnoreCase(s.getStatus())).count();
            long customsHoldCount = allShipments.stream().filter(s -> "Customs Hold".equalsIgnoreCase(s.getStatus())).count();
            long deliveredCount = allShipments.stream().filter(s -> "Delivered".equalsIgnoreCase(s.getStatus())).count();
            long activeCount = allShipments.stream().filter(s -> !"Delivered".equalsIgnoreCase(s.getStatus()) && !"Cancelled".equalsIgnoreCase(s.getStatus())).count();
            long delayedCount = allShipments.stream().filter(s -> "Delayed".equalsIgnoreCase(s.getStatus())).count();

            request.setAttribute("totalCount", totalCount);
            request.setAttribute("activeCount", activeCount);
            request.setAttribute("inTransitCount", inTransitCount);
            request.setAttribute("customsHoldCount", customsHoldCount);
            request.setAttribute("delayedCount", delayedCount);
            request.setAttribute("vessels", vesselDAO.getAllVessels());

            request.getRequestDispatcher("/jsp/live_tracking_dashboard.jsp").forward(request, response);
                } else if (pathInfo.equals("/tracking/detail")) {
            // Live Tracking Timeline Detail View
            String idParam = request.getParameter("id");
            if (idParam != null && !idParam.trim().isEmpty()) {
                try {
                    int id = idParam.startsWith("SHP-") ? Integer.parseInt(idParam.substring(4).trim()) : Integer.parseInt(idParam.trim());
                    // IDOR guard: refuse a shipment the caller does not own / does not
                    // belong to their tenant, rather than rendering someone else's cargo.
                    if (!shipmentDAO.canAccessShipment(id,
                            com.nlogistic.util.RbacContext.roleId(request),
                            com.nlogistic.util.RbacContext.companyId(request),
                            com.nlogistic.util.RbacContext.customerId(request))) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN,
                                "Access Denied: this shipment does not belong to your account.");
                        return;
                    }
                    request.setAttribute("shipment", shipmentDAO.getShipmentById(id));
                    request.setAttribute("logs", shipmentDAO.getMovementLogs(id));

                    // Official scannable barcode & direct mobile scan URL
                    BarcodeDAO barcodeDAO = new BarcodeDAO();
                    com.nlogistic.model.BarcodeEntry barcode = barcodeDAO.findByEntity("Shipment", id);
                    if (barcode == null) {
                        User caller = com.nlogistic.util.RbacContext.user(request);
                        int genBy = (caller != null) ? caller.getUserId() : 1;
                        com.nlogistic.util.BarcodeAutoGenerator.generateFor(request, "Shipment", id, genBy);
                        barcode = barcodeDAO.findByEntity("Shipment", id);
                    }
                    request.setAttribute("barcode", barcode);
                    String scanUrl = com.nlogistic.util.BarcodeUtil.buildScanUrl(request, barcode != null ? barcode.getBarcodeValue() : ("SHI-" + id));
                    request.setAttribute("scanUrl", scanUrl);
                } catch (NumberFormatException e) {
                    // ignore, let JSP handle null shipment
                }
            }
            request.getRequestDispatcher("/jsp/live_tracking_detail.jsp").forward(request, response);
        } else if (pathInfo.equals("/edit")) {
            int shipmentId = Integer.parseInt(request.getParameter("id"));
            int editRole = com.nlogistic.util.RbacContext.roleId(request);
            if (editRole > 3 || !shipmentDAO.canAccessShipment(shipmentId, editRole,
                    com.nlogistic.util.RbacContext.companyId(request),
                    com.nlogistic.util.RbacContext.customerId(request))) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Access Denied: you may not edit this shipment.");
                return;
            }
            request.setAttribute("shipment", shipmentDAO.getFullShipmentById(shipmentId));
            request.setAttribute("ports", portDAO.getAllPorts());
            request.setAttribute("vessels", vesselDAO.getAllVessels());
            request.setAttribute("containers", containerDAO.getContainers("All", 1000, 0));
            request.setAttribute("customers", customerDAO.getAllCustomers());
            request.getRequestDispatcher("/jsp/edit_shipment.jsp").forward(request, response);
        } else if (pathInfo.equals("/create")) {
            // Show Form
            request.setAttribute("ports", portDAO.getAllPorts());       
            request.setAttribute("vessels", vesselDAO.getAllVessels());
            request.setAttribute("containers", containerDAO.getContainers("Available", 1000, 0));

            // A Customer books only for themselves. Handing them the full customer
            // directory leaked every other client's name AND let them submit a
            // booking under someone else's customer_id (CLAUDE.md S3.5.6).
            int createRole = com.nlogistic.util.RbacContext.roleId(request);
            if (createRole == com.nlogistic.util.RbacContext.CUSTOMER) {
                Integer ownId = com.nlogistic.util.RbacContext.customerId(request);
                com.nlogistic.model.Customer self = (ownId != null) ? customerDAO.getCustomerById(ownId) : null;
                request.setAttribute("customers", self != null
                        ? java.util.Collections.singletonList(self)
                        : java.util.Collections.emptyList());
                request.setAttribute("lockCustomer", Boolean.TRUE);
            } else {
                request.setAttribute("customers", customerDAO.getAllCustomers());
            }
            // Arriving from a catalog card (/containers -> "Book This Container"):
            // carry that container onto the form so it is already selected.
            String preContainer = request.getParameter("containerId");
            if (preContainer != null && !preContainer.trim().isEmpty()) {
                try {
                    int preId = Integer.parseInt(preContainer.trim());
                    com.nlogistic.model.Container picked = containerDAO.getContainerById(preId);
                    // Only honour it if the container is genuinely bookable (FR3.3).
                    if (picked != null && "Available".equalsIgnoreCase(picked.getStatus())) {
                        request.setAttribute("preselectedContainerId", preId);
                        request.setAttribute("preselectedContainer", picked);
                    }
                } catch (NumberFormatException ignored) { /* fall through to empty form */ }
            }

            request.getRequestDispatcher("/jsp/create_shipment.jsp").forward(request, response);
        } else if (pathInfo.equals("/availableContainers")) {
            handleAvailableContainersJson(request, response);
            return;
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession();

        // FR3.4 + FR3.5: quote step. The customer fills the booking form, we verify
        // the cargo fits and price it from the live rate card, then show the
        // breakdown for acceptance. Nothing is written until they confirm.
        if ("/quote".equals(pathInfo)) {
            try {
                int containerId = Integer.parseInt(request.getParameter("containerId"));
                double cargoWeight = Double.parseDouble(request.getParameter("cargoWeight"));
                double cargoVolume = Double.parseDouble(request.getParameter("cargoVolume"));

                com.nlogistic.model.Container container = containerDAO.getContainerById(containerId);

                if (container == null || !"Available".equalsIgnoreCase(container.getStatus())) {
                    session.setAttribute("errorMessage",
                            "That container is no longer available. Please choose another.");
                    response.sendRedirect(request.getContextPath() + "/shipments/create");
                    return;
                }
                // FR3.4 capacity precondition - checked before we quote a price.
                if (cargoWeight > container.getMaxGrossWeightKg() || cargoVolume > container.getGoodsCapacityCbm()) {
                    session.setAttribute("errorMessage",
                            "Cargo exceeds container capacity. Max " + container.getMaxGrossWeightKg()
                          + " kg and " + container.getGoodsCapacityCbm() + " CBM.");
                    response.sendRedirect(request.getContextPath() + "/shipments/create?containerId=" + containerId);
                    return;
                }

                com.nlogistic.model.PricingRule rule =
                        new com.nlogistic.dao.PricingDAO().getPricingRule(container.getType(), container.getSize());
                if (rule == null) {
                    session.setAttribute("errorMessage",
                            "No published rate card covers this container type yet. Please contact support.");
                    response.sendRedirect(request.getContextPath() + "/shipments/create");
                    return;
                }

                request.setAttribute("container", container);
                request.setAttribute("cargoWeight", cargoWeight);
                request.setAttribute("cargoVolume", cargoVolume);
                request.setAttribute("cargoDesc", request.getParameter("cargoDesc"));
                request.setAttribute("origin", request.getParameter("originPortId"));
                request.setAttribute("destination", request.getParameter("destPortId"));
                request.setAttribute("vesselId", request.getParameter("vesselId"));
                request.setAttribute("cargoValue", request.getParameter("cargoValue"));
                request.setAttribute("pricingRule", rule);
                request.setAttribute("finalPrice", rule.calculateFinalPrice());

                try {
                    String o = request.getParameter("originPortId");
                    String d = request.getParameter("destPortId");
                    if (o != null && !o.isEmpty()) request.setAttribute("originPort", portDAO.getPortById(Integer.parseInt(o)));
                    if (d != null && !d.isEmpty()) request.setAttribute("destPort", portDAO.getPortById(Integer.parseInt(d)));
                } catch (Exception ignored) {}

                request.getRequestDispatcher("/jsp/pricing.jsp").forward(request, response);
            } catch (Exception e) {
                session.setAttribute("errorMessage", "Could not price this booking: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/shipments/create");
            }
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        
        if (pathInfo != null && pathInfo.equals("/updateFull")) {
            Shipment s = new Shipment();
            s.setShipmentId(Integer.parseInt(request.getParameter("shipmentId")));
            s.setCustomerId(Integer.parseInt(request.getParameter("customerId")));
            s.setContainerId(Integer.parseInt(request.getParameter("containerId")));
            s.setOriginPortId(Integer.parseInt(request.getParameter("originPortId")));
            s.setDestinationPortId(Integer.parseInt(request.getParameter("destPortId")));
            s.setVesselId(Integer.parseInt(request.getParameter("vesselId")));
            s.setCargoDescription(request.getParameter("cargoDesc"));
            s.setCargoWeightKg(Double.parseDouble(request.getParameter("cargoWeight")));
            s.setCargoVolumeCbm(Double.parseDouble(request.getParameter("cargoVolume")));
            s.setCargoDeclaredValue(Double.parseDouble(request.getParameter("cargoValue")));
            s.setFreightCost(Double.parseDouble(request.getParameter("freightCost")));
            
            String insCost = request.getParameter("insuranceCost");
            if (insCost != null && !insCost.isEmpty()) s.setInsuranceCost(Double.parseDouble(insCost));
            
            String otherCost = request.getParameter("otherCharges");
            if (otherCost != null && !otherCost.isEmpty()) s.setOtherCharges(Double.parseDouble(otherCost));
            
            s.setStatus(request.getParameter("status"));

            // FR5.3: block transition to Departed until all mandatory compliance documents
            // are Approved and none are expired (contract precondition).
            com.nlogistic.dao.ShipmentDAO.ShipmentDetail prior = shipmentDAO.getShipmentById(s.getShipmentId());
            if (isAtOrBeyondDeparture(s.getStatus())
                    && !isAtOrBeyondDeparture(prior != null ? prior.getStatus() : null)
                    && !complianceDAO.canShipmentDepart(s.getShipmentId())) {
                session.setAttribute("errorMessage", "Cannot move Shipment #SHP-" + s.getShipmentId()
                        + " to Departed: one or more compliance documents are missing, not Approved, or expired. "
                        + "Resolve them on the Compliance page first.");
                response.sendRedirect(request.getContextPath() + "/shipments");
                return;
            }

            shipmentDAO.updateFullShipment(s, currentUser.getUserId());
            response.sendRedirect(request.getContextPath() + "/shipments");
        } else if (pathInfo != null && pathInfo.equals("/save")) {
            Shipment s = new Shipment();
            s.setCustomerId(Integer.parseInt(request.getParameter("customerId")));
            s.setContainerId(Integer.parseInt(request.getParameter("containerId")));
            s.setOriginPortId(Integer.parseInt(request.getParameter("originPortId")));
            s.setDestinationPortId(Integer.parseInt(request.getParameter("destPortId")));
            s.setVesselId(Integer.parseInt(request.getParameter("vesselId")));
            s.setCargoDescription(request.getParameter("cargoDesc"));
            s.setCargoWeightKg(Double.parseDouble(request.getParameter("cargoWeight")));
            s.setCargoVolumeCbm(Double.parseDouble(request.getParameter("cargoVolume")));
            s.setCargoDeclaredValue(Double.parseDouble(request.getParameter("cargoValue")));
            s.setFreightCost(Double.parseDouble(request.getParameter("freightCost")));
            String insStr = request.getParameter("insuranceCost");
            s.setInsuranceCost(insStr != null && !insStr.isEmpty() ? Double.parseDouble(insStr) : 0);
            String othStr = request.getParameter("otherCharges");
            s.setOtherCharges(othStr != null && !othStr.isEmpty() ? Double.parseDouble(othStr) : 0);
            s.setCreatedBy(currentUser.getUserId());

            // GAP-M2-01: this route used to call book_shipment() and stop there, so the
            // container stayed "Available" forever, no profit_loss row existed (the
            // shipment was invisible to the PLG) and no barcode was issued. It now runs
            // the same complete contract as the /book flow.
            int newShipmentId = shipmentDAO.bookShipmentAndReturnId(s);
            if (newShipmentId > 0) {
                StringBuilder note = new StringBuilder();

                // FR3.3: bind the container and flip it to Allocated.
                if (shipmentDAO.allocateContainer(newShipmentId, s.getContainerId())) {
                    note.append(" Container allocated.");
                } else {
                    note.append(" WARNING: container could not be allocated - check its availability.");
                }

                // FR2.6: seed the P&L record so the shipment appears in analytics.
                double revenue = s.getFreightCost() + s.getInsuranceCost() + s.getOtherCharges();
                if (shipmentDAO.seedProfitLoss(newShipmentId, revenue)) {
                    note.append(" P&L record created.");
                }

                // FR8.1: every core record gets a scannable barcode.
                try {
                    com.nlogistic.util.BarcodeAutoGenerator.generateFor(
                            request, "Shipment", newShipmentId, currentUser.getUserId());
                } catch (Exception barcodeEx) {
                    barcodeEx.printStackTrace();
                }

                // FR5.5: raise the invoice automatically, as the customer flow does.
                try {
                    int invId = new com.nlogistic.dao.BillingDAO()
                            .generateInvoice(s.getCustomerId(), newShipmentId);
                    if (invId > 0) note.append(" Invoice INV-").append(invId).append(" raised.");
                } catch (Exception invEx) {
                    invEx.printStackTrace();
                }

                session.setAttribute("successMessage",
                        "Shipment #SHP-" + newShipmentId + " booked." + note);
                response.sendRedirect(request.getContextPath() + "/shipments");
            } else {
                session.setAttribute("errorMessage",
                        "Booking failed. Verify the container is Available and the cargo fits within its capacity.");
                response.sendRedirect(request.getContextPath() + "/shipments/create?error=true");
            }
        } else if (pathInfo != null && pathInfo.equals("/delete")) {
            try {
                String idParam = request.getParameter("id");
                if (idParam == null || idParam.isEmpty()) idParam = request.getParameter("shipmentId");
                int delId = Integer.parseInt(idParam);
                shipmentDAO.deleteShipment(delId, currentUser.getUserId());
                session.setAttribute("successMessage", "Shipment #" + delId + " was deleted successfully.");
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Failed to delete shipment: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/shipments");
} else if (pathInfo != null && pathInfo.equals("/updateStatus")) {
            String shipmentIdStr = request.getParameter("shipmentId");
            String status = request.getParameter("status");
            String remarks = request.getParameter("remarks");
            String redirectUrl = request.getParameter("redirectUrl");
            // GAP-M2-02: recording movement is an Operations & Admin duty. Company Admin (Role 2),
            // Operations staff (Role 3), and Super Admin (Role 1) can record checkpoints.
            int csRole = com.nlogistic.util.RbacContext.roleId(request);
            if (csRole > 3 || csRole <= 0) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Access Denied: only Operations staff and Admins (Roles 1-3) may record movement checkpoints.");
                return;
            }
            try {
                int shipmentId = Integer.parseInt(shipmentIdStr);
                int userId = (currentUser != null) ? currentUser.getUserId() : (session.getAttribute("user") != null ? ((User) session.getAttribute("user")).getUserId() : 1);

                // Tenant guard: never move a shipment outside your own company.
                if (!shipmentDAO.canAccessShipment(shipmentId, csRole,
                        com.nlogistic.util.RbacContext.companyId(request), null)) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN,
                            "Access Denied: this shipment does not belong to your company.");
                    return;
                }

                // Movement order. Without this a shipment could jump from Container
                // Allocated straight to In Transit or Delivered, which is precisely
                // how the FR5.3 gate below was being walked around.
                com.nlogistic.dao.ShipmentDAO.ShipmentDetail cur = shipmentDAO.getShipmentById(shipmentId);
                String currentStatus = (cur != null) ? cur.getStatus() : null;
                String blocked = checkMovement(currentStatus, status);
                if (blocked != null) {
                    session.setAttribute("errorMessage", blocked);
                    if (redirectUrl != null && !redirectUrl.trim().isEmpty()) {
                        response.sendRedirect(redirectUrl);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/shipments/tracking/detail?id=SHP-" + shipmentId);
                    }
                    return;
                }

                // GAP-M2-03 / FR5.3: the departure gate was enforced only in
                // /updateFull, while dock staff use this route. A DB trigger also
                // blocks it, but checking here yields a readable message instead of
                // a raw SQL error.
                //
                // It now covers every status from Departed onward. Guarding the word
                // "Departed" alone let the same request reach In Transit, Arrived or
                // Delivered with no approved paperwork at all.
                if (isAtOrBeyondDeparture(status) && !isAtOrBeyondDeparture(currentStatus)
                        && !complianceDAO.canShipmentDepart(shipmentId)) {
                    session.setAttribute("errorMessage",
                            "Departure Blocked: Shipment #SHP-" + shipmentId + " still has compliance documents "
                          + "that are missing, not Approved, or expired (FR5.3).");
                    if (redirectUrl != null && !redirectUrl.trim().isEmpty()) {
                        response.sendRedirect(redirectUrl);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/shipments/tracking/detail?id=SHP-" + shipmentId);
                    }
                    return;
                }

                shipmentDAO.updateStatus(shipmentId, status, remarks, userId);

                // GAP-M2-04 / FR2.5: on arrival, settle expected vs actual and record the delay.
                String delayNote = "";
                if ("Arrived".equalsIgnoreCase(status) || "Delivered".equalsIgnoreCase(status)) {
                    int delayDays = shipmentDAO.settleArrivalDelay(shipmentId, userId);
                    if (delayDays > 0) {
                        delayNote = " Arrived " + delayDays + " day(s) late - tagged against the 'Delay' loss reason.";
                    }
                }

                session.setAttribute("successMessage", "Checkpoint recorded: Shipment #SHP-" + shipmentId
                        + " status updated to '" + status + "'." + delayNote);

                if (redirectUrl != null && !redirectUrl.trim().isEmpty()) {
                    response.sendRedirect(redirectUrl);
                } else {
                    response.sendRedirect(request.getContextPath() + "/shipments/tracking/detail?id=SHP-" + shipmentId);
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Failed to record checkpoint: " + e.getMessage());
                if (redirectUrl != null && !redirectUrl.trim().isEmpty()) {
                    response.sendRedirect(redirectUrl);
                } else if (shipmentIdStr != null) {
                    response.sendRedirect(request.getContextPath() + "/shipments/tracking/detail?id=SHP-" + shipmentIdStr);
                } else {
                    response.sendRedirect(request.getContextPath() + "/shipments");
                }
            }
        } else if (pathInfo != null && pathInfo.equals("/allocateContainer")) {
            handleAllocateContainer(request, response);
            return;
        }
    }

    /**
     * FR3.3 / FR3.4: JSON provider for available containers matching shipment cargo specifications.
     * Accessible by Super Admin (Role 1), Company Admin (Role 2), and Operations Staff (Role 3).
     */
    private void handleAvailableContainersJson(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int roleId = com.nlogistic.util.RbacContext.roleId(request);
        if (roleId > 3) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\":\"Forbidden: Only Operations staff and Admins may allocate containers.\"}");
            return;
        }

        Integer companyId = (roleId == 1) ? null : com.nlogistic.util.RbacContext.companyId(request);
        String shipmentIdParam = request.getParameter("shipmentId");
        ShipmentDAO.ShipmentDetail shipment = null;
        Shipment fullShipment = null;

        if (shipmentIdParam != null && !shipmentIdParam.trim().isEmpty()) {
            try {
                int shipmentId = Integer.parseInt(shipmentIdParam.trim());
                if (shipmentDAO.canAccessShipment(shipmentId, roleId, companyId, null)) {
                    shipment = shipmentDAO.getShipmentById(shipmentId);
                    fullShipment = shipmentDAO.getFullShipmentById(shipmentId);
                }
            } catch (NumberFormatException ignored) {}
        }

        List<Container> containers = containerDAO.getContainersPaged("Available", 1000, 0, companyId);

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        StringBuilder sb = new StringBuilder();
        sb.append("{");

        if (shipment != null && fullShipment != null) {
            sb.append("\"shipment\":{");
            sb.append("\"shipmentId\":").append(shipment.getShipmentId()).append(",");
            sb.append("\"customerName\":\"").append(escapeJson(shipment.getCustomerName())).append("\",");
            sb.append("\"originPort\":\"").append(escapeJson(shipment.getOriginPort())).append("\",");
            sb.append("\"destPort\":\"").append(escapeJson(shipment.getDestPort())).append("\",");
            sb.append("\"originPortId\":").append(fullShipment.getOriginPortId()).append(",");
            sb.append("\"destPortId\":").append(fullShipment.getDestinationPortId()).append(",");
            sb.append("\"cargoDesc\":\"").append(escapeJson(fullShipment.getCargoDescription())).append("\",");
            sb.append("\"cargoWeight\":").append(fullShipment.getCargoWeightKg()).append(",");
            sb.append("\"cargoVolume\":").append(fullShipment.getCargoVolumeCbm()).append(",");
            sb.append("\"status\":\"").append(escapeJson(shipment.getStatus())).append("\"");
            sb.append("},");
        }

        sb.append("\"containers\":[");
        for (int i = 0; i < containers.size(); i++) {
            Container c = containers.get(i);
            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"containerId\":").append(c.getContainerId()).append(",");
            sb.append("\"containerNumber\":\"").append(escapeJson(c.getContainerNumber())).append("\",");
            sb.append("\"type\":\"").append(escapeJson(c.getType())).append("\",");
            sb.append("\"size\":\"").append(escapeJson(c.getSize())).append("\",");
            sb.append("\"currentPortId\":").append(c.getCurrentPortId()).append(",");
            sb.append("\"portName\":\"").append(escapeJson(c.getPortName() != null ? c.getPortName() : "Container Depot")).append("\",");
            sb.append("\"portCountry\":\"").append(escapeJson(c.getPortCountry() != null ? c.getPortCountry() : "")).append("\",");
            sb.append("\"ownerCompanyName\":\"").append(escapeJson(c.getOwnerCompanyName() != null ? c.getOwnerCompanyName() : "")).append("\",");
            sb.append("\"maxGrossWeightKg\":").append(c.getMaxGrossWeightKg()).append(",");
            sb.append("\"goodsCapacityKg\":").append(c.getGoodsCapacityKg()).append(",");
            sb.append("\"goodsCapacityCbm\":").append(c.getGoodsCapacityCbm()).append(",");

            double weight = (fullShipment != null) ? fullShipment.getCargoWeightKg() : 0;
            double volume = (fullShipment != null) ? fullShipment.getCargoVolumeCbm() : 0;
            double maxW = c.getGoodsCapacityKg() > 0 ? c.getGoodsCapacityKg() : c.getMaxGrossWeightKg();
            boolean fitsW = maxW <= 0 || weight <= maxW;
            boolean fitsV = c.getGoodsCapacityCbm() <= 0 || volume <= c.getGoodsCapacityCbm();
            boolean matchesOrigin = fullShipment != null && fullShipment.getOriginPortId() == c.getCurrentPortId();

            sb.append("\"fitsWeight\":").append(fitsW).append(",");
            sb.append("\"fitsVolume\":").append(fitsV).append(",");
            sb.append("\"fitsAll\":").append(fitsW && fitsV).append(",");
            sb.append("\"matchesOrigin\":").append(matchesOrigin);
            sb.append("}");
        }
        sb.append("]}");
        out.print(sb.toString());
        out.flush();
    }

    /**
     * FR3.3 & FR3.4: Formally allocates an Available container to a Booked shipment.
     * Enforces contract preconditions and advances status to 'Container Allocated'.
     */
    private void handleAllocateContainer(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        int roleId = com.nlogistic.util.RbacContext.roleId(request);

        if (roleId > 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: only Operations staff and Admins may allocate containers.");
            return;
        }

        String redirectUrl = request.getParameter("redirectUrl");

        try {
            int shipmentId = Integer.parseInt(request.getParameter("shipmentId"));
            int containerId = Integer.parseInt(request.getParameter("containerId"));
            int userId = (currentUser != null) ? currentUser.getUserId() : 1;
            Integer companyId = com.nlogistic.util.RbacContext.companyId(request);

            // Tenant guard
            if (!shipmentDAO.canAccessShipment(shipmentId, roleId, companyId, null)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: this shipment does not belong to your company.");
                return;
            }

            // Invariant: Container must be Available (FR3.3)
            Container container = containerDAO.getContainerById(containerId);
            if (container == null || !"Available".equalsIgnoreCase(container.getStatus())) {
                session.setAttribute("errorMessage", "Allocation Failed: Selected container is no longer Available.");
                safeRedirect(request, response, redirectUrl);
                return;
            }

            // Tenancy check on container
            if (roleId != 1 && companyId != null && container.getOwnerCompanyId() != companyId) {
                session.setAttribute("errorMessage", "Allocation Failed: You cannot allocate a container owned by another company.");
                safeRedirect(request, response, redirectUrl);
                return;
            }

            // Precondition: Shipment must be Booked
            ShipmentDAO.ShipmentDetail shipment = shipmentDAO.getShipmentById(shipmentId);
            if (shipment == null || !"Booked".equalsIgnoreCase(shipment.getStatus())) {
                session.setAttribute("errorMessage", "Allocation Failed: Shipment #SHP-" + shipmentId + " is not in 'Booked' status (Current: " 
                        + (shipment != null ? shipment.getStatus() : "Not Found") + ").");
                safeRedirect(request, response, redirectUrl);
                return;
            }

            // Precondition FR3.4: Weight and Volume check
            Shipment fullShipment = shipmentDAO.getFullShipmentById(shipmentId);
            if (fullShipment != null) {
                double maxWeight = container.getGoodsCapacityKg() > 0 ? container.getGoodsCapacityKg() : container.getMaxGrossWeightKg();
                if (maxWeight > 0 && fullShipment.getCargoWeightKg() > maxWeight) {
                    session.setAttribute("errorMessage", "Allocation Failed: Cargo weight (" + fullShipment.getCargoWeightKg() 
                            + " kg) exceeds container capacity (" + maxWeight + " kg).");
                    safeRedirect(request, response, redirectUrl);
                    return;
                }
                if (container.getGoodsCapacityCbm() > 0 && fullShipment.getCargoVolumeCbm() > container.getGoodsCapacityCbm()) {
                    session.setAttribute("errorMessage", "Allocation Failed: Cargo volume (" + fullShipment.getCargoVolumeCbm() 
                            + " CBM) exceeds container capacity (" + container.getGoodsCapacityCbm() + " CBM).");
                    safeRedirect(request, response, redirectUrl);
                    return;
                }
            }

            String remark = request.getParameter("remarks");
            if (remark == null || remark.trim().isEmpty()) {
                remark = "Container Depot - Allocated " + container.getContainerNumber() + " (" + container.getSize() + " " + container.getType() + ")";
            }

            boolean ok = shipmentDAO.allocateContainer(shipmentId, containerId, userId, remark);
            if (ok) {
                session.setAttribute("successMessage", "Container " + container.getContainerNumber() + " successfully allocated to Shipment #SHP-" 
                        + shipmentId + ". Milestone advanced to 'Container Allocated'.");
            } else {
                session.setAttribute("errorMessage", "Allocation Failed: Database error while linking container.");
            }

            safeRedirect(request, response, redirectUrl);

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Allocation Failed: " + e.getMessage());
            safeRedirect(request, response, redirectUrl);
        }
    }

    private void safeRedirect(HttpServletRequest request, HttpServletResponse response, String redirectUrl) throws IOException {
        if (redirectUrl != null && !redirectUrl.trim().isEmpty()) {
            response.sendRedirect(redirectUrl);
        } else {
            response.sendRedirect(request.getContextPath() + "/shipments");
        }
    }

    private static String escapeJson(String str) {
        if (str == null) return "";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < str.length(); i++) {
            char c = str.charAt(i);
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\b': sb.append("\\b"); break;
                case '\f': sb.append("\\f"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (c < ' ') {
                        String t = "000" + Integer.toHexString(c);
                        sb.append("\\u").append(t.substring(t.length() - 4));
                    } else {
                        sb.append(c);
                    }
            }
        }
        return sb.toString();
    }
}

