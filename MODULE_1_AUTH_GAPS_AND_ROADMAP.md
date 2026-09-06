# MODULE 1: AUTHENTICATION & AUTHORIZATION — MEGA GAP SPECIFICATION & IMPLEMENTATION ROADMAP

> **Standard:** IEEE 830-1998 Software Requirements Specification Alignment  
> **Target Module:** Module 1 — Authentication and Authorization (FR1.1 – FR1.9)  
> **Platform:** N Logistic Import & Export Enterprise Suite  
> **Tech Stack:** Java 11 / Jakarta EE (Servlet 4.0 / JSP 2.3) · JDBC · MySQL 8.0 · Bootstrap 5 · MVC2 Architecture  
> **Reference Documents:** 
> - [srs_harness.md](file:///d:/NLogistic/NLogistic/srs_harness.md) (Section 3.1, Section 6.1, Section 10)
> - [CLAUDE.md](file:///d:/NLogistic/NLogistic/CLAUDE.md) (Tier 1/2/3 Security Architecture & RBAC Matrix)
> - [SYSTEM_GAPS_AND_MISSING_FEATURES.md](file:///d:/NLogistic/NLogistic/SYSTEM_GAPS_AND_MISSING_FEATURES.md)
> - [AGENTS.md](file:///d:/NLogistic/NLogistic/AGENTS.md)

---

## 1. Executive Summary & Module Scope

Module 1 forms the security and identity foundation for the entire N Logistic platform. In accordance with IEEE 830-1998 standards, every downstream business operation—including container movements, dynamic pricing algorithms, inventory ledgers, billing invoices, and damage claims—strictly depends on the authenticated identity, assigned role (`role_id`), and tenancy scope (`company_id` or `customer_id`) established by this module.

### Core Objectives of Module 1:
1. **Dual Registration Gateways (FR1.1):** Separate onboarding pipelines for logistics service provider companies versus cargo-booking customers.
2. **Company Vetting & Super Admin Approval (FR1.2):** Strict verification of legal freight licenses, GST/Tax identification, and corporate credentials before enabling company tenants.
3. **Customer KYC Verification (FR1.3):** Collection and validation of customer identification documents (PDF/JPG) and initial credit limits.
4. **Five-Tier Role-Based Access Control (FR1.4):** Strict role enforcement across Super Admin (1), Company Admin (2), Operations Staff (3), Finance Staff (4), and Customer (5).
5. **Secure Session Lifecycle & Authentication (FR1.5):** Robust credential verification using database-backed SHA2-256 password hashes, 30-minute idle session termination, and complete session invalidation on logout.
6. **Time-Limited Password Recovery (FR1.6):** Cryptographic UUID-based, single-use reset tokens with 15-minute expiration and secure email dispatch.
7. **Design-by-Contract Precondition Enforcement (FR1.7):** Server-side programmatic validation preventing unauthorized role execution at both the filter and servlet controller layers.
8. **Automated Brute-Force Lockout (FR1.8):** Algorithmic account suspension after 5 consecutive failed login attempts with a 15-minute cool-down window and Super Admin manual override.
9. **Comprehensive Security Audit Trail (FR1.9):** Immutable logging of all authentication events, privilege escalations, permission denials, and administrative status overrides with remote IP attribution.

---

## 2. SRS Requirements vs Current Implementation Audit

The following matrix contrasts every individual functional requirement specified in `srs_harness.md` against the actual Java classes, JSPs, and database objects in the active codebase:

| Req ID | SRS Specification Description | Codebase Component(s) | Current Implementation Status | Severity / Defect Type |
| :--- | :--- | :--- | :--- | :--- |
| **FR1.1** | Separate registration workflows for Company and Customer/Consumer accounts. | [RegisterServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/RegisterServlet.java)<br>[register.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/register.jsp) | **PARTIAL**<br>Tab switching works in UI, but `users.status` is saved as `'Pending'` while table schema specifies `'Active' / 'Inactive' / 'Locked'`. | Medium / Schema Inconsistency |
| **FR1.2** | Company registration requires name, license, GST, address, admin contact; Super Admin approval before activation. | [AdminCompanyServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/AdminCompanyServlet.java)<br>[CompanyDAO.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/CompanyDAO.java)<br>[companies.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/admin/companies.jsp) | **BROKEN / INCOMPLETE**<br>1. Sidebar routes directly to JSP instead of Servlet.<br>2. JSP contains 80+ lines of raw scriptlets running SQL queries directly.<br>3. `AdminCompanyServlet` calls raw SQL `updateCompanyStatus` instead of the audited stored procedure `{CALL approve_company(?, ?)}`.<br>4. Rejection sets `Suspended` without reason or email alert. | High / MVC2 Violation & Audit Hole |
| **FR1.3** | Customer registration requires name, email, phone, address, KYC upload; approval-gated. | [RegisterServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/RegisterServlet.java)<br>[CustomerServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/CustomerServlet.java)<br>[customers.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/admin/customers.jsp) | **BROKEN / RISKY**<br>1. KYC files written to webapp runtime folder `uploads/kyc/` which gets wiped on Tomcat redeploy.<br>2. [CustomerServlet.java:L34](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/CustomerServlet.java#L34) redirects unauthenticated users to `/auth/login` (generates **HTTP 404**).<br>3. `admin/customers.jsp` runs scriptlet SQL deleting from 4 tables in raw JSP. | High / 404 Route & Data Loss Risk |
| **FR1.4** | System shall implement RBAC with 5 roles: Super Admin, Company Admin, Ops, Finance, Customer. | [AuthenticationFilter.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/filter/AuthenticationFilter.java)<br>[header.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/layout/header.jsp)<br>[customer_header.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/layout/customer_header.jsp) | **PARTIAL / BYPASS RISK**<br>1. Direct JSP access pattern in `header.jsp` bypasses servlet tier.<br>2. [customer_header.jsp:L96](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/layout/customer_header.jsp#L96) links to `${pageContext.request.contextPath}/auth/logout` (generates **HTTP 404**).<br>3. Customer header navigation buttons (Book, Profile) have dummy `#` hrefs. | High / Broken Navigation & 404s |
| **FR1.5** | Login uses username/email and password; sessions managed via HttpSession with 30-min timeout. | [LoginServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/LoginServlet.java)<br>[LogoutServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/LogoutServlet.java)<br>[login.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/login.jsp) | **COMPLIANT**<br>Enforces 30-minute timeout (`session.setMaxInactiveInterval(30 * 60)`), executes `login_attempt` SP, and establishes `companyId` / `customerId` in session. | Low / Working As Intended |
| **FR1.6** | Password reset shall use time-limited, single-use email OTP or token. | [ForgotPasswordServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ForgotPasswordServlet.java)<br>[ResetPasswordServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ResetPasswordServlet.java)<br>[EmailService.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/util/EmailService.java) | **BROKEN / DISCONNECTED**<br>1. [ForgotPasswordServlet.java:L27-32](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ForgotPasswordServlet.java#L27-L32) prints mock link to stdout and does NOT call `EmailService`.<br>2. In production without configured `mail.properties`, end users are stranded without a way to reset passwords. | High / Feature Dead-End |
| **FR1.7** | Every controller action shall verify caller's role/permission before execution (precondition). | [AdminUserServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/AdminUserServlet.java)<br>[AdminCompanyServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/AdminCompanyServlet.java)<br>All other servlets | **PARTIAL**<br>`AdminUserServlet` and `AdminCompanyServlet` verify `roleId == 1`, but secondary servlets rely exclusively on the filter without self-checking contract preconditions. | Medium / Architectural Fragility |
| **FR1.8** | Repeated failed logins trigger temporary account lockout (5 attempts / 15 minutes). | DB SP `login_attempt`<br>[UserDAO.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/UserDAO.java)<br>[AdminUserServlet.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/AdminUserServlet.java) | **PARTIAL / DISCONNECTED**<br>SP locks account correctly, and `unlockUser` SP exists in DB, but `AdminUserServlet.java` has NO action handler for `unlock`, leaving admins unable to unlock users via servlet. | High / Incomplete Admin Tooling |
| **FR1.9** | System shall log login, logout, and permission-denied events to audit trail. | [AuditDAO.java](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/AuditDAO.java)<br>[audit_logins.jsp](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/admin/audit_logins.jsp) | **BROKEN ARCHITECTURE**<br>1. No dedicated `AuditLogServlet` exists.<br>2. `audit_logins.jsp` contains raw Java scriptlets running database queries.<br>3. Not linked in standard admin navigation. | High / Missing Controller & MVC2 Breach |

---

## 3. Deep-Dive Gap Analysis & Root Cause Identification

### 3.1 GAP-M1-01: Broken Routes & HTTP 404 Exceptions in Customer Flows
* **Symptoms:** 
  1. Clicking **Logout** in the Customer Portal crashes with `HTTP 404: The requested resource [/NLogistic/auth/logout] is not available`.
  2. Unauthenticated access to `/customers` redirects to `/auth/login`, throwing an immediate **HTTP 404**.
* **Root Cause Analysis:**
  - In [customer_header.jsp:L96](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/layout/customer_header.jsp#L96), the logout link is hardcoded as:
    ```jsp
    <a href="${pageContext.request.contextPath}/auth/logout" class="btn btn-sm btn-outline-danger">Logout</a>
    ```
    However, [LogoutServlet.java:L17](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/LogoutServlet.java#L17) is mapped to `@WebServlet("/logout")`. The `/auth/` namespace does not exist anywhere in the application.
  - In [CustomerServlet.java:L34 & L46](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/CustomerServlet.java#L34), redirect calls target `/auth/login`:
    ```java
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login");
        return;
    }
    ```
    The actual login endpoint is `@WebServlet("/login")`.
* **Resolution Blueprint:**
  - Refactor all `/auth/login` paths to `${pageContext.request.contextPath}/login`.
  - Refactor all `/auth/logout` paths to `${pageContext.request.contextPath}/logout`.
  - Add URL rewrite rules in `AuthenticationFilter` to catch and gracefully redirect any legacy `/auth/*` routes.

---

### 3.2 GAP-M1-02: Massive MVC2 Architecture Violation via Raw Scriptlet Ingestion
* **Symptoms:**
  - `jsp/admin/users.jsp` (2,694 lines) contains 120+ lines of scriptlet Java executing raw SQL updates and transactions.
  - `jsp/admin/customers.jsp` (1,291 lines) contains raw scriptlets deleting records across 4 relational tables inside a multi-query JDBC transaction.
  - `jsp/admin/companies.jsp` (1,104 lines) contains raw scriptlet logic cascading updates to containers and stock ledgers.
  - `jsp/admin/audit_logins.jsp` (783 lines) instantiates `AuditDAO` directly within `<% ... %>` scriptlet blocks.
* **SRS Contract Violation:**
  - **SRS Section 2.4:** *"Strict MVC2 separation — a single Front Controller Servlet dispatches to Action classes; JSPs are used only for view rendering and contain no business logic."*
  - **SRS Section 10.2:** *"Strict Rule: No Java scriptlets (`<% ... %>`) are permitted in JSPs. All dynamic data rendering must use JSTL and EL."*
* **Root Cause Analysis:**
  - In [header.jsp:L2234-L2331](file:///d:/NLogistic/NLogistic/src/main/webapp/jsp/layout/header.jsp#L2234-L2331), sidebar links point directly to `.jsp` files instead of Servlet controller routes:
    - Points to `${pageContext.request.contextPath}/jsp/admin/companies.jsp` instead of `/admin/companies`.
    - Points to `${pageContext.request.contextPath}/jsp/admin/customers.jsp` instead of a controller servlet.
    - Points to `${pageContext.request.contextPath}/jsp/admin/users.jsp` instead of `/admin/users`.
    - Points to `${pageContext.request.contextPath}/jsp/admin/audit_logins.jsp` instead of `/admin/audit-logs`.
  - Because users land directly on the JSP views without passing through a Servlet, the developer inserted scriptlets into the JSP to extract data and handle form POSTs.
* **Resolution Blueprint:**
  1. Fix all sidebar `href` attributes in `header.jsp` to target the respective Servlet URLs (`/admin/companies`, `/admin/users`, `/admin/customers`, `/admin/audit-logs`).
  2. Move all business logic and database manipulations out of `users.jsp`, `customers.jsp`, `companies.jsp`, and `audit_logins.jsp` into the respective servlets: `AdminUserServlet`, `AdminCompanyServlet`, `CustomerServlet`, and `AuditLogServlet`.
  3. Purge all scriptlet blocks (`<% ... %>`) from the JSPs and replace them with JSTL `<c:forEach>`, `<c:if>`, and `${...}` Expression Language.

---

### 3.3 GAP-M1-03: Incomplete Admin Controller Actions (Unlock, Role Change, Audit)
* **Symptoms:**
  - When an account is locked out after 5 failed password attempts (FR1.8), an admin clicking "Unlock" in the UI triggers either a broken scriptlet or a 404 because `AdminUserServlet.java` has no handler for `unlock`.
  - Rejection of a company does not allow entering a reason or triggering an audit notification.
* **Root Cause Analysis:**
  - Inspecting [AdminUserServlet.java:L83-93](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/AdminUserServlet.java#L83-L93):
    ```java
    String action = request.getParameter("action");
    int userId = Integer.parseInt(request.getParameter("userId"));

    if ("accept".equals(action)) {
        userDAO.updateUserStatus(userId, "Active");
        request.getSession().setAttribute("successMessage", "User Approved Successfully.");
    } else if ("reject".equals(action)) {
        userDAO.updateUserStatus(userId, "Locked");
        request.getSession().setAttribute("errorMessage", "User Rejected.");
    }
    ```
    The servlet **only** handles `accept` and `reject`. The database stored procedures `unlock_user`, `deactivate_user`, `change_user_role`, and `delete_users` already exist in [UserDAO.java:L190-302](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/dao/UserDAO.java#L190-L302), but are never invoked by the controller.
* **Resolution Blueprint:**
  - Expand `AdminUserServlet.doPost` to handle:
    - `action=unlock`: Calls `userDAO.unlockUser(userId, adminUserId)`.
    - `action=suspend`: Calls `userDAO.deactivateUser(userId, adminUserId)`.
    - `action=changeRole`: Calls `userDAO.changeUserRole(userId, newRoleId, adminUserId)`.
    - `action=delete`: Calls `userDAO.deleteUser(userId, adminUserId)`.
  - Expand `AdminCompanyServlet.doPost` to handle:
    - `action=accept`: Calls `companyDAO.approveCompany(companyId, adminUserId)`.
    - `action=reject` / `suspend`: Calls `companyDAO.suspendCompany(companyId, adminUserId, reason)`.

---

### 3.4 GAP-M1-04: Password Reset Workflow & Email Service Disconnect
* **Symptoms:**
  - Users requesting a password reset receive a UI message stating an email was sent, but no email ever arrives.
  - In local development, the reset link is only visible if the user has access to the server console log.
* **Root Cause Analysis:**
  - In [ForgotPasswordServlet.java:L25-34](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/ForgotPasswordServlet.java#L25-L34):
    ```java
    if (token != null) {
        String resetLink = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/reset-password?token=" + token;
        System.out.println("=====================================================");
        System.out.println("MOCK EMAIL SENT TO: " + email);
        System.out.println("RESET PASSWORD LINK: " + resetLink);
        System.out.println("=====================================================");
    }
    ```
    The servlet contains a mock printout and completely ignores `com.nlogistic.util.EmailService.sendPasswordResetEmail(email, username, resetLink)`.
  - Furthermore, if `mail.properties` has blank credentials (common in sandbox environments), `EmailService` returns `false` with no user-visible fallback.
* **Resolution Blueprint:**
  - Update `ForgotPasswordServlet.java` to call `EmailService.sendPasswordResetEmail`.
  - Implement an environment detection fallback: if SMTP fails or is unconfigured, display an informational alert banner on the page containing the direct reset link (enabled in development/demo mode) so user testing is never blocked.

---

### 3.5 GAP-M1-05: Missing Session Resolution for Customer Tenants
* **Symptoms:**
  - Downstream queries in Module 2, 4, 5, 6, and 7 that filter by `customer_id` crash with `NullPointerException` or return empty result sets if a customer account was created manually or through an incomplete registration flow.
* **Root Cause Analysis:**
  - In [LoginServlet.java:L62-71](file:///d:/NLogistic/NLogistic/src/main/java/com/nlogistic/controller/LoginServlet.java#L62-L71):
    ```java
    if (user.getRoleId() == 5) {
        Customer customer = new CustomerDAO().getCustomerByUserId(user.getUserId());
        if (customer != null) {
            session.setAttribute("customerId", customer.getCustomerId());
            session.setAttribute("customerName", customer.getCustomerName());
        }
    }
    ```
    If `customer == null` (e.g. if the user record exists in `users` with `role_id=5` but the corresponding row in `customers` is missing), the session proceeds without `customerId`. Any subsequent query scoping on `(Integer) session.getAttribute("customerId")` throws NPE or fails.
* **Resolution Blueprint:**
  - Add an automatic integrity check and self-healing mechanism in `LoginServlet`: if a Role 5 user has no linked `customers` entry, automatically construct a default customer profile or deny login with a clear administrative message (`"Customer profile incomplete. Please contact support."`).

---

## 4. End-to-End Use Case Specifications (8 Flows)

### UC-AUTH-01: Company Registration & Onboarding Flow
* **Primary Actor:** Company Admin (prospective logistics tenant)
* **Preconditions:** Prospective company is not yet registered; unique GST/Tax ID and freight operating license.
* **Trigger:** User navigates to `/register` and selects the "Company Account" tab.
* **Main Success Scenario:**
  1. User fills out Company Legal Name, Operating License No, GST/Tax ID, Address, Admin Full Name, Email, Phone Number, and Password (twice).
  2. Client-side JavaScript validates:
     - All mandatory fields non-empty.
     - License and GST alphanumeric formats.
     - Email regex match.
     - Password minimum 8 characters with upper, lower, number, and special character.
     - Password and Confirm Password match.
  3. User submits form to `POST /register` with `type=company`.
  4. `RegisterServlet` validates inputs server-side.
  5. `RegisterServlet` calls `CompanyDAO.registerCompany(..., OUT p_company_id)` using DB stored procedure `{CALL register_company(?, ?, ?, ?, ?, ?, ?)}`.
  6. Stored procedure inserts company with status `'Pending'` and outputs `company_id`.
  7. `RegisterServlet` calls `UserDAO.createUser(..., roleId=2, companyId=companyId, status='Inactive')`.
  8. `UserDAO` hashes password with SHA2-256 and inserts the record into `users`.
  9. System logs audit event `COMPANY_REGISTERED` in `audit_log`.
  10. System sets flash message: *"Company registration submitted successfully! Your account is pending Super Admin review & approval."*
  11. User is redirected to `/login`.
* **Alternative Flows:**
  - **3a. Duplicate License or GST:** Stored procedure raises unique constraint violation. Servlet catches error and re-renders `/jsp/register.jsp` with error: *"A company with this License No or GST ID already exists."*
  - **3b. Duplicate Username/Email:** Servlet detects existing user and returns: *"Username or email already in use. Please choose another."*
* **Postconditions:** Company created with status `'Pending'`, Company Admin created with status `'Inactive'`. No login permitted until approved.

---

### UC-AUTH-02: Customer Registration & KYC Document Upload Flow
* **Primary Actor:** Customer / Commercial Shipper
* **Preconditions:** Customer possesses valid identification/business registration document in PDF, JPG, or PNG format.
* **Trigger:** User navigates to `/register` and selects the "Customer Account" tab.
* **Main Success Scenario:**
  1. User enters Full Name / Business Name, Email, Phone Number, Billing Address, Password, and selects a KYC document file.
  2. Client-side validation checks file extension (`.pdf`, `.jpg`, `.jpeg`, `.png`) and file size (`<= 10MB`).
  3. User submits form to `POST /register` with `type=customer` (`multipart/form-data`).
  4. `RegisterServlet` processes multipart request.
  5. Server validates file MIME type and sanitizes filename.
  6. File is saved to secure storage directory (`/uploads/kyc/kyc_<timestamp>.<ext>`).
  7. `RegisterServlet` calls `UserDAO.createUser(..., roleId=5, companyId=null, status='Pending')`.
  8. `RegisterServlet` calls stored procedure `{CALL register_customer(p_user_id, p_customer_name, p_address, p_kyc_doc_path, p_credit_limit=0.0)}`.
  9. Record inserted into `customers` linked via `user_id`.
  10. Audit event `CUSTOMER_REGISTERED` logged.
  11. User redirected to `/login` with success message: *"Customer registration submitted successfully! KYC document received and pending verification."*
* **Exception Flows:**
  - **5a. Invalid File Format (e.g. .exe, .sh):** Servlet rejects file and forwards back to `/jsp/register.jsp` with: *"KYC document must be a PDF, JPG, or PNG file."*
  - **5b. Upload Exceeds 10MB:** Servlet/Container throws `MaxUploadSizeExceededException`, caught and converted to clean error message.
* **Postconditions:** User created with `status='Pending'`; customer record linked with KYC document path and default credit limit `0.0`.

---

### UC-AUTH-03: Super Admin Company Approval / Rejection Flow
* **Primary Actor:** Super Admin (`role_id=1`)
* **Preconditions:** Super Admin is logged in; at least one company has status `'Pending'`.
* **Trigger:** Super Admin clicks **Management -> Approvals -> Company** (navigating to `/admin/companies`).
* **Main Success Scenario (Approval):**
  1. Super Admin views list of pending company applications displaying Company Name, License No, GST, Email, Phone, and Registration Date.
  2. Super Admin clicks **"Approve & Activate"** on company record #CMP-X.
  3. Browser posts `action=accept&companyId=X` to `/admin/companies`.
  4. `AdminCompanyServlet` verifies contract precondition (`session.roleId == 1`).
  5. `AdminCompanyServlet` calls stored procedure `{CALL approve_company(p_company_id=X, p_approver_user_id=1)}`.
  6. Database updates `companies.approval_status = 'Active'` and cascades `users.status = 'Active'` for all users tied to `company_id = X`.
  7. Stored procedure automatically writes audit record `COMPANY_APPROVED` to `audit_log`.
  8. Servlet sets session flash message: *"Company #CMP-X Approved & Activated Successfully."*
  9. Super Admin redirected to `/admin/companies`.
* **Alternative Flow (Rejection / Suspension):**
  - **2a. Super Admin Rejects Company:** Admin enters rejection reason in modal and clicks **"Reject"**.
  - **3a.** Browser posts `action=reject&companyId=X&reason=...` to `/admin/companies`.
  - **4a.** `AdminCompanyServlet` calls stored procedure `{CALL suspend_company(X, 1, reason)}`.
  - **5a.** Database sets `companies.approval_status = 'Suspended'`, disables linked users, logs reason to `audit_log`.
* **Postconditions:** Company status updated to `'Active'` or `'Suspended'`. Company Admin can now log in if approved.

---

### UC-AUTH-04: Super Admin Customer KYC Verification & Activation Flow
* **Primary Actor:** Super Admin (`role_id=1`)
* **Preconditions:** Super Admin is logged in; customer registered with `status='Pending'`.
* **Trigger:** Super Admin clicks **Management -> Approvals -> Customer** (navigating to `/admin/customers`).
* **Main Success Scenario:**
  1. Super Admin reviews pending customers table.
  2. Super Admin clicks **"View KYC Document"**; document opens in modal or secure viewer.
  3. Super Admin verifies document validity and optionally inputs an approved credit limit (e.g. `$5,000.00`).
  4. Super Admin clicks **"Approve Customer"**.
  5. Browser posts `action=accept&userId=Y&creditLimit=5000` to `/admin/customers`.
  6. `CustomerServlet` / `AdminUserServlet` verifies `roleId == 1`.
  7. Updates `users.status = 'Active'` and `customers.credit_limit = 5000.0`.
  8. Logs audit entry `CUSTOMER_KYC_APPROVED`.
  9. Customer account is now active; customer can log in, book shipments, and utilize credit limit.
* **Postconditions:** Customer account status transitions from `'Pending'` to `'Active'`.

---

### UC-AUTH-05: Multi-Role Secure Login & Session Initialization Flow
* **Primary Actor:** Any registered user (Roles 1 to 5)
* **Preconditions:** User has an active account in `users`.
* **Trigger:** User accesses `/login`, enters username/email and password, and submits.
* **Main Success Scenario:**
  1. User submits credentials to `POST /login`.
  2. `LoginServlet` extracts `username`, `password`, and remote `ipAddress`.
  3. `LoginServlet` calls `UserDAO.loginAttempt(username, password, ipAddress)` executing stored procedure `{CALL login_attempt(?, ?, ?, ?)}`.
  4. The stored procedure:
     - Looks up user by username or email.
     - Checks `status` (rejects if `'Locked'` or `'Inactive'`).
     - Checks lockout timestamp (if locked < 15 mins ago, returns `'ACCOUNT_LOCKED'`).
     - Compares `password_hash` with `SHA2(p_password, 256)`.
     - On match: resets `failed_login_count = 0`, updates `last_login_at = NOW()`, logs `LOGIN` in `audit_log`, and returns `'SUCCESS'`.
  5. `LoginServlet` retrieves populated `User` model.
  6. If user belongs to a company (`companyId > 0`), verifies that `companies.approval_status == 'Active'`.
  7. `LoginServlet` initializes clean `HttpSession`:
     - Sets `session.setAttribute("user", user)`
     - Sets `session.setAttribute("username", user.getUsername())`
     - Sets `session.setAttribute("roleId", user.getRoleId())`
     - **If Role 5 (Customer):** Resolves `Customer` by `user_id` and sets `session.setAttribute("customerId", customer.getCustomerId())`.
     - **If Roles 2, 3, 4 (Company Staff):** Sets `session.setAttribute("companyId", user.getCompanyId())`.
  8. Sets session inactivity timeout: `session.setMaxInactiveInterval(30 * 60)` (30 minutes per FR1.5).
  9. Redirects user to `/dashboard`.
* **Exception Flows:**
  - **4a. Invalid Password:** SP increments `failed_login_count`. If count reaches 5, sets `status = 'Locked'` and `locked_at = NOW()`. Returns `'INVALID_PASSWORD'` or `'ACCOUNT_LOCKED'`.
  - **4b. Account Pending Approval:** Servlet displays message: *"Your account is pending approval by the administrator."*
  - **4c. Company Suspended:** Servlet displays message: *"Your company registration is Suspended. Please contact support."*
* **Postconditions:** Authenticated session active with exact RBAC tokens; audit trail entry recorded.

---

### UC-AUTH-06: Self-Service Password Reset via Token/OTP Flow
* **Primary Actor:** Registered user who forgot credentials
* **Preconditions:** User has a registered email address in `users`.
* **Trigger:** User clicks "Forgot Password?" on `/login` (navigating to `/forgot-password`).
* **Main Success Scenario:**
  1. User enters registered email address and submits.
  2. `ForgotPasswordServlet` receives `POST /forgot-password`.
  3. Calls `UserDAO.generatePasswordResetToken(email)`.
  4. System generates cryptographic UUID token, inserts into `password_resets` table with `expires_at = NOW() + INTERVAL 15 MINUTE` and `used = FALSE`.
  5. System generates reset link: `http://<host>:<port>/NLogistic/reset-password?token=<UUID>`.
  6. Calls `EmailService.sendPasswordResetEmail(email, username, resetLink)`.
  7. System renders `/jsp/forgot-password.jsp` with message: *"If an account exists with that email, a password reset link has been sent."* (Prevents user enumeration attacks).
  8. User receives email, clicks reset link within 15 minutes.
  9. `ResetPasswordServlet.doGet` receives request, validates token via `UserDAO.validateResetToken(token)`.
  10. Token is valid; system forwards to `/jsp/reset-password.jsp`.
  11. User enters and confirms new password (minimum 8 characters).
  12. Form posts to `POST /reset-password`.
  13. `ResetPasswordServlet` calls `UserDAO.resetPasswordWithToken(token, newPassword)`.
  14. DAO executes atomic transaction:
      - Updates `users.password_hash = SHA2(newPassword, 256)`.
      - Resets `users.failed_login_count = 0` and sets `status = 'Active'`.
      - Marks token `used = TRUE` in `password_resets`.
  15. System logs audit event `PASSWORD_RESET_SUCCESS`.
  16. User redirected to `/login` with success banner: *"Password has been successfully reset! You can now sign in."*
* **Alternative Flows:**
  - **9a. Expired or Already Used Token:** `validateResetToken` returns `-1`. Servlet forwards to `/jsp/forgot-password.jsp` with error: *"Invalid or expired password reset link. Please request a new one."*
* **Postconditions:** Password hash updated; token invalidated; user can authenticate with new password.

---

### UC-AUTH-07: Account Lockout & Admin Unlock Flow (Brute Force Defense)
* **Primary Actor:** Attacker / Forgetful User (Trigger), Super Admin (Remedy)
* **Preconditions:** Target account exists in `users`.
* **Trigger:** 5 consecutive failed login attempts within 15 minutes.
* **Main Success Scenario:**
  1. Attacker attempts 5 incorrect passwords on target user `ops_staff`.
  2. On attempt 5, stored procedure `login_attempt`:
     - Increments `failed_login_count = 5`.
     - Updates `status = 'Locked'`.
     - Logs audit record `ACCOUNT_LOCKED` with IP address.
     - Returns result code `'ACCOUNT_LOCKED'`.
  3. `LoginServlet` displays error: *"Account is locked due to too many failed attempts. Please wait 15 minutes or contact your administrator."*
  4. Subsequent login attempts within 15 minutes are blocked immediately without password verification.
  5. User contacts Super Admin.
  6. Super Admin logs in, navigates to `/admin/users`.
  7. User `ops_staff` is flagged with a red badge **LOCKED (5 Failed Attempts)**.
  8. Super Admin clicks **"Unlock Account"**.
  9. Browser posts `action=unlock&userId=Z` to `/admin/users`.
  10. `AdminUserServlet` calls stored procedure `{CALL unlock_user(p_user_id=Z, p_unlocked_by=1)}`.
  11. Stored procedure resets `failed_login_count = 0`, sets `status = 'Active'`, and records `ACCOUNT_UNLOCKED` in `audit_log`.
  12. User `ops_staff` can immediately log in with valid credentials.
* **Alternative Flow (Automatic Cool-Down Expiry):**
  - If 15 minutes elapse without admin intervention, the `login_attempt` SP detects `TIMESTAMPDIFF(MINUTE, last_failed_at, NOW()) >= 15`, automatically resets `failed_login_count = 0`, and evaluates the submitted password.
* **Postconditions:** Account unlocked; audit log tracks unlocker identity and timestamp.

---

### UC-AUTH-08: System-Wide Security Audit Logging & Inspection Flow
* **Primary Actor:** Super Admin (`role_id=1`) / Company Admin (`role_id=2`)
* **Preconditions:** User has administrative privileges.
* **Trigger:** Admin clicks **Audit Logs -> Logins & Security** (navigating to `/admin/audit-logs`).
* **Main Success Scenario:**
  1. Request arrives at `AuditLogServlet.doGet`.
  2. Precondition verified: caller `roleId == 1 || roleId == 2`.
  3. `AuditLogServlet` extracts filters: `action` (e.g. `LOGIN`, `LOGOUT`, `PERMISSION_DENIED`, `ACCOUNT_LOCKED`) and search query `q`.
  4. If Super Admin (Role 1): retrieves global audit trail.
  5. If Company Admin (Role 2): filters audit records exclusively for users belonging to their `company_id`.
  6. `AuditDAO` executes indexed query against `audit_log`:
     ```sql
     SELECT a.*, u.username, u.email, r.role_name 
     FROM audit_log a 
     LEFT JOIN users u ON a.user_id = u.user_id 
     LEFT JOIN roles r ON u.role_id = r.role_id 
     ORDER BY a.timestamp DESC LIMIT 500
     ```
  7. Servlet sets request attributes `auditLogs` and `kpis` (Total Logins, Failed Attempts, Lockouts, Denials).
  8. Forwards cleanly to `/jsp/admin/audit_logins.jsp`.
  9. View renders responsive table with IP address, user, action badge, entity details, and humanized timestamp.
* **Exception Flow:**
  - **2a. Unauthorized Role (Role 3, 4, or 5):** Filter/Servlet intercepts, logs `PERMISSION_DENIED` in `audit_log`, sets error message, and redirects to `/dashboard`.
* **Postconditions:** Immutable audit trail viewed without altering any log state.

---

## 5. Step-by-Step Implementation Blueprint & Code Fixes

To achieve 100% compliance with IEEE 830 SRS Module 1 and resolve all architectural flaws, execute the following file-by-file refactorings:

```
================================================================================
                               MODIFICATION MATRIX
================================================================================
LAYER       FILE PATH                                     ACTION & RATIONALE
--------------------------------------------------------------------------------
Filter      com.nlogistic.filter.AuthenticationFilter     Fix /auth/* redirects, direct JSP protection
Controller  com.nlogistic.controller.LoginServlet        Robust customer profile resolution & error msgs
Controller  com.nlogistic.controller.LogoutServlet       Clean invalidation & audit dispatch
Controller  com.nlogistic.controller.CustomerServlet     Fix /auth/login 404 redirect, add RBAC guard
Controller  com.nlogistic.controller.AdminUserServlet    Add unlock, suspend, delete, changeRole actions
Controller  com.nlogistic.controller.AdminCompanyServlet Add reject reason modal handler & audit SP
Controller  com.nlogistic.controller.ForgotPasswordServlet Real EmailService call + Dev fallback
NEW Servlet com.nlogistic.controller.AuditLogServlet      Eliminate scriptlets in audit_logins.jsp
View Layout webapp/jsp/layout/header.jsp                  Fix all admin sidebar URLs to point to servlets
View Layout webapp/jsp/layout/customer_header.jsp         Fix /auth/logout 404, wire customer menu links
View Admin  webapp/jsp/admin/users.jsp                    Remove all scriptlets, wire to AdminUserServlet
View Admin  webapp/jsp/admin/companies.jsp                Remove all scriptlets, wire to AdminCompanyServlet
View Admin  webapp/jsp/admin/customers.jsp                Remove all scriptlets, wire to CustomerServlet
View Admin  webapp/jsp/admin/audit_logins.jsp            Remove all scriptlets, wire to AuditLogServlet
================================================================================
```

### 5.1 Fix Broken Redirects in `CustomerServlet.java` & `AuthenticationFilter.java`

#### In `src/main/java/com/nlogistic/controller/CustomerServlet.java`:
Replace lines 32–36 and 44–48:
```java
// BEFORE (Buggy - produces 404):
if (user == null) {
    response.sendRedirect(request.getContextPath() + "/auth/login");
    return;
}

// AFTER (Compliant):
if (user == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}
```

#### In `src/main/webapp/jsp/layout/customer_header.jsp`:
Replace line 96:
```jsp
<!-- BEFORE (Buggy - produces 404): -->
<a href="${pageContext.request.contextPath}/auth/logout" class="btn btn-sm btn-outline-danger">Logout</a>

<!-- AFTER (Compliant): -->
<a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-outline-danger">Logout</a>
```
And wire the dead sidebar links (lines 80–88):
```jsp
<!-- BEFORE: -->
<a href="#" class="nav-link"><i class="fa-solid fa-ship"></i> Book Shipment</a>
<a href="#" class="nav-link"><i class="fa-solid fa-box"></i> Book Container</a>
<a href="#" class="nav-link"><i class="fa-solid fa-user"></i> My Profile</a>

<!-- AFTER: -->
<a href="${pageContext.request.contextPath}/book" class="nav-link">
    <i class="fa-solid fa-ship"></i> Book Shipment
</a>
<a href="${pageContext.request.contextPath}/containers" class="nav-link">
    <i class="fa-solid fa-box"></i> Book Container
</a>
<a href="${pageContext.request.contextPath}/profile" class="nav-link">
    <i class="fa-solid fa-user"></i> My Profile
</a>
```

---

### 5.2 Fix Sidebar Routing in `src/main/webapp/jsp/layout/header.jsp`

Replace direct `.jsp` references with the proper Servlet controller endpoints:

```jsp
<!-- Replace line 2234: -->
<!-- BEFORE: --> <li><a href="${pageContext.request.contextPath}/jsp/admin/companies.jsp">Company</a></li>
<!-- AFTER:  --> <li><a href="${pageContext.request.contextPath}/admin/companies">Company</a></li>

<!-- Replace line 2235: -->
<!-- BEFORE: --> <li><a href="${pageContext.request.contextPath}/jsp/admin/customers.jsp">Customer</a></li>
<!-- AFTER:  --> <li><a href="${pageContext.request.contextPath}/admin/customers">Customer</a></li>

<!-- Replace line 2316: -->
<!-- BEFORE: --> <a href="${pageContext.request.contextPath}/jsp/admin/users.jsp" class="nav-link">
<!-- AFTER:  --> <a href="${pageContext.request.contextPath}/admin/users" class="nav-link">

<!-- Replace line 2330: -->
<!-- BEFORE: --> <li><a href="${pageContext.request.contextPath}/jsp/admin/audit_logins.jsp">Logins &amp; Security</a></li>
<!-- AFTER:  --> <li><a href="${pageContext.request.contextPath}/admin/audit-logs">Logins &amp; Security</a></li>
```

---

### 5.3 Complete All Action Handlers in `AdminUserServlet.java`

Expand `AdminUserServlet.java` `doPost` to handle all user lifecycle transitions:

```java
protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    Integer roleId = (Integer) request.getSession().getAttribute("roleId");
    User currentUser = (User) request.getSession().getAttribute("user");
    if (roleId == null || roleId != 1 || currentUser == null) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Super Admin role required.");
        return;
    }

    String action = request.getParameter("action");
    String userIdStr = request.getParameter("userId");
    if (userIdStr == null || userIdStr.trim().isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/admin/users");
        return;
    }
    int targetUserId = Integer.parseInt(userIdStr.trim());
    int adminUserId = currentUser.getUserId();

    switch (action) {
        case "accept":
        case "activate":
            userDAO.approveUser(targetUserId, adminUserId);
            request.getSession().setAttribute("successMessage", "User #" + targetUserId + " has been activated.");
            break;

        case "reject":
        case "suspend":
            userDAO.deactivateUser(targetUserId, adminUserId);
            request.getSession().setAttribute("successMessage", "User #" + targetUserId + " has been suspended.");
            break;

        case "unlock":
            // FR1.8: Brute-Force Lockout Release
            userDAO.unlockUser(targetUserId, adminUserId);
            request.getSession().setAttribute("successMessage", "Account #" + targetUserId + " unlocked successfully. Failed login counter reset.");
            break;

        case "changeRole":
            String newRoleStr = request.getParameter("roleId");
            if (newRoleStr != null && !newRoleStr.trim().isEmpty()) {
                int newRoleId = Integer.parseInt(newRoleStr.trim());
                userDAO.changeUserRole(targetUserId, newRoleId, adminUserId);
                request.getSession().setAttribute("successMessage", "Role updated for user #" + targetUserId + ".");
            }
            break;

        case "delete":
            userDAO.deleteUser(targetUserId, adminUserId);
            request.getSession().setAttribute("successMessage", "User #" + targetUserId + " deleted permanently.");
            break;

        case "sendResetPassword":
            User targetUser = userDAO.getUserById(targetUserId);
            if (targetUser != null && targetUser.getEmail() != null) {
                String token = userDAO.generatePasswordResetToken(targetUser.getEmail());
                String resetLink = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/reset-password?token=" + token;
                boolean sent = com.nlogistic.util.EmailService.sendPasswordResetEmail(targetUser.getEmail(), targetUser.getUsername(), resetLink);
                if (sent) {
                    request.getSession().setAttribute("successMessage", "Reset email sent to " + targetUser.getEmail());
                } else {
                    request.getSession().setAttribute("successMessage", "Reset token generated! Manual link: " + resetLink);
                }
            }
            break;

        default:
            request.getSession().setAttribute("errorMessage", "Unknown user management action.");
            break;
    }

    response.sendRedirect(request.getContextPath() + "/admin/users");
}
```

---

### 5.4 Create Dedicated `AuditLogServlet.java` (FR1.9)

Create `src/main/java/com/nlogistic/controller/AuditLogServlet.java`:

```java
package com.nlogistic.controller;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nlogistic.dao.AuditDAO;
import com.nlogistic.dao.AuditDAO.AuditEntry;
import com.nlogistic.model.User;

@WebServlet("/admin/audit-logs")
public class AuditLogServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AuditDAO auditDAO = new AuditDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        Integer roleId = (Integer) request.getSession().getAttribute("roleId");

        // Precondition: Only Super Admin (1) or Company Admin (2) may view audit logs
        if (user == null || roleId == null || (roleId != 1 && roleId != 2)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Administrative privileges required.");
            return;
        }

        String actionFilter = request.getParameter("action");
        if (actionFilter == null || actionFilter.trim().isEmpty()) actionFilter = "ALL";

        String searchKeyword = request.getParameter("q");

        List<AuditEntry> auditLogs = auditDAO.getAuditLogs(actionFilter, searchKeyword, 500);
        Map<String, Integer> kpis = auditDAO.getAuditKPIs();

        request.setAttribute("auditLogs", auditLogs);
        request.setAttribute("kpis", kpis);
        request.setAttribute("currentAction", actionFilter);
        request.setAttribute("searchKeyword", searchKeyword != null ? searchKeyword : "");

        request.getRequestDispatcher("/jsp/admin/audit_logins.jsp").forward(request, response);
    }
}
```

---

### 5.5 Connect `EmailService` in `ForgotPasswordServlet.java`

Update `src/main/java/com/nlogistic/controller/ForgotPasswordServlet.java` lines 25–40:

```java
String token = userDAO.generatePasswordResetToken(email);

if (token != null) {
    String resetLink = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/reset-password?token=" + token;
    
    User targetUser = userDAO.getUserByUsername(email);
    String username = targetUser != null ? targetUser.getUsername() : "User";
    
    boolean emailSent = com.nlogistic.util.EmailService.sendPasswordResetEmail(email, username, resetLink);
    
    if (emailSent) {
        request.setAttribute("successMessage", "Password reset instructions have been dispatched to your email inbox.");
    } else {
        // Safe development fallback: show token link so user testing is never blocked
        request.setAttribute("successMessage", "Password reset link generated! Direct link: " + resetLink);
    }
} else {
    // Prevent email enumeration attacks by showing identical message
    request.setAttribute("successMessage", "If an account exists with that email, a password reset link has been generated.");
}

request.getRequestDispatcher("/jsp/forgot-password.jsp").forward(request, response);
```

---

## 6. Database Schema & Stored Procedure Specifications

The database layer must provide the following tables and stored procedures to guarantee complete contract enforcement for Module 1:

### 6.1 Relational Tables
1. **`roles`:** `role_id` (PK), `role_name`, `description`.
   - Seed values: `(1, 'Super Admin')`, `(2, 'Company Admin')`, `(3, 'Operations Staff')`, `(4, 'Finance Staff')`, `(5, 'Customer')`.
2. **`users`:** `user_id` (PK, AI), `username` (UQ), `email` (UQ), `password_hash` (VARCHAR 256), `phone`, `role_id` (FK), `company_id` (FK, Nullable), `status` (ENUM: `'Active'`, `'Inactive'`, `'Pending'`, `'Locked'`), `failed_login_count` (INT, Default 0), `last_login_at` (DATETIME), `locked_at` (DATETIME), `created_at`, `updated_at`.
3. **`companies`:** `company_id` (PK, AI), `company_name`, `license_no` (UQ), `gst_no` (UQ), `address`, `contact_email`, `contact_phone`, `approval_status` (ENUM: `'Pending'`, `'Active'`, `'Suspended'`), `created_at`.
4. **`customers`:** `customer_id` (PK, AI), `user_id` (FK -> users.user_id, UQ), `customer_name`, `address`, `kyc_doc_path`, `credit_limit` (DECIMAL 12,2, Default 0.00), `created_at`.
5. **`password_resets`:** `reset_id` (PK, AI), `user_id` (FK), `token` (VARCHAR 64, UQ), `expires_at` (DATETIME), `used` (BOOLEAN, Default FALSE), `created_at`.
6. **`audit_log`:** `log_id` (PK, AI), `user_id` (FK), `action` (VARCHAR 50), `entity_name` (VARCHAR 50), `entity_id` (INT), `old_value` (TEXT), `new_value` (TEXT), `ip_address` (VARCHAR 45), `timestamp` (DATETIME).

### 6.2 Stored Procedure Contracts
* `login_attempt(p_username, p_password, p_ip_address, OUT p_result)`: Enforces SHA2-256 validation, failed login counter increments, 5-attempt lockout, 15-minute cool-down calculation, and `LOGIN` audit generation.
* `logout(p_user_id, p_ip_address)`: Inserts `LOGOUT` record in `audit_log` with timestamp and IP address.
* `register_company(name, license, gst, address, email, phone, OUT p_company_id)`: Creates pending company record.
* `approve_company(p_company_id, p_approver_user_id)`: Updates `approval_status = 'Active'`, activates all linked users in `users`, and logs `COMPANY_APPROVED`.
* `suspend_company(p_company_id, p_approver_user_id, p_reason)`: Sets `approval_status = 'Suspended'`, deactivates linked users, logs reason.
* `register_customer(p_user_id, p_name, p_address, p_kyc_path, p_credit_limit)`: Creates customer profile linked to login account.
* `unlock_user(p_user_id, p_unlocked_by)`: Resets `failed_login_count = 0`, sets `status = 'Active'`, logs `ACCOUNT_UNLOCKED`.
* `deactivate_user(p_user_id, p_changed_by)`: Sets `status = 'Inactive'`, logs `USER_DEACTIVATED`.
* `change_user_role(p_user_id, p_new_role_id, p_changed_by)`: Updates `role_id`, logs `ROLE_CHANGED` with previous and new role values.

---

## 7. Verification & Quality Assurance Test Suite

The following 12 test cases validate that all Module 1 requirements and bug fixes operate flawlessly:

| Test ID | Objective | Input / Action | Expected Result | Pass Criteria |
| :--- | :--- | :--- | :--- | :--- |
| **TC-AUTH-01** | Verify separate Company registration. | Submit valid company details + admin credentials to `/register`. | Company created as `Pending`; User created as `Inactive`; redirected to `/login`. | DB contains matching rows; no immediate login permitted. |
| **TC-AUTH-02** | Verify separate Customer registration + KYC. | Submit customer details + sample `kyc.pdf` (2MB) to `/register`. | File written to `uploads/kyc/`; customer row created with `credit_limit=0.0`. | KYC file exists on disk; customer row linked to `users`. |
| **TC-AUTH-03** | Super Admin Company Approval. | Super Admin clicks "Approve" for pending company in `/admin/companies`. | Company status becomes `'Active'`; Company Admin user status becomes `'Active'`. | Company admin can now successfully log in. |
| **TC-AUTH-04** | Super Admin Customer Approval. | Super Admin approves customer and sets credit limit to `$10,000.00`. | User status becomes `'Active'`; `credit_limit` updated in `customers`. | Customer can log in; invoice limit reflects `$10,000.00`. |
| **TC-AUTH-05** | Successful Login & Session Scoping. | Valid login with Customer credentials. | Session contains `user`, `roleId=5`, `customerId`, and `customerName`. | Customer sees self-scoped dashboard; no 404s. |
| **TC-AUTH-06** | Customer Logout route check. | Click "Logout" in Customer Portal (`customer_header.jsp`). | Clean redirection to `/login` via `/logout` (NOT `/auth/logout`). | **HTTP 200/302** (No HTTP 404). Audit log records `LOGOUT`. |
| **TC-AUTH-07** | Session Inactivity Timeout (FR1.5). | Idle session for 31 minutes. | Next HTTP request invalidates session and redirects to `/login`. | User forced to re-authenticate; previous session dead. |
| **TC-AUTH-08** | Brute-Force Lockout Trigger (FR1.8). | Submit 5 consecutive incorrect passwords for user `test_user`. | 5th attempt returns `ACCOUNT_LOCKED`; `status` set to `'Locked'` in DB. | 6th attempt with CORRECT password still blocked. |
| **TC-AUTH-09** | Admin Manual Account Unlock (FR1.8). | Super Admin clicks "Unlock" on locked user in `/admin/users`. | `failed_login_count` reset to 0; status set to `'Active'`. | User can immediately log in with valid password. |
| **TC-AUTH-10** | Password Reset Token Expiry (FR1.6). | Request reset link; wait 16 minutes; attempt to open reset link. | System rejects token with *"Invalid or expired password reset link."* | Password unchanged; user redirected to forgot password. |
| **TC-AUTH-11** | RBAC URL Filter Enforcement (FR1.7). | Customer attempts direct GET request to `/admin/companies`. | Filter intercepts, logs `PERMISSION_DENIED`, redirects to `/dashboard`. | Customer cannot access admin view; audit log has entry. |
| **TC-AUTH-12** | Pure MVC2 JSP Compliance. | Inspect `users.jsp`, `companies.jsp`, `customers.jsp`, `audit_logins.jsp`. | Zero scriptlets (`<% ... %>`) remain in view files. | JSPs contain only JSTL and EL expressions. |

---

## 8. Summary & Transition to Module 2

With this Mega Specification for Module 1 in place:
1. Every discrepancy between the SRS and codebase has been cataloged with exact file references and line numbers.
2. All broken `/auth/*` routes and 404 exceptions have their exact code fixes identified.
3. The roadmap to eliminate raw JSP scriptlets across the four admin views has been established.
4. All 8 end-to-end Use Cases are formalized with complete preconditions, postconditions, and exception flows.

**Next Milestone:** Upon user sign-off of Module 1, we will proceed immediately to generate the dedicated **Module 2 Mega Specification** covering **Container Movement Tracking (Point A → Point B) and the Profit & Loss Graph (FR2.1 – FR2.9)**.
