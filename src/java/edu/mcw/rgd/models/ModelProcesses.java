package edu.mcw.rgd.models;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.models.GeneticModel;
import edu.mcw.rgd.datamodel.ontologyx.Term;


import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Created by jthota on 9/6/2016.
 */
public class ModelProcesses {
    GeneDAO geneDAO=new GeneDAO();
    StrainDAO strainDAO= new StrainDAO();
    GeneticModelsDAO dao= new GeneticModelsDAO();
    PhenominerDAO phenominerDAO= new PhenominerDAO();
    OntologyXDAO ontologyXDAO= new OntologyXDAO();
    public List<GeneticModel> getStrains() throws Exception{

        return dao.getStrains();
    }
    public String getTermAccId(String aliasName) throws Exception{
        String termAccId= null;

        Term term= ontologyXDAO.getTermByTermName(aliasName, "RS");
        if(term!=null){
            termAccId=term.getAccId();
        }
        return termAccId;
    }
    public int getExperimentRecordCount(String termAccId) throws Exception{

        int expRecordCount= 0;
        if(phenominerDAO.getRecordCountForTermAndDescendants(termAccId)!=0)
            expRecordCount= phenominerDAO.getRecordCountForTermAndDescendants(termAccId);
        return expRecordCount;

    }
    public Map<String, Integer> getExperimentRecordCounts(List<String> termAccIds) throws Exception{

        int expRecordCount= 0;
       Map<String, Integer> recordCountMap= phenominerDAO.getRecordCountForTermAndDescendantsByListOfAccdIds(termAccIds);
       return recordCountMap;

    }
    public List<String> getChildTermAccIds(String parentTermAccId) throws Exception{
        List<String> childTermAccIds= new ArrayList<>();
        List<Term> childTerms= ontologyXDAO.getAllActiveTermDescendants(parentTermAccId);
        for(Term term:childTerms){
            childTermAccIds.add(term.getAccId());
        }
        return childTermAccIds;
    }
}
