# N LOGISTIC IMPORT & EXPORT
## Comprehensive Master Architecture, System Workflows, Use Cases & Role-Based Access Control (RBAC) Specification

> **Document Version:** 1.0  
> **Target System:** N Logistic Import & Export Enterprise Platform  
> **Core Technologies:** Java EE · Servlet 4.0 · JSP 2.3 / JSTL · JDBC · MySQL 8.x · Bootstrap 5 · MVC2 Architecture · Design by Contract  
> **Primary References:** `srs_harness.md`, `srs.pdf`, Active Source Codebase (`com.nlogistic.*`, `webapp/jsp/*`)  
> **Purpose:** Authoritative specification of the entire system architecture, end-to-end workflows, comprehensive use cases for all actors, granular Role-Based Access Control (RBAC) matrix, field-level visibility rules, and tenant/customer data isolation guidelines.

---

## 1. Executive Summary & Problem Context

### 1.1 Platform Mission
N Logistic Import & Export is an enterprise logistics management platform managing the end-to-end lifecycle of maritime container shipments across international trade routes. The system supports multi-tenant logistics companies, internal operations/finance staff, system administrators, and external commercial customers.

The system encompasses **8 Core Functional Modules** and **5 Analytical Algorithms**:
1. **Module 1: Authentication & Authorization (FR1.1 – FR1.9)** — Multi-role registration, account lockout, audit logging, session management, and RBAC.
2. **Module 2: Container Movement Tracking & Profit & Loss Graph (FR2.1 – FR2.9)** — Checkpoint tracking (Point A to Point B), route maps, delay computation, revenue/cost attribution, and standard loss reason tagging.
3. **Module 3: Container Allocation & Dynamic Pricing (FR3.1 – FR3.7)** — Container fleet catalog, ISO capacity constraints, dynamic pricing engine, and Advance Predictive Demand graphs.
4. **Module 4: Stock & Inventory Management (FR4.1 – FR4.6)** — Bulk CSV stock upload, manual receipts, FIFO/WAC inventory ledger, and damage write-offs.
5. **Module 5: Government Compliance & Billing (FR5.1 – FR5.8)** — Regulatory document gating, expiry monitoring, automated invoice generation, line-item taxes, and multi-mode payment recording.
6. **Module 6: Analytics Dashboard & Algorithms (FR6.1 – FR6.2, 5.1 – 5.5)** — Five algorithmic engines: Sales Trend, ABC Pareto Classification, Inventory Turnover Ratio, Product Profitability, and Demand Forecasting.
7. **Module 7: Supply Chain Claims (Loss & Damage) (FR7.1 – FR7.7)** — Customer and staff incident reporting, photo evidence, lifecycle status review, settlement approvals, credit notes, and P&L feedback.
8. **Module 8: Barcode-Based Entry Tracking (FR8.1 – FR8.6)** — Code128 / QR generation across all entities, physical camera/scanner lookup, and dock audit trails.

### 1.2 The RBAC Visibility Gap (Identified Defect & Target State)
* **Current State in Codebase:** The application has basic role identification (`role_id` 1 through 5 in database and session) and superficial path filtering in `AuthenticationFilter.java`. However, **data scoping and visual permissions are not enforced**:
  - Global queries like `SELECT * FROM shipment` are executed regardless of whether a Super Admin, Company Admin, or Customer calls them.
  - The main navigation sidebar (`header.jsp`) displays internal menus (e.g., Profit & Loss Analytics, Financial Drilldowns, Barcode Tracking, Stock Ledgers) to all logged-in users, including Customers and Operations staff.
  - Action buttons (Edit, Delete, Financial Drilldown, Status Override) are rendered in data tables without role-checking guards (`<c:if>`).
* **Required Target State:** A 3-tiered access control model:
  1. **UI / Presentation Layer:** Dynamic menu rendering, omnibox filtering, and action button gating based on `user.roleId`.
  2. **Controller / Servlet Layer:** Contract precondition enforcement on every endpoint; validation that the requested entity belongs to the caller's tenant/account (IDOR prevention).
  3. **DAO / Database Layer:** Strict parameterized filtering (`WHERE owner_company_id = ?` for internal staff, `WHERE customer_id = ?` for customers) and execution of permission-gated stored procedures.

---

## 2. Actor Classification & System Scopes

| Role ID | Role Name | System Scope | Principal Responsibilities |
| :---: | :--- | :--- | :--- |
| **1** | **Super Admin** | **Global System-Wide** | Multi-company governance, company registration approvals, user administration, security audit trails, algorithm parameter calibration, global master data (ports, vessels, loss reasons). |
| **2** | **Company Admin** | **Company-Scoped (Tenant)** | Full administration of own company's assets, containers, internal staff, pricing rules, customer shipments, billing, financial drilldown, and company-level analytics. |
| **3** | **Company Staff — Operations** | **Company-Scoped (Operational)** | Physical container allocation, cargo fit validation, checkpoint status transitions, stock CSV uploads, warehouse inventory ledger, barcode scanning, dock operations, compliance document ingestion. |
| **4** | **Company Staff — Finance** | **Company-Scoped (Financial)** | Billing and invoicing, payment processing, overdue collections, claim settlements, credit note generation, profit & loss analysis, financial drilldowns, cost attribution. |
| **5** | **Customer / Consumer** | **Self-Scoped (Personal)** | Self-registration & KYC, container catalog browsing, self-service shipment booking, live shipment tracking (Point A to Point B), invoice viewing & online payment, filing loss & damage claims with proof. |

---

## 3. Exhaustive Role Specifications

### 3.1 Role 1: Super Admin (`role_id = 1`)

#### 3.1.1 Access Scope & Authority
The Super Admin is the global platform administrator. They have unconstrained visibility and modification authority across all companies, customers, containers, shipments, and financial records.

#### 3.1.2 What Super Admin Can VIEW
* **Company Governance:** Complete list of all registered logistics companies, their license numbers, GST IDs, contact details, registration timestamps, and approval status (`Pending`, `Active`, `Suspended`).
* **User & Staff Governance:** Every user account in the system across all companies and customer accounts, including username, email, phone, assigned role, company affiliation, status (`Active`, `Pending`, `Locked`), failed login counters, and last login timestamps.
* **Security & Audit Logs:** The global `audit_log` and login history: who logged in, login failures, lockout events, permission-denied attempts, IP addresses, entity change logs with old/new values.
* **Global Master Data:** All global ports (UN/LOCODE, coordinates), maritime vessels (IMO numbers, TEU capacities), container types, and standard loss reasons.
* **All Containers:** Complete container fleet catalog across all logistics companies, current port locations, maintenance states, tare/gross weights, and CBM capacities.
* **All Shipments:** Every shipment booked across all companies and customers, full route information, cargo declarations, assigned containers, and transit statuses.
* **Pricing & Analytics:** Global pricing rules, demand multipliers, seasonal multipliers, pricing change audit logs, Advance Predictive Demand graphs, and all 5 analytical algorithms across any company.
* **Global Compliance & Billing:** All uploaded compliance documents, document status across all shipments, all invoices, line items, and recorded payments.
* **Claims & Barcodes:** Every filed claim system-wide, evidence attachments, status transition history, all generated barcodes, and the complete barcode scan log.

