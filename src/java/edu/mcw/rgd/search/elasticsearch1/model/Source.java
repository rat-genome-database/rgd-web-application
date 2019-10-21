package edu.mcw.rgd.search.elasticsearch1.model;

import java.util.List;
import java.util.Set;

/**
 * Created by jthota on 11/9/2018.
 */
public class Source {
    private String id;
    private String type;
    private String symbol;
    private String source;
    private String origin;
    private String name;
    private String objectType;
    private String speciesTypeKey;
    private Set<String> matchingFields;

    public String getSpeciesTypeKey() {
        return speciesTypeKey;
    }

    public void setSpeciesTypeKey(String speciesTypeKey) {
        this.speciesTypeKey = speciesTypeKey;
    }

    public String getObjectType() {
        return objectType;
    }

    public void setObjectType(String objectType) {
        this.objectType = objectType;
    }

    public Set<String> getMatchingFields() {
        return matchingFields;
    }

    public void setMatchingFields(Set<String> matchingFields) {
        this.matchingFields = matchingFields;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getSymbol() {
        return symbol;
    }

    public void setSymbol(String symbol) {
        this.symbol = symbol;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public String getOrigin() {
        return origin;
    }

    public void setOrigin(String origin) {
        this.origin = origin;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }


}
