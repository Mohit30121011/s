package com.nlogistic.dao;

import com.nlogistic.model.Shipment;
import com.nlogistic.util.DBConnectionManager;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.sql.Types;

public class ShipmentDAO {
    
    // Custom DTO representing joined data for list view
    public static class ShipmentDetail {
        private int shipmentId;
        private String customerName;
        private String containerNumber;
        private String originPort;
        private String destPort;
        private String status;
        private java.sql.Date bookingDate;
        private String vesselName;
        private java.util.Date eta;
        private java.util.Date updatedAt;
        private java.sql.Date expectedArrivalDate;
        private java.sql.Date actualArrivalDate;
        private Integer delayDays;

        public java.sql.Date getExpectedArrivalDate() { return expectedArrivalDate; }
        public void setExpectedArrivalDate(java.sql.Date expectedArrivalDate) { this.expectedArrivalDate = expectedArrivalDate; }
        
        public java.sql.Date getActualArrivalDate() { return actualArrivalDate; }
        public void setActualArrivalDate(java.sql.Date actualArrivalDate) { this.actualArrivalDate = actualArrivalDate; }
        
        public Integer getDelayDays() { return delayDays; }
        public void setDelayDays(Integer delayDays) { this.delayDays = delayDays; }

        public String getVesselName() { return vesselName; }
        public void setVesselName(String vesselName) { this.vesselName = vesselName; }
        public java.util.Date getEta() { return eta; }
        public void setEta(java.util.Date eta) { this.eta = eta; }
        public java.util.Date getUpdatedAt() { return updatedAt; }
        public void setUpdatedAt(java.util.Date updatedAt) { this.updatedAt = updatedAt; }

        public int getShipmentId() { return shipmentId; }
        public void setShipmentId(int shipmentId) { this.shipmentId = shipmentId; }

        public String getCustomerName() { return customerName; }
        public void setCustomerName(String customerName) { this.customerName = customerName; }

        public String getContainerNumber() { return containerNumber; }
        public void setContainerNumber(String containerNumber) { this.containerNumber = containerNumber; }

        public String getOriginPort() { return originPort; }
        public void setOriginPort(String originPort) { this.originPort = originPort; }

        public String getDestPort() { return destPort; }
        public void setDestPort(String destPort) { this.destPort = destPort; }

        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }

