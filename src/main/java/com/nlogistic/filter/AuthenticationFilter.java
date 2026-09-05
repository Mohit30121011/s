package com.nlogistic.filter;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.nlogistic.model.User;

/**
 * FR1.4, FR1.5, FR1.7, FR1.9 - Central authentication and RBAC filter.
 *
 * This is Tier 2 of the three-tier access model described in CLAUDE.md S6:
 *   Tier 1 (Presentation) - header.jsp / view JSPs hide unauthorised UI.
 *   Tier 2 (this filter)  - blocks unauthorised URLs outright.
 *   Tier 3 (DAO)          - scopes every row by company_id / customer_id.
 *
 * Rules below implement the permission matrix in CLAUDE.md S4 exactly.
 * Role IDs: 1=Super Admin, 2=Company Admin, 3=Ops, 4=Finance, 5=Customer.
 */
@WebFilter("/*")
public class AuthenticationFilter implements Filter {

    private static final int SUPER_ADMIN  = 1;
    private static final int COMPANY_ADMIN = 2;
    private static final int OPERATIONS   = 3;
    private static final int FINANCE      = 4;
    private static final int CUSTOMER     = 5;

    public void init(FilterConfig fConfig) throws ServletException {}

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = uri.substring(contextPath.length());

        // FR1.5: login/register/static assets are reachable without a session.
        // /barcode-pdf is intentionally public: QR scans from phones must not require login.
        boolean isPublicPath = path.equals("/") || path.equals("/index.jsp")
                || path.startsWith("/login") || path.startsWith("/register")
                || path.startsWith("/forgot-password") || path.startsWith("/reset-password")
                || path.startsWith("/barcode-pdf")
                || path.contains("/assets/") || path.endsWith("login.jsp") || path.endsWith("register.jsp")
                || path.endsWith("forgot-password.jsp") || path.endsWith("reset-password.jsp");

