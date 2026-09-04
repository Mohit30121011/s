package com.nlogistic.controller;

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

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/products")) {
            request.setAttribute("products", productDAO.getAllProducts());
            request.getRequestDispatcher("/jsp/products.jsp").forward(request, response);
        } else if (pathInfo.equals("/stock")) {
            request.setAttribute("stocks", stockDAO.getAllStock());
            request.setAttribute("ledger", stockDAO.getInventoryLedger());
            request.setAttribute("products", productDAO.getAllProducts()); // Needed for dropdown
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
        }
    }
}
