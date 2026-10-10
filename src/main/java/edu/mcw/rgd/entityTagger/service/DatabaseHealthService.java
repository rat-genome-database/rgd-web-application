package edu.mcw.rgd.entityTagger.service;

import com.zaxxer.hikari.HikariDataSource;
import com.zaxxer.hikari.HikariPoolMXBean;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import javax.management.MBeanServer;
import javax.management.ObjectName;
import javax.sql.DataSource;
import java.lang.management.ManagementFactory;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * Service for monitoring database health and connection pool metrics.
 * Provides functionality to check database connectivity, monitor pool usage,
 * and alert on potential issues.
 */
@Service
public class DatabaseHealthService {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseHealthService.class);

    @Autowired
    @Qualifier("dataSource")
    private DataSource dataSource;

    @Value("${db.healthcheck.enabled:true}")
    private boolean healthCheckEnabled;

    @Value("${db.healthcheck.validationQuery:SELECT 1 FROM DUAL}")
    private String validationQuery;

    @Value("${db.healthcheck.timeout:5000}")
    private int healthCheckTimeout;

    @Value("${hikari.poolName:RGD-CurationPool}")
    private String poolName;

    private LocalDateTime lastHealthCheck;
    private boolean lastHealthStatus = true;
    private String lastErrorMessage;

    /**
     * Check if the database connection is healthy.
     * 
     * @return true if database is accessible, false otherwise
     */
    public boolean isDatabaseHealthy() {
        if (!healthCheckEnabled) {
            return true;
        }

        try (Connection connection = dataSource.getConnection();
             PreparedStatement statement = connection.prepareStatement(validationQuery)) {
            
            statement.setQueryTimeout(healthCheckTimeout / 1000);
            
            try (ResultSet resultSet = statement.executeQuery()) {
                boolean isHealthy = resultSet.next();
                updateHealthStatus(isHealthy, null);
                return isHealthy;
            }
            
        } catch (SQLException e) {
            String errorMessage = "Database health check failed: " + e.getMessage();
            logger.error(errorMessage, e);
            updateHealthStatus(false, errorMessage);
            return false;
        }
    }

    /**
     * Get detailed connection pool metrics.
     * 
     * @return Map containing pool metrics
     */
    public Map<String, Object> getConnectionPoolMetrics() {
        Map<String, Object> metrics = new HashMap<>();
        
        try {
            if (dataSource instanceof HikariDataSource) {
                HikariDataSource hikariDataSource = (HikariDataSource) dataSource;
                HikariPoolMXBean poolMXBean = hikariDataSource.getHikariPoolMXBean();
                
                if (poolMXBean != null) {
                    metrics.put("activeConnections", poolMXBean.getActiveConnections());
                    metrics.put("idleConnections", poolMXBean.getIdleConnections());
                    metrics.put("totalConnections", poolMXBean.getTotalConnections());
                    metrics.put("threadsAwaitingConnection", poolMXBean.getThreadsAwaitingConnection());
                    metrics.put("poolName", poolName);
                    metrics.put("maximumPoolSize", hikariDataSource.getMaximumPoolSize());
                    metrics.put("minimumIdle", hikariDataSource.getMinimumIdle());
                }
            }
            
            // Add database health status
            metrics.put("databaseHealthy", lastHealthStatus);
            metrics.put("lastHealthCheck", lastHealthCheck);
            if (lastErrorMessage != null) {
                metrics.put("lastError", lastErrorMessage);
            }
            
        } catch (Exception e) {
            logger.error("Failed to retrieve connection pool metrics", e);
            metrics.put("error", "Failed to retrieve metrics: " + e.getMessage());
        }
        
        return metrics;
    }

    /**
     * Get connection pool health summary.
     * 
     * @return Health summary with status and metrics
     */
    public Map<String, Object> getHealthSummary() {
        Map<String, Object> summary = new HashMap<>();
        Map<String, Object> poolMetrics = getConnectionPoolMetrics();
        
        // Overall health status
        boolean isHealthy = isDatabaseHealthy();
        summary.put("status", isHealthy ? "UP" : "DOWN");
        summary.put("timestamp", LocalDateTime.now());
        
        // Pool health assessment
        if (poolMetrics.containsKey("activeConnections") && poolMetrics.containsKey("totalConnections")) {
            int activeConnections = (Integer) poolMetrics.get("activeConnections");
            int totalConnections = (Integer) poolMetrics.get("totalConnections");
            int threadsAwaiting = (Integer) poolMetrics.getOrDefault("threadsAwaitingConnection", 0);
            
            double utilizationRate = totalConnections > 0 ? (double) activeConnections / totalConnections : 0;
            summary.put("poolUtilization", String.format("%.2f%%", utilizationRate * 100));
            summary.put("poolStatus", determinePoolStatus(utilizationRate, threadsAwaiting));
        }
        
        summary.put("poolMetrics", poolMetrics);
        return summary;
    }

    /**
     * Periodic health check that runs every 30 seconds.
     */
    @Scheduled(fixedDelayString = "${db.healthcheck.interval:30000}")
    public void performScheduledHealthCheck() {
        if (!healthCheckEnabled) {
            return;
        }

        try {
            boolean isHealthy = isDatabaseHealthy();
            Map<String, Object> poolMetrics = getConnectionPoolMetrics();
            
            // Log health status periodically
            if (logger.isDebugEnabled()) {
                logger.debug("Database health check completed. Status: {}, Pool metrics: {}", 
                           isHealthy ? "HEALTHY" : "UNHEALTHY", poolMetrics);
            }
            
            // Alert on concerning metrics
            checkForConcerns(poolMetrics);
            
        } catch (Exception e) {
            logger.error("Scheduled health check failed", e);
        }
    }

    /**
     * Suspend the connection pool if supported.
     * 
     * @return true if suspension was successful, false otherwise
     */
    public boolean suspendPool() {
        try {
            if (dataSource instanceof HikariDataSource) {
                HikariDataSource hikariDataSource = (HikariDataSource) dataSource;
                HikariPoolMXBean poolMXBean = hikariDataSource.getHikariPoolMXBean();
                
                if (poolMXBean != null) {
                    poolMXBean.suspendPool();
                    logger.info("Connection pool suspended");
                    return true;
                }
            }
        } catch (Exception e) {
            logger.error("Failed to suspend connection pool", e);
        }
        return false;
    }

    /**
     * Resume the connection pool if supported.
     * 
     * @return true if resume was successful, false otherwise
     */
    public boolean resumePool() {
        try {
            if (dataSource instanceof HikariDataSource) {
                HikariDataSource hikariDataSource = (HikariDataSource) dataSource;
                HikariPoolMXBean poolMXBean = hikariDataSource.getHikariPoolMXBean();
                
                if (poolMXBean != null) {
                    poolMXBean.resumePool();
                    logger.info("Connection pool resumed");
                    return true;
                }
            }
        } catch (Exception e) {
            logger.error("Failed to resume connection pool", e);
        }
        return false;
    }

    /**
     * Soft evict a connection from the pool.
     * 
     * @return true if eviction was successful, false otherwise
     */
    public boolean evictConnection() {
        try {
            if (dataSource instanceof HikariDataSource) {
                HikariDataSource hikariDataSource = (HikariDataSource) dataSource;
                HikariPoolMXBean poolMXBean = hikariDataSource.getHikariPoolMXBean();
                
                if (poolMXBean != null) {
                    poolMXBean.softEvictConnections();
                    logger.info("Connection eviction requested");
                    return true;
                }
            }
        } catch (Exception e) {
            logger.error("Failed to evict connections", e);
        }
        return false;
    }

    // Private helper methods

    private void updateHealthStatus(boolean isHealthy, String errorMessage) {
        this.lastHealthStatus = isHealthy;
        this.lastHealthCheck = LocalDateTime.now();
        this.lastErrorMessage = errorMessage;
    }

    private String determinePoolStatus(double utilizationRate, int threadsAwaiting) {
        if (threadsAwaiting > 0) {
            return "UNDER_PRESSURE";
        } else if (utilizationRate > 0.9) {
            return "HIGH_UTILIZATION";
        } else if (utilizationRate > 0.7) {
            return "MODERATE_UTILIZATION";
        } else {
            return "HEALTHY";
        }
    }

    private void checkForConcerns(Map<String, Object> poolMetrics) {
        try {
            Integer threadsAwaiting = (Integer) poolMetrics.get("threadsAwaitingConnection");
            Integer activeConnections = (Integer) poolMetrics.get("activeConnections");
            Integer totalConnections = (Integer) poolMetrics.get("totalConnections");
            
            if (threadsAwaiting != null && threadsAwaiting > 0) {
                logger.warn("Connection pool under pressure: {} threads waiting for connections", threadsAwaiting);
            }
            
            if (activeConnections != null && totalConnections != null && totalConnections > 0) {
                double utilizationRate = (double) activeConnections / totalConnections;
                if (utilizationRate > 0.9) {
                    logger.warn("High connection pool utilization: {:.1f}% ({}/{})", 
                              utilizationRate * 100, activeConnections, totalConnections);
                }
            }
            
        } catch (Exception e) {
            logger.debug("Failed to check pool concerns", e);
        }
    }

    // Getters for health status (for use by other services)

    public LocalDateTime getLastHealthCheck() {
        return lastHealthCheck;
    }

    public boolean getLastHealthStatus() {
        return lastHealthStatus;
    }

    public String getLastErrorMessage() {
        return lastErrorMessage;
    }
}