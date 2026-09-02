package com.nlogistic.model;
public class InventoryLedger {
    private int ledgerId;
    private int productId;
    private String productName;
    private String transactionType;
    private double quantity;
    private double unitCostAtTxn;
    private String referenceType;
    private int referenceId;
    private java.sql.Timestamp transactionDate;

    public int getLedgerId() { return ledgerId; }
    public void setLedgerId(int ledgerId) { this.ledgerId = ledgerId; }
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getTransactionType() { return transactionType; }
    public void setTransactionType(String transactionType) { this.transactionType = transactionType; }
    public double getQuantity() { return quantity; }
    public void setQuantity(double quantity) { this.quantity = quantity; }
    public double getUnitCostAtTxn() { return unitCostAtTxn; }
    public void setUnitCostAtTxn(double unitCostAtTxn) { this.unitCostAtTxn = unitCostAtTxn; }
    public String getReferenceType() { return referenceType; }
    public void setReferenceType(String referenceType) { this.referenceType = referenceType; }
    public int getReferenceId() { return referenceId; }
    public void setReferenceId(int referenceId) { this.referenceId = referenceId; }
    public java.sql.Timestamp getTransactionDate() { return transactionDate; }
    public void setTransactionDate(java.sql.Timestamp transactionDate) { this.transactionDate = transactionDate; }
}
