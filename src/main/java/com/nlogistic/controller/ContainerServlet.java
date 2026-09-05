package com.nlogistic.controller;

import com.nlogistic.dao.CompanyDAO;
import com.nlogistic.dao.ContainerDAO;
import com.nlogistic.dao.PortDAO;
import com.nlogistic.model.User;

import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
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
    private CompanyDAO companyDAO = new CompanyDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // FR3.1: the fleet list was global, so every company could see (and act on)
        // every other company's containers.
        request.setAttribute("containers", containerDAO.getContainersForRole(
                com.nlogistic.util.RbacContext.roleId(request),
                com.nlogistic.util.RbacContext.companyId(request)));
        request.setAttribute("ports", portDAO.getAllPorts());
        request.setAttribute("companies", companyDAO.getAllCompanies());
        request.getRequestDispatcher("/jsp/containers.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (pathInfo != null && pathInfo.equals("/update")) {
            int containerId = Integer.parseInt(request.getParameter("containerId"));
            if (!mayMutateContainer(request, containerId)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Access Denied: this container belongs to another company.");
                return;
            }
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
            if (number == null || number.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/containers?error=empty_number");
                return;
            }
            number = number.trim().toUpperCase();

            // Prevent duplicate container numbers
            if (containerDAO.isContainerNumberTaken(number)) {
                response.sendRedirect(request.getContextPath() + "/containers?error=duplicate&number=" + URLEncoder.encode(number, "UTF-8"));
                return;
            }

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

            double tare = 3750.0;
            try { tare = Double.parseDouble(request.getParameter("tareWeightKg")); } catch (Exception ignored) {}
            double maxGross = 30480.0;
            try { maxGross = Double.parseDouble(request.getParameter("maxGrossWeightKg")); } catch (Exception ignored) {}
            double capKg = 26730.0;
            try { capKg = Double.parseDouble(request.getParameter("goodsCapacityKg")); } catch (Exception ignored) {}
            double capCbm = 67.7;
            try { capCbm = Double.parseDouble(request.getParameter("goodsCapacityCbm")); } catch (Exception ignored) {}

            String status = request.getParameter("status");
            if (status == null || status.trim().isEmpty()) {
                status = "Available";
            }
            int portId = 1;
            try { portId = Integer.parseInt(request.getParameter("portId")); } catch (Exception ignored) {}

            // Determine owning company
            int targetCompanyId = 0;
            String compIdParam = request.getParameter("companyId");
            if (compIdParam != null && !compIdParam.trim().isEmpty()) {
                try {
                    targetCompanyId = Integer.parseInt(compIdParam.trim());
                } catch (Exception ignored) {}
            }
            if (targetCompanyId <= 0 && currentUser != null) {
                targetCompanyId = currentUser.getCompanyId();
            }
            if (targetCompanyId <= 0) {
                targetCompanyId = 1; // Default to standard fleet company 1
            }

            int newContainerId = containerDAO.addContainer(number, type, size, imageUrl, tare, maxGross, capKg, capCbm, status, portId, targetCompanyId);
            boolean success = (newContainerId != -1);
            if (success) {
                // FR8.1: auto-generate a barcode for every newly created container
                try {
                    com.nlogistic.util.BarcodeAutoGenerator.generateFor(request, "Container", newContainerId, currentUser != null ? currentUser.getUserId() : 1);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
                response.sendRedirect(request.getContextPath() + "/containers?add=true&newId=" + newContainerId + "&number=" + URLEncoder.encode(number, "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/containers?add=false");
            }
        } else if (pathInfo != null && pathInfo.equals("/delete")) {
            int delContainerId = Integer.parseInt(request.getParameter("id"));
            if (!mayMutateContainer(request, delContainerId)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Access Denied: this container belongs to another company.");
                return;
            }
            containerDAO.deleteContainer(delContainerId, currentUser.getUserId());
            response.sendRedirect(request.getContextPath() + "/containers");
        }
    }

    /**
     * True when the caller may edit or delete this container: Super Admin always,
     * company staff only for assets their own company owns.
     */
    private boolean mayMutateContainer(HttpServletRequest request, int containerId) {
        int role = com.nlogistic.util.RbacContext.roleId(request);
        if (role == 1) return true;
        if (role > 3) return false; // Finance and Customers never mutate the fleet
        Integer company = com.nlogistic.util.RbacContext.companyId(request);
        return company != null && containerDAO.isOwnedBy(containerId, company);
    }
}
