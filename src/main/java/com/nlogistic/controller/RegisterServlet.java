package com.nlogistic.controller;

import java.io.File;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import com.nlogistic.dao.CompanyDAO;
import com.nlogistic.dao.UserDAO;

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
        if (type == null || type.trim().isEmpty()) {
            type = "company";
        }

        try {
            if ("company".equals(type)) {
                // FR1.2: Company registration requires company name, license/registration number,
                // GST/Tax ID, address and admin contact, and is subject to Super Admin approval before activation.
                String companyName = request.getParameter("companyName");
                String licenseNo = request.getParameter("licenseNo");
                String gstNo = request.getParameter("gstNo");
                String address = request.getParameter("address");
                
                // Admin contact fields
                String contactPerson = request.getParameter("contactPerson");
                String email = request.getParameter("email");
                String phone = request.getParameter("phone");
                String username = request.getParameter("username");
                String password = request.getParameter("password");
                String confirmPassword = request.getParameter("confirmPassword");

                if (password == null || !password.equals(confirmPassword)) {
                    throw new Exception("Passwords do not match.");
                }

                // Register Company with 'Pending' approval status
                int companyId = companyDAO.registerCompany(companyName, licenseNo, gstNo, address, email, phone);

                if (companyId > 0) {
                    // Register Company Admin (Role 2) with status 'Inactive' until Super Admin approves
                    userDAO.registerUser(username, email, password, phone, 2, companyId, "Inactive");
                } else {
                    throw new Exception("Could not register company in database. Please verify the details.");
                }

                request.setAttribute("successMessage", "Company registration submitted successfully! Your account is pending Super Admin review & approval before activation.");
                request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
            } else {
                // FR1.3: Customer registration requires name, email, phone, address and a KYC document upload
                String customerName = request.getParameter("customerName");
                if (customerName == null || customerName.trim().isEmpty()) {
                    customerName = request.getParameter("companyName");
                }
                String email = request.getParameter("email");
                String phone = request.getParameter("phone");
                String address = request.getParameter("address");
                String username = request.getParameter("username");
                String password = request.getParameter("password");
                String confirmPassword = request.getParameter("confirmPassword");

                if (password == null || !password.equals(confirmPassword)) {
                    throw new Exception("Passwords do not match.");
                }

                // Handle KYC document file upload
                String kycDocPath = null;
                try {
                    Part kycPart = request.getPart("kycDoc");
                    if (kycPart != null && kycPart.getSize() > 0) {
                        String submitted = new File(kycPart.getSubmittedFileName()).getName();
                        String ext = "";
                        int dot = submitted.lastIndexOf('.');
                        if (dot > 0) ext = submitted.substring(dot);
                        String fileName = "kyc_" + System.currentTimeMillis() + ext;
                        String uploadDir = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "kyc";
                        File dir = new File(uploadDir);
                        if (!dir.exists()) dir.mkdirs();
                        kycPart.write(uploadDir + File.separator + fileName);
                        kycDocPath = request.getContextPath() + "/uploads/kyc/" + fileName;
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                // Register User (Role 5 = Customer) with status 'Inactive' (gated)
                int newUserId = userDAO.createUser(username, email, password, phone, 5, null, "Inactive");
                if (newUserId > 0) {
                    userDAO.registerCustomer(newUserId, customerName, address, kycDocPath, 0.0);
                } else {
                    throw new Exception("Username or email already exists. Please choose another.");
                }

                request.setAttribute("successMessage", "Customer registration submitted successfully! KYC document received and pending approval.");
                request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Registration failed: " + e.getMessage());
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
        }
    }
}
