# Database Auditing & Compliance Logging

> **Category:** Database Security  
> **Target Audience:** Security Engineers, Compliance Officers, Database Administrators  
> **Relevant Tools:** `pgaudit`, MySQL Audit Plugin, SIEM (Splunk, Elastic)

---

## 1. Why Database Auditing is Required
Regulatory standards (PCI-DSS 4.0, HIPAA, SOC 2 Type II, GDPR) require an unalterable, forensic audit trail of all access and modifications to sensitive data. 

Standard application logs are insufficient because:
- Direct DBA access via SSH or psql bypasses the application layer entirely.
- Application logs can be tampered with or disabled by rogue application engineers.

---

## 2. Hardened Auditing with `pgaudit` (PostgreSQL)

The official **PostgreSQL Audit Extension (`pgaudit`)** intercepts queries within the database engine and produces detailed structured audit logs.

### Configuration in `postgresql.conf`:
```ini
shared_preload_libraries = 'pgaudit'

# Audit classes to capture:
# READ: SELECT and COPY
# WRITE: INSERT, UPDATE, DELETE, TRUNCATE
# ROLE: GRANT, REVOKE, CREATE/ALTER/DROP ROLE
# DDL: All CREATE, ALTER, DROP operations
pgaudit.log = 'role, ddl, write'

# Log execution parameters (bind variables)
pgaudit.log_parameter = on

# Log relation names
pgaudit.log_relation = on
```

### Sample Audit Log Entry (Sent to Syslog / SIEM):
```text
AUDIT: SESSION,1,1,WRITE,UPDATE,TABLE,public.accounts,UPDATE accounts SET balance = balance + 5000 WHERE id = 101,<none>
```

---

## 3. SIEM Ingestion & Tamper-Proof Storage
To meet compliance requirements, audit logs must not reside solely on the database server:
- Forward logs immediately via `syslog-ng` or `vector` to an immutable, write-once-read-many (WORM) storage target (such as an AWS S3 bucket with Object Lock enabled).
- Alert in real-time on anomalous activities:
  - Superuser login outside business hours.
  - Excessive row exports (`SELECT` returning > 100,000 rows).
  - Failed authentication spikes (potential brute-force attack).

---

## 4. Authoritative References
- [pgAudit Official Documentation](https://www.pgaudit.org/)
- [PCI-DSS Database Auditing Guidelines](https://www.pcisecuritystandards.org/)
