package com.nlogistic.dao;

import com.nlogistic.util.DBConnectionManager;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ProfitLossDAO {

    public static class ProfitLossKPI {
        private double totalRevenue;
        private double totalCost;
        private double netProfitLoss;

        public double getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(double totalRevenue) { this.totalRevenue = totalRevenue; }
        public double getTotalCost() { return totalCost; }
        public void setTotalCost(double totalCost) { this.totalCost = totalCost; }
        public double getNetProfitLoss() { return netProfitLoss; }
        public void setNetProfitLoss(double netProfitLoss) { this.netProfitLoss = netProfitLoss; }
    }

    public static class ProfitLossTrend {
        private String monthYear;
        private double profitLossAmount;

        public String getMonthYear() { return monthYear; }
        public void setMonthYear(String monthYear) { this.monthYear = monthYear; }
        public double getProfitLossAmount() { return profitLossAmount; }
        public void setProfitLossAmount(double profitLossAmount) { this.profitLossAmount = profitLossAmount; }
    }

    public static class LossReasonImpact {
        private String reasonName;
        private String category;
        private double totalImpact;

        public String getReasonName() { return reasonName; }
        public void setReasonName(String reasonName) { this.reasonName = reasonName; }
        public String getCategory() { return category; }
        public void setCategory(String category) { this.category = category; }
        public double getTotalImpact() { return totalImpact; }
        public void setTotalImpact(double totalImpact) { this.totalImpact = totalImpact; }
    }

    public static class CustomerProfitability {
        private String customerName;
        private double totalRevenue;
        private double totalCost;
        private double netProfit;

        public String getCustomerName() { return customerName; }
        public void setCustomerName(String customerName) { this.customerName = customerName; }
        public double getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(double totalRevenue) { this.totalRevenue = totalRevenue; }
        public double getTotalCost() { return totalCost; }
        public void setTotalCost(double totalCost) { this.totalCost = totalCost; }
        public double getNetProfit() { return netProfit; }
        public void setNetProfit(double netProfit) { this.netProfit = netProfit; }
    }

    public ProfitLossKPI getOverallKPIs() {
        ProfitLossKPI kpi = new ProfitLossKPI();
        String query = "SELECT SUM(revenue_amount) as rev, SUM(total_cost_amount) as cost, SUM(profit_loss_amount) as pl FROM profit_loss";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                kpi.setTotalRevenue(rs.getDouble("rev"));
                kpi.setTotalCost(rs.getDouble("cost"));
                kpi.setNetProfitLoss(rs.getDouble("pl"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return kpi;
    }

    public List<ProfitLossTrend> getMonthlyTrend() {
        List<ProfitLossTrend> list = new ArrayList<>();
        String query = "SELECT DATE_FORMAT(record_date, '%b %Y') as monthYear, SUM(profit_loss_amount) as pl " +
                       "FROM profit_loss GROUP BY YEAR(record_date), MONTH(record_date), monthYear ORDER BY YEAR(record_date), MONTH(record_date)";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                ProfitLossTrend t = new ProfitLossTrend();
                t.setMonthYear(rs.getString("monthYear"));
                t.setProfitLossAmount(rs.getDouble("pl"));
                list.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<LossReasonImpact> getLossReasonBreakdown() {
        List<LossReasonImpact> list = new ArrayList<>();
        // Using ABS because loss amounts might be recorded as negative, or the total_cost_amount might be positive.
        // In this db schema, profit_loss_amount is revenue - cost. A loss reason usually applies when cost > revenue.
        // The total_financial_impact in the stored procedure is SUM(profit_loss_amount), but for the donut chart we usually want positive absolute values.
        String query = "SELECT lr.reason_name, lr.category, SUM(ABS(pl.profit_loss_amount)) as total_impact " +
                       "FROM loss_reasons lr " +
                       "JOIN profit_loss_reason_map m ON lr.reason_id = m.reason_id " +
                       "JOIN profit_loss pl ON m.pl_id = pl.pl_id " +
                       "GROUP BY lr.reason_name, lr.category ORDER BY total_impact DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                LossReasonImpact r = new LossReasonImpact();
                r.setReasonName(rs.getString("reason_name"));
                r.setCategory(rs.getString("category"));
                r.setTotalImpact(rs.getDouble("total_impact"));
                list.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<CustomerProfitability> getCustomerProfitability() {
        List<CustomerProfitability> list = new ArrayList<>();
        String query = "SELECT c.customer_name, SUM(pl.revenue_amount) as rev, SUM(pl.total_cost_amount) as cost, SUM(pl.profit_loss_amount) as pl " +
                       "FROM customers c " +
                       "JOIN shipment s ON c.customer_id = s.customer_id " +
                       "JOIN profit_loss pl ON s.shipment_id = pl.shipment_id " +
                       "GROUP BY c.customer_name ORDER BY pl DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                CustomerProfitability cp = new CustomerProfitability();
                cp.setCustomerName(rs.getString("customer_name"));
                cp.setTotalRevenue(rs.getDouble("rev"));
                cp.setTotalCost(rs.getDouble("cost"));
                cp.setNetProfit(rs.getDouble("pl"));
                list.add(cp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}

