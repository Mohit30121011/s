package com.nlogistic.dao;

import com.nlogistic.model.Stock;
import com.nlogistic.model.InventoryLedger;
import com.nlogistic.util.DBConnectionManager;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class StockDAO {
    
    public List<Stock> getAllStock() {
        List<Stock> list = new ArrayList<>();
        String sql = "SELECT s.*, p.product_name FROM stock s JOIN products p ON s.product_id = p.product_id ORDER BY s.stock_id DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Stock s = new Stock();
                s.setStockId(rs.getInt("stock_id"));
                s.setCompanyId(rs.getInt("company_id"));
                s.setProductId(rs.getInt("product_id"));
                s.setProductName(rs.getString("product_name"));
                s.setWarehouseLocation(rs.getString("warehouse_location"));
                s.setQuantityOnHand(rs.getDouble("quantity_on_hand"));
                s.setBatchNo(rs.getString("batch_no"));
                s.setExpiryDate(rs.getDate("expiry_date"));
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<InventoryLedger> getInventoryLedger() {
        List<InventoryLedger> list = new ArrayList<>();
        String sql = "SELECT l.*, p.product_name FROM inventory_ledger l JOIN products p ON l.product_id = p.product_id ORDER BY l.txn_date DESC LIMIT 50";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                InventoryLedger l = new InventoryLedger();
                l.setLedgerId(rs.getInt("ledger_id"));
                l.setProductId(rs.getInt("product_id"));
                l.setProductName(rs.getString("product_name"));
                l.setTransactionType(rs.getString("transaction_type"));
                l.setQuantity(rs.getDouble("quantity"));
                l.setUnitCostAtTxn(rs.getDouble("unit_cost_at_txn"));
                l.setReferenceType(rs.getString("reference_type"));
                l.setReferenceId(rs.getInt("reference_id"));
                l.setTransactionDate(rs.getTimestamp("txn_date"));
                list.add(l);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean adjustStock(int stockId, int productId, double newQty, String reason) {
        String sql = "{CALL adjust_stock(?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, stockId);
            cs.setInt(2, productId);
            cs.setDouble(3, newQty);
            cs.setString(4, reason);
            cs.execute();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public int uploadStockCsv(int companyId, int userId, String fileName, InputStream fileContent) {
        Connection conn = null;
        try {
            conn = DBConnectionManager.getConnection();
            
            // 1. Start Upload Log
            String startSql = "{CALL start_upload_log(?, ?, ?, ?)}";
            int uploadId = -1;
            try (CallableStatement csStart = conn.prepareCall(startSql)) {
                csStart.setInt(1, companyId);
                csStart.setInt(2, userId);
                csStart.setString(3, fileName);
                csStart.registerOutParameter(4, Types.INTEGER);
                csStart.execute();
                uploadId = csStart.getInt(4);
            }
            
            if (uploadId == -1) return -1;
            
            // 2. Parse CSV and Upload Rows
            try (BufferedReader br = new BufferedReader(new InputStreamReader(fileContent))) {
                String line;
                boolean isFirstLine = true;
                while ((line = br.readLine()) != null) {
                    if (isFirstLine) {
                        isFirstLine = false;
                        continue; // Skip header
                    }
                    if (line.trim().isEmpty()) continue;
                    
                    String[] cols = line.split(",");
                    // Expected format: productId, warehouseLocation, quantity, unitCost, batchNo, expiryDate
                    // Example: 1,Mumbai Warehouse B,200.5,8000,BATCH002,2026-12-31
                    if (cols.length < 4) continue;
                    
                    try {
                        int productId = Integer.parseInt(cols[0].trim());
                        String location = cols[1].trim();
                        double quantity = Double.parseDouble(cols[2].trim());
                        double unitCost = Double.parseDouble(cols[3].trim());
                        String batch = cols.length > 4 ? cols[4].trim() : null;
                        java.sql.Date expiry = null;
                        if (cols.length > 5 && !cols[5].trim().isEmpty() && !cols[5].trim().equalsIgnoreCase("null")) {
                            expiry = java.sql.Date.valueOf(cols[5].trim());
                        }

                        String rowSql = "{CALL upload_stock_row(?, ?, ?, ?, ?, ?, ?, ?)}";
                        try (CallableStatement csRow = conn.prepareCall(rowSql)) {
                            csRow.setInt(1, companyId);
                            csRow.setInt(2, productId);
                            csRow.setString(3, location);
                            csRow.setDouble(4, quantity);
                            csRow.setDouble(5, unitCost);
                            csRow.setString(6, batch != null ? batch : "");
                            csRow.setDate(7, expiry);
                            csRow.setInt(8, uploadId);
                            csRow.execute();
                        }
                    } catch (Exception ex) {
                        // Log failure for this specific row, but continue with next
                        System.err.println("Failed to process row: " + line);
                        ex.printStackTrace();
                    }
                }
            }
            return uploadId;
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (Exception e) {}
            }
        }
    }

    /**
     * DB: record_sale(p_product_id, p_customer_id, p_shipment_id, p_quantity, p_sale_price)
     */
    public boolean recordSale(int productId, int customerId, Integer shipmentId, double quantity, double salePrice) {
        String sql = "{CALL record_sale(?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnectionManager.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, productId);
            cs.setInt(2, customerId);
            if (shipmentId != null) cs.setInt(3, shipmentId); else cs.setNull(3, Types.INTEGER);
            cs.setDouble(4, quantity);
            cs.setDouble(5, salePrice);
            cs.execute();
            return true;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

}
