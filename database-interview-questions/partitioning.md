# Database Partitioning Interview Questions & Answers

> **Module:** Database Interview Preparation  
> **Topic:** Declarative Table Partitioning, Range/List/Hash, Partition Pruning, Maintenance  
> **Target Audience:** Software Engineers, Senior Database Engineers, Data Architects

---

## Difficulty Navigation
- [Beginner Level](#beginner-level)
- [Intermediate Level](#intermediate-level)
- [Advanced Level](#advanced-level)
- [Senior Engineer Level](#senior-engineer-level)
- [Software Architect Level](#software-architect-level)

---

## Beginner Level

### Q1: What is table partitioning and what problem does it solve?
#### Short Interview-Ready Answer
"Table partitioning is a database feature where a very large logical table is divided into smaller, discrete physical child tables on disk, while remaining a single unified table to SQL queries. It solves performance degradation caused by bloated B-Tree indexes, improves cache hit ratios, enables partition pruning for faster scans, and allows near-instantaneous bulk data deletion via `DROP TABLE` instead of slow, lock-heavy `DELETE` queries."

---

### Q2: What are the three primary partitioning methods in PostgreSQL?
#### Short Interview-Ready Answer
"The three declarative partitioning methods in PostgreSQL are:
1. **Range Partitioning:** Maps rows based on continuous value intervals (e.g., dates: `FROM ('2026-01-01') TO ('2026-02-01')`).
2. **List Partitioning:** Maps rows based on explicit lists of discrete values (e.g., country codes: `IN ('US', 'CA')`).
3. **Hash Partitioning:** Maps rows using a modulus and remainder on a hash of the partition key (`MODULUS 4 REMAINDER 0`)."

---

## Intermediate Level

### Q3: What is Partition Pruning and how does the query planner use it?
#### Short Interview-Ready Answer
"Partition pruning is a query optimizer mechanism where the planner evaluates query `WHERE` predicates against child partition constraint boundaries and eliminates irrelevant partitions from the execution plan entirely. This avoids scanning physical disk blocks of unneeded partitions, reducing disk I/O and query latency."

#### Verification with `EXPLAIN`
```sql
EXPLAIN (COSTS OFF)
SELECT * FROM audit_logs 
WHERE log_date >= '2026-03-01' AND log_date < '2026-04-01';

-- Plan output confirms only 'audit_logs_2026_03' is scanned:
-- Append
--   ->  Seq Scan on audit_logs_2026_03
```
- **Planning-time vs Run-time Pruning:** Planning-time pruning occurs when literals are constant. Run-time pruning evaluates parameters or prepared statements dynamically during query execution.

---

### Q4: Why must the partition key be part of the Primary Key in PostgreSQL declarative partitioning?
#### Short Interview-Ready Answer
"PostgreSQL enforces uniqueness on partitioned tables using local per-partition indexes rather than a global cross-partition index. To verify that an inserted value is globally unique without performing expensive lock and search operations across all partitions on every write, the engine must know which partition holds the key. Therefore, the partition key must be included in the Primary Key and any `UNIQUE` constraints."

```sql
-- Valid Primary Key definition:
CREATE TABLE orders (
    order_id BIGINT,
    order_date DATE,
    PRIMARY KEY (order_id, order_date) -- Must include order_date!
) PARTITION BY RANGE (order_date);
```

---

## Advanced Level

### Q5: What happens when an update changes a row's partition key so that it belongs in a different partition?
#### Short Interview-Ready Answer
"In PostgreSQL 11 and later, row movement across partitions is natively supported. When an `UPDATE` modifies the partition key (e.g., updating an order date from January to March), PostgreSQL automatically deletes the tuple from the original child partition and inserts it into the target child partition within the same transaction. In PostgreSQL 10 or older, this operation would fail with a constraint violation error."

---

### Q6: What is the hazard of 'Over-Partitioning' and how many partitions is too many?
#### Short Interview-Ready Answer
"Over-partitioning occurs when a table is divided into too many small partitions (e.g., partitioning by hour or day over many years, resulting in thousands of partitions). 

The negative impacts include:
1. **Query Planning Latency:** The query optimizer must inspect locks, metadata, and statistics for thousands of tables, increasing plan time from 1ms to hundreds of milliseconds.
2. **Operating System File Descriptor Saturation:** Each partition opens multiple OS file handles (data files, toast, indexes).
3. **Memory Overhead:** Metadata for each partition consumes server shared memory and connection-private cache.
*Best practice:* Keep the total active partition count per table under 100–300."

---

## Senior Engineer Level

### Q7: How do you implement zero-downtime historical data archival using table partitioning?
#### Short Interview-Ready Answer
"Instead of executing a massive `DELETE FROM logs WHERE created_at < '2024-01-01'` (which generates heavy WAL, table bloat, and exclusive row locks), we execute declarative partition detachment:
1. Detach the target partition concurrently:
   ```sql
   ALTER TABLE logs DETACH PARTITION logs_2023_q4 CONCURRENTLY;
   ```
2. The partition becomes a standalone independent table. Live queries to `logs` immediately stop scanning it with zero locking impact on active users.
3. Export the standalone table to Amazon S3 or cold storage using `pg_dump` or Parquet conversion.
4. Drop the standalone table instantly:
   ```sql
   DROP TABLE logs_2023_q4;
   ```
This reclaims disk space instantaneously with zero WAL amplification."

---

## Software Architect Level

### Q8: When would you combine Table Partitioning with Database Sharding?
#### Short Interview-Ready Answer
"We combine Table Partitioning and Database Sharding when a system has reached both **horizontal write throughput limits** and **single-node table manageability limits**. 

For instance, in a global fintech ledger:
1. **Sharding (Tier 1):** We shard across 16 independent database clusters keyed by `account_id` to distribute 40,000 writes/sec and avoid hardware IOPS bottlenecks.
2. **Partitioning (Tier 2):** Inside each of the 16 shards, the local `ledger_entries` table is partitioned by month (`RANGE (entry_date)`).
This ensures each individual shard maintains compact, memory-resident B-Trees for the active billing cycle and can execute instant monthly data archival locally without distributed coordination."

---

## Common Mistakes & Misconceptions
- **Misconception:** Table partitioning will automatically speed up every query on the table. *(Reality: Queries that omit the partition key in their `WHERE` clause must scan every child partition, often performing worse than a single table with a good index).*
- **Misconception:** Table partitioning allows horizontal scaling across multiple servers. *(Reality: Partitioning is strictly local to a single database server).*

---

## Related References
- [Database Partitioning Architecture Guide](../database-architecture/database-partitioning.md)
- [PostgreSQL Declarative Partitioning Documentation](https://www.postgresql.org/docs/current/ddl-partitioning.html)
