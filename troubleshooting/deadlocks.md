# Incident Runbook: Deadlocks and Lock Contention

> **Severity Level:** SEV-2 (Degraded Performance / Transaction Aborts)  
> **Affected Systems:** Relational Storage Engine, High-Throughput Write Paths  
> **Target Audience:** Backend Developers, Database Administrators

---

## 1. Symptom & Alert Trigger
- **Alert:** Spikes in `PostgresDeadlocksDetectedTotal > 5/min` or application errors:
  ```text
  org.postgresql.util.PSQLException: ERROR: deadlock detected
  Detail: Process 1845 waits for ShareLock on transaction 98402; blocked by process 1920.
  Process 1920 waits for ExclusiveLock on tuple (42, 10) of relation 'accounts'; blocked by process 1845.
  ```

---

## 2. Immediate Diagnostic Queries

### Inspect Active Lock Wait Graph:
```sql
SELECT 
    blocked_locks.pid     AS blocked_pid,
    blocked_activity.usename  AS blocked_user,
    blocking_locks.pid    AS blocking_pid,
    blocking_activity.usename AS blocking_user,
    blocked_activity.query    AS blocked_statement,
    blocking_activity.query   AS blocking_statement
FROM  pg_catalog.pg_locks         blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks         blocking_locks 
    ON blocking_locks.locktype = blocked_locks.locktype
    AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
    AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
    AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
    AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
    AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
    AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
    AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
    AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
    AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
    AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted;
```

---

## 3. Root Cause Mitigation & Prevention

### 1. Enforce Consistent Lock Ordering
The primary cause of deadlocks is inconsistent access order across concurrent threads:
- **Thread A:** Locks Account 101, then requests Account 202.
- **Thread B:** Locks Account 202, then requests Account 101.
- **Fix:** Sort account IDs deterministically before acquiring locks:
  ```java
  List<Long> sortedIds = Stream.of(fromId, toId).sorted().toList();
  // Lock sortedIds.get(0) first, then sortedIds.get(1)
  ```

### 2. Set Aggressive Lock Timeouts
Prevent queries from waiting indefinitely for locks:
```sql
SET lock_timeout = '3000'; -- Abort if lock cannot be acquired within 3 seconds
```

### 3. Application-Level Retries
Deadlocks are transient concurrency collisions. Ensure application service methods caught in a deadlock catch `CannotAcquireLockException` and retry with exponential jitter.

---

## 4. Authoritative References
- [PostgreSQL Explicit Locking Documentation](https://www.postgresql.org/docs/current/explicit-locking.html)
- [PostgreSQL Deadlock Detection Parameters](https://www.postgresql.org/docs/current/runtime-config-client.html#GUC-DEADLOCK-TIMEOUT)
