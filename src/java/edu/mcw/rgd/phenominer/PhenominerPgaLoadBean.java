package edu.mcw.rgd.phenominer;

import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.pheno.Condition;
import edu.mcw.rgd.datamodel.pheno.Experiment;
import edu.mcw.rgd.datamodel.pheno.Record;
import edu.mcw.rgd.datamodel.pheno.Study;
import edu.mcw.rgd.reporting.Report;

import java.security.PrivateKey;
import java.util.List;
import java.util.Map;

/**
 * Created by IntelliJ IDEA. <br>
 * User: mtutaj <br>
 * Date: 7/15/11 <br>
 * Time: 1:30 PM <br>
 * <p/>
 * contains all of the data used during the PGA data load
 */
public class PhenominerPgaLoadBean {

    private Study study; // study the pga data will be loaded into
    private List<Experiment> experiments; // experiments attached to the study
    private List<Record> experimentRecords; //

    private String dataFileName;
    private List<String[]> data; // list of lines with data; every line is array of columns

    private int strainCol = -1; // column nr for strain in the data
    private Map<String,Term> mapStrains; // map of strain names as found in data to strain ont term
    private int unmappedStrainCount; // count of strains that could not be mapped

    // atmospheric conditions
    private int atmCol = -1; // column nr for atmospheric condition in the data
    private Map<String,Condition> mapAtmCond; // map of atm cond names as found in data to atm cond object

    // diet conditions
    private int dietCondCol = -1; // column nr for diet condition in the data
    private Map<String,Condition> mapDietCond; // map of diet cond names as found in data to diet cond object

    // gender
    private int genderCol = -1; // column nr for gender in the data
    private Map<String,String> mapGender; // map of gender names as found in data to sex name

    // rat diet
    private int ratDietCol = -1; // column nr for rat diet code in the data
    private Map<String,String> mapRatDiet; // map of rat diet codes as found in data to rat diet description

    // phenotypes
    private int mappedPhenotypeCount = -1;
    private int dataFirstCol = -1; // index of first column with data
    private List<Map<String,Object>> phenotypes; // list of phenotypes (f.e. 'plasma glucose level')
        // every phenotype has a map of attributes:
        //   'col_name'   => 'body weight (kg)' -- as found in Excel column name
        //   'col_index'  => 7
        //   'phenotype'  => 'body weight'
        //   'unit'       => 'kg'
        //   'cmo_acc_id' => 'CMO:0000012'
        //   'cmo_acc_status' => match status: match by 'term name', match by 'term synonym', 'custom mapping' supplied by user
        //   'cmo_term_name' => term name validated against database
        //   'mmo_acc_id' => 'MMO:0000017'
        //   'mmo_acc_status' => match status: match by 'term name', match by 'term synonym', 'custom mapping' supplied by user
        //   'mmo_term_name' => term name validated against database

    private Report report;

    public int getRatIdCol() {
        return ratIdCol;
    }

    public void setRatIdCol(int ratIdCol) {
        this.ratIdCol = ratIdCol;
    }

    // rat id
    private int ratIdCol = -1; // Column number of rat_id

    public Study getStudy() {
        return study;
    }

    public void setStudy(Study study) {
        this.study = study;
    }

    public List<Experiment> getExperiments() {
        return experiments;
    }

    public void setExperiments(List<Experiment> experiments) {
        this.experiments = experiments;
    }

    public List<Record> getExperimentRecords() {
        return experimentRecords;
    }

    public void setExperimentRecords(List<Record> experimentRecords) {
        this.experimentRecords = experimentRecords;
    }

    public String getDataFileName() {
        return dataFileName;
    }

    public void setDataFileName(String dataFileName) {
        this.dataFileName = dataFileName;
    }

    public List<String[]> getData() {
        return data;
    }

    public void setData(List<String[]> data) {
        this.data = data;
    }

    public int getStrainCol() {
        return strainCol;
    }

    public void setStrainCol(int strainCol) {
        this.strainCol = strainCol;
    }

    public Map<String, Term> getMapStrains() {
        return mapStrains;
    }

    public void setMapStrains(Map<String, Term> mapStrains) {
        this.mapStrains = mapStrains;
    }

    public int getUnmappedStrainCount() {
        return unmappedStrainCount;
    }

    public void setUnmappedStrainCount(int unmappedStrainCount) {
        this.unmappedStrainCount = unmappedStrainCount;
    }

    public int getAtmCol() {
        return atmCol;
    }

    public void setAtmCol(int atmCol) {
        this.atmCol = atmCol;
    }

    public Map<String, Condition> getMapAtmCond() {
        return mapAtmCond;
    }

    public void setMapAtmCond(Map<String, Condition> mapAtmCond) {
        this.mapAtmCond = mapAtmCond;
    }

    public int getDietCondCol() {
        return dietCondCol;
    }

    public void setDietCondCol(int dietCondCol) {
        this.dietCondCol = dietCondCol;
    }

    public Map<String, Condition> getMapDietCond() {
        return mapDietCond;
    }

    public void setMapDietCond(Map<String, Condition> mapDietCond) {
        this.mapDietCond = mapDietCond;
    }

    public int getGenderCol() {
        return genderCol;
    }

    public void setGenderCol(int genderCol) {
        this.genderCol = genderCol;
    }

    public Map<String, String> getMapGender() {
        return mapGender;
    }

    public void setMapGender(Map<String, String> mapGender) {
        this.mapGender = mapGender;
    }

    public int getRatDietCol() {
        return ratDietCol;
    }

    public void setRatDietCol(int ratDietCol) {
        this.ratDietCol = ratDietCol;
    }

    public Map<String, String> getMapRatDiet() {
        return mapRatDiet;
    }

    public void setMapRatDiet(Map<String, String> mapRatDiet) {
        this.mapRatDiet = mapRatDiet;
    }

    public List<Map<String, Object>> getPhenotypes() {
        return phenotypes;
    }

    public void setPhenotypes(List<Map<String, Object>> phenotypes) {
        this.phenotypes = phenotypes;
    }

    public int getMappedPhenotypeCount() {
        return mappedPhenotypeCount;
    }

    public void setMappedPhenotypeCount(int mappedPhenotypeCount) {
        this.mappedPhenotypeCount = mappedPhenotypeCount;
    }

    public int getDataFirstCol() {
        return dataFirstCol;
    }

    public void setDataFirstCol(int dataFirstCol) {
        this.dataFirstCol = dataFirstCol;
    }

    public Report getReport() {
        return report;
    }

    public void setReport(Report report) {
        this.report = report;
    }


}
