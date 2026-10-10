package edu.mcw.rgd.entityTagger.service;

import java.util.ArrayList;
import java.util.List;

/**
 * Result of entity recognition processing
 */
public class EntityRecognitionResult {
    
    private boolean successful;
    private String errorMessage;
    private long processingTimeMs;
    
    private List<BiologicalEntity> genes;
    private List<BiologicalEntity> diseases;
    private List<BiologicalEntity> chemicals;
    private List<BiologicalEntity> species;
    private List<BiologicalEntity> phenotypes;
    private List<BiologicalEntity> cellularComponents;
    private List<BiologicalEntity> ratStrains;

    // Store raw model responses and metadata
    private List<String> rawModelResponses;
    private String modelUsed;

    // Constructors
    public EntityRecognitionResult() {}
    
    // Getters and Setters
    public boolean isSuccessful() {
        return successful;
    }
    
    public void setSuccessful(boolean successful) {
        this.successful = successful;
    }
    
    public String getErrorMessage() {
        return errorMessage;
    }
    
    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }
    
    public long getProcessingTimeMs() {
        return processingTimeMs;
    }
    
    public void setProcessingTimeMs(long processingTimeMs) {
        this.processingTimeMs = processingTimeMs;
    }
    
    public List<BiologicalEntity> getGenes() {
        return genes;
    }
    
    public void setGenes(List<BiologicalEntity> genes) {
        this.genes = genes;
    }
    
    public List<BiologicalEntity> getDiseases() {
        return diseases;
    }
    
    public void setDiseases(List<BiologicalEntity> diseases) {
        this.diseases = diseases;
    }
    
    public List<BiologicalEntity> getChemicals() {
        return chemicals;
    }
    
    public void setChemicals(List<BiologicalEntity> chemicals) {
        this.chemicals = chemicals;
    }
    
    public List<BiologicalEntity> getSpecies() {
        return species;
    }
    
    public void setSpecies(List<BiologicalEntity> species) {
        this.species = species;
    }
    
    public List<BiologicalEntity> getPhenotypes() {
        return phenotypes;
    }
    
    public void setPhenotypes(List<BiologicalEntity> phenotypes) {
        this.phenotypes = phenotypes;
    }
    
    public List<BiologicalEntity> getCellularComponents() {
        return cellularComponents;
    }
    
    public void setCellularComponents(List<BiologicalEntity> cellularComponents) {
        this.cellularComponents = cellularComponents;
    }
    
    public List<BiologicalEntity> getRatStrains() {
        return ratStrains;
    }
    
    public void setRatStrains(List<BiologicalEntity> ratStrains) {
        this.ratStrains = ratStrains;
    }

    public List<String> getRawModelResponses() {
        return rawModelResponses;
    }

    public void setRawModelResponses(List<String> rawModelResponses) {
        this.rawModelResponses = rawModelResponses;
    }

    public String getModelUsed() {
        return modelUsed;
    }

    public void setModelUsed(String modelUsed) {
        this.modelUsed = modelUsed;
    }

    /**
     * Get total number of entities found
     */
    public int getTotalEntities() {
        int total = 0;
        if (genes != null) total += genes.size();
        if (diseases != null) total += diseases.size();
        if (chemicals != null) total += chemicals.size();
        if (species != null) total += species.size();
        if (phenotypes != null) total += phenotypes.size();
        if (cellularComponents != null) total += cellularComponents.size();
        if (ratStrains != null) total += ratStrains.size();
        return total;
    }
    
    @Override
    public String toString() {
        return "EntityRecognitionResult{" +
                "successful=" + successful +
                ", errorMessage='" + errorMessage + '\'' +
                ", processingTimeMs=" + processingTimeMs +
                ", totalEntities=" + getTotalEntities() +
                '}';
    }
}