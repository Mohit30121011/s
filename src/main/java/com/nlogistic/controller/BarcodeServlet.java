package com.nlogistic.controller;

import com.nlogistic.dao.BarcodeDAO;
import com.nlogistic.model.BarcodeEntry;
import com.nlogistic.model.BarcodeScanLog;
import com.nlogistic.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/barcodes")
public class BarcodeServlet extends HttpServlet {
    private BarcodeDAO barcodeDAO = new BarcodeDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<BarcodeEntry> barcodes = barcodeDAO.getAllBarcodes();
        List<BarcodeScanLog> scanLogs = barcodeDAO.getAllScanLogs();
        request.setAttribute("barcodes", barcodes);
        request.setAttribute("scanLogs", scanLogs);
        request.getRequestDispatcher("/jsp/barcodes.jsp").forward(request, response);
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
            response.sendRedirect(request.getContextPath() + "/barcodes");
            return;
        }

        try {
            switch (action) {
                case "generate":
                    String entityType = request.getParameter("entityType");
                    int entityId = Integer.parseInt(request.getParameter("entityId"));
                    String generatedCode = barcodeDAO.generateBarcode(entityType, entityId, userId);
                    request.getSession().setAttribute("successMessage", "Barcode generated: " + generatedCode);
                    break;
                case "scan":
                    String barcodeValue = request.getParameter("barcodeValue");
                    String scanLocation = request.getParameter("scanLocation");
                    String moduleContext = request.getParameter("moduleContext");
                    if (moduleContext == null || moduleContext.isEmpty()) moduleContext = "General";
                    String[] result = barcodeDAO.scanBarcode(barcodeValue, scanLocation, userId, moduleContext);
                    request.getSession().setAttribute("successMessage", 
                        "Barcode scanned! Entity: " + result[0] + " #" + result[1]);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/barcodes");
    }
}
