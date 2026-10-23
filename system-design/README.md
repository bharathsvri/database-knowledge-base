# Database System Design & Architectural Patterns

This module provides end-to-end database system design architectures for real-world enterprise domains, capacity estimations, and scaling strategies.

---

## System Design Directory

| Case Study / Architecture | Primary Domain | Core Architectural Patterns |
| :--- | :--- | :--- |
| **[Database Capacity Estimation](database-capacity-estimation.md)** | Estimation Framework | Mathematical formulas for QPS, write IOPS, storage projections, and buffer pool sizing. |
| **[E-Commerce Database Design](e-commerce-database-design.md)** | Retail & Marketplace | Product catalogs, shopping carts, inventory reservation, flash sales, order history. |
| **[Banking & Ledger Database Design](banking-database-design.md)** | Fintech & Payments | Double-entry bookkeeping, strict auditability, immutable ledger tables, idempotency. |
| **[Multi-Tenant Database Design](multi-tenant-database-design.md)** | B2B Enterprise SaaS | Database-per-tenant vs Schema-per-tenant vs Shared Schema with Row-Level Security (RLS). |
| **[Database Scaling Strategies](database-scaling-strategies.md)** | Global Scaling | Vertical scale limits, read replication, caching, sharding, and polyglot persistence. |
