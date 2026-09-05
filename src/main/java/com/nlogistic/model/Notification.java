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
    private String type = "info"; // "warning", "danger", "info", "success"
    private String icon = "ti ti-bell";
    private String category = "General";
    private String timeAgo = "";

    public Notification() {}

    public Notification(int notifId, int userId, String title, String message, String link, 
                        String type, String icon, String category, String timeAgo, Timestamp createdAt) {
        this.notifId = notifId;
        this.userId = userId;
        this.title = title;
        this.message = message;
        this.link = link;
        this.type = type != null ? type : "info";
        this.icon = icon != null ? icon : "ti ti-bell";
        this.category = category != null ? category : "General";
        this.timeAgo = timeAgo != null ? timeAgo : "";
        this.createdAt = createdAt;
        this.isRead = false;
    }

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

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getTimeAgo() { return timeAgo; }
    public void setTimeAgo(String timeAgo) { this.timeAgo = timeAgo; }
}
