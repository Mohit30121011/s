# MEGA PROMPT FOR CLAUDE CODE: IMPLEMENT FULL MULTI-TENANT & CUSTOMER RBAC + VISIBILITY CONTROLS

> **Target Tool:** Claude Code (CLI / Coding Agent)  
> **Workspace:** `d:\NLogistic\NLogistic`  
> **Mission:** Implement end-to-end Role-Based Access Control (RBAC), tenant & customer data isolation, and granular UI/action visibility across the entire N Logistic Java EE web application in one shot.  
> **Reference Specs:** Refer to `CLAUDE.md`, `AGENTS.md`, and `srs_harness.md`.

---

## 1. Context & Identified Problem
In the current codebase:
1. `role_id` (1=Super Admin, 2=Company Admin, 3=Ops Staff, 4=Finance Staff, 5=Customer) is stored in the database and session, but **data queries are completely unscoped**. `ShipmentServlet`, `BillingServlet`, `DashboardServlet`, etc. execute global queries like `SELECT * FROM shipment`, leaking all customer and company data to anyone who logs in.
2. In `header.jsp`, virtually all sidebar menus (Profit & Loss Analytics, Financial Drilldown, Stock Uploads, Barcodes, Inventory Ledgers, Pricing Rules, Analytics) are displayed unconditionally to all users, including Customers and Operations Staff.
3. Action buttons (`Edit`, `Delete`, `Financial Drilldown`, `Status Update`) in `shipments.jsp`, `containers.jsp`, and `billing.jsp` are rendered without checking `user.roleId`. Customers can see and trigger delete modals, view confidential internal costs, and edit other customers' records.
4. When a Customer logs in, their `customer_id` is never mapped or stored in the `HttpSession`.

You must fix all three tiers (Presentation Tier, Controller/Filter Tier, Data Access Tier) so that **every user sees ONLY their authorized data and permitted UI controls**.

---

## 2. Role Definition & Access Rules

| Role ID | Role Name | Scope | Permissions & Strict Restrictions |
| :---: | :--- | :--- | :--- |
| **1** | **Super Admin** | Global | Full cross-company CRUD, company/customer approvals, user management, audit logs, algorithm execution, pricing overrides. |
| **2** | **Company Admin** | Company Tenant (`company_id`) | Manages own company's fleet, containers, staff, pricing rules, customer shipments, P&L analytics, billing, claims, and stock. |
| **3** | **Operations Staff** | Company Operational | Container allocation, shipment checkpoint progression, bulk stock CSV upload, inventory ledger, dock barcode scanning, compliance docs. **STRICTLY HIDDEN:** Financial P&L, drilldowns, billing, payment recording, pricing rules, user admin. |
| **4** | **Finance Staff** | Company Financial | Invoicing, payment recording, overdue debt collections, claim settlements, credit notes, profit & loss analysis, financial drilldowns. **STRICTLY HIDDEN:** Container allocation, movement checkpoint overrides, warehouse stock uploads, dock barcode scanning. |
| **5** | **Customer** | Self-Scoped (`customer_id`) | Browse container catalog, book own shipments, live tracking (Point A to Point B), view/download own invoices, pay online, file loss/damage claims with photos. **STRICTLY HIDDEN:** Internal P&L, fuel/port costs, loss reason tagging, pricing multipliers, other customers' data, stock ledgers, dock scanning, admin menus, delete buttons. |

---

## 3. Step-by-Step Tactical Implementation Plan

Follow these exact implementation steps across the codebase:

### STEP 1: Customer ID Resolution in Session (`CustomerDAO.java` & `LoginServlet.java`)

1. **Modify `src/main/java/com/nlogistic/dao/CustomerDAO.java`**:
   Add a method `getCustomerByUserId(int userId)`:
   ```java
   public Customer getCustomerByUserId(int userId) {
       String sql = "SELECT * FROM customers WHERE user_id = ?";
       try (Connection conn = DBConnectionManager.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
           ps.setInt(1, userId);
           try (ResultSet rs = ps.executeQuery()) {
               if (rs.next()) {
                   Customer c = new Customer();
                   c.setCustomerId(rs.getInt("customer_id"));
                   c.setUserId(rs.getInt("user_id"));
                   c.setCustomerName(rs.getString("customer_name"));
                   c.setAddress(rs.getString("address"));
                   c.setKycDocPath(rs.getString("kyc_doc_path"));
                   c.setCreditLimit(rs.getDouble("credit_limit"));
                   return c;
               }
           }
       } catch (Exception e) { e.printStackTrace(); }
       return null;
   }
   ```

