# Spring Boot Database Engineering Labs

This directory contains production-ready, clean Java 17+ and Spring Boot implementations for enterprise database architectures.

---

## Lab Modules

| Module | Location | Description |
| :--- | :--- | :--- |
| **Read-Write Routing** | [`read-write-routing/`](read-write-routing/) | Dynamic routing between Primary writer and Replica readers using `@Transactional(readOnly=true)` and `AbstractRoutingDataSource`. |
| **Shard Routing** | [`shard-routing/`](shard-routing/) | Application-level shard routing with consistent hashing, per-shard isolated HikariCP connection pools, and `ThreadLocal` context. |
| **Connection Pool Tuning** | [`connection-pooling/`](connection-pooling/) | HikariCP pool sizing formula implementation, leak detection, and Prometheus metrics export configuration. |
