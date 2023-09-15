package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.ontologyx.TermSynonym;
import edu.mcw.rgd.process.Utils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: 3/19/13
 */
public class TermMergeController implements Controller {

    OntologyXDAO ontologyXDAO = new OntologyXDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse httpServletResponse) throws Exception {

        TermMergeBean bean = new TermMergeBean();

        String action = request.getParameter("action");
        boolean isCommit = action!=null && action.equals("commit");
        boolean isPreview = !isCommit;

        String termAccFrom = request.getParameter("termAccFrom");
        String termAccTo = request.getParameter("termAccTo");
        String sessionObj = "term-merge-"+termAccFrom+"-"+termAccTo;

        if( isPreview ) {
            populateBean(termAccFrom, termAccTo, bean);
            request.getSession().setAttribute(sessionObj, bean);
        }
        else { // commit mode
            // commit the changes first
            bean = (TermMergeBean) request.getSession().getAttribute(sessionObj);
            commit(bean);
            request.getSession().removeAttribute(sessionObj);

            // populate bean from database, so it is up-to-date
            populateBean(termAccFrom, termAccTo, bean);
        }


        String page = isPreview ? "/WEB-INF/jsp/curation/edit/termMergePreview.jsp"
                : "/WEB-INF/jsp/curation/edit/termMergeSummary.jsp";

        ModelAndView mv = new ModelAndView(page);
        mv.addObject("bean", bean);
        return mv;
    }

    void populateBean(String termAccFrom, String termAccTo, TermMergeBean bean) throws Exception {
        bean.setTermFrom(ontologyXDAO.getTermByAccId(termAccFrom));
        bean.setTermTo(ontologyXDAO.getTermByAccId(termAccTo));

        List<TermSynonym> termFromSynonyms = ontologyXDAO.getTermSynonyms(termAccFrom);
        bean.setExistingSynonyms(termFromSynonyms);
        List<TermSynonym> termToSynonyms = ontologyXDAO.getTermSynonyms(termAccTo);
        bean.getExistingSynonyms().addAll(termToSynonyms);
        Collections.sort(bean.getExistingSynonyms(), new Comparator<TermSynonym>() {
            @Override
            public int compare(TermSynonym o1, TermSynonym o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getName(), o2.getName());
            }
        });

        bean.setToBeDeletedSynonyms(generateToBeDeletedSynonyms(termFromSynonyms, termAccFrom));
        bean.setToBeInsertedSynonyms(generateToBeInsertedSynonyms(termFromSynonyms, bean.getTermFrom(), termToSynonyms, termAccTo));

        bean.setTermFromParents(getParentTerms(termAccFrom));
        bean.setTermToParents(getParentTerms(termAccTo));

        bean.setTermFromChildren(getChildTerms(termAccFrom));
        bean.setTermToChildren(getChildTerms(termAccTo));
    }

    List<TermSynonym> generateToBeDeletedSynonyms(List<TermSynonym> existingFromSynonyms, String accIdFrom) {

        List<TermSynonym> toBeDeleted = new ArrayList<TermSynonym>();
        for( TermSynonym ts: existingFromSynonyms ) {
            if( ts.getTermAcc().equals(accIdFrom) && ts.getType().equals("primary_id")) {
                toBeDeleted.add(ts);
            }
        }
        return toBeDeleted;
    }

    List<TermSynonym> generateToBeInsertedSynonyms(List<TermSynonym> synonymsFrom, Term termFrom,
                                                   List<TermSynonym> synonymsTo, String accIdTo) {

        List<TermSynonym> toBeInserted = new ArrayList<TermSynonym>();

        TermSynonym syn = new TermSynonym();
        // check if replaced_by synonym is already on fromTerm
        for( TermSynonym tsFrom: synonymsFrom ) {
            if( tsFrom.getType().equals("replaced_by") && tsFrom.getName().equals(accIdTo) ) {
                syn = null;
                break;
            }
        }
        if( syn!=null ) {
            syn.setType("replaced_by");
            syn.setTermAcc(termFrom.getAccId());
            syn.setName(accIdTo);
            syn.setSource("RGD");
            syn.setCreatedDate(new Date());
            syn.setLastModifiedDate(new Date());
            toBeInserted.add(syn);
        }


        syn = new TermSynonym();
        // check if alt_id synonym is already on toTerm
        for( TermSynonym tsTo: synonymsTo ) {
            if( tsTo.getType().equals("alt_id") && tsTo.getName().equals(termFrom.getAccId()) ) {
                syn = null;
                break;
            }
        }
        if( syn!=null ) {
            syn.setType("alt_id");
            syn.setTermAcc(accIdTo);
            syn.setName(termFrom.getAccId());
            syn.setSource("RGD");
            syn.setCreatedDate(new Date());
            syn.setLastModifiedDate(new Date());
            toBeInserted.add(syn);
        }


        syn = new TermSynonym();
        // check if term-from name is already a synonym on toTerm
        for( TermSynonym tsTo: synonymsTo ) {
            if( tsTo.getName().equalsIgnoreCase(termFrom.getTerm()) ) {
                syn = null;
                break;
            }
        }
        if( syn!=null ) {
            syn.setType("exact_synonym");
            syn.setTermAcc(accIdTo);
            syn.setName(termFrom.getTerm());
            syn.setSource("RGD");
            syn.setCreatedDate(new Date());
            syn.setLastModifiedDate(new Date());
            toBeInserted.add(syn);
        }

        // examine FROM synonyms; if they are unique, add them to TO term
        for( TermSynonym tsFrom: synonymsFrom ) {

            boolean fromSynonymIsUnique = true;
            for( TermSynonym tsTo: synonymsTo ) {
                if( Utils.stringsAreEqualIgnoreCase(tsFrom.getName(), tsTo.getName()) ) {
                    fromSynonymIsUnique = false;
                    break;
                }
            }

            if( fromSynonymIsUnique ) {

                // skip generation of synonyms like
                // type=replaced_by  term_acc=RDO:9000013  name=RDO:9000013
                if( tsFrom.getType().equals("replaced_by") && accIdTo.equals(tsFrom.getName()) ) {
                    continue;
                }

                syn = new TermSynonym();
                syn.setType(tsFrom.getType());
                syn.setTermAcc(accIdTo);
                syn.setName(tsFrom.getName());
                syn.setSource(tsFrom.getSource());
                syn.setCreatedDate(tsFrom.getCreatedDate());
                syn.setLastModifiedDate(new Date());
                toBeInserted.add(syn);
            }
        }
        return toBeInserted;
    }

    List<Term> getParentTerms(String termAcc) throws Exception {
        Set<String> parentTermAccs = ontologyXDAO.getTermAncestors(termAcc).keySet();
        List<Term> parentTerms = new ArrayList<Term>(parentTermAccs.size());
        for( String parentTermAcc: parentTermAccs ) {
            parentTerms.add(ontologyXDAO.getTermByAccId(parentTermAcc));
        }
        return parentTerms;
    }

    List<Term> getChildTerms(String termAcc) throws Exception {
        Set<String> childTermAccs = ontologyXDAO.getTermDescendants(termAcc).keySet();
        List<Term> childTerms = new ArrayList<Term>(childTermAccs.size());
        for( String childTermAcc: childTermAccs ) {
            childTerms.add(ontologyXDAO.getTermByAccId(childTermAcc));
        }
        return childTerms;
    }

    void commit(TermMergeBean bean) throws Exception {
        if( !bean.getTermFrom().getOntologyId().equals(bean.getTermTo().getOntologyId()) ) {
            throw new Exception("terms from different ontologies may not be merged!");
        }

        // obsolete from term
        bean.getTermFrom().setObsolete(1);
        bean.getTermFrom().setModificationDate(new Date());
        ontologyXDAO.updateTerm(bean.getTermFrom());

        // update definition
        if( Utils.isStringEmpty(bean.getTermTo().getDefinition())
            && !Utils.isStringEmpty(bean.getTermFrom().getDefinition()) ) {
            bean.getTermTo().setDefinition(bean.getTermFrom().getDefinition());
            ontologyXDAO.updateTerm(bean.getTermTo());
        }

        // insert synonyms
        for( TermSynonym syn: bean.getToBeInsertedSynonyms() ) {
            ontologyXDAO.insertTermSynonym(syn);
        }

        // delete synonyms
        for( TermSynonym syn: bean.getToBeDeletedSynonyms() ) {
            ontologyXDAO.dropTermSynonym(syn);
        }

        // merge parent and child relations
        ontologyXDAO.mergeDags(bean.getTermFrom().getAccId(), bean.getTermTo().getAccId());
        ontologyXDAO.deleteDagsForObsoleteTerm(bean.getTermFrom().getAccId());

        new AnnotationDAO().reassignAnnotations(bean.getTermFrom().getAccId(), bean.getTermTo().getAccId());
    }
}
