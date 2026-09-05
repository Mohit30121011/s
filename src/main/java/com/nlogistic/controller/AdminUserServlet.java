package com.nlogistic.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.dao.UserDAO;
import com.nlogistic.model.User;

@WebServlet({"/admin/users", "/admin/customers"})
public class AdminUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO = new UserDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Contract Precondition: Verify caller role/permission
        Integer roleId = (Integer) request.getSession().getAttribute("roleId");
        com.nlogistic.model.User caller = (com.nlogistic.model.User) request.getSession().getAttribute("user");
        boolean customerQueueView = request.getServletPath().endsWith("/customers");

        // Staff governance is open to Company Admins; the customer approval queue is not.
        boolean permitted = (roleId != null)
                && (roleId == 1 || (roleId == 2 && !customerQueueView));
        if (!permitted) {
            if (caller != null) {
                userDAO.logAuditEvent(caller.getUserId(), "PERMISSION_DENIED_CONTRACT", request.getRequestURI(), request.getRemoteAddr());
            }
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: administrative role required.");
            return;
        }

        List<User> pendingUsers = userDAO.getPendingUsers();
        List<User> allUsers = userDAO.getAllUsers();

        // Tenant isolation: a Company Admin governs only their own company's staff.
        if (roleId == 2 && caller != null) {
            final int myCompany = caller.getCompanyId();
            if (allUsers != null) allUsers.removeIf(u -> u.getCompanyId() != myCompany);
            if (pendingUsers != null) pendingUsers.removeIf(u -> u.getCompanyId() != myCompany);
        }
        com.nlogistic.dao.CompanyDAO cDao = new com.nlogistic.dao.CompanyDAO();
        List<com.nlogistic.model.Company> allComps = cDao.getAllCompanies();

        java.util.Map<Integer, String> companyNameMap = new java.util.HashMap<>();
        if (allComps != null) {
            for (com.nlogistic.model.Company cp : allComps) {
                companyNameMap.put(cp.getCompanyId(), cp.getCompanyName());
            }
        }

        int pendingCount = 0;
        int activeCount = 0;
        int inactiveCount = 0;
        int totalCount = (allUsers != null) ? allUsers.size() : 0;

        if (allUsers != null) {
            for (User u : allUsers) {
                if ("Pending".equalsIgnoreCase(u.getStatus())) {
                    pendingCount++;
                } else if ("Active".equalsIgnoreCase(u.getStatus())) {
                    activeCount++;
                } else {
                    inactiveCount++;
                }
            }
        }

        // Attributes the users.jsp view needs. These were previously assembled by a
        // 140-line scriptlet inside the view itself (SRS 10.2 forbids scriptlets).
        Integer scopeCompany = (roleId == 2 && caller != null) ? caller.getCompanyId() : null;
        java.util.List<java.util.Map<String, Object>> staffList = userDAO.getStaffDirectory(scopeCompany);

        java.util.Set<String> allDeptNames = new java.util.TreeSet<>();
        for (java.util.Map<String, Object> m : staffList) {
            Object d = m.get("dept");
            if (d != null) allDeptNames.add(String.valueOf(d));
        }

        // Per-user activity feed, emitted as JSON for the profile drawer.
        java.util.Map<Integer, java.util.List<java.util.Map<String, String>>> auditMap =
                userDAO.getUserAuditEvents(10);
        StringBuilder auditJson = new StringBuilder("{");
        boolean firstUser = true;
        for (java.util.Map.Entry<Integer, java.util.List<java.util.Map<String, String>>> e : auditMap.entrySet()) {
            if (!firstUser) auditJson.append(",");
            firstUser = false;
            auditJson.append("\"").append(e.getKey()).append("\":[");
            boolean firstEvent = true;
            for (java.util.Map<String, String> ev : e.getValue()) {
                if (!firstEvent) auditJson.append(",");
                firstEvent = false;
                auditJson.append("{\"action\":\"").append(jsonEscape(ev.get("action")))
                         .append("\",\"entity\":\"").append(jsonEscape(ev.get("entity")))
                         .append("\",\"ip\":\"").append(jsonEscape(ev.get("ip")))
                         .append("\",\"time\":\"").append(jsonEscape(ev.get("time"))).append("\"}");
            }
            auditJson.append("]");
        }
        auditJson.append("}");

        java.util.List<com.nlogistic.model.Company> companyOptions = cDao.getAllCompanies();
        if (roleId == 2 && caller != null && companyOptions != null) {
            final int myCo = caller.getCompanyId();
            companyOptions.removeIf(cp -> cp.getCompanyId() != myCo);
        }

        request.setAttribute("staffList", staffList);
        request.setAttribute("allDeptNames", allDeptNames);
        request.setAttribute("userAuditJson", auditJson.toString());
        request.setAttribute("allCompanies", companyOptions);
        request.setAttribute("allUsers", allUsers);
        request.setAttribute("pendingUsers", pendingUsers);
        request.setAttribute("companyNameMap", companyNameMap);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("activeCount", activeCount);
        request.setAttribute("inactiveCount", inactiveCount);
        request.setAttribute("totalCount", totalCount);

        // Both approval queues are served from here; the path picks the view.
        boolean customerQueue = request.getServletPath().endsWith("/customers");
        request.getRequestDispatcher(customerQueue ? "/jsp/admin/customers.jsp" : "/jsp/admin/users.jsp")
               .forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Contract Precondition: Verify caller role/permission
        Integer roleId = (Integer) request.getSession().getAttribute("roleId");
        if (roleId == null || roleId > 2) {
            com.nlogistic.model.User user = (com.nlogistic.model.User) request.getSession().getAttribute("user");
            if(user != null) {
                userDAO.logAuditEvent(user.getUserId(), "PERMISSION_DENIED_CONTRACT", request.getRequestURI(), request.getRemoteAddr());
            }
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: administrative role required.");
            return;
        }

        com.nlogistic.model.User admin = (com.nlogistic.model.User) request.getSession().getAttribute("user");
        int adminUserId = admin.getUserId();

        String action = request.getParameter("action");
        String userIdStr = request.getParameter("userId");

        // Creating a staff account carries no userId, so handle it first.
        if ("addStaff".equals(action) || "inviteStaff".equals(action)) {
            String uName = firstNonBlank(request.getParameter("staffUsername"), request.getParameter("inviteName"));
            String uEmail = firstNonBlank(request.getParameter("staffEmail"), request.getParameter("inviteEmail"));
            String uPass = firstNonBlank(request.getParameter("staffPassword"), "Staff@12345");
            String uPhone = firstNonBlank(request.getParameter("staffPhone"), request.getParameter("invitePhone"), "");
            String uRoleStr = firstNonBlank(request.getParameter("staffRoleId"), request.getParameter("inviteRoleId"), "3");
            String uStatus = firstNonBlank(request.getParameter("staffStatus"), "Active");

            if (uName == null || uEmail == null) {
                request.getSession().setAttribute("errorMessage", "Name and email are required to create a staff account.");
            } else {
                int rId = 3;
                try { rId = Integer.parseInt(uRoleStr.trim()); } catch (NumberFormatException ignored) {}
                Integer compId = null;
                String compIdStr = request.getParameter("staffCompanyId");
                if (compIdStr != null && !compIdStr.trim().isEmpty()) {
                    try { compId = Integer.parseInt(compIdStr.trim()); } catch (NumberFormatException ignored) {}
                }
                // A Company Admin only ever creates staff inside their own company,
                // and may not mint another admin-level account.
                if (roleId == 2) {
                    compId = admin.getCompanyId();
                    if (rId < 3) rId = 3;
                }
                int newUserId = userDAO.createUser(uName.trim(), uEmail.trim(), uPass.trim(),
                        uPhone.trim(), rId, compId, uStatus.trim());
                if (newUserId > 0) {
                    userDAO.logAuditEvent(newUserId, "USER_REGISTERED", uName.trim(), request.getRemoteAddr());
                    request.getSession().setAttribute("successMessage",
                            "Staff account #USR-" + newUserId + " (" + uName.trim() + ") created.");
                } else {
                    request.getSession().setAttribute("errorMessage",
                            "Could not create the account - the username or email may already exist.");
                }
            }
            response.sendRedirect(request.getContextPath() + request.getServletPath());
            return;
        }

        if (action == null || userIdStr == null || userIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }
        int userId = Integer.parseInt(userIdStr.trim());

        // A Company Admin may only act on their own staff, and may never delete users.
        if (roleId == 2) {
            com.nlogistic.model.User target = userDAO.getUserById(userId);
            if (target == null || target.getCompanyId() != admin.getCompanyId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Access Denied: that user does not belong to your company.");
                return;
            }
            if ("delete".equals(action) || "changeRole".equals(action)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Access Denied: only a Super Admin may delete users or change roles.");
                return;
            }
        }

        // FR1.8 / GAP-M1-03: the full user lifecycle. The stored procedures for
        // unlock, deactivate, role change and delete already existed in UserDAO
        // but no controller action ever invoked them, so a locked-out account
        // could never be released through the UI.
        if ("accept".equals(action) || "activate".equals(action) || "reactivate".equals(action)) {
            userDAO.approveUser(userId, adminUserId);
            request.getSession().setAttribute("successMessage", "User #" + userId + " approved and activated.");

        } else if ("reject".equals(action) || "suspend".equals(action)) {
            userDAO.deactivateUser(userId, adminUserId);
            request.getSession().setAttribute("successMessage", "User #" + userId + " has been suspended.");

        } else if ("unlock".equals(action)) {
            // FR1.8: release a brute-force lockout and reset the failed counter.
            userDAO.unlockUser(userId, adminUserId);
            request.getSession().setAttribute("successMessage",
                    "Account #" + userId + " unlocked. Failed login counter reset to 0.");

        } else if ("changeRole".equals(action)) {
            String newRoleStr = request.getParameter("roleId");
            if (newRoleStr != null && !newRoleStr.trim().isEmpty()) {
                userDAO.changeUserRole(userId, Integer.parseInt(newRoleStr.trim()), adminUserId);
                request.getSession().setAttribute("successMessage", "Role updated for user #" + userId + ".");
            } else {
                request.getSession().setAttribute("errorMessage", "No target role supplied.");
            }

        } else if ("delete".equals(action)) {
            userDAO.deleteUser(userId, adminUserId);
            request.getSession().setAttribute("successMessage", "User #" + userId + " deleted permanently.");

        } else if ("savePermissions".equals(action)) {
            String newRoleStr = request.getParameter("assignedRoleId");
            if (newRoleStr != null && !newRoleStr.trim().isEmpty()) {
                try {
                    userDAO.assignRole(userId, Integer.parseInt(newRoleStr.trim()));
                } catch (Exception ignored) {}
            }

            List<String> perms = new ArrayList<>();
            if ("on".equalsIgnoreCase(request.getParameter("perm_dashboard")) || "true".equalsIgnoreCase(request.getParameter("perm_dashboard"))) perms.add("dashboard");
            if ("on".equalsIgnoreCase(request.getParameter("perm_tracking")) || "true".equalsIgnoreCase(request.getParameter("perm_tracking"))) perms.add("tracking");
            if ("on".equalsIgnoreCase(request.getParameter("perm_shipments")) || "true".equalsIgnoreCase(request.getParameter("perm_shipments"))) perms.add("shipments");
            if ("on".equalsIgnoreCase(request.getParameter("perm_plg")) || "true".equalsIgnoreCase(request.getParameter("perm_plg"))) perms.add("plg");
            if ("on".equalsIgnoreCase(request.getParameter("perm_invoicing")) || "true".equalsIgnoreCase(request.getParameter("perm_invoicing"))) perms.add("invoicing");
            if ("on".equalsIgnoreCase(request.getParameter("perm_inventory")) || "true".equalsIgnoreCase(request.getParameter("perm_inventory"))) perms.add("inventory");
            if ("on".equalsIgnoreCase(request.getParameter("perm_claims")) || "true".equalsIgnoreCase(request.getParameter("perm_claims"))) perms.add("claims");
            if ("on".equalsIgnoreCase(request.getParameter("perm_compliance")) || "true".equalsIgnoreCase(request.getParameter("perm_compliance"))) perms.add("compliance");
            if ("on".equalsIgnoreCase(request.getParameter("perm_users")) || "true".equalsIgnoreCase(request.getParameter("perm_users"))) perms.add("users");
            if ("on".equalsIgnoreCase(request.getParameter("perm_settings")) || "true".equalsIgnoreCase(request.getParameter("perm_settings"))) perms.add("settings");

            String permsCsv = String.join(",", perms);
            boolean ok = userDAO.updateUserPermissions(userId, permsCsv, adminUserId);

            // If updating currently logged in user's own permissions, refresh session user immediately
            if (admin.getUserId() == userId) {
                admin.setModulePermissions(permsCsv);
                request.getSession().setAttribute("user", admin);
                request.getSession().setAttribute("userPermissions", admin.getPermissionsMap());
            }

            if ("XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":" + ok + ",\"permissions\":\"" + permsCsv + "\"}");
                return;
            }

            if (ok) {
                request.getSession().setAttribute("successMessage",
                        "Module permissions updated for staff #USR-" + userId + ".");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to update permissions.");
            }
            response.sendRedirect(request.getContextPath() + request.getServletPath() + "?selectedUserId=" + userId);
            return;

        } else if ("updateStaffProfile".equals(action)) {
            String uName = request.getParameter("staffUsername");
            String uEmail = request.getParameter("staffEmail");
            if (uName == null || uEmail == null || uName.trim().isEmpty() || uEmail.trim().isEmpty()) {
                request.getSession().setAttribute("errorMessage", "Username and email are required.");
            } else {
                String uPhone = request.getParameter("staffPhone");
                String uStatus = request.getParameter("staffStatus");
                String uRoleStr = request.getParameter("staffRoleId");
                String compIdStr = request.getParameter("staffCompanyId");
                int rId = 3;
                if (uRoleStr != null && !uRoleStr.trim().isEmpty()) {
                    try { rId = Integer.parseInt(uRoleStr.trim()); } catch (NumberFormatException ignored) {}
                }
                Integer compId = null;
                if (compIdStr != null && !compIdStr.trim().isEmpty()) {
                    try { compId = Integer.parseInt(compIdStr.trim()); } catch (NumberFormatException ignored) {}
                }
                // A Company Admin can never move a user into another tenant.
                if (roleId == 2) compId = admin.getCompanyId();

                boolean ok = userDAO.updateUserProfile(userId, uName.trim(), uEmail.trim(),
                        (uPhone != null ? uPhone.trim() : ""), rId, compId,
                        (uStatus != null && !uStatus.trim().isEmpty()) ? uStatus.trim() : "Active");
                if (ok) {
                    userDAO.logAuditEvent(userId, "USER_PROFILE_UPDATED", uName.trim(), request.getRemoteAddr());
                    request.getSession().setAttribute("successMessage",
                            "Staff profile for " + uName.trim() + " (#USR-" + userId + ") updated.");
                } else {
                    request.getSession().setAttribute("errorMessage", "Could not update that staff profile.");
                }
            }

        } else if ("sendResetPassword".equals(action)) {
            com.nlogistic.model.User target = userDAO.getUserById(userId);
            if (target != null && target.getEmail() != null) {
                String token = userDAO.generatePasswordResetToken(target.getEmail());
                String resetLink = request.getScheme() + "://" + request.getServerName() + ":"
                        + request.getServerPort() + request.getContextPath() + "/reset-password?token=" + token;
                boolean sent = com.nlogistic.util.EmailService.sendPasswordResetEmail(
                        target.getEmail(), target.getUsername(), resetLink);
                request.getSession().setAttribute("successMessage", sent
                        ? "Password reset email sent to " + target.getEmail()
                        : "Reset token generated. Direct link: " + resetLink);
            } else {
                request.getSession().setAttribute("errorMessage", "User has no email on file.");
            }

        } else {
            request.getSession().setAttribute("errorMessage", "Unknown user management action: " + action);
        }
        
        response.sendRedirect(request.getContextPath() + request.getServletPath());
    }

    /** First non-blank value, or null when every candidate is blank. */
    private static String firstNonBlank(String... values) {
        for (String v : values) {
            if (v != null && !v.trim().isEmpty()) return v;
        }
        return null;
    }

    /** Minimal JSON string escaping for the activity feed. */
    private static String jsonEscape(String v) {
        if (v == null) return "";
        return v.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", " ").replace("\r", " ");
    }
}
