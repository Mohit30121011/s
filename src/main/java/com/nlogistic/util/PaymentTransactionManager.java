package com.nlogistic.util;

import com.nlogistic.model.PaymentTransaction;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * In-memory thread-safe manager for mock payment transactions.
 * Enables real-time cross-device synchronization between mobile QR scanner and desktop browser.
 */
public class PaymentTransactionManager {

    private static final Map<String, PaymentTransaction> TRANSACTIONS = new ConcurrentHashMap<>();

    private PaymentTransactionManager() {}

    /**
     * Creates and registers a new pending payment transaction.
     */
    public static PaymentTransaction createTransaction(double amount, Map<String, Object> bookingParams) {
        String randomSuffix = UUID.randomUUID().toString().substring(0, 6).toUpperCase();
        String txnId = "TXN-" + System.currentTimeMillis() + "-" + randomSuffix;

        PaymentTransaction txn = new PaymentTransaction(txnId, amount, bookingParams);
        txn.setStatus(PaymentTransaction.Status.PENDING);
        TRANSACTIONS.put(txnId, txn);

        cleanupOldTransactions();
        return txn;
    }

    public static PaymentTransaction getTransaction(String txnId) {
        if (txnId == null) return null;
        return TRANSACTIONS.get(txnId.trim());
    }

    public static boolean markSuccess(String txnId, String paymentMethod, int shipmentId, int invoiceId) {
        PaymentTransaction txn = getTransaction(txnId);
        if (txn != null) {
            txn.setStatus(PaymentTransaction.Status.SUCCESS);
            txn.setPaymentMethod(paymentMethod != null ? paymentMethod : "UPI_QR");
            txn.setPaidAt(new java.util.Date());
            txn.setGeneratedShipmentId(shipmentId);
            txn.setGeneratedInvoiceId(invoiceId);
            return true;
        }
        return false;
    }

    public static boolean markFailed(String txnId, String reason) {
        PaymentTransaction txn = getTransaction(txnId);
        if (txn != null) {
            txn.setStatus(PaymentTransaction.Status.FAILED);
            txn.setFailureReason(reason);
            return true;
        }
        return false;
    }

    private static void cleanupOldTransactions() {
        long oneDayAgo = System.currentTimeMillis() - (24L * 60 * 60 * 1000);
        TRANSACTIONS.entrySet().removeIf(entry -> 
            entry.getValue().getCreatedAt() != null && entry.getValue().getCreatedAt().getTime() < oneDayAgo
        );
    }
}
