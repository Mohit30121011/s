package com.nlogistic.model;

import java.util.ArrayList;
import java.util.List;

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

    // Joined / enriched display fields
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private String cargoDescription;
    private String originPort;
    private String destinationPort;
    private List<InvoiceLineItem> lineItems = new ArrayList<>();
    private List<Payment> payments = new ArrayList<>();

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

    public double getBalanceDue() {
        return Math.max(0.0, this.totalAmount - this.paidAmount);
    }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getCustomerEmail() { return customerEmail; }
    public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }

    public String getCustomerPhone() { return customerPhone; }
    public void setCustomerPhone(String customerPhone) { this.customerPhone = customerPhone; }

    public String getCargoDescription() { return cargoDescription; }
    public void setCargoDescription(String cargoDescription) { this.cargoDescription = cargoDescription; }

    public String getOriginPort() { return originPort; }
    public void setOriginPort(String originPort) { this.originPort = originPort; }

    public String getDestinationPort() { return destinationPort; }
    public void setDestinationPort(String destinationPort) { this.destinationPort = destinationPort; }

    public List<InvoiceLineItem> getLineItems() { return lineItems; }
    public void setLineItems(List<InvoiceLineItem> lineItems) { this.lineItems = lineItems; }

    public List<Payment> getPayments() { return payments; }
    public void setPayments(List<Payment> payments) { this.payments = payments; }
}
