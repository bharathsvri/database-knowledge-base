-- SQL Joins Catalog: Syntax and Semantics

-- 1. INNER JOIN: Returns only rows where match exists in both tables
SELECT c.customer_id, c.email, o.order_number, o.total_amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;

-- 2. LEFT OUTER JOIN: Returns all rows from left table, NULL for non-matching right rows
SELECT c.customer_id, c.first_name, o.order_number
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- Find customers who have NEVER placed an order (Anti-Join pattern):
SELECT c.customer_id, c.first_name, c.email
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 3. RIGHT OUTER JOIN: Returns all rows from right table
SELECT o.order_number, c.first_name
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;

-- 4. FULL OUTER JOIN: Returns all rows from both tables, filling NULLs where no match
SELECT c.customer_id, o.order_id
FROM customers c
FULL OUTER JOIN orders o ON c.customer_id = o.customer_id;

-- 5. CROSS JOIN (Cartesian Product)
SELECT c.first_name, p.product_name
FROM customers c
CROSS JOIN (VALUES ('Premium Support'), ('Standard Warranty')) AS p(product_name);

-- 6. SELF JOIN: Comparing rows within the same table (e.g. employee to manager)
-- Assuming an employees table with manager_id:
-- SELECT e.name AS emp, m.name AS manager FROM employees e LEFT JOIN employees m ON e.manager_id = m.id;

-- 7. LATERAL JOIN (PostgreSQL power feature: correlated subquery per row)
-- Returns the latest 2 orders for each active customer:
SELECT c.customer_id, c.first_name, latest_orders.order_id, latest_orders.order_date
FROM customers c
CROSS JOIN LATERAL (
    SELECT o.order_id, o.order_date
    FROM orders o
    WHERE o.customer_id = c.customer_id
    ORDER BY o.order_date DESC
    LIMIT 2
) latest_orders
WHERE c.is_active = true;
