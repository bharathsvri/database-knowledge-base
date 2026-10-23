package com.database.routing;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * AOP aspect that intercepts methods annotated with @Transactional.
 * Runs at Order(0) so the routing context is established BEFORE Spring's
 * TransactionInterceptor opens a JDBC connection.
 */
@Aspect
@Component
@Order(0)
public class ReadOnlyRouteInterceptor {

    private static final Logger log = LoggerFactory.getLogger(ReadOnlyRouteInterceptor.class);

    @Around("@annotation(transactional)")
    public Object route(ProceedingJoinPoint joinPoint, Transactional transactional) throws Throwable {
        try {
            if (transactional.readOnly()) {
                log.debug("Routing to REPLICA datasource for read-only transaction");
                DatabaseContextHolder.setDatabaseType(DatabaseType.REPLICA);
            } else {
                log.debug("Routing to PRIMARY datasource for read-write transaction");
                DatabaseContextHolder.setDatabaseType(DatabaseType.PRIMARY);
            }
            return joinPoint.proceed();
        } finally {
            DatabaseContextHolder.clear();
        }
    }
}
