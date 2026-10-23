# Slow Query Analysis & Performance Profiling

> **Category:** Database Performance  
> **Target Audience:** SREs, Performance Engineers, Database Administrators  
> **Tooling:** `pg_stat_statements`, MySQL Slow Query Log, PMM

---

## 1. Automated Profiling with `pg_stat_statements`

The single most valuable tool for diagnosing query performance in PostgreSQL is the official extension `pg_stat_statements`. It records normalized query fingerprints across all client sessions.

### Installation in `postgresql.conf`:
```ini
shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.track = all
pg_stat_statements.max = 10000
```

### Finding the Greatest Resource Drains:
```sql
SELECT 
    query,
    calls,
    round(total_exec_time::numeric, 2) AS total_exec_ms,
    round(mean_exec_time::numeric, 2) AS avg_exec_ms,
    round((shared_blks_read * 8192 / 1024 / 1024)::numeric, 2) AS disk_read_mb,
    round((shared_blks_hit * 8192 / 1024 / 1024)::numeric, 2) AS memory_hit_mb
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;
```

---

## 2. PostgreSQL Active Wait Events Analysis
When a query is slow, inspect what the executing OS thread is waiting on:
```sql
SELECT 
    wait_event_type, 
    wait_event, 
    count(*) AS waiting_queries
FROM pg_stat_activity
WHERE state = 'active'
GROUP BY wait_event_type, wait_event
ORDER BY waiting_queries DESC;
```
- **`IO / DataFileRead`:** Query is stalled reading cold pages from physical disk into buffer cache. Add memory or indexes.
- **`Lock / relation`:** Queries are blocked waiting for an exclusive table lock held by a DDL statement (`ALTER TABLE`, `VACUUM FULL`).
- **`IPC / BufferPin`:** Massive concurrency contention on hot shared memory buffers.

---

## 3. Authoritative References
- [PostgreSQL pg_stat_statements Documentation](https://www.postgresql.org/docs/current/pgstatstatements.html)
- [PostgreSQL Wait Events Catalog](https://www.postgresql.org/docs/current/monitoring-stats.html#WAIT-EVENT-TABLE)
