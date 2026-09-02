package com.nlogistic.dao;

import com.nlogistic.model.*;
import com.nlogistic.util.DBConnectionManager;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BarcodeDAO {

    /**
     * Calls: getall_barcode_entries() - returns all columns from barcode_entries.
     * DB columns: barcode_id, barcode_value, barcode_type, entity_type, entity_id, image_path, generated_by, generated_at
     */
    public List<BarcodeEntry> getAllBarcodes() {
        List<BarcodeEntry> list = new ArrayList<>();
        String sql = "{CALL getall_barcode_entries()}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {
            while (rs.next()) {
                BarcodeEntry b = new BarcodeEntry();
                b.setBarcodeId(rs.getInt("barcode_id"));
                b.setBarcodeValue(rs.getString("barcode_value"));
                b.setBarcodeType(rs.getString("barcode_type"));
                b.setEntityType(rs.getString("entity_type"));
                b.setEntityId(rs.getInt("entity_id"));
                b.setImagePath(rs.getString("image_path"));
                b.setGeneratedBy(rs.getInt("generated_by"));
                b.setGeneratedAt(rs.getTimestamp("generated_at"));
                list.add(b);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Calls: getall_barcode_scan_logs() - returns all columns from barcode_scan_log.
     * DB columns: scan_id, barcode_id, scanned_by, scanned_at, scan_location, module_context
     */
    public List<BarcodeScanLog> getAllScanLogs() {
        List<BarcodeScanLog> list = new ArrayList<>();
        String sql = "{CALL getall_barcode_scan_logs()}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {
            while (rs.next()) {
                BarcodeScanLog log = new BarcodeScanLog();
                log.setScanId(rs.getInt("scan_id"));
                log.setBarcodeId(rs.getInt("barcode_id"));
                log.setScannedBy(rs.getInt("scanned_by"));
                log.setScannedAt(rs.getTimestamp("scanned_at"));
                log.setScanLocation(rs.getString("scan_location"));
                log.setModuleContext(rs.getString("module_context"));
                list.add(log);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Calls: generate_barcode(p_barcode_value, p_barcode_type, p_entity_type, p_entity_id, p_image_path, p_generated_by)
     * 6 IN params, NO OUT param. Barcode value is auto-generated if empty.
     */
    public String generateBarcode(String entityType, int entityId, int generatedBy) {
        // Auto-generate barcode value: ENTITYTYPE-ENTITYID-TIMESTAMP
        String barcodeValue = entityType.toUpperCase() + "-" + entityId + "-" + System.currentTimeMillis();
        String sql = "{CALL generate_barcode(?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, barcodeValue);
            cs.setString(2, "Code128");
            cs.setString(3, entityType);
            cs.setInt(4, entityId);
            cs.setString(5, null); // image_path - generated client-side via JsBarcode
            cs.setInt(6, generatedBy);
            cs.execute();
        } catch (Exception e) { e.printStackTrace(); }
        return barcodeValue;
    }

    /**
     * Calls: scan_barcode(p_barcode_value, p_scanned_by, p_scan_location, p_module_context, OUT p_entity_type, OUT p_entity_id)
     * 4 IN + 2 OUT params.
     */
    public String[] scanBarcode(String barcodeValue, String scanLocation, int scannedBy, String moduleContext) {
        String sql = "{CALL scan_barcode(?, ?, ?, ?, ?, ?)}";
        String[] result = new String[2]; // [entityType, entityId]
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, barcodeValue);
            cs.setInt(2, scannedBy);
            cs.setString(3, scanLocation);
            cs.setString(4, moduleContext);
            cs.registerOutParameter(5, Types.VARCHAR);
            cs.registerOutParameter(6, Types.INTEGER);
            cs.execute();
            result[0] = cs.getString(5);
            result[1] = String.valueOf(cs.getInt(6));
        } catch (Exception e) { e.printStackTrace(); }
        return result;
    }

    /**
     * Calls: get_scan_history_for_barcode(p_barcode_id)
     */
    public List<BarcodeScanLog> getScanHistoryForBarcode(int barcodeId) {
        List<BarcodeScanLog> list = new ArrayList<>();
        String sql = "{CALL get_scan_history_for_barcode(?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, barcodeId);
            ResultSet rs = cs.executeQuery();
            while (rs.next()) {
                BarcodeScanLog log = new BarcodeScanLog();
                log.setScanId(rs.getInt("scan_id"));
                log.setBarcodeId(rs.getInt("barcode_id"));
                log.setScannedBy(rs.getInt("scanned_by"));
                log.setScannedAt(rs.getTimestamp("scanned_at"));
                log.setScanLocation(rs.getString("scan_location"));
                log.setModuleContext(rs.getString("module_context"));
                list.add(log);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Calls: get_entity_by_barcode(p_barcode_value)
     */
    public String[] getEntityByBarcode(String barcodeValue) {
        String sql = "{CALL get_entity_by_barcode(?)}";
        String[] result = new String[3]; // [entityType, entityId, generatedAt]
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, barcodeValue);
            ResultSet rs = cs.executeQuery();
            if (rs.next()) {
                result[0] = rs.getString("entity_type");
                result[1] = String.valueOf(rs.getInt("entity_id"));
                result[2] = rs.getString("generated_at");
            }
        } catch (Exception e) { e.printStackTrace(); }
        return result;
    }
}
