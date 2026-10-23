# Incident Runbook: Data Consistency and Drift Remediation

> **Severity Level:** SEV-1 (Data Integrity Violation)  
> **Affected Systems:** Replicated Shards, Search Sync Pipelines, Multi-Node Clusters  
> **Target Audience:** Database Engineers, SREs, Systems Architects

---

## 1. Symptom & Types of Consistency Issues
- **Replication Drift:** Standby replica returning different row values than the Primary for the same committed transaction.
- **CDC / Cache Drift:** Kafka topics or Elasticsearch indexes missing records present in PostgreSQL.
- **Cross-Shard Orphan Records:** Foreign key relationships broken across sharded databases due to partial transaction failures.

---

## 2. Immediate Diagnostic Procedures

### Step 1: Detect Block-Level Physical Corruption
```sql
-- Check for corrupted physical disk pages (PostgreSQL 12+)
SELECT * FROM pg_checksum_state();
```
Run `amcheck` to verify B-Tree index structure integrity:
```sql
CREATE EXTENSION IF NOT EXISTS amcheck;

-- Verify integrity of target index pages:
SELECT bt_index_check('idx_orders_customer_id', true);
```

### Step 2: Cross-Node Data Reconciliation (Logical Checksums)
Compare row counts and cryptographic hashes across primary and replica:
```sql
-- Calculate MD5 hash of customer records:
SELECT 
    count(*), 
    md5(string_agg(customer_id::text || email || is_active::text, ',' ORDER BY customer_id)) AS dataset_hash
FROM customers;
```
If hashes diverge, logical replication dropped records or skipped transactions.

---

## 3. Remediation Actions

1. **Rebuilding Corrupted Indexes:**
   ```sql
   REINDEX INDEX CONCURRENTLY idx_orders_customer_id;
   ```
2. **Resyncing Broken Standbys:**
   - If physical replication streams show corruption, do not patch manually.
   - Destroy the standby data directory and re-clone cleanly from the primary via `pg_basebackup`.
3. **Re-seeding Search / Analytics Engines:**
   - Trigger a full table export and bulk re-index into Elasticsearch/ClickHouse using keyset pagination.

---

## 4. Authoritative References
- [PostgreSQL amcheck Extension](https://www.postgresql.org/docs/current/amcheck.html)
- [PostgreSQL Data Checksums](https://www.postgresql.org/docs/current/app-initdb.html#APP-INITDB-DATA-CHECKSUMS)
