package com.nlogistic.model;
public class Invoice {
    private int invoiceId;
    private int customerId;
    private int shipmentId;
    private java.sql.Date invoiceDate;
    private java.sql.Date dueDate;
    private double subtotalAmount;
    private double taxAmount;
    private double totalAmount;
    private double paidAmount;
    private String paymentStatus;

    public int getInvoiceId() { return invoiceId; }
    public void setInvoiceId(int invoiceId) { this.invoiceId = invoiceId; }
    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }
    public int getShipmentId() { return shipmentId; }
    public void setShipmentId(int shipmentId) { this.shipmentId = shipmentId; }
    public java.sql.Date getInvoiceDate() { return invoiceDate; }
    public void setInvoiceDate(java.sql.Date invoiceDate) { this.invoiceDate = invoiceDate; }
    public java.sql.Date getDueDate() { return dueDate; }
    public void setDueDate(java.sql.Date dueDate) { this.dueDate = dueDate; }
    public double getSubtotalAmount() { return subtotalAmount; }
    public void setSubtotalAmount(double subtotalAmount) { this.subtotalAmount = subtotalAmount; }
    public double getTaxAmount() { return taxAmount; }
    public void setTaxAmount(double taxAmount) { this.taxAmount = taxAmount; }
    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }
    public double getPaidAmount() { return paidAmount; }
    public void setPaidAmount(double paidAmount) { this.paidAmount = paidAmount; }
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
}
