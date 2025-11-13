-- ============================================================
-- Snowflake External User Setup Script
-- Author: Samuel Mahembe
-- Purpose: Create read-only role, configure MFA, 
--          create external user, and assign permissions
-- ============================================================

-- 1️⃣ Use ACCOUNTADMIN for full access
USE ROLE ACCOUNTADMIN;

-- 2️⃣ Create a Read-Only Role for External/Test Users
CREATE OR REPLACE ROLE EXTERNAL_READ_ROLE;

-- 3️⃣ Grant Warehouse, Database, Schema and Table Access
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE EXTERNAL_READ_ROLE;
GRANT USAGE ON DATABASE LAYOFF_ANALYTICS TO ROLE EXTERNAL_READ_ROLE;
GRANT USAGE ON SCHEMA LAYOFF_ANALYTICS.LAYOFFS TO ROLE EXTERNAL_READ_ROLE;

-- Read-only access to all current + future tables
GRANT SELECT ON ALL TABLES IN SCHEMA LAYOFF_ANALYTICS.LAYOFFS TO ROLE EXTERNAL_READ_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA LAYOFF_ANALYTICS.LAYOFFS TO ROLE EXTERNAL_READ_ROLE;

-- 4️⃣ Create External User (MFA-ready)
CREATE OR REPLACE USER test_user
  LOGIN_NAME = 'test.user'
  EMAIL = 'your-email@example.com'
  DEFAULT_ROLE = EXTERNAL_READ_ROLE
  DEFAULT_WAREHOUSE = COMPUTE_WH
  DEFAULT_NAMESPACE = LAYOFF_ANALYTICS.LAYOFFS
  PASSWORD = 'TempPass#2025'
  MUST_CHANGE_PASSWORD = TRUE
  COMMENT = 'External user created with read-only access';

-- 5️⃣ Configure MFA (Snowflake enforces MFA on first login)
CREATE OR REPLACE AUTHENTICATION POLICY require_mfa_policy
  MFA_ENROLLMENT = REQUIRED
  MFA_POLICY = (ALLOWED_METHODS = ('PASSKEY', 'TOTP'));

ALTER ACCOUNT SET AUTHENTICATION POLICY = require_mfa_policy;

-- 6️⃣ Assign Role to User
GRANT ROLE EXTERNAL_READ_ROLE TO USER test_user;

-- ============================================================
-- END OF SCRIPT
-- ============================================================
