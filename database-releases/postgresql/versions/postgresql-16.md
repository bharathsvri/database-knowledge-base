# PostgreSQL 16

## Release Information

- **Product:** PostgreSQL
- **Version:** 16.0 (and subsequent minor updates 16.1–16.4)
- **Release date:** 2023-09-14
- **Release type:** Major GA
- **Support status:** Supported (Active until 2028-11-09, checked 2026-10-23)
- **Official release notes:** [PostgreSQL 16 Release Notes](https://www.postgresql.org/docs/16/release-16.html)

## New Features
- **Logical Replication from Standby Servers:** Standby instances can now serve as logical replication publishers, offloading CDC and ETL decoding workloads from the primary node.
- **`pg_stat_io` View:** Comprehensive system view providing fine-grained observability into disk I/O metrics across tables, indexes, vacuuming, and temporary files.
- **SQL/JSON Syntax Support:** Full support for SQL-standard JSON constructors (`JSON_ARRAY()`, `JSON_OBJECT()`) and predicates (`IS JSON`).
- **Parallel Execution Enhancements:** Query planner can now parallelize `FULL` and `RIGHT` hash outer joins.
- **Non-Decimal Integer Literals:** Native support for binary (`0b101`), octal (`0o755`), and hexadecimal (`0xFF`) literals in SQL queries.

## Breaking Changes
- **Reserved Keywords:** New SQL/JSON keywords (`JSON`, `JSON_ARRAY`, `JSON_OBJECT`, `WITHOUT`) are now reserved words, requiring quotes if used as column names.
- **Removal of `vacuum_cost_page_miss`:** Removed in favor of unified I/O accounting parameters.
- **Subquery Plan Invalidation:** Stricter validation of push-down predicates may alter plans for malformed legacy queries.

## Deprecated or Removed Features
- **Removed:** Configuration parameter `vacuum_cost_page_miss` (replaced by unified cost tracking).
- **Deprecated:** Legacy regex functions replaced by SQL standard regex equivalents.

## Security Fixes
PostgreSQL 16 incorporated critical fixes accumulated across previous release cycles:
- **CVE-2023-39417:** Fix for extension script SQL injection vulnerabilities during `CREATE EXTENSION`.
- Enforced SCRAM-SHA-256 by default in `pg_hba.conf` templates.

## Performance Improvements
- **SIMD CPU Acceleration:** Optimized ASCII string validation, JSON parsing, and vector calculations using modern CPU SIMD instruction sets (AVX-512, NEON).
- **Bulk Loading Enhancements:** Up to 300% performance improvement on concurrent `COPY` commands into partitioned tables.
- **Vacuum Memory Limits:** Introduction of `vacuum_buffer_usage_limit` preventing aggressive autovacuum from evicting hot OLTP pages from shared buffers.

## Compatibility
- Supported Client Drivers: PostgreSQL JDBC 42.6+, pgx v5, Npgsql 7.0+.
- Operating Systems: Linux (RHEL 8/9, Ubuntu 20.04/22.04/24.04), Windows Server 2019/2022, macOS.

## Upgrade Prerequisites
- Run `pg_upgrade --check` to verify catalog and extension compatibility.
- Ensure at least 20% free disk space for temporary catalog structures.
- Verify that third-party extensions (PostGIS, timescaledb) have compiled binaries for PostgreSQL 16.

## Upgrade Procedure
```bash
# 1. Install PostgreSQL 16 binaries alongside existing PostgreSQL 15 installation
sudo apt-get install postgresql-16 postgresql-client-16

# 2. Stop both clusters
sudo systemctl stop postgresql@15-main
sudo systemctl stop postgresql@16-main

# 3. Execute fast link-mode upgrade (takes seconds on terabyte databases)
sudo -u postgres /usr/lib/postgresql/16/bin/pg_upgrade \
  --old-datadir=/var/lib/postgresql/15/main \
  --new-datadir=/var/lib/postgresql/16/main \
  --old-bindir=/usr/lib/postgresql/15/bin \
  --new-bindir=/usr/lib/postgresql/16/bin \
  --old-options='-c config_file=/etc/postgresql/15/main/postgresql.conf' \
  --new-options='-c config_file=/etc/postgresql/16/main/postgresql.conf' \
  --link --check

# 4. If check succeeds, re-run without --check
sudo -u postgres /usr/lib/postgresql/16/bin/pg_upgrade ... --link
```

## Post-Upgrade Validation
```sql
-- 1. Check version banner
SELECT version();

-- 2. Verify all tables and physical counts
SELECT count(*) FROM pg_tables WHERE schemaname NOT IN ('pg_catalog', 'information_schema');

-- 3. Crucial: Generate optimizer statistics immediately
-- (pg_upgrade does NOT copy optimizer statistics!)
VACUUM ANALYZE;
```

## Rollback and Recovery Considerations
> [!WARNING]
> When using `pg_upgrade --link`, hard links are created between old and new files. Once PostgreSQL 16 starts and writes to these files, the old cluster is modified and cannot be started. Rollback requires restoring from a pre-upgrade physical storage snapshot or basebackup.

## Interview-Relevant Changes
- **"What was the biggest replication enhancement in PostgreSQL 16?"**  
  *Answer:* Logical replication can now run on standby servers! Previously, logical decoding required connecting directly to the primary, adding CPU and WAL retention burden to the writer node.

## References
- [PostgreSQL 16 Press Release](https://www.postgresql.org/about/news/postgresql-16-released-2703/)
- [PostgreSQL pg_stat_io Documentation](https://www.postgresql.org/docs/16/monitoring-stats.html#PG-STAT-IO-VIEW)
