package edu.mcw.rgd.entityTagger.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;

/**
 * API response DTO for entity recognition operations.
 * Contains the results of text analysis and entity extraction.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class EntityRecognitionApiResponse {

    private boolean success;
    private String sessionId;
    private LocalDateTime timestamp;
    private Long processingTimeMs;
    
    private List<RecognizedEntityDto> entities;
    private Integer entityCount;
    private EntitySummaryDto summary;
    
    private List<String> warnings;
    private String errorMessage;
    private String errorCode;
    
    private String modelUsed;
    private Double overallConfidence;

    /**
     * Default constructor
     */
    public EntityRecognitionApiResponse() {
        this.timestamp = LocalDateTime.now();
        this.entities = new ArrayList<>();
    }

    /**
     * Create success response
     */
    public static EntityRecognitionApiResponse success(List<RecognizedEntityDto> entities, String sessionId) {
        EntityRecognitionApiResponse response = new EntityRecognitionApiResponse();
        response.setSuccess(true);
        response.setEntities(entities);
        response.setEntityCount(entities != null ? entities.size() : 0);
        response.setSessionId(sessionId);
        return response;
    }

    /**
     * Create error response
     */
    public static EntityRecognitionApiResponse error(String errorMessage) {
        EntityRecognitionApiResponse response = new EntityRecognitionApiResponse();
        response.setSuccess(false);
        response.setErrorMessage(errorMessage);
        response.setEntityCount(0);
        return response;
    }

    /**
     * Create error response with code
     */
    public static EntityRecognitionApiResponse error(String errorMessage, String errorCode) {
        EntityRecognitionApiResponse response = error(errorMessage);
        response.setErrorCode(errorCode);
        return response;
    }

    // Getters and Setters

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    public Long getProcessingTimeMs() {
        return processingTimeMs;
    }

    public void setProcessingTimeMs(Long processingTimeMs) {
        this.processingTimeMs = processingTimeMs;
    }

    public List<RecognizedEntityDto> getEntities() {
        return entities;
    }

    public void setEntities(List<RecognizedEntityDto> entities) {
        this.entities = entities;
    }

    public Integer getEntityCount() {
        return entityCount;
    }

    public void setEntityCount(Integer entityCount) {
        this.entityCount = entityCount;
    }

    public EntitySummaryDto getSummary() {
        return summary;
    }

    public void setSummary(EntitySummaryDto summary) {
        this.summary = summary;
    }

    public List<String> getWarnings() {
        return warnings;
    }

    public void setWarnings(List<String> warnings) {
        this.warnings = warnings;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(String errorCode) {
        this.errorCode = errorCode;
    }

    public String getModelUsed() {
        return modelUsed;
    }

    public void setModelUsed(String modelUsed) {
        this.modelUsed = modelUsed;
    }

    public Double getOverallConfidence() {
        return overallConfidence;
    }

    public void setOverallConfidence(Double overallConfidence) {
        this.overallConfidence = overallConfidence;
    }

    @Override
    public String toString() {
        return String.format("EntityRecognitionApiResponse{success=%s, entityCount=%d, sessionId='%s', " +
                           "processingTimeMs=%d, hasWarnings=%s}",
                success, entityCount, sessionId, processingTimeMs, 
                warnings != null && !warnings.isEmpty());
    }
}