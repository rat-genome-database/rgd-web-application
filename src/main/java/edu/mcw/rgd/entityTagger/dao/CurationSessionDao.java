package edu.mcw.rgd.entityTagger.dao;

import edu.mcw.rgd.entityTagger.model.CurationSession;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Data Access Object interface for CurationSession entities.
 * Provides methods for managing curation sessions in the database.
 */
public interface CurationSessionDao extends BaseDao<CurationSession, Long> {

    /**
     * Find a curation session by its session key.
     * 
     * @param sessionKey The unique session key
     * @return Optional containing the session if found, empty otherwise
     */
    Optional<CurationSession> findBySessionKey(String sessionKey);

    /**
     * Find all sessions for a specific user.
     * 
     * @param userId The user ID
     * @return List of sessions for the user
     */
    List<CurationSession> findByUserId(String userId);

    /**
     * Find sessions by status.
     * 
     * @param status The session status
     * @return List of sessions with the specified status
     */
    List<CurationSession> findByStatus(CurationSession.SessionStatus status);

    /**
     * Find active sessions for a user.
     * 
     * @param userId The user ID
     * @return List of active sessions for the user
     */
    List<CurationSession> findActiveSessionsByUser(String userId);

    /**
     * Find sessions created within a date range.
     * 
     * @param startDate The start date (inclusive)
     * @param endDate The end date (inclusive)
     * @return List of sessions created in the date range
     */
    List<CurationSession> findByDateRange(LocalDateTime startDate, LocalDateTime endDate);

    /**
     * Find sessions that have been inactive for longer than the specified minutes.
     * 
     * @param inactiveMinutes Number of minutes of inactivity
     * @return List of inactive sessions
     */
    List<CurationSession> findInactiveSessions(int inactiveMinutes);

    /**
     * Update the last activity timestamp for a session.
     * 
     * @param sessionId The session ID
     * @return true if update was successful, false otherwise
     */
    boolean updateLastActivity(Long sessionId);

    /**
     * Update session statistics (texts processed, entities recognized, processing time).
     * 
     * @param sessionId The session ID
     * @param textsProcessed Number of texts processed to add
     * @param entitiesRecognized Number of entities recognized to add
     * @param processingTimeMs Processing time in milliseconds to add
     * @return true if update was successful, false otherwise
     */
    boolean updateSessionStatistics(Long sessionId, int textsProcessed, int entitiesRecognized, long processingTimeMs);

    /**
     * Mark a session as completed and set completion date.
     * 
     * @param sessionId The session ID
     * @return true if update was successful, false otherwise
     */
    boolean completeSession(Long sessionId);

    /**
     * Mark expired sessions as expired based on last activity date.
     * 
     * @param expirationMinutes Number of minutes after which a session expires
     * @return Number of sessions that were marked as expired
     */
    int markExpiredSessions(int expirationMinutes);

    /**
     * Get session statistics summary for a user.
     * 
     * @param userId The user ID
     * @return Map containing statistics (total_sessions, total_texts_processed, total_entities_recognized, avg_processing_time)
     */
    java.util.Map<String, Object> getSessionStatistics(String userId);

    /**
     * Get session statistics summary for a date range.
     * 
     * @param startDate The start date (inclusive)
     * @param endDate The end date (inclusive)
     * @return Map containing statistics for the date range
     */
    java.util.Map<String, Object> getSessionStatisticsByDateRange(LocalDateTime startDate, LocalDateTime endDate);

    /**
     * Delete old completed sessions older than specified days.
     * 
     * @param daysOld Number of days after which completed sessions should be deleted
     * @return Number of sessions deleted
     */
    int deleteOldCompletedSessions(int daysOld);
    
    // Additional methods used by CurationTransactionService
    CurationSession save(CurationSession session);
    void delete(CurationSession session);
    List<CurationSession> findByStatusAndDateRange(CurationSession.SessionStatus status, Object unused, LocalDateTime endDate);
}