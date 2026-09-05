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
        private int customerId;

        public int getCustomerId() { return customerId; }
        public void setCustomerId(int customerId) { this.customerId = customerId; }

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
        String sql = "SELECT s.shipment_id, s.customer_id, c.customer_name, cnt.container_number, v.vessel_name, " +
                     "p1.port_name as origin, p2.port_name as dest, s.status, s.booking_date, " +
                     "COALESCE((SELECT MAX(updated_at) FROM container_movements WHERE shipment_id = s.shipment_id), s.booking_date) as last_updated, " +
                     "COALESCE((SELECT expected_arrival_date FROM container_movements WHERE shipment_id = s.shipment_id ORDER BY movement_id DESC LIMIT 1), DATE_ADD(s.booking_date, INTERVAL 14 DAY)) as eta " +
                     "FROM shipment s " +
                     "JOIN customers c ON s.customer_id = c.customer_id " +
                     "JOIN containers cnt ON s.container_id = cnt.container_id " +
                     "JOIN vessels v ON s.vessel_id = v.vessel_id " +
                     "JOIN ports p1 ON s.origin_port_id = p1.port_id " +
                     "JOIN ports p2 ON s.destination_port_id = p2.port_id " +
                     "ORDER BY s.shipment_id DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ShipmentDetail d = new ShipmentDetail();
                d.setShipmentId(rs.getInt("shipment_id"));
                d.setCustomerId(rs.getInt("customer_id"));
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
        String sql = "SELECT s.shipment_id, s.customer_id, c.customer_name, cnt.container_number, v.vessel_name, " +
                     "p1.port_name as origin, p2.port_name as dest, s.status, s.booking_date, " +
                     "COALESCE((SELECT MAX(updated_at) FROM container_movements WHERE shipment_id = s.shipment_id), s.booking_date) as last_updated, " +
                     "COALESCE((SELECT expected_arrival_date FROM container_movements WHERE shipment_id = s.shipment_id ORDER BY movement_id DESC LIMIT 1), DATE_ADD(s.booking_date, INTERVAL 14 DAY)) as eta, " +
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
                d.setCustomerId(rs.getInt("customer_id"));
                    d.setCustomerName(rs.getString("customer_name"));
                    d.setContainerNumber(rs.getString("container_number"));
                    d.setOriginPort(rs.getString("origin"));
                    d.setDestPort(rs.getString("dest"));
                    d.setStatus(rs.getString("status"));
                    d.setBookingDate(rs.getDate("booking_date"));
                    d.setVesselName(rs.getString("vessel_name"));
                    d.setEta(rs.getDate("eta"));
                    d.setExpectedArrivalDate(rs.getDate("expected_arrival_date"));
                    d.setActualArrivalDate(rs.getDate("actual_arrival_date"));
                    Object delay = rs.getObject("delay_days");
                    d.setDelayDays(delay != null ? ((Number) delay).intValue() : 0);
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

        public int bookShipmentAndReturnId(Shipment s) {
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
            return cs.getInt(14);
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
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
    
    public boolean updateStatus(int shipmentId, String status, String checkpointLocation, int updatedBy) throws SQLException {
        String sql = "{CALL update_movement_status(?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, shipmentId);
            cs.setString(2, status);
            cs.setString(3, (checkpointLocation != null && !checkpointLocation.trim().isEmpty()) ? checkpointLocation.trim() : "Checkpoint Milestone Recorded");
            // FR2.5: carry the shipment's expected arrival forward on every checkpoint
            // so the arrival step has something to measure the delay against.
            java.sql.Date expected = resolveExpectedArrival(shipmentId);
            if (expected != null) {
                cs.setDate(4, expected);
            } else {
                cs.setNull(4, Types.DATE);
            }
            if ("Arrived".equalsIgnoreCase(status) || "Delivered".equalsIgnoreCase(status)) {
                cs.setTimestamp(5, new java.sql.Timestamp(System.currentTimeMillis()));
            } else {
                cs.setNull(5, Types.DATE);
            }
            cs.setInt(6, updatedBy);
            cs.execute();
            return true;
        }
    }

    public boolean updateStatus(int shipmentId, String status, int updatedBy) {
        try {
            return updateStatus(shipmentId, status, "Checkpoint Update", updatedBy);
        } catch (SQLException e) {
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
     * Cascades deletion across child tables atomically via database foreign keys.
     */
    public void deleteShipment(int shipmentId, int requestingUserId) {
        String sql = "{CALL delete_shipment(?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, shipmentId);
            cs.setInt(2, requestingUserId);
            cs.execute();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Deletes a shipment by ID using native ON DELETE CASCADE foreign key rules.
     * Referential integrity is preserved without disabling FOREIGN_KEY_CHECKS.
     */
    public void deleteShipment(int shipmentId) {
        String sql = "DELETE FROM shipment WHERE shipment_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipmentId);
            ps.executeUpdate();
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
            String movementSql = "INSERT INTO container_movements (shipment_id, status, checkpoint_location, updated_by) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ms = conn.prepareStatement(movementSql)) {
                ms.setInt(1, s.getShipmentId());
                ms.setString(2, s.getStatus());
                ms.setString(3, "Full Edit Details");
                ms.setInt(4, userId);
                ms.executeUpdate();
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /* ==================================================================
     * RBAC data scoping (CLAUDE.md S6.2.2 / MEGA_PROMPT Step 3).
     * Customers see only their own shipments; company staff see only
     * shipments belonging to their tenant. Never call getAllShipments()
     * for anyone except a Super Admin.
     * ================================================================== */

    private static final String SHIPMENT_LIST_SELECT =
        "SELECT s.shipment_id, s.customer_id, c.customer_name, cnt.container_number, v.vessel_name, " +
        "p1.port_name as origin, p2.port_name as dest, s.status, s.booking_date, " +
        "COALESCE((SELECT MAX(updated_at) FROM container_movements WHERE shipment_id = s.shipment_id), s.booking_date) as last_updated, " +
        "COALESCE((SELECT expected_arrival_date FROM container_movements WHERE shipment_id = s.shipment_id ORDER BY movement_id DESC LIMIT 1), DATE_ADD(s.booking_date, INTERVAL 14 DAY)) as eta " +
        "FROM shipment s " +
        "JOIN customers c ON s.customer_id = c.customer_id " +
        "JOIN containers cnt ON s.container_id = cnt.container_id " +
        "JOIN vessels v ON s.vessel_id = v.vessel_id " +
        "JOIN ports p1 ON s.origin_port_id = p1.port_id " +
        "JOIN ports p2 ON s.destination_port_id = p2.port_id ";

    private List<ShipmentDetail> queryShipments(String whereClause, int... params) {
        List<ShipmentDetail> list = new ArrayList<>();
        String sql = SHIPMENT_LIST_SELECT + whereClause + " ORDER BY s.shipment_id DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setInt(i + 1, params[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ShipmentDetail d = new ShipmentDetail();
                    d.setShipmentId(rs.getInt("shipment_id"));
                    d.setCustomerId(rs.getInt("customer_id"));
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
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Self-scoped view for Role 5 (Customer). */
    public List<ShipmentDetail> getShipmentsByCustomerId(int customerId) {
        return queryShipments("WHERE s.customer_id = ?", customerId);
    }

    /**
     * Tenant-scoped view for Roles 2, 3 and 4. A shipment belongs to a company when
     * the allocated container is owned by it, or the booking was created by one of
     * its staff users.
     */
    public List<ShipmentDetail> getShipmentsByCompanyId(int companyId) {
        return queryShipments(
            "WHERE cnt.owner_company_id = ? " +
            "   OR s.created_by IN (SELECT user_id FROM users WHERE company_id = ?)",
            companyId, companyId);
    }

    /**
     * Single entry point used by every controller: returns exactly the shipments
     * this caller is entitled to see, based on their role.
     */
    public List<ShipmentDetail> getShipmentsForRole(int roleId, Integer companyId, Integer customerId) {
        if (roleId == 5) {
            return getShipmentsByCustomerId(customerId != null ? customerId : -1);
        }
        if (roleId >= 2 && roleId <= 4) {
            return getShipmentsByCompanyId(companyId != null ? companyId : -1);
        }
        return getAllShipments();
    }

    /**
     * IDOR guard (CLAUDE.md S6.2.2). Returns true only when this caller may read
     * the given shipment. Super Admin always may; a Customer only their own;
     * company staff only shipments inside their tenant.
     */
    public boolean canAccessShipment(int shipmentId, int roleId, Integer companyId, Integer customerId) {
        if (roleId == 1) return true;
        String sql;
        if (roleId == 5) {
            sql = "SELECT 1 FROM shipment WHERE shipment_id = ? AND customer_id = ?";
        } else {
            sql = "SELECT 1 FROM shipment s LEFT JOIN containers cnt ON s.container_id = cnt.container_id " +
                  "WHERE s.shipment_id = ? AND (cnt.owner_company_id = ? " +
                  "   OR s.created_by IN (SELECT user_id FROM users WHERE company_id = ?))";
        }
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipmentId);
            if (roleId == 5) {
                ps.setInt(2, customerId != null ? customerId : -1);
            } else {
                int cid = companyId != null ? companyId : -1;
                ps.setInt(2, cid);
                ps.setInt(3, cid);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /* ==================================================================
     * FR2.5 - expected vs actual arrival and delay attribution.
     * ================================================================== */

    /**
     * The expected arrival for a shipment: whatever was already recorded on an
     * earlier checkpoint, otherwise a default 14-day transit window from booking.
     */
    private java.sql.Date resolveExpectedArrival(int shipmentId) {
        String sql = "SELECT COALESCE("
                   + "  (SELECT expected_arrival_date FROM container_movements "
                   + "    WHERE shipment_id = ? AND expected_arrival_date IS NOT NULL "
                   + "    ORDER BY movement_id ASC LIMIT 1), "
                   + "  (SELECT DATE_ADD(booking_date, INTERVAL 14 DAY) FROM shipment WHERE shipment_id = ?)"
                   + ") AS expected";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipmentId);
            ps.setInt(2, shipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDate("expected");
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    /**
     * Called when a shipment reaches Arrived/Delivered. Computes
     * delay_days = max(0, DATEDIFF(actual, expected)), persists it, and when the
     * shipment is late attributes the loss to the standard "Delay" reason so it
     * shows up in the P&L breakdown (FR2.7).
     *
     * @return the delay in days (0 when on time or not determinable).
     */
    public int settleArrivalDelay(int shipmentId, int updatedBy) {
        int delayDays = 0;
        try (Connection conn = DBConnectionManager.getConnection()) {
            conn.setAutoCommit(false);

            String sel = "SELECT movement_id, expected_arrival_date, "
                       + "COALESCE(actual_arrival_date, CURDATE()) AS actual_date "
                       + "FROM container_movements WHERE shipment_id = ? "
                       + "ORDER BY movement_id DESC LIMIT 1";
            int movementId = -1;
            java.sql.Date expected = null, actual = null;
            try (PreparedStatement ps = conn.prepareStatement(sel)) {
                ps.setInt(1, shipmentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        movementId = rs.getInt("movement_id");
                        expected = rs.getDate("expected_arrival_date");
                        actual = rs.getDate("actual_date");
                    }
                }
            }
            if (movementId == -1 || expected == null || actual == null) {
                conn.rollback();
                return 0;
            }

            long diff = actual.getTime() - expected.getTime();
            delayDays = (int) Math.max(0, java.util.concurrent.TimeUnit.DAYS.convert(
                    diff, java.util.concurrent.TimeUnit.MILLISECONDS));

            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE container_movements SET delay_days = ?, actual_arrival_date = ? WHERE movement_id = ?")) {
                ps.setInt(1, delayDays);
                ps.setDate(2, actual);
                ps.setInt(3, movementId);
                ps.executeUpdate();
            }

            if (delayDays > 0) {
                // Attribute the late arrival to the standard Delay loss reason,
                // but never duplicate an existing tag for the same shipment.
                String map = "INSERT INTO profit_loss_reason_map (pl_id, reason_id, remark) "
                           + "SELECT pl.pl_id, lr.reason_id, ? FROM profit_loss pl "
                           + "JOIN loss_reasons lr ON lr.reason_name = 'Delay' "
                           + "WHERE pl.shipment_id = ? "
                           + "AND NOT EXISTS (SELECT 1 FROM profit_loss_reason_map m "
                           + "                WHERE m.pl_id = pl.pl_id AND m.reason_id = lr.reason_id) "
                           + "LIMIT 1";
                try (PreparedStatement ps = conn.prepareStatement(map)) {
                    ps.setString(1, "Auto-tagged: arrived " + delayDays + " day(s) after expected arrival.");
                    ps.setInt(2, shipmentId);
                    ps.executeUpdate();
                } catch (Exception tagEx) {
                    // A missing 'Delay' reason row must not undo the delay record itself.
                    tagEx.printStackTrace();
                }
            }

            conn.commit();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return delayDays;
    }

    /* ==================================================================
     * FR3.3 / FR2.6 - post-booking contract steps shared by both booking
     * routes (/book and /shipments/save).
     * ================================================================== */

    /** Binds the container to the shipment and flips it to Allocated. */
    public boolean allocateContainer(int shipmentId, int containerId) {
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall("{call allocate_container(?, ?)}")) {
            cs.setInt(1, shipmentId);
            cs.setInt(2, containerId);
            cs.execute();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Creates the opening profit_loss row so the shipment is visible to the PLG
     * from day one. Costs start at zero and accrue as claims, delays and port
     * charges are recorded. No-op if a row already exists.
     */
    public boolean seedProfitLoss(int shipmentId, double revenue) {
        String sql = "INSERT INTO profit_loss (shipment_id, revenue_amount, total_cost_amount, profit_loss_amount, record_date) "
                   + "SELECT ?, ?, 0.00, ?, CURDATE() "
                   + "FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM profit_loss WHERE shipment_id = ?)";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipmentId);
            ps.setDouble(2, revenue);
            ps.setDouble(3, revenue);
            ps.setInt(4, shipmentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
