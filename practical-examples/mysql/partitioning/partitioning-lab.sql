-- MySQL 8.0+ Range Partitioning by Year

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id INT NOT NULL,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    amount DECIMAL(10, 2),
    PRIMARY KEY (order_id, order_date)
) ENGINE=InnoDB
PARTITION BY RANGE (YEAR(order_date)) (
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p_max VALUES LESS THAN MAXVALUE
);

-- Seed data
INSERT INTO orders VALUES
(1, 101, '2024-05-15', 120.00),
(2, 102, '2025-08-20', 350.50),
(3, 103, '2026-02-10', 890.00);

-- Verify partition pruning
EXPLAIN SELECT * FROM orders WHERE order_date BETWEEN '2026-01-01' AND '2026-03-31';
-- Partitions column in EXPLAIN will show ONLY 'p2026'!
