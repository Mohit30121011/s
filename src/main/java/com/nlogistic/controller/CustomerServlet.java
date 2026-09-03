package com.nlogistic.controller;

import java.io.File;
import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import com.nlogistic.dao.CustomerDAO;
import com.nlogistic.dao.UserDAO;
import com.nlogistic.model.Customer;
import com.nlogistic.model.User;

@WebServlet("/customers")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class CustomerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CustomerDAO customerDAO = new CustomerDAO();
    private UserDAO userDAO = new UserDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        List<Customer> customers = customerDAO.getAllCustomers();
        request.setAttribute("customers", customers);
        request.getRequestDispatcher("/jsp/customers.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String action = request.getParameter("action");
        if ("add".equals(action)) {
            String name = request.getParameter("customerName");
            String address = request.getParameter("address");
            String creditLimitStr = request.getParameter("creditLimit");
            double creditLimit = 0.0;
            if (creditLimitStr != null && !creditLimitStr.trim().isEmpty()) {
                try {
                    creditLimit = Double.parseDouble(creditLimitStr);
                } catch (NumberFormatException e) {
                    creditLimit = 0.0;
                }
            }
            
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            
            // Handle KYC Document file upload
            String kycDocPath = null;
            try {
                Part filePart = request.getPart("kycFile");
                if (filePart != null && filePart.getSize() > 0) {
                    String submittedName = new File(filePart.getSubmittedFileName()).getName();
                    String fileName = System.currentTimeMillis() + "_" + submittedName;
                    String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "kyc";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) {
                        uploadDir.mkdirs();
                    }
                    filePart.write(uploadPath + File.separator + fileName);
                    kycDocPath = "uploads/kyc/" + fileName;
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            
            // 1. Create User account for Customer (Role ID = 5)
            String username = email != null && email.contains("@") ? email.split("@")[0] : "customer";
            username = username + "_" + (System.currentTimeMillis() % 10000);
            
            int newUserId = userDAO.createUser(username, email, password, "", 5, null, "Active");
            
            if (newUserId > 0) {
                // 2. Create Customer profile in database linked to the new user_id
                userDAO.registerCustomer(newUserId, name, address, kycDocPath != null ? kycDocPath : "", creditLimit);
                request.getSession().setAttribute("successMessage", "Customer '" + name + "' added successfully with login account!");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to add customer. Email might already be registered in the system.");
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/customers");
    }
}