2. **Modify `src/main/java/com/nlogistic/controller/LoginServlet.java`**:
   Inside `doPost`, after successful authentication when `user` is retrieved:
   ```java
   HttpSession session = request.getSession();
   session.setAttribute("user", user);
   session.setAttribute("username", user.getUsername());
   session.setAttribute("roleId", user.getRoleId());

   if (user.getRoleId() == 5) { // Customer
       com.nlogistic.dao.CustomerDAO customerDAO = new com.nlogistic.dao.CustomerDAO();
       com.nlogistic.model.Customer customer = customerDAO.getCustomerByUserId(user.getUserId());
       if (customer != null) {
           session.setAttribute("customerId", customer.getCustomerId());
           session.setAttribute("customerName", customer.getCustomerName());
       }
   } else {
       session.setAttribute("companyId", user.getCompanyId());
   }
   ```

---

### STEP 2: Strict Central Filter Enforcement (`AuthenticationFilter.java`)

Modify `src/main/java/com/nlogistic/filter/AuthenticationFilter.java`:
Replace the coarse role checks with strict path-level RBAC rules:

```java
User user = (User) session.getAttribute("user");
int roleId = user.getRoleId();
boolean allowed = true;

// 1. Super Admin Only (Role 1)
if (path.startsWith("/admin") || path.contains("/delete")) {
    allowed = (roleId == 1);
}
// 2. Executive Dashboard & Predictive Analytics (Super Admin & Company Admin)
else if (path.startsWith("/dashboard/executive") || path.startsWith("/executive")) {
    allowed = (roleId <= 2);
}
// 3. Profit & Loss Analytics & Financial Drilldown (Roles 1, 2, 4)
else if (path.startsWith("/finance")) {
    allowed = (roleId == 1 || roleId == 2 || roleId == 4);
}
// 4. Dynamic Pricing Engine (Admin & Finance)
else if (path.startsWith("/pricing") || path.startsWith("/predictive-graph")) {
    allowed = (roleId <= 2 || roleId == 4);
}
// 5. Physical Operations, Stock Uploads, Ledgers, Dock Barcodes (Roles 1, 2, 3)
else if (path.startsWith("/upload-stock") || path.startsWith("/stock") || 
         path.startsWith("/ledger") || path.startsWith("/manual-stock") || 
         path.startsWith("/adjust-stock") || path.startsWith("/barcodes") || 
         path.startsWith("/scan-barcode") || path.startsWith("/allocate")) {
    allowed = (roleId <= 3);
}
// 6. Billing & Invoicing (Roles 1, 2, 4, and 5 for viewing/paying own invoices)
else if (path.startsWith("/billing") || path.startsWith("/generate-invoice") || path.startsWith("/record-payment")) {
    allowed = (roleId <= 2 || roleId == 4); // Customer uses /invoices or /view-invoice
}
// 7. General modules (Controllers enforce data-level scoping)
else if (path.startsWith("/shipments") || path.startsWith("/containers") || 
         path.startsWith("/claims") || path.startsWith("/invoices") || 
         path.startsWith("/compliance") || path.startsWith("/dashboard")) {
    allowed = true;
}

if (!allowed) {
    com.nlogistic.dao.UserDAO userDAO = new com.nlogistic.dao.UserDAO();
    userDAO.logAuditEvent(user.getUserId(), "PERMISSION_DENIED", path, req.getRemoteAddr());
    req.setAttribute("errorMessage", "Access Denied: You do not have permission to access this resource.");
    req.getRequestDispatcher("/dashboard").forward(req, res);
    return;
}
```

---

### STEP 3: Data Scoping in DAOs (`ShipmentDAO.java`, `BillingDAO.java`, `ClaimDAO.java`)

