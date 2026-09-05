package com.nlogistic.controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLDecoder;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/download-errors")
public class DownloadErrorServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // GAP 4: the only guard here was "the file sits in the OS temp dir", so any
        // authenticated user who guessed a report name could pull another company's
        // rejected stock rows. Error reports belong to the upload batch that produced
        // them, so the caller must own that batch.
        com.nlogistic.model.User user = com.nlogistic.util.RbacContext.user(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (user.getRoleId() > 3) { // warehouse function: Admins and Operations only
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access Denied: stock error reports are an Operations function.");
            return;
        }

        String filePath = request.getParameter("file");
        if (filePath == null || filePath.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "File parameter is missing");
            return;
        }

        if (!ownsErrorReport(filePath, user)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access Denied: this error report belongs to another company's upload.");
            return;
        }
        
        try {
            // Decode the URL encoded file path
            filePath = URLDecoder.decode(filePath, "UTF-8");
            
            File downloadFile = new File(filePath);
            if (!downloadFile.exists() || !downloadFile.isFile()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found");
                return;
            }
            
            // Security check to ensure we only download CSVs from the temp directory
            String tempDir = System.getProperty("java.io.tmpdir");
            if (!downloadFile.getAbsolutePath().startsWith(new File(tempDir).getAbsolutePath())) {
                 response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access to this file is forbidden");
                 return;
            }

            response.setContentType("text/csv");
            response.setHeader("Content-Disposition", "attachment; filename=\"error_report.csv\"");
            response.setContentLength((int) downloadFile.length());

            byte[] buffer = new byte[4096];
            int bytesRead;
            try (FileInputStream inStream = new FileInputStream(downloadFile);
                 OutputStream outStream = response.getOutputStream()) {
                while ((bytesRead = inStream.read(buffer)) != -1) {
                    outStream.write(buffer, 0, bytesRead);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error downloading file");
        }
    }

    /**
     * True when this error report was produced by an upload belonging to the
     * caller's company. Super Admin may read any report.
     */
    private boolean ownsErrorReport(String rawPath, com.nlogistic.model.User user) {
        if (user.getRoleId() == 1) return true;
        String sql = "SELECT 1 FROM stock_upload_log WHERE error_report_path = ? AND company_id = ?";
        try (java.sql.Connection conn = com.nlogistic.util.DBConnectionManager.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            String decoded = java.net.URLDecoder.decode(rawPath, "UTF-8");
            ps.setString(1, decoded);
            ps.setInt(2, user.getCompanyId());
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
