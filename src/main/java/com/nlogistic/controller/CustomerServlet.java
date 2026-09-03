package com.nlogistic.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.dao.CustomerDAO;
import com.nlogistic.dao.UserDAO;
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
            
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String kycDocPath = request.getParameter("kycDocPath");
            
            // 1. Create User account for Customer (Role ID = 5)
            UserDAO userDAO = new UserDAO();
            // Using customerName as username, or email prefix
            String username = email.split("@")[0] + "_" + System.currentTimeMillis() % 1000;
            userDAO.registerUser(username, email, password, "", 5, null, "Active");
            
            // 2. Fetch the newly created User to get user_id
            User newUser = userDAO.getUserByUsername(username);
            
            if (newUser != null) {
                // 3. Create Customer profile linked to the new user
                Customer c = new Customer();
                c.setUserId(newUser.getUserId());
                c.setCustomerName(name);
                c.setAddress(address);
                c.setCreditLimit(creditLimit);
                c.setKycDocPath(kycDocPath != null ? kycDocPath : "");
                
                customerDAO.registerCustomer(c);
            }
            request.getSession().setAttribute("successMessage", "Customer added successfully.");
        }
        
        response.sendRedirect(request.getContextPath() + "/customers");
    }
}

