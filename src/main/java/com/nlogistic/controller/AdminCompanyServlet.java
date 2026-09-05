package com.nlogistic.controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.dao.CompanyDAO;
import com.nlogistic.model.Company;
import com.nlogistic.dao.UserDAO;

@WebServlet("/admin/companies")
public class AdminCompanyServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CompanyDAO companyDAO = new CompanyDAO();
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

        List<Company> pendingCompanies = companyDAO.getPendingCompanies();
        List<Company> allCompanies = companyDAO.getAllCompanies();

        int pendingCount = (pendingCompanies != null) ? pendingCompanies.size() : 0;
        int activeCount = 0;
        int suspendedCount = 0;
        int totalCount = (allCompanies != null) ? allCompanies.size() : 0;

        if (allCompanies != null) {
            for (Company comp : allCompanies) {
                if ("Active".equalsIgnoreCase(comp.getApprovalStatus())) {
                    activeCount++;
                } else if ("Suspended".equalsIgnoreCase(comp.getApprovalStatus()) || "Rejected".equalsIgnoreCase(comp.getApprovalStatus())) {
                    suspendedCount++;
                }
            }
        }

        request.setAttribute("pendingCompanies", pendingCompanies);
        request.setAttribute("allCompanies", allCompanies);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("activeCount", activeCount);
        request.setAttribute("suspendedCount", suspendedCount);
        request.setAttribute("totalCount", totalCount);

        request.getRequestDispatcher("/jsp/admin/companies.jsp").forward(request, response);
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

        com.nlogistic.model.User admin = (com.nlogistic.model.User) request.getSession().getAttribute("user");
        int adminUserId = admin.getUserId();

        String action = request.getParameter("action");
        int companyId = Integer.parseInt(request.getParameter("companyId"));

        // FR1.2 / GAP-M1-03: route approvals through the audited stored procedures
        // (approve_company / suspend_company) instead of raw UPDATE statements, so
        // the cascade to linked users and the audit_log entry are written by the DB.
        if ("accept".equals(action) || "approve".equals(action)) {
            companyDAO.approveCompany(companyId, adminUserId);
            request.getSession().setAttribute("successMessage",
                    "Company #" + companyId + " approved and activated. Linked staff accounts are now active.");

        } else if ("reject".equals(action) || "suspend".equals(action)) {
            String reason = request.getParameter("reason");
            if (reason == null || reason.trim().isEmpty()) {
                reason = "No reason supplied by approver.";
            }
            companyDAO.suspendCompany(companyId, adminUserId, reason.trim());
            request.getSession().setAttribute("successMessage",
                    "Company #" + companyId + " suspended. Reason recorded in the audit trail.");

        } else if ("delete".equals(action)) {
            companyDAO.deleteCompany(companyId, adminUserId);
            request.getSession().setAttribute("successMessage", "Company #" + companyId + " deleted.");

        } else if ("update".equals(action)) {
            companyDAO.updateCompany(companyId, adminUserId,
                    request.getParameter("companyName"), request.getParameter("licenseNo"),
                    request.getParameter("gstNo"), request.getParameter("address"),
                    request.getParameter("contactEmail"), request.getParameter("contactPhone"),
                    request.getParameter("approvalStatus"));
            request.getSession().setAttribute("successMessage", "Company #" + companyId + " updated.");

        } else {
            request.getSession().setAttribute("errorMessage", "Unknown company approval action: " + action);
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/companies");
    }
}
