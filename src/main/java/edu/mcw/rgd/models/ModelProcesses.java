package edu.mcw.rgd.models;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.models.GeneticModel;

import java.util.List;
import java.util.Map;

/**
 * Created by jthota on 9/6/2016.
 */
public class ModelProcesses {
    GeneticModelsDAO dao= new GeneticModelsDAO();
    PhenominerDAO phenominerDAO= new PhenominerDAO();
    public List<GeneticModel> getStrains() throws Exception{
        return dao.getStrains();
    }
    public Map<String, Integer> getExperimentRecordCounts(List<String> termAccIds) throws Exception{
        return phenominerDAO.getRecordCountForTermAndDescendantsByListOfAccdIds(termAccIds);

    }

}
