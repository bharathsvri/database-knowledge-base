# Practical Database Engineering Labs & Code Examples

This directory provides runnable, syntax-checked SQL laboratories, Docker Compose orchestration files, and modern Java Spring Boot implementations for database engineering patterns.

---

## Lab Directory

| Category | Lab Directory | Technology & Focus |
| :--- | :--- | :--- |
| **PostgreSQL Labs** | [`postgresql/`](postgresql/README.md) | Physical Streaming Replication, Declarative Partitioning, Advanced Indexing (Covering & GIN), Point-In-Time Recovery (PITR). |
| **MySQL Labs** | [`mysql/`](mysql/README.md) | InnoDB Partitioning, Composite Indexing, Invisible Indexes. |
| **Java / Spring Boot Labs** | [`spring-boot/`](spring-boot/README.md) | Dynamic Read-Write Routing (`AbstractRoutingDataSource`), Shard Key Context Routing, HikariCP Connection Pool Sizing & Metrics. |

---

## Standard Lab Structure
Each practical lab includes:
1. **Prerequisites & Environment Setup:** Minimal local dependencies (Docker, PostgreSQL 14+, Java 17+, Maven).
2. **Setup Scripts (DDL/DML):** Runnable schema definitions and test data.
3. **Verification Commands & Queries:** Diagnostic queries, `EXPLAIN ANALYZE` commands, and expected terminal outputs.
4. **Failure Scenarios & Troubleshooting:** What breaks under load or node failure, and how to triage it.
5. **Security Considerations:** Least privilege roles, SSL enforcement, credential isolation.
6. **Cleanup Scripts:** Tear-down commands to reset your local workstation environment.
