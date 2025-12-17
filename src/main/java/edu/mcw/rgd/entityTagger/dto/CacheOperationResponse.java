package edu.mcw.rgd.entityTagger.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.LocalDateTime;

/**
 * DTO for cache operation response.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CacheOperationResponse {

    private boolean success;
    private LocalDateTime timestamp;
    
    private String operation;
    private String message;
    private String errorMessage;
    
    private Long operationTimeMs;
    private Integer affectedEntries;

    /**
     * Default constructor
     */
    public CacheOperationResponse() {
        this.timestamp = LocalDateTime.now();
    }

    /**
     * Create error response
     */
    public static CacheOperationResponse error(String errorMessage) {
        CacheOperationResponse response = new CacheOperationResponse();
        response.setSuccess(false);
        response.setErrorMessage(errorMessage);
        return response;
    }

    // Getters and Setters

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    public String getOperation() {
        return operation;
    }

    public void setOperation(String operation) {
        this.operation = operation;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public Long getOperationTimeMs() {
        return operationTimeMs;
    }

    public void setOperationTimeMs(Long operationTimeMs) {
        this.operationTimeMs = operationTimeMs;
    }

    public Integer getAffectedEntries() {
        return affectedEntries;
    }

    public void setAffectedEntries(Integer affectedEntries) {
        this.affectedEntries = affectedEntries;
    }

    @Override
    public String toString() {
        return String.format("CacheOperationResponse{success=%s, operation='%s', message='%s'}",
                success, operation, message);
    }
}