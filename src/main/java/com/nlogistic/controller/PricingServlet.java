package com.nlogistic.controller;

import com.nlogistic.dao.PricingRuleDAO;
import com.nlogistic.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/pricing/*")
public class PricingServlet extends HttpServlet {

    private PricingRuleDAO pricingRuleDAO = new PricingRuleDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("rules", pricingRuleDAO.getAllPricingRules());
        request.getRequestDispatcher("/jsp/pricing.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (pathInfo != null && pathInfo.equals("/update")) {
            int pricingId = Integer.parseInt(request.getParameter("pricingId"));
            double seasonal = Double.parseDouble(request.getParameter("seasonalMultiplier"));
            double demand = Double.parseDouble(request.getParameter("demandMultiplier"));
            
            boolean success = pricingRuleDAO.updateMultipliers(pricingId, seasonal, demand, currentUser.getUserId());
            if (success) {
                response.sendRedirect(request.getContextPath() + "/pricing?success=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/pricing?error=true");
            }
        }
    }
}