#### 3.1.3 What Super Admin Can ADD / CREATE
* **Companies:** Manually create and onboard new logistics companies.
* **Users:** Create user accounts with any role (Super Admin, Company Admin, Operations, Finance, Customer) and assign to any company.
* **Master Data:** Add new international Ports, maritime Vessels, standard Loss Reasons, and Container profiles.
* **Pricing Rules:** Create new baseline pricing rules for specific container types and trade routes.
* **Products:** Add master products and HSN codes to the global product catalog.
* **Barcodes:** Generate barcodes for any entity type on demand.

#### 3.1.4 What Super Admin Can EDIT / UPDATE
* **Company Status:** Approve pending companies (`Pending` -> `Active`), suspend non-compliant companies (`Active` -> `Suspended`), or reject applications.
* **User Accounts:** Activate pending users, unlock locked accounts (resetting `failed_login_count` to 0), reassign roles, change company affiliations, and trigger password reset flows.
* **Pricing Rules & Base Rates:** Update base freight rates (with mandatory audit reason), update seasonal multipliers, and calibrate demand multipliers.
* **Shipment & Movements:** Override shipment details, update transit statuses, bypass or resolve compliance blocks in extraordinary administrative scenarios.
* **Container Specifications:** Update container locations, maintenance flags, and capacity parameters.
* **Claims:** Override claim statuses (`Filed` -> `Under Review` -> `Approved` / `Rejected` -> `Settled`) and set final `approved_amount`.
* **Compliance Documents:** Approve or reject any compliance document system-wide.

#### 3.1.5 What Super Admin Can DELETE
* **Users:** Permanently delete user accounts via stored procedure `CALL delete_users(p_user_id, p_requesting_user_id)`.
* **Customers:** Permanently delete customer profiles via `CALL delete_customers(p_customer_id, p_requesting_user_id)`.
* **Companies:** Delete or decommission logistics company tenants.
* **Shipments:** Delete canceled or corrupt shipment records and their movement logs.
* **Containers & Vessels:** Delete decommissioned containers (invariant: container must not be allocated to active shipments) and decommissioned vessels.
* **Pricing Rules & Master Data:** Delete obsolete pricing rules, ports, or loss reasons.
* *(Note: Super Admin is the ONLY role authorized to execute deletions of core master records).*

#### 3.1.6 Operations & Actions Performed by Super Admin
* Execute the 5 Analytical Algorithms globally or per company.
* Review audit trails to detect brute-force attacks and security anomalies.
* Recalibrate predictive pricing demand forecasting parameters.
* Audit and resolve system-wide compliance and billing disputes.

---

### 3.2 Role 2: Company Admin (`role_id = 2`)

#### 3.2.1 Access Scope & Authority
The Company Admin has full administrative control strictly scoped to their own logistics company (`company_id = user.company_id`). They manage company staff, container fleets, pricing rules, customer bookings, warehouse inventory, billing, compliance, and claims.

#### 3.2.2 What Company Admin Can VIEW
* **Company Profile:** Own company license, GST, address, and operating details.
* **Company Staff:** All staff members belonging to their company (Operations, Finance), their activity, and account statuses.
* **Company Containers:** All containers owned or leased by their company, their real-time status (Available, Allocated, In-Transit, Under Maintenance), and current port locations.
* **Company Shipments:** All shipments booked with their company, cargo details, assigned vessels, and live movement checkpoints.
* **Profit & Loss Analytics:** Full financial P&L dashboard for own company shipments: total freight revenue, service charges, fuel costs, port charges, customs duty, insurance costs, delay penalties, damage payouts, net profit/loss, and loss reason breakdowns.
* **Financial Drilldown:** Deep-dive into individual shipment financial cards (revenue breakdown, cost attribution breakdown, margin %).
* **Stock & Inventory:** Warehouse stock levels for own company, complete inventory ledger (IN/OUT transactions), stock upload logs, error reports, and damage adjustments.
* **Compliance & Billing:** Government compliance status of all company shipments, document expiry warnings (15-day alerts), all billing invoices, line items, customer payment receipts, and overdue aging summaries.
* **Claims Register:** All loss/damage claims filed against own company shipments, evidence documents, and resolution history.
* **Company Analytics & Algorithms:** Sales Trend Analysis, ABC Pareto Classification, Inventory Turnover Ratio, Product Profitability Analysis, and Demand Forecasting for own company operations.

#### 3.2.3 What Company Admin Can ADD / CREATE
* **Staff Accounts:** Create and register new Operations Staff (`role_id = 3`) and Finance Staff (`role_id = 4`) under their company.
* **Containers:** Register new containers under their company ownership.
* **Shipments:** Create/book shipments on behalf of customers.
* **Stock & Products:** Add products to the catalog, initiate bulk stock uploads, and record manual stock entries.
* **Invoices:** Generate invoices for booked or delivered shipments.
* **Claims:** File internal claims for supply chain damages discovered on dock/vessel.

#### 3.2.4 What Company Admin Can EDIT / UPDATE
* **Company Staff:** Update staff profiles, reset passwords, deactivate staff accounts.
* **Pricing Rules:** Adjust base freight rates and seasonal multipliers for their company routes (logs pricing audit trail with mandatory reason).
* **Containers:** Update container status, assign to maintenance, update current port.
* **Shipments & Movement:** Update shipment details, checkpoints, delay notes.
* **Stock Adjustments:** Approve stock adjustments for damaged or written-off inventory.
* **Compliance:** Upload and verify compliance documents.
* **Claims Review:** Review claims, transition status (`Filed` -> `Under Review` -> `Approved` / `Rejected`), and approve settlement amounts.

#### 3.2.5 What Company Admin Can DELETE
* **Company Staff:** Deactivate company staff (cannot delete global users).
* **Draft Shipments:** Delete draft or unallocated shipments before departure.
* **Cannot Delete:** Cannot delete other companies, cannot delete global master ports/vessels, cannot delete settled invoices or financial audit trails.

---

### 3.3 Role 3: Company Staff — Operations (`role_id = 3`)

#### 3.3.1 Access Scope & Authority
Operations Staff handle the physical, logistical, and cargo-handling workflow within their company. They are responsible for container allocation, cargo validation, shipment movement checkpoints, stock management, dock scanning, and compliance document uploads.

