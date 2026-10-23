# Practical Lab: PostgreSQL Advanced Indexing

This lab demonstrates three high-impact indexing patterns in PostgreSQL:
1. **Covering Indexes (`INCLUDE`):** Satisfying queries entirely via Index-Only Scans without touching heap pages.
2. **GIN Indexes on JSONB:** Accelerating arbitrary document attribute lookups (`@>` containment operator).
3. **Partial Indexes:** Indexing only active or unprocessed subsets of data to reduce index size by 80%+ and minimize write amplification.

---

## Running the Lab
```bash
psql -h localhost -p 5432 -U postgres -d app_db -f indexing-lab.sql
```
Inspect the output to confirm `Index Only Scan` and `Bitmap Index Scan using idx_events_payload_gin`.
