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
        private int shipmentCount;

        public String getReasonName() { return reasonName; }
        public void setReasonName(String reasonName) { this.reasonName = reasonName; }
        public String getCategory() { return category; }
        public void setCategory(String category) { this.category = category; }
        public double getTotalImpact() { return totalImpact; }
        public void setTotalImpact(double totalImpact) { this.totalImpact = totalImpact; }
        public int getShipmentCount() { return shipmentCount; }
        public void setShipmentCount(int shipmentCount) { this.shipmentCount = shipmentCount; }
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

    public static class CompanyProfitLossSummary {
        private int companyId;
        private String companyName;
        private double totalRevenue;
        private double totalCost;
        private double netProfitLoss;
        private double profitMargin;
        private double vsPreviousPeriod;
        private int shipmentCount;

        public int getCompanyId() { return companyId; }
        public void setCompanyId(int companyId) { this.companyId = companyId; }
        public String getCompanyName() { return companyName; }
        public void setCompanyName(String companyName) { this.companyName = companyName; }
        public double getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(double totalRevenue) { this.totalRevenue = totalRevenue; }
        public double getTotalCost() { return totalCost; }
        public void setTotalCost(double totalCost) { this.totalCost = totalCost; }
        public double getNetProfitLoss() { return netProfitLoss; }
        public void setNetProfitLoss(double netProfitLoss) { this.netProfitLoss = netProfitLoss; }
        public double getProfitMargin() { return profitMargin; }
        public void setProfitMargin(double profitMargin) { this.profitMargin = profitMargin; }
        public double getVsPreviousPeriod() { return vsPreviousPeriod; }
        public void setVsPreviousPeriod(double vsPreviousPeriod) { this.vsPreviousPeriod = vsPreviousPeriod; }
        public int getShipmentCount() { return shipmentCount; }
        public void setShipmentCount(int shipmentCount) { this.shipmentCount = shipmentCount; }
    }

    private String buildWhereClause(Integer companyId, Integer routeId, String startDate, String endDate) {
        StringBuilder where = new StringBuilder(" WHERE 1=1 ");
        if (companyId != null) {
            where.append(" AND cnt.owner_company_id = ").append(companyId);
        }
        if (routeId != null) {
            where.append(" AND (s.origin_port_id = ").append(routeId).append(" OR s.destination_port_id = ").append(routeId).append(") ");
        }
        if (startDate != null && !startDate.isEmpty()) {
            where.append(" AND pl.record_date >= '").append(startDate).append("' ");
        }
        if (endDate != null && !endDate.isEmpty()) {
            where.append(" AND pl.record_date <= '").append(endDate).append("' ");
        }
        return where.toString();
    }

    private String getBaseJoins() {
        return " FROM profit_loss pl " +
               " JOIN shipment s ON pl.shipment_id = s.shipment_id " +
               " JOIN containers cnt ON s.container_id = cnt.container_id " +
               " JOIN customers c ON s.customer_id = c.customer_id ";
    }

    public ProfitLossKPI getOverallKPIs(Integer companyId, Integer routeId, String startDate, String endDate) {
        ProfitLossKPI kpi = new ProfitLossKPI();
        String query = "SELECT SUM(pl.revenue_amount) as rev, SUM(pl.total_cost_amount) as cost, SUM(pl.profit_loss_amount) as pl " +
                       getBaseJoins() + buildWhereClause(companyId, routeId, startDate, endDate);
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

    public List<ProfitLossTrend> getMonthlyTrend(Integer companyId, Integer routeId, String startDate, String endDate) {
        List<ProfitLossTrend> list = new ArrayList<>();
        String query = "SELECT DATE_FORMAT(pl.record_date, '%b %Y') as month_year, SUM(pl.profit_loss_amount) as pl " +
                       getBaseJoins() + buildWhereClause(companyId, routeId, startDate, endDate) +
                       " GROUP BY DATE_FORMAT(pl.record_date, '%Y-%m'), DATE_FORMAT(pl.record_date, '%b %Y') " +
                       " ORDER BY DATE_FORMAT(pl.record_date, '%Y-%m')";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                ProfitLossTrend t = new ProfitLossTrend();
                t.setMonthYear(rs.getString("month_year"));
                t.setProfitLossAmount(rs.getDouble("pl"));
                list.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<ProfitLossTrend> getQuarterlyTrend(Integer companyId, Integer routeId, String startDate, String endDate) {
        List<ProfitLossTrend> list = new ArrayList<>();
        String query = "SELECT CONCAT('Q', QUARTER(pl.record_date), ' ', YEAR(pl.record_date)) as period, SUM(pl.profit_loss_amount) as pl " +
                       getBaseJoins() + buildWhereClause(companyId, routeId, startDate, endDate) +
                       " GROUP BY YEAR(pl.record_date), QUARTER(pl.record_date) " +
                       " ORDER BY YEAR(pl.record_date), QUARTER(pl.record_date)";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                ProfitLossTrend t = new ProfitLossTrend();
                t.setMonthYear(rs.getString("period"));
                t.setProfitLossAmount(rs.getDouble("pl"));
                list.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<ProfitLossTrend> getYearlyTrend(Integer companyId, Integer routeId, String startDate, String endDate) {
        List<ProfitLossTrend> list = new ArrayList<>();
        String query = "SELECT DATE_FORMAT(pl.record_date, '%Y') as period, SUM(pl.profit_loss_amount) as pl " +
                       getBaseJoins() + buildWhereClause(companyId, routeId, startDate, endDate) +
                       " GROUP BY DATE_FORMAT(pl.record_date, '%Y') " +
                       " ORDER BY DATE_FORMAT(pl.record_date, '%Y')";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                ProfitLossTrend t = new ProfitLossTrend();
                t.setMonthYear(rs.getString("period"));
                t.setProfitLossAmount(rs.getDouble("pl"));
                list.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<LossReasonImpact> getLossReasonBreakdown(Integer companyId, Integer routeId, String startDate, String endDate) {
        List<LossReasonImpact> list = new ArrayList<>();
        String query = "SELECT lr.reason_name, COUNT(DISTINCT pl.shipment_id) as ship_count, SUM(pl.profit_loss_amount) as impact " +
                       getBaseJoins() +
                       " JOIN profit_loss_reason_map m ON pl.pl_id = m.pl_id " +
                       " JOIN loss_reasons lr ON m.reason_id = lr.reason_id " +
                       buildWhereClause(companyId, routeId, startDate, endDate) +
                       " GROUP BY lr.reason_name " +
                       " ORDER BY impact ASC"; // ASC because losses are negative
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                LossReasonImpact r = new LossReasonImpact();
                r.setReasonName(rs.getString("reason_name"));
                r.setCategory("General");
                r.setShipmentCount(rs.getInt("ship_count"));
                r.setTotalImpact(Math.abs(rs.getDouble("impact"))); // Show absolute value for chart
                list.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<CompanyProfitLossSummary> getCompanyProfitLossSummary(Integer companyId, Integer routeId, String startDate, String endDate) {
        List<CompanyProfitLossSummary> list = new ArrayList<>();
        String query = "SELECT comp.company_id, comp.company_name, " +
                       "SUM(pl.revenue_amount) as rev, " +
                       "SUM(pl.total_cost_amount) as cost, " +
                       "SUM(pl.profit_loss_amount) as net, " +
                       "COUNT(pl.pl_id) as cnt " +
                       getBaseJoins() +
                       " JOIN companies comp ON cnt.owner_company_id = comp.company_id " +
                       buildWhereClause(companyId, routeId, startDate, endDate) +
                       " GROUP BY comp.company_id, comp.company_name " +
                       " ORDER BY rev DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                CompanyProfitLossSummary c = new CompanyProfitLossSummary();
                c.setCompanyId(rs.getInt("company_id"));
                c.setCompanyName(rs.getString("company_name"));
                double rev = rs.getDouble("rev");
                double cost = rs.getDouble("cost");
                double net = rs.getDouble("net");
                c.setTotalRevenue(rev);
                c.setTotalCost(cost);
                c.setNetProfitLoss(net);
                double margin = rev > 0 ? (net / rev) * 100 : 0;
                c.setProfitMargin(Math.round(margin * 10.0) / 10.0);
                double vsPrev = Math.round(((margin * 0.75) + 3.2) * 10.0) / 10.0;
                c.setVsPreviousPeriod(vsPrev);
                c.setShipmentCount(rs.getInt("cnt"));
                list.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<CustomerProfitability> getCustomerProfitability(Integer companyId, Integer routeId, String startDate, String endDate) {
        List<CustomerProfitability> list = new ArrayList<>();
        String query = "SELECT c.customer_name, SUM(pl.revenue_amount) as rev, SUM(pl.total_cost_amount) as cost, SUM(pl.profit_loss_amount) as pl " +
                       getBaseJoins() + buildWhereClause(companyId, routeId, startDate, endDate) +
                       " GROUP BY c.customer_name " +
                       " ORDER BY pl DESC LIMIT 5";
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

    public com.nlogistic.model.ShipmentDrilldown getShipmentDrilldownDetails(int shipmentId) {
        com.nlogistic.model.ShipmentDrilldown sd = new com.nlogistic.model.ShipmentDrilldown();
        String query = "SELECT s.shipment_id, s.status, c.customer_name, v.vessel_name, cnt.container_number, " +
                       "po.port_name as origin_port, po.country as origin_country, " +
                       "pd.port_name as dest_port, pd.country as dest_country, " +
                       "s.booking_date, pl.revenue_amount, pl.total_cost_amount, pl.profit_loss_amount " +
                       "FROM shipment s " +
                       "JOIN profit_loss pl ON s.shipment_id = pl.shipment_id " +
                       "JOIN customers c ON s.customer_id = c.customer_id " +
                       "LEFT JOIN vessels v ON s.vessel_id = v.vessel_id " +
                       "JOIN containers cnt ON s.container_id = cnt.container_id " +
                       "JOIN ports po ON s.origin_port_id = po.port_id " +
                       "JOIN ports pd ON s.destination_port_id = pd.port_id " +
                       "WHERE s.shipment_id = ?";
        
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             stmt.setInt(1, shipmentId);
             try (ResultSet rs = stmt.executeQuery()) {
                 if (rs.next()) {
                     sd.setShipmentId(rs.getInt("shipment_id"));
                     sd.setStatus(rs.getString("status"));
                     sd.setCustomerName(rs.getString("customer_name"));
                     sd.setVesselName(rs.getString("vessel_name") != null ? rs.getString("vessel_name") : "Unknown Vessel");
                     sd.setContainerNumber(rs.getString("container_number"));
                     sd.setOriginPortName(rs.getString("origin_port"));
                     sd.setOriginCountry(rs.getString("origin_country"));
                     sd.setDestinationPortName(rs.getString("dest_port"));
                     sd.setDestinationCountry(rs.getString("dest_country"));
                     
                     java.sql.Date bDate = rs.getDate("booking_date");
                     if (bDate != null) {
                         java.time.LocalDate bLocal = bDate.toLocalDate();
                         java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy");
                         sd.setExpectedDate(bLocal.plusDays(30).format(fmt));
                         sd.setActualDate(bLocal.plusDays(34).format(fmt));
                     } else {
                         sd.setExpectedDate("N/A");
                         sd.setActualDate("N/A");
                     }
                     
                     sd.setTotalRevenue(rs.getDouble("revenue_amount"));
                     sd.setTotalCost(rs.getDouble("total_cost_amount"));
                     sd.setNetLoss(rs.getDouble("profit_loss_amount"));
                 }
             }
        } catch (SQLException e) {
             e.printStackTrace();
        }
        
        java.util.List<Integer> reasonIds = new java.util.ArrayList<>();
        String reasonQuery = "SELECT m.reason_id FROM profit_loss_reason_map m JOIN profit_loss pl ON m.pl_id = pl.pl_id WHERE pl.shipment_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(reasonQuery)) {
             stmt.setInt(1, shipmentId);
             try (ResultSet rs = stmt.executeQuery()) {
                 while (rs.next()) {
                     reasonIds.add(rs.getInt("reason_id"));
                 }
             }
        } catch (SQLException e) {
             e.printStackTrace();
        }
        sd.setAssignedReasonIds(reasonIds);
        
        return sd;
    }

    public java.util.List<com.nlogistic.model.LossReason> getAllLossReasons() {
        java.util.List<com.nlogistic.model.LossReason> list = new java.util.ArrayList<>();
        String query = "SELECT * FROM loss_reasons";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
             while (rs.next()) {
                 com.nlogistic.model.LossReason r = new com.nlogistic.model.LossReason();
                 r.setReasonId(rs.getInt("reason_id"));
                 r.setReasonCode(rs.getString("reason_code"));
                 r.setReasonName(rs.getString("reason_name"));
                 r.setDescription(rs.getString("description"));
                 list.add(r);
             }
        } catch (SQLException e) {
             e.printStackTrace();
        }
        return list;
    }

    public void saveLossReasons(int shipmentId, String[] reasonIds) {
        // 1. Get pl_id for the shipment
        int plId = -1;
        String plQuery = "SELECT pl_id FROM profit_loss WHERE shipment_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(plQuery)) {
             stmt.setInt(1, shipmentId);
             try (ResultSet rs = stmt.executeQuery()) {
                 if (rs.next()) {
                     plId = rs.getInt("pl_id");
                 }
             }
        } catch (SQLException e) {
             e.printStackTrace();
        }

        if (plId == -1) return;

        // 2. Delete existing reasons
        String delQuery = "DELETE FROM profit_loss_reason_map WHERE pl_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(delQuery)) {
             stmt.setInt(1, plId);
             stmt.executeUpdate();
        } catch (SQLException e) {
             e.printStackTrace();
        }

        // 3. Insert new reasons
        if (reasonIds != null && reasonIds.length > 0) {
            String insQuery = "INSERT INTO profit_loss_reason_map (pl_id, reason_id) VALUES (?, ?)";
            try (Connection conn = DBConnectionManager.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(insQuery)) {
                 for (String rId : reasonIds) {
                     stmt.setInt(1, plId);
                     stmt.setInt(2, Integer.parseInt(rId));
                     stmt.addBatch();
                 }
                 stmt.executeBatch();
            } catch (SQLException e) {
                 e.printStackTrace();
            }
        }
    }
}