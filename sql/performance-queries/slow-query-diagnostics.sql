-- Production Performance Diagnostics & Monitoring Queries for PostgreSQL

-- 1. Identify Top 10 Slowest Queries by Total Execution Time (Requires pg_stat_statements)
-- CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT 
    round((total_exec_time / 1000)::numeric, 2) AS total_time_seconds,
    calls,
    round((mean_exec_time)::numeric, 2) AS mean_time_ms,
    round((stddev_exec_time)::numeric, 2) AS stddev_time_ms,
    round((100 * total_exec_time / sum(total_exec_time) OVER ())::numeric, 2) AS percentage_cpu,
    query
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;

-- 2. Inspect Currently Running Queries & Blocked Transactions
SELECT 
    pid,
    now() - query_start AS duration,
    state,
    wait_event_type,
    wait_event,
    query
FROM pg_stat_activity
WHERE state != 'idle' 
  AND pid <> pg_backend_pid()
ORDER BY duration DESC;

-- 3. Cache Hit Ratio (Should be > 99% in healthy OLTP systems)
SELECT 
    sum(heap_blks_read) as heap_read,
    sum(heap_blks_hit)  as heap_hit,
    round((sum(heap_blks_hit)::numeric / (sum(heap_blks_hit) + sum(heap_blks_read))) * 100, 2) as buffer_cache_hit_ratio
FROM pg_statio_user_tables;

-- 4. Identify Unused / Redundant Indexes (Candidates for Dropping)
SELECT 
    schemaname,
    relname AS table_name,
    indexrelname AS index_name,
    idx_scan AS number_of_scans,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0 
  AND indexrelname NOT LIKE '%_pkey' -- Do NOT drop primary keys!
ORDER BY pg_relation_size(indexrelid) DESC;
