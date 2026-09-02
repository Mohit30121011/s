package com.nlogistic.filter;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.nlogistic.model.User;

/**
 * FR1.4, FR1.5, FR1.7: Central authentication and RBAC filter.
 * Intercepts all requests, verifies session and role permissions.
 */
@WebFilter("/*")
public class AuthenticationFilter implements Filter {

    public void init(FilterConfig fConfig) throws ServletException {}

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = uri.substring(contextPath.length());
        
        // Allow public paths (FR1.5: login/register accessible without auth)
        boolean isPublicPath = path.equals("/") || path.equals("/index.jsp") || 
                               path.startsWith("/login") || path.startsWith("/register") || 
                               path.startsWith("/forgot-password") || path.startsWith("/reset-password") ||
                               path.contains("/assets/") || path.endsWith("login.jsp") || path.endsWith("register.jsp") ||
                               path.endsWith("forgot-password.jsp") || path.endsWith("reset-password.jsp");
        
        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);

        if (isPublicPath) {
            chain.doFilter(request, response);
            return;
        }

        if (!isLoggedIn) {
            res.sendRedirect(contextPath + "/login");
            return;
        }

        // FR1.7: Role-based access control
        User user = (User) session.getAttribute("user");
        int roleId = user.getRoleId();
        // Role IDs: 1=Super Admin, 2=Company Admin, 3=Company Staff Ops, 4=Company Staff Finance, 5=Customer

        boolean allowed = true;


        // Admin-only pages (Approve users, master data)
        if (path.startsWith("/admin") || path.contains("/approve") || path.contains("/delete")) {
            allowed = (roleId == 1); // Super Admin only
        }
        // Executive dashboard (Super Admin, Company Admin)
        else if (path.startsWith("/executive") || path.startsWith("/company")) {
            allowed = (roleId <= 2); 
        }
        // Vessels & Containers (Module 3) & Stock Management (Module 4)
        else if (path.startsWith("/vessel") || path.startsWith("/container") || path.startsWith("/stock")) {
            allowed = (roleId <= 3); // Super Admin, Company Admin, Operations
        }
        // Finance & Billing (Module 5)
        else if (path.startsWith("/billing") || path.startsWith("/invoice") || path.startsWith("/payment")) {
            // Role 4 = Finance. Customers (5) can view, but this filter handles base paths.
            // Assuming specific view endpoints bypass this or we allow 5 to enter but controller restricts actions.
            // Let's allow all to access the controller, and let controller limit actions.
            allowed = true; 
        }
        // Compliance (Module 7)
        else if (path.startsWith("/compliance")) {
            allowed = (roleId <= 3); // Admin and Ops
        }
        // Shipments (Module 2) & Claims (Module 6)
        else if (path.startsWith("/shipment") || path.startsWith("/claims")) {
            allowed = true; // Customers can book/track shipments and file claims. Controllers enforce write access.
        }

        if (!allowed) {
            // FR1.9: Log permission denied event
            com.nlogistic.dao.UserDAO userDAO = new com.nlogistic.dao.UserDAO();
            userDAO.logAuditEvent(user.getUserId(), "PERMISSION_DENIED", path, req.getRemoteAddr());
            
            req.setAttribute("errorMessage", "Access Denied: You do not have permission to access this page.");
            req.getRequestDispatcher("/jsp/dashboard.jsp").forward(req, res);
            return;
        }

        chain.doFilter(request, response);
    }

    public void destroy() {}
}
