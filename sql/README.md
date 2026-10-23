# SQL Reference Catalog & Practice Labs

This directory contains executable, production-standard SQL scripts covering everything from core DDL to advanced recursive queries and diagnostic scripts for PostgreSQL and MySQL.

---

## Directory Navigation

| Subfolder | Script Name | Topic & Practical Application |
| :--- | :--- | :--- |
| **[`ddl/`](ddl/)** | `table-definitions.sql` | Data Definition Language: Tables, Primary/Foreign keys, constraints, domains, enums. |
| **[`dml/`](dml/)** | `crud-operations.sql` | Data Manipulation Language: Batch inserts, `ON CONFLICT DO UPDATE` (upsert), RETURNING. |
| **[`joins/`](joins/)** | `all-joins-demo.sql` | Inner, Left, Right, Full Outer, Cross, Self, and Lateral Joins with execution plans. |
| **[`subqueries/`](subqueries/)** | `correlated-and-scalar.sql` | Scalar subqueries, correlated subqueries, `EXISTS` vs `IN` performance comparisons. |
| **[`cte-and-recursive-queries/`](cte-and-recursive-queries/)** | `hierarchies-and-ctes.sql` | Common Table Expressions (CTEs), recursive tree traversal, bill-of-materials. |
| **[`window-functions/`](window-functions/)** | `ranking-and-aggregates.sql` | `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `LEAD()`, `LAG()`, running totals, frames. |
| **[`indexes/`](indexes/)** | `index-types-demo.sql` | B-Tree, GIN, Partial, Expression, and Covering indexes (`INCLUDE`). |
| **[`transactions/`](transactions/)** | `acid-isolation-demo.sql` | Savepoints, Isolation Levels, `SELECT FOR UPDATE`, Pessimistic locking. |
| **[`performance-queries/`](performance-queries/)** | `slow-query-diagnostics.sql` | `pg_stat_statements`, cache hit ratios, table bloat checks, lock contention triage. |
