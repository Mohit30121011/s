package com.nlogistic.model;
import java.util.Date;
public class BarcodeEntry {
    private int barcodeId;
    private String barcodeValue;
    private String barcodeType;
    private String entityType;
    private int entityId;
    private String imagePath;
    private int generatedBy;
    private Date generatedAt;

    public int getBarcodeId() { return barcodeId; }
    public void setBarcodeId(int barcodeId) { this.barcodeId = barcodeId; }
    public String getBarcodeValue() { return barcodeValue; }
    public void setBarcodeValue(String barcodeValue) { this.barcodeValue = barcodeValue; }
    public String getBarcodeType() { return barcodeType; }
    public void setBarcodeType(String barcodeType) { this.barcodeType = barcodeType; }
    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }
    public int getEntityId() { return entityId; }
    public void setEntityId(int entityId) { this.entityId = entityId; }
    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }
    public int getGeneratedBy() { return generatedBy; }
    public void setGeneratedBy(int generatedBy) { this.generatedBy = generatedBy; }
    public Date getGeneratedAt() { return generatedAt; }
    public void setGeneratedAt(Date generatedAt) { this.generatedAt = generatedAt; }
}
