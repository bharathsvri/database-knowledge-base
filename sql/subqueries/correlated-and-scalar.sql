-- Subqueries: Scalar, Multi-row, and Correlated Subqueries

-- 1. Scalar Subquery in SELECT list (Returns exactly 1 row, 1 column)
SELECT 
    c.customer_id,
    c.first_name,
    (SELECT count(*) FROM orders o WHERE o.customer_id = c.customer_id) AS total_orders,
    (SELECT coalesce(avg(total_amount), 0.00) FROM orders o WHERE o.customer_id = c.customer_id) AS avg_spend
FROM customers c;

-- 2. Multi-Row Subquery in WHERE clause (IN vs EXISTS)
-- Using EXISTS (Optimized by the query planner as a Semi-Join):
SELECT c.customer_id, c.first_name, c.email
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o 
    WHERE o.customer_id = c.customer_id 
      AND o.total_amount > 500.00
);

-- 3. Correlated Subquery: Find orders that exceed the customer's personal average order amount
SELECT o1.order_id, o1.customer_id, o1.total_amount
FROM orders o1
WHERE o1.total_amount > (
    SELECT avg(o2.total_amount)
    FROM orders o2
    WHERE o2.customer_id = o1.customer_id
);

-- 4. Derived Table (Subquery in FROM clause)
SELECT dept_stats.dept_name, dept_stats.avg_salary
FROM (
    SELECT d.dept_name, avg(e.salary) AS avg_salary
    FROM departments d
    JOIN employees e ON d.dept_id = e.dept_id
    GROUP BY d.dept_name
) AS dept_stats
WHERE dept_stats.avg_salary > 75000;
