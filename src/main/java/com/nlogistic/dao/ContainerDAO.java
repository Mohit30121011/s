package com.nlogistic.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.nlogistic.model.Container;
import com.nlogistic.util.DBConnectionManager;

public class ContainerDAO {

    /**
     * Fetches a paginated list of containers, optionally filtered by status.
     */
    public List<Container> getContainers(String statusFilter, int limit, int offset) {
        List<Container> containers = new ArrayList<>();
        String sql = "SELECT * FROM containers";
        
        if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("All")) {
            sql += " WHERE status = ?";
        }
        
        sql += " ORDER BY container_id DESC LIMIT ? OFFSET ?";
        
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            int paramIndex = 1;
            if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("All")) {
                ps.setString(paramIndex++, statusFilter);
            }
            
            ps.setInt(paramIndex++, limit);
            ps.setInt(paramIndex, offset);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    containers.add(mapResultSetToContainer(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return containers;
    }

    /**
     * Get total count of containers for pagination
     */
    public int getContainerCount(String statusFilter) {
        String sql = "SELECT COUNT(*) FROM containers";
        if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("All")) {
            sql += " WHERE status = ?";
        }
        
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
            if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("All")) {
                ps.setString(1, statusFilter);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Helper method to map ResultSet to Container object
     */
    private Container mapResultSetToContainer(ResultSet rs) throws Exception {
        Container c = new Container();
        c.setContainerId(rs.getInt("container_id"));
        c.setContainerNumber(rs.getString("container_number"));
        c.setType(rs.getString("type"));
        c.setSize(rs.getString("size"));
        c.setImageUrl(rs.getString("image_url"));
        c.setTareWeightKg(rs.getDouble("tare_weight_kg"));
        c.setMaxGrossWeightKg(rs.getDouble("max_gross_weight_kg"));
        c.setGoodsCapacityKg(rs.getDouble("goods_capacity_kg"));
        c.setGoodsCapacityCbm(rs.getDouble("goods_capacity_cbm"));
        c.setStatus(rs.getString("status"));
        c.setCurrentPortId(rs.getInt("current_port_id"));
        c.setOwnerCompanyId(rs.getInt("owner_company_id"));
        return c;
    }
}
