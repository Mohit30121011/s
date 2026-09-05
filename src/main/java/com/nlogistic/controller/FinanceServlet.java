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
            
            // Tenant isolation: only a Super Admin may choose which company to view.
            // Everyone else is pinned to their own company regardless of the URL.
            int plRole = com.nlogistic.util.RbacContext.roleId(request);
            Integer companyId;
            if (plRole == com.nlogistic.util.RbacContext.SUPER_ADMIN) {
                companyId = null;
                String req = request.getParameter("companyId");
                if (req != null && !req.isEmpty()) {
                    try { companyId = Integer.parseInt(req); } catch (NumberFormatException ignored) {}
                }
            } else {
                companyId = com.nlogistic.util.RbacContext.companyId(request);
            }
            request.setAttribute("companyFilterLocked", plRole != com.nlogistic.util.RbacContext.SUPER_ADMIN);
            
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

            // Only a Super Admin needs the full company list; others would just be
            // reading a directory of other tenants.
            if (plRole == com.nlogistic.util.RbacContext.SUPER_ADMIN) {
                request.setAttribute("companies", companyDAO.getAllCompanies());
            } else {
                com.nlogistic.model.Company own = (companyId != null) ? companyDAO.getCompanyById(companyId) : null;
                request.setAttribute("companies", own != null
                        ? java.util.Collections.singletonList(own)
                        : java.util.Collections.emptyList());
            }
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
            // IDOR guard: the drilldown exposes full cost structure, so verify the
            // caller owns this shipment before loading it. Previously any id worked,
            // and a missing shipment silently fell back to shipment #1.
            int ddRole = com.nlogistic.util.RbacContext.roleId(request);
            if (!new com.nlogistic.dao.ShipmentDAO().canAccessShipment(shipmentId, ddRole,
                    com.nlogistic.util.RbacContext.companyId(request),
                    com.nlogistic.util.RbacContext.customerId(request))) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Access Denied: this shipment does not belong to your company.");
                return;
            }
            com.nlogistic.model.ShipmentDrilldown sd = profitLossDAO.getShipmentDrilldownDetails(shipmentId);
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