package com.nlogistic.controller;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;
import com.nlogistic.model.PaymentTransaction;
import com.nlogistic.model.User;
import com.nlogistic.util.BarcodeUtil;
import com.nlogistic.util.PaymentTransactionManager;
import com.nlogistic.util.ShipmentBookingExecutor;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

@WebServlet({"/payment/initiate", "/payment/status", "/payment/pay-mock", "/payment/qr"})
public class PaymentGatewayServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String servletPath = request.getServletPath();

        if ("/payment/status".equals(servletPath)) {
            handleStatusCheck(request, response);
        } else if ("/payment/qr".equals(servletPath)) {
            handleQrStream(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String servletPath = request.getServletPath();

        if ("/payment/initiate".equals(servletPath)) {
            handleInitiate(request, response);
        } else if ("/payment/pay-mock".equals(servletPath)) {
            handlePayMock(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void handleInitiate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession(false);
            User user = (session != null) ? (User) session.getAttribute("user") : null;

            double finalPrice = Double.parseDouble(request.getParameter("finalPrice"));
            double invoiceTotal = Math.round(finalPrice * 1.18 * 100.0) / 100.0;

            Map<String, Object> bookingParams = new HashMap<>();
            bookingParams.put("containerId", request.getParameter("containerId"));
            bookingParams.put("cargoWeight", request.getParameter("cargoWeight"));
            bookingParams.put("cargoVolume", request.getParameter("cargoVolume"));
            bookingParams.put("cargoDesc", request.getParameter("cargoDesc"));
            bookingParams.put("finalPrice", finalPrice);
            bookingParams.put("origin", request.getParameter("origin"));
            bookingParams.put("destination", request.getParameter("destination"));
            bookingParams.put("vesselId", request.getParameter("vesselId"));
            bookingParams.put("cargoValue", request.getParameter("cargoValue"));

            Integer custId = null;
            if (user != null && user.getRoleId() == 5) {
                custId = com.nlogistic.util.RbacContext.customerId(request);
            } else if (request.getParameter("customerId") != null && !request.getParameter("customerId").trim().isEmpty()) {
                custId = Integer.parseInt(request.getParameter("customerId").trim());
            }
            if (custId == null && user != null) {
                custId = user.getUserId();
            }
            bookingParams.put("customerId", custId);
            bookingParams.put("userId", user != null ? user.getUserId() : 1);

            PaymentTransaction txn = PaymentTransactionManager.createTransaction(invoiceTotal, bookingParams);

            String lanIp = BarcodeUtil.getLocalNetworkIp();
            int port = request.getServerPort();
            String portStr = (port == 80 || port == 443) ? "" : (":" + port);
            String mobilePayUrl = request.getScheme() + "://" + lanIp + portStr + request.getContextPath() + "/pay-mobile?txn=" + txn.getTxnId();
            String qrUrl = request.getContextPath() + "/payment/qr?txn=" + txn.getTxnId();

            out.write(String.format("{\"success\":true,\"txnId\":\"%s\",\"amount\":%.2f,\"qrUrl\":\"%s\",\"mobilePayUrl\":\"%s\"}",
                    txn.getTxnId(), invoiceTotal, qrUrl, mobilePayUrl));

        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\":false,\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    private void handleStatusCheck(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String txnId = request.getParameter("txn");
        PaymentTransaction txn = PaymentTransactionManager.getTransaction(txnId);

        if (txn == null) {
            out.write("{\"status\":\"NOT_FOUND\"}");
            return;
        }

        out.write(String.format("{\"status\":\"%s\",\"shipmentId\":%d,\"invoiceId\":%d,\"method\":\"%s\"}",
                txn.getStatus().name(),
                txn.getGeneratedShipmentId(),
                txn.getGeneratedInvoiceId(),
                txn.getPaymentMethod() != null ? txn.getPaymentMethod() : ""));
    }

    private void handlePayMock(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String txnId = request.getParameter("txn");
        String method = request.getParameter("paymentMethod");
        if (method == null || method.trim().isEmpty()) {
            method = "UPI_QR";
        }

        PaymentTransaction txn = PaymentTransactionManager.getTransaction(txnId);
        if (txn == null) {
            out.write("{\"success\":false,\"error\":\"Transaction not found or expired.\"}");
            return;
        }

        if (txn.getStatus() == PaymentTransaction.Status.SUCCESS) {
            out.write(String.format("{\"success\":true,\"alreadyPaid\":true,\"shipmentId\":%d,\"invoiceId\":%d}",
                    txn.getGeneratedShipmentId(), txn.getGeneratedInvoiceId()));
            return;
        }

        // Execute booking atomically
        synchronized (txn) {
            if (txn.getStatus() == PaymentTransaction.Status.SUCCESS) {
                out.write(String.format("{\"success\":true,\"shipmentId\":%d,\"invoiceId\":%d}",
                        txn.getGeneratedShipmentId(), txn.getGeneratedInvoiceId()));
                return;
            }

            ShipmentBookingExecutor.BookingResult bResult = ShipmentBookingExecutor.executeBooking(
                    request, txn.getBookingParams(), method, txn.getTxnId()
            );

            if (bResult.success) {
                PaymentTransactionManager.markSuccess(txn.getTxnId(), method, bResult.shipmentId, bResult.invoiceId);
                out.write(String.format("{\"success\":true,\"shipmentId\":%d,\"invoiceId\":%d}",
                        bResult.shipmentId, bResult.invoiceId));
            } else {
                PaymentTransactionManager.markFailed(txn.getTxnId(), bResult.errorMessage);
                out.write(String.format("{\"success\":false,\"error\":\"%s\"}",
                        bResult.errorMessage != null ? bResult.errorMessage.replace("\"", "\\\"") : "Booking failed"));
            }
        }
    }

    private void handleQrStream(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String txnId = request.getParameter("txn");
        if (txnId == null || txnId.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing txn");
            return;
        }

        String lanIp = BarcodeUtil.getLocalNetworkIp();
        int port = request.getServerPort();
        String portStr = (port == 80 || port == 443) ? "" : (":" + port);
        String mobilePayUrl = request.getScheme() + "://" + lanIp + portStr + request.getContextPath() + "/pay-mobile?txn=" + txnId.trim();

        try {
            QRCodeWriter qrCodeWriter = new QRCodeWriter();
            Map<EncodeHintType, Object> hints = new HashMap<>();
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.H);
            hints.put(EncodeHintType.MARGIN, 1);

            BitMatrix bitMatrix = qrCodeWriter.encode(mobilePayUrl, BarcodeFormat.QR_CODE, 320, 320, hints);

            response.setContentType("image/png");
            response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
            MatrixToImageWriter.writeToStream(bitMatrix, "PNG", response.getOutputStream());
            response.getOutputStream().flush();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error rendering QR: " + e.getMessage());
        }
    }
}
