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
public class StrainQTLAssociationUpdate implements AssociationUpdate{

    AssociationDAO adao = new AssociationDAO();

    public List get(int strainRgdId) throws Exception {
            return adao.getQTLAssociationsForStrain(strainRgdId);
    }

    public void insert(int strainRgdId, int qtlRgdId ) throws Exception {
        adao.insertStrainToQTLAssociation(strainRgdId, qtlRgdId);
    }

    public void remove(int strainRgdId, int qtlRgdId) throws Exception {
        adao.removeStrainToQTLAssociation(strainRgdId,qtlRgdId );
    }
}