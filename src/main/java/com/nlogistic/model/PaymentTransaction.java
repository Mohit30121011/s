package com.nlogistic.model;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * Encapsulates an in-flight or completed mock payment transaction.
 */
public class PaymentTransaction implements Serializable {
    private static final long serialVersionUID = 1L;

    public enum Status {
        PENDING,
        PROCESSING,
        SUCCESS,
        FAILED
    }

    private String txnId;
    private double amount;
    private String currency = "USD";
    private Status status = Status.PENDING;
    private String paymentMethod; // UPI_QR, CARD, NETBANKING
    private String failureReason;
    private Date createdAt = new Date();
    private Date paidAt;
    private int generatedShipmentId = -1;
    private int generatedInvoiceId = -1;

    // Booking parameters payload to execute upon payment approval
    private Map<String, Object> bookingParams = new HashMap<>();

    public PaymentTransaction() {}

    public PaymentTransaction(String txnId, double amount, Map<String, Object> bookingParams) {
        this.txnId = txnId;
        this.amount = amount;
        this.bookingParams = bookingParams != null ? bookingParams : new HashMap<>();
    }

    public String getTxnId() { return txnId; }
    public void setTxnId(String txnId) { this.txnId = txnId; }

    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getFailureReason() { return failureReason; }
    public void setFailureReason(String failureReason) { this.failureReason = failureReason; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public Date getPaidAt() { return paidAt; }
    public void setPaidAt(Date paidAt) { this.paidAt = paidAt; }

    public int getGeneratedShipmentId() { return generatedShipmentId; }
    public void setGeneratedShipmentId(int generatedShipmentId) { this.generatedShipmentId = generatedShipmentId; }

    public int getGeneratedInvoiceId() { return generatedInvoiceId; }
    public void setGeneratedInvoiceId(int generatedInvoiceId) { this.generatedInvoiceId = generatedInvoiceId; }

    public Map<String, Object> getBookingParams() { return bookingParams; }
    public void setBookingParams(Map<String, Object> bookingParams) { this.bookingParams = bookingParams; }

    public Object getParam(String key) {
        return bookingParams != null ? bookingParams.get(key) : null;
    }
}
