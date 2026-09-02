package com.nlogistic.model;

import java.util.Date;

public class SalesTransaction {
    private int transactionId;
    private int productId;
    private int customerId;
    private int shipmentId;
    private double quantitySold;
    private double salePriceSnapshot;
    private double saleAmount;
    private java.util.Date saleDate;

    public SalesTransaction() {}

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public int getShipmentId() {
        return shipmentId;
    }

    public void setShipmentId(int shipmentId) {
        this.shipmentId = shipmentId;
    }

    public double getQuantitySold() {
        return quantitySold;
    }

    public void setQuantitySold(double quantitySold) {
        this.quantitySold = quantitySold;
    }

    public double getSalePriceSnapshot() {
        return salePriceSnapshot;
    }

    public void setSalePriceSnapshot(double salePriceSnapshot) {
        this.salePriceSnapshot = salePriceSnapshot;
    }

    public double getSaleAmount() {
        return saleAmount;
    }

    public void setSaleAmount(double saleAmount) {
        this.saleAmount = saleAmount;
    }

    public java.util.Date getSaleDate() {
        return saleDate;
    }

    public void setSaleDate(java.util.Date saleDate) {
        this.saleDate = saleDate;
    }

}
