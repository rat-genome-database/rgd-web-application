package edu.mcw.rgd.entityTagger.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import java.util.List;

/**
 * DTO for ontology matching requests.
 * Allows matching specific entity names to ontology terms.
 */
public class OntologyMatchingRequest {

    @NotEmpty(message = "Entity names list cannot be empty")
    @Size(max = 100, message = "Cannot match more than 100 entities in a single request")
    private List<@Size(max = 200, message = "Entity name cannot exceed 200 characters") String> entityNames;

    @Size(max = 50, message = "Namespace cannot exceed 50 characters")
    private String namespace;

    @Size(max = 100, message = "Session ID cannot exceed 100 characters")
    private String sessionId;

    @DecimalMin(value = "0.0", message = "Fuzzy threshold must be between 0.0 and 1.0")
    @DecimalMax(value = "1.0", message = "Fuzzy threshold must be between 0.0 and 1.0")
    private Double fuzzyThreshold;

    @DecimalMin(value = "0.0", message = "Minimum confidence must be between 0.0 and 1.0")
    @DecimalMax(value = "1.0", message = "Minimum confidence must be between 0.0 and 1.0")
    private Double minimumConfidence;

    private Integer maxResults;

    private boolean enableExactMatch = true;
    private boolean enableFuzzyMatch = true;
    private boolean enableSynonymMatch = true;
    private boolean enablePartialMatch = true;
    private boolean enableSemanticMatch = false;

    private boolean includeObsoleteTerms = false;
    private boolean includeHierarchy = false;
    private boolean includeDefinitions = true;

    /**
     * Default constructor
     */
    public OntologyMatchingRequest() {
        this.fuzzyThreshold = 0.8;
        this.minimumConfidence = 0.5;
        this.maxResults = 10;
    }

    // Getters and Setters

    public List<String> getEntityNames() {
        return entityNames;
    }

    public void setEntityNames(List<String> entityNames) {
        this.entityNames = entityNames;
    }

    public String getNamespace() {
        return namespace;
    }

    public void setNamespace(String namespace) {
        this.namespace = namespace;
    }

    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }

    public Double getFuzzyThreshold() {
        return fuzzyThreshold;
    }

    public void setFuzzyThreshold(Double fuzzyThreshold) {
        this.fuzzyThreshold = fuzzyThreshold;
    }

    public Double getMinimumConfidence() {
        return minimumConfidence;
    }

    public void setMinimumConfidence(Double minimumConfidence) {
        this.minimumConfidence = minimumConfidence;
    }

    public Integer getMaxResults() {
        return maxResults;
    }

    public void setMaxResults(Integer maxResults) {
        this.maxResults = maxResults;
    }

    public boolean isEnableExactMatch() {
        return enableExactMatch;
    }

    public void setEnableExactMatch(boolean enableExactMatch) {
        this.enableExactMatch = enableExactMatch;
    }

    public boolean isEnableFuzzyMatch() {
        return enableFuzzyMatch;
    }

    public void setEnableFuzzyMatch(boolean enableFuzzyMatch) {
        this.enableFuzzyMatch = enableFuzzyMatch;
    }

    public boolean isEnableSynonymMatch() {
        return enableSynonymMatch;
    }

    public void setEnableSynonymMatch(boolean enableSynonymMatch) {
        this.enableSynonymMatch = enableSynonymMatch;
    }

    public boolean isEnablePartialMatch() {
        return enablePartialMatch;
    }

    public void setEnablePartialMatch(boolean enablePartialMatch) {
        this.enablePartialMatch = enablePartialMatch;
    }

    public boolean isEnableSemanticMatch() {
        return enableSemanticMatch;
    }

    public void setEnableSemanticMatch(boolean enableSemanticMatch) {
        this.enableSemanticMatch = enableSemanticMatch;
    }

    public boolean isIncludeObsoleteTerms() {
        return includeObsoleteTerms;
    }

    public void setIncludeObsoleteTerms(boolean includeObsoleteTerms) {
        this.includeObsoleteTerms = includeObsoleteTerms;
    }

    public boolean isIncludeHierarchy() {
        return includeHierarchy;
    }

    public void setIncludeHierarchy(boolean includeHierarchy) {
        this.includeHierarchy = includeHierarchy;
    }

    public boolean isIncludeDefinitions() {
        return includeDefinitions;
    }

    public void setIncludeDefinitions(boolean includeDefinitions) {
        this.includeDefinitions = includeDefinitions;
    }

    @Override
    public String toString() {
        return String.format("OntologyMatchingRequest{entityCount=%d, namespace='%s', " +
                           "fuzzyThreshold=%.2f, maxResults=%d, sessionId='%s'}",
                entityNames != null ? entityNames.size() : 0, namespace, 
                fuzzyThreshold, maxResults, sessionId);
    }
}