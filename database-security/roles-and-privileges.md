# Database Roles, Privileges, and Row-Level Security

> **Category:** Database Security  
> **Target Audience:** Database Administrators, Backend Developers

---

## 1. Principle of Least Privilege in Database Design
A database user account should possess only the absolute minimum set of privileges required to perform its operational duties.
- **Never use `postgres` or `root` superuser accounts in application connection strings.**
- Superusers bypass all permission checks, bypass Row-Level Security (RLS), and can execute filesystem commands (`COPY ... FROM PROGRAM`).

---

## 2. Structured Role Hierarchy Pattern (PostgreSQL)

```sql
-- 1. Create functional role groups (NOLOGIN)
CREATE ROLE readonly_group NOLOGIN;
CREATE ROLE readwrite_group NOLOGIN;
CREATE ROLE migration_group NOLOGIN;

-- 2. Grant permissions to groups
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_group;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO readwrite_group;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO migration_group;

-- Ensure future tables inherit permissions automatically:
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly_group;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO readwrite_group;

-- 3. Create concrete application users and assign to groups
CREATE ROLE app_runtime_user WITH LOGIN ENCRYPTED PASSWORD 'ComplexPass123!' IN ROLE readwrite_group;
CREATE ROLE bi_analyst_user WITH LOGIN ENCRYPTED PASSWORD 'AnalystPass123!' IN ROLE readonly_group;
```

---

## 3. PostgreSQL Row-Level Security (RLS)
RLS restricts which subset of rows a user query can view or modify:

```sql
-- Enable RLS
ALTER TABLE sensitive_documents ENABLE ROW LEVEL SECURITY;

-- Create policy restricting users to their department
CREATE POLICY dept_isolation_policy ON sensitive_documents
    FOR ALL
    TO readwrite_group
    USING (dept_id = current_setting('app.current_dept')::INT);
```

---

## 4. Authoritative References
- [PostgreSQL Database Roles](https://www.postgresql.org/docs/current/user-manag.html)
- [PostgreSQL Row Security Policies](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
