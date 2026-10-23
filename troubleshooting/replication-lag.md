# Incident Runbook: Replication Lag Spike

> **Severity Level:** SEV-2 (Degraded Performance / Stale Reads)  
> **Affected Systems:** Read Replica Fleet, Application Read Pool  
> **Target Audience:** SREs, Database Administrators, Backend Engineers

---

## 1. Symptom & Alert Trigger
- **Alert:** `PostgresReplicationLagSeconds > 30s` or `PostgresReplicationByteLag > 500MB`.
- **User Impact:** Users reporting stale data immediately after checkout/update; reporting dashboards showing outdated records.

---

## 2. Immediate Diagnostic Queries

### Step 1: Measure Byte Lag on Primary
```sql
SELECT 
    application_name,
    client_addr,
    state,
    sync_state,
    pg_wal_lsn_diff(pg_current_wal_lsn(), sent_lsn) AS send_lag_bytes,
    pg_wal_lsn_diff(sent_lsn, flush_lsn) AS flush_lag_bytes,
    pg_wal_lsn_diff(flush_lsn, replay_lsn) AS replay_lag_bytes
FROM pg_stat_replication;
```

### Step 2: Check for Conflicting Queries on Standby
If `replay_lag_bytes` is massive, a long-running query on the standby is blocking WAL replay:
```sql
-- Executed on Standby:
SELECT 
    pid, 
    now() - query_start AS duration, 
    query 
FROM pg_stat_activity 
WHERE state = 'active' 
ORDER BY duration DESC;
```

---

## 3. Immediate Mitigation Steps

1. **Terminate Conflicting Read Queries on Standby:**
   ```sql
   -- Kill query blocking WAL replay on standby:
   SELECT pg_terminate_backend(:pid);
   ```
2. **Temporarily Shift Read Traffic:**
   - If replication lag exceeds 60 seconds, configure the application load balancer to temporarily remove the lagging standby from the reader pool to prevent stale reads.
3. **Inspect Primary for Massive Bulk Writes:**
   - Check if an unindexed `UPDATE` or batch ETL script is generating gigabytes of WAL per minute:
   ```sql
   SELECT pid, now() - query_start AS duration, query 
   FROM pg_stat_activity 
   WHERE state = 'active' AND query ILIKE ANY(ARRAY['%UPDATE%', '%DELETE%', '%COPY%']);
   ```

---

## 4. Permanent Preventive Actions
- Set `max_standby_streaming_delay = '30s'` on standbys so queries automatically cancel rather than stalling WAL replay indefinitely.
- Break massive bulk mutations into micro-batches of 5,000 rows.
- Enable `hot_standby_feedback = on` if query cancellations are frequent, while monitoring primary table bloat.

---

## 5. Authoritative References
- [PostgreSQL Documentation: Handling Replication Conflicts](https://www.postgresql.org/docs/current/hot-standby.html#HOT-STANDBY-CONFLICT)
