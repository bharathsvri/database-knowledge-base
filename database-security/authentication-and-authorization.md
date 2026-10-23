# Database Authentication and Authorization

> **Category:** Database Security  
> **Target Audience:** Security Engineers, Database Administrators, Systems Architects  
> **Relevant Engines:** PostgreSQL (`pg_hba.conf`), MySQL

---

## 1. What It Is
- **Authentication:** The cryptographic verification of identity (confirming *who* is connecting to the database).
- **Authorization:** The enforcement of permissions (confirming *what* actions that authenticated identity is allowed to execute).

---

## 2. Hardened Authentication: SCRAM-SHA-256 vs md5
Older databases defaulted to `md5` password hashing, which is vulnerable to rainbow table lookups and replay attacks. 
PostgreSQL 14+ enforces **SCRAM-SHA-256** (Salted Challenge Response Authentication Mechanism):
- The server never stores the raw password or its simple MD5 hash.
- Authentication occurs via a multi-step cryptographic exchange where the client proves knowledge of the password without ever transmitting the password across the network.

### Hardened `pg_hba.conf` Configuration:
```text
# TYPE  DATABASE        USER            ADDRESS                 METHOD
# Reject unencrypted local sockets
local   all             all                                     peer

# Enforce TLS and SCRAM-SHA-256 for application tier
hostssl all             app_user        10.0.10.0/24            scram-sha-256

# Reject all plaintext connections explicitly
hostnossl all           all             0.0.0.0/0               reject
```

---

## 3. Cloud IAM Authentication (Zero-Password Identity)
In AWS RDS and Google Cloud SQL, applications can connect without static database passwords using **IAM Authentication**:
- The microservice assumes an IAM role (e.g., via Kubernetes Service Account OIDC).
- The AWS SDK generates a signed, temporary authentication token with a **15-minute lifetime**.
- The database validates the token via AWS STS, eliminating static hardcoded passwords from configuration files.

---

## 4. Authoritative References
- [PostgreSQL Client Authentication Documentation](https://www.postgresql.org/docs/current/client-authentication.html)
- [RFC 5802: SCRAM Authentication Mechanism](https://datatracker.ietf.org/doc/html/rfc5802)
