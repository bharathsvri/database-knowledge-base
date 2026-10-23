# Database Interview Preparation Guide & Question Bank

Welcome to the **Database Interview Preparation** repository module. This guide is organized for technical interviewers, database engineers, software architects, and backend developers preparing for rigorous system design and database internals interviews.

---

## Question Bank Directory

| Topic & Guide | Target Topics Covered | Target Career Levels |
| :--- | :--- | :--- |
| **[Scenario-Based Architecture Questions](scenario-based-questions.md)** | Real-world catastrophic production failures, shard overloading, zero-downtime shard migrations, read-after-write lag, split-brain triage. | Senior Engineer, Principal Architect |
| **[Software Architect System Design Questions](software-architect-questions.md)** | 100B row annual architectures, global multi-region consistency, zero-downtime schema migrations, multi-tenant persistence models. | Software Architect, Staff/Principal |
| **[Database Replication Questions](replication.md)** | WAL streaming, Sync vs Async, replication lag, standby recovery, failover candidate election, replication conflicts. | Junior, Senior, Staff Engineer |
| **[Database Sharding Questions](sharding.md)** | Shard key selection, consistent hashing, hot shard mitigation, cross-shard joins, distributed ID generation. | Intermediate, Senior, Architect |
| **[Database Partitioning Questions](partitioning.md)** | Declarative table partitioning, range/list/hash, partition pruning, index propagation, over-partitioning hazards. | Junior, Senior, Data Engineer |
| **[Transactions & Locking Questions](transactions-and-locking.md)** | ANSI isolation levels, dirty/non-repeatable/phantom reads, MVCC internals (`xmin`/`xmax`), deadlock prevention. | All Engineering Levels |
| **[Indexing & Performance Questions](indexing-and-performance.md)** | B-Tree mechanics, covering indexes, leftmost prefix rule, EXPLAIN ANALYZE, vacuuming & bloat. | All Engineering Levels |
| **[SQL Problem-Solving Queries](sql-queries.md)** | N-th highest salary, window functions (`DENSE_RANK`), recursive CTEs, tree traversal, complex analytics. | Backend Developers, Analysts |
| **[High Availability & Failover Questions](high-availability.md)** | RTO, RPO, Raft/Paxos consensus, STONITH split-brain fencing, lease timeouts, false-positive prevention. | SRE, DevOps, Systems Architects |
| **[Database Security Questions](database-security.md)** | SQL injection defense, prepared statements, TDE encryption, Row-Level Security (RLS), dynamic secrets rotation. | Security Engineers, Developers |
| **[Database Fundamentals Questions](fundamentals.md)** | Database vs DBMS, relational vs NoSQL, database keys, 1NF/2NF/3NF/BCNF normalization, ACID properties. | Beginner to Intermediate |

---

## 5-Level Competency Rubric

```text
Level 1: Beginner       ──▶ Core definitions, ACID, basic SQL joins, primary keys.
Level 2: Intermediate   ──▶ B-Tree index traversal, composite keys, basic replication lag, isolation levels.
Level 3: Advanced       ──▶ MVCC mechanics, partition pruning, query plan cost analysis, write conflicts.
Level 4: Senior         ──▶ High availability election, deadlock wait-graphs, pool sizing formulas, shard keys.
Level 5: Architect      ──▶ Multi-region consensus, CAP/PACELC trade-offs, Sagas vs 2PC, 100B row architectures.
```

---

## Interview Preparation Roadmap
1. Review [Database Fundamentals](fundamentals.md) and [Transactions & Locking](transactions-and-locking.md).
2. Master execution plans with [Indexing & Performance](indexing-and-performance.md).
3. Deep-dive on distributed scale with [Database Replication](replication.md) and [Database Sharding](sharding.md).
4. Practice complex scenarios with [Scenario-Based Questions](scenario-based-questions.md).
5. Prepare for architectural leadership interviews with [Software Architect Questions](software-architect-questions.md).
