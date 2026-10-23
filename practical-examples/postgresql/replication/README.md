# Practical Lab: PostgreSQL Streaming Replication with Docker Compose

This hands-on lab demonstrates physical streaming replication between a Primary PostgreSQL 16 container and a Standby Read Replica container using Docker Compose.

---

## 1. Prerequisites
- Docker Engine 20.10+ and Docker Compose v2.0+
- `psql` command-line client or GUI (DBeaver / DataGrip)

---

## 2. Environment Startup
From this directory, run:
```bash
docker compose up -d
```
Check logs to verify the replica cloned the base backup and entered standby recovery:
```bash
docker compose logs -f pg-replica
```
*Expected log output:*
```text
pg-replica | entering standby mode
pg-replica | redo starts at 0/1600028
pg-replica | consistent recovery state reached at 0/1600100
pg-replica | database system is ready to accept read only connections
pg-replica | started streaming WAL from primary at 0/1700000 on timeline 1
```

---

## 3. Replication Verification & Testing

### Test 1: Verify Role and Status
Connect to Primary (port 5432):
```bash
psql -h localhost -p 5432 -U app_admin -d app_db -c "SELECT pg_is_in_recovery();"
# Returns: f (false -> Primary)
```
Connect to Standby (port 5433):
```bash
psql -h localhost -p 5433 -U app_admin -d app_db -c "SELECT pg_is_in_recovery();"
# Returns: t (true -> Standby Replica)
```

### Test 2: Measure Replication Lag on Primary
```sql
-- Connect to localhost:5432
SELECT 
    client_addr, 
    application_name, 
    state, 
    sync_state,
    pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn) AS replay_byte_lag
FROM pg_stat_replication;
```

### Test 3: Write-Replication Propagation Test
```bash
# 1. Insert new row on Primary:
psql -h localhost -p 5432 -U app_admin -d app_db -c \
  "INSERT INTO customer_orders (customer_name, amount) VALUES ('Initech Solutions', 999.99);"

# 2. Immediately query Standby:
psql -h localhost -p 5433 -U app_admin -d app_db -c \
  "SELECT * FROM customer_orders WHERE customer_name = 'Initech Solutions';"
# Output shows the replicated row!

# 3. Attempt write on Standby (verifies read-only protection):
psql -h localhost -p 5433 -U app_admin -d app_db -c \
  "INSERT INTO customer_orders (customer_name, amount) VALUES ('Hacker Corp', 1.00);"
# Output:
# ERROR: cannot execute INSERT in a read-only transaction
```

---

## 4. Failure Scenarios & Troubleshooting
- **Replica fails to start with "directory not empty":** The replica initialization script clears `/var/lib/postgresql/data/*` before running `pg_basebackup`. Ensure persistent volume permissions allow writes.
- **High byte lag:** Check network latency between containers or run heavy bulk updates to observe lag spikes in `pg_stat_replication`.

---

## 5. Teardown & Cleanup
```bash
docker compose down -v
```
