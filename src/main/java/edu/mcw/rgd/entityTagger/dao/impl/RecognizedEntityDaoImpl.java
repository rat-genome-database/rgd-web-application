package edu.mcw.rgd.entityTagger.dao.impl;

import edu.mcw.rgd.entityTagger.dao.RecognizedEntityDao;
import edu.mcw.rgd.entityTagger.model.RecognizedEntity;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * Implementation of RecognizedEntityDao using JDBC.
 * Handles database operations for RecognizedEntity entities.
 */
@Repository
public class RecognizedEntityDaoImpl extends BaseDaoImpl<RecognizedEntity, Long> implements RecognizedEntityDao {

    private static final String TABLE_NAME = "RECOGNIZED_ENTITIES";
    private static final String ID_COLUMN = "ENTITY_ID";

    public RecognizedEntityDaoImpl(DataSource dataSource) {
        super(dataSource);
    }

    @Override
    protected String getTableName() {
        return TABLE_NAME;
    }

    @Override
    protected String getIdColumnName() {
        return ID_COLUMN;
    }

    @Override
    protected String getInsertSql() {
        return """
            INSERT INTO RECOGNIZED_ENTITIES (
                SESSION_ID, TEXT_ID, ENTITY_NAME, ENTITY_TYPE, NORMALIZED_NAME,
                CONFIDENCE_SCORE, START_POSITION, END_POSITION, CONTEXT, SOURCE_TEXT,
                ONTOLOGY_TERM_ID, ONTOLOGY_NAMESPACE, IS_VALIDATED, RECOGNIZED_DATE,
                NOTES, METADATA
            ) VALUES (
                :sessionId, :textId, :entityName, :entityType, :normalizedName,
                :confidenceScore, :startPosition, :endPosition, :context, :sourceText,
                :ontologyTermId, :ontologyNamespace, :isValidated, :recognizedDate,
                :notes, :metadata
            )
            """;
    }

    @Override
    protected String getUpdateSql() {
        return """
            UPDATE RECOGNIZED_ENTITIES SET
                SESSION_ID = :sessionId,
                TEXT_ID = :textId,
                ENTITY_NAME = :entityName,
                ENTITY_TYPE = :entityType,
                NORMALIZED_NAME = :normalizedName,
                CONFIDENCE_SCORE = :confidenceScore,
                START_POSITION = :startPosition,
                END_POSITION = :endPosition,
                CONTEXT = :context,
                SOURCE_TEXT = :sourceText,
                ONTOLOGY_TERM_ID = :ontologyTermId,
                ONTOLOGY_NAMESPACE = :ontologyNamespace,
                IS_VALIDATED = :isValidated,
                VALIDATED_BY = :validatedBy,
                VALIDATED_DATE = :validatedDate,
                NOTES = :notes,
                METADATA = :metadata
            WHERE ENTITY_ID = :entityId
            """;
    }

    @Override
    protected String getSelectByIdSql() {
        return "SELECT * FROM " + TABLE_NAME + " WHERE " + ID_COLUMN + " = :id";
    }

    @Override
    protected String getSelectAllSql() {
        return "SELECT * FROM " + TABLE_NAME + " ORDER BY RECOGNIZED_DATE DESC";
    }

    @Override
    protected RowMapper<RecognizedEntity> getRowMapper() {
        return new RecognizedEntityRowMapper();
    }

    @Override
    protected Long extractId(RecognizedEntity entity) {
        return entity.getEntityId();
    }

    @Override
    protected void setId(RecognizedEntity entity, Long id) {
        entity.setEntityId(id);
    }

