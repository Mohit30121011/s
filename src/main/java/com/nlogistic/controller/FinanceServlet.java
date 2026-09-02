package com.nlogistic.controller;

import com.nlogistic.dao.ProfitLossDAO;
import com.nlogistic.dao.CompanyDAO;
import com.nlogistic.dao.PortDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/finance/*")
public class FinanceServlet extends HttpServlet {
    private ProfitLossDAO profitLossDAO;
    private CompanyDAO companyDAO;
    private PortDAO portDAO;

    @Override
    public void init() {
        profitLossDAO = new ProfitLossDAO();
        companyDAO = new CompanyDAO();
        portDAO = new PortDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if (pathInfo == null || pathInfo.equals("/")) {
            request.getRequestDispatcher("/jsp/profit_loss_analytics.jsp").forward(request, response);
        } else if (pathInfo.equals("/profit-loss")) {
            
            Integer companyId = null;
            if (request.getParameter("companyId") != null && !request.getParameter("companyId").isEmpty()) {
                companyId = Integer.parseInt(request.getParameter("companyId"));
            }
            
            Integer routeId = null;
            if (request.getParameter("routeId") != null && !request.getParameter("routeId").isEmpty()) {
                routeId = Integer.parseInt(request.getParameter("routeId"));
            }
            
            String startDate = null;
            String endDate = null;
            String dateRange = request.getParameter("dateRange"); // Format: YYYY-MM-DD to YYYY-MM-DD
            if (dateRange != null && !dateRange.isEmpty() && dateRange.contains(" to ")) {
                String[] parts = dateRange.split(" to ");
                if (parts.length == 2) {
                    startDate = parts[0].trim();
                    endDate = parts[1].trim();
                }
            }

            request.setAttribute("companies", companyDAO.getAllCompanies());
            request.setAttribute("ports", portDAO.getAllPorts());
            
            request.setAttribute("selectedCompany", companyId);
            request.setAttribute("selectedRoute", routeId);
            request.setAttribute("selectedDateRange", dateRange);

            request.setAttribute("kpi", profitLossDAO.getOverallKPIs(companyId, routeId, startDate, endDate));
            request.setAttribute("monthlyTrend", profitLossDAO.getMonthlyTrend(companyId, routeId, startDate, endDate));
            request.setAttribute("quarterlyTrend", profitLossDAO.getQuarterlyTrend(companyId, routeId, startDate, endDate));
            request.setAttribute("yearlyTrend", profitLossDAO.getYearlyTrend(companyId, routeId, startDate, endDate));
            request.setAttribute("lossBreakdown", profitLossDAO.getLossReasonBreakdown(companyId, routeId, startDate, endDate));
            request.setAttribute("companySummary", profitLossDAO.getCompanyProfitLossSummary(companyId, routeId, startDate, endDate));
            request.setAttribute("customerProfitability", profitLossDAO.getCustomerProfitability(companyId, routeId, startDate, endDate));
            
            request.getRequestDispatcher("/jsp/profit_loss_analytics.jsp").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
}
