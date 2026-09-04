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
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String confirmPassword = request.getParameter("confirmPassword");
            String address = request.getParameter("address");

            // Common validations
            if (username == null || username.trim().length() < 3) {
                throw new Exception("Username must be at least 3 characters long.");
            }
            if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
                throw new Exception("Please enter a valid email address.");
            }
            if (phone == null || phone.trim().length() < 8) {
                throw new Exception("Please enter a valid phone number (minimum 8 digits).");
            }
            if (address == null || address.trim().isEmpty()) {
                throw new Exception("Address cannot be empty.");
            }
            if (password == null || password.length() < 8) {
                throw new Exception("Password must be at least 8 characters long.");
            }
            if (!password.equals(confirmPassword)) {
                throw new Exception("Create Password and Confirm Password do not match.");
            }

            if ("company".equals(type)) {
                String companyName = request.getParameter("companyName");
                String licenseNo = request.getParameter("licenseNo");
                String gstNo = request.getParameter("gstNo");

                if (companyName == null || companyName.trim().isEmpty()) {
                    throw new Exception("Company Name is required.");
                }
                if (licenseNo == null || licenseNo.trim().isEmpty()) {
                    throw new Exception("License / Registration Number is required.");
                }
                if (gstNo == null || gstNo.trim().isEmpty()) {
                    throw new Exception("GST / Tax ID is required.");
                }

                // Register Company with 'Pending' status
                int companyId = companyDAO.registerCompany(companyName.trim(), licenseNo.trim().toUpperCase(), gstNo.trim().toUpperCase(), address.trim(), email.trim(), phone.trim());

                if (companyId > 0) {
                    // Register Company Admin (Role 2) with status 'Inactive' pending Super Admin approval
                    int userId = userDAO.createUser(username.trim(), email.trim(), password, phone.trim(), 2, companyId, "Pending");
                    if (userId <= 0) {
                        throw new Exception("Username or email already in use. Please choose a different one.");
                    }
                } else {
                    throw new Exception("Could not register company in database. Please verify your company details.");
                }

                request.setAttribute("successMessage", "Company registration submitted successfully! Your account is pending Super Admin review & approval before activation.");
                request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
            } else {
                // Customer registration
                String customerName = request.getParameter("customerName");
                if (customerName == null || customerName.trim().isEmpty()) {
                    customerName = request.getParameter("companyName");
                }
                if (customerName == null || customerName.trim().isEmpty()) {
                    throw new Exception("Customer full name is required.");
                }

                // Handle KYC document upload
                String kycDocPath = null;
                try {
                    Part kycPart = request.getPart("kycDoc");
                    if (kycPart != null && kycPart.getSize() > 0) {
                        String submitted = new File(kycPart.getSubmittedFileName()).getName();
                        String ext = "";
                        int dot = submitted.lastIndexOf('.');
                        if (dot > 0) ext = submitted.substring(dot).toLowerCase();
                        if (!ext.equals(".pdf") && !ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png")) {
                            throw new Exception("KYC document must be a PDF, JPG, or PNG file.");
                        }
                        String fileName = "kyc_" + System.currentTimeMillis() + ext;
                        String uploadDir = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "kyc";
                        File dir = new File(uploadDir);
                        if (!dir.exists()) dir.mkdirs();
                        kycPart.write(uploadDir + File.separator + fileName);
                        kycDocPath = request.getContextPath() + "/uploads/kyc/" + fileName;
                    } else {
                        throw new Exception("Please upload a valid KYC document (PDF, JPG, PNG).");
                    }
                } catch (Exception ex) {
                    if (ex.getMessage() != null && ex.getMessage().contains("KYC")) {
                        throw ex;
                    }
                }

                // Register User (Role 5 = Customer) with status 'Inactive'
                int newUserId = userDAO.createUser(username.trim(), email.trim(), password, phone.trim(), 5, null, "Pending");
                if (newUserId > 0) {
                    userDAO.registerCustomer(newUserId, customerName.trim(), address.trim(), kycDocPath, 0.0);
                } else {
                    throw new Exception("Username or email already exists. Please choose another.");
                }

                request.setAttribute("successMessage", "Customer registration submitted successfully! KYC document received and pending verification.");
                request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
        }
    }
}
