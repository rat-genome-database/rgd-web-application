package edu.mcw.rgd.entityTagger.model;

/**
 * Request model for entity recognition
 */
public class EntityRecognitionRequest {
    private String text;
    private String entityTypes;
    private Double confidenceThreshold;
    private String domain;
    private String sessionId;
    
    // Constructors
    public EntityRecognitionRequest() {}
    
    public EntityRecognitionRequest(String text) {
        this.text = text;
    }
    
    // Getters and setters
    public String getText() { return text; }
    public void setText(String text) { this.text = text; }
    
    public String getEntityTypes() { return entityTypes; }
    public void setEntityTypes(String entityTypes) { this.entityTypes = entityTypes; }
    
    public Double getConfidenceThreshold() { return confidenceThreshold; }
    public void setConfidenceThreshold(Double confidenceThreshold) { this.confidenceThreshold = confidenceThreshold; }
    
    public String getDomain() { return domain; }
    public void setDomain(String domain) { this.domain = domain; }
    
    public String getSessionId() { return sessionId; }
    public void setSessionId(String sessionId) { this.sessionId = sessionId; }
}