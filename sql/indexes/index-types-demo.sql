-- Advanced Indexing Types in PostgreSQL

-- 1. Standard B-Tree Composite Index
CREATE INDEX idx_orders_customer_date 
ON orders (customer_id, order_date DESC);

-- 2. Covering Index (Index-Only Scan) via INCLUDE clause
CREATE INDEX idx_orders_covering 
ON orders (customer_id, status) 
INCLUDE (total_amount, order_date);

-- 3. Partial Index (Filters indexed rows to save RAM and write IOPS)
CREATE INDEX idx_orders_unfulfilled 
ON orders (order_date) 
WHERE status IN ('PENDING', 'PAID');

-- 4. Functional / Expression Index (Index on computed value)
-- Accelerates queries like: WHERE lower(email) = 'user@example.com'
CREATE INDEX idx_customers_lower_email 
ON customers (lower(email));

-- 5. GIN Index on JSONB Columns (Document Containment)
-- Accelerates: WHERE metadata @> '{"tier": "gold"}'
-- CREATE INDEX idx_orders_metadata ON orders USING GIN (metadata);

-- 6. Concurrent Index Creation (Zero table-locking downtime in production)
-- CREATE INDEX CONCURRENTLY idx_orders_amount ON orders (total_amount);
