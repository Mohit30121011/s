# MODULE 2: CONTAINER MOVEMENT TRACKING & PROFIT & LOSS GRAPH — MEGA GAP SPECIFICATION & IMPLEMENTATION ROADMAP

> **Standard:** IEEE 830-1998 Software Requirements Specification Alignment  
> **Target Module:** Module 2 — Container Movement Tracking (Point A → Point B) and Profit & Loss Graph (FR2.1 – FR2.9)  
> **Platform:** N Logistic Import & Export Enterprise Suite  
> **Tech Stack:** Java 11 / Jakarta EE (Servlet 4.0 / JSP 2.3) · JDBC · MySQL 8.0 · Chart.js · Bootstrap 5 · MVC2 Architecture  
> **Reference Documents:** 
> - [srs_harness.md](file:///d:/NLogistic/NLogistic/srs_harness.md) (Section 3.2, Section 6.2, Section 10)
> - [CLAUDE.md](file:///d:/NLogistic/NLogistic/CLAUDE.md) (Tier 1/2/3 Security Architecture & RBAC Matrix)
> - [SYSTEM_WORKFLOW_AND_ENTITY_RELATIONSHIPS.md](file:///d:/NLogistic/NLogistic/SYSTEM_WORKFLOW_AND_ENTITY_RELATIONSHIPS.md) (Shipment vs Container Lifecycle)
> - [SYSTEM_GAPS_AND_MISSING_FEATURES.md](file:///d:/NLogistic/NLogistic/SYSTEM_GAPS_AND_MISSING_FEATURES.md) (Disconnect 1 & 2)
> - [MODULE_1_AUTH_GAPS_AND_ROADMAP.md](file:///d:/NLogistic/NLogistic/MODULE_1_AUTH_GAPS_AND_ROADMAP.md)

---

## 1. Executive Summary & Module Scope

Module 2 represents the core operational and financial engine of the N Logistic platform. It connects physical freight logistics with analytical financial intelligence. It tracks a container shipment across its entire oceanic voyage—from initial customer booking at an origin port (Point A), through multi-milestone transit checkpoints, to arrival and final cargo handover at a destination port (Point B). Concurrently, it tracks shipment-level revenue, expenses (fuel, port charges, customs, insurance, delays, damage claims), computes net profit or loss, and tags loss-making shipments against standardized maritime loss categories.

### Core Objectives of Module 2:
1. **Multilateral Shipment Booking (FR2.1):** Unify Customer, Allocated Container, Origin Port (Point A), Destination Port (Point B), and Assigned Maritime Vessel into a validated booking entity.
2. **Seven-Stage Checkpoint Lifecycle (FR2.2):** Enforce strict milestone progression: `Booked` $\rightarrow$ `Container Allocated` $\rightarrow$ `Departed` $\rightarrow$ `In Transit` $\rightarrow$ `Customs Hold` (optional) $\rightarrow$ `Arrived` $\rightarrow$ `Delivered`.
3. **Attributed Milestone Auditing (FR2.3):** Every checkpoint update must capture an immutable timestamp, precise terminal location/remarks, and the staff member's authenticated identity.
4. **Visual Route Presentation (FR2.4):** Provide interactive, step-by-step visual route progression showing the active location marker and completed milestones.
5. **Dynamic Arrival Calculation & Delay Detection (FR2.5):** Continuously evaluate `expected_arrival_date` against `actual_arrival_date`, calculate `delay_days`, and trigger automated delay alerts.
6. **Unit Economics & Profit/Loss Computation (FR2.6):** Calculate net margin per shipment: $\text{Profit/Loss} = \text{Total Revenue} - \text{Total Costs}$ (fuel, port handling, customs fees, insurance, delay penalties, damage claims).
7. **Categorized Maritime Loss Attribution (FR2.7):** Tag every loss-making shipment against the 8 standardized loss reasons: *Traffic in Sea, Weather Condition, Delay, Dock Allocation, Government Legal/Regulatory Hold, War/Geopolitical Disruption, Ship Issue,* and *Damaged Product*.
8. **Multi-Dimensional Analytics & Visual PLG (FR2.8):** Render interactive time-series charts (monthly, quarterly, yearly) filterable by Company, Maritime Corridor/Route, and Loss Category, alongside loss distribution breakdowns.
9. **Micro-Drilldown Traceability (FR2.9):** Seamless one-click drilldown from aggregate PLG chart markers down to the granular shipment record, loss reasons, and underlying financial ledger.

---

## 2. SRS Requirements vs Current Implementation Audit

The following matrix contrasts every individual functional requirement in Module 2 against the active codebase:

| Req ID | SRS Specification Description | Codebase Component(s) | Current Implementation Status | Severity / Defect Type |
| :--- | :--- | :--- | :--- | :--- |
| **FR2.1** | Booking linking Customer, Container, Origin Port (A), Destination Port (B), and Vessel. | [BookShipmentServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/BookShipmentServlet.java)<br>[ShipmentServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ShipmentServlet.java)<br>[ShipmentDAO.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ShipmentDAO.java) | **CRITICAL DEFECT**<br>1. [BookShipmentServlet.java:L52](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/BookShipmentServlet.java#L52) passes `user_id` into `customer_id` FK column.<br>2. Competing flow `/shipments/save` does NOT update container status, does NOT insert P&L record, and does NOT generate barcodes. | High / Data Corruption & Disconnected Flow |
| **FR2.2** | Checkpoint lifecycle: Booked $\rightarrow$ Allocated $\rightarrow$ Departed $\rightarrow$ In Transit $\rightarrow$ Customs Hold $\rightarrow$ Arrived $\rightarrow$ Delivered. | [ShipmentServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ShipmentServlet.java)<br>[live_tracking_detail.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/live_tracking_detail.jsp)<br>[ShipmentDAO.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ShipmentDAO.java) | **PARTIAL / CONTRACT BYPASS**<br>1. Stepper UI renders all 7 steps beautifully.<br>2. BUT `/updateStatus` in `ShipmentServlet.java` has NO role checks (Customers & Finance can alter status).<br>3. Compliance departure gate (FR5.3) is completely bypassed in `/updateStatus`. | High / Security Breach & Gate Bypass |
| **FR2.3** | Status change timestamped and attributed to staff user who recorded it. | `container_movements` table<br>[ShipmentDAO.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ShipmentDAO.java)<br>[live_tracking_detail.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/live_tracking_detail.jsp) | **COMPLIANT**<br>Inserts into `container_movements` with `updated_at = NOW()`, `updated_by = userId`, and displays staff attribution in checkpoint audit table. | Low / Working As Intended |
| **FR2.4** | Visual route from origin to destination with current status marker. | [live_tracking_detail.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/live_tracking_detail.jsp)<br>[live_tracking_dashboard.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/live_tracking_dashboard.jsp) | **COMPLIANT**<br>Interactive horizontal stepper with active pulse animation, milestone completed states, and origin/destination markers. | Low / Working As Intended |
| **FR2.5** | Compute expected vs actual arrival date and automatically flag delay in days. | [ShipmentDAO.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ShipmentDAO.java)<br>[live_tracking_detail.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/live_tracking_detail.jsp) | **BROKEN / INCOMPLETE**<br>1. In [ShipmentDAO.java:L258](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ShipmentDAO.java#L258), `expected_arrival_date` is passed as `NULL` during status updates.<br>2. `delay_days` is never computed or persisted when actual arrival occurs.<br>3. Delayed shipments are NOT automatically tagged with Loss Reason `Delay`. | High / Missing Computation & Automation |
| **FR2.6** | PLG: Compute Profit/Loss = Total Revenue (freight + charges) - Total Cost (fuel, port, customs, insurance, claims, delay penalties). | [ProfitLossDAO.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ProfitLossDAO.java)<br>[FinanceServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/FinanceServlet.java)<br>`profit_loss` table | **PARTIAL**<br>Formula implemented in DB schema (`profit_loss_amount = revenue_amount - total_cost_amount`), but costs are never dynamically recalculated when damage claims or delay penalties occur. | Medium / Disconnected Cost Aggregation |
| **FR2.7** | Loss-making shipments tagged with 8 standard Loss Reasons: Traffic in Sea, Weather, Delay, Dock, Customs, War, Ship Issue, Damaged Product. | [ProfitLossDAO.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ProfitLossDAO.java)<br>[shipment_drilldown.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/shipment_drilldown.jsp)<br>`loss_reasons` table | **PARTIAL / MANUAL ONLY**<br>1. Manual tagging via modal exists.<br>2. Zero automated tagging occurs when a delay, customs hold, or damage claim is recorded. | Medium / Missing Automated Workflow |
| **FR2.8** | Render PLG as filterable time-series chart (monthly / quarterly / yearly) by company, route, loss reason + breakdown chart. | [FinanceServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/FinanceServlet.java)<br>[profit_loss_analytics.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/profit_loss_analytics.jsp) | **CRITICAL ARCHITECTURAL HOLE**<br>1. Multi-period Chart.js charts work visually.<br>2. BUT [FinanceServlet.java:L35-38](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/FinanceServlet.java#L35-L38) allows cross-company data leakage by taking unverified `companyId` from query string.<br>3. `profit_loss_analytics.jsp` contains raw Java scriptlets. | High / Tenant Data Leak & MVC2 Breach |
| **FR2.9** | Drill-down from PLG data point to underlying shipment record(s). | [FinanceServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/FinanceServlet.java)<br>[shipment_drilldown.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/shipment_drilldown.jsp) | **PARTIAL**<br>Drilldown view displays shipment metadata and financial breakdown, but `shipment_drilldown.jsp` contains 15+ lines of raw scriptlets. | Medium / Scriptlet MVC2 Violation |

---

## 3. Deep-Dive Forensic Gap Breakdown

### 3.1 GAP-M2-01: Foreign Key Corruption & Dual Booking Disconnect
* **Symptoms:**
  - Booking through `/allocate -> pricing.jsp -> /book` fails with a MySQL Foreign Key constraint error, or creates a shipment assigned to the wrong customer.
  - Booking through `/shipments/create` creates a shipment, but the container remains marked `Available`, no record is created in `profit_loss`, and the shipment is omitted from all financial analytics.
* **Root Cause Analysis:**
  1. In [BookShipmentServlet.java:L51-61](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/BookShipmentServlet.java#L51-L61):
     ```java
     String insertShipment = "INSERT INTO shipment (customer_id, container_id, ...) VALUES (?, ?, ...)";
     try (PreparedStatement ps = conn.prepareStatement(insertShipment, Statement.RETURN_GENERATED_KEYS)) {
         ps.setInt(1, user.getUserId()); // CRITICAL BUG: user_id is NOT customer_id!
     ```
     In the database, `customers.customer_id` is an auto-increment primary key, while `customers.user_id` links to `users`. Passing `user.getUserId()` into `shipment.customer_id` corrupts customer data or fails when `user_id` does not match `customer_id`.
  2. In `ShipmentServlet.java` (`/save` handler lines 148–171), the insert statement executes:
     ```java
     boolean success = shipmentDAO.bookShipment(s);
     ```
     `shipmentDAO.bookShipment` calls stored procedure `{CALL book_shipment(...)}`, but:
     - It does NOT call `allocate_container` SP $\rightarrow$ container remains `Available` indefinitely!
     - It does NOT insert into `profit_loss` $\rightarrow$ PLG is never aware of the shipment!
     - It does NOT generate a tracking barcode via `BarcodeAutoGenerator`.
* **Resolution Blueprint:**
  - Unify the booking engine:
    - If customer is booking (`roleId == 5`), resolve `customerId` from `session.getAttribute("customerId")`.
    - If company staff is booking (`roleId <= 3`), require selecting a customer from the customer catalog.
    - Consolidate all booking operations inside a single transactional DAO method (`ShipmentDAO.bookAndAllocateShipment`) that atomically:
      1. Inserts shipment with correct `customer_id`.
      2. Enforces container availability and weight/CBM capacity limits.
      3. Updates container status to `Allocated`.
      4. Creates the initial `profit_loss` row (`revenue = freight + other, total_cost = 0, profit_loss = revenue`).
      5. Auto-generates Code128 / QR barcode record.

---

### 3.2 GAP-M2-02: Checkpoint Precondition Bypass & Role Elevation Vulnerability
* **Symptoms:**
  - Customers (`role_id=5`) or Finance Staff (`role_id=4`) can open a live tracking detail page and advance any shipment checkpoint, including marking goods as `Delivered` or `Departed`.
* **SRS & RBAC Violation:**
  - **CLAUDE.md Section 4 & AGENTS.md:** 
    - *Company Staff (Operations - Role 3):* Full operational authority over container allocation and movement checkpoint updates.
    - *Company Staff (Finance - Role 4):* Strictly NO movement status overrides.
    - *Customer (Role 5):* Strictly NO dock scanning tools or movement status overrides.
* **Root Cause Analysis:**
  1. In [live_tracking_detail.jsp:L350-385](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/live_tracking_detail.jsp#L350-L385), the `<form action="${pageContext.request.contextPath}/shipments/updateStatus">` is rendered without checking `<c:if test="${sessionScope.user.roleId <= 3}">`.
  2. In [ShipmentServlet.java:L184-210](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ShipmentServlet.java#L184-L210):
     ```java
     } else if (pathInfo != null && pathInfo.equals("/updateStatus")) {
         String shipmentIdStr = request.getParameter("shipmentId");
         String status = request.getParameter("status");
         String remarks = request.getParameter("remarks");
         // ZERO ROLE VERIFICATION!
         shipmentDAO.updateStatus(shipmentId, status, remarks, userId);
     ```
* **Resolution Blueprint:**
  - In `live_tracking_detail.jsp`, wrap the "Record Next Checkpoint" form inside:
    ```jsp
    <c:if test="${sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2 || sessionScope.user.roleId == 3}">
        <!-- Checkpoint Form -->
    </c:if>
    ```
  - In `ShipmentServlet.java`, enforce the contract precondition at the top of the `/updateStatus` handler:
    ```java
    int roleId = com.nlogistic.util.RbacContext.roleId(request);
    if (roleId > 3) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Only Operations Staff may record movement checkpoints.");
        return;
    }
    ```

---

### 3.3 GAP-M2-03: Bypassed Departure Compliance Gate in Checkpoint Updates
* **Symptoms:**
  - Operations staff can immediately move a newly booked shipment from `Container Allocated` to `Departed` using the quick checkpoint dropdown, even when zero mandatory export documents (Bill of Lading, Customs Declaration, Commercial Invoice) have been uploaded or approved.
* **SRS Requirement (FR5.3 & FR2.2):**
  - *"The system shall block a shipment's transition to Departed status until all mandatory compliance documents are Approved and none are expired (contract precondition)."*
* **Root Cause Analysis:**
  - In `ShipmentServlet.java:L138`, `complianceDAO.canShipmentDepart(s.getShipmentId())` is checked only in the `/updateFull` servlet handler.
  - In `ShipmentServlet.java:L184` (`/updateStatus`), which is the primary route used by dock staff and tracking pages, the compliance check is completely omitted.
* **Resolution Blueprint:**
  - Add the gate check directly into `ShipmentServlet.java` `/updateStatus`:
    ```java
    if ("Departed".equalsIgnoreCase(status) && !complianceDAO.canShipmentDepart(shipmentId)) {
        session.setAttribute("errorMessage", "Departure Gated: Shipment #SHP-" + shipmentId 
            + " cannot depart until all mandatory compliance documents are Approved and verified non-expired.");
        response.sendRedirect(redirectUrl);
        return;
    }
    ```

---

### 3.4 GAP-M2-04: Transit ETA & Delay Days Auto-Calculation Breakdown (FR2.5)
* **Symptoms:**
  - On tracking dashboards and shipment lists, the "Delay Days" metric always shows `0` or `null`, even for shipments that arrive weeks past their expected arrival date.
* **Root Cause Analysis:**
  1. In [ShipmentDAO.java:L258](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ShipmentDAO.java#L258):
     ```java
     cs.setNull(4, Types.DATE); // expected_arrival_date is set to NULL!
     ```
     The DAO never computes or supplies `expected_arrival_date` during status transitions.
  2. When status transitions to `Arrived` or `Delivered`, the database or DAO never evaluates:
     $$\text{delay\_days} = \max(0, \text{DATEDIFF}(\text{actual\_arrival\_date}, \text{expected\_arrival\_date}))$$
  3. Furthermore, when `delay_days > 0`, the system fails to auto-tag the shipment with Loss Reason: `Delay` (Reason ID 3).
* **Resolution Blueprint:**
  - Compute `expected_arrival_date` at booking time based on the maritime corridor (e.g. Origin Port to Destination Port default transit window, e.g. 14 to 28 days).
  - When status changes to `Arrived` or `Delivered`, calculate `delay_days`:
    ```java
    long diffMillis = actualDate.getTime() - expectedDate.getTime();
    int delayDays = (int) Math.max(0, TimeUnit.DAYS.convert(diffMillis, TimeUnit.MILLISECONDS));
    ```
  - If `delayDays > 0`:
    1. Persist `delay_days` into `container_movements`.
    2. Add delay penalty to `profit_loss.total_cost_amount`.
    3. Automatically link Loss Reason `Delay` into `profit_loss_reason_map`.

---

### 3.5 GAP-M2-05: P&L Tenant Isolation Leak in `FinanceServlet.java` (FR2.6, FR2.8)
* **Symptoms:**
  - A Company Admin (`role_id=2`) or Finance Staff (`role_id=4`) from "Oceanic Freight Ltd" can inspect the financial margins, COGS, port handling fees, and client profitability of "Pacific Star Logistics" simply by altering the `?companyId=` query parameter on `/finance/profit-loss`.
* **Root Cause Analysis:**
  - Inspecting [FinanceServlet.java:L35-38](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/FinanceServlet.java#L35-L38):
    ```java
    Integer companyId = null;
    if (request.getParameter("companyId") != null && !request.getParameter("companyId").isEmpty()) {
        companyId = Integer.parseInt(request.getParameter("companyId"));
    }
    ```
    The servlet trusts user input from the HTTP request query parameter and fails to enforce tenancy:
    - Super Admin (`roleId == 1`): Allowed to filter by any `companyId` or view global aggregates.
    - Company Admin / Finance (`roleId == 2 || roleId == 4`): Must be **locked** to their own `session.getAttribute("companyId")`.
* **Resolution Blueprint:**
  - In `FinanceServlet.java`, enforce tenancy scoping:
    ```java
    int roleId = com.nlogistic.util.RbacContext.roleId(request);
    Integer companyId = null;
    if (roleId == 1) { // Super Admin can filter across companies
        if (request.getParameter("companyId") != null && !request.getParameter("companyId").isEmpty()) {
            companyId = Integer.parseInt(request.getParameter("companyId"));
        }
    } else { // Company Admin & Finance strictly scoped to own company
        companyId = com.nlogistic.util.RbacContext.companyId(request);
    }
    ```

---

### 3.6 GAP-M2-06: Raw Scriptlet MVC2 Violations in Analytics & Drilldown JSPs
* **Symptoms:**
  - `profit_loss_analytics.jsp:L5-22` contains scriptlet blocks instantiating DAOs and executing queries directly in the view.
  - `shipment_drilldown.jsp:L5-18` contains scriptlet blocks extracting request parameters, running fallback queries, and binding models.
* **SRS Contract Violation:**
  - Violates **SRS Section 2.4 & Section 10.2** (Strict MVC2 separation; no Java scriptlets permitted).
* **Resolution Blueprint:**
  - Ensure all navigation links route to `/finance/profit-loss` and `/finance/shipment-drilldown?id=X`.
  - Remove all scriptlet blocks (`<% ... %>`) from both JSPs and rely exclusively on request attributes set by `FinanceServlet.java`.

---

## 4. End-to-End Use Case Specifications (7 Flows)

### UC-TRK-01: End-to-End Unified Shipment Booking & Container Allocation
* **Primary Actor:** Customer (`role_id=5`) or Company Operations Staff (`role_id=3`)
* **Preconditions:**
  - If Customer: Logged in, KYC approved (`status='Active'`), and valid `customerId` in session.
  - If Staff: Logged in with `companyId` in session.
  - Target container status is `'Available'`.
* **Trigger:** User completes booking form on `/shipments/create` or `/allocate -> /pricing`.
* **Main Success Scenario:**
  1. User selects/inputs: Customer (if staff), Origin Port, Destination Port, Container ID, Assigned Vessel, Cargo Description, Weight (kg), Volume (CBM), Declared Value, and Agreed Freight Price.
  2. Client-side script validates:
     - Cargo weight $\le$ Container `goods_capacity_kg`.
     - Cargo volume $\le$ Container `goods_capacity_cbm`.
     - Origin port $\ne$ Destination port.
  3. Form submits to `POST /shipments/save`.
  4. `ShipmentServlet` verifies contract preconditions:
     - Authenticates user session.
     - Resolves `customerId`: uses `session.customerId` for Role 5, or form parameter for staff.
  5. `ShipmentServlet` calls `ShipmentDAO.bookAndAllocateShipment(shipment)`.
  6. DAO begins database transaction:
     - Validates container status = `'Available'`.
     - Inserts record into `shipment` with `status='Booked'`.
     - Updates container status to `'Allocated'`.
     - Inserts initial movement log into `container_movements` (`status='Booked'`, `checkpoint_location='Origin Port Gate-In'`).
     - Inserts initial row into `profit_loss` (`revenue_amount = freight_cost, total_cost_amount = 0.00, profit_loss_amount = freight_cost`).
     - Commits transaction.
  7. `ShipmentServlet` invokes `BarcodeAutoGenerator.generateFor(request, "Shipment", shipmentId, userId)` to produce unique Code128 / QR barcode.
  8. Flash success message set: *"Shipment #SHP-X successfully booked and Container allocated!"*
  9. User redirected to `/shipments/tracking/detail?id=SHP-X`.
* **Alternative Flows:**
  - **2a. Cargo Exceeds Capacity:** UI flags validation error; submission blocked.
  - **6a. Container Already Allocated by Concurrent Request:** DAO detects non-available status, aborts transaction, and returns error: *"Selected container is no longer available. Please select another container."*
* **Postconditions:** Shipment created in `Booked` status; container status `'Allocated'`; `profit_loss` record initialized; barcode generated.

---

### UC-TRK-02: Checkpoint-Based Movement Lifecycle & Timestamped Audit Logging
* **Primary Actor:** Company Staff — Operations (`role_id=3`) or Company Admin (`role_id=2`)
* **Preconditions:** Shipment exists; caller has operational role (`roleId <= 3`); shipment belongs to caller's company.
* **Trigger:** Staff navigates to `/shipments/tracking/detail?id=SHP-X` and fills out the "Record Next Checkpoint" form.
* **Main Success Scenario:**
  1. Staff selects next milestone status (e.g. `In Transit`) and enters detailed terminal remarks (e.g. *"Vessel MV Pacific Star passed Malacca Strait checkpoint"*).
  2. Staff clicks **"Record Checkpoint"**.
  3. Browser posts `shipmentId`, `status`, `remarks`, and `redirectUrl` to `POST /shipments/updateStatus`.
  4. `ShipmentServlet` verifies caller has `roleId <= 3` (FR1.7).
  5. `ShipmentServlet` validates milestone order against state machine:
     - `Booked` $\rightarrow$ `Container Allocated` $\rightarrow$ `Departed` $\rightarrow$ `In Transit` $\rightarrow$ `Customs Hold` (optional) $\rightarrow$ `Arrived` $\rightarrow$ `Delivered`.
  6. `ShipmentServlet` calls `ShipmentDAO.updateStatus(shipmentId, status, remarks, userId)`.
  7. DAO executes stored procedure `{CALL update_movement_status(?, ?, ?, ?, ?, ?)}`:
     - Inserts new row into `container_movements` with `status`, `checkpoint_location=remarks`, `updated_at=NOW()`, `updated_by=userId`.
     - Updates `shipment.status = new_status`.
     - If `status == 'Departed'`, updates container status to `'In-Transit'`.
     - If `status == 'Delivered'`, updates container status to `'Available'` at destination port.
  8. Logs audit entry `SHIPMENT_STATUS_UPDATED` in `audit_log`.
  9. Flash success message displayed: *"Checkpoint recorded: Shipment #SHP-X status updated to 'In Transit'!"*
  10. Page reloads showing the new milestone in the stepper and appended to the Checkpoint Audit Trail table.
* **Exception Flows:**
  - **4a. Customer or Finance Staff Submits Status:** Servlet blocks request with `HTTP 403 Forbidden` and logs `PERMISSION_DENIED` in `audit_log`.
* **Postconditions:** Movement history updated; container status synced; visual stepper advanced.

---

### UC-TRK-03: Departure Compliance Gating Enforcement
* **Primary Actor:** Operations Staff (`role_id=3`)
* **Preconditions:** Shipment status is `Container Allocated`; next milestone requested is `Departed`.
* **Trigger:** Staff submits checkpoint update to `Departed`.
* **Main Success Scenario:**
  1. Staff submits `status='Departed'` on shipment #SHP-X.
  2. `ShipmentServlet` detects transition to `Departed`.
  3. `ShipmentServlet` executes contract precondition: `complianceDAO.canShipmentDepart(shipmentId)`.
  4. `ComplianceDAO` verifies:
     - All mandatory document types (Bill of Lading, Customs Declaration, Commercial Invoice, Packing List) exist for this shipment.
     - Every mandatory document has `status = 'Approved'`.
     - None of the documents have `expiry_date < CURDATE()`.
  5. All documents are verified; gate passes.
  6. Status advances to `Departed`.
* **Alternative Flow (Gate Rejection):**
  - **4a. Missing or Unapproved Documents:** `canShipmentDepart` returns `false`.
  - **5a.** `ShipmentServlet` aborts transition, leaves shipment status as `Container Allocated`, and sets session error:
    *"Departure Gated: Shipment #SHP-X cannot depart. One or more mandatory compliance documents are missing, unapproved, or expired. Resolve them on the Compliance page first."*
  - **6a.** User is redirected back with error banner; milestone does NOT advance.
* **Postconditions:** Shipment departs only if 100% compliant with customs and maritime laws.

---

### UC-TRK-04: Visual Route Tracking & Status Stepper Inspection
* **Primary Actor:** Customer (`role_id=5`) or Any Staff Member
* **Preconditions:** User is logged in and authorized to view the target shipment.
* **Trigger:** User navigates to `/shipments/tracking/detail?id=SHP-X`.
* **Main Success Scenario:**
  1. User accesses tracking detail URL.
  2. `ShipmentServlet` executes IDOR ownership verification:
     - If Customer: confirms `shipment.customer_id == session.customerId`.
     - If Company Staff: confirms `shipment` belongs to `session.companyId`.
  3. Servlet fetches `ShipmentDetail` and full `MovementLog` list from `ShipmentDAO`.
  4. View renders responsive 7-step horizontal timeline stepper:
     - Completed steps display solid green circles with checkmarks (`ti-check`).
     - Active current step displays an enlarged orange pulsing circle (`active-orange`).
     - Future steps display neutral gray outlines.
  5. Origin Port (Point A) and Destination Port (Point B) are prominently shown with vessel name and container ISO number.
  6. Checkpoint Audit Trail table displays all past updates with exact timestamps and staff attributions.
* **Postconditions:** User inspects shipment progression with zero security leaks.

---

### UC-TRK-05: Expected vs Actual Arrival Calculation & Delay Flagging
* **Primary Actor:** System (Automated) / Operations Staff
* **Preconditions:** Shipment has progressed to `In Transit` with established `expected_arrival_date`.
* **Trigger:** Staff records checkpoint status as `Arrived`.
* **Main Success Scenario:**
  1. Staff submits `status='Arrived'` on shipment #SHP-X.
  2. System records `actual_arrival_date = CURDATE()`.
  3. System compares `actual_arrival_date` against `expected_arrival_date`.
  4. If $\text{actual\_date} > \text{expected\_date}$:
     - Calculates $\text{delay\_days} = \text{DATEDIFF}(\text{actual\_date}, \text{expected\_date})$.
     - Updates `container_movements.delay_days = delay_days`.
     - Computes delay penalty: $\text{penalty} = \text{delay\_days} \times \$250.00$.
     - Adds penalty to `profit_loss.total_cost_amount` and recalculates `profit_loss_amount`.
     - Automatically links Loss Reason `Delay` (Reason ID 3) into `profit_loss_reason_map`.
  5. Detail page displays red warning pill: **Delayed by X days**.
* **Postconditions:** Arrival recorded; delay days and penalties calculated; loss reason automatically tagged.

---

### UC-TRK-06: Multi-Dimensional Profit & Loss Graph (PLG) Rendering
* **Primary Actor:** Super Admin (`role_id=1`), Company Admin (`role_id=2`), or Finance Staff (`role_id=4`)
* **Preconditions:** Caller has financial privileges (`roleId <= 2 || roleId == 4`).
* **Trigger:** User accesses `/finance/profit-loss`.
* **Main Success Scenario:**
  1. `FinanceServlet.doGet` receives request.
  2. Enforces tenant scope:
     - Super Admin: reads optional `companyId` filter (defaults to All).
     - Company Admin / Finance: strictly locks `companyId = session.companyId`.
  3. Extracts secondary filters: `routeId` (origin/destination port) and `dateRange`.
  4. `ProfitLossDAO` queries database:
     - Overall KPIs: Total Revenue, Total Cost, Net Profit/Loss, Average Margin %.
     - Monthly, Quarterly, and Yearly time-series trend data.
     - Loss Reason Breakdown (Impact in $ and shipment count).
     - Customer Profitability ranking.
  5. `FinanceServlet` binds data to request scope and forwards to `/jsp/profit_loss_analytics.jsp`.
  6. View renders interactive Chart.js visualizations:
     - Main Time-Series Bar/Line Chart: Net Profit/Loss over time.
     - Donut Chart: Categorized Loss Breakdown.
     - Data table with export to PDF / CSV capability.
* **Exception Flows:**
  - **1a. Operations Staff (Role 3) or Customer (Role 5) attempts access:** Intercepted by `AuthenticationFilter`, logged as `PERMISSION_DENIED`, redirected to `/dashboard`.
* **Postconditions:** Confidential financial margins rendered with zero cross-tenant leakage.

---

### UC-TRK-07: P&L Shipment Drilldown & Multi-Loss Reason Tagging
* **Primary Actor:** Company Admin (`role_id=2`) or Finance Staff (`role_id=4`)
* **Preconditions:** User is viewing PLG or shipment list; shipment is loss-making ($\text{profit\_loss\_amount} < 0$).
* **Trigger:** User clicks on a shipment in the financial table or chart, navigating to `/finance/shipment-drilldown?id=SHP-X`.
* **Main Success Scenario:**
  1. `FinanceServlet` receives drilldown request, verifies caller has financial rights, and checks shipment ownership.
  2. Retrieves full `ShipmentDrilldown` entity:
     - Revenue breakdown (freight rate, insurance, extra services).
     - Cost breakdown (fuel surcharge, port terminal handling, customs duties, delay penalty, damage claims).
     - Net Loss amount in highlighted red card.
     - Currently assigned loss reasons.
  3. User clicks **"Tag Loss Reasons"**.
  4. Modal displays the 8 standard loss reason checkboxes:
     - *Traffic in Sea*
     - *Weather Condition*
     - *Delay*
     - *Dock Allocation*
     - *Government Legal/Regulatory Hold*
     - *War/Geopolitical Disruption*
     - *Ship Issue*
     - *Damaged Product*
  5. User selects applicable reasons (e.g. *Weather Condition* + *Dock Allocation*) and submits.
  6. Form posts to `POST /finance/shipment-drilldown/save`.
  7. `ProfitLossDAO.saveLossReasons(shipmentId, selectedReasonIds)` updates `profit_loss_reason_map`.
  8. Flash success message set: *"Loss reasons updated successfully for shipment #SHP-X."*
  9. Page reloads reflecting updated loss attribution badges.
* **Postconditions:** Financial loss tagged to verified root causes; reflected in subsequent PLG breakdown charts.

---

## 5. Step-by-Step Implementation Blueprint & Code Fixes

Execute the following file-by-file refactorings to resolve all Module 2 architectural flaws:

```
================================================================================
                               MODIFICATION MATRIX
================================================================================
LAYER       FILE PATH                                     ACTION & RATIONALE
--------------------------------------------------------------------------------
Controller  com.nlogistic.controller.BookShipmentServlet Fix customer_id FK bug (user_id -> customer_id)
Controller  com.nlogistic.controller.ShipmentServlet     Enforce RBAC & compliance gate in /updateStatus
Controller  com.nlogistic.controller.FinanceServlet      Enforce tenant isolation on companyId parameter
DAO         com.nlogistic.dao.ShipmentDAO                 Atomic booking+allocation, arrival delay calc
DAO         com.nlogistic.dao.ProfitLossDAO               Dynamic cost sync & automated delay tagging
View Layout webapp/jsp/live_tracking_detail.jsp           Hide checkpoint form from Customers/Finance
View Layout webapp/jsp/profit_loss_analytics.jsp          Purge all raw scriptlets (<% ... %>)
View Layout webapp/jsp/shipment_drilldown.jsp             Purge all raw scriptlets (<% ... %>)
================================================================================
```

### 5.1 Fix Customer ID FK Bug in `BookShipmentServlet.java`

In `src/main/java/com/nlogistic/controller/BookShipmentServlet.java`:
Replace lines 51–68:

```java
// BEFORE (Buggy - puts user_id into customer_id):
ps.setInt(1, user.getUserId());

// AFTER (Compliant):
int customerId = -1;
if (user.getRoleId() == 5) {
    // Role 5: Resolve from session or CustomerDAO
    Integer sessCustId = (Integer) request.getSession().getAttribute("customerId");
    if (sessCustId != null && sessCustId > 0) {
        customerId = sessCustId;
    } else {
        com.nlogistic.model.Customer cust = new com.nlogistic.dao.CustomerDAO().getCustomerByUserId(user.getUserId());
        if (cust != null) customerId = cust.getCustomerId();
    }
} else {
    // Staff/Admin: Parse selected customer from form parameter
    String custParam = request.getParameter("customerId");
    if (custParam != null && !custParam.trim().isEmpty()) {
        customerId = Integer.parseInt(custParam.trim());
    }
}

if (customerId <= 0) {
    throw new Exception("Unable to resolve a valid Customer profile for this booking.");
}

ps.setInt(1, customerId);
```

---

### 5.2 Enforce RBAC & Compliance Gate in `ShipmentServlet.java` (`/updateStatus`)

In `src/main/java/com/nlogistic/controller/ShipmentServlet.java`:
Replace lines 184–211:

```java
} else if (pathInfo != null && pathInfo.equals("/updateStatus")) {
    // 1. Contract Precondition: Role Guard (FR1.7)
    int roleId = com.nlogistic.util.RbacContext.roleId(request);
    if (roleId > 3) { // Role 4 (Finance) and Role 5 (Customer) are strictly forbidden
        response.sendError(HttpServletResponse.SC_FORBIDDEN, 
                "Access Denied: Only Operations Staff and Administrators may record movement checkpoints.");
        return;
    }

    String shipmentIdStr = request.getParameter("shipmentId");
    String status = request.getParameter("status");
    String remarks = request.getParameter("remarks");
    String redirectUrl = request.getParameter("redirectUrl");
    
    try {
        int shipmentId = Integer.parseInt(shipmentIdStr);
        int userId = (currentUser != null) ? currentUser.getUserId() : 1;

        // 2. Tenancy Guard (CLAUDE.md S6.2)
        if (!shipmentDAO.canAccessShipment(shipmentId, roleId, 
                com.nlogistic.util.RbacContext.companyId(request), 
                com.nlogistic.util.RbacContext.customerId(request))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, 
                    "Access Denied: This shipment does not belong to your company tenant.");
            return;
        }

        // 3. Contract Precondition: Departure Compliance Gating (FR5.3 & FR2.2)
        if ("Departed".equalsIgnoreCase(status) && !complianceDAO.canShipmentDepart(shipmentId)) {
            session.setAttribute("errorMessage", "Departure Gated: Shipment #SHP-" + shipmentId 
                    + " cannot depart until all mandatory compliance documents are Approved and non-expired. Resolve them on Compliance first.");
            if (redirectUrl != null && !redirectUrl.trim().isEmpty()) {
                response.sendRedirect(redirectUrl);
            } else {
                response.sendRedirect(request.getContextPath() + "/shipments/tracking/detail?id=SHP-" + shipmentId);
            }
            return;
        }

        // 4. Record Checkpoint with dynamic delay evaluation
        shipmentDAO.updateStatus(shipmentId, status, remarks, userId);
        session.setAttribute("successMessage", "Checkpoint recorded: Shipment #SHP-" + shipmentId + " status updated to '" + status + "'!");

        if (redirectUrl != null && !redirectUrl.trim().isEmpty()) {
            response.sendRedirect(redirectUrl);
        } else {
            response.sendRedirect(request.getContextPath() + "/shipments/tracking/detail?id=SHP-" + shipmentId);
        }
    } catch (Exception e) {
        e.printStackTrace();
        session.setAttribute("errorMessage", "Failed to record checkpoint: " + e.getMessage());
        if (redirectUrl != null && !redirectUrl.trim().isEmpty()) {
            response.sendRedirect(redirectUrl);
        } else {
            response.sendRedirect(request.getContextPath() + "/shipments");
        }
    }
}
```

---

### 5.3 Enforce Tenant Isolation in `FinanceServlet.java` (FR2.6, FR2.8)

In `src/main/java/com/nlogistic/controller/FinanceServlet.java`:
Replace lines 34–39:

```java
// BEFORE (Buggy - permits cross-tenant data leak):
Integer companyId = null;
if (request.getParameter("companyId") != null && !request.getParameter("companyId").isEmpty()) {
    companyId = Integer.parseInt(request.getParameter("companyId"));
}

// AFTER (Compliant):
int roleId = com.nlogistic.util.RbacContext.roleId(request);
Integer companyId = null;

if (roleId == 1) { // Super Admin can filter by any company or view all
    if (request.getParameter("companyId") != null && !request.getParameter("companyId").isEmpty()) {
        companyId = Integer.parseInt(request.getParameter("companyId"));
    }
} else if (roleId == 2 || roleId == 4) { // Company Admin & Finance locked to own tenant
    companyId = com.nlogistic.util.RbacContext.companyId(request);
} else { // Roles 3 & 5 blocked from financial dashboards
    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Financial analytics restricted to Finance and Management.");
    return;
}
```

---

### 5.4 Hide Checkpoint Form from Non-Ops Roles in `live_tracking_detail.jsp`

In `src/main/webapp/jsp/live_tracking_detail.jsp`:
Wrap the form panel (lines 350–385) with:

```jsp
<c:if test="${sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2 || sessionScope.user.roleId == 3}">
    <!-- Live Form Panel: Record Next Checkpoint -->
    <div class="card-panel" style="margin-bottom: 0;">
        <div class="panel-header">
            <i class="ti ti-edit"></i> Record Next Checkpoint
        </div>
        ...
    </div>
</c:if>
```

---

### 5.5 Purge Raw Scriptlets from `profit_loss_analytics.jsp` & `shipment_drilldown.jsp`

Remove lines 5–22 of `profit_loss_analytics.jsp` and lines 5–19 of `shipment_drilldown.jsp`. Both views must render purely through request attributes provided by `FinanceServlet`.

---

## 6. Database Schema & Stored Procedure Specifications

### 6.1 Relational Tables
1. **`shipment`:** `shipment_id` (PK, AI), `customer_id` (FK -> customers), `container_id` (FK -> containers), `origin_port_id` (FK -> ports), `destination_port_id` (FK -> ports), `vessel_id` (FK -> vessels), `booking_date` (DATE), `cargo_description` (TEXT), `cargo_weight_kg` (DECIMAL 10,2), `cargo_volume_cbm` (DECIMAL 10,2), `cargo_declared_value` (DECIMAL 12,2), `freight_cost` (DECIMAL 12,2), `insurance_cost` (DECIMAL 12,2), `other_charges` (DECIMAL 12,2), `status` (ENUM), `created_by` (FK -> users).
2. **`container_movements`:** `movement_id` (PK, AI), `shipment_id` (FK -> shipment), `status` (VARCHAR 50), `checkpoint_location` (TEXT), `expected_arrival_date` (DATE), `actual_arrival_date` (DATE), `delay_days` (INT, Default 0), `updated_by` (FK -> users), `updated_at` (DATETIME).
3. **`profit_loss`:** `pl_id` (PK, AI), `shipment_id` (FK -> shipment, UQ), `revenue_amount` (DECIMAL 12,2), `total_cost_amount` (DECIMAL 12,2), `profit_loss_amount` (DECIMAL 12,2), `record_date` (DATE).
4. **`loss_reasons`:** `reason_id` (PK, AI), `reason_code` (VARCHAR 20, UQ), `reason_name` (VARCHAR 100), `description` (TEXT).
   - Seeded with the 8 standard reasons (FR2.7).
5. **`profit_loss_reason_map`:** `map_id` (PK, AI), `pl_id` (FK -> profit_loss), `reason_id` (FK -> loss_reasons).

### 6.2 Stored Procedures
* `book_shipment(...)`: Inserts shipment and outputs `shipment_id`.
* `allocate_container(p_shipment_id, p_container_id)`: Enforces container availability, verifies weight/CBM capacity, sets status to `'Allocated'`.
* `update_movement_status(p_shipment_id, p_status, p_checkpoint_location, p_expected_date, p_actual_date, p_updated_by)`: Inserts movement audit record, updates shipment status, recalculates `delay_days`, and syncs container status (`In-Transit` / `Available`).

---

## 7. Verification & Quality Assurance Test Suite

The following 12 test cases validate that all Module 2 requirements and bug fixes operate flawlessly:

| Test ID | Objective | Input / Action | Expected Result | Pass Criteria |
| :--- | :--- | :--- | :--- | :--- |
| **TC-TRK-01** | Verify Customer Booking links correct `customer_id`. | Customer logs in and books a shipment on `/book`. | `shipment.customer_id` matches `customers.customer_id` (NOT `user_id`). | Foreign key valid; customer sees shipment in their portal. |
| **TC-TRK-02** | Verify Container Allocation sync on Booking. | Complete shipment booking for container `CONT-101`. | Container status updates from `Available` to `Allocated`. | DB `containers.status = 'Allocated'`. |
| **TC-TRK-03** | Verify Initial P&L Record Creation on Booking. | Complete shipment booking with freight rate $3,500.00. | Row created in `profit_loss` with `revenue = 3500.00, cost = 0.00, profit = 3500.00`. | Row exists in `profit_loss` linked via `shipment_id`. |
| **TC-TRK-04** | Verify Checkpoint Stepper UI rendering (FR2.2 & FR2.4). | View `/shipments/tracking/detail?id=SHP-1` in `In Transit` status. | Steps 1–3 green checkmarks; step 4 active orange circle; steps 5–7 gray. | Correct visual state matching database status. |
| **TC-TRK-05** | Verify Departure Compliance Gate (FR5.3). | Attempt to set status to `Departed` with 0 compliance docs. | Blocked with error: *"Departure Gated: Mandatory compliance documents missing"*. | Status remains `Container Allocated`; no departure logged. |
| **TC-TRK-06** | Verify RBAC Block on Checkpoint Submission (FR1.7 & FR2.3). | Customer or Finance submits `POST /shipments/updateStatus`. | Request blocked with `HTTP 403 Forbidden`. Audit log records denial. | Status unchanged; non-ops users cannot modify movement. |
| **TC-TRK-07** | Verify Delay Days Computation (FR2.5). | Record `Arrived` on shipment 5 days past `expected_arrival_date`. | `delay_days` calculated as `5`; delay penalty added to P&L. | Red badge **Delayed by 5 days** displayed. |
| **TC-TRK-08** | Verify Automated Delay Loss Tagging (FR2.7). | Shipment arrival delayed by 5 days. | Loss Reason `Delay` automatically inserted into `profit_loss_reason_map`. | Drilldown displays "Delay" badge without manual input. |
| **TC-TRK-09** | Verify Tenant Isolation in PLG (FR2.8). | Company 2 Admin accesses `/finance/profit-loss?companyId=3`. | Servlet overrides parameter and enforces `companyId = 2`. | User only sees Company 2 financials. |
| **TC-TRK-10** | Verify Financial Drilldown (FR2.9). | Click shipment row in financial analytics table. | Opens `/finance/shipment-drilldown?id=SHP-X` with full revenue/cost breakdown. | Accurate cost breakdown displayed; no 404/500 errors. |
| **TC-TRK-11** | Verify Multi-Loss Reason Tagging (FR2.7). | Select *Weather Condition* and *Ship Issue* in drilldown modal. | `profit_loss_reason_map` stores both reason IDs for this shipment. | Both badges appear on shipment drilldown view. |
| **TC-TRK-12** | Pure MVC2 JSP Compliance. | Inspect `profit_loss_analytics.jsp` and `shipment_drilldown.jsp`. | Zero scriptlets (`<% ... %>`) remain in view files. | JSPs contain only JSTL and EL expressions. |

---

## 8. Summary & Transition to Module 3

With this Mega Specification for Module 2 in place:
1. The critical foreign key bug in `BookShipmentServlet` has an exact fix.
2. The dual booking conflict (`/allocate` vs `/shipments/create`) is unified.
3. The bypassed departure compliance gate in quick checkpoints is closed.
4. Tenant isolation leaks in `FinanceServlet` are sealed.
5. All 7 end-to-end Use Cases are formalized with complete preconditions, postconditions, and exception flows.

**Next Milestone:** Upon user sign-off of Module 2, we will proceed immediately to generate the dedicated **Module 3 Mega Specification** covering **Container Allocation and Dynamic Pricing with Predictive Demand Graph (FR3.1 – FR3.6)**.
