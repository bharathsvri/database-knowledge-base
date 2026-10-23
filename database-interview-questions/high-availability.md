# High Availability & Failover Interview Questions

> **Module:** Database Interview Preparation  
> **Topic:** High Availability, Failover Mechanisms, Consensus, Quorum, STONITH, RTO/RPO  
> **Target Audience:** SREs, Systems Architects, Principal Engineers

---

## Difficulty Navigation
- [Intermediate Level](#intermediate-level)
- [Advanced Level](#advanced-level)
- [Senior Engineer Level](#senior-engineer-level)

---

## Intermediate Level

### Q1: What is the relationship between RTO, RPO, and High Availability?
#### Short Interview-Ready Answer
"- **RTO (Recovery Time Objective):** The maximum tolerable downtime required to restore service after a crash (e.g., automated Patroni failover provides an RTO of 10–30 seconds).
- **RPO (Recovery Point Objective):** The maximum tolerable data loss measured in time or transactions. Synchronous replication guarantees RPO = 0; asynchronous replication yields RPO equal to the replication lag at crash time.
- **High Availability (HA):** A quantitative SLA measuring uptime: 99.99% ('four nines') permits up to 52.6 minutes of total unplanned downtime per calendar year."

---

## Advanced Level

### Q2: What is the role of an odd number of consensus nodes in Distributed High Availability?
#### Short Interview-Ready Answer
"Distributed consensus algorithms (Raft, Paxos, etcd) require a strict majority quorum to elect a leader:
$$\text{Quorum} = \left\lfloor \frac{N}{2} \right\rfloor + 1$$
An odd number of nodes provides optimal fault tolerance at minimum infrastructure cost:
- A **3-node cluster** can tolerate **1 failure** ($3/2 + 1 = 2$ votes needed).
- A **4-node cluster** requires 3 votes for quorum ($4/2 + 1 = 3$), so it can **still only tolerate 1 failure!** Adding the 4th node increases network traffic without increasing fault tolerance.
- A **5-node cluster** tolerates **2 failures** (3 votes needed)."

---

## Senior Engineer Level

### Q3: How do you prevent False-Positive Failovers caused by transient network blips?
#### Short Interview-Ready Answer
"False-positive failovers (initiating a disruptive primary promotion when the existing primary is completely healthy but experienced a temporary 2-second GC pause or network blip) are prevented by:
1. **Multi-Step Failure Detection Windows:** Requiring consecutive missed heartbeats (e.g., 3 missed checks of 3 seconds each = 9 seconds) before declaring a node dead.
2. **Dual-Channel Health Verification:** Verifying reachability through both the database port and a dedicated sidecar HTTP health API (e.g., Patroni REST API).
3. **Lease Renewal Grace Periods:** Primary proactively steps down to read-only mode if it fails to renew its consensus lease within a fraction of the TTL (e.g., lease TTL is 10s; primary steps down if unrenewed at 7s), ensuring no overlap between primary roles."

---

## Authoritative References
- [Patroni High Availability Framework](https://patroni.readthedocs.io/)
- [Raft Consensus Algorithm Guide](https://raft.github.io/)
