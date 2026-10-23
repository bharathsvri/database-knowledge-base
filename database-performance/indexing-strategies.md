# Production Indexing Strategies

> **Category:** Database Performance  
> **Target Audience:** Database Architects, Senior Engineers  
> **Relevant Engines:** PostgreSQL, MySQL (InnoDB)

---

## 1. The Three Index Design Rules

### Rule 1: Equality First, Ranges Second
In a composite B-Tree index, order columns based on how they appear in query filters:
1. Columns filtered with equality (`=`) come **first**.
2. Columns filtered with range operators (`<`, `>`, `BETWEEN`, `LIKE 'x%'`) come **second**.
3. Ordering columns (`ORDER BY`) come **last**.

```sql
-- Optimal index for: WHERE tenant_id = 5 AND status = 'ACTIVE' AND created_at >= '2026-01-01'
CREATE INDEX idx_tenant_status_date ON orders (tenant_id, status, created_at);
```

### Rule 2: Covering Indexes (`INCLUDE`) for Hot Queries
If a query accounts for 40% of all database read traffic, eliminate all heap accesses by including unindexed projection columns in the index payload:
```sql
CREATE INDEX idx_users_lookup 
ON users (email) 
INCLUDE (first_name, last_name, is_active);
```

### Rule 3: Use Partial Indexes for Skewed Distributions
If a table has 50 million rows, but only 20,000 are in status `PENDING_REVIEW`, never index the entire table!
```sql
-- Creates an index containing only 20,000 leaf entries instead of 50,000,000!
CREATE INDEX idx_pending_reviews 
ON orders (created_at) 
WHERE status = 'PENDING_REVIEW';
```

---

## 2. Managing Write Amplification and Unused Indexes
Every index consumes disk space, occupies RAM in `shared_buffers`, and incurs write amplification during `INSERT`/`UPDATE`.

### Detecting Unused Indexes in PostgreSQL:
```sql
SELECT 
    schemaname, 
    relname AS table_name, 
    indexrelname AS index_name, 
    idx_scan,
    pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE idx_scan = 0 
  AND indexrelname NOT LIKE '%_pkey'
ORDER BY pg_relation_size(indexrelid) DESC;
```

---

## 3. Authoritative References
- [PostgreSQL Indexing Best Practices](https://www.postgresql.org/docs/current/indexes.html)
- [Markus Winand: SQL Performance Explained](https://sql-performance-explained.com/)
