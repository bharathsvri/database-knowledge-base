# Point-In-Time Recovery (PITR) Architecture

> **Category:** Database Backup & Recovery  
> **Target Audience:** Systems Architects, Database Administrators, SREs

---

## 1. What is Point-In-Time Recovery (PITR)?
**Point-In-Time Recovery (PITR)** is an advanced database recovery mechanism that combines a physical base backup with continuous Write-Ahead Log (WAL) archiving to restore a database to any arbitrary second or transaction boundary in the past.

---

## 2. PITR Internal Mechanics

```mermaid
sequenceDiagram
    autonumber
    participant Base as Physical Base Backup (02:00 AM)
    participant WAL as Archived WAL Stream (02:00 AM - 04:30 PM)
    participant Recovery as Recovery Engine (Startup Process)

    Note over Recovery: Restore physical files from 02:00 AM Base Backup
    Recovery->>Base: Copy data files into PGDATA
    Note over Recovery: Create recovery.signal and set target time (04:15:30 PM)
    
    loop Replay WAL Segments
        Recovery->>WAL: Fetch WAL file via restore_command
        Recovery->>Recovery: Replay transaction changes sequentially
    end

    Note over Recovery: Target timestamp reached at 04:15:30 PM!
    Recovery->>Recovery: Stop replay; PROMOTE to new timeline
    Note over Recovery: Database opened for read-write!
```

---

## 3. Configuration Parameters in PostgreSQL 12+

In modern PostgreSQL, PITR parameters are configured directly in `postgresql.conf` alongside an empty `recovery.signal` trigger file:

```ini
# Restore command used to fetch archived WAL segments from S3 or local disk
restore_command = 'aws s3 cp s3://company-db-wal-archive/%f %p'

# Target timestamp for recovery cessation (ISO 8601 format)
recovery_target_time = '2026-10-23 16:15:30+00'

# What to do when target is reached ('promote' opens DB for read-write immediately)
recovery_target_action = 'promote'

# Whether to stop before or including the target transaction
recovery_target_inclusive = false
```

---

## 4. Authoritative References
- [PostgreSQL Continuous Archiving and PITR](https://www.postgresql.org/docs/current/continuous-archiving.html)
