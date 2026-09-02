package com.nlogistic.model;

import java.util.Date;

public class PricingAudit {
    private int auditId;
    private int pricingId;
    private double oldPrice;
    private double newPrice;
    private int changedBy;
    private String reason;
    private java.util.Date changedAt;

    public PricingAudit() {}

    public int getAuditId() {
        return auditId;
    }

    public void setAuditId(int auditId) {
        this.auditId = auditId;
    }

    public int getPricingId() {
        return pricingId;
    }

    public void setPricingId(int pricingId) {
        this.pricingId = pricingId;
    }

    public double getOldPrice() {
        return oldPrice;
    }

    public void setOldPrice(double oldPrice) {
        this.oldPrice = oldPrice;
    }

    public double getNewPrice() {
        return newPrice;
    }

    public void setNewPrice(double newPrice) {
        this.newPrice = newPrice;
    }

    public int getChangedBy() {
        return changedBy;
    }

    public void setChangedBy(int changedBy) {
        this.changedBy = changedBy;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public java.util.Date getChangedAt() {
        return changedAt;
    }

    public void setChangedAt(java.util.Date changedAt) {
        this.changedAt = changedAt;
    }

}