1. **Modify `src/main/java/com/nlogistic/dao/ShipmentDAO.java`**:
   Add scoped query methods:
   ```java
   public List<ShipmentDetail> getShipmentsByCustomerId(int customerId) {
       List<ShipmentDetail> list = new ArrayList<>();
       String sql = "SELECT s.*, c.customer_name, cnt.container_number, p1.port_name as origin_port, " +
                    "p2.port_name as dest_port, v.vessel_name " +
                    "FROM shipment s " +
                    "JOIN customers c ON s.customer_id = c.customer_id " +
                    "LEFT JOIN containers cnt ON s.container_id = cnt.container_id " +
                    "JOIN ports p1 ON s.origin_port_id = p1.port_id " +
                    "JOIN ports p2 ON s.destination_port_id = p2.port_id " +
                    "LEFT JOIN vessels v ON s.vessel_id = v.vessel_id " +
                    "WHERE s.customer_id = ? ORDER BY s.shipment_id DESC";
       try (Connection conn = DBConnectionManager.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
           ps.setInt(1, customerId);
           ResultSet rs = ps.executeQuery();
           while (rs.next()) {
               list.add(mapShipmentDetail(rs)); // Use existing mapping helper
           }
       } catch (Exception e) { e.printStackTrace(); }
       return list;
   }

   public List<ShipmentDetail> getShipmentsByCompanyId(int companyId) {
       List<ShipmentDetail> list = new ArrayList<>();
       String sql = "SELECT s.*, c.customer_name, cnt.container_number, p1.port_name as origin_port, " +
                    "p2.port_name as dest_port, v.vessel_name " +
                    "FROM shipment s " +
                    "JOIN customers c ON s.customer_id = c.customer_id " +
                    "LEFT JOIN containers cnt ON s.container_id = cnt.container_id " +
                    "JOIN ports p1 ON s.origin_port_id = p1.port_id " +
                    "JOIN ports p2 ON s.destination_port_id = p2.port_id " +
                    "LEFT JOIN vessels v ON s.vessel_id = v.vessel_id " +
                    "WHERE cnt.owner_company_id = ? OR s.created_by IN (SELECT user_id FROM users WHERE company_id = ?) " +
                    "ORDER BY s.shipment_id DESC";
       try (Connection conn = DBConnectionManager.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
           ps.setInt(1, companyId);
           ps.setInt(2, companyId);
           ResultSet rs = ps.executeQuery();
           while (rs.next()) {
               list.add(mapShipmentDetail(rs));
           }
       } catch (Exception e) { e.printStackTrace(); }
       return list;
   }
   ```

2. **Modify `src/main/java/com/nlogistic/dao/BillingDAO.java`**:
   Add `getInvoicesByCustomerId(int customerId)`:
   ```java
   public List<Invoice> getInvoicesByCustomerId(int customerId) {
       List<Invoice> list = new ArrayList<>();
       String sql = "SELECT bi.*, c.customer_name, s.cargo_description FROM billing_invoices bi " +
                    "JOIN customers c ON bi.customer_id = c.customer_id " +
                    "LEFT JOIN shipment s ON bi.shipment_id = s.shipment_id " +
                    "WHERE bi.customer_id = ? ORDER BY bi.invoice_id DESC";
       try (Connection conn = DBConnectionManager.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
           ps.setInt(1, customerId);
           ResultSet rs = ps.executeQuery();
           while (rs.next()) {
               list.add(mapInvoice(rs)); // Use existing mapping helper
           }
       } catch (Exception e) { e.printStackTrace(); }
       return list;
   }
   ```

3. **Modify `src/main/java/com/nlogistic/dao/ClaimDAO.java`**:
   Ensure `getClaimsByCustomerId(int customerId)` returns claims where `customer_id = ?`.

---

### STEP 4: Scoped Data Dispatching in Servlets