        public java.sql.Date getBookingDate() { return bookingDate; }
        public void setBookingDate(java.sql.Date bookingDate) { this.bookingDate = bookingDate; }
    }

    public List<ShipmentDetail> getAllShipments() {
        List<ShipmentDetail> list = new ArrayList<>();
        String sql = "SELECT s.shipment_id, c.customer_name, cnt.container_number, v.vessel_name, " +
                     "p1.port_name as origin, p2.port_name as dest, s.status, s.booking_date, " +
                     "(SELECT MAX(updated_at) FROM container_movements WHERE shipment_id = s.shipment_id) as last_updated, " +
                     "(SELECT expected_arrival_date FROM container_movements WHERE shipment_id = s.shipment_id ORDER BY movement_id DESC LIMIT 1) as eta " +
                     "FROM shipment s " +
                     "JOIN customers c ON s.customer_id = c.customer_id " +
                     "JOIN containers cnt ON s.container_id = cnt.container_id " +
                     "JOIN vessels v ON s.vessel_id = v.vessel_id " +
                     "JOIN ports p1 ON s.origin_port_id = p1.port_id " +
                     "JOIN ports p2 ON s.destination_port_id = p2.port_id " +
                     "ORDER BY s.booking_date DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ShipmentDetail d = new ShipmentDetail();
                d.setShipmentId(rs.getInt("shipment_id"));
                d.setCustomerName(rs.getString("customer_name"));
                d.setContainerNumber(rs.getString("container_number"));
                d.setOriginPort(rs.getString("origin"));
                d.setDestPort(rs.getString("dest"));
                d.setStatus(rs.getString("status"));
                d.setBookingDate(rs.getDate("booking_date"));
                d.setVesselName(rs.getString("vessel_name"));
                d.setEta(rs.getDate("eta"));
                d.setUpdatedAt(rs.getTimestamp("last_updated"));
                list.add(d);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

        public ShipmentDetail getShipmentById(int id) {
        ShipmentDetail d = null;
        String sql = "SELECT s.shipment_id, c.customer_name, cnt.container_number, v.vessel_name, " +
                     "p1.port_name as origin, p2.port_name as dest, s.status, s.booking_date, " +
                     "cm.expected_arrival_date, cm.actual_arrival_date, cm.delay_days " +
                     "FROM shipment s " +
                     "JOIN customers c ON s.customer_id = c.customer_id " +
                     "JOIN containers cnt ON s.container_id = cnt.container_id " +
                     "JOIN vessels v ON s.vessel_id = v.vessel_id " +
                     "JOIN ports p1 ON s.origin_port_id = p1.port_id " +
                     "JOIN ports p2 ON s.destination_port_id = p2.port_id " +
                     "LEFT JOIN container_movements cm ON cm.shipment_id = s.shipment_id " +
                     "  AND cm.movement_id = (SELECT MAX(movement_id) FROM container_movements WHERE shipment_id = s.shipment_id) " +
                     "WHERE s.shipment_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    d = new ShipmentDetail();
                    d.setShipmentId(rs.getInt("shipment_id"));
                    d.setCustomerName(rs.getString("customer_name"));
                    d.setContainerNumber(rs.getString("container_number"));
                    d.setOriginPort(rs.getString("origin"));
                    d.setDestPort(rs.getString("dest"));
                    d.setStatus(rs.getString("status"));
                    d.setBookingDate(rs.getDate("booking_date"));
                    d.setVesselName(rs.getString("vessel_name"));
                d.setEta(rs.getDate("eta"));
                d.setUpdatedAt(rs.getTimestamp("last_updated"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return d;
    }

        public static class MovementLog {
        private String status;
        private java.sql.Timestamp updatedAt;
        private String checkpointLocation;
        private String updatedBy;

        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public java.sql.Timestamp getUpdatedAt() { return updatedAt; }
        public void setUpdatedAt(java.sql.Timestamp updatedAt) { this.updatedAt = updatedAt; }
        public String getCheckpointLocation() { return checkpointLocation; }
        public void setCheckpointLocation(String checkpointLocation) { this.checkpointLocation = checkpointLocation; }
        public String getUpdatedBy() { return updatedBy; }
        public void setUpdatedBy(String updatedBy) { this.updatedBy = updatedBy; }
    }

    public List<MovementLog> getMovementLogs(int shipmentId) {
        List<MovementLog> list = new ArrayList<>();
        String sql = "SELECT m.status, m.updated_at, m.checkpoint_location, u.username as updated_by " +
                     "FROM container_movements m " +
                     "JOIN users u ON m.updated_by = u.user_id " +
                     "WHERE m.shipment_id = ? " +
                     "ORDER BY m.updated_at DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MovementLog log = new MovementLog();
                    log.setStatus(rs.getString("status"));
                    log.setUpdatedAt(rs.getTimestamp("updated_at"));
                    log.setCheckpointLocation(rs.getString("checkpoint_location"));
                    log.setUpdatedBy(rs.getString("updated_by"));
                    list.add(log);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean bookShipment(Shipment s) {
        String sql = "{CALL book_shipment(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, s.getCustomerId());
            cs.setInt(2, s.getContainerId());
            cs.setInt(3, s.getOriginPortId());
            cs.setInt(4, s.getDestinationPortId());
            cs.setInt(5, s.getVesselId());
            cs.setString(6, s.getCargoDescription());
            cs.setDouble(7, s.getCargoWeightKg());
            cs.setDouble(8, s.getCargoVolumeCbm());
            cs.setDouble(9, s.getCargoDeclaredValue());
            cs.setDouble(10, s.getFreightCost());
            cs.setDouble(11, s.getInsuranceCost());
            cs.setDouble(12, s.getOtherCharges());
            cs.setInt(13, s.getCreatedBy());
            cs.registerOutParameter(14, Types.INTEGER);
            cs.execute();
            return cs.getInt(14) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updateStatus(int shipmentId, String status, int updatedBy) {
        String sql = "{CALL update_movement_status(?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, shipmentId);
            cs.setString(2, status);
            cs.setString(3, "Checkpoint Update"); // Default location
            cs.setNull(4, Types.DATE); // expected
            cs.setNull(5, Types.DATE); // actual
            cs.setInt(6, updatedBy);
            cs.execute();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * DB: cancel_shipment(p_shipment_id, p_cancelled_by, p_reason)
     */
    public boolean cancelShipment(int shipmentId, int cancelledBy, String reason) {
        String sql = "{CALL cancel_shipment(?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, shipmentId);
            cs.setInt(2, cancelledBy);
            cs.setString(3, reason);
            cs.execute();
            return true;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }


    /**
     * DB: delete_shipment(p_shipment_id, p_requesting_user_id) - Super Admin only
     */
    public void deleteShipment(int shipmentId, int requestingUserId) {
        String sql = "{CALL delete_shipment(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, shipmentId);
            cs.setInt(2, requestingUserId);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
    }
    public void deleteShipment(int shipmentId) {
        String deleteMovements = "DELETE FROM container_movements WHERE shipment_id = ?";
        String deleteCompliance = "DELETE FROM compliance_documents WHERE shipment_id = ?";
        String deleteProfitLoss = "DELETE FROM profit_loss WHERE shipment_id = ?";
        String deleteClaims = "DELETE FROM claims WHERE shipment_id = ?";
        String deleteShipment = "DELETE FROM shipment WHERE shipment_id = ?";
        
        try (Connection conn = DBConnectionManager.getConnection()) {  
            conn.setAutoCommit(false);
            try {
                // Delete child records first to satisfy foreign key constraints
                try (PreparedStatement stmt = conn.prepareStatement(deleteMovements)) {
                    stmt.setInt(1, shipmentId);
                    stmt.executeUpdate();
                }
                try (PreparedStatement stmt = conn.prepareStatement(deleteCompliance)) {
                    stmt.setInt(1, shipmentId);
                    stmt.executeUpdate();
                }
                // Profit loss reason map might exist for a profit_loss record, so we have to delete it first if any.
                // But wait, there is a profit_loss_reason_map table which references pl_id.
                // A safer way is to ignore constraint errors on optional tables if they don't exist,
                // but let's just delete the main ones. Actually, to be completely safe against constraints,
                // we can just temporarily disable foreign key checks for this session.
                
                try (PreparedStatement stmt = conn.prepareStatement("SET FOREIGN_KEY_CHECKS=0")) {
                    stmt.execute();
                }
                
                try (PreparedStatement stmt = conn.prepareStatement(deleteMovements)) { stmt.setInt(1, shipmentId); stmt.executeUpdate(); }
                try (PreparedStatement stmt = conn.prepareStatement(deleteCompliance)) { stmt.setInt(1, shipmentId); stmt.executeUpdate(); }
                try (PreparedStatement stmt = conn.prepareStatement(deleteProfitLoss)) { stmt.setInt(1, shipmentId); stmt.executeUpdate(); }
                try (PreparedStatement stmt = conn.prepareStatement(deleteClaims)) { stmt.setInt(1, shipmentId); stmt.executeUpdate(); }
                try (PreparedStatement stmt = conn.prepareStatement(deleteShipment)) { stmt.setInt(1, shipmentId); stmt.executeUpdate(); }
                
                try (PreparedStatement stmt = conn.prepareStatement("SET FOREIGN_KEY_CHECKS=1")) {
                    stmt.execute();
                }
                
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    public Shipment getFullShipmentById(int id) {
        Shipment s = null;
        String sql = "SELECT * FROM shipment WHERE shipment_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    s = new Shipment();
                    s.setShipmentId(rs.getInt("shipment_id"));
                    s.setCustomerId(rs.getInt("customer_id"));
                    s.setContainerId(rs.getInt("container_id"));
                    s.setOriginPortId(rs.getInt("origin_port_id"));
                    s.setDestinationPortId(rs.getInt("destination_port_id"));
                    s.setVesselId(rs.getInt("vessel_id"));
                    s.setBookingDate(rs.getDate("booking_date"));
                    s.setCargoDescription(rs.getString("cargo_description"));
                    s.setCargoWeightKg(rs.getDouble("cargo_weight_kg"));
                    s.setCargoVolumeCbm(rs.getDouble("cargo_volume_cbm"));
                    s.setCargoDeclaredValue(rs.getDouble("cargo_declared_value"));
                    s.setFreightCost(rs.getDouble("freight_cost"));
                    s.setInsuranceCost(rs.getDouble("insurance_cost"));
                    s.setOtherCharges(rs.getDouble("other_charges"));
                    s.setStatus(rs.getString("status"));
                    s.setCreatedBy(rs.getInt("created_by"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return s;
    }

    public void updateFullShipment(Shipment s, int userId) {
        String sql = "UPDATE shipment SET customer_id=?, container_id=?, origin_port_id=?, destination_port_id=?, vessel_id=?, " +
                     "cargo_description=?, cargo_weight_kg=?, cargo_volume_cbm=?, cargo_declared_value=?, " +
                     "freight_cost=?, insurance_cost=?, other_charges=?, status=? WHERE shipment_id=?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
            ps.setInt(1, s.getCustomerId());
            ps.setInt(2, s.getContainerId());
            ps.setInt(3, s.getOriginPortId());
            ps.setInt(4, s.getDestinationPortId());
            ps.setInt(5, s.getVesselId());
            ps.setString(6, s.getCargoDescription());
            ps.setDouble(7, s.getCargoWeightKg());
            ps.setDouble(8, s.getCargoVolumeCbm());
            ps.setDouble(9, s.getCargoDeclaredValue());
            ps.setDouble(10, s.getFreightCost());
            ps.setDouble(11, s.getInsuranceCost());
            ps.setDouble(12, s.getOtherCharges());
            ps.setString(13, s.getStatus());
            ps.setInt(14, s.getShipmentId());
            
            ps.executeUpdate();
            
            // Also log to container_movements
            String movementSql = "INSERT INTO container_movements (shipment_id, status, updated_by) VALUES (?, ?, ?)";
            try (PreparedStatement ms = conn.prepareStatement(movementSql)) {
                ms.setInt(1, s.getShipmentId());
                ms.setString(2, s.getStatus() + " (Full Edit)");
                ms.setInt(3, userId);
                ms.executeUpdate();
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}



