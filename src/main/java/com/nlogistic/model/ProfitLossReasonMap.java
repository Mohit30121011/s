package com.nlogistic.model;

public class ProfitLossReasonMap {
    private int id;
    private int plId;
    private int reasonId;
    private String remark;

    public ProfitLossReasonMap() {}

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getPlId() {
        return plId;
    }

    public void setPlId(int plId) {
        this.plId = plId;
    }

    public int getReasonId() {
        return reasonId;
    }

    public void setReasonId(int reasonId) {
        this.reasonId = reasonId;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

}