    @Override
    public List<RecognizedEntity> findBySessionId(Long sessionId) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE SESSION_ID = :sessionId ORDER BY RECOGNIZED_DATE DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("sessionId", sessionId);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<RecognizedEntity> findByEntityType(String entityType) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE ENTITY_TYPE = :entityType ORDER BY RECOGNIZED_DATE DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("entityType", entityType);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<RecognizedEntity> findByEntityName(String entityName) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE UPPER(ENTITY_NAME) = UPPER(:entityName) ORDER BY RECOGNIZED_DATE DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("entityName", entityName);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<RecognizedEntity> findByTextId(String textId) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE TEXT_ID = :textId ORDER BY START_POSITION";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("textId", textId);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<RecognizedEntity> findByConfidenceAbove(double threshold) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE CONFIDENCE_SCORE >= :threshold ORDER BY CONFIDENCE_SCORE DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("threshold", threshold);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<RecognizedEntity> findByValidationStatus(boolean isValidated) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE IS_VALIDATED = :isValidated ORDER BY RECOGNIZED_DATE DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("isValidated", isValidated ? 1 : 0);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<RecognizedEntity> findByValidatedBy(String validatedBy) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE VALIDATED_BY = :validatedBy ORDER BY VALIDATED_DATE DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("validatedBy", validatedBy);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<RecognizedEntity> findByOntologyMappingStatus(boolean hasOntologyMapping) {
        String sql;
        if (hasOntologyMapping) {
            sql = "SELECT * FROM " + TABLE_NAME + " WHERE ONTOLOGY_TERM_ID IS NOT NULL ORDER BY RECOGNIZED_DATE DESC";
        } else {
            sql = "SELECT * FROM " + TABLE_NAME + " WHERE ONTOLOGY_TERM_ID IS NULL ORDER BY RECOGNIZED_DATE DESC";
        }
        
