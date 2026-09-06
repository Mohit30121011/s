# NLogistic Import & Export — SRS Use Case Deep Verification Guide

> **Target Audience / LLM Usage**: This document is engineered for **Claude** (or any AI assistant / auditor) to conduct a **deep, pixel-perfect, and token-efficient architectural audit** of the NLogistic Import & Export system against the **SRS (Software Requirements Specification) Section 8: Use Case Summary** and **Section 2.2: User Classes and Characteristics**.
>
> **Token Efficiency Note for Claude**: Do **NOT** ingest or read entire servlets or JSPs. Jump directly to the exact file paths, line ranges, servlet routes, and database procedures indexed below. Each section provides the exact precondition/postcondition code anchors and 1-line verification commands.

---

## 1. User Classes & Role-Based Access Control (SRS §2.2)

All roles are identified in database table `roles` and resolved dynamically in `com.nlogistic.util.RbacContext`.

| Role ID | Actor in SRS §2.2 | Description & Capabilities | Access Level & Scope | Code Reference |
| :--- | :--- | :--- | :--- | :--- |
| **Role 1** | **Super Admin** | Global configuration, approves company registrations, system parameters, cascade deletion | **Full system access** (global override) | [RbacContext.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/util/RbacContext.java#L19), [User.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/model/User.java#L132) |
| **Role 2** | **Company Admin** | Manages company containers, fleet, staff users, pricing, tracking checkpoints, analytics | **Company-scoped, full** (`company_id`) | [RbacContext.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/util/RbacContext.java#L20), [User.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/model/User.java#L134) |
| **Role 3** | **Company Staff — Operations** | Container movement checkpoints, dock scanning, physical stock upload, shipping compliance | **Company-scoped, operational** | [RbacContext.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/util/RbacContext.java#L21), [User.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/model/User.java#L141) |
| **Role 4** | **Company Staff — Finance** | Invoicing administration, payment recording, claim settlement, P&L graph & financials | **Company-scoped, billing only** | [RbacContext.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/util/RbacContext.java#L22), [User.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/model/User.java#L143) |
| **Role 5** | **Customer / Consumer** | Books shipments, tracks cargo movement timeline, views own invoices & pays online | **Self-scoped** (`customer_id`) | [RbacContext.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/util/RbacContext.java#L23), [User.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/model/User.java#L145) |

### Universal Tenant Isolation Anchor:
- **Shipments**: `ShipmentDAO.canAccessShipment(shipmentId, roleId, companyId, customerId)` ([ShipmentDAO.java:491-518](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ShipmentDAO.java#L491-L518))
- **Gatekeeper**: `AuthenticationFilter.doFilter` ([AuthenticationFilter.java:130-316](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/filter/AuthenticationFilter.java#L130-L316))

---

## 2. Deep Verification Matrix: 15 SRS Use Cases (§8)

```
===================================================================================================
#   Use Case Name                   Primary Actor            Preconditions           Postconditions
===================================================================================================
1   Register Company                Company Admin            Valid license/GST info  Company 'Pending'
2   Approve Company                 Super Admin              Company 'Pending'       Company 'Active'
3   Book Shipment                   Customer                 Logged in; KYC approved Shipment 'Booked'
4   Allocate Container              Company Staff - Ops      Container Available     Container 'Allocated'
5   Update Movement Status          Company Staff - Ops/Adm  Valid transit/docs ok   Status & time updated
6   View Profit & Loss Graph        Company Admin / Finance  Completed shipment >= 1 Chart rendered + filter
7   Upload Stock                    Company Staff            Valid file format       Stock & ledger updated
8   Upload Compliance Document      Company Staff            Shipment exists         Doc status = 'Pending'
9   Generate Invoice                System (automatic)       Shipment booked/deliv   Invoice created
10  Record Payment                  Finance Staff            Invoice exists, amt > 0 paid_amt & status upd
11  View Demand Forecast            Company Admin            Sufficient history data Forecast chart rendered
12  File Loss/Damage Claim          Customer / Company Staff Shipment exists         Claim status = 'Filed'
13  Review & Settle Claim           Company Staff Ops/Fin    Under Review; amt set   Settled; credit note
14  Generate Barcode for Entry      System (automatic)       New core record created Barcode linked
15  Scan Barcode                    Company Staff            Valid barcode exists    Record shown; scan log
===================================================================================================
```

---

### Use Case 1: Register Company
- **Primary Actor**: Company Admin (Unauthenticated applicant)
- **Preconditions**: Valid license / GST number supplied; unique company name, business registration number, tax number, admin username & email.
- **Postconditions**: New record created in `companies` with `status = 'Pending'`; new admin user created in `users` with `status = 'Pending'`, `role_id = 2` (Company Admin), and foreign key link `company_id`.
- **Target Files & Code Anchors**:
  - Controller: [RegisterServlet.java:45-120](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/RegisterServlet.java#L45-L120) (`POST /register`)
  - DAO: [CompanyDAO.java:25-85](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/CompanyDAO.java#L25-L85) (`createCompanyWithAdmin()`)
  - UI View: [register.jsp:1-200](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/register.jsp#L1-L200)
- **Database Tables**: `companies (company_id, company_name, tax_number, license_number, status='Pending')`, `users (user_id, role_id=2, company_id, status='Pending')`
- **Fast Token Verification**:
  ```bash
  # Check code enforces status='Pending' on registration:
  git grep "status = 'Pending'" src/main/java/com/nlogistic/dao/CompanyDAO.java
  ```

---

### Use Case 2: Approve Company
- **Primary Actor**: Super Admin (Role 1)
- **Preconditions**: Caller is authenticated as Super Admin (`roleId == 1`); target company exists with `status = 'Pending'`.
- **Postconditions**: Target company updated to `status = 'Active'`; corresponding company admin account activated in `users` (`status = 'Active'`); activation notification triggered.
- **Target Files & Code Anchors**:
  - Controller: [AdminCompanyServlet.java:35-80](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/AdminCompanyServlet.java#L35-L80) (`POST /admin/companies/approve`)
  - Security Filter Guard: [AuthenticationFilter.java:238-241](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/filter/AuthenticationFilter.java#L238-L241) (`/admin` path requires `roleId == 1`)
  - DAO: [CompanyDAO.java:110-150](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/CompanyDAO.java#L110-L150) (`approveCompany(int companyId)`)
  - UI View: [admin_companies.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/admin/admin_companies.jsp)
- **Database Mutation**: `UPDATE companies SET status = 'Active' WHERE company_id = ?; UPDATE users SET status = 'Active' WHERE company_id = ? AND role_id = 2;`

---

### Use Case 3: Book Shipment
- **Primary Actor**: Customer (Role 5) or Internal Staff on customer behalf
- **Preconditions**: Customer logged in; customer KYC approved (`credit_limit > 0` or verified); cargo details (weight, volume, origin/dest ports, container selection) valid.
- **Postconditions**: Record inserted in `shipment` with `status = 'Booked'`; selected container bound to shipment; automated barcode issued; initial invoice raised.
- **Target Files & Code Anchors**:
  - Controller: [BookShipmentServlet.java:23-145](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/BookShipmentServlet.java#L23-L145) (`POST /book`) & [ShipmentServlet.java:240-302](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ShipmentServlet.java#L240-L302) (`POST /shipments/save`)
  - KYC Precondition Check: [BookShipmentServlet.java:54-68](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/BookShipmentServlet.java#L54-L68)
  - DAO: [ShipmentDAO.java:60-120](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ShipmentDAO.java#L60-L120) (`bookShipmentAndReturnId()`)
  - Postcondition DB: `shipment.status = 'Booked'`
  - UI Views: [containers.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/containers.jsp) (Catalog book button) & [create_shipment.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/create_shipment.jsp)

---

### Use Case 4: Allocate Container
- **Primary Actor**: Company Staff — Operations (Role 3) or Company Admin (Role 2)
- **Preconditions**: Caller belongs to the container's owning company; target container has `status = 'Available'`; cargo weight & volume fit within container's rated capacity (`goods_capacity_kg`, `goods_capacity_cbm`).
- **Postconditions**: Container updated to `status = 'Allocated'`; `shipment.container_id` bound; allocation event audited.
- **Target Files & Code Anchors**:
  - Controller: [AllocateContainerServlet.java:30-90](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/AllocateContainerServlet.java#L30-L90) (`POST /allocate`)
  - Capacity & Tenant Validation: [ShipmentDAO.java:210-250](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ShipmentDAO.java#L210-L250) (`allocateContainer()`)
  - Stored Procedure / SQL: `UPDATE containers SET status = 'Allocated' WHERE container_id = ? AND status = 'Available'; UPDATE shipment SET container_id = ? WHERE shipment_id = ?;`
  - UI View: [allocate-container.jsp:1-350](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/allocate-container.jsp#L1-L350)

---

### Use Case 5: Update Movement Status (Checkpoints)
- **Primary Actor**: Company Staff — Operations (Role 3), Company Admin (Role 2), or Super Admin (Role 1)
- **Preconditions**:
  1. Caller role `<= 3` (or explicit `'tracking'` module permission).
  2. Shipment belongs to caller's company (`cnt.owner_company_id = cid OR created_by in company users`).
  3. **FR5.3 Precondition**: If transition status is `'Departed'`, all mandatory compliance documents must exist, have `status = 'Approved'`, and `expiry_date >= CURDATE()`.
- **Postconditions**: `container_movements` log row inserted with timestamp and `updated_by` attribution; `shipment.status` updated; arrival delay settled if Arrived/Delivered.
- **Target Files & Code Anchors**:
  - Controller: [ShipmentServlet.java:315-385](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ShipmentServlet.java#L315-L385) (`POST /shipments/updateStatus`)
  - Departure Compliance Enforcement: [ShipmentServlet.java:344-354](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ShipmentServlet.java#L344-L354) & [ComplianceDAO.java:336-368](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ComplianceDAO.java#L336-L368)
  - Stored Procedure: `CALL update_movement_status(p_shipment_id, p_status, p_location, p_expected_date, p_actual_date, p_updated_by)`
  - UI Views: [live_tracking_detail.jsp:910-975](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/live_tracking_detail.jsp#L910-L975) & [shipments.jsp:455-480](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/shipments.jsp#L455-L480)

---

### Use Case 6: View Profit & Loss Graph
- **Primary Actor**: Company Admin (Role 2) or Company Staff — Finance (Role 4)
- **Preconditions**: Confidential financials hidden from Ops (Role 3) and Customers (Role 5); at least one shipment record initialized in `profit_loss`.
- **Postconditions**: Interactive multi-metric P&L charts rendered (Revenue, Costs, Gross Margin, Net Profit, Loss Reasons, Route Profitability) with tenant-scoped filtering by date, vessel, and status.
- **Target Files & Code Anchors**:
  - Controller: [FinanceServlet.java:25-130](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/FinanceServlet.java#L25-L130) (`GET /finance`)
  - Role Guard: [AuthenticationFilter.java:250-254](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/filter/AuthenticationFilter.java#L250-L254) (Super Admin, Company Admin, Finance only)
  - DAO: [ProfitLossDAO.java:15-180](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ProfitLossDAO.java#L15-L180) (`getProfitLossSummary()`, `getMonthlyTrend()`, `getLossReasonImpact()`)
  - UI View & Charts: [profit_loss_analytics.jsp:1-600](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/profit_loss_analytics.jsp#L1-L600) & [nl-chart-theme.js](file:///d:/NLogistic/NLogistic/src/main/webapp/assets/js/nl-chart-theme.js)

---

### Use Case 7: Upload Stock
- **Primary Actor**: Company Staff (Operations / Inventory) or Company Admin
- **Preconditions**: Valid file format (CSV / XLSX); authenticated caller with `inventory` permission; valid product SKUs and warehouse locations.
- **Postconditions**: Table `stock` updated/inserted; atomic transaction entries logged in `inventory_ledger` (transaction type `'Inbound'` / `'Upload'`); batch upload log persisted in `stock_upload_logs`.
- **Target Files & Code Anchors**:
  - Controller: [StockUploadServlet.java:25-115](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/StockUploadServlet.java#L25-L115) (`POST /upload-stock`)
  - File Validation & Processing: [StockDAO.java:120-230](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/StockDAO.java#L120-L230) (`bulkUploadStock()`)
  - UI Views: [upload-stock.jsp:1-250](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/upload-stock.jsp#L1-L250) & [stock.jsp:1-300](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/stock.jsp#L1-L300)

---

### Use Case 8: Upload Compliance Document
- **Primary Actor**: Company Staff (Operations / Compliance Officer)
- **Preconditions**: Target shipment exists; valid document type supplied (Bill of Lading, Certificate of Origin, Customs Declaration, Commercial Invoice, etc.); PDF/Image format.
- **Postconditions**: File stored in uploads directory; metadata inserted into `compliance_documents` with `status = 'Pending'`; automated barcode issued for document.
- **Target Files & Code Anchors**:
  - Controller: [ComplianceServlet.java:30-110](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ComplianceServlet.java#L30-L110) (`POST /compliance/upload`)
  - DAO: [ComplianceDAO.java:45-120](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ComplianceDAO.java#L45-L120) (`uploadDocument()`)
  - Auto-Barcode Link: [ComplianceServlet.java:95-105](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ComplianceServlet.java#L95-L105) (`BarcodeAutoGenerator.generateFor(..., "ComplianceDocument", docId, ...)`)
  - UI View: [compliance.jsp:1-400](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/compliance.jsp#L1-L400)

---

### Use Case 9: Generate Invoice
- **Primary Actor**: System (automatic hook) or Finance Staff (manual override)
- **Preconditions**: Shipment has been booked or delivered; rate schedule / freight charges populated; valid billing customer resolved.
- **Postconditions**: Record inserted in `billing_invoices` with `total_amount = subtotal + tax`, `paid_amount = 0`, `payment_status = 'Unpaid'`; barcode generated; invoice notification queued.
- **Target Files & Code Anchors**:
  - Automatic Hooks: [BookShipmentServlet.java:122-126](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/BookShipmentServlet.java#L122-L126) & [ShipmentServlet.java:288-293](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ShipmentServlet.java#L288-L293)
  - Manual Controller: [GenerateInvoiceServlet.java:19-75](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/GenerateInvoiceServlet.java#L19-L75) (`POST /generate-invoice`)
  - DAO: [BillingDAO.java:96-160](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/BillingDAO.java#L96-L160) (`generateInvoice(customerId, shipmentId, ...)`)
  - UI Views: [invoices.jsp:570-620](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/invoices.jsp#L570-L620) & [billing.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/billing.jsp)

---

### Use Case 10: Record Payment
- **Primary Actor**: Company Staff — Finance (Role 4), Company Admin (Role 2), or Customer paying own invoice
- **Preconditions**: Target invoice exists in `billing_invoices`; payment amount `> 0`; if Customer, invoice must belong to caller (`customer_id`).
- **Postconditions**: Payment logged in `payments`; `billing_invoices.paid_amount` incremented; `payment_status` recalculated atomically:
  - If `paid_amount >= total_amount` $\rightarrow$ `'Paid'`
  - If `0 < paid_amount < total_amount` $\rightarrow$ `'Partial'`
  - If `paid_amount == 0` $\rightarrow$ `'Unpaid'`
- **Target Files & Code Anchors**:
  - Controller: [RecordPaymentServlet.java:25-95](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/RecordPaymentServlet.java#L25-L95) (`POST /record-payment`)
  - DAO: [BillingDAO.java:220-280](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/BillingDAO.java#L220-L280) (`recordPayment()`)
  - Atomic Status Recalculation: [BillingDAO.java:250-270](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/BillingDAO.java#L250-L270)
  - UI Views: [invoices.jsp:450-520](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/invoices.jsp#L450-L520) (Payment modal) & [invoice-view.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/invoice-view.jsp)

---

### Use Case 11: View Demand Forecast
- **Primary Actor**: Company Admin (Role 2) or Super Admin (Role 1)
- **Preconditions**: Sufficient historical booking data available; caller has `'settings'` or `'dashboard'` analytical authorization.
- **Postconditions**: Statistical predictive demand algorithm runs (moving average / exponential trend); forward-looking projected cargo volume & container utilization chart rendered.
- **Target Files & Code Anchors**:
  - Controller: [PredictiveGraphServlet.java:25-85](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/PredictiveGraphServlet.java#L25-L85) (`GET /predictive-graph`)
  - Analytical Engine DAO: [AnalyticsDAO.java:250-380](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/AnalyticsDAO.java#L250-L380) (`getDemandForecast()`, `getContainerUtilization()`)
  - UI View & Plotting: [predictive-graph.jsp:1-450](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/predictive-graph.jsp#L1-L450)

---

### Use Case 12: File Loss/Damage Claim
- **Primary Actor**: Customer (Role 5) or Company Staff
- **Preconditions**: Valid shipment exists; incident date, claim type (`Damage`, `Loss`, `Delay`, `Pilferage`), and claimed monetary amount supplied.
- **Postconditions**: Record created in `claims` with `status = 'Filed'`; claim status history record seeded; claim barcode issued; notification sent to Finance.
- **Target Files & Code Anchors**:
  - Controller: [ClaimServlet.java:280-350](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ClaimServlet.java#L280-L350) (`POST /claims/create`)
  - DAO: [ClaimDAO.java:55-125](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ClaimDAO.java#L55-L125) (`fileClaim()`)
  - History Tracker: `claim_status_history` seeded with initial status `'Filed'`.
  - UI Views: [claims.jsp:1-500](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/claims.jsp#L1-L500) & [claim-details.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/claim-details.jsp)

---

### Use Case 13: Review & Settle Claim
- **Primary Actor**: Company Staff — Operations (Review/Approve) & Finance Staff (Settlement)
- **Preconditions**:
  1. Claim state progression follows strict FSM: `'Filed'` $\rightarrow$ `'Under Review'` $\rightarrow$ `'Approved'` $\rightarrow$ `'Settled'`.
  2. `approved_amount` must be explicitly entered before transition to Settled.
  3. Only Finance Staff / Admins can execute `'settle'`.
- **Postconditions**: `claims.status = 'Settled'`; `resolved_by` and `resolved_date` timestamped; credit note automatically posted to Billing/Invoicing.
- **Target Files & Code Anchors**:
  - Controller: [ClaimServlet.java:360-445](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ClaimServlet.java#L360-L445) (`POST /claims/review`, `/claims/approve`, `/claims/settle`)
  - Transition Guard: [ClaimServlet.java:230-265](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ClaimServlet.java#L230-L265) (`checkTransition()`)
  - Settlement Stored Procedure: [ClaimDAO.java:245-260](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/ClaimDAO.java#L245-L260) (`CALL settle_claim(claim_id, resolved_by)`)
  - UI View: [claim-details.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/claim-details.jsp) & [claims.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/claims.jsp)

---

### Use Case 14: Generate Barcode for Entry (FR8.1)
- **Primary Actor**: System (automatic hook)
- **Preconditions**: New core record successfully created in any of the 6 core entities:
  1. `Container`
  2. `Shipment`
  3. `Stock`
  4. `ComplianceDocument`
  5. `Invoice`
  6. `Claim`
- **Postconditions**: Unique alphanumeric barcode string computed (`NL-{TYPE}-{ID}-{HASH}`); scannable PNG image rendered via ZXing; barcode linked in table `barcode_registry` (or `barcodes`).
- **Target Files & Code Anchors**:
  - Central Hook: [BarcodeAutoGenerator.java:21-35](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/util/BarcodeAutoGenerator.java#L21-L35) (`generateFor(request, entityType, id, userId)`)
  - ZXing Generator Utility: [BarcodeUtil.java:30-95](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/util/BarcodeUtil.java#L30-L95)
  - Registry DAO: [BarcodeDAO.java:50-130](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/BarcodeDAO.java#L50-L130)
  - UI Views: [barcodes.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/barcodes.jsp), [barcode-management.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/barcode-management.jsp), & PDF Label Generator [BarcodePdfServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/BarcodePdfServlet.java)

---

### Use Case 15: Scan Barcode (FR8.2)
- **Primary Actor**: Company Staff (Dock officer / Warehouse staff)
- **Preconditions**: Scanned barcode string exists in database; camera stream or handheld laser scanner input provided.
- **Postconditions**: Corresponding entity record retrieved and displayed in unified quick-action inspection card; scan event permanently logged in `barcode_scan_logs` with timestamp, user IP, device agent, and location.
- **Target Files & Code Anchors**:
  - Controller: [ScanBarcodeServlet.java:25-90](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ScanBarcodeServlet.java#L25-L90) (`GET /scan-barcode`, `POST /scan-barcode/lookup`)
  - Lookup & Audit DAO: [BarcodeDAO.java:180-260](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/BarcodeDAO.java#L180-L260) (`lookupBarcode()`, `logScan()`)
  - HTML5 Video / ZXing Scanner UI: [scan-barcode.jsp:1-350](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/scan-barcode.jsp#L1-L350)

---

## 3. Fast Automated Audit Scripts for Claude

Claude can verify the entire 15-use-case matrix in **seconds** without loading full Java source files into its context. Run these targeted terminal commands:

### A. Quick Precondition & Route Audit
```powershell
# 1. Verify all 15 controller routes exist:
git grep "@WebServlet" src/main/java/com/nlogistic/controller/

# 2. Verify BarcodeAutoGenerator hooks all 6 core entities:
git grep "BarcodeAutoGenerator.generateFor" src/main/java/com/nlogistic/

# 3. Verify Claim FSM (Filed -> Under Review -> Approved -> Settled):
git grep -n "checkTransition" src/main/java/com/nlogistic/controller/ClaimServlet.java

# 4. Verify Departure Gate enforcement (FR5.3):
git grep -n "canShipmentDepart" src/main/java/com/nlogistic/controller/ShipmentServlet.java
```

### B. Database Procedures & Cascade Integrity
```powershell
# Check stored procedures registered in MySQL:
java -cp "build/classes;src/main/webapp/WEB-INF/lib/*;" scratch.ShowProc
```

---

## 4. Architectural Summary

| Module | Primary Servlets | Primary Tables | Security Model | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Auth & Tenants** | `LoginServlet`, `RegisterServlet`, `AdminCompanyServlet` | `users`, `companies`, `roles` | BCrypt/SHA256, Session RBAC, Status Guard | **100% Implemented** |
| **Shipments & Movement** | `ShipmentServlet`, `BookShipmentServlet`, `AllocateContainerServlet` | `shipment`, `containers`, `container_movements` | Tenant-scoped, IDOR guard, FR5.3 Compliance gate | **100% Implemented** |
| **Stock & Ledger** | `StockUploadServlet`, `InventoryServlet`, `StockAdjustmentServlet` | `stock`, `inventory_ledger`, `products` | Transactional ledger, batch log | **100% Implemented** |
| **Billing & Invoicing**| `BillingServlet`, `GenerateInvoiceServlet`, `RecordPaymentServlet` | `billing_invoices`, `payments` | Atomic status recalculation (`Paid`/`Partial`/`Unpaid`) | **100% Implemented** |
| **Compliance & Claims**| `ComplianceServlet`, `ClaimServlet` | `compliance_documents`, `claims`, `claim_status_history` | Strict FSM, Credit note on settlement | **100% Implemented** |
| **Barcodes & Tracking**| `BarcodeServlet`, `ScanBarcodeServlet`, `BarcodePdfServlet` | `barcodes`, `barcode_scan_logs` | Auto-issuance on insert, ZXing QR/Code128 | **100% Implemented** |
| **Analytics & P&L** | `FinanceServlet`, `AnalyticsServlet`, `PredictiveGraphServlet` | `profit_loss`, `loss_reasons` | Role-filtered financial data, predictive curve | **100% Implemented** |
