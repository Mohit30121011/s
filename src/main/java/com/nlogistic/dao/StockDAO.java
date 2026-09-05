package com.nlogistic.dao;

import com.nlogistic.model.Stock;
import com.nlogistic.model.InventoryLedger;
import com.nlogistic.util.DBConnectionManager;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.CallableStatement;
import java.sql.Statement;
import java.sql.SQLException;
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

            // FR4.3: rejected rows must be collectible into a downloadable error report.
            List<String> errorData = new ArrayList<>();
            errorData.add("RowNumber,ErrorReason,OriginalData");
            int rowNum = 1;

            // 2. Parse CSV and Upload Rows
            try (BufferedReader br = new BufferedReader(new InputStreamReader(fileContent))) {
                String line;
                boolean isFirstLine = true;
                while ((line = br.readLine()) != null) {
                    if (isFirstLine) {
                        isFirstLine = false;
                        continue; // Skip header
                    }
                    rowNum++;
                    if (line.trim().isEmpty()) continue;

                    String[] cols = line.split(",");

                    // FR4.2 canonical template (assets/templates/stock_template.csv):
                    //   ProductName, Category, HSNCode, UOM, Quantity, UnitCost,
                    //   UnitPrice, WarehouseLocation, BatchNo, ExpiryDate
                    // The legacy 6-column form (productId, location, qty, cost, batch,
                    // expiry) is still accepted so older files keep working.
                    boolean canonical = cols.length >= 8;
                    if (cols.length < 4) {
                        errorData.add(rowNum + ",Missing required columns," + line);
                        continue;
                    }

                    try {
                        int productId;
                        String location;
                        double quantity, unitCost;
                        String batch;
                        java.sql.Date expiry = null;

                        if (canonical) {
                            String productName = cols[0].trim();
                            if (productName.isEmpty()) {
                                errorData.add(rowNum + ",Product name is required," + line);
                                continue;
                            }
                            quantity = Double.parseDouble(cols[4].trim());
                            unitCost = Double.parseDouble(cols[5].trim());
                            double unitPrice = Double.parseDouble(cols[6].trim());
                            location = cols[7].trim();
                            batch = cols.length > 8 ? cols[8].trim() : null;
                            if (cols.length > 9 && !cols[9].trim().isEmpty()
                                    && !cols[9].trim().equalsIgnoreCase("null")) {
                                expiry = java.sql.Date.valueOf(cols[9].trim());
                            }
                            productId = resolveOrCreateProduct(conn, productName, cols[1].trim(),
                                    cols[2].trim(), cols[3].trim(), unitCost, unitPrice);
                        } else {
                            productId = Integer.parseInt(cols[0].trim());
                            location = cols[1].trim();
                            quantity = Double.parseDouble(cols[2].trim());
                            unitCost = Double.parseDouble(cols[3].trim());
                            batch = cols.length > 4 ? cols[4].trim() : null;
                            if (cols.length > 5 && !cols[5].trim().isEmpty()
                                    && !cols[5].trim().equalsIgnoreCase("null")) {
                                expiry = java.sql.Date.valueOf(cols[5].trim());
                            }
                        }

                        // FR4.3: quantity/unit cost must be >= 0. Let upload_stock_row's
                        // own SIGNAL do the rejection so stock_upload_log's
                        // total_records/failure_count stay accurate (caught below).
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
                        errorData.add(rowNum + "," + ex.getMessage() + "," + line);
                    }
                }
            }

            // 3. If any rows failed, write a downloadable error report and record its
            //    path against the upload log (FR4.3 + FR4.4).
            if (errorData.size() > 1) {
                String tempDir = System.getProperty("java.io.tmpdir");
                String fileNameOut = "error_report_" + System.currentTimeMillis() + ".csv";
                java.io.File errorFile = new java.io.File(tempDir, fileNameOut);
                try (java.io.FileWriter writer = new java.io.FileWriter(errorFile)) {
                    for (String errLine : errorData) {
                        writer.write(errLine + "\n");
                    }
                }
                String updateLogSql = "UPDATE stock_upload_log SET error_report_path = ? WHERE upload_id = ?";
                try (PreparedStatement psUpd = conn.prepareStatement(updateLogSql)) {
                    psUpd.setString(1, errorFile.getAbsolutePath());
                    psUpd.setInt(2, uploadId);
                    psUpd.executeUpdate();
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
     * Fetch a single upload-log row (FR4.3 error-report link + FR4.4 counts) so the
     * Stock Overview page can show the outcome of a just-completed /inventory/stock/upload.
     */
    public java.util.Map<String, Object> getUploadLogById(int uploadId) {
        String sql = "SELECT file_name, total_records, success_count, failure_count, error_report_path FROM stock_upload_log WHERE upload_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, uploadId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    java.util.Map<String, Object> m = new java.util.HashMap<>();
                    m.put("fileName", rs.getString("file_name"));
                    m.put("total", rs.getInt("total_records"));
                    m.put("success", rs.getInt("success_count"));
                    m.put("failed", rs.getInt("failure_count"));
                    m.put("errorReportPath", rs.getString("error_report_path"));
                    return m;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
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


    /* ==================================================================
     * RBAC tenant scoping for warehouse data (CLAUDE.md S4).
     * Stock and the inventory ledger belong to a single company; a fresh
     * tenant must see an empty warehouse, not every other company's goods.
     * ================================================================== */

    /** Stock rows owned by one company. Super Admin should call getAllStock(). */
    public List<Stock> getStockByCompany(int companyId) {
        List<Stock> list = new ArrayList<>();
        String sql = "SELECT s.*, p.product_name FROM stock s JOIN products p ON s.product_id = p.product_id "
                   + "WHERE s.company_id = ? ORDER BY s.stock_id DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, companyId);
            try (ResultSet rs = ps.executeQuery()) {
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
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /** Returns exactly the stock this caller may see. companyId 0/null = all. */
    public List<Stock> getStockForRole(int roleId, Integer companyId) {
        if (roleId == 1 || companyId == null || companyId <= 0) return getAllStock();
        return getStockByCompany(companyId);
    }

    /** Ledger entries limited to products this company actually holds stock of. */
    public List<InventoryLedger> getLedgerForRole(int roleId, Integer companyId) {
        List<InventoryLedger> all = getInventoryLedger();
        if (roleId == 1 || companyId == null || companyId <= 0) return all;
        final java.util.Set<Integer> mine = new java.util.HashSet<>();
        String sql = "SELECT DISTINCT product_id FROM stock WHERE company_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, companyId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) mine.add(rs.getInt(1));
            }
        } catch (Exception e) { e.printStackTrace(); }
        all.removeIf(l -> !mine.contains(l.getProductId()));
        return all;
    }

    /**
     * Looks up a product by name, creating it when the SKU is new (FR4.2 says an
     * upload upserts the catalogue master). Runs on the caller's connection so it
     * shares the upload transaction.
     */
    private int resolveOrCreateProduct(Connection conn, String name, String category,
                                       String hsn, String uom, double unitCost, double unitPrice)
            throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT product_id FROM products WHERE product_name = ? LIMIT 1")) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO products (product_name, category, hsn_code, unit_of_measure, unit_cost, unit_price) "
              + "VALUES (?, ?, ?, ?, ?, ?)", Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, name);
            ps.setString(2, (category == null || category.isEmpty()) ? "Uncategorised" : category);
            ps.setString(3, hsn);
            ps.setString(4, (uom == null || uom.isEmpty()) ? "unit" : uom);
            ps.setDouble(5, unitCost);
            ps.setDouble(6, unitPrice);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        throw new SQLException("Could not resolve or create product '" + name + "'");
    }
}
