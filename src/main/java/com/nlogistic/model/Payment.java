package com.nlogistic.model;
public class Payment {
    private int paymentId;
    private int invoiceId;
    private java.sql.Date paymentDate;
    private double amountPaid;
    private String paymentMode;
    private String transactionRef;

    public int getPaymentId() { return paymentId; }
    public void setPaymentId(int paymentId) { this.paymentId = paymentId; }
    public int getInvoiceId() { return invoiceId; }
    public void setInvoiceId(int invoiceId) { this.invoiceId = invoiceId; }
    public java.sql.Date getPaymentDate() { return paymentDate; }
    public void setPaymentDate(java.sql.Date paymentDate) { this.paymentDate = paymentDate; }
    public double getAmountPaid() { return amountPaid; }
    public void setAmountPaid(double amountPaid) { this.amountPaid = amountPaid; }
    public String getPaymentMode() { return paymentMode; }
    public void setPaymentMode(String paymentMode) { this.paymentMode = paymentMode; }
    public String getTransactionRef() { return transactionRef; }
    public void setTransactionRef(String transactionRef) { this.transactionRef = transactionRef; }
}
