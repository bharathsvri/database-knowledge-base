# PostgreSQL 15

## Release Information

- **Product:** PostgreSQL
- **Version:** 15.0 (and subsequent minor updates 15.1–15.8)
- **Release date:** 2022-10-13
- **Release type:** Major GA
- **Support status:** Supported (Active until 2027-11-11, checked 2026-10-23)
- **Official release notes:** [PostgreSQL 15 Release Notes](https://www.postgresql.org/docs/15/release-15.html)

## New Features
- **SQL-Standard `MERGE` Command:** Introduced standard conditional insert/update/delete syntax (`MERGE INTO target USING source ON (...) WHEN MATCHED THEN UPDATE ...`).
- **Modern Compression Algorithms:** Native support for Zstandard (zstd) and LZ4 compression in Write-Ahead Logs (`wal_compression = zstd`), table TOAST data, and `pg_basebackup`.
- **Logical Replication Row Filters and Column Lists:** Publishers can now define `WHERE` clauses to replicate subsets of rows and filter out sensitive or bulky columns.
- **Structured Server Logging (JSON):** Added `jsonlog` log format for direct ingestion into Elasticsearch, Datadog, and Fluentd without complex regex parsing.

## Breaking Changes
- **Revocation of Public Schema Permissions:** Removed the default `CREATE` permission on the `public` schema for all non-superusers (`REVOKE CREATE ON SCHEMA public FROM PUBLIC;`). Applications connecting with non-superusers will fail to create tables in `public` unless explicitly granted `GRANT CREATE ON SCHEMA public TO app_user;`.
- **Removal of Python 2 Support in PL/Python:** PL/Python now strictly requires Python 3.

## Deprecated or Removed Features
- **Removed:** `exclusive backup` mode (`pg_start_backup(..., true)`). Non-exclusive backups via `pg_basebackup` are now mandatory.
- **Removed:** Parameter `stats_temp_directory` (in-memory statistics collector replaced with shared memory architecture).

## Security Fixes
- Hardening against CVE-2022-1552 (autovacuum execution privilege escalation).
- Public schema permission restriction prevents untrusted users from hijacking objects created by superusers.

## Performance Improvements
- **In-Memory Shared Memory Cumulative Stats:** Eliminated the legacy background stats collector process; statistics are now recorded directly in shared memory, dramatically reducing disk I/O and latency spikes.
- **Sorting Enhancements:** In-memory and on-disk sorting algorithms optimized, yielding 25% to 400% speedups for queries with `ORDER BY`.
- **Window Functions:** Memory optimization for window functions (`row_number()`, `rank()`).

## Compatibility
- Client drivers: PostgreSQL JDBC 42.5+, libpq, Npgsql.
- Schema migration tools (Flyway, Liquibase) required updates to accommodate the public schema permission revocation.

## Upgrade Prerequisites
- Review database users to ensure non-superusers have explicit `GRANT CREATE ON SCHEMA public` or dedicated application schemas.
- Backup physical data directory using `pg_basebackup`.

## Upgrade Procedure
```bash
# Verify compatibility
sudo -u postgres /usr/lib/postgresql/15/bin/pg_upgrade \
  --old-datadir=/var/lib/postgresql/14/main \
  --new-datadir=/var/lib/postgresql/15/main \
  --old-bindir=/usr/lib/postgresql/14/bin \
  --new-bindir=/usr/lib/postgresql/15/bin \
  --link --check

# Execute upgrade
sudo -u postgres /usr/lib/postgresql/15/bin/pg_upgrade ... --link
```

## Post-Upgrade Validation
```sql
SELECT version();
VACUUM ANALYZE;
```

## Rollback and Recovery Considerations
> [!WARNING]
> Upgrading using `pg_upgrade --link` cannot be rolled back in-place. A full base backup or disk snapshot prior to upgrading must be retained until validation completes.

## Interview-Relevant Changes
- **"What security change in PostgreSQL 15 broke many legacy applications?"**  
  *Answer:* The revocation of `CREATE` permission on the `public` schema from `PUBLIC`. Previously, any newly created user could create tables in the public schema. Starting in PG 15, administrators must explicitly grant schema permissions.

## References
- [PostgreSQL 15 Release Announcement](https://www.postgresql.org/about/news/postgresql-15-released-2525/)
- [PostgreSQL MERGE Documentation](https://www.postgresql.org/docs/15/sql-merge.html)
