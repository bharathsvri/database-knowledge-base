package com.database.sharding;

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
public class ShardDataSourceConfig {

    private HikariDataSource buildShardPool(String jdbcUrl, String poolName) {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(jdbcUrl);
        config.setUsername("app_user");
        config.setPassword("password123");
        config.setPoolName(poolName);
        config.setMaximumPoolSize(20);
        config.setMinimumIdle(5);
        config.setConnectionTimeout(30000);
        return new HikariDataSource(config);
    }

    @Bean
    public DataSource shard1DataSource() {
        return buildShardPool("jdbc:postgresql://localhost:5432/shard_1", "Hikari-Shard-1");
    }

    @Bean
    public DataSource shard2DataSource() {
        return buildShardPool("jdbc:postgresql://localhost:5432/shard_2", "Hikari-Shard-2");
    }

    @Bean
    public DataSource shard3DataSource() {
        return buildShardPool("jdbc:postgresql://localhost:5432/shard_3", "Hikari-Shard-3");
    }

    @Bean
    public DataSource shardRoutingDataSource() {
        ShardRoutingDataSource routing = new ShardRoutingDataSource();
        Map<Object, Object> dataSources = new HashMap<>();
        dataSources.put("SHARD_1", shard1DataSource());
        dataSources.put("SHARD_2", shard2DataSource());
        dataSources.put("SHARD_3", shard3DataSource());

        routing.setTargetDataSources(dataSources);
        routing.setDefaultTargetDataSource(shard1DataSource());
        routing.afterPropertiesSet();
        return routing;
    }

    @Bean
    @Primary
    public DataSource dataSource() {
        return new LazyConnectionDataSourceProxy(shardRoutingDataSource());
    }
}
