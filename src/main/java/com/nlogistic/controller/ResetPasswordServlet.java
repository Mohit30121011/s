package com.nlogistic.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.nlogistic.dao.UserDAO;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO = new UserDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String token = request.getParameter("token");
        
        if (token == null || token.trim().isEmpty() || userDAO.validateResetToken(token) == -1) {
            request.setAttribute("errorMessage", "Invalid or expired password reset link.");
            request.getRequestDispatcher("/jsp/forgot-password.jsp").forward(request, response);
            return;
        }
        
        request.setAttribute("token", token);
        request.getRequestDispatcher("/jsp/reset-password.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String token = request.getParameter("token");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        
        if (password == null || !password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/jsp/reset-password.jsp").forward(request, response);
            return;
        }
        
        boolean success = userDAO.resetPasswordWithToken(token, password);
        
        if (success) {
            request.setAttribute("successMessage", "Password has been successfully reset! You can now sign in.");
            request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Invalid or expired password reset link.");
            request.getRequestDispatcher("/jsp/forgot-password.jsp").forward(request, response);
        }
    }
}
