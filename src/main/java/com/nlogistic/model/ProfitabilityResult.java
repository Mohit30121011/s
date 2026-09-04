package com.nlogistic.model;

public class ProfitabilityResult {
    private int id;
    private int productId;
    private String productName;
    private String category;
    private String period;
    private double revenue;
    private double directCogs;
    private double allocatedLogisticsCost;
    private double netProfit;
    private double profitMarginPct;

    public ProfitabilityResult() {}

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

    public double getRevenue() {
        return revenue;
    }

    public void setRevenue(double revenue) {
        this.revenue = revenue;
    }

    public double getDirectCogs() {
        return directCogs;
    }

    public void setDirectCogs(double directCogs) {
        this.directCogs = directCogs;
    }

    public double getAllocatedLogisticsCost() {
        return allocatedLogisticsCost;
    }

    public void setAllocatedLogisticsCost(double allocatedLogisticsCost) {
        this.allocatedLogisticsCost = allocatedLogisticsCost;
    }

    public double getNetProfit() {
        return netProfit;
    }

    public void setNetProfit(double netProfit) {
        this.netProfit = netProfit;
    }

    public double getProfitMarginPct() {
        return profitMarginPct;
    }

    public void setProfitMarginPct(double profitMarginPct) {
        this.profitMarginPct = profitMarginPct;
    }

}
