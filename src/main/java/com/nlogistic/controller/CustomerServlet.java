package com.nlogistic.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.dao.CustomerDAO;
import com.nlogistic.model.Customer;
import com.nlogistic.model.User;

@WebServlet("/customers")
public class CustomerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CustomerDAO customerDAO = new CustomerDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        List<Customer> customers = customerDAO.getAllCustomers();
        request.setAttribute("customers", customers);
        request.getRequestDispatcher("/jsp/customers.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String action = request.getParameter("action");
        if ("add".equals(action)) {
            String name = request.getParameter("customerName");
            String address = request.getParameter("address");
            String creditLimitStr = request.getParameter("creditLimit");
            double creditLimit = 0.0;
            if (creditLimitStr != null && !creditLimitStr.trim().isEmpty()) {
                try {
                    creditLimit = Double.parseDouble(creditLimitStr);
                } catch (NumberFormatException e) {}
            }
            
            Customer c = new Customer();
            c.setUserId(user.getUserId()); // Link to current user or set a dummy
            c.setCustomerName(name);
            c.setAddress(address);
            c.setCreditLimit(creditLimit);
            c.setKycDocPath("");
            
            customerDAO.registerCustomer(c);
            request.getSession().setAttribute("successMessage", "Customer added successfully.");
        }
        
        response.sendRedirect(request.getContextPath() + "/customers");
    }
}

