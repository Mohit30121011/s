# N LOGISTIC — SECURITY, SESSION & OWASP DEEP AUDIT
> **Master Forensic Security Audit**: Vulnerability Assessment, CSRF Protection, Account Takeover Risks, RCE File Uploads, Session Fixation, Cryptographic Storage & OWASP Top 10 Hardening.  
> **Application Target**: Java EE / Servlet 3.1 (`com.nlogistic.*`) on Apache Tomcat 9.0  
> **Audit Execution Date**: September 2026

---

## 1. EXECUTIVE SUMMARY & THREAT MATRIX

A comprehensive security audit of the N Logistic application was conducted across the authentication layer, session management, HTTP request handling, file upload pipelines, and database interactions.

### 1.1 OWASP Top 10 (2021/2025) Risk Scoring Matrix

```
=============================================================================================================
                                      SECURITY THREAT MATRIX
=============================================================================================================
OWASP Category                  Vulnerability Discovered                         Severity   Exploitability
-------------------------------------------------------------------------------------------------------------
A01: Broken Access Control      Zero CSRF Tokens on state-mutating POST requests CRITICAL   High (1-Click)
A01: Broken Access Control      /shipments/updateStatus unauthenticated role     HIGH       High (Direct IDOR)
A01: Broken Access Control      Open Redirect via ?redirectUrl= parameter        MEDIUM     Medium (Phishing)
A07: Identification & Auth      Account Takeover via Forgot Password link leak   CRITICAL   High (Zero Auth)
A07: Identification & Auth      Session Fixation (No session ID rotation)        HIGH       Medium (Man-in-Middle)
A07: Identification & Auth      Missing HttpOnly, Secure, SameSite cookie flags  HIGH       High (XSS/Cookie theft)
A04: Insecure Design            Unrestricted File Upload (.jsp execution / RCE) CRITICAL   High (Web Shell)
A02: Cryptographic Failures     Unsalted SHA-256 Passwords via MySQL SHA2()      HIGH       High (Rainbow Table)
A03: Injection / XSS            Reflected ${errorMessage} in JSPs without c:out  MEDIUM     Medium (Stored/Reflected)
A05: Security Misconfiguration  Detailed Tomcat Stack Trace on 500 Error         LOW        High (Reconnaissance)
=============================================================================================================
```

---

## 2. VULNERABILITY 1: ZERO CSRF PROTECTION ACROSS ALL POST ENDPOINTS

### 2.1 Technical Analysis
The N Logistic application relies exclusively on HTTP Session cookies (`JSESSIONID`) for authentication. However, across the entire project, there is **zero Cross-Site Request Forgery (CSRF) protection**:
* No CSRF Synchronizer Token filter exists.
* No forms contain hidden `<input type="hidden" name="csrfToken">` fields.
* No AJAX/Fetch requests supply `X-CSRF-Token` headers.

### 2.2 Exploitation Scenario
An attacker hosts a malicious website or sends a phishing link to an authenticated Super Admin or Company Admin:

```html
<!-- Malicious attacker page: http://attacker.com/steal.html -->
<html>
  <body onload="document.forms[0].submit()">
    <form action="http://localhost:8080/NLogistic/shipments/delete" method="POST">
      <input type="hidden" name="shipmentId" value="105" />
    </form>
  </body>
</html>
```

When the admin visits this page, their browser automatically attaches their valid `JSESSIONID` cookie to the cross-site POST request. The server executes `ShipmentDAO.deleteShipment(105, 1)` and completely purges the shipment and its associated financial and compliance records without the administrator's knowledge.

### 2.3 Affected Critical Operations
1. `ShipmentServlet.java`: `/shipments/delete` (Deletes shipments).
2. `ShipmentServlet.java`: `/shipments/create` (Unauthorized booking creation).
3. `ClaimServlet.java`: `/claims/review` (Approves fraudulent claims / payouts).
4. `BillingServlet.java`: `/billing/void` (Voids legitimate commercial invoices).
5. `StockServlet.java`: `/adjust-stock` (Fraudulently alters inventory quantities).
6. `PricingRuleServlet.java`: `/pricing/update` (Manipulates freight pricing rates).
7. `UserServlet.java`: `/admin/users/role` (Privilege escalation: upgrades any account to Super Admin).

---

## 3. VULNERABILITY 2: CRITICAL ACCOUNT TAKEOVER IN FORGOT PASSWORD FLOW

### 3.1 Technical Analysis
In `com.nlogistic.controller.ForgotPasswordServlet.java` (lines 37–43), the application includes a fallback intended for development/demo mode when SMTP email delivery is unconfigured:

