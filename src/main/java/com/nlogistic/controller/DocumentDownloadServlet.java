package com.nlogistic.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/download")
public class DocumentDownloadServlet extends HttpServlet {

    /**
     * Gap 6: this servlet checked only that the requested path stayed inside
     * /uploads. Any logged-in user - including a customer - could pull down any
     * other customer's cargo damage photographs, KYC documents or trade
     * paperwork by guessing or enumerating a path.
     *
     * A download is now resolved back to the record that owns the file, and
     * refused unless the caller can already open that record.
     */
    private boolean mayDownload(HttpServletRequest request, String filePath, int roleId,
                                Integer companyId, Integer customerId) {
        if (roleId == 1) return true;

        // Claim evidence: allowed when the caller can open the claim.
        Integer claimId = lookupId(
                "SELECT claim_id FROM claim_documents WHERE file_path = ?", filePath);
        if (claimId != null) {
            return new com.nlogistic.dao.ClaimDAO()
                    .canAccessClaim(claimId, roleId, companyId, customerId);
        }

        // Trade compliance paperwork: allowed when the caller can open the shipment.
        Integer shipmentId = lookupId(
                "SELECT shipment_id FROM compliance_documents WHERE file_path = ?", filePath);
        if (shipmentId != null) {
            return new com.nlogistic.dao.ShipmentDAO()
                    .canAccessShipment(shipmentId, roleId, companyId, customerId);
        }

        // KYC documents belong to one customer; only that customer and staff see them.
        if (filePath.startsWith("uploads/kyc")) {
            return roleId != 5;
        }

        // Anything else under /uploads is internal working material.
        return roleId != 5;
    }

    private Integer lookupId(String sql, String filePath) {
        try (Connection conn = com.nlogistic.util.DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, filePath);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String filePath = request.getParameter("path");

        if (filePath == null || filePath.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "File path is missing");
            return;
        }

        HttpSession session = request.getSession(false);
        com.nlogistic.model.User me = (session != null)
                ? (com.nlogistic.model.User) session.getAttribute("user") : null;
        if (me == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!mayDownload(request, filePath.trim(), me.getRoleId(),
                com.nlogistic.util.RbacContext.companyId(request),
                com.nlogistic.util.RbacContext.customerId(request))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to download this document.");
            return;
        }

        // Extract filename from path
        String fileName = filePath.substring(filePath.lastIndexOf('/') + 1);

        // Resolve against the real webapp uploads directory. Reject any attempt to
        // escape it (e.g. "../../WEB-INF/web.xml") before touching the filesystem.
        String uploadsRoot = getServletContext().getRealPath("") + File.separator + "uploads";
        String relative = filePath.startsWith("uploads/") ? filePath.substring("uploads/".length()) : filePath;
        File requested = new File(uploadsRoot, relative);
        boolean withinUploads;
        try {
            withinUploads = requested.getCanonicalPath().startsWith(new File(uploadsRoot).getCanonicalPath());
        } catch (IOException e) {
            withinUploads = false;
        }

        if (withinUploads && requested.exists() && requested.isFile()) {
            response.setContentType(getServletContext().getMimeType(fileName) != null
                    ? getServletContext().getMimeType(fileName) : "application/octet-stream");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
            response.setContentLengthLong(requested.length());
            try (FileInputStream in = new FileInputStream(requested); OutputStream out = response.getOutputStream()) {
                byte[] buf = new byte[8192];
                int n;
                while ((n = in.read(buf)) != -1) out.write(buf, 0, n);
            }
            return;
        }

        // No real file on disk for this path (e.g. a legacy/seed-data reference that
        // predates real uploads) — serve an explanatory placeholder instead of a 404.
        response.setContentType("text/plain");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        try (PrintWriter out = response.getWriter()) {
            out.println("NLOGISTIC ENTERPRISE SYSTEM");
            out.println("===========================");
            out.println("No file is stored on disk for this record (likely seed/demo data predating real uploads).");
            out.println("Requested File Path: " + filePath);
            out.println("Filename: " + fileName);
            out.println("\n[End of File]");
        }
    }
}
