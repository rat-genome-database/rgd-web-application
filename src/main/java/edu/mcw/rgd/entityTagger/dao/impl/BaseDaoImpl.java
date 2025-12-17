package edu.mcw.rgd.entityTagger.dao.impl;

import edu.mcw.rgd.entityTagger.dao.BaseDao;
import edu.mcw.rgd.entityTagger.service.TransactionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.BeanPropertySqlParameterSource;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import javax.sql.DataSource;
import java.io.Serializable;
import java.lang.reflect.ParameterizedType;
import java.util.List;
import java.util.Optional;

/**
 * Abstract base implementation of BaseDao that provides common CRUD operations using JDBC.
 * Entity-specific DAOs should extend this class and implement the abstract methods.
 * 
 * @param <T> The entity type
 * @param <ID> The primary key type
 */
public abstract class BaseDaoImpl<T, ID extends Serializable> implements BaseDao<T, ID> {

    protected static final Logger logger = LoggerFactory.getLogger(BaseDaoImpl.class);

    protected final JdbcTemplate jdbcTemplate;
    protected final NamedParameterJdbcTemplate namedParameterJdbcTemplate;
    protected final Class<T> entityClass;

    @Autowired(required = false)
    protected TransactionService transactionService;

    @SuppressWarnings("unchecked")
    public BaseDaoImpl(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
        this.namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(dataSource);
        
        // Get the actual entity class from generic parameters
        this.entityClass = (Class<T>) ((ParameterizedType) getClass()
                .getGenericSuperclass()).getActualTypeArguments()[0];
    }

    // Abstract methods that must be implemented by subclasses

    /**
     * Get the table name for this entity.
     * 
     * @return The database table name
     */
    protected abstract String getTableName();

    /**
     * Get the primary key column name.
     * 
     * @return The primary key column name
     */
    protected abstract String getIdColumnName();

    /**
     * Get the SQL for inserting a new entity.
     * 
     * @return The INSERT SQL statement
     */
    protected abstract String getInsertSql();

    /**
     * Get the SQL for updating an entity.
     * 
     * @return The UPDATE SQL statement
     */
    protected abstract String getUpdateSql();

    /**
     * Get the SQL for selecting an entity by ID.
     * 
     * @return The SELECT SQL statement
     */
    protected abstract String getSelectByIdSql();

    /**
     * Get the SQL for selecting all entities.
     * 
     * @return The SELECT ALL SQL statement
     */
    protected abstract String getSelectAllSql();

    /**
     * Get the row mapper for converting database rows to entities.
     * 
     * @return The RowMapper implementation
     */
    protected abstract RowMapper<T> getRowMapper();

    /**
     * Create SQL parameter source for the given entity.
     * 
     * @param entity The entity to create parameters for
     * @return SqlParameterSource containing entity data
     */
    protected SqlParameterSource createParameterSource(T entity) {
        return new BeanPropertySqlParameterSource(entity);
    }

    /**
     * Extract the ID from an entity.
     * 
     * @param entity The entity to extract ID from
     * @return The entity ID
     */
    protected abstract ID extractId(T entity);

    /**
     * Set the ID on an entity.
     * 
     * @param entity The entity to set ID on
     * @param id The ID to set
     */
    protected abstract void setId(T entity, ID id);

    // Base DAO implementation methods

    @Override
    @Transactional
    public T save(T entity) {
        logTransactionState("save", extractId(entity));
        
        KeyHolder keyHolder = new GeneratedKeyHolder();
        SqlParameterSource parameterSource = createParameterSource(entity);
        
        namedParameterJdbcTemplate.update(getInsertSql(), parameterSource, keyHolder);
        
        // Set the generated ID if applicable
        if (keyHolder.getKey() != null) {
            @SuppressWarnings("unchecked")
            ID generatedId = (ID) keyHolder.getKey();
            setId(entity, generatedId);
        }
        
        return entity;
    }

    @Override
    @Transactional
    public T update(T entity) {
        logTransactionState("update", extractId(entity));
        
        SqlParameterSource parameterSource = createParameterSource(entity);
        int rowsAffected = namedParameterJdbcTemplate.update(getUpdateSql(), parameterSource);
        
        if (rowsAffected == 0) {
            throw new EmptyResultDataAccessException("No entity found to update with ID: " + extractId(entity), 1);
        }
        
        return entity;
    }

    @Override
    @Transactional
    public T saveOrUpdate(T entity) {
        logTransactionState("saveOrUpdate", extractId(entity));
        
        ID id = extractId(entity);
        if (id != null && existsById(id)) {
            return update(entity);
        } else {
            return save(entity);
        }
    }

