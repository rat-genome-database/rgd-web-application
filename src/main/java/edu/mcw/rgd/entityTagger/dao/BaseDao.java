package edu.mcw.rgd.entityTagger.dao;

import java.io.Serializable;
import java.util.List;
import java.util.Optional;

/**
 * Base Data Access Object interface that provides common CRUD operations.
 * All entity-specific DAOs should extend this interface.
 * 
 * @param <T> The entity type
 * @param <ID> The primary key type
 */
public interface BaseDao<T, ID extends Serializable> {

    /**
     * Save a new entity to the database.
     * 
     * @param entity The entity to save
     * @return The saved entity with generated ID
     * @throws org.springframework.dao.DataAccessException if save fails
     */
    T save(T entity);

    /**
     * Update an existing entity in the database.
     * 
     * @param entity The entity to update
     * @return The updated entity
     * @throws org.springframework.dao.DataAccessException if update fails
     */
    T update(T entity);

    /**
     * Save or update an entity (upsert operation).
     * If the entity has an ID and exists in the database, it will be updated.
     * Otherwise, it will be saved as a new entity.
     * 
     * @param entity The entity to save or update
     * @return The saved/updated entity
     * @throws org.springframework.dao.DataAccessException if operation fails
     */
    T saveOrUpdate(T entity);

    /**
     * Delete an entity from the database.
     * 
     * @param entity The entity to delete
     * @throws org.springframework.dao.DataAccessException if delete fails
     */
    void delete(T entity);

    /**
     * Delete an entity by its ID.
     * 
     * @param id The ID of the entity to delete
     * @throws org.springframework.dao.DataAccessException if delete fails
     */
    void deleteById(ID id);

    /**
     * Find an entity by its ID.
     * 
     * @param id The ID to search for
     * @return Optional containing the entity if found, empty otherwise
     * @throws org.springframework.dao.DataAccessException if query fails
     */
    Optional<T> findById(ID id);

    /**
     * Check if an entity exists by its ID.
     * 
     * @param id The ID to check
     * @return true if entity exists, false otherwise
     * @throws org.springframework.dao.DataAccessException if query fails
     */
    boolean existsById(ID id);

    /**
     * Find all entities.
     * 
     * @return List of all entities
     * @throws org.springframework.dao.DataAccessException if query fails
     */
    List<T> findAll();

    /**
     * Find entities with pagination support.
     * 
     * @param offset The number of records to skip
     * @param limit The maximum number of records to return
     * @return List of entities within the specified range
     * @throws org.springframework.dao.DataAccessException if query fails
     */
    List<T> findAll(int offset, int limit);

    /**
     * Count the total number of entities.
     * 
     * @return The total count of entities
     * @throws org.springframework.dao.DataAccessException if query fails
     */
    long count();

    /**
     * Execute a batch insert operation for multiple entities.
     * 
     * @param entities The list of entities to insert
     * @throws org.springframework.dao.DataAccessException if batch insert fails
     */
    void batchInsert(List<T> entities);

    /**
     * Execute a batch update operation for multiple entities.
     * 
     * @param entities The list of entities to update
     * @throws org.springframework.dao.DataAccessException if batch update fails
     */
    void batchUpdate(List<T> entities);

    /**
     * Execute a batch delete operation for multiple entities.
     * 
     * @param entities The list of entities to delete
     * @throws org.springframework.dao.DataAccessException if batch delete fails
     */
    void batchDelete(List<T> entities);
}