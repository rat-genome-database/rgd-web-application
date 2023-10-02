package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.Strain;
import edu.mcw.rgd.datamodel.Strain2MarkerAssociation;
import edu.mcw.rgd.process.Utils;

import java.util.Iterator;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class StrainReportController extends ReportController {

    public String getViewUrl() throws Exception {
       return "strain/main.jsp";

    }

    public Object getObject(int rgdId) throws Exception{
        Strain obj = new StrainDAO().getStrain(rgdId);

        // retrieve all strain 2 gene associations
        // leave only alleles (marker_type='allele' or marker_type is NULL)
        List<Strain2MarkerAssociation> geneAlleles = new AssociationDAO().getStrain2GeneAssociations(rgdId);
        Iterator<Strain2MarkerAssociation> it = geneAlleles.iterator();
        while( it.hasNext() ) {
            Strain2MarkerAssociation i = it.next();
            if( !Utils.stringsAreEqual(Utils.NVL(i.getMarkerType(),"allele"), "allele") ) {
                it.remove();
            }
        }
        request.setAttribute("gene_alleles", geneAlleles);

        return obj;
    }

}