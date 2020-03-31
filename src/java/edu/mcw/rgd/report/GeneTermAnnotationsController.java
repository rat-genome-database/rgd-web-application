package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.AnnotationDAO;
import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.datamodel.ontology.Annotation;
import edu.mcw.rgd.datamodel.ontologyx.TermSynonym;
import edu.mcw.rgd.process.Utils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * @author mtutaj
 * @since 4/3/12
 * shows all annotations for given gene and ontology term
 */
public class GeneTermAnnotationsController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ModelAndView mv = new ModelAndView("/WEB-INF/jsp/report/annotation/table.jsp");

        GeneTermAnnotationsBean bean = new GeneTermAnnotationsBean();

        // parameter handling: we expect 'rgdId' - geneRgdId and 'accId' - term acc id
        RGDManagementDAO managementDAO = new RGDManagementDAO();
        int rgdId = 0;
        try {
            rgdId = Integer.parseInt(request.getParameter("id"));
            RgdId rgdIdObj = managementDAO.getRgdId2(rgdId);
            if( rgdIdObj!=null ) {
                bean.setRgdId(rgdIdObj);
                bean.setRgdObject(managementDAO.getObject(rgdId));
            }
        }
        catch(NumberFormatException ignore) {}

        if( bean.getRgdObject()==null ) {
            // unknown rgd id -- redirect to home page
            response.sendRedirect("/../");
            return null;
        }

        OntologyXDAO ontologyDAO = new OntologyXDAO();
        bean.setAccId(Utils.defaultString(request.getParameter("term")));
        bean.setTerm(ontologyDAO.getTermByAccId(bean.getAccId()));

        // validate term accession id
        if( bean.getTerm()==null ) {
            // unknown term accession id -- redirect to home page
            response.sendRedirect("/../");
            return null;
        }

        // load CasRN if available
        if( bean.getAccId().startsWith("CHEBI") ) {
            for( TermSynonym synonym: ontologyDAO.getTermSynonyms(bean.getAccId()) ) {
                if( Utils.stringsAreEqual(synonym.getType(), "xref_casrn") ) {
                    bean.setCasRN(synonym.getName());
                }
                else if( Utils.stringsAreEqual(synonym.getType(), "xref_mesh") ) {
                    bean.setMeshID(synonym.getName());
                }
            }
        }

        AnnotationDAO annotationDAO = new AnnotationDAO();
        List<Annotation> annotationList = annotationDAO.getAnnotations(rgdId,bean.getAccId());
        if(annotationList.isEmpty() ) {
            annotationList = annotationDAO.getAnnotationsByReferenceAndTermAcc(rgdId, bean.getAccId());
        }

        // sort annotations
        Collections.sort(annotationList, new Comparator<Annotation>() {
            @Override
            public int compare(Annotation o1, Annotation o2) {
                // SORT ORDER
                // 1. data_source: 'RGD','OMIM','CTD',...
                // 2. evidence
                // 3. with_info
                // 4. xrefs
                int r = getDataSourceRank(o1.getDataSrc()) - getDataSourceRank(o2.getDataSrc());
                if( r!=0 ) {
                    return r;
                }
                r = Utils.stringsCompareTo(o1.getEvidence(), o2.getEvidence());
                if( r!=0 ) {
                    return r;
                }
                r = Utils.stringsCompareTo(o1.getWithInfo(), o2.getWithInfo());
                if( r!=0 ) {
                    return r;
                }
                return Utils.stringsCompareTo(o1.getXrefSource(), o2.getXrefSource());
            }

            int getDataSourceRank(String dataSrc) {
                switch(dataSrc) {
                    case "RGD": return -10;
                    case "OMIM": return -9;
                    case "CTD": return -8;
                    default: return Character.codePointAt(dataSrc, 0);
                }
            }
        });

        bean.setAnnotations(annotationList);
        
        mv.addObject("bean", bean);

        return mv;
    }
}