#### 3.3.2 What Operations Staff Can VIEW
* **Container Catalog & Availability:** All containers, their specifications, tare weight, max gross weight, goods capacity (kg and CBM), current location, and availability status.
* **Shipments & Live Tracking:** Shipments booked with the company, cargo descriptions, declared weight/volume, route (Origin Port -> Destination Port), assigned vessel, and movement history.
* **Live Tracking Dashboard & Detail:** Checkpoint status, route map, actual vs expected arrival dates, and delay day indicators.
* **Stock & Warehouse Management:** Warehouse stock quantities, product catalog (HSN codes, units of measure), inventory ledger entries, stock upload batch logs, and upload error reports.
* **Compliance Status:** Shipment compliance document list, approval states (`Pending`, `Approved`, `Rejected`, `Expired`), and 15-day expiry warning badges.
* **Claims (Operational View):** Claim incident descriptions, damaged container/item references, incident dates, and attached photographic evidence.
* **Barcodes:** Barcode management catalog, scannable QR/Code128 labels, and scan history.

#### 3.3.3 What Operations Staff Can ADD / CREATE
* **Container Allocation:** Allocate an available container to a booked shipment (enforcing capacity invariants FR3.3 and FR3.4).
* **Movement Checkpoint Updates:** Record new transit checkpoints: `Booked` -> `Container Allocated` -> `Departed` -> `In Transit` -> `Customs Hold` -> `Arrived` -> `Delivered` with timestamp and checkpoint location.
* **Stock Ingestion:** Upload bulk stock CSV files (`/upload-stock`), create manual stock entries, and record stock receipts.
* **Stock Adjustments:** Log inventory adjustments for damaged or lost warehouse goods (with mandatory adjustment reason).
* **Compliance Documents:** Upload required regulatory documents (Customs Declarations, Bills of Lading, Certificates of Origin, Inspection Certificates, Insurance Policies).
* **Barcode Generation & Scanning:** Generate printable barcode labels and scan barcodes on the dock floor via camera or barcode reader (`/scan-barcode`).
* **Operational Claims:** File loss or damage claims upon inspecting incoming/outgoing cargo at the dock.

#### 3.3.4 What Operations Staff Can EDIT / UPDATE
* **Movement Logs:** Update actual departure and arrival dates, log delay justifications.
* **Container Status:** Switch container status between `Available`, `Allocated`, and `Under Maintenance`.
* **Stock Levels:** Modify warehouse quantities through verified physical counts and ledger entries.

#### 3.3.5 What Operations Staff Can DELETE
* **Strict Prohibition:** Operations staff **CANNOT DELETE** shipments, containers, stock items, invoices, claims, or users.

#### 3.3.6 STRICTLY HIDDEN from Operations Staff
* **Company Financials & P&L:** Total revenue, fuel costs, dock penalties, profit/loss amounts, profit margins, and the Profit & Loss Analytics dashboard (`/finance/profit-loss`).
* **Pricing Administration:** Base freight rates, dynamic pricing rules, demand multipliers, and pricing audit logs.
* **Billing Operations:** Generating invoices, recording payments, managing customer credit limits, and reviewing invoice aging.
* **Company Governance:** Company profile editing, staff user management, and security audit logs.
* **Executive Analytics:** ABC classification, Product Profitability Analysis, and executive turnover dashboards.

---

### 3.4 Role 4: Company Staff — Finance (`role_id = 4`)

#### 3.4.1 Access Scope & Authority
Finance Staff govern billing, invoicing, payments, financial loss attribution, and claim monetary settlements. They ensure that all freight services, terminal handling, taxes, and duties are accurately billed, collected, and reconciled.

#### 3.4.2 What Finance Staff Can VIEW
* **Billing & Invoices:** Complete billing register, invoice numbers, customer references, shipment links, issue dates, due dates, subtotal, tax amounts (GST/customs duty), total amounts, paid amounts, balance due, and payment status (`Unpaid`, `Partial`, `Paid`, `Overdue`).
* **Eligible Unbilled Shipments:** Shipments that have reached billable status (`Booked` or `Delivered`) but have not yet had an invoice generated.
* **Payment Ledger:** Complete record of all received payments, payment dates, payment modes (Bank Transfer, Credit Card, UPI, Cheque), and gateway/bank transaction reference numbers.
* **Customer Credit Limits:** Approved credit limits, outstanding balances, and invoice aging reports.
* **Profit & Loss Analytics & Financial Drilldown:** Detailed financial analytics for every shipment: revenue vs total cost breakdown (fuel, port charges, customs duty, insurance, delay penalties, damage payouts), net profit/loss, and loss-reason distribution.
* **Claims (Financial View):** All filed claims, claimed amounts, recommended settlements, approved payout amounts, and linked credit adjustments.
* **Product Profitability Analysis:** Net profitability per product line item after allocating logistics and shipping costs.

#### 3.4.3 What Finance Staff Can ADD / CREATE
* **Invoice Generation:** Generate itemized invoices for eligible shipments with line items (freight cost, insurance, handling surcharges, GST/taxes).
* **Invoice Line Items:** Add custom charges or adjustments to draft invoices.
* **Payment Records:** Record full or partial payments against open invoices (`/record-payment`).
* **Credit Notes / Adjustments:** Issue credit notes against approved claim settlements, reducing customer invoice liability.

#### 3.4.4 What Finance Staff Can EDIT / UPDATE
* **Invoice Details:** Modify invoice payment terms, adjust line-item charges before finalization.
* **Payment Status:** Reconcile payments and update invoice payment status.
* **Claim Settlement:** Settle approved claims (`Approved` -> `Settled`) upon releasing credit notes or issuing refunds.

#### 3.4.5 What Finance Staff Can DELETE
* **Draft Invoices:** Void or cancel draft invoices that contain billing errors before payment has been recorded.
* **Cannot Delete:** Cannot delete completed shipments, customer accounts, payment transaction history, or audit logs.

#### 3.4.6 STRICTLY HIDDEN from Finance Staff
* **Physical Movement Management:** Updating container movement checkpoints (cannot set shipments to Departed, Arrived, Delivered).
* **Container Allocation:** Allocating containers to cargo (operational responsibility).
* **Stock & Inventory Operations:** Uploading stock CSVs, warehouse shelf allocation, and inventory adjustments.
* **Physical Dock Scanning:** Managing dock gate scanners and barcode configuration.
* **Master Data & Governance:** Modifying vessel or port master catalogs, approving companies, managing user accounts.

---

### 3.5 Role 5: Customer / Consumer (`role_id = 5`)

#### 3.5.1 Access Scope & Authority
The Customer is an external client (importer, exporter, business, or individual). Their access is **strictly self-scoped** (`customer_id = user's customer_id`). They can only interact with their own shipments, invoices, containers allocated to their bookings, and claims they have filed.

