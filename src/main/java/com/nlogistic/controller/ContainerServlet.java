package com.nlogistic.controller;

import com.nlogistic.dao.ContainerDAO;
import com.nlogistic.dao.PortDAO;
import com.nlogistic.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/containers/*")
public class ContainerServlet extends HttpServlet {

    private ContainerDAO containerDAO = new ContainerDAO();
    private PortDAO portDAO = new PortDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("containers", containerDAO.getAllContainers());
        request.setAttribute("ports", portDAO.getAllPorts());
        request.getRequestDispatcher("/jsp/containers.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (pathInfo != null && pathInfo.equals("/update")) {
            int containerId = Integer.parseInt(request.getParameter("containerId"));
            String status = request.getParameter("status");
            int portId = Integer.parseInt(request.getParameter("portId"));
            
            boolean success = containerDAO.updateContainerStatus(containerId, status, portId);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/containers?success=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/containers?error=true");
            }
        } else if (pathInfo != null && pathInfo.equals("/delete")) {
containerDAO.deleteContainer(Integer.parseInt(request.getParameter("id")), currentUser.getUserId());
            response.sendRedirect(request.getContextPath() + "/containers");
        }
    }
}
