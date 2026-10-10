package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.ontologyx.TermSynonym;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.*;

public class ObsoleteGoTermsController implements Controller {

    OntologyXDAO odao = new OntologyXDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String msg = null;

        // handle deletion
        String delKey = request.getParameter("delKey");
        if( delKey != null ) {
            TermSynonym syn = new TermSynonym();
            syn.setKey(Integer.parseInt(delKey));
            odao.deleteTermSynonyms(Collections.singletonList(syn));
            msg = "Deleted synonym with key: " + delKey;
        }

        // handle insertion
        String currentTermAcc = request.getParameter("currentTermAcc");
        String obsoleteTermAcc = request.getParameter("obsoleteTermAcc");
        if( currentTermAcc != null && obsoleteTermAcc != null ) {
            currentTermAcc = currentTermAcc.trim();
            obsoleteTermAcc = obsoleteTermAcc.trim();

            if( currentTermAcc.isEmpty() || obsoleteTermAcc.isEmpty() ) {
                msg = "Both 'Current Term Acc' and 'Obsolete Term Acc' must be provided.";
            } else {
                TermSynonym syn = new TermSynonym();
                syn.setTermAcc(currentTermAcc);
                syn.setName(obsoleteTermAcc);
                syn.setType("alt_id");
                syn.setSource("RGD");
                syn.setCreatedDate(new Date());
                syn.setLastModifiedDate(new Date());
                odao.insertTermSynonym(syn);
                msg = "Inserted obsolete GO term: " + obsoleteTermAcc + " for current term: " + currentTermAcc;
            }
        }

        List<TermSynonym> synonyms = odao.getObsoleteGoTermSynonyms();

        // resolve term names for term_acc and synonym_name
        Map<String, String> termNames = new HashMap<>();
        for( TermSynonym syn : synonyms ) {
            termNames.computeIfAbsent(syn.getTermAcc(), acc -> getTermName(acc));
            termNames.computeIfAbsent(syn.getName(), acc -> getTermName(acc));
        }

        String page = "/WEB-INF/jsp/curation/edit/obsoleteGoTerms.jsp";
        ModelAndView mv = new ModelAndView(page);
        mv.addObject("synonyms", synonyms);
        mv.addObject("termNames", termNames);
        mv.addObject("msg", msg);
        return mv;
    }

    String getTermName(String accId) {
        try {
            Term term = odao.getTermByAccId(accId);
            if( term != null ) {
                return term.getTerm();
            }
        } catch( Exception ignored ) {
        }
        return "";
    }
}
