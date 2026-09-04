package com.nlogistic.controller;

import com.nlogistic.dao.ClaimDAO;
import com.nlogistic.model.*;
import com.nlogistic.util.DBConnectionManager;

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
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import java.util.Map;

@WebServlet("/claims")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2 MB
    maxFileSize = 1024 * 1024 * 15,      // 15 MB
    maxRequestSize = 1024 * 1024 * 50    // 50 MB
)
public class ClaimServlet extends HttpServlet {
    private ClaimDAO claimDAO = new ClaimDAO();

    // Role IDs (match DB ROLES table)
    private static final int ROLE_SUPER_ADMIN   = 1;
    private static final int ROLE_COMPANY_ADMIN = 2;
    private static final int ROLE_OPS           = 3;
    private static final int ROLE_FINANCE       = 4;
    private static final int ROLE_CUSTOMER      = 5;

    // Resolve customer_id for the logged-in user (for customers only)
    private int resolveCustomerId(int userId) {
        String sql = "SELECT customer_id FROM CUSTOMERS WHERE user_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("customer_id");
        } catch (Exception e) { e.printStackTrace(); }
        return -1;
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User currentUser = (User) session.getAttribute("user");
        int userId = currentUser.getUserId();
        int roleId = session.getAttribute("roleId") != null ? (int) session.getAttribute("roleId") : currentUser.getRoleId();

        // Resolve and cache customerId for customer role
        Integer customerId = (Integer) session.getAttribute("customerId");
        if (customerId == null && roleId == ROLE_CUSTOMER) {
            int resolved = resolveCustomerId(userId);
            customerId = resolved > 0 ? resolved : null;
            if (customerId != null) session.setAttribute("customerId", customerId);
        }

        String action = request.getParameter("action");

        // View a single claim's details
        if ("view".equals(action)) {
            String claimIdStr = request.getParameter("claimId");
            if (claimIdStr != null && !claimIdStr.isEmpty()) {
                try {
                    int claimId = Integer.parseInt(claimIdStr);
                    Claim claim = claimDAO.getClaimById(claimId);

                    if (claim != null) {
                        // Customer can only view their own claims
                        if (roleId == ROLE_CUSTOMER && customerId != null && claim.getCustomerId() != customerId) {
                            session.setAttribute("errorMessage", "Access denied - this is not your claim.");
                            response.sendRedirect(request.getContextPath() + "/claims");
                            return;
                        }
                        List<ClaimHistory> history = claimDAO.getClaimHistory(claimId);
                        List<ClaimDocument> documents = claimDAO.getClaimDocuments(claimId);
                        request.setAttribute("claim", claim);
                        request.setAttribute("history", history);
                        request.setAttribute("documents", documents);
                        request.setAttribute("roleId", roleId);
                        request.setAttribute("customerId", customerId);
                        request.getRequestDispatcher("/jsp/claim-details.jsp").forward(request, response);
                        return;
                    } else {
                        session.setAttribute("errorMessage", "Claim not found.");
                    }
                } catch (NumberFormatException ignored) {}
            }
        }

        // Claims register / dashboard
        String statusFilter = request.getParameter("statusFilter");
        String typeFilter = request.getParameter("typeFilter");

        List<Claim> claims;
        // Customer sees only their own claims
        if (roleId == ROLE_CUSTOMER) {
            claims = (customerId != null && customerId > 0)
                     ? claimDAO.getClaimsByCustomer(customerId)
                     : new java.util.ArrayList<>();
        } else if (statusFilter != null && !statusFilter.isEmpty()) {
            claims = claimDAO.getClaimsByStatus(statusFilter);
        } else {
            claims = claimDAO.getAllClaims();
        }

        // Type filter (Java-side)
        if (typeFilter != null && !typeFilter.isEmpty()) {
            final String tf = typeFilter;
            claims.removeIf(c -> !tf.equals(c.getClaimType()));
        }

        Map<String, Object> stats = (roleId == ROLE_CUSTOMER && customerId != null) 
                     ? claimDAO.getClaimStats(customerId) 
                     : claimDAO.getClaimStats();
        List<LossReason> lossReasons = claimDAO.getAllLossReasons();
        List<Object[]> shipments = claimDAO.getShipmentsForUser(userId, roleId, customerId);

