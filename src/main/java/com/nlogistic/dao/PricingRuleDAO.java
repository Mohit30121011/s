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

    public boolean updateMultipliers(int pricingId, double seasonal, double demand, int updatedBy) {
        // The spec requires calling update_price which takes (pricing_id, new_base_price, changed_by, reason)
        // But we want to update multipliers. The SP only updates base_price!
        // Wait, looking at update_price:
        // SET v_new_final = COALESCE(p_new_base_price, v_old_price) * v_seasonal * v_demand;
        // UPDATE pricing_rules SET base_price = ... final_price = v_new_final
        // Ah, the SP doesn't let us update multipliers! 
        // We will do it with a raw update query for now, since SP lacks multiplier update logic.
        String sql = "UPDATE pricing_rules SET seasonal_multiplier = ?, demand_multiplier = ?, final_price = base_price * ? * ? WHERE pricing_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, seasonal);
            ps.setDouble(2, demand);
            ps.setDouble(3, seasonal);
            ps.setDouble(4, demand);
            ps.setInt(5, pricingId);
            
            int rows = ps.executeUpdate();
            
            // Log to audit
            if (rows > 0) {
                String auditSql = "INSERT INTO pricing_audit (pricing_id, changed_by, reason) VALUES (?, ?, ?)";
                try (PreparedStatement auditPs = conn.prepareStatement(auditSql)) {
                    auditPs.setInt(1, pricingId);
                    auditPs.setInt(2, updatedBy);
                    auditPs.setString(3, "Updated Multipliers");
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

}
