package com.nlogistic.model;
public class ClaimDocument {
    private int docId;
    private int claimId;
    private String documentUrl;
    private String documentType;
    // Getters and setters
    public int getDocId() { return docId; }
    public void setDocId(int docId) { this.docId = docId; }
    public int getClaimId() { return claimId; }
    public void setClaimId(int claimId) { this.claimId = claimId; }
    public String getDocumentUrl() { return documentUrl; }
    public void setDocumentUrl(String documentUrl) { this.documentUrl = documentUrl; }
    public String getDocumentType() { return documentType; }
    public void setDocumentType(String documentType) { this.documentType = documentType; }
}