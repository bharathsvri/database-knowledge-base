-- Declarative Range Partitioning Setup
-- Compatible with PostgreSQL 12, 13, 14, 15, 16

-- 1. Create logical master partitioned table
CREATE TABLE telemetry_readings (
    reading_id BIGINT GENERATED ALWAYS AS IDENTITY,
    device_id VARCHAR(32) NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL,
    temperature NUMERIC(5, 2) NOT NULL,
    humidity NUMERIC(5, 2) NOT NULL,
    PRIMARY KEY (reading_id, recorded_at)
) PARTITION BY RANGE (recorded_at);

-- 2. Create monthly child partitions for Q1 2026
CREATE TABLE telemetry_2026_01 PARTITION OF telemetry_readings
    FOR VALUES FROM ('2026-01-01 00:00:00+00') TO ('2026-02-01 00:00:00+00');

CREATE TABLE telemetry_2026_02 PARTITION OF telemetry_readings
    FOR VALUES FROM ('2026-02-01 00:00:00+00') TO ('2026-03-01 00:00:00+00');

CREATE TABLE telemetry_2026_03 PARTITION OF telemetry_readings
    FOR VALUES FROM ('2026-03-01 00:00:00+00') TO ('2026-04-01 00:00:00+00');

-- 3. Create default catch-all partition
CREATE TABLE telemetry_default PARTITION OF telemetry_readings DEFAULT;

-- 4. Create composite index on device_id and recorded_at (propagates to child partitions)
CREATE INDEX idx_telemetry_device_time ON telemetry_readings (device_id, recorded_at);

-- 5. Seed test data
INSERT INTO telemetry_readings (device_id, recorded_at, temperature, humidity) VALUES
('DEV-IOT-001', '2026-01-10 14:20:00+00', 21.5, 45.0),
('DEV-IOT-002', '2026-01-25 09:15:00+00', 22.0, 48.2),
('DEV-IOT-001', '2026-02-05 18:00:00+00', 19.8, 52.1),
('DEV-IOT-003', '2026-02-20 11:30:00+00', 23.4, 41.0),
('DEV-IOT-002', '2026-03-12 08:45:00+00', 20.1, 49.5),
('DEV-IOT-999', '2026-06-01 12:00:00+00', 30.0, 60.0); -- Lands in default partition
