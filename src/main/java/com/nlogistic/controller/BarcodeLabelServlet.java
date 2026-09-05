package com.nlogistic.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.dao.BarcodeDAO;
import com.nlogistic.model.BarcodeEntry;
import com.nlogistic.model.User;
import com.nlogistic.util.DBConnectionManager;
import com.nlogistic.util.RbacContext;

/**
 * FR8.4 — physical label printing.
 *
 * The only export available before was html2canvas, which screenshots the
 * dashboard card: a picture of a web page, at screen resolution, with the wrong
 * aspect ratio for any label stock. Nothing could be sent to the thermal
 * printers a dock actually runs.
 *
 * This produces true print layouts sized in inches:
 *   - 4" x 6" container placard (ISO code, tare / max gross / payload, ports)
 *   - 3" x 2" warehouse shelf tag (product, HSN, batch, expiry, bay)
 *   - 4" x 6" generic record label for shipments, invoices, claims and documents
 *   - an A4 batch sheet that tiles the labels of the current registry page
 *
 * Labels are tenant-scoped exactly like the registry: a caller can only print a
 * label for an entity they are already allowed to see.
 */
@WebServlet("/barcodes/label")
public class BarcodeLabelServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRoleId() > 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }
        int roleId = user.getRoleId();
        Integer companyId = RbacContext.companyId(request);
        BarcodeDAO dao = new BarcodeDAO();

        List<Map<String, Object>> labels = new ArrayList<>();
        boolean batch = "1".equals(request.getParameter("batch"));

        try (Connection conn = DBConnectionManager.getConnection()) {
            if (batch) {
                // Tile whatever the registry is currently showing, so "print this
                // page of labels" needs no second selection step.
                String search = request.getParameter("search");
                String category = request.getParameter("category");
                int page = 1, pageSize = 12;
                try { page = Math.max(1, Integer.parseInt(request.getParameter("page"))); } catch (Exception ignored) {}
                try { pageSize = Integer.parseInt(request.getParameter("pageSize")); } catch (Exception ignored) {}
                for (BarcodeEntry b : dao.searchBarcodesScoped(search, category, pageSize,
                        (page - 1) * pageSize, roleId, companyId)) {
                    Map<String, Object> label = buildLabel(conn, b);
                    if (label != null) labels.add(label);
                }
            } else {
                int barcodeId;
                try {
                    barcodeId = Integer.parseInt(request.getParameter("barcodeId"));
                } catch (Exception e) {
                    response.sendRedirect(request.getContextPath() + "/barcodes");
                    return;
                }
                if (!dao.canAccessBarcode(barcodeId, roleId, companyId)) {
                    request.getSession().setAttribute("errorMessage",
                            "That barcode belongs to another company.");
                    response.sendRedirect(request.getContextPath() + "/barcodes");
                    return;
                }
                BarcodeEntry b = loadBarcode(conn, barcodeId);
                if (b != null) {
                    Map<String, Object> label = buildLabel(conn, b);
                    if (label != null) labels.add(label);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("labels", labels);
        request.setAttribute("batchMode", batch);
        request.getRequestDispatcher("/jsp/barcode-labels.jsp").forward(request, response);
    }

    private BarcodeEntry loadBarcode(Connection conn, int barcodeId) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT * FROM barcode_entries WHERE barcode_id = ?")) {
            ps.setInt(1, barcodeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                BarcodeEntry b = new BarcodeEntry();
                b.setBarcodeId(rs.getInt("barcode_id"));
                b.setBarcodeValue(rs.getString("barcode_value"));
                b.setBarcodeType(rs.getString("barcode_type"));
                b.setEntityType(rs.getString("entity_type"));
                b.setEntityId(rs.getInt("entity_id"));
                b.setImagePath(rs.getString("image_path"));
                return b;
            }
        }
    }

    /**
     * Assemble one label. "format" tells the view which physical layout to use;
     * "rows" is the ordered set of fields printed under the heading.
     */
    private Map<String, Object> buildLabel(Connection conn, BarcodeEntry b) throws Exception {
        Map<String, Object> label = new LinkedHashMap<>();
        label.put("barcodeValue", b.getBarcodeValue());
        label.put("barcodeType", b.getBarcodeType());
        label.put("imagePath", b.getImagePath());
        label.put("entityType", b.getEntityType());
        label.put("entityId", b.getEntityId());

        Map<String, Object> rows = new LinkedHashMap<>();
        String type = b.getEntityType();

        if ("Container".equals(type)) {
            label.put("format", "placard");
            String sql = "SELECT c.*, p.port_name, co.company_name "
                       + "FROM containers c "
                       + "LEFT JOIN ports p ON p.port_id = c.current_port_id "
                       + "LEFT JOIN companies co ON co.company_id = c.owner_company_id "
                       + "WHERE c.container_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, b.getEntityId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return null;
                    label.put("heading", rs.getString("container_number"));
                    label.put("subheading", rs.getString("type") + " · " + rs.getString("size"));
                    label.put("owner", rs.getString("company_name"));
                    rows.put("Tare Weight", fmtKg(rs.getBigDecimal("tare_weight_kg")));
                    rows.put("Max Gross", fmtKg(rs.getBigDecimal("max_gross_weight_kg")));
                    rows.put("Payload", fmtKg(rs.getBigDecimal("goods_capacity_kg")));
                    rows.put("Capacity", rs.getBigDecimal("goods_capacity_cbm") + " CBM");
                    rows.put("Current Port", nn(rs.getString("port_name")));
                    rows.put("Status", nn(rs.getString("status")));
                }
            }

        } else if ("Stock".equals(type)) {
            label.put("format", "shelf");
            String sql = "SELECT st.*, p.product_name, p.category, p.hsn_code, p.unit_of_measure "
                       + "FROM stock st JOIN products p ON p.product_id = st.product_id "
                       + "WHERE st.stock_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, b.getEntityId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return null;
                    label.put("heading", rs.getString("product_name"));
                    label.put("subheading", "HSN " + nn(rs.getString("hsn_code")) + " · " + nn(rs.getString("category")));
                    rows.put("Bay / Shelf", nn(rs.getString("warehouse_location")));
                    rows.put("Batch", nn(rs.getString("batch_no")));
                    rows.put("Expiry", rs.getDate("expiry_date") != null ? String.valueOf(rs.getDate("expiry_date")) : "—");
                    rows.put("On Hand", rs.getBigDecimal("quantity_on_hand") + " " + nn(rs.getString("unit_of_measure")));
                }
            }

        } else if ("Shipment".equals(type)) {
            label.put("format", "record");
            String sql = "SELECT s.*, op.port_name AS origin_name, dp.port_name AS dest_name "
                       + "FROM shipment s "
                       + "LEFT JOIN ports op ON op.port_id = s.origin_port_id "
                       + "LEFT JOIN ports dp ON dp.port_id = s.destination_port_id "
                       + "WHERE s.shipment_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, b.getEntityId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return null;
                    label.put("heading", "SHP-" + rs.getInt("shipment_id"));
                    label.put("subheading", nn(rs.getString("origin_name")) + "  →  " + nn(rs.getString("dest_name")));
                    rows.put("Status", nn(rs.getString("status")));
                    rows.put("Cargo", nn(rs.getString("cargo_description")));
                    rows.put("Cargo Weight", fmtKg(rs.getBigDecimal("cargo_weight_kg")));
                    rows.put("Booked", rs.getDate("booking_date") != null ? String.valueOf(rs.getDate("booking_date")) : "—");
                }
            }

        } else {
            // Invoice / Claim / ComplianceDocument share the generic record label.
            label.put("format", "record");
            label.put("heading", type + " #" + b.getEntityId());
            label.put("subheading", "Scan to open the record");
            rows.put("Reference", b.getBarcodeValue());
        }

        label.put("rows", rows);
        return label;
    }

    private static String nn(String v) { return (v == null || v.trim().isEmpty()) ? "—" : v; }

    private static String fmtKg(java.math.BigDecimal v) {
        return v == null ? "—" : String.format("%,.0f kg", v);
    }
}