        if (isPublicPath) {
            chain.doFilter(request, response);
            return;
        }

        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);
        if (!isLoggedIn) {
            res.sendRedirect(contextPath + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        int roleId = user.getRoleId();

        // MVC2: these views hold no logic of their own any more, so a direct hit
        // would render an empty page. Send it through the controller that scopes
        // the data instead.
        String controllerRoute = viewToController(path);
        if (controllerRoute != null) {
            String qs = req.getQueryString();
            res.sendRedirect(contextPath + controllerRoute + (qs != null && !qs.isEmpty() ? "?" + qs : ""));
            return;
        }

        boolean allowed = isAllowed(path, user);

        if (!allowed) {
            // FR1.9: every denied attempt is written to the audit trail.
            try {
                new com.nlogistic.dao.UserDAO()
                        .logAuditEvent(user.getUserId(), "PERMISSION_DENIED", path, req.getRemoteAddr());
            } catch (Exception ignored) { /* auditing must never break the response */ }

            session.setAttribute("errorMessage",
                    "Access Denied: You do not have permission to access this module.");
            res.sendRedirect(contextPath + "/dashboard");
            return;
        }

        chain.doFilter(request, response);
    }

    /**
     * Central authorization check: checks user module permissions for internal staff
     * and role baseline for customers.
     */
    private boolean isAllowed(String path, User user) {
        if (user == null) return false;
        int roleId = user.getRoleId();
        if (roleId == SUPER_ADMIN) return true;

        if (roleId == CUSTOMER) {
            return isRoleAllowed(path, roleId);
        }

        // Granular Module Permissions for Internal Staff
        if (path.startsWith("/admin/users") || path.startsWith("/admin/companies") || path.startsWith("/admin/customers")
                || path.startsWith("/admin/audit-logs") || path.endsWith("/jsp/admin/users.jsp") || path.endsWith("/jsp/admin/audit_logins.jsp")) {
            return user.hasPermission("users");
        }

        if (path.startsWith("/finance") || path.contains("/profit-loss") || path.endsWith("/profit_loss_analytics.jsp")
                || path.endsWith("/shipment_drilldown.jsp")) {
            return user.hasPermission("plg");
        }

        if (path.startsWith("/pricing") || path.startsWith("/predictive-graph") || path.endsWith("/pricing.jsp")
                || path.endsWith("/predictive-graph.jsp") || path.startsWith("/settings")) {
            return user.hasPermission("settings");
        }

        if (path.startsWith("/upload-stock") || path.startsWith("/stock") || path.startsWith("/manual-stock")
                || path.startsWith("/adjust-stock") || path.startsWith("/download-errors") || path.startsWith("/inventory")
                || path.startsWith("/ledger") || path.endsWith("/stock.jsp") || path.endsWith("/upload-stock.jsp")
                || path.endsWith("/ledger.jsp") || path.endsWith("/products.jsp")) {
            return user.hasPermission("inventory");
        }

        if (path.startsWith("/barcodes") || path.startsWith("/scan-barcode") || path.endsWith("/barcodes.jsp")
                || path.endsWith("/barcode-management.jsp") || path.endsWith("/scan-barcode.jsp")
                || path.startsWith("/containers") || path.endsWith("/containers.jsp") || path.startsWith("/vessel")
                || path.startsWith("/ports") || path.endsWith("/vessels.jsp") || path.endsWith("/ports.jsp")
                || path.contains("/tracking")) {
            return user.hasPermission("tracking");
        }

        if (path.startsWith("/shipments") || path.startsWith("/allocate") || path.endsWith("/create_shipment.jsp")
                || path.endsWith("/shipments.jsp") || path.endsWith("/allocate-container.jsp") || path.startsWith("/book")) {
            return user.hasPermission("shipments");
        }

        if (path.startsWith("/billing") || path.startsWith("/generate-invoice") || path.startsWith("/invoices")
                || path.startsWith("/record-payment") || path.startsWith("/payment") || path.startsWith("/view-invoice")
                || path.startsWith("/invoice-view") || path.endsWith("/billing.jsp") || path.endsWith("/invoices.jsp")) {
            return user.hasPermission("invoicing");
        }

        if (path.startsWith("/claims") || path.endsWith("/claims.jsp") || path.endsWith("/claim-details.jsp")) {
            return user.hasPermission("claims");
        }

        if (path.startsWith("/compliance") || path.endsWith("/compliance.jsp") || path.contains("/document")) {
            return user.hasPermission("compliance");
        }

        if (path.startsWith("/analytics") || path.startsWith("/dashboard/executive") || path.startsWith("/executive")
                || path.endsWith("/analytics.jsp") || path.endsWith("/executive_dashboard.jsp")) {
            return user.hasPermission("dashboard");
        }

        // Remaining system routes check role baseline table
        return isRoleAllowed(path, roleId);
    }

    /**
     * Path-to-role permission table. Ordered most-specific first, because
     * several prefixes overlap (e.g. /dashboard/executive before /dashboard).
     */
    private boolean isRoleAllowed(String path, int roleId) {

        // ---- 0. Direct .jsp view access ---------------------------------------
        // Several sidebar links target JSPs directly (e.g. /jsp/admin/users.jsp),
        // which would otherwise sidestep every servlet-path rule below. Sensitive
        // views are therefore matched on their file name as well as their route.
        if (path.startsWith("/admin/users") || path.startsWith("/admin/audit-logs")
                || path.endsWith("/jsp/admin/users.jsp") || path.endsWith("/jsp/admin/audit_logins.jsp")) {
            // Staff governance + audit trail: Super Admin globally, Company Admin
            // scoped to their own tenant (enforced inside the servlets).
            return roleId <= COMPANY_ADMIN;
        }
        if (path.startsWith("/jsp/admin")) {
            return roleId == SUPER_ADMIN;
        }
        if (path.endsWith("/executive_dashboard.jsp") || path.endsWith("/analytics.jsp")) {
            return roleId <= COMPANY_ADMIN;
        }
        if (path.endsWith("/profit_loss_analytics.jsp") || path.endsWith("/shipment_drilldown.jsp")) {
            return roleId == SUPER_ADMIN || roleId == COMPANY_ADMIN || roleId == FINANCE;
        }
        if (path.endsWith("/pricing.jsp") || path.endsWith("/predictive-graph.jsp")) {
            return roleId <= COMPANY_ADMIN || roleId == FINANCE;
        }
        if (path.endsWith("/stock.jsp") || path.endsWith("/upload-stock.jsp")
                || path.endsWith("/ledger.jsp") || path.endsWith("/barcodes.jsp")
                || path.endsWith("/barcode-management.jsp") || path.endsWith("/scan-barcode.jsp")) {
            return roleId <= OPERATIONS;
        }
        if (path.endsWith("/billing.jsp")) {
            return roleId <= COMPANY_ADMIN || roleId == FINANCE;
        }
        if (path.endsWith("/vessels.jsp") || path.endsWith("/ports.jsp")
                || path.endsWith("/customers.jsp")) {
            return roleId <= FINANCE;
        }

        // ---- 1. Governance & destructive operations: Super Admin only ----------
        // Company & customer approval queues stay Super-Admin exclusive.
        if (path.startsWith("/admin") || path.contains("/approve") || path.contains("/delete")) {
            return roleId == SUPER_ADMIN;
        }

        // ---- 2. Executive dashboard & the 5 analytical engines: Admins only ----
        // Matched before the generic /dashboard rule below.
        if (path.startsWith("/dashboard/executive") || path.startsWith("/executive")
                || path.startsWith("/analytics")) {
            return roleId <= COMPANY_ADMIN;
        }

        // ---- 3. Profit & Loss and Financial Drilldown: Admins + Finance --------
        // Confidential cost structure - strictly hidden from Ops and Customers.
        if (path.startsWith("/finance")) {
            return roleId == SUPER_ADMIN || roleId == COMPANY_ADMIN || roleId == FINANCE;
        }

        // ---- 4. Pricing engine & predictive graph: Admins + Finance (view) -----
        if (path.startsWith("/pricing") || path.startsWith("/predictive-graph")) {
            return roleId <= COMPANY_ADMIN || roleId == FINANCE;
        }

        // ---- 5. Warehouse, stock, ledger, dock scanning, allocation -----------
        // Physical operations: Admins + Operations. Finance and Customers blocked.
        if (path.startsWith("/upload-stock") || path.startsWith("/stock")
                || path.startsWith("/manual-stock") || path.startsWith("/adjust-stock")
                || path.startsWith("/download-errors") || path.startsWith("/inventory")
                || path.startsWith("/ledger") || path.startsWith("/barcodes")
                || path.startsWith("/scan-barcode") || path.startsWith("/allocate")) {
            return roleId <= OPERATIONS;
        }

        // ---- 6. Master data: vessels & ports ----------------------------------
        if (path.startsWith("/vessel") || path.startsWith("/ports")) {
            return roleId <= FINANCE; // all internal staff may view; Customers blocked
        }

        // ---- 7. Billing administration: Admins + Finance ----------------------
        // Customers never reach these; they use /invoices and /view-invoice.
        if (path.startsWith("/billing") || path.startsWith("/generate-invoice")) {
            return roleId <= COMPANY_ADMIN || roleId == FINANCE;
        }

        // ---- 8. Payment recording -------------------------------------------
        // FR5.7: Customers MAY pay their own invoices; the servlet verifies
        // that the invoice actually belongs to them before writing anything.
        if (path.startsWith("/record-payment") || path.startsWith("/payment")) {
            return roleId <= COMPANY_ADMIN || roleId == FINANCE || roleId == CUSTOMER;
        }

        // ---- 8b. Invoice register: Admins, Finance and Customers --------------
        // Operations staff have no billing authority (CLAUDE.md S3.3.6).
        if (path.startsWith("/invoices") || path.startsWith("/view-invoice")
                || path.startsWith("/invoice-view")) {
            return roleId != OPERATIONS;
        }

        // ---- 9. Customer directory: internal staff only -----------------------
        if (path.startsWith("/customers")) {
            return roleId <= FINANCE;
        }

        // ---- 10. Shared modules: all roles enter, DAOs scope the rows ---------
        // Shipments, containers, claims, invoices, compliance and the dashboard
        // are legitimately reachable by every role including Customers. Row-level
        // isolation is enforced in Tier 3 (see *DAO.getXForRole / canAccessX).
        if (path.startsWith("/shipment") || path.startsWith("/container")
                || path.startsWith("/book") || path.startsWith("/claims")
                || path.startsWith("/invoices") || path.startsWith("/view-invoice")
                || path.startsWith("/compliance") || path.startsWith("/dashboard")
                || path.startsWith("/profile") || path.startsWith("/logout")
                || path.startsWith("/download-document") || path.startsWith("/jsp/")) {
            return true;
        }

        // Default: allow authenticated access to anything not explicitly listed
        // (static resources, error pages). Sensitive routes are all matched above.
        return true;
    }

    public void destroy() {}

    /** Maps a directly-requested view to the controller that owns its data. */
    private String viewToController(String path) {
        if (path.endsWith("/jsp/profit_loss_analytics.jsp")) return "/finance/profit-loss";
        if (path.endsWith("/jsp/shipment_drilldown.jsp"))    return "/finance/shipment-drilldown";
        if (path.endsWith("/jsp/admin/users.jsp"))           return "/admin/users";
        if (path.endsWith("/jsp/admin/customers.jsp"))       return "/admin/customers";
        if (path.endsWith("/jsp/admin/companies.jsp"))       return "/admin/companies";
        if (path.endsWith("/jsp/admin/audit_logins.jsp"))    return "/admin/audit-logs";
        if (path.endsWith("/jsp/doc-viewer.jsp"))            return "/compliance-document";
        if (path.endsWith("/jsp/ports.jsp"))                 return "/ports";
        if (path.endsWith("/jsp/vessels.jsp"))               return "/vessels";
        if (path.endsWith("/jsp/products.jsp"))              return "/inventory/products";
        if (path.endsWith("/jsp/containers.jsp"))            return "/containers";
        if (path.endsWith("/jsp/claims.jsp"))                return "/claims";
        // barcodes.jsp is an early prototype that still answered on its own URL,
        // rendering an unstyled, unscoped shell outside the servlet.
        if (path.endsWith("/jsp/barcodes.jsp"))              return "/barcodes";
        if (path.endsWith("/jsp/barcode-management.jsp"))    return "/barcodes";
        if (path.endsWith("/jsp/pricing.jsp"))               return "/pricing";
        if (path.endsWith("/jsp/predictive-graph.jsp"))      return "/predictive-graph";
        if (path.endsWith("/jsp/alerts.jsp"))                return "/alerts";
        return null;
    }
}
