package edu.mcw.rgd.entityTagger.migration;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Database migration runner for the RGD Curation Tool.
 * Executes SQL migration scripts in order and tracks migration history.
 * 
 * This runner can be used during application startup or manually triggered
 * to apply database schema changes and updates.
 */
@Component
public class DatabaseMigrationRunner implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseMigrationRunner.class);

    @Autowired
    @Qualifier("dataSource")
    private DataSource dataSource;

    private JdbcTemplate jdbcTemplate;

    private static final String MIGRATION_TABLE = "CURATION_MIGRATIONS";
    private static final String MIGRATION_PATH = "db/migration/";

    // List of migration scripts in execution order
    private static final String[] MIGRATION_SCRIPTS = {
        "001_create_curation_tables.sql",
        "002_add_performance_indexes.sql",
        "003_add_validation_and_sample_data.sql"
    };

    @Override
    public void run(String... args) throws Exception {
        // Only run migrations if explicitly requested
        if (args.length > 0 && "migrate".equals(args[0])) {
            logger.info("Running database migrations...");
            runMigrations();
        }
    }

    /**
     * Run all pending database migrations.
     */
    public void runMigrations() {
        try {
            initializeJdbcTemplate();
            ensureMigrationTableExists();
            
            List<String> appliedMigrations = getAppliedMigrations();
            
            for (String script : MIGRATION_SCRIPTS) {
                if (!appliedMigrations.contains(script)) {
                    logger.info("Applying migration: {}", script);
                    applyMigration(script);
                } else {
                    logger.debug("Migration already applied: {}", script);
                }
            }
            
            logger.info("Database migrations completed successfully");
            
        } catch (Exception e) {
            logger.error("Database migration failed", e);
            throw new RuntimeException("Database migration failed", e);
        }
    }

    /**
     * Apply a specific migration script.
     * 
     * @param scriptName The name of the migration script
     */
    public void applyMigration(String scriptName) {
        try {
            String migrationSql = loadMigrationScript(scriptName);
            
            // Split the script into individual statements
            List<String> statements = splitSqlStatements(migrationSql);
            
            // Execute each statement
            for (String statement : statements) {
                if (statement.trim().isEmpty()) {
                    continue;
                }
                
                try {
                    logger.debug("Executing statement: {}", statement.substring(0, Math.min(100, statement.length())) + "...");
                    jdbcTemplate.execute(statement);
                } catch (Exception e) {
                    logger.error("Failed to execute statement: {}", statement.substring(0, Math.min(200, statement.length())));
                    throw e;
                }
            }
            
            // Record the migration as applied
            recordMigrationApplied(scriptName);
            
            logger.info("Successfully applied migration: {}", scriptName);
            
        } catch (Exception e) {
            logger.error("Failed to apply migration: {}", scriptName, e);
            throw new RuntimeException("Migration failed: " + scriptName, e);
        }
    }

    /**
     * Check if a specific migration has been applied.
     * 
     * @param scriptName The name of the migration script
     * @return true if the migration has been applied, false otherwise
     */
    public boolean isMigrationApplied(String scriptName) {
        try {
            initializeJdbcTemplate();
            ensureMigrationTableExists();
            
            Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM " + MIGRATION_TABLE + " WHERE SCRIPT_NAME = ?",
                Integer.class, scriptName);
            
            return count != null && count > 0;
            
        } catch (Exception e) {
            logger.error("Error checking migration status for: {}", scriptName, e);
            return false;
        }
    }

    /**
     * Get migration history with status information.
     * 
     * @return List of migration information
     */
    public List<MigrationInfo> getMigrationHistory() {
        try {
            initializeJdbcTemplate();
            ensureMigrationTableExists();
            
            List<MigrationInfo> history = new ArrayList<>();
            
            for (String script : MIGRATION_SCRIPTS) {
                MigrationInfo info = new MigrationInfo();
                info.setScriptName(script);
                info.setApplied(isMigrationApplied(script));
                
                if (info.isApplied()) {
                    try {
                        String sql = "SELECT APPLIED_DATE FROM " + MIGRATION_TABLE + " WHERE SCRIPT_NAME = ?";
                        info.setAppliedDate(jdbcTemplate.queryForObject(sql, LocalDateTime.class, script));
                    } catch (Exception e) {
                        logger.debug("Could not retrieve applied date for migration: {}", script);
                    }
                }
                
                history.add(info);
            }
            
            return history;
            
        } catch (Exception e) {
            logger.error("Error retrieving migration history", e);
            return new ArrayList<>();
        }
    }

    // Private helper methods

    private void initializeJdbcTemplate() {
        if (jdbcTemplate == null) {
            jdbcTemplate = new JdbcTemplate(dataSource);
        }
    }

    private void ensureMigrationTableExists() {
        try {
            // Check if migration table exists
            jdbcTemplate.queryForObject("SELECT COUNT(*) FROM " + MIGRATION_TABLE, Integer.class);
        } catch (Exception e) {
            // Table doesn't exist, create it
            logger.info("Creating migration tracking table: {}", MIGRATION_TABLE);
            
            String createTableSql = """
                CREATE TABLE %s (
                    ID NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
                    SCRIPT_NAME VARCHAR2(255) NOT NULL UNIQUE,
                    APPLIED_DATE TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                    CHECKSUM VARCHAR2(64),
                    EXECUTION_TIME_MS NUMBER,
                    SUCCESS CHAR(1) DEFAULT 'Y' CHECK (SUCCESS IN ('Y', 'N'))
                )
                """.formatted(MIGRATION_TABLE);
            
            jdbcTemplate.execute(createTableSql);
            
            // Create index
            jdbcTemplate.execute("CREATE INDEX IDX_" + MIGRATION_TABLE + "_SCRIPT ON " + MIGRATION_TABLE + " (SCRIPT_NAME)");
            
            logger.info("Migration tracking table created successfully");
        }
    }

    private List<String> getAppliedMigrations() {
        String sql = "SELECT SCRIPT_NAME FROM " + MIGRATION_TABLE + " WHERE SUCCESS = 'Y' ORDER BY APPLIED_DATE";
        return jdbcTemplate.queryForList(sql, String.class);
    }

    private String loadMigrationScript(String scriptName) throws IOException {
        Resource resource = new ClassPathResource(MIGRATION_PATH + scriptName);
        
        if (!resource.exists()) {
            throw new IOException("Migration script not found: " + scriptName);
        }
        
        StringBuilder content = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(resource.getInputStream(), StandardCharsets.UTF_8))) {
            
            String line;
            while ((line = reader.readLine()) != null) {
                content.append(line).append("\n");
            }
        }
        
        return content.toString();
    }

    private List<String> splitSqlStatements(String sql) {
        List<String> statements = new ArrayList<>();
        StringBuilder currentStatement = new StringBuilder();
        boolean inBlockComment = false;
        boolean inLineComment = false;
        boolean inQuotes = false;
        boolean inPlSqlBlock = false;
        
        String[] lines = sql.split("\n");
        
        for (String line : lines) {
            String trimmedLine = line.trim();
            
            // Skip empty lines
            if (trimmedLine.isEmpty()) {
                continue;
            }
            
            // Handle comments
            if (trimmedLine.startsWith("--") && !inQuotes) {
                continue; // Skip line comments
            }
            
            if (trimmedLine.startsWith("/*") && !inQuotes) {
                inBlockComment = true;
                continue;
            }
            
            if (trimmedLine.endsWith("*/") && inBlockComment) {
                inBlockComment = false;
                continue;
            }
            
            if (inBlockComment) {
                continue;
            }
            
            // Detect PL/SQL blocks
            if (trimmedLine.toUpperCase().matches("^(CREATE|DECLARE|BEGIN)\\s+.*") && !inQuotes) {
                inPlSqlBlock = true;
            }
            
            currentStatement.append(line).append("\n");
            
            // Check for statement terminators
            if (inPlSqlBlock && trimmedLine.equals("/")) {
                // End of PL/SQL block
                statements.add(currentStatement.toString().trim());
                currentStatement = new StringBuilder();
                inPlSqlBlock = false;
            } else if (!inPlSqlBlock && trimmedLine.endsWith(";") && !inQuotes) {
                // Regular SQL statement
                statements.add(currentStatement.toString().trim());
                currentStatement = new StringBuilder();
            }
        }
        
        // Add any remaining statement
        if (currentStatement.length() > 0) {
            statements.add(currentStatement.toString().trim());
        }
        
        return statements;
    }

    private void recordMigrationApplied(String scriptName) {
        String sql = """
            INSERT INTO %s (SCRIPT_NAME, APPLIED_DATE, SUCCESS) 
            VALUES (?, CURRENT_TIMESTAMP, 'Y')
            """.formatted(MIGRATION_TABLE);
        
        jdbcTemplate.update(sql, scriptName);
    }

    /**
     * Information about a migration script.
     */
    public static class MigrationInfo {
        private String scriptName;
        private boolean applied;
        private LocalDateTime appliedDate;
        private String status;

        // Getters and setters
        public String getScriptName() { return scriptName; }
        public void setScriptName(String scriptName) { this.scriptName = scriptName; }

        public boolean isApplied() { return applied; }
        public void setApplied(boolean applied) { this.applied = applied; }

        public LocalDateTime getAppliedDate() { return appliedDate; }
        public void setAppliedDate(LocalDateTime appliedDate) { this.appliedDate = appliedDate; }

        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }

        @Override
        public String toString() {
            return String.format("Migration{script=%s, applied=%s, date=%s}", 
                               scriptName, applied, appliedDate);
        }
    }
}