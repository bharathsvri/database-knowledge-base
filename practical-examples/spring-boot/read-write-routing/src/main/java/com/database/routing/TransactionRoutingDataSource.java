package com.database.routing;

import org.springframework.jdbc.datasource.lookup.AbstractRoutingDataSource;

/**
 * Dynamic DataSource routing implementation for Read-Write Splitting.
 * Inspects ThreadLocal DatabaseContextHolder to return PRIMARY or REPLICA key.
 */
public class TransactionRoutingDataSource extends AbstractRoutingDataSource {

    @Override
    protected Object determineCurrentLookupKey() {
        DatabaseType type = DatabaseContextHolder.getDatabaseType();
        return (type != null) ? type : DatabaseType.PRIMARY;
    }
}