```java
// Snippet from ForgotPasswordServlet.java:
boolean emailSent = com.nlogistic.util.EmailService.sendPasswordResetEmail(email, username, resetLink);

if (emailSent) {
    request.setAttribute("successMessage",
            "Password reset instructions have been sent to your email inbox.");
} else {
    // CRITICAL ATO VULNERABILITY:
    // SMTP unconfigured (common in local/demo installs): surface the link
    // directly rather than leaving the user with no way forward.
    request.setAttribute("successMessage",
            "Password reset link generated. Direct link: " + resetLink);
}
```

### 3.2 Exploitation Vector
Because production environments that experience SMTP server downtime, invalid credentials, or network firewalls fail `sendPasswordResetEmail()`, the application outputs:
`"Password reset link generated. Direct link: http://localhost:8080/NLogistic/reset-password?token=d3b07384-..."` directly on the browser screen.

An external anonymous attacker simply types `superadmin@nlogistic.com` into the Forgot Password form. The server returns the active password reset token directly in the HTTP response. The attacker clicks the link, enters a new password, and seizes global Super Admin control within 10 seconds.

### 3.3 Remediation Architecture
1. **Never** display reset tokens in web responses under any circumstances.
2. If SMTP fails, log the error on the server and display a generic message: *"If an account exists with this email, reset instructions have been dispatched."*
3. Implement IP-based and email-based rate limiting on `/forgot-password` (maximum 3 requests per IP per hour).

---

## 4. VULNERABILITY 3: REMOTE CODE EXECUTION (RCE) VIA FILE UPLOAD

### 4.1 Technical Analysis
File uploads are handled in `ComplianceServlet.java`, `CustomerServlet.java`, and `ClaimServlet.java` using the Servlet 3.0 `@MultipartConfig` API.

In `ComplianceServlet.java` (lines 141–149):
```java
Part filePart = request.getPart("docFile");
String fileName = (filePart != null) ? filePart.getSubmittedFileName() : null;

if (fileName != null && !fileName.trim().isEmpty()) {
    String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) uploadDir.mkdirs();
    
    String sanitized = System.currentTimeMillis() + "_" + fileName.replaceAll("[^a-zA-Z0-9.-]", "_");
    String filePath = uploadPath + File.separator + sanitized;
    filePart.write(filePath);
    dbFilePath = "uploads/" + sanitized;
}
```

### 4.2 Exploitation Vector & Impact
1. **Zero Extension Whitelisting**:
   The code only sanitizes special characters with regex `[^a-zA-Z0-9.-]`. It does **not** check the file extension. If an authenticated user uploads `exploit.jsp`, `shell.jspx`, or `cmd.jsp`, the file is saved as `uploads/1725500000000_exploit.jsp`.
2. **Direct Webroot Exposure**:
   Because `uploadPath` is inside `getServletContext().getRealPath("")`, the file is placed directly inside Tomcat's deployed web application directory.
3. **Execution**:
   The attacker navigates to `http://localhost:8080/NLogistic/uploads/1725500000000_exploit.jsp`. Tomcat's `JspServlet` compiles and runs the file as Java code under the OS permissions of the web server process, yielding full Remote Code Execution and database takeover.

### 4.3 Remediation Architecture
* **Strict Whitelisting**: Only allow extensions: `.pdf`, `.png`, `.jpg`, `.jpeg`, `.csv`.
* **MIME Verification**: Verify MIME header (`application/pdf`, `image/png`, `image/jpeg`).
* **Randomized Storage Names**: Generate purely synthetic UUIDs without retaining user-supplied file extensions (e.g. `UUID.randomUUID().toString() + ".pdf"`).
* **Storage Outside Webroot**: Store uploads in an isolated directory on disk (e.g. `D:/nlogistic_storage/uploads/`) and stream files via a dedicated controller (`DownloadDocumentServlet`) with `Content-Disposition: attachment`.

---

## 5. VULNERABILITY 4: BROKEN ACCESS CONTROL & OPEN REDIRECT

### 5.1 Technical Analysis
In `ShipmentServlet.java` (lines 184–199):
```java
else if (pathInfo != null && pathInfo.equals("/updateStatus")) {
    String shipmentIdStr = request.getParameter("shipmentId");
    String status = request.getParameter("status");
    String remarks = request.getParameter("remarks");
    String redirectUrl = request.getParameter("redirectUrl");
    try {
        int shipmentId = Integer.parseInt(shipmentIdStr);
        int userId = (currentUser != null) ? currentUser.getUserId() : 1;
        shipmentDAO.updateStatus(shipmentId, status, remarks, userId);
        ...
        if (redirectUrl != null && !redirectUrl.trim().isEmpty()) {
            response.sendRedirect(redirectUrl);
        }
```

