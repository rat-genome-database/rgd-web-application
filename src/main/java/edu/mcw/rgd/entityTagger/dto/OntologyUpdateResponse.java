package edu.mcw.rgd.entityTagger.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.Set;

/**
 * DTO for ontology update operation response.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class OntologyUpdateResponse {

    private boolean success;
    private LocalDateTime timestamp;
    
    private Integer totalTermsLoaded;
    private Set<String> ontologiesUpdated;
    private Map<String, String> errors;
    
    private String updateSource;
    private Long processingTimeMs;
    private String errorMessage;

    /**
     * Default constructor
     */
    public OntologyUpdateResponse() {
        this.timestamp = LocalDateTime.now();
    }

    /**
     * Create error response
     */
    public static OntologyUpdateResponse error(String errorMessage) {
        OntologyUpdateResponse response = new OntologyUpdateResponse();
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

    public Integer getTotalTermsLoaded() {
        return totalTermsLoaded;
    }

    public void setTotalTermsLoaded(Integer totalTermsLoaded) {
        this.totalTermsLoaded = totalTermsLoaded;
    }

    public Set<String> getOntologiesUpdated() {
        return ontologiesUpdated;
    }

    public void setOntologiesUpdated(Set<String> ontologiesUpdated) {
        this.ontologiesUpdated = ontologiesUpdated;
    }

    public Map<String, String> getErrors() {
        return errors;
    }

    public void setErrors(Map<String, String> errors) {
        this.errors = errors;
    }

    public String getUpdateSource() {
        return updateSource;
    }

    public void setUpdateSource(String updateSource) {
        this.updateSource = updateSource;
    }

    public Long getProcessingTimeMs() {
        return processingTimeMs;
    }

    public void setProcessingTimeMs(Long processingTimeMs) {
        this.processingTimeMs = processingTimeMs;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    @Override
    public String toString() {
        return String.format("OntologyUpdateResponse{success=%s, totalTermsLoaded=%d, " +
                           "ontologiesUpdated=%s, hasErrors=%s}",
                success, totalTermsLoaded, ontologiesUpdated,
                errors != null && !errors.isEmpty());
    }
}