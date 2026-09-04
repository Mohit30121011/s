package com.nlogistic.model;
public class ClaimDocument {
    private int docId;
    private int claimId;
    private String documentUrl;
    private String documentType;
    // Enriched fields matching the CLAIM_DOCUMENTS table (doc_type, file_path, uploaded_by, uploaded_at)
    private int uploadedBy;
    private java.util.Date uploadedAt;

    // Getters and setters
    public int getDocId() { return docId; }
    public void setDocId(int docId) { this.docId = docId; }
    public int getClaimId() { return claimId; }
    public void setClaimId(int claimId) { this.claimId = claimId; }
    public String getDocumentUrl() { return documentUrl; }
    public void setDocumentUrl(String documentUrl) { this.documentUrl = documentUrl; }
    public String getDocumentType() { return documentType; }
    public void setDocumentType(String documentType) { this.documentType = documentType; }

    // Aliases used by claim-document DAO code (doc_type / file_path column naming)
    public String getDocType() { return documentType; }
    public void setDocType(String docType) { this.documentType = docType; }
    public String getFilePath() { return documentUrl; }
    public void setFilePath(String filePath) { this.documentUrl = filePath; }

    public int getUploadedBy() { return uploadedBy; }
    public void setUploadedBy(int uploadedBy) { this.uploadedBy = uploadedBy; }
    public java.util.Date getUploadedAt() { return uploadedAt; }
    public void setUploadedAt(java.util.Date uploadedAt) { this.uploadedAt = uploadedAt; }
}