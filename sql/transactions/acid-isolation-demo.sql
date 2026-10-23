-- Transaction Control, Isolation, and Pessimistic Locking

-- 1. Explicit Transaction with Savepoint & Partial Rollback
BEGIN;

INSERT INTO customers (first_name, last_name, email) 
VALUES ('Mark', 'Ruffalo', 'mark.r@example.com');

SAVEPOINT customer_created;

-- Simulate operation that violates constraint:
-- INSERT INTO orders (order_id, customer_id, total_amount) VALUES (1, 999999, -100);

-- Recover from error without aborting transaction:
-- ROLLBACK TO SAVEPOINT customer_created;

COMMIT;

-- 2. Pessimistic Row Locking (SELECT FOR UPDATE)
-- Locks selected rows against concurrent UPDATE/DELETE until transaction commits
BEGIN;

SELECT balance 
FROM accounts 
WHERE account_id = 101 
FOR UPDATE;

-- Concurrent transactions trying to SELECT ... FOR UPDATE or UPDATE account_id = 101 
-- will BLOCK until this transaction commits or rolls back!
UPDATE accounts 
SET balance = balance - 50.00 
WHERE account_id = 101;

COMMIT;

-- 3. Non-Blocking Pessimistic Locking with SKIP LOCKED (Job Queue Pattern)
-- Selects and locks next available queue item without blocking on locked rows:
BEGIN;

SELECT job_id, payload 
FROM background_jobs 
WHERE status = 'QUEUED' 
ORDER BY priority DESC, created_at ASC 
LIMIT 1 
FOR UPDATE SKIP LOCKED;

-- Marks job as PROCESSING and commits, releasing row for worker:
-- UPDATE background_jobs SET status = 'PROCESSING' WHERE job_id = ...;
COMMIT;
