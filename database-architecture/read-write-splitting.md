# Read-Write Splitting Architecture

> **Module:** Database Architecture  
> **Target Audience:** Backend Developers, Software Architects, Database Engineers  
> **Relevant Technologies:** Java / Spring Boot, HikariCP, PgBouncer, ProxySQL, PostgreSQL, MySQL

---

## 1. What It Is

**Read-Write Splitting** is the architectural pattern of routing state-modifying database statements (`INSERT`, `UPDATE`, `DELETE`, `DDL`) to the authoritative **Primary database**, while directing read-only operations (`SELECT`) to an elastic pool of **Read Replicas**.

```text
HTTP Request (POST /orders) ──> Spring Boot Service ──> Primary DataSource ──> Primary DB (Writes)
HTTP Request (GET /catalog) ──> Spring Boot Service ──> Replica DataSource ──> Read Replica Pool (Reads)
```

---

## 2. Why It Is Needed (Problem Statement)

1. **Primary Database Overload:** When an application directs both transactional writes and analytical read queries to the same primary node, CPU cycles, memory caches, and disk I/O are shared. Complex `SELECT` aggregations cause locks and cache eviction, stalling critical transactional writes.
2. **Resource Optimization:** Read replicas can be sized differently (e.g., memory-optimized instances for query caching) while preserving high-IOPS write instances for the primary.
3. **Maximizing Horizontal Investment:** Simply having standby replicas running for failover leaves compute idle; read-write splitting leverages those standbys to actively absorb read query volume.

---

## 3. Architecture & Internal Mechanics

```mermaid
flowchart TD
    Client["Client HTTP Request"] --> Controller["Spring Boot REST Controller"]
    Controller --> Service["Transactional Service Layer"]

    subgraph RoutingTier["Application-Level Routing (Spring Boot)"]
        TxCheck{"Inspect @Transactional annotation"}
        Service --> TxCheck
        TxCheck -->|readOnly = false (Default)| WriteBranch["RoutingContext = PRIMARY"]
        TxCheck -->|readOnly = true| ReadBranch["RoutingContext = REPLICA"]

        WriteBranch --> AbstractDS["AbstractRoutingDataSource"]
        ReadBranch --> AbstractDS

        AbstractDS -->|Key = PRIMARY| HikariPrimary["HikariCP Pool: Primary (20 conns)"]
        AbstractDS -->|Key = REPLICA| HikariReplica["HikariCP Pool: Replicas (50 conns)"]
    end

    subgraph DatabaseTier["Database Cluster"]
        HikariPrimary --> PrimaryDB[("PostgreSQL Primary Node")]
        HikariReplica --> Rep1[("Read Replica 1")]
        HikariReplica --> Rep2[("Read Replica 2")]
        PrimaryDB -.->|Replication Stream| Rep1
        PrimaryDB -.->|Replication Stream| Rep2
    end
```

### 3.1 Routing Paradigms: Application vs Proxy Layer

| Paradigm | How It Works | Advantages | Disadvantages |
| :--- | :--- | :--- | :--- |
| **Application Layer** (e.g., Spring Boot `AbstractRoutingDataSource`) | Code inspects transaction boundaries (`@Transactional(readOnly = true)`) and switches Hikari pools dynamically. | Zero proxy latency; no extra infrastructure; direct pool control and metrics. | Tied to application language/framework; code changes required for legacy systems. |
| **Proxy Layer** (e.g., PgBouncer + Pgpool-II / ProxySQL / AWS RDS Proxy) | Application connects to proxy on a single port; proxy parses SQL text and routes to nodes. | Polyglot (any language can use it); transparent to developers. | Extra network hop adds 0.5–2ms latency; proxy can misroute transactions containing prepared statements or session variables. |

---

## 4. Java Spring Boot Implementation Pattern

In Spring Boot, dynamic datasource routing is implemented by extending `AbstractRoutingDataSource`:

```java
package com.database.routing;

import org.springframework.jdbc.datasource.lookup.AbstractRoutingDataSource;

public class TransactionRoutingDataSource extends AbstractRoutingDataSource {
    @Override
    protected Object determineCurrentLookupKey() {
        return DatabaseContextHolder.getDatabaseType();
    }
}
```

```java
package com.database.routing;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Aspect
@Component
@Order(0) // Must execute BEFORE Spring's @Transactional creates the connection
public class ReadOnlyRouteInterceptor {

    @Around("@annotation(transactional)")
    public Object route(ProceedingJoinPoint joinPoint, Transactional transactional) throws Throwable {
        try {
            if (transactional.readOnly()) {
                DatabaseContextHolder.setDatabaseType(DatabaseType.REPLICA);
            } else {
                DatabaseContextHolder.setDatabaseType(DatabaseType.PRIMARY);
            }
            return joinPoint.proceed();
        } finally {
            DatabaseContextHolder.clear();
        }
    }
}
```

---

## 5. Handling Read-After-Write Consistency

The greatest hazard in read-write splitting is **replication lag**. If a user submits an order, the browser redirects to `/orders/101`. If `/orders/101` reads from a replica that has not caught up to the primary's commit, the user receives an HTTP 404 "Order Not Found".

### Architectural Solutions:
1. **Sticky Session / Pin-to-Primary Window:** Route reads to the primary for 2–5 seconds immediately following any write by that user (stored in user session or Redis token).
2. **LSN / Token Tracking (Causal Consistency):** The primary returns the committed LSN in the response header. The replica pool validates `pg_last_wal_replay_lsn() >= required_lsn` before serving the read.
3. **Explicit Write Path Enforcement:** Keep critical reads in `@Transactional(readOnly = false)` or a specialized `@TargetPrimary` annotation.

---

## 6. Common Implementation Mistakes

1. **Order of AOP Interceptor:** Setting the routing aspect's `@Order` lower than Spring's `TransactionInterceptor`. If Spring acquires the JDBC connection before the aspect sets the ThreadLocal, the connection always defaults to the primary pool!
2. **Missing `readOnly = true`:** Developers forget to annotate read-only methods with `@Transactional(readOnly = true)`, causing 100% of read traffic to burden the primary.
3. **Single Connection Pool for Both Nodes:** Creating a single pool pointing to a proxy load balancer instead of separate pools. If replicas lag or disconnect, pool exhaustion stalls writes on the primary.

---

## 7. Authoritative References

- [Spring Framework: AbstractRoutingDataSource](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/jdbc/datasource/lookup/AbstractRoutingDataSource.html)
- [HikariCP Connection Pool Best Practices](https://github.com/brettwooldridge/HikariCP)
- [ProxySQL Read-Write Splitting Rules](https://proxysql.com/documentation/)
