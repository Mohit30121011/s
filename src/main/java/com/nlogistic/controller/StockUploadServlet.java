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
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        // Fetch recent uploads (FR4.4)
        List<java.util.Map<String, Object>> recentUploads = new ArrayList<>();
        String sql = "SELECT l.uploaded_at, u.username, l.success_count, l.failure_count "
                   + "FROM stock_upload_log l "
                   + "JOIN users u ON l.uploaded_by = u.user_id "
                   + "WHERE l.company_id = ? "
                   + "ORDER BY l.uploaded_at DESC LIMIT 5";

        // Fetch products for manual entry dropdown (FR4.1)
        List<java.util.Map<String, Object>> productList = new ArrayList<>();
        String prodSql = "SELECT product_id, product_name FROM products ORDER BY product_name";

        // Fetch current stock for overview (FR4.6)
        List<java.util.Map<String, Object>> stockList = new ArrayList<>();
        String stockSql = "SELECT s.stock_id, p.product_name, p.hsn_code, s.warehouse_location, s.quantity_on_hand "
                        + "FROM stock s JOIN products p ON s.product_id = p.product_id "
                        + "WHERE s.company_id = ? ORDER BY p.product_name";

        // Fetch full upload history (FR4.4)
        List<java.util.Map<String, Object>> fullHistoryList = new ArrayList<>();
        String histSql = "SELECT l.uploaded_at, u.username, l.file_name, l.total_records, l.success_count, l.failure_count "
                       + "FROM stock_upload_log l "
                       + "JOIN users u ON l.uploaded_by = u.user_id "
                       + "WHERE l.company_id = ? "
                       + "ORDER BY l.uploaded_at DESC LIMIT 50";

        try (java.sql.Connection conn = com.nlogistic.util.DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             java.sql.PreparedStatement psProd = conn.prepareStatement(prodSql);
             java.sql.PreparedStatement psStock = conn.prepareStatement(stockSql);
             java.sql.PreparedStatement psHist = conn.prepareStatement(histSql)) {
            
            ps.setInt(1, user.getCompanyId());
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> upload = new java.util.HashMap<>();
                    upload.put("date", rs.getTimestamp("uploaded_at"));
                    upload.put("user", rs.getString("username"));
                    upload.put("success", rs.getInt("success_count"));
                    upload.put("failed", rs.getInt("failure_count"));
                    recentUploads.add(upload);
                }
            }
            
            psHist.setInt(1, user.getCompanyId());
            try (java.sql.ResultSet rsHist = psHist.executeQuery()) {
                while (rsHist.next()) {
                    java.util.Map<String, Object> hist = new java.util.HashMap<>();
                    hist.put("date", rsHist.getTimestamp("uploaded_at"));
                    hist.put("user", rsHist.getString("username"));
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
            
            psStock.setInt(1, user.getCompanyId());
            try (java.sql.ResultSet rsStock = psStock.executeQuery()) {
                while (rsStock.next()) {
                    java.util.Map<String, Object> stk = new java.util.HashMap<>();
                    stk.put("stockId", rsStock.getInt("stock_id"));
                    stk.put("productName", rsStock.getString("product_name"));
                    stk.put("hsnCode", rsStock.getString("hsn_code"));
                    stk.put("warehouse", rsStock.getString("warehouse_location"));
                    stk.put("quantity", rsStock.getDouble("quantity_on_hand"));
                    stockList.add(stk);
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("recentUploads", recentUploads);
        request.setAttribute("productList", productList);
        request.setAttribute("stockList", stockList);
        request.setAttribute("fullHistoryList", fullHistoryList);
        request.getRequestDispatcher("/jsp/upload-stock.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only Staff can upload stock.");
            return;
        }

        Part filePart = request.getPart("csvFile"); 
        if (filePart == null || filePart.getSize() == 0) {
            request.setAttribute("errorMessage", "Please select a valid CSV file.");
            request.getRequestDispatcher("/jsp/upload-stock.jsp").forward(request, response);
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
            int companyId = user.getCompanyId();
            
            // STRICT SRS ENFORCEMENT: FR4.1 "Company staff shall be able to upload stock"
            if (companyId == 0) {
                request.setAttribute("errorMessage", "SRS Violation: Super Admins cannot upload stock. You must belong to a company (Company Admin or Operations Staff) to manage inventory.");
                request.getRequestDispatcher("/jsp/upload-stock.jsp").forward(request, response);
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
            
            response.sendRedirect(request.getContextPath() + "/upload-stock");

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Error parsing CSV: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/upload-stock");
        }
    }
}
