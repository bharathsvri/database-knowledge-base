package com.database.sharding;

import org.springframework.stereotype.Service;

@Service
public class ShardRouterService {

    private static final int TOTAL_SHARDS = 3;

    public String resolveShard(String customerId) {
        if (customerId == null || customerId.isBlank()) {
            return "SHARD_1";
        }
        int hash = Math.abs(customerId.hashCode());
        int shardIndex = (hash % TOTAL_SHARDS) + 1;
        return "SHARD_" + shardIndex;
    }

    public <T> T executeOnShard(String customerId, ShardSupplier<T> supplier) {
        String targetShard = resolveShard(customerId);
        ShardContextHolder.setCurrentShard(targetShard);
        try {
            return supplier.get();
        } finally {
            ShardContextHolder.clear();
        }
    }

    @FunctionalInterface
    public interface ShardSupplier<T> {
        T get();
    }
}
