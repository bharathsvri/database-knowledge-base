# Database Security Interview Questions & Answers

> **Module:** Database Interview Preparation  
> **Topic:** Authentication, Authorization, RBAC, Encryption (TDE / In-Transit), Row-Level Security, SQL Injection  
> **Target Audience:** Security Engineers, Backend Developers, Database Administrators

---

## Difficulty Navigation
- [Beginner Level](#beginner-level)
- [Intermediate Level](#intermediate-level)
- [Advanced Level](#advanced-level)
- [Senior Engineer Level](#senior-engineer-level)

---

## Beginner Level

### Q1: How do Prepared Statements prevent SQL Injection attacks?
#### Short Interview-Ready Answer
"Prepared statements prevent SQL injection by strictly separating SQL query code from user-supplied data at the database protocol level. The database engine parses, analyzes, and compiles the SQL query structure with placeholders (`?` or `$1`) **before** parameters are transmitted. When user input is subsequently sent, the engine treats it purely as literal scalar values, making it impossible for attacker payloads to alter the query's syntax tree or execution plan."

---

## Intermediate Level

### Q2: What is the difference between Encryption at Rest, In-Transit, and In-Use?
#### Short Interview-Ready Answer
"- **Encryption in Transit:** Encrypts data moving over the network using TLS (SSL) between client applications and database servers.
- **Encryption at Rest:** Encrypts physical database files, WAL logs, and backups stored on disk using Transparent Data Encryption (TDE) or block-level storage encryption (e.g., AWS EBS KMS).
- **Encryption in Use / Client-Side Encryption:** Data remains encrypted in database memory, buffer pools, and queries (e.g., AWS KMS Client-Side SDK, Always Encrypted), decrypted only within the client application's secure memory."

---

## Advanced Level

### Q3: What is PostgreSQL Row-Level Security (RLS) and how is it used in multi-tenant SaaS?
#### Short Interview-Ready Answer
"PostgreSQL Row-Level Security (RLS) enforces fine-grained access control policies directly within the database engine at the individual row level. When enabled on a table, PostgreSQL transparently appends security filter conditions to every `SELECT`, `UPDATE`, and `DELETE` query based on the executing database user or session settings."

```sql
-- Enable RLS on multi-tenant table:
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Define tenant isolation policy:
CREATE POLICY tenant_isolation_policy ON documents
    USING (tenant_id = current_setting('app.current_tenant_id', true));

-- Set session context before executing user queries:
SET LOCAL app.current_tenant_id = 'org_982';
SELECT * FROM documents; -- Engine automatically appends: WHERE tenant_id = 'org_982'
```

---

## Senior Engineer Level

### Q4: How do you implement Zero-Trust Secret Rotation for Database Credentials in Kubernetes?
#### Short Interview-Ready Answer
"We eliminate static long-lived database passwords by implementing **dynamic ephemeral credentials** using HashiCorp Vault or AWS IAM Database Authentication:
1. When a Spring Boot microservice pod starts, it authenticates with Vault using its Kubernetes Service Account token.
2. The Vault PostgreSQL database secrets engine generates a unique, temporary database role and password with an explicit TTL (e.g., 1 hour).
3. The Spring Boot application leases these credentials and refreshes them automatically before expiry.
4. If a pod is compromised, the stolen credentials expire automatically within minutes, eliminating manual credential rotation operational emergencies."

---

## Authoritative References
- [PostgreSQL Row-Level Security](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [OWASP SQL Injection Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html)
