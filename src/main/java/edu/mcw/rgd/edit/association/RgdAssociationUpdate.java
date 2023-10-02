package edu.mcw.rgd.edit.association;

import edu.mcw.rgd.dao.impl.AssociationDAO;
import edu.mcw.rgd.datamodel.Association;
import edu.mcw.rgd.datamodel.Identifiable;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: 1/29/14
 * Time: 2:30 PM
 * <p>
 * generic class for handling associations in RGD_ASSOCIATIONS table
 */
public class RgdAssociationUpdate implements AssociationUpdate {

    private String assocType;
    private AssociationDAO adao = new AssociationDAO();

    public RgdAssociationUpdate(String assocType) {
        this.assocType = assocType;
    }

    public List get(int rgdId) throws Exception {
        return adao.getAssociationsForMasterRgdId(rgdId, assocType);
    }

    public void insert(int objectRgdId, int associationRgdId) throws Exception {
        Association assoc = new Association();
        assoc.setAssocType(assocType);
        assoc.setMasterRgdId(objectRgdId);
        assoc.setDetailRgdId(associationRgdId);
        assoc.setSrcPipeline("OBJECT_EDIT");
        adao.insertAssociation(assoc);
    }

    public void remove(int associationRgdId, int objectRgdId) throws Exception {

        adao.deleteAssociations(associationRgdId, objectRgdId, assocType);
    }

}
