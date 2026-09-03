package com.nlogistic.controller;

import com.nlogistic.dao.ComplianceDAO;
import com.nlogistic.dao.ShipmentDAO;
import com.nlogistic.dao.CustomerDAO;
import com.nlogistic.dao.UserDAO;
import com.nlogistic.model.ComplianceDocument;
import java.util.List;
import java.util.Date;
import java.util.Calendar;
import com.nlogistic.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;

@WebServlet("/compliance/*")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2 MB
    maxFileSize = 1024 * 1024 * 10,      // 10 MB
    maxRequestSize = 1024 * 1024 * 50    // 50 MB
)
public class ComplianceServlet extends HttpServlet {

    private ComplianceDAO complianceDAO = new ComplianceDAO();
    private ShipmentDAO shipmentDAO = new ShipmentDAO();
    private CustomerDAO customerDAO = new CustomerDAO();
    private UserDAO userDAO = new UserDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/")) {
            List<ComplianceDocument> docs = complianceDAO.getAllDocuments();
            
            // Document KPIs
            int docApproved = 0, docReview = 0, docRejected = 0, docExpiring = 0;
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.DAY_OF_YEAR, 30);
            Date thirtyDaysFromNow = cal.getTime();
            Date now = new Date();
            
            for (ComplianceDocument d : docs) {
                if ("Approved".equalsIgnoreCase(d.getStatus())) docApproved++;
                else if ("Under Review".equalsIgnoreCase(d.getStatus())) docReview++;
                else if ("Rejected".equalsIgnoreCase(d.getStatus())) docRejected++;
                
                if (d.getExpiryDate() != null && d.getExpiryDate().after(now) && d.getExpiryDate().before(thirtyDaysFromNow)) {
                    docExpiring++;
                }
            }
            
            request.setAttribute("documents", docs);
            request.setAttribute("docTotal", docs.size());
            request.setAttribute("docApproved", docApproved);
            request.setAttribute("docReview", docReview);
            request.setAttribute("docRejected", docRejected);
            request.setAttribute("docExpiring", docExpiring);
            
            request.setAttribute("shipments", shipmentDAO.getAllShipments());
            request.setAttribute("users", userDAO.getAllUsers());
            
            request.getRequestDispatcher("/jsp/compliance.jsp").forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (pathInfo != null && pathInfo.equals("/upload")) {
            try {
                int shipmentId = Integer.parseInt(request.getParameter("shipmentId"));
                String docType = request.getParameter("docType");
                String docNumber = request.getParameter("docNumber");
                String issuer = request.getParameter("issuingAuthority");
                java.sql.Date issueDate = java.sql.Date.valueOf(request.getParameter("issueDate"));
                java.sql.Date expiryDate = java.sql.Date.valueOf(request.getParameter("expiryDate"));
                
                Part filePart = request.getPart("docFile");
                String fileName = filePart.getSubmittedFileName();
                
                // Save file to server
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdir();
                String filePath = uploadPath + File.separator + fileName;
                filePart.write(filePath);
                
                String dbFilePath = "uploads/" + fileName;

                boolean success = complianceDAO.uploadDocument(shipmentId, docType, docNumber, issuer, issueDate, expiryDate, dbFilePath, currentUser.getUserId());
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/compliance?success=true");
                } else {
                    response.sendRedirect(request.getContextPath() + "/compliance?error=true");
                }
            } catch(Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/compliance?error=true");
            }
        } else if (pathInfo != null && pathInfo.equals("/review")) {
            int docId = Integer.parseInt(request.getParameter("docId"));
            String status = request.getParameter("status");
            boolean success = complianceDAO.reviewDocument(docId, status);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/compliance?success=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/compliance?error=true");
            }
        }
    }
}
