package com.nlogistic.model;
public class ActiveShipment {
    private int shipmentId;
    private String customerName;
    private String containerNumber;
    private String status;
    private String originPort;
    private String destinationPort;
    public int getShipmentId() { return shipmentId; }
    public void setShipmentId(int shipmentId) { this.shipmentId = shipmentId; }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public String getContainerNumber() { return containerNumber; }
    public void setContainerNumber(String containerNumber) { this.containerNumber = containerNumber; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getOriginPort() { return originPort; }
    public void setOriginPort(String originPort) { this.originPort = originPort; }
    public String getDestinationPort() { return destinationPort; }
    public void setDestinationPort(String destinationPort) { this.destinationPort = destinationPort; }
}