        request.setAttribute("claims", claims);
        request.setAttribute("stats", stats);
        request.setAttribute("lossReasons", lossReasons);
        request.setAttribute("shipments", shipments);
        request.setAttribute("statusFilter", statusFilter != null ? statusFilter : "");
        request.setAttribute("typeFilter", typeFilter != null ? typeFilter : "");
        request.setAttribute("roleId", roleId);
        request.setAttribute("customerId", customerId);
        request.getRequestDispatcher("/jsp/claims.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User currentUser = (User) session.getAttribute("user");
        int userId = currentUser.getUserId();
        int roleId = session.getAttribute("roleId") != null ? (int) session.getAttribute("roleId") : currentUser.getRoleId();
        Integer customerId = (Integer) session.getAttribute("customerId");

        String action = request.getParameter("action");
        String redirectUrl = request.getContextPath() + "/claims";

        if (action == null) {
            response.sendRedirect(redirectUrl);
            return;
        }

        try {
            switch (action) {

                case "file": {
                    String shipStr = request.getParameter("shipmentId");
                    String custStr = request.getParameter("customerId");
                    String contStr = request.getParameter("containerId");
                    String prodStr = request.getParameter("productId");
                    String claimType = request.getParameter("claimType");
                    String desc = request.getParameter("description");
                    String dateStr = request.getParameter("incidentDate");
                    String amtStr = request.getParameter("claimedAmount");
                    String reaStr = request.getParameter("reasonId");

                    int shipmentId = Integer.parseInt(shipStr.trim());
                    int claimCustId = Integer.parseInt(custStr.trim());
                    double claimedAmt = Double.parseDouble(amtStr.trim());
                    java.sql.Date incidentDate = java.sql.Date.valueOf(dateStr.trim());
                    Integer containerId = (contStr != null && !contStr.trim().isEmpty()) ? Integer.parseInt(contStr.trim()) : null;
                    Integer productId = (prodStr != null && !prodStr.trim().isEmpty()) ? Integer.parseInt(prodStr.trim()) : null;
                    Integer reasonId = (reaStr != null && !reaStr.trim().isEmpty()) ? Integer.parseInt(reaStr.trim()) : null;

                    // Customer can only file for themselves
                    if (roleId == ROLE_CUSTOMER && customerId != null && claimCustId != customerId) {
                        throw new SecurityException("You can only file claims for your own account.");
                    }

                    int newClaimId = claimDAO.fileClaim(shipmentId, containerId, productId, claimCustId,
                                                         claimType, desc, incidentDate, claimedAmt, reasonId, userId);
                    if (newClaimId > 0) {
                        session.setAttribute("successMessage", "Claim #" + newClaimId + " filed successfully. Current Status: Filed.");
                        redirectUrl = request.getContextPath() + "/claims?action=view&claimId=" + newClaimId;
                    } else {
                        session.setAttribute("successMessage", "Claim filed successfully.");
                    }
                    break;
                }

                case "review": {
                    if (roleId != ROLE_OPS && roleId != ROLE_SUPER_ADMIN && roleId != ROLE_COMPANY_ADMIN) {
                        throw new SecurityException("Only Operations staff can move a claim to Under Review.");
                    }
                    int claimId = Integer.parseInt(request.getParameter("claimId").trim());
                    String remark = request.getParameter("remarks");
                    claimDAO.startReview(claimId, userId, remark);
                    session.setAttribute("successMessage", "Claim #" + claimId + " is now Under Review. Finance team will evaluate.");
                    redirectUrl = request.getContextPath() + "/claims?action=view&claimId=" + claimId;
                    break;
                }

                case "approve": {
                    if (roleId != ROLE_FINANCE && roleId != ROLE_SUPER_ADMIN && roleId != ROLE_COMPANY_ADMIN) {
                        throw new SecurityException("Only Finance staff can approve a claim.");
                    }
                    int claimId = Integer.parseInt(request.getParameter("claimId").trim());
                    double approvedAmt = Double.parseDouble(request.getParameter("approvedAmount").trim());
                    String remark = request.getParameter("remarks");
                    claimDAO.approveClaim(claimId, approvedAmt, userId, remark);
                    session.setAttribute("successMessage", "Claim #" + claimId + " approved for " + String.format("%,.2f", approvedAmt) +
                        ". Credit note posted to billing.");
                    redirectUrl = request.getContextPath() + "/claims?action=view&claimId=" + claimId;
                    break;
                }

                case "reject": {
                    if (roleId != ROLE_FINANCE && roleId != ROLE_SUPER_ADMIN && roleId != ROLE_COMPANY_ADMIN) {
                        throw new SecurityException("Only Finance staff can reject a claim.");
                    }
                    int claimId = Integer.parseInt(request.getParameter("claimId").trim());
                    String remark = request.getParameter("remarks");
                    claimDAO.rejectClaim(claimId, userId, remark);
                    session.setAttribute("successMessage", "Claim #" + claimId + " has been rejected. Reason recorded in status history.");
                    redirectUrl = request.getContextPath() + "/claims?action=view&claimId=" + claimId;
                    break;
                }

                case "settle": {
                    if (roleId != ROLE_FINANCE && roleId != ROLE_SUPER_ADMIN && roleId != ROLE_COMPANY_ADMIN) {
                        throw new SecurityException("Only Finance staff can settle a claim.");
                    }
                    int claimId = Integer.parseInt(request.getParameter("claimId").trim());
                    claimDAO.settleClaim(claimId, userId);
                    session.setAttribute("successMessage", "Claim #" + claimId + " settled. Resolution recorded and credit note posted to billing.");
                    redirectUrl = request.getContextPath() + "/claims?action=view&claimId=" + claimId;
                    break;
                }

                case "addDoc": {
                    int claimId = Integer.parseInt(request.getParameter("claimId").trim());
                    String docType = request.getParameter("docType");
                    if (roleId == ROLE_CUSTOMER) {
                        Claim c = claimDAO.getClaimById(claimId);
                        if (c == null || (customerId != null && c.getCustomerId() != customerId)) {
                            throw new SecurityException("Cannot upload a document to a claim you don't own.");
                        }
                    }

                    Part filePart = request.getPart("evidenceFile");
                    String submittedName = (filePart != null) ? filePart.getSubmittedFileName() : null;
                    if (submittedName == null || submittedName.trim().isEmpty()) {
                        throw new IllegalArgumentException("Please choose a file to upload as evidence.");
                    }
                    String lower = submittedName.toLowerCase();
                    boolean validExt = lower.endsWith(".pdf") || lower.endsWith(".jpg") || lower.endsWith(".jpeg")
                            || lower.endsWith(".png") || lower.endsWith(".doc") || lower.endsWith(".docx");
                    if (!validExt) {
                        throw new IllegalArgumentException("Unsupported file type. Allowed: PDF, JPG, PNG, DOC.");
                    }
                    if (filePart.getSize() <= 0) {
                        throw new IllegalArgumentException("The uploaded file is empty.");
                    }

                    String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "claims";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) uploadDir.mkdirs();
                    String sanitized = System.currentTimeMillis() + "_claim" + claimId + "_" + submittedName.replaceAll("[^a-zA-Z0-9.-]", "_");
                    filePart.write(uploadPath + File.separator + sanitized);
                    String dbFilePath = "uploads/claims/" + sanitized;

                    boolean docSaved = claimDAO.addClaimDocument(claimId, docType, dbFilePath, userId);
                    if (docSaved) {
                        session.setAttribute("successMessage", "Document \"" + submittedName + "\" uploaded and added to Claim #" + claimId);
                    } else {
                        session.setAttribute("errorMessage", "The file was uploaded but could not be recorded against the claim. Please try again.");
                    }
                    redirectUrl = request.getContextPath() + "/claims?action=view&claimId=" + claimId;
                    break;
                }

                default:
                    session.setAttribute("errorMessage", "Unknown action: " + action);
            }
        } catch (SecurityException e) {
            session.setAttribute("errorMessage", "Access Denied: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Error processing claim: " + e.getMessage());
        }

        response.sendRedirect(redirectUrl);
    }
}
