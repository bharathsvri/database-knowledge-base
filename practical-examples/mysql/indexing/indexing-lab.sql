-- MySQL 8.0+ Indexing Lab: Composite Indexes & Invisible Indexes

DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    email VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tenant_status (tenant_id, status)
) ENGINE=InnoDB;

-- 1. Demonstrate Invisible Index (Safe Testing Before Dropping)
-- Make index invisible to the optimizer
ALTER TABLE users ALTER INDEX idx_tenant_status INVISIBLE;

-- Explain will now show Table Scan:
EXPLAIN SELECT * FROM users WHERE tenant_id = 10 AND status = 'ACTIVE';

-- Make index visible again
ALTER TABLE users ALTER INDEX idx_tenant_status VISIBLE;

-- Explain now utilizes the composite index:
EXPLAIN SELECT * FROM users WHERE tenant_id = 10 AND status = 'ACTIVE';
