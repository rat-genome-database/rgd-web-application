package edu.mcw.rgd.phenotype.phenotypeExpectedRanges.model;

import edu.mcw.rgd.datamodel.ontologyx.Term;

import java.util.List;
import java.util.Map;

/**
 * Created by jthota on 3/5/2018.
 */
public class PhenotypeObject {
    private String phenotype;
    private String clinicalMeasurementId;
    private int recordsCountByStrain;
    private int recordsCountBySex;
    private int recordsCountByAge;
    private String overall;
    private List<ExpectedRangeRecord> records;
    private List<String> strainsSymbolsOfGroup;
    private List<String> cmoTerms;
    private List<String> xcoTerms;
    private List<String> mmoTerms;

    private List<Term> methodTerms;
    private List<Term> condtionTerms;
    private List<Term> ratStrainTerms;

    private List<String> sex;
    private List<String> age;
    private Map<String, Integer> strainGroupIdMap;

    private ExpectedRangeRecord normalAll;
    private ExpectedRangeRecord normalMale;
    private ExpectedRangeRecord normalFemale;

    public List<Term> getRatStrainTerms() {
        return ratStrainTerms;
    }

    public void setRatStrainTerms(List<Term> ratStrainTerms) {
        this.ratStrainTerms = ratStrainTerms;
    }

    public ExpectedRangeRecord getNormalAll() {
        return normalAll;
    }

    public void setNormalAll(ExpectedRangeRecord normalAll) {
        this.normalAll = normalAll;
    }

    public ExpectedRangeRecord getNormalMale() {
        return normalMale;
    }

    public void setNormalMale(ExpectedRangeRecord normalMale) {
        this.normalMale = normalMale;
    }

    public ExpectedRangeRecord getNormalFemale() {
        return normalFemale;
    }

    public void setNormalFemale(ExpectedRangeRecord normalFemale) {
        this.normalFemale = normalFemale;
    }

    public List<Term> getMethodTerms() {
        return methodTerms;
    }

    public void setMethodTerms(List<Term> methodTerms) {
        this.methodTerms = methodTerms;
    }

    public List<Term> getCondtionTerms() {
        return condtionTerms;
    }

    public void setCondtionTerms(List<Term> condtionTerms) {
        this.condtionTerms = condtionTerms;
    }

    public Map<String, Integer> getStrainGroupIdMap() {
        return strainGroupIdMap;
    }

    public void setStrainGroupIdMap(Map<String, Integer> strainGroupIdMap) {
        this.strainGroupIdMap = strainGroupIdMap;
    }

    public List<String> getSex() {
        return sex;
    }

    public void setSex(List<String> sex) {
        this.sex = sex;
    }

    public List<String> getAge() {
        return age;
    }

    public void setAge(List<String> age) {
        this.age = age;
    }




      public List<String> getStrainsSymbolsOfGroup() {
        return strainsSymbolsOfGroup;
    }

    public void setStrainsSymbolsOfGroup(List<String> strainsSymbolsOfGroup) {
        this.strainsSymbolsOfGroup = strainsSymbolsOfGroup;
    }

   public List<String> getCmoTerms() {
        return cmoTerms;
    }

    public void setCmoTerms(List<String> cmoTerms) {
        this.cmoTerms = cmoTerms;
    }

    public List<String> getXcoTerms() {
        return xcoTerms;
    }

    public void setXcoTerms(List<String> xcoTerms) {
        this.xcoTerms = xcoTerms;
    }

    public List<String> getMmoTerms() {
        return mmoTerms;
    }

    public void setMmoTerms(List<String> mmoTerms) {
        this.mmoTerms = mmoTerms;
    }

    public String getClinicalMeasurementId() {
        return clinicalMeasurementId;
    }

    public void setClinicalMeasurementId(String clinicalMeasurementId) {
        this.clinicalMeasurementId = clinicalMeasurementId;
    }

    public String getOverall() {
        return overall;
    }

    public void setOverall(String overall) {
        this.overall = overall;
    }

    public String getPhenotype() {
        return phenotype;
    }

    public void setPhenotype(String phenotype) {
        this.phenotype = phenotype;
    }

    public int getRecordsCountByStrain() {
        return recordsCountByStrain;
    }

    public void setRecordsCountByStrain(int recordsCountByStrain) {
        this.recordsCountByStrain = recordsCountByStrain;
    }

    public int getRecordsCountBySex() {
        return recordsCountBySex;
    }

    public void setRecordsCountBySex(int recordsCountBySex) {
        this.recordsCountBySex = recordsCountBySex;
    }

    public int getRecordsCountByAge() {
        return recordsCountByAge;
    }

    public void setRecordsCountByAge(int recordsCountByAge) {
        this.recordsCountByAge = recordsCountByAge;
    }

    public List<ExpectedRangeRecord> getRecords() {
        return records;
    }

    public void setRecords(List<ExpectedRangeRecord> records) {
        this.records = records;
    }
}
