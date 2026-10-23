# MySQL Version Tracking & Release Notes

This directory tracks release lifecycles, architectural shifts, upgrade runbooks, and breaking changes across Oracle MySQL releases.

---

## Documented Releases

| Version | Release Date | Support Status (Checked 2026-10-23) | Major Architecture Highlights | Detailed Release Notes |
| :--- | :--- | :--- | :--- | :--- |
| **MySQL 8.4 LTS** | 2024-04-30 | Active LTS (Supported until April 2029) | First official Long-Term Support (LTS) release; removal of `mysql_native_password` by default; automated replication failover tuning. | [`versions/mysql-8-4-lts.md`](versions/mysql-8-4-lts.md) |
| **MySQL 8.0** | 2018-04-19 | Active (EOL April 2026) | Transactional data dictionary; native Window Functions; CTEs; default `utf8mb4` charset; Instant DDL. | [`versions/mysql-8-0.md`](versions/mysql-8-0.md) |

---

## MySQL Release Model Transition
Starting in 2023–2024, Oracle shifted MySQL versioning to an **LTS (Long-Term Support) and Innovation Release** model:
- **LTS Releases (e.g., MySQL 8.4, 9.7):** Released every two years with 5 years of standard support. Strict stability focus; no breaking syntax or behavioral changes during the release cycle.
- **Innovation Releases (e.g., MySQL 8.1, 8.2, 8.3, 9.0):** Rapid cadence for cutting-edge features. Supported only until the subsequent release.

For complete release timelines, refer to [`release-history.md`](release-history.md).
