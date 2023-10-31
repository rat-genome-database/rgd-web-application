package edu.mcw.rgd.phenotype.phenotypeExpectedRanges.dao;

import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.dao.spring.StringListQuery;

import java.util.List;

/**
 * Created by jthota on 3/6/2018.
 */
public class StrainGroupDao extends PhenominerDAO {
    public String getStrainGroupName(int strainGroupId) throws Exception {
        String sql="SELECT STRAIN_GROUP_NAME FROM STRAIN_GROUP WHERE STRAIN_GROUP_ID="+"'"+ strainGroupId+"'";
        StringListQuery query=new StringListQuery(this.getDataSource(), sql);
        return (String) query.execute().get(0);
    }
    public List<String> getStrainsOfStrainGroup(int strainGroupId) throws Exception {
        String sql="SELECT STRAIN_ONT_ID FROM STRAIN_GROUP WHERE STRAIN_GROUP_ID="+"'"+   strainGroupId+"'";
        StringListQuery query= new StringListQuery(this.getDataSource(), sql);
        return  query.execute();
    }
}
