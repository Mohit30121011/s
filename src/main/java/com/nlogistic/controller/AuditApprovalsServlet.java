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
 * Audit Trail Controller for Approvals & Governance Decisions.
 * Displays all company and user/customer approval, suspension, and deactivation events.
 */
@WebServlet("/admin/audit-approvals")
public class AuditApprovalsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");

        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 2)) {
            if (user != null) {
                new com.nlogistic.dao.UserDAO().logAuditEvent(
                        user.getUserId(), "PERMISSION_DENIED", request.getRequestURI(), request.getRemoteAddr());
            }
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access Denied: administrative privileges required to view approval audit logs.");
            return;
        }

        String filter = request.getParameter("filter");
        if (filter == null || filter.trim().isEmpty()) {
            filter = "ALL";
        }
        String searchKeyword = request.getParameter("q");

        List<AuditEntry> auditLogs = auditDAO.getApprovalAuditLogs(filter, searchKeyword, 500);

        // A Company Admin may only inspect events raised by their own staff or for their company
        if (user.getRoleId() == 2) {
            final int companyId = user.getCompanyId();
            final com.nlogistic.dao.UserDAO userDAO = new com.nlogistic.dao.UserDAO();
            auditLogs.removeIf(entry -> {
                User actor = userDAO.getUserById(entry.getUserId());
                return actor == null || actor.getCompanyId() != companyId;
            });
        }

        Map<String, Integer> kpis = auditDAO.getApprovalKPIs();

        request.setAttribute("auditLogs", auditLogs);
        request.setAttribute("kpis", kpis);
        request.setAttribute("currentFilter", filter);
        request.setAttribute("searchKeyword", searchKeyword != null ? searchKeyword : "");

        request.getRequestDispatcher("/jsp/admin/audit_approvals.jsp").forward(request, response);
    }
}
