package com.database.sharding;

import org.springframework.jdbc.datasource.lookup.AbstractRoutingDataSource;

public class ShardRoutingDataSource extends AbstractRoutingDataSource {

    @Override
    protected Object determineCurrentLookupKey() {
        String shardKey = ShardContextHolder.getCurrentShard();
        return (shardKey != null) ? shardKey : "SHARD_1";
    }
}
