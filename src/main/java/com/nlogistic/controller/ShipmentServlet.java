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

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/")) {    
            // List Shipments
            request.setAttribute("shipments", shipmentDAO.getAllShipments());
            request.getRequestDispatcher("/jsp/shipments.jsp").forward(request, response);
                                } else if (pathInfo.equals("/tracking")) {
            // Live Tracking Dashboard View with REAL DB Data
            List<ShipmentDAO.ShipmentDetail> allShipments = shipmentDAO.getAllShipments();
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
                    request.setAttribute("shipment", shipmentDAO.getShipmentById(id));
                    request.setAttribute("logs", shipmentDAO.getMovementLogs(id));
                } catch (NumberFormatException e) {
                    // ignore, let JSP handle null shipment
                }
            }
            request.getRequestDispatcher("/jsp/live_tracking_detail.jsp").forward(request, response);
        } else if (pathInfo.equals("/edit")) {
            int shipmentId = Integer.parseInt(request.getParameter("id"));
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
            request.setAttribute("customers", customerDAO.getAllCustomers());
            request.getRequestDispatcher("/jsp/create_shipment.jsp").forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession();
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

            boolean success = shipmentDAO.bookShipment(s);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/shipments?success=true");
            } else {
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
            int shipmentId = Integer.parseInt(request.getParameter("shipmentId"));
            String status = request.getParameter("status");
            shipmentDAO.updateStatus(shipmentId, status, currentUser.getUserId());
            response.sendRedirect(request.getContextPath() + "/shipments");
        }
    }
}









