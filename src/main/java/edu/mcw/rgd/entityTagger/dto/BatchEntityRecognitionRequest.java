package edu.mcw.rgd.entityTagger.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import java.util.List;

/**
 * DTO for batch entity recognition requests.
 * Allows processing multiple texts in a single API call.
 */
public class BatchEntityRecognitionRequest {

    @NotEmpty(message = "Text list cannot be empty")
    @Size(max = 100, message = "Cannot process more than 100 texts in a single batch")
    private List<@Size(max = 100000, message = "Each text cannot exceed 100,000 characters") String> texts;

    @Size(max = 200, message = "Entity types string cannot exceed 200 characters")
    private String entityTypes;

    @Size(max = 100, message = "Domain cannot exceed 100 characters")
    private String domain;

    @DecimalMin(value = "0.0", message = "Confidence threshold must be between 0.0 and 1.0")
    @DecimalMax(value = "1.0", message = "Confidence threshold must be between 0.0 and 1.0")
    private Double confidenceThreshold;

    @Size(max = 100, message = "Session ID cannot exceed 100 characters")
    private String sessionId;

    private boolean enableOntologyMatching = true;

    @Size(max = 50, message = "Namespace cannot exceed 50 characters")
    private String ontologyNamespace;

    @DecimalMin(value = "0.0", message = "Fuzzy threshold must be between 0.0 and 1.0")
    @DecimalMax(value = "1.0", message = "Fuzzy threshold must be between 0.0 and 1.0")
    private Double fuzzyMatchThreshold;

    private Integer maxOntologyMatches;

    private boolean includeObsoleteTerms = false;

    private boolean parallelProcessing = true;

    private Integer maxConcurrentRequests;

    /**
     * Default constructor
     */
    public BatchEntityRecognitionRequest() {
        this.confidenceThreshold = 0.5;
        this.fuzzyMatchThreshold = 0.8;
        this.maxOntologyMatches = 5;
        this.maxConcurrentRequests = 5;
    }

    // Getters and Setters

    public List<String> getTexts() {
        return texts;
    }

    public void setTexts(List<String> texts) {
        this.texts = texts;
    }

    public String getEntityTypes() {
        return entityTypes;
    }

    public void setEntityTypes(String entityTypes) {
        this.entityTypes = entityTypes;
    }

    public String getDomain() {
        return domain;
    }

    public void setDomain(String domain) {
        this.domain = domain;
    }

    public Double getConfidenceThreshold() {
        return confidenceThreshold;
    }

    public void setConfidenceThreshold(Double confidenceThreshold) {
        this.confidenceThreshold = confidenceThreshold;
    }

    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }

    public boolean isEnableOntologyMatching() {
        return enableOntologyMatching;
    }

    public void setEnableOntologyMatching(boolean enableOntologyMatching) {
        this.enableOntologyMatching = enableOntologyMatching;
    }

    public String getOntologyNamespace() {
        return ontologyNamespace;
    }

    public void setOntologyNamespace(String ontologyNamespace) {
        this.ontologyNamespace = ontologyNamespace;
    }

    public Double getFuzzyMatchThreshold() {
        return fuzzyMatchThreshold;
    }

    public void setFuzzyMatchThreshold(Double fuzzyMatchThreshold) {
        this.fuzzyMatchThreshold = fuzzyMatchThreshold;
    }

    public Integer getMaxOntologyMatches() {
        return maxOntologyMatches;
    }

    public void setMaxOntologyMatches(Integer maxOntologyMatches) {
        this.maxOntologyMatches = maxOntologyMatches;
    }

    public boolean isIncludeObsoleteTerms() {
        return includeObsoleteTerms;
    }

    public void setIncludeObsoleteTerms(boolean includeObsoleteTerms) {
        this.includeObsoleteTerms = includeObsoleteTerms;
    }

    public boolean isParallelProcessing() {
        return parallelProcessing;
    }

    public void setParallelProcessing(boolean parallelProcessing) {
        this.parallelProcessing = parallelProcessing;
    }

    public Integer getMaxConcurrentRequests() {
        return maxConcurrentRequests;
    }

    public void setMaxConcurrentRequests(Integer maxConcurrentRequests) {
        this.maxConcurrentRequests = maxConcurrentRequests;
    }

    /**
     * Get the total length of all texts
     */
    public int getTotalTextLength() {
        if (texts == null) {
            return 0;
        }
        return texts.stream().mapToInt(String::length).sum();
    }

    /**
     * Check if the request is valid for processing
     */
    public boolean isValid() {
        return texts != null && !texts.isEmpty() && 
               texts.stream().allMatch(text -> text != null && !text.trim().isEmpty());
    }

    @Override
    public String toString() {
        return String.format("BatchEntityRecognitionRequest{textCount=%d, totalLength=%d, " +
                           "entityTypes='%s', domain='%s', enableOntologyMatching=%s, sessionId='%s'}",
                texts != null ? texts.size() : 0, getTotalTextLength(), 
                entityTypes, domain, enableOntologyMatching, sessionId);
    }
}