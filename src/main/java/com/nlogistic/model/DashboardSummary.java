package com.nlogistic.model;
public class DashboardSummary {
    private int activeShipments;
    private double totalRevenue;
    private double netProfit;
    private int overdueInvoices;
    private double overdueReceivables;
    // Getters and Setters
    public int getActiveShipments() { return activeShipments; }
    public void setActiveShipments(int activeShipments) { this.activeShipments = activeShipments; }
    public double getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(double totalRevenue) { this.totalRevenue = totalRevenue; }
    public double getNetProfit() { return netProfit; }
    public void setNetProfit(double netProfit) { this.netProfit = netProfit; }
    public int getOverdueInvoices() { return overdueInvoices; }
    public void setOverdueInvoices(int overdueInvoices) { this.overdueInvoices = overdueInvoices; }
    public double getOverdueReceivables() { return overdueReceivables; }
    public void setOverdueReceivables(double overdueReceivables) { this.overdueReceivables = overdueReceivables; }
}