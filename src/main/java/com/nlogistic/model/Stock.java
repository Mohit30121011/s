package com.nlogistic.model;
public class Stock {
    private int stockId;
    private int companyId;
    private int productId;
    private String productName;
    private String warehouseLocation;
    private double quantityOnHand;
    private String batchNo;
    private java.sql.Date expiryDate;

    public int getStockId() { return stockId; }
    public void setStockId(int stockId) { this.stockId = stockId; }
    public int getCompanyId() { return companyId; }
    public void setCompanyId(int companyId) { this.companyId = companyId; }
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getWarehouseLocation() { return warehouseLocation; }
    public void setWarehouseLocation(String warehouseLocation) { this.warehouseLocation = warehouseLocation; }
    public double getQuantityOnHand() { return quantityOnHand; }
    public void setQuantityOnHand(double quantityOnHand) { this.quantityOnHand = quantityOnHand; }
    public String getBatchNo() { return batchNo; }
    public void setBatchNo(String batchNo) { this.batchNo = batchNo; }
    public java.sql.Date getExpiryDate() { return expiryDate; }
    public void setExpiryDate(java.sql.Date expiryDate) { this.expiryDate = expiryDate; }
}
