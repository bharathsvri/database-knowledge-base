# PostgreSQL Version Tracking & Release Notes

This directory tracks the lifecycle, architectural evolutions, breaking changes, and upgrade runbooks for official PostgreSQL releases.

---

## Documented Releases

| Version | Release Date | Support Status (Checked 2026-10-23) | Major Architecture Highlights | Detailed Release Notes |
| :--- | :--- | :--- | :--- | :--- |
| **PostgreSQL 16** | 2023-09-14 | Active / Supported until 2028-11-09 | Logical replication from standbys, `pg_stat_io`, parallel Hash Right/Full Joins, SIMD acceleration. | [`versions/postgresql-16.md`](versions/postgresql-16.md) |
| **PostgreSQL 15** | 2022-10-13 | Active / Supported until 2027-11-11 | Standard `MERGE` SQL command, LZ4/zstd WAL compression, Row filtering in logical replication, `public` schema security hardening. | [`versions/postgresql-15.md`](versions/postgresql-15.md) |

---

## Global Version Roadmap
For historical version milestones dating from PostgreSQL 10 through PostgreSQL 16, refer to:
- [`release-history.md`](release-history.md)

---

## Upgrade Strategy Summary
- **Minor Upgrades (e.g., 16.1 to 16.4):** Update packages/binaries, restart service. Zero catalog modifications.
- **Major Upgrades (e.g., 14 to 16):** Use `pg_upgrade --link` for near-instant upgrade using hard links, or physical logical streaming migration for zero-downtime upgrades.
