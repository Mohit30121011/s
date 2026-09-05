package com.nlogistic.controller;

import com.nlogistic.dao.*;
import com.nlogistic.model.Shipment;
import java.util.List;
import com.nlogistic.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/shipments/*")
public class ShipmentServlet extends HttpServlet {
      															  
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
            if (idParam != null && idParam.startsWith("SHP-")) {
                try {
                    int id = Integer.parseInt(idParam.substring(4).trim());
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
            if ("Departed".equalsIgnoreCase(s.getStatus()) && !complianceDAO.canShipmentDepart(s.getShipmentId())) {
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
            // GAP-M2-02: recording movement is an Operations duty. Finance staff and
            // Customers previously could advance any shipment to Departed/Delivered.
            int csRole = com.nlogistic.util.RbacContext.roleId(request);
            if (csRole > 3) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Access Denied: only Operations staff and Admins may record movement checkpoints.");
                return;
            }
            try {
                int shipmentId = Integer.parseInt(shipmentIdStr);
                int userId = (currentUser != null) ? currentUser.getUserId() : 1;

                // Tenant guard: never move a shipment outside your own company.
                if (!shipmentDAO.canAccessShipment(shipmentId, csRole,
                        com.nlogistic.util.RbacContext.companyId(request), null)) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN,
                            "Access Denied: this shipment does not belong to your company.");
                    return;
                }

                // GAP-M2-03 / FR5.3: the departure gate was enforced only in
                // /updateFull, while dock staff use this route. A DB trigger also
                // blocks it, but checking here yields a readable message instead of
                // a raw SQL error.
                if ("Departed".equalsIgnoreCase(status) && !complianceDAO.canShipmentDepart(shipmentId)) {
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
        }
    }
}
