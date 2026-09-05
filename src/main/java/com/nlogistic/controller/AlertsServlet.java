package com.nlogistic.controller;

import com.nlogistic.dao.NotificationDAO;
import com.nlogistic.model.Notification;
import com.nlogistic.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/alerts")
public class AlertsServlet extends HttpServlet {
    private final NotificationDAO notifDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("markAllRead".equals(action)) {
            notifDAO.markAllAsReadForUser(user.getUserId());
            response.sendRedirect(request.getContextPath() + "/alerts");
            return;
        } else if ("markRead".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                notifDAO.markAsRead(user.getUserId(), id);
            } catch (Exception ignored) {}
            response.sendRedirect(request.getContextPath() + "/alerts");
            return;
        }

        // Fetch live alerts for user based on their role and tenant scope
        List<Notification> alertsList = notifDAO.getUnreadNotificationsForUser(user.getUserId());
        if (alertsList == null) {
            alertsList = new ArrayList<>();
        }

        // Compute KPIs
        int totalAlerts = alertsList.size();
        int criticalCount = 0;
        int complianceCount = 0;
        int billingCount = 0;
        int claimsCount = 0;

        for (Notification n : alertsList) {
            if ("danger".equalsIgnoreCase(n.getType()) || "warning".equalsIgnoreCase(n.getType())) {
                criticalCount++;
            }
            if ("Compliance".equalsIgnoreCase(n.getCategory())) {
                complianceCount++;
            } else if ("Billing".equalsIgnoreCase(n.getCategory()) || "Finance".equalsIgnoreCase(n.getCategory())) {
                billingCount++;
            } else if ("Claims".equalsIgnoreCase(n.getCategory())) {
                claimsCount++;
            }
        }

        request.setAttribute("alertsList", alertsList);
        request.setAttribute("totalAlerts", totalAlerts);
        request.setAttribute("criticalCount", criticalCount);
        request.setAttribute("complianceCount", complianceCount);
        request.setAttribute("billingCount", billingCount);
        request.setAttribute("claimsCount", claimsCount);

        request.getRequestDispatcher("/jsp/alerts.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
