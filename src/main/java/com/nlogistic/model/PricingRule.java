package com.nlogistic.model;

import java.sql.Date;

public class PricingRule {
    private int pricingId;
    private String containerType;
    private String containerSize;
    private int routeId;
    private double basePrice;
    private double seasonalMultiplier;
    private double demandMultiplier;
    private double finalPrice;
    private Date validFrom;
    private Date validTo;

    public PricingRule() {}

    public int getPricingId() { return pricingId; }
    public void setPricingId(int pricingId) { this.pricingId = pricingId; }

    public String getContainerType() { return containerType; }
    public void setContainerType(String containerType) { this.containerType = containerType; }

    public String getContainerSize() { return containerSize; }
    public void setContainerSize(String containerSize) { this.containerSize = containerSize; }

    public int getRouteId() { return routeId; }
    public void setRouteId(int routeId) { this.routeId = routeId; }

    public double getBasePrice() { return basePrice; }
    public void setBasePrice(double basePrice) { this.basePrice = basePrice; }

    public double getSeasonalMultiplier() { return seasonalMultiplier; }
    public void setSeasonalMultiplier(double seasonalMultiplier) { this.seasonalMultiplier = seasonalMultiplier; }

    public double getDemandMultiplier() { return demandMultiplier; }
    public void setDemandMultiplier(double demandMultiplier) { this.demandMultiplier = demandMultiplier; }

    public double getFinalPrice() { return finalPrice; }
    public void setFinalPrice(double finalPrice) { this.finalPrice = finalPrice; }

    public Date getValidFrom() { return validFrom; }
    public void setValidFrom(Date validFrom) { this.validFrom = validFrom; }

    public Date getValidTo() { return validTo; }
    public void setValidTo(Date validTo) { this.validTo = validTo; }
    
    // FR3.5 Formula: Final Price = Base Price * Seasonal Multiplier * Demand Multiplier
    public double calculateFinalPrice() {
        return basePrice * seasonalMultiplier * demandMultiplier;
    }
}
