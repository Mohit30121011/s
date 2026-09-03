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
        String filePath = request.getParameter("file");
        if (filePath == null || filePath.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "File parameter is missing");
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
}
