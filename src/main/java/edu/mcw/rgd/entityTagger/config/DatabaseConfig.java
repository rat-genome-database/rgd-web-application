package edu.mcw.rgd.entityTagger.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.jndi.JndiObjectFactoryBean;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.naming.NamingException;
import javax.sql.DataSource;

/**
 * Database configuration for the RGD Curation Tool.
 * This configuration integrates with the existing RGD database using JNDI lookup.
 */
@Configuration
@EnableTransactionManagement
@PropertySource("classpath:curation-database.properties")
public class DatabaseConfig {

    @Autowired
    private Environment env;

    /**
     * Primary DataSource using JNDI lookup to connect to existing RGD database.
     * This integrates with the application server's connection pool.
     */
    @Bean
    @Primary
    public DataSource dataSource() {
        try {
            JndiObjectFactoryBean jndiObjectFactoryBean = new JndiObjectFactoryBean();
            jndiObjectFactoryBean.setJndiName(env.getProperty("db.jndi.name", "java:comp/env/jdbc/carpe"));
            jndiObjectFactoryBean.setProxyInterface(DataSource.class);
            jndiObjectFactoryBean.setLookupOnStartup(true);
            jndiObjectFactoryBean.afterPropertiesSet();
            return (DataSource) jndiObjectFactoryBean.getObject();
        } catch (NamingException e) {
            // Fallback to HikariCP for development/testing when JNDI is not available
            return developmentDataSource();
        }
    }

    /**
     * Development DataSource using HikariCP for local testing.
     * This is used when JNDI lookup fails (e.g., in development environment).
     */
    private DataSource developmentDataSource() {
        HikariConfig config = new HikariConfig();
        config.setDriverClassName(env.getProperty("db.driver"));
        config.setJdbcUrl(env.getProperty("db.url"));
        config.setUsername(env.getProperty("db.username"));
        config.setPassword(env.getProperty("db.password"));
        
        // Basic connection pool settings
        config.setMaximumPoolSize(env.getProperty("hikari.maximumPoolSize", Integer.class, 15));
        config.setMinimumIdle(env.getProperty("hikari.minimumIdle", Integer.class, 5));
        config.setConnectionTimeout(env.getProperty("hikari.connectionTimeout", Long.class, 30000L));
        config.setIdleTimeout(env.getProperty("hikari.idleTimeout", Long.class, 600000L));
        config.setMaxLifetime(env.getProperty("hikari.maxLifetime", Long.class, 1800000L));
        config.setConnectionTestQuery(env.getProperty("hikari.connectionTestQuery", "SELECT 1 FROM DUAL"));
        
        // Advanced pool settings
        config.setPoolName(env.getProperty("hikari.poolName", "RGD-CurationPool"));
        config.setAutoCommit(env.getProperty("hikari.autoCommit", Boolean.class, false));
        config.setIsolateInternalQueries(env.getProperty("hikari.isolateInternalQueries", Boolean.class, false));
        config.setAllowPoolSuspension(env.getProperty("hikari.allowPoolSuspension", Boolean.class, false));
        config.setReadOnly(env.getProperty("hikari.readOnly", Boolean.class, false));
        config.setRegisterMbeans(env.getProperty("hikari.registerMbeans", Boolean.class, true));
        config.setValidationTimeout(env.getProperty("hikari.validationTimeout", Long.class, 5000L));
        config.setLeakDetectionThreshold(env.getProperty("hikari.leakDetectionThreshold", Long.class, 60000L));
        config.setInitializationFailTimeout(env.getProperty("hikari.initializationFailTimeout", Long.class, 1L));
        
        // Database-specific optimizations for Oracle
        config.addDataSourceProperty("oracle.jdbc.ReadTimeout", "30000");
        config.addDataSourceProperty("oracle.net.CONNECT_TIMEOUT", "30000");
        config.addDataSourceProperty("oracle.jdbc.implicitStatementCacheSize", "25");
        config.addDataSourceProperty("oracle.jdbc.defaultNChar", "false");
        
        // Enable statement caching
        config.addDataSourceProperty("cachePrepStmts", "true");
        config.addDataSourceProperty("prepStmtCacheSize", "250");
        config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
        config.addDataSourceProperty("useServerPrepStmts", "true");
        
        return new HikariDataSource(config);
    }

    /**
     * Transaction manager for database operations.
     */
    @Bean
    public PlatformTransactionManager transactionManager(@Qualifier("dataSource") DataSource dataSource) {
        DataSourceTransactionManager transactionManager = new DataSourceTransactionManager();
        transactionManager.setDataSource(dataSource);
        transactionManager.setDefaultTimeout(env.getProperty("transaction.timeout", Integer.class, 300));
        return transactionManager;
    }

    /**
     * JdbcTemplate for database operations.
     */
    @Bean
    public JdbcTemplate jdbcTemplate(@Qualifier("dataSource") DataSource dataSource) {
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
        jdbcTemplate.setQueryTimeout(env.getProperty("query.timeout", Integer.class, 120));
        jdbcTemplate.setFetchSize(env.getProperty("query.fetchSize", Integer.class, 100));
        return jdbcTemplate;
    }
}