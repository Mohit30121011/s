package com.nlogistic.model;

import java.sql.Timestamp;

public class Notification {
    private int notifId;
    private int userId;
    private String title;
    private String message;
    private String link;
    private boolean isRead;
    private Timestamp createdAt;

    // Getters and Setters
    public int getNotifId() { return notifId; }
    public void setNotifId(int notifId) { this.notifId = notifId; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    
    public String getLink() { return link; }
    public void setLink(String link) { this.link = link; }
    
    public boolean isRead() { return isRead; }
    public void setRead(boolean isRead) { this.isRead = isRead; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
