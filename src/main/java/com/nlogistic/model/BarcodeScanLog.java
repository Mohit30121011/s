package com.nlogistic.model;
import java.util.Date;
public class BarcodeScanLog {
    private int scanId;
    private int barcodeId;
    private int scannedBy;
    private Date scannedAt;
    private String scanLocation;
    private String moduleContext;

    public int getScanId() { return scanId; }
    public void setScanId(int scanId) { this.scanId = scanId; }
    public int getBarcodeId() { return barcodeId; }
    public void setBarcodeId(int barcodeId) { this.barcodeId = barcodeId; }
    public int getScannedBy() { return scannedBy; }
    public void setScannedBy(int scannedBy) { this.scannedBy = scannedBy; }
    public Date getScannedAt() { return scannedAt; }
    public void setScannedAt(Date scannedAt) { this.scannedAt = scannedAt; }
    public String getScanLocation() { return scanLocation; }
    public void setScanLocation(String scanLocation) { this.scanLocation = scanLocation; }
    public String getModuleContext() { return moduleContext; }
    public void setModuleContext(String moduleContext) { this.moduleContext = moduleContext; }
}
