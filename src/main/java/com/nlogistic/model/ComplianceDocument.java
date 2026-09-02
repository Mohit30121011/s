package com.nlogistic.model;
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
    public void setExpiryDate(java.sql.Date expiryDate) { this.expiryDate = expiryDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }
    public int getUploadedBy() { return uploadedBy; }
    public void setUploadedBy(int uploadedBy) { this.uploadedBy = uploadedBy; }
}
