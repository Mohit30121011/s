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
            response.sendRedirect(request.getContextPath() + "/finance/profit-loss");
            return;
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
        } else if (pathInfo.equals("/shipment-drilldown")) {
            String idParam = request.getParameter("id");
            int shipmentId = 1;
            if (idParam != null && !idParam.isEmpty()) {
                try {
                    if (idParam.startsWith("SHP-")) {
                        shipmentId = Integer.parseInt(idParam.substring(4));
                    } else {
                        shipmentId = Integer.parseInt(idParam);
                    }
                } catch (NumberFormatException e) {
                    shipmentId = 1;
                }
            }
            com.nlogistic.model.ShipmentDrilldown sd = profitLossDAO.getShipmentDrilldownDetails(shipmentId);
            if (sd == null && shipmentId != 1) {
                sd = profitLossDAO.getShipmentDrilldownDetails(1);
            }
            request.setAttribute("drilldown", sd);
            request.setAttribute("allLossReasons", profitLossDAO.getAllLossReasons());
            request.getRequestDispatcher("/jsp/shipment_drilldown.jsp").forward(request, response);
            return;
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo != null && pathInfo.equals("/shipment-drilldown/save")) {
            String shipmentIdStr = request.getParameter("shipmentId");
            String[] reasonIds = request.getParameterValues("reasonIds");
            
            if (shipmentIdStr != null && !shipmentIdStr.isEmpty()) {
                try {
                    int shipmentId = Integer.parseInt(shipmentIdStr);
                    profitLossDAO.saveLossReasons(shipmentId, reasonIds);
                    response.sendRedirect(request.getContextPath() + "/finance/shipment-drilldown?id=" + shipmentId);
                    return;
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            response.sendRedirect(request.getContextPath() + "/finance/profit-loss");
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
}