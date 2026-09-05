package com.nlogistic.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
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

    public int addContainer(String number, String type, String size, double tare, double maxGross, double capKg, double capCbm, int portId, int ownerId) {
        return addContainer(number, type, size, null, tare, maxGross, capKg, capCbm, "Available", portId, ownerId);
    }

    /**
     * Check if a container number already exists in the system.
     */
    public boolean isContainerNumberTaken(String number) {
        if (number == null || number.trim().isEmpty()) return false;
        String sql = "SELECT 1 FROM containers WHERE container_number = ? LIMIT 1";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, number.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * FR3.1: Full container master catalog creation with all specifications:
     * container number, type, size, image_url, tare weight, max gross, goods capacity (kg & CBM), status, port, owner.
     * Returns the generated container_id, or -1 on failure (used by FR8.1 auto-barcode generation).
     */
    public int addContainer(String number, String type, String size, String imageUrl, double tare, double maxGross, double capKg, double capCbm, String status, int portId, int ownerId) {
        // Defensive: if caller has no company (e.g. Super Admin role 1), fall back to company 1
        if (ownerId <= 0) {
            ownerId = 1;
        }
        String sql = "INSERT INTO containers (container_number, type, size, image_url, tare_weight_kg, max_gross_weight_kg, goods_capacity_kg, goods_capacity_cbm, status, current_port_id, owner_company_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, number.trim().toUpperCase());
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
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet gk = ps.getGeneratedKeys()) {
                    if (gk.next()) return gk.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /** Single container with its port/owner joins - used to preselect one on the booking form. */
    public Container getContainerById(int containerId) {
        String sql = "SELECT c.*, p.port_name, p.country AS port_country, co.company_name AS owner_company_name "
                   + "FROM containers c "
                   + "LEFT JOIN ports p ON c.current_port_id = p.port_id "
                   + "LEFT JOIN companies co ON c.owner_company_id = co.company_id "
                   + "WHERE c.container_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, containerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapResultSetToContainer(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    /* ==================================================================
     * FR3.1 - fleet ownership scoping. A container is a company asset;
     * only its owner (and a Super Admin) may manage it. Customers browse
     * the catalog across companies, which is intended (FR3.2).
     * ================================================================== */

    /** Containers owned by one company. */
    public List<Container> getContainersByCompany(int companyId) {
        List<Container> list = new ArrayList<>();
        String sql = "SELECT c.*, p.port_name, p.country AS port_country, co.company_name AS owner_company_name "
                   + "FROM containers c "
                   + "LEFT JOIN ports p ON c.current_port_id = p.port_id "
                   + "LEFT JOIN companies co ON c.owner_company_id = co.company_id "
                   + "WHERE c.owner_company_id = ? ORDER BY c.container_id DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, companyId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapResultSetToContainer(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Exactly the fleet this caller should see. Super Admin sees everything;
     * company staff only their own assets; a Customer browses the public
     * catalog of bookable units.
     */
    public List<Container> getContainersForRole(int roleId, Integer companyId) {
        if (roleId == 1) return getAllContainers();
        if (roleId == 5) return getContainers("Available", 1000, 0);
        return getContainersByCompany(companyId != null ? companyId : -1);
    }

    /** Ownership guard for /containers/update and /containers/delete. */
    public boolean isOwnedBy(int containerId, int companyId) {
        String sql = "SELECT 1 FROM containers WHERE container_id = ? AND owner_company_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, containerId);
            ps.setInt(2, companyId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    /** Paginated fleet, scoped to a company when one is supplied. */
    public List<Container> getContainersPaged(String statusFilter, int limit, int offset, Integer companyId) {
        List<Container> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT c.*, p.port_name, p.country AS port_country, co.company_name AS owner_company_name "
          + "FROM containers c "
          + "LEFT JOIN ports p ON c.current_port_id = p.port_id "
          + "LEFT JOIN companies co ON c.owner_company_id = co.company_id WHERE 1=1 ");
        boolean hasStatus = statusFilter != null && !statusFilter.isEmpty() && !"All".equals(statusFilter);
        if (hasStatus)        sql.append("AND c.status = ? ");
        if (companyId != null) sql.append("AND c.owner_company_id = ? ");
        sql.append("ORDER BY c.container_id DESC LIMIT ? OFFSET ?");

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int i = 1;
            if (hasStatus)         ps.setString(i++, statusFilter);
            if (companyId != null) ps.setInt(i++, companyId);
            ps.setInt(i++, limit);
            ps.setInt(i, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapResultSetToContainer(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /** Row count matching the same filters, so pagination stays correct. */
    public int getContainerCount(String statusFilter, Integer companyId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM containers WHERE 1=1 ");
        boolean hasStatus = statusFilter != null && !statusFilter.isEmpty() && !"All".equals(statusFilter);
        if (hasStatus)         sql.append("AND status = ? ");
        if (companyId != null) sql.append("AND owner_company_id = ? ");
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int i = 1;
            if (hasStatus)         ps.setString(i++, statusFilter);
            if (companyId != null) ps.setInt(i, companyId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    /** The company filter to apply for a given caller (null = no restriction). */
    public static Integer fleetScopeFor(int roleId, Integer companyId) {
        if (roleId == 1 || roleId == 5) return null; // Super Admin global; Customer browses catalog
        return companyId;
    }

    /* ==================================================================
     * Catalog listing for /containers.
     *
     * Search, status and type used to be applied in JavaScript over the one
     * page the server had already sent, so they could never find a container
     * on page 2. They belong in the query, next to the tenant scope.
     * ================================================================== */
    private String catalogWhere(String status, String type, String search, Integer companyId,
                                List<Object> args) {
        StringBuilder w = new StringBuilder(" WHERE 1=1 ");
        if (companyId != null) { w.append("AND c.owner_company_id = ? "); args.add(companyId); }
        if (status != null && !status.trim().isEmpty() && !"All".equalsIgnoreCase(status.trim())) {
            w.append("AND c.status = ? "); args.add(status.trim());
        }
        if (type != null && !type.trim().isEmpty() && !"All".equalsIgnoreCase(type.trim())) {
            w.append("AND c.type = ? "); args.add(type.trim());
        }
        if (search != null && !search.trim().isEmpty()) {
            w.append("AND (c.container_number LIKE ? OR c.type LIKE ? OR c.size LIKE ?) ");
            String like = "%" + search.trim() + "%";
            args.add(like); args.add(like); args.add(like);
        }
        return w.toString();
    }

    public List<Container> getCatalogPage(String status, String type, String search,
                                          int limit, int offset, Integer companyId) {
        List<Container> list = new ArrayList<>();
        List<Object> args = new ArrayList<>();
        String sql = "SELECT c.*, p.port_name, p.country AS port_country, co.company_name AS owner_company_name "
                   + "FROM containers c "
                   + "LEFT JOIN ports p ON c.current_port_id = p.port_id "
                   + "LEFT JOIN companies co ON c.owner_company_id = co.company_id"
                   + catalogWhere(status, type, search, companyId, args)
                   + "ORDER BY c.container_id DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int i = 1;
            for (Object a : args) ps.setObject(i++, a);
            ps.setInt(i++, limit);
            ps.setInt(i, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapResultSetToContainer(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public int countCatalog(String status, String type, String search, Integer companyId) {
        List<Object> args = new ArrayList<>();
        String sql = "SELECT COUNT(*) FROM containers c"
                   + catalogWhere(status, type, search, companyId, args);
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int i = 1;
            for (Object a : args) ps.setObject(i++, a);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getInt(1); }
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
}
