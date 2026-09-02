package com.nlogistic.model;

import java.util.Date;

public class ClaimStatusHistory {
    private int historyId;
    private int claimId;
    private String oldStatus;
    private String newStatus;
    private int changedBy;
    private java.util.Date changedAt;
    private String remark;

    public ClaimStatusHistory() {}

    public int getHistoryId() {
        return historyId;
    }

    public void setHistoryId(int historyId) {
        this.historyId = historyId;
    }

    public int getClaimId() {
        return claimId;
    }

    public void setClaimId(int claimId) {
        this.claimId = claimId;
    }

    public String getOldStatus() {
        return oldStatus;
    }

    public void setOldStatus(String oldStatus) {
        this.oldStatus = oldStatus;
    }

    public String getNewStatus() {
        return newStatus;
    }

    public void setNewStatus(String newStatus) {
        this.newStatus = newStatus;
    }

    public int getChangedBy() {
        return changedBy;
    }

    public void setChangedBy(int changedBy) {
        this.changedBy = changedBy;
    }

    public java.util.Date getChangedAt() {
        return changedAt;
    }

    public void setChangedAt(java.util.Date changedAt) {
        this.changedAt = changedAt;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

}
