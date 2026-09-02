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
                        sv.setTotalQuantityOnHand(rs.getDouble("total_quantity_on_hand"));
                        sv.setTotalInventoryValuation(rs.getDouble("total_inventory_valuation"));
                        list.add(sv);
                    }
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
