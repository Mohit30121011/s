package com.nlogistic.model;

import java.util.Date;

public class ContainerMovement {
    private int movementId;
    private int shipmentId;
    private String status;
    private String checkpointLocation;
    private java.util.Date departureDate;
    private java.util.Date expectedArrivalDate;
    private java.util.Date actualArrivalDate;
    private int delayDays;
    private int updatedBy;
    private java.util.Date updatedAt;

    public ContainerMovement() {}

    public int getMovementId() {
        return movementId;
    }

    public void setMovementId(int movementId) {
        this.movementId = movementId;
    }

    public int getShipmentId() {
        return shipmentId;
    }

    public void setShipmentId(int shipmentId) {
        this.shipmentId = shipmentId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCheckpointLocation() {
        return checkpointLocation;
    }

    public void setCheckpointLocation(String checkpointLocation) {
        this.checkpointLocation = checkpointLocation;
    }

    public java.util.Date getDepartureDate() {
        return departureDate;
    }

    public void setDepartureDate(java.util.Date departureDate) {
        this.departureDate = departureDate;
    }

    public java.util.Date getExpectedArrivalDate() {
        return expectedArrivalDate;
    }

    public void setExpectedArrivalDate(java.util.Date expectedArrivalDate) {
        this.expectedArrivalDate = expectedArrivalDate;
    }

    public java.util.Date getActualArrivalDate() {
        return actualArrivalDate;
    }

    public void setActualArrivalDate(java.util.Date actualArrivalDate) {
        this.actualArrivalDate = actualArrivalDate;
    }

    public int getDelayDays() {
        return delayDays;
    }

    public void setDelayDays(int delayDays) {
        this.delayDays = delayDays;
    }

    public int getUpdatedBy() {
        return updatedBy;
    }

    public void setUpdatedBy(int updatedBy) {
        this.updatedBy = updatedBy;
    }

    public java.util.Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(java.util.Date updatedAt) {
        this.updatedAt = updatedAt;
    }

}
