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
public class QTLStrainAssociationUpdate implements AssociationUpdate{

    AssociationDAO adao = new AssociationDAO();

    public List get(int qtlRgdId) throws Exception {
            return adao.getStrainAssociationsForQTL(qtlRgdId);
    }

    public void insert(int qtlRgdId,int strainRgdId ) throws Exception {
        adao.insertStrainToQTLAssociation(strainRgdId,qtlRgdId);
    }

    public void remove( int qtlRgdId, int strainRgdId) throws Exception {
        adao.removeStrainToQTLAssociation(strainRgdId,qtlRgdId);
    }
}
    