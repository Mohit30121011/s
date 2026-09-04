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
        String sql = "SELECT c.*, p.port_name, p.country AS port_country, co.company_name AS owner_company_name " +
                     "FROM containers c " +
                     "LEFT JOIN ports p ON c.current_port_id = p.port_id " +
                     "LEFT JOIN companies co ON c.owner_company_id = co.company_id";

        if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("All")) {
            sql += " WHERE c.status = ?";
        }

        sql += " ORDER BY c.container_id DESC LIMIT ? OFFSET ?";
        
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
        try { c.setPortName(rs.getString("port_name")); } catch (Exception ignored) {}
        try { c.setPortCountry(rs.getString("port_country")); } catch (Exception ignored) {}
        try { c.setOwnerCompanyName(rs.getString("owner_company_name")); } catch (Exception ignored) {}
        return c;
    }

    public List<Container> getAllContainers() {
        return getContainers("All", 1000, 0); // Alias for backwards compatibility
    }

    /** FR3.1: full container master-data update — every editable spec, not just status/port. */
    public boolean updateContainer(int containerId, String type, String size, double tare, double maxGross,
                                    double capKg, double capCbm, String status, int portId, String imageUrl) {
        StringBuilder sql = new StringBuilder(
            "UPDATE containers SET type=?, size=?, tare_weight_kg=?, max_gross_weight_kg=?, " +
            "goods_capacity_kg=?, goods_capacity_cbm=?, status=?, current_port_id=?");
        if (imageUrl != null && !imageUrl.trim().isEmpty()) sql.append(", image_url=?");
        sql.append(" WHERE container_id=?");

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int i = 1;
            ps.setString(i++, type);
            ps.setString(i++, size);
            ps.setDouble(i++, tare);
            ps.setDouble(i++, maxGross);
            ps.setDouble(i++, capKg);
            ps.setDouble(i++, capCbm);
            ps.setString(i++, status);
            ps.setInt(i++, portId);
            if (imageUrl != null && !imageUrl.trim().isEmpty()) ps.setString(i++, imageUrl);
            ps.setInt(i, containerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateContainerStatus(int containerId, String status, int portId) {
        String sql = "UPDATE containers SET status = ?, current_port_id = ? WHERE container_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, portId);
            ps.setInt(3, containerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteContainer(int containerId, int userId) {
        String sql = "DELETE FROM containers WHERE container_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, containerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addContainer(String number, String type, String size, double tare, double maxGross, double capKg, double capCbm, int portId, int ownerId) {
        return addContainer(number, type, size, null, tare, maxGross, capKg, capCbm, "Available", portId, ownerId);
    }

    /**
     * FR3.1: Full container master catalog creation with all specifications:
     * container number, type, size, image_url, tare weight, max gross, goods capacity (kg & CBM), status, port, owner.
     */
    public boolean addContainer(String number, String type, String size, String imageUrl, double tare, double maxGross, double capKg, double capCbm, String status, int portId, int ownerId) {
        String sql = "INSERT INTO containers (container_number, type, size, image_url, tare_weight_kg, max_gross_weight_kg, goods_capacity_kg, goods_capacity_cbm, status, current_port_id, owner_company_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, number);
            ps.setString(2, type);
            ps.setString(3, size);
            ps.setString(4, (imageUrl != null && !imageUrl.trim().isEmpty()) ? imageUrl.trim() : null);
            ps.setDouble(5, tare);
            ps.setDouble(6, maxGross);
            ps.setDouble(7, capKg);
            ps.setDouble(8, capCbm);
            ps.setString(9, (status != null && !status.trim().isEmpty()) ? status.trim() : "Available");
            ps.setInt(10, portId);
            ps.setInt(11, ownerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
