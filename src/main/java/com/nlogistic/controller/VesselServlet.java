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
            int capacity = 0;
            if (capacityStr != null && !capacityStr.trim().isEmpty()) {
                try {
                    capacity = Integer.parseInt(capacityStr);
                } catch (NumberFormatException e) {}
            }
            vesselDAO.addVessel(name, imo, capacity);
            request.getSession().setAttribute("successMessage", "Vessel added successfully.");
        }
        
        response.sendRedirect(request.getContextPath() + "/vessels");
    }
}
