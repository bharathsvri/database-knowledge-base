# Incident Runbook: Slow Query Triage and Remediation

> **Severity Level:** SEV-2 (Degraded Latency / Elevated CPU)  
> **Affected Systems:** Primary Database or Read Replica Cluster  
> **Target Audience:** SREs, On-Call Engineers, DBAs

---

## 1. Symptom & Alert Trigger
- **Alert:** `DatabaseHostCPUUtilization > 90%` or `DatabaseQueryP99Latency > 2000ms`.
- **User Impact:** Degraded API response times; elevated 504 gateway timeout errors.

---

## 2. Immediate Diagnostic Steps (Emergency Triage)

### Step 1: Identify Offending Queries Running Right Now
```sql
SELECT 
    pid, 
    now() - query_start AS duration, 
    state, 
    wait_event_type, 
    wait_event, 
    query
FROM pg_stat_activity
WHERE state != 'idle' 
  AND pid <> pg_backend_pid()
ORDER BY duration DESC
LIMIT 5;
```

### Step 2: Cancel or Terminate the Rogue Query
- **Graceful Cancellation (Attempts clean statement stop):**
  ```sql
  SELECT pg_cancel_backend(:pid);
  ```
- **Forceful Termination (Kills physical OS backend process if cancel fails):**
  ```sql
  SELECT pg_terminate_backend(:pid);
  ```

---

## 3. Post-Incident Root Cause Analysis

### Step 1: Capture Execution Plan
Execute `EXPLAIN (ANALYZE, BUFFERS)` on the identified query in a staging environment:
- Check for `Seq Scan on large_table`.
- Check for `Sort Method: external merge Disk`.
- Check for major row estimate skews (actual rows = 1,000,000 vs estimated rows = 1).

### Step 2: Update Table Statistics
If row estimates are severely inaccurate:
```sql
ANALYZE VERBOSE table_name;
```

### Step 3: Implement Index or Rewrite
- Add missing composite index:
  ```sql
  CREATE INDEX CONCURRENTLY idx_table_filter ON table_name (column_a, column_b);
  ```
- Rewrite non-SARGable functions to standard range boundaries.

---

## 4. Authoritative References
- [PostgreSQL EXPLAIN Guide](https://www.postgresql.org/docs/current/using-explain.html)
- [PostgreSQL System Administration Functions](https://www.postgresql.org/docs/current/functions-admin.html)