1. **Modify `src/main/java/com/nlogistic/controller/ShipmentServlet.java`**:
   In `doGet`:
   ```java
   HttpSession session = request.getSession();
   User user = (User) session.getAttribute("user");
   int roleId = user.getRoleId();

   if (pathInfo == null || pathInfo.equals("/")) {
       if (roleId == 5) { // Customer
           Integer customerId = (Integer) session.getAttribute("customerId");
           request.setAttribute("shipments", shipmentDAO.getShipmentsByCustomerId(customerId != null ? customerId : -1));
       } else if (roleId >= 2 && roleId <= 4) { // Company Staff & Admin
           request.setAttribute("shipments", shipmentDAO.getShipmentsByCompanyId(user.getCompanyId()));
       } else { // Super Admin
           request.setAttribute("shipments", shipmentDAO.getAllShipments());
       }
       request.getRequestDispatcher("/jsp/shipments.jsp").forward(request, response);
   } else if (pathInfo.equals("/tracking")) {
       List<ShipmentDAO.ShipmentDetail> shipments;
       if (roleId == 5) {
           Integer customerId = (Integer) session.getAttribute("customerId");
           shipments = shipmentDAO.getShipmentsByCustomerId(customerId != null ? customerId : -1);
       } else if (roleId >= 2 && roleId <= 4) {
           shipments = shipmentDAO.getShipmentsByCompanyId(user.getCompanyId());
       } else {
           shipments = shipmentDAO.getAllShipments();
       }
       request.setAttribute("shipments", shipments);
       // Calculate KPI counts from the scoped list
       request.setAttribute("totalCount", shipments.size());
       request.setAttribute("activeCount", shipments.stream().filter(s -> !"Delivered".equalsIgnoreCase(s.getStatus()) && !"Cancelled".equalsIgnoreCase(s.getStatus())).count());
       request.setAttribute("inTransitCount", shipments.stream().filter(s -> "In Transit".equalsIgnoreCase(s.getStatus())).count());
       request.setAttribute("customsHoldCount", shipments.stream().filter(s -> "Customs Hold".equalsIgnoreCase(s.getStatus())).count());
       request.setAttribute("delayedCount", shipments.stream().filter(s -> "Delayed".equalsIgnoreCase(s.getStatus())).count());
       request.setAttribute("vessels", vesselDAO.getAllVessels());
       request.getRequestDispatcher("/jsp/live_tracking_dashboard.jsp").forward(request, response);
   } else if (pathInfo.equals("/tracking/detail")) {
       String idParam = request.getParameter("id");
       if (idParam != null && idParam.startsWith("SHP-")) {
           int id = Integer.parseInt(idParam.substring(4).trim());
           ShipmentDetail detail = shipmentDAO.getShipmentById(id);
           // IDOR Prevention: Customer can only view own shipment detail
           if (roleId == 5) {
               Integer customerId = (Integer) session.getAttribute("customerId");
               if (detail == null || detail.getCustomerId() != customerId) {
                   response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: You do not own this shipment.");
                   return;
               }
           }
           request.setAttribute("shipment", detail);
           request.setAttribute("logs", shipmentDAO.getMovementLogs(id));
       }
       request.getRequestDispatcher("/jsp/live_tracking_detail.jsp").forward(request, response);
   } else if (pathInfo.equals("/create")) {
       if (roleId == 5) {
           // Lock customer selection to current customer
           Integer customerId = (Integer) session.getAttribute("customerId");
           Customer currentCust = customerDAO.getCustomerById(customerId);
           request.setAttribute("customers", Collections.singletonList(currentCust));
       } else {
           request.setAttribute("customers", customerDAO.getAllCustomers());
       }
       request.setAttribute("ports", portDAO.getAllPorts());
       request.setAttribute("vessels", vesselDAO.getAllVessels());
       request.setAttribute("containers", containerDAO.getContainers("Available", 1000, 0));
       request.getRequestDispatcher("/jsp/create_shipment.jsp").forward(request, response);
   }
   ```

2. **Modify `src/main/java/com/nlogistic/controller/DashboardServlet.java`**:
   - For `roleId == 5` (Customer), filter SQL queries by `WHERE customer_id = ?`. Compute customer KPI cards: Total Bookings, In-Transit, Delivered, Pending Invoices.
   - For `roleId == 2, 3, 4` (Company Staff), filter SQL queries by `WHERE company_id = ?` or containers owned by `company_id`.
   - For `roleId == 1` (Super Admin), keep global aggregated stats.

