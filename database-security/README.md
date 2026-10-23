# Database Security & Compliance Architecture

This module provides exhaustive guides, hardened configuration baselines, role-based access models, and encryption runbooks for securing relational databases in production.

---

## Security Documentation Directory

| Document | Focus Area | Key Architectural Topics |
| :--- | :--- | :--- |
| **[Authentication and Authorization](authentication-and-authorization.md)** | Identity & Verification | SCRAM-SHA-256, mTLS, Kerberos, IAM database authentication, session tokens. |
| **[Roles and Privileges](roles-and-privileges.md)** | RBAC & Access Control | Least privilege principle, `GRANT`/`REVOKE`, default roles, PostgreSQL Row-Level Security (RLS). |
| **[Database Encryption](encryption.md)** | Cryptography | Encryption in transit (TLS 1.3), encryption at rest (TDE / LUKS / KMS), client-side field encryption. |
| **[Secrets Management](secrets-management.md)** | Credential Lifecycle | HashiCorp Vault dynamic database secrets, AWS Secrets Manager, zero-trust rotation. |
| **[Database Auditing](auditing.md)** | Compliance & Logging | `pgaudit`, logging DDL/DML, SOC-2 / PCI-DSS compliance, forensic audit trails. |
| **[Backup Security](backup-security.md)** | Cold Data Protection | GPG backup encryption, immutable S3 object locks, ransomware defense, air-gapped snapshots. |
