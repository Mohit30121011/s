# MEGA PROMPT: SRS-Compliant Two-Stage Booking & Container Allocation Workflow

> **Purpose:** Use this Mega Prompt to instruct any AI coding assistant (Claude Code, Antigravity, Cursor, GitHub Copilot, ChatGPT) or developer to implement the industry-standard decoupled **Customer Booking & Operations Container Allocation Workflow** in **ANY** logistics, supply chain, freight forwarding, or shipping enterprise application regardless of backend stack or file structure.

---

```markdown
# TASK SPECIFICATION: Implementation of Decoupled Customer Booking and Operations Container Allocation Workflow (SRS Compliant)

## 1. OBJECTIVE & ARCHITECTURAL PROBLEM STATEMENT
You are an expert enterprise systems architect and supply chain engineer. Your mission is to implement a strict, decoupled, two-stage **Shipment Booking and Physical Fleet Allocation Workflow** compliant with standard Software Requirements Specifications (SRS).

### The Anti-Pattern Being Eliminated:
In naive logistics implementations, when a customer (shipper) books a shipment online, the system prematurely assigns and locks a specific physical container (`container_id`) and immediately sets its status to `'Allocated'` or `'In-Transit'`.
This violates real-world supply chain reality:
1. Customers book cargo capacity (e.g. "I want to ship 18,000 kg / 35 CBM of Machinery from Port A to Port B"). They do NOT own, manage, or assign physical yard assets.
2. Physical container assignment is the strict operational responsibility of **Depot Dispatchers, Dock Foremen, and Company Operations Staff**.
3. Prematurely locking a container prevents other customers from booking and bypasses yard inspections, physical tare/gross capacity verification, and depot availability.

### The Standard Decoupled Architecture:
- **Stage 1 (Customer / Shipper - Role 5):**
  - Customer books cargo specifications (Description, Weight, Volume, Origin, Destination, Declared Value, requested container type) and completes payment.
  - **Postcondition:** Shipment is created with **`Status = 'Booked'`**.
  - **Fleet Invariant:** The physical container is **NOT** locked; fleet units in `containers` remain **`Status = 'Available'`**.
  - **Customer UI Transparency:** The customer's tracking view is strictly read-only. It marks Milestone 1 (`Booked`) as completed, while the Container field displays a clear badge: *"Pending Allocation by Operations"*, and Milestone 2 (`Container Allocated`) shows *"Pending Operations"*.

- **Stage 2 (Company Operations Staff / Company Admin - Roles 2 & 3):**
  - Operations staff open the **Shipments Management Portal** and view shipments in `'Booked'` status.
  - An **"Allocate Container"** workbench opens, inspecting cargo weight and volume against available depot containers.
  - **Contract Preconditions (FR3.3 & FR3.4):**
    * *FR3.3 (Availability Invariant):* Container must currently have `Status = 'Available'`.
    * *FR3.4 (Capacity Precondition):* `cargoWeight <= container.maxGrossWeight` AND `cargoVolume <= container.goodsCapacityCbm`.
  - Operations staff select a valid container and confirm allocation.
  - **Postcondition:** Atomic transaction:
    1. `shipment.container_id` is assigned the physical container ID.
    2. `shipment.status` advances to `'Container Allocated'`.
    3. `containers.status` is locked to `'Allocated'`.
    4. An audit milestone is logged in `container_movements` / movement history.
    5. Database stored procedure / triggers execute.

- **Stage 3 (Real-Time Customer Synchronization):**
  - Customer's live tracking view automatically reflects Milestone 2 (`Container Allocated`) as green/completed and displays the real physical container number (e.g., `#MSKU-782910`).

---

## 2. SYSTEM DATA FLOW & STATE PROGRESSION

```
[Customer Checkout / Booking]
       │
       ├──► 1. POST /shipments/create or /book (Cargo specs: weight, volume, route)
       │         │
       │         ▼
       │    [Atomic Booking Insertion]
       │         ├── Insert shipment (status='Booked')
       │         ├── Insert movement_log (status='Booked', location='Booking Confirmed - Awaiting Container Allocation')
       │         └── DO NOT change containers table! Container remains 'Available'.
       │
       ▼
[Customer Live Tracking]
       ├── Milestone 1: [● Booked] (Active / Completed)
       ├── Container ID: [⏳ Pending Allocation by Operations]
       └── Milestone 2: [○ Container Allocated] (Pending Operations)
       │
       ▼
[Operations / Admin Shipments Workbench]
       │
       ├──► 2. Operations Staff inspects All Shipments
       │         └── Row with status 'Booked' renders [📦 Allocate] action button
       │
       ├──► 3. Clicks [Allocate] -> Opens Allocation Workbench Modal
       │         └── GET /shipments/availableContainers?shipmentId=xxx
       │         └── Displays cargo specs vs available container list
       │         └── Live validation flags:
       │             * Fits Cargo: cargoWeight <= maxGross && cargoVolume <= maxCbm (GREEN)
       │             * Over Capacity: cargo exceeds container limits (RED - Disabled)
       │             * At Origin Port: depot port matches shipment origin (BLUE)
       │
       ├──► 4. POST /shipments/allocateContainer (shipmentId=xxx, containerId=yyy)
       │         │
       │         ▼
       │    [Atomic Allocation Mutation]
       │         ├── UPDATE shipment SET container_id = yyy, status = 'Container Allocated'
       │         ├── UPDATE containers SET status = 'Allocated' WHERE container_id = yyy
       │         ├── INSERT container_movements (status='Container Allocated', location='Depot Yard - Container Allocated')
       │         └── CALL allocate_container(shipmentId, containerId)
       │
       ▼
[Customer Live Tracking (Auto-Updated)]
       ├── Milestone 1: [✔ Booked]
       ├── Container ID: [📦 #MSKU-782910] (Assigned Physical Fleet Unit)
       └── Milestone 2: [● Container Allocated] (Active / Completed)
```

