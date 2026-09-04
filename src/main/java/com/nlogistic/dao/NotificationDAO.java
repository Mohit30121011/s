package com.nlogistic.dao;

import com.nlogistic.model.Notification;
import com.nlogistic.util.DBConnectionManager;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Reads "notifications" for the bell dropdown by deriving them on the fly from
 * CLAIM_STATUS_HISTORY (no new SYSTEM_NOTIFICATIONS table exists, and creating one is
 * out of scope for this change). "Unread" is approximated as "history rows newer than
 * the user's last login" using the existing USERS.last_login_at column - there is no
 * persisted read/unread flag, so markAsRead/markAllAsReadForUser are no-ops that simply
 * let the next login naturally clear the bell.
 *
 * Every query here is wrapped defensively: if CLAIM_STATUS_HISTORY is empty (a known
 * seeding gap) or any SQL error occurs, this returns an empty list rather than throwing,
 * so the notification bell never breaks page rendering.
 */
public class NotificationDAO {

    public List<Notification> getUnreadNotificationsForUser(int userId) {
        List<Notification> list = new ArrayList<>();
        try (Connection conn = DBConnectionManager.getConnection()) {
            int roleId = -1;
            Timestamp lastLogin = null;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT role_id, last_login_at FROM USERS WHERE user_id = ?")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        roleId = rs.getInt("role_id");
                        lastLogin = rs.getTimestamp("last_login_at");
                    }
                }
            }
            if (roleId <= 0) return list;
            // If the user has never logged in before (no timestamp), don't flood them with all history.
            if (lastLogin == null) return list;

            String sql;
            boolean isCustomer = (roleId == 5);
            if (isCustomer) {
                sql = "SELECT h.history_id, h.claim_id, h.old_status, h.new_status, h.remark, h.changed_at " +
                      "FROM CLAIM_STATUS_HISTORY h " +
                      "JOIN CLAIMS c ON h.claim_id = c.claim_id " +
                      "JOIN CUSTOMERS cu ON c.customer_id = cu.customer_id " +
                      "WHERE cu.user_id = ? AND h.changed_at > ? " +
                      "ORDER BY h.changed_at DESC LIMIT 10";
            } else if (roleId == 3) {
                // Ops staff: notified of claims that moved into Under Review
                sql = "SELECT h.history_id, h.claim_id, h.old_status, h.new_status, h.remark, h.changed_at " +
                      "FROM CLAIM_STATUS_HISTORY h " +
                      "WHERE h.new_status = 'Under Review' AND h.changed_at > ? " +
                      "ORDER BY h.changed_at DESC LIMIT 10";
            } else if (roleId == 4) {
                // Finance staff: notified of claims that moved into Approved
                sql = "SELECT h.history_id, h.claim_id, h.old_status, h.new_status, h.remark, h.changed_at " +
                      "FROM CLAIM_STATUS_HISTORY h " +
                      "WHERE h.new_status = 'Approved' AND h.changed_at > ? " +
                      "ORDER BY h.changed_at DESC LIMIT 10";
            } else {
                // Super Admin / Company Admin: see all recent status changes
                sql = "SELECT h.history_id, h.claim_id, h.old_status, h.new_status, h.remark, h.changed_at " +
                      "FROM CLAIM_STATUS_HISTORY h " +
                      "WHERE h.changed_at > ? " +
                      "ORDER BY h.changed_at DESC LIMIT 10";
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                if (isCustomer) {
                    ps.setInt(1, userId);
                    ps.setTimestamp(2, lastLogin);
                } else {
                    ps.setTimestamp(1, lastLogin);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int claimId = rs.getInt("claim_id");
                        String newStatus = rs.getString("new_status");
                        String oldStatus = rs.getString("old_status");

                        Notification n = new Notification();
                        n.setNotifId(rs.getInt("history_id"));
                        n.setUserId(userId);
                        n.setTitle("Claim #" + claimId + " - " + newStatus);
                        n.setMessage(oldStatus != null
                                ? ("Status changed from " + oldStatus + " to " + newStatus)
                                : ("Status set to " + newStatus));
                        n.setLink("/claims?action=view&claimId=" + claimId);
                        n.setRead(false);
                        n.setCreatedAt(rs.getTimestamp("changed_at"));
                        list.add(n);
                    }
                }
            }
        } catch (Exception e) {
            // Defensive: CLAIM_STATUS_HISTORY may be empty or a column may be unavailable.
            // Never let a notification lookup break page rendering - just show zero notifications.
            e.printStackTrace();
        }
        return list;
    }

    /** No persisted read/unread flag exists; the bell naturally clears on next login. No-op kept for API compatibility. */
    public void markAsRead(int notifId) {
        // Intentional no-op: no SYSTEM_NOTIFICATIONS table / is_read column exists.
    }

    /** No persisted read/unread flag exists; the bell naturally clears on next login. No-op kept for API compatibility. */
    public void markAllAsReadForUser(int userId) {
        // Intentional no-op: no SYSTEM_NOTIFICATIONS table / is_read column exists.
    }
}
