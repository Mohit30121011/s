package com.nlogistic.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Contract Precondition: Verify caller is authenticated with a valid role
        Integer roleId = (Integer) request.getSession().getAttribute("roleId");
        if (roleId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Access Denied: Authentication required.");
            return;
        }

        // AuthenticationFilter already ensures that only logged-in users reach here.
        // We can load some basic summary data here if needed (e.g. from a DashboardDAO).
        
        request.getRequestDispatcher("/jsp/dashboard.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
