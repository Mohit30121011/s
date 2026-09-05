package com.nlogistic.model;

import java.util.Date;

public class User {
    private int userId;
    private String username;
    private String email;
    private String passwordHash;
    private String phone;
    private int roleId;
    private int companyId;
    private String status;
    private int failedLoginCount;
    private java.util.Date lastLoginAt;
    private java.util.Date createdAt;
    private java.util.Date updatedAt;

    public User() {}

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public int getCompanyId() {
        return companyId;
    }

    public void setCompanyId(int companyId) {
        this.companyId = companyId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getFailedLoginCount() {
        return failedLoginCount;
    }

    public void setFailedLoginCount(int failedLoginCount) {
        this.failedLoginCount = failedLoginCount;
    }

    public java.util.Date getLastLoginAt() {
        return lastLoginAt;
    }

    public void setLastLoginAt(java.util.Date lastLoginAt) {
        this.lastLoginAt = lastLoginAt;
    }

    public java.util.Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(java.util.Date createdAt) {
        this.createdAt = createdAt;
    }

    public java.util.Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(java.util.Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    private String modulePermissions;

    public String getModulePermissions() {
        return modulePermissions;
    }

    public void setModulePermissions(String modulePermissions) {
        this.modulePermissions = modulePermissions;
    }

    /**
     * Resolves default permissions if not explicitly customized.
     */
    public static String getDefaultPermissionsForRole(int rId) {
        switch (rId) {
            case 1: // Super Admin
                return "dashboard,tracking,shipments,plg,invoicing,inventory,claims,compliance,users,settings";
            case 2: // Company Admin
                return "dashboard,tracking,shipments,plg,invoicing,inventory,claims,compliance,users";
            case 3: // Operations Staff
                return "dashboard,tracking,shipments,inventory,claims,compliance";
            case 4: // Finance Staff
                return "dashboard,plg,invoicing,claims";
            case 5: // Customer
                return "dashboard,tracking,shipments,invoicing,claims,compliance";
            default:
                return "dashboard";
        }
    }

    /**
     * Checks if this user has access to a specific module key.
     */
    public boolean hasPermission(String moduleKey) {
        if (moduleKey == null || moduleKey.trim().isEmpty()) return true;
        if (this.roleId == 1) return true; // Super Admin has global override
        String perms = this.modulePermissions;
        if (perms == null || perms.trim().isEmpty()) {
            perms = getDefaultPermissionsForRole(this.roleId);
        }
        String cleanKey = moduleKey.trim().toLowerCase();
        String[] tokens = perms.split(",");
        for (String t : tokens) {
            if (t.trim().equalsIgnoreCase(cleanKey)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns a map of permission keys to boolean for simple EL evaluation: ${userPermissions['tracking']}
     */
    public java.util.Map<String, Boolean> getPermissionsMap() {
        java.util.Map<String, Boolean> map = new java.util.HashMap<>();
        String[] allKeys = new String[]{
            "dashboard", "tracking", "shipments", "plg", "invoicing",
            "inventory", "claims", "compliance", "users", "settings"
        };
        for (String k : allKeys) {
            map.put(k, hasPermission(k));
        }
        return map;
    }
}
