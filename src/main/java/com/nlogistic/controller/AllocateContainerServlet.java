package com.nlogistic.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.dao.ContainerDAO;
import com.nlogistic.dao.PortDAO;
import com.nlogistic.model.Container;
import com.nlogistic.model.User;
import com.nlogistic.util.DBConnectionManager;

@WebServlet("/allocate")
public class AllocateContainerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ContainerDAO containerDAO = new ContainerDAO();
    private PortDAO portDAO = new PortDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String containerIdStr = request.getParameter("containerId");
        if (containerIdStr == null || containerIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/containers");
            return;
        }

        try {
            int containerId = Integer.parseInt(containerIdStr);
            Container container = getContainerById(containerId);

            if (container == null) {
                request.setAttribute("errorMessage", "Container not found.");
                request.getRequestDispatcher("/jsp/containers.jsp").forward(request, response);
                return;
            }

            request.setAttribute("container", container);
            // FR2.1 / GAP-M3-02: staff book on behalf of a shipper, so they must be
            // able to choose one. Without this the booking had no customer at all.
            if (com.nlogistic.util.RbacContext.roleId(request) <= 3) {
                request.setAttribute("customers", new com.nlogistic.dao.CustomerDAO().getAllCustomers());
            }
            // Genuinely missing previously: the origin/destination port dropdowns in
            // allocate-container.jsp were hardcoded to 5 fixed IDs/names that may not match
            // the actual seeded `ports` table rows. Drive them from the real data instead.
            request.setAttribute("ports", portDAO.getAllPorts());
            request.getRequestDispatcher("/jsp/allocate-container.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/containers");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int containerId = Integer.parseInt(request.getParameter("containerId"));
        double cargoWeight = Double.parseDouble(request.getParameter("cargoWeight"));
        double cargoVolume = Double.parseDouble(request.getParameter("cargoVolume"));
        
        Container container = getContainerById(containerId);
        
        // Contract Invariant (FR3.3)
        if (!"Available".equals(container.getStatus())) {
            request.getSession().setAttribute("errorMessage", "Allocation Failed: Container is no longer available.");
            response.sendRedirect(request.getContextPath() + "/containers");
            return;
        }

        // Contract Precondition (FR3.4)
        if (cargoWeight > container.getGoodsCapacityKg() || cargoVolume > container.getGoodsCapacityCbm()) {
            request.setAttribute("errorMessage", "Allocation Failed: Cargo weight or volume exceeds container capacity!");
            request.setAttribute("container", container);
            // Pre-fill form values so user doesn't lose them
            request.setAttribute("cargoWeight", cargoWeight);
            request.setAttribute("cargoVolume", cargoVolume);
            request.setAttribute("cargoDesc", request.getParameter("cargoDesc"));
            request.setAttribute("origin", request.getParameter("origin"));
            request.setAttribute("destination", request.getParameter("destination"));
            request.setAttribute("ports", portDAO.getAllPorts());

            request.getRequestDispatcher("/jsp/allocate-container.jsp").forward(request, response);
            return;
        }

        // If preconditions pass, we proceed to Price Calculation & Booking.
        com.nlogistic.dao.PricingDAO pricingDAO = new com.nlogistic.dao.PricingDAO();
        com.nlogistic.model.PricingRule rule = pricingDAO.getPricingRule(container.getType(), container.getSize());
        
        double finalPrice = rule.calculateFinalPrice();
        
        request.setAttribute("container", container);
        request.setAttribute("cargoWeight", cargoWeight);
        request.setAttribute("cargoVolume", cargoVolume);
        request.setAttribute("cargoDesc", request.getParameter("cargoDesc"));
        request.setAttribute("origin", request.getParameter("origin"));
        request.setAttribute("destination", request.getParameter("destination"));
        request.setAttribute("pricingRule", rule);
        request.setAttribute("finalPrice", finalPrice);
        request.setAttribute("customerId", request.getParameter("customerId"));
        
        // Resolve Origin and Destination port entities for display in pricing.jsp
        try {
            if (request.getParameter("origin") != null && !request.getParameter("origin").isEmpty()) {
                request.setAttribute("originPort", portDAO.getPortById(Integer.parseInt(request.getParameter("origin"))));
            }
            if (request.getParameter("destination") != null && !request.getParameter("destination").isEmpty()) {
                request.setAttribute("destPort", portDAO.getPortById(Integer.parseInt(request.getParameter("destination"))));
            }
        } catch (Exception ignored) {}
        
        // Forward to the detailed pricing breakdown page (FR3.5)
        request.getRequestDispatcher("/jsp/pricing.jsp").forward(request, response);
    }

    private Container getContainerById(int id) {
        String sql = "SELECT * FROM containers WHERE container_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Container c = new Container();
                    c.setContainerId(rs.getInt("container_id"));
                    c.setContainerNumber(rs.getString("container_number"));
                    c.setType(rs.getString("type"));
                    c.setSize(rs.getString("size"));
                    c.setImageUrl(rs.getString("image_url"));
                    c.setTareWeightKg(rs.getDouble("tare_weight_kg"));
                    c.setMaxGrossWeightKg(rs.getDouble("max_gross_weight_kg"));
                    c.setGoodsCapacityKg(rs.getDouble("goods_capacity_kg"));
                    c.setGoodsCapacityCbm(rs.getDouble("goods_capacity_cbm"));
                    c.setStatus(rs.getString("status"));
                    return c;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }
}
