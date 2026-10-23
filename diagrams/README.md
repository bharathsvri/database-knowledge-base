# Architecture Diagrams Catalog

This directory houses the visual architectural models, sequence flows, and system topologies for database engineering patterns documented across this repository.

## Visual Topologies & Diagrams

| Diagram Name | Source File | Embedded Document | Description |
| :--- | :--- | :--- | :--- |
| **Primary-Replica Replication** | [`sources/primary-replica-replication.mmd`](sources/primary-replica-replication.mmd) | [`database-replication.md`](../database-architecture/database-replication.md) | WAL streaming, primary/standby architecture, and sync vs async semantics. |
| **Failover & Replica Promotion** | [`sources/failover-and-replica-promotion.mmd`](sources/failover-and-replica-promotion.mmd) | [`failover-and-high-availability.md`](../database-architecture/failover-and-high-availability.md) | Quorum consensus, heartbeat monitoring, standby promotion, and split-brain fencing. |
| **Read-Write Splitting** | [`sources/read-write-splitting.mmd`](sources/read-write-splitting.mmd) | [`read-write-splitting.md`](../database-architecture/read-write-splitting.md) | Application/Proxy-level routing between writer primary and reader pool. |
| **Shard Routing** | [`sources/shard-routing.mmd`](sources/shard-routing.mmd) | [`database-sharding.md`](../database-architecture/database-sharding.md) | Application routing keys, hash ring distribution, and per-shard connection pools. |
| **Partitioned Table Structure** | [`sources/partitioned-table-structure.mmd`](sources/partitioned-table-structure.mmd) | [`database-partitioning.md`](../database-architecture/database-partitioning.md) | Logical parent table, declarative boundary routing, and partition pruning. |
| **Combined Architecture** | [`sources/combined-architecture.mmd`](sources/combined-architecture.mmd) | [`replication-vs-sharding-vs-partitioning.md`](../database-architecture/replication-vs-sharding-vs-partitioning.md) | Enterprise scale: Sharding across clusters, replicating for HA, and partitioning locally for lifecycle retention. |

## Standards & Tooling
- Diagrams are rendered natively on GitHub using GitHub Flavored Markdown `mermaid` fenced code blocks.
- Editable source definitions are maintained in `diagrams/sources/*.mmd` using standard Mermaid syntax.
- Flowcharts use `flowchart TD` or `flowchart LR`. Sequence diagrams use `sequenceDiagram`.
