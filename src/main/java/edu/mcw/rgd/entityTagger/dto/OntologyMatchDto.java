package edu.mcw.rgd.entityTagger.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.util.List;

/**
 * DTO representing a match between an entity and an ontology term.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class OntologyMatchDto {

    private String termId;
    private String termName;
    private String namespace;
    private String definition;
    
    private String matchType;
    private Double confidence;
    private String explanation;
    
    private List<String> synonyms;
    private List<String> parentTerms;
    private List<String> childTerms;
    
    private boolean obsolete;
    private String replacedBy;
    private List<String> consider;
    
    private String ontologySource;
    private String termUrl;

    /**
     * Default constructor
     */
    public OntologyMatchDto() {
    }

    /**
     * Constructor with required fields
     */
    public OntologyMatchDto(String termId, String termName, String matchType, Double confidence) {
        this.termId = termId;
        this.termName = termName;
        this.matchType = matchType;
        this.confidence = confidence;
    }

    // Getters and Setters

    public String getTermId() {
        return termId;
    }

    public void setTermId(String termId) {
        this.termId = termId;
    }

    public String getTermName() {
        return termName;
    }

    public void setTermName(String termName) {
        this.termName = termName;
    }

    public String getNamespace() {
        return namespace;
    }

    public void setNamespace(String namespace) {
        this.namespace = namespace;
    }

    public String getDefinition() {
        return definition;
    }

    public void setDefinition(String definition) {
        this.definition = definition;
    }

    public String getMatchType() {
        return matchType;
    }

    public void setMatchType(String matchType) {
        this.matchType = matchType;
    }

    public Double getConfidence() {
        return confidence;
    }

    public void setConfidence(Double confidence) {
        this.confidence = confidence;
    }

    public String getExplanation() {
        return explanation;
    }

    public void setExplanation(String explanation) {
        this.explanation = explanation;
    }

    public List<String> getSynonyms() {
        return synonyms;
    }

    public void setSynonyms(List<String> synonyms) {
        this.synonyms = synonyms;
    }

    public List<String> getParentTerms() {
        return parentTerms;
    }

    public void setParentTerms(List<String> parentTerms) {
        this.parentTerms = parentTerms;
    }

    public List<String> getChildTerms() {
        return childTerms;
    }

    public void setChildTerms(List<String> childTerms) {
        this.childTerms = childTerms;
    }

    public boolean isObsolete() {
        return obsolete;
    }

    public void setObsolete(boolean obsolete) {
        this.obsolete = obsolete;
    }

    public String getReplacedBy() {
        return replacedBy;
    }

    public void setReplacedBy(String replacedBy) {
        this.replacedBy = replacedBy;
    }

    public List<String> getConsider() {
        return consider;
    }

    public void setConsider(List<String> consider) {
        this.consider = consider;
    }

    public String getOntologySource() {
        return ontologySource;
    }

    public void setOntologySource(String ontologySource) {
        this.ontologySource = ontologySource;
    }

    public String getTermUrl() {
        return termUrl;
    }

    public void setTermUrl(String termUrl) {
        this.termUrl = termUrl;
    }

    /**
     * Check if this is a high-confidence match
     */
    public boolean isHighConfidence() {
        return confidence != null && confidence >= 0.8;
    }

    /**
     * Check if this is an exact match
     */
    public boolean isExactMatch() {
        return "EXACT".equals(matchType);
    }

    /**
     * Get a display string for the match quality
     */
    public String getMatchQuality() {
        if (confidence == null) {
            return "Unknown";
        }
        if (confidence >= 0.9) {
            return "Excellent";
        } else if (confidence >= 0.8) {
            return "Good";
        } else if (confidence >= 0.6) {
            return "Fair";
        } else {
            return "Poor";
        }
    }

    @Override
    public String toString() {
        return String.format("OntologyMatchDto{termId='%s', termName='%s', matchType='%s', " +
                           "confidence=%.2f, namespace='%s', obsolete=%s}",
                termId, termName, matchType, confidence, namespace, obsolete);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        
        OntologyMatchDto that = (OntologyMatchDto) o;
        
        return termId != null ? termId.equals(that.termId) : that.termId == null;
    }

    @Override
    public int hashCode() {
        return termId != null ? termId.hashCode() : 0;
    }
}