-- DDL: Comprehensive Schema & Table Creation Examples
-- Compatible with PostgreSQL 13+

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Custom Enum Type
CREATE TYPE order_status AS ENUM ('PENDING', 'PAID', 'SHIPPED', 'DELIVERED', 'CANCELLED');

-- 2. Master Customers Table
CREATE TABLE customers (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_uuid UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

-- 3. Orders Table with Foreign Key & Check Constraints
CREATE TABLE orders (
    order_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_number VARCHAR(32) NOT NULL UNIQUE,
    status order_status NOT NULL DEFAULT 'PENDING',
    subtotal NUMERIC(12, 2) NOT NULL CHECK (subtotal >= 0),
    tax NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (tax >= 0),
    total_amount NUMERIC(12, 2) GENERATED ALWAYS AS (subtotal + tax) STORED,
    order_date TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) 
        REFERENCES customers (customer_id) ON DELETE RESTRICT
);

-- 4. Order Line Items Table
CREATE TABLE order_items (
    item_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0),
    quantity INT NOT NULL CHECK (quantity > 0),
    CONSTRAINT fk_items_order FOREIGN KEY (order_id) 
        REFERENCES orders (order_id) ON DELETE CASCADE
);
