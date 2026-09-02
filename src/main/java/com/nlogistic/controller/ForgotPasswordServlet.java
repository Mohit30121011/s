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
            // Simulate sending email by printing to server logs
            String resetLink = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/reset-password?token=" + token;
            System.out.println("=====================================================");
            System.out.println("MOCK EMAIL SENT TO: " + email);
            System.out.println("RESET PASSWORD LINK: " + resetLink);
            System.out.println("=====================================================");
            
            request.setAttribute("successMessage", "If an account exists with that email, a password reset link has been sent.");
        } else {
            // For security, always show the same message even if email not found
            request.setAttribute("successMessage", "If an account exists with that email, a password reset link has been sent.");
        }
        
        request.getRequestDispatcher("/jsp/forgot-password.jsp").forward(request, response);
    }
}
