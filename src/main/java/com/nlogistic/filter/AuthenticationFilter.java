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
        boolean isPublicPath = path.startsWith("/login") || path.startsWith("/register") || 
                               path.contains("/assets/") || path.endsWith("login.jsp") || path.endsWith("register.jsp");
        
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

        // Admin-only pages
        if (path.startsWith("/admin") || path.contains("/approve") || path.contains("/delete")) {
            allowed = (roleId == 1); // Super Admin only
        }
        // Finance pages (billing)
        else if (path.startsWith("/billing")) {
            allowed = (roleId <= 4); // Not customers for write ops, but allow read
        }
        // Compliance
        else if (path.startsWith("/compliance")) {
            allowed = (roleId <= 4); // Staff and admin
        }
        // Executive dashboard
        else if (path.startsWith("/executive")) {
            allowed = (roleId <= 2); // Admin only
        }
        // Claims
        else if (path.startsWith("/claims")) {
            allowed = true; // All roles can file/view claims
        }

        if (!allowed) {
            // FR1.9: Log permission denied event
            req.setAttribute("errorMessage", "Access Denied: You do not have permission to access this page.");
            req.getRequestDispatcher("/jsp/dashboard.jsp").forward(req, res);
            return;
        }

        chain.doFilter(request, response);
    }

    public void destroy() {}
}
