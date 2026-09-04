package com.nlogistic.controller;

import com.nlogistic.dao.ContainerDAO;
import com.nlogistic.dao.PortDAO;
import com.nlogistic.model.User;

import java.io.File;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/containers/*")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
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
            String type = request.getParameter("type");
            String size = request.getParameter("size");
            double tare = Double.parseDouble(request.getParameter("tareWeightKg"));
            double maxGross = Double.parseDouble(request.getParameter("maxGrossWeightKg"));
            double capKg = Double.parseDouble(request.getParameter("goodsCapacityKg"));
            double capCbm = Double.parseDouble(request.getParameter("goodsCapacityCbm"));
            String status = request.getParameter("status");
            int portId = Integer.parseInt(request.getParameter("portId"));

            String imageUrl = null;
            try {
                Part filePart = request.getPart("containerImageFile");
                if (filePart != null && filePart.getSize() > 0) {
                    String submittedName = new File(filePart.getSubmittedFileName()).getName();
                    String ext = "";
                    int dotIdx = submittedName.lastIndexOf('.');
                    if (dotIdx > 0) ext = submittedName.substring(dotIdx);
                    String fileName = "cont_" + System.currentTimeMillis() + ext;
                    String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "containers";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) uploadDir.mkdirs();
                    filePart.write(uploadPath + File.separator + fileName);
                    imageUrl = request.getContextPath() + "/uploads/containers/" + fileName;
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }

            boolean success = containerDAO.updateContainer(containerId, type, size, tare, maxGross, capKg, capCbm, status, portId, imageUrl);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/containers?success=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/containers?error=true");
            }
        } else if (pathInfo != null && pathInfo.equals("/add")) {
            String number = request.getParameter("containerNumber");
            String type = request.getParameter("type");
            String size = request.getParameter("size");
            String imageUrl = request.getParameter("imageUrl");

            // Handle file upload for container image
            try {
                Part filePart = request.getPart("containerImageFile");
                if (filePart != null && filePart.getSize() > 0) {
                    String submittedName = new File(filePart.getSubmittedFileName()).getName();
                    String ext = "";
                    int dotIdx = submittedName.lastIndexOf('.');
                    if (dotIdx > 0) {
                        ext = submittedName.substring(dotIdx);
                    }
                    String fileName = "cont_" + System.currentTimeMillis() + ext;
                    String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "containers";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) {
                        uploadDir.mkdirs();
                    }
                    filePart.write(uploadPath + File.separator + fileName);
                    imageUrl = request.getContextPath() + "/uploads/containers/" + fileName;
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }

            double tare = Double.parseDouble(request.getParameter("tareWeightKg"));
            double maxGross = Double.parseDouble(request.getParameter("maxGrossWeightKg"));
            double capKg = Double.parseDouble(request.getParameter("goodsCapacityKg"));
            double capCbm = Double.parseDouble(request.getParameter("goodsCapacityCbm"));
            String status = request.getParameter("status");
            if (status == null || status.trim().isEmpty()) {
                status = "Available";
            }
            int portId = Integer.parseInt(request.getParameter("portId"));

            boolean success = containerDAO.addContainer(number, type, size, imageUrl, tare, maxGross, capKg, capCbm, status, portId, currentUser.getCompanyId());
            response.sendRedirect(request.getContextPath() + "/containers?add=" + success);
        } else if (pathInfo != null && pathInfo.equals("/delete")) {
            containerDAO.deleteContainer(Integer.parseInt(request.getParameter("id")), currentUser.getUserId());
            response.sendRedirect(request.getContextPath() + "/containers");
        }
    }
}
