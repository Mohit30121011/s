package com.nlogistic.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.nlogistic.util.DBConnectionManager;
import com.nlogistic.dao.AnalyticsDAO;
import com.nlogistic.model.AbcResult;
import com.nlogistic.model.LossReasonSummary;
import com.nlogistic.model.StockValuation;
import com.nlogistic.model.DemandForecast;
import com.nlogistic.model.TurnoverResult;

@WebServlet("/analytics/*")
public class AnalyticsServlet extends HttpServlet {
    private AnalyticsDAO analyticsDAO = new AnalyticsDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String export = request.getParameter("export");
        if ("csv".equals(export)) {
            exportCsv(request, response);
            return;
        }

        // Period used to (re)compute and read the cached analytical result tables
        // (abc_classification_result, inventory_turnover_result, profitability_result, sales_trend_result)
        String period = new java.text.SimpleDateFormat("yyyy-MM").format(new java.util.Date());
        javax.servlet.http.HttpSession analyticsSession = request.getSession(false);
        int analyticsUserId = 1;
        try {
            Object u = analyticsSession != null ? analyticsSession.getAttribute("user") : null;
            if (u != null) analyticsUserId = ((com.nlogistic.model.User) u).getUserId();
        } catch (Exception ignored) {}
        analyticsDAO.computeAllAnalytics(period, analyticsUserId);

        // Read filter params
        String filterCompany  = request.getParameter("company");
        String filterRoute    = request.getParameter("route");
        String filterCategory = request.getParameter("category");
        String filterDateFrom = request.getParameter("dateFrom");
        String filterDateTo   = request.getParameter("dateTo");

        // Preserve filter values for JSP
        request.setAttribute("filterCompany",  filterCompany  != null ? filterCompany  : "");
        request.setAttribute("filterRoute",    filterRoute    != null ? filterRoute    : "");
        request.setAttribute("filterCategory", filterCategory != null ? filterCategory : "");
        request.setAttribute("filterDateFrom", filterDateFrom != null ? filterDateFrom : "");
        request.setAttribute("filterDateTo",   filterDateTo   != null ? filterDateTo   : "");

        // Build WHERE clause based on filters (for profit_loss + shipment join)
        // Note: profit_loss has no company_id column (see SRS Section 6.3) - company filtering must go
        // through shipment -> customers -> users, matching the join used elsewhere in this file/DAO.
        StringBuilder where = new StringBuilder("WHERE 1=1");
        List<String> params = new ArrayList<>();

        if (filterCompany != null && !filterCompany.trim().isEmpty()) {
            where.append(" AND pl.shipment_id IN (SELECT s.shipment_id FROM shipment s " +
                    "JOIN customers c ON s.customer_id = c.customer_id " +
                    "JOIN users u ON c.user_id = u.user_id WHERE u.company_id = ?)");
            params.add(filterCompany);
        }
        if (filterDateFrom != null && !filterDateFrom.trim().isEmpty()) {
            where.append(" AND pl.record_date >= ?");
            params.add(filterDateFrom);
        }
        if (filterDateTo != null && !filterDateTo.trim().isEmpty()) {
            where.append(" AND pl.record_date <= ?");
            params.add(filterDateTo);
        }
        if (filterRoute != null && !filterRoute.trim().isEmpty() && filterRoute.contains("-")) {
            String[] portIds = filterRoute.split("-", 2);
            where.append(" AND pl.shipment_id IN (SELECT s.shipment_id FROM shipment s " +
                    "WHERE s.origin_port_id = ? AND s.destination_port_id = ?)");
            params.add(portIds[0]);
            params.add(portIds[1]);
        }

        int activeShipments = 0;
        double totalRevenue = 0.0;
        double totalCost    = 0.0;
        double netProfit    = 0.0;
        double onTimePct    = 78.6;

        try (Connection conn = DBConnectionManager.getConnection()) {

            // ---- Dropdown data ----
            List<String[]> companies = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT company_id, company_name FROM companies WHERE approval_status='Active' ORDER BY company_name")) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) companies.add(new String[]{rs.getString(1), rs.getString(2)});
            } catch (Exception e) { e.printStackTrace(); }
            request.setAttribute("companies", companies);

