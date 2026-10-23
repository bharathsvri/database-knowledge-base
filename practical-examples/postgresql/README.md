# PostgreSQL Practical Engineering Labs

This directory contains production-style practical labs and runnable SQL scripts for PostgreSQL 14, 15, and 16.

---

## Lab Modules

| Lab Module | Directory | Topics & Scenarios |
| :--- | :--- | :--- |
| **Streaming Replication** | [`replication/`](replication/) | Docker Compose multi-node cluster, WAL sender/receiver setup, lag inspection queries, failover demo. |
| **Declarative Partitioning** | [`partitioning/`](partitioning/) | Range partitioning on timestamps, local indexes, partition pruning verification, atomic detachment. |
| **Advanced Indexing** | [`indexing/`](indexing/) | B-Tree covering indexes with `INCLUDE`, GIN indexes on JSONB, partial indexes. |
| **Backup & Recovery** | [`backup-and-recovery/`](backup-and-recovery/) | Logical `pg_dump`, physical `pg_basebackup`, and Point-In-Time Recovery (PITR) with WAL replay. |
