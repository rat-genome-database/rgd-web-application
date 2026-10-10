package edu.mcw.rgd.entityTagger.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import java.util.List;

/**
 * API request DTO for entity recognition operations.
 * Defines the input parameters for text analysis and entity extraction.
 */
@Schema(description = "Request for biological entity recognition and ontology matching")
public class EntityRecognitionApiRequest {

    @Schema(description = "Text to analyze for biological entities", 
            example = "The patient showed symptoms of diabetes mellitus and hypertension. Treatment included metformin and ACE inhibitors.",
            required = true,
            maxLength = 100000)
    @NotBlank(message = "Text cannot be empty")
    @Size(max = 100000, message = "Text cannot exceed 100,000 characters")
    private String text;

    @Schema(description = "Comma-separated list of entity types to focus on", 
            example = "disease,drug,gene",
            allowableValues = {"gene", "protein", "disease", "phenotype", "pathway", "drug", "chemical", "organism", "tissue", "cell_type", "anatomy", "strain", "allele"})
    @Size(max = 200, message = "Entity types string cannot exceed 200 characters")
    private String entityTypes;

    @Schema(description = "Scientific domain for context-aware analysis", 
            example = "cardiology",
            allowableValues = {"general", "cardiology", "oncology", "neurology", "immunology", "genetics"})
    @Size(max = 100, message = "Domain cannot exceed 100 characters")
    private String domain;

    @Schema(description = "Minimum confidence score for entity recognition (0.0 to 1.0)", 
            example = "0.7",
            minimum = "0.0", 
            maximum = "1.0",
            defaultValue = "0.5")
    @DecimalMin(value = "0.0", message = "Confidence threshold must be between 0.0 and 1.0")
    @DecimalMax(value = "1.0", message = "Confidence threshold must be between 0.0 and 1.0")
    private Double confidenceThreshold;

    @Schema(description = "Unique session identifier for tracking", 
            example = "session_20240115_001")
    @Size(max = 100, message = "Session ID cannot exceed 100 characters")
    private String sessionId;

    @Schema(description = "Whether to match entities to ontology terms", 
            example = "true",
            defaultValue = "true")
    private boolean enableOntologyMatching = true;

    @Size(max = 50, message = "Namespace cannot exceed 50 characters")
    private String ontologyNamespace;

    private List<String> preferredOntologies;

    @DecimalMin(value = "0.0", message = "Fuzzy threshold must be between 0.0 and 1.0")
    @DecimalMax(value = "1.0", message = "Fuzzy threshold must be between 0.0 and 1.0")
    private Double fuzzyMatchThreshold;

    private Integer maxOntologyMatches;

    private boolean includeObsoleteTerms = false;

    private boolean enableDeepAnalysis = false;

    /**
     * Default constructor
     */
    public EntityRecognitionApiRequest() {
        this.confidenceThreshold = 0.5;
        this.fuzzyMatchThreshold = 0.8;
        this.maxOntologyMatches = 5;
    }

    // Getters and Setters

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
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

    public List<String> getPreferredOntologies() {
        return preferredOntologies;
    }

    public void setPreferredOntologies(List<String> preferredOntologies) {
        this.preferredOntologies = preferredOntologies;
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

    public boolean isEnableDeepAnalysis() {
        return enableDeepAnalysis;
    }

    public void setEnableDeepAnalysis(boolean enableDeepAnalysis) {
        this.enableDeepAnalysis = enableDeepAnalysis;
    }

    @Override
    public String toString() {
        return String.format("EntityRecognitionApiRequest{textLength=%d, entityTypes='%s', domain='%s', " +
                           "confidenceThreshold=%.2f, enableOntologyMatching=%s, sessionId='%s'}",
                text != null ? text.length() : 0, entityTypes, domain, 
                confidenceThreshold, enableOntologyMatching, sessionId);
    }
}