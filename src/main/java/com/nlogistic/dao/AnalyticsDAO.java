package com.nlogistic.dao;

import com.nlogistic.model.*;
import com.nlogistic.util.DBConnectionManager;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class AnalyticsDAO {

    public List<ActiveShipment> getActiveShipments(int companyId, int requestedBy) {
        List<ActiveShipment> list = new ArrayList<>();
        String sql = "{CALL get_active_shipments(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             java.sql.CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, companyId);
            cs.setInt(2, requestedBy);
            if (cs.execute()) {
                try (ResultSet rs = cs.getResultSet()) {
                    while (rs.next()) {
                        ActiveShipment as = new ActiveShipment();
                        as.setShipmentId(rs.getInt("shipment_id"));
                        as.setCustomerName(rs.getString("customer_name"));
                        as.setContainerNumber(rs.getString("container_number"));
                        as.setStatus(rs.getString("status"));
                        as.setOriginPort(rs.getString("origin_port"));
                        as.setDestinationPort(rs.getString("destination_port"));
                        list.add(as);
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<SalesTrendResult> getSalesTrends(String period) {
        List<SalesTrendResult> list = new ArrayList<>();
        String sql = "SELECT product_id, actual_sales, moving_avg, trend_label FROM sales_trend_result WHERE period = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, period);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SalesTrendResult st = new SalesTrendResult();
                    st.setProductId(rs.getInt("product_id"));
                    st.setActualSales(rs.getDouble("actual_sales"));
                    st.setMovingAvg(rs.getDouble("moving_avg"));
                    st.setTrendLabel(rs.getString("trend_label"));
                    list.add(st);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }


    public DashboardSummary getDashboardSummary(String period, int requestedBy) {
        DashboardSummary summary = new DashboardSummary();
        String sql = "{CALL get_dashboard_summary(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, period);
            cs.setInt(2, requestedBy);
            boolean hasResults = cs.execute();
            
            // Result 1: ABC
            // Result 2: Turnover
            if (cs.getMoreResults()) {
                // skip for summary object if needed, or parse
            }
            // Result 3: Profitability
            if (cs.getMoreResults()) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        summary.setTotalRevenue(rs.getDouble("total_revenue"));
                        summary.setNetProfit(rs.getDouble("total_net_profit"));
                    }
                }
            }
            // Result 4: Active Shipments
            if (cs.getMoreResults()) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) summary.setActiveShipments(rs.getInt("active_shipment_count"));
                }
            }
            // Result 5: Overdue Invoices
            if (cs.getMoreResults()) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        summary.setOverdueInvoices(rs.getInt("overdue_invoice_count"));
                        summary.setOverdueReceivables(rs.getDouble("total_overdue_receivables"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return summary;
    }

    public List<AbcResult> getAbcResults(String period, int requestedBy) {
        List<AbcResult> list = new ArrayList<>();
        String sql = "{CALL get_dashboard_summary(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, period);
            cs.setInt(2, requestedBy);
            if (cs.execute()) {
                try (ResultSet rs = cs.getResultSet()) {
                    while (rs.next()) {
                        AbcResult r = new AbcResult();
                        r.setClassName(rs.getString("class"));
                        r.setProductCount(rs.getInt("product_count"));
                        list.add(r);
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public TurnoverResult getTurnoverResult(String period, int requestedBy) {
        TurnoverResult t = new TurnoverResult();
        String sql = "{CALL get_dashboard_summary(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, period);
            cs.setInt(2, requestedBy);
            cs.execute();
            if (cs.getMoreResults()) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        t.setAvgTurnoverRatio(rs.getDouble("avg_turnover_ratio"));
                        t.setAvgDaysInInventory(rs.getDouble("avg_days_in_inventory"));
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return t;
    }

    public List<LossReasonSummary> getTopLossReasons(int limit, int requestedBy) {
        List<LossReasonSummary> list = new ArrayList<>();
        String sql = "{CALL get_top_loss_reasons(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, limit);
            cs.setInt(2, requestedBy);
            if (cs.execute()) {
                try (ResultSet rs = cs.getResultSet()) {
                    while (rs.next()) {
                        LossReasonSummary r = new LossReasonSummary();
                        r.setReasonName(rs.getString("reason_name"));
                        try { r.setCategory(rs.getString("category")); } catch (Exception ignored) { r.setCategory(""); }
                        r.setOccurrenceCount(rs.getInt("occurrence_count"));
                        r.setTotalFinancialImpact(rs.getDouble("total_financial_impact"));
                        list.add(r);
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public ContainerUtilization getContainerUtilization(int companyId, int requestedBy) {
        ContainerUtilization cu = new ContainerUtilization();
        String sql = "{CALL get_container_utilization(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, companyId);
            cs.setInt(2, requestedBy);
            if (cs.execute()) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        cu.setTotalContainers(rs.getInt("total_containers"));
                        cu.setInUseContainers(rs.getInt("in_use_containers"));
                        cu.setIdleContainers(rs.getInt("idle_containers"));
                        cu.setUtilizationRatePct(rs.getDouble("utilization_rate_pct"));
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return cu;
    }

    public List<StockValuation> getStockValuation(int companyId, int requestedBy) {
        List<StockValuation> list = new ArrayList<>();
        String sql = "{CALL get_stock_valuation(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, companyId);
            cs.setInt(2, requestedBy);
            if (cs.execute()) {
                try (ResultSet rs = cs.getResultSet()) {
                    while (rs.next()) {
                        StockValuation sv = new StockValuation();
                        sv.setProductName(rs.getString("product_name"));
                        sv.setCategory(rs.getString("category"));
                        try { sv.setWarehouseLocation(rs.getString("warehouse_location")); } catch (Exception ignored) {}
                        sv.setTotalQuantityOnHand(rs.getDouble("total_quantity_on_hand"));
                        sv.setTotalInventoryValuation(rs.getDouble("total_inventory_valuation"));
                        list.add(sv);
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Full itemized ABC Classification details joined with product names.
     * (Ported from module 6 draft - supports detail drill-down tables required by FR6.1/5.2.)
     */
    public List<AbcClassificationResult> getAbcDetails(String period) {
        List<AbcClassificationResult> list = new ArrayList<>();
        String sql = "SELECT a.*, p.product_name, p.category, " +
                     "(SELECT COALESCE(SUM(sale_amount), 0) FROM sales_transactions st WHERE st.product_id = a.product_id) as annual_rev " +
                     "FROM abc_classification_result a " +
                     "JOIN products p ON a.product_id = p.product_id " +
                     (period != null ? "WHERE a.computed_period = ? " : "") +
                     "ORDER BY a.cumulative_pct ASC";
        try (Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            if (period != null) ps.setString(1, period);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AbcClassificationResult r = new AbcClassificationResult();
                    r.setId(rs.getInt("id"));
                    r.setProductId(rs.getInt("product_id"));
                    r.setProductName(rs.getString("product_name"));
                    r.setCategory(rs.getString("category"));
                    r.setAnnualRevenue(rs.getDouble("annual_rev"));
                    r.setRevenueContributionPct(rs.getDouble("revenue_contribution_pct"));
                    r.setCumulativePct(rs.getDouble("cumulative_pct"));
                    r.setAbcClass(rs.getString("class"));
                    r.setComputedPeriod(rs.getString("computed_period"));
                    list.add(r);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Itemized Inventory Turnover results per product (Section 5.3).
     */
    public List<InventoryTurnoverResult> getTurnoverDetails(String period) {
        List<InventoryTurnoverResult> list = new ArrayList<>();
        String sql = "SELECT t.*, p.product_name, p.category " +
                     "FROM inventory_turnover_result t " +
                     "JOIN products p ON t.product_id = p.product_id " +
                     (period != null ? "WHERE t.period = ? " : "") +
                     "ORDER BY t.turnover_ratio DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            if (period != null) ps.setString(1, period);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InventoryTurnoverResult r = new InventoryTurnoverResult();
                    r.setId(rs.getInt("id"));
                    r.setProductId(rs.getInt("product_id"));
                    r.setProductName(rs.getString("product_name"));
                    r.setCategory(rs.getString("category"));
                    r.setPeriod(rs.getString("period"));
                    r.setCogsAmount(rs.getDouble("cogs_amount"));
                    r.setAvgInventoryValue(rs.getDouble("avg_inventory_value"));
                    r.setTurnoverRatio(rs.getDouble("turnover_ratio"));
                    r.setDaysInInventory(rs.getDouble("days_in_inventory"));
                    list.add(r);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Product Profitability Analysis table (Revenue - Direct COGS - Logistics = Net Profit) (Section 5.4).
     */
    public List<ProfitabilityResult> getProductProfitability(String period) {
        List<ProfitabilityResult> list = new ArrayList<>();
        String sql = "SELECT pr.*, p.product_name, p.category " +
                     "FROM profitability_result pr " +
                     "JOIN products p ON pr.product_id = p.product_id " +
                     (period != null ? "WHERE pr.period = ? " : "") +
                     "ORDER BY pr.net_profit DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            if (period != null) ps.setString(1, period);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProfitabilityResult r = new ProfitabilityResult();
                    r.setId(rs.getInt("id"));
                    r.setProductId(rs.getInt("product_id"));
                    r.setProductName(rs.getString("product_name"));
                    r.setCategory(rs.getString("category"));
                    r.setPeriod(rs.getString("period"));
                    r.setRevenue(rs.getDouble("revenue"));
                    r.setDirectCogs(rs.getDouble("direct_cogs"));
                    r.setAllocatedLogisticsCost(rs.getDouble("allocated_logistics_cost"));
                    r.setNetProfit(rs.getDouble("net_profit"));
                    r.setProfitMarginPct(rs.getDouble("profit_margin_pct"));
                    list.add(r);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Demand Forecasting projections (Section 5.5 / FR3.6 / FR6.1), filterable by container type and route.
     * Uses PreparedStatement parameters (unlike the module-6 draft, which concatenated containerType into
     * the SQL string) to avoid SQL injection.
     */
    public List<DemandForecast> getDemandForecast(String containerType, Integer routeId) {
        List<DemandForecast> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM demand_forecast WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (containerType != null && !containerType.trim().isEmpty() && !"All".equalsIgnoreCase(containerType)) {
            sql.append(" AND container_type = ? ");
            params.add(containerType);
        }
        if (routeId != null && routeId > 0) {
            sql.append(" AND route_id = ? ");
            params.add(routeId);
        }
        sql.append(" ORDER BY forecast_period ASC, forecasted_demand DESC");

        try (Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DemandForecast df = new DemandForecast();
                    df.setForecastId(rs.getInt("forecast_id"));
                    df.setContainerType(rs.getString("container_type"));
                    df.setRouteId(rs.getInt("route_id"));
                    df.setForecastPeriod(rs.getString("forecast_period"));
                    df.setForecastedDemand(rs.getDouble("forecasted_demand"));
                    df.setForecastedPrice(rs.getDouble("forecasted_price"));
                    df.setAlgorithmVersion(rs.getString("algorithm_version"));
                    list.add(df);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<CustomerProfitability> getCustomerProfitability(int requestedBy) {
        List<CustomerProfitability> list = new ArrayList<>();
        String sql = "{CALL get_customer_profitability(NULL, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, requestedBy);
            if (cs.execute()) {
                try (ResultSet rs = cs.getResultSet()) {
                    while (rs.next()) {
                        CustomerProfitability cp = new CustomerProfitability();
                        cp.setCustomerName(rs.getString("customer_name"));
                        cp.setTotalRevenue(rs.getDouble("total_revenue"));
                        cp.setTotalCost(rs.getDouble("total_cost"));
                        cp.setNetProfit(rs.getDouble("net_profit"));
                        list.add(cp);
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public void computeAllAnalytics(String period, int computedBy) {
        try (Connection conn = DBConnectionManager.getConnection()) {
            // The four compute_* procedures INSERT without clearing the previous run,
            // and computeAllAnalytics() is called on every /analytics page load. That
            // grew the four result tables to 21,301 rows for 200 products and made the
            // ABC chart climb on every refresh. Clear this period first so a recompute
            // replaces rather than accumulates.
            purgePeriod(conn, period);

            CallableStatement cs1 = conn.prepareCall("{CALL compute_abc_classification(?, ?)}");
            cs1.setString(1, period); cs1.setInt(2, computedBy); cs1.execute(); cs1.close();
            
            CallableStatement cs2 = conn.prepareCall("{CALL compute_inventory_turnover(?, ?)}");
            cs2.setString(1, period); cs2.setInt(2, computedBy); cs2.execute(); cs2.close();
            
            CallableStatement cs3 = conn.prepareCall("{CALL compute_profitability(?, ?)}");
            cs3.setString(1, period); cs3.setInt(2, computedBy); cs3.execute(); cs3.close();
            
            CallableStatement cs4 = conn.prepareCall("{CALL compute_sales_trend(?, ?)}");
            cs4.setString(1, period); cs4.setInt(2, computedBy); cs4.execute(); cs4.close();

            // SRS 5.5 / FR3.6 - Algorithm 5. This was missing entirely, so
            // demand_forecast never refreshed and both the predictive graph and the
            // FR3.5 demand multiplier ran on static seed rows.
            CallableStatement cs5 = conn.prepareCall("{CALL compute_demand_forecast(?, ?)}");
            cs5.setString(1, period); cs5.setInt(2, computedBy); cs5.execute(); cs5.close();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * Top Performing Trade Route by revenue (used on the executive dashboard KPI row).
     * Optionally scoped to a company and/or a date range on profit_loss.record_date.
     */
    public static class TopRoute {
        public String routeName = "N/A";
        public double totalRevenue = 0.0;
        public int shipmentCount = 0;
    }

    public TopRoute getTopTradeRoute(Integer companyId, String dateFrom, String dateTo) {
        TopRoute tr = new TopRoute();
        StringBuilder sql = new StringBuilder(
            "SELECT CONCAT(p1.port_name, ' → ', p2.port_name) as route_name, " +
            "COUNT(DISTINCT s.shipment_id) as shipment_count, " +
            "COALESCE(SUM(pl.revenue_amount), 0) as total_revenue " +
            "FROM shipment s " +
            "JOIN ports p1 ON s.origin_port_id = p1.port_id " +
            "JOIN ports p2 ON s.destination_port_id = p2.port_id " +
            "LEFT JOIN profit_loss pl ON pl.shipment_id = s.shipment_id "
        );
        List<Object> params = new ArrayList<>();
        StringBuilder where = new StringBuilder(" WHERE 1=1 ");
        if (companyId != null && companyId > 0) {
            where.append(" AND s.customer_id IN (SELECT customer_id FROM customers c JOIN users u ON c.user_id = u.user_id WHERE u.company_id = ?) ");
            params.add(companyId);
        }
        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            where.append(" AND (pl.record_date IS NULL OR pl.record_date >= ?) ");
            params.add(dateFrom);
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            where.append(" AND (pl.record_date IS NULL OR pl.record_date <= ?) ");
            params.add(dateTo);
        }
        sql.append(where)
           .append(" GROUP BY p1.port_id, p2.port_id, route_name ORDER BY total_revenue DESC LIMIT 1");

        try (Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    tr.routeName = rs.getString("route_name");
                    tr.totalRevenue = rs.getDouble("total_revenue");
                    tr.shipmentCount = rs.getInt("shipment_count");
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return tr;
    }

    // --- Legacy methods for old AnalyticsServlet ---
    public static class MonthlyProfit {
        public String month;
        public double revenue;
        public double cost;
    }

    public static class LossReasonStat {
        public String reasonName;
        public double totalLoss;
    }

    public List<MonthlyProfit> getMonthlyProfitLoss() {
        List<MonthlyProfit> list = new ArrayList<>();
        String sql = "SELECT DATE_FORMAT(record_date, '%Y-%m') as month, " +
                     "SUM(revenue_amount) as revenue, SUM(total_cost_amount) as cost " +
                     "FROM profit_loss GROUP BY month ORDER BY month";
        try (Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                MonthlyProfit mp = new MonthlyProfit();
                mp.month = rs.getString("month");
                mp.revenue = rs.getDouble("revenue");
                mp.cost = rs.getDouble("cost");
                list.add(mp);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<LossReasonStat> getLossReasonBreakdown() {
        List<LossReasonStat> list = new ArrayList<>();
        String sql = "SELECT lr.reason_name, SUM(pl.profit_loss_amount) as total_loss " +
                     "FROM profit_loss pl " +
                     "JOIN profit_loss_reason_map map ON pl.pl_id = map.pl_id " +
                     "JOIN loss_reasons lr ON map.reason_id = lr.reason_id " +
                     "WHERE pl.profit_loss_amount < 0 " +
                     "GROUP BY lr.reason_name ORDER BY total_loss ASC";
        try (Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LossReasonStat lr = new LossReasonStat();
                lr.reasonName = rs.getString("reason_name");
                // Math.abs to make it positive for the chart
                lr.totalLoss = Math.abs(rs.getDouble("total_loss"));
                list.add(lr);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Demand forecast aggregated for the dashboard card.
     *
     * getDemandForecast(null, null) returns one row per lane per period. Once
     * Algorithm 5 began producing real per-lane forecasts that became ~600 rows,
     * and the chart plotted every one of them - repeating each quarter label and
     * stacking bars on top of each other. The card wants total projected demand
     * per period, so aggregate here.
     *
     * @param containerType optional filter; null/blank = every type.
     */
    public java.util.List<java.util.Map<String, Object>> getDemandForecastByPeriod(String containerType) {
        java.util.List<java.util.Map<String, Object>> out = new java.util.ArrayList<>();
        boolean filtered = containerType != null && !containerType.trim().isEmpty()
                && !"All".equalsIgnoreCase(containerType.trim());

        String sql = "SELECT forecast_period, SUM(forecasted_demand) AS demand, AVG(forecasted_price) AS price "
                   + "FROM demand_forecast "
                   + "WHERE algorithm_version = (SELECT algorithm_version FROM demand_forecast "
                   + "                            ORDER BY generated_at DESC, forecast_id DESC LIMIT 1) "
                   + (filtered ? "AND container_type = ? " : "")
                   + "GROUP BY forecast_period ORDER BY forecast_period ASC LIMIT 6";

        try (java.sql.Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            if (filtered) ps.setString(1, containerType.trim());
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> m = new java.util.LinkedHashMap<>();
                    m.put("period", rs.getString("forecast_period"));
                    m.put("demand", Math.round(rs.getDouble("demand") * 100.0) / 100.0);
                    m.put("price", Math.round(rs.getDouble("price") * 100.0) / 100.0);
                    out.add(m);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return out;
    }

    /** Container types that actually have a forecast, for the card's filter. */
    public java.util.List<String> getForecastContainerTypes() {
        java.util.List<String> types = new java.util.ArrayList<>();
        String sql = "SELECT DISTINCT container_type FROM demand_forecast ORDER BY container_type";
        try (java.sql.Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             java.sql.ResultSet rs = ps.executeQuery()) {
            while (rs.next()) types.add(rs.getString(1));
        } catch (Exception e) { e.printStackTrace(); }
        return types;
    }

    /**
     * FR5.8 / FR6.1 - invoice aging buckets from real receivables.
     *
     * The Invoice Aging widget on analytics.jsp was hardcoded HTML (55/20/15/10%
     * with a fixed total). This returns the actual outstanding balance split by how
     * far past its due date each invoice is.
     *
     * @param companyId tenant scope; null = all companies (Super Admin).
     */
    public java.util.Map<String, Double> getInvoiceAging(Integer companyId) {
        java.util.Map<String, Double> out = new java.util.LinkedHashMap<>();
        out.put("current", 0.0); out.put("d31_60", 0.0);
        out.put("d61_90", 0.0);  out.put("d90plus", 0.0);
        out.put("total", 0.0);   out.put("overdue", 0.0);

        String sql = "SELECT DATEDIFF(CURDATE(), bi.due_date) AS days_late, "
                   + "       SUM(bi.total_amount - bi.paid_amount) AS balance "
                   + "FROM billing_invoices bi "
                   + (companyId != null
                        ? "JOIN shipment s ON s.shipment_id = bi.shipment_id "
                        + "LEFT JOIN containers c ON c.container_id = s.container_id " : "")
                   + "WHERE bi.total_amount > bi.paid_amount "
                   + (companyId != null
                        ? "AND (c.owner_company_id = ? OR s.created_by IN "
                        + "     (SELECT user_id FROM users WHERE company_id = ?)) " : "")
                   + "GROUP BY DATEDIFF(CURDATE(), bi.due_date)";

        try (java.sql.Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            if (companyId != null) { ps.setInt(1, companyId); ps.setInt(2, companyId); }
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int late = rs.getInt("days_late");
                    double bal = rs.getDouble("balance");
                    String bucket = (late <= 30) ? "current"
                                  : (late <= 60) ? "d31_60"
                                  : (late <= 90) ? "d61_90" : "d90plus";
                    out.put(bucket, out.get(bucket) + bal);
                    out.put("total", out.get("total") + bal);
                    if (late > 0) out.put("overdue", out.get("overdue") + bal);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return out;
    }

    /**
     * SRS 5.3 inputs - COGS and average inventory value, computed live.
     * inventory_turnover_result.cogs_amount is 0 on most cached rows, so the
     * analytics card was showing fixed placeholder rupee figures instead.
     */
    public java.util.Map<String, Double> getTurnoverInputs(Integer companyId) {
        java.util.Map<String, Double> out = new java.util.LinkedHashMap<>();
        out.put("cogs", 0.0);
        out.put("avgInventoryValue", 0.0);

        String cogsSql = "SELECT COALESCE(SUM(st.quantity_sold * p.unit_cost), 0) AS cogs "
                       + "FROM sales_transactions st JOIN products p ON p.product_id = st.product_id";
        String invSql  = "SELECT COALESCE(SUM(s.quantity_on_hand * p.unit_cost), 0) AS inv "
                       + "FROM stock s JOIN products p ON p.product_id = s.product_id"
                       + (companyId != null ? " WHERE s.company_id = ?" : "");

        try (java.sql.Connection conn = DBConnectionManager.getConnection()) {
            try (java.sql.PreparedStatement ps = conn.prepareStatement(cogsSql);
                 java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) out.put("cogs", rs.getDouble("cogs"));
            }
            try (java.sql.PreparedStatement ps = conn.prepareStatement(invSql)) {
                if (companyId != null) ps.setInt(1, companyId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) out.put("avgInventoryValue", rs.getDouble("inv"));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return out;
    }

    /* ==================================================================
     * FR6.2 - "All dashboard charts shall be filterable by date range,
     * company, route, and product/category."
     *
     * Gap 2: only the KPI totals and the P&L trend honoured the filter bar.
     * Container utilisation, ABC, loss reasons and turnover each ran their own
     * unfiltered query, so selecting a company still left competitor figures on
     * screen. These variants take the same filter set.
     * ================================================================== */

    /** Fleet utilisation, optionally limited to one company's containers. */
    public double[] getContainerUtilization(Integer companyId) {
        double[] out = new double[]{0, 0, 0}; // total, inUse, pct
        String sql = "SELECT COUNT(*) AS total, "
                   + "SUM(CASE WHEN status IN ('In-Transit','Allocated') THEN 1 ELSE 0 END) AS inuse "
                   + "FROM containers"
                   + (companyId != null ? " WHERE owner_company_id = ?" : "");
        try (java.sql.Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            if (companyId != null) ps.setInt(1, companyId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    out[0] = rs.getInt("total");
                    out[1] = rs.getInt("inuse");
                    out[2] = out[0] > 0 ? (out[1] * 100.0 / out[0]) : 0.0;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return out;
    }

    /** ABC class distribution, optionally limited to one product category. */
    public java.util.List<java.util.Map<String, Object>> getAbcDistribution(String period, String category) {
        java.util.List<java.util.Map<String, Object>> out = new java.util.ArrayList<>();
        boolean byCat = category != null && !category.trim().isEmpty() && !"All".equalsIgnoreCase(category.trim());
        String sql = "SELECT r.class AS cls, COUNT(*) AS n "
                   + "FROM abc_classification_result r "
                   + "JOIN products p ON p.product_id = r.product_id "
                   + "WHERE r.computed_period = ? "
                   + (byCat ? "AND p.category = ? " : "")
                   + "GROUP BY r.class ORDER BY r.class";
        try (java.sql.Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, period);
            if (byCat) ps.setString(2, category.trim());
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> m = new java.util.LinkedHashMap<>();
                    m.put("cls", rs.getString("cls"));
                    m.put("count", rs.getInt("n"));
                    out.add(m);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return out;
    }

    /** Top loss reasons under the active company / date / route filters. */
    public java.util.List<java.util.Map<String, Object>> getTopLossReasonsFiltered(
            int limit, Integer companyId, String dateFrom, String dateTo,
            String originPortId, String destPortId) {

        java.util.List<java.util.Map<String, Object>> out = new java.util.ArrayList<>();
        StringBuilder sql = new StringBuilder(
              "SELECT lr.reason_name, COUNT(m.id) AS occurrences, "
            + "       COALESCE(ABS(SUM(pl.profit_loss_amount)), 0) AS impact "
            + "FROM loss_reasons lr "
            + "JOIN profit_loss_reason_map m ON m.reason_id = lr.reason_id "
            + "JOIN profit_loss pl ON pl.pl_id = m.pl_id "
            + "LEFT JOIN shipment s ON s.shipment_id = pl.shipment_id "
            + "LEFT JOIN containers c ON c.container_id = s.container_id "
            + "WHERE 1=1 ");
        java.util.List<Object> args = new java.util.ArrayList<>();

        if (companyId != null) {
            sql.append("AND (c.owner_company_id = ? OR s.created_by IN "
                     + "(SELECT user_id FROM users WHERE company_id = ?)) ");
            args.add(companyId); args.add(companyId);
        }
        if (dateFrom != null && !dateFrom.trim().isEmpty()) { sql.append("AND pl.record_date >= ? "); args.add(dateFrom.trim()); }
        if (dateTo   != null && !dateTo.trim().isEmpty())   { sql.append("AND pl.record_date <= ? "); args.add(dateTo.trim()); }
        if (originPortId != null && destPortId != null) {
            sql.append("AND s.origin_port_id = ? AND s.destination_port_id = ? ");
            args.add(originPortId); args.add(destPortId);
        }
        sql.append("GROUP BY lr.reason_id, lr.reason_name ORDER BY impact DESC LIMIT ").append(Math.max(1, limit));

        try (java.sql.Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < args.size(); i++) ps.setObject(i + 1, args.get(i));
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> m = new java.util.LinkedHashMap<>();
                    m.put("reason", rs.getString("reason_name"));
                    m.put("impact", Math.round(rs.getDouble("impact") * 100.0) / 100.0);
                    m.put("occurrences", rs.getInt("occurrences"));
                    out.add(m);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return out;
    }

    /** Stock valuation by category, optionally limited to one category. */
    public java.util.List<java.util.Map<String, Object>> getStockValuationByCategory(Integer companyId, String category) {
        java.util.List<java.util.Map<String, Object>> out = new java.util.ArrayList<>();
        boolean byCat = category != null && !category.trim().isEmpty() && !"All".equalsIgnoreCase(category.trim());
        String sql = "SELECT p.category, COALESCE(SUM(s.quantity_on_hand * p.unit_cost), 0) AS value "
                   + "FROM stock s JOIN products p ON p.product_id = s.product_id WHERE 1=1 "
                   + (companyId != null ? "AND s.company_id = ? " : "")
                   + (byCat ? "AND p.category = ? " : "")
                   + "GROUP BY p.category ORDER BY value DESC";
        try (java.sql.Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            int i = 1;
            if (companyId != null) ps.setInt(i++, companyId);
            if (byCat) ps.setString(i, category.trim());
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> m = new java.util.LinkedHashMap<>();
                    m.put("category", rs.getString("category"));
                    m.put("value", Math.round(rs.getDouble("value") * 100.0) / 100.0);
                    out.add(m);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return out;
    }

    /** Distinct product categories, for the analytics category filter. */
    public java.util.List<String> getProductCategories() {
        java.util.List<String> out = new java.util.ArrayList<>();
        try (java.sql.Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(
                 "SELECT DISTINCT category FROM products WHERE category IS NOT NULL AND category <> '' ORDER BY category");
             java.sql.ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(rs.getString(1));
        } catch (Exception e) { e.printStackTrace(); }
        return out;
    }

    /**
     * Removes the cached analytical results for one period so a recompute is
     * idempotent. These are derived tables (SRS 6.9 "cached outputs for dashboard
     * performance"), rebuilt immediately by the procedures that follow.
     */
    private void purgePeriod(java.sql.Connection conn, String period) {
        String[] statements = {
            "DELETE FROM abc_classification_result WHERE computed_period = ?",
            "DELETE FROM inventory_turnover_result WHERE period = ?",
            "DELETE FROM profitability_result WHERE period = ?",
            "DELETE FROM sales_trend_result WHERE period = ?"
        };
        for (String sql : statements) {
            try (java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, period);
                ps.executeUpdate();
            } catch (Exception e) {
                // A schema variation on one table must not stop the others.
                e.printStackTrace();
            }
        }
    }

    /* ==================================================================
     * Company scoping for the widgets that were still reading globally.
     *
     * A newly registered carrier with one container opened /analytics and saw
     * 200 ABC-classified products, a six-quarter demand forecast and a COGS of
     * 20.5 million - the whole platform's data, presented as its own. These
     * queries take the same company scope the rest of the page already uses.
     * ================================================================== */

    /** ABC distribution over the products this company actually holds. */
    public java.util.List<java.util.Map<String, Object>> getAbcDistribution(String period, String category, Integer companyId) {
        java.util.List<java.util.Map<String, Object>> out = new java.util.ArrayList<>();
        boolean byCat = category != null && !category.trim().isEmpty() && !"All".equalsIgnoreCase(category.trim());
        StringBuilder sql = new StringBuilder(
              "SELECT r.class AS cls, COUNT(DISTINCT r.product_id) AS n "
            + "FROM abc_classification_result r "
            + "JOIN products p ON p.product_id = r.product_id ");
        if (companyId != null) sql.append("JOIN stock st ON st.product_id = r.product_id AND st.company_id = ? ");
        sql.append("WHERE r.computed_period = ? ");
        if (byCat) sql.append("AND p.category = ? ");
        sql.append("GROUP BY r.class ORDER BY r.class");

        try (java.sql.Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int i = 1;
            if (companyId != null) ps.setInt(i++, companyId);
            ps.setString(i++, period);
            if (byCat) ps.setString(i, category.trim());
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> m = new java.util.LinkedHashMap<>();
                    m.put("cls", rs.getString("cls"));
                    m.put("count", rs.getInt("n"));
                    out.add(m);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return out;
    }

    /**
     * Demand forecast limited to the lanes and container types this company
     * actually ships on. A carrier that has never sailed a route has no demand
     * to forecast on it, and showing the platform-wide curve implied otherwise.
     */
    public java.util.List<java.util.Map<String, Object>> getDemandForecastByPeriod(String containerType, Integer companyId) {
        java.util.List<java.util.Map<String, Object>> out = new java.util.ArrayList<>();
        boolean byType = containerType != null && !containerType.trim().isEmpty()
                      && !"All".equalsIgnoreCase(containerType.trim());
        StringBuilder sql = new StringBuilder(
              "SELECT f.forecast_period AS period, ROUND(SUM(f.forecasted_demand)) AS demand "
            + "FROM demand_forecast f WHERE 1=1 ");
        if (byType) sql.append("AND f.container_type = ? ");
        if (companyId != null) {
            sql.append("AND EXISTS (SELECT 1 FROM shipment s "
                     + "  JOIN containers c ON c.container_id = s.container_id "
                     + "  WHERE c.owner_company_id = ? AND c.type = f.container_type "
                     + "    AND COALESCE(s.origin_port_id, 1) = f.route_id) ");
        }
        sql.append("GROUP BY f.forecast_period ORDER BY f.forecast_period");

        try (java.sql.Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int i = 1;
            if (byType) ps.setString(i++, containerType.trim());
            if (companyId != null) ps.setInt(i, companyId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> m = new java.util.LinkedHashMap<>();
                    m.put("period", rs.getString("period"));
                    m.put("demand", rs.getInt("demand"));
                    out.add(m);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return out;
    }

    /**
     * Turnover inputs. Cost of goods sold was read across the whole platform
     * while average inventory value was already scoped, so a company with no
     * stock showed a multi-million COGS against zero inventory.
     */
    public java.util.Map<String, Double> getTurnoverInputs(Integer companyId, boolean scoped) {
        java.util.Map<String, Double> out = new java.util.LinkedHashMap<>();
        out.put("cogs", 0.0);
        out.put("avgInventoryValue", 0.0);

        String cogsSql = "SELECT COALESCE(SUM(st.quantity_sold * p.unit_cost), 0) AS cogs "
                       + "FROM sales_transactions st JOIN products p ON p.product_id = st.product_id "
                       + (companyId != null
                          ? "LEFT JOIN shipment sh ON sh.shipment_id = st.shipment_id "
                          + "LEFT JOIN containers c ON c.container_id = sh.container_id "
                          + "WHERE c.owner_company_id = ? " : "");
        String invSql  = "SELECT COALESCE(SUM(s.quantity_on_hand * p.unit_cost), 0) AS inv "
                       + "FROM stock s JOIN products p ON p.product_id = s.product_id"
                       + (companyId != null ? " WHERE s.company_id = ?" : "");

        try (java.sql.Connection conn = DBConnectionManager.getConnection()) {
            try (java.sql.PreparedStatement ps = conn.prepareStatement(cogsSql)) {
                if (companyId != null) ps.setInt(1, companyId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) out.put("cogs", rs.getDouble("cogs"));
                }
            }
            try (java.sql.PreparedStatement ps = conn.prepareStatement(invSql)) {
                if (companyId != null) ps.setInt(1, companyId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) out.put("avgInventoryValue", rs.getDouble("inv"));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return out;
    }

    /** On-time delivery rate over this company's own movements. */
    public double getOnTimeRate(Integer companyId) {
        String sql = "SELECT COUNT(*) AS total, "
                   + "SUM(CASE WHEN m.actual_arrival_date <= m.expected_arrival_date OR m.delay_days <= 0 THEN 1 ELSE 0 END) AS on_time "
                   + "FROM container_movements m "
                   + (companyId != null
                      ? "JOIN shipment s ON s.shipment_id = m.shipment_id "
                      + "LEFT JOIN containers c ON c.container_id = s.container_id " : "")
                   + "WHERE m.actual_arrival_date IS NOT NULL "
                   + (companyId != null ? "AND c.owner_company_id = ? " : "");
        try (java.sql.Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            if (companyId != null) ps.setInt(1, companyId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int total = rs.getInt("total");
                    if (total > 0) return rs.getInt("on_time") * 100.0 / total;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return 0.0;
    }

    /**
     * FR2.6 profit & loss trend at a chosen granularity.
     *
     * Only the Month tab was ever real. Day, Week, Quarter and Year returned
     * arrays typed into the JSP - the same invented curve on every account,
     * including one that had never shipped anything.
     *
     * @param granularity day | week | month | quarter | year
     */
    public java.util.List<java.util.Map<String, Object>> getPlgSeries(String granularity, Integer companyId) {
        java.util.List<java.util.Map<String, Object>> out = new java.util.ArrayList<>();

        String label, group, order, window;
        String g = (granularity == null) ? "month" : granularity.trim().toLowerCase();
        switch (g) {
            case "day":
                label = "DATE_FORMAT(pl.record_date, '%d %b')";
                group = "DATE(pl.record_date)";
                window = "AND pl.record_date >= DATE_SUB(CURDATE(), INTERVAL 14 DAY) ";
                break;
            case "week":
                label = "CONCAT('Wk ', WEEK(pl.record_date, 3))";
                group = "YEARWEEK(pl.record_date, 3)";
                window = "AND pl.record_date >= DATE_SUB(CURDATE(), INTERVAL 8 WEEK) ";
                break;
            case "quarter":
                label = "CONCAT('Q', QUARTER(pl.record_date), ' ', YEAR(pl.record_date))";
                group = "YEAR(pl.record_date), QUARTER(pl.record_date)";
                window = "AND pl.record_date >= DATE_SUB(CURDATE(), INTERVAL 8 QUARTER) ";
                break;
            case "year":
                label = "YEAR(pl.record_date)";
                group = "YEAR(pl.record_date)";
                window = "";
                break;
            default:
                label = "DATE_FORMAT(pl.record_date, '%b %Y')";
                group = "YEAR(pl.record_date), MONTH(pl.record_date)";
                window = "AND pl.record_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH) ";
                break;
        }
        order = group;

        String sql = "SELECT " + label + " AS lbl, "
                   + "COALESCE(SUM(pl.revenue_amount), 0) AS revenue, "
                   + "COALESCE(SUM(pl.total_cost_amount), 0) AS cost "
                   + "FROM profit_loss pl "
                   + (companyId != null
                      ? "LEFT JOIN shipment s ON s.shipment_id = pl.shipment_id "
                      + "LEFT JOIN containers c ON c.container_id = s.container_id " : "")
                   + "WHERE 1=1 " + window
                   + (companyId != null
                      ? "AND (c.owner_company_id = ? OR s.created_by IN "
                      + "(SELECT user_id FROM users WHERE company_id = ?)) " : "")
                   + "GROUP BY " + group + " ORDER BY " + order;

        try (java.sql.Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            if (companyId != null) { ps.setInt(1, companyId); ps.setInt(2, companyId); }
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> m = new java.util.LinkedHashMap<>();
                    m.put("label", rs.getString("lbl"));
                    m.put("revenue", rs.getDouble("revenue"));
                    m.put("cost", rs.getDouble("cost"));
                    out.add(m);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return out;
    }

    /**
     * Month-over-month change for the KPI cards.
     *
     * The five badges under the headline figures read "12% / 18% / 9% / 32% /
     * 4.2% vs Apr 2025" on every account and in every month, because those
     * numbers were literals in the markup.
     */
    public java.util.Map<String, Double> getKpiDeltas(Integer companyId) {
        java.util.Map<String, Double> out = new java.util.LinkedHashMap<>();
        String scope = (companyId != null)
                ? "LEFT JOIN shipment s ON s.shipment_id = pl.shipment_id "
                + "LEFT JOIN containers c ON c.container_id = s.container_id "
                + "WHERE (c.owner_company_id = ? OR s.created_by IN (SELECT user_id FROM users WHERE company_id = ?)) AND "
                : "WHERE ";

        String sql = "SELECT "
                + "COALESCE(SUM(CASE WHEN pl.record_date >= DATE_FORMAT(CURDATE(), '%Y-%m-01') THEN pl.revenue_amount END), 0) AS rev_now, "
                + "COALESCE(SUM(CASE WHEN pl.record_date >= DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m-01') "
                + "                   AND pl.record_date <  DATE_FORMAT(CURDATE(), '%Y-%m-01') THEN pl.revenue_amount END), 0) AS rev_prev, "
                + "COALESCE(SUM(CASE WHEN pl.record_date >= DATE_FORMAT(CURDATE(), '%Y-%m-01') THEN pl.total_cost_amount END), 0) AS cost_now, "
                + "COALESCE(SUM(CASE WHEN pl.record_date >= DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m-01') "
                + "                   AND pl.record_date <  DATE_FORMAT(CURDATE(), '%Y-%m-01') THEN pl.total_cost_amount END), 0) AS cost_prev "
                + "FROM profit_loss pl " + scope + " 1=1";

        try (java.sql.Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            if (companyId != null) { ps.setInt(1, companyId); ps.setInt(2, companyId); }
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double revNow = rs.getDouble("rev_now"), revPrev = rs.getDouble("rev_prev");
                    double costNow = rs.getDouble("cost_now"), costPrev = rs.getDouble("cost_prev");
                    out.put("revenue", pctChange(revNow, revPrev));
                    out.put("cost", pctChange(costNow, costPrev));
                    out.put("profit", pctChange(revNow - costNow, revPrev - costPrev));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return out;
    }

    /** null when there is no prior period to compare against, so the view can stay silent. */
    private static Double pctChange(double now, double prev) {
        if (prev == 0) return null;
        return Math.round((now - prev) / Math.abs(prev) * 1000.0) / 10.0;
    }
}
