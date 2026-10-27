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
 * Access is checked by AuthenticationInterceptor (curation/expression/*).
 */
public class MissingStudyReferencesController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        LinkedHashMap<Study, List<String>> studies = new GeneExpressionDAO().getStudiesWithRnaSeqPubmedIdsButNoReferences();

        Set<String> pmids = new HashSet<>();
        for( List<String> studyPmids: studies.values() ) {
            pmids.addAll(studyPmids);
        }
        Map<String, Integer> refRgdIds = new ReferenceDAO().getReferenceRgdIdsByPubmedIds(pmids);

        request.setAttribute("studies", studies);
        request.setAttribute("refRgdIds", refRgdIds);
        return new ModelAndView("/WEB-INF/jsp/curation/expression/missingStudyReferences.jsp");
    }
}
