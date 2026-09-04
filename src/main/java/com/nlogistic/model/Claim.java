package com.nlogistic.model;
import java.util.Date;
public class Claim {
    private int claimId;
    private int shipmentId;
    private Integer containerId;
    private Integer productId;
    private int customerId;
    private String claimType;
    private String description;
    private Date incidentDate;
    private double claimedAmount;
    private double approvedAmount;
    private Integer reasonId;
    private String status;
    private int filedBy;
    private Date filedDate;
    private Integer resolvedBy;
    private Date resolvedDate;

    // Joined / enriched display fields (populated by DAO queries that join related tables)
    private String customerName;
    private String reasonName;
    private String filedByName;
    private String resolvedByName;
    private String productName;
    private String containerNumber;

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public String getReasonName() { return reasonName; }
    public void setReasonName(String reasonName) { this.reasonName = reasonName; }
    public String getFiledByName() { return filedByName; }
    public void setFiledByName(String filedByName) { this.filedByName = filedByName; }
    public String getResolvedByName() { return resolvedByName; }
    public void setResolvedByName(String resolvedByName) { this.resolvedByName = resolvedByName; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getContainerNumber() { return containerNumber; }
    public void setContainerNumber(String containerNumber) { this.containerNumber = containerNumber; }

    public int getClaimId() { return claimId; }
    public void setClaimId(int claimId) { this.claimId = claimId; }
    public int getShipmentId() { return shipmentId; }
    public void setShipmentId(int shipmentId) { this.shipmentId = shipmentId; }
    public Integer getContainerId() { return containerId; }
    public void setContainerId(Integer containerId) { this.containerId = containerId; }
    public Integer getProductId() { return productId; }
    public void setProductId(Integer productId) { this.productId = productId; }
    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }
    public String getClaimType() { return claimType; }
    public void setClaimType(String claimType) { this.claimType = claimType; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Date getIncidentDate() { return incidentDate; }
    public void setIncidentDate(Date incidentDate) { this.incidentDate = incidentDate; }
    public double getClaimedAmount() { return claimedAmount; }
    public void setClaimedAmount(double claimedAmount) { this.claimedAmount = claimedAmount; }
    public double getApprovedAmount() { return approvedAmount; }
    public void setApprovedAmount(double approvedAmount) { this.approvedAmount = approvedAmount; }
    public Integer getReasonId() { return reasonId; }
    public void setReasonId(Integer reasonId) { this.reasonId = reasonId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getFiledBy() { return filedBy; }
    public void setFiledBy(int filedBy) { this.filedBy = filedBy; }
    public Date getFiledDate() { return filedDate; }
    public void setFiledDate(Date filedDate) { this.filedDate = filedDate; }
    public Integer getResolvedBy() { return resolvedBy; }
    public void setResolvedBy(Integer resolvedBy) { this.resolvedBy = resolvedBy; }
    public Date getResolvedDate() { return resolvedDate; }
    public void setResolvedDate(Date resolvedDate) { this.resolvedDate = resolvedDate; }
}
