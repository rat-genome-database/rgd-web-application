package edu.mcw.rgd.entityTagger.model;

/**
 * Statistics model for batch operations
 */
public class BatchStatistics {
    private long totalBatches;
    private long completedBatches;
    private long failedBatches;
    private long averageProcessingTime;
    private int totalEntitiesFound;
    private int totalOntologyMatches;
    private double averageConfidence;
    private java.util.Map<String, Integer> entityTypeCounts;
    
    // Constructors
    public BatchStatistics() {
        this.entityTypeCounts = new java.util.HashMap<>();
    }
    
    // Getters and setters
    public long getTotalBatches() { return totalBatches; }
    public void setTotalBatches(long totalBatches) { this.totalBatches = totalBatches; }
    
    public long getCompletedBatches() { return completedBatches; }
    public void setCompletedBatches(long completedBatches) { this.completedBatches = completedBatches; }
    
    public long getFailedBatches() { return failedBatches; }
    public void setFailedBatches(long failedBatches) { this.failedBatches = failedBatches; }
    
    public long getAverageProcessingTime() { return averageProcessingTime; }
    public void setAverageProcessingTime(long averageProcessingTime) { this.averageProcessingTime = averageProcessingTime; }
    
    public int getTotalEntitiesFound() { return totalEntitiesFound; }
    public void setTotalEntitiesFound(int totalEntitiesFound) { this.totalEntitiesFound = totalEntitiesFound; }
    
    public int getTotalOntologyMatches() { return totalOntologyMatches; }
    public void setTotalOntologyMatches(int totalOntologyMatches) { this.totalOntologyMatches = totalOntologyMatches; }
    
    public double getAverageConfidence() { return averageConfidence; }
    public void setAverageConfidence(double averageConfidence) { this.averageConfidence = averageConfidence; }
    
    public java.util.Map<String, Integer> getEntityTypeCounts() { return entityTypeCounts; }
    public void setEntityTypeCounts(java.util.Map<String, Integer> entityTypeCounts) { this.entityTypeCounts = entityTypeCounts; }
}