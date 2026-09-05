package com.nlogistic.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import com.nlogistic.model.User;

/**
 * Reads the caller's RBAC identity out of the HttpSession.
 *
 * Every controller that returns tenant- or customer-owned rows must scope its
 * query through these values (CLAUDE.md S6.2.2). The ids are established once,
 * at login, by LoginServlet.
 *
 * Role IDs: 1=Super Admin, 2=Company Admin, 3=Ops, 4=Finance, 5=Customer.
 */
public final class RbacContext {

    public static final int SUPER_ADMIN   = 1;
    public static final int COMPANY_ADMIN = 2;
    public static final int OPERATIONS    = 3;
    public static final int FINANCE       = 4;
    public static final int CUSTOMER      = 5;

    private RbacContext() {}

    public static User user(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : (User) session.getAttribute("user");
    }

    /** Returns the caller's role, or -1 when there is no authenticated session. */
    public static int roleId(HttpServletRequest request) {
        User u = user(request);
        return u == null ? -1 : u.getRoleId();
    }

    /** Owning company for Roles 2-4; null for Super Admin and Customers. */
    public static Integer companyId(HttpServletRequest request) {
        User u = user(request);
        if (u == null) return null;
        HttpSession session = request.getSession(false);
        Object attr = session == null ? null : session.getAttribute("companyId");
        if (attr instanceof Integer) return (Integer) attr;
        return u.getCompanyId();
    }

    /**
     * customers.customer_id for Role 5. Falls back to a live lookup when the
     * session predates the login change, so existing sessions still scope correctly.
     */
    public static Integer customerId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        Object attr = session.getAttribute("customerId");
        if (attr instanceof Integer) return (Integer) attr;

        User u = user(request);
        if (u != null && u.getRoleId() == CUSTOMER) {
            com.nlogistic.model.Customer c =
                    new com.nlogistic.dao.CustomerDAO().getCustomerByUserId(u.getUserId());
            if (c != null) {
                session.setAttribute("customerId", c.getCustomerId());
                session.setAttribute("customerName", c.getCustomerName());
                return c.getCustomerId();
            }
        }
        return null;
    }

    public static boolean isCustomer(HttpServletRequest request) {
        return roleId(request) == CUSTOMER;
    }

    public static boolean isSuperAdmin(HttpServletRequest request) {
        return roleId(request) == SUPER_ADMIN;
    }

    /** True for roles that may see cost structure and margins (CLAUDE.md S3.5.6). */
    public static boolean canSeeFinancials(HttpServletRequest request) {
        int r = roleId(request);
        return r == SUPER_ADMIN || r == COMPANY_ADMIN || r == FINANCE;
    }
}
