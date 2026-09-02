package com.nlogistic.model;

import java.util.Date;

public class StockUploadLog {
    private int uploadId;
    private int companyId;
    private int uploadedBy;
    private String fileName;
    private int totalRecords;
    private int successCount;
    private int failureCount;
    private String errorReportPath;
    private java.util.Date uploadedAt;

    public StockUploadLog() {}

    public int getUploadId() {
        return uploadId;
    }

    public void setUploadId(int uploadId) {
        this.uploadId = uploadId;
    }

    public int getCompanyId() {
        return companyId;
    }

    public void setCompanyId(int companyId) {
        this.companyId = companyId;
    }

    public int getUploadedBy() {
        return uploadedBy;
    }

    public void setUploadedBy(int uploadedBy) {
        this.uploadedBy = uploadedBy;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public int getTotalRecords() {
        return totalRecords;
    }

    public void setTotalRecords(int totalRecords) {
        this.totalRecords = totalRecords;
    }

    public int getSuccessCount() {
        return successCount;
    }

    public void setSuccessCount(int successCount) {
        this.successCount = successCount;
    }

    public int getFailureCount() {
        return failureCount;
    }

    public void setFailureCount(int failureCount) {
        this.failureCount = failureCount;
    }

    public String getErrorReportPath() {
        return errorReportPath;
    }

    public void setErrorReportPath(String errorReportPath) {
        this.errorReportPath = errorReportPath;
    }

    public java.util.Date getUploadedAt() {
        return uploadedAt;
    }

    public void setUploadedAt(java.util.Date uploadedAt) {
        this.uploadedAt = uploadedAt;
    }

}
