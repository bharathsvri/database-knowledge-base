# PostgreSQL Release History & Version Roadmap

> **Data Source:** PostgreSQL Global Development Group (PGDG)  
> **Status Verification Date:** 2026-10-23

---

## PostgreSQL Major Release Lifecycle Overview

PostgreSQL releases a new major version approximately once per year (typically September/October). Each major version is officially supported for **5 years** with regular quarterly minor releases containing bug fixes and security patches.

```mermaid
flowchart LR
    v12["PG 12 (EOL Nov 2024)"] --> v13["PG 13 (EOL Nov 2025)"]
    v13 --> v14["PG 14 (EOL Nov 2026)"]
    v14 --> v15["PG 15 (EOL Nov 2027)"]
    v15 --> v16["PG 16 (EOL Nov 2028)"]
```

---

## Detailed Version Milestone Table

| Major Version | Initial Release Date | Final Support / EOL Date | Support Status (as of 2026-10-23) | Landmark Architectural Capabilities |
| :---: | :---: | :---: | :---: | :--- |
| **PostgreSQL 16** | 2023-09-14 | 2028-11-09 | **Supported** | Logical replication from standbys; `pg_stat_io` view; parallel Hash Right/Full joins; SIMD JSON acceleration. |
| **PostgreSQL 15** | 2022-10-13 | 2027-11-11 | **Supported** | SQL-standard `MERGE`; zstd/lz4 WAL and basebackup compression; logical replication row/column filters; public schema permissions tightened. |
| **PostgreSQL 14** | 2021-09-30 | 2026-11-12 | **Supported** | B-Tree index bloat reduction under high concurrency; multirange types; stored procedure `OUT` parameters; LZ4 TOAST compression. |
| **PostgreSQL 13** | 2020-09-24 | 2025-11-13 | **Supported (Approaching EOL)** | B-Tree index deduplication; parallel vacuuming for indexes; incremental sorting; hash aggregations using disk. |
| **PostgreSQL 12** | 2019-10-03 | 2024-11-14 | **End of Life (EOL)** | Complete rewrite of declarative table partitioning (fast pruning); inline CTEs; `REINDEX CONCURRENTLY`; pluggable table storage. |
| **PostgreSQL 11** | 2018-10-18 | 2023-11-09 | **End of Life (EOL)** | Declarative hash partitioning; default partitions; partition-wise joins; JIT compilation for expressions; stored procedures (`CALL`). |
| **PostgreSQL 10** | 2017-10-05 | 2022-11-10 | **End of Life (EOL)** | Introduction of native declarative partitioning (`PARTITION BY`); native logical replication; SCRAM-SHA-256 authentication. |

---

## Authoritative Reference
- [PostgreSQL Versioning Policy & Roadmap](https://www.postgresql.org/support/versioning/)
