package com.nlogistic.controller;

import com.nlogistic.dao.ProfitLossDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/finance/*")
public class FinanceServlet extends HttpServlet {
    private ProfitLossDAO profitLossDAO;

    @Override
    public void init() {
        profitLossDAO = new ProfitLossDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if (pathInfo == null || pathInfo.equals("/")) {
            request.getRequestDispatcher("/jsp/profit_loss_analytics.jsp").forward(request, response);
        } else if (pathInfo.equals("/profit-loss")) {
            // Phase 3: Profit & Loss Analytics wired to live DB
            request.setAttribute("kpi", profitLossDAO.getOverallKPIs());
            request.setAttribute("monthlyTrend", profitLossDAO.getMonthlyTrend());
            request.setAttribute("lossBreakdown", profitLossDAO.getLossReasonBreakdown());
            request.setAttribute("customerProfitability", profitLossDAO.getCustomerProfitability());
            
            request.getRequestDispatcher("/jsp/profit_loss_analytics.jsp").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
}
