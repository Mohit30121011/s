package com.nlogistic.model;

import java.util.Date;

public class AbcClassificationResult {
    private int id;
    private int productId;
    private String productName;
    private String category;
    private double annualRevenue;
    private double revenueContributionPct;
    private double cumulativePct;
    private String abcClass;
    private String computedPeriod;
    private java.util.Date computedAt;

    public AbcClassificationResult() {}

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public double getAnnualRevenue() { return annualRevenue; }
    public void setAnnualRevenue(double annualRevenue) { this.annualRevenue = annualRevenue; }

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

    public double getRevenueContributionPct() {
        return revenueContributionPct;
    }

    public void setRevenueContributionPct(double revenueContributionPct) {
        this.revenueContributionPct = revenueContributionPct;
    }

    public double getCumulativePct() {
        return cumulativePct;
    }

    public void setCumulativePct(double cumulativePct) {
        this.cumulativePct = cumulativePct;
    }

    public String getAbcClass() {
        return abcClass;
    }

    public void setAbcClass(String abcClass) {
        this.abcClass = abcClass;
    }

    public String getComputedPeriod() {
        return computedPeriod;
    }

    public void setComputedPeriod(String computedPeriod) {
        this.computedPeriod = computedPeriod;
    }

    public java.util.Date getComputedAt() {
        return computedAt;
    }

    public void setComputedAt(java.util.Date computedAt) {
        this.computedAt = computedAt;
    }

}
