package com.nlogistic.controller;

import com.nlogistic.dao.CustomerDAO;
import com.nlogistic.dao.ProductDAO;
import com.nlogistic.dao.StockDAO;
import com.nlogistic.model.Product;
import com.nlogistic.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;

@WebServlet("/inventory/*")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
    maxFileSize = 1024 * 1024 * 10,      // 10 MB
    maxRequestSize = 1024 * 1024 * 100   // 100 MB
)
public class InventoryServlet extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();
    private StockDAO stockDAO = new StockDAO();
    private CustomerDAO customerDAO = new CustomerDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/products")) {
            request.setAttribute("products", productDAO.getAllProducts());
            request.getRequestDispatcher("/jsp/products.jsp").forward(request, response);
        } else if (pathInfo.equals("/stock")) {
            // RBAC: warehouse stock is tenant-owned. A Super Admin sees everything;
            // company staff only their own company's goods and ledger entries.
            int invRole = com.nlogistic.util.RbacContext.roleId(request);
            Integer invCompany = com.nlogistic.util.RbacContext.companyId(request);
            request.setAttribute("stocks", stockDAO.getStockForRole(invRole, invCompany));
            request.setAttribute("ledger", stockDAO.getLedgerForRole(invRole, invCompany));
            request.setAttribute("products", productDAO.getAllProducts()); // Needed for dropdown
            request.setAttribute("customers", customerDAO.getAllCustomers()); // FR4.5: needed for Record Sale

            // FR4.3/FR4.4: show the outcome (and any downloadable error report) of a
            // bulk CSV upload just performed via /inventory/stock/upload.
            String uploadIdParam = request.getParameter("uploadId");
            if (uploadIdParam != null) {
                try {
                    java.util.Map<String, Object> uploadInfo = stockDAO.getUploadLogById(Integer.parseInt(uploadIdParam));
                    if (uploadInfo != null) {
                        Object errPath = uploadInfo.get("errorReportPath");
                        if (errPath != null) {
                            uploadInfo.put("errorReportPath", java.net.URLEncoder.encode((String) errPath, "UTF-8"));
                        }
                        request.setAttribute("uploadInfo", uploadInfo);
                    }
                } catch (NumberFormatException ignore) { }
            }

            request.getRequestDispatcher("/jsp/stock.jsp").forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (pathInfo != null && pathInfo.equals("/product/add")) {
            try {
                Product p = new Product();
                p.setProductName(request.getParameter("productName"));
                p.setCategory(request.getParameter("category"));
                p.setHsnCode(request.getParameter("hsnCode"));
                p.setUnitOfMeasure(request.getParameter("unitOfMeasure"));
                double cost = Double.parseDouble(request.getParameter("unitCost"));
                double price = Double.parseDouble(request.getParameter("unitPrice"));

                // FR4.3: quantity/cost/price must not be negative
                if (cost < 0 || price < 0) {
                    response.sendRedirect(request.getContextPath() + "/inventory/products?error=negative_values");
                    return;
                }
                p.setUnitCost(cost);
                p.setUnitPrice(price);

                boolean success = productDAO.addProduct(p);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/inventory/products?success=true");
                } else {
                    response.sendRedirect(request.getContextPath() + "/inventory/products?error=true");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/inventory/products?error=invalid_input");
            }
        } else if (pathInfo != null && pathInfo.equals("/product/update")) {
            try {
                int productId = Integer.parseInt(request.getParameter("productId"));
                double cost = Double.parseDouble(request.getParameter("unitCost"));
                double price = Double.parseDouble(request.getParameter("unitPrice"));

                // FR4.3: quantity/cost/price must not be negative
                if (cost < 0 || price < 0) {
                    response.sendRedirect(request.getContextPath() + "/inventory/products?error=negative_values");
                    return;
                }

                productDAO.updateProduct(productId, currentUser != null ? currentUser.getUserId() : 0,
                        request.getParameter("productName"), request.getParameter("category"),
                        request.getParameter("hsnCode"), request.getParameter("unitOfMeasure"), cost, price);
                response.sendRedirect(request.getContextPath() + "/inventory/products?success=updated");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/inventory/products?error=invalid_input");
            }
        } else if (pathInfo != null && pathInfo.equals("/stock/upload")) {
            Part filePart = request.getPart("stockCsv");
            if (filePart != null) {
                String fileName = filePart.getSubmittedFileName();
                try (InputStream fileContent = filePart.getInputStream()) {
                    int companyId = currentUser != null ? currentUser.getCompanyId() : 0;
                    int userId = currentUser != null ? currentUser.getUserId() : 0;
                    int uploadId = stockDAO.uploadStockCsv(companyId, userId, fileName, fileContent);
                    if (uploadId != -1) {
                        response.sendRedirect(request.getContextPath() + "/inventory/stock?success=true&uploadId=" + uploadId);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/inventory/stock?error=true");
                    }
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/inventory/stock?error=true");
            }
        } else if (pathInfo != null && pathInfo.equals("/product/delete")) {
            try {
                String idStr = request.getParameter("id");
                if (idStr == null || idStr.isEmpty()) {
                    idStr = request.getParameter("productId");
                }
                int productId = Integer.parseInt(idStr);
                productDAO.deleteProduct(productId, currentUser != null ? currentUser.getUserId() : 0);
                response.sendRedirect(request.getContextPath() + "/inventory/products?success=deleted");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/inventory/products?error=delete_failed");
            }
        } else if (pathInfo != null && pathInfo.equals("/stock/adjust")) {
            int stockId = Integer.parseInt(request.getParameter("stockId"));
            int productId = Integer.parseInt(request.getParameter("productId"));
            double newQty = Double.parseDouble(request.getParameter("newQty"));
            String reason = request.getParameter("reason");
            
            boolean success = stockDAO.adjustStock(stockId, productId, newQty, reason);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/inventory/stock?success=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/inventory/stock?error=true");
            }
        } else if (pathInfo != null && pathInfo.equals("/stock/sale")) {
            // FR4.5: "sale" is one of the three stock-change paths that must create
            // an inventory_ledger entry. Backed by the existing record_sale stored
            // procedure (already present in the schema, previously unused by any
            // reachable page — StockDAO.recordSale() had no caller anywhere).
            try {
                int productId = Integer.parseInt(request.getParameter("productId"));
                int customerId = Integer.parseInt(request.getParameter("customerId"));
                double quantity = Double.parseDouble(request.getParameter("quantity"));
                double salePrice = Double.parseDouble(request.getParameter("salePrice"));

                if (quantity <= 0 || salePrice < 0) {
                    response.sendRedirect(request.getContextPath() + "/inventory/stock?error=true");
                    return;
                }

                boolean success = stockDAO.recordSale(productId, customerId, null, quantity, salePrice);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/inventory/stock?success=true");
                } else {
                    response.sendRedirect(request.getContextPath() + "/inventory/stock?error=true");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/inventory/stock?error=true");
            }
        }
    }
}
