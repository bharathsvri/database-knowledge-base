# Database Troubleshooting & Production Incident Runbooks

This module provides production-tested incident triage runbooks, diagnostic queries, and root cause mitigation checklists for critical database outages.

---

## Runbook Directory

| Runbook | Outage Type | Key Diagnostic Commands & Scenarios |
| :--- | :--- | :--- |
| **[Replication Lag](replication-lag.md)** | SEV-2 / SEV-1 | Byte vs time lag, standby replay lock conflicts, feedback bloat, replication slot overflow. |
| **[Connection Exhaustion](connection-exhaustion.md)** | SEV-1 Outage | `FATAL: remaining connection slots are reserved`, pool starvation, rogue thread leaks, PgBouncer triage. |
| **[Deadlocks](deadlocks.md)** | SEV-2 Degradation | `ERROR: deadlock detected`, lock wait graphs, cross-table ordering violations, explicit locking triage. |
| **[Slow Queries](slow-queries.md)** | SEV-2 Degradation | Active query termination (`pg_terminate_backend`), disk spill detection, missing indexes, optimizer skew. |
| **[Failover Failures](failover-failures.md)** | SEV-1 Outage | Split-brain recovery, Patroni lease timeouts, DNS TTL caching issues, STONITH fence failures. |
| **[Data Consistency Issues](data-consistency-issues.md)** | SEV-1 Integrity | Broken foreign keys, lost updates, ghost reads, dual-write drift, checksum reconciliation. |
