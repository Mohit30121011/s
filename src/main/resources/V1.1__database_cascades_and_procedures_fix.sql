-- ============================================================================
-- N LOGISTIC PRODUCTION DATABASE MIGRATION SCRIPT
-- Version: V1.1__database_cascades_and_procedures_fix.sql
-- Target Database: MySQL 8.0+ / nlogistic_db
-- Description:
--   1. Clean up dangling orphan records across child tables.
--   2. Reconfigure Foreign Keys to ON DELETE CASCADE for owned children.
--   3. Modify user tracking columns to NULL and reconfigure to ON DELETE SET NULL.
--   4. Deploy 4 missing stored procedures & refactor delete_shipment.
--   5. Add high-performance composite indexes.
-- ============================================================================

USE nlogistic_db;

-- ----------------------------------------------------------------------------
-- STEP 1: CLEAN UP EXISTING DANGLING ORPHAN RECORDS (IF ANY)
-- ----------------------------------------------------------------------------
DELETE FROM profit_loss_reason_map 
WHERE pl_id NOT IN (SELECT pl_id FROM profit_loss);

DELETE FROM claim_documents 
WHERE claim_id NOT IN (SELECT claim_id FROM claims);

DELETE FROM claim_status_history 
WHERE claim_id NOT IN (SELECT claim_id FROM claims);

DELETE FROM invoice_line_items 
WHERE invoice_id NOT IN (SELECT invoice_id FROM billing_invoices);

DELETE FROM payments 
WHERE invoice_id NOT IN (SELECT invoice_id FROM billing_invoices);

DELETE FROM container_movements 
WHERE shipment_id NOT IN (SELECT shipment_id FROM shipment);

DELETE FROM compliance_documents 
WHERE shipment_id NOT IN (SELECT shipment_id FROM shipment);

DELETE FROM profit_loss 
WHERE shipment_id IS NOT NULL AND shipment_id NOT IN (SELECT shipment_id FROM shipment);

DELETE FROM billing_invoices 
WHERE shipment_id IS NOT NULL AND shipment_id NOT IN (SELECT shipment_id FROM shipment);

DELETE FROM sales_transactions 
WHERE shipment_id IS NOT NULL AND shipment_id NOT IN (SELECT shipment_id FROM shipment);

-- Clean up invalid user references in shipment
UPDATE shipment 
SET created_by = NULL 
WHERE created_by IS NOT NULL AND created_by NOT IN (SELECT user_id FROM users);

-- ----------------------------------------------------------------------------
-- STEP 2: RECONFIGURE FOREIGN KEYS WITH PROPER CASCADES (TIER A)
-- ----------------------------------------------------------------------------

-- 2.1 Container Movements -> Shipment (CASCADE)
ALTER TABLE container_movements DROP FOREIGN KEY container_movements_ibfk_1;
ALTER TABLE container_movements 
  ADD CONSTRAINT fk_movements_shipment 
  FOREIGN KEY (shipment_id) REFERENCES shipment(shipment_id) 
  ON DELETE CASCADE ON UPDATE CASCADE;

-- 2.2 Compliance Documents -> Shipment (CASCADE)
ALTER TABLE compliance_documents DROP FOREIGN KEY compliance_documents_ibfk_1;
ALTER TABLE compliance_documents 
  ADD CONSTRAINT fk_compliance_shipment 
  FOREIGN KEY (shipment_id) REFERENCES shipment(shipment_id) 
  ON DELETE CASCADE ON UPDATE CASCADE;

-- 2.3 Claims -> Shipment (CASCADE)
ALTER TABLE claims DROP FOREIGN KEY claims_ibfk_1;
ALTER TABLE claims 
  ADD CONSTRAINT fk_claims_shipment 
  FOREIGN KEY (shipment_id) REFERENCES shipment(shipment_id) 
  ON DELETE CASCADE ON UPDATE CASCADE;

-- 2.4 Claim Documents -> Claims (CASCADE)
ALTER TABLE claim_documents DROP FOREIGN KEY claim_documents_ibfk_1;
ALTER TABLE claim_documents 
  ADD CONSTRAINT fk_claim_docs_claim 
  FOREIGN KEY (claim_id) REFERENCES claims(claim_id) 
  ON DELETE CASCADE ON UPDATE CASCADE;

-- 2.5 Claim Status History -> Claims (CASCADE)
ALTER TABLE claim_status_history DROP FOREIGN KEY claim_status_history_ibfk_1;
ALTER TABLE claim_status_history 
  ADD CONSTRAINT fk_claim_hist_claim 
  FOREIGN KEY (claim_id) REFERENCES claims(claim_id) 
  ON DELETE CASCADE ON UPDATE CASCADE;

