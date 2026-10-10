package edu.mcw.rgd.entityTagger.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.util.List;

/**
 * DTO representing a recognized entity with optional ontology matches.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class RecognizedEntityDto {

    private String entityName;
    private String entityType;
    private Double confidenceScore;
    
    private Integer startPosition;
    private Integer endPosition;
    private String context;
    
    private String normalizedName;
    private List<String> synonyms;
    
    private List<OntologyMatchDto> ontologyMatches;
    private String bestMatchTermId;
    private Double bestMatchConfidence;
    
    private String sourceMethod;
    private String validationStatus;

    /**
     * Default constructor
     */
    public RecognizedEntityDto() {
    }

    /**
     * Constructor with required fields
     */
    public RecognizedEntityDto(String entityName, String entityType, Double confidenceScore) {
        this.entityName = entityName;
        this.entityType = entityType;
        this.confidenceScore = confidenceScore;
    }

    // Getters and Setters

    public String getEntityName() {
        return entityName;
    }

    public void setEntityName(String entityName) {
        this.entityName = entityName;
    }

    public String getEntityType() {
        return entityType;
    }

    public void setEntityType(String entityType) {
        this.entityType = entityType;
    }

    public Double getConfidenceScore() {
        return confidenceScore;
    }

    public void setConfidenceScore(Double confidenceScore) {
        this.confidenceScore = confidenceScore;
    }

    public Integer getStartPosition() {
        return startPosition;
    }

    public void setStartPosition(Integer startPosition) {
        this.startPosition = startPosition;
    }

    public Integer getEndPosition() {
        return endPosition;
    }

    public void setEndPosition(Integer endPosition) {
        this.endPosition = endPosition;
    }

    public String getContext() {
        return context;
    }

    public void setContext(String context) {
        this.context = context;
    }

    public String getNormalizedName() {
        return normalizedName;
    }

    public void setNormalizedName(String normalizedName) {
        this.normalizedName = normalizedName;
    }

    public List<String> getSynonyms() {
        return synonyms;
    }

    public void setSynonyms(List<String> synonyms) {
        this.synonyms = synonyms;
    }

    public List<OntologyMatchDto> getOntologyMatches() {
        return ontologyMatches;
    }

    public void setOntologyMatches(List<OntologyMatchDto> ontologyMatches) {
        this.ontologyMatches = ontologyMatches;
        
        // Update best match fields when setting ontology matches
        if (ontologyMatches != null && !ontologyMatches.isEmpty()) {
            OntologyMatchDto bestMatch = ontologyMatches.get(0); // Assume first is best
            this.bestMatchTermId = bestMatch.getTermId();
            this.bestMatchConfidence = bestMatch.getConfidence();
        }
    }

    public String getBestMatchTermId() {
        return bestMatchTermId;
    }

    public void setBestMatchTermId(String bestMatchTermId) {
        this.bestMatchTermId = bestMatchTermId;
    }

    public Double getBestMatchConfidence() {
        return bestMatchConfidence;
    }

    public void setBestMatchConfidence(Double bestMatchConfidence) {
        this.bestMatchConfidence = bestMatchConfidence;
    }

    public String getSourceMethod() {
        return sourceMethod;
    }

    public void setSourceMethod(String sourceMethod) {
        this.sourceMethod = sourceMethod;
    }

    public String getValidationStatus() {
        return validationStatus;
    }

    public void setValidationStatus(String validationStatus) {
        this.validationStatus = validationStatus;
    }

    /**
     * Check if this entity has ontology matches
     */
    public boolean hasOntologyMatches() {
        return ontologyMatches != null && !ontologyMatches.isEmpty();
    }

    /**
     * Get the number of ontology matches
     */
    public int getOntologyMatchCount() {
        return ontologyMatches != null ? ontologyMatches.size() : 0;
    }

    /**
     * Check if entity has position information
     */
    public boolean hasPosition() {
        return startPosition != null && endPosition != null && 
               startPosition >= 0 && endPosition > startPosition;
    }

    @Override
    public String toString() {
        return String.format("RecognizedEntityDto{entityName='%s', entityType='%s', " +
                           "confidenceScore=%.2f, ontologyMatches=%d, position=[%d,%d]}",
                entityName, entityType, confidenceScore, getOntologyMatchCount(), 
                startPosition, endPosition);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        
        RecognizedEntityDto that = (RecognizedEntityDto) o;
        
        if (entityName != null ? !entityName.equals(that.entityName) : that.entityName != null) return false;
        if (entityType != null ? !entityType.equals(that.entityType) : that.entityType != null) return false;
        if (startPosition != null ? !startPosition.equals(that.startPosition) : that.startPosition != null) return false;
        return endPosition != null ? endPosition.equals(that.endPosition) : that.endPosition == null;
    }

    @Override
    public int hashCode() {
        int result = entityName != null ? entityName.hashCode() : 0;
        result = 31 * result + (entityType != null ? entityType.hashCode() : 0);
        result = 31 * result + (startPosition != null ? startPosition.hashCode() : 0);
        result = 31 * result + (endPosition != null ? endPosition.hashCode() : 0);
        return result;
    }
}