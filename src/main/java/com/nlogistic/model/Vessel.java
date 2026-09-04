package com.nlogistic.model;

public class Vessel {
    private int vesselId;
    private String vesselName;
    private String imoNumber;
    private int capacityTeu;
    private String status = "In Service";

    public Vessel() {}

    public int getVesselId() {
        return vesselId;
    }

    public void setVesselId(int vesselId) {
        this.vesselId = vesselId;
    }

    public String getVesselName() {
        return vesselName;
    }

    public void setVesselName(String vesselName) {
        this.vesselName = vesselName;
    }

    public String getImoNumber() {
        return imoNumber;
    }

    public void setImoNumber(String imoNumber) {
        this.imoNumber = imoNumber;
    }

    public int getCapacityTeu() {
        return capacityTeu;
    }

    public void setCapacityTeu(int capacityTeu) {
        this.capacityTeu = capacityTeu;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