-- 2.6 Billing Invoices -> Shipment (CASCADE)
ALTER TABLE billing_invoices DROP FOREIGN KEY billing_invoices_ibfk_2;
ALTER TABLE billing_invoices 
  ADD CONSTRAINT fk_invoices_shipment 
  FOREIGN KEY (shipment_id) REFERENCES shipment(shipment_id) 
  ON DELETE CASCADE ON UPDATE CASCADE;

-- 2.7 Invoice Line Items -> Billing Invoices (CASCADE)
ALTER TABLE invoice_line_items DROP FOREIGN KEY invoice_line_items_ibfk_1;
ALTER TABLE invoice_line_items 
  ADD CONSTRAINT fk_items_invoice 
  FOREIGN KEY (invoice_id) REFERENCES billing_invoices(invoice_id) 
  ON DELETE CASCADE ON UPDATE CASCADE;

-- 2.8 Payments -> Billing Invoices (CASCADE)
ALTER TABLE payments DROP FOREIGN KEY payments_ibfk_1;
ALTER TABLE payments 
  ADD CONSTRAINT fk_payments_invoice 
  FOREIGN KEY (invoice_id) REFERENCES billing_invoices(invoice_id) 
  ON DELETE CASCADE ON UPDATE CASCADE;

-- 2.9 Profit Loss -> Shipment (CASCADE)
ALTER TABLE profit_loss DROP FOREIGN KEY profit_loss_ibfk_1;
ALTER TABLE profit_loss 
  ADD CONSTRAINT fk_pl_shipment 
  FOREIGN KEY (shipment_id) REFERENCES shipment(shipment_id) 
  ON DELETE CASCADE ON UPDATE CASCADE;

-- 2.10 Profit Loss Reason Map -> Profit Loss (CASCADE)
ALTER TABLE profit_loss_reason_map DROP FOREIGN KEY profit_loss_reason_map_ibfk_1;
ALTER TABLE profit_loss_reason_map 
  ADD CONSTRAINT fk_plrm_pl 
  FOREIGN KEY (pl_id) REFERENCES profit_loss(pl_id) 
  ON DELETE CASCADE ON UPDATE CASCADE;

-- 2.11 Sales Transactions -> Shipment (CASCADE)
ALTER TABLE sales_transactions DROP FOREIGN KEY sales_transactions_ibfk_3;
ALTER TABLE sales_transactions 
  ADD CONSTRAINT fk_sales_shipment 
  FOREIGN KEY (shipment_id) REFERENCES shipment(shipment_id) 
  ON DELETE CASCADE ON UPDATE CASCADE;

-- 2.12 Barcode Scan Log -> Barcode Entries (CASCADE)
ALTER TABLE barcode_scan_log DROP FOREIGN KEY barcode_scan_log_ibfk_1;
ALTER TABLE barcode_scan_log 
  ADD CONSTRAINT fk_scan_barcode 
  FOREIGN KEY (barcode_id) REFERENCES barcode_entries(barcode_id) 
  ON DELETE CASCADE ON UPDATE CASCADE;

-- 2.13 Pricing Audit -> Pricing Rules (CASCADE)
ALTER TABLE pricing_audit DROP FOREIGN KEY pricing_audit_ibfk_1;
ALTER TABLE pricing_audit 
  ADD CONSTRAINT fk_audit_pricing 
  FOREIGN KEY (pricing_id) REFERENCES pricing_rules(pricing_id) 
  ON DELETE CASCADE ON UPDATE CASCADE;

-- ----------------------------------------------------------------------------
-- STEP 3: RECONFIGURE USER ATTRIBUTION KEYS WITH SET NULL (TIER B)
-- ----------------------------------------------------------------------------

-- 3.1 Audit Log -> Users (SET NULL)
ALTER TABLE audit_log MODIFY COLUMN user_id INT(11) NULL;
ALTER TABLE audit_log DROP FOREIGN KEY audit_log_ibfk_1;
ALTER TABLE audit_log 
  ADD CONSTRAINT fk_audit_user 
  FOREIGN KEY (user_id) REFERENCES users(user_id) 
  ON DELETE SET NULL ON UPDATE CASCADE;

-- 3.2 Shipment -> Users (created_by SET NULL)
ALTER TABLE shipment MODIFY COLUMN created_by INT(11) NULL;
ALTER TABLE shipment DROP FOREIGN KEY shipment_ibfk_6;
ALTER TABLE shipment 
  ADD CONSTRAINT fk_shipment_creator 
  FOREIGN KEY (created_by) REFERENCES users(user_id) 
  ON DELETE SET NULL ON UPDATE CASCADE;

-- 3.3 Compliance Documents -> Users (uploaded_by SET NULL)
ALTER TABLE compliance_documents MODIFY COLUMN uploaded_by INT(11) NULL;
ALTER TABLE compliance_documents DROP FOREIGN KEY compliance_documents_ibfk_2;
ALTER TABLE compliance_documents 
  ADD CONSTRAINT fk_compliance_uploader 
  FOREIGN KEY (uploaded_by) REFERENCES users(user_id) 
  ON DELETE SET NULL ON UPDATE CASCADE;

