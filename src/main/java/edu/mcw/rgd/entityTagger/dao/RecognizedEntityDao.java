package edu.mcw.rgd.entityTagger.dao;

import edu.mcw.rgd.entityTagger.model.RecognizedEntity;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object interface for RecognizedEntity entities.
 * Provides methods for managing recognized entities in the database.
 */
public interface RecognizedEntityDao extends BaseDao<RecognizedEntity, Long> {

    /**
     * Find all entities recognized in a specific session.
     * 
     * @param sessionId The session ID
     * @return List of entities from the session
     */
    List<RecognizedEntity> findBySessionId(Long sessionId);

    /**
     * Find entities by entity type.
     * 
     * @param entityType The entity type (e.g., "gene", "disease", "drug")
     * @return List of entities of the specified type
     */
    List<RecognizedEntity> findByEntityType(String entityType);

    /**
     * Find entities by entity name (case-insensitive).
     * 
     * @param entityName The entity name to search for
     * @return List of entities with matching names
     */
    List<RecognizedEntity> findByEntityName(String entityName);

    /**
     * Find entities by text ID.
     * 
     * @param textId The text ID
     * @return List of entities found in the specified text
     */
    List<RecognizedEntity> findByTextId(String textId);

    /**
     * Find entities with confidence score above a threshold.
     * 
     * @param threshold The minimum confidence score (0.0 to 1.0)
     * @return List of high-confidence entities
     */
    List<RecognizedEntity> findByConfidenceAbove(double threshold);

    /**
     * Find entities that have been validated.
     * 
     * @param isValidated Whether to find validated (true) or unvalidated (false) entities
     * @return List of entities based on validation status
     */
    List<RecognizedEntity> findByValidationStatus(boolean isValidated);

    /**
     * Find entities validated by a specific user.
     * 
     * @param validatedBy The user ID who validated the entities
     * @return List of entities validated by the user
     */
    List<RecognizedEntity> findByValidatedBy(String validatedBy);

    /**
     * Find entities with ontology mappings.
     * 
     * @param hasOntologyMapping Whether to find entities with (true) or without (false) ontology mappings
     * @return List of entities based on ontology mapping presence
     */
    List<RecognizedEntity> findByOntologyMappingStatus(boolean hasOntologyMapping);

    /**
     * Find entities by ontology namespace.
     * 
     * @param namespace The ontology namespace (e.g., "gene_ontology", "disease_ontology")
     * @return List of entities mapped to the specified namespace
     */
    List<RecognizedEntity> findByOntologyNamespace(String namespace);

    /**
     * Find entities recognized within a date range.
     * 
     * @param startDate The start date (inclusive)
     * @param endDate The end date (inclusive)
     * @return List of entities recognized in the date range
     */
    List<RecognizedEntity> findByDateRange(LocalDateTime startDate, LocalDateTime endDate);

    /**
     * Search entities by source text content (case-insensitive).
     * 
     * @param searchTerm The search term to look for in source text
     * @return List of entities whose source text contains the search term
     */
    List<RecognizedEntity> searchBySourceText(String searchTerm);

    /**
     * Find duplicate entities (same name, type, and position within the same text).
     * 
     * @return List of entities that appear to be duplicates
     */
    List<RecognizedEntity> findPotentialDuplicates();

    /**
     * Validate an entity and set validation information.
     * 
     * @param entityId The entity ID to validate
     * @param validatedBy The user ID who validated the entity
     * @param notes Optional validation notes
     * @return true if validation was successful, false otherwise
     */
    boolean validateEntity(Long entityId, String validatedBy, String notes);

    /**
     * Update ontology mapping for an entity.
     * 
     * @param entityId The entity ID
     * @param ontologyTermId The ontology term ID
     * @param ontologyNamespace The ontology namespace
     * @return true if update was successful, false otherwise
     */
    boolean updateOntologyMapping(Long entityId, String ontologyTermId, String ontologyNamespace);

    /**
     * Get entity statistics for a session.
     * 
     * @param sessionId The session ID
     * @return Map containing statistics (total_entities, by_type, avg_confidence, validation_rate)
     */
    Map<String, Object> getEntityStatisticsBySession(Long sessionId);

    /**
     * Get entity statistics by type for a date range.
     * 
     * @param startDate The start date (inclusive)
     * @param endDate The end date (inclusive)
     * @return Map containing statistics grouped by entity type
     */
    Map<String, Object> getEntityStatisticsByType(LocalDateTime startDate, LocalDateTime endDate);

    /**
     * Get validation statistics for entities.
     * 
     * @param startDate The start date (inclusive)
     * @param endDate The end date (inclusive)
     * @return Map containing validation statistics
     */
    Map<String, Object> getValidationStatistics(LocalDateTime startDate, LocalDateTime endDate);

    /**
     * Find entities that need validation (high confidence but not yet validated).
     * 
     * @param confidenceThreshold Minimum confidence score to consider
     * @param limit Maximum number of entities to return
     * @return List of entities needing validation
     */
    List<RecognizedEntity> findEntitiesNeedingValidation(double confidenceThreshold, int limit);

    /**
     * Batch update validation status for multiple entities.
     * 
     * @param entityIds List of entity IDs to validate
     * @param validatedBy The user ID who validated the entities
     * @return Number of entities successfully validated
     */
    int batchValidateEntities(List<Long> entityIds, String validatedBy);

    /**
     * Delete entities older than specified days from completed sessions.
     * 
     * @param daysOld Number of days after which entities should be deleted
     * @return Number of entities deleted
     */
    int deleteOldEntities(int daysOld);

    /**
     * Find the most frequently recognized entities.
     * 
     * @param entityType Optional entity type filter (null for all types)
     * @param limit Maximum number of results to return
     * @return List of entities with their recognition counts
     */
    List<Map<String, Object>> findMostFrequentEntities(String entityType, int limit);

    /**
     * Get entity recognition trends over time.
     * 
     * @param days Number of days to look back
     * @param entityType Optional entity type filter (null for all types)
     * @return List of daily recognition counts
     */
    List<Map<String, Object>> getEntityRecognitionTrends(int days, String entityType);
    
    // Additional methods used by CurationTransactionService
    RecognizedEntity save(RecognizedEntity entity);
    void batchDelete(List<RecognizedEntity> entities);
    List<RecognizedEntity> findBySessionIdAndDateRange(Long sessionId, LocalDateTime startDate, LocalDateTime endDate);
}