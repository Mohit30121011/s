package com.nlogistic.dao;

import com.nlogistic.model.Notification;
import com.nlogistic.util.DBConnectionManager;

import java.io.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

public class NotificationDAO {

    // Persistent storage file for dismissed notifications (Zero DB schema alterations)
    private static final File DATA_FILE_PRIMARY = new File("d:/NLogistic/NLogistic/data/dismissed_notifs.properties");
    private static final File DATA_FILE_BACKUP = new File(System.getProperty("user.home"), ".nlogistic" + File.separator + "dismissed_notifs.properties");
    private static final ConcurrentHashMap<Integer, Set<Integer>> dismissedByUser = new ConcurrentHashMap<>();

    static {
        loadDismissedFromFile();
    }

    private static synchronized void loadDismissedFromFile() {
        File fileToRead = DATA_FILE_PRIMARY.exists() ? DATA_FILE_PRIMARY : (DATA_FILE_BACKUP.exists() ? DATA_FILE_BACKUP : null);
        if (fileToRead == null || !fileToRead.exists()) {
            return;
        }

        Properties props = new Properties();
        try (InputStream in = new FileInputStream(fileToRead)) {
            props.load(in);
            for (String key : props.stringPropertyNames()) {
                try {
                    int uid = Integer.parseInt(key.trim());
                    String rawIds = props.getProperty(key);
                    if (rawIds != null && !rawIds.trim().isEmpty()) {
                        Set<Integer> idSet = ConcurrentHashMap.newKeySet();
                        for (String idStr : rawIds.split(",")) {
                            try {
                                String clean = idStr.trim();
                                if (!clean.isEmpty()) {
                                    idSet.add(Integer.parseInt(clean));
                                }
                            } catch (NumberFormatException ignored) {}
                        }
                        dismissedByUser.put(uid, idSet);
                    }
                } catch (NumberFormatException ignored) {}
            }
        } catch (Exception e) {
            System.err.println("[NotificationDAO] Could not load dismissed notifications from file: " + e.getMessage());
        }
    }

    private static synchronized void saveDismissedToFile() {
        Properties props = new Properties();
        for (Map.Entry<Integer, Set<Integer>> entry : dismissedByUser.entrySet()) {
            int uid = entry.getKey();
            Set<Integer> ids = entry.getValue();
            if (ids != null && !ids.isEmpty()) {
                StringBuilder sb = new StringBuilder();
                for (int id : ids) {
                    if (sb.length() > 0) sb.append(",");
                    sb.append(id);
                }
                props.setProperty(String.valueOf(uid), sb.toString());
            }
        }

        saveToPropsFile(props, DATA_FILE_PRIMARY);
        saveToPropsFile(props, DATA_FILE_BACKUP);
    }

    private static void saveToPropsFile(Properties props, File file) {
        try {
            File parent = file.getParentFile();
            if (parent != null && !parent.exists()) {
                parent.mkdirs();
            }
            try (OutputStream out = new FileOutputStream(file)) {
                props.store(out, "NLogistic Dismissed Notifications Store");
            }
        } catch (Exception ignored) {}
    }

