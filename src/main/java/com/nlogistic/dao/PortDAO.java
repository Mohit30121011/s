package com.nlogistic.dao;

import com.nlogistic.model.Port;
import com.nlogistic.util.DBConnectionManager;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Types;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class PortDAO {
    public List<Port> getAllPorts() {
        List<Port> ports = new ArrayList<>();
        String sql = "SELECT * FROM ports";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Port p = new Port();
                p.setPortId(rs.getInt("port_id"));
                p.setPortName(rs.getString("port_name"));
                p.setPortCode(rs.getString("port_code"));
                p.setCountry(rs.getString("country"));
                p.setLatitude(rs.getDouble("latitude"));
                p.setLongitude(rs.getDouble("longitude"));
                ports.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ports;
    }

    /**
     * DB: delete_ports(p_port_id, p_requesting_user_id) - Super Admin only
     */
    public void deletePort(int portId, int requestingUserId) {
        String sql = "{CALL delete_ports(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, portId);
            cs.setInt(2, requestingUserId);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /**
     * DB: update_ports(p_port_id, p_requesting_user_id, name, code, country, lat, lng)
     */
    public void updatePort(int portId, int requestingUserId, String name, String code, String country, Double lat, Double lng) {
        String sql = "{CALL update_ports(?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, portId);
            cs.setInt(2, requestingUserId);
            if (name != null) cs.setString(3, name); else cs.setNull(3, Types.VARCHAR);
            if (code != null) cs.setString(4, code); else cs.setNull(4, Types.VARCHAR);
            if (country != null) cs.setString(5, country); else cs.setNull(5, Types.VARCHAR);
            if (lat != null) cs.setDouble(6, lat); else cs.setNull(6, Types.DECIMAL);
            if (lng != null) cs.setDouble(7, lng); else cs.setNull(7, Types.DECIMAL);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }



    public void addPort(String name, String code, String country, double lat, double lng) {
        String sql = "INSERT INTO ports (port_name, port_code, country, latitude, longitude) VALUES (?, ?, ?, ?, ?)";
        try (java.sql.Connection conn = com.nlogistic.util.DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, code);
            ps.setString(3, country);
            ps.setDouble(4, lat);
            ps.setDouble(5, lng);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

}
