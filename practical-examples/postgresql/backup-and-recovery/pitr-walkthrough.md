# Practical Guide: Point-In-Time Recovery (PITR) in PostgreSQL

Point-In-Time Recovery (PITR) allows restoring a PostgreSQL database to the exact millisecond before an accidental disaster (e.g., an unauthorized `DROP TABLE` or corrupting script).

---

## 1. How PITR Works Internally
PITR relies on two physical artifacts:
1. **Physical Base Backup:** A filesystem-level snapshot of the database cluster taken via `pg_basebackup`.
2. **Continuous WAL Archive:** Continuous stream of archived WAL segments written by `archive_command` or streamed to an S3 bucket (e.g., via pgBackRest or WAL-G).

Recovery restores the base backup, reads through the archived WAL segments sequentially, and stops at the precise target timestamp (`recovery_target_time`).

---

## 2. Step-by-Step Production PITR Simulation

### Step 1: Ensure Archiving is Active on Primary
In `postgresql.conf`:
```ini
wal_level = replica
archive_mode = on
archive_command = 'cp %p /var/lib/postgresql/wal_archive/%f'
```

### Step 2: Take Base Backup
```bash
pg_basebackup -h localhost -p 5432 -U postgres -D /var/lib/postgresql/basebackup_2026_01 -Fp -Xs -P -v
```

### Step 3: Record Timestamp & Disaster Occurs
```sql
-- Normal business activity
INSERT INTO accounts (id, balance) VALUES (1, 1000.00);

-- Record timestamp BEFORE disaster:
SELECT clock_timestamp(); 
-- Result: '2026-10-23 14:15:30.123456+00'

-- DISASTER: Rogue script runs at 14:16:00
DROP TABLE accounts;
```

### Step 4: Execute PITR Restore
```bash
# 1. Stop PostgreSQL server
sudo systemctl stop postgresql

# 2. Move broken data directory to safe storage
mv /var/lib/postgresql/data /var/lib/postgresql/data_broken

# 3. Restore data files from base backup
cp -a /var/lib/postgresql/basebackup_2026_01 /var/lib/postgresql/data

# 4. Create recovery signal file (PostgreSQL 12+)
touch /var/lib/postgresql/data/recovery.signal

# 5. Append recovery parameters in postgresql.conf:
cat <<EOF >> /var/lib/postgresql/data/postgresql.conf
restore_command = 'cp /var/lib/postgresql/wal_archive/%f %p'
recovery_target_time = '2026-10-23 14:15:30+00'
recovery_target_action = 'promote'
EOF

# 6. Start PostgreSQL
sudo systemctl start postgresql
```

### Step 5: Verification
Connect to PostgreSQL and verify `accounts` table exists with balance intact!
```sql
SELECT * FROM accounts;
-- Returns row (1, 1000.00) intact!
```
