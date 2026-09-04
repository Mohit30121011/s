package com.nlogistic.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.dao.PortDAO;
import com.nlogistic.model.Port;
import com.nlogistic.model.User;

@WebServlet("/ports")
public class PortServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private PortDAO portDAO = new PortDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        List<Port> ports = portDAO.getAllPorts();
        request.setAttribute("ports", ports);
        request.getRequestDispatcher("/jsp/ports.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String action = request.getParameter("action");
        if ("add".equalsIgnoreCase(action)) {
            String portName = request.getParameter("portName");
            String portCode = request.getParameter("portCode");
            String country = request.getParameter("country");
            String latStr = request.getParameter("latitude");
            String lngStr = request.getParameter("longitude");

            double lat = 0.0;
            double lng = 0.0;
            if (latStr != null && !latStr.trim().isEmpty()) {
                try { lat = Double.parseDouble(latStr.trim()); } catch (NumberFormatException ignored) {}
            }
            if (lngStr != null && !lngStr.trim().isEmpty()) {
                try { lng = Double.parseDouble(lngStr.trim()); } catch (NumberFormatException ignored) {}
            }

            if (portName != null && !portName.trim().isEmpty()) {
                portDAO.addPort(portName.trim(), portCode != null ? portCode.trim().toUpperCase() : "", country != null ? country.trim() : "", lat, lng);
                request.getSession().setAttribute("successMessage", "Port '" + portName.trim() + "' registered successfully!");
            } else {
                request.getSession().setAttribute("errorMessage", "Port name is required.");
            }
        } else if ("edit".equalsIgnoreCase(action) || "update".equalsIgnoreCase(action)) {
            String portIdStr = request.getParameter("portId");
            String portName = request.getParameter("portName");
            String portCode = request.getParameter("portCode");
            String country = request.getParameter("country");
            String latStr = request.getParameter("latitude");
            String lngStr = request.getParameter("longitude");

            if (portIdStr != null && !portIdStr.trim().isEmpty()) {
                try {
                    int portId = Integer.parseInt(portIdStr.trim());
                    double lat = 0.0;
                    double lng = 0.0;
                    if (latStr != null && !latStr.trim().isEmpty()) {
                        try { lat = Double.parseDouble(latStr.trim()); } catch (NumberFormatException ignored) {}
                    }
                    if (lngStr != null && !lngStr.trim().isEmpty()) {
                        try { lng = Double.parseDouble(lngStr.trim()); } catch (NumberFormatException ignored) {}
                    }

                    if (portName != null && !portName.trim().isEmpty()) {
                        portDAO.updatePort(portId, portName.trim(), portCode != null ? portCode.trim().toUpperCase() : "", country != null ? country.trim() : "", lat, lng);
                        request.getSession().setAttribute("successMessage", "Port #PRT-" + portId + " (" + portName.trim() + ") updated successfully!");
                    } else {
                        request.getSession().setAttribute("errorMessage", "Port name cannot be empty.");
                    }
                } catch (Exception e) {
                    request.getSession().setAttribute("errorMessage", "Invalid Port ID: " + e.getMessage());
                }
            }
        } else if ("delete".equalsIgnoreCase(action)) {
            String portIdStr = request.getParameter("portId");
            if (portIdStr != null && !portIdStr.trim().isEmpty()) {
                try {
                    int portId = Integer.parseInt(portIdStr.trim());
                    portDAO.deletePort(portId);
                    request.getSession().setAttribute("successMessage", "Port #PRT-" + portId + " removed successfully from directory.");
                } catch (Exception e) {
                    request.getSession().setAttribute("errorMessage", "Failed to delete port: " + e.getMessage());
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/ports");
    }
}
