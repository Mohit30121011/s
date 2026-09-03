package com.nlogistic.model;

import java.util.List;

public class ShipmentDrilldown {
    private int shipmentId;
    private String status;
    private String customerName;
    private String vesselName;
    private String containerNumber;
    private String originPortName;
    private String originCountry;
    private String destinationPortName;
    private String destinationCountry;
    private String expectedDate;
    private String actualDate;
    private double totalRevenue;
    private double totalCost;
    private double netLoss;
    private List<Integer> assignedReasonIds;

    public ShipmentDrilldown() {}

    public int getShipmentId() { return shipmentId; }
    public void setShipmentId(int shipmentId) { this.shipmentId = shipmentId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getVesselName() { return vesselName; }
    public void setVesselName(String vesselName) { this.vesselName = vesselName; }

    public String getContainerNumber() { return containerNumber; }
    public void setContainerNumber(String containerNumber) { this.containerNumber = containerNumber; }

    public String getOriginPortName() { return originPortName; }
    public void setOriginPortName(String originPortName) { this.originPortName = originPortName; }

    public String getOriginCountry() { return originCountry; }
    public void setOriginCountry(String originCountry) { this.originCountry = originCountry; }

    public String getDestinationPortName() { return destinationPortName; }
    public void setDestinationPortName(String destinationPortName) { this.destinationPortName = destinationPortName; }

    public String getDestinationCountry() { return destinationCountry; }
    public void setDestinationCountry(String destinationCountry) { this.destinationCountry = destinationCountry; }

    public String getExpectedDate() { return expectedDate; }
    public void setExpectedDate(String expectedDate) { this.expectedDate = expectedDate; }

    public String getActualDate() { return actualDate; }
    public void setActualDate(String actualDate) { this.actualDate = actualDate; }

    public double getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(double totalRevenue) { this.totalRevenue = totalRevenue; }

    public double getTotalCost() { return totalCost; }
    public void setTotalCost(double totalCost) { this.totalCost = totalCost; }

    public double getNetLoss() { return netLoss; }
    public void setNetLoss(double netLoss) { this.netLoss = netLoss; }

    public List<Integer> getAssignedReasonIds() { return assignedReasonIds; }
    public void setAssignedReasonIds(List<Integer> assignedReasonIds) { this.assignedReasonIds = assignedReasonIds; }
}
