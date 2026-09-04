package com.nlogistic.controller;

import com.nlogistic.dao.AnalyticsDAO;
import com.nlogistic.dao.ClaimDAO;
import com.nlogistic.util.DBConnectionManager;
import com.nlogistic.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/dashboard/executive")
public class ExecutiveDashboardServlet extends HttpServlet {
    private AnalyticsDAO analyticsDAO = new AnalyticsDAO();
    private ClaimDAO claimDAO = new ClaimDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        Integer userId = user != null ? user.getUserId() : 1;
        Integer sessionCompanyId = user != null ? user.getCompanyId() : null;

        String period = new SimpleDateFormat("yyyy-MM").format(new Date());

        // ---- FR6.2 Filter bar: Company, Route, Category, Date From/To ----
        String filterCompanyParam = request.getParameter("company");
        String filterRoute        = request.getParameter("route");
        String filterCategory     = request.getParameter("category");
        String filterDateFrom     = request.getParameter("dateFrom");
        String filterDateTo       = request.getParameter("dateTo");

        Integer companyId = sessionCompanyId;
        if (filterCompanyParam != null && !filterCompanyParam.trim().isEmpty()) {
            try { companyId = Integer.parseInt(filterCompanyParam); } catch (Exception ignored) {}
        }

        request.setAttribute("filterCompany",  filterCompanyParam != null ? filterCompanyParam : "");
        request.setAttribute("filterRoute",    filterRoute    != null ? filterRoute    : "");
        request.setAttribute("filterCategory", filterCategory != null ? filterCategory : "");
        request.setAttribute("filterDateFrom", filterDateFrom != null ? filterDateFrom : "");
        request.setAttribute("filterDateTo",   filterDateTo   != null ? filterDateTo   : "");
        loadFilterDropdowns(request);

        // Force compute algorithms before fetching data (for demonstration purposes so dashboard is always fresh)
        analyticsDAO.computeAllAnalytics(period, userId);

        // Fetch Data
        DashboardSummary summary = analyticsDAO.getDashboardSummary(period, userId);
        List<AbcResult> abcResults = analyticsDAO.getAbcResults(period, userId);
        TurnoverResult turnover = analyticsDAO.getTurnoverResult(period, userId);
        List<LossReasonSummary> topLossReasons = analyticsDAO.getTopLossReasons(5, userId);
        ContainerUtilization utilization = analyticsDAO.getContainerUtilization(companyId != null ? companyId : 0, userId);
        List<StockValuation> stockValuations = analyticsDAO.getStockValuation(companyId != null ? companyId : 0, userId);
        List<CustomerProfitability> customerProfitabilities = analyticsDAO.getCustomerProfitability(userId);

        // Set Attributes
        request.setAttribute("summary", summary);
        request.setAttribute("abcResults", abcResults);
        request.setAttribute("turnover", turnover);
        request.setAttribute("topLossReasons", topLossReasons);
        request.setAttribute("utilization", utilization);
        request.setAttribute("stockValuations", stockValuations);
        request.setAttribute("customerProfitabilities", customerProfitabilities);
        
        List<ActiveShipment> activeShipments = analyticsDAO.getActiveShipments(companyId != null ? companyId : 0, userId);
        List<SalesTrendResult> salesTrends = analyticsDAO.getSalesTrends(period);
        request.setAttribute("activeShipments", activeShipments);
        request.setAttribute("salesTrends", salesTrends);

        // FR6.1 also requires demand forecast on the role-based dashboard (was previously missing here).
        List<DemandForecast> demandForecast = analyticsDAO.getDemandForecast(null, null);
        request.setAttribute("demandForecast", demandForecast);

        // ---- Remaining FR6.1 KPIs: Gross Margin, On-Time Delivery %, Total Inventory Value, ----
        // ---- Inventory Turnover Ratio, Pending Claims Count, Top Performing Trade Route      ----

        // Gross Profit Margin (derived from the KPIs already fetched above)
        double grossMarginPct = summary.getTotalRevenue() > 0
                ? (summary.getNetProfit() / summary.getTotalRevenue()) * 100.0 : 0.0;
        request.setAttribute("grossMarginPct", grossMarginPct);

        // On-Time Delivery % (container_movements delay_days / actual vs expected arrival)
        double onTimeDeliveryPct = 0.0;
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) as total_delivered, " +
                "SUM(CASE WHEN actual_arrival_date <= expected_arrival_date OR delay_days <= 0 THEN 1 ELSE 0 END) as on_time " +
                "FROM container_movements WHERE actual_arrival_date IS NOT NULL")) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int totalDelivered = rs.getInt("total_delivered");
                int onTime = rs.getInt("on_time");
                if (totalDelivered > 0) onTimeDeliveryPct = (onTime * 100.0 / totalDelivered);
            }
        } catch (Exception e) { e.printStackTrace(); }
        request.setAttribute("onTimeDeliveryPct", onTimeDeliveryPct);

        // Total Inventory Value (sum of the stock valuation rows already fetched above)
        double totalInventoryValue = 0.0;
        for (StockValuation sv : stockValuations) totalInventoryValue += sv.getTotalInventoryValuation();
        request.setAttribute("totalInventoryValue", totalInventoryValue);

        // Inventory Turnover Ratio - reuse the same TurnoverResult (Section 5.3 / compute_inventory_turnover)
        // already fetched into `turnover` above; exposed here under its own KPI-friendly attribute name.
        request.setAttribute("turnoverRatio", turnover.getAvgTurnoverRatio());

        // Pending Claims Count (Filed + Under Review), via ClaimDAO.getClaimStats()
        Map<String, Object> claimStats = claimDAO.getClaimStats();
        int pendingClaims = 0;
        try {
            pendingClaims = ((Number) claimStats.getOrDefault("filed", 0)).intValue()
                          + ((Number) claimStats.getOrDefault("underReview", 0)).intValue();
        } catch (Exception ignored) {}
        request.setAttribute("pendingClaimsCount", pendingClaims);

        // Top Performing Trade Route (highest-revenue route), filtered by company/date range where applied
        AnalyticsDAO.TopRoute topRoute = analyticsDAO.getTopTradeRoute(companyId, filterDateFrom, filterDateTo);
        request.setAttribute("topRoute", topRoute);

        request.getRequestDispatcher("/jsp/executive_dashboard.jsp").forward(request, response);
    }

    private void loadFilterDropdowns(HttpServletRequest request) {
        try (Connection conn = DBConnectionManager.getConnection()) {
            List<String[]> companies = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT company_id, company_name FROM companies WHERE approval_status='Active' ORDER BY company_name")) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) companies.add(new String[]{rs.getString(1), rs.getString(2)});
            }
            request.setAttribute("companies", companies);

            List<String[]> routes = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT DISTINCT CONCAT(p1.port_name, ' → ', p2.port_name) as route_name, " +
                    "CONCAT(p1.port_id, '-', p2.port_id) as route_id FROM shipment s " +
                    "JOIN ports p1 ON s.origin_port_id = p1.port_id " +
                    "JOIN ports p2 ON s.destination_port_id = p2.port_id ORDER BY route_name LIMIT 30")) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) routes.add(new String[]{rs.getString("route_id"), rs.getString("route_name")});
            }
            request.setAttribute("routes", routes);

            List<String> categories = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT DISTINCT category FROM products WHERE category IS NOT NULL ORDER BY category")) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) categories.add(rs.getString(1));
            }
            request.setAttribute("categories", categories);
        } catch (Exception e) { e.printStackTrace(); }
    }
}
