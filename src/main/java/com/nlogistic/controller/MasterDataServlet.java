package com.nlogistic.controller;

import com.nlogistic.dao.*;
import com.nlogistic.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/master-data/*")
public class MasterDataServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();
    private CompanyDAO companyDAO = new CompanyDAO();
    private CustomerDAO customerDAO = new CustomerDAO();
    private PortDAO portDAO = new PortDAO();
    private VesselDAO vesselDAO = new VesselDAO();
    private LossReasonDAO lossReasonDAO = new LossReasonDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        // Fetch all master data for the UI
        request.setAttribute("users", userDAO.getAllUsers());
        request.setAttribute("companies", companyDAO.getAllCompanies());
        request.setAttribute("customers", customerDAO.getAllCustomers());
        request.setAttribute("ports", portDAO.getAllPorts());
        request.setAttribute("vessels", vesselDAO.getAllVessels());
        request.setAttribute("lossReasons", lossReasonDAO.getAllLossReasons());
        
        request.getRequestDispatcher("/jsp/master_data.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        int reqUserId = currentUser.getUserId();

        try {
            if (pathInfo.equals("/port/add")) {
                portDAO.addPort(request.getParameter("name"), request.getParameter("code"), request.getParameter("country"), 
                    Double.parseDouble(request.getParameter("lat")), Double.parseDouble(request.getParameter("lng")));
            } else if (pathInfo.equals("/port/delete")) {
                portDAO.deletePort(Integer.parseInt(request.getParameter("id")), reqUserId);
            } else if (pathInfo.equals("/vessel/add")) {
                vesselDAO.addVessel(request.getParameter("name"), request.getParameter("imo"), Integer.parseInt(request.getParameter("capacity")));
            } else if (pathInfo.equals("/vessel/delete")) {
                vesselDAO.deleteVessel(Integer.parseInt(request.getParameter("id")), reqUserId);
            } else if (pathInfo.equals("/company/delete")) {
                companyDAO.deleteCompany(Integer.parseInt(request.getParameter("id")), reqUserId);
            } else if (pathInfo.equals("/customer/delete")) {
                customerDAO.deleteCustomer(Integer.parseInt(request.getParameter("id")), reqUserId);
            } else if (pathInfo.equals("/user/delete")) {
                userDAO.deleteUser(Integer.parseInt(request.getParameter("id")), reqUserId);
            } else if (pathInfo.equals("/lossreason/add")) {
                lossReasonDAO.addLossReason(request.getParameter("code"), request.getParameter("name"), request.getParameter("desc"));
            } else if (pathInfo.equals("/lossreason/delete")) {
                lossReasonDAO.deleteLossReason(Integer.parseInt(request.getParameter("id")), reqUserId);
            }
            response.sendRedirect(request.getContextPath() + "/master-data?success=true");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/master-data?error=true");
        }
    }
}