        return queryForList(sql);
    }

    @Override
    public List<RecognizedEntity> findByOntologyNamespace(String namespace) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE ONTOLOGY_NAMESPACE = :namespace ORDER BY RECOGNIZED_DATE DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("namespace", namespace);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<RecognizedEntity> findByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE RECOGNIZED_DATE >= :startDate AND RECOGNIZED_DATE <= :endDate ORDER BY RECOGNIZED_DATE DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("startDate", startDate);
        parameterSource.addValue("endDate", endDate);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<RecognizedEntity> searchBySourceText(String searchTerm) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE UPPER(SOURCE_TEXT) LIKE UPPER(:searchTerm) ORDER BY RECOGNIZED_DATE DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("searchTerm", "%" + searchTerm + "%");
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<RecognizedEntity> findPotentialDuplicates() {
        String sql = """
            SELECT * FROM RECOGNIZED_ENTITIES e1
            WHERE EXISTS (
                SELECT 1 FROM RECOGNIZED_ENTITIES e2
                WHERE e1.ENTITY_ID != e2.ENTITY_ID
                    AND UPPER(e1.ENTITY_NAME) = UPPER(e2.ENTITY_NAME)
                    AND e1.ENTITY_TYPE = e2.ENTITY_TYPE
                    AND e1.TEXT_ID = e2.TEXT_ID
                    AND e1.START_POSITION = e2.START_POSITION
                    AND e1.END_POSITION = e2.END_POSITION
            )
            ORDER BY ENTITY_NAME, TEXT_ID, START_POSITION
            """;
        
        return queryForList(sql);
    }

    @Override
    public boolean validateEntity(Long entityId, String validatedBy, String notes) {
        String sql = """
            UPDATE RECOGNIZED_ENTITIES SET
                IS_VALIDATED = 1,
                VALIDATED_BY = :validatedBy,
                VALIDATED_DATE = :now,
                NOTES = :notes
            WHERE ENTITY_ID = :entityId
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("entityId", entityId);
        parameterSource.addValue("validatedBy", validatedBy);
        parameterSource.addValue("now", LocalDateTime.now());
        parameterSource.addValue("notes", notes);
        
        int rowsAffected = namedParameterJdbcTemplate.update(sql, parameterSource);
        return rowsAffected > 0;
    }

    @Override
    public boolean updateOntologyMapping(Long entityId, String ontologyTermId, String ontologyNamespace) {
        String sql = """
            UPDATE RECOGNIZED_ENTITIES SET
                ONTOLOGY_TERM_ID = :ontologyTermId,
                ONTOLOGY_NAMESPACE = :ontologyNamespace
            WHERE ENTITY_ID = :entityId
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("entityId", entityId);
        parameterSource.addValue("ontologyTermId", ontologyTermId);
        parameterSource.addValue("ontologyNamespace", ontologyNamespace);
        
        int rowsAffected = namedParameterJdbcTemplate.update(sql, parameterSource);
        return rowsAffected > 0;
    }

    @Override
    public Map<String, Object> getEntityStatisticsBySession(Long sessionId) {
        String sql = """
            SELECT 
                COUNT(*) as total_entities,
                COUNT(DISTINCT ENTITY_TYPE) as entity_types_count,
                AVG(CONFIDENCE_SCORE) as avg_confidence,
                ROUND(SUM(CASE WHEN IS_VALIDATED = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as validation_rate
            FROM RECOGNIZED_ENTITIES 
            WHERE SESSION_ID = :sessionId
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("sessionId", sessionId);
        
        return namedParameterJdbcTemplate.queryForMap(sql, parameterSource);
    }

    @Override
    public Map<String, Object> getEntityStatisticsByType(LocalDateTime startDate, LocalDateTime endDate) {
        String sql = """
            SELECT 
                ENTITY_TYPE,
                COUNT(*) as entity_count,
                AVG(CONFIDENCE_SCORE) as avg_confidence,
                ROUND(SUM(CASE WHEN IS_VALIDATED = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as validation_rate
            FROM RECOGNIZED_ENTITIES 
            WHERE RECOGNIZED_DATE >= :startDate AND RECOGNIZED_DATE <= :endDate
            GROUP BY ENTITY_TYPE
            ORDER BY entity_count DESC
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("startDate", startDate);
        parameterSource.addValue("endDate", endDate);
        
        return namedParameterJdbcTemplate.queryForMap(sql, parameterSource);
    }

    @Override
    public Map<String, Object> getValidationStatistics(LocalDateTime startDate, LocalDateTime endDate) {
        String sql = """
            SELECT 
                COUNT(*) as total_entities,
                SUM(CASE WHEN IS_VALIDATED = 1 THEN 1 ELSE 0 END) as validated_entities,
                ROUND(SUM(CASE WHEN IS_VALIDATED = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as validation_rate,
                COUNT(DISTINCT VALIDATED_BY) as unique_validators
            FROM RECOGNIZED_ENTITIES 
            WHERE RECOGNIZED_DATE >= :startDate AND RECOGNIZED_DATE <= :endDate
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("startDate", startDate);
        parameterSource.addValue("endDate", endDate);
        
        return namedParameterJdbcTemplate.queryForMap(sql, parameterSource);
    }

    @Override
    public List<RecognizedEntity> findEntitiesNeedingValidation(double confidenceThreshold, int limit) {
        String sql = """
            SELECT * FROM RECOGNIZED_ENTITIES 
            WHERE CONFIDENCE_SCORE >= :threshold 
                AND IS_VALIDATED = 0
            ORDER BY CONFIDENCE_SCORE DESC, RECOGNIZED_DATE DESC
            FETCH FIRST :limit ROWS ONLY
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("threshold", confidenceThreshold);
        parameterSource.addValue("limit", limit);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public int batchValidateEntities(List<Long> entityIds, String validatedBy) {
        if (entityIds.isEmpty()) {
            return 0;
        }
        
        String sql = """
            UPDATE RECOGNIZED_ENTITIES SET
                IS_VALIDATED = 1,
                VALIDATED_BY = :validatedBy,
                VALIDATED_DATE = :now
            WHERE ENTITY_ID IN (:entityIds)
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("entityIds", entityIds);
        parameterSource.addValue("validatedBy", validatedBy);
        parameterSource.addValue("now", LocalDateTime.now());
        
        return namedParameterJdbcTemplate.update(sql, parameterSource);
    }

    @Override
    public int deleteOldEntities(int daysOld) {
        String sql = """
            DELETE FROM RECOGNIZED_ENTITIES 
            WHERE ENTITY_ID IN (
                SELECT re.ENTITY_ID 
                FROM RECOGNIZED_ENTITIES re
                JOIN CURATION_SESSIONS cs ON re.SESSION_ID = cs.SESSION_ID
                WHERE cs.STATUS = 'COMPLETED' 
                    AND cs.COMPLETED_DATE < :cutoffDate
            )
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("cutoffDate", LocalDateTime.now().minusDays(daysOld));
        
        return namedParameterJdbcTemplate.update(sql, parameterSource);
    }

    @Override
    public List<Map<String, Object>> findMostFrequentEntities(String entityType, int limit) {
        String sql = """
            SELECT 
                UPPER(ENTITY_NAME) as entity_name,
                ENTITY_TYPE,
                COUNT(*) as recognition_count,
                AVG(CONFIDENCE_SCORE) as avg_confidence
            FROM RECOGNIZED_ENTITIES 
            WHERE (:entityType IS NULL OR ENTITY_TYPE = :entityType)
            GROUP BY UPPER(ENTITY_NAME), ENTITY_TYPE
            ORDER BY recognition_count DESC
            FETCH FIRST :limit ROWS ONLY
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("entityType", entityType);
        parameterSource.addValue("limit", limit);
        
        return namedParameterJdbcTemplate.queryForList(sql, parameterSource);
    }

    @Override
    public List<Map<String, Object>> getEntityRecognitionTrends(int days, String entityType) {
        String sql = """
            SELECT 
                TO_CHAR(RECOGNIZED_DATE, 'YYYY-MM-DD') as recognition_date,
                COUNT(*) as entity_count,
                COUNT(DISTINCT ENTITY_NAME) as unique_entities
            FROM RECOGNIZED_ENTITIES 
            WHERE RECOGNIZED_DATE >= :startDate
                AND (:entityType IS NULL OR ENTITY_TYPE = :entityType)
            GROUP BY TO_CHAR(RECOGNIZED_DATE, 'YYYY-MM-DD')
            ORDER BY recognition_date
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("startDate", LocalDateTime.now().minusDays(days));
        parameterSource.addValue("entityType", entityType);
        
        return namedParameterJdbcTemplate.queryForList(sql, parameterSource);
    }

    /**
     * Row mapper for converting database rows to RecognizedEntity objects.
     */
    private static class RecognizedEntityRowMapper implements RowMapper<RecognizedEntity> {
        @Override
        public RecognizedEntity mapRow(ResultSet rs, int rowNum) throws SQLException {
            RecognizedEntity entity = new RecognizedEntity();
            
            entity.setEntityId(rs.getLong("ENTITY_ID"));
            entity.setSessionId(rs.getLong("SESSION_ID"));
            entity.setTextId(rs.getString("TEXT_ID"));
            entity.setEntityName(rs.getString("ENTITY_NAME"));
            entity.setEntityType(rs.getString("ENTITY_TYPE"));
            entity.setNormalizedName(rs.getString("NORMALIZED_NAME"));
            entity.setConfidenceScore(rs.getDouble("CONFIDENCE_SCORE"));
            entity.setStartPosition(rs.getInt("START_POSITION"));
            entity.setEndPosition(rs.getInt("END_POSITION"));
            entity.setContext(rs.getString("CONTEXT"));
            entity.setSourceText(rs.getString("SOURCE_TEXT"));
            entity.setOntologyTermId(rs.getString("ONTOLOGY_TERM_ID"));
            entity.setOntologyNamespace(rs.getString("ONTOLOGY_NAMESPACE"));
            entity.setIsValidated(rs.getBoolean("IS_VALIDATED"));
            entity.setValidatedBy(rs.getString("VALIDATED_BY"));
            
            if (rs.getTimestamp("RECOGNIZED_DATE") != null) {
                entity.setRecognizedDate(rs.getTimestamp("RECOGNIZED_DATE").toLocalDateTime());
            }
            if (rs.getTimestamp("VALIDATED_DATE") != null) {
                entity.setValidatedDate(rs.getTimestamp("VALIDATED_DATE").toLocalDateTime());
            }
            
            entity.setNotes(rs.getString("NOTES"));
            entity.setMetadata(rs.getString("METADATA"));
            
            return entity;
        }
    }
    
    // Missing implementations for new methods
    @Override
    public void batchDelete(List<RecognizedEntity> entities) {
        // TODO: Implement batch delete
    }
    
    @Override
    public List<RecognizedEntity> findBySessionIdAndDateRange(Long sessionId, LocalDateTime startDate, LocalDateTime endDate) {
        // TODO: Implement date range query
        return java.util.Collections.emptyList();
    }
}