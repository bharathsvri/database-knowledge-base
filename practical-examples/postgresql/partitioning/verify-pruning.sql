-- Verification Queries for Declarative Table Partitioning & Pruning

-- 1. Verify physical row distribution across partitions
SELECT 
    tableoid::regclass AS physical_partition,
    count(*) AS row_count
FROM telemetry_readings
GROUP BY tableoid
ORDER BY physical_partition;

-- Expected Output:
--  physical_partition   | row_count 
-- ----------------------+-----------
--  telemetry_2026_01    |         2
--  telemetry_2026_02    |         2
--  telemetry_2026_03    |         1
--  telemetry_default    |         1

-- 2. Verify partition pruning with EXPLAIN ANALYZE
SET enable_partition_pruning = on;

EXPLAIN (ANALYZE, COSTS OFF)
SELECT * FROM telemetry_readings
WHERE recorded_at >= '2026-02-01' AND recorded_at < '2026-03-01';

-- Notice: Only 'telemetry_2026_02' is scanned; all other partitions are pruned from the plan!

-- 3. Fast Detach Archival Demonstration
-- Detach January partition concurrently:
ALTER TABLE telemetry_readings DETACH PARTITION telemetry_2026_01 CONCURRENTLY;

-- Confirm 'telemetry_2026_01' is now a standalone table:
SELECT count(*) FROM telemetry_readings WHERE recorded_at < '2026-02-01';
-- Returns: 0 (Instant isolation)

SELECT count(*) FROM telemetry_2026_01;
-- Returns: 2 (Data preserved in detached table ready for S3 archive)