3. **Modify `src/main/java/com/nlogistic/controller/BillingServlet.java` & `InvoiceServlet.java`**:
   - If `roleId == 5`, call `billingDAO.getInvoicesByCustomerId(customerId)`.
   - Prevent customer from viewing eligible unbilled shipments of other clients or generating invoices.

---

### STEP 5: Master UI Guard in `header.jsp`

Modify `src/main/webapp/jsp/layout/header.jsp` to enforce role-based sidebar menus and omnibox filtering:

1. **Inside the Sidebar (`<aside class="sidebar">`):**
   Wrap sections with `<c:choose>`:

   ```jsp
   <c:choose>
       <%-- ================= ROLE 5: DEDICATED CUSTOMER PORTAL ================= --%>
       <c:when test="${sessionScope.user.roleId == 5}">
           <div class="nav-section">
               <div class="nav-item mb-2">
                   <a href="${pageContext.request.contextPath}/dashboard" class="nav-link dashboard-link">
                       <i class="ti ti-smart-home main-icon"></i>
                       <span>My Dashboard</span>
                   </a>
               </div>
               <div class="sidebar-section-header"><span>SHIPPING &amp; CARGO</span></div>
               <div class="nav-item">
                   <a href="${pageContext.request.contextPath}/containers" class="nav-link">
                       <i class="ti ti-box main-icon"></i>
                       <span>Container Catalog</span>
                   </a>
               </div>
               <div class="nav-item">
                   <a href="${pageContext.request.contextPath}/shipments/create" class="nav-link">
                       <i class="ti ti-plus main-icon"></i>
                       <span>Book Shipment</span>
                   </a>
               </div>
               <div class="nav-item">
                   <a href="${pageContext.request.contextPath}/shipments" class="nav-link">
                       <i class="ti ti-truck main-icon"></i>
                       <span>My Shipments</span>
                   </a>
               </div>
               <div class="nav-item">
                   <a href="${pageContext.request.contextPath}/shipments/tracking" class="nav-link">
                       <i class="ti ti-map-pin main-icon"></i>
                       <span>Live Tracking</span>
                   </a>
               </div>
               <div class="sidebar-section-header"><span>BILLING &amp; CLAIMS</span></div>
               <div class="nav-item">
                   <a href="${pageContext.request.contextPath}/invoices" class="nav-link">
                       <i class="ti ti-receipt main-icon"></i>
                       <span>Invoices &amp; Payments</span>
                   </a>
               </div>
               <div class="nav-item">
                   <a href="${pageContext.request.contextPath}/claims" class="nav-link">
                       <i class="ti ti-shield main-icon"></i>
                       <span>Loss &amp; Damage Claims</span>
                   </a>
               </div>
           </div>
       </c:when>

       <%-- ================= ROLES 1, 2, 3, 4: INTERNAL MANAGEMENT ================= --%>
       <c:otherwise>
           <div class="nav-section">
               <div class="nav-item mb-2">
                   <a href="${pageContext.request.contextPath}/dashboard" class="nav-link dashboard-link">
                       <i class="ti ti-smart-home main-icon"></i>
                       <span>Dashboard</span>
                   </a>
               </div>

               <!-- SECTION 1: OPERATIONS (Roles 1, 2, 3, and view-only for 4) -->
               <div class="sidebar-section-header"><span>OPERATIONS</span></div>
               
               <!-- Shipments Dropdown -->
               <div class="nav-item">
                   <a href="javascript:void(0);" data-target="shipmentsSubmenu" class="nav-link sidebar-dropdown-toggle">
                       <i class="ti ti-truck main-icon"></i>
                       <span>Shipments</span>
                       <i class="ti ti-chevron-down caret"></i>
                   </a>
                   <ul class="sub-nav" id="shipmentsSubmenu" style="display: none;">
                       <li><a href="${pageContext.request.contextPath}/shipments">All Shipments</a></li>
                       <c:if test="${sessionScope.user.roleId <= 3}">
                           <li><a href="${pageContext.request.contextPath}/shipments/create">Create Shipment</a></li>
                       </c:if>
                       <li><a href="${pageContext.request.contextPath}/shipments/tracking">Live Tracking</a></li>
                       <%-- P&L only for Super Admin, Company Admin, Finance --%>
                       <c:if test="${sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2 || sessionScope.user.roleId == 4}">
                           <li><a href="${pageContext.request.contextPath}/finance/profit-loss">Profit &amp; Loss Analytics</a></li>
                           <li><a href="${pageContext.request.contextPath}/finance/shipment-drilldown?id=1">Financial Drilldown</a></li>
                       </c:if>
                   </ul>
               </div>

               <!-- Containers Dropdown -->
               <div class="nav-item">
                   <a href="javascript:void(0);" data-target="containersSubmenu" class="nav-link sidebar-dropdown-toggle">
                       <i class="ti ti-box main-icon"></i>
                       <span>Containers</span>
                       <i class="ti ti-chevron-down caret"></i>
                   </a>
                   <ul class="sub-nav" id="containersSubmenu" style="display: none;">
                       <li><a href="${pageContext.request.contextPath}/containers">All Containers</a></li>
                       <c:if test="${sessionScope.user.roleId <= 2 || sessionScope.user.roleId == 4}">
                           <li><a href="${pageContext.request.contextPath}/pricing">Pricing &amp; Rate Governance</a></li>
                           <li><a href="${pageContext.request.contextPath}/predictive-graph">Predictive Pricing Graph</a></li>
                       </c:if>
                   </ul>
               </div>

               <!-- Vessels & Ports (Admins and Ops) -->
               <c:if test="${sessionScope.user.roleId <= 3}">
                   <div class="nav-item">
                       <a href="${pageContext.request.contextPath}/jsp/vessels.jsp" class="nav-link">
                           <i class="ti ti-ship main-icon"></i>
                           <span>Vessels</span>
                       </a>
                   </div>
                   <div class="nav-item">
                       <a href="${pageContext.request.contextPath}/ports" class="nav-link">
                           <i class="ti ti-anchor main-icon"></i>
                           <span>Ports</span>
                       </a>
                   </div>
               </c:if>

               <!-- SECTION 2: MANAGEMENT -->
               <div class="sidebar-section-header"><span>MANAGEMENT</span></div>

               <!-- Approvals (Super Admin Only) -->
               <c:if test="${sessionScope.user.roleId == 1}">
                   <div class="nav-item">
                       <a href="javascript:void(0);" data-target="approvalsSubmenu" class="nav-link sidebar-dropdown-toggle">
                           <i class="ti ti-clipboard-check main-icon"></i>
                           <span>Approvals</span>
                           <i class="ti ti-chevron-down caret"></i>
                       </a>
                       <ul class="sub-nav" id="approvalsSubmenu" style="display: none;">
                           <li><a href="${pageContext.request.contextPath}/jsp/admin/companies.jsp">Company Approvals</a></li>
                           <li><a href="${pageContext.request.contextPath}/jsp/admin/customers.jsp">Customer Approvals</a></li>
                       </ul>
                   </div>
               </c:if>

               <!-- Claims (Admins, Ops, Finance) -->
               <div class="nav-item">
                   <a href="${pageContext.request.contextPath}/claims" class="nav-link">
                       <i class="ti ti-shield main-icon"></i>
                       <span>Claims Management</span>
                   </a>
               </div>

               <!-- Compliance & Billing -->
               <div class="nav-item">
                   <a href="javascript:void(0);" data-target="complianceSubmenu" class="nav-link sidebar-dropdown-toggle">
                       <i class="ti ti-shield-check main-icon"></i>
                       <span>Compliance &amp; Billing</span>
                       <i class="ti ti-chevron-down caret"></i>
                   </a>
                   <ul class="sub-nav" id="complianceSubmenu" style="display: none;">
                       <c:if test="${sessionScope.user.roleId <= 3}">
                           <li><a href="${pageContext.request.contextPath}/compliance">Government Compliance</a></li>
                       </c:if>
                       <c:if test="${sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2 || sessionScope.user.roleId == 4}">
                           <li><a href="${pageContext.request.contextPath}/billing">Billing &amp; Invoices</a></li>
                           <li><a href="${pageContext.request.contextPath}/invoices">Invoices &amp; Statements</a></li>
                       </c:if>
                   </ul>
               </div>

               <!-- Stock & Inventory (Admins & Ops Only) -->
               <c:if test="${sessionScope.user.roleId <= 3}">
                   <div class="nav-item">
                       <a href="javascript:void(0);" data-target="stockSubmenu" class="nav-link sidebar-dropdown-toggle">
                           <i class="ti ti-packages main-icon"></i>
                           <span>Stock &amp; Inventory</span>
                           <i class="ti ti-chevron-down caret"></i>
                       </a>
                       <ul class="sub-nav" id="stockSubmenu" style="display: none;">
                           <li><a href="${pageContext.request.contextPath}/upload-stock">Upload / Manage Stock</a></li>
                           <li><a href="${pageContext.request.contextPath}/inventory/products">Product Catalog</a></li>
                           <li><a href="${pageContext.request.contextPath}/inventory/stock">Stock Overview</a></li>
                           <li><a href="${pageContext.request.contextPath}/ledger">Inventory Ledger</a></li>
                       </ul>
                   </div>

                   <!-- Tracking & Scanning (Admins & Ops Only) -->
                   <div class="nav-item">
                       <a href="javascript:void(0);" data-target="barcodeSubmenu" class="nav-link sidebar-dropdown-toggle">
                           <i class="ti ti-barcode main-icon"></i>
                           <span>Tracking &amp; Scanning</span>
                           <i class="ti ti-chevron-down caret"></i>
                       </a>
                       <ul class="sub-nav" id="barcodeSubmenu" style="display: none;">
                           <li><a href="${pageContext.request.contextPath}/barcodes">Manage Barcodes</a></li>
                           <li><a href="${pageContext.request.contextPath}/scan-barcode">Scan Barcodes</a></li>
                       </ul>
                   </div>
               </c:if>

               <!-- SECTION 3: INSIGHTS & CONFIGURATION -->
               <c:if test="${sessionScope.user.roleId <= 2}">
                   <div class="sidebar-section-header"><span>INSIGHTS &amp; GOVERNANCE</span></div>
                   <div class="nav-item">
                       <a href="${pageContext.request.contextPath}/analytics" class="nav-link">
                           <i class="ti ti-chart-pie main-icon"></i>
                           <span>Analytics (5 Engines)</span>
                       </a>
                   </div>
                   <div class="nav-item">
                       <a href="${pageContext.request.contextPath}/jsp/admin/users.jsp" class="nav-link">
                           <i class="ti ti-users main-icon"></i>
                           <span>Users &amp; Roles</span>
                       </a>
                   </div>
                   <div class="nav-item">
                       <a href="${pageContext.request.contextPath}/jsp/admin/audit_logins.jsp" class="nav-link">
                           <i class="ti ti-history main-icon"></i>
                           <span>Audit Logs</span>
                       </a>
                   </div>
               </c:if>
           </div>
       </c:otherwise>
   </c:choose>
   ```

