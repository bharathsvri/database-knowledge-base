# Spring Boot Read-Write Routing Lab

This module demonstrates dynamic DataSource routing between a **Primary writer** and **Read Replicas** using Spring Boot, HikariCP, and AOP.

---

## 1. Architectural Highlights
- Uses Spring's `AbstractRoutingDataSource` to select connection pools at runtime.
- Intercepts `@Transactional(readOnly = true)` to target the Replica pool and `@Transactional(readOnly = false)` to target the Primary pool.
- Wraps the routing DataSource in `LazyConnectionDataSourceProxy` to defer physical JDBC connection acquisition until the first statement executes, guaranteeing that the routing context is populated.

---

## 2. Key Components
1. [`TransactionRoutingDataSource.java`](src/main/java/com/database/routing/TransactionRoutingDataSource.java): Extends `AbstractRoutingDataSource`.
2. [`ReadOnlyRouteInterceptor.java`](src/main/java/com/database/routing/ReadOnlyRouteInterceptor.java): AOP Aspect executing at `@Order(0)`.
3. [`DataSourceConfig.java`](src/main/java/com/database/routing/DataSourceConfig.java): Builds isolated HikariCP pools for Primary and Replica.

---

## 3. Production Considerations
- **Causal Consistency / Read-After-Write:** In asynchronous replication setups, add a pinned session filter to route reads to the primary for 3 seconds following any user mutation.
