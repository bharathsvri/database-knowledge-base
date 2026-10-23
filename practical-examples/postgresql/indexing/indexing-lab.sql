-- Advanced PostgreSQL Indexing Demonstration
-- Covers: B-Tree Covering Indexes (INCLUDE), GIN Index on JSONB, and Partial Indexes

DROP TABLE IF EXISTS customer_events CASCADE;

CREATE TABLE customer_events (
    event_id BIGSERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    payload JSONB NOT NULL,
    is_processed BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- Seed 10,000 synthetic records
INSERT INTO customer_events (customer_id, event_type, payload, is_processed, created_at)
SELECT 
    (random() * 500)::INT,
    (ARRAY['LOGIN', 'PURCHASE', 'LOGOUT', 'ADD_TO_CART'])[(random() * 3 + 1)::INT],
    jsonb_build_object(
        'ip', '192.168.1.' || (random() * 254)::INT,
        'amount', (random() * 1000)::NUMERIC(10,2),
        'device', (ARRAY['iOS', 'Android', 'Web'])[(random() * 2 + 1)::INT]
    ),
    (random() > 0.8), -- ~20% unprocessed
    clock_timestamp() - (random() * interval '30 days')
FROM generate_series(1, 10000);

-- 1. Covering Index with INCLUDE (Index-Only Scan)
CREATE INDEX idx_events_customer_covering 
ON customer_events (customer_id, event_type) 
INCLUDE (created_at);

-- 2. GIN Index on JSONB for arbitrary key search
CREATE INDEX idx_events_payload_gin 
ON customer_events USING GIN (payload);

-- 3. Partial Index (Indexes ONLY unprocessed rows, saving 80% index space!)
CREATE INDEX idx_events_unprocessed 
ON customer_events (created_at) 
WHERE is_processed = false;

-- Verification Queries:
-- Test 1: Verify Index-Only Scan using Covering Index
EXPLAIN (ANALYZE, COSTS OFF)
SELECT customer_id, event_type, created_at 
FROM customer_events 
WHERE customer_id = 42 AND event_type = 'PURCHASE';

-- Test 2: Verify GIN Index on JSON containment query (@>)
EXPLAIN (ANALYZE, COSTS OFF)
SELECT count(*) 
FROM customer_events 
WHERE payload @> '{"device": "iOS"}';

-- Test 3: Verify Partial Index usage
EXPLAIN (ANALYZE, COSTS OFF)
SELECT * FROM customer_events 
WHERE is_processed = false 
ORDER BY created_at ASC LIMIT 10;