2. **In the Omnibox Javascript (`initOmnibox()` in `header.jsp`):**
   Filter `omniIndex` items according to `var userRoleId = ${sessionScope.user.roleId};`:
   - If `userRoleId == 5`, exclude any item with category `Management`, `Finance`, `Audit`, `Stock`, or `Analytics`.

---

### STEP 6: Table Action Button Guards in `shipments.jsp`

Modify `src/main/webapp/jsp/shipments.jsp`:

1. **Top Action Bar (Lines ~340):**
   Wrap the Profit & Loss Analytics button:
   ```jsp
   <c:if test="${sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2 || sessionScope.user.roleId == 4}">
       <a href="${pageContext.request.contextPath}/finance/profit-loss" class="btn-profit-loss" title="View Profit &amp; Loss Trend Graph">
           <i class="ti ti-chart-line"></i> Profit &amp; Loss Analytics
       </a>
   </c:if>
   <c:if test="${sessionScope.user.roleId != 4}">
       <a href="${pageContext.request.contextPath}/shipments/create" class="btn-book">
           <i class="fa-solid fa-plus"></i> Book Shipment
       </a>
   </c:if>
   ```

2. **Table Action Column (`<td>` in `<c:forEach var="s" items="${shipments}">`):**
   ```jsp
   <td style="text-align: center;">
       <div style="display: flex; gap: 8px; justify-content: center;">
           <%-- Financial Drilldown: Admins & Finance Only --%>
           <c:if test="${sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2 || sessionScope.user.roleId == 4}">
               <a href="${pageContext.request.contextPath}/finance/shipment-drilldown?id=${s.shipmentId}" class="btn-icon-action drilldown" title="Financial Drilldown">
                   <i class="ti ti-chart-arrows-vertical"></i>
               </a>
           </c:if>

           <%-- Edit Shipment: Admins & Ops Only --%>
           <c:if test="${sessionScope.user.roleId <= 3}">
               <a href="${pageContext.request.contextPath}/shipments/edit?id=${s.shipmentId}" class="btn-icon-action edit" title="Edit Shipment">
                   <i class="ti ti-pencil"></i>
               </a>
           </c:if>

           <%-- Update Status: Operations & Admins Only --%>
           <c:if test="${sessionScope.user.roleId <= 3}">
               <button type="button" class="btn-icon-action" data-bs-toggle="modal" data-bs-target="#updateModal${s.shipmentId}" title="Update Checkpoint Status">
                   <i class="ti ti-refresh"></i>
               </button>
           </c:if>

           <%-- Delete Shipment: Super Admin Only (Role 1) --%>
           <c:if test="${sessionScope.user.roleId == 1}">
               <button class="btn-icon-action delete" data-bs-toggle="modal" data-bs-target="#deleteModal${s.shipmentId}" title="Delete Shipment">
                   <i class="ti ti-trash"></i>
               </button>
           </c:if>

           <%-- Live Tracking: Available to All Roles including Customer --%>
           <a href="${pageContext.request.contextPath}/shipments/tracking/detail?id=SHP-${s.shipmentId}" class="btn-icon-action" title="View Live Tracking Timeline">
               <i class="ti ti-map-pin"></i>
           </a>
       </div>
   </td>
   ```

