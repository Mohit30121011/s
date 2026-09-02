# Stitch AI UI Megaprompts: Module 2 (Container Movement & P&L)

Below are the highly detailed, phase-by-phase "megaprompts" you can copy and paste into Stitch to generate the complete UI workflow for **Module 2**. I have broken them down page-by-page so the AI can focus on building high-quality, interconnected screens.

---

## Phase 1: Shipment Booking & Creation Page
**Goal:** Create a rich form to book new shipments (FR2.1).

**Copy & Paste this Megaprompt:**
```text
You are an expert fullstack frontend developer and creative UI engineer. Build a premium, highly aesthetic "Shipment Booking Dashboard" page.

**Visual Aesthetic:** Use modern enterprise SaaS aesthetics. I want a clean white/light-gray background with subtle glassmorphism on the cards. Use a curated, harmonious color palette (primary: deep oceanic blue, secondary: vibrant teal for actions). Use the 'Inter' font. Add subtle hover micro-animations to all inputs and buttons.

**Page Requirements:**
1. **Header:** Title "Create New Shipment" with a breadcrumb (Dashboard > Shipments > New).
2. **Main Form Structure:** Use a 2-column grid layout for the form, enclosed in a beautiful elevated card with soft shadows.
3. **Form Fields (Must include):**
   - **Customer Select:** A searchable dropdown (e.g., React Select style) to pick a Customer.
   - **Container Select:** A searchable dropdown to assign a Container ID.
   - **Route Configuration:** Two side-by-side dropdowns for "Origin Port (Point A)" and "Destination Port (Point B)". Add a subtle connecting arrow icon between them.
   - **Vessel Select:** Dropdown to pick the assigned Vessel.
   - **Dates:** Date pickers for "Booking Date" and "Expected Arrival Date".
4. **Action Area:** A sticky footer or bottom section with a "Cancel" button (ghost style) and a prominent "Confirm & Book Shipment" button (solid primary color with a loading spinner state).
5. **No Placeholders:** Do not use `lorem ipsum`. Use realistic dummy data like "Shanghai Port", "Ocean Giant Vessel", "Global Freight Ltd".
```

---

## Phase 2: Shipment Tracking & Checkpoint Dashboard
**Goal:** A visual timeline to track the status of a specific container and update checkpoints (FR2.2, FR2.3, FR2.4, FR2.5).

**Copy & Paste this Megaprompt:**
```text
You are an expert UI engineer. Build a premium "Live Shipment Tracking" page for a logistics application. 

**Visual Aesthetic:** Dark mode preferred for this page to make the tracking elements pop, or a very sleek light mode with high-contrast elements. Use smooth CSS keyframes or Framer Motion for the progress animations. 

**Page Requirements:**
1. **Shipment Header:** Display "Shipment #SHP-90210" at the top. Below it, show a bold warning pill in red if the shipment is delayed: "⚠️ Delayed by 4 Days" (Expected vs Actual Arrival).
2. **Visual Route Tracker (FR2.4):** A beautiful horizontal stepper/timeline spanning the screen.
   - Nodes: Booked → Container Allocated → Departed → In Transit → Customs Hold → Arrived → Delivered.
   - Visuals: The completed nodes should be solid vibrant green with checkmarks. The current node should pulse or glow. Future nodes should be greyed out. 
3. **Checkpoint Update Panel:** A card below the tracker for staff to update the status. 
   - A dropdown to select the "Next Status".
   - A text area for "Status Remarks".
   - A "Record Checkpoint" button. 
4. **Audit Log Table (FR2.3):** A sleek table at the bottom showing the history of status changes. Columns: Status, Timestamp, Recorded By (Staff Name), Remarks.
```

---

## Phase 3: Profit & Loss Graph (PLG) Dashboard
**Goal:** A data-heavy analytics dashboard showing financial health and loss reasons (FR2.6, FR2.7, FR2.8).

**Copy & Paste this Megaprompt:**
```text
You are a senior data visualization UI developer. Build a "Profit & Loss Analytics Dashboard" for an enterprise logistics app.

**Visual Aesthetic:** Extremely premium financial dashboard. Use Recharts, Chart.js, or beautiful custom SVG charts. Use a dark, sleek theme with vibrant neon accents (green for profit, red for loss, purple/blue for neutral metrics). 

**Page Requirements:**
1. **Top KPI Cards (Glassmorphism style):**
   - Total Revenue (Freight + Service Charges)
   - Total Cost (Fuel, Port, Customs, Penalties)
   - Net Profit/Loss (Color coded green/red)
2. **Main PLG Time-Series Chart (FR2.8):** A large, interactive Area or Line chart showing Profit/Loss trends over time. Include a toggle at the top right to switch between "Monthly", "Quarterly", and "Yearly". 
3. **Loss Reason Breakdown (FR2.8):** A beautiful Donut Chart to the right of the main chart. Show the breakdown of standard Loss Reasons: "Traffic in Sea", "Weather", "Delay", "Dock Allocation", "Regulatory Hold", "War/Disruption", "Ship Issue", "Damaged Product".
4. **Filter Bar:** A sleek horizontal bar above the charts to filter by "Company", "Route (Origin-Destination)", and "Date Range".
5. **Interactivity:** Clicking on any bar/point in the charts should look like it triggers a drill-down (show a hover tooltip saying "Click to view underlying shipments").
```

---

## Phase 4: Loss-Making Shipment Drill-Down & Tagging
**Goal:** The view when clicking a data point in Phase 3, allowing users to tag specific loss reasons to a shipment (FR2.7, FR2.9).

**Copy & Paste this Megaprompt:**
```text
You are an expert UI engineer. Build a "Shipment Financial Drill-Down" modal or page.

**Visual Aesthetic:** Clean, highly structured data presentation. Use a split-screen or 2-column layout. 

**Page Requirements:**
1. **Financial Breakdown Column (Left):** 
   - Display a mini-invoice style breakdown: Revenue side (Freight, Services) vs Cost side (Fuel, Port, Claims).
   - Show a massive red number at the bottom: "NET LOSS: -$4,500".
2. **Loss Reason Tagging Column (Right) (FR2.7):**
   - A title "Assign Loss Reasons".
   - A grid of modern, clickable "Tags" representing standard reasons (Weather, Delay, Port Strike, etc.). When clicked, they should turn solid red to indicate they are active.
   - A multiselect dropdown for "Add Custom Reason".
   - A "Save Financial Audit" button at the bottom.
3. **Shipment Context:** A small mini-map or route summary at the very top so the user remembers which shipment they are auditing. 
```
