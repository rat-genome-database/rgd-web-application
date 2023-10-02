package edu.mcw.rgd.ontology;

import edu.mcw.rgd.dao.impl.ReferenceDAO;
import edu.mcw.rgd.datamodel.Reference;

import java.util.List;

public class ReferencePipelines  {
    static ReferenceDAO rdao = new ReferenceDAO();
    static List<Reference> pipelines;

    public ReferencePipelines() {
        try{
        pipelines = rdao.getAllReferencesByReferenceType("DIRECT DATA TRANSFER");}
        catch (Exception e)
        {
            System.out.println("There is apparently not a pipeline that exits");
        }
    }

    public boolean search(int rgdId) throws Exception
    {
        for (Reference pipe : pipelines){
            if (pipe.getRgdId() == rgdId)
                return true;
        }
        return false;
    }
}
