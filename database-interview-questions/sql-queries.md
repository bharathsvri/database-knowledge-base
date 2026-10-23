# SQL Queries & Problem-Solving Interview Questions

> **Module:** Database Interview Preparation  
> **Topic:** Joins, Subqueries, CTEs, Window Functions, Complex Analytics  
> **Target Audience:** Software Engineers, Backend Developers, Data Analysts

---

## Difficulty Navigation
- [Intermediate Level](#intermediate-level)
- [Advanced Level](#advanced-level)
- [Senior Engineer Level](#senior-engineer-level)

---

## Intermediate Level

### Q1: Find the N-th highest salary from an Employee table.
#### Short Interview-Ready Answer
"The most reliable and standards-compliant way to find the N-th highest salary in SQL is using the `DENSE_RANK()` window function inside a Common Table Expression (CTE) or subquery. `DENSE_RANK()` cleanly handles ties (duplicate salaries) without skipping rank positions."

```sql
WITH RankedSalaries AS (
    SELECT 
        employee_id, 
        salary,
        DENSE_RANK() OVER (ORDER BY salary DESC) AS salary_rank
    FROM employees
)
SELECT salary 
FROM RankedSalaries 
WHERE salary_rank = 3; -- Example: 3rd highest salary
```

*Alternative using LIMIT/OFFSET (vulnerable to duplicate values unless `DISTINCT` is used):*
```sql
SELECT DISTINCT salary 
FROM employees 
ORDER BY salary DESC 
LIMIT 1 OFFSET 2; -- (N - 1) offset for 3rd highest
```

---

### Q2: What is the difference between `WHERE` and `HAVING`?
#### Short Interview-Ready Answer
"`WHERE` filters individual rows **before** any aggregation or `GROUP BY` operation takes place. `HAVING` filters aggregated groups **after** the aggregation calculations (`COUNT`, `SUM`, `AVG`) have been computed by the execution engine."

---

## Advanced Level

### Q3: What is the difference between `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`?
#### Short Interview-Ready Answer
"When ranking duplicate values (e.g., salaries: 100, 90, 90, 80):
- `ROW_NUMBER()` assigns sequential unique integers regardless of ties: **1, 2, 3, 4**.
- `RANK()` assigns identical ranks to ties and skips subsequent positions: **1, 2, 2, 4** (skips 3).
- `DENSE_RANK()` assigns identical ranks to ties without skipping subsequent positions: **1, 2, 2, 3**."

---

### Q4: Write a query to find all employees whose salary exceeds their manager's salary.
```sql
SELECT 
    e.employee_id,
    e.first_name AS employee_name,
    e.salary AS employee_salary,
    m.first_name AS manager_name,
    m.salary AS manager_salary
FROM employees e
INNER JOIN employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;
```

---

## Senior Engineer Level

### Q5: Write a recursive CTE to traverse an organizational hierarchy tree.
#### Problem Statement
Given an `employees` table with `(employee_id, name, manager_id)`, retrieve the full reporting chain from the CEO down to junior staff, including tree depth.

```sql
WITH RECURSIVE OrgHierarchy AS (
    -- Anchor member: Start at the top with the CEO (manager_id IS NULL)
    SELECT 
        employee_id, 
        name, 
        manager_id, 
        1 AS depth,
        name::TEXT AS hierarchy_path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive member: Find all direct reports
    SELECT 
        e.employee_id, 
        e.name, 
        e.manager_id, 
        oh.depth + 1,
        (oh.hierarchy_path || ' -> ' || e.name)::TEXT
    FROM employees e
    INNER JOIN OrgHierarchy oh ON e.manager_id = oh.employee_id
)
SELECT depth, hierarchy_path, name 
FROM OrgHierarchy 
ORDER BY depth, hierarchy_path;
```

---

## Authoritative References
- [PostgreSQL Window Functions Tutorial](https://www.postgresql.org/docs/current/tutorial-window.html)
- [PostgreSQL Recursive Queries (WITH RECURSIVE)](https://www.postgresql.org/docs/current/queries-with.html)