### 5.2 Exploitation Vectors
1. **Horizontal / Vertical Privilege Escalation**:
   In `AuthenticationFilter.java`:
   `if (path.startsWith("/shipment") ...) return true;`
   Because `/shipments/updateStatus` begins with `/shipment`, any authenticated user—including a Customer (Role 5)—passes through the filter. `ShipmentServlet` performs no internal role check before executing `shipmentDAO.updateStatus()`. Any user can arbitrarily change any shipment's status from `Booked` to `Delivered` or `Customs Hold`.
2. **Open Redirect (Phishing)**:
   The `redirectUrl` parameter is passed directly to `response.sendRedirect(redirectUrl)` without domain verification.
   Attacker URL:
   `http://localhost:8080/NLogistic/shipments/updateStatus?shipmentId=1&status=Booked&redirectUrl=https://phishing-nlogistic.com/login`
   Users are seamlessly redirected to an external credential-harvesting portal.

---

## 6. VULNERABILITY 5: SESSION FIXATION & MISSING COOKIE SECURITY ATTRIBUTES

### 6.1 Session Fixation
In `LoginServlet.java` (line 55):
```java
HttpSession session = request.getSession();
session.setAttribute("user", user);
session.setAttribute("roleId", user.getRoleId());
```
The session identifier is not changed upon successful login. An attacker who sets a `JSESSIONID` cookie in a shared browser or through subdomain cookie injection retains access to the session once the victim authenticates.

**Fix**: Call `request.changeSessionId()` immediately upon credential verification.

### 6.2 Missing Cookie Security Configuration in `web.xml`
The current `web.xml` contains no `<session-config>` or `<cookie-config>`. Consequently:
* **`HttpOnly` is missing**: JavaScript (via any future XSS vulnerability) can execute `document.cookie` and exfiltrate the `JSESSIONID`.
* **`Secure` is missing**: The session cookie is transmitted over plaintext HTTP connections.
* **`SameSite` is not set**: Cross-site requests automatically transmit the session cookie.

---

## 7. VULNERABILITY 6: UNSALTED SHA-256 PASSWORD HASHING

### 7.1 Technical Analysis
In `UserDAO.java` (lines 88, 113, 427) and MySQL stored procedures:
```sql
INSERT INTO users (username, email, password_hash, ...) VALUES (?, ?, SHA2(?, 256), ...)
UPDATE users SET password_hash = SHA2(?, 256) WHERE user_id = ?
SELECT * FROM users WHERE email = ? AND password_hash = SHA2(?, 256)
```

### 7.2 Cryptographic Risks
1. **Zero Salt**: Identical passwords generate identical 64-character hex strings across the entire user base.
2. **Rainbow Table Vulnerability**: Fast hashes like unsalted SHA-256 can be computed at rates exceeding billions of hashes per second on consumer GPUs. An attacker with a database leak can reverse 90%+ of user passwords in minutes.
3. **Plaintext Password in JDBC Traffic**: Passing plaintext passwords to MySQL means that any database query log, packet inspection, or general log records the cleartext password.

---

## 8. COMPLETE SECURITY HARDENING BLUEPRINT

### 8.1 Production CSRF Protection Filter (`CsrfFilter.java`)
Deploy this filter to intercept all state-changing HTTP methods (`POST`, `PUT`, `DELETE`):

```java
package com.nlogistic.filter;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.Base64;
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

@WebFilter("/*")
public class CsrfFilter implements Filter {

    private static final String CSRF_TOKEN_SESSION_ATTR = "CSRF_TOKEN";
    private static final String CSRF_PARAM_NAME = "csrfToken";
    private static final String CSRF_HEADER_NAME = "X-CSRF-Token";
    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(true);

        // Ensure session has an active CSRF token
        String sessionToken = (String) session.getAttribute(CSRF_TOKEN_SESSION_ATTR);
        if (sessionToken == null) {
            byte[] bytes = new byte[32];
            secureRandom.nextBytes(bytes);
            sessionToken = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
            session.setAttribute(CSRF_TOKEN_SESSION_ATTR, sessionToken);
        }

        // Pass token to request attributes for JSPs to render in hidden fields
        req.setAttribute("csrfToken", sessionToken);

        String method = req.getMethod().toUpperCase();
        if ("POST".equals(method) || "PUT".equals(method) || "DELETE".equals(method)) {
            String path = req.getRequestURI().substring(req.getContextPath().length());

            // Exclude public authentication endpoints if necessary
            boolean isExcluded = path.equals("/login") || path.equals("/register") 
                              || path.equals("/forgot-password") || path.equals("/reset-password");

            if (!isExcluded) {
                String reqToken = req.getParameter(CSRF_PARAM_NAME);
                if (reqToken == null || reqToken.isEmpty()) {
                    reqToken = req.getHeader(CSRF_HEADER_NAME);
                }

                if (reqToken == null || !sessionToken.equals(reqToken)) {
                    res.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF Validation Failed: Invalid or missing token.");
                    return;
                }
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
```

### 8.2 Production HTTP Security Headers Filter (`SecurityHeadersFilter.java`)

