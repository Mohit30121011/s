package com.nlogistic.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.model.User;
import com.nlogistic.util.DBConnectionManager;

@WebServlet("/scan-barcode")
public class ScanBarcodeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        request.getRequestDispatcher("/jsp/scan-barcode.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        String barcodeValue = request.getParameter("barcodeValue");
        String scanLocation = request.getParameter("scanLocation");
        if (scanLocation == null || scanLocation.isEmpty()) scanLocation = "Warehouse A";

        try (Connection conn = DBConnectionManager.getConnection()) {
            // 1. Look up the barcode
            String sqlFind = "SELECT barcode_id, entity_type, entity_id FROM barcode_entries WHERE barcode_value = ?";
            int barcodeId = -1;
            String entityType = "";
            int entityId = -1;
            
            try (PreparedStatement ps = conn.prepareStatement(sqlFind)) {
                ps.setString(1, barcodeValue);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        barcodeId = rs.getInt("barcode_id");
                        entityType = rs.getString("entity_type");
                        entityId = rs.getInt("entity_id");
                    }
                }
            }
            
            if (barcodeId == -1) {
                request.setAttribute("errorMessage", "Invalid Barcode! Not found in system.");
                request.getRequestDispatcher("/jsp/scan-barcode.jsp").forward(request, response);
                return;
            }

            // 2. Log the scan (FR8.5)
            String sqlLog = "INSERT INTO barcode_scan_log (barcode_id, scanned_by, scan_location, module_context) VALUES (?, ?, ?, ?)";
            try (PreparedStatement psLog = conn.prepareStatement(sqlLog)) {
                psLog.setInt(1, barcodeId);
                psLog.setInt(2, user.getUserId());
                psLog.setString(3, scanLocation);
                psLog.setString(4, "Scanner App");
                psLog.executeUpdate();
            }

            // 3. Fetch Entity Details (FR8.4)
            if ("Shipment".equalsIgnoreCase(entityType)) {
                String sqlShipment = "SELECT * FROM shipment WHERE shipment_id = ?";
                try (PreparedStatement psShip = conn.prepareStatement(sqlShipment)) {
                    psShip.setInt(1, entityId);
                    try (ResultSet rsShip = psShip.executeQuery()) {
                        if (rsShip.next()) {
                            request.setAttribute("entityDetails", "Shipment #" + entityId + " - " + rsShip.getString("cargo_description") + " (" + rsShip.getString("status") + ")");
                        }
                    }
                }
            } else if ("Container".equalsIgnoreCase(entityType)) {
                String sqlContainer = "SELECT * FROM containers WHERE container_id = ?";
                try (PreparedStatement psCont = conn.prepareStatement(sqlContainer)) {
                    psCont.setInt(1, entityId);
                    try (ResultSet rsCont = psCont.executeQuery()) {
                        if (rsCont.next()) {
                            request.setAttribute("entityDetails", "Container #" + rsCont.getString("container_number") + " - " + rsCont.getString("type") + " (" + rsCont.getString("status") + ")");
                        }
                    }
                }
            } else {
                request.setAttribute("entityDetails", entityType + " #" + entityId + " scanned successfully.");
            }

            request.setAttribute("successMessage", "Barcode Scanned & Logged Successfully!");
            request.setAttribute("scannedBarcode", barcodeValue);
            request.setAttribute("entityType", entityType);
            request.setAttribute("entityId", entityId);
            
            request.getRequestDispatcher("/jsp/scan-barcode.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "System Error: " + e.getMessage());
            request.getRequestDispatcher("/jsp/scan-barcode.jsp").forward(request, response);
        }
    }
}
