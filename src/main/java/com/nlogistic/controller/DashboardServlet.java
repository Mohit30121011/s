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

            String dateCond = "";
            if ("today".equals(period)) {
                dateCond = "DATE(booking_date) = CURDATE()";
            } else if ("week".equals(period)) {
                dateCond = "booking_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)";
            } else if ("month".equals(period)) {
                dateCond = "booking_date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)";
            }

            /* ------------------------------------------------------------------
             * RBAC tenant scoping for the whole dashboard.
             * Without this every role saw the global figures: a Company Admin's
             * "Total Shipments" card read 206 (the entire platform) instead of
             * their own 31. Values interpolated below are ints taken from the
             * session, never request input.
             * ------------------------------------------------------------------ */
            Integer scopeCompany = com.nlogistic.util.RbacContext.companyId(request);
            Integer scopeCustomer = com.nlogistic.util.RbacContext.customerId(request);

            String shipScopeBare = "";  // for queries whose FROM has no alias
            String shipScopeS = "";     // for queries aliased as s
            String containerScope = "";
            String auditScope = "";

            if (roleId == 5) {
                int cid = (scopeCustomer != null) ? scopeCustomer : -1;
                shipScopeBare = "customer_id = " + cid;
                shipScopeS = "s.customer_id = " + cid;
                // FR3.1/3.2: a Customer may browse the catalog, but the dashboard card
                // is "active fleet inventory" - internal ops data. Show them only what
                // they can actually book (Available units), never the whole fleet.
                containerScope = "status = 'Available'";
                com.nlogistic.model.User me = com.nlogistic.util.RbacContext.user(request);
                auditScope = "user_id = " + (me != null ? me.getUserId() : -1);
            } else if (roleId >= 2 && roleId <= 4) {
                int co = (scopeCompany != null) ? scopeCompany : -1;
                String owned = "SELECT s2.shipment_id FROM shipment s2 "
                             + "LEFT JOIN containers c2 ON s2.container_id = c2.container_id "
                             + "WHERE c2.owner_company_id = " + co
                             + " OR s2.created_by IN (SELECT user_id FROM users WHERE company_id = " + co + ")";
                shipScopeBare = "shipment_id IN (" + owned + ")";
                shipScopeS = "s.shipment_id IN (" + owned + ")";
                containerScope = "owner_company_id = " + co;
                auditScope = "user_id IN (SELECT user_id FROM users WHERE company_id = " + co + ")";
            }

            String whereClause = buildWhere(dateCond, shipScopeBare);
            String wherePrefix = whereClause.isEmpty() ? "" : whereClause + " AND ";


            // --- KPI Cards ---
            int totalShipments = 0, activeShipments = 0, deliveredShipments = 0, pendingShipments = 0, overdueShipments = 0;
            try (PreparedStatement ps = conn.prepareStatement("SELECT status, COUNT(*) as cnt FROM shipment " + whereClause + " GROUP BY status")) {
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
            try (PreparedStatement ps = conn.prepareStatement("SELECT status, COUNT(*) as cnt FROM shipment " + whereClause + " GROUP BY status ORDER BY cnt DESC")) {
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

            String trendCond = "";
            String trendLimit = "7";
            if ("week".equals(trendPeriod)) {
                trendCond = "booking_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND booking_date <= CURDATE()";
                trendLimit = "7";
            } else if ("month".equals(trendPeriod)) {
                trendCond = "booking_date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND booking_date <= CURDATE()";
                trendLimit = "30";
            } else if ("year".equals(trendPeriod)) {
                trendCond = "booking_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND booking_date <= CURDATE()";
                trendLimit = "365";
            }
            String trendDateFilter = buildWhere(trendCond, shipScopeBare) + " ";

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
                    buildWhere("", shipScopeS) + " " +
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
                    buildWhere("", shipScopeS) + " " +
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
            try (PreparedStatement ps = conn.prepareStatement("SELECT type, COUNT(*) as cnt FROM containers " + buildWhere("", containerScope) + " GROUP BY type ORDER BY cnt DESC")) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) containerTypes.put(rs.getString("type"), rs.getInt("cnt"));
            }
            request.setAttribute("containerTypes", containerTypes);

            int totalContainers = 0;
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM containers " + buildWhere("", containerScope))) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) totalContainers = rs.getInt(1);
            }
            request.setAttribute("totalContainers", totalContainers);

            // --- Recent Alerts (audit_log) ---
            List<Map<String,String>> alerts = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT action, entity_name, entity_id, new_value, timestamp FROM audit_log " + buildWhere("", auditScope) + " ORDER BY timestamp DESC LIMIT 5")) {
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

            // FR5.4: documents inside the 15-day expiry window must be visible on the
            // dashboard, not only to whoever happens to open /compliance.
            if (roleId <= 3) {
                java.util.List<com.nlogistic.model.ComplianceDocument> expiring =
                        new com.nlogistic.dao.ComplianceDAO().getExpiringDocuments(15);
                if (expiring != null && roleId != 1) {
                    final com.nlogistic.dao.ShipmentDAO expScope = new com.nlogistic.dao.ShipmentDAO();
                    final int expRole = roleId;
                    expiring.removeIf(d -> !expScope.canAccessShipment(
                            d.getShipmentId(), expRole, scopeCompany, null));
                }
                request.setAttribute("expiringDocs", expiring);
                request.setAttribute("expiringDocsCount", expiring != null ? expiring.size() : 0);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("/jsp/dashboard.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    /** Joins a date condition and a tenant-scope condition into a single WHERE clause. */
    private static String buildWhere(String dateCond, String scopeCond) {
        boolean hasDate = dateCond != null && !dateCond.trim().isEmpty();
        boolean hasScope = scopeCond != null && !scopeCond.trim().isEmpty();
        if (!hasDate && !hasScope) return "";
        if (hasDate && hasScope) return " WHERE (" + dateCond + ") AND (" + scopeCond + ") ";
        return " WHERE " + (hasDate ? dateCond : scopeCond) + " ";
    }
}
