# Database Backup Strategies: Logical vs Physical vs Snapshot

> **Category:** Database Backup & Recovery  
> **Target Audience:** Database Engineers, SREs, Systems Architects

---

## 1. Executive Summary of Backup Types

| Dimension | Logical Backups (`pg_dump` / `mysqldump`) | Physical Backups (`pg_basebackup` / Percona XtraBackup) | Storage Snapshots (AWS EBS / ZFS / LVM) |
| :--- | :--- | :--- | :--- |
| **Mechanic** | Queries database tables and generates SQL text (`CREATE TABLE`, `INSERT`) or proprietary binary archives. | Copies physical data pages and WAL files byte-for-byte directly from filesystem. | Hypervisor / OS level copy-on-write disk block snapshot. |
| **Speed (Backup)** | **Slow:** Must execute SQL queries and serialize every tuple (Hours for 1 TB). | **Fast:** Sequential disk/network I/O (Minutes to 1 hour for 1 TB). | **Near Instantaneous:** Seconds (snapshot pointer created immediately). |
| **Speed (Restore)** | **Extremely Slow:** Must re-execute inserts and rebuild all B-Tree indexes from scratch. | **Fast:** Copies physical files and replays recent WAL. | **Instantaneous:** Fast volume attach and block hydration. |
| **Granularity** | Highly flexible: Can restore a single table, single schema, or subset of rows. | All-or-nothing: Restores the entire database cluster. | All-or-nothing: Restores the entire disk volume. |
| **Engine Portability** | High: Can restore across different operating systems or PostgreSQL minor versions. | Low: Must restore to identical engine major version and CPU architecture. | Strict: Bound to cloud provider volume infrastructure. |

---

## 2. The 3-2-1 Enterprise Backup Rule
A resilient enterprise backup strategy mandates:
- **3 Copies of Data:** Production database + Primary backup + Secondary replica/archive.
- **2 Different Storage Media:** High-performance NVMe EBS snapshots + Cold S3 object storage.
- **1 Off-Site / Cross-Region Copy:** Replicated to a secondary geographic cloud region or air-gapped security account.

---

## 3. Recommended Production Schedule
- **Continuous:** Continuous WAL archiving (enabling PITR down to the second).
- **Daily:** Automated physical snapshot or `pg_basebackup` taken during low-traffic windows.
- **Weekly:** Automated logical dump for granular single-table corruption recovery and cross-version insurance.

---

## 4. Authoritative References
- [PostgreSQL Backup and Restore Documentation](https://www.postgresql.org/docs/current/backup.html)
