package com.nlogistic.model;

import java.util.Date;

public class ProfitLoss {
    private int plId;
    private int shipmentId;
    private double revenueAmount;
    private double totalCostAmount;
    private double profitLossAmount;
    private java.util.Date recordDate;

    public ProfitLoss() {}

    public int getPlId() {
        return plId;
    }

    public void setPlId(int plId) {
        this.plId = plId;
    }

    public int getShipmentId() {
        return shipmentId;
    }

    public void setShipmentId(int shipmentId) {
        this.shipmentId = shipmentId;
    }

    public double getRevenueAmount() {
        return revenueAmount;
    }

    public void setRevenueAmount(double revenueAmount) {
        this.revenueAmount = revenueAmount;
    }

    public double getTotalCostAmount() {
        return totalCostAmount;
    }

    public void setTotalCostAmount(double totalCostAmount) {
        this.totalCostAmount = totalCostAmount;
    }

    public double getProfitLossAmount() {
        return profitLossAmount;
    }

    public void setProfitLossAmount(double profitLossAmount) {
        this.profitLossAmount = profitLossAmount;
    }

    public java.util.Date getRecordDate() {
        return recordDate;
    }

    public void setRecordDate(java.util.Date recordDate) {
        this.recordDate = recordDate;
    }

}
