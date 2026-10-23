# MySQL 8.4 LTS

## Release Information

- **Product:** MySQL
- **Version:** 8.4.0 LTS
- **Release date:** 2024-04-30
- **Release type:** Long-Term Support (LTS)
- **Support status:** Supported (Active LTS until 2029-04-30, Extended Support until 2032; checked 2026-10-23)
- **Official release notes:** [MySQL 8.4 LTS Release Notes](https://dev.mysql.com/doc/relnotes/mysql/8.4/en/)

## New Features
- **First Official LTS Release:** Establishes the new baseline for enterprise stability with 5 years of premier bug fixes and security maintenance without disruptive syntax deprecations.
- **Group Replication Modernization:** Enhanced automatic primary failover election weights, improved network partitioning handling, and faster distributed state synchronization.
- **Clone Plugin Enhancements:** Improved remote provisioning and instant donor replica bootstrapping over secure network endpoints.
- **Native MySQL Telemetry:** Built-in OpenTelemetry tracing integration for database query lifecycle and execution spans.

## Breaking Changes
- **`mysql_native_password` Disabled by Default:** The legacy authentication plugin `mysql_native_password` is no longer loaded by default. Connections using legacy JDBC or client connectors will fail unless migrated to `caching_sha2_password` or explicitly loaded via `--mysql-native-password=ON`.
- **Default Replication Terminology:** Replaced legacy terms (`MASTER`, `SLAVE`) in configuration files and status outputs with SQL standard terms (`SOURCE`, `REPLICA`). Configurations retaining legacy syntax throw errors.

## Deprecated or Removed Features
- **Removed:** Legacy replication commands (`CHANGE MASTER TO` completely replaced by `CHANGE REPLICATION SOURCE TO`).
- **Removed:** Old cryptographic variables replaced by OpenSSL 3.0 standards.

## Security Fixes
- Addressed multiple OpenSSL and CPU timing side-channel attack vectors in client authentication handshakes.
- Enforced TLS 1.3 as preferred protocol for client-server and replication communication.

## Performance Improvements
- **InnoDB Buffer Pool Parallel Read-Ahead:** Optimized asynchronous disk page prefetching on NVMe SSD arrays.
- **Histogram-Driven Optimizer Cost Model:** Dynamic sample collection for statistics reduces suboptimal join plans in queries with complex nested predicates.

## Compatibility
- Client drivers: MySQL Connector/J 8.3+, Connector/Python 8.3+, modern JDBC drivers supporting `caching_sha2_password`.
- Operating Systems: Oracle Linux 8/9, Ubuntu 22.04/24.04, RHEL 8/9, Windows Server 2022.

## Upgrade Prerequisites
- Run MySQL Upgrade Checker (`mysql-shell -e "util.checkForServerUpgrade()"`) against the existing 8.0 instance.
- Verify all database user accounts are using `caching_sha2_password`.
- Take a consistent physical backup with MySQL Enterprise Backup or Percona XtraBackup.

## Upgrade Procedure
```bash
# 1. Check readiness using MySQL Shell
mysqlsh root@localhost:3306 -- util checkForServerUpgrade

# 2. Perform slow shutdown on MySQL 8.0 (cleans undo and redo logs)
mysql -u root -p -e "SET GLOBAL innodb_fast_shutdown = 0;"
systemctl stop mysqld

# 3. Install MySQL 8.4 LTS binaries
sudo dpkg -i mysql-server_8.4.*.deb

# 4. Start MySQL 8.4 (automatically updates transactional data dictionary)
systemctl start mysqld
```

## Post-Upgrade Validation
```sql
-- 1. Check version
SELECT VERSION();

-- 2. Check server error log for upgrade completion
-- Tail /var/log/mysql/error.log for:
-- "[Server] Server upgrade from 80000 to 80400 completed."
```

## Rollback and Recovery Considerations
> [!WARNING]
> MySQL data dictionary upgrades alter physical data dictionaries in-place. A downgrade from 8.4 to 8.0 is **unsupported** without a full logical dump (`mysqldump` / `mysqlpump`) or restoring from a physical pre-upgrade backup snapshot.

## Interview-Relevant Changes
- **"What breaking authentication change occurred in MySQL 8.4 LTS?"**  
  *Answer:* The removal of `mysql_native_password` as the default authentication plugin. Applications running legacy database drivers without SHA-256 caching support will fail to connect until drivers are upgraded or the legacy plugin is manually enabled.

## References
- [MySQL 8.4 Reference Manual](https://dev.mysql.com/doc/refman/8.4/en/)
- [MySQL Introducing 8.4 LTS](https://blogs.oracle.com/mysql/post/introducing-mysql-innovation-and-longterm-support-lts-versions)