            List<String[]> routes = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT DISTINCT CONCAT(p1.port_name, ' \u2192 ', p2.port_name) as route_name, " +
                    "CONCAT(p1.port_id, '-', p2.port_id) as route_id " +
                    "FROM shipment s " +
                    "JOIN ports p1 ON s.origin_port_id = p1.port_id " +
                    "JOIN ports p2 ON s.destination_port_id = p2.port_id " +
                    "ORDER BY route_name LIMIT 30")) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) routes.add(new String[]{rs.getString("route_id"), rs.getString("route_name")});
            } catch (Exception e) { e.printStackTrace(); }
            request.setAttribute("routes", routes);

            List<String> categories = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT DISTINCT category FROM products WHERE category IS NOT NULL ORDER BY category")) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) categories.add(rs.getString(1));
            } catch (Exception e) { e.printStackTrace(); }
            request.setAttribute("categories", categories);

            // ---- KPIs ----
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM shipment WHERE status NOT IN ('Delivered','Cancelled')")) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) activeShipments = rs.getInt(1);
            }

            String plQuery = "SELECT SUM(revenue_amount), SUM(total_cost_amount) FROM profit_loss pl " + where;
            PreparedStatement plPs = conn.prepareStatement(plQuery);
            for (int i = 0; i < params.size(); i++) plPs.setString(i + 1, params.get(i));
            ResultSet plRs = plPs.executeQuery();
            if (plRs.next()) {
                totalRevenue = plRs.getDouble(1);
                totalCost    = plRs.getDouble(2);
                netProfit    = totalRevenue - totalCost;
            }

            // ---- P&L Trend JSON ----
            StringBuilder plgJson = new StringBuilder("[");
            String trendQuery = "SELECT DATE_FORMAT(pl.record_date, '%d %b') as month, " +
                "SUM(pl.revenue_amount) as revenue, SUM(pl.total_cost_amount) as cost " +
                "FROM profit_loss pl " + where + " GROUP BY month ORDER BY MAX(pl.record_date) LIMIT 7";
            PreparedStatement trendPs = conn.prepareStatement(trendQuery);
            for (int i = 0; i < params.size(); i++) trendPs.setString(i + 1, params.get(i));
            ResultSet trendRs = trendPs.executeQuery();
            boolean first = true;
            while (trendRs.next()) {
                if (!first) plgJson.append(",");
                plgJson.append("{\"month\":\"").append(trendRs.getString("month")).append("\",")
                       .append("\"revenue\":").append(trendRs.getDouble("revenue")).append(",")
                       .append("\"cost\":").append(trendRs.getDouble("cost")).append("}");
                first = false;
            }
            plgJson.append("]");
            request.setAttribute("plgJson", plgJson.toString());

            // ---- Container Utilization ----
            int totalContainers = 842, inUseContainers = 643;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) as total, SUM(CASE WHEN status='In-Transit' THEN 1 ELSE 0 END) as inuse FROM containers")) {
                ResultSet rs = ps.executeQuery();
                if (rs.next() && rs.getInt("total") > 0) {
                    totalContainers  = rs.getInt("total");
                    inUseContainers  = rs.getInt("inuse");
                }
            }
            request.setAttribute("totalContainers", totalContainers);
            request.setAttribute("inUseContainers",  inUseContainers);
            request.setAttribute("idleContainers",   totalContainers - inUseContainers);
            double utilPct = totalContainers > 0 ? (inUseContainers * 100.0 / totalContainers) : 0;
            request.setAttribute("utilizationPct", String.format("%.1f", utilPct));

            // ---- On-Time Delivery Rate (was previously hardcoded to 78.6) ----
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) as total_delivered, " +
                    "SUM(CASE WHEN actual_arrival_date <= expected_arrival_date OR delay_days <= 0 THEN 1 ELSE 0 END) as on_time " +
                    "FROM container_movements WHERE actual_arrival_date IS NOT NULL")) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    int totalDelivered = rs.getInt("total_delivered");
                    int onTime = rs.getInt("on_time");
                    if (totalDelivered > 0) onTimePct = (onTime * 100.0 / totalDelivered);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        // ---- ABC Classification, Top Loss Reasons, Stock Valuation, Demand Forecast, Turnover ----
        // (Wired to the same real data the KPIs above already use, mirroring the existing plgJson pattern,
        // instead of the static placeholder chart data the page previously shipped with.)
        StringBuilder abcJson = new StringBuilder("[");
        boolean firstAbc = true;
        for (AbcResult a : analyticsDAO.getAbcResults(period, analyticsUserId)) {
            if (!firstAbc) abcJson.append(",");
            abcJson.append("{\"class\":\"Class ").append(a.getClassName()).append("\",\"count\":").append(a.getProductCount()).append("}");
            firstAbc = false;
        }
        abcJson.append("]");
        request.setAttribute("abcJson", abcJson.toString());

        StringBuilder lossJson = new StringBuilder("[");
        boolean firstLoss = true;
        double totalLossImpact = 0.0;
        for (LossReasonSummary l : analyticsDAO.getTopLossReasons(7, analyticsUserId)) {
            if (!firstLoss) lossJson.append(",");
            lossJson.append("{\"reason\":\"").append(l.getReasonName() != null ? l.getReasonName().replace("\"", "\\\"") : "").append("\",")
                    .append("\"impact\":").append(l.getTotalFinancialImpact()).append("}");
            totalLossImpact += l.getTotalFinancialImpact();
            firstLoss = false;
        }
        lossJson.append("]");
        request.setAttribute("lossJson", lossJson.toString());
        request.setAttribute("totalLossImpact", totalLossImpact);

        Integer stockCompanyId = null;
        try { if (filterCompany != null && !filterCompany.trim().isEmpty()) stockCompanyId = Integer.parseInt(filterCompany); } catch (Exception ignored) {}
        double currentStockValue = 0.0;
        java.util.Map<String, Double> stockByCategory = new java.util.LinkedHashMap<>();
        for (StockValuation sv : analyticsDAO.getStockValuation(stockCompanyId != null ? stockCompanyId : 0, analyticsUserId)) {
            String cat = (sv.getCategory() != null && !sv.getCategory().trim().isEmpty()) ? sv.getCategory() : "Uncategorized";
            if (filterCategory != null && !filterCategory.trim().isEmpty() && !filterCategory.equals(cat)) {
                continue; // Category filter applied (FR6.2)
            }
            currentStockValue += sv.getTotalInventoryValuation();
            stockByCategory.merge(cat, sv.getTotalInventoryValuation(), Double::sum);
        }
        request.setAttribute("currentStockValue", currentStockValue);

        StringBuilder stockValJson = new StringBuilder("[");
        boolean firstSv = true;
        for (java.util.Map.Entry<String, Double> e : stockByCategory.entrySet()) {
            if (!firstSv) stockValJson.append(",");
            stockValJson.append("{\"category\":\"").append(e.getKey().replace("\"", "\\\"")).append("\",")
                        .append("\"value\":").append(e.getValue()).append("}");
            firstSv = false;
        }
        stockValJson.append("]");
        request.setAttribute("stockValJson", stockValJson.toString());

        StringBuilder demandJson = new StringBuilder("[");
        boolean firstDf = true;
        for (DemandForecast df : analyticsDAO.getDemandForecast(null, null)) {
            if (!firstDf) demandJson.append(",");
            demandJson.append("{\"period\":\"").append(df.getForecastPeriod()).append("\",")
                      .append("\"demand\":").append(df.getForecastedDemand()).append("}");
            firstDf = false;
        }
        demandJson.append("]");
        request.setAttribute("demandJson", demandJson.toString());

        TurnoverResult turnover = analyticsDAO.getTurnoverResult(period, analyticsUserId);
        request.setAttribute("avgTurnoverRatio", turnover.getAvgTurnoverRatio());

        request.setAttribute("activeShipments", activeShipments);
        request.setAttribute("totalRevenue",    totalRevenue);
        request.setAttribute("totalCost",       totalCost);
        request.setAttribute("netProfit",       netProfit);
        request.setAttribute("onTimePct",       onTimePct);

        request.getRequestDispatcher("/jsp/analytics.jsp").forward(request, response);
    }

    private void exportCsv(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"analytics_report.csv\"");
        PrintWriter writer = response.getWriter();
        writer.println("Metric,Value");
        try (Connection conn = DBConnectionManager.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM shipment WHERE status NOT IN ('Delivered','Cancelled')")) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) writer.println("Active Shipments," + rs.getInt(1));
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT SUM(revenue_amount), SUM(total_cost_amount) FROM profit_loss")) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    writer.println("Total Revenue," + rs.getDouble(1));
                    writer.println("Total Cost,"    + rs.getDouble(2));
                    writer.println("Net Profit,"    + (rs.getDouble(1) - rs.getDouble(2)));
                }
            }
        } catch (Exception e) { writer.println("Error," + e.getMessage()); }
        writer.flush();
    }
}
