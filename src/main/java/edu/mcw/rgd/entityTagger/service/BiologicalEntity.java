package edu.mcw.rgd.entityTagger.service;

/**
 * Represents a biological entity identified in text
 */
public class BiologicalEntity {
    
    private String name;
    private String description;
    private double confidence;
    private String type; // gene, disease, chemical, species, phenotype
    private String context; // surrounding text context
    private String accessionId; // ontology accession ID (e.g., RS:0000015, DOID:9351)
    
    // Constructors
    public BiologicalEntity() {}
    
    public BiologicalEntity(String name, String description, double confidence) {
        this.name = name;
        this.description = description;
        this.confidence = confidence;
    }
    
    public BiologicalEntity(String name, String description, double confidence, String type) {
        this.name = name;
        this.description = description;
        this.confidence = confidence;
        this.type = type;
    }
    
    // Getters and Setters
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public double getConfidence() {
        return confidence;
    }
    
    public void setConfidence(double confidence) {
        this.confidence = confidence;
    }
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
    }
    
    public String getContext() {
        return context;
    }
    
    public void setContext(String context) {
        this.context = context;
    }
    
    public String getAccessionId() {
        return accessionId;
    }
    
    public void setAccessionId(String accessionId) {
        this.accessionId = accessionId;
    }
    
    /**
     * Get confidence as percentage string
     */
    public String getConfidencePercentage() {
        return String.format("%.1f%%", confidence * 100);
    }
    
    /**
     * Check if confidence is above threshold
     */
    public boolean isHighConfidence() {
        return confidence >= 0.8;
    }
    
    public boolean isMediumConfidence() {
        return confidence >= 0.6 && confidence < 0.8;
    }
    
    public boolean isLowConfidence() {
        return confidence < 0.6;
    }
    
    /**
     * Get CSS class based on confidence level
     */
    public String getConfidenceClass() {
        if (isHighConfidence()) {
            return "confidence-high";
        } else if (isMediumConfidence()) {
            return "confidence-medium";
        } else {
            return "confidence-low";
        }
    }
    
    @Override
    public String toString() {
        return "BiologicalEntity{" +
                "name='" + name + '\'' +
                ", type='" + type + '\'' +
                ", confidence=" + confidence +
                ", description='" + description + '\'' +
                '}';
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        
        BiologicalEntity that = (BiologicalEntity) o;
        
        if (name != null ? !name.equals(that.name) : that.name != null) return false;
        return type != null ? type.equals(that.type) : that.type == null;
    }
    
    @Override
    public int hashCode() {
        int result = name != null ? name.hashCode() : 0;
        result = 31 * result + (type != null ? type.hashCode() : 0);
        return result;
    }
}