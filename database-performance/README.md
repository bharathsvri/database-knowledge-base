# Database Performance Engineering & Tuning

This module provides exhaustive production tuning runbooks, cost-based optimizer analysis, indexing strategies, and connection pool sizing formulas for high-throughput relational databases.

---

## Performance Documentation Directory

| Document | Focus Area | Key Architectural Topics |
| :--- | :--- | :--- |
| **[Query Optimization](query-optimization.md)** | SQL Tuning Patterns | Avoiding full table scans, SARGable predicates, JOIN optimization (Hash vs Merge vs Nested Loop). |
| **[Execution Plans](execution-plans.md)** | Cost-Based Optimizer | Reading `EXPLAIN (ANALYZE, BUFFERS)`, cost calculations, cardinality estimation, actual vs estimated rows. |
| **[Indexing Strategies](indexing-strategies.md)** | B-Tree & Specialized Indexes | Composite index order, covering indexes (`INCLUDE`), partial indexes, index deduplication, write amplification. |
| **[Slow Query Analysis](slow-query-analysis.md)** | Diagnostics & Profiling | `pg_stat_statements`, MySQL Slow Query Log, wait events, lock analysis, query fingerprinting. |
| **[Connection Pool Tuning](connection-pool-tuning.md)** | Concurrency & Throughput | HikariCP sizing formula, PgBouncer transaction pooling, OS context switching, thread starvation. |
| **[Database Capacity Planning](database-capacity-planning.md)** | Sizing & Growth Models | IOPS estimation, storage growth projections, RAM buffer pool sizing, network throughput limits. |
