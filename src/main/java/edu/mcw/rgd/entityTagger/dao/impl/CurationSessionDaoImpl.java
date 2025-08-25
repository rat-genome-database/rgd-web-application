package edu.mcw.rgd.entityTagger.dao.impl;

import edu.mcw.rgd.entityTagger.dao.CurationSessionDao;
import edu.mcw.rgd.entityTagger.model.CurationSession;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Implementation of CurationSessionDao using JDBC.
 * Handles database operations for CurationSession entities.
 */
@Repository
public class CurationSessionDaoImpl extends BaseDaoImpl<CurationSession, Long> implements CurationSessionDao {

    private static final String TABLE_NAME = "CURATION_SESSIONS";
    private static final String ID_COLUMN = "SESSION_ID";

    public CurationSessionDaoImpl(DataSource dataSource) {
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
            INSERT INTO CURATION_SESSIONS (
                SESSION_KEY, USER_ID, USER_EMAIL, STATUS, SESSION_TYPE,
                CREATED_DATE, LAST_ACTIVITY_DATE, TOTAL_TEXTS_PROCESSED,
                ENTITIES_RECOGNIZED, PROCESSING_TIME_MS, CONFIGURATION, NOTES
            ) VALUES (
                :sessionKey, :userId, :userEmail, :status, :sessionType,
                :createdDate, :lastActivityDate, :totalTextsProcessed,
                :entitiesRecognized, :processingTimeMs, :configuration, :notes
            )
            """;
    }

    @Override
    protected String getUpdateSql() {
        return """
            UPDATE CURATION_SESSIONS SET
                SESSION_KEY = :sessionKey,
                USER_ID = :userId,
                USER_EMAIL = :userEmail,
                STATUS = :status,
                SESSION_TYPE = :sessionType,
                LAST_ACTIVITY_DATE = :lastActivityDate,
                COMPLETED_DATE = :completedDate,
                TOTAL_TEXTS_PROCESSED = :totalTextsProcessed,
                ENTITIES_RECOGNIZED = :entitiesRecognized,
                PROCESSING_TIME_MS = :processingTimeMs,
                CONFIGURATION = :configuration,
                NOTES = :notes
            WHERE SESSION_ID = :sessionId
            """;
    }

    @Override
    protected String getSelectByIdSql() {
        return "SELECT * FROM " + TABLE_NAME + " WHERE " + ID_COLUMN + " = :id";
    }

    @Override
    protected String getSelectAllSql() {
        return "SELECT * FROM " + TABLE_NAME + " ORDER BY CREATED_DATE DESC";
    }

    @Override
    protected RowMapper<CurationSession> getRowMapper() {
        return new CurationSessionRowMapper();
    }

    @Override
    protected Long extractId(CurationSession entity) {
        return entity.getSessionId();
    }

    @Override
    protected void setId(CurationSession entity, Long id) {
        entity.setSessionId(id);
    }

    @Override
    public Optional<CurationSession> findBySessionKey(String sessionKey) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE SESSION_KEY = :sessionKey";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("sessionKey", sessionKey);
        
        return queryForObject(sql, parameterSource);
    }

    @Override
    public List<CurationSession> findByUserId(String userId) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE USER_ID = :userId ORDER BY CREATED_DATE DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("userId", userId);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<CurationSession> findByStatus(CurationSession.SessionStatus status) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE STATUS = :status ORDER BY CREATED_DATE DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("status", status.name());
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<CurationSession> findActiveSessionsByUser(String userId) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE USER_ID = :userId AND STATUS = :status ORDER BY LAST_ACTIVITY_DATE DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("userId", userId);
        parameterSource.addValue("status", CurationSession.SessionStatus.ACTIVE.name());
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<CurationSession> findByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE CREATED_DATE >= :startDate AND CREATED_DATE <= :endDate ORDER BY CREATED_DATE DESC";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("startDate", startDate);
        parameterSource.addValue("endDate", endDate);
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public List<CurationSession> findInactiveSessions(int inactiveMinutes) {
        String sql = "SELECT * FROM " + TABLE_NAME + " WHERE STATUS = :status AND LAST_ACTIVITY_DATE < :cutoffTime";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("status", CurationSession.SessionStatus.ACTIVE.name());
        parameterSource.addValue("cutoffTime", LocalDateTime.now().minusMinutes(inactiveMinutes));
        
        return queryForList(sql, parameterSource);
    }

    @Override
    public boolean updateLastActivity(Long sessionId) {
        String sql = "UPDATE " + TABLE_NAME + " SET LAST_ACTIVITY_DATE = :now WHERE SESSION_ID = :sessionId";
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("now", LocalDateTime.now());
        parameterSource.addValue("sessionId", sessionId);
        
        int rowsAffected = namedParameterJdbcTemplate.update(sql, parameterSource);
        return rowsAffected > 0;
    }

    @Override
    public boolean updateSessionStatistics(Long sessionId, int textsProcessed, int entitiesRecognized, long processingTimeMs) {
        String sql = """
            UPDATE CURATION_SESSIONS SET
                TOTAL_TEXTS_PROCESSED = TOTAL_TEXTS_PROCESSED + :textsProcessed,
                ENTITIES_RECOGNIZED = ENTITIES_RECOGNIZED + :entitiesRecognized,
                PROCESSING_TIME_MS = PROCESSING_TIME_MS + :processingTimeMs,
                LAST_ACTIVITY_DATE = :now
            WHERE SESSION_ID = :sessionId
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("textsProcessed", textsProcessed);
        parameterSource.addValue("entitiesRecognized", entitiesRecognized);
        parameterSource.addValue("processingTimeMs", processingTimeMs);
        parameterSource.addValue("now", LocalDateTime.now());
        parameterSource.addValue("sessionId", sessionId);
        
        int rowsAffected = namedParameterJdbcTemplate.update(sql, parameterSource);
        return rowsAffected > 0;
    }

