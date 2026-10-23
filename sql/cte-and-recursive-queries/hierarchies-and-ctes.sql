-- CTEs and Recursive Queries
-- Common Table Expressions (WITH clause)

-- 1. Standard Modular CTE: Improves query readability and refactoring
WITH HighValueOrders AS (
    SELECT customer_id, count(*) AS order_count, sum(total_amount) AS total_spent
    FROM orders
    WHERE order_date >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY customer_id
    HAVING sum(total_amount) > 1000
),
VIPCustomers AS (
    SELECT c.customer_id, c.first_name, c.email, hvo.total_spent
    FROM customers c
    INNER JOIN HighValueOrders hvo ON c.customer_id = hvo.customer_id
)
SELECT * FROM VIPCustomers ORDER BY total_spent DESC;

-- 2. Recursive CTE: Generating a Date Series (Alternative to generate_series)
WITH RECURSIVE DateRange AS (
    SELECT DATE '2026-01-01' AS calendar_date
    UNION ALL
    SELECT (calendar_date + INTERVAL '1 day')::DATE
    FROM DateRange
    WHERE calendar_date < DATE '2026-01-10'
)
SELECT calendar_date FROM DateRange;

-- 3. Recursive CTE: Tree / Graph Traversal (Category Hierarchy)
-- Schema setup for demonstration:
-- CREATE TABLE categories (cat_id INT PRIMARY KEY, name VARCHAR(50), parent_id INT);
WITH RECURSIVE CategoryPath AS (
    -- Anchor member: Root categories (no parent)
    SELECT cat_id, name, parent_id, name::TEXT AS breadcrumb, 1 AS level
    FROM categories
    WHERE parent_id IS NULL

    UNION ALL

    -- Recursive member: Subcategories
    SELECT c.cat_id, c.name, c.parent_id, (cp.breadcrumb || ' > ' || c.name)::TEXT, cp.level + 1
    FROM categories c
    INNER JOIN CategoryPath cp ON c.parent_id = cp.cat_id
)
SELECT cat_id, breadcrumb, level FROM CategoryPath ORDER BY breadcrumb;
