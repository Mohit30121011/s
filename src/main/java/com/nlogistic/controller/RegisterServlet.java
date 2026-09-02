package com.nlogistic.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.dao.UserDAO;
import com.nlogistic.dao.CompanyDAO;
import javax.servlet.annotation.MultipartConfig;

@WebServlet("/register")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,      // 10MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO = new UserDAO();
    private CompanyDAO companyDAO = new CompanyDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String type = request.getParameter("type");
        
        try {
            if ("company".equals(type)) {
                String companyName = request.getParameter("companyName");
                String email = request.getParameter("email");
                String contactPerson = request.getParameter("contactPerson");
                String phone = request.getParameter("phone");
                String gstNo = request.getParameter("gstNo");
                String licenseNo = request.getParameter("licenseNo");
                String address = request.getParameter("address");
                String city = request.getParameter("city");
                String state = request.getParameter("state");
                String pinCode = request.getParameter("pinCode");
                String password = request.getParameter("password");
                String confirmPassword = request.getParameter("confirmPassword");
                
                if (password == null || !password.equals(confirmPassword)) {
                    throw new Exception("Passwords do not match.");
                }
                
                String fullAddress = address + ", " + city + ", " + state + " - " + pinCode;
                
                // Register Company
                int companyId = companyDAO.registerCompany(companyName, licenseNo, gstNo, fullAddress, email, phone);
                
                if (companyId > 0) {
                    // Register Company Admin (Role 2)
                    String username = request.getParameter("username");
                    // Company admins are always 'Inactive' until Super Admin approves the company
                    userDAO.registerUser(username, email, password, phone, 2, companyId, "Inactive");
                } else {
                    throw new Exception("Could not create company in database. Please check details.");
                }
            } else {
                // Customer registration (Reusing same UI fields as per standard mockup)
                String email = request.getParameter("email");
                String phone = request.getParameter("phone");
                String password = request.getParameter("password");
                String confirmPassword = request.getParameter("confirmPassword");
                
                if (password == null || !password.equals(confirmPassword)) {
                    throw new Exception("Passwords do not match.");
                }
                
                String username = request.getParameter("username");
                
                // Configurable: activation may be automatic or approval gated
                boolean autoActivate = false; // Set to true for automatic activation, false for approval gated
                String status = autoActivate ? "Active" : "Inactive";
                
                // Register User (Role 5 = Customer)
                userDAO.registerUser(username, email, password, phone, 5, null, status);
            }
            
            request.setAttribute("successMessage", "Registration successful! You can now sign in.");
            request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Registration failed: " + e.getMessage());
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
        }
    }
}
