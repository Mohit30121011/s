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
        request.setAttribute("pendingCompanies", pendingCompanies);
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

        String action = request.getParameter("action");
        int companyId = Integer.parseInt(request.getParameter("companyId"));

        if ("accept".equals(action)) {
            companyDAO.updateCompanyStatus(companyId, "Active");
            // Find all users tied to this company and activate them
            try (java.sql.Connection conn = com.nlogistic.util.DBConnectionManager.getConnection();
                 java.sql.PreparedStatement ps = conn.prepareStatement("UPDATE users SET status = 'Active' WHERE company_id = ?")) {
                ps.setInt(1, companyId);
                ps.executeUpdate();
            } catch(Exception e) { e.printStackTrace(); }
            request.getSession().setAttribute("successMessage", "Company Approved Successfully.");
        } else if ("reject".equals(action)) {
            companyDAO.updateCompanyStatus(companyId, "Suspended");
            request.getSession().setAttribute("errorMessage", "Company Rejected.");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/companies");
    }
}
