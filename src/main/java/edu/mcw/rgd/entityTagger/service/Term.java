package edu.mcw.rgd.entityTagger.service;

import java.util.List;

/**
 * Represents an ontology term
 */
public class Term {
    private String termId;
    private String name;
    private String namespace;
    private String definition;
    private List<String> synonyms;
    private boolean obsolete;
    
    public Term() {}
    
    public Term(String termId, String name, String namespace, String definition) {
        this.termId = termId;
        this.name = name;
        this.namespace = namespace;
        this.definition = definition;
    }
    
    public String getTermId() { return termId; }
    public void setTermId(String termId) { this.termId = termId; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getNamespace() { return namespace; }
    public void setNamespace(String namespace) { this.namespace = namespace; }
    
    public String getDefinition() { return definition; }
    public void setDefinition(String definition) { this.definition = definition; }
    
    public List<String> getSynonyms() { return synonyms; }
    public void setSynonyms(List<String> synonyms) { this.synonyms = synonyms; }
    
    public boolean isObsolete() { return obsolete; }
    public void setObsolete(boolean obsolete) { this.obsolete = obsolete; }
}