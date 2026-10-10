package edu.mcw.rgd.entityTagger.config;

import edu.mcw.rgd.dao.DataSourceFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.sql.DataSource;

/**
 * Database configuration for the RGD Curation Tool.
 * This configuration uses the RGD Core DataSourceFactory for database connectivity.
 */
@Configuration
@EnableTransactionManagement
public class DatabaseConfig {

    /**
     * Primary DataSource using RGD Core DataSourceFactory.
     * This handles JNDI lookup or Spring configuration automatically.
     */
    @Bean
    @Primary
    public DataSource dataSource() throws Exception {
        return DataSourceFactory.getInstance().getDataSource();
    }

    /**
     * Transaction manager for database operations.
     */
    @Bean
    public PlatformTransactionManager transactionManager(@Qualifier("dataSource") DataSource dataSource) {
        DataSourceTransactionManager transactionManager = new DataSourceTransactionManager();
        transactionManager.setDataSource(dataSource);
        return transactionManager;
    }

    /**
     * JdbcTemplate for database operations.
     */
    @Bean
    public JdbcTemplate jdbcTemplate(@Qualifier("dataSource") DataSource dataSource) {
        return new JdbcTemplate(dataSource);
    }
}