#### 3.5.2 What Customer Can VIEW
* **Customer Profile:** Own business/individual name, registered address, KYC document status (`Pending`, `Approved`), and approved credit limit.
* **Container Catalog (FR3.1, FR3.2):** Browse the public container catalog: container types (Dry, Reefer, Open Top, Flat Rack, Tank), sizes (20ft, 40ft, 40ft HC, 45ft), container high-resolution photographs, tare weight, maximum gross weight, goods capacity in kilograms and cubic meters (CBM), and current availability.
* **Own Bookings & Shipments:** Complete list of shipments booked by this customer: Shipment ID (`#SHP-XXXXX`), booking date, origin port, destination port, assigned vessel, container ISO number, declared cargo weight/volume, declared value, and current shipment status.
* **Live Movement Tracking (FR2.4, FR2.5):** Real-time checkpoint tracking for own shipments:
  - Route visualizer from Origin Port (Point A) to Destination Port (Point B).
  - Current status indicator: `Booked` -> `Container Allocated` -> `Departed` -> `In Transit` -> `Customs Hold` -> `Arrived` -> `Delivered`.
  - Checkpoint location history with timestamps.
  - Expected arrival date, actual arrival date, and delay days badge.
* **Own Invoices & Billing (FR5.5, FR5.8):**
  - All invoices issued to this customer.
  - Invoice breakdown: freight cost, service charges, GST/taxes, total payable, amount paid, balance due, due date, and payment status (`Unpaid`, `Partial`, `Paid`, `Overdue`).
  - Printable/downloadable PDF format of own invoices (`/view-invoice?id=...`).
* **Own Claims (FR7.1, FR7.3):**
  - Register of claims filed by this customer for lost, damaged, or short-delivered goods.
  - Claim details: claim ID, shipment reference, claim type (Loss, Damage, Shortage), incident date, claimed amount, approved settlement amount, claim status (`Filed`, `Under Review`, `Approved`, `Rejected`, `Settled`), and resolution date.
* **Own Compliance Documents:** Status of mandatory trade documents required for their booked shipments (Customs Declaration, Export License, etc.).

#### 3.5.3 What Customer Can ADD / CREATE
* **Account Registration & KYC (FR1.1, FR1.3):** Register a new customer account, input contact details, and upload KYC verification documents (PDF/images).
* **Book Shipment (FR2.1):** Book a new container shipment:
  - Select Origin Port (Point A) and Destination Port (Point B).
  - Declare cargo description, weight in kg, volume in CBM, and declared insurance value.
  - Select an available container from the catalog matching capacity.
* **Digital Invoice Payments (FR5.7):** Initiate payment against unpaid or partially paid invoices using online payment modes (Card, UPI, Net Banking, Bank Transfer Reference).
* **File Loss & Damage Claims (FR7.1, FR7.2):** Submit a formal claim for damaged or lost cargo:
  - Select affected shipment, container, and product line item.
  - Specify claim type (Loss, Damage, Shortage), incident date, and claimed monetary amount.
  - Provide incident description and upload supporting photographic evidence / inspection reports.

#### 3.5.4 What Customer Can EDIT / UPDATE
* **Profile:** Update phone number, mailing address, and password.
* **Cancel Booking:** Cancel a shipment *only if* it is still in `Booked` status (before container allocation and departure).
* **Upload KYC / Documentation:** Re-upload KYC documents if rejected or expired.

#### 3.5.5 What Customer Can DELETE
* **Strict Prohibition:** Customers **CANNOT DELETE** any records (no deleting shipments, invoices, containers, claims, or audit logs).

#### 3.5.6 STRICTLY HIDDEN & FORBIDDEN FROM CUSTOMER (CRITICAL RBAC MATRIX)
Under no circumstances may a Customer view, access, or infer any of the following data:

| Forbidden Category | Forbidden Resource / Data Field | Rationale |
| :--- | :--- | :--- |
| **Internal Profit & Loss** | • Revenue, Cost, and Profit/Loss amounts<br>• Fuel costs, port docking charges, customs penalties<br>• Profit & Loss Analytics dashboard (`/finance/profit-loss`)<br>• Financial Drilldown screen (`/finance/shipment-drilldown`)<br>• P&L Graph buttons and cost columns on shipment tables | **Confidential Company Trade Secret:** Customers must never see the company's cost structure, profit margins, or internal vendor costs. |
| **Loss Reason Attributions** | • Loss reason tagging (Traffic in Sea, Weather, Dock Allocation, War, Damaged Product)<br>• Loss reason distribution charts | **Internal Operational Liability:** Revealing internal operational failure tags to customers creates legal and commercial exposure. |
| **Other Customers' Data** | • Shipments, containers, invoices, or claims belonging to other customers<br>• Customer directory lists (`/customers`, `/jsp/customers.jsp`)<br>• Dropdowns listing other customers | **Tenant / Privacy Isolation:** Customers must only see their own records. Cross-customer data leakage is a critical security vulnerability. |
| **Pricing Engine & Multipliers** | • Pricing Rules admin page (`/pricing`, `pricing_rules` table)<br>• Base freight rate configuration & pricing audit logs<br>• Seasonal Multiplier & Demand Multiplier formula inputs<br>• Advance Predictive Pricing Graph administration (`/predictive-graph`) | **Commercial Strategy Protection:** Customers see the final calculated quote for a booking, never the internal pricing formulas or multiplier rules. |
| **Warehouse & Stock Management** | • Stock Upload page (`/upload-stock`)<br>• Product Catalog management (`/inventory/products`)<br>• Warehouse stock overview (`/inventory/stock`)<br>• Inventory Ledger (`/ledger`) and damage adjustments | **Internal Operations:** Warehouse inventory and bulk stock ledger are internal logistics company functions. |
| **Barcode Management & Scanning** | • Manage Barcodes page (`/barcodes`)<br>• Scan Barcodes page (`/scan-barcode`)<br>• Dock scanning audit logs (`barcode_scan_log`) | **Internal Floor Workflow:** Barcode scanning is reserved for warehouse and dock staff. |
| **Master Data & Fleet Control** | • Vessels management page (`/jsp/vessels.jsp`, `/vessel`)<br>• Ports management page (`/ports`)<br>• Action buttons to Add, Edit, or Delete Vessels/Ports/Containers | **System Configuration:** Core physical assets are managed exclusively by internal administrators. |
| **Executive & Algorithmic Dashboards** | • Executive Dashboard (`/dashboard/executive`)<br>• Analytics dashboard (`/analytics`)<br>• Sales Trend Analysis, ABC Pareto Classification, Inventory Turnover Ratio, Product Profitability Analysis | **Managerial Decision Support:** These 5 analytical engines are designed strictly for company leadership and Super Admins. |
| **Governance & Security** | • Approvals dropdown (Company & Customer approvals)<br>• Users & Roles administration (`/jsp/admin/users.jsp`)<br>• Audit logs & security monitoring (`/jsp/admin/audit_logins.jsp`) | **System Security:** Governance tools are restricted to Super Admin and Company Admin. |

