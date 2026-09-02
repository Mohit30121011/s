package com.nlogistic.model;

import java.util.Date;

public class Shipment {
    private int shipmentId;
    private int customerId;
    private int containerId;
    private int originPortId;
    private int destinationPortId;
    private int vesselId;
    private java.util.Date bookingDate;
    private String cargoDescription;
    private double cargoWeightKg;
    private double cargoVolumeCbm;
    private double cargoDeclaredValue;
    private double freightCost;
    private double insuranceCost;
    private double otherCharges;
    private String status;
    private int createdBy;

    public Shipment() {}

    public int getShipmentId() {
        return shipmentId;
    }

    public void setShipmentId(int shipmentId) {
        this.shipmentId = shipmentId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public int getContainerId() {
        return containerId;
    }

    public void setContainerId(int containerId) {
        this.containerId = containerId;
    }

    public int getOriginPortId() {
        return originPortId;
    }

    public void setOriginPortId(int originPortId) {
        this.originPortId = originPortId;
    }

    public int getDestinationPortId() {
        return destinationPortId;
    }

    public void setDestinationPortId(int destinationPortId) {
        this.destinationPortId = destinationPortId;
    }

    public int getVesselId() {
        return vesselId;
    }

    public void setVesselId(int vesselId) {
        this.vesselId = vesselId;
    }

    public java.util.Date getBookingDate() {
        return bookingDate;
    }

    public void setBookingDate(java.util.Date bookingDate) {
        this.bookingDate = bookingDate;
    }

    public String getCargoDescription() {
        return cargoDescription;
    }

    public void setCargoDescription(String cargoDescription) {
        this.cargoDescription = cargoDescription;
    }

    public double getCargoWeightKg() {
        return cargoWeightKg;
    }

    public void setCargoWeightKg(double cargoWeightKg) {
        this.cargoWeightKg = cargoWeightKg;
    }

    public double getCargoVolumeCbm() {
        return cargoVolumeCbm;
    }

    public void setCargoVolumeCbm(double cargoVolumeCbm) {
        this.cargoVolumeCbm = cargoVolumeCbm;
    }

    public double getCargoDeclaredValue() {
        return cargoDeclaredValue;
    }

    public void setCargoDeclaredValue(double cargoDeclaredValue) {
        this.cargoDeclaredValue = cargoDeclaredValue;
    }

    public double getFreightCost() {
        return freightCost;
    }

    public void setFreightCost(double freightCost) {
        this.freightCost = freightCost;
    }

    public double getInsuranceCost() {
        return insuranceCost;
    }

    public void setInsuranceCost(double insuranceCost) {
        this.insuranceCost = insuranceCost;
    }

    public double getOtherCharges() {
        return otherCharges;
    }

    public void setOtherCharges(double otherCharges) {
        this.otherCharges = otherCharges;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

}
