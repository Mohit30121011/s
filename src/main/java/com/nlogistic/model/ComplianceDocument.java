package com.nlogistic.model;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

public class ComplianceDocument {
    private int docId;
    private int shipmentId;
    private String docType;
    private String docNumber;
    private String issuingAuthority;
    private java.sql.Date issueDate;
    private java.sql.Date expiryDate;
    private String status;
    private String filePath;
    private int uploadedBy;

    // Joined / enriched display fields
    private String customerName;
    private String cargoDescription;
    private String originPort;
    private String destinationPort;
    private String uploaderName;
    private boolean expiringSoon;
    private long daysUntilExpiry;

    public int getDocId() { return docId; }
    public void setDocId(int docId) { this.docId = docId; }
    public int getShipmentId() { return shipmentId; }
    public void setShipmentId(int shipmentId) { this.shipmentId = shipmentId; }
    public String getDocType() { return docType; }
    public void setDocType(String docType) { this.docType = docType; }
    public String getDocNumber() { return docNumber; }
    public void setDocNumber(String docNumber) { this.docNumber = docNumber; }
    public String getIssuingAuthority() { return issuingAuthority; }
    public void setIssuingAuthority(String issuingAuthority) { this.issuingAuthority = issuingAuthority; }
    public java.sql.Date getIssueDate() { return issueDate; }
    public void setIssueDate(java.sql.Date issueDate) { this.issueDate = issueDate; }
    public java.sql.Date getExpiryDate() { return expiryDate; }
    public void setExpiryDate(java.sql.Date expiryDate) {
        this.expiryDate = expiryDate;
        calculateExpiryMeta();
    }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }
    public int getUploadedBy() { return uploadedBy; }
    public void setUploadedBy(int uploadedBy) { this.uploadedBy = uploadedBy; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getCargoDescription() { return cargoDescription; }
    public void setCargoDescription(String cargoDescription) { this.cargoDescription = cargoDescription; }

    public String getOriginPort() { return originPort; }
    public void setOriginPort(String originPort) { this.originPort = originPort; }

    public String getDestinationPort() { return destinationPort; }
    public void setDestinationPort(String destinationPort) { this.destinationPort = destinationPort; }
    public String getDestPort() { return destinationPort; }
    public void setDestPort(String destPort) { this.destinationPort = destPort; }

    public String getUploaderName() { return uploaderName; }
    public void setUploaderName(String uploaderName) { this.uploaderName = uploaderName; }

    public boolean isExpiringSoon() { return expiringSoon; }
    public void setExpiringSoon(boolean expiringSoon) { this.expiringSoon = expiringSoon; }

    public long getDaysUntilExpiry() { return daysUntilExpiry; }
    public void setDaysUntilExpiry(long daysUntilExpiry) { this.daysUntilExpiry = daysUntilExpiry; }

    public boolean isExpired() {
        if ("Expired".equalsIgnoreCase(status)) return true;
        if (expiryDate != null) {
            return expiryDate.before(new java.util.Date(System.currentTimeMillis() - 86400000L));
        }
        return false;
    }

    private void calculateExpiryMeta() {
        if (this.expiryDate != null) {
            LocalDate exp = this.expiryDate.toLocalDate();
            LocalDate today = LocalDate.now();
            this.daysUntilExpiry = ChronoUnit.DAYS.between(today, exp);
            this.expiringSoon = (this.daysUntilExpiry >= 0 && this.daysUntilExpiry <= 15);
        } else {
            this.expiringSoon = false;
            this.daysUntilExpiry = 999;
        }
    }
}
