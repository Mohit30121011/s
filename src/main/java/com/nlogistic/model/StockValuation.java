package com.nlogistic.model;
public class StockValuation {
    private String productName;
    private String category;
    private double totalQuantityOnHand;
    private double totalInventoryValuation;
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public double getTotalQuantityOnHand() { return totalQuantityOnHand; }
    public void setTotalQuantityOnHand(double totalQuantityOnHand) { this.totalQuantityOnHand = totalQuantityOnHand; }
    public double getTotalInventoryValuation() { return totalInventoryValuation; }
    public void setTotalInventoryValuation(double totalInventoryValuation) { this.totalInventoryValuation = totalInventoryValuation; }
}