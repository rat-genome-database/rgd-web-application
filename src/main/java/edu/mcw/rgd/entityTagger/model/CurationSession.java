package edu.mcw.rgd.entityTagger.model;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDateTime;
import java.util.Objects;

/**
 * Entity representing a curation session in the database.
 * A curation session tracks user activities and progress during entity recognition tasks.
 */
public class CurationSession {
    
    private Long sessionId;
    private String sessionKey;
    private String userId;
    private String userEmail;
    private SessionStatus status;
    private String sessionType;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdDate;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime lastActivityDate;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime completedDate;
    
    private Integer totalTextsProcessed;
    private Integer entitiesRecognized;
    private Long processingTimeMs;
    private String configuration;
    private String notes;

    public enum SessionStatus {
        ACTIVE,
        COMPLETED,
        CANCELLED,
        EXPIRED
    }

    public CurationSession() {
        this.createdDate = LocalDateTime.now();
        this.lastActivityDate = LocalDateTime.now();
        this.status = SessionStatus.ACTIVE;
        this.totalTextsProcessed = 0;
        this.entitiesRecognized = 0;
        this.processingTimeMs = 0L;
    }

    public CurationSession(String sessionKey, String userId) {
        this();
        this.sessionKey = sessionKey;
        this.userId = userId;
    }

    // Getters and Setters

    public Long getSessionId() {
        return sessionId;
    }

    public void setSessionId(Long sessionId) {
        this.sessionId = sessionId;
    }

    public String getSessionKey() {
        return sessionKey;
    }

    public void setSessionKey(String sessionKey) {
        this.sessionKey = sessionKey;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public SessionStatus getStatus() {
        return status;
    }

    public void setStatus(SessionStatus status) {
        this.status = status;
    }

    public String getSessionType() {
        return sessionType;
    }

    public void setSessionType(String sessionType) {
        this.sessionType = sessionType;
    }

    public LocalDateTime getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(LocalDateTime createdDate) {
        this.createdDate = createdDate;
    }

    public LocalDateTime getLastActivityDate() {
        return lastActivityDate;
    }

    public void setLastActivityDate(LocalDateTime lastActivityDate) {
        this.lastActivityDate = lastActivityDate;
    }

    public LocalDateTime getCompletedDate() {
        return completedDate;
    }

    public void setCompletedDate(LocalDateTime completedDate) {
        this.completedDate = completedDate;
    }

    public Integer getTotalTextsProcessed() {
        return totalTextsProcessed;
    }

    public void setTotalTextsProcessed(Integer totalTextsProcessed) {
        this.totalTextsProcessed = totalTextsProcessed;
    }

    public Integer getEntitiesRecognized() {
        return entitiesRecognized;
    }

    public void setEntitiesRecognized(Integer entitiesRecognized) {
        this.entitiesRecognized = entitiesRecognized;
    }

    public Long getProcessingTimeMs() {
        return processingTimeMs;
    }

    public void setProcessingTimeMs(Long processingTimeMs) {
        this.processingTimeMs = processingTimeMs;
    }

    public String getConfiguration() {
        return configuration;
    }

    public void setConfiguration(String configuration) {
        this.configuration = configuration;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    // Utility methods

    /**
     * Mark the session as completed and set completion timestamp.
     */
    public void complete() {
        this.status = SessionStatus.COMPLETED;
        this.completedDate = LocalDateTime.now();
        this.lastActivityDate = LocalDateTime.now();
    }

    /**
     * Update the last activity timestamp.
     */
    public void updateActivity() {
        this.lastActivityDate = LocalDateTime.now();
    }

    /**
     * Add processing time to the session total.
     * 
     * @param additionalTimeMs Additional processing time in milliseconds
     */
    public void addProcessingTime(long additionalTimeMs) {
        this.processingTimeMs += additionalTimeMs;
        updateActivity();
    }

    /**
     * Increment the count of texts processed.
     * 
     * @param count Number of texts to add to the total
     */
    public void addTextsProcessed(int count) {
        this.totalTextsProcessed += count;
        updateActivity();
    }

    /**
     * Increment the count of entities recognized.
     * 
     * @param count Number of entities to add to the total
     */
    public void addEntitiesRecognized(int count) {
        this.entitiesRecognized += count;
        updateActivity();
    }

    /**
     * Check if the session is active.
     * 
     * @return true if session is active, false otherwise
     */
    public boolean isActive() {
        return SessionStatus.ACTIVE.equals(this.status);
    }

    /**
     * Check if the session is completed.
     * 
     * @return true if session is completed, false otherwise
     */
    public boolean isCompleted() {
        return SessionStatus.COMPLETED.equals(this.status);
    }
    
    // Additional methods used by CurationTransactionService
    public void setSessionName(String sessionName) {
        this.notes = sessionName; // Use notes field for session name
    }
    
    public String getSessionName() {
        return this.notes; // Use notes field for session name
    }
    
    public void setDescription(String description) {
        this.configuration = description; // Use configuration field for description
    }
    
    public String getDescription() {
        return this.configuration; // Use configuration field for description
    }
    
    public void setStartTime(LocalDateTime startTime) {
        this.createdDate = startTime;
    }
    
    public LocalDateTime getStartTime() {
        return this.createdDate;
    }
    
    public void setLastActivity(LocalDateTime lastActivity) {
        this.lastActivityDate = lastActivity;
    }
    
    public LocalDateTime getLastActivity() {
        return this.lastActivityDate;
    }
    
    public void incrementEntitiesProcessed(int count) {
        if (this.entitiesRecognized == null) {
            this.entitiesRecognized = 0;
        }
        this.entitiesRecognized += count;
        updateActivity();
    }
    
    public void decrementEntitiesProcessed(int count) {
        if (this.entitiesRecognized == null) {
            this.entitiesRecognized = 0;
        }
        this.entitiesRecognized = Math.max(0, this.entitiesRecognized - count);
        updateActivity();
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        CurationSession that = (CurationSession) o;
        return Objects.equals(sessionId, that.sessionId) &&
               Objects.equals(sessionKey, that.sessionKey);
    }

    @Override
    public int hashCode() {
        return Objects.hash(sessionId, sessionKey);
    }

    @Override
    public String toString() {
        return "CurationSession{" +
                "sessionId=" + sessionId +
                ", sessionKey='" + sessionKey + '\'' +
                ", userId='" + userId + '\'' +
                ", status=" + status +
                ", createdDate=" + createdDate +
                ", totalTextsProcessed=" + totalTextsProcessed +
                ", entitiesRecognized=" + entitiesRecognized +
                '}';
    }
}