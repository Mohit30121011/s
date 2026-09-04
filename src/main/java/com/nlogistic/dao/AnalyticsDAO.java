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
            CallableStatement cs1 = conn.prepareCall("{CALL compute_abc_classification(?, ?)}");
            cs1.setString(1, period); cs1.setInt(2, computedBy); cs1.execute(); cs1.close();
            
            CallableStatement cs2 = conn.prepareCall("{CALL compute_inventory_turnover(?, ?)}");
            cs2.setString(1, period); cs2.setInt(2, computedBy); cs2.execute(); cs2.close();
            
            CallableStatement cs3 = conn.prepareCall("{CALL compute_profitability(?, ?)}");
            cs3.setString(1, period); cs3.setInt(2, computedBy); cs3.execute(); cs3.close();
            
            CallableStatement cs4 = conn.prepareCall("{CALL compute_sales_trend(?, ?)}");
            cs4.setString(1, period); cs4.setInt(2, computedBy); cs4.execute(); cs4.close();
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
}
