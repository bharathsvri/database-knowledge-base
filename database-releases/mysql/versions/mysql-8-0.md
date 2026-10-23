# MySQL 8.0

## Release Information

- **Product:** MySQL
- **Version:** 8.0 (Initial GA 8.0.11, through maintenance releases 8.0.36+)
- **Release date:** 2018-04-19
- **Release type:** Major Mainstream
- **Support status:** Supported (Approaching EOL in April 2026, checked 2026-10-23)
- **Official release notes:** [MySQL 8.0 Release Notes](https://dev.mysql.com/doc/relnotes/mysql/8.0/en/)

## New Features
- **Transactional Data Dictionary:** Completely removed legacy `.frm` metadata files. All dictionary metadata is stored transactionally in standard InnoDB tables.
- **Window Functions:** Native SQL-standard window functions (`ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `LEAD()`, `LAG()`).
- **Common Table Expressions (CTEs):** Support for non-recursive and recursive CTEs (`WITH ...`).
- **Default `utf8mb4` Character Set:** Replaced legacy 3-byte `utf8` (`utf8mb3`) with complete 4-byte Unicode UTF-8 (`utf8mb4_0900_ai_ci`).
- **Instant DDL:** Added capability to add columns to large tables instantly without rebuilding table data pages (`ALGORITHM=INSTANT`).

## Breaking Changes
- **Default Authentication Plugin:** Shifted default authentication to `caching_sha2_password` (older PHP/Python/Java drivers failed until upgraded).
- **Default Charset Collations:** Changing default charset to `utf8mb4` altered string sorting and index length limits (up to 3072 bytes).
- **Reserved Keywords:** Added `GROUPS`, `RANK`, `WINDOW`, `SYSTEM`, `ADMIN` to reserved words.

## Deprecated or Removed Features
- **Removed:** Query Cache (`query_cache_type`, `query_cache_size`) completely removed due to severe multi-core write locking contention.
- **Deprecated:** `mysql_native_password` (eventually removed in 8.4).

## Security Fixes
- Addressed multiple OpenSSL CVEs and added password expiration and reuse policies.
- Introduced SQL Roles (`CREATE ROLE`, `GRANT ROLE`) for structured RBAC.

## Performance Improvements
- **Hash Joins:** Replaced legacy block nested loop joins with in-memory hash joins for non-equi joins.
- **Resource Groups:** CPU affinity mapping to prioritize OLTP workloads over background batch tasks.
- **Invisible Indexes:** Capability to toggle index visibility to the query optimizer (`ALTER INDEX ... INVISIBLE`) before dropping it.

## Compatibility
- Client drivers: MySQL Connector/J 8.0+, modern ODBC, Python MySQL connector.

## Upgrade Prerequisites
- Run MySQL 8.0 pre-upgrade check script against MySQL 5.7.
- Fix all tables with incompatible partitioned MyISAM engines (InnoDB conversion mandatory).

## Upgrade Procedure
```bash
# Verify compatibility on MySQL 5.7
mysqlcheck -u root -p --all-databases --check-upgrade

# Shutdown MySQL 5.7 gracefully
mysql -u root -p -e "SET GLOBAL innodb_fast_shutdown = 0;"
systemctl stop mysql

# Install 8.0 packages and start
systemctl start mysql
```

## Post-Upgrade Validation
```sql
SELECT VERSION();
CHECK TABLE mysql.user;
```

## Rollback and Recovery Considerations
> [!WARNING]
> Downgrading from MySQL 8.0 to 5.7 is impossible in-place because MySQL 5.7 cannot parse the new transactional data dictionary. Rollback requires restoring a MySQL 5.7 backup.

## Interview-Relevant Changes
- **"Why was the MySQL Query Cache removed in 8.0?"**  
  *Answer:* The Query Cache required a global mutex lock. Any modification to a table invalidated all cached queries referencing that table across the entire server, creating severe lock contention on modern multi-core machines. Application-level caching (Redis) is vastly superior.

## References
- [MySQL 8.0 Reference Manual](https://dev.mysql.com/doc/refman/8.0/en/)
- [MySQL 8.0 GA Announcement](https://blogs.oracle.com/mysql/post/announcing-general-availability-of-mysql-80)