    @Override
    @Transactional
    public void delete(T entity) {
        deleteById(extractId(entity));
    }

    @Override
    @Transactional
    public void deleteById(ID id) {
        logTransactionState("deleteById", id);
        
        String sql = "DELETE FROM " + getTableName() + " WHERE " + getIdColumnName() + " = ?";
        int rowsAffected = jdbcTemplate.update(sql, id);
        
        if (rowsAffected == 0) {
            throw new EmptyResultDataAccessException("No entity found to delete with ID: " + id, 1);
        }
    }

    @Override
    @Transactional(readOnly = true, isolation = Isolation.READ_COMMITTED)
    public Optional<T> findById(ID id) {
        try {
            MapSqlParameterSource parameterSource = new MapSqlParameterSource();
            parameterSource.addValue("id", id);
            
            T entity = namedParameterJdbcTemplate.queryForObject(
                getSelectByIdSql(), parameterSource, getRowMapper());
            return Optional.of(entity);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    @Override
    @Transactional(readOnly = true, isolation = Isolation.READ_COMMITTED)
    public boolean existsById(ID id) {
        String sql = "SELECT COUNT(*) FROM " + getTableName() + " WHERE " + getIdColumnName() + " = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, id);
        return count != null && count > 0;
    }

    @Override
    @Transactional(readOnly = true, isolation = Isolation.READ_COMMITTED)
    public List<T> findAll() {
        return jdbcTemplate.query(getSelectAllSql(), getRowMapper());
    }

    @Override
    @Transactional(readOnly = true, isolation = Isolation.READ_COMMITTED)
    public List<T> findAll(int offset, int limit) {
        String sql = getSelectAllSql() + " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        return jdbcTemplate.query(sql, getRowMapper(), offset, limit);
    }

    @Override
    @Transactional(readOnly = true, isolation = Isolation.READ_COMMITTED)
    public long count() {
        String sql = "SELECT COUNT(*) FROM " + getTableName();
        Long count = jdbcTemplate.queryForObject(sql, Long.class);
        return count != null ? count : 0L;
    }

    @Override
    @Transactional
    public void batchInsert(List<T> entities) {
        if (entities.isEmpty()) {
            return;
        }
        
        logTransactionState("batchInsert", entities.size() + " entities");
        
        // Use transaction service for large batches
        if (transactionService != null && entities.size() > 100) {
            int batchSize = 50;
            transactionService.executeBatchInTransaction(
                (startIndex, currentBatchSize, previousResult) -> {
                    List<T> batch = entities.subList(startIndex, Math.min(startIndex + currentBatchSize, entities.size()));
                    SqlParameterSource[] parameterSources = batch.stream()
                            .map(this::createParameterSource)
                            .toArray(SqlParameterSource[]::new);
                    
                    namedParameterJdbcTemplate.batchUpdate(getInsertSql(), parameterSources);
                    return null;
                }, batchSize, entities.size()
            );
        } else {
            SqlParameterSource[] parameterSources = entities.stream()
                    .map(this::createParameterSource)
                    .toArray(SqlParameterSource[]::new);
            
            namedParameterJdbcTemplate.batchUpdate(getInsertSql(), parameterSources);
        }
    }

    @Override
    @Transactional
    public void batchUpdate(List<T> entities) {
        if (entities.isEmpty()) {
            return;
        }
        
        logTransactionState("batchUpdate", entities.size() + " entities");
        
        // Use transaction service for large batches
        if (transactionService != null && entities.size() > 100) {
            int batchSize = 50;
            transactionService.executeBatchInTransaction(
                (startIndex, currentBatchSize, previousResult) -> {
                    List<T> batch = entities.subList(startIndex, Math.min(startIndex + currentBatchSize, entities.size()));
                    SqlParameterSource[] parameterSources = batch.stream()
                            .map(this::createParameterSource)
                            .toArray(SqlParameterSource[]::new);
                    
                    namedParameterJdbcTemplate.batchUpdate(getUpdateSql(), parameterSources);
                    return null;
                }, batchSize, entities.size()
            );
        } else {
            SqlParameterSource[] parameterSources = entities.stream()
                    .map(this::createParameterSource)
                    .toArray(SqlParameterSource[]::new);
            
            namedParameterJdbcTemplate.batchUpdate(getUpdateSql(), parameterSources);
        }
    }

    @Override
    @Transactional
    public void batchDelete(List<T> entities) {
        if (entities.isEmpty()) {
            return;
        }
        
        logTransactionState("batchDelete", entities.size() + " entities");
        
        List<ID> ids = entities.stream()
                .map(this::extractId)
                .toList();
        
        String sql = "DELETE FROM " + getTableName() + " WHERE " + getIdColumnName() + " = ?";
        jdbcTemplate.batchUpdate(sql, ids, ids.size(), (ps, id) -> ps.setObject(1, id));
    }

    // Utility methods for subclasses

    /**
     * Execute a custom query and return the results.
     * 
     * @param sql The SQL query to execute
     * @param parameters Query parameters
     * @return List of entities matching the query
     */
    protected List<T> queryForList(String sql, Object... parameters) {
        return jdbcTemplate.query(sql, getRowMapper(), parameters);
    }

    /**
     * Execute a custom query with named parameters and return the results.
     * 
     * @param sql The SQL query to execute
     * @param parameterSource Named parameters
     * @return List of entities matching the query
     */
    protected List<T> queryForList(String sql, SqlParameterSource parameterSource) {
        return namedParameterJdbcTemplate.query(sql, parameterSource, getRowMapper());
    }

    /**
     * Execute a custom query and return a single result.
     * 
     * @param sql The SQL query to execute
     * @param parameters Query parameters
     * @return Optional containing the entity if found, empty otherwise
     */
    protected Optional<T> queryForObject(String sql, Object... parameters) {
        try {
            T entity = jdbcTemplate.queryForObject(sql, getRowMapper(), parameters);
            return Optional.of(entity);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    /**
     * Execute a custom query with named parameters and return a single result.
     * 
     * @param sql The SQL query to execute
     * @param parameterSource Named parameters
     * @return Optional containing the entity if found, empty otherwise
     */
    protected Optional<T> queryForObject(String sql, SqlParameterSource parameterSource) {
        try {
            T entity = namedParameterJdbcTemplate.queryForObject(sql, parameterSource, getRowMapper());
            return Optional.of(entity);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    // Transaction management utility methods

    /**
     * Log current transaction state for debugging purposes.
     * 
     * @param operation The operation being performed
     * @param identifier Additional identifier (entity ID, count, etc.)
     */
    protected void logTransactionState(String operation, Object identifier) {
        if (logger.isDebugEnabled() && transactionService != null) {
            TransactionService.TransactionInfo txInfo = transactionService.getCurrentTransactionInfo();
            logger.debug("DAO operation '{}' on {} {} - Transaction: {}", 
                       operation, getTableName(), identifier, 
                       txInfo != null ? txInfo.toString() : "NONE");
        }
    }

    /**
     * Execute a DAO operation within a transaction using TransactionService.
     * Useful for complex operations that need specific transaction characteristics.
     * 
     * @param operation The operation to execute
     * @param isolationLevel The transaction isolation level
     * @param <R> The return type
     * @return The result of the operation
     */
    protected <R> R executeInTransaction(java.util.function.Supplier<R> operation, Isolation isolationLevel) {
        if (transactionService != null) {
            return transactionService.executeInTransaction(operation, isolationLevel);
        } else {
            return operation.get();
        }
    }

    /**
     * Execute a DAO operation within a read-only transaction.
     * 
     * @param operation The operation to execute
     * @param <R> The return type
     * @return The result of the operation
     */
    protected <R> R executeInReadOnlyTransaction(java.util.function.Supplier<R> operation) {
        if (transactionService != null) {
            return transactionService.executeInReadOnlyTransaction(operation);
        } else {
            return operation.get();
        }
    }

    /**
     * Check if currently executing within a transaction.
     * 
     * @return true if in a transaction, false otherwise
     */
    protected boolean isInTransaction() {
        if (transactionService != null) {
            TransactionService.TransactionInfo txInfo = transactionService.getCurrentTransactionInfo();
            return txInfo != null;
        }
        return false;
    }

    /**
     * Execute a batch operation with optimal transaction handling.
     * 
     * @param entities The entities to process
     * @param batchSize The batch size
     * @param processor The batch processor function
     * @param <R> The return type
     * @return The result of the batch operation
     */
    protected <R> R executeBatchOperation(List<T> entities, int batchSize, 
                                        java.util.function.Function<List<T>, R> processor) {
        if (transactionService != null && entities.size() > batchSize) {
            return transactionService.executeBatchInTransaction(
                (startIndex, currentBatchSize, previousResult) -> {
                    List<T> batch = entities.subList(startIndex, Math.min(startIndex + currentBatchSize, entities.size()));
                    return processor.apply(batch);
                }, batchSize, entities.size()
            );
        } else {
            return processor.apply(entities);
        }
    }
}