-- 3.4 Claim Documents -> Users (uploaded_by SET NULL)
ALTER TABLE claim_documents MODIFY COLUMN uploaded_by INT(11) NULL;
ALTER TABLE claim_documents DROP FOREIGN KEY claim_documents_ibfk_2;
ALTER TABLE claim_documents 
  ADD CONSTRAINT fk_claim_docs_uploader 
  FOREIGN KEY (uploaded_by) REFERENCES users(user_id) 
  ON DELETE SET NULL ON UPDATE CASCADE;

-- 3.5 Claim Status History -> Users (changed_by SET NULL)
ALTER TABLE claim_status_history MODIFY COLUMN changed_by INT(11) NULL;
ALTER TABLE claim_status_history DROP FOREIGN KEY claim_status_history_ibfk_2;
ALTER TABLE claim_status_history 
  ADD CONSTRAINT fk_claim_hist_user 
  FOREIGN KEY (changed_by) REFERENCES users(user_id) 
  ON DELETE SET NULL ON UPDATE CASCADE;

-- 3.6 Claims -> Users (filed_by & resolved_by SET NULL)
ALTER TABLE claims MODIFY COLUMN filed_by INT(11) NULL;
ALTER TABLE claims MODIFY COLUMN resolved_by INT(11) NULL;
ALTER TABLE claims DROP FOREIGN KEY claims_ibfk_6;
ALTER TABLE claims DROP FOREIGN KEY claims_ibfk_7;
ALTER TABLE claims 
  ADD CONSTRAINT fk_claims_filer 
  FOREIGN KEY (filed_by) REFERENCES users(user_id) 
  ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE claims 
  ADD CONSTRAINT fk_claims_resolver 
  FOREIGN KEY (resolved_by) REFERENCES users(user_id) 
  ON DELETE SET NULL ON UPDATE CASCADE;

-- 3.7 Container Movements -> Users (updated_by SET NULL)
ALTER TABLE container_movements MODIFY COLUMN updated_by INT(11) NULL;
ALTER TABLE container_movements DROP FOREIGN KEY container_movements_ibfk_2;
ALTER TABLE container_movements 
  ADD CONSTRAINT fk_movements_user 
  FOREIGN KEY (updated_by) REFERENCES users(user_id) 
  ON DELETE SET NULL ON UPDATE CASCADE;

-- 3.8 Barcode Entries -> Users (generated_by SET NULL)
ALTER TABLE barcode_entries MODIFY COLUMN generated_by INT(11) NULL;
ALTER TABLE barcode_entries DROP FOREIGN KEY barcode_entries_ibfk_1;
ALTER TABLE barcode_entries 
  ADD CONSTRAINT fk_barcode_gen_user 
  FOREIGN KEY (generated_by) REFERENCES users(user_id) 
  ON DELETE SET NULL ON UPDATE CASCADE;

-- 3.9 Barcode Scan Log -> Users (scanned_by SET NULL)
ALTER TABLE barcode_scan_log MODIFY COLUMN scanned_by INT(11) NULL;
ALTER TABLE barcode_scan_log DROP FOREIGN KEY barcode_scan_log_ibfk_2;
ALTER TABLE barcode_scan_log 
  ADD CONSTRAINT fk_scan_user 
  FOREIGN KEY (scanned_by) REFERENCES users(user_id) 
  ON DELETE SET NULL ON UPDATE CASCADE;

-- 3.10 Stock Upload Log -> Users (uploaded_by SET NULL)
ALTER TABLE stock_upload_log MODIFY COLUMN uploaded_by INT(11) NULL;
ALTER TABLE stock_upload_log DROP FOREIGN KEY stock_upload_log_ibfk_2;
ALTER TABLE stock_upload_log 
  ADD CONSTRAINT fk_stock_upload_user 
  FOREIGN KEY (uploaded_by) REFERENCES users(user_id) 
  ON DELETE SET NULL ON UPDATE CASCADE;

-- 3.11 Pricing Audit -> Users (changed_by SET NULL)
ALTER TABLE pricing_audit MODIFY COLUMN changed_by INT(11) NULL;
ALTER TABLE pricing_audit DROP FOREIGN KEY pricing_audit_ibfk_2;
ALTER TABLE pricing_audit 
  ADD CONSTRAINT fk_pricing_audit_user 
  FOREIGN KEY (changed_by) REFERENCES users(user_id) 
  ON DELETE SET NULL ON UPDATE CASCADE;

-- ----------------------------------------------------------------------------
-- STEP 4: RECREATE MISSING STORED PROCEDURES & REFACTOR delete_shipment
-- ----------------------------------------------------------------------------

