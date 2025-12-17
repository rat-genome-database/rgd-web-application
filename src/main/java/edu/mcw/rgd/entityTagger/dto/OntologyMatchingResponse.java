package edu.mcw.rgd.entityTagger.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

/**
 * DTO for ontology matching response.
 * Contains matching results for multiple entities.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class OntologyMatchingResponse {

    private boolean success;
    private String sessionId;
    private LocalDateTime timestamp;
    private Long processingTimeMs;
    
    private Map<String, List<OntologyMatchDto>> matches;
    private Integer totalMatches;
    private Integer entitiesWithMatches;
    private Integer entitiesWithoutMatches;
    
    private List<String> warnings;
    private String errorMessage;

    /**
     * Default constructor
     */
    public OntologyMatchingResponse() {
        this.timestamp = LocalDateTime.now();
        this.matches = new HashMap<>();
    }

    /**
     * Create error response
     */
    public static OntologyMatchingResponse error(String errorMessage) {
        OntologyMatchingResponse response = new OntologyMatchingResponse();
        response.setSuccess(false);
        response.setErrorMessage(errorMessage);
        response.setTotalMatches(0);
        response.setEntitiesWithMatches(0);
        response.setEntitiesWithoutMatches(0);
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

    public Map<String, List<OntologyMatchDto>> getMatches() {
        return matches;
    }

    public void setMatches(Map<String, List<OntologyMatchDto>> matches) {
        this.matches = matches;
        
        // Update statistics when matches are set
        if (matches != null) {
            this.totalMatches = matches.values().stream()
                    .mapToInt(List::size)
                    .sum();
            this.entitiesWithMatches = (int) matches.values().stream()
                    .mapToLong(list -> list.isEmpty() ? 0 : 1)
                    .sum();
            this.entitiesWithoutMatches = matches.size() - this.entitiesWithMatches;
        }
    }

    public Integer getTotalMatches() {
        return totalMatches;
    }

    public void setTotalMatches(Integer totalMatches) {
        this.totalMatches = totalMatches;
    }

    public Integer getEntitiesWithMatches() {
        return entitiesWithMatches;
    }

    public void setEntitiesWithMatches(Integer entitiesWithMatches) {
        this.entitiesWithMatches = entitiesWithMatches;
    }

    public Integer getEntitiesWithoutMatches() {
        return entitiesWithoutMatches;
    }

    public void setEntitiesWithoutMatches(Integer entitiesWithoutMatches) {
        this.entitiesWithoutMatches = entitiesWithoutMatches;
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

    /**
     * Get match rate as percentage
     */
    public double getMatchRate() {
        if (matches == null || matches.isEmpty()) {
            return 0.0;
        }
        return (double) entitiesWithMatches / matches.size() * 100.0;
    }

    /**
     * Get average matches per entity
     */
    public double getAverageMatchesPerEntity() {
        if (matches == null || matches.isEmpty()) {
            return 0.0;
        }
        return (double) totalMatches / matches.size();
    }

    @Override
    public String toString() {
        return String.format("OntologyMatchingResponse{success=%s, totalMatches=%d, " +
                           "entitiesWithMatches=%d, matchRate=%.1f%%, processingTimeMs=%d}",
                success, totalMatches, entitiesWithMatches, getMatchRate(), processingTimeMs);
    }
}