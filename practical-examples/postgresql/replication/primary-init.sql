-- Executed automatically on container creation of pg-primary

-- 1. Create dedicated replication user with REPLICATION privilege
CREATE ROLE replicator WITH REPLICATION LOGIN ENCRYPTED PASSWORD 'ReplicatorSecretPassword123!';

-- 2. Create sample business table
CREATE TABLE customer_orders (
    order_id BIGSERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- 3. Populate test records
INSERT INTO customer_orders (customer_name, amount) VALUES
('Acme Corporation', 12500.00),
('Globex Logistics', 4320.50),
('Soylent Industries', 890.00);
