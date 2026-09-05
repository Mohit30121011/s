package com.nlogistic.util;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.EncodeHintType;

import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

/**
 * FR8.1 / FR8.2 / FR8.3 support: generates real, scannable Code128/QR barcode
 * images on disk (via ZXing) and builds the direct scan URL a QR code should
 * encode so a phone camera scan lands on the entity's detail page.
 */
public final class BarcodeUtil {

    private BarcodeUtil() {}

    /** Builds a short human-readable + unique barcode value, e.g. CON-101-3F9A1B. */
    public static String buildBarcodeValue(String entityType, int entityId) {
        String prefix = entityType.length() >= 3 ? entityType.substring(0, 3).toUpperCase() : entityType.toUpperCase();
        String hash = Long.toHexString(System.nanoTime()).toUpperCase();
        hash = hash.substring(Math.max(0, hash.length() - 6));
        return prefix + "-" + entityId + "-" + hash;
    }

    /**
     * Builds the absolute URL a QR scan should open: /barcode-pdf?value=...
     * This endpoint is PUBLIC (no login required) and streams a real PDF binary
     * directly to mobile browsers so the PDF opens natively without showing an HTML page or link.
     * If the server was accessed via localhost/127.0.0.1, it resolves the machine's LAN IP
     * so phones scanning the QR on the same Wi-Fi can directly reach the endpoint.
     */
    public static String buildScanUrl(HttpServletRequest request, String barcodeValue) {
        try {
            String scheme = request != null ? request.getScheme() : "http";
            String host = request != null ? request.getServerName() : null;
            int port = request != null ? request.getServerPort() : 8080;

            if (host == null || "localhost".equalsIgnoreCase(host) || "127.0.0.1".equals(host)) {
                host = getLocalNetworkIp();
            }

            StringBuilder sb = new StringBuilder();
            sb.append(scheme).append("://").append(host);
            if (!("http".equals(scheme) && port == 80) && !("https".equals(scheme) && port == 443)) {
                sb.append(":").append(port);
            }
            String contextPath = request != null ? request.getContextPath() : "/NLogistic";
            sb.append(contextPath).append("/barcode-pdf?value=")
              .append(URLEncoder.encode(barcodeValue, "UTF-8"));
            return sb.toString();
        } catch (Exception e) {
            String contextPath = request != null ? request.getContextPath() : "/NLogistic";
            return contextPath + "/barcode-pdf?value=" + barcodeValue;
        }
    }

    /** Helper to find the active LAN IPv4 address (e.g. 192.168.x.x) for phone access. */
    public static String getLocalNetworkIp() {
        try {
            java.util.Enumeration<java.net.NetworkInterface> interfaces = java.net.NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                java.net.NetworkInterface iface = interfaces.nextElement();
                if (iface.isLoopback() || !iface.isUp()) continue;
                java.util.Enumeration<java.net.InetAddress> addresses = iface.getInetAddresses();
                while (addresses.hasMoreElements()) {
                    java.net.InetAddress addr = addresses.nextElement();
                    if (addr instanceof java.net.Inet4Address && !addr.isLoopbackAddress() && !addr.isLinkLocalAddress()) {
                        String ip = addr.getHostAddress();
                        if (!ip.startsWith("127.")) {
                            return ip;
                        }
                    }
                }
            }
        } catch (Exception ignored) {}
        try {
            return java.net.InetAddress.getLocalHost().getHostAddress();
        } catch (Exception ignored) {}
        return "localhost";
    }

    /**
     * Generates a real Code128 or QR image and saves it under
     * &lt;webappRealPath&gt;/uploads/barcodes/&lt;barcodeValue&gt;.png
     * QR codes encode the full scan URL (so a camera scan opens the record directly);
     * Code128 encodes the raw barcode value (alphanumeric, scanner-gun friendly).
     * Returns the context-relative path to store in barcode_entries.image_path, e.g. /uploads/barcodes/xxx.png
     */
    public static String generateImage(String webappRealPath, String barcodeType, String barcodeValue, String scanUrl) throws Exception {
        BitMatrix matrix;
        String content = "QR".equalsIgnoreCase(barcodeType) ? scanUrl : barcodeValue;
        BarcodeFormat format = "QR".equalsIgnoreCase(barcodeType) ? BarcodeFormat.QR_CODE : BarcodeFormat.CODE_128;
        int width = "QR".equalsIgnoreCase(barcodeType) ? 320 : 400;
        int height = "QR".equalsIgnoreCase(barcodeType) ? 320 : 130;

        if ("QR".equalsIgnoreCase(barcodeType)) {
            Map<EncodeHintType, Object> hints = new HashMap<>();
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.H);
            hints.put(EncodeHintType.MARGIN, 1);
            matrix = new QRCodeWriter().encode(content, format, width, height, hints);
        } else {
            matrix = new MultiFormatWriter().encode(content, format, width, height);
        }

        File dir = new File(webappRealPath, "uploads" + File.separator + "barcodes");
        if (!dir.exists()) dir.mkdirs();
        String fileName = barcodeValue.replaceAll("[^A-Za-z0-9_-]", "_") + ".png";
        File outFile = new File(dir, fileName);
        MatrixToImageWriter.writeToPath(matrix, "PNG", outFile.toPath());
        return "/uploads/barcodes/" + fileName;
    }
}