    @Override
    public boolean completeSession(Long sessionId) {
        String sql = """
            UPDATE CURATION_SESSIONS SET
                STATUS = :status,
                COMPLETED_DATE = :now,
                LAST_ACTIVITY_DATE = :now
            WHERE SESSION_ID = :sessionId
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("status", CurationSession.SessionStatus.COMPLETED.name());
        parameterSource.addValue("now", LocalDateTime.now());
        parameterSource.addValue("sessionId", sessionId);
        
        int rowsAffected = namedParameterJdbcTemplate.update(sql, parameterSource);
        return rowsAffected > 0;
    }

    @Override
    public int markExpiredSessions(int expirationMinutes) {
        String sql = """
            UPDATE CURATION_SESSIONS SET
                STATUS = :expiredStatus,
                LAST_ACTIVITY_DATE = :now
            WHERE STATUS = :activeStatus
                AND LAST_ACTIVITY_DATE < :cutoffTime
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("expiredStatus", CurationSession.SessionStatus.EXPIRED.name());
        parameterSource.addValue("activeStatus", CurationSession.SessionStatus.ACTIVE.name());
        parameterSource.addValue("now", LocalDateTime.now());
        parameterSource.addValue("cutoffTime", LocalDateTime.now().minusMinutes(expirationMinutes));
        
        return namedParameterJdbcTemplate.update(sql, parameterSource);
    }

