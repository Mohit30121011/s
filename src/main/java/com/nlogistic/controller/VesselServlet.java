package com.nlogistic.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.dao.VesselDAO;
import com.nlogistic.model.Vessel;
import com.nlogistic.model.User;

@WebServlet("/vessels")
public class VesselServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private VesselDAO vesselDAO = new VesselDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        List<Vessel> vessels = vesselDAO.getAllVessels();
        request.setAttribute("vessels", vessels);
        request.getRequestDispatcher("/jsp/vessels.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String action = request.getParameter("action");
        if ("add".equals(action)) {
            String name = request.getParameter("vesselName");
            String imo = request.getParameter("imoNumber");
            String capacityStr = request.getParameter("capacityTeu");
            String status = request.getParameter("status");
            int capacity = 0;
            if (capacityStr != null && !capacityStr.trim().isEmpty()) {
                try {
                    capacity = Integer.parseInt(capacityStr);
                } catch (NumberFormatException e) {}
            }
            if (status == null || status.trim().isEmpty()) {
                status = "In Service";
            }
            vesselDAO.addVessel(name, imo, capacity, status);
            request.getSession().setAttribute("successMessage", "Vessel " + (name != null ? name : "") + " registered successfully.");
        } else if ("edit".equals(action)) {
            String vesselIdStr = request.getParameter("vesselId");
            String name = request.getParameter("vesselName");
            String imo = request.getParameter("imoNumber");
            String capacityStr = request.getParameter("capacityTeu");
            String status = request.getParameter("status");
            if (vesselIdStr != null) {
                try {
                    int vesselId = Integer.parseInt(vesselIdStr);
                    int capacity = 0;
                    if (capacityStr != null && !capacityStr.trim().isEmpty()) {
                        capacity = Integer.parseInt(capacityStr);
                    }
                    if (status == null || status.trim().isEmpty()) {
                        status = "In Service";
                    }
                    vesselDAO.updateVessel(vesselId, name, imo, capacity, status);
                    request.getSession().setAttribute("successMessage", "Vessel " + (name != null ? name : "") + " details and status updated successfully.");
                } catch (Exception e) {
                    e.printStackTrace();
                    request.getSession().setAttribute("errorMessage", "Failed to update vessel: " + e.getMessage());
                }
            }
        } else if ("delete".equals(action)) {
            String vesselIdStr = request.getParameter("vesselId");
            if (vesselIdStr != null) {
                try {
                    int vesselId = Integer.parseInt(vesselIdStr);
                    vesselDAO.deleteVessel(vesselId, user.getUserId());
                    request.getSession().setAttribute("successMessage", "Vessel decommissioned successfully.");
                } catch (Exception e) {
                    e.printStackTrace();
                    request.getSession().setAttribute("errorMessage", "Failed to delete vessel: " + e.getMessage());
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/jsp/vessels.jsp");
    }
}