---

## 3. ADAPTABLE IMPLEMENTATION BLUEPRINT (Any Framework / Language)

### Step 1: Database Schema & Entity Invariants
Ensure your database tables support this lifecycle (adapt column names as needed):

1. **`shipment` / `orders` table:**
   - `shipment_id` (PK)
   - `customer_id` (FK -> customers)
   - `container_id` (FK -> containers, nullable or initially linked to requested catalog type)
   - `origin_port_id` / `destination_port_id` (FK -> ports / locations)
   - `cargo_weight_kg` (Decimal)
   - `cargo_volume_cbm` (Decimal)
   - `cargo_description` (Text)
   - `status` (Enum/Varchar): Values: `'Booked'`, `'Container Allocated'`, `'Departed'`, `'In Transit'`, `'Arrived'`, `'Delivered'`, `'Cancelled'`.

2. **`containers` table:**
   - `container_id` (PK)
   - `container_number` (Varchar, e.g. MSKU-782910)
   - `type` (Dry, Reefer, Open Top, Flat Rack, Tank)
   - `size` (20ft, 40ft, 40ft HC, 45ft)
   - `max_gross_weight_kg` / `goods_capacity_kg` (Decimal)
   - `goods_capacity_cbm` (Decimal)
   - `status` (Enum/Varchar): Values: `'Available'`, `'Allocated'`, `'In-Transit'`, `'Under Maintenance'`.
   - `current_port_id` (FK -> ports)
   - `owner_company_id` (FK -> companies)

3. **`container_movements` / `tracking_logs` table:**
   - `movement_id` (PK)
   - `shipment_id` (FK -> shipment)
   - `status` (Varchar)
   - `checkpoint_location` (Varchar)
   - `updated_by` (FK -> users)
   - `updated_at` (Timestamp)

---

### Step 2: Customer Booking Execution (Stage 1)
Modify the booking controller / executor so that customer bookings:
1. Calculate freight price & process payment.
2. Insert shipment with `status = 'Booked'`.
3. Record initial movement:
   ```sql
   INSERT INTO container_movements (shipment_id, status, updated_by, checkpoint_location)
   VALUES (?, 'Booked', ?, 'Booking Confirmed - Awaiting Container Allocation by Operations');
   ```
4. **CRITICAL:** Do NOT update `containers SET status = 'Allocated'` during customer booking! The container status MUST stay `'Available'`.

---

### Step 3: REST / Controller Endpoints for Allocation Workbench (Stage 2)

#### 1. Available Containers Provider: `GET /shipments/availableContainers?shipmentId=xxx`
- **Role Guard:** Staff & Admins only (`roleId <= 3`).
- **Logic:**
  1. Fetch shipment cargo weight, volume, and origin port.
  2. Fetch all containers with `status = 'Available'` (scoped to tenant company if applicable).
  3. Map each container with capability booleans:
     - `fitsWeight = (container.maxGrossWeight <= 0 || cargoWeight <= container.maxGrossWeight)`
     - `fitsVolume = (container.capacityCbm <= 0 || cargoVolume <= container.capacityCbm)`
     - `fitsAll = fitsWeight && fitsVolume`
     - `matchesOrigin = (shipment.originPortId == container.currentPortId)`
- **Response (JSON):**
  ```json
  {
    "shipment": {
      "shipmentId": 105,
      "customerName": "Acme Logistics",
      "originPort": "Port of Nhava Sheva",
      "destPort": "Port of Singapore",
      "cargoWeight": 14200.0,
      "cargoVolume": 26.5,
      "status": "Booked"
    },
    "containers": [
      {
        "containerId": 42,
        "containerNumber": "MSKU-782910",
        "type": "Dry",
        "size": "40ft",
        "portName": "Port of Nhava Sheva",
        "goodsCapacityKg": 28000.0,
        "goodsCapacityCbm": 67.0,
        "fitsWeight": true,
        "fitsVolume": true,
        "fitsAll": true,
        "matchesOrigin": true
      }
    ]
  }
  ```

