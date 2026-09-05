package com.nlogistic.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.dao.ComplianceDAO;
import com.nlogistic.dao.ShipmentDAO;
import com.nlogistic.model.ComplianceDocument;
import com.nlogistic.model.User;
import com.nlogistic.util.RbacContext;

/**
 * FR5.1 / FR5.2 - compliance document viewer.
 *
 * doc-viewer.jsp used to load the document itself in a scriptlet, which meant the
 * view carried the ownership check and the role logic (SRS 10.2 forbids scriptlets,
 * and a view is the wrong place for an authorisation decision).
 */
@WebServlet("/compliance-document")
public class DocumentViewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ComplianceDAO complianceDAO = new ComplianceDAO();
    private ShipmentDAO shipmentDAO = new ShipmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = RbacContext.user(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int docId = 0;
        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.trim().isEmpty()) {
            try { docId = Integer.parseInt(idParam.trim()); } catch (NumberFormatException ignored) {}
        }

        ComplianceDocument doc = (docId > 0) ? complianceDAO.getDocumentById(docId) : null;

        // Never render a document belonging to another tenant or customer.
        if (doc != null && user.getRoleId() != 1) {
            Integer company = (user.getRoleId() == 5) ? null : RbacContext.companyId(request);
            Integer customer = RbacContext.customerId(request);
            if (!shipmentDAO.canAccessShipment(doc.getShipmentId(), user.getRoleId(), company, customer)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Access Denied: this document does not belong to your account.");
                return;
            }
        }

        // FR5.2: approving or rejecting is an Admin + Operations decision.
        request.setAttribute("canReview", user.getRoleId() <= 3);
        request.setAttribute("doc", doc);
        request.getRequestDispatcher("/jsp/doc-viewer.jsp").forward(request, response);
    }
}
