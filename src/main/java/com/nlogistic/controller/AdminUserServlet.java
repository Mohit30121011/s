package com.nlogistic.controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.dao.UserDAO;
import com.nlogistic.model.User;

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO = new UserDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Contract Precondition: Verify caller role/permission
        Integer roleId = (Integer) request.getSession().getAttribute("roleId");
        if (roleId == null || roleId != 1) {
            com.nlogistic.model.User user = (com.nlogistic.model.User) request.getSession().getAttribute("user");
            if(user != null) {
                userDAO.logAuditEvent(user.getUserId(), "PERMISSION_DENIED_CONTRACT", request.getRequestURI(), request.getRemoteAddr());
            }
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Super Admin role required.");
            return;
        }

        List<User> pendingUsers = userDAO.getPendingUsers();
        List<User> allUsers = userDAO.getAllUsers();
        com.nlogistic.dao.CompanyDAO cDao = new com.nlogistic.dao.CompanyDAO();
        List<com.nlogistic.model.Company> allComps = cDao.getAllCompanies();

        java.util.Map<Integer, String> companyNameMap = new java.util.HashMap<>();
        if (allComps != null) {
            for (com.nlogistic.model.Company cp : allComps) {
                companyNameMap.put(cp.getCompanyId(), cp.getCompanyName());
            }
        }

        int pendingCount = 0;
        int activeCount = 0;
        int inactiveCount = 0;
        int totalCount = (allUsers != null) ? allUsers.size() : 0;

        if (allUsers != null) {
            for (User u : allUsers) {
                if ("Pending".equalsIgnoreCase(u.getStatus())) {
                    pendingCount++;
                } else if ("Active".equalsIgnoreCase(u.getStatus())) {
                    activeCount++;
                } else {
                    inactiveCount++;
                }
            }
        }

        request.setAttribute("allUsers", allUsers);
        request.setAttribute("pendingUsers", pendingUsers);
        request.setAttribute("companyNameMap", companyNameMap);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("activeCount", activeCount);
        request.setAttribute("inactiveCount", inactiveCount);
        request.setAttribute("totalCount", totalCount);

        request.getRequestDispatcher("/jsp/admin/users.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Contract Precondition: Verify caller role/permission
        Integer roleId = (Integer) request.getSession().getAttribute("roleId");
        if (roleId == null || roleId != 1) {
            com.nlogistic.model.User user = (com.nlogistic.model.User) request.getSession().getAttribute("user");
            if(user != null) {
                userDAO.logAuditEvent(user.getUserId(), "PERMISSION_DENIED_CONTRACT", request.getRequestURI(), request.getRemoteAddr());
            }
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Super Admin role required.");
            return;
        }

        String action = request.getParameter("action");
        int userId = Integer.parseInt(request.getParameter("userId"));

        if ("accept".equals(action)) {
            userDAO.updateUserStatus(userId, "Active");
            request.getSession().setAttribute("successMessage", "User Approved Successfully.");
        } else if ("reject".equals(action)) {
            userDAO.updateUserStatus(userId, "Locked"); // Or some other rejected status
            request.getSession().setAttribute("errorMessage", "User Rejected.");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}
