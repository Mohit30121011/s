package com.nlogistic.controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.dao.CompanyDAO;
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
    private CompanyDAO companyDAO = new CompanyDAO();

    /** The sizes offered by the "cards per page" selector. */
    private static final java.util.List<Integer> PAGE_SIZES = java.util.Arrays.asList(12, 24, 48, 96);

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // The selector in the view offered 12/24/48/96 but this servlet never read
        // it, so every page was 12 rows no matter what was chosen.
        int recordsPerPage = 12;
        try {
            int requested = Integer.parseInt(request.getParameter("pageSize"));
            if (PAGE_SIZES.contains(requested)) recordsPerPage = requested;
        } catch (Exception ignored) {}

        int page = 1;
        try { page = Math.max(1, Integer.parseInt(request.getParameter("page"))); } catch (Exception ignored) {}

        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.trim().isEmpty()) statusFilter = "All";
        String typeFilter = request.getParameter("type");
        if (typeFilter == null || typeFilter.trim().isEmpty()) typeFilter = "All";
        String search = request.getParameter("search");

        // FR3.1: the catalog is where the fleet leak actually surfaced - /containers
        // is served by THIS servlet, and it queried every company's assets.
        Integer fleetScope = com.nlogistic.dao.ContainerDAO.fleetScopeFor(
                com.nlogistic.util.RbacContext.roleId(request),
                com.nlogistic.util.RbacContext.companyId(request));

        int totalRecords = containerDAO.countCatalog(statusFilter, typeFilter, search, fleetScope);
        int totalPages = Math.max(1, (int) Math.ceil((double) totalRecords / recordsPerPage));
        if (page > totalPages) page = totalPages;
        int offset = (page - 1) * recordsPerPage;

        List<Container> containers = containerDAO.getCatalogPage(
                statusFilter, typeFilter, search, recordsPerPage, offset, fleetScope);

        request.setAttribute("containers", containers);
        request.setAttribute("ports", portDAO.getAllPorts());
        request.setAttribute("companies", companyDAO.getAllCompanies());
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("pageSize", recordsPerPage);
        request.setAttribute("pageSizes", PAGE_SIZES);
        request.setAttribute("rangeStart", totalRecords == 0 ? 0 : offset + 1);
        request.setAttribute("rangeEnd", Math.min(offset + recordsPerPage, totalRecords));
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("typeFilter", typeFilter);
        request.setAttribute("searchTerm", search != null ? search : "");

        request.getRequestDispatcher("/jsp/containers.jsp").forward(request, response);
    }
}
