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
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {
    private NotificationDAO notifDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        Integer userId = null;

        User user = (User) request.getSession().getAttribute("user");
        if (user != null) {
            userId = user.getUserId();
        }

        if (userId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        if ("markAllRead".equals(action)) {
            notifDAO.markAllAsReadForUser(userId);
            response.setStatus(HttpServletResponse.SC_OK);
            return;
        } else if ("markRead".equals(action)) {
            try {
                int notifId = Integer.parseInt(request.getParameter("id"));
                notifDAO.markAsRead(notifId);
                response.setStatus(HttpServletResponse.SC_OK);
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }
            return;
        }

        // Default: fetch notifications (empty list if the derived query fails for any reason)
        List<Notification> notifs = notifDAO.getUnreadNotificationsForUser(userId);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Build simple JSON array manually to avoid adding Jackson/GSON dependencies
        StringBuilder json = new StringBuilder();
        json.append("[");
        for (int i = 0; i < notifs.size(); i++) {
            Notification n = notifs.get(i);
            json.append("{")
                .append("\"id\":").append(n.getNotifId()).append(",")
                .append("\"title\":\"").append(escapeJson(n.getTitle())).append("\",")
                .append("\"message\":\"").append(escapeJson(n.getMessage())).append("\",")
                .append("\"link\":\"").append(escapeJson(n.getLink() != null ? n.getLink() : "")).append("\"")
                .append("}");
            if (i < notifs.size() - 1) json.append(",");
        }
        json.append("]");
        out.print(json.toString());
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
