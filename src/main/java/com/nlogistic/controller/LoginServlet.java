package com.nlogistic.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.nlogistic.dao.UserDAO;
import com.nlogistic.model.User;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO = new UserDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String ipAddress = request.getRemoteAddr();
  
        // Use login_attempt SP which enforces:
        // - FR1.5: Session-based login
        // - FR1.8: Account lockout after 5 failed attempts
        // - FR1.9: Audit logging of login/logout/permission-denied
        String result = userDAO.loginAttempt(username, password, ipAddress);

        if ("SUCCESS".equals(result)) {      
            User user = userDAO.getUserByUsername(username);
            if (user != null) {
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                session.setAttribute("username", user.getUsername());
                session.setAttribute("roleId", user.getRoleId());
                session.setMaxInactiveInterval(30 * 60); // FR1.5: 30 minute timeout
                response.sendRedirect(request.getContextPath() + "/dashboard");
                return;
            }
        }

        // Map result codes to user-friendly messages
        String errorMsg;
        switch (result) {  
            case "USER_NOT_FOUND":      errorMsg = "User not found. Please check your username."; break;
            case "INVALID_PASSWORD":    errorMsg = "Invalid password. Please try again."; break;
            case "ACCOUNT_LOCKED":      errorMsg = "Account is locked due to too many failed attempts. Please wait 15 minutes."; break;
            case "ACCOUNT_INACTIVE":    errorMsg = "Account is inactive. Please contact administrator."; break;
            default:
                if (result != null && result.startsWith("DB_ERROR:")) {
                    errorMsg = "Database Connection Failed: " + result.substring(10) + ". Please check DBConnectionManager.java for correct MySQL password or ensure stored procedure exists.";
                } else {
                    errorMsg = "Login failed. Please try again.";
                }
                break;
        }
        request.setAttribute("errorMessage", errorMsg);
        request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
    }
}
