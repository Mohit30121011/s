package com.nlogistic.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;

@WebServlet("/download")
public class DocumentDownloadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String filePath = request.getParameter("path");

        if (filePath == null || filePath.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "File path is missing");
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
