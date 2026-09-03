package com.nlogistic.model;

public class Container {
    private int containerId;
    private String containerNumber;
    private String type;
    private String size;
    private String imageUrl;
    private double tareWeightKg;
    private double maxGrossWeightKg;
    private double goodsCapacityKg;
    private double goodsCapacityCbm;
    private String status;
    private int currentPortId;
    private int ownerCompanyId;

    public Container() {}

    public int getContainerId() { return containerId; }
    public void setContainerId(int containerId) { this.containerId = containerId; }

    public String getContainerNumber() { return containerNumber; }
    public void setContainerNumber(String containerNumber) { this.containerNumber = containerNumber; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getSize() { return size; }
    public void setSize(String size) { this.size = size; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public double getTareWeightKg() { return tareWeightKg; }
    public void setTareWeightKg(double tareWeightKg) { this.tareWeightKg = tareWeightKg; }

    public double getMaxGrossWeightKg() { return maxGrossWeightKg; }
    public void setMaxGrossWeightKg(double maxGrossWeightKg) { this.maxGrossWeightKg = maxGrossWeightKg; }

    public double getGoodsCapacityKg() { return goodsCapacityKg; }
    public void setGoodsCapacityKg(double goodsCapacityKg) { this.goodsCapacityKg = goodsCapacityKg; }

    public double getGoodsCapacityCbm() { return goodsCapacityCbm; }
    public void setGoodsCapacityCbm(double goodsCapacityCbm) { this.goodsCapacityCbm = goodsCapacityCbm; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getCurrentPortId() { return currentPortId; }
    public void setCurrentPortId(int currentPortId) { this.currentPortId = currentPortId; }

    public int getOwnerCompanyId() { return ownerCompanyId; }
    public void setOwnerCompanyId(int ownerCompanyId) { this.ownerCompanyId = ownerCompanyId; }
}
