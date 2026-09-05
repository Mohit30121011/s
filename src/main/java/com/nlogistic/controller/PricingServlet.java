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
        java.util.List<com.nlogistic.model.PricingRule> rules = pricingRuleDAO.getAllPricingRules();
        java.util.List<com.nlogistic.model.PricingAudit> auditHistory = pricingRuleDAO.getAuditHistory();

        request.setAttribute("rules", rules);
        request.setAttribute("auditHistory", auditHistory);

        // The four KPI cards on pricing.jsp read kpiTotalRules, kpiAvgFinalPrice,
        // kpiMaxBasePrice and kpiTotalAudit. Nothing ever set them, so every card
        // rendered its label and an empty value. They are derived from the rows
        // already loaded above, which also keeps them in step with the table.
        int totalRules = rules.size();
        double sumFinal = 0.0;
        double maxBase = 0.0;
        for (com.nlogistic.model.PricingRule r : rules) {
            sumFinal += r.getFinalPrice();
            if (r.getBasePrice() > maxBase) maxBase = r.getBasePrice();
        }
        request.setAttribute("kpiTotalRules", totalRules);
        request.setAttribute("kpiAvgFinalPrice", totalRules > 0 ? sumFinal / totalRules : 0.0);
        request.setAttribute("kpiMaxBasePrice", maxBase);
        request.setAttribute("kpiTotalAudit", auditHistory.size());

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
        } else if (pathInfo != null && pathInfo.equals("/syncDemand")) {
            // FR3.5 / SRS 5.5: recompute every demand multiplier from the latest
            // forecast. Admins only, and every resulting price change is audited.
            if (currentUser == null || currentUser.getRoleId() > 2) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Only Super Admin or Company Admin can recalibrate demand multipliers.");
                return;
            }
            int changed = new com.nlogistic.dao.PricingRuleDAO().syncDemandMultipliers(currentUser.getUserId());
            request.getSession().setAttribute("successMessage", changed > 0
                    ? "Demand multipliers recalibrated from the latest forecast - " + changed + " rate(s) updated and logged to the price audit trail."
                    : "Demand multipliers are already in line with the current forecast; no rates changed.");
            response.sendRedirect(request.getContextPath() + "/pricing");
            return;

        } else if (pathInfo != null && pathInfo.equals("/updatePrice")) {
            // FR3.7: base-price adjustment with mandatory audit reason — governance table only, Admins only.
            if (currentUser == null || currentUser.getRoleId() > 2) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only Super Admin or Company Admin can adjust freight rates.");
                return;
            }
            int pricingId = Integer.parseInt(request.getParameter("pricingId"));
            double newBasePrice = Double.parseDouble(request.getParameter("basePrice"));
            String reason = request.getParameter("reason");
            if (reason == null || reason.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/pricing?error=reason_required");
                return;
            }
            boolean success = pricingRuleDAO.updateBasePrice(pricingId, newBasePrice, currentUser.getUserId(), reason.trim());
            response.sendRedirect(request.getContextPath() + "/pricing?" + (success ? "success=true" : "error=true"));
        }
    }
}
