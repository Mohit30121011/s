package com.nlogistic.model;

public class ShipmentComplianceInfo {
    private int shipmentId;
    private String shipmentStatus;
    private String cargoDescription;
    private String customerName;
    private int totalDocuments;
    private int approvedDocuments;
    private boolean clearedForDeparture;

    public int getShipmentId() { return shipmentId; }
    public void setShipmentId(int shipmentId) { this.shipmentId = shipmentId; }

    public String getShipmentStatus() { return shipmentStatus; }
    public void setShipmentStatus(String shipmentStatus) { this.shipmentStatus = shipmentStatus; }

    public String getCargoDescription() { return cargoDescription; }
    public void setCargoDescription(String cargoDescription) { this.cargoDescription = cargoDescription; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public int getTotalDocuments() { return totalDocuments; }
    public void setTotalDocuments(int totalDocuments) { this.totalDocuments = totalDocuments; }

    public int getApprovedDocuments() { return approvedDocuments; }
    public void setApprovedDocuments(int approvedDocuments) { this.approvedDocuments = approvedDocuments; }

    public boolean isClearedForDeparture() { return clearedForDeparture; }
    public void setClearedForDeparture(boolean clearedForDeparture) { this.clearedForDeparture = clearedForDeparture; }
}