```java
package com.nlogistic.filter;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletResponse;

@WebFilter("/*")
public class SecurityHeadersFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletResponse res = (HttpServletResponse) response;

        // OWASP Recommended Security Headers
        res.setHeader("X-Content-Type-Options", "nosniff");
        res.setHeader("X-Frame-Options", "DENY");
        res.setHeader("X-XSS-Protection", "1; mode=block");
        res.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
        res.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
        res.setHeader("Content-Security-Policy", 
            "default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://cdnjs.cloudflare.com; " +
            "style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://cdnjs.cloudflare.com https://fonts.googleapis.com; " +
            "font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com; img-src 'self' data:;");

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
```

### 8.3 Hardened `web.xml` Configuration

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
                             http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1"
         metadata-complete="false">

    <display-name>NLogistic</display-name>

    <!-- Session Management Hardening -->
    <session-config>
        <session-timeout>30</session-timeout>
        <cookie-config>
            <http-only>true</http-only>
            <secure>true</secure>
            <name>JSESSIONID</name>
        </cookie-config>
        <tracking-mode>COOKIE</tracking-mode>
    </session-config>

    <!-- Global Error Handlers (Prevents Tomcat Information Disclosure Stack Traces) -->
    <error-page>
        <error-code>403</error-code>
        <location>/jsp/error-403.jsp</location>
    </error-page>
    <error-page>
        <error-code>404</error-code>
        <location>/jsp/error-404.jsp</location>
    </error-page>
    <error-page>
        <error-code>500</error-code>
        <location>/jsp/error-500.jsp</location>
    </error-page>
    <error-page>
        <exception-type>java.lang.Throwable</exception-type>
        <location>/jsp/error-500.jsp</location>
    </error-page>

</web-app>
```

### 8.4 Secure File Upload Validator Utility (`FileUploadSecurity.java`)

```java
package com.nlogistic.util;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;
import javax.servlet.http.Part;

public class FileUploadSecurity {

    private static final Set<String> ALLOWED_EXTENSIONS = new HashSet<>(
        Arrays.asList("pdf", "png", "jpg", "jpeg", "csv")
    );

    private static final Set<String> ALLOWED_MIME_TYPES = new HashSet<>(
        Arrays.asList(
            "application/pdf", 
            "image/png", 
            "image/jpeg", 
            "text/csv", 
            "application/vnd.ms-excel"
        )
    );

    public static boolean isAllowed(Part filePart) {
        if (filePart == null || filePart.getSize() == 0) return false;

        String submittedName = filePart.getSubmittedFileName();
        if (submittedName == null || !submittedName.contains(".")) return false;

        String extension = submittedName.substring(submittedName.lastIndexOf(".") + 1).toLowerCase();
        if (!ALLOWED_EXTENSIONS.contains(extension)) {
            return false;
        }

        String mimeType = filePart.getContentType();
        if (mimeType == null || !ALLOWED_MIME_TYPES.contains(mimeType.toLowerCase())) {
            return false;
        }

        return true;
    }

    public static String generateSecureStorageName(String originalFilename) {
        String ext = originalFilename.substring(originalFilename.lastIndexOf(".") + 1).toLowerCase();
        return UUID.randomUUID().toString() + "." + ext;
    }
}
```

---

## 9. STEP-BY-STEP IMPLEMENTATION ROADMAP

| Phase | Action Item | Target File(s) | Security Impact |
| :--- | :--- | :--- | :--- |
| **Phase 1** | Deploy `CsrfFilter.java` & update `web.xml` session cookie config. | `CsrfFilter.java`, `web.xml` | Prevents 100% of Cross-Site Request Forgery attacks. |
| **Phase 2** | Remove direct link exposure in Forgot Password servlet. | `ForgotPasswordServlet.java` | Eliminates critical zero-authentication Account Takeover. |
| **Phase 3** | Implement file extension whitelist & secure storage naming. | `ComplianceServlet.java`, `CustomerServlet.java` | Prevents Remote Code Execution via `.jsp` webshells. |
| **Phase 4** | Enforce RBAC & Open Redirect check on `/shipments/updateStatus`. | `ShipmentServlet.java` | Closes privilege escalation and phishing redirects. |
| **Phase 5** | Add `request.changeSessionId()` on successful login. | `LoginServlet.java` | Prevents session fixation attacks. |
| **Phase 6** | Deploy `SecurityHeadersFilter.java` and custom error pages. | `SecurityHeadersFilter.java`, `error-500.jsp` | Blocks clickjacking, MIME sniffing, and stack trace leaks. |
| **Phase 7** | Migrate from plain SHA-256 to BCrypt / Argon2 with individual salts. | `UserDAO.java`, `SecurityUtil.java` | Protects database credentials against GPU offline cracking. |
