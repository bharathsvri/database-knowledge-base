# Database Encryption: In-Transit, At-Rest, and In-Use

> **Category:** Database Security  
> **Target Audience:** Security Engineers, Systems Architects, Compliance Officers  
> **Relevant Standards:** PCI-DSS 4.0, HIPAA, SOC 2, ISO 27001

---

## 1. The Three Tiers of Database Encryption

```mermaid
flowchart TD
    subgraph InTransit["1. Encryption In-Transit (Network)"]
        Client["Client / Application"] -->|TLS 1.3 Encrypted Socket (Port 5432)| Server["Database Server"]
    end

    subgraph AtRest["2. Encryption At-Rest (Storage)"]
        Server -->|Decrypted in Memory Buffer Pool| Buffer["Buffer Cache"]
        Buffer -->|AES-256 Block Encryption| Disk[("Encrypted NVMe / EBS Storage")]
    end

    subgraph InUse["3. Client-Side Encryption In-Use"]
        AppCrypto["App Encrypts Field with KMS Key"] -->|Ciphertext sent to DB| DBEngine["DB Stores Opaque Ciphertext"]
    end
```

---

## 2. Encryption In-Transit (TLS / SSL)
- Enforces mutual authentication and encrypts all network packets passing between application connection pools and database servers.
- **PostgreSQL Configuration (`postgresql.conf`):**
  ```ini
  ssl = on
  ssl_cert_file = '/etc/ssl/certs/server.crt'
  ssl_key_file = '/etc/ssl/private/server.key'
  ssl_min_protocol_version = 'TLSv1.3'
  ```
- **Client JDBC Requirement:**
  ```properties
  spring.datasource.url=jdbc:postgresql://db.internal:5432/app_db?sslmode=verify-full&sslrootcert=/path/to/ca.crt
  ```

---

## 3. Transparent Data Encryption (TDE) vs Block-Level Encryption
- **Block-Level Storage Encryption (AWS KMS / LUKS):** Encrypts underlying storage volumes (EBS/NVMe) transparently at the OS kernel or hypervisor layer. Protects against physical disk theft or decommissioning leaks.
- **Transparent Data Encryption (TDE):** The database engine encrypts pages before writing to disk and decrypts them when reading into memory.
- **Limitation of At-Rest Encryption:** Once data is read into memory, it resides unencrypted in the server's RAM buffer pool. A compromised database superuser can query and read plaintext data.

---

## 4. Client-Side Field-Level Encryption (In-Use)
For extreme compliance data (credit card PANs, SSNs):
- The application encrypts the value using AES-GCM-256 before transmitting the SQL query.
- The database stores binary ciphertext. Even if the database server, operating system, and storage are completely breached, the attacker cannot read the plaintext without access to the application's KMS key.

---

## 5. Authoritative References
- [PostgreSQL SSL Configuration Guide](https://www.postgresql.org/docs/current/ssl-tcp.html)
- [NIST SP 800-57: Recommendation for Key Management](https://csrc.nist.gov/publications/detail/sp/800-57-part-1/rev-5/final)
