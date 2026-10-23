#!/usr/bin/env bash
# PostgreSQL Backup & Export Quick Reference Commands

# 1. Logical Backup: Single database custom compressed format (best for pg_restore)
pg_dump -h localhost -U postgres -d app_db -F c -b -v -f app_db_$(date +%F).dump

# 2. Logical Restore: Parallel restore with 4 workers
pg_restore -h localhost -U postgres -d app_db -j 4 -v app_db_*.dump

# 3. Global Cluster Metadata Backup (Roles, Tablespaces, Permissions)
pg_dumpall -h localhost -U postgres --globals-only -f globals_$(date +%F).sql

# 4. Physical Base Backup (Streaming WAL included)
pg_basebackup -h localhost -U postgres -D /backups/base_$(date +%F) -Fp -Xs -P -v
