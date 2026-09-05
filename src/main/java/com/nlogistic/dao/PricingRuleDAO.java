package com.nlogistic.dao;

import com.nlogistic.model.PricingRule;
import com.nlogistic.util.DBConnectionManager;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class PricingRuleDAO {
    
    public List<PricingRule> getAllPricingRules() {
        List<PricingRule> list = new ArrayList<>();
        String sql = "SELECT * FROM pricing_rules ORDER BY valid_to DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                PricingRule pr = new PricingRule();
                pr.setPricingId(rs.getInt("pricing_id"));
                pr.setContainerType(rs.getString("container_type"));
                pr.setContainerSize(rs.getString("container_size"));
                pr.setRouteId(rs.getInt("route_id"));
                pr.setBasePrice(rs.getDouble("base_price"));
                pr.setSeasonalMultiplier(rs.getDouble("seasonal_multiplier"));
                pr.setDemandMultiplier(rs.getDouble("demand_multiplier"));
                pr.setFinalPrice(rs.getDouble("final_price"));
                pr.setValidFrom(rs.getDate("valid_from"));
                pr.setValidTo(rs.getDate("valid_to"));
                list.add(pr);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** FR3.7: full price-change audit trail, newest first, with the responsible user's name. */
    public List<com.nlogistic.model.PricingAudit> getAuditHistory() {
        List<com.nlogistic.model.PricingAudit> list = new ArrayList<>();
        String sql = "SELECT a.audit_id, a.pricing_id, a.old_price, a.new_price, a.reason, a.changed_at, " +
                     "u.username AS changed_by_name, " +
                     "CONCAT(pr.container_size, ' ', pr.container_type) AS container_profile " +
                     "FROM pricing_audit a " +
                     "LEFT JOIN users u ON a.changed_by = u.user_id " +
                     "LEFT JOIN pricing_rules pr ON a.pricing_id = pr.pricing_id " +
                     "ORDER BY a.changed_at DESC LIMIT 200";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                com.nlogistic.model.PricingAudit a = new com.nlogistic.model.PricingAudit();
                a.setAuditId(rs.getInt("audit_id"));
                a.setPricingId(rs.getInt("pricing_id"));
                a.setOldPrice(rs.getDouble("old_price"));
                a.setNewPrice(rs.getDouble("new_price"));
                a.setReason(rs.getString("reason"));
                a.setChangedAt(rs.getTimestamp("changed_at"));
                a.setChangedByName(rs.getString("changed_by_name"));
                a.setContainerProfile(rs.getString("container_profile"));
                list.add(a);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateMultipliers(int pricingId, double seasonal, double demand, int updatedBy) {
        // The spec requires calling update_price which takes (pricing_id, new_base_price, changed_by, reason)
        // But we want to update multipliers. The SP only updates base_price!
        // Wait, looking at update_price:
        // SET v_new_final = COALESCE(p_new_base_price, v_old_price) * v_seasonal * v_demand;
        // UPDATE pricing_rules SET base_price = ... final_price = v_new_final
        // Ah, the SP doesn't let us update multipliers!
        // We will do it with a raw update query for now, since SP lacks multiplier update logic.
        try (Connection conn = DBConnectionManager.getConnection()) {
            // FR3.7: capture the old final_price before it changes so the audit row is complete.
            double oldFinalPrice = 0.0;
            double basePrice = 0.0;
            try (PreparedStatement fetchPs = conn.prepareStatement(
                    "SELECT base_price, final_price FROM pricing_rules WHERE pricing_id = ?")) {
                fetchPs.setInt(1, pricingId);
                try (ResultSet rs = fetchPs.executeQuery()) {
                    if (rs.next()) {
                        basePrice = rs.getDouble("base_price");
                        oldFinalPrice = rs.getDouble("final_price");
                    }
                }
            }

            double newFinalPrice = basePrice * seasonal * demand;
            String sql = "UPDATE pricing_rules SET seasonal_multiplier = ?, demand_multiplier = ?, final_price = ? WHERE pricing_id = ?";
            int rows;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDouble(1, seasonal);
                ps.setDouble(2, demand);
                ps.setDouble(3, newFinalPrice);
                ps.setInt(4, pricingId);
                rows = ps.executeUpdate();
            }

            // Log to audit (FR3.7: old value, new value, reason, timestamp, responsible user)
            if (rows > 0) {
                String auditSql = "INSERT INTO pricing_audit (pricing_id, old_price, new_price, changed_by, reason, changed_at) VALUES (?, ?, ?, ?, ?, NOW())";
                try (PreparedStatement auditPs = conn.prepareStatement(auditSql)) {
                    auditPs.setInt(1, pricingId);
                    auditPs.setDouble(2, oldFinalPrice);
                    auditPs.setDouble(3, newFinalPrice);
                    auditPs.setInt(4, updatedBy);
                    auditPs.setString(5, "Updated seasonal/demand multipliers");
                    auditPs.executeUpdate();
                }
            }
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * DB: add_pricing_rule(type, size, route, base, seasonal, demand, valid_from, valid_to)
     */
    public boolean addPricingRule(String containerType, String containerSize, int routeId, double basePrice,
                                  double seasonal, double demand, java.sql.Date validFrom, java.sql.Date validTo) {
        String sql = "{CALL add_pricing_rule(?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, containerType);
            cs.setString(2, containerSize);
            cs.setInt(3, routeId);
            cs.setDouble(4, basePrice);
            cs.setDouble(5, seasonal);
            cs.setDouble(6, demand);
            cs.setDate(7, validFrom);
            cs.setDate(8, validTo);
            cs.execute();
            return true;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    /**
     * DB: update_price(p_pricing_id, p_new_base_price, p_changed_by, p_reason) - with audit log
     */
    public boolean updateBasePrice(int pricingId, double newBasePrice, int changedBy, String reason) {
        String sql = "{CALL update_price(?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, pricingId);
            cs.setDouble(2, newBasePrice);
            cs.setInt(3, changedBy);
            cs.setString(4, reason);
            cs.execute();
            return true;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    /**
     * DB: deactivate_pricing_rule(p_pricing_id, p_changed_by)
     */
    public boolean deactivateRule(int pricingId, int changedBy) {
        String sql = "{CALL deactivate_pricing_rule(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, pricingId);
            cs.setInt(2, changedBy);
            cs.execute();
            return true;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }


    public List<com.nlogistic.model.PricingAudit> getAuditHistoryByType(String containerType) {
        List<com.nlogistic.model.PricingAudit> list = new ArrayList<>();
        String sql = "SELECT a.audit_id, a.pricing_id, a.old_price, a.new_price, a.reason, a.changed_at, " +
                     "u.username AS changed_by_name, " +
                     "CONCAT(COALESCE(pr.container_size, ''), ' ', COALESCE(pr.container_type, ?)) AS container_profile " +
                     "FROM pricing_audit a " +
                     "LEFT JOIN users u ON a.changed_by = u.user_id " +
                     "LEFT JOIN pricing_rules pr ON a.pricing_id = pr.pricing_id " +
                     "WHERE pr.container_type = ? OR pr.container_type LIKE ? " +
                     "ORDER BY a.changed_at DESC LIMIT 100";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, containerType);
            ps.setString(2, containerType);
            ps.setString(3, "%" + containerType + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    com.nlogistic.model.PricingAudit a = new com.nlogistic.model.PricingAudit();
                    a.setAuditId(rs.getInt("audit_id"));
                    a.setPricingId(rs.getInt("pricing_id"));
                    a.setOldPrice(rs.getDouble("old_price"));
                    a.setNewPrice(rs.getDouble("new_price"));
                    a.setReason(rs.getString("reason"));
                    a.setChangedAt(rs.getTimestamp("changed_at"));
                    a.setChangedByName(rs.getString("changed_by_name"));
                    a.setContainerProfile(rs.getString("container_profile"));
                    list.add(a);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (list.isEmpty()) {
            return getAuditHistory();
        }
        return list;
    }


    /**
     * FR3.5 + SRS 5.5 - GAP-M3-03.
     *
     * demand_multiplier was a static column that nobody ever recomputed, so the
     * "dynamic" pricing engine was effectively a fixed rate card. This derives the
     * multiplier from the FORECAST TREND for the lane:
     *
     *   growth     = (last forecast period - first forecast period) / first
     *   multiplier = 1.0 + clamp(growth * 0.15, -0.20, +0.50)
     *
     * Comparing a lane against a per-type average (as first drafted) is degenerate
     * while demand_forecast holds a single route per type - every lane equals its
     * own baseline and each multiplier collapses to 1.00, wiping the rate card.
     * The trend reading works with the data that actually exists, and the 0.15
     * damping keeps a rising lane from repricing violently. Every resulting price
     * change is written to pricing_audit (FR3.7) so a sync can be rolled back.
     *
     * @return number of pricing rules whose price actually moved.
     */
    public int syncDemandMultipliers(int changedBy) {
        int updated = 0;
        String select =
            "SELECT pr.pricing_id, pr.container_type, pr.base_price, pr.seasonal_multiplier, "
          + "       pr.demand_multiplier, pr.final_price, "
          + "       (SELECT df.forecasted_demand FROM demand_forecast df "
          + "         WHERE df.container_type = pr.container_type AND df.route_id = pr.route_id "
          + "         ORDER BY df.forecast_id ASC LIMIT 1) AS first_demand, "
          + "       (SELECT df2.forecasted_demand FROM demand_forecast df2 "
          + "         WHERE df2.container_type = pr.container_type AND df2.route_id = pr.route_id "
          + "         ORDER BY df2.forecast_id DESC LIMIT 1) AS last_demand "
          + "FROM pricing_rules pr";

        try (Connection conn = DBConnectionManager.getConnection()) {
            conn.setAutoCommit(false);
            java.util.List<double[]> changes = new java.util.ArrayList<>();
            java.util.List<String> reasons = new java.util.ArrayList<>();

            try (PreparedStatement ps = conn.prepareStatement(select);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    double firstDemand = rs.getDouble("first_demand");
                    if (rs.wasNull() || firstDemand <= 0) continue;
                    double lastDemand = rs.getDouble("last_demand");
                    if (rs.wasNull()) continue;

                    double growth = (lastDemand - firstDemand) / firstDemand;
                    double deviation = growth * 0.15; // damping
                    if (deviation > 0.50)  deviation = 0.50;
                    if (deviation < -0.20) deviation = -0.20;

                    double newMultiplier = Math.round((1.0 + deviation) * 100.0) / 100.0;
                    double basePrice = rs.getDouble("base_price");
                    double seasonal = rs.getDouble("seasonal_multiplier");
                    double newPrice = Math.round(basePrice * seasonal * newMultiplier * 100.0) / 100.0;
                    double oldPrice = rs.getDouble("final_price");

                    if (Math.abs(newPrice - oldPrice) >= 0.01) {
                        changes.add(new double[]{ rs.getInt("pricing_id"), newMultiplier, newPrice, oldPrice });
                        reasons.add(String.format(
                            "Demand sync: %s lane forecast %.0f -> %.0f (%+.1f%% growth), multiplier %.2f",
                            rs.getString("container_type"), firstDemand, lastDemand,
                            growth * 100.0, newMultiplier));
                    }
                }
            }

            String upd = "UPDATE pricing_rules SET demand_multiplier = ?, final_price = ? WHERE pricing_id = ?";
            String aud = "INSERT INTO pricing_audit (pricing_id, old_price, new_price, changed_by, reason) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement psU = conn.prepareStatement(upd);
                 PreparedStatement psA = conn.prepareStatement(aud)) {
                for (int i = 0; i < changes.size(); i++) {
                    double[] c = changes.get(i);
                    psU.setDouble(1, c[1]);
                    psU.setDouble(2, c[2]);
                    psU.setInt(3, (int) c[0]);
                    psU.addBatch();

                    psA.setInt(1, (int) c[0]);
                    psA.setDouble(2, c[3]);
                    psA.setDouble(3, c[2]);
                    psA.setInt(4, changedBy);
                    psA.setString(5, reasons.get(i));
                    psA.addBatch();
                }
                psU.executeBatch();
                psA.executeBatch();
                updated = changes.size();
            }
            conn.commit();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return updated;
    }
}
