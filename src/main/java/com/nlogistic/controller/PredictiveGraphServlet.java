package com.nlogistic.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


import com.nlogistic.model.User;
import com.nlogistic.util.DBConnectionManager;

@WebServlet("/predictive-graph")
public class PredictiveGraphServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String containerType = request.getParameter("type");
        if (containerType == null) {
            containerType = "Dry";
        }
        // FR3.6: the forecast is per container type AND route. Ignoring route_id
        // produced one blended curve across every corridor in the world.
        Integer routeId = null;
        String routeParam = request.getParameter("routeId");
        if (routeParam != null && !routeParam.trim().isEmpty() && !"all".equalsIgnoreCase(routeParam)) {
            try { routeId = Integer.parseInt(routeParam.trim()); } catch (NumberFormatException ignored) {}
        }
        request.setAttribute("selectedRoute", routeId);
        request.setAttribute("routes", new com.nlogistic.dao.PortDAO().getAllPorts());

        List<String> labels = new ArrayList<>();
        List<Double> demandData = new ArrayList<>();
        List<Double> priceData = new ArrayList<>();

        StringBuilder labelsJson = new StringBuilder("[");
        StringBuilder demandJson = new StringBuilder("[");
        StringBuilder priceJson = new StringBuilder("[");

        String sql = "SELECT forecast_period, forecasted_demand, forecasted_price FROM demand_forecast "
                   + "WHERE container_type = ? "
                   + (routeId != null ? "AND route_id = ? " : "")
                   + "AND algorithm_version = (SELECT algorithm_version FROM demand_forecast "
                   + "                            ORDER BY generated_at DESC, forecast_id DESC LIMIT 1) "
                   + "ORDER BY forecast_id ASC LIMIT 6";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, containerType);
            if (routeId != null) ps.setInt(2, routeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    if (labelsJson.length() > 1) { labelsJson.append(","); demandJson.append(","); priceJson.append(","); }
                    labelsJson.append("\"").append(rs.getString("forecast_period")).append("\"");
                    demandJson.append(rs.getDouble("forecasted_demand"));
                    priceJson.append(rs.getDouble("forecasted_price"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        labelsJson.append("]");
        demandJson.append("]");
        priceJson.append("]");

        request.setAttribute("chartLabels", labelsJson.toString());
        request.setAttribute("chartDemand", demandJson.toString());
        request.setAttribute("chartPrice", priceJson.toString());
        request.setAttribute("selectedType", containerType);

        // Fetch current base price for updating
        double currentBasePrice = 0.0;
        int pricingId = 0;
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT pricing_id, base_price FROM pricing_rules WHERE container_type = ? LIMIT 1")) {
            ps.setString(1, containerType);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    pricingId = rs.getInt("pricing_id");
                    currentBasePrice = rs.getDouble("base_price");
                }
            }
        } catch (Exception e) { e.printStackTrace(); }

        request.setAttribute("pricingId", pricingId);
        request.setAttribute("currentBasePrice", currentBasePrice);

                com.nlogistic.dao.PricingRuleDAO pricingRuleDAO = new com.nlogistic.dao.PricingRuleDAO();
        List<com.nlogistic.model.PricingAudit> auditList = pricingRuleDAO.getAuditHistoryByType(containerType);
        request.setAttribute("auditHistory", auditList);

        request.getRequestDispatcher("/jsp/predictive-graph.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // FR3.7: Every price change shall be logged with old value, new value, reason, timestamp, user
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 2) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only Admins can update prices.");
            return;
        }

        int pricingId = Integer.parseInt(request.getParameter("pricingId"));
        double newPrice = Double.parseDouble(request.getParameter("newPrice"));
        String reason = request.getParameter("reason");
        String containerType = request.getParameter("containerType");

        double oldPrice = 0.0;
        double seasonalMultiplier = 1.0;
        double demandMultiplier = 1.0;

        try (Connection conn = DBConnectionManager.getConnection()) {
            conn.setAutoCommit(false);

            // Get old price + existing multipliers (needed to recompute final_price correctly)
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT base_price, seasonal_multiplier, demand_multiplier FROM pricing_rules WHERE pricing_id = ?")) {
                ps.setInt(1, pricingId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    oldPrice = rs.getDouble("base_price");
                    seasonalMultiplier = rs.getDouble("seasonal_multiplier");
                    demandMultiplier = rs.getDouble("demand_multiplier");
                }
            }

            double newFinalPrice = newPrice * seasonalMultiplier * demandMultiplier;

            // Update price - also recompute final_price so it never goes stale (bug: previously
            // only base_price was updated, leaving final_price out of sync with the new base rate).
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE pricing_rules SET base_price = ?, final_price = ? WHERE pricing_id = ?")) {
                ps.setDouble(1, newPrice);
                ps.setDouble(2, newFinalPrice);
                ps.setInt(3, pricingId);
                ps.executeUpdate();
            }

            // Insert into audit log (FR3.7: old value, new value, reason, timestamp, responsible user)
            try (PreparedStatement ps = conn.prepareStatement("INSERT INTO pricing_audit (pricing_id, old_price, new_price, changed_by, reason, changed_at) VALUES (?, ?, ?, ?, ?, NOW())")) {
                ps.setInt(1, pricingId);
                ps.setDouble(2, oldPrice);
                ps.setDouble(3, newPrice);
                ps.setInt(4, user.getUserId());
                ps.setString(5, reason);
                ps.executeUpdate();
            }

            conn.commit();
            request.getSession().setAttribute("successMessage", "Price updated successfully and logged in Audit Trail.");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Error updating price.");
        }

        response.sendRedirect(request.getContextPath() + "/predictive-graph?type=" + containerType);
    }
}
