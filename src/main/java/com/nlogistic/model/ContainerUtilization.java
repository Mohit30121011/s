package com.nlogistic.model;
public class ContainerUtilization {
    private int totalContainers;
    private int inUseContainers;
    private int idleContainers;
    private double utilizationRatePct;
    public int getTotalContainers() { return totalContainers; }
    public void setTotalContainers(int totalContainers) { this.totalContainers = totalContainers; }
    public int getInUseContainers() { return inUseContainers; }
    public void setInUseContainers(int inUseContainers) { this.inUseContainers = inUseContainers; }
    public int getIdleContainers() { return idleContainers; }
    public void setIdleContainers(int idleContainers) { this.idleContainers = idleContainers; }
    public double getUtilizationRatePct() { return utilizationRatePct; }
    public void setUtilizationRatePct(double utilizationRatePct) { this.utilizationRatePct = utilizationRatePct; }
}