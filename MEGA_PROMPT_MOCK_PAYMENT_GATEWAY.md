# MEGA PROMPT: Enterprise-Grade Mock Payment Gateway (Multi-Channel & Cross-Device Mobile Simulator)

> **Purpose:** Use this Mega Prompt to instruct any AI coding assistant (Claude Code, Antigravity, Cursor, GitHub Copilot, ChatGPT) or developer to implement a full-featured, zero-cost, cross-device Mock Payment Gateway in **ANY** web application regardless of framework (Java EE/Servlets, Spring Boot, Node.js/Express, Python Django/FastAPI, PHP/Laravel, ASP.NET, etc.) and file structure.

---

```markdown
# TASK SPECIFICATION: Implementation of Multi-Channel Mock Payment Gateway with Real Phone QR Cross-Device Sync

## 1. OBJECTIVE & ARCHITECTURAL CONTEXT
You are an expert full-stack engineer and payment systems architect. Your mission is to implement a production-grade, zero-external-dependency **Mock Payment Gateway** with real-time cross-device mobile synchronization for an online checkout / booking workflow.

### The Core Problem Solved:
Most web applications integrate sandbox gateways (Razorpay, Stripe, PayPal) that require developer API keys, KYC, webhook ngrok tunnels, and fail when testing from local networks.
This Mock Gateway provides:
1. An **in-app modal checkout experience** resembling enterprise gateways (Razorpay / Stripe).
2. Four payment modes:
   - **Dynamic QR Code (UPI / Mobile Pay):** Live rendered QR code that can be scanned by a real smartphone camera on the same Wi-Fi / LAN network.
   - **Credit / Debit Card:** Form with real-time card brand detection, formatting, and mock OTP / CVV validation.
   - **NetBanking:** Bank selector with simulated bank portal redirect / approval.
   - **Instant 1-Click Demo Pay:** For lightning-fast automated QA and demo presentations.
3. **Cross-Device State Synchronization:** Scanning the QR code with a mobile phone opens a responsive, PhonePe / GPay styled authorization screen. When the user taps "Approve Payment" on their phone, the desktop browser *automatically* detects completion via polling or SSE, closes the modal, and transitions the checkout to success without manual intervention!

---

## 2. SYSTEM ARCHITECTURE & DATA FLOW

```
[Desktop Browser / Checkout Modal]
       │
       ├──► 1. POST /payment/initiate (Payload: amount, orderId, customerId, metadata)
       │         │
       │         ▼
       │    [Payment Transaction Manager (In-Memory / Redis / DB)]
       │         ├── Generates unique Txn Token (e.g. TXN-1725619283-ABCD)
       │         ├── Status: CREATED
       │         └── Stores transaction params & expiry timer (10 mins)
       │
       ├──► 2. Render Checkout Modal with Txn Token
       │         ├── Tab A: UPI QR (Displays QR pointing to: http://<LAN_IP>:<PORT>/<CONTEXT>/pay-mobile?txn=TXN-xxx)
       │         ├── Tab B: Credit/Debit Card
       │         ├── Tab C: NetBanking
       │         └── Tab D: Instant Demo Pay
       │
       ├──► 3. Background Polling Loop: GET /payment/status?txn=TXN-xxx (Every 1.5s)
       │
[Mobile Phone (Real Device on same Wi-Fi)]
       │
       ├──► 4. User scans QR code with Camera / Lens
       ├──► 5. Mobile Browser opens: GET /pay-mobile?txn=TXN-xxx
       │         └── Renders high-fidelity GPay/PhonePe styled approval screen
       ├──► 6. Mobile user taps [Approve Payment]
       │         └── POST /payment/pay-mock (txn=TXN-xxx, status=SUCCESS, method=UPI_MOBILE)
       │         └── Transaction State updated to SUCCESS in Manager
       │
[Desktop Browser]
       │
       ├──► 7. Next Poll detects status == 'SUCCESS'!
       ├──► 8. Triggers post-payment atomic order fulfillment callback / redirect
       └──► 9. Renders Order Confirmation / Live Tracking view
```

---

## 3. ADAPTABLE IMPLEMENTATION BLUEPRINT (Any Framework / Language)

### Step 1: Payment Transaction Model & State Machine
Create a model and thread-safe manager to track in-flight checkout transactions.

- **Entity Fields:**
  - `transactionId` (String): Unique alphanumeric string (e.g., `TXN-` + timestamp + random hex).
  - `amount` (Double/Decimal): Total payable amount (including taxes/fees).
  - `currency` (String): e.g., `"INR"`, `"USD"`, `"EUR"`.
  - `orderReferenceId` (String/Int): Foreign key / ID of booking, order, or cart.
  - `customerId` / `customerName` (String/Int): Associated client identity.
  - `description` (String): Order line item description.
  - `status` (Enum/String): `CREATED`, `PENDING`, `SUCCESS`, `FAILED`, `CANCELLED`, `EXPIRED`.
  - `paymentMethod` (String): `"UPI_QR"`, `"CARD"`, `"NETBANKING"`, `"DEMO_PAY"`.
  - `externalReference` (String): Simulated bank UTR / RRN (e.g., `UTR-20260906-89210`).
  - `createdAt` / `updatedAt` (Timestamp).
  - `metadata` (Map / JSON): Extra project-specific parameters (e.g., origin, destination, container type, weights).

- **State Manager Contract (`PaymentTransactionManager`):**
  - Thread-safe storage: Use `ConcurrentHashMap<String, PaymentTransaction>` (Java), `dict` with threading locks (Python), in-memory Map (Node.js), or Redis / Database table.
  - Methods:
    - `createTransaction(amount, orderId, metadata) -> PaymentTransaction`
    - `getTransaction(txnId) -> PaymentTransaction`
    - `authorizePayment(txnId, method, externalRef) -> boolean` (Atomic update to `SUCCESS`)
    - `failPayment(txnId, reason) -> boolean`
    - `cleanupExpiredTransactions()` (Transactions older than 15 minutes expire)

---

### Step 2: REST / HTTP Endpoints Specification
Implement the following controller endpoints (adapt to your routing convention):

1. **`POST /payment/initiate`**
   - **Input (JSON / Form):** `amount`, `orderId`, `customerId`, `description`, `metadata`
   - **Action:** Initializes transaction via `PaymentTransactionManager`. Resolves local machine's LAN IP (`InetAddress.getLocalHost().getHostAddress()` or system environment) so the mobile payment URL points to the accessible Wi-Fi IP (e.g., `http://192.168.1.5:8080/app/pay-mobile?txn=...`).
   - **Response (JSON):**
     ```json
     {
       "success": true,
       "transactionId": "TXN-1725619283-ABCD",
       "amount": 28910.00,
       "currency": "INR",
       "mobilePayUrl": "http://192.168.1.5:8080/app/pay-mobile?txn=TXN-1725619283-ABCD",
       "qrImageUrl": "/payment/qr?txn=TXN-1725619283-ABCD"
     }
     ```

2. **`GET /payment/qr?txn=TXN-xxxx`**
   - **Action:** Reads `txn` parameter, finds the transaction, generates a QR code image encoding `mobilePayUrl`.
   - **QR Libraries:** Use ZXing (`com.google.zxing:javase`), `qrcode` (Python/Node.js), or render an SVG / HTML canvas fallback if libraries cannot be installed.
   - **Response:** Image `image/png` streamed directly with caching disabled (`Cache-Control: no-cache`).

3. **`GET /payment/status?txn=TXN-xxxx`**
   - **Action:** Returns current transaction status. Polled by desktop modal every 1.5 seconds.
   - **Response (JSON):**
     ```json
     {
       "transactionId": "TXN-1725619283-ABCD",
       "status": "SUCCESS", // or "CREATED", "PENDING", "FAILED"
       "paymentMethod": "UPI_QR",
       "orderReferenceId": "1002"
     }
     ```

4. **`POST /payment/pay-mock`**
   - **Input:** `txnId`, `paymentMethod` (CARD/UPI/NETBANKING/DEMO), `action` (APPROVE/REJECT)
   - **Action:** Updates transaction status to `SUCCESS` or `FAILED`. Generates simulated bank reference code.
   - **Response (JSON):** `{"success": true, "status": "SUCCESS", "message": "Payment captured successfully"}`

5. **`GET /pay-mobile?txn=TXN-xxxx`**
   - **Action:** Mobile view accessed via scanned QR code.
   - **Renders:** Clean, mobile-first payment simulator view (UI details in Step 4).

---

### Step 3: Security & Session Whitelist (CRITICAL)
In web applications protected by session filters, JWT guards, or Spring Security:
- Mobile phones scanning the QR code **do NOT possess the desktop user's session cookie** or login JWT.
- **Requirement:** You MUST whitelist public access for:
  - `GET /pay-mobile*`
  - `GET /payment/qr*`
  - `POST /payment/pay-mock*`
  - `GET /payment/status*`
- Without this whitelist, the phone scanner will be redirected to the login page, breaking cross-device checkout!

---

### Step 4: UI / UX Implementation

#### A. The Desktop Checkout Modal (`payment-modal`)
Embed inside the checkout/pricing view:
- **Design Standard:** Clean enterprise card with dark mode compatibility (`[data-theme="dark"]`).
- **Sidebar Tabs:**
  1. `📱 UPI QR Code` (Default)
  2. `💳 Cards` (Debit / Credit)
  3. `🏦 NetBanking`
  4. `⚡ Instant Demo Pay`
- **Tab 1: UPI QR Content:**
  - Centered live QR code image (`<img src="/payment/qr?txn=...">`).
  - Pulsing radar badge: *"Scan with any UPI app (GPay, PhonePe, Paytm)"*.
  - Displays Wi-Fi Notice: *"Ensure your phone is connected to the same local network / Wi-Fi"*.
  - Fallback clickable link: *"Testing on same PC? Open Mobile Simulator in new tab"*.
  - Live animated countdown timer (10:00).
- **Tab 2: Card Content:**
  - 16-digit card input with auto-spacing (`4242 4242 ...`).
  - Cardholder Name, MM/YY Expiry, 3-digit CVV.
  - "Pay Now" button triggering instant simulated capture.
- **Tab 3: NetBanking Content:**
  - Radio buttons / grid for popular banks (HDFC, SBI, ICICI, Axis) + "Other Banks" dropdown.
  - "Proceed to Bank Portal" button simulating immediate authorization.
- **Tab 4: Instant Demo Pay:**
  - 1-click button with lightning icon for quick automated test execution.
- **Live Sync Polling Script:**
  ```javascript
  let pollInterval = setInterval(() => {
      fetch('/payment/status?txn=' + currentTxnId)
          .then(res => res.json())
          .then(data => {
              if (data.status === 'SUCCESS') {
                  clearInterval(pollInterval);
                  showSuccessAnimation();
                  // Dispatch fulfillment form or trigger order execution
                  executeOrderFulfillment(data);
              }
          });
  }, 1500);
  ```

#### B. The Mobile Payment Simulator (`pay-mobile.jsp` / `pay-mobile.html`)
- Mobile-optimized responsive viewport (`<meta name="viewport" content="width=device-width, initial-scale=1.0">`).
- **Styling:** Premium fintech mobile app aesthetic (Teal / Indigo / Purple gradient header).
- **Elements:**
  - Header: Verified Merchant badge, Lock icon (*"256-bit Encrypted Mock Gateway"*).
  - Bill Breakdown Card: Order ID, Merchant Name, Total Amount formatted with currency symbol.
  - Payer Options: Simulated bank accounts (e.g., *"HDFC Bank •••• 4092"*).
  - Prominent Action Buttons:
    - Green Pill Button: **"Pay ₹[Amount] (Authorize)"** -> Triggers `POST /payment/pay-mock` with status `SUCCESS`.
    - Ghost Button: **"Decline Transaction"** -> Sets status to `FAILED`.
  - On authorization success: Shows green animated checkmark with text: *"Payment Approved! Check your desktop screen."*

---

### Step 5: Atomic Post-Payment Order Fulfillment
Once payment state becomes `SUCCESS`:
1. Execute the target business booking / order insertion inside a single database transaction (`setAutoCommit(false)`):
   - Insert Order / Shipment record with status e.g. `'Paid'` or `'Booked'`.
   - Insert Billing / Invoice record marked as `'PAID'` with payment method, timestamp, and transaction token.
   - Commit database transaction.
2. Redirect desktop browser to order confirmation / live tracking view with success toast.

---

## 5. VERIFICATION CHECKLIST
When implementing, verify every item:
- [ ] Initiating payment generates a unique transaction token and returns JSON.
- [ ] QR code endpoint streams an image encoding the mobile pay LAN IP URL.
- [ ] Opening the QR URL on a smartphone connected to Wi-Fi loads the mobile simulator without requiring login.
- [ ] Tapping "Authorize" on the phone updates transaction state to `SUCCESS`.
- [ ] Desktop polling detects `SUCCESS` within 1.5 seconds, auto-closes modal, and completes the order.
- [ ] Card and Instant Demo Pay tabs work independently on desktop.
- [ ] Modals and simulator seamlessly support dark and light UI themes.
```
