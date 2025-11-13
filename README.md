# 📘 Snowflake External User Setup Guide  
### Created by **Samuel Mahembe**  

Step-by-step instructions for creating external users, assigning read-only access, and enabling MFA in Snowflake.

---

## 📌 Overview
This guide explains how to:
- Create a secure read-only role  
- Grant access to warehouses, databases, and schemas  
- Create an external user account  
- Enforce MFA during first login  
- Assign the role to the user  
- Share the login URL  

These steps match the demonstration shown in the video tutorial.

---

# ✅ 1. Use the ACCOUNTADMIN Role
This role has the required privileges for user and role management.

```sql
USE ROLE ACCOUNTADMIN;
```

# ✅ 2. Create a Read-Only Role

CREATE OR REPLACE ROLE EXTERNAL_READ_ROLE;


This role will contain all access permissions needed by the external user.

✅ 3. Grant Warehouse, Database, and Schema Access

Grant minimal access (read-only):
```sql
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE EXTERNAL_READ_ROLE;
GRANT USAGE ON DATABASE LAYOFF_ANALYTICS TO ROLE EXTERNAL_READ_ROLE;
GRANT USAGE ON SCHEMA LAYOFF_ANALYTICS.LAYOFFS TO ROLE EXTERNAL_READ_ROLE;

GRANT SELECT ON ALL TABLES IN SCHEMA LAYOFF_ANALYTICS.LAYOFFS TO ROLE EXTERNAL_READ_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA LAYOFF_ANALYTICS.LAYOFFS TO ROLE EXTERNAL_READ_ROLE;
```

This ensures:

- User can connect to the warehouse
- User can view the database

User can read all current + future tables

# ✅ 4. Create External User (MFA Ready)

The MUST_CHANGE_PASSWORD = TRUE setting forces password reset and MFA setup.
```sql
CREATE OR REPLACE USER test_user
  EMAIL = 'your-email@example.com'
  DEFAULT_ROLE = EXTERNAL_READ_ROLE
  DEFAULT_WAREHOUSE = COMPUTE_WH
  DEFAULT_NAMESPACE = LAYOFF_ANALYTICS.LAYOFFS
  PASSWORD = 'TempPass#2025'
  MUST_CHANGE_PASSWORD = TRUE;
```

# ✅ 5. Configure MFA

Snowflake enforces MFA during the first login when required.
```sql
CREATE OR REPLACE AUTHENTICATION POLICY require_mfa_policy
  MFA_ENROLLMENT = REQUIRED
  MFA_POLICY = (ALLOWED_METHODS = ('PASSKEY', 'TOTP'));

ALTER ACCOUNT SET AUTHENTICATION POLICY = require_mfa_policy;
```

This ensures the external user must:

- Change password
- Set up MFA using Microsoft Authenticator, Google Authenticator, Passkey, etc.

# ✅ 6. Assign the Role to the User
```sql
GRANT ROLE EXTERNAL_READ_ROLE TO USER test_user;
```

The user now inherits all read-only permissions.

# 🚀 External User Login Instructions
Share the Snowflake Account URL:
https://<account_locator>.snowflakecomputing.com


The account locator can be found in:
Admin → Accounts → Account Details

What the external user will do:

- Go to the login URL
- Enter username + temporary password
- Set a new password

Scan MFA QR code with an authenticator app

Log in with read-only access

# 🔒 Security Notes

- MFA is required for all new users
- External user has no write access

Future table grants ensure access stays consistent

Role-based access control keeps your account secure

# 📁 Files in This Repository

| File                      | Description                                                             |
|--------------------------|-------------------------------------------------------------------------|
| `external_user_setup.sql` | Full SQL script for setting up roles, grants, MFA policy, and user     |
| `README.md`               | Step-by-step guide and login instructions                              |

  
# 🙌 Author

**Samuel Mahembe**  
*Layoff Analytics Project – Snowflake Access Demonstration*
