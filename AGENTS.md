# N LOGISTIC — AGENT & WORKFLOW CONFIGURATION GUIDE

> **Reference Files:**
> - [CLAUDE.md](file:///d:/NLogistic/NLogistic/CLAUDE.md) — Exhaustive master RBAC specification and field-level visibility rules.
> - [SYSTEM_WORKFLOW_AND_ENTITY_RELATIONSHIPS.md](file:///d:/NLogistic/NLogistic/SYSTEM_WORKFLOW_AND_ENTITY_RELATIONSHIPS.md) — Visual entity creation order, container vs shipment lifecycle, and Mermaid flowcharts.
> - [CLAUDE_CODE_RBAC_MEGA_PROMPT.md](file:///d:/NLogistic/NLogistic/CLAUDE_CODE_RBAC_MEGA_PROMPT.md) — Tactical implementation prompt for Claude Code.
> - [SYSTEM_GAPS_AND_MISSING_FEATURES.md](file:///d:/NLogistic/NLogistic/SYSTEM_GAPS_AND_MISSING_FEATURES.md) — Comprehensive audit of disconnected workflows, broken routes, and missing functionalities.
> - [MODULE_1_AUTH_GAPS_AND_ROADMAP.md](file:///d:/NLogistic/NLogistic/MODULE_1_AUTH_GAPS_AND_ROADMAP.md) — Module 1 (Authentication & Authorization) exhaustive gap analysis, 8 use cases, and code blueprint.
> - [MODULE_2_TRACKING_AND_PLG_GAPS_AND_ROADMAP.md](file:///d:/NLogistic/NLogistic/MODULE_2_TRACKING_AND_PLG_GAPS_AND_ROADMAP.md) — Module 2 (Container Tracking & P&L Graph) exhaustive gap analysis, 7 use cases, and code blueprint.
> - [MODULE_3_CONTAINER_ALLOCATION_AND_PRICING_GAPS_AND_ROADMAP.md](file:///d:/NLogistic/NLogistic/MODULE_3_CONTAINER_ALLOCATION_AND_PRICING_GAPS_AND_ROADMAP.md) — Module 3 (Container Allocation, Dynamic Pricing & Predictive Graph) exhaustive gap analysis, 7 use cases, and code blueprint.
> - [MODULE_4_STOCK_UPLOAD_AND_LEDGER_GAPS_AND_ROADMAP.md](file:///d:/NLogistic/NLogistic/MODULE_4_STOCK_UPLOAD_AND_LEDGER_GAPS_AND_ROADMAP.md) — Module 4 (Upload Stock Details & Inventory Ledger) exhaustive gap analysis, 6 use cases, and code blueprint.
> - [MODULE_5_GOVERNMENT_COMPLIANCE_AND_BILLING_GAPS_AND_ROADMAP.md](file:///d:/NLogistic/NLogistic/MODULE_5_GOVERNMENT_COMPLIANCE_AND_BILLING_GAPS_AND_ROADMAP.md) — Module 5 (Government Compliance & Billing) exhaustive gap analysis, 7 use cases, and code blueprint.
> - [MODULE_6_ANALYTICS_AND_ALGORITHMS_GAPS_AND_ROADMAP.md](file:///d:/NLogistic/NLogistic/MODULE_6_ANALYTICS_AND_ALGORITHMS_GAPS_AND_ROADMAP.md) — Module 6 (Analytics Dashboard & Algorithmic Engines) exhaustive gap analysis, 7 use cases, and code blueprint.
> - [MODULE_7_CLAIMS_GAPS_AND_ROADMAP.md](file:///d:/NLogistic/NLogistic/MODULE_7_CLAIMS_GAPS_AND_ROADMAP.md) — Module 7 (Claim of Loss & Damage - Supply Chain Claims) exhaustive gap analysis, 7 use cases, and code blueprint.
> - [MODULE_8_BARCODE_GAPS_AND_ROADMAP.md](file:///d:/NLogistic/NLogistic/MODULE_8_BARCODE_GAPS_AND_ROADMAP.md) — Module 8 (Barcode-Based Systemwide Traceability) exhaustive gap analysis, 6 use cases, and code blueprint.
> - [GOLDEN_SHIPMENT_END_TO_END_ORCHESTRATION_TRACE.md](file:///d:/NLogistic/NLogistic/GOLDEN_SHIPMENT_END_TO_END_ORCHESTRATION_TRACE.md) — The Golden Shipment: complete 16-phase end-to-end lifecycle orchestration, database mutation trace, and integration test suite.
> - [DATABASE_AND_STORED_PROCEDURES_AUDIT.md](file:///d:/NLogistic/NLogistic/DATABASE_AND_STORED_PROCEDURES_AUDIT.md) — Master Database & Stored Procedures Deep Audit: Foreign key cascades, parameter compatibility matrix, missing SP recovery, and indexing tuning.
> - [SECURITY_SESSION_AND_OWASP_AUDIT.md](file:///d:/NLogistic/NLogistic/SECURITY_SESSION_AND_OWASP_AUDIT.md) — Master Security, Session Hardening & OWASP Top 10 Audit: CSRF defense, account takeover prevention, RCE upload protection, and cryptographic storage.
> - [AUTOMATED_WORKFLOWS_AND_REACTIVE_IMPACT_GRAPH.md](file:///d:/NLogistic/NLogistic/AUTOMATED_WORKFLOWS_AND_REACTIVE_IMPACT_GRAPH.md) — Master Automated Workflows, Cascade Lifecycle & Reactive Impact Graph: Multi-table mutations, DB triggers, auto-barcodes, port updates, and financial cascades.
> - [AGENT_OPERATING_METHOD.md](file:///d:/NLogistic/NLogistic/AGENT_OPERATING_METHOD.md) — Master Agent Operating Method: Working loop, surgical verification, patch assertions, speed rules, and error traps.

## Quick Role Access Index

1. **Role 1 (Super Admin):** Global System Master. Full cross-company CRUD, approvals, user management, and audit logs.
2. **Role 2 (Company Admin):** Company Tenant Administrator. Manages company fleet, containers, staff, pricing rules, customer shipments, and P&L.
3. **Role 3 (Company Staff — Operations):** Operational Dispatch & Cargo Specialist. Container allocation, cargo fit checking, checkpoint transitions, stock CSV uploads, barcode scanning. Strictly no financial/P&L visibility.
4. **Role 4 (Company Staff — Finance):** Financial & Billing Specialist. Invoicing, payment recording, overdue collections, claim settlements, profit & loss analysis, and financial drilldowns. Strictly no movement status overrides.
5. **Role 5 (Customer / Consumer):** External Shipper. Self-service booking, container catalog browsing, own shipment live tracking, own invoice viewing/payment, and loss/damage claim submission. Strictly no internal company financials, pricing multipliers, other customers' data, stock ledgers, or dock scanning tools.

## Implementation Architecture

- **UI Guard:** Strict JSTL `<c:if>` tags in `header.jsp` and view JSPs to hide forbidden menus, action buttons (Edit, Delete, Drilldown), and sensitive columns.
- **Filter Guard:** `AuthenticationFilter.java` intercepting protected URLs and issuing HTTP 403 Forbidden for unauthorized roles.
- **Controller Guard:** Parametric validation ensuring Customers only access their own `customer_id` records and Company Staff only access their own `company_id` records.
- **Contract Enforcement:** Design-by-Contract preconditions for Container Allocation (FR3.3/3.4), Departure Gating (FR5.3), and Claim Settlement (FR7.5).

## Automated Cascades & Reactive State Reference

For the exhaustive multi-table mutation pipeline, consult [AUTOMATED_WORKFLOWS_AND_REACTIVE_IMPACT_GRAPH.md](file:///d:/NLogistic/NLogistic/AUTOMATED_WORKFLOWS_AND_REACTIVE_IMPACT_GRAPH.md):
- **Cargo Booking & Capacity Gate:** Trigger `shipment_cargo_capacity_check` verifies container limits; `BarcodeAutoGenerator` stamps QR barcode `SHP-xxxx`.
- **Container Allocation & Fleet Removal:** Atomic lock in `allocate_container` sets container `Allocated` and binds to shipment; pricing rule multipliers evaluated.
- **Departure Gatekeeper:** Trigger `movement_prevent_depart_if_docs_pending` intercepts `container_movements` and physically blocks departure if compliance docs are missing, rejected, or expired.
- **In-Transit Fleet Tracking:** Trigger `movement_in_transit` automatically cascades container status to `In-Transit`.
- **Destination Arrival & Asset Re-location:** Destination port updates `containers.current_port_id`; handheld scans logged to `barcode_scan_log`.
- **Delivery & Container Recycling:** Trigger `shipment_delivered` automatically resets container status to `Available` at destination port for instant fleet reuse.
- **Invoice & Financial Realization:** `generate_invoice` creates line items (`invoice_line_item_total`); payment recording updates customer credit and realizes net profit in `profit_loss`.
- **Damage Claim Compensation:** Triggers `claim_approved_amount_check` and `claim_require_review_precondition` govern settlement payouts, deducting approved amounts into P&L costs with mapped loss reasons.
