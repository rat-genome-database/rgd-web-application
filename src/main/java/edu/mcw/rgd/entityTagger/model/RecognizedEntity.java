package edu.mcw.rgd.entityTagger.model;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDateTime;
import java.util.Objects;

/**
 * Entity representing a recognized entity from text analysis stored in the database.
 * This entity tracks individual entities found during the curation process.
 */
public class RecognizedEntity {
    
    private Long entityId;
    private Long sessionId;
    private String textId;
    private String entityName;
    private String entityType;
    private String normalizedName;
    private Double confidenceScore;
    private Integer startPosition;
    private Integer endPosition;
    private String context;
    private String sourceText;
    private String ontologyTermId;
    private String ontologyNamespace;
    private Boolean isValidated;
    private String validatedBy;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime recognizedDate;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime validatedDate;
    
    private String notes;
    private String metadata;

    public RecognizedEntity() {
        this.recognizedDate = LocalDateTime.now();
        this.isValidated = false;
    }

    public RecognizedEntity(String entityName, String entityType, Double confidenceScore) {
        this();
        this.entityName = entityName;
        this.entityType = entityType;
        this.confidenceScore = confidenceScore;
    }

    // Getters and Setters

    public Long getEntityId() {
        return entityId;
    }

    public void setEntityId(Long entityId) {
        this.entityId = entityId;
    }

    public Long getSessionId() {
        return sessionId;
    }

    public void setSessionId(Long sessionId) {
        this.sessionId = sessionId;
    }

    public String getTextId() {
        return textId;
    }

    public void setTextId(String textId) {
        this.textId = textId;
    }

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

    public String getNormalizedName() {
        return normalizedName;
    }

    public void setNormalizedName(String normalizedName) {
        this.normalizedName = normalizedName;
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

    public String getSourceText() {
        return sourceText;
    }

    public void setSourceText(String sourceText) {
        this.sourceText = sourceText;
    }

    public String getOntologyTermId() {
        return ontologyTermId;
    }

    public void setOntologyTermId(String ontologyTermId) {
        this.ontologyTermId = ontologyTermId;
    }

    public String getOntologyNamespace() {
        return ontologyNamespace;
    }

    public void setOntologyNamespace(String ontologyNamespace) {
        this.ontologyNamespace = ontologyNamespace;
    }

    public Boolean getIsValidated() {
        return isValidated;
    }

    public void setIsValidated(Boolean isValidated) {
        this.isValidated = isValidated;
    }

    public String getValidatedBy() {
        return validatedBy;
    }

    public void setValidatedBy(String validatedBy) {
        this.validatedBy = validatedBy;
    }

    public LocalDateTime getRecognizedDate() {
        return recognizedDate;
    }

    public void setRecognizedDate(LocalDateTime recognizedDate) {
        this.recognizedDate = recognizedDate;
    }

    public LocalDateTime getValidatedDate() {
        return validatedDate;
    }

    public void setValidatedDate(LocalDateTime validatedDate) {
        this.validatedDate = validatedDate;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getMetadata() {
        return metadata;
    }

    public void setMetadata(String metadata) {
        this.metadata = metadata;
    }

    // Utility methods

    /**
     * Mark this entity as validated by a user.
     * 
     * @param validatorId The ID of the user who validated this entity
     */
    public void validate(String validatorId) {
        this.isValidated = true;
        this.validatedBy = validatorId;
        this.validatedDate = LocalDateTime.now();
    }

    /**
     * Set the position information for this entity in the source text.
     * 
     * @param startPos Start position in the text
     * @param endPos End position in the text
     */
    public void setPosition(int startPos, int endPos) {
        this.startPosition = startPos;
        this.endPosition = endPos;
    }

    /**
     * Set ontology mapping information.
     * 
     * @param termId The ontology term ID
     * @param namespace The ontology namespace
     */
    public void setOntologyMapping(String termId, String namespace) {
        this.ontologyTermId = termId;
        this.ontologyNamespace = namespace;
    }

    /**
     * Check if this entity has a high confidence score.
     * 
     * @return true if confidence is >= 0.8, false otherwise
     */
    public boolean isHighConfidence() {
        return confidenceScore != null && confidenceScore >= 0.8;
    }

    /**
     * Check if this entity has been mapped to an ontology.
     * 
     * @return true if ontology mapping exists, false otherwise
     */
    public boolean hasOntologyMapping() {
        return ontologyTermId != null && !ontologyTermId.trim().isEmpty();
    }

    /**
     * Get the length of the recognized entity text.
     * 
     * @return The length in characters, or 0 if positions are not set
     */
    public int getEntityLength() {
        if (startPosition != null && endPosition != null) {
            return endPosition - startPosition;
        }
        return entityName != null ? entityName.length() : 0;
    }
    
    // Additional methods used by CurationTransactionService
    public void setBatchId(String batchId) {
        this.textId = batchId; // Use textId field for batchId
    }
    
    public String getBatchId() {
        return this.textId; // Use textId field for batchId
    }
    
    public String getEntityText() {
        return this.entityName; // entityText is same as entityName
    }
    
    public void setEntityText(String entityText) {
        this.entityName = entityText; // entityText is same as entityName
    }
    
    public String getValidationStatus() {
        return this.isValidated != null && this.isValidated ? "VALIDATED" : "PENDING";
    }
    
    public void setValidationStatus(String status) {
        this.isValidated = "VALIDATED".equals(status);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        RecognizedEntity that = (RecognizedEntity) o;
        return Objects.equals(entityId, that.entityId) &&
               Objects.equals(entityName, that.entityName) &&
               Objects.equals(entityType, that.entityType) &&
               Objects.equals(startPosition, that.startPosition) &&
               Objects.equals(endPosition, that.endPosition);
    }

    @Override
    public int hashCode() {
        return Objects.hash(entityId, entityName, entityType, startPosition, endPosition);
    }

    @Override
    public String toString() {
        return "RecognizedEntity{" +
                "entityId=" + entityId +
                ", entityName='" + entityName + '\'' +
                ", entityType='" + entityType + '\'' +
                ", confidenceScore=" + confidenceScore +
                ", startPosition=" + startPosition +
                ", endPosition=" + endPosition +
                ", isValidated=" + isValidated +
                '}';
    }
}