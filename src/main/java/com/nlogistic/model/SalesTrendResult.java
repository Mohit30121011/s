package com.nlogistic.model;
public class SalesTrendResult {
    private int productId;
    private String productName;
    private String category;
    private double actualSales;
    private double movingAvg;
    private String trendLabel;
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public double getActualSales() { return actualSales; }
    public void setActualSales(double actualSales) { this.actualSales = actualSales; }
    public double getMovingAvg() { return movingAvg; }
    public void setMovingAvg(double movingAvg) { this.movingAvg = movingAvg; }
    public String getTrendLabel() { return trendLabel; }
    public void setTrendLabel(String trendLabel) { this.trendLabel = trendLabel; }
}