---

## 4. Master Granular RBAC Permissions & Visibility Matrix

The following matrix defines the exact CRUD (Create, Read, Update, Delete) permissions and visual visibility for every module and feature across all 5 roles:

| Module / Feature | Super Admin (1) | Company Admin (2) | Operations (3) | Finance (4) | Customer (5) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Dashboard Home (`/dashboard`)** | Global KPI Cards & Trends | Company KPI Cards & Trends | Operational Shipment Status | Financial & Invoicing KPIs | **Clean Customer Portal (Own Bookings & Invoices Only)** |
| **Executive Dashboard (`/dashboard/executive`)** | Full View (Global) | Full View (Company) | **HIDDEN** | **HIDDEN** | **HIDDEN** |
| **All Shipments (`/shipments`)** | View All, Edit All, Delete | View Company, Edit, Delete Draft | View Company, Update Status | View Company, View Invoice | **View Own Only (No Edit / Delete / P&L)** |
| **Create Shipment (`/shipments/create`)** | Create for any company | Create for company | Create for company | **HIDDEN** | **Book Own Shipment (Self-Service)** |
| **Live Tracking (`/shipments/tracking`)** | Full Global Tracking | Company Fleet Tracking | Full Checkpoint Tracking | View Transit Status | **View Own Shipments Tracking (Point A -> B)** |
| **Profit & Loss Analytics (`/finance/profit-loss`)** | Full Global Access | Full Company Access | **HIDDEN** | Full Company Access | **STRICTLY HIDDEN** |
| **Financial Drilldown (`/finance/shipment-drilldown`)**| Full Global Access | Full Company Access | **HIDDEN** | Full Company Access | **STRICTLY HIDDEN** |
| **Container Catalog (`/containers`)** | Full CRUD (Global) | Full CRUD (Company) | View & Allocate | View Only | **Browse Catalog & Feasibility (View Only)** |
| **Allocate Container (`/allocate`)** | Execute Allocation | Execute Allocation | **Execute Allocation** | **HIDDEN** | **HIDDEN** (Triggered via Booking) |
| **Pricing Rules (`/pricing`)** | Full CRUD & Override | Edit Base Price & Seasonal | **HIDDEN** | View Rates | **STRICTLY HIDDEN** |
| **Predictive Pricing Graph (`/predictive-graph`)** | View & Calibrate | View Company Forecast | **HIDDEN** | View Demand Trend | **STRICTLY HIDDEN** |
| **Vessels Management (`/vessels`)** | Full CRUD (Global) | View / Add Company Fleet | View Fleet | View Fleet | **HIDDEN** |
| **Ports Management (`/ports`)** | Full CRUD (Global) | View Only | View Only | View Only | **HIDDEN** |
| **Stock Upload (`/upload-stock`)** | Full Access | Full Access | **Upload & Process CSV** | **HIDDEN** | **STRICTLY HIDDEN** |
| **Product Catalog (`/inventory/products`)** | Full CRUD | Full CRUD (Company) | View / Add Products | View Products | **STRICTLY HIDDEN** |
| **Stock Overview (`/inventory/stock`)** | Full View (Global) | Full View (Company) | Full View & Update | View Valuation | **STRICTLY HIDDEN** |
| **Inventory Ledger (`/ledger`)** | Full View (Global) | Full View (Company) | Log IN/OUT & Adjustments | View COGS Impact | **STRICTLY HIDDEN** |
| **Compliance Management (`/compliance`)** | View & Approve All | View & Upload Company | **Upload & Verify Docs** | View Status | **View Own Doc Status Only** |
| **Billing & Invoices (`/billing`)** | Full View & Audit | Full Access (Company) | **HIDDEN** | **Full CRUD & Reconcile** | **View Own Invoices & Pay Online** |
| **Invoices & Statements (`/invoices`)** | Global Invoices | Company Invoices | **HIDDEN** | Company Invoices | **Own Invoices Only** |
| **Claims Management (`/claims`)** | Full View & Settlement | Review & Approve Claims | **File & View Proof** | **Settle & Issue Credit** | **File Claim & Track Own Status** |
| **Barcode Management (`/barcodes`)** | Generate & Audit All | Generate for Company | **Generate Labels** | **HIDDEN** | **STRICTLY HIDDEN** |
| **Barcode Scanning (`/scan-barcode`)** | Full Scanner Access | Full Scanner Access | **Dock Scanner Access** | **HIDDEN** | **STRICTLY HIDDEN** |
| **Analytics (5 Algorithms) (`/analytics`)** | Full Execution (Global) | Full Execution (Company)| **HIDDEN** | Product Profitability Only | **STRICTLY HIDDEN** |
| **Approvals: Companies (`/admin/companies`)** | **Approve / Reject** | **HIDDEN** | **HIDDEN** | **HIDDEN** | **HIDDEN** |
| **Approvals: Customers (`/admin/customers`)** | **Approve / Reject** | Review Company Customers | **HIDDEN** | **HIDDEN** | **HIDDEN** |
| **Users & Roles (`/admin/users`)** | **Full User CRUD** | Manage Company Staff | **HIDDEN** | **HIDDEN** | **HIDDEN** |
| **Audit Logs (`/admin/audit_logins`)** | **Full Security Audit** | View Company Audit Log | **HIDDEN** | **HIDDEN** | **HIDDEN** |

---

## 5. End-to-End System Workflows

### 5.1 Primary Shipment Lifecycle Workflow
The diagram below illustrates the complete lifecycle of a shipment, showing handoffs between Customer, Operations, Compliance, and Finance:

