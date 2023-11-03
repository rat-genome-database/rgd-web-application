package edu.mcw.rgd.phenominer.frontend;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.ontologyx.TermWithStats;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Created by jdepons on 5/11/2017.
 */
public class OntChoicesController implements Controller {

    OntologyXDAO odao = new OntologyXDAO();
    PhenominerDAO pdao = new PhenominerDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        int speciesTypeKey = 3;
        String spParam = request.getParameter("species");
        if (spParam != null && spParam.equals("4")) {
            speciesTypeKey = 4;
        }

        List<String> sampleIds = new ArrayList<String>();
        List<String> csIds = new ArrayList<String>();
        List<String> mmIds = new ArrayList<String>();
        List<String> cmIds = new ArrayList<String>();
        List<String> ecIds = new ArrayList<String>();
        String termString="";
        int filteredRecordCount = 0;


        if (request.getParameter("terms") == null || request.getParameter("terms").equals("")) {

        }else {

            termString = request.getParameter("terms");
            String sex = null;

            //System.out.println("termString" + termString);

            String[] terms = termString.split(",");

            //System.out.println("term lenght = " + terms.length);

            for (int j = 0; j < terms.length; j++) {
                String[] termParts = terms[j].split(":");

                while (termParts[1].length() < 7) {
                    termParts[1] = "0" + termParts[1];
                }

                terms[j] = termParts[0] + ":" + termParts[1];

            }

            Set<Integer> sampleRecIds = new HashSet<Integer>();
            Set<Integer> csRecIds = new HashSet<Integer>();
            Set<Integer> mmRecIds = new HashSet<Integer>();
            Set<Integer> cmRecIds = new HashSet<Integer>();
            Set<Integer> ecRecIds = new HashSet<Integer>();

            for (String term : terms) {
                if (term.startsWith("RS")) {
                    sampleIds.add(term);
                    sampleRecIds.addAll(pdao.getRecordIdsForTermOnly(term, sex, speciesTypeKey));
                } else if (term.startsWith("CMO")) {
                    cmIds.add(term);
                    cmRecIds.addAll(pdao.getRecordIdsForTermOnly(term, sex, speciesTypeKey));
                } else if (term.startsWith("MMO")) {
                    mmIds.add(term);
                    mmRecIds.addAll(pdao.getRecordIdsForTermOnly(term, sex, speciesTypeKey));
                } else if (term.startsWith("XCO")) {
                    ecIds.add(term);
                    ecRecIds.addAll(pdao.getRecordIdsForTermOnly(term, sex, speciesTypeKey));
                } else if (term.startsWith("CS")) {
                    csIds.add(term);
                    csRecIds.addAll(pdao.getRecordIdsForTermOnly(term, sex, speciesTypeKey));
                }
            }

            Set<Integer> filteredRecIds = new HashSet<Integer>();
            applyFilter(filteredRecIds, sampleRecIds);
            applyFilter(filteredRecIds, csRecIds);
            applyFilter(filteredRecIds, cmRecIds);
            applyFilter(filteredRecIds, mmRecIds);
            applyFilter(filteredRecIds, ecRecIds);
            filteredRecordCount = filteredRecIds.size();

            sortByTermName(sampleIds);
            sortByTermName(csIds);
            sortByTermName(cmIds);
            sortByTermName(mmIds);
            sortByTermName(ecIds);
        }

        request.setAttribute("sex", null);
        request.setAttribute("sampleIds", sampleIds);
        request.setAttribute("csIds", csIds);
        request.setAttribute("cmIds", cmIds);
        request.setAttribute("mmIds", mmIds);
        request.setAttribute("ecIds", ecIds);
        request.setAttribute("termString", termString);
        request.setAttribute("speciesTypeKey", speciesTypeKey);
        request.setAttribute("filteredRecCount", filteredRecordCount);
        request.setAttribute("species", speciesTypeKey);
        return new ModelAndView("/WEB-INF/jsp/phenominer/ontChoices.jsp", "", null);
    }

    void sortByTermName(List<String> termAccs) {

        if( termAccs.size() <=1 ) {
            return;
        }

        Collections.sort(termAccs, new Comparator<String>() {
            @Override
            public int compare(String o1, String o2) {
                try {
                    TermWithStats t1 = odao.getTermWithStatsCached(o1);
                    TermWithStats t2 = odao.getTermWithStatsCached(o2);
                    return t1.getTerm().compareToIgnoreCase(t2.getTerm());
                } catch(Exception e ) {
                }
                return 0;
            }
        });
    }

    void applyFilter(Set<Integer> filteredRecIds, Set<Integer> ontRecIds) {
        if( !ontRecIds.isEmpty() ) {
            if( filteredRecIds.isEmpty() ) {
                filteredRecIds.addAll(ontRecIds);
            } else {
                filteredRecIds.retainAll(ontRecIds);
            }
        }
    }
}
