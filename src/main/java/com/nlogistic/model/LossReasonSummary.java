package com.nlogistic.model;
public class LossReasonSummary {
    private String reasonName;
    private String category;
    private int occurrenceCount;
    private double totalFinancialImpact;
    public String getReasonName() { return reasonName; }
    public void setReasonName(String reasonName) { this.reasonName = reasonName; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public int getOccurrenceCount() { return occurrenceCount; }
    public void setOccurrenceCount(int occurrenceCount) { this.occurrenceCount = occurrenceCount; }
    public double getTotalFinancialImpact() { return totalFinancialImpact; }
    public void setTotalFinancialImpact(double totalFinancialImpact) { this.totalFinancialImpact = totalFinancialImpact; }
}