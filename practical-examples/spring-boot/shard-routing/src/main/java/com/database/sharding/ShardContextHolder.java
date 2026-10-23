package com.database.sharding;

public final class ShardContextHolder {

    private static final ThreadLocal<String> CURRENT_SHARD = new ThreadLocal<>();

    private ShardContextHolder() {}

    public static void setCurrentShard(String shardId) {
        CURRENT_SHARD.set(shardId);
    }

    public static String getCurrentShard() {
        return CURRENT_SHARD.get();
    }

    public static void clear() {
        CURRENT_SHARD.remove();
    }
}
