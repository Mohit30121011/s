package com.nlogistic.dao;

import com.nlogistic.model.LossReason;
import com.nlogistic.util.DBConnectionManager;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class LossReasonDAO {
    public List<LossReason> getAllLossReasons() {
        List<LossReason> list = new ArrayList<>();
        String sql = "SELECT * FROM loss_reasons";
        try (Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LossReason lr = new LossReason();
                lr.setReasonId(rs.getInt("reason_id"));
                lr.setReasonCode(rs.getString("reason_code"));
                lr.setReasonName(rs.getString("reason_name"));
                lr.setDescription(rs.getString("description"));
                list.add(lr);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public void addLossReason(String code, String name, String desc) {
        String sql = "INSERT INTO loss_reasons (reason_code, reason_name, description) VALUES (?, ?, ?)";
        try (Connection conn = DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            ps.setString(2, name);
            ps.setString(3, desc);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    public void deleteLossReason(int reasonId, int requestingUserId) {
        String sql = "{CALL delete_loss_reasons(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, reasonId);
            cs.setInt(2, requestingUserId);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }

    public void updateLossReason(int reasonId, int requestingUserId, String code, String name, String desc) {
        String sql = "{CALL update_loss_reasons(?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, reasonId);
            cs.setInt(2, requestingUserId);
            cs.setString(3, code);
            cs.setString(4, name);
            cs.setString(5, desc);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }
}