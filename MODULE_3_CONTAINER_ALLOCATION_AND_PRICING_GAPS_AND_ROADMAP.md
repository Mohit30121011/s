# MODULE 3: CONTAINER ALLOCATION, DYNAMIC PRICING & PREDICTIVE GRAPH — MEGA GAP SPECIFICATION & IMPLEMENTATION ROADMAP

> **Standard:** IEEE 830-1998 Software Requirements Specification Alignment  
> **Target Module:** Module 3 — Container Allocation and Pricing (FR3.1 – FR3.7 & Section 5.5)  
> **Platform:** N Logistic Import & Export Enterprise Suite  
> **Tech Stack:** Java 11 / Jakarta EE (Servlet 4.0 / JSP 2.3) · JDBC · MySQL 8.0 · Chart.js · Bootstrap 5 · MVC2 Architecture  
> **Reference Documents:** 
> - [srs_harness.md](file:///d:/NLogistic/NLogistic/srs_harness.md) (Section 3.3, Section 5.5, Section 6.2, Section 6.4)
> - [CLAUDE.md](file:///d:/NLogistic/NLogistic/CLAUDE.md) (Container Master Data & Pricing Architecture)
> - [SYSTEM_GAPS_AND_MISSING_FEATURES.md](file:///d:/NLogistic/NLogistic/SYSTEM_GAPS_AND_MISSING_FEATURES.md) (Disconnect 1: Dual Booking)
> - [MODULE_1_AUTH_GAPS_AND_ROADMAP.md](file:///d:/NLogistic/NLogistic/MODULE_1_AUTH_GAPS_AND_ROADMAP.md)
> - [MODULE_2_TRACKING_AND_PLG_GAPS_AND_ROADMAP.md](file:///d:/NLogistic/NLogistic/MODULE_2_TRACKING_AND_PLG_GAPS_AND_ROADMAP.md)

---

## 1. Executive Summary & Module Scope

Module 3 governs physical container fleet inventory, physical cargo allocation constraints, algorithmic dynamic pricing, and advance predictive demand forecasting. It acts as the operational bridge between a customer's cargo booking intent and the physical maritime vessel. It ensures that no container is ever overloaded beyond legal tare/gross limits (CBM volume or metric tonnage), computes commercial freight rates using real-time seasonal and demand surge multipliers, projects corridor demand trends 6 periods into the future, and maintains an immutable audit trail of all rate tariff adjustments.

### Core Objectives of Module 3:
1. **Container Master Catalog (FR3.1):** Maintain comprehensive specifications for the entire fleet: Container ISO Number, Type (*Dry, Reefer, Open Top, Flat Rack, Tank*), Size (*20ft, 40ft, 40ft HC, 45ft*), scannable Image, Tare Weight (kg), Maximum Gross Weight (kg), Goods Capacity (kg & CBM), Status (*Available, Allocated, In-Transit, Under Maintenance*), Current Port Location, and Owning Company Tenant.
2. **Visual Allocation Interface (FR3.2):** Deliver a rich allocation dashboard displaying container visuals, dimensional capacity gauges, and real-time utilization progress bars to both internal staff and external customers.
3. **Container Availability Invariant (FR3.3):** Enforce strict Design-by-Contract rules guaranteeing that only containers in `'Available'` status can ever be allocated to a shipment booking.
4. **Cargo Fit Capacity Precondition (FR3.4):** Programmatically reject any cargo whose declared weight ($\text{kg}$) or physical volume ($\text{CBM}$) exceeds the container's certified maximum payload limits.
5. **Algorithmic Dynamic Pricing Engine (FR3.5):** Compute freight rates using the multi-factor formula:
   $$\text{Final Price} = (\text{Base Price} \times \text{Seasonal Multiplier} \times \text{Demand Multiplier}) + \text{Surcharges}$$
   where the Demand Multiplier is dynamically derived from historical booking velocity and the Demand Forecasting Algorithm (Section 5.5).
6. **Advance Predictive Graph (FR3.6):** Render multi-period projection curves (default 6 periods) visualising forecasted demand volume and projected freight price movements per container type and sea corridor.
7. **Rate Governance & Pricing Audit Trail (FR3.7):** Capture an immutable audit record of every rate modification, recording previous base price, new base price, mandatory justification reason, timestamp, and the responsible administrator's identity.

---

## 2. SRS Requirements vs Current Implementation Audit

The following matrix compares every requirement in Module 3 against the active codebase:

| Req ID | SRS Specification Description | Codebase Component(s) | Current Implementation Status | Severity / Defect Type |
| :--- | :--- | :--- | :--- | :--- |
| **FR3.1** | Maintain container master catalog: number, type, size, image, tare, max gross, goods capacity (kg & CBM), status, port, owner. | [ContainerServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ContainerServlet.java)<br>[ContainerDAO.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ContainerDAO.java)<br>[containers.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/containers.jsp) | **PARTIAL / TENANT LEAK**<br>1. All fields stored and rendered.<br>2. [ContainerDAO.java:L20-29](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ContainerDAO.java#L20-L29) fails to filter by `owner_company_id` for company tenants.<br>3. `POST /containers/update` and `/delete` have no ownership checks (Company A can delete Company B's fleet). | High / Cross-Tenant Data Leak & Mutation |
| **FR3.2** | Allocation screen displaying container image, size, and goods capacity to staff and customers. | [AllocateContainerServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/AllocateContainerServlet.java)<br>[allocate-container.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/allocate-container.jsp) | **COMPLIANT IN UI**<br>Displays image banner, ISO number, type pill, weight progress bar, volume progress bar, and real port dropdowns. | Low / Working As Intended |
| **FR3.3** | Prevent allocation of a container not in Available status (contract invariant). | [AllocateContainerServlet.java:L70](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/AllocateContainerServlet.java#L70)<br>DB SP `allocate_container` | **PARTIAL**<br>Enforced in `/allocate`, but bypassed if booking directly through `/shipments/save`! | High / Inconsistent Gate Enforcement |
| **FR3.4** | Prevent allocation of cargo exceeding container weight or volume capacity (contract precondition). | [AllocateContainerServlet.java:L76-90](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/AllocateContainerServlet.java#L76-L90)<br>[allocate-container.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/allocate-container.jsp) | **COMPLIANT IN ALLOCATE / BYPASSED IN SHIPMENTS**<br>Client JS blocks submit; servlet verifies `cargoWeight <= capKg` and `cargoVolume <= capCbm`. But bypassed if user submits via `/shipments/save`. | Medium / Dual Flow Disconnect |
| **FR3.5** | Dynamic pricing engine: $\text{Final Price} = \text{Base} \times \text{Seasonal} \times \text{Demand} + \text{Surcharges}$, Demand Multiplier from Sec 5.5. | [PricingRule.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/model/PricingRule.java)<br>[PricingRuleDAO.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/PricingRuleDAO.java)<br>[pricing.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/pricing.jsp) | **PARTIAL / DISCONNECTED**<br>1. Formula implemented in `PricingRule.calculateFinalPrice()`.<br>2. But `demand_multiplier` is static in DB and never updated by the Demand Forecasting Algorithm.<br>3. `pricing.jsp` overloaded with 60 lines of raw scriptlets. | High / Algorithm Disconnect & MVC2 Breach |
| **FR3.6** | Advance Predictive Graph per container type/route showing forecasted demand and price trend for next N periods (default 6). | [PredictiveGraphServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/PredictiveGraphServlet.java)<br>[predictive-graph.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/predictive-graph.jsp) | **PARTIAL / MISSING ROUTE FILTER**<br>1. Renders Chart.js dual-axis graph for 6 periods.<br>2. [PredictiveGraphServlet.java:L40](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/PredictiveGraphServlet.java#L40) filters ONLY by `container_type` and ignores `route_id`.<br>3. Contains scriptlet fallbacks in JSP. | Medium / Incomplete Corridors & MVC2 Breach |
| **FR3.7** | Every price change logged with old value, new value, reason, timestamp, and responsible user. | [PricingRuleDAO.java:L108-117](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/PricingRuleDAO.java#L108-L117)<br>`pricing_audit` table<br>[pricing.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/pricing.jsp) | **COMPLIANT**<br>Captures `old_price`, `new_price`, `changed_by`, `reason`, `changed_at` into `pricing_audit` and displays in audit table. | Low / Working As Intended |

---

## 3. Deep-Dive Forensic Gap Breakdown

### 3.1 GAP-M3-01: Cross-Tenant Fleet Isolation & Mutation Vulnerability (FR3.1)
* **Symptoms:**
  - Company Admins (Role 2) and Operations Staff (Role 3) logged in under "Maersk Logistics" can see, edit, and delete container assets belonging to "Evergreen Marine" on `/containers`.
* **Root Cause Analysis:**
  1. In [ContainerDAO.java:L20-30](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ContainerDAO.java#L20-L30), the base query is:
     ```sql
     SELECT c.*, p.port_name, p.country AS port_country, co.company_name AS owner_company_name 
     FROM containers c 
     LEFT JOIN ports p ON c.current_port_id = p.port_id 
     LEFT JOIN companies co ON c.owner_company_id = co.company_id
     ```
     The query does not filter on `owner_company_id`.
  2. In [ContainerServlet.java:L39-74 & L121-124](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ContainerServlet.java#L39-L74):
     ```java
     } else if (pathInfo != null && pathInfo.equals("/delete")) {
         containerDAO.deleteContainer(Integer.parseInt(request.getParameter("id")), currentUser.getUserId());
     ```
     The servlet does not verify whether the container to be modified or deleted actually belongs to `currentUser.getCompanyId()`. An authenticated user from Company A can send a POST request with `id=X` (belonging to Company B) and delete or reassign it.
* **Resolution Blueprint:**
  - Update `ContainerDAO.getContainers` to accept `Integer companyId`:
    - If Super Admin (`roleId == 1`) or Customer (`roleId == 5` browsing available containers): allow cross-company viewing.
    - If Company Staff (`roleId == 2 || roleId == 3`): inject `AND c.owner_company_id = ?`.
  - In `ContainerServlet.doPost`, verify container ownership before executing `/update` or `/delete`:
    ```java
    Container target = containerDAO.getContainerById(containerId);
    if (currentUser.getRoleId() != 1 && (target == null || target.getOwnerCompanyId() != currentUser.getCompanyId())) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: You do not own this container asset.");
        return;
    }
    ```

---

### 3.2 GAP-M3-02: Missing Customer Selection in Allocation & Pricing Summary
* **Symptoms:**
  - When operations staff completes container allocation on `allocate-container.jsp` and proceeds to `pricing.jsp`, the quote displays and the staff member clicks "Confirm Booking & Allocate Container".
  - The booking submits to `/book` (`BookShipmentServlet`), which inserts the staff member's own `user_id` as the customer!
* **Root Cause Analysis:**
  1. `allocate-container.jsp` collects cargo weight, volume, description, and origin/destination ports, but **omits a Customer selection dropdown**.
  2. `pricing.jsp` has hidden inputs for container ID, cargo dimensions, and ports, but has **no `customerId` input**.
  3. When staff books on behalf of a commercial shipper, the system has no idea who the customer is, causing foreign key corruption or linking the shipment to the staff user.
* **Resolution Blueprint:**
  - In `allocate-container.jsp`, if `currentUser.getRoleId() <= 3` (Staff/Admin), display a searchable Customer dropdown:
    ```jsp
    <c:if test="${sessionScope.user.roleId <= 3}">
        <div class="col-md-12 mb-3">
            <label class="allocate-form-label">Customer / Shipper <span class="req">*</span></label>
            <select name="customerId" class="form-select-custom" required>
                <option value="" disabled selected>Select Customer Account</option>
                <c:forEach var="cust" items="${customers}">
                    <option value="${cust.customerId}">${cust.customerName} (ID: #${cust.customerId})</option>
                </c:forEach>
            </select>
        </div>
    </c:if>
    ```
  - Pass `customerId` through `AllocateContainerServlet` into `pricing.jsp` as `<input type="hidden" name="customerId" value="${customerId}">`.
  - In `BookShipmentServlet`, extract `customerId` from the form parameter for staff, or from `sessionScope.customerId` for customer self-bookings.

---

### 3.3 GAP-M3-03: Demand Multiplier Algorithmic Disconnect (FR3.5 & Section 5.5)
* **Symptoms:**
  - In `pricing_rules`, the `demand_multiplier` is stored as a static decimal (e.g. `1.15`).
  - As bookings surge or decline on a given trade lane, the multiplier never adjusts dynamically based on the Section 5.5 Demand Forecasting Algorithm.
* **SRS Requirement (FR3.5 & Section 5.5):**
  - *"A dynamic pricing engine shall compute Final Price = Base Price × Seasonal Multiplier × Demand Multiplier + Surcharges, where the Demand Multiplier is derived from the Demand Forecasting Algorithm (Section 5.5)."*
* **Root Cause Analysis:**
  - There is no background job, trigger, or calculation service that recomputes the `demand_multiplier` in `pricing_rules` based on recent booking counts in `shipment` and `demand_forecast`.
* **Resolution Blueprint:**
  - Implement dynamic multiplier derivation in `PricingRuleDAO`:
    $$\text{demand\_multiplier} = 1.0 + \min\left(0.50, \max\left(-0.20, \frac{\text{forecasted\_demand} - \text{average\_capacity}}{\text{average\_capacity}}\right)\right)$$
  - Provide an automated synchronization method `PricingRuleDAO.syncDemandMultipliers()` that updates `pricing_rules.demand_multiplier` whenever the Demand Forecasting Algorithm executes.

---

### 3.4 GAP-M3-04: Route Parameter Missing from Predictive Demand Graph (FR3.6)
* **Symptoms:**
  - On `/predictive-graph`, selecting "Dry Container" renders a 6-month forecast curve, but the curve represents an arbitrary aggregate across all world ports combined, rather than the specific trade lane requested.
* **SRS Requirement (FR3.6):**
  - *"The system shall display an Advance Predictive Graph per container type/route showing forecasted demand and price trend for the next N periods (default 6, configurable)."*
* **Root Cause Analysis:**
  - In [PredictiveGraphServlet.java:L40](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/PredictiveGraphServlet.java#L40):
    ```sql
    SELECT forecast_period, forecasted_demand, forecasted_price 
    FROM demand_forecast 
    WHERE container_type = ? 
    ORDER BY forecast_id ASC LIMIT 6
    ```
    The query filters only on `container_type = ?`. The `demand_forecast` table contains a `route_id` column, but `PredictiveGraphServlet` completely ignores it.
* **Resolution Blueprint:**
  - Expand `PredictiveGraphServlet.doGet` to extract `routeId` (origin/destination port pair):
    ```sql
    SELECT forecast_period, forecasted_demand, forecasted_price 
    FROM demand_forecast 
    WHERE container_type = ? AND (route_id = ? OR ? IS NULL)
    ORDER BY forecast_id ASC LIMIT 6
    ```
  - Add a "Trade Route / Corridor" dropdown on `predictive-graph.jsp` populated with standard maritime routes.

---

### 3.5 GAP-M3-05: Raw Scriptlet MVC2 Violations in `pricing.jsp` & `predictive-graph.jsp`
* **Symptoms:**
  - Lines 1–55 of `pricing.jsp` contain raw scriptlets calculating KPIs (`kpiTotalRules`, `maxBasePrice`, `avgFinalPrice`) and instantiating `PricingRuleDAO`.
  - Lines 1–11 of `predictive-graph.jsp` contain raw scriptlets instantiating `PricingRuleDAO` to load audit history.
* **SRS Contract Violation:**
  - Violates **SRS Section 2.4 & Section 10.2** (Strict MVC2 separation; no Java scriptlets permitted).
* **Resolution Blueprint:**
  - Move all KPI calculations and DAO queries into `PricingServlet.java` and `PredictiveGraphServlet.java`.
  - Remove all `<% ... %>` scriptlet blocks from both JSPs and bind data strictly through request attributes.

---

## 4. End-to-End Use Case Specifications (7 Flows)

### UC-ALLOC-01: Container Master Catalog Management & Image Upload (FR3.1)
* **Primary Actor:** Company Admin (`role_id=2`) or Super Admin (`role_id=1`)
* **Preconditions:** Caller is authenticated with administrative privileges.
* **Trigger:** Admin navigates to `/containers` and clicks **"Add New Container"**.
* **Main Success Scenario:**
  1. Admin enters: Container ISO Number (e.g. `MSKU-908234-1`), Container Type (`Dry`, `Reefer`, `Open Top`, `Flat Rack`, `Tank`), Size (`20ft`, `40ft`, `40ft HC`, `45ft`), Tare Weight (kg), Max Gross Weight (kg), Goods Capacity (kg), Goods Capacity (CBM), Initial Port Location, and uploads a container photo (PNG/JPG).
  2. Client-side script validates:
     - ISO container number matches standard 4-letter prefix + 7 digits.
     - $\text{Max Gross Weight} \ge \text{Tare Weight} + \text{Goods Capacity (kg)}$.
     - Image file $\le 10\text{MB}$.
  3. Form submits to `POST /containers/add` (`multipart/form-data`).
  4. `ContainerServlet` processes upload, saves image to `/uploads/containers/cont_<timestamp>.<ext>`.
  5. Sets `owner_company_id = currentUser.getCompanyId()`.
  6. Calls `ContainerDAO.addContainer(...)`.
  7. Container record inserted with `status = 'Available'`.
  8. Auto-generates unique barcode record via `BarcodeAutoGenerator.generateFor(request, "Container", newContainerId, userId)`.
  9. Admin redirected to `/containers` with success notification: *"Container MSKU-908234-1 registered successfully!"*
* **Alternative Flows:**
  - **2a. Duplicate Container Number:** DB throws unique constraint violation; servlet displays error: *"A container with this ISO number already exists in the registry."*
* **Postconditions:** Container asset registered in `Available` status; barcode generated.

---

### UC-ALLOC-02: Container Allocation & Cargo Fit Precondition Enforcement (FR3.2, FR3.3, FR3.4)
* **Primary Actor:** Operations Staff (`role_id=3`) or Customer (`role_id=5`)
* **Preconditions:** Target container exists and has `status = 'Available'`.
* **Trigger:** User selects an available container and clicks **"Allocate Cargo"**, landing on `/allocate?containerId=X`.
* **Main Success Scenario:**
  1. System displays container visual specifications: photo, type pill, certified max weight, certified max volume, and live utilization progress bars.
  2. User enters: Cargo Description, Declared Total Weight (kg), Declared Total Volume (CBM), Origin Port, Destination Port, and Customer (if staff).
  3. Live JavaScript updates dynamic capacity meters:
     - If $\text{weight} \le \text{Max Weight}$ and $\text{volume} \le \text{Max Volume}$, progress bars render green/blue with percentage indicators.
     - If limits exceeded, progress bars turn red, and submit button toggles to warning state.
  4. User clicks **"Validate & Calculate Rate"**.
  5. Form submits to `POST /allocate`.
  6. `AllocateContainerServlet` validates Design-by-Contract rules server-side:
     - **Invariant Check (FR3.3):** Confirms `container.status == 'Available'`.
     - **Precondition Check (FR3.4):** Confirms `cargoWeight <= container.goodsCapacityKg` AND `cargoVolume <= container.goodsCapacityCbm`.
  7. Preconditions pass. Servlet retrieves applicable `PricingRule` for container type and size.
  8. Computes provisional quote: `finalPrice = rule.calculateFinalPrice()`.
  9. Forwards request attributes to `/jsp/pricing.jsp`.
* **Exception Flows:**
  - **6a. Container No Longer Available (FR3.3):** If container was allocated by another concurrent booking, servlet rejects allocation with error: *"Allocation Failed: Container is no longer available."*
  - **6b. Cargo Exceeds Capacity (FR3.4):** If weight or volume exceeds payload, servlet rejects allocation, preserves user inputs, and re-renders `/jsp/allocate-container.jsp` with error: *"Allocation Failed: Cargo weight (X kg) or volume (Y CBM) exceeds container certified payload limit!"*
* **Postconditions:** Cargo fit certified; preliminary tariff quote generated.

---

### UC-ALLOC-03: Dynamic Pricing Calculation & Tariff Breakdown (FR3.5)
* **Primary Actor:** Customer (`role_id=5`) or Operations Staff (`role_id=3`)
* **Preconditions:** Allocation preconditions passed in UC-ALLOC-02; user forwarded to `/jsp/pricing.jsp` in quote mode.
* **Trigger:** View renders the verified commercial tariff quote.
* **Main Success Scenario:**
  1. System displays a transparent rate breakdown card:
     - **Commercial Base Rate:** Standard corridor tariff (e.g. `$2,400.00`).
     - **Seasonal Multiplier:** Peak season / monsoon factor (e.g. `× 1.15`).
     - **Demand Multiplier:** Real-time demand surge index from Predictive Engine (e.g. `× 1.10`).
     - **Surcharges:** Terminal handling (THC) + Low-Sulfur Bunker charge (e.g. `+$350.00`).
     - **Total Calculated Rate:** Hero card displaying $[(2400 \times 1.15 \times 1.10) + 350] = \$3,386.00$.
  2. Route card visually displays Point A (Origin Port) $\rightarrow$ Oceanic Corridor $\rightarrow$ Point B (Destination Port).
  3. User reviews and clicks **"Confirm Booking & Allocate Container"**.
  4. Submits to `POST /book`.
  5. Unified booking service executes: creates shipment, marks container `'Allocated'`, initializes `profit_loss`, and generates barcode.
* **Postconditions:** Rate locked and committed; shipment booked.

---

### UC-ALLOC-04: Multiplier-Driven Dynamic Price Recalculation (FR3.5)
* **Primary Actor:** System (Automated) / Company Admin (`role_id=2`)
* **Preconditions:** Caller is Company Admin or background scheduler.
* **Trigger:** Demand surge detected or seasonal calendar transition occurs.
* **Main Success Scenario:**
  1. System triggers rate multiplier update for a container profile (e.g. `40ft Reefer`).
  2. Submits `pricingId`, `seasonalMultiplier=1.25`, and `demandMultiplier=1.20` to `POST /pricing/update`.
  3. `PricingServlet` verifies admin privileges (`roleId <= 2`).
  4. `PricingRuleDAO.updateMultipliers` calculates new final price:
     $$\text{new\_final\_price} = \text{base\_price} \times 1.25 \times 1.20$$
  5. Updates `pricing_rules` table.
  6. Automatically logs entry in `pricing_audit` capturing old price, new price, user, and timestamp.
  7. Subsequent customer bookings automatically reflect the new surged rate.
* **Postconditions:** Active commercial tariff updated; audit trail recorded.

---

### UC-ALLOC-05: Rate Governance Base-Price Adjustment & Audit Logging (FR3.7)
* **Primary Actor:** Super Admin (`role_id=1`) or Company Admin (`role_id=2`)
* **Preconditions:** Admin is logged in; viewing Rate Governance table on `/pricing`.
* **Trigger:** Admin clicks **"Adjust Tariff"** on a pricing rule.
* **Main Success Scenario:**
  1. Admin enters new Base Price (e.g. from `$2,200.00` to `$2,500.00`) and a **mandatory justification reason** (e.g. *"Q3 Fuel Bunkering Cost Escalation"*).
  2. Form submits to `POST /pricing/updatePrice`.
  3. `PricingServlet` enforces contract preconditions:
     - Caller `roleId <= 2`.
     - Reason field non-empty.
     - New Base Price $> 0$.
  4. `PricingRuleDAO` calls stored procedure `{CALL update_price(p_pricing_id, p_new_base_price, p_changed_by, p_reason)}`.
  5. Stored procedure:
     - Fetches existing `base_price` and multipliers.
     - Calculates new `final_price = p_new_base_price * seasonal_multiplier * demand_multiplier`.
     - Updates `pricing_rules`.
     - Inserts record into `pricing_audit` capturing `old_price`, `new_price`, `changed_by`, `reason`, and `NOW()`.
  6. Flash success message displayed: *"Tariff updated successfully and logged in Pricing Audit Trail."*
  7. Audit history table at the bottom of the page displays the new audit row with admin username, old rate, new rate, and justification.
* **Exception Flows:**
  - **3a. Reason Omitted:** Servlet blocks submission, redirects back with error: *"Justification reason is required for all base rate adjustments (FR3.7)."*
* **Postconditions:** Base rate modified; audit trail permanently recorded.

---

### UC-ALLOC-06: Advance Predictive Demand & Pricing Graph Generation (FR3.6 & Section 5.5)
* **Primary Actor:** Company Admin (`role_id=2`), Finance (`role_id=4`), or Super Admin (`role_id=1`)
* **Preconditions:** Caller has access to analytics (`roleId <= 2 || roleId == 4`); historical shipment and booking data exist.
* **Trigger:** User navigates to `/predictive-graph`.
* **Main Success Scenario:**
  1. User selects Container Type (e.g. `40ft High Cube`) and Maritime Route (e.g. `Port of Singapore -> Port of Rotterdam`).
  2. `PredictiveGraphServlet` queries `demand_forecast` table for the next 6 future periods:
     ```sql
     SELECT forecast_period, forecasted_demand, forecasted_price 
     FROM demand_forecast 
     WHERE container_type = ? AND route_id = ? 
     ORDER BY forecast_id ASC LIMIT 6
     ```
  3. Formats projection series into Chart.js dual-axis JSON:
     - Left Axis (Blue Bar Chart): Forecasted Demand in TEU volume.
     - Right Axis (Orange Line Chart): Projected Freight Rate ($/container).
  4. Binds current base price and recent pricing audit entries for the selected profile.
  5. Forwards to `/jsp/predictive-graph.jsp`.
  6. View renders interactive chart showing seasonal demand peaks and predictive price trends.
* **Postconditions:** 6-period predictive business intelligence visualized for management decision-making.

---

### UC-ALLOC-07: Self-Service Customer Container Booking & Immediate Reservation
* **Primary Actor:** Customer (`role_id=5`)
* **Preconditions:** Customer account is active; credit limit verified or card payment enabled.
* **Trigger:** Customer browses container catalog on `/containers` with filter `status=Available`.
* **Main Success Scenario:**
  1. Customer views available containers across ports.
  2. Selects container `CONT-40HC-012`, enters cargo specs (garments, 18,000 kg, 55 CBM).
  3. System validates cargo fit; displays transparent quote: `$3,100.00`.
  4. Customer confirms booking.
  5. System creates shipment linked directly to `session.customerId`.
  6. Container status flips to `'Allocated'` immediately.
  7. Customer redirected to live tracking page displaying Point A $\rightarrow$ Point B route and Step 1 `Booked`.
* **Postconditions:** Container reserved; customer shipment live in portal.

---

## 5. Step-by-Step Implementation Blueprint & Code Fixes

Execute the following file-by-file refactorings:

```
================================================================================
                               MODIFICATION MATRIX
================================================================================
LAYER       FILE PATH                                     ACTION & RATIONALE
--------------------------------------------------------------------------------
Controller  com.nlogistic.controller.ContainerServlet    Enforce multi-tenant fleet isolation in update/delete
Controller  com.nlogistic.controller.AllocateContainerServlet Add Customer list for staff, pass customerId
Controller  com.nlogistic.controller.PredictiveGraphServlet   Add route_id filter & trade lane parameter
DAO         com.nlogistic.dao.ContainerDAO                Filter by owner_company_id for company roles
DAO         com.nlogistic.dao.PricingRuleDAO              Automate demand multiplier derivation (Sec 5.5)
View Admin  webapp/jsp/allocate-container.jsp             Add Customer dropdown for staff booking
View Admin  webapp/jsp/pricing.jsp                        Purge raw scriptlets (<% ... %>), add customerId hidden
View Admin  webapp/jsp/predictive-graph.jsp               Add Route dropdown, purge raw scriptlets
================================================================================
```

### 5.1 Enforce Fleet Tenancy in `ContainerDAO.java` & `ContainerServlet.java`

#### In `src/main/java/com/nlogistic/dao/ContainerDAO.java`:
Update `getContainers` (lines 18–30) to accept `Integer companyId`:

```java
public List<Container> getContainers(String statusFilter, Integer companyId, int limit, int offset) {
    List<Container> containers = new ArrayList<>();
    StringBuilder sql = new StringBuilder(
        "SELECT c.*, p.port_name, p.country AS port_country, co.company_name AS owner_company_name " +
        "FROM containers c " +
        "LEFT JOIN ports p ON c.current_port_id = p.port_id " +
        "LEFT JOIN companies co ON c.owner_company_id = co.company_id WHERE 1=1 ");

    if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("All")) {
        sql.append(" AND c.status = ? ");
    }
    if (companyId != null && companyId > 0) {
        sql.append(" AND c.owner_company_id = ? ");
    }

    sql.append(" ORDER BY c.container_id DESC LIMIT ? OFFSET ?");

    try (Connection conn = DBConnectionManager.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql.toString())) {
        
        int idx = 1;
        if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("All")) {
            ps.setString(idx++, statusFilter);
        }
        if (companyId != null && companyId > 0) {
            ps.setInt(idx++, companyId);
        }
        ps.setInt(idx++, limit);
        ps.setInt(idx++, offset);

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                containers.add(mapResultSetToContainer(rs));
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return containers;
}
```

#### In `src/main/java/com/nlogistic/controller/ContainerServlet.java`:
Update `doGet` (lines 29–33) to pass `companyId`:

```java
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    int roleId = com.nlogistic.util.RbacContext.roleId(request);
    Integer companyId = null;
    // Super Admin (1) and Customers (5) can view all available containers
    // Company staff (2 & 3) view their own fleet
    if (roleId == 2 || roleId == 3) {
        companyId = com.nlogistic.util.RbacContext.companyId(request);
    }

    request.setAttribute("containers", containerDAO.getContainers("All", companyId, 1000, 0));
    request.setAttribute("ports", portDAO.getAllPorts());
    request.getRequestDispatcher("/jsp/containers.jsp").forward(request, response);
}
```

---

### 5.2 Add Customer Dropdown for Staff in `allocate-container.jsp` & `AllocateContainerServlet.java`

#### In `src/main/java/com/nlogistic/controller/AllocateContainerServlet.java`:
In `doGet` (lines 43–48), provide customer list:

```java
request.setAttribute("container", container);
request.setAttribute("ports", portDAO.getAllPorts());
if (com.nlogistic.util.RbacContext.roleId(request) <= 3) {
    request.setAttribute("customers", new com.nlogistic.dao.CustomerDAO().getAllCustomers());
}
request.getRequestDispatcher("/jsp/allocate-container.jsp").forward(request, response);
```

In `doPost` (lines 98–106), extract and forward `customerId`:

```java
String custIdParam = request.getParameter("customerId");
if (custIdParam != null && !custIdParam.trim().isEmpty()) {
    request.setAttribute("customerId", Integer.parseInt(custIdParam.trim()));
} else if (user.getRoleId() == 5) {
    request.setAttribute("customerId", request.getSession().getAttribute("customerId"));
}
```

#### In `src/main/webapp/jsp/allocate-container.jsp`:
Insert customer dropdown inside the form:

```jsp
<c:if test="${sessionScope.user.roleId <= 3}">
    <div class="col-md-12 mb-3">
        <label class="allocate-form-label">Booking Customer / Shipper <span style="color: #FC8019;">*</span></label>
        <div class="select-wrapper">
            <select name="customerId" class="form-select-custom" required>
                <option value="" disabled selected>Select Customer Account</option>
                <c:forEach var="cust" items="${customers}">
                    <option value="${cust.customerId}">${cust.customerName} (ID: #${cust.customerId})</option>
                </c:forEach>
            </select>
        </div>
    </div>
</c:if>
```

#### In `src/main/webapp/jsp/pricing.jsp`:
In the booking confirmation form (line 1085), pass `customerId`:

```jsp
<form action="<c:url value='/book'/>" method="POST">
    <input type="hidden" name="customerId" value="${customerId}">
    <input type="hidden" name="containerId" value="${container.containerId}">
    <input type="hidden" name="cargoWeight" value="${cargoWeight}">
    <input type="hidden" name="cargoVolume" value="${cargoVolume}">
    <input type="hidden" name="cargoDesc" value="${cargoDesc}">
    <input type="hidden" name="finalPrice" value="${finalPrice}">
    <input type="hidden" name="origin" value="${origin}">
    <input type="hidden" name="destination" value="${destination}">
    
    <button type="submit" class="btn-confirm-booking-cta">
        <i class="ti ti-circle-check"></i> Confirm Booking &amp; Allocate Container
    </button>
</form>
```

---

### 5.3 Add Route Filtering in `PredictiveGraphServlet.java` (FR3.6)

In `src/main/java/com/nlogistic/controller/PredictiveGraphServlet.java`:
Update lines 27–45:

```java
String containerType = request.getParameter("type");
if (containerType == null || containerType.trim().isEmpty()) {
    containerType = "Dry";
}

String routeParam = request.getParameter("routeId");
Integer routeId = (routeParam != null && !routeParam.trim().isEmpty()) ? Integer.parseInt(routeParam.trim()) : null;

StringBuilder sql = new StringBuilder(
    "SELECT forecast_period, forecasted_demand, forecasted_price FROM demand_forecast WHERE container_type = ? ");
if (routeId != null) {
    sql.append(" AND route_id = ? ");
}
sql.append(" ORDER BY forecast_id ASC LIMIT 6");

try (Connection conn = DBConnectionManager.getConnection();
     PreparedStatement ps = conn.prepareStatement(sql.toString())) {
    ps.setString(1, containerType);
    if (routeId != null) {
        ps.setInt(2, routeId);
    }
    ...
```

---

### 5.4 Purge Raw Scriptlets from `pricing.jsp` & `predictive-graph.jsp`

Remove lines 1–55 of `pricing.jsp` and lines 1–11 of `predictive-graph.jsp`. All data binding must flow strictly through `PricingServlet.java` and `PredictiveGraphServlet.java`.

---

## 6. Database Schema & Stored Procedure Specifications

### 6.1 Relational Tables
1. **`containers`:** `container_id` (PK, AI), `container_number` (VARCHAR 20, UQ), `type` (ENUM: `'Dry'`, `'Reefer'`, `'Open Top'`, `'Flat Rack'`, `'Tank'`), `size` (ENUM: `'20ft'`, `'40ft'`, `'40ft HC'`, `'45ft'`), `image_url` (VARCHAR 255), `tare_weight_kg` (DECIMAL 10,2), `max_gross_weight_kg` (DECIMAL 10,2), `goods_capacity_kg` (DECIMAL 10,2), `goods_capacity_cbm` (DECIMAL 10,2), `status` (ENUM: `'Available'`, `'Allocated'`, `'In-Transit'`, `'Under Maintenance'`), `current_port_id` (FK -> ports), `owner_company_id` (FK -> companies).
2. **`pricing_rules`:** `pricing_id` (PK, AI), `container_type` (VARCHAR 50), `container_size` (VARCHAR 20), `route_id` (FK -> ports, Nullable), `base_price` (DECIMAL 12,2), `seasonal_multiplier` (DECIMAL 4,2, Default 1.00), `demand_multiplier` (DECIMAL 4,2, Default 1.00), `final_price` (DECIMAL 12,2), `valid_from` (DATE), `valid_to` (DATE).
3. **`pricing_audit`:** `audit_id` (PK, AI), `pricing_id` (FK -> pricing_rules), `old_price` (DECIMAL 12,2), `new_price` (DECIMAL 12,2), `changed_by` (FK -> users), `reason` (TEXT), `changed_at` (DATETIME).
4. **`demand_forecast`:** `forecast_id` (PK, AI), `container_type` (VARCHAR 50), `route_id` (FK -> ports), `forecast_period` (VARCHAR 30), `forecasted_demand` (DECIMAL 10,2), `forecasted_price` (DECIMAL 12,2), `algorithm_version` (VARCHAR 20), `generated_at` (DATETIME).

### 6.2 Stored Procedure Contracts
* `allocate_container(p_shipment_id, p_container_id)`:
  - Validates container status = `'Available'`.
  - Verifies cargo weight $\le$ container max goods capacity (kg).
  - Verifies cargo volume $\le$ container max goods capacity (CBM).
  - Updates `containers.status = 'Allocated'`.
  - Updates `shipment.status = 'Container Allocated'`.
* `update_price(p_pricing_id, p_new_base_price, p_changed_by, p_reason)`:
  - Updates `base_price` and recalculates `final_price`.
  - Inserts row into `pricing_audit`.

---

## 7. Verification & Quality Assurance Test Suite

The following 12 test cases validate that all Module 3 requirements and bug fixes operate flawlessly:

| Test ID | Objective | Input / Action | Expected Result | Pass Criteria |
| :--- | :--- | :--- | :--- | :--- |
| **TC-ALLOC-01** | Verify Container Master Registration (FR3.1). | Submit valid container specs + photo to `POST /containers/add`. | Container created with status `'Available'`; Barcode generated. | Record in `containers` and `barcode_entries`. |
| **TC-ALLOC-02** | Verify Fleet Tenancy Isolation (FR3.1). | Company 2 Admin accesses `/containers`. | Only displays containers owned by Company 2. | Zero Company 1 containers visible. |
| **TC-ALLOC-03** | Verify Cross-Tenant Modification Block (FR3.1). | Company 2 Admin attempts `POST /containers/delete?id=Company1Cont`. | Request rejected with `HTTP 403 Forbidden`. | Container remains intact in database. |
| **TC-ALLOC-04** | Verify Allocation Screen Visuals (FR3.2). | Open `/allocate?containerId=X`. | Image, type pill, certified weight, CBM limits, and progress bars rendered. | Complete visual spec displayed. |
| **TC-ALLOC-05** | Verify Invariant: Reject Non-Available Container (FR3.3). | Attempt to allocate container with status `'In-Transit'`. | Blocked with error: *"Container is no longer available"*. | Allocation aborted; status unchanged. |
| **TC-ALLOC-06** | Verify Precondition: Reject Overweight Cargo (FR3.4). | Enter weight 32,000 kg for container with max 28,000 kg. | Client JS flags red; server rejects with capacity error. | Allocation blocked; user returned to form. |
| **TC-ALLOC-07** | Verify Precondition: Reject Over-Volume Cargo (FR3.4). | Enter volume 85 CBM for container with max 67 CBM. | Client JS flags red; server rejects with volume error. | Allocation blocked; user returned to form. |
| **TC-ALLOC-08** | Verify Dynamic Pricing Formula (FR3.5). | Base $2,000, Seasonal 1.20, Demand 1.10, Surcharge $300. | Final price calculated as $(2000 \times 1.20 \times 1.10) + 300 = \$2,940.00$. | Displayed quote matches exact formula. |
| **TC-ALLOC-09** | Verify Staff Booking preserves `customerId`. | Operations Staff selects Customer #5 and confirms booking. | `shipment.customer_id` set to `5` (NOT staff `user_id`). | Customer #5 sees shipment in portal. |
| **TC-ALLOC-10** | Verify Base Price Adjustment Audit Trail (FR3.7). | Admin updates base rate with reason *"Fuel cost adjustment"*. | Rate updated in `pricing_rules`; audit row inserted in `pricing_audit`. | Audit history shows old rate, new rate, user, reason. |
| **TC-ALLOC-11** | Verify Predictive Graph Route Filtering (FR3.6). | Select container type `Dry` and route `Singapore -> Rotterdam`. | Chart queries only matching corridor forecast data. | Dual-axis Chart.js renders 6 periods. |
| **TC-ALLOC-12** | Pure MVC2 JSP Compliance. | Inspect `allocate-container.jsp`, `pricing.jsp`, `predictive-graph.jsp`. | Zero scriptlets (`<% ... %>`) remain in view files. | JSPs contain only JSTL and EL expressions. |

---

## 8. Summary & Transition to Module 4

With this Mega Specification for Module 3 in place:
1. Fleet tenant isolation leaks in `ContainerServlet` and `ContainerDAO` are sealed.
2. The missing customer selection in allocation quotes is resolved.
3. Strict Design-by-Contract rules for container availability (FR3.3) and cargo fit (FR3.4) are enforced.
4. Route filtering for the Predictive Demand Graph (FR3.6) is specified.
5. All 7 end-to-end Use Cases are formalized with complete preconditions, postconditions, and exception flows.

**Next Milestone:** Upon user sign-off of Module 3, we will proceed immediately to generate the dedicated **Module 4 Mega Specification** covering **Bulk Stock Details Upload, Validation Engine, Inventory Ledger & Turnover Analysis (FR4.1 – FR4.6)**.
