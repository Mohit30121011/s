package com.nlogistic.controller;

import com.nlogistic.dao.AnalyticsDAO;
import com.nlogistic.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/dashboard/executive")
public class ExecutiveDashboardServlet extends HttpServlet {
    private AnalyticsDAO analyticsDAO = new AnalyticsDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        Integer userId = user != null ? user.getUserId() : 1;
        Integer companyId = user != null ? user.getCompanyId() : null;
        
        String period = new SimpleDateFormat("yyyy-MM").format(new Date());

        // Force compute algorithms before fetching data (for demonstration purposes so dashboard is always fresh)
        analyticsDAO.computeAllAnalytics(period, userId);

        // Fetch Data
        DashboardSummary summary = analyticsDAO.getDashboardSummary(period, userId);
        List<AbcResult> abcResults = analyticsDAO.getAbcResults(period, userId);
        TurnoverResult turnover = analyticsDAO.getTurnoverResult(period, userId);
        List<LossReasonSummary> topLossReasons = analyticsDAO.getTopLossReasons(5, userId);
        ContainerUtilization utilization = analyticsDAO.getContainerUtilization(companyId != null ? companyId : 0, userId);
        List<StockValuation> stockValuations = analyticsDAO.getStockValuation(companyId != null ? companyId : 0, userId);
        List<CustomerProfitability> customerProfitabilities = analyticsDAO.getCustomerProfitability(userId);

        // Set Attributes
        request.setAttribute("summary", summary);
        request.setAttribute("abcResults", abcResults);
        request.setAttribute("turnover", turnover);
        request.setAttribute("topLossReasons", topLossReasons);
        request.setAttribute("utilization", utilization);
        request.setAttribute("stockValuations", stockValuations);
        request.setAttribute("customerProfitabilities", customerProfitabilities);
        
        List<ActiveShipment> activeShipments = analyticsDAO.getActiveShipments(companyId != null ? companyId : 0, userId);
        List<SalesTrendResult> salesTrends = analyticsDAO.getSalesTrends(period);
        request.setAttribute("activeShipments", activeShipments);
        request.setAttribute("salesTrends", salesTrends);

        request.getRequestDispatcher("/jsp/executive_dashboard.jsp").forward(request, response);
    }
}
