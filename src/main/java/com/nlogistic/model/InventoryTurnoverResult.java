package com.nlogistic.model;

import java.util.Date;

public class InventoryTurnoverResult {
    private int id;
    private int productId;
    private String productName;
    private String category;
    private String period;
    private double cogsAmount;
    private double avgInventoryValue;
    private double turnoverRatio;
    private double daysInInventory;
    private java.util.Date computedAt;

    public InventoryTurnoverResult() {}

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getPeriod() {
        return period;
    }

    public void setPeriod(String period) {
        this.period = period;
    }

    public double getCogsAmount() {
        return cogsAmount;
    }

    public void setCogsAmount(double cogsAmount) {
        this.cogsAmount = cogsAmount;
    }

    public double getAvgInventoryValue() {
        return avgInventoryValue;
    }

    public void setAvgInventoryValue(double avgInventoryValue) {
        this.avgInventoryValue = avgInventoryValue;
    }

    public double getTurnoverRatio() {
        return turnoverRatio;
    }

    public void setTurnoverRatio(double turnoverRatio) {
        this.turnoverRatio = turnoverRatio;
    }

    public double getDaysInInventory() {
        return daysInInventory;
    }

    public void setDaysInInventory(double daysInInventory) {
        this.daysInInventory = daysInInventory;
    }

    public java.util.Date getComputedAt() {
        return computedAt;
    }

    public void setComputedAt(java.util.Date computedAt) {
        this.computedAt = computedAt;
    }

}
