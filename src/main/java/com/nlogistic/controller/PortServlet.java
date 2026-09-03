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
        if ("add".equals(action)) {
            String portName = request.getParameter("portName");
            String portCode = request.getParameter("portCode");
            String country = request.getParameter("country");
            String latStr = request.getParameter("latitude");
            String lngStr = request.getParameter("longitude");

            double lat = 0.0;
            double lng = 0.0;
            if (latStr != null && !latStr.trim().isEmpty()) {
                try {
                    lat = Double.parseDouble(latStr.trim());
                } catch (NumberFormatException ignored) {}
            }
            if (lngStr != null && !lngStr.trim().isEmpty()) {
                try {
                    lng = Double.parseDouble(lngStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            if (portName != null && !portName.trim().isEmpty()) {
                portDAO.addPort(portName.trim(), portCode != null ? portCode.trim() : "", country != null ? country.trim() : "", lat, lng);
                request.getSession().setAttribute("successMessage", "Port '" + portName.trim() + "' added successfully to database!");
            } else {
                request.getSession().setAttribute("errorMessage", "Port name is required.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/ports");
    }
}
