# Spring Boot Shard Routing Lab

This module demonstrates application-level database sharding in Java Spring Boot using consistent hashing and dynamic DataSource lookup.

---

## 1. Architectural Highlights
- Routes queries based on `customer_id` hash across 3 independent database shards (`shard_1`, `shard_2`, `shard_3`).
- **Maintains one isolated HikariCP connection pool per shard**, ensuring that slowdowns or outages on one shard do not starve other shards of database connections.
- Thread-safe context management using `ShardContextHolder` with guaranteed `finally` cleanup to prevent memory leaks in pooled thread environments.

---

## 2. Limitations & Production Requirements
- **Scatter-Gather Queries:** Queries that do not supply a shard key cannot be executed with standard JPA methods; they require an orchestration layer that queries all shards in parallel and merges results.
- **Cross-Shard Transactions:** Requires distributed transaction orchestration (Saga pattern).
