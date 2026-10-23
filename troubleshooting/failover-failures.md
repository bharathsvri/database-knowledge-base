# Incident Runbook: Failover Failures and Split-Brain Recovery

> **Severity Level:** SEV-1 (Critical Cluster Outage)  
> **Affected Systems:** Database High Availability Topology, Application Write Access  
> **Target Audience:** Systems Architects, Principal SREs, Lead DBAs

---

## 1. Symptom & Alert Trigger
- **Alert:** `ClusterLeaderElectionFailed` or `MultiplePrimaryInstancesDetected` (Split-Brain).
- **User Impact:** Writes failing cluster-wide or divergent writes occurring across isolated nodes.

---

## 2. Immediate Diagnostic Steps

### Step 1: Check Consensus State (etcd / Patroni)
```bash
# Check Patroni cluster topology:
patronictl -c /etc/patroni/patroni.yml list
```
*Sample Output Indicating Failure:*
```text
+ Cluster: pg-cluster (7201948201) +---------+
| Member   | Host        | Role    | State   | TL | Lag in MB |
+----------+-------------+---------+---------+----+-----------+
| db-01    | 10.0.1.10   | Primary | running |  1 |           |
| db-02    | 10.0.1.11   | Primary | running |  2 |         0 |
+----------+-------------+---------+---------+----+-----------+
WARNING: MULTIPLE PRIMARIES DETECTED (SPLIT BRAIN)!
```

### Step 2: Emergency Fencing
Immediately cut write access to the older timeline primary:
```bash
# Stop postgres on the legacy isolated node:
ssh 10.0.1.10 "systemctl stop patroni && systemctl stop postgresql"
```

---

## 3. Reconciling & Rejoining the Demoted Primary

Because both nodes accepted independent writes, their WAL timelines diverged:
- You cannot simply restart `db-01` as a replica without reconciliation!
- Use **`pg_rewind`** to rewind `db-01` back to the point where its timeline diverged from `db-02`:

```bash
# On db-01:
pg_rewind \
  --target-pgdata=/var/lib/postgresql/data \
  --source-server='host=10.0.1.11 port=5432 user=postgres password=secret dbname=postgres' \
  -P -v
```
`pg_rewind` reads WAL changes from the target primary, finds the divergence point, copies only the modified data blocks from `db-02`, and rewires `db-01` so it can cleanly stream as a standby.

---

## 4. Permanent Preventive Actions
- Ensure consensus cluster has a strict odd-number quorum (minimum 3 etcd nodes).
- Enforce watchdog hardware fencing (Linux watchdog device `/dev/watchdog`) so un-renewed primaries reboot immediately.

---

## 5. Authoritative References
- [Patroni Documentation: High Availability and Failover](https://patroni.readthedocs.io/)
- [PostgreSQL pg_rewind Documentation](https://www.postgresql.org/docs/current/app-pgrewind.html)
