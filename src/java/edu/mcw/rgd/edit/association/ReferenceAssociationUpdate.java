package edu.mcw.rgd.edit.association;

import edu.mcw.rgd.dao.impl.AssociationDAO;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Aug 3, 2009
 * Time: 1:44:10 PM
 * To change this template use File | Settings | File Templates.
 */
public class ReferenceAssociationUpdate implements AssociationUpdate{

    AssociationDAO adao = new AssociationDAO();

    public List get(int rgdId) throws Exception {
            return adao.getReferenceAssociations(rgdId);
    }

    public void insert(int objectRgdId, int referenceRgdId ) throws Exception {
        adao.insertReferenceeAssociation(objectRgdId, referenceRgdId);
    }

    public void remove(int objectRgdId, int referenceRgdId) throws Exception {
        adao.removeReferenceAssociation(objectRgdId, referenceRgdId);
    }

}

