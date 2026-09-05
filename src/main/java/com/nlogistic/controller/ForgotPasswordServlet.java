package com.nlogistic.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.nlogistic.dao.UserDAO;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO = new UserDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/jsp/forgot-password.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        
        String token = userDAO.generatePasswordResetToken(email);
        
        if (token != null) {
            String resetLink = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/reset-password?token=" + token;
            // FR1.6 / GAP-M1-04: actually dispatch the reset mail. Previously this
            // only printed to stdout, so users could never complete a reset.
            com.nlogistic.model.User target = userDAO.getUserByEmail(email);
            String username = (target != null && target.getUsername() != null) ? target.getUsername() : "User";

            boolean emailSent = com.nlogistic.util.EmailService.sendPasswordResetEmail(email, username, resetLink);

            if (emailSent) {
                request.setAttribute("successMessage",
                        "Password reset instructions have been sent to your email inbox.");
            } else {
                // SMTP unconfigured (common in local/demo installs): surface the link
                // directly rather than leaving the user with no way forward.
                request.setAttribute("successMessage",
                        "Password reset link generated. Direct link: " + resetLink);
            }
        } else {
            // For security, always show the same message even if email not found
            request.setAttribute("successMessage", "If an account exists with that email, a password reset link has been sent.");
        }
        
        request.getRequestDispatcher("/jsp/forgot-password.jsp").forward(request, response);
    }
}