```
[1. CUSTOMER]
      │  Browses Container Catalog (FR3.1, FR3.2)
      │  Checks dimensions, CBM capacity, tare weight
      ▼
[2. CUSTOMER]
      │  Books Shipment (FR2.1) -> Status: "Booked"
      │  Supplies cargo weight, volume, origin, destination
      ▼
[3. OPERATIONS STAFF]
      │  Inspects available containers at Origin Port
      │  Validates cargo weight <= max_gross_weight (FR3.4)
      │  Validates cargo volume <= goods_capacity_cbm (FR3.4)
      │  Allocates container (FR3.3) -> Status: "Container Allocated"
      ▼
[4. OPERATIONS / CUSTOMER]
      │  Uploads mandatory Trade Compliance Docs (FR5.1, FR5.2)
      │  (Customs Declaration, Export License, Certificate of Origin, Insurance)
      ▼
[5. COMPLIANCE CHECK (CONTRACT PRECONDITION - FR5.3)]
      │  Are ALL mandatory documents Approved and unexpired?
      ├───────────────────────────────┐
     [NO]                            [YES]
      │                               │
      ▼                               ▼
[BLOCKED: Cannot Depart]     [6. OPERATIONS STAFF]
                              Sets Status: "Departed"
                                      │
                                      ▼
                             [7. CHECKPOINT TRACKING]
                              Operations updates:
                              "In Transit" -> ("Customs Hold") -> "Arrived" -> "Delivered"
                              Timestamped & attributed to staff user (FR2.3)
                                      │
                                      ▼
                             [8. FINANCE STAFF / SYSTEM]
                              Auto-generates Invoice (FR5.5)
                              Freight + Service Charges + Tax (GST) + Surcharges
                                      │
                                      ▼
                             [9. CUSTOMER]
                              Views Invoice & makes payment (FR5.7)
                                      │
                                      ▼
                             [10. FINANCE / SYSTEM]
                              Computes Profit & Loss (FR2.6)
                              Revenue - (Fuel + Port + Customs + Insurance + Claims)
                              Tags Loss Reasons if loss-making (FR2.7)
```

---

### 5.2 Supply Chain Loss & Damage Claim Workflow (Module 7)
Claims can be initiated by either a Customer (upon receiving damaged/short goods) or Operations Staff (upon inspecting incoming containers at the dock):

```
[CUSTOMER or OPERATIONS STAFF]
      │
      │  Files Claim (FR7.1, FR7.2)
      │  Captures: Shipment ID, Container ID, Claim Type (Loss/Damage/Shortage),
      │  Incident Date, Claimed Amount, Photo Evidence / Inspection Reports
      ▼
[CLAIM STATUS: "Filed"]
      │
      │  Attributed to filing user with timestamp (FR7.6)
      ▼
[COMPANY ADMIN / OPERATIONS REVIEW]
      │
      │  Reviews physical inspection and photographic proof
      ▼
[CLAIM STATUS: "Under Review"]
      │
      ├───────────────────────────────────────────┐
     [REJECTED]                                  [APPROVED]
      │                                           │
      ▼                                           ▼
[Status: "Rejected"]                     [Status: "Approved"]
Reason logged in history                 `approved_amount` recorded (FR7.4)
                                                  │
                                                  ▼
                                         [FINANCE SETTLEMENT]
                                         Issues Credit Note against Customer Invoice
                                         Posts additional cost to Shipment P&L (FR7.6)
                                                  │
                                                  ▼
                                         [CLAIM STATUS: "Settled"] (FR7.5)
```

---

### 5.3 Dynamic Pricing & Demand Forecasting Feedback Loop (Modules 3 & 6)
The dynamic pricing engine automatically adjusts container rates based on real-time and historical demand:

```
[HISTORICAL DATA FACT TABLES]
Sales Transactions + Shipment Bookings per Container Type & Route
      │
      ▼
[DEMAND FORECASTING ALGORITHM (Section 5.5)]
Computes projected demand for upcoming N periods
      │
      ▼
[DEMAND MULTIPLIER (FR3.5)]
Derived from forecasted demand index
      │
      ▼
[DYNAMIC PRICING ENGINE (FR3.5)]
Final Price = Base Price × Seasonal Multiplier × Demand Multiplier + Surcharges
      │
      ▼
[ADVANCE PREDICTIVE GRAPH (FR3.6)]
Renders future price and demand trend curves for Admins
      │
      ▼
[CUSTOMER BOOKING QUOTE]
Displayed to Customer when selecting container for route
```

---

## 6. Implementation Architecture for RBAC & Visibility

To resolve the identified visibility gap where roles are assigned but UI and data access are not partitioned, the following architectural controls must be implemented across all three application tiers:

### 6.1 Presentation Tier (`header.jsp` & JSP Views)

#### 6.1.1 Navigation Sidebar Segmentation
The main navigation sidebar in `header.jsp` must use JSTL `<c:choose>` and `<c:if>` tags conditioned on `${sessionScope.user.roleId}`:

1. **Role 5 (Customer): Clean Dedicated Portal:**
   * **Dashboard Home:** Customer personal overview (Active bookings, invoices pending payment, recent tracking status).
   * **Container Catalog:** Browse containers, specifications, and dimensions (`/containers`).
   * **Book Shipment:** Self-service shipment booking wizard (`/shipments/create`).
   * **My Shipments & Tracking:** List of own shipments and live tracking timelines (`/shipments`, `/shipments/tracking`).
   * **My Invoices & Payments:** Billing statements, invoice viewer, and payment modal (`/invoices`).
   * **Claims & Support:** My filed claims and new claim submission (`/claims`).
   * **Profile & KYC:** Contact details and KYC status.
   * *(All internal Operations, Management, Financial Drilldown, and Analytics menus are completely suppressed).*

2. **Role 3 (Operations Staff):**
   * **Operations Section:** All Shipments, Create Shipment, Live Tracking, All Containers, Allocate Container, Vessels, Ports.
   * **Stock Section:** Upload Stock (CSV), Product Catalog, Stock Overview, Inventory Ledger.
   * **Tracking & Scanning:** Manage Barcodes, Scan Barcodes.
   * **Compliance:** Government Compliance document manager.
   * **Claims:** Claims register (operational view).
   * *(Profit & Loss Analytics, Financial Drilldowns, Billing, Pricing Rules, User Governance, and Analytics are hidden).*

3. **Role 4 (Finance Staff):**
   * **Financial Operations:** Profit & Loss Analytics, Financial Drilldown, Billing & Invoices, Invoices & Statements, Record Payment.
   * **Pricing Reference:** View freight rates and pricing rules.
   * **Claims Settlement:** Claims register (financial review & settlement).
   * **Reports:** Customer Aging and Product Profitability.
   * *(Physical Container Allocation, Movement Status Checkpoint overrides, Stock CSV Uploads, and Barcode Scanning are hidden).*

4. **Role 2 (Company Admin):**
   * Access to all company-scoped Operations, Finance, Stock, Compliance, Claims, and Analytics menus.
   * Staff governance: Users & Roles (filtered to own company staff).
   * *(Approvals for other companies and global platform settings are hidden).*

5. **Role 1 (Super Admin):**
   * Unrestricted access to all sections.
   * Exclusive Approvals menu: Company Approvals (`/admin/companies`), Customer Approvals (`/admin/customers`).
   * Exclusive Security menu: Global Users & Roles (`/admin/users`), Security & Audit Logs (`/admin/audit_logins`).

#### 6.1.2 Omnibox Search Palette Filtering
The global omnibox search script in `header.jsp` (`initOmnibox()`) must filter searchable navigation routes based on the user's role, preventing unauthorized endpoints from appearing in search results.

