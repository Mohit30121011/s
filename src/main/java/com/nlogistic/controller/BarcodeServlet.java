package com.nlogistic.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.model.User;
import com.nlogistic.util.DBConnectionManager;

@WebServlet("/barcodes")
public class BarcodeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        int roleId = user.getRoleId();
        Integer scopeCompany = com.nlogistic.util.RbacContext.companyId(request);
        com.nlogistic.dao.BarcodeDAO barcodeDAO = new com.nlogistic.dao.BarcodeDAO();

        // AJAX endpoint to return JSON entity list for the modal dropdown
        if ("getEntities".equals(request.getParameter("action"))) {
            response.setContentType("application/json;charset=UTF-8");
            String reqType = request.getParameter("type");
            List<Map<String, Object>> entities = barcodeDAO.getAvailableEntitiesForType(reqType, roleId, scopeCompany);
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < entities.size(); i++) {
                Map<String, Object> item = entities.get(i);
                if (i > 0) json.append(",");
                String lbl = (String) item.get("label");
                String cleanLabel = lbl != null ? lbl.replace("\\", "\\\\").replace("\"", "\\\"") : "";
                json.append("{")
                    .append("\"id\":").append(item.get("id")).append(",")
                    .append("\"label\":\"").append(cleanLabel).append("\",")
                    .append("\"hasBarcode\":").append(item.get("hasBarcode")).append(",")
                    .append("\"barcodeValue\":\"").append(item.get("barcodeValue")).append("\"")
                    .append("}");
            }
            json.append("]");
            response.getWriter().write(json.toString());
            return;
        }

        List<Map<String, Object>> barcodeList = new ArrayList<>();

        // Library: search + category filter + pagination (FR8.1/8.2 — full catalog, not just recent 60)
        String search = request.getParameter("search");
        String category = request.getParameter("category");

        int page = 1;
        try {
            String p = request.getParameter("page");
            if (p != null && !p.isEmpty()) page = Integer.parseInt(p);
        } catch (NumberFormatException ignored) {}
        if (page < 1) page = 1;
        int pageSize = 20;

        int totalCount = barcodeDAO.countBarcodesScoped(search, category, roleId, scopeCompany);
        int totalPages = Math.max(1, (int) Math.ceil(totalCount / (double) pageSize));
        if (page > totalPages) page = totalPages;
        int offset = (page - 1) * pageSize;

        java.util.Map<Integer, String> usernameCache = new HashMap<>();
        for (com.nlogistic.model.BarcodeEntry b : barcodeDAO.searchBarcodesScoped(
                search, category, pageSize, offset, roleId, scopeCompany)) {
            Map<String, Object> row = new HashMap<>();
            row.put("barcodeId", b.getBarcodeId());
            row.put("barcodeValue", b.getBarcodeValue());
            row.put("barcodeType", b.getBarcodeType());
            row.put("entityType", b.getEntityType());
            row.put("entityId", b.getEntityId());
            row.put("imagePath", b.getImagePath());
            row.put("generatedAt", b.getGeneratedAt());
            barcodeList.add(row);
        }

        request.setAttribute("barcodeList", barcodeList);
        request.setAttribute("categoryCounts", barcodeDAO.getCategoryCountsScoped(roleId, scopeCompany));
        // FR8.5: the scan log had no viewer at all on this page - it was left behind
        // in the orphaned barcodes.jsp prototype.
        request.setAttribute("recentScans", barcodeDAO.getRecentScans(roleId, scopeCompany, 50));
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("selectedCategory", category != null ? category : "All");
        request.setAttribute("selectedSearch", search != null ? search : "");
        // Pre-load default entity list (Containers) for instantaneous zero-latency modal display
        request.setAttribute("defaultEntities", barcodeDAO.getAvailableEntitiesForType("Container", roleId, scopeCompany));
        request.getRequestDispatcher("/jsp/barcode-management.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        if ("delete".equals(request.getParameter("action"))) {
            int barcodeId = Integer.parseInt(request.getParameter("barcodeId"));
            com.nlogistic.dao.BarcodeDAO dao = new com.nlogistic.dao.BarcodeDAO();

            // This deleted any row by id. Operations staff are barred from deleting
            // records at all (CLAUDE.md 3.3.5), and nothing checked the tenant, so
            // one carrier's dock clerk could wipe another carrier's label and its
            // whole scan history. Deletion of a master record is Super Admin work;
            // a Company Admin may still retire a label of their own.
            int delRole = user.getRoleId();
            Integer delCompany = com.nlogistic.util.RbacContext.companyId(request);
            if (delRole != 1 && delRole != 2) {
                request.getSession().setAttribute("errorMessage",
                        "Only an administrator can delete a barcode.");
                response.sendRedirect(request.getContextPath() + "/barcodes");
                return;
            }
            if (!dao.canAccessBarcode(barcodeId, delRole, delCompany)) {
                request.getSession().setAttribute("errorMessage",
                        "That barcode belongs to another company.");
                response.sendRedirect(request.getContextPath() + "/barcodes");
                return;
            }
            boolean ok = dao.deleteBarcode(barcodeId);
            request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Barcode #" + barcodeId + " deleted." : "Failed to delete barcode #" + barcodeId + ".");
            String qs = request.getParameter("returnQs");
            response.sendRedirect(request.getContextPath() + "/barcodes" + (qs != null && !qs.isEmpty() ? "?" + qs : ""));
            return;
        }

        String entityType = request.getParameter("entityType"); // Container, Shipment, Stock, ComplianceDocument, Invoice, Claim
        int entityId = Integer.parseInt(request.getParameter("entityId"));
        String barcodeType = request.getParameter("barcodeType"); // Code128, QR

        com.nlogistic.dao.BarcodeDAO genDao = new com.nlogistic.dao.BarcodeDAO();
        int genRole = user.getRoleId();
        Integer genCompany = com.nlogistic.util.RbacContext.companyId(request);

        // FR8.6: a database trigger already refuses a second barcode for the same
        // entity, but it surfaced as a raw "Failed to generate barcode: ..." error.
        // Point the user at the label that already exists instead.
        com.nlogistic.model.BarcodeEntry existing = genDao.findByEntity(entityType, entityId);
        if (existing != null) {
            request.getSession().setAttribute("successMessage",
                    entityType + " #" + entityId + " already carries barcode " + existing.getBarcodeValue()
                    + ". Reprint that label rather than issuing a second one.");
            response.sendRedirect(request.getContextPath() + "/barcodes?search=" + existing.getBarcodeValue());
            return;
        }

        // FR8.1/FR8.2 — generate a unique barcode value plus a REAL scannable image on disk
        // (ZXing Code128/QR), with the QR content pointing to the direct scan-and-view URL.
        String barcodeValue = com.nlogistic.util.BarcodeUtil.buildBarcodeValue(entityType, entityId);
        String scanUrl = com.nlogistic.util.BarcodeUtil.buildScanUrl(request, barcodeValue);
        String imagePath = null;
        try {
            String realPath = request.getServletContext().getRealPath("");
            imagePath = com.nlogistic.util.BarcodeUtil.generateImage(realPath, barcodeType, barcodeValue, scanUrl);
        } catch (Exception imgEx) {
            imgEx.printStackTrace();
        }

        String sql = "INSERT INTO barcode_entries (barcode_value, barcode_type, entity_type, entity_id, generated_by, image_path) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, barcodeValue);
            ps.setString(2, barcodeType);
            ps.setString(3, entityType);
            ps.setInt(4, entityId);
            ps.setInt(5, user.getUserId());
            ps.setString(6, imagePath);

            ps.executeUpdate();
            request.getSession().setAttribute("successMessage", "Barcode/QR Code successfully generated for " + entityType + " #" + entityId);

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Failed to generate barcode: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/barcodes");
    }
}