#### 2. Allocation Execution Action: `POST /shipments/allocateContainer`
- **Parameters:** `shipmentId`, `containerId`, `remarks`
- **Role Guard:** Staff & Admins only (`roleId <= 3`). Deny customers with `403 Forbidden`.
- **Precondition Validations (Enforce Design-by-Contract):**
  1. Shipment must exist and current status must be `'Booked'`.
  2. Container must exist and current status must be `'Available'` (FR3.3).
  3. Tenancy check: Container owner company matches staff company.
  4. Capacity check (FR3.4): Reject with error if `cargoWeight > container.maxGrossWeight` or `cargoVolume > container.capacityCbm`.
- **Atomic Mutation (inside DB Transaction):**
  ```java
  // 1. Link physical container & advance shipment status
  UPDATE shipment SET container_id = ?, status = 'Container Allocated' WHERE shipment_id = ?;

  // 2. Lock physical container
  UPDATE containers SET status = 'Allocated' WHERE container_id = ?;

  // 3. Log audit checkpoint
  INSERT INTO container_movements (shipment_id, status, checkpoint_location, updated_by)
  VALUES (?, 'Container Allocated', ?, ?);

  // 4. Stored procedure / trigger execution
  CALL allocate_container(shipmentId, containerId);
  ```
- **Redirect / Response:** Success flash message: *"Container MSKU-782910 successfully allocated to Shipment #SHP-105. Status advanced to 'Container Allocated'."*

---

### Step 4: Front-End UI Components

#### A. Shipments Table View (`shipments.jsp` / `ShipmentsList.vue` / `ShipmentsPage.tsx`)
1. **Container Column:**
   - If `status == 'Booked'`: Render `<span class="badge badge-warning"><i class="ti ti-clock"></i> Pending Allocation</span>`.
   - If `status != 'Booked'`: Render `<strong class="text-orange">#${containerNumber}</strong>`.
2. **Action Column:**
   - For Operations Staff & Admins: If `status == 'Booked'`, render prominent button:
     `<button class="btn btn-sm btn-warning" onclick="openAllocationWorkbench(shipmentId)"><i class="ti ti-box"></i> Allocate</button>`.

#### B. Container Allocation Workbench Modal
- **Trigger:** Clicking "Allocate" button opens modal with shipment ID.
- **Header:** *"Container Allocation Workbench — Physical Fleet Assignment & Capacity Verification"*.
- **Cargo Summary Card:**
  - Shipment ID `#SHP-xxx`, Customer Name.
  - Route: Origin Port &rarr; Destination Port.
  - Weight (kg) badge & Volume (CBM) badge.
- **Available Containers Table:**
  - Columns: `Radio Pick`, `Container Number`, `Type & Size`, `Depot Location`, `Capacity Limits`, `FR3.4 Gate`.
  - Rows with `fitsAll == true`: Display green badge `<span class="badge bg-success">Fits Cargo</span>`. Radio enabled.
  - Rows with `fitsAll == false`: Display red badge `<span class="badge bg-danger">Over Capacity</span>`. Radio disabled!
  - Rows with `matchesOrigin == true`: Display blue badge `<span class="badge bg-info">At Origin</span>`.
- **Remarks Input:** Optional dispatcher note (e.g. *"Assigned from Yard 3 &bull; Physical inspection clear"*).
- **Footer:** `"Confirm & Allocate Container"` button (submits form).

#### C. Customer Live Tracking View (`live_tracking_detail.jsp` / `TrackingPage.tsx`)
1. **Top Summary & Meta Card:**
   - When `shipment.status == 'Booked'`:
     ```html
     <span class="badge bg-warning text-dark">
         <i class="ti ti-clock"></i> Pending Allocation by Operations
     </span>
     ```
   - When `shipment.status != 'Booked'`:
     ```html
     <strong class="font-monospace text-orange">#${shipment.containerNumber}</strong>
     ```
2. **Horizontal Milestone Stepper:**
   - **Milestone 1 (Booked):** Marked completed / active.
   - **Milestone 2 (Container Allocated):** Marked pending with label: `"Pending Operations"` until physically allocated.
   - Once allocated, Milestone 2 turns green and displays date/time.

---

## 5. AUTOMATED VERIFICATION TEST PLAN
When implementing, verify the following sequence:
1. **TC-ALLOC-01 (Customer Booking):**
   - Book a shipment as a customer.
   - Assert in DB: `shipment.status == 'Booked'`.
   - Assert in DB: `containers.status == 'Available'` (container is NOT allocated).
   - Assert on Tracking UI: Container ID displays *"Pending Allocation by Operations"*.
2. **TC-ALLOC-02 (Precondition Rejection - Overweight Cargo):**
   - Attempt to allocate a 10,000 kg container to a 15,000 kg cargo.
   - Assert: UI flags red *"Over Capacity"* and disables radio.
   - Assert: Backend rejects with error: *"Cargo weight exceeds container capacity"*.
3. **TC-ALLOC-03 (Successful Allocation):**
   - Operations staff selects an available container that fits cargo.
   - Assert in DB: `shipment.status == 'Container Allocated'`.
   - Assert in DB: `containers.status == 'Allocated'`.
   - Assert in DB: `container_movements` contains milestone `'Container Allocated'`.
4. **TC-ALLOC-04 (Live Tracking Update):**
   - Customer refreshes tracking page.
   - Assert: Milestone 2 is green, Container ID displays the physical container number.
```