#### 6.1.3 Data Table Action Button Guards
In `shipments.jsp`, `containers.jsp`, `billing.jsp`, `claims.jsp`, and `stock.jsp`, action buttons must be wrapped in role checks:
* **Edit Button (`/shipments/edit`):** Rendered only for Role <= 3 (Admins and Ops).
* **Delete Button (Delete Modal):** Rendered **ONLY for Role 1 (Super Admin)** and Role 2 (Company Admin for draft shipments).
* **Profit & Loss / Financial Drilldown Button:** Rendered **ONLY for Role 1, 2, and 4 (Finance)**. Hidden from Role 3 (Ops) and Role 5 (Customer).
* **Status Update Modal:** Rendered **ONLY for Role <= 3 (Ops and Admins)**. Hidden from Finance and Customer.

---

### 6.2 Controller & Filter Tier (Java EE Servlets & Filters)

#### 6.2.1 Central `AuthenticationFilter.java` Refinement
The `AuthenticationFilter` must enforce the following strict path-to-role rules:

```java
// Role Hierarchy Constants:
// 1 = SUPER_ADMIN, 2 = COMPANY_ADMIN, 3 = OPERATIONS, 4 = FINANCE, 5 = CUSTOMER

// 1. Super Admin Only
if (path.startsWith("/admin") || path.contains("/delete")) {
    allowed = (roleId == 1);
}
// 2. Executive & Algorithmic Analytics (Admins Only)
else if (path.startsWith("/dashboard/executive") || path.startsWith("/analytics")) {
    allowed = (roleId <= 2);
}
// 3. Profit & Loss and Financial Drilldown (Admins & Finance Only)
else if (path.startsWith("/finance")) {
    allowed = (roleId == 1 || roleId == 2 || roleId == 4);
}
// 4. Pricing Administration
else if (path.startsWith("/pricing") || path.startsWith("/predictive-graph")) {
    allowed = (roleId <= 2 || roleId == 4); // View/edit based on role
}
// 5. Physical Operations, Stock Uploads & Barcode Scanning
else if (path.startsWith("/upload-stock") || path.startsWith("/stock") || 
         path.startsWith("/ledger") || path.startsWith("/scan-barcode") || 
         path.startsWith("/barcodes") || path.startsWith("/allocate")) {
    allowed = (roleId <= 3); // Admins and Operations
}
// 6. Billing & Invoices
else if (path.startsWith("/billing") || path.startsWith("/generate-invoice") || 
         path.startsWith("/record-payment")) {
    allowed = (roleId <= 2 || roleId == 4); // Admins and Finance
}
// 7. Customer Accessible Endpoints (Controllers enforce tenant/ownership isolation)
else if (path.startsWith("/shipments") || path.startsWith("/containers") || 
         path.startsWith("/claims") || path.startsWith("/invoices") || 
         path.startsWith("/compliance")) {
    allowed = true; // All authenticated roles can enter; controllers scope data
}
```

#### 6.2.2 Controller Data Scoping & IDOR Prevention
Every controller must query data partitioned by the caller's identity:

* **`ShipmentServlet.java`:**
  ```java
  if (roleId == 5) { // Customer
      int customerId = resolveCustomerId(user.getUserId());
      request.setAttribute("shipments", shipmentDAO.getShipmentsByCustomerId(customerId));
  } else if (roleId == 2 || roleId == 3 || roleId == 4) { // Company-scoped
      request.setAttribute("shipments", shipmentDAO.getShipmentsByCompanyId(user.getCompanyId()));
  } else { // Super Admin
      request.setAttribute("shipments", shipmentDAO.getAllShipments());
  }
  ```
* **`BillingServlet.java` & `InvoiceServlet.java`:**
  - When accessed by a Customer (`roleId == 5`), return only invoices where `customer_id = customerId`.
  - When accessed by Finance Staff (`roleId == 4`), return invoices where shipment belongs to `company_id`.
* **`ClaimServlet.java`:**
  - Ensure Customers can only view, edit, or submit claims for shipments where `shipment.customer_id = customerId`.

---

### 6.3 Data Access Tier (DAO & Database Stored Procedures)

1. **Scoped Query Methods:**
   * `ShipmentDAO`: Add `getShipmentsByCustomerId(int customerId)` and `getShipmentsByCompanyId(int companyId)`.
   * `BillingDAO`: Add `getInvoicesByCustomerId(int customerId)` and `getInvoicesByCompanyId(int companyId)`.
   * `ClaimDAO`: Add `getClaimsByCustomerId(int customerId)` and `getClaimsByCompanyId(int companyId)`.
   * `CustomerDAO`: Add `getCustomerByUserId(int userId)`.
2. **Database Stored Procedures:**
   * Existing stored procedures (`update_users`, `delete_users`, `delete_customers`, `login_attempt`) already accept `p_requesting_user_id` and enforce Super Admin authority at the database engine level.

---

## 7. Project Codebase & Directory Map

