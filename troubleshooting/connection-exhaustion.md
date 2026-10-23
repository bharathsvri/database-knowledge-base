# Incident Runbook: Database Connection Exhaustion

> **Severity Level:** SEV-1 (Critical Outage)  
> **Affected Systems:** Primary Database, All Application Services  
> **Target Audience:** SREs, Incident Commanders, Database Administrators

---

## 1. Symptom & Alert Trigger
- **Alert:** `PostgresActiveConnectionsRatio > 95%` or application logs reporting:
  ```text
  FATAL: remaining connection slots are reserved for non-replication superuser connections
  org.postgresql.util.PSQLException: FATAL: 53300: sorry, too many clients already
  ```
- **User Impact:** All HTTP requests fail with HTTP 500 / 503; microservices crash or fail health probes.

---

## 2. Immediate Diagnostic Steps (Emergency Triage)

### Step 1: Connect via Reserved Superuser Slot
PostgreSQL reserves `superuser_reserved_connections` (default 3) so administrators can connect even during exhaustion:
```bash
psql -h localhost -p 5432 -U postgres -d postgres
```

### Step 2: Identify Who is Consuming Connections
```sql
SELECT 
    usename, 
    client_addr, 
    application_name, 
    state, 
    count(*) AS connection_count
FROM pg_stat_activity
GROUP BY usename, client_addr, application_name, state
ORDER BY connection_count DESC;
```

### Step 3: Check for "Idle in Transaction" Sessions
Often, connections are held idle because of an uncommitted transaction:
```sql
SELECT 
    pid, 
    usename, 
    client_addr, 
    now() - state_change AS idle_duration, 
    query
FROM pg_stat_activity
WHERE state = 'idle in transaction'
ORDER BY idle_duration DESC;
```

---

## 3. Immediate Mitigation Steps

### Terminate Idle in Transaction Sessions Immediately
```sql
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE state = 'idle in transaction'
  AND state_change < clock_timestamp() - INTERVAL '60 seconds'
  AND pid <> pg_backend_pid();
```

### Terminate Leaked Application Connections
If a single service pod has auto-scaled to 50 replicas and opened 50 connections each:
```sql
-- Terminate connections from offending service:
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE application_name = 'rogue-service-name';
```

---

## 4. Permanent Preventive Actions
1. **Enforce `idle_in_transaction_session_timeout`:**
   In `postgresql.conf`:
   ```ini
   idle_in_transaction_session_timeout = '30000' # Kills session after 30s idle
   ```
2. **Deploy PgBouncer in Transaction Pooling Mode:**
   Multiplexes 5,000 application connections onto 50 physical backend slots.
3. **Right-Size Client HikariCP Pools:**
   Reduce `maximumPoolSize` from 50 to 5–10 per microservice pod.

---

## 5. Authoritative References
- [PostgreSQL Connection Settings](https://www.postgresql.org/docs/current/runtime-config-connection.html)
- [PgBouncer Pooling Guide](https://www.pgbouncer.org/)
