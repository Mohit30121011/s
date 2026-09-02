package com.nlogistic.controller;

import com.nlogistic.dao.ClaimDAO;
import com.nlogistic.model.Claim;
import com.nlogistic.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/claims")
public class ClaimServlet extends HttpServlet {
    private ClaimDAO claimDAO = new ClaimDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String statusFilter = request.getParameter("statusFilter");
        List<Claim> claims;
        if (statusFilter != null && !statusFilter.isEmpty()) {
            claims = claimDAO.getClaimsByStatus(statusFilter);
        } else {
            claims = claimDAO.getAllClaims();
        }
        request.setAttribute("claims", claims);
        request.getRequestDispatcher("/jsp/claims.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        User user = (User) session.getAttribute("user");
        int userId = user.getUserId();
        
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/claims");
            return;
        }

        try {
            switch (action) {
                case "file":
                    int shipmentId = Integer.parseInt(request.getParameter("shipmentId"));
                    String containerIdStr = request.getParameter("containerId");
                    Integer containerId = (containerIdStr != null && !containerIdStr.isEmpty()) ? Integer.parseInt(containerIdStr) : null;
                    String productIdStr = request.getParameter("productId");
                    Integer productId = (productIdStr != null && !productIdStr.isEmpty()) ? Integer.parseInt(productIdStr) : null;
                    int customerId = Integer.parseInt(request.getParameter("customerId"));
                    String claimType = request.getParameter("claimType");
                    String description = request.getParameter("description");
                    String incidentDateStr = request.getParameter("incidentDate");
                    java.sql.Date incidentDate = java.sql.Date.valueOf(incidentDateStr);
                    double claimedAmount = Double.parseDouble(request.getParameter("claimedAmount"));
                    String reasonIdStr = request.getParameter("reasonId");
                    Integer reasonId = (reasonIdStr != null && !reasonIdStr.isEmpty()) ? Integer.parseInt(reasonIdStr) : null;
                    
                    claimDAO.fileClaim(shipmentId, containerId, productId, customerId,
                                      claimType, description, incidentDate, claimedAmount, reasonId, userId);
                    request.getSession().setAttribute("successMessage", "Claim filed successfully.");
                    break;
                case "review":
                    int reviewClaimId = Integer.parseInt(request.getParameter("claimId"));
                    double approvedAmount = Double.parseDouble(request.getParameter("approvedAmount"));
                    String reviewRemarks = request.getParameter("remarks");
                    // review_claim expects: claim_id, new_status, approved_amount, changed_by, remark
                    claimDAO.reviewClaim(reviewClaimId, "Approved", approvedAmount, userId, reviewRemarks);
                    request.getSession().setAttribute("successMessage", "Claim reviewed and approved.");
                    break;
                case "reject":
                    int rejectClaimId = Integer.parseInt(request.getParameter("claimId"));
                    String rejectRemarks = request.getParameter("remarks");
                    claimDAO.rejectClaim(rejectClaimId, userId, rejectRemarks);
                    request.getSession().setAttribute("successMessage", "Claim rejected.");
                    break;
                case "settle":
                    int settleClaimId = Integer.parseInt(request.getParameter("claimId"));
                    // settle_claim expects: claim_id, resolved_by (2 params only!)
                    claimDAO.settleClaim(settleClaimId, userId);
                    request.getSession().setAttribute("successMessage", "Claim settled. Credit note posted to billing.");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Error processing claim: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/claims");
    }
}
