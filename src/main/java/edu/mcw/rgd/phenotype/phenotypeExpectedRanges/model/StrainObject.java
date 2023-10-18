package edu.mcw.rgd.phenotype.phenotypeExpectedRanges.model;

import edu.mcw.rgd.datamodel.ontologyx.Term;

import java.util.List;
import java.util.Map;

/**
 * Created by jthota on 3/12/2018.
 */
public class StrainObject {
    private String strainGroupName;
    private String strainGroupId;
    private List<Term> strains;
    private List<Term>  cmoTerms;
    private List<Term> conditions;
    private List<Term> methods;
    private List<String> cmoAccIds;
    private Map<String, String> phenotypeNameAccIdMap;
    private String overall;
    private List<ExpectedRangeRecord> records;

    public Map<String, String> getPhenotypeNameAccIdMap() {
        return phenotypeNameAccIdMap;
    }

    public void setPhenotypeNameAccIdMap(Map<String, String> phenotypeNameAccIdMap) {
        this.phenotypeNameAccIdMap = phenotypeNameAccIdMap;
    }

    public List<String> getCmoAccIds() {
        return cmoAccIds;
    }

    public void setCmoAccIds(List<String> cmoAccIds) {
        this.cmoAccIds = cmoAccIds;
    }

    public List<ExpectedRangeRecord> getRecords() {
        return records;
    }

    public void setRecords(List<ExpectedRangeRecord> records) {
        this.records = records;
    }

    public String getStrainGroupName() {
        return strainGroupName;
    }

    public void setStrainGroupName(String strainGroupName) {
        this.strainGroupName = strainGroupName;
    }

    public String getStrainGroupId() {
        return strainGroupId;
    }

    public void setStrainGroupId(String strainGroupId) {
        this.strainGroupId = strainGroupId;
    }

    public List<Term> getStrains() {
        return strains;
    }

    public void setStrains(List<Term> strains) {
        this.strains = strains;
    }

    public List<Term> getCmoTerms() {
        return cmoTerms;
    }

    public void setCmoTerms(List<Term> cmoTerms) {
        this.cmoTerms = cmoTerms;
    }

    public List<Term> getConditions() {
        return conditions;
    }

    public void setConditions(List<Term> conditions) {
        this.conditions = conditions;
    }

    public List<Term> getMethods() {
        return methods;
    }

    public void setMethods(List<Term> methods) {
        this.methods = methods;
    }

    public String getOverall() {
        return overall;
    }

    public void setOverall(String overall) {
        this.overall = overall;
    }
}
