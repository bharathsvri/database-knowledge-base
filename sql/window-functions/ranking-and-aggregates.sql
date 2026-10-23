-- Window Functions Catalog: Ranking, Offsets, and Running Aggregates

-- 1. Ranking Functions: ROW_NUMBER, RANK, DENSE_RANK
SELECT 
    order_id,
    customer_id,
    total_amount,
    -- Unique sequential integer per customer partition:
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY total_amount DESC) AS row_num,
    -- Rank with gaps on ties:
    RANK() OVER (PARTITION BY customer_id ORDER BY total_amount DESC) AS rnk,
    -- Rank without gaps on ties:
    DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY total_amount DESC) AS dense_rnk
FROM orders;

-- 2. Value Offset Functions: LEAD and LAG
-- Calculate days elapsed since customer's previous order:
SELECT 
    order_id,
    customer_id,
    order_date,
    total_amount,
    LAG(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date,
    order_date - LAG(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS days_since_last_order,
    LEAD(total_amount, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order_amount
FROM orders;

-- 3. Running Totals and Moving Averages with Window Frames
SELECT 
    order_id,
    order_date,
    total_amount,
    -- Running total from beginning of time to current row:
    SUM(total_amount) OVER (
        ORDER BY order_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
    -- 7-row moving average:
    AVG(total_amount) OVER (
        ORDER BY order_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7_orders
FROM orders;