DELIMITER $$

-- 4.1 check_shipment_compliance (Matches ComplianceDAO.java expectation)
DROP PROCEDURE IF EXISTS `check_shipment_compliance`$$
CREATE PROCEDURE `check_shipment_compliance`(IN p_shipment_id INT)
BEGIN
    DECLARE v_total_docs INT DEFAULT 0;
    DECLARE v_blocking_count INT DEFAULT 0;
    DECLARE v_cleared INT DEFAULT 0;

    SELECT COUNT(*) INTO v_total_docs
    FROM compliance_documents
    WHERE shipment_id = p_shipment_id;

    SELECT COUNT(*) INTO v_blocking_count
    FROM compliance_documents
    WHERE shipment_id = p_shipment_id
      AND (status <> 'Approved' OR expiry_date < CURDATE());

    IF v_total_docs > 0 AND v_blocking_count = 0 THEN
        SET v_cleared = 1;
    ELSE
        SET v_cleared = 0;
    END IF;

    SELECT v_cleared AS is_cleared_for_departure;
END$$

-- 4.2 flag_expired_documents (Matches ComplianceDAO.java:110)
DROP PROCEDURE IF EXISTS `flag_expired_documents`$$
CREATE PROCEDURE `flag_expired_documents`()
BEGIN
    UPDATE compliance_documents
    SET status = 'Expired'
    WHERE expiry_date < CURDATE()
      AND status NOT IN ('Expired', 'Rejected');
    
    SELECT ROW_COUNT() AS affected_documents;
END$$

-- 4.3 get_expiring_compliance_documents (Matches ComplianceDAO.java:51)
DROP PROCEDURE IF EXISTS `get_expiring_compliance_documents`$$
CREATE PROCEDURE `get_expiring_compliance_documents`(
    IN p_days_ahead INT
)
BEGIN
    SELECT cd.*, s.customer_id, c.customer_name
    FROM compliance_documents cd
    JOIN shipment s ON cd.shipment_id = s.shipment_id
    JOIN customers c ON s.customer_id = c.customer_id
    WHERE cd.expiry_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL p_days_ahead DAY)
      AND cd.status = 'Approved'
    ORDER BY cd.expiry_date ASC;
END$$

-- 4.4 getall_claim_documents (Matches ClaimDAO.java:277)
DROP PROCEDURE IF EXISTS `getall_claim_documents`$$
CREATE PROCEDURE `getall_claim_documents`(IN p_claim_id INT)
BEGIN
    SELECT *
    FROM claim_documents
    WHERE claim_id = p_claim_id
    ORDER BY doc_id ASC;
END$$

-- 4.5 RE-ENGINEER delete_shipment TO ELIMINATE SET FOREIGN_KEY_CHECKS=0
DROP PROCEDURE IF EXISTS `delete_shipment`$$
CREATE PROCEDURE `delete_shipment`(
    IN p_shipment_id INT,
    IN p_requesting_user_id INT
)
BEGIN
    DECLARE v_role INT;
    
    SELECT role_id INTO v_role 
    FROM users 
    WHERE user_id = p_requesting_user_id;

    IF v_role != 1 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Permission Denied: Super Admin access required to delete shipment';
    END IF;

    -- Deletion of shipment now cleanly cascades natively without disabling FK checks!
    START TRANSACTION;
        DELETE FROM shipment WHERE shipment_id = p_shipment_id;
    COMMIT;
END$$

DELIMITER ;

-- ----------------------------------------------------------------------------
-- STEP 5: ADD HIGH-PERFORMANCE COMPOSITE INDEXES
-- ----------------------------------------------------------------------------

-- 5.1 Shipment active lookups
CREATE INDEX idx_shipment_customer_status 
  ON shipment (customer_id, status);

CREATE INDEX idx_shipment_container_active 
  ON shipment (container_id, status);

-- 5.2 Barcode entity lookup
CREATE INDEX idx_barcode_entity_covering 
  ON barcode_entries (entity_type, entity_id, barcode_value);

-- 5.3 Barcode scan chronological log
CREATE INDEX idx_scan_log_barcode_time 
  ON barcode_scan_log (barcode_id, scanned_at DESC);

-- 5.4 Stock warehouse deduplication
CREATE INDEX idx_stock_comp_prod_loc 
  ON stock (company_id, product_id, warehouse_location);

-- 5.5 Container availability filter
CREATE INDEX idx_containers_company_status_type 
  ON containers (owner_company_id, status, type);

-- 5.6 Compliance gating check
CREATE INDEX idx_compliance_shipment_status_expiry 
  ON compliance_documents (shipment_id, status, expiry_date);

-- 5.7 Profit Loss report range
CREATE INDEX idx_pl_shipment_date 
  ON profit_loss (shipment_id, record_date);
