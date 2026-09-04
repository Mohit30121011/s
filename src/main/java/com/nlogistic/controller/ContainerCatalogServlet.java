package com.nlogistic.controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.dao.ContainerDAO;
import com.nlogistic.dao.PortDAO;
import com.nlogistic.model.Container;

/**
 * FR3.1 & FR3.2: Container Master Catalog Listing
 */
@WebServlet("/containers")
public class ContainerCatalogServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ContainerDAO containerDAO = new ContainerDAO();
    private PortDAO portDAO = new PortDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // Pagination logic
        int page = 1;
        int recordsPerPage = 12; // 12 containers per page (nice grid of 3 or 4 columns)
        
        if (request.getParameter("page") != null) {
            try {
                page = Integer.parseInt(request.getParameter("page"));
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        String statusFilter = request.getParameter("status"); // 'Available', 'Allocated', etc.
        if (statusFilter == null) {
            statusFilter = "All";
        }
        
        int offset = (page - 1) * recordsPerPage;
        
        List<Container> containers = containerDAO.getContainers(statusFilter, recordsPerPage, offset);
        int totalRecords = containerDAO.getContainerCount(statusFilter);
        int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
        
        request.setAttribute("containers", containers);
        request.setAttribute("ports", portDAO.getAllPorts());
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("statusFilter", statusFilter);
        
        request.getRequestDispatcher("/jsp/containers.jsp").forward(request, response);
    }
}
