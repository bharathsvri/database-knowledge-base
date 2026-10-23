# Connection Pool Tuning & Starvation Analysis

> **Target:** Backend Developers, SREs  
> **Tooling:** Java / Spring Boot, HikariCP, Micrometer, Prometheus

---

## 1. The Pool Starvation Trap
Pool starvation occurs when all connections in a pool are borrowed and new threads are blocked waiting for `connection-timeout` (default 30s) before throwing:
```text
org.springframework.jdbc.CannotGetJdbcConnectionException: 
Failed to obtain JDBC Connection; nested exception is java.sql.SQLTransientConnectionException: 
HikariPool-1 - Connection is not available, request timed out after 30005ms.
```

### Common Root Causes
1. **Thread Holding Connection During Remote API Call:** A method annotated with `@Transactional` calls a slow payment gateway HTTP endpoint while holding a connection open.
2. **Missing Transaction Boundaries:** Unbounded result sets read in memory over multiple minutes.
3. **Connection Leaks:** Direct JDBC `dataSource.getConnection()` without closing in `try-with-resources`.

---

## 2. PostgreSQL / HikariCP Pool Sizing Formula
$$\text{Pool Size} = ((\text{CPU Cores} \times 2) + \text{Effective Spindle Count})$$

| Database Hardware | Cores | Storage Type | Recommended Max Pool Size |
| :--- | :---: | :--- | :---: |
| **AWS db.r6g.large** | 2 | NVMe SSD (spindle = 1) | **5–7** |
| **AWS db.r6g.xlarge** | 4 | NVMe SSD (spindle = 1) | **9–10** |
| **AWS db.r6g.4xlarge** | 16 | NVMe SSD (spindle = 1) | **33–35** |

Setting `maxPoolSize = 200` on a 4-core machine degrades performance due to kernel context switching!

---

## 3. HikariCP Production Configuration
```properties
# Maximum physical connections
spring.datasource.hikari.maximum-pool-size=20

# Fixed-size pool optimization (minimum-idle equals maximum-pool-size)
spring.datasource.hikari.minimum-idle=20

# Milliseconds before throwing timeout exception
spring.datasource.hikari.connection-timeout=30000

# Connection lifetime (set 2-3 mins shorter than infrastructure firewall timeouts)
spring.datasource.hikari.max-lifetime=1800000

# Leak detection threshold: logs warning stack trace if a thread holds connection > 5 seconds
spring.datasource.hikari.leak-detection-threshold=5000
```
