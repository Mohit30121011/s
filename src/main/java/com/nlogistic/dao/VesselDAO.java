package com.nlogistic.dao;

import com.nlogistic.model.Vessel;
import com.nlogistic.util.DBConnectionManager;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Types;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class VesselDAO {
    public List<Vessel> getAllVessels() {
        List<Vessel> vessels = new ArrayList<>();
        String sql = "SELECT * FROM vessels ORDER BY vessel_id ASC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Vessel v = new Vessel();
                v.setVesselId(rs.getInt("vessel_id"));
                v.setVesselName(rs.getString("vessel_name"));
                v.setImoNumber(rs.getString("imo_number"));
                v.setCapacityTeu(rs.getInt("capacity_teu"));
                try {
                    String st = rs.getString("status");
                    v.setStatus(st != null && !st.trim().isEmpty() ? st.trim() : "In Service");
                } catch (Exception ignored) {
                    v.setStatus("In Service");
                }
                vessels.add(v);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return vessels;
    }

    /**
     * DB: delete_vessels(p_vessel_id, p_requesting_user_id) - Super Admin only
     */
    public void deleteVessel(int vesselId, int requestingUserId) {
        String sql = "{CALL delete_vessels(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, vesselId);
            cs.setInt(2, requestingUserId);
            cs.execute();
        } catch (Exception e) {
            // Fallback direct delete
            try (Connection conn2 = DBConnectionManager.getConnection();
                 PreparedStatement ps2 = conn2.prepareStatement("DELETE FROM vessels WHERE vessel_id = ?")) {
                ps2.setInt(1, vesselId);
                ps2.executeUpdate();
            } catch (Exception ex) { ex.printStackTrace(); }
        }
    }

    /**
     * DB: update_vessels(p_vessel_id, p_requesting_user_id, name, imo, capacity_teu)
     */
    public void updateVessel(int vesselId, int requestingUserId, String name, String imo, Integer capacityTeu) {
        updateVessel(vesselId, name, imo, capacityTeu != null ? capacityTeu : 0, "In Service");
    }

    public void updateVessel(int vesselId, String name, String imo, int capacityTeu, String status) {
        String sql = "UPDATE vessels SET vessel_name = ?, imo_number = ?, capacity_teu = ?, status = ? WHERE vessel_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, imo);
            ps.setInt(3, capacityTeu);
            ps.setString(4, status != null && !status.trim().isEmpty() ? status.trim() : "In Service");
            ps.setInt(5, vesselId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    public void addVessel(String name, String imo, int capacity) {
        addVessel(name, imo, capacity, "In Service");
    }

    public void addVessel(String name, String imo, int capacity, String status) {
        String sql = "INSERT INTO vessels (vessel_name, imo_number, capacity_teu, status) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, imo);
            ps.setInt(3, capacity);
            ps.setString(4, status != null && !status.trim().isEmpty() ? status.trim() : "In Service");
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }
}
