package edu.mcw.rgd.entityTagger.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.EnableAspectJAutoProxy;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.web.multipart.support.StandardServletMultipartResolver;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.ViewResolverRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.view.InternalResourceViewResolver;
import org.springframework.web.servlet.view.JstlView;

import javax.sql.DataSource;

/**
 * Spring configuration for the RGD Curation Tool module.
 * This configuration sets up the necessary beans and components for the curation functionality.
 */
@Configuration
@EnableWebMvc
@EnableTransactionManagement
@EnableAspectJAutoProxy
@EnableScheduling
@ComponentScan(basePackages = {
    "edu.mcw.rgd.entityTagger.controller",
    "edu.mcw.rgd.entityTagger.service",
    "edu.mcw.rgd.entityTagger.dao",
    "edu.mcw.rgd.entityTagger.validator",
    "edu.mcw.rgd.entityTagger.aspect"
})
public class CurationConfig implements WebMvcConfigurer {

    /**
     * Configure view resolver for JSP views
     */
    @Override
    public void configureViewResolvers(ViewResolverRegistry registry) {
        InternalResourceViewResolver resolver = new InternalResourceViewResolver();
        resolver.setViewClass(JstlView.class);
        resolver.setPrefix("/WEB-INF/jsp/curation/");
        resolver.setSuffix(".jsp");
        registry.viewResolver(resolver);
    }

    /**
     * Configure static resource handling
     */
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/js/curation/**")
                .addResourceLocations("/js/curation/");
        registry.addResourceHandler("/css/curation/**")
                .addResourceLocations("/css/curation/");
    }

    /**
     * Configure multipart resolver for file uploads using Jakarta Servlet API
     * Maximum file size: 50MB as per requirements
     */
    @Bean
    public StandardServletMultipartResolver multipartResolver() {
        return new StandardServletMultipartResolver();
    }

    /**
     * Configure HikariCP connection pool for database connections
     * Note: This bean is commented out because the application already has a DataSource
     * configured via JNDI. Uncomment if you need a separate connection pool for curation.
     */
    /*
    @Bean
    public DataSource curationDataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:oracle:thin:@//your-oracle-host:1521/your-service");
        config.setUsername("your-username");
        config.setPassword("your-password");
        config.setDriverClassName("oracle.jdbc.OracleDriver");
        
        // Connection pool settings
        config.setMaximumPoolSize(10);
        config.setMinimumIdle(5);
        config.setConnectionTimeout(30000);
        config.setIdleTimeout(600000);
        config.setMaxLifetime(1800000);
        
        return new HikariDataSource(config);
    }
    */
}