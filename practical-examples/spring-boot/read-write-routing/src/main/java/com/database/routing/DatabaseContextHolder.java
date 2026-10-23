package com.database.routing;

/**
 * Thread-safe context holder storing the active DatabaseType (PRIMARY or REPLICA)
 * for the currently executing thread.
 */
public final class DatabaseContextHolder {

    private static final ThreadLocal<DatabaseType> CONTEXT = new ThreadLocal<>();

    private DatabaseContextHolder() {}

    public static void setDatabaseType(DatabaseType type) {
        CONTEXT.set(type);
    }

    public static DatabaseType getDatabaseType() {
        return CONTEXT.get();
    }

    public static void clear() {
        CONTEXT.remove();
    }
}