---

### STEP 7: Guards in `billing.jsp` and `claims.jsp`

1. **In `src/main/webapp/jsp/billing.jsp`:**
   - Wrap "Generate Invoice", "Eligible Unbilled Shipments", and "Record Payment" modals in `<c:if test="${sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2 || sessionScope.user.roleId == 4}">`.
   - If accessed by Role 5 (Customer), redirect or display only the Customer's invoices and a "Pay Online" modal.

2. **In `src/main/webapp/jsp/claims.jsp`:**
   - For Role 5 (Customer), hide the "Review Status" dropdown (`Approved`/`Rejected`/`Settled`) and `approved_amount` settlement inputs. Customer can only submit new claims and view review remarks.

---

## 4. Verification & Validation Checklist

Once you have applied these modifications, verify:
1. **Login as Customer (`roleId = 5`):**
   - Main sidebar displays ONLY the clean Customer Portal (My Dashboard, Container Catalog, Book Shipment, My Shipments, Live Tracking, Invoices, Claims).
   - `/shipments` lists ONLY shipments where `customer_id` matches the logged-in customer.
   - Profit & Loss button and Financial Drilldown buttons are completely absent from the UI.
   - Attempting to access `/finance/profit-loss`, `/upload-stock`, `/admin/users`, `/pricing` directly via URL results in an immediate HTTP 403 Forbidden or redirect to `/dashboard` with an audit log event.
2. **Login as Operations Staff (`roleId = 3`):**
   - Can allocate containers, update checkpoint statuses, upload stock CSVs, and scan barcodes.
   - Cannot see P&L graphs, cannot see financial drilldown, cannot generate invoices.
3. **Login as Finance Staff (`roleId = 4`):**
   - Can generate invoices, record payments, view P&L analytics and financial drilldowns.
   - Cannot update movement status checkpoints or upload warehouse stock.
4. **Login as Super Admin (`roleId = 1`):**
   - Retains full unhindered CRUD across all companies, approvals, users, and audit logs.