    public List<Notification> getUnreadNotificationsForUser(int userId) {
        List<Notification> list = new ArrayList<>();
        try (Connection conn = DBConnectionManager.getConnection()) {
            int roleId = -1;
            Integer companyId = null;
            Integer customerId = null;
            String userStatus = null;
            String username = null;

            String userSql = "SELECT u.role_id, u.company_id, u.status, u.username, c.customer_id " +
                             "FROM USERS u LEFT JOIN CUSTOMERS c ON c.user_id = u.user_id " +
                             "WHERE u.user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(userSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        roleId = rs.getInt("role_id");
                        companyId = (Integer) rs.getObject("company_id");
                        customerId = (Integer) rs.getObject("customer_id");
                        userStatus = rs.getString("status");
                        username = rs.getString("username");
                    }
                }
            }
            if (roleId <= 0) return list;

            // ══════════════════════════════════════════════════════════════════
            // 1. COMPLIANCE EXPIRY ALERTS (Roles 1, 2, 3 - strictly NO Role 4 / 5)
            // ══════════════════════════════════════════════════════════════════
            if (roleId <= 3) {
                StringBuilder compSql = new StringBuilder();
                compSql.append("SELECT cd.doc_id, cd.doc_type, cd.doc_number, cd.expiry_date, cd.status, cd.shipment_id, ")
                       .append("DATEDIFF(cd.expiry_date, CURRENT_DATE()) AS days_left ")
                       .append("FROM COMPLIANCE_DOCUMENTS cd ")
                       .append("JOIN SHIPMENT s ON cd.shipment_id = s.shipment_id ")
                       .append("JOIN CONTAINERS cnt ON s.container_id = cnt.container_id ")
                       .append("WHERE (cd.expiry_date <= DATE_ADD(CURRENT_DATE(), INTERVAL 15 DAY)) ")
                       .append("  AND cd.status NOT IN ('Rejected') ")
                       .append("  AND s.status NOT IN ('Delivered', 'Cancelled') ");

                if (roleId != 1 && companyId != null) {
                    compSql.append("  AND (cnt.owner_company_id = ? OR s.created_by IN (SELECT user_id FROM USERS WHERE company_id = ?)) ");
                }
                compSql.append("ORDER BY cd.expiry_date ASC LIMIT 5");

                try (PreparedStatement ps = conn.prepareStatement(compSql.toString())) {
                    if (roleId != 1 && companyId != null) {
                        ps.setInt(1, companyId);
                        ps.setInt(2, companyId);
                    }
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int docId = rs.getInt("doc_id");
                            String docType = rs.getString("doc_type");
                            String docNumber = rs.getString("doc_number");
                            java.sql.Date expiry = rs.getDate("expiry_date");
                            int daysLeft = rs.getInt("days_left");

                            String title;
                            String message;
                            String type;
                            String icon;
                            String timeAgo;

                            if (daysLeft < 0) {
                                title = "Compliance Expired: " + docType;
                                message = docType + (docNumber != null ? " #" + docNumber : "") +
                                          " expired on " + expiry + ". Shipments cannot depart on expired paperwork.";
                                type = "danger";
                                icon = "ti ti-alert-circle";
                                timeAgo = "Expired " + Math.abs(daysLeft) + "d ago";
                            } else {
                                title = "Compliance Expiry Warning";
                                message = docType + (docNumber != null ? " #" + docNumber : "") +
                                          " expires in " + (daysLeft == 0 ? "today" : daysLeft + " day" + (daysLeft > 1 ? "s" : "")) +
                                          ". Departure gatekeeper blocks uncertified vessels.";
                                type = "warning";
                                icon = "ti ti-alert-triangle";
                                timeAgo = (daysLeft == 0 ? "Expires Today" : "Expires in " + daysLeft + "d");
                            }

                            int notifId = 100000 + docId;
                            if (!isDismissed(userId, notifId)) {
                                list.add(new Notification(
                                    notifId, userId, title, message,
                                    "/compliance", type, icon, "Compliance", timeAgo,
                                    new Timestamp(System.currentTimeMillis())
                                ));
                            }
                        }
                    }
                } catch (Exception ignored) {}
            }

            // ══════════════════════════════════════════════════════════════════
            // 2. INVOICE & BILLING ALERTS (Roles 1, 2, 4, 5 - strictly NO Role 3 Ops)
            // ══════════════════════════════════════════════════════════════════
            if (roleId == 1 || roleId == 2 || roleId == 4 || roleId == 5) {
                StringBuilder invSql = new StringBuilder();
                invSql.append("SELECT bi.invoice_id, bi.total_amount, bi.paid_amount, bi.due_date, bi.payment_status, ")
                      .append("DATEDIFF(CURRENT_DATE(), bi.due_date) AS days_overdue ")
                      .append("FROM BILLING_INVOICES bi ")
                      .append("JOIN SHIPMENT s ON bi.shipment_id = s.shipment_id ")
                      .append("JOIN CONTAINERS cnt ON s.container_id = cnt.container_id ")
                      .append("WHERE bi.payment_status != 'Paid' ");

                if (roleId == 5 && customerId != null) {
                    invSql.append("  AND bi.customer_id = ? ");
                } else if ((roleId == 2 || roleId == 4) && companyId != null) {
                    invSql.append("  AND bi.due_date < CURRENT_DATE() ");
                    invSql.append("  AND (cnt.owner_company_id = ? OR s.created_by IN (SELECT user_id FROM USERS WHERE company_id = ?)) ");
                } else if (roleId == 1) {
                    invSql.append("  AND bi.due_date < CURRENT_DATE() ");
                }

                invSql.append("ORDER BY bi.due_date ASC LIMIT 5");

                try (PreparedStatement ps = conn.prepareStatement(invSql.toString())) {
                    if (roleId == 5 && customerId != null) {
                        ps.setInt(1, customerId);
                    } else if ((roleId == 2 || roleId == 4) && companyId != null) {
                        ps.setInt(1, companyId);
                        ps.setInt(2, companyId);
                    }
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int invId = rs.getInt("invoice_id");
                            double total = rs.getDouble("total_amount");
                            double paid = rs.getDouble("paid_amount");
                            double bal = Math.max(0, total - paid);
                            java.sql.Date due = rs.getDate("due_date");
                            int daysOverdue = rs.getInt("days_overdue");

                            String title;
                            String message;
                            String type;
                            String timeAgo;
                            String link = (roleId == 5 ? "/invoices" : "/billing");

                            if (daysOverdue > 0) {
                                title = (roleId == 5 ? "Payment Overdue: Invoice #" : "Overdue Invoice #") + invId;
                                message = "Unpaid balance of $" + String.format("%,.0f", bal) + " was due on " + due + ".";
                                type = "danger";
                                timeAgo = daysOverdue + "d overdue";
                            } else {
                                title = (roleId == 5 ? "Invoice Due Soon: #" : "Pending Invoice #") + invId;
                                message = "Invoice balance of $" + String.format("%,.0f", bal) + " due on " + due + ".";
                                type = "warning";
                                timeAgo = (daysOverdue == 0 ? "Due Today" : "Due in " + Math.abs(daysOverdue) + "d");
                            }

                            int notifId = 200000 + invId;
                            if (!isDismissed(userId, notifId)) {
                                list.add(new Notification(
                                    notifId, userId, title, message,
                                    link, type, "ti ti-receipt-tax", "Billing",
                                    timeAgo, new Timestamp(System.currentTimeMillis())
                                ));
                            }
                        }
                    }
                } catch (Exception ignored) {}
            }

            // ══════════════════════════════════════════════════════════════════
            // 3. CLAIMS ACTION ALERTS (Role Scoped - Zero Cross-Customer Bleed)
            // ══════════════════════════════════════════════════════════════════
            if (roleId <= 4) {
                // Internal Staff & Admins
                StringBuilder claimSql = new StringBuilder();
                claimSql.append("SELECT c.claim_id, c.shipment_id, c.status, c.claimed_amount, c.approved_amount, c.claim_type ")
                        .append("FROM CLAIMS c ")
                        .append("JOIN SHIPMENT s ON c.shipment_id = s.shipment_id ")
                        .append("JOIN CONTAINERS cnt ON s.container_id = cnt.container_id ")
                        .append("WHERE ");

                if (roleId == 3) {
                    claimSql.append("c.status IN ('Under Review', 'Submitted') ");
                } else if (roleId == 4) {
                    claimSql.append("c.status = 'Approved' ");
                } else {
                    claimSql.append("c.status IN ('Under Review', 'Submitted', 'Approved') ");
                }

                if ((roleId == 2 || roleId == 3 || roleId == 4) && companyId != null) {
                    claimSql.append("  AND (cnt.owner_company_id = ? OR s.created_by IN (SELECT user_id FROM USERS WHERE company_id = ?)) ");
                }
                claimSql.append("ORDER BY c.claim_id DESC LIMIT 5");

                try (PreparedStatement ps = conn.prepareStatement(claimSql.toString())) {
                    if ((roleId == 2 || roleId == 3 || roleId == 4) && companyId != null) {
                        ps.setInt(1, companyId);
                        ps.setInt(2, companyId);
                    }
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int claimId = rs.getInt("claim_id");
                            String status = rs.getString("status");
                            double claimed = rs.getDouble("claimed_amount");
                            double approved = rs.getDouble("approved_amount");
                            String claimType = rs.getString("claim_type");

                            String title;
                            String message;
                            String type;
                            String icon;
                            String timeAgo;

                            if ("Approved".equals(status)) {
                                title = "Claim #" + claimId + " Approved Payout";
                                message = "Payout of $" + String.format("%,.0f", approved) + " pending financial settlement disbursement.";
                                type = "info";
                                icon = "ti ti-cash";
                                timeAgo = "Payout Ready";
                            } else {
                                title = "Claim #" + claimId + " Under Review";
                                message = (claimType != null ? claimType : "Damage") + " claim of $" + String.format("%,.0f", claimed) + " requires operational inspection.";
                                type = "warning";
                                icon = "ti ti-file-alert";
                                timeAgo = "Action Required";
                            }

                            int notifId = 300000 + claimId;
                            if (!isDismissed(userId, notifId)) {
                                list.add(new Notification(
                                    notifId, userId, title, message,
                                    "/claims?action=view&claimId=" + claimId, type, icon, "Claims", timeAgo,
                                    new Timestamp(System.currentTimeMillis())
                                ));
                            }
                        }
                    }
                } catch (Exception ignored) {}
            } else if (roleId == 5 && customerId != null) {
                // Customer Role 5: ONLY claims belonging to this customer
                String custClaimSql = "SELECT claim_id, status, claimed_amount, approved_amount " +
                                      "FROM CLAIMS WHERE customer_id = ? AND status IN ('Submitted', 'Under Review', 'Approved') " +
                                      "ORDER BY claim_id DESC LIMIT 5";
                try (PreparedStatement ps = conn.prepareStatement(custClaimSql)) {
                    ps.setInt(1, customerId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int claimId = rs.getInt("claim_id");
                            String status = rs.getString("status");
                            double claimed = rs.getDouble("claimed_amount");
                            double approved = rs.getDouble("approved_amount");

                            String title = "Claim #" + claimId + " Status: " + status;
                            String message;
                            String type = "info";
                            if ("Approved".equalsIgnoreCase(status)) {
                                message = "Your claim #" + claimId + " has been approved for $" + String.format("%,.0f", approved) + ". Payment is being processed.";
                                type = "success";
                            } else {
                                message = "Your claim #" + claimId + " for $" + String.format("%,.0f", claimed) + " is under active review.";
                            }

                            int notifId = 300000 + claimId;
                            if (!isDismissed(userId, notifId)) {
                                list.add(new Notification(
                                    notifId, userId, title, message,
                                    "/claims?action=view&claimId=" + claimId, type, "ti ti-shield-check", "Claims", status,
                                    new Timestamp(System.currentTimeMillis())
                                ));
                            }
                        }
                    }
                } catch (Exception ignored) {}
            }

            // ══════════════════════════════════════════════════════════════════
            // 4. CLAIM STATUS HISTORY (Strictly Scoped by Customer & Tenant)
            // ══════════════════════════════════════════════════════════════════
            try {
                StringBuilder histSql = new StringBuilder();
                histSql.append("SELECT h.history_id, h.claim_id, h.old_status, h.new_status, h.changed_at ")
                       .append("FROM CLAIM_STATUS_HISTORY h ")
                       .append("JOIN CLAIMS c ON h.claim_id = c.claim_id ")
                       .append("JOIN SHIPMENT s ON c.shipment_id = s.shipment_id ")
                       .append("JOIN CONTAINERS cnt ON s.container_id = cnt.container_id ");

                if (roleId == 5 && customerId != null) {
                    histSql.append("WHERE c.customer_id = ? ");
                } else if ((roleId == 2 || roleId == 3 || roleId == 4) && companyId != null) {
                    histSql.append("WHERE (cnt.owner_company_id = ? OR s.created_by IN (SELECT user_id FROM USERS WHERE company_id = ?)) ");
                }

                histSql.append("ORDER BY h.changed_at DESC LIMIT 5");

                try (PreparedStatement ps = conn.prepareStatement(histSql.toString())) {
                    if (roleId == 5 && customerId != null) {
                        ps.setInt(1, customerId);
                    } else if ((roleId == 2 || roleId == 3 || roleId == 4) && companyId != null) {
                        ps.setInt(1, companyId);
                        ps.setInt(2, companyId);
                    }
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int histId = rs.getInt("history_id");
                            int claimId = rs.getInt("claim_id");
                            String newStatus = rs.getString("new_status");
                            String oldStatus = rs.getString("old_status");
                            Timestamp ts = rs.getTimestamp("changed_at");

                            int notifId = 400000 + histId;
                            if (!isDismissed(userId, notifId)) {
                                list.add(new Notification(
                                    notifId, userId, "Claim #" + claimId + " Status Update",
                                    "Status updated from " + (oldStatus != null ? oldStatus : "Pending") + " to " + newStatus,
                                    "/claims?action=view&claimId=" + claimId, "info", "ti ti-refresh", "Claims", "Updated", ts
                                ));
                            }
                        }
                    }
                }
            } catch (Exception ignored) {}

            // ══════════════════════════════════════════════════════════════════
            // 5. CUSTOMER LIVE SHIPMENT MILESTONES (Customer Role 5 only)
            // ══════════════════════════════════════════════════════════════════
            if (roleId == 5 && customerId != null) {
                try {
                    String shpSql = "SELECT s.shipment_id, s.tracking_number, s.status, s.cargo_type, s.created_at " +
                                    "FROM SHIPMENT s " +
                                    "WHERE s.customer_id = ? AND s.status IN ('In-Transit', 'At Port', 'Out for Delivery', 'Delivered') " +
                                    "ORDER BY s.shipment_id DESC LIMIT 5";
                    try (PreparedStatement ps = conn.prepareStatement(shpSql)) {
                        ps.setInt(1, customerId);
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                int shpId = rs.getInt("shipment_id");
                                String trk = rs.getString("tracking_number");
                                String st = rs.getString("status");
                                String cargo = rs.getString("cargo_type");
                                Timestamp ts = rs.getTimestamp("created_at");

                                String title;
                                String type;
                                String icon;
                                if ("Delivered".equalsIgnoreCase(st)) {
                                    title = "Shipment #" + shpId + " Delivered";
                                    type = "success";
                                    icon = "ti ti-circle-check";
                                } else if ("In-Transit".equalsIgnoreCase(st)) {
                                    title = "Shipment #" + shpId + " In-Transit";
                                    type = "info";
                                    icon = "ti ti-truck-delivery";
                                } else {
                                    title = "Shipment #" + shpId + " Status: " + st;
                                    type = "info";
                                    icon = "ti ti-navigation";
                                }

                                String msg = "Your shipment " + (trk != null ? "(" + trk + ") " : "") +
                                             (cargo != null ? "containing " + cargo + " " : "") +
                                             "is currently " + st + ".";

                                int notifId = 500000 + shpId;
                                if (!isDismissed(userId, notifId)) {
                                    list.add(new Notification(
                                        notifId, userId, title, msg,
                                        "/track", type, icon, "Shipments", st, ts
                                    ));
                                }
                            }
                        }
                    }
                } catch (Exception ignored) {}
            }

            // ══════════════════════════════════════════════════════════════════
            // 6. SUPER ADMIN REAL APPROVAL RADAR (Role 1 only)
            // ══════════════════════════════════════════════════════════════════
            if (roleId == 1) {
                try {
                    // Pending Customer Approvals / KYC
                    String pendCustSql = "SELECT u.user_id, u.username, c.customer_name " +
                                         "FROM USERS u LEFT JOIN CUSTOMERS c ON c.user_id = u.user_id " +
                                         "WHERE u.role_id = 5 AND u.status IN ('Pending', 'Pending Approval') " +
                                         "ORDER BY u.created_at DESC LIMIT 5";
                    try (PreparedStatement ps = conn.prepareStatement(pendCustSql);
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int pendingUid = rs.getInt("user_id");
                            String uname = rs.getString("username");
                            String cname = rs.getString("customer_name");

                            int notifId = 600000 + pendingUid;
                            if (!isDismissed(userId, notifId)) {
                                list.add(new Notification(
                                    notifId, userId, "Customer KYC Review: " + uname,
                                    "Customer " + (cname != null ? "(" + cname + ") " : "") + "registered and uploaded KYC documents requiring verification.",
                                    "/admin/customers", "warning", "ti ti-user-check", "Approvals", "Pending",
                                    new Timestamp(System.currentTimeMillis())
                                ));
                            }
                        }
                    }

                    // Pending Company Approvals
                    String pendCmpSql = "SELECT u.user_id, u.username, cmp.company_name " +
                                        "FROM USERS u JOIN COMPANIES cmp ON cmp.user_id = u.user_id " +
                                        "WHERE u.status IN ('Pending', 'Pending Approval') " +
                                        "ORDER BY u.created_at DESC LIMIT 5";
                    try (PreparedStatement ps = conn.prepareStatement(pendCmpSql);
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int pendingUid = rs.getInt("user_id");
                            String cmpName = rs.getString("company_name");

                            int notifId = 650000 + pendingUid;
                            if (!isDismissed(userId, notifId)) {
                                list.add(new Notification(
                                    notifId, userId, "Carrier Approval: " + cmpName,
                                    "New logistics company registered and awaiting operator vetting.",
                                    "/admin/company", "warning", "ti ti-building", "Approvals", "Pending",
                                    new Timestamp(System.currentTimeMillis())
                                ));
                            }
                        }
                    }
                } catch (Exception ignored) {}
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void markAsRead(int userId, int notifId) {
        dismissedByUser.computeIfAbsent(userId, k -> ConcurrentHashMap.newKeySet()).add(notifId);
        saveDismissedToFile();
    }

    public void markAsRead(int notifId) {
        for (Set<Integer> set : dismissedByUser.values()) {
            set.add(notifId);
        }
        saveDismissedToFile();
    }

    public void markAllAsReadForUser(int userId) {
        List<Notification> current = getUnreadNotificationsForUser(userId);
        Set<Integer> set = dismissedByUser.computeIfAbsent(userId, k -> ConcurrentHashMap.newKeySet());
        for (Notification n : current) {
            set.add(n.getNotifId());
        }
        saveDismissedToFile();
    }

    public boolean isDismissed(int userId, int notifId) {
        Set<Integer> set = dismissedByUser.get(userId);
        return set != null && set.contains(notifId);
    }
}
