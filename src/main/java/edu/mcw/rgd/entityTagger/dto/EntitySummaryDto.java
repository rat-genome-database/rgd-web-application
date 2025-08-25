package edu.mcw.rgd.entityTagger.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.util.Map;

/**
 * DTO containing summary statistics for entity recognition results.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class EntitySummaryDto {

    private Integer totalEntities;
    private Integer processedTextLength;
    private Double averageConfidence;
    private Map<String, Integer> entityTypeCounts;
    private Integer ontologyMatchCount;
    private Integer highConfidenceMatches;
    private Integer exactMatches;
    private Double ontologyMatchRate;
    private String dominantEntityType;
    private String confidenceDistribution;

    /**
     * Default constructor
     */
    public EntitySummaryDto() {
    }

    // Getters and Setters

    public Integer getTotalEntities() {
        return totalEntities;
    }

    public void setTotalEntities(Integer totalEntities) {
        this.totalEntities = totalEntities;
    }

    public Integer getProcessedTextLength() {
        return processedTextLength;
    }

    public void setProcessedTextLength(Integer processedTextLength) {
        this.processedTextLength = processedTextLength;
    }

    public Double getAverageConfidence() {
        return averageConfidence;
    }

    public void setAverageConfidence(Double averageConfidence) {
        this.averageConfidence = averageConfidence;
    }

    public Map<String, Integer> getEntityTypeCounts() {
        return entityTypeCounts;
    }

    public void setEntityTypeCounts(Map<String, Integer> entityTypeCounts) {
        this.entityTypeCounts = entityTypeCounts;
    }

    public Integer getOntologyMatchCount() {
        return ontologyMatchCount;
    }

    public void setOntologyMatchCount(Integer ontologyMatchCount) {
        this.ontologyMatchCount = ontologyMatchCount;
    }

    public Integer getHighConfidenceMatches() {
        return highConfidenceMatches;
    }

    public void setHighConfidenceMatches(Integer highConfidenceMatches) {
        this.highConfidenceMatches = highConfidenceMatches;
    }

    public Integer getExactMatches() {
        return exactMatches;
    }

    public void setExactMatches(Integer exactMatches) {
        this.exactMatches = exactMatches;
    }

    public Double getOntologyMatchRate() {
        return ontologyMatchRate;
    }

    public void setOntologyMatchRate(Double ontologyMatchRate) {
        this.ontologyMatchRate = ontologyMatchRate;
    }

    public String getDominantEntityType() {
        return dominantEntityType;
    }

    public void setDominantEntityType(String dominantEntityType) {
        this.dominantEntityType = dominantEntityType;
    }

    public String getConfidenceDistribution() {
        return confidenceDistribution;
    }

    public void setConfidenceDistribution(String confidenceDistribution) {
        this.confidenceDistribution = confidenceDistribution;
    }

    @Override
    public String toString() {
        return String.format("EntitySummaryDto{totalEntities=%d, averageConfidence=%.2f, " +
                           "ontologyMatchCount=%d, dominantEntityType='%s'}",
                totalEntities, averageConfidence, ontologyMatchCount, dominantEntityType);
    }
}