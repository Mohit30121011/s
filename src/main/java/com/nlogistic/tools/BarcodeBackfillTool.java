package com.nlogistic.tools;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import java.io.File;
import java.net.URLEncoder;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

/**
 * One-time standalone backfill (run outside Tomcat, not deployed as a servlet):
 * generates real ZXing QR barcodes for every pre-existing container / shipment /
 * stock / compliance document / invoice / claim record created before the
 * auto-generation hooks were added to the live creation servlets (FR8.1 gap fix).
 *
 * Usage: java -cp "<zxing jars>;mysql-connector.jar;." com.nlogistic.tools.BarcodeBackfillTool <webappRealPath> <baseUrl>
 */
public class BarcodeBackfillTool {

    public static void main(String[] args) throws Exception {
        String webappRealPath = args.length > 0 ? args[0] : "D:/NLogistic/.metadata/.plugins/org.eclipse.wst.server.core/tmp0/wtpwebapps/NLogistic";
        String baseUrl = args.length > 1 ? args[1] : "http://localhost:8080/NLogistic";
        String generatedBy = args.length > 2 ? args[2] : "1"; // superadmin user_id

        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nlogistic_db?useSSL=false&serverTimezone=UTC", "root", "")) {
            int total = 0;
            total += backfill(conn, "Container", "SELECT container_id AS id FROM containers c WHERE NOT EXISTS (SELECT 1 FROM barcode_entries b WHERE b.entity_type='Container' AND b.entity_id=c.container_id)", webappRealPath, baseUrl, Integer.parseInt(generatedBy));
            total += backfill(conn, "Shipment", "SELECT shipment_id AS id FROM shipment s WHERE NOT EXISTS (SELECT 1 FROM barcode_entries b WHERE b.entity_type='Shipment' AND b.entity_id=s.shipment_id)", webappRealPath, baseUrl, Integer.parseInt(generatedBy));
            total += backfill(conn, "Stock", "SELECT stock_id AS id FROM stock s WHERE NOT EXISTS (SELECT 1 FROM barcode_entries b WHERE b.entity_type='Stock' AND b.entity_id=s.stock_id)", webappRealPath, baseUrl, Integer.parseInt(generatedBy));
            total += backfill(conn, "ComplianceDocument", "SELECT doc_id AS id FROM compliance_documents d WHERE NOT EXISTS (SELECT 1 FROM barcode_entries b WHERE b.entity_type='ComplianceDocument' AND b.entity_id=d.doc_id)", webappRealPath, baseUrl, Integer.parseInt(generatedBy));
            total += backfill(conn, "Invoice", "SELECT invoice_id AS id FROM billing_invoices i WHERE NOT EXISTS (SELECT 1 FROM barcode_entries b WHERE b.entity_type='Invoice' AND b.entity_id=i.invoice_id)", webappRealPath, baseUrl, Integer.parseInt(generatedBy));
            total += backfill(conn, "Claim", "SELECT claim_id AS id FROM claims c WHERE NOT EXISTS (SELECT 1 FROM barcode_entries b WHERE b.entity_type='Claim' AND b.entity_id=c.claim_id)", webappRealPath, baseUrl, Integer.parseInt(generatedBy));
            System.out.println("TOTAL BACKFILLED: " + total);
        }
    }

    private static int backfill(Connection conn, String entityType, String selectSql, String webappRealPath, String baseUrl, int generatedBy) {
        int count = 0;
        try (PreparedStatement ps = conn.prepareStatement(selectSql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int id = rs.getInt("id");
                try {
                    String hash = Long.toHexString(System.nanoTime()).toUpperCase();
                    hash = hash.substring(Math.max(0, hash.length() - 6));
                    String prefix = entityType.length() >= 3 ? entityType.substring(0, 3).toUpperCase() : entityType.toUpperCase();
                    String barcodeValue = prefix + "-" + id + "-" + hash;
                    String scanUrl = baseUrl + "/scan-barcode?value=" + URLEncoder.encode(barcodeValue, "UTF-8");

                    Map<EncodeHintType, Object> hints = new HashMap<>();
                    hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.H);
                    hints.put(EncodeHintType.MARGIN, 1);
                    BitMatrix matrix = new QRCodeWriter().encode(scanUrl, BarcodeFormat.QR_CODE, 320, 320, hints);

                    File dir = new File(webappRealPath, "uploads" + File.separator + "barcodes");
                    if (!dir.exists()) dir.mkdirs();
                    String fileName = barcodeValue.replaceAll("[^A-Za-z0-9_-]", "_") + ".png";
                    File outFile = new File(dir, fileName);
                    MatrixToImageWriter.writeToPath(matrix, "PNG", outFile.toPath());
                    String imagePath = "/uploads/barcodes/" + fileName;

                    try (CallableStatement cs = conn.prepareCall("{CALL generate_barcode(?, ?, ?, ?, ?, ?)}")) {
                        cs.setString(1, barcodeValue);
                        cs.setString(2, "QR");
                        cs.setString(3, entityType);
                        cs.setInt(4, id);
                        cs.setString(5, imagePath);
                        cs.setInt(6, generatedBy);
                        cs.execute();
                    }
                    count++;
                } catch (Exception rowEx) {
                    System.err.println("  Failed " + entityType + " #" + id + ": " + rowEx.getMessage());
                }
                // Ensure timestamp/nano uniqueness across a tight loop
                Thread.sleep(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println(entityType + ": " + count + " barcodes generated.");
        return count;
    }
}
