package com.nlogistic.controller;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.nlogistic.util.DBConnectionManager;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Contract Precondition: Verify caller is authenticated with a valid role
        Integer roleId = (Integer) request.getSession().getAttribute("roleId");
        if (roleId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Access Denied: Authentication required.");
            return;
        }

                try (Connection conn = DBConnectionManager.getConnection()) {
            
            String period = request.getParameter("period");
            if (period == null) period = "all";
            request.setAttribute("currentPeriod", period);

            String dateFilter = "";
            if ("today".equals(period)) {
                dateFilter = " WHERE DATE(booking_date) = CURDATE() ";
            } else if ("week".equals(period)) {
                dateFilter = " WHERE booking_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) ";
            } else if ("month".equals(period)) {
                dateFilter = " WHERE booking_date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH) ";
            }
            
            String wherePrefix = dateFilter.isEmpty() ? "" : dateFilter + " AND ";
            String whereClause = dateFilter.isEmpty() ? "" : dateFilter;


            // --- KPI Cards ---
            int totalShipments = 0, activeShipments = 0, deliveredShipments = 0, pendingShipments = 0, overdueShipments = 0;
            try (PreparedStatement ps = conn.prepareStatement("SELECT status, COUNT(*) as cnt FROM shipment" + whereClause + " GROUP BY status")) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    int cnt = rs.getInt("cnt");
                    totalShipments += cnt;
                    String st = rs.getString("status");
                    if ("In Transit".equals(st) || "Container Allocated".equals(st) || "Departed".equals(st)) activeShipments += cnt;
                    else if ("Delivered".equals(st)) deliveredShipments = cnt;
                    else if ("Booked".equals(st) || "Arrived".equals(st)) pendingShipments += cnt;
                    else if ("Customs Hold".equals(st) || "Cancelled".equals(st)) overdueShipments += cnt;
                }
            }
            request.setAttribute("totalShipments", totalShipments);
            request.setAttribute("activeShipments", activeShipments);
            request.setAttribute("deliveredShipments", deliveredShipments);
            request.setAttribute("pendingShipments", pendingShipments);
            request.setAttribute("overdueShipments", overdueShipments);

            // --- Shipments by Status (for doughnut chart) JSON ---
            StringBuilder statusJson = new StringBuilder("[");
            try (PreparedStatement ps = conn.prepareStatement("SELECT status, COUNT(*) as cnt FROM shipment" + whereClause + " GROUP BY status ORDER BY cnt DESC")) {
                ResultSet rs = ps.executeQuery();
                boolean first = true;
                while (rs.next()) {
                    if (!first) statusJson.append(",");
                    statusJson.append("{\"status\":\"").append(rs.getString("status")).append("\",\"cnt\":").append(rs.getInt("cnt")).append("}");
                    first = false;
                }
            }
            statusJson.append("]");
            request.setAttribute("statusJson", statusJson.toString());
            String trendPeriod = request.getParameter("trendPeriod");
            if (trendPeriod == null) trendPeriod = "week";
            request.setAttribute("currentTrendPeriod", trendPeriod);

            String trendDateFilter = "";
            String trendLimit = "7";
            if ("week".equals(trendPeriod)) {
                trendDateFilter = " WHERE booking_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND booking_date <= CURDATE() ";
                trendLimit = "7";
            } else if ("month".equals(trendPeriod)) {
                trendDateFilter = " WHERE booking_date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND booking_date <= CURDATE() ";
                trendLimit = "30";
            } else if ("year".equals(trendPeriod)) {
                trendDateFilter = " WHERE booking_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND booking_date <= CURDATE() ";
                trendLimit = "365"; 
            }

            // --- Weekly Shipment Trend (last 7 days) JSON ---
            StringBuilder trendJson = new StringBuilder("[");
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT DATE_FORMAT(booking_date,'%d %b') as d, COUNT(*) as cnt FROM shipment " +
                    trendDateFilter +
                    "GROUP BY DATE(booking_date) ORDER BY DATE(booking_date) ASC LIMIT " + trendLimit)) {
                ResultSet rs = ps.executeQuery();
                boolean first = true;
                while (rs.next()) {
                    if (!first) trendJson.append(",");
                    trendJson.append("{\"d\":\"").append(rs.getString("d")).append("\",\"cnt\":").append(rs.getInt("cnt")).append("}");
                    first = false;
                }
            }
            trendJson.append("]");
            request.setAttribute("trendJson", trendJson.toString());

            // --- Recent Shipments (last 5) ---
            List<Map<String,String>> recentShipments = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT s.shipment_id, c.customer_name, s.status, " +
                    "CONCAT(p1.port_name, ' \u2192 ', p2.port_name) as route, s.booking_date " +
                    "FROM shipment s " +
                    "JOIN customers c ON s.customer_id = c.customer_id " +
                    "JOIN ports p1 ON s.origin_port_id = p1.port_id " +
                    "JOIN ports p2 ON s.destination_port_id = p2.port_id " +
                    "ORDER BY s.shipment_id DESC LIMIT 5")) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String,String> row = new LinkedHashMap<>();
                    row.put("id", "SHP-" + String.format("%05d", rs.getInt("shipment_id")));
                    row.put("customer", rs.getString("customer_name"));
                    row.put("status", rs.getString("status"));
                    row.put("route", rs.getString("route"));
                    row.put("date", rs.getString("booking_date"));
                    recentShipments.add(row);
                }
            }
            request.setAttribute("recentShipments", recentShipments);

            // --- Top Routes ---
            List<Map<String,Object>> topRoutes = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT CONCAT(p1.port_name, ' \u2192 ', p2.port_name) as route, COUNT(*) as cnt " +
                    "FROM shipment s " +
                    "JOIN ports p1 ON s.origin_port_id = p1.port_id " +
                    "JOIN ports p2 ON s.destination_port_id = p2.port_id " +
                    "GROUP BY s.origin_port_id, s.destination_port_id ORDER BY cnt DESC LIMIT 5")) {
                ResultSet rs = ps.executeQuery();
                int maxCnt = 1;
                List<int[]> counts = new ArrayList<>();
                List<String> routes = new ArrayList<>();
                while (rs.next()) {
                    int cnt = rs.getInt("cnt");
                    if (cnt > maxCnt) maxCnt = cnt;
                    routes.add(rs.getString("route"));
                    counts.add(new int[]{cnt});
                }
                for (int i = 0; i < routes.size(); i++) {
                    Map<String,Object> row = new LinkedHashMap<>();
                    row.put("route", routes.get(i));
                    row.put("cnt", counts.get(i)[0]);
                    row.put("pct", (int) Math.round(counts.get(i)[0] * 100.0 / totalShipments));
                    topRoutes.add(row);
                }
            }
            request.setAttribute("topRoutes", topRoutes);

            // --- Container Overview ---
            Map<String,Integer> containerTypes = new LinkedHashMap<>();
            try (PreparedStatement ps = conn.prepareStatement("SELECT type, COUNT(*) as cnt FROM containers GROUP BY type ORDER BY cnt DESC")) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) containerTypes.put(rs.getString("type"), rs.getInt("cnt"));
            }
            request.setAttribute("containerTypes", containerTypes);

            int totalContainers = 0;
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM containers")) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) totalContainers = rs.getInt(1);
            }
            request.setAttribute("totalContainers", totalContainers);

            // --- Recent Alerts (audit_log) ---
            List<Map<String,String>> alerts = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT action, entity_name, entity_id, new_value, timestamp FROM audit_log ORDER BY timestamp DESC LIMIT 5")) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String,String> row = new LinkedHashMap<>();
                    row.put("action", rs.getString("action"));
                    row.put("entity", rs.getString("entity_name") != null ? rs.getString("entity_name") : "System");
                    row.put("detail", rs.getString("new_value") != null ? rs.getString("new_value") : rs.getString("action"));
                    row.put("time", rs.getString("timestamp"));
                    alerts.add(row);
                }
            }
            request.setAttribute("alerts", alerts);

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("/jsp/dashboard.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
