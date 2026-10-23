# Practical Lab: PostgreSQL Declarative Partitioning

This lab demonstrates setting up declarative range partitioning, verifying partition distribution, confirming partition pruning with `EXPLAIN ANALYZE`, and performing concurrent partition detachment for zero-downtime historical data archival.

---

## 1. Prerequisites
- PostgreSQL 12+ (local instance or Docker container).

---

## 2. Lab Execution Steps

### Step 1: Run Schema & Data Setup
```bash
psql -h localhost -p 5432 -U postgres -d app_db -f setup-partitions.sql
```

### Step 2: Run Verification & Pruning Checks
```bash
psql -h localhost -p 5432 -U postgres -d app_db -f verify-pruning.sql
```

### Step 3: Cleanup Environment
```bash
psql -h localhost -p 5432 -U postgres -d app_db -f cleanup.sql
```

---

## 3. Key Observations
1. **Partition Pruning:** When executing a date-filtered query, the PostgreSQL optimizer completely omits non-matching child tables, reducing disk I/O.
2. **Instant Archival:** `ALTER TABLE ... DETACH PARTITION ... CONCURRENTLY` instantly detaches historical partitions in milliseconds without locking the logical parent table.
