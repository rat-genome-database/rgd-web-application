package edu.mcw.rgd.entityTagger.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;

/**
 * DTO for batch entity recognition response.
 * Contains results for multiple text processing operations.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class BatchEntityRecognitionResponse {

    private boolean success;
    private String sessionId;
    private LocalDateTime timestamp;
    private Long processingTimeMs;
    
    private List<EntityRecognitionApiResponse> results;
    private Integer processedCount;
    private Integer successfulCount;
    private Integer failedCount;
    
    private BatchSummaryDto batchSummary;
    private List<String> warnings;
    private String errorMessage;

    /**
     * Default constructor
     */
    public BatchEntityRecognitionResponse() {
        this.timestamp = LocalDateTime.now();
        this.results = new ArrayList<>();
    }

    /**
     * Create error response
     */
    public static BatchEntityRecognitionResponse error(String errorMessage) {
        BatchEntityRecognitionResponse response = new BatchEntityRecognitionResponse();
        response.setSuccess(false);
        response.setErrorMessage(errorMessage);
        response.setProcessedCount(0);
        response.setSuccessfulCount(0);
        response.setFailedCount(0);
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

    public List<EntityRecognitionApiResponse> getResults() {
        return results;
    }

    public void setResults(List<EntityRecognitionApiResponse> results) {
        this.results = results;
        // Update counts when results are set
        if (results != null) {
            this.processedCount = results.size();
            this.successfulCount = (int) results.stream().mapToLong(r -> r.isSuccess() ? 1 : 0).sum();
            this.failedCount = this.processedCount - this.successfulCount;
        }
    }

    public Integer getProcessedCount() {
        return processedCount;
    }

    public void setProcessedCount(Integer processedCount) {
        this.processedCount = processedCount;
    }

    public Integer getSuccessfulCount() {
        return successfulCount;
    }

    public void setSuccessfulCount(Integer successfulCount) {
        this.successfulCount = successfulCount;
    }

    public Integer getFailedCount() {
        return failedCount;
    }

    public void setFailedCount(Integer failedCount) {
        this.failedCount = failedCount;
    }

    public BatchSummaryDto getBatchSummary() {
        return batchSummary;
    }

    public void setBatchSummary(BatchSummaryDto batchSummary) {
        this.batchSummary = batchSummary;
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
     * Get success rate as percentage
     */
    public double getSuccessRate() {
        if (processedCount == null || processedCount == 0) {
            return 0.0;
        }
        return (double) successfulCount / processedCount * 100.0;
    }

    @Override
    public String toString() {
        return String.format("BatchEntityRecognitionResponse{success=%s, processed=%d, successful=%d, " +
                           "failed=%d, processingTimeMs=%d, successRate=%.1f%%}",
                success, processedCount, successfulCount, failedCount, 
                processingTimeMs, getSuccessRate());
    }

    /**
     * DTO for batch processing summary statistics
     */
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class BatchSummaryDto {
        private Integer totalEntitiesFound;
        private Integer totalOntologyMatches;
        private Double averageConfidenceAcrossBatch;
        private Double averageProcessingTimePerText;
        private String mostCommonEntityType;
        private Integer uniqueTermsFound;

        public BatchSummaryDto() {}

        // Getters and Setters
        public Integer getTotalEntitiesFound() { return totalEntitiesFound; }
        public void setTotalEntitiesFound(Integer totalEntitiesFound) { this.totalEntitiesFound = totalEntitiesFound; }

        public Integer getTotalOntologyMatches() { return totalOntologyMatches; }
        public void setTotalOntologyMatches(Integer totalOntologyMatches) { this.totalOntologyMatches = totalOntologyMatches; }

        public Double getAverageConfidenceAcrossBatch() { return averageConfidenceAcrossBatch; }
        public void setAverageConfidenceAcrossBatch(Double averageConfidenceAcrossBatch) { this.averageConfidenceAcrossBatch = averageConfidenceAcrossBatch; }

        public Double getAverageProcessingTimePerText() { return averageProcessingTimePerText; }
        public void setAverageProcessingTimePerText(Double averageProcessingTimePerText) { this.averageProcessingTimePerText = averageProcessingTimePerText; }

        public String getMostCommonEntityType() { return mostCommonEntityType; }
        public void setMostCommonEntityType(String mostCommonEntityType) { this.mostCommonEntityType = mostCommonEntityType; }

        public Integer getUniqueTermsFound() { return uniqueTermsFound; }
        public void setUniqueTermsFound(Integer uniqueTermsFound) { this.uniqueTermsFound = uniqueTermsFound; }

        @Override
        public String toString() {
            return String.format("BatchSummaryDto{totalEntities=%d, ontologyMatches=%d, avgConfidence=%.2f}",
                    totalEntitiesFound, totalOntologyMatches, averageConfidenceAcrossBatch);
        }
    }
}