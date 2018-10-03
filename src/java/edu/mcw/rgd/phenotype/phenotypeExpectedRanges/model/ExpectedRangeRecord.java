package edu.mcw.rgd.phenotype.phenotypeExpectedRanges.model;

import java.util.Date;
import java.util.List;

/**
 * Created by jthota on 3/5/2018.
 */
public class ExpectedRangeRecord {
    private int id;
    private String studyId;
    private String Experiment;
    private String clinicalMeasurement;
    private String clinicalMeasurementAccId;
    private int strainGroupId;
    private String strainGroupName;
    private String conditionGroupId;
    private String measurementMethodGroupId;
    private String ageLowBound;
    private String ageHighBound;
    private String sex;
    private double min;
    private double max;
    private double range;
    private double groupValue;
    private double groupSD;
    private double groupLow;
    private double groupHigh;
    private Date createdDate;
    private Date modifiedDate;
    private String expectedRangeName;
    private List<String> measurementMethodTerms;
    private List<String> conditionTerms;
    private List<String> methodAccIds;
    private String units;

    public String getUnits() {
        return units;
    }

    public void setUnits(String units) {
        this.units = units;
    }

    private List<String> measurementMethod;

    public List<String> getMethodAccIds() {
        return methodAccIds;
    }

    public void setMethodAccIds(List<String> methodAccIds) {
        this.methodAccIds = methodAccIds;
    }

    public List<String> getMeasurementMethodTerms() {
        return measurementMethodTerms;
    }

    public void setMeasurementMethodTerms(List<String> measurementMethodTerms) {
        this.measurementMethodTerms = measurementMethodTerms;
    }

    public List<String> getConditionTerms() {
        return conditionTerms;
    }

    public void setConditionTerms(List<String> conditionTerms) {
        this.conditionTerms = conditionTerms;
    }

    public List<String> getMeasurementMethod() {
        return measurementMethod;
    }

    public void setMeasurementMethod(List<String> measurementMethod) {
        this.measurementMethod = measurementMethod;
    }

    public String getExpectedRangeName() {
        return expectedRangeName;
    }

    public void setExpectedRangeName(String expectedRangeName) {
        this.expectedRangeName = expectedRangeName;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getStudyId() {
        return studyId;
    }

    public void setStudyId(String studyId) {
        this.studyId = studyId;
    }

    public String getExperiment() {
        return Experiment;
    }

    public void setExperiment(String experiment) {
        Experiment = experiment;
    }

    public String getClinicalMeasurement() {
        return clinicalMeasurement;
    }

    public void setClinicalMeasurement(String clinicalMeasurement) {
        this.clinicalMeasurement = clinicalMeasurement;
    }

    public String getClinicalMeasurementAccId() {
        return clinicalMeasurementAccId;
    }

    public void setClinicalMeasurementAccId(String clinicalMeasurementAccId) {
        this.clinicalMeasurementAccId = clinicalMeasurementAccId;
    }

    public int getStrainGroupId() {
        return strainGroupId;
    }

    public void setStrainGroupId(int strainGroupId) {
        this.strainGroupId = strainGroupId;
    }

    public String getStrainGroupName() {
        return strainGroupName;
    }

    public void setStrainGroupName(String strainGroupName) {
        this.strainGroupName = strainGroupName;
    }

    public String getConditionGroupId() {
        return conditionGroupId;
    }

    public void setConditionGroupId(String conditionGroupId) {
        this.conditionGroupId = conditionGroupId;
    }

    public String getMeasurementMethodGroupId() {
        return measurementMethodGroupId;
    }

    public void setMeasurementMethodGroupId(String measurementMethodGroupId) {
        this.measurementMethodGroupId = measurementMethodGroupId;
    }

    public String getAgeLowBound() {
        return ageLowBound;
    }

    public void setAgeLowBound(String ageLowBound) {
        this.ageLowBound = ageLowBound;
    }

    public String getAgeHighBound() {
        return ageHighBound;
    }

    public void setAgeHighBound(String ageHighBound) {
        this.ageHighBound = ageHighBound;
    }

    public String getSex() {
        return sex;
    }

    public void setSex(String sex) {
        this.sex = sex;
    }

    public double getMin() {
        return min;
    }

    public void setMin(double min) {
        this.min = min;
    }

    public double getMax() {
        return max;
    }

    public void setMax(double max) {
        this.max = max;
    }

    public double getRange() {
        return range;
    }

    public void setRange(double range) {
        this.range = range;
    }

    public double getGroupValue() {
        return groupValue;
    }

    public void setGroupValue(double groupValue) {
        this.groupValue = groupValue;
    }

    public double getGroupSD() {
        return groupSD;
    }

    public void setGroupSD(double groupSD) {
        this.groupSD = groupSD;
    }

    public double getGroupLow() {
        return groupLow;
    }

    public void setGroupLow(double groupLow) {
        this.groupLow = groupLow;
    }

    public double getGroupHigh() {
        return groupHigh;
    }

    public void setGroupHigh(double groupHigh) {
        this.groupHigh = groupHigh;
    }

    public Date getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Date createdDate) {
        this.createdDate = createdDate;
    }

    public Date getModifiedDate() {
        return modifiedDate;
    }

    public void setModifiedDate(Date modifiedDate) {
        this.modifiedDate = modifiedDate;
    }
}
