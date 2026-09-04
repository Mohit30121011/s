package com.nlogistic.controller;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import com.nlogistic.model.User;

@WebServlet("/upload-stock")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 15    // 15MB
)
public class StockUploadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = null;
        Object userObj = request.getSession().getAttribute("user");
        if (userObj instanceof User) {
            user = (User) userObj;
        }
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (user.getRoleId() > 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        // Super Admin (roleId == 1) has no company of their own — allow filtering by
        // any specific company OR viewing "All Companies" (effectiveCompanyId = 0).
        List<java.util.Map<String, Object>> companies = new ArrayList<>();
        int effectiveCompanyId = user.getCompanyId();
        if (user.getRoleId() == 1) {
            try (Connection conn = com.nlogistic.util.DBConnectionManager.getConnection();
                 PreparedStatement psCo = conn.prepareStatement(
                     "SELECT company_id, company_name FROM companies WHERE approval_status='Active' ORDER BY company_name")) {
                try (ResultSet rsCo = psCo.executeQuery()) {
                    while (rsCo.next()) {
                        java.util.Map<String, Object> co = new java.util.HashMap<>();
                        co.put("id", rsCo.getInt("company_id"));
                        co.put("name", rsCo.getString("company_name"));
                        companies.add(co);
                    }
                }
            } catch (Exception e) { e.printStackTrace(); }

            String companyParam = request.getParameter("companyId");
            if (companyParam != null && !companyParam.trim().isEmpty()) {
                try {
                    effectiveCompanyId = Integer.parseInt(companyParam.trim());
                    request.getSession().setAttribute("selectedCompanyId", effectiveCompanyId);
                } catch (NumberFormatException ignored) {}
            } else if (request.getSession().getAttribute("selectedCompanyId") != null) {
                effectiveCompanyId = (int) request.getSession().getAttribute("selectedCompanyId");
            } else {
                // Default Super Admin to All Companies (0)
                effectiveCompanyId = 0;
                request.getSession().setAttribute("selectedCompanyId", 0);
            }
        }
        request.setAttribute("companies", companies);
        request.setAttribute("selectedCompanyId", effectiveCompanyId);

        // Fetch recent uploads (FR4.4)
        List<java.util.Map<String, Object>> recentUploads = new ArrayList<>();
        String sql;
        if (effectiveCompanyId > 0) {
            sql = "SELECT l.uploaded_at, u.username, l.success_count, l.failure_count, c.company_name "
                + "FROM stock_upload_log l "
                + "JOIN users u ON l.uploaded_by = u.user_id "
                + "JOIN companies c ON l.company_id = c.company_id "
                + "WHERE l.company_id = ? "
                + "ORDER BY l.uploaded_at DESC LIMIT 10";
        } else {
            sql = "SELECT l.uploaded_at, u.username, l.success_count, l.failure_count, c.company_name "
                + "FROM stock_upload_log l "
                + "JOIN users u ON l.uploaded_by = u.user_id "
                + "JOIN companies c ON l.company_id = c.company_id "
                + "ORDER BY l.uploaded_at DESC LIMIT 10";
        }

        // Fetch products for manual entry dropdown (FR4.1)
        List<java.util.Map<String, Object>> productList = new ArrayList<>();
        String prodSql = "SELECT product_id, product_name FROM products ORDER BY product_name";

        // Fetch current stock for overview (FR4.6)
        List<java.util.Map<String, Object>> stockList = new ArrayList<>();
        String stockSql;
        if (effectiveCompanyId > 0) {
            stockSql = "SELECT s.stock_id, s.company_id, c.company_name, p.product_name, p.hsn_code, s.warehouse_location, s.quantity_on_hand, s.batch_no "
                     + "FROM stock s "
                     + "JOIN products p ON s.product_id = p.product_id "
                     + "JOIN companies c ON s.company_id = c.company_id "
                     + "WHERE s.company_id = ? ORDER BY s.last_updated DESC, p.product_name";
        } else {
            stockSql = "SELECT s.stock_id, s.company_id, c.company_name, p.product_name, p.hsn_code, s.warehouse_location, s.quantity_on_hand, s.batch_no "
                     + "FROM stock s "
                     + "JOIN products p ON s.product_id = p.product_id "
                     + "JOIN companies c ON s.company_id = c.company_id "
                     + "ORDER BY s.last_updated DESC, p.product_name";
        }

        // Fetch full upload history (FR4.4)
        List<java.util.Map<String, Object>> fullHistoryList = new ArrayList<>();
        String histSql;
        if (effectiveCompanyId > 0) {
            histSql = "SELECT l.uploaded_at, u.username, l.file_name, l.total_records, l.success_count, l.failure_count, c.company_name "
                    + "FROM stock_upload_log l "
                    + "JOIN users u ON l.uploaded_by = u.user_id "
                    + "JOIN companies c ON l.company_id = c.company_id "
                    + "WHERE l.company_id = ? "
                    + "ORDER BY l.uploaded_at DESC LIMIT 100";
        } else {
            histSql = "SELECT l.uploaded_at, u.username, l.file_name, l.total_records, l.success_count, l.failure_count, c.company_name "
                    + "FROM stock_upload_log l "
                    + "JOIN users u ON l.uploaded_by = u.user_id "
                    + "JOIN companies c ON l.company_id = c.company_id "
                    + "ORDER BY l.uploaded_at DESC LIMIT 100";
        }

        // KPI card figures — real numbers across active context
        String kpiSql;
        if (effectiveCompanyId > 0) {
            kpiSql = "SELECT COUNT(DISTINCT s.product_id) AS total_products, "
                   + "IFNULL(SUM(s.quantity_on_hand),0) AS total_stock, "
                   + "MAX(s.last_updated) AS last_updated "
                   + "FROM stock s WHERE s.company_id = ?";
        } else {
            kpiSql = "SELECT COUNT(DISTINCT s.product_id) AS total_products, "
                   + "IFNULL(SUM(s.quantity_on_hand),0) AS total_stock, "
                   + "MAX(s.last_updated) AS last_updated "
                   + "FROM stock s";
        }

        String lastUploadSql;
        if (effectiveCompanyId > 0) {
            lastUploadSql = "SELECT l.success_count, l.uploaded_at, u.username "
                          + "FROM stock_upload_log l JOIN users u ON l.uploaded_by = u.user_id "
                          + "WHERE l.company_id = ? ORDER BY l.uploaded_at DESC LIMIT 1";
        } else {
            lastUploadSql = "SELECT l.success_count, l.uploaded_at, u.username "
                          + "FROM stock_upload_log l JOIN users u ON l.uploaded_by = u.user_id "
                          + "ORDER BY l.uploaded_at DESC LIMIT 1";
        }

        // Low stock alerts (< 50 threshold)
        List<java.util.Map<String, Object>> lowStockList = new ArrayList<>();
        final double LOW_STOCK_THRESHOLD = 50.0;
        String lowStockSql;
        if (effectiveCompanyId > 0) {
            lowStockSql = "SELECT s.stock_id, s.company_id, c.company_name, p.product_name, p.hsn_code, s.quantity_on_hand, s.warehouse_location "
                        + "FROM stock s "
                        + "JOIN products p ON s.product_id = p.product_id "
                        + "JOIN companies c ON s.company_id = c.company_id "
                        + "WHERE s.company_id = ? AND s.quantity_on_hand < ? "
                        + "ORDER BY s.quantity_on_hand ASC LIMIT 50";
        } else {
            lowStockSql = "SELECT s.stock_id, s.company_id, c.company_name, p.product_name, p.hsn_code, s.quantity_on_hand, s.warehouse_location "
                        + "FROM stock s "
                        + "JOIN products p ON s.product_id = p.product_id "
                        + "JOIN companies c ON s.company_id = c.company_id "
                        + "WHERE s.quantity_on_hand < ? "
                        + "ORDER BY s.quantity_on_hand ASC LIMIT 50";
        }

        java.util.Map<String, Object> kpi = new java.util.HashMap<>();

        try (java.sql.Connection conn = com.nlogistic.util.DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             java.sql.PreparedStatement psProd = conn.prepareStatement(prodSql);
             java.sql.PreparedStatement psStock = conn.prepareStatement(stockSql);
             java.sql.PreparedStatement psHist = conn.prepareStatement(histSql);
             java.sql.PreparedStatement psKpi = conn.prepareStatement(kpiSql);
             java.sql.PreparedStatement psLastUpload = conn.prepareStatement(lastUploadSql);
             java.sql.PreparedStatement psLowStock = conn.prepareStatement(lowStockSql)) {

            if (effectiveCompanyId > 0) {
                ps.setInt(1, effectiveCompanyId);
            }
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> upload = new java.util.HashMap<>();
                    upload.put("date", rs.getTimestamp("uploaded_at"));
                    upload.put("user", rs.getString("username"));
                    upload.put("companyName", rs.getString("company_name"));
                    upload.put("success", rs.getInt("success_count"));
                    upload.put("failed", rs.getInt("failure_count"));
                    recentUploads.add(upload);
                }
            }
            
            if (effectiveCompanyId > 0) {
                psHist.setInt(1, effectiveCompanyId);
            }
            try (java.sql.ResultSet rsHist = psHist.executeQuery()) {
                while (rsHist.next()) {
                    java.util.Map<String, Object> hist = new java.util.HashMap<>();
                    hist.put("date", rsHist.getTimestamp("uploaded_at"));
                    hist.put("user", rsHist.getString("username"));
                    hist.put("companyName", rsHist.getString("company_name"));
                    hist.put("fileName", rsHist.getString("file_name"));
                    hist.put("total", rsHist.getInt("total_records"));
                    hist.put("success", rsHist.getInt("success_count"));
                    hist.put("failed", rsHist.getInt("failure_count"));
                    fullHistoryList.add(hist);
                }
            }
            
            try (java.sql.ResultSet rsProd = psProd.executeQuery()) {
                while (rsProd.next()) {
                    java.util.Map<String, Object> prod = new java.util.HashMap<>();
                    prod.put("id", rsProd.getInt("product_id"));
                    prod.put("name", rsProd.getString("product_name"));
                    productList.add(prod);
                }
            }
            
            if (effectiveCompanyId > 0) {
                psStock.setInt(1, effectiveCompanyId);
            }
            try (java.sql.ResultSet rsStock = psStock.executeQuery()) {
                while (rsStock.next()) {
                    java.util.Map<String, Object> stk = new java.util.HashMap<>();
                    stk.put("stockId", rsStock.getInt("stock_id"));
                    stk.put("companyId", rsStock.getInt("company_id"));
                    stk.put("companyName", rsStock.getString("company_name"));
                    stk.put("productName", rsStock.getString("product_name"));
                    stk.put("hsnCode", rsStock.getString("hsn_code"));
                    stk.put("warehouse", rsStock.getString("warehouse_location"));
                    stk.put("quantity", rsStock.getDouble("quantity_on_hand"));
                    stk.put("batchNo", rsStock.getString("batch_no"));
                    stockList.add(stk);
                }
            }

            if (effectiveCompanyId > 0) {
                psKpi.setInt(1, effectiveCompanyId);
            }
            try (java.sql.ResultSet rsKpi = psKpi.executeQuery()) {
                if (rsKpi.next()) {
                    kpi.put("totalProducts", rsKpi.getInt("total_products"));
                    kpi.put("totalStock", rsKpi.getDouble("total_stock"));
                    kpi.put("lastUpdated", rsKpi.getTimestamp("last_updated"));
                }
            }

            if (effectiveCompanyId > 0) {
                psLastUpload.setInt(1, effectiveCompanyId);
            }
            try (java.sql.ResultSet rsLU = psLastUpload.executeQuery()) {
                if (rsLU.next()) {
                    kpi.put("lastUploadCount", rsLU.getInt("success_count"));
                    kpi.put("lastUploadUser", rsLU.getString("username"));
                }
            }

            if (effectiveCompanyId > 0) {
                psLowStock.setInt(1, effectiveCompanyId);
                psLowStock.setDouble(2, LOW_STOCK_THRESHOLD);
            } else {
                psLowStock.setDouble(1, LOW_STOCK_THRESHOLD);
            }
            try (java.sql.ResultSet rsLow = psLowStock.executeQuery()) {
                while (rsLow.next()) {
                    java.util.Map<String, Object> low = new java.util.HashMap<>();
                    low.put("stockId", rsLow.getInt("stock_id"));
                    low.put("companyId", rsLow.getInt("company_id"));
                    low.put("companyName", rsLow.getString("company_name"));
                    low.put("productName", rsLow.getString("product_name"));
                    low.put("hsnCode", rsLow.getString("hsn_code"));
                    low.put("quantity", rsLow.getDouble("quantity_on_hand"));
                    low.put("warehouse", rsLow.getString("warehouse_location"));
                    lowStockList.add(low);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("recentUploads", recentUploads);
        request.setAttribute("productList", productList);
        request.setAttribute("stockList", stockList);
        request.setAttribute("fullHistoryList", fullHistoryList);
        request.setAttribute("kpi", kpi);
        request.setAttribute("lowStockList", lowStockList);
        request.getRequestDispatcher("/jsp/upload-stock.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = null;
        Object userObj = request.getSession().getAttribute("user");
        if (userObj instanceof User) {
            user = (User) userObj;
        }
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (user.getRoleId() > 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only Staff can upload stock.");
            return;
        }

        Part filePart = request.getPart("csvFile"); 
        if (filePart == null || filePart.getSize() == 0) {
            request.getSession().setAttribute("errorMessage", "Please select a valid CSV file.");
            response.sendRedirect(request.getContextPath() + "/upload-stock?tab=bulk");
            return;
        }

        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        
        int totalRows = 0;
        int validRows = 0;
        int invalidRows = 0;
        
        List<String> validData = new ArrayList<>();
        List<String> errorData = new ArrayList<>();
        errorData.add("RowNumber,ErrorReason,OriginalData"); // Error CSV header

        try (InputStream fileContent = filePart.getInputStream();
             BufferedReader reader = new BufferedReader(new InputStreamReader(fileContent))) {
            
            String header = reader.readLine(); // skip or parse header
            if (header == null) {
                throw new Exception("File is empty.");
            }
            
            String line;
            int rowNum = 1;
            while ((line = reader.readLine()) != null) {
                rowNum++;
                totalRows++;
                if (line.trim().isEmpty()) continue;

                // Simple comma split (assuming no quotes/commas inside values for this prototype)
                String[] cols = line.split(",", -1);
                
                // Format: ProductName, Category, HSNCode, UOM, Quantity, UnitCost, UnitPrice, WarehouseLocation, BatchNo, ExpiryDate
                if (cols.length < 8) {
                    invalidRows++;
                    errorData.add(rowNum + ",Missing required columns," + line);
                    continue;
                }

                try {
                    double quantity = Double.parseDouble(cols[4].trim());
                    double unitCost = Double.parseDouble(cols[5].trim());
                    double unitPrice = Double.parseDouble(cols[6].trim());

                    // FR4.3 Validation
                    if (quantity < 0 || unitCost < 0 || unitPrice < 0) {
                        invalidRows++;
                        errorData.add(rowNum + ",Negative values are not allowed (FR4.3)," + line);
                    } else {
                        validRows++;
                        validData.add(line); // Save for DB insertion later
                    }
                } catch (NumberFormatException e) {
                    invalidRows++;
                    errorData.add(rowNum + ",Invalid number format for Quantity/Cost/Price," + line);
                }
            }
            
            // Step 3 - Insert validData into database (products, stock, inventory_ledger)
            // Super Admin has no company of their own — they must pick which company this
            // upload is for (hidden "companyId" field on the form); staff use their own.
            int companyId = user.getCompanyId();
            if (user.getRoleId() == 1) {
                String companyParam = request.getParameter("companyId");
                if (companyParam == null || companyParam.trim().isEmpty() || "0".equals(companyParam.trim())) {
                    request.getSession().setAttribute("errorMessage", "Please select a specific company for this stock upload.");
                    response.sendRedirect(request.getContextPath() + "/upload-stock?tab=bulk");
                    return;
                }
                try {
                    companyId = Integer.parseInt(companyParam.trim());
                } catch (NumberFormatException e) {
                    request.getSession().setAttribute("errorMessage", "Invalid company selection.");
                    response.sendRedirect(request.getContextPath() + "/upload-stock?tab=bulk");
                    return;
                }
            } else if (companyId == 0) {
                request.getSession().setAttribute("errorMessage", "You must belong to a company (Company Admin or Operations Staff) to manage inventory.");
                response.sendRedirect(request.getContextPath() + "/upload-stock?tab=bulk");
                return;
            }
            
            String errorFilePath = null;
            try (Connection conn = com.nlogistic.util.DBConnectionManager.getConnection()) {
                conn.setAutoCommit(false);
                
                String checkProduct = "SELECT product_id FROM products WHERE product_name = ?";
                String insertProduct = "INSERT INTO products (product_name, category, hsn_code, unit_of_measure, unit_cost, unit_price) VALUES (?, ?, ?, ?, ?, ?)";
                
                String checkStock = "SELECT stock_id, quantity_on_hand FROM stock WHERE company_id = ? AND product_id = ?";
                String insertStock = "INSERT INTO stock (company_id, product_id, warehouse_location, quantity_on_hand, batch_no, expiry_date) VALUES (?, ?, ?, ?, ?, ?)";
                String updateStock = "UPDATE stock SET quantity_on_hand = quantity_on_hand + ?, warehouse_location = ?, last_updated = CURRENT_TIMESTAMP WHERE stock_id = ?";
                
                String insertLedger = "INSERT INTO inventory_ledger (product_id, transaction_type, quantity, unit_cost_at_txn, reference_type) VALUES (?, 'IN', ?, ?, 'Bulk Upload')";
                
                try (PreparedStatement psCheckProd = conn.prepareStatement(checkProduct);
                     PreparedStatement psInsertProd = conn.prepareStatement(insertProduct, java.sql.Statement.RETURN_GENERATED_KEYS);
                     PreparedStatement psCheckStock = conn.prepareStatement(checkStock);
                     PreparedStatement psInsertStock = conn.prepareStatement(insertStock);
                     PreparedStatement psUpdateStock = conn.prepareStatement(updateStock);
                     PreparedStatement psInsertLedger = conn.prepareStatement(insertLedger)) {
                    
                    for (String validLine : validData) {
                        String[] cols = validLine.split(",", -1);
                        String pName = cols[0].trim();
                        String category = cols[1].trim();
                        String hsn = cols[2].trim();
                        String uom = cols[3].trim();
                        double quantity = Double.parseDouble(cols[4].trim());
                        double unitCost = Double.parseDouble(cols[5].trim());
                        double unitPrice = Double.parseDouble(cols[6].trim());
                        String warehouse = cols[7].trim();
                        String batch = cols.length > 8 ? cols[8].trim() : null;
                        
                        // Parse Expiry Date safely
                        java.sql.Date expiry = null;
                        if (cols.length > 9 && !cols[9].trim().isEmpty() && !cols[9].trim().equals("-")) {
                            try { expiry = java.sql.Date.valueOf(cols[9].trim()); } catch(Exception e) {}
                        }
                        
                        // 1. Product Logic
                        int productId = -1;
                        psCheckProd.setString(1, pName);
                        try (ResultSet rs = psCheckProd.executeQuery()) {
                            if (rs.next()) {
                                productId = rs.getInt("product_id");
                            }
                        }
                        if (productId == -1) {
                            psInsertProd.setString(1, pName);
                            psInsertProd.setString(2, category);
                            psInsertProd.setString(3, hsn);
                            psInsertProd.setString(4, uom);
                            psInsertProd.setDouble(5, unitCost);
                            psInsertProd.setDouble(6, unitPrice);
                            psInsertProd.executeUpdate();
                            try (ResultSet rs = psInsertProd.getGeneratedKeys()) {
                                if (rs.next()) productId = rs.getInt(1);
                            }
                        }
                        
                        // 2. Stock Logic
                        int stockId = -1;
                        psCheckStock.setInt(1, companyId);
                        psCheckStock.setInt(2, productId);
                        try (ResultSet rs = psCheckStock.executeQuery()) {
                            if (rs.next()) stockId = rs.getInt("stock_id");
                        }
                        
                        if (stockId == -1) {
                            psInsertStock.setInt(1, companyId);
                            psInsertStock.setInt(2, productId);
                            psInsertStock.setString(3, warehouse);
                            psInsertStock.setDouble(4, quantity);
                            psInsertStock.setString(5, batch);
                            psInsertStock.setDate(6, expiry);
                            psInsertStock.executeUpdate();
                        } else {
                            psUpdateStock.setDouble(1, quantity);
                            psUpdateStock.setString(2, warehouse);
                            psUpdateStock.setInt(3, stockId);
                            psUpdateStock.executeUpdate();
                        }
                        
                        // 3. Inventory Ledger (FR4.5)
                        psInsertLedger.setInt(1, productId);
                        psInsertLedger.setDouble(2, quantity);
                        psInsertLedger.setDouble(3, unitCost);
                        psInsertLedger.executeUpdate();
                    }
                }
                
                if (invalidRows > 0) {
                    String tempDir = System.getProperty("java.io.tmpdir");
                    String fileNameOut = "error_report_" + System.currentTimeMillis() + ".csv";
                    File errorFile = new File(tempDir, fileNameOut);
                    try (java.io.FileWriter writer = new java.io.FileWriter(errorFile)) {
                        for (String errLine : errorData) {
                            writer.write(errLine + "\n");
                        }
                    }
                    errorFilePath = errorFile.getAbsolutePath();
                }
                
                String insertLog = "INSERT INTO stock_upload_log (company_id, uploaded_by, file_name, total_records, success_count, failure_count, error_report_path) VALUES (?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement psLog = conn.prepareStatement(insertLog)) {
                    psLog.setInt(1, companyId);
                    psLog.setInt(2, user.getUserId());
                    psLog.setString(3, fileName);
                    psLog.setInt(4, totalRows);
                    psLog.setInt(5, validRows);
                    psLog.setInt(6, invalidRows);
                    psLog.setString(7, errorFilePath);
                    psLog.executeUpdate();
                }
                
                conn.commit();
            }

            String msg = String.format("File '%s' processed. Total: %d, Valid: %d, Invalid: %d", fileName, totalRows, validRows, invalidRows);
            request.getSession().setAttribute("successMessage", msg);
            if (errorFilePath != null) {
                request.getSession().setAttribute("errorFilePath", java.net.URLEncoder.encode(errorFilePath, "UTF-8"));
            } else {
                request.getSession().setAttribute("errorFilePath", null);
            }
            
            request.getSession().setAttribute("selectedCompanyId", companyId);
            response.sendRedirect(request.getContextPath() + "/upload-stock?companyId=" + companyId + "&tab=history");

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Error parsing CSV: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/upload-stock?tab=bulk");
        }
    }
}
