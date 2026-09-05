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
                        // Gap 4: this used to check customers only, so a member of
                        // Company A could read Company B's claim - customer name,
                        // cargo description, amounts, internal remarks and evidence
                        // links - just by changing claimId in the URL.
                        if (!claimDAO.canAccessClaim(claimId, roleId,
                                com.nlogistic.util.RbacContext.companyId(request), customerId)) {
                            session.setAttribute("errorMessage", "Access denied - this claim does not belong to your account.");
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

        // Claims register / dashboard.
        // FR7.7: status and type were the only filters; date range, customer and
        // (for a Super Admin) company are added here. Scoping now happens inside
        // the query rather than by reading every claim and discarding the ones
        // the caller may not see.
        String statusFilter   = request.getParameter("statusFilter");
        String typeFilter     = request.getParameter("typeFilter");
        String dateFrom       = request.getParameter("dateFrom");
        String dateTo         = request.getParameter("dateTo");
        Integer custFilter    = parseIntOrNull(request.getParameter("customerFilter"));
        Integer companyFilter = (roleId == ROLE_SUPER_ADMIN)
                                ? parseIntOrNull(request.getParameter("companyFilter")) : null;

        Integer scopeCompany = com.nlogistic.util.RbacContext.companyId(request);
        List<Claim> claims = claimDAO.getClaimsFiltered(roleId, scopeCompany, customerId,
                statusFilter, typeFilter, dateFrom, dateTo, custFilter, companyFilter);

        if (roleId != ROLE_CUSTOMER) {
            request.setAttribute("filterCustomers", claimDAO.getFilterCustomers(roleId, scopeCompany));
        }
        request.setAttribute("dateFrom", dateFrom != null ? dateFrom : "");
        request.setAttribute("dateTo", dateTo != null ? dateTo : "");
        request.setAttribute("customerFilter", custFilter != null ? String.valueOf(custFilter) : "");
        request.setAttribute("companyFilter", companyFilter != null ? String.valueOf(companyFilter) : "");

        // KPI cards used to come from an unscoped COUNT over the whole claims
        // table, so company staff read system-wide totals above a table that
        // showed only their own tenant. Summarising the rows on screen keeps the
        // cards honest and makes them follow the filters as well.
        Map<String, Object> stats = summarise(claims);
        List<LossReason> lossReasons = claimDAO.getAllLossReasons();
        List<Object[]> shipments = claimDAO.getShipmentsForUser(userId, roleId, customerId, scopeCompany);

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

    /**
     * Gap 4 (write side): review / approve / reject / settle checked the caller's
     * role but never that the claim belonged to their company, so a Finance
     * officer at one carrier could approve and settle a rival's claim - raising a
     * real credit note against another tenant's customer.
     */
    private void requireTenant(HttpServletRequest request, int claimId, int roleId, Integer customerId) {
        if (!claimDAO.canAccessClaim(claimId, roleId,
                com.nlogistic.util.RbacContext.companyId(request), customerId)) {
            throw new SecurityException("That claim does not belong to your company.");
        }
    }

    /**
     * Save an optional evidence file submitted alongside a new claim.
     * Returns a fragment to append to the success message; never throws, because
     * a rejected attachment must not lose the claim that was just filed.
     */
    private String storeEvidence(HttpServletRequest request, int claimId, int userId) {
        try {
            Part filePart = request.getPart("evidenceFile");
            if (filePart == null || filePart.getSize() <= 0) return "";
            String submitted = filePart.getSubmittedFileName();
            if (submitted == null || submitted.trim().isEmpty()) return "";

            String lower = submitted.toLowerCase();
            boolean validExt = lower.endsWith(".pdf") || lower.endsWith(".jpg") || lower.endsWith(".jpeg")
                    || lower.endsWith(".png") || lower.endsWith(".doc") || lower.endsWith(".docx");
            if (!validExt) return " The attachment was not saved: allowed types are PDF, JPG, PNG and DOC.";

            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "claims";
            File dir = new File(uploadPath);
            if (!dir.exists()) dir.mkdirs();
            String sanitized = System.currentTimeMillis() + "_claim" + claimId + "_"
                    + submitted.replaceAll("[^a-zA-Z0-9.-]", "_");
            filePart.write(uploadPath + File.separator + sanitized);

            boolean saved = claimDAO.addClaimDocument(claimId, "Photo Evidence",
                    "uploads/claims/" + sanitized, userId);
            return saved ? " Evidence \"" + submitted + "\" attached."
                         : " The attachment could not be recorded against the claim.";
        } catch (Exception e) {
            e.printStackTrace();
            return " The attachment could not be saved.";
        }
    }

    /** Claim KPI counters for exactly the rows the caller is allowed to see. */
    private static Map<String, Object> summarise(List<Claim> claims) {
        int filed = 0, review = 0, approved = 0, settled = 0, rejected = 0;
        double claimed = 0, approvedAmt = 0;
        for (Claim c : claims) {
            String st = c.getStatus();
            if ("Filed".equals(st)) filed++;
            else if ("Under Review".equals(st)) review++;
            else if ("Approved".equals(st)) approved++;
            else if ("Settled".equals(st)) settled++;
            else if ("Rejected".equals(st)) rejected++;
            claimed += c.getClaimedAmount();
            approvedAmt += c.getApprovedAmount();
        }
        Map<String, Object> m = new java.util.HashMap<>();
        m.put("total", claims.size());
        m.put("filed", filed);
        m.put("underReview", review);
        m.put("approved", approved);
        m.put("settled", settled);
        m.put("rejected", rejected);
        m.put("totalClaimed", claimed);
        m.put("totalApproved", approvedAmt);
        return m;
    }

    private static Integer parseIntOrNull(String v) {
        if (v == null || v.trim().isEmpty()) return null;
        try { return Integer.valueOf(v.trim()); } catch (NumberFormatException e) { return null; }
    }

    /**
     * FR7.3 / FR7.5 state machine.
     *
     * Gap 2: the servlet executed whatever transition the request asked for. A
     * claim could go straight from Filed to Approved without review, an already
     * Settled claim could be reopened to Approved and then settled a second time
     * (raising a second credit note against the customer), and a Rejected claim
     * could be resurrected. Three database triggers cover part of this, but they
     * only guard entry into Settled - everything else was unguarded.
     *
     * @return null when the transition is legal, otherwise why it is not.
     */
    private String checkTransition(String current, String target) {
        if (current == null) return "That claim no longer exists.";
        if ("Settled".equals(current))  return "Claim is already settled; settled claims cannot be changed.";
        if ("Rejected".equals(current)) return "Claim was rejected; a rejected claim cannot be reopened.";

        if ("Under Review".equals(target)) {
            if (!"Filed".equals(current)) return "Only a claim in Filed status can be moved to Under Review.";
        } else if ("Approved".equals(target)) {
            if (!"Under Review".equals(current)) return "A claim must be Under Review before it can be approved.";
        } else if ("Rejected".equals(target)) {
            if (!"Filed".equals(current) && !"Under Review".equals(current)) {
                return "Only a Filed or Under Review claim can be rejected.";
            }
        } else if ("Settled".equals(target)) {
            if (!"Approved".equals(current)) return "A claim must be Approved before it can be settled.";
        }
        return null;
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

                    // Gap 3: the account was checked but the shipment was not, so a
                    // customer could file a claim against a stranger's shipment simply
                    // by posting its id, and staff could file against another tenant's.
                    com.nlogistic.dao.ShipmentDAO shipScope = new com.nlogistic.dao.ShipmentDAO();
                    if (roleId == ROLE_CUSTOMER) {
                        if (!shipScope.canAccessShipment(shipmentId, roleId, null, claimCustId)) {
                            throw new SecurityException("That shipment is not on your account.");
                        }
                    } else if (!shipScope.canAccessShipment(shipmentId, roleId,
                            com.nlogistic.util.RbacContext.companyId(request), null)) {
                        throw new SecurityException("That shipment does not belong to your company.");
                    }

                    int newClaimId = claimDAO.fileClaim(shipmentId, containerId, productId, claimCustId,
                                                         claimType, desc, incidentDate, claimedAmt, reasonId, userId);
                    if (newClaimId > 0) {
                        // FR7.2: evidence supplied with the claim is stored against it
                        // straight away rather than requiring a second upload step.
                        String evidenceNote = storeEvidence(request, newClaimId, userId);

                        session.setAttribute("successMessage", "Claim #" + newClaimId
                                + " filed successfully. Current Status: Filed." + evidenceNote);
                        redirectUrl = request.getContextPath() + "/claims?action=view&claimId=" + newClaimId;

                        // FR8.1: auto-generate a barcode for every newly filed claim
                        com.nlogistic.util.BarcodeAutoGenerator.generateFor(request, "Claim", newClaimId, userId);
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
                    requireTenant(request, claimId, roleId, customerId);
                    String block = checkTransition(claimDAO.getClaimStatus(claimId), "Under Review");
                    if (block != null) { session.setAttribute("errorMessage", block); break; }

                    String remark = request.getParameter("remarks");
                    String err = claimDAO.startReview(claimId, userId, remark);
                    if (err != null) {
                        session.setAttribute("errorMessage", err);
                    } else {
                        session.setAttribute("successMessage", "Claim #" + claimId + " is now Under Review. Finance team will evaluate.");
                    }
                    redirectUrl = request.getContextPath() + "/claims?action=view&claimId=" + claimId;
                    break;
                }

                case "approve": {
                    if (roleId != ROLE_FINANCE && roleId != ROLE_SUPER_ADMIN && roleId != ROLE_COMPANY_ADMIN) {
                        throw new SecurityException("Only Finance staff can approve a claim.");
                    }
                    int claimId = Integer.parseInt(request.getParameter("claimId").trim());
                    requireTenant(request, claimId, roleId, customerId);
                    String block = checkTransition(claimDAO.getClaimStatus(claimId), "Approved");
                    if (block != null) { session.setAttribute("errorMessage", block); break; }

                    double approvedAmt = Double.parseDouble(request.getParameter("approvedAmount").trim());
                    // FR7.5 precondition: an approval must carry a real amount, or the
                    // settlement that follows raises a credit note for nothing.
                    if (approvedAmt <= 0) {
                        session.setAttribute("errorMessage",
                                "Approved amount must be greater than zero. Reject the claim instead if nothing is payable.");
                        break;
                    }
                    String remark = request.getParameter("remarks");
                    String err = claimDAO.approveClaim(claimId, approvedAmt, userId, remark);
                    if (err != null) {
                        session.setAttribute("errorMessage", err);
                    } else {
                        session.setAttribute("successMessage", "Claim #" + claimId + " approved for " + String.format("%,.2f", approvedAmt) +
                            ". Settle the claim to raise the credit note.");
                    }
                    redirectUrl = request.getContextPath() + "/claims?action=view&claimId=" + claimId;
                    break;
                }

                case "reject": {
                    if (roleId != ROLE_FINANCE && roleId != ROLE_SUPER_ADMIN && roleId != ROLE_COMPANY_ADMIN) {
                        throw new SecurityException("Only Finance staff can reject a claim.");
                    }
                    int claimId = Integer.parseInt(request.getParameter("claimId").trim());
                    requireTenant(request, claimId, roleId, customerId);
                    String block = checkTransition(claimDAO.getClaimStatus(claimId), "Rejected");
                    if (block != null) { session.setAttribute("errorMessage", block); break; }

                    String remark = request.getParameter("remarks");
                    String err = claimDAO.rejectClaim(claimId, userId, remark);
                    if (err != null) {
                        session.setAttribute("errorMessage", err);
                    } else {
                        session.setAttribute("successMessage", "Claim #" + claimId + " has been rejected. Reason recorded in status history.");
                    }
                    redirectUrl = request.getContextPath() + "/claims?action=view&claimId=" + claimId;
                    break;
                }

                case "settle": {
                    if (roleId != ROLE_FINANCE && roleId != ROLE_SUPER_ADMIN && roleId != ROLE_COMPANY_ADMIN) {
                        throw new SecurityException("Only Finance staff can settle a claim.");
                    }
                    int claimId = Integer.parseInt(request.getParameter("claimId").trim());
                    requireTenant(request, claimId, roleId, customerId);
                    com.nlogistic.model.Claim settling = claimDAO.getClaimById(claimId);
                    String block = checkTransition(settling != null ? settling.getStatus() : null, "Settled");
                    if (block != null) { session.setAttribute("errorMessage", block); break; }

                    // FR7.5 contract precondition.
                    if (settling.getApprovedAmount() <= 0) {
                        session.setAttribute("errorMessage",
                                "Claim #" + claimId + " has no approved amount, so it cannot be settled.");
                        break;
                    }

                    // FR7.4 / FR7.6 are handled inside the settle_claim stored procedure,
                    // which raises the credit note in billing_invoices and posts the cost
                    // to profit_loss with its loss reason. Do NOT credit again here - an
                    // earlier attempt to do so in Java double-credited the customer.
                    String err = claimDAO.settleClaim(claimId, userId);
                    if (err != null) {
                        session.setAttribute("errorMessage", err);
                    } else {
                        session.setAttribute("successMessage",
                                "Claim #" + claimId + " settled and resolution recorded. Credit note of "
                                + String.format("%,.2f", settling.getApprovedAmount())
                                + " raised against the customer's account.");
                    }
                    redirectUrl = request.getContextPath() + "/claims?action=view&claimId=" + claimId;
                    break;
                }

                case "addDoc": {
                    int claimId = Integer.parseInt(request.getParameter("claimId").trim());
                    String docType = request.getParameter("docType");
                    requireTenant(request, claimId, roleId, customerId);

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
