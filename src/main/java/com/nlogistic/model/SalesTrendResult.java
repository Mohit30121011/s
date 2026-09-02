package com.nlogistic.model;
public class SalesTrendResult {
    private int productId;
    private double actualSales;
    private double movingAvg;
    private String trendLabel;
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public double getActualSales() { return actualSales; }
    public void setActualSales(double actualSales) { this.actualSales = actualSales; }
    public double getMovingAvg() { return movingAvg; }
    public void setMovingAvg(double movingAvg) { this.movingAvg = movingAvg; }
    public String getTrendLabel() { return trendLabel; }
    public void setTrendLabel(String trendLabel) { this.trendLabel = trendLabel; }
}