```
d:\NLogistic\NLogistic\
├── CLAUDE.md                               # This Master Architecture & RBAC Specification
├── srs_harness.md                          # Original IEEE 830 SRS Specification
├── srs.pdf                                 # Full Master Project Document
├── DataSeeder.java                         # Database Seeder Utility
├── src/main/
│   ├── java/com/nlogistic/
│   │   ├── controller/                     # MVC2 Servlets (HTTP dispatchers & controllers)
│   │   │   ├── AdminCompanyServlet.java    # Company approvals (Super Admin)
│   │   │   ├── AdminUserServlet.java       # User approvals & lockout unlocks
│   │   │   ├── AllocateContainerServlet.java # Container allocation with capacity contracts
│   │   │   ├── AnalyticsServlet.java       # 5 Analytical Algorithms engine
│   │   │   ├── BarcodeServlet.java         # Barcode catalog & label export
│   │   │   ├── BillingServlet.java         # Invoicing, taxes, receivables, overdue flagging
│   │   │   ├── BookShipmentServlet.java    # Customer self-service shipment booking
│   │   │   ├── ClaimServlet.java           # Supply chain loss & damage claims
│   │   │   ├── ComplianceServlet.java      # Trade compliance gating & expiry alerts
│   │   │   ├── ContainerCatalogServlet.java# Container public catalog
│   │   │   ├── ContainerServlet.java       # Container fleet CRUD
│   │   │   ├── CustomerServlet.java        # Customer management & registration
│   │   │   ├── DashboardServlet.java       # Role-based dashboard router
│   │   │   ├── ExecutiveDashboardServlet.java # Executive KPI & algorithm dashboard
│   │   │   ├── FinanceServlet.java         # Profit & Loss Analytics & Financial Drilldown
│   │   │   ├── InventoryServlet.java       # Warehouse products & stock levels
│   │   │   ├── LoginServlet.java           # Authentication, session timeout, lockout
│   │   │   ├── LogoutServlet.java          # Session invalidation
│   │   │   ├── ManualStockServlet.java     # Direct stock receipt entry
│   │   │   ├── PortServlet.java            # UN/LOCODE port master
│   │   │   ├── PredictiveGraphServlet.java # Demand forecasting graph & pricing trends
│   │   │   ├── PricingServlet.java         # Base rate adjustments & multiplier calibration
│   │   │   ├── RecordPaymentServlet.java   # Payment receipt recording
│   │   │   ├── RegisterServlet.java        # Company & Customer registration
│   │   │   ├── ScanBarcodeServlet.java     # Dock barcode camera/scanner handler
│   │   │   ├── ShipmentServlet.java        # Shipment lifecycle & live tracking
│   │   │   ├── StockAdjustmentServlet.java # Damage write-offs with mandatory reason
│   │   │   ├── StockUploadServlet.java     # Bulk stock CSV upload & error reporting
│   │   │   └── VesselServlet.java          # Maritime vessel master
│   │   ├── dao/                            # Data Access Objects (JDBC with PreparedStatement)
│   │   │   ├── AnalyticsDAO.java           # Algorithm computation (ABC, Turnover, Profit, Forecast)
│   │   │   ├── AuditDAO.java               # Security audit logging
│   │   │   ├── BarcodeDAO.java             # Barcode entry generation & scan logs
│   │   │   ├── BillingDAO.java             # Invoices, line items, payments
│   │   │   ├── ClaimDAO.java               # Claims, photo documents, status history
│   │   │   ├── CompanyDAO.java             # Company tenants & approval states
│   │   │   ├── ComplianceDAO.java          # Document status & departure gating
│   │   │   ├── ContainerDAO.java           # Container capacity & port tracking
│   │   │   ├── CustomerDAO.java            # Customer profiles & KYC docs
│   │   │   ├── PricingRuleDAO.java         # Dynamic pricing rules & audit history
│   │   │   ├── ProductDAO.java             # Products & HSN codes
│   │   │   ├── ProfitLossDAO.java          # Financial P&L calculations & loss reasons
│   │   │   ├── ShipmentDAO.java            # Shipments, movements, checkpoints
│   │   │   ├── StockDAO.java               # Warehouse stock, ledger, CSV logs
│   │   │   └── UserDAO.java                # User credentials, BCrypt/SHA2, SP login
│   │   ├── filter/
│   │   │   └── AuthenticationFilter.java   # Central RBAC and session security filter
│   │   ├── model/                          # POJO Domain Entities
│   │   └── util/
│   │       ├── DBConnectionManager.java    # HikariCP / JDBC Connection Pool
│   │       ├── BarcodeUtil.java            # Barcode image generator (ZXing)
│   │       └── EmailService.java           # Expiry alerts & password reset tokens
│   └── webapp/
│       ├── WEB-INF/web.xml                 # Java EE Deployment Descriptor
│       ├── assets/                         # CSS, JS, Brand Icons, Vendor Libraries
│       └── jsp/                            # View Layer (Strict JSTL/EL - No Scriptlets)
│           ├── layout/
│           │   ├── header.jsp              # Main sidebar, topbar, omnibox, user profile
│           │   ├── customer_header.jsp     # Dedicated customer portal header
│           │   └── footer.jsp              # Footer & global modal scripts
│           ├── admin/
│           │   ├── companies.jsp           # Super Admin company approval queue
│           │   ├── customers.jsp           # Customer approvals & credit limits
│           │   ├── users.jsp               # Staff user management & role assignment
│           │   └── audit_logins.jsp        # Security audit log & lockout viewer
│           ├── dashboard.jsp               # Main operational & role dashboard
│           ├── customer_dashboard.jsp      # Clean customer self-service dashboard
│           ├── executive_dashboard.jsp     # Executive KPI & predictive analytics
│           ├── shipments.jsp               # All shipments list with action modals
│           ├── create_shipment.jsp         # Booking wizard
│           ├── live_tracking_dashboard.jsp # Real-time fleet tracking map & route list
│           ├── live_tracking_detail.jsp    # Checkpoint timeline & delay status
│           ├── profit_loss_analytics.jsp   # P&L time-series & loss reason breakdown
│           ├── shipment_drilldown.jsp      # Deep financial cost attribution card
│           ├── containers.jsp              # Container catalog & capacity viewer
│           ├── allocate-container.jsp      # Physical allocation with capacity checks
│           ├── pricing.jsp                 # Pricing rules & multiplier calibration
│           ├── predictive-graph.jsp        # Advance predictive pricing & demand graph
│           ├── stock.jsp                   # Warehouse stock levels & adjustments
│           ├── upload-stock.jsp            # Bulk CSV stock upload interface
│           ├── ledger.jsp                  # Inventory movement ledger (IN/OUT)
│           ├── compliance.jsp              # Regulatory document status & expiry alerts
│           ├── billing.jsp                 # Billing overview & invoice generation
│           ├── invoices.jsp                # Invoice register & statements
│           ├── invoice-template.jsp        # Printable / PDF invoice template
│           ├── claims.jsp                  # Claims register & review workflow
│           ├── claim-details.jsp           # Claim evidence & settlement audit
│           ├── barcodes.jsp                # Barcode label management & print
│           └── scan-barcode.jsp            # Camera / hardware scanner terminal
```

---

## 8. Summary of Action Items for Ongoing Implementation

1. **Update `AuthenticationFilter.java`:** Refine path matching so that `/finance/*`, `/pricing/*`, `/upload-stock`, `/admin/*`, and `/scan-barcode` strictly enforce role IDs 1, 2, 3, 4, and 5 according to the matrix above.
2. **Partition Navigation in `header.jsp`:** Enforce role-based `<c:if>` wrappers around sidebar links, submenus, and omnibox search entries. Provide external Customers with a clean, unencumbered portal view.
3. **Guard Action Buttons in JSPs:** Wrap `Edit`, `Delete`, `Financial Drilldown`, and `Status Update` modal triggers in `shipments.jsp`, `containers.jsp`, and `billing.jsp` with `<c:if test="${sessionScope.user.roleId <= ...}">`.
4. **Implement Tenant & Customer Scoping in Servlets:** Ensure that `ShipmentServlet`, `BillingServlet`, `ClaimServlet`, and `DashboardServlet` automatically query data filtered by `customer_id` for Role 5 and `company_id` for Roles 2, 3, and 4.
5. **Contract Enforcement:** Maintain Design-by-Contract preconditions at the service/controller layer:
   - Container allocation requires `status == 'Available'` and `cargoWeight <= max_gross_weight` and `cargoVolume <= goods_capacity_cbm`.
   - Shipment transition to `Departed` requires all mandatory compliance documents to be `Approved` and unexpired (FR5.3).
   - Claim transition to `Settled` requires an `approved_amount` and credit note generation (FR7.5).
