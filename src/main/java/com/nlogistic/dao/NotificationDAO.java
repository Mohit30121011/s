package com.nlogistic.dao;

import com.nlogistic.model.Notification;
import com.nlogistic.util.DBConnectionManager;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    public List<Notification> getUnreadNotificationsForUser(int userId) {
        List<Notification> list = new ArrayList<>();
        try (Connection conn = DBConnectionManager.getConnection()) {
            int roleId = -1;
            Integer companyId = null;
            Integer customerId = null;

            String userSql = "SELECT u.role_id, u.company_id, c.customer_id " +
                             "FROM USERS u LEFT JOIN CUSTOMERS c ON c.user_id = u.user_id " +
                             "WHERE u.user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(userSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        roleId = rs.getInt("role_id");
                        companyId = (Integer) rs.getObject("company_id");
                        customerId = (Integer) rs.getObject("customer_id");
                    }
                }
            }
            if (roleId <= 0) return list;

            int notifSequence = 1;

            // 1. COMPLIANCE EXPIRY ALERTS (Roles 1, 2, 3 - Operations & Admin)
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
                            int shipmentId = rs.getInt("shipment_id");
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
                                          ". Shipments cannot depart on expired paperwork.";
                                type = "warning";
                                icon = "ti ti-alert-triangle";
                                timeAgo = (daysLeft == 0 ? "Expires Today" : "Expires in " + daysLeft + "d");
                            }

                            int notifId = 100000 + docId;
                            if (!isDismissed(userId, notifId)) {
                                Notification n = new Notification(
                                    notifId, userId, title, message,
                                    "/compliance", type, icon, "Compliance", timeAgo,
                                    new Timestamp(System.currentTimeMillis())
                                );
                                list.add(n);
                            }
                        }
                    }
                } catch (Exception e) {
                    // Fail gracefully
                }
            }

            // 2. OVERDUE INVOICES (Roles 1, 2, 4, 5 - Finance, Admin, Customer)
            if (roleId == 1 || roleId == 2 || roleId == 4 || roleId == 5) {
                StringBuilder invSql = new StringBuilder();
                invSql.append("SELECT bi.invoice_id, bi.total_amount, bi.paid_amount, bi.due_date, ")
                      .append("DATEDIFF(CURRENT_DATE(), bi.due_date) AS days_overdue ")
                      .append("FROM BILLING_INVOICES bi ")
                      .append("JOIN SHIPMENT s ON bi.shipment_id = s.shipment_id ")
                      .append("JOIN CONTAINERS cnt ON s.container_id = cnt.container_id ")
                      .append("WHERE bi.payment_status != 'Paid' AND bi.due_date < CURRENT_DATE() ");

                if (roleId == 5 && customerId != null) {
                    invSql.append("  AND bi.customer_id = ? ");
                } else if ((roleId == 2 || roleId == 4) && companyId != null) {
                    invSql.append("  AND (cnt.owner_company_id = ? OR s.created_by IN (SELECT user_id FROM USERS WHERE company_id = ?)) ");
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

                            String title = (roleId == 5 ? "Payment Overdue: Invoice #" : "Overdue Invoice #") + invId;
                            String message = "Unpaid balance of $" + String.format("%,.0f", bal) + " was due on " + due + ".";
                            String link = (roleId == 5 ? "/invoices" : "/billing");

                            int notifId = 200000 + invId;
                            if (!isDismissed(userId, notifId)) {
                                Notification n = new Notification(
                                    notifId, userId, title, message,
                                    link, "danger", "ti ti-receipt-tax", "Billing",
                                    daysOverdue + "d overdue",
                                    new Timestamp(System.currentTimeMillis())
                                );
                                list.add(n);
                            }
                        }
                    }
                } catch (Exception e) {
                    // Fail gracefully
                }
            }

            // 3. CLAIMS ACTION ALERTS (Roles 1, 2, 3, 4, 5)
            if (roleId <= 4) {
                StringBuilder claimSql = new StringBuilder();
                claimSql.append("SELECT c.claim_id, c.shipment_id, c.status, c.claimed_amount, c.approved_amount, c.claim_type ")
                        .append("FROM CLAIMS c ")
                        .append("JOIN SHIPMENT s ON c.shipment_id = s.shipment_id ")
                        .append("JOIN CONTAINERS cnt ON s.container_id = cnt.container_id ")
                        .append("WHERE ");

                if (roleId == 3) {
                    // Ops: claims under review or newly submitted
                    claimSql.append("c.status IN ('Under Review', 'Submitted') ");
                } else if (roleId == 4) {
                    // Finance: approved claims awaiting settlement payout
                    claimSql.append("c.status = 'Approved' ");
                } else {
                    // Admin: all active claims
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
                                Notification n = new Notification(
                                    notifId, userId, title, message,
                                    "/claims?action=view&claimId=" + claimId, type, icon, "Claims", timeAgo,
                                    new Timestamp(System.currentTimeMillis())
                                );
                                list.add(n);
                            }
                        }
                    }
                } catch (Exception e) {
                    // Fail gracefully
                }
            } else if (roleId == 5 && customerId != null) {
                // Customer: their own claims
                String custClaimSql = "SELECT claim_id, status, claimed_amount, approved_amount " +
                                      "FROM CLAIMS WHERE customer_id = ? ORDER BY claim_id DESC LIMIT 5";
                try (PreparedStatement ps = conn.prepareStatement(custClaimSql)) {
                    ps.setInt(1, customerId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int claimId = rs.getInt("claim_id");
                            String status = rs.getString("status");
                            double claimed = rs.getDouble("claimed_amount");

                            int notifId = 300000 + claimId;
                            if (!isDismissed(userId, notifId)) {
                                Notification n = new Notification(
                                    notifId, userId, "Claim #" + claimId + " - " + status,
                                    "Your claim for $" + String.format("%,.0f", claimed) + " is currently " + status + ".",
                                    "/claims?action=view&claimId=" + claimId, "info", "ti ti-shield-check", "Claims", status,
                                    new Timestamp(System.currentTimeMillis())
                                );
                                list.add(n);
                            }
                        }
                    }
                } catch (Exception e) {
                    // Fail gracefully
                }
            }

            // 4. CLAIM STATUS HISTORY (Recent status changes)
            try {
                String histSql = "SELECT h.history_id, h.claim_id, h.old_status, h.new_status, h.changed_at " +
                                 "FROM CLAIM_STATUS_HISTORY h ORDER BY h.changed_at DESC LIMIT 3";
                try (PreparedStatement ps = conn.prepareStatement(histSql);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int histId = rs.getInt("history_id");
                        int claimId = rs.getInt("claim_id");
                        String newStatus = rs.getString("new_status");
                        String oldStatus = rs.getString("old_status");
                        Timestamp ts = rs.getTimestamp("changed_at");

                        int notifId = 400000 + histId;
                        if (!isDismissed(userId, notifId)) {
                            Notification n = new Notification(
                                notifId, userId, "Claim #" + claimId + " Status Update",
                                "Status updated from " + (oldStatus != null ? oldStatus : "Pending") + " to " + newStatus,
                                "/claims?action=view&claimId=" + claimId, "info", "ti ti-refresh", "Claims", "Updated", ts
                            );
                            list.add(n);
                        }
                    }
                }
            } catch (Exception ignored) {}

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // In-memory set of dismissed notification IDs per user (Zero new database tables)
    private static final java.util.concurrent.ConcurrentHashMap<Integer, java.util.Set<Integer>> dismissedByUser = new java.util.concurrent.ConcurrentHashMap<>();

    public void markAsRead(int userId, int notifId) {
        dismissedByUser.computeIfAbsent(userId, k -> java.util.concurrent.ConcurrentHashMap.newKeySet()).add(notifId);
    }

    public void markAsRead(int notifId) {
        for (java.util.Set<Integer> set : dismissedByUser.values()) {
            set.add(notifId);
        }
    }

    public void markAllAsReadForUser(int userId) {
        List<Notification> current = getUnreadNotificationsForUser(userId);
        java.util.Set<Integer> set = dismissedByUser.computeIfAbsent(userId, k -> java.util.concurrent.ConcurrentHashMap.newKeySet());
        for (Notification n : current) {
            set.add(n.getNotifId());
        }
    }

    public boolean isDismissed(int userId, int notifId) {
        java.util.Set<Integer> set = dismissedByUser.get(userId);
        return set != null && set.contains(notifId);
    }
}