    @Override
    public Map<String, Object> getSessionStatistics(String userId) {
        String sql = """
            SELECT 
                COUNT(*) as total_sessions,
                COALESCE(SUM(TOTAL_TEXTS_PROCESSED), 0) as total_texts_processed,
                COALESCE(SUM(ENTITIES_RECOGNIZED), 0) as total_entities_recognized,
                COALESCE(AVG(PROCESSING_TIME_MS), 0) as avg_processing_time
            FROM CURATION_SESSIONS 
            WHERE USER_ID = :userId
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("userId", userId);
        
        return namedParameterJdbcTemplate.queryForMap(sql, parameterSource);
    }

    @Override
    public Map<String, Object> getSessionStatisticsByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        String sql = """
            SELECT 
                COUNT(*) as total_sessions,
                COUNT(DISTINCT USER_ID) as unique_users,
                COALESCE(SUM(TOTAL_TEXTS_PROCESSED), 0) as total_texts_processed,
                COALESCE(SUM(ENTITIES_RECOGNIZED), 0) as total_entities_recognized,
                COALESCE(AVG(PROCESSING_TIME_MS), 0) as avg_processing_time,
                COALESCE(SUM(PROCESSING_TIME_MS), 0) as total_processing_time
            FROM CURATION_SESSIONS 
            WHERE CREATED_DATE >= :startDate AND CREATED_DATE <= :endDate
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("startDate", startDate);
        parameterSource.addValue("endDate", endDate);
        
        return namedParameterJdbcTemplate.queryForMap(sql, parameterSource);
    }

    @Override
    public int deleteOldCompletedSessions(int daysOld) {
        String sql = """
            DELETE FROM CURATION_SESSIONS 
            WHERE STATUS = :status 
                AND COMPLETED_DATE < :cutoffDate
            """;
        
        MapSqlParameterSource parameterSource = new MapSqlParameterSource();
        parameterSource.addValue("status", CurationSession.SessionStatus.COMPLETED.name());
        parameterSource.addValue("cutoffDate", LocalDateTime.now().minusDays(daysOld));
        
        return namedParameterJdbcTemplate.update(sql, parameterSource);
    }

    /**
     * Row mapper for converting database rows to CurationSession objects.
     */
    private static class CurationSessionRowMapper implements RowMapper<CurationSession> {
        @Override
        public CurationSession mapRow(ResultSet rs, int rowNum) throws SQLException {
            CurationSession session = new CurationSession();
            
            session.setSessionId(rs.getLong("SESSION_ID"));
            session.setSessionKey(rs.getString("SESSION_KEY"));
            session.setUserId(rs.getString("USER_ID"));
            session.setUserEmail(rs.getString("USER_EMAIL"));
            
            String statusStr = rs.getString("STATUS");
            if (statusStr != null) {
                session.setStatus(CurationSession.SessionStatus.valueOf(statusStr));
            }
            
            session.setSessionType(rs.getString("SESSION_TYPE"));
            
            if (rs.getTimestamp("CREATED_DATE") != null) {
                session.setCreatedDate(rs.getTimestamp("CREATED_DATE").toLocalDateTime());
            }
            if (rs.getTimestamp("LAST_ACTIVITY_DATE") != null) {
                session.setLastActivityDate(rs.getTimestamp("LAST_ACTIVITY_DATE").toLocalDateTime());
            }
            if (rs.getTimestamp("COMPLETED_DATE") != null) {
                session.setCompletedDate(rs.getTimestamp("COMPLETED_DATE").toLocalDateTime());
            }
            
            session.setTotalTextsProcessed(rs.getInt("TOTAL_TEXTS_PROCESSED"));
            session.setEntitiesRecognized(rs.getInt("ENTITIES_RECOGNIZED"));
            session.setProcessingTimeMs(rs.getLong("PROCESSING_TIME_MS"));
            session.setConfiguration(rs.getString("CONFIGURATION"));
            session.setNotes(rs.getString("NOTES"));
            
            return session;
        }
    }
    
    // Missing implementation for new method
    @Override
    public List<edu.mcw.rgd.entityTagger.model.CurationSession> findByStatusAndDateRange(
            edu.mcw.rgd.entityTagger.model.CurationSession.SessionStatus status, Object unused, LocalDateTime endDate) {
        // TODO: Implement status and date range query
        return java.util.Collections.emptyList();
    }
}