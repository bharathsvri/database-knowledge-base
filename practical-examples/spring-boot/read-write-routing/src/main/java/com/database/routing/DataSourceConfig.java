package com.database.routing;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.datasource.LazyConnectionDataSourceProxy;

import javax.sql.DataSource;
import java.util.HashMap;
import java.util.Map;

@Configuration
public class DataSourceConfig {

    private HikariDataSource buildHikariPool(String url, String username, String password, String poolName, int maxPoolSize) {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(url);
        config.setUsername(username);
        config.setPassword(password);
        config.setPoolName(poolName);
        config.setMaximumPoolSize(maxPoolSize);
        config.setMinimumIdle(5);
        config.setConnectionTimeout(30000);
        config.setIdleTimeout(600000);
        config.setMaxLifetime(1800000);
        return new HikariDataSource(config);
    }

    @Bean
    public DataSource primaryDataSource() {
        return buildHikariPool("jdbc:postgresql://localhost:5432/app_db", "app_user", "password123", "Hikari-Primary", 20);
    }

    @Bean
    public DataSource replicaDataSource() {
        return buildHikariPool("jdbc:postgresql://localhost:5433/app_db", "app_user", "password123", "Hikari-Replica", 40);
    }

    @Bean
    public DataSource routingDataSource() {
        TransactionRoutingDataSource routing = new TransactionRoutingDataSource();
        Map<Object, Object> targetDataSources = new HashMap<>();
        targetDataSources.put(DatabaseType.PRIMARY, primaryDataSource());
        targetDataSources.put(DatabaseType.REPLICA, replicaDataSource());

        routing.setTargetDataSources(targetDataSources);
        routing.setDefaultTargetDataSource(primaryDataSource());
        routing.afterPropertiesSet();
        return routing;
    }

    /**
     * CRITICAL: LazyConnectionDataSourceProxy delays physical JDBC connection acquisition
     * until the first SQL statement actually executes within the transaction boundary.
     * This ensures the ThreadLocal context set by ReadOnlyRouteInterceptor is active!
     */
    @Bean
    @Primary
    public DataSource dataSource() {
        return new LazyConnectionDataSourceProxy(routingDataSource());
    }
}
