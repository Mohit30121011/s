package com.nlogistic.controller;

import com.nlogistic.dao.AnalyticsDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/analytics")
public class AnalyticsServlet extends HttpServlet {
    
    private AnalyticsDAO analyticsDAO = new AnalyticsDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<AnalyticsDAO.MonthlyProfit> monthlyData = analyticsDAO.getMonthlyProfitLoss();
        List<AnalyticsDAO.LossReasonStat> lossData = analyticsDAO.getLossReasonBreakdown();

        // Manual JSON construction to avoid external JAR dependencies
        StringBuilder months = new StringBuilder("[");
        StringBuilder revenues = new StringBuilder("[");
        StringBuilder costs = new StringBuilder("[");
        
        for (int i = 0; i < monthlyData.size(); i++) {
            AnalyticsDAO.MonthlyProfit mp = monthlyData.get(i);
            months.append("\"").append(mp.month).append("\"");
            revenues.append(mp.revenue);
            costs.append(mp.cost);
            if (i < monthlyData.size() - 1) {
                months.append(","); revenues.append(","); costs.append(",");
            }
        }
        months.append("]"); revenues.append("]"); costs.append("]");

        StringBuilder reasonLabels = new StringBuilder("[");
        StringBuilder reasonData = new StringBuilder("[");
        for (int i = 0; i < lossData.size(); i++) {
            AnalyticsDAO.LossReasonStat lr = lossData.get(i);
            reasonLabels.append("\"").append(lr.reasonName).append("\"");
            reasonData.append(lr.totalLoss);
            if (i < lossData.size() - 1) {
                reasonLabels.append(","); reasonData.append(",");
            }
        }
        reasonLabels.append("]"); reasonData.append("]");

        request.setAttribute("jsonMonths", months.toString());
        request.setAttribute("jsonRevenues", revenues.toString());
        request.setAttribute("jsonCosts", costs.toString());
        request.setAttribute("jsonReasonLabels", reasonLabels.toString());
        request.setAttribute("jsonReasonData", reasonData.toString());

        request.getRequestDispatcher("/jsp/analytics.jsp").forward(request, response);
    }
}
