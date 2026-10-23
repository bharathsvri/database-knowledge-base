# Database Release Notes & Version Tracking System

This directory maintains verified release documentation, version-specific architecture changes, upgrade procedures, and breaking changes for major relational database management systems.

---

## Supported Database Systems

| Database Engine | Release Directory | Active LTS / Mainstream Versions Documented |
| :--- | :--- | :--- |
| **PostgreSQL** | [`postgresql/`](postgresql/README.md) | PostgreSQL 16, PostgreSQL 15, Release History (v10–v16) |
| **MySQL** | [`mysql/`](mysql/README.md) | MySQL 8.4 LTS, MySQL 8.0, Release History |

---

## Core Engineering Principles for Release Documentation

1. **Major vs Minor Releases:**
   - **Major Releases (e.g., PostgreSQL 15 $\to$ 16, MySQL 8.0 $\to$ 8.4):** Introduce new features, catalog changes, and potential breaking syntax changes. Data directory storage layouts change; in-place binary swaps are impossible without explicit data migration (`pg_upgrade` or MySQL upgrade).
   - **Minor Releases (e.g., PostgreSQL 16.1 $\to$ 16.2, MySQL 8.0.35 $\to$ 8.0.36):** Strictly contain bug fixes and security patches (CVEs). Binary drop-in replacements with identical storage compatibility; safe to apply with standard service restarts.
2. **Verified Facts Only:** All release dates, CVE numbers, breaking changes, and support lifecycle dates are verified against official PostgreSQL Global Development Group and Oracle MySQL documentation.
3. **No Assumed In-Place Rollbacks:** Major database upgrades write new metadata formats to data pages. Once an upgraded engine starts writing to a database cluster, reverting to older engine binaries without restoring a pre-upgrade physical backup is physically impossible.

---

## Release Note Template
All release files follow the standardized format in [`release-note-template.md`](release-note-template.md).
