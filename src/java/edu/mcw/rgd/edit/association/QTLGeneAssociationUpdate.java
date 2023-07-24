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
public class QTLGeneAssociationUpdate implements AssociationUpdate{

    AssociationDAO adao = new AssociationDAO();

    public List get(int qtlRgdId) throws Exception {
        return adao.getGeneAssociationsByQTL(qtlRgdId);
    }

    public void insert(int qtlRgdId, int geneRgdId ) throws Exception {
        adao.insertGeneAssociationsByQTL(qtlRgdId, geneRgdId);
    }

    public void remove(int qtlRgdId, int geneRgdId) throws Exception {
        adao.removeGeneAssociationsByQTL(qtlRgdId, geneRgdId);
    }

}