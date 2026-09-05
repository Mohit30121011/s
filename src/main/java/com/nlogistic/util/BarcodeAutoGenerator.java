package com.nlogistic.util;

import com.nlogistic.dao.BarcodeDAO;

import javax.servlet.http.HttpServletRequest;

/**
 * FR8.1 — central hook called by every core-entity creation servlet
 * (Container, Shipment, Stock, ComplianceDocument, Invoice, Claim) right
 * after the entity is successfully persisted, so a real, scannable barcode
 * is generated for every record automatically instead of relying on a
 * manual "Generate Barcode" action.
 *
 * Failures here are logged and swallowed — barcode generation must never
 * block or roll back the entity creation it's attached to.
 */
public final class BarcodeAutoGenerator {

    private BarcodeAutoGenerator() {}

    public static void generateFor(HttpServletRequest request, String entityType, int entityId, int generatedBy) {
        try {
            String barcodeValue = BarcodeUtil.buildBarcodeValue(entityType, entityId);
            String scanUrl = BarcodeUtil.buildScanUrl(request, barcodeValue);
            String realPath = request.getServletContext().getRealPath("");
            String imagePath = BarcodeUtil.generateImage(realPath, "QR", barcodeValue, scanUrl);

            BarcodeDAO dao = new BarcodeDAO();
            dao.generateBarcode(entityType, entityId, generatedBy, "QR", barcodeValue, imagePath);
        } catch (Exception e) {
            System.err.println("[BarcodeAutoGenerator] Failed to auto-generate barcode for "
                    + entityType + " #" + entityId + ": " + e.getMessage());
            e.printStackTrace();
        }
    }
}
