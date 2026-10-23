# Reading Database Execution Plans

> **Category:** Database Performance  
> **Target Audience:** Database Engineers, Senior Backend Developers  
> **Relevant Engines:** PostgreSQL (`EXPLAIN ANALYZE`), MySQL (`EXPLAIN FORMAT=TREE`)

---

## 1. What is an Execution Plan?
An **execution plan** is the graph of physical relational operations (scans, joins, aggregations, sorts) selected by the database's Cost-Based Optimizer (CBO) to execute an SQL statement.

---

## 2. Anatomy of a PostgreSQL Execution Plan

```sql
EXPLAIN (ANALYZE, BUFFERS, COSTS)
SELECT c.name, o.total_amount
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.order_date >= '2026-01-01';
```

### Sample Output Breakdown:
```text
Hash Join  (cost=15.40..45.80 rows=50 width=48) (actual time=0.120..0.450 rows=48 loops=1)
  Hash Cond: (o.customer_id = c.id)
  Buffers: shared hit=32 read=2
  ->  Index Scan using idx_orders_date on orders o  (cost=0.28..28.50 rows=52 width=24) (actual time=0.035..0.210 rows=48 loops=1)
        Index Cond: (order_date >= '2026-01-01'::date)
        Buffers: shared hit=18 read=2
  ->  Hash  (cost=12.50..12.50 rows=200 width=32) (actual time=0.065..0.065 rows=200 loops=1)
        Buckets: 1024  Batches: 1  Memory Usage: 18kB
        Buffers: shared hit=14
        ->  Seq Scan on customers c  (cost=0.00..12.50 rows=200 width=32) (actual time=0.010..0.040 rows=200 loops=1)
              Buffers: shared hit=14
Planning Time: 0.185 ms
Execution Time: 0.512 ms
```

### Key Metrics to Analyze:
1. **`cost=15.40..45.80`:**
   - First number (`15.40`): **Startup cost** (cost to fetch the very first row).
   - Second number (`45.80`): **Total cost** (estimated cost to complete the node). Costs are relative units based on sequential page fetches (`seq_page_cost = 1.0`).
2. **`actual time=0.120..0.450`:** Real elapsed wall-clock time in milliseconds.
3. **`rows=50` vs `actual rows=48`:** **Cardinality estimation accuracy**. If estimated rows is 1 and actual rows is 500,000, database statistics are stale! Run `ANALYZE table_name;`.
4. **`Buffers: shared hit=32 read=2`:**
   - `hit`: 8KB data blocks served from RAM buffer cache.
   - `read`: 8KB data blocks read from physical disk (expensive random I/O).

---

## 3. Warning Signs in Execution Plans

- **Seq Scan on Large Table:** The query planner scanned millions of rows from disk. Indicates a missing index or non-SARGable predicate.
- **Sort Method: external merge Disk:** Memory assigned for sorting (`work_mem`) was too small. The engine spilled temporary sort files to disk, increasing latency by 10x–50x.
- **Nested Loop with High Loop Count:** A nested loop join executed 500,000 times, multiplying disk accesses.

---

## 4. Authoritative References
- [PostgreSQL EXPLAIN Documentation](https://www.postgresql.org/docs/current/using-explain.html)
- [The Art of PostgreSQL: Understanding Execution Plans](https://theartofpostgresql.com/)
