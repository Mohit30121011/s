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
        String sql = "SELECT * FROM vessels";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Vessel v = new Vessel();
                v.setVesselId(rs.getInt("vessel_id"));
                v.setVesselName(rs.getString("vessel_name"));
                v.setImoNumber(rs.getString("imo_number"));
                v.setCapacityTeu(rs.getInt("capacity_teu"));
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
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * DB: update_vessels(p_vessel_id, p_requesting_user_id, name, imo, capacity_teu)
     */
    public void updateVessel(int vesselId, int requestingUserId, String name, String imo, Integer capacityTeu) {
        String sql = "{CALL update_vessels(?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, vesselId);
            cs.setInt(2, requestingUserId);
            if (name != null) cs.setString(3, name); else cs.setNull(3, Types.VARCHAR);
            if (imo != null) cs.setString(4, imo); else cs.setNull(4, Types.VARCHAR);
            if (capacityTeu != null) cs.setInt(5, capacityTeu); else cs.setNull(5, Types.INTEGER);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }



    public void addVessel(String name, String imo, int capacity) {
        String sql = "INSERT INTO vessels (vessel_name, imo_number, capacity_teu) VALUES (?, ?, ?)";
        try (java.sql.Connection conn = com.nlogistic.util.DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, imo);
            ps.setInt(3, capacity);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

}
