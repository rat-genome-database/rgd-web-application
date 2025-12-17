package edu.mcw.rgd.entityTagger.model;

import java.util.List;
import java.util.ArrayList;

/**
 * Response model for entity recognition
 */
public class EntityRecognitionResponse {
    private List<RecognizedEntity> entities;
    private String status;
    private String sessionId;
    private String requestId;
    private boolean success;
    private Long processingTimeMs;
    private Object statistics;
    private List<String> warnings;
    
    // Constructors
    public EntityRecognitionResponse() {
        this.entities = new ArrayList<>();
        this.status = "SUCCESS";
    }
    
    // Getters and setters
    public List<RecognizedEntity> getEntities() { return entities; }
    public void setEntities(List<RecognizedEntity> entities) { this.entities = entities; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getSessionId() { return sessionId; }
    public void setSessionId(String sessionId) { this.sessionId = sessionId; }
    
    public String getRequestId() { return requestId; }
    public void setRequestId(String requestId) { this.requestId = requestId; }
    
    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }
    
    public Long getProcessingTimeMs() { return processingTimeMs; }
    public void setProcessingTimeMs(Long processingTimeMs) { this.processingTimeMs = processingTimeMs; }
    
    public Object getStatistics() { return statistics; }
    public void setStatistics(Object statistics) { this.statistics = statistics; }
    
    public List<String> getWarnings() { return warnings; }
    public void setWarnings(List<String> warnings) { this.warnings = warnings; }
    
    /**
     * Inner class representing a recognized entity with metadata
     */
    public static class RecognizedEntity {
        private String text;
        private String type;
        private String entityType;
        private String ontologyId;
        private double confidence;
        private double confidenceScore;
        private int startPosition;
        private int endPosition;
        private String context;
        private String normalizedName;
        private List<String> synonyms;
        
        public RecognizedEntity() {}
        
        public RecognizedEntity(String text, String type, String ontologyId, double confidence, int startPosition, int endPosition) {
            this.text = text;
            this.type = type;
            this.ontologyId = ontologyId;
            this.confidence = confidence;
            this.startPosition = startPosition;
            this.endPosition = endPosition;
        }
        
        public String getText() { return text; }
        public void setText(String text) { this.text = text; }
        
        public String getEntityName() { return text; }
        public void setEntityName(String entityName) { this.text = entityName; }
        
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        
        public String getEntityType() { return entityType != null ? entityType : type; }
        public void setEntityType(String entityType) { this.entityType = entityType; }
        
        public String getOntologyId() { return ontologyId; }
        public void setOntologyId(String ontologyId) { this.ontologyId = ontologyId; }
        
        public double getConfidence() { return confidence; }
        public void setConfidence(double confidence) { this.confidence = confidence; }
        
        public int getStartPosition() { return startPosition; }
        public void setStartPosition(int startPosition) { this.startPosition = startPosition; }
        
        public int getEndPosition() { return endPosition; }
        public void setEndPosition(int endPosition) { this.endPosition = endPosition; }
        
        public double getConfidenceScore() { return confidenceScore != 0 ? confidenceScore : confidence; }
        public void setConfidenceScore(double confidenceScore) { this.confidenceScore = confidenceScore; }
        
        public String getContext() { return context; }
        public void setContext(String context) { this.context = context; }
        
        public String getNormalizedName() { return normalizedName; }
        public void setNormalizedName(String normalizedName) { this.normalizedName = normalizedName; }
        
        public List<String> getSynonyms() { return synonyms; }
        public void setSynonyms(List<String> synonyms) { this.synonyms = synonyms; }
    }
}