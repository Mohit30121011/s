package com.nlogistic.controller;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.dao.AuditDAO;
import com.nlogistic.dao.AuditDAO.AuditEntry;
import com.nlogistic.model.User;

/**
 * FR1.9 - Security audit trail viewer.
 *
 * Previously there was no controller for the audit log at all: the sidebar
 * linked straight at /jsp/admin/audit_logins.jsp, so the view had to load its
 * own data and no role precondition was ever evaluated on the server side.
 */
@WebServlet("/admin/audit-logs")
public class AuditLogServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");

        // FR1.7 contract precondition: audit trails are governance tooling.
        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 2)) {
            if (user != null) {
                new com.nlogistic.dao.UserDAO().logAuditEvent(
                        user.getUserId(), "PERMISSION_DENIED", request.getRequestURI(), request.getRemoteAddr());
            }
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access Denied: administrative privileges required to view audit logs.");
            return;
        }

        String actionFilter = request.getParameter("action");
        if (actionFilter == null || actionFilter.trim().isEmpty()) {
            actionFilter = "ALL";
        }
        String searchKeyword = request.getParameter("q");

        List<AuditEntry> auditLogs = auditDAO.getAuditLogs(actionFilter, searchKeyword, 500);

        // A Company Admin may only inspect events raised by their own staff.
        if (user.getRoleId() == 2) {
            final int companyId = user.getCompanyId();
            final com.nlogistic.dao.UserDAO userDAO = new com.nlogistic.dao.UserDAO();
            auditLogs.removeIf(entry -> {
                User actor = userDAO.getUserById(entry.getUserId());
                return actor == null || actor.getCompanyId() != companyId;
            });
        }

        Map<String, Integer> kpis = auditDAO.getAuditKPIs();

        request.setAttribute("auditLogs", auditLogs);
        request.setAttribute("kpis", kpis);
        request.setAttribute("currentAction", actionFilter);
        request.setAttribute("searchKeyword", searchKeyword != null ? searchKeyword : "");

        request.getRequestDispatcher("/jsp/admin/audit_logins.jsp").forward(request, response);
    }
}
