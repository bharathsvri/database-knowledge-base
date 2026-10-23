-- DML: Practical CRUD Operations, Upsert, and Bulk Manipulation

-- 1. Insert with RETURNING (PostgreSQL specific, eliminates round-trip query)
INSERT INTO customers (first_name, last_name, email)
VALUES ('Jane', 'Doe', 'jane.doe@example.com')
RETURNING customer_id, created_at;

-- 2. Bulk Insert (Multi-Row VALUES)
INSERT INTO customers (first_name, last_name, email) VALUES
('John', 'Smith', 'john.smith@example.com'),
('Alice', 'Johnson', 'alice.j@example.com'),
('Bob', 'Williams', 'bob.w@example.com');

-- 3. Upsert (ON CONFLICT DO UPDATE)
-- If email exists, update first_name and last_name rather than failing with unique violation
INSERT INTO customers (first_name, last_name, email)
VALUES ('Jane', 'Smith-Doe', 'jane.doe@example.com')
ON CONFLICT (email) 
DO UPDATE SET 
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    is_active = true
RETURNING customer_id, first_name, last_name;

-- 4. Update with FROM clause (Cross-Table Update)
UPDATE orders o
SET status = 'CANCELLED'
FROM customers c
WHERE o.customer_id = c.customer_id
  AND c.is_active = false
  AND o.status = 'PENDING';

-- 5. Delete with RETURNING
DELETE FROM orders 
WHERE status = 'CANCELLED'
RETURNING order_id, customer_id, order_number;
