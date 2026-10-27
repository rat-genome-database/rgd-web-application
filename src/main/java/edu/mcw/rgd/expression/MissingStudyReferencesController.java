package edu.mcw.rgd.expression;

import edu.mcw.rgd.dao.impl.GeneExpressionDAO;
import edu.mcw.rgd.dao.impl.ReferenceDAO;
import edu.mcw.rgd.datamodel.pheno.Study;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Lists studies whose GEO series has a PubMed id in RNA_SEQ but that have no entry in STUDY_REFERENCES.
 * act=fixAll (POST) adds a STUDY_REFERENCES row for every listed PubMed id that is a reference in RGD.
 * Access is checked by AuthenticationInterceptor (curation/expression/*).
 */
public class MissingStudyReferencesController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        GeneExpressionDAO geDAO = new GeneExpressionDAO();
        ArrayList<String> status = new ArrayList<>();
        ArrayList<String> error = new ArrayList<>();

        if( "POST".equalsIgnoreCase(request.getMethod()) && "fixAll".equals(request.getParameter("act")) ) {
            // the list is computed again here, so only studies that still have no references are changed
            LinkedHashMap<Study, List<String>> studies = geDAO.getStudiesWithRnaSeqPubmedIdsButNoReferences();
            Map<String, Integer> refRgdIds = new ReferenceDAO().getReferenceRgdIdsByPubmedIds(getPubmedIds(studies));

            int studiesFixed = 0;
            int referencesAdded = 0;
            for( Map.Entry<Study, List<String>> entry: studies.entrySet() ) {
                Set<Integer> studyRefRgdIds = new LinkedHashSet<>();
                for( String pmid: entry.getValue() ) {
                    Integer refRgdId = refRgdIds.get(pmid);
                    if( refRgdId != null ) {
                        studyRefRgdIds.add(refRgdId);
                    }
                }
                try {
                    for( Integer refRgdId: studyRefRgdIds ) {
                        geDAO.insertStudyReference(entry.getKey().getId(), refRgdId);
                        referencesAdded++;
                    }
                    if( !studyRefRgdIds.isEmpty() ) {
                        studiesFixed++;
                    }
                } catch( Exception e ) {
                    error.add("Study " + entry.getKey().getId() + ": " + e.getMessage());
                }
            }
            status.add("Added " + referencesAdded + " study references to " + studiesFixed + " studies.");
        }

        LinkedHashMap<Study, List<String>> studies = geDAO.getStudiesWithRnaSeqPubmedIdsButNoReferences();
        Map<String, Integer> refRgdIds = new ReferenceDAO().getReferenceRgdIdsByPubmedIds(getPubmedIds(studies));

        request.setAttribute("studies", studies);
        request.setAttribute("refRgdIds", refRgdIds);
        request.setAttribute("status", status);
        request.setAttribute("error", error);
        return new ModelAndView("/WEB-INF/jsp/curation/expression/missingStudyReferences.jsp");
    }

    private Set<String> getPubmedIds(Map<Study, List<String>> studies) {
        Set<String> pmids = new HashSet<>();
        for( List<String> studyPmids: studies.values() ) {
            pmids.addAll(studyPmids);
        }
        return pmids;
    }
}
