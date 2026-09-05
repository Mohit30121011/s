package com.nlogistic.controller;

import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.lowagie.text.*;
import com.lowagie.text.pdf.*;
import com.lowagie.text.pdf.draw.LineSeparator;
import com.nlogistic.util.DBConnectionManager;

import java.awt.Color;

/**
 * FR8.3 — Real Data-Driven QR Barcode PDF Endpoint.
 *
 * Streams an authentic, comprehensive, audit-grade verification PDF directly
 * to mobile and desktop browsers on scan. Every QR code maps to its real database
 * entity (Container, Shipment, Stock, Invoice, Claim, ComplianceDocument, Company)
 * and outputs all relevant operational, technical, and relational records.
 */
@WebServlet("/barcode-pdf")
public class BarcodePdfServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Brand theme colours
    private static final Color COLOR_CONTAINER_BG  = new Color(13, 148, 136);  // Teal 600
    private static final Color COLOR_SHIPMENT_BG   = new Color(37, 99, 235);   // Blue 600
    private static final Color COLOR_STOCK_BG      = new Color(124, 58, 237);  // Purple 600
    private static final Color COLOR_INVOICE_BG    = new Color(217, 119, 6);   // Amber 600
    private static final Color COLOR_CLAIM_BG      = new Color(220, 38, 38);   // Red 600
    private static final Color COLOR_COMPLIANCE_BG = new Color(3, 105, 161);   // Sky 700
    private static final Color COLOR_COMPANY_BG    = new Color(79, 70, 229);   // Indigo 600
    private static final Color COLOR_DEFAULT_BG    = new Color(51, 65, 85);    // Slate 700

    private static final Color COLOR_WHITE       = Color.WHITE;
    private static final Color COLOR_LABEL       = new Color(100, 116, 139); // Slate 500
    private static final Color COLOR_VALUE       = new Color(15, 23, 42);    // Slate 900
    private static final Color COLOR_CARD_BG     = new Color(248, 250, 252); // Slate 50
    private static final Color COLOR_ALT_BG      = new Color(241, 245, 249); // Slate 100
    private static final Color COLOR_BORDER      = new Color(226, 232, 240); // Slate 200

    private static final DecimalFormat CURRENCY_FMT = new DecimalFormat("#,##0.00");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String value = request.getParameter("value");
        if (value == null || value.trim().isEmpty()) {
            sendError(response, "No barcode value provided.");
            return;
        }
        value = value.trim();

        // Strip full URL if a scanner gun pasted the whole link
        if (value.contains("value=")) {
            int idx = value.indexOf("value=");
            value = value.substring(idx + 6);
            int amp = value.indexOf('&');
            if (amp >= 0) value = value.substring(0, amp);
            try { value = java.net.URLDecoder.decode(value, "UTF-8"); } catch (Exception ignored) {}
        }
        value = value.replaceAll("[\\r\\n]", "").trim();

        try (Connection conn = DBConnectionManager.getConnection()) {
            // 1. Look up the barcode
            int    barcodeId  = -1;
            String entityType = null;
            int    entityId   = -1;
            String barcodeType = "QR";

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT barcode_id, entity_type, entity_id, barcode_type FROM barcode_entries WHERE barcode_value = ?")) {
                ps.setString(1, value);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        barcodeId   = rs.getInt("barcode_id");
                        entityType  = rs.getString("entity_type");
                        entityId    = rs.getInt("entity_id");
                        barcodeType = rs.getString("barcode_type");
                    }
                }
            }

            if (barcodeId == -1) {
                sendError(response, "Barcode record not found in system: " + value);
                return;
            }

            // 2. Fetch rich, complete database data for this specific entity
            EntityReportData reportData = fetchCompleteEntityData(conn, entityType, entityId, value, barcodeType);

            // 3. Log scan event in barcode_scan_log (FR8.5)
            String ua = request.getHeader("User-Agent");
            String device = (ua != null && ua.toLowerCase().matches(".*(mobile|android|iphone|ipad).*"))
                    ? "Mobile QR Camera Scan" : "QR Camera Scan";
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO barcode_scan_log (barcode_id, scanned_by, scan_location, module_context) VALUES (?, NULL, ?, ?)")) {
                ps.setInt(1, barcodeId);
                ps.setString(2, "Public Mobile Scan");
                ps.setString(3, device);
                ps.executeUpdate();
            }

            // 4. Stream real PDF binary with attachment disposition for mobile download
            String filename = entityType + "-" + entityId + "-Report.pdf";
            String mode = request.getParameter("mode");
            String disposition = "view".equalsIgnoreCase(mode) ? "inline" : "attachment";
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", disposition + "; filename=\"" + filename + "\"");
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

            generatePdfDocument(response.getOutputStream(), reportData);

        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, "System error while generating PDF: " + e.getMessage());
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PDF Document Rendering (iText)
    // ─────────────────────────────────────────────────────────────────────────

    private void generatePdfDocument(OutputStream out, EntityReportData data) throws Exception {
        // A5 portrait layout
        Rectangle pageSize = new Rectangle(PageSize.A5);
        Document doc = new Document(pageSize, 24, 24, 24, 24);
        PdfWriter.getInstance(doc, out);
        doc.open();

        Color headerColor = getHeaderColor(data.entityType);
        String scannedAt = new SimpleDateFormat("dd MMM yyyy, HH:mm:ss").format(new Date());

        // ── Top Header Banner ────────────────────────────────────────────────
        PdfPTable headerTable = new PdfPTable(1);
        headerTable.setWidthPercentage(100);

        PdfPCell topCell = new PdfPCell();
        topCell.setBackgroundColor(headerColor);
        topCell.setPadding(16);
        topCell.setBorder(Rectangle.NO_BORDER);

        Font brandFont = new Font(Font.HELVETICA, 10f, Font.BOLD, new Color(255, 255, 255, 210));
        Paragraph brand = new Paragraph("N LOGISTIC · ENTERPRISE SUPPLY CHAIN VERIFICATION", brandFont);
        topCell.addElement(brand);

        Font titleFont = new Font(Font.HELVETICA, 17f, Font.BOLD, COLOR_WHITE);
        Paragraph title = new Paragraph(data.title, titleFont);
        title.setSpacingBefore(4f);
        topCell.addElement(title);

        Font subFont = new Font(Font.HELVETICA, 9.5f, Font.NORMAL, new Color(255, 255, 255, 220));
        Paragraph subtitle = new Paragraph(data.subtitle, subFont);
        subtitle.setSpacingBefore(2f);
        topCell.addElement(subtitle);

        Font metaFont = new Font(Font.HELVETICA, 8f, Font.NORMAL, new Color(255, 255, 255, 180));
        Paragraph meta = new Paragraph("Verified: " + scannedAt + "  ·  Live DB Sync", metaFont);
        meta.setSpacingBefore(6f);
        topCell.addElement(meta);

        headerTable.addCell(topCell);
        doc.add(headerTable);

        // ── Barcode & Status Banner ──────────────────────────────────────────
        PdfPTable strip = new PdfPTable(2);
        strip.setWidthPercentage(100);
        strip.setWidths(new float[]{3f, 2f});
        strip.setSpacingBefore(10f);

        PdfPCell bcCell = new PdfPCell();
        bcCell.setBackgroundColor(COLOR_CARD_BG);
        bcCell.setPadding(10);
        bcCell.setBorderColor(COLOR_BORDER);
        bcCell.setBorderWidth(0.5f);

        Font bcLbl = new Font(Font.HELVETICA, 7.5f, Font.BOLD, COLOR_LABEL);
        Font bcVal = new Font(Font.COURIER, 11f, Font.BOLD, COLOR_VALUE);
        bcCell.addElement(new Paragraph("AUTHENTICATED BARCODE TOKEN", bcLbl));
        bcCell.addElement(new Paragraph(data.barcodeValue + " (" + data.barcodeType + ")", bcVal));
        strip.addCell(bcCell);

        PdfPCell statusCell = new PdfPCell();
        statusCell.setBackgroundColor(COLOR_CARD_BG);
        statusCell.setPadding(10);
        statusCell.setBorderColor(COLOR_BORDER);
        statusCell.setBorderWidth(0.5f);
        statusCell.setHorizontalAlignment(Element.ALIGN_RIGHT);

        Font stLbl = new Font(Font.HELVETICA, 7.5f, Font.BOLD, COLOR_LABEL);
        Color stColor = getStatusColor(data.status);
        Font stVal = new Font(Font.HELVETICA, 11f, Font.BOLD, stColor);
        statusCell.addElement(new Paragraph("CURRENT LIFECYCLE STATUS", stLbl));
        statusCell.addElement(new Paragraph(data.status != null ? data.status.toUpperCase() : "N/A", stVal));
        strip.addCell(statusCell);

        doc.add(strip);

        // ── Render Structured Sections ───────────────────────────────────────
        for (Section sec : data.sections) {
            Paragraph secTitle = new Paragraph(sec.title.toUpperCase(), new Font(Font.HELVETICA, 8.5f, Font.BOLD, headerColor));
            secTitle.setSpacingBefore(12f);
            secTitle.setSpacingAfter(4f);
            doc.add(secTitle);

            PdfPTable table = new PdfPTable(2);
            table.setWidthPercentage(100);
            table.setWidths(new float[]{1f, 1f});

            Font fLbl = new Font(Font.HELVETICA, 7.5f, Font.BOLD, COLOR_LABEL);
            Font fVal = new Font(Font.HELVETICA, 9.5f, Font.BOLD, COLOR_VALUE);

            int idx = 0;
            for (Map.Entry<String, String> entry : sec.fields.entrySet()) {
                String k = entry.getKey();
                String v = entry.getValue();
                if (v == null || v.trim().isEmpty()) v = "—";

                PdfPCell c = new PdfPCell();
                c.setPadding(7);
                c.setBorderColor(COLOR_BORDER);
                c.setBorderWidth(0.5f);
                c.setBackgroundColor((idx / 2) % 2 == 0 ? COLOR_CARD_BG : COLOR_WHITE);

                c.addElement(new Paragraph(k, fLbl));
                Paragraph valP = new Paragraph(v, fVal);
                valP.setSpacingBefore(2f);
                c.addElement(valP);
                table.addCell(c);
                idx++;
            }

            // Odd number of fields -> span last
            if (idx % 2 != 0) {
                PdfPCell empty = new PdfPCell();
                empty.setBorderColor(COLOR_BORDER);
                empty.setBorderWidth(0.5f);
                empty.setBackgroundColor((idx / 2) % 2 == 0 ? COLOR_CARD_BG : COLOR_WHITE);
                table.addCell(empty);
            }

            doc.add(table);
        }

        // ── Render Line Items (if Invoice has items) ─────────────────────────
        if (data.lineItems != null && !data.lineItems.isEmpty()) {
            Paragraph liTitle = new Paragraph("INVOICE BILLED ITEMS BREAKDOWN", new Font(Font.HELVETICA, 8.5f, Font.BOLD, headerColor));
            liTitle.setSpacingBefore(12f);
            liTitle.setSpacingAfter(4f);
            doc.add(liTitle);

            PdfPTable liTable = new PdfPTable(4);
            liTable.setWidthPercentage(100);
            liTable.setWidths(new float[]{4f, 1.5f, 2f, 2.5f});

            // Header
            String[] headers = {"Description", "Qty", "Unit Price", "Line Total"};
            for (String h : headers) {
                PdfPCell hc = new PdfPCell(new Phrase(h, new Font(Font.HELVETICA, 8f, Font.BOLD, COLOR_WHITE)));
                hc.setBackgroundColor(headerColor);
                hc.setPadding(6);
                hc.setBorder(Rectangle.NO_BORDER);
                liTable.addCell(hc);
            }

            // Rows
            Font rFont = new Font(Font.HELVETICA, 8.5f, Font.NORMAL, COLOR_VALUE);
            Font rBold = new Font(Font.HELVETICA, 8.5f, Font.BOLD, COLOR_VALUE);
            for (LineItem item : data.lineItems) {
                PdfPCell c1 = new PdfPCell(new Phrase(item.description, rFont));
                PdfPCell c2 = new PdfPCell(new Phrase(String.valueOf(item.quantity), rFont));
                PdfPCell c3 = new PdfPCell(new Phrase("$" + CURRENCY_FMT.format(item.unitPrice), rFont));
                PdfPCell c4 = new PdfPCell(new Phrase("$" + CURRENCY_FMT.format(item.lineTotal), rBold));

                c1.setPadding(5); c2.setPadding(5); c3.setPadding(5); c4.setPadding(5);
                c1.setBorderColor(COLOR_BORDER); c2.setBorderColor(COLOR_BORDER);
                c3.setBorderColor(COLOR_BORDER); c4.setBorderColor(COLOR_BORDER);
                c1.setBorderWidth(0.5f); c2.setBorderWidth(0.5f);
                c3.setBorderWidth(0.5f); c4.setBorderWidth(0.5f);

                liTable.addCell(c1);
                liTable.addCell(c2);
                liTable.addCell(c3);
                liTable.addCell(c4);
            }
            doc.add(liTable);
        }

        // ── Footer ───────────────────────────────────────────────────────────
        Paragraph footer = new Paragraph(
                "N Logistic Automated System  ·  Digital Supply Chain Chain-of-Custody  ·  Token: " + data.barcodeValue,
                new Font(Font.HELVETICA, 7.5f, Font.NORMAL, COLOR_LABEL));
        footer.setAlignment(Element.ALIGN_CENTER);
        footer.setSpacingBefore(16f);
        doc.add(footer);

        doc.close();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Database Data Retrieval Engine
    // ─────────────────────────────────────────────────────────────────────────

    private EntityReportData fetchCompleteEntityData(Connection conn, String entityType, int entityId,
                                                      String barcodeValue, String barcodeType) throws Exception {
        EntityReportData data = new EntityReportData();
        data.entityType   = entityType;
        data.entityId     = entityId;
        data.barcodeValue = barcodeValue;
        data.barcodeType  = barcodeType;

        switch (entityType) {
            case "Container": {
                data.title = "Container #" + entityId;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT c.*, p.port_name, p.port_code, p.country, comp.company_name, comp.license_no, comp.contact_email " +
                        "FROM containers c " +
                        "LEFT JOIN ports p ON c.current_port_id = p.port_id " +
                        "LEFT JOIN companies comp ON c.owner_company_id = comp.company_id " +
                        "WHERE c.container_id = ?")) {
                    ps.setInt(1, entityId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            data.subtitle = "ISO Intermodal Shipping Unit: " + rs.getString("container_number");
                            data.status = rs.getString("status");

                            Section s1 = new Section("Physical & Mechanical Specifications");
                            s1.fields.put("Container Number", rs.getString("container_number"));
                            s1.fields.put("Container Type", rs.getString("type"));
                            s1.fields.put("Container Size", rs.getString("size"));
                            s1.fields.put("Operational Status", rs.getString("status"));
                            s1.fields.put("Tare Weight (Empty)", safeNum(rs.getBigDecimal("tare_weight_kg")) + " KG");
                            s1.fields.put("Max Gross Weight (M.G.W.)", safeNum(rs.getBigDecimal("max_gross_weight_kg")) + " KG");
                            s1.fields.put("Payload Capacity (Weight)", safeNum(rs.getBigDecimal("goods_capacity_kg")) + " KG");
                            s1.fields.put("Payload Capacity (Volume)", safeNum(rs.getBigDecimal("goods_capacity_cbm")) + " CBM");
                            data.sections.add(s1);

                            Section s2 = new Section("Location & Fleet Management");
                            s2.fields.put("Current Port", rs.getString("port_name") + " (" + rs.getString("port_code") + ")");
                            s2.fields.put("Port Country", rs.getString("country"));
                            s2.fields.put("Fleet Owner / Carrier", rs.getString("company_name"));
                            s2.fields.put("Owner License No.", rs.getString("license_no"));
                            s2.fields.put("Owner Contact Email", rs.getString("contact_email"));
                            s2.fields.put("Container DB ID", "CON-" + entityId);
                            data.sections.add(s2);
                        }
                    }
                }

                // Check for active linked shipment
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT s.shipment_id, s.status, s.cargo_description, s.booking_date, " +
                        "op.port_name as orig, dp.port_name as dest, u.username as shipper " +
                        "FROM shipment s " +
                        "LEFT JOIN ports op ON s.origin_port_id = op.port_id " +
                        "LEFT JOIN ports dp ON s.destination_port_id = dp.port_id " +
                        "LEFT JOIN users u ON s.customer_id = u.user_id " +
                        "WHERE s.container_id = ? AND s.status NOT IN ('Delivered', 'Cancelled') " +
                        "ORDER BY s.shipment_id DESC LIMIT 1")) {
                    ps.setInt(1, entityId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            Section s3 = new Section("Active Bound Shipment Allocation");
                            s3.fields.put("Allocated Shipment", "SHP-" + rs.getInt("shipment_id"));
                            s3.fields.put("Shipment Status", rs.getString("status"));
                            s3.fields.put("Shipper / Customer", rs.getString("shipper"));
                            s3.fields.put("Cargo Description", rs.getString("cargo_description"));
                            s3.fields.put("Route", rs.getString("orig") + " → " + rs.getString("dest"));
                            s3.fields.put("Booking Date", fmtDate(rs.getDate("booking_date")));
                            data.sections.add(s3);
                        }
                    }
                }
                break;
            }

            case "Shipment": {
                data.title = "Shipment SHP-" + entityId;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT s.*, u.username as customer_name, u.email as customer_email, u.phone as customer_phone, " +
                        "c.container_number, c.type as container_type, c.size as container_size, " +
                        "v.vessel_name, v.imo_number, " +
                        "op.port_name as origin_name, op.port_code as origin_code, op.country as origin_country, " +
                        "dp.port_name as dest_name, dp.port_code as dest_code, dp.country as dest_country " +
                        "FROM shipment s " +
                        "LEFT JOIN users u ON s.customer_id = u.user_id " +
                        "LEFT JOIN containers c ON s.container_id = c.container_id " +
                        "LEFT JOIN vessels v ON s.vessel_id = v.vessel_id " +
                        "LEFT JOIN ports op ON s.origin_port_id = op.port_id " +
                        "LEFT JOIN ports dp ON s.destination_port_id = dp.port_id " +
                        "WHERE s.shipment_id = ?")) {
                    ps.setInt(1, entityId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            data.subtitle = "Global Freight Consignment: " + rs.getString("cargo_description");
                            data.status = rs.getString("status");

                            Section s1 = new Section("Cargo & Booking Details");
                            s1.fields.put("Shipment Tracking ID", "SHP-" + entityId);
                            s1.fields.put("Consignment Status", rs.getString("status"));
                            s1.fields.put("Cargo Description", rs.getString("cargo_description"));
                            s1.fields.put("Booking Date", fmtDate(rs.getDate("booking_date")));
                            s1.fields.put("Cargo Weight", safeNum(rs.getBigDecimal("cargo_weight_kg")) + " KG");
                            s1.fields.put("Cargo Volume", safeNum(rs.getBigDecimal("cargo_volume_cbm")) + " CBM");
                            s1.fields.put("Declared Cargo Value", "$" + safeMoney(rs.getBigDecimal("cargo_declared_value")));
                            data.sections.add(s1);

                            Section s2 = new Section("Shipper & Transit Allocation");
                            s2.fields.put("Customer / Shipper", rs.getString("customer_name"));
                            s2.fields.put("Customer Contact", rs.getString("customer_email"));
                            s2.fields.put("Allocated Container", rs.getString("container_number") != null ? rs.getString("container_number") + " (" + rs.getString("container_size") + ")" : "Pending Allocation");
                            s2.fields.put("Assigned Vessel", rs.getString("vessel_name") != null ? rs.getString("vessel_name") + " (IMO: " + rs.getString("imo_number") + ")" : "Pending Vessel");
                            s2.fields.put("Origin Port", rs.getString("origin_name") + " (" + rs.getString("origin_code") + ", " + rs.getString("origin_country") + ")");
                            s2.fields.put("Destination Port", rs.getString("dest_name") + " (" + rs.getString("dest_code") + ", " + rs.getString("dest_country") + ")");
                            data.sections.add(s2);

                            Section s3 = new Section("Freight & Commercial Charges");
                            BigDecimal fCost = rs.getBigDecimal("freight_cost");
                            BigDecimal iCost = rs.getBigDecimal("insurance_cost");
                            BigDecimal oCost = rs.getBigDecimal("other_charges");
                            BigDecimal tot = (fCost != null ? fCost : BigDecimal.ZERO)
                                    .add(iCost != null ? iCost : BigDecimal.ZERO)
                                    .add(oCost != null ? oCost : BigDecimal.ZERO);

                            s3.fields.put("Ocean Freight Cost", "$" + safeMoney(fCost));
                            s3.fields.put("Cargo Marine Insurance", "$" + safeMoney(iCost));
                            s3.fields.put("Terminal & Handling Fees", "$" + safeMoney(oCost));
                            s3.fields.put("Total Shipping Charges", "$" + safeMoney(tot));
                            data.sections.add(s3);
                        }
                    }
                }
                break;
            }

            case "Stock": {
                data.title = "Stock Inventory #" + entityId;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT st.*, p.product_name, p.category, p.hsn_code, p.unit_of_measure, p.unit_cost, p.unit_price, comp.company_name " +
                        "FROM stock st " +
                        "JOIN products p ON st.product_id = p.product_id " +
                        "LEFT JOIN companies comp ON st.company_id = comp.company_id " +
                        "WHERE st.stock_id = ?")) {
                    ps.setInt(1, entityId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            data.subtitle = "Warehouse Stock Batch: " + rs.getString("product_name");
                            data.status = "In Stock";

                            Section s1 = new Section("Product & Item Information");
                            s1.fields.put("Product Name", rs.getString("product_name"));
                            s1.fields.put("Category", rs.getString("category"));
                            s1.fields.put("HSN / Tariff Code", rs.getString("hsn_code"));
                            s1.fields.put("Unit of Measure", rs.getString("unit_of_measure"));
                            s1.fields.put("Batch / Lot Number", rs.getString("batch_no"));
                            s1.fields.put("Expiration Date", fmtDate(rs.getDate("expiry_date")));
                            data.sections.add(s1);

                            Section s2 = new Section("Warehouse & Valuation Summary");
                            BigDecimal qty = rs.getBigDecimal("quantity_on_hand");
                            BigDecimal uPrice = rs.getBigDecimal("unit_price");
                            BigDecimal uCost = rs.getBigDecimal("unit_cost");
                            BigDecimal totVal = (qty != null && uPrice != null) ? qty.multiply(uPrice) : BigDecimal.ZERO;

                            s2.fields.put("Warehouse Bin / Rack", rs.getString("warehouse_location"));
                            s2.fields.put("Quantity On Hand", safeNum(qty) + " " + rs.getString("unit_of_measure"));
                            s2.fields.put("Unit Cost", "$" + safeMoney(uCost));
                            s2.fields.put("Unit Selling Price", "$" + safeMoney(uPrice));
                            s2.fields.put("Total Stock Valuation", "$" + safeMoney(totVal));
                            s2.fields.put("Managing Company", rs.getString("company_name"));
                            s2.fields.put("Last Ledger Update", fmtDateTime(rs.getTimestamp("last_updated")));
                            data.sections.add(s2);
                        }
                    }
                }
                break;
            }

            case "Invoice": {
                data.title = "Commercial Invoice INV-" + entityId;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT inv.*, u.username as cust_name, u.email as cust_email, u.phone as cust_phone, " +
                        "s.cargo_description, s.status as ship_status " +
                        "FROM billing_invoices inv " +
                        "LEFT JOIN users u ON inv.customer_id = u.user_id " +
                        "LEFT JOIN shipment s ON inv.shipment_id = s.shipment_id " +
                        "WHERE inv.invoice_id = ?")) {
                    ps.setInt(1, entityId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            data.subtitle = "Official Billing Document for Customer: " + rs.getString("cust_name");
                            data.status = rs.getString("payment_status");

                            Section s1 = new Section("Invoice Metadata & Customer");
                            s1.fields.put("Invoice Number", "INV-" + entityId);
                            s1.fields.put("Payment Status", rs.getString("payment_status"));
                            s1.fields.put("Invoice Date", fmtDate(rs.getDate("invoice_date")));
                            s1.fields.put("Payment Due Date", fmtDate(rs.getDate("due_date")));
                            s1.fields.put("Billed Customer", rs.getString("cust_name"));
                            s1.fields.put("Customer Email", rs.getString("cust_email"));
                            s1.fields.put("Related Shipment", rs.getInt("shipment_id") > 0 ? "SHP-" + rs.getInt("shipment_id") + " (" + rs.getString("cargo_description") + ")" : "N/A");
                            data.sections.add(s1);

                            Section s2 = new Section("Financial Accounting Summary");
                            BigDecimal sub = rs.getBigDecimal("subtotal_amount");
                            BigDecimal tax = rs.getBigDecimal("tax_amount");
                            BigDecimal tot = rs.getBigDecimal("total_amount");
                            BigDecimal paid = rs.getBigDecimal("paid_amount");
                            BigDecimal bal = (tot != null ? tot : BigDecimal.ZERO).subtract(paid != null ? paid : BigDecimal.ZERO);

                            s2.fields.put("Subtotal Amount", "$" + safeMoney(sub));
                            s2.fields.put("Tax & Customs Duty", "$" + safeMoney(tax));
                            s2.fields.put("Total Grand Amount", "$" + safeMoney(tot));
                            s2.fields.put("Total Paid to Date", "$" + safeMoney(paid));
                            s2.fields.put("Outstanding Balance", "$" + safeMoney(bal));
                            data.sections.add(s2);
                        }
                    }
                }

                // Fetch line items
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT description, quantity, unit_price, line_total FROM invoice_line_items WHERE invoice_id = ?")) {
                    ps.setInt(1, entityId);
                    try (ResultSet rs = ps.executeQuery()) {
                        data.lineItems = new ArrayList<>();
                        while (rs.next()) {
                            LineItem li = new LineItem();
                            li.description = rs.getString("description");
                            li.quantity = rs.getBigDecimal("quantity");
                            li.unitPrice = rs.getBigDecimal("unit_price");
                            li.lineTotal = rs.getBigDecimal("line_total");
                            data.lineItems.add(li);
                        }
                    }
                }
                break;
            }

            case "Claim": {
                data.title = "Insurance & Damage Claim CLA-" + entityId;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT cl.*, u.username as claimant, u.email as claimant_email, " +
                        "s.cargo_description, c.container_number, p.product_name " +
                        "FROM claims cl " +
                        "LEFT JOIN users u ON cl.customer_id = u.user_id " +
                        "LEFT JOIN shipment s ON cl.shipment_id = s.shipment_id " +
                        "LEFT JOIN containers c ON cl.container_id = c.container_id " +
                        "LEFT JOIN products p ON cl.product_id = p.product_id " +
                        "WHERE cl.claim_id = ?")) {
                    ps.setInt(1, entityId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            data.subtitle = "Cargo Discrepancy & Loss Report: " + rs.getString("claim_type");
                            data.status = rs.getString("status");

                            Section s1 = new Section("Claim Overview & Incident");
                            s1.fields.put("Claim Reference", "CLA-" + entityId);
                            s1.fields.put("Claim Type", rs.getString("claim_type"));
                            s1.fields.put("Adjudication Status", rs.getString("status"));
                            s1.fields.put("Date of Incident", fmtDate(rs.getDate("incident_date")));
                            s1.fields.put("Filing Timestamp", fmtDateTime(rs.getTimestamp("filed_date")));
                            s1.fields.put("Claimant Name", rs.getString("claimant"));
                            s1.fields.put("Claimant Email", rs.getString("claimant_email"));
                            data.sections.add(s1);

                            Section s2 = new Section("Associated Assets & Financial Claim");
                            s2.fields.put("Related Shipment", rs.getInt("shipment_id") > 0 ? "SHP-" + rs.getInt("shipment_id") + " (" + rs.getString("cargo_description") + ")" : "N/A");
                            s2.fields.put("Related Container", rs.getString("container_number") != null ? rs.getString("container_number") : "N/A");
                            s2.fields.put("Affected Product", rs.getString("product_name") != null ? rs.getString("product_name") : "General Cargo");
                            s2.fields.put("Total Claimed Amount", "$" + safeMoney(rs.getBigDecimal("claimed_amount")));
                            s2.fields.put("Settled / Approved Amount", "$" + safeMoney(rs.getBigDecimal("approved_amount")));
                            s2.fields.put("Loss Description", rs.getString("description"));
                            data.sections.add(s2);
                        }
                    }
                }
                break;
            }

            case "ComplianceDocument": {
                data.title = "Compliance Document DOC-" + entityId;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT cd.*, s.cargo_description, u.username as uploader " +
                        "FROM compliance_documents cd " +
                        "LEFT JOIN shipment s ON cd.shipment_id = s.shipment_id " +
                        "LEFT JOIN users u ON cd.uploaded_by = u.user_id " +
                        "WHERE cd.doc_id = ?")) {
                    ps.setInt(1, entityId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            data.subtitle = "Government & Regulatory Clearance: " + rs.getString("doc_type");
                            data.status = rs.getString("status");

                            Section s1 = new Section("Regulatory Document Information");
                            s1.fields.put("Document Type", rs.getString("doc_type"));
                            s1.fields.put("Document / Permit No.", rs.getString("doc_number"));
                            s1.fields.put("Issuing Regulatory Body", rs.getString("issuing_authority"));
                            s1.fields.put("Compliance Status", rs.getString("status"));
                            s1.fields.put("Issue Date", fmtDate(rs.getDate("issue_date")));
                            s1.fields.put("Validity Expiration Date", fmtDate(rs.getDate("expiry_date")));
                            s1.fields.put("Associated Shipment", rs.getInt("shipment_id") > 0 ? "SHP-" + rs.getInt("shipment_id") + " (" + rs.getString("cargo_description") + ")" : "General Fleet");
                            s1.fields.put("Uploaded Officer", rs.getString("uploader"));
                            data.sections.add(s1);
                        }
                    }
                }
                break;
            }

            case "Company": {
                data.title = "Carrier Company COM-" + entityId;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT comp.*, " +
                        "(SELECT COUNT(*) FROM containers WHERE owner_company_id = comp.company_id) as fleet_count, " +
                        "(SELECT COUNT(*) FROM stock WHERE company_id = comp.company_id) as stock_count " +
                        "FROM companies comp WHERE comp.company_id = ?")) {
                    ps.setInt(1, entityId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            data.subtitle = "Registered Freight Carrier: " + rs.getString("company_name");
                            data.status = rs.getString("approval_status");

                            Section s1 = new Section("Corporate Profile & Registration");
                            s1.fields.put("Company Name", rs.getString("company_name"));
                            s1.fields.put("Maritime License No.", rs.getString("license_no"));
                            s1.fields.put("GST / Tax Identification", rs.getString("gst_no"));
                            s1.fields.put("Approval Status", rs.getString("approval_status"));
                            s1.fields.put("Official Email", rs.getString("contact_email"));
                            s1.fields.put("Contact Telephone", rs.getString("contact_phone"));
                            s1.fields.put("Headquarters Address", rs.getString("address"));
                            s1.fields.put("Registered Fleet Size", rs.getInt("fleet_count") + " Containers");
                            s1.fields.put("Active Stock Lines", rs.getInt("stock_count") + " Batches");
                            data.sections.add(s1);
                        }
                    }
                }
                break;
            }

            default: {
                data.title = entityType + " #" + entityId;
                data.subtitle = "N Logistic Enterprise Entity";
                data.status = "Active";
                Section s1 = new Section("Basic Record");
                s1.fields.put("Entity Type", entityType);
                s1.fields.put("Entity ID", String.valueOf(entityId));
                data.sections.add(s1);
                break;
            }
        }

        return data;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Colour & Styling Helpers
    // ─────────────────────────────────────────────────────────────────────────

    private Color getHeaderColor(String entityType) {
        if (entityType == null) return COLOR_DEFAULT_BG;
        switch (entityType) {
            case "Container":          return COLOR_CONTAINER_BG;
            case "Shipment":           return COLOR_SHIPMENT_BG;
            case "Stock":              return COLOR_STOCK_BG;
            case "Invoice":            return COLOR_INVOICE_BG;
            case "Claim":              return COLOR_CLAIM_BG;
            case "ComplianceDocument": return COLOR_COMPLIANCE_BG;
            case "Company":            return COLOR_COMPANY_BG;
            default:                   return COLOR_DEFAULT_BG;
        }
    }

    private Color getStatusColor(String status) {
        if (status == null) return COLOR_VALUE;
        String s = status.toUpperCase();
        if (s.contains("AVAILABLE") || s.contains("PAID") || s.contains("APPROVED") || s.contains("DELIVERED") || s.contains("IN STOCK")) {
            return new Color(5, 150, 105); // Green 600
        }
        if (s.contains("IN-TRANSIT") || s.contains("ALLOCATED") || s.contains("BOOKED") || s.contains("PENDING") || s.contains("REVIEW") || s.contains("PARTIAL")) {
            return new Color(217, 119, 6); // Amber 600
        }
        if (s.contains("OVERDUE") || s.contains("CANCELLED") || s.contains("REJECTED") || s.contains("DAMAGED") || s.contains("MAINTENANCE") || s.contains("LOSS")) {
            return new Color(220, 38, 38); // Red 600
        }
        return COLOR_VALUE;
    }

    private String safeNum(BigDecimal val) {
        if (val == null) return "0";
        return CURRENCY_FMT.format(val);
    }

    private String safeMoney(BigDecimal val) {
        if (val == null) return "0.00";
        return CURRENCY_FMT.format(val);
    }

    private String fmtDate(java.sql.Date d) {
        if (d == null) return "—";
        return new SimpleDateFormat("dd MMM yyyy").format(d);
    }

    private String fmtDateTime(java.sql.Timestamp t) {
        if (t == null) return "—";
        return new SimpleDateFormat("dd MMM yyyy, HH:mm").format(t);
    }

    private void sendError(HttpServletResponse response, String message) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().println("<!DOCTYPE html><html><head><title>N Logistic - Barcode Error</title></head>");
        response.getWriter().println("<body style='font-family:sans-serif;padding:30px;background:#f8fafc;color:#1e293b;'>");
        response.getWriter().println("<div style='max-width:500px;margin:auto;background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px -1px rgba(0,0,0,0.1);'>");
        response.getWriter().println("<h3 style='color:#dc2626;margin-top:0;'>⚠️ Barcode Error</h3>");
        response.getWriter().println("<p>" + message + "</p>");
        response.getWriter().println("</div></body></html>");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Internal Models
    // ─────────────────────────────────────────────────────────────────────────

    private static class EntityReportData {
        String entityType;
        int entityId;
        String barcodeValue;
        String barcodeType;
        String title;
        String subtitle;
        String status;
        java.util.List<Section> sections = new ArrayList<>();
        java.util.List<LineItem> lineItems = null;
    }

    private static class Section {
        String title;
        Map<String, String> fields = new LinkedHashMap<>();
        Section(String title) { this.title = title; }
    }

    private static class LineItem {
        String description;
        BigDecimal quantity;
        BigDecimal unitPrice;
        BigDecimal lineTotal;
    }
}
