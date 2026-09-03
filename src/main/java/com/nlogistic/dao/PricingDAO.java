package com.nlogistic.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.nlogistic.model.PricingRule;
import com.nlogistic.util.DBConnectionManager;

public class PricingDAO {

    /**
     * Gets the pricing rule matching the container type and size.
     */
    public PricingRule getPricingRule(String containerType, String containerSize) {
        String sql = "SELECT * FROM pricing_rules WHERE container_type = ? AND container_size = ? LIMIT 1";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, containerType);
            ps.setString(2, containerSize);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PricingRule rule = new PricingRule();
                    rule.setPricingId(rs.getInt("pricing_id"));
                    rule.setContainerType(rs.getString("container_type"));
                    rule.setContainerSize(rs.getString("container_size"));
                    rule.setBasePrice(rs.getDouble("base_price"));
                    rule.setSeasonalMultiplier(rs.getDouble("seasonal_multiplier"));
                    rule.setDemandMultiplier(rs.getDouble("demand_multiplier"));
                    rule.setFinalPrice(rs.getDouble("final_price"));
                    return rule;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // Return default if not found
        PricingRule defaultRule = new PricingRule();
        defaultRule.setBasePrice(1200.0);
        defaultRule.setSeasonalMultiplier(1.0);
        defaultRule.setDemandMultiplier(1.0);
        return defaultRule;
    }
}
