package com.nlogistic.dao;

import com.nlogistic.model.Container;
import com.nlogistic.util.DBConnectionManager;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ContainerDAO {
    
    // Original method from Module 2
    public List<Container> getAvailableContainers() {
        List<Container> list = new ArrayList<>();
        String sql = "SELECT * FROM containers WHERE status = 'Available'";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Container c = new Container();
                c.setContainerId(rs.getInt("container_id"));
                c.setContainerNumber(rs.getString("container_number"));
                c.setType(rs.getString("type"));
                c.setSize(rs.getString("size"));
                c.setGoodsCapacityKg(rs.getDouble("goods_capacity_kg"));
                c.setGoodsCapacityCbm(rs.getDouble("goods_capacity_cbm"));
                c.setStatus(rs.getString("status"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // New Module 3 Method: Get All Containers
    public List<Container> getAllContainers() {
        List<Container> list = new ArrayList<>();
        String sql = "SELECT c.*, p.port_name FROM containers c LEFT JOIN ports p ON c.current_port_id = p.port_id";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Container c = new Container();
                c.setContainerId(rs.getInt("container_id"));
                c.setContainerNumber(rs.getString("container_number"));
                c.setType(rs.getString("type"));
                c.setSize(rs.getString("size"));
                c.setGoodsCapacityKg(rs.getDouble("goods_capacity_kg"));
                c.setGoodsCapacityCbm(rs.getDouble("goods_capacity_cbm"));
                c.setStatus(rs.getString("status"));
                c.setCurrentPortId(rs.getInt("current_port_id"));
                // We hijack image_url temporarily to pass port name for display logic since there's no direct portName field
                c.setImageUrl(rs.getString("port_name"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // New Module 3 Method: Update Container Status/Location via SP
    public boolean updateContainerStatus(int containerId, String status, int portId) {
        String sql = "{CALL update_container(?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, containerId);
            cs.setString(2, status);
            cs.setInt(3, portId);
            cs.execute();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * DB: add_container(p_container_number, p_type, p_size, p_tare_weight_kg, p_max_gross_weight_kg,
     *   p_goods_capacity_kg, p_goods_capacity_cbm, p_current_port_id, p_owner_company_id)
     */
    public boolean addContainer(String containerNumber, String type, String size, double tareWeight, 
                                double maxGross, double goodsKg, double goodsCbm, int portId, int companyId) {
        String sql = "{CALL add_container(?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, containerNumber);
            cs.setString(2, type);
            cs.setString(3, size);
            cs.setDouble(4, tareWeight);
            cs.setDouble(5, maxGross);
            cs.setDouble(6, goodsKg);
            cs.setDouble(7, goodsCbm);
            cs.setInt(8, portId);
            cs.setInt(9, companyId);
            cs.execute();
            return true;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }


    /**
     * DB: delete_containers(p_container_id, p_requesting_user_id)
     */
    public void deleteContainer(int containerId, int requestingUserId) {
        String sql = "{CALL delete_containers(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, containerId);
            cs.setInt(2, requestingUserId);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

}
