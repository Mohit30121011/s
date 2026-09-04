package com.nlogistic.controller;

import com.nlogistic.dao.ComplianceDAO;
import com.nlogistic.dao.ShipmentDAO;
import com.nlogistic.dao.CustomerDAO;
import com.nlogistic.dao.UserDAO;
import com.nlogistic.model.ComplianceDocument;
import com.nlogistic.model.ShipmentComplianceInfo;
import com.nlogistic.model.User;

import java.io.File;
import java.io.IOException;
import java.sql.Date;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet({"/compliance", "/compliance/*"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2 MB
    maxFileSize = 1024 * 1024 * 15,      // 15 MB
    maxRequestSize = 1024 * 1024 * 50    // 50 MB
)
public class ComplianceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ComplianceDAO complianceDAO = new ComplianceDAO();
    private ShipmentDAO shipmentDAO = new ShipmentDAO();
    private CustomerDAO customerDAO = new CustomerDAO();
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        // AJAX Departure Clearance Check API
        if (pathInfo != null && pathInfo.equals("/check-departure")) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            try {
                int shipmentId = Integer.parseInt(request.getParameter("shipmentId"));
                boolean canDepart = complianceDAO.canShipmentDepart(shipmentId);
                response.getWriter().write("{\"shipmentId\":" + shipmentId + ",\"clearedForDeparture\":" + canDepart + "}");
            } catch (Exception e) {
                response.getWriter().write("{\"error\":\"Invalid shipment ID\"}");
            }
            return;
        }

        // Automatic batch check: flag expired documents
        complianceDAO.flagExpiredDocuments();

        // 1. Fetch All Compliance Documents
        List<ComplianceDocument> docs = complianceDAO.getAllDocuments();

        // 2. Fetch Expiring Documents Alert List (FR5.4 - within 15 days)
        List<ComplianceDocument> expiringDocs = complianceDAO.getExpiringDocuments(15);

        // 3. Compute KPI Counts
        int docTotal = docs.size();
        int docApproved = 0;
        int docReview = 0;
        int docRejected = 0;
        int docExpired = 0;

        for (ComplianceDocument d : docs) {
            String s = d.getStatus();
            if ("Approved".equalsIgnoreCase(s)) docApproved++;
            else if ("Pending".equalsIgnoreCase(s) || "Under Review".equalsIgnoreCase(s)) docReview++;
            else if ("Rejected".equalsIgnoreCase(s)) docRejected++;
            else if ("Expired".equalsIgnoreCase(s)) docExpired++;
        }

        // 4. Fetch Shipment Compliance Gatekeeper List (FR5.3)
        List<ShipmentComplianceInfo> shipmentComplianceList = complianceDAO.getShipmentComplianceList();

        // Set request attributes
        request.setAttribute("documents", docs);
        request.setAttribute("expiringDocs", expiringDocs);
        request.setAttribute("docTotal", docTotal);
        request.setAttribute("docApproved", docApproved);
        request.setAttribute("docReview", docReview);
        request.setAttribute("docRejected", docRejected);
        request.setAttribute("docExpired", docExpired);
        request.setAttribute("docExpiringCount", expiringDocs.size());
        request.setAttribute("docExpiring", expiringDocs.size());
        request.setAttribute("shipmentComplianceList", shipmentComplianceList);
        request.setAttribute("shipments", shipmentDAO.getAllShipments());
        request.setAttribute("users", userDAO.getAllUsers());

        request.getRequestDispatcher("/jsp/compliance.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        int userId = (currentUser != null) ? currentUser.getUserId() : 1;

        if (pathInfo != null && pathInfo.equals("/upload")) {
            try {
                int shipmentId = Integer.parseInt(request.getParameter("shipmentId"));
                String docType = request.getParameter("docType");
                String docNumber = request.getParameter("docNumber");
                String issuer = request.getParameter("issuingAuthority");
                String issueDateStr = request.getParameter("issueDate");
                String expiryDateStr = request.getParameter("expiryDate");

                Date issueDate = (issueDateStr != null && !issueDateStr.trim().isEmpty()) 
                                 ? Date.valueOf(issueDateStr.trim()) : new Date(System.currentTimeMillis());
                Date expiryDate = (expiryDateStr != null && !expiryDateStr.trim().isEmpty()) 
                                  ? Date.valueOf(expiryDateStr.trim()) : null;

                Part filePart = request.getPart("docFile");
                String fileName = (filePart != null) ? filePart.getSubmittedFileName() : null;
                String dbFilePath = "uploads/sample_compliance.pdf";

                if (fileName != null && !fileName.trim().isEmpty()) {
                    String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) uploadDir.mkdirs();
                    
                    String sanitized = System.currentTimeMillis() + "_" + fileName.replaceAll("[^a-zA-Z0-9.-]", "_");
                    String filePath = uploadPath + File.separator + sanitized;
                    filePart.write(filePath);
                    dbFilePath = "uploads/" + sanitized;
                }

                boolean success = complianceDAO.uploadDocument(shipmentId, docType, docNumber, issuer, issueDate, expiryDate, dbFilePath, userId);
                if (success) {
                    session.setAttribute("successMessage", "Compliance document " + docNumber + " (" + docType + ") successfully uploaded.");
                } else {
                    session.setAttribute("errorMessage", "Could not upload document. Please check the provided values.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Error uploading document: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/compliance");

        } else if (pathInfo != null && pathInfo.equals("/review")) {
            try {
                int docId = Integer.parseInt(request.getParameter("docId"));
                String status = request.getParameter("status"); // Approved or Rejected
                boolean success = complianceDAO.reviewDocument(docId, status);
                if (success) {
                    session.setAttribute("successMessage", "Document status updated to " + status + ".");
                } else {
                    session.setAttribute("errorMessage", "Failed to update document status.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Error updating document: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/compliance");

        } else if (pathInfo != null && pathInfo.equals("/delete")) {
            try {
                int docId = Integer.parseInt(request.getParameter("docId"));
                boolean success = complianceDAO.deleteDocument(docId);
                if (success) {
                    session.setAttribute("successMessage", "Document successfully deleted.");
                } else {
                    session.setAttribute("errorMessage", "Failed to delete document.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Error deleting document: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/compliance");
        } else {
            response.sendRedirect(request.getContextPath() + "/compliance");
        }
    }
}
