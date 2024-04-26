package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.spring.StringListQuery;
import edu.mcw.rgd.datamodel.ontologyx.*;
import edu.mcw.rgd.process.Utils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.Principal;
import java.util.*;

public class TermEditObjectController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        request.setCharacterEncoding("UTF-8");

        String action = "";
        String termAcc = Utils.defaultString(request.getParameter("rgdId"));
        if( Utils.isStringEmpty(termAcc) ) {
            action = Utils.defaultString(request.getParameter("action"));
            termAcc = Utils.defaultString(request.getParameter("termAcc"));
            if( Utils.stringsAreEqualIgnoreCase(termAcc, "select ontology") ) {
                termAcc = Utils.defaultString(request.getParameter("newTermAcc"));
            }
        }

        Term term;
        String synTabMsg = ""; // custom message for synonym table
        String dagTabMsg = ""; // custom message for dag table
        String xrefTabMsg = ""; // custom message for xref table
        String statusMsg = null; // custom message for xref table

        // delete this term
        String formDelete = Utils.defaultString(request.getParameter("form_delete"));
        if( !Utils.isStringEmpty(formDelete) ) {
            // delete the term and synonyms
            term = deleteTerm(termAcc);

            ModelAndView mv = new ModelAndView("/WEB-INF/jsp/curation/edit/editTerm.jsp");
            mv.addObject("term", term);
            mv.addObject("statusMsg", "OK! Term "+termAcc+" ["+term.getTerm()+"] has been deleted!");
            return mv;
        }

        // obsolete this term
        String formObsolete = Utils.defaultString(request.getParameter("form_obsolete"));
        if( !Utils.isStringEmpty(formObsolete) ) {
            // obsolete the term
            term = obsoleteTerm(termAcc);
            statusMsg = "OK! Term "+termAcc+" ["+term.getTerm()+"] has been obsoleted!";
            action = "update";
        }

        OntologyXDAO odao = new OntologyXDAO();

        List<TermSynonym> synonyms = Collections.emptyList();
        List<TermDagEdge> parentEdges = Collections.emptyList();
        List<TermXRef> xrefs = Collections.emptyList();

        // new term
        if( Utils.defaultString(request.getParameter("act")).equals("new") ) {
            // new custom RDO term
            term = new Term();
            term.setAccId("select ontology");
            term.setCreatedBy(getCreatedBy(request));
            term.setCreationDate(new Date());
        }
        else {
            if( !(termAcc.startsWith("DOID:") || termAcc.startsWith("CHEBI:") || termAcc.startsWith("MP:")
                    || termAcc.startsWith("PW:") || termAcc.startsWith("CMO:") || termAcc.startsWith("MMO:")
                    || termAcc.startsWith("XCO:") || termAcc.startsWith("RS:") || termAcc.startsWith("HP:")) ) {
                throw new Exception("Term Edit is allowed only for DO+ (RDO), PW, MP, HP, RS, CMO, MMO, XCO and CHEBI ontologies!");
            }

            if( action.equals("update") ) {
                // generate unique id for new DO+ custom term
                if( termAcc.equals("DOID:9XXXXXX") ) {
                    termAcc = getUnusedCustomDoTermAcc(odao);

                }
                // generate unique id for new PW term
                else if( termAcc.equals("PW:XXXXXXX") ) {
                    termAcc = getUnusedPwTermAcc(odao);
                }
                else if( termAcc.equals("RS:XXXXXXX") ) {
                    termAcc = getUnusedRsTermAcc(odao);
                }
                else if( termAcc.equals("CMO:XXXXXXX") ) {
                    termAcc = getUnusedCmoTermAcc(odao);
                }
                else if( termAcc.equals("MMO:XXXXXXX") ) {
                    termAcc = getUnusedMmoTermAcc(odao);
                }
                else if( termAcc.equals("XCO:XXXXXXX") ) {
                    termAcc = getUnusedXcoTermAcc(odao);
                }
                synTabMsg += update(request, termAcc, odao);
                dagTabMsg += updateDags(request, termAcc, odao);
                xrefTabMsg += updateXrefs(request, termAcc, odao);
            }
            term = odao.getTermByAccId(termAcc);

            synonyms = odao.getTermSynonyms(termAcc);
            Collections.sort(synonyms, new Comparator<TermSynonym>() {
                @Override
                public int compare(TermSynonym o1, TermSynonym o2) {
                    String name1 = normalizeName(o1.getName());
                    String name2 = normalizeName(o2.getName());
                    return name1.compareTo(name2);
                }

                String normalizeName(String name) {
                    return name.toLowerCase().replaceAll("\\W", "");
                }
            });

            parentEdges = odao.getAncestorEdges(termAcc);

            xrefs = odao.getTermXRefs(termAcc);
        }

        ModelAndView mv = new ModelAndView("/WEB-INF/jsp/curation/edit/editTerm.jsp");
        mv.addObject("term", term);
        mv.addObject("synTabMsg", synTabMsg);
        mv.addObject("synonyms", synonyms);
        mv.addObject("synonymTypes", odao.getSynonymTypes(term.getOntologyId()));
        mv.addObject("xrefs", xrefs);
        mv.addObject("dags", parentEdges);
        mv.addObject("dagTabMsg", dagTabMsg);
        mv.addObject("xrefTabMsg", xrefTabMsg);
        if( statusMsg!=null ) {
            mv.addObject("statusMsg", statusMsg);
        }
        return mv;
    }

    String update(HttpServletRequest req, String termAcc, OntologyXDAO odao) throws Exception {

        String newTermName = Utils.defaultString(req.getParameter("name")).trim();

        // definition may not contain TAB, CR and NL characters -- they will be replaced with a single SPACE
        String newTermDef = Utils.defaultString(req.getParameter("def"))
                .replaceAll("[\\s]+", " ").trim();

        String newComment = Utils.defaultString(req.getParameter("comment"))
                .replaceAll("[\\s]+", " ").trim();

        Term term = odao.getTermByAccId(termAcc);
        if( term==null ) {
            if( !( termAcc.startsWith("DOID:9") || termAcc.startsWith("PW:") || termAcc.startsWith("RS:")
                || termAcc.startsWith("CMO:") ||termAcc.startsWith("MMO:") ||termAcc.startsWith("XCO:") ) ) {

                return "ERROR: you can create only DO+/PW/RS/MMO/CMO/XCO custom terms!";
            }

            String createdBy = getCreatedBy(req);
            if( createdBy.equals("rgd") ) {
                throw new Exception("ERROR: to insert new terms, please log in first!");
            }

            term = new Term();
            term.setAccId(termAcc);
            term.setTerm(newTermName);
            term.setDefinition(newTermDef);
            term.setComment(newComment);
            term.setCreatedBy(createdBy);

            term.setCreationDate(new Date());
            term.setModificationDate(new Date());

            if( termAcc.startsWith("DOID:") ) {
                term.setOntologyId("RDO");
            } else if( termAcc.startsWith("PW:") ) {
                term.setOntologyId("PW");
            } else if( termAcc.startsWith("RS:") ) {
                term.setOntologyId("RS");
            } else if( termAcc.startsWith("CMO:") ) {
                term.setOntologyId("CMO");
            } else if( termAcc.startsWith("MMO:") ) {
                term.setOntologyId("MMO");
            } else if( termAcc.startsWith("XCO:") ) {
                term.setOntologyId("XCO");
            }

            odao.insertTerm(term);
            term = odao.getTermByAccId(termAcc);
        }
        else {
            // check if term name or definition needs to be updated
            if( (termAcc.startsWith("DOID:") || termAcc.startsWith("PW:") || termAcc.startsWith("RS:")
                || termAcc.startsWith("CMO:") ||termAcc.startsWith("MMO:") ||termAcc.startsWith("XCO:")
            ) &&
               (!Utils.stringsAreEqual(newTermName, term.getTerm()) ||
                !Utils.stringsAreEqual(newTermDef, term.getDefinition()) ||
                !Utils.stringsAreEqual(newComment, term.getComment())) ) {

                // update term
                term.setTerm(newTermName);
                term.setDefinition(newTermDef);
                term.setComment(newComment);
                odao.updateTerm(term);
            }
        }

        // update synonyms
        //
        // collect incoming data
        String[] synKey = req.getParameterValues("syn_key");
        String[] synType = req.getParameterValues("syn_type");
        String[] synName = req.getParameterValues("syn_name");
        String[] synSource = req.getParameterValues("syn_source");
        String[] synDbxrefs = req.getParameterValues("syn_dbxrefs");

        String synTabMsg = "";
        if( synKey!=null ) {
            // handle synonyms to be deleted
            for( int i=0; i<synKey.length; i++ ) {
                int key = Integer.parseInt(synKey[i]);
                if( key<=0 )  // this synonym must have been in RGD to be deleted
                    continue;
                // and it must be checked for delete
                String name = "syn_del"+i;
                if( !Utils.isStringEmpty(req.getParameter(name)) ) {
                    synTabMsg += "deleted synonym ["+synName[i]+"] ("+synType[i]+") {"+synSource[i]+"}<br>";
                    odao.dropTermSynonym(key);
                }
            }

            // handle synonyms to be inserted
            for( int i=0; i<synKey.length; i++ ) {
                int key = Integer.parseInt(synKey[i]);
                if( key>0 )  // this synonym must not have been in RGD
                    continue;
                // and it must be not checked for delete
                String name = "syn_delm"+(-key);
                if( !Utils.isStringEmpty(req.getParameter(name)) ) {
                    continue;
                }

                TermSynonym ts = new TermSynonym();
                ts.setCreatedDate(new Date());
                ts.setDbXrefs(synDbxrefs[i]);
                ts.setLastModifiedDate(new Date());
                ts.setName(synName[i].trim());
                ts.setType(synType[i].trim());
                ts.setSource(synSource[i].trim());
                ts.setTermAcc(termAcc);

                // synonym type, name and source must not be null
                if( Utils.isStringEmpty(ts.getName()) || Utils.isStringEmpty(ts.getType()) || Utils.isStringEmpty(ts.getSource()) ) {
                    synTabMsg += "ERROR: can't insert synonym with empty name, type or source!<br>";
                } else {
                    odao.insertTermSynonym(ts);
                    synTabMsg += "inserted synonym ["+synName[i]+"] ("+synType[i]+") {"+synSource[i]+"}<br>";
                }
            }


            // handle synonyms to be updated
            List<TermSynonym> synonymsInRgd = odao.getTermSynonyms(termAcc);
            for( int i=0; i<synKey.length; i++ ) {
                int key = Integer.parseInt(synKey[i]);
                if( key<=0 )  // this synonym must have been in RGD to be updatable
                    continue;
                // and it must NOT be checked for delete
                String name = "syn_del"+i;
                String val = req.getParameter(name);
                if( !Utils.isStringEmpty(val) ) {
                    continue;
                }

                TermSynonym ts = new TermSynonym();
                ts.setKey(key);
                ts.setDbXrefs(synDbxrefs[i]);
                ts.setLastModifiedDate(new Date());
                ts.setName(synName[i].trim());
                ts.setType(synType[i].trim());
                ts.setSource(synSource[i].trim());
                ts.setTermAcc(termAcc);

                // find if this synonym is in rgd
                Iterator<TermSynonym> it = synonymsInRgd.iterator();
                while( it.hasNext() ) {
                    TermSynonym tsInRgd = it.next();
                    if( tsInRgd.getKey()==key ) {
                        it.remove();
                        // is the incoming synonym in need of update?
                        if( !tsInRgd.equals(ts) ||
                            !Utils.stringsAreEqual(ts.getSource(), tsInRgd.getSource()) ||
                            !Utils.stringsAreEqual(ts.getDbXrefs(), tsInRgd.getDbXrefs()) ) {

                            if( Utils.isStringEmpty(ts.getName()) || Utils.isStringEmpty(ts.getType()) || Utils.isStringEmpty(ts.getSource()) ) {
                                synTabMsg += "ERROR: can't update synonym with empty name, type or source!<br>";
                            } else {
                                synTabMsg += "updated synonym NEW ["+synName[i]+"] ("+synType[i]+") {"+synSource[i]+"}<br>";
                                synTabMsg += "                OLD ["+tsInRgd.getName()+"] ("+tsInRgd.getType()+") {"+tsInRgd.getSource()+"}<br>";

                                odao.updateTermSynonym(ts);
                            }
                        }
                        break;
                    }
                }
            }
        }

        return synTabMsg;
    }

    String updateXrefs(HttpServletRequest req, String termAcc, OntologyXDAO odao) throws Exception {
        // update definition xrefs
        //
        // collect incoming data
        String[] xrefKey = req.getParameterValues("xref_key");
        String[] xrefValue = req.getParameterValues("xref_value");
        String[] xrefInfo = req.getParameterValues("xref_info");

        if( xrefKey==null ) {
            return "";
        }

        String xrefTabMsg = "";

        // handle xrefs to be deleted
        for( int i=0; i<xrefKey.length; i++ ) {
            int key = Integer.parseInt(xrefKey[i]);
            if( key<=0 )  // this xref must have been in RGD to be deleted
                continue;
            // and it must be checked for delete
            String name = "xref_del"+i;
            if( !Utils.isStringEmpty(req.getParameter(name)) ) {
                xrefTabMsg += "deleted xref ["+xrefValue[i]+"] {"+xrefInfo[i]+"}<br>";
                TermXRef xref = new TermXRef();
                xref.setKey(key);
                odao.deleteTermXRef(xref);
            }
        }

        // handle xrefs to be inserted
        for( int i=0; i<xrefKey.length; i++ ) {
            int key = Integer.parseInt(xrefKey[i]);
            if( key>0 )  // this xref must not have been in RGD
                continue;
            // and it must be not checked for delete
            String name = "xref_delm"+(-key);
            if( !Utils.isStringEmpty(req.getParameter(name)) ) {
                continue;
            }

            TermXRef xref = new TermXRef();
            xref.setTermAcc(termAcc);
            xref.setXrefValue(xrefValue[i].trim());
            xref.setXrefDescription(xrefInfo[i].trim());

            // xref value must be non-empty
            if( Utils.isStringEmpty(xref.getXrefValue()) ) {
                xrefTabMsg += "ERROR: can't insert an empty xref!<br>";
            } else if( !xref.getXrefValue().contains(":") ) {
                xrefTabMsg += "ERROR: xref must contain a colon ':' !<br>";
            } else {
                odao.insertTermXRef(xref);
                xrefTabMsg += "inserted xref ["+xrefValue[i]+"] {"+xrefInfo[i]+"}<br>";
            }
        }

        // handle xrefs to be updated
        List<TermXRef> xrefsInRgd = odao.getTermXRefs(termAcc);
        for( int i=0; i<xrefKey.length; i++ ) {
            int key = Integer.parseInt(xrefKey[i]);
            if( key<=0 )  // this xref must have been in RGD to be updatable
                continue;
            // and it must NOT be checked for delete
            String name = "xref_del"+i;
            String val = req.getParameter(name);
            if( !Utils.isStringEmpty(val) ) {
                continue;
            }

            TermXRef xref = new TermXRef();
            xref.setKey(key);
            xref.setTermAcc(termAcc);
            xref.setXrefValue(xrefValue[i].trim());
            xref.setXrefDescription(xrefInfo[i].trim());

            // find if this xref is in rgd
            Iterator<TermXRef> it = xrefsInRgd.iterator();
            while( it.hasNext() ) {
                TermXRef xrefInRgd = it.next();
                if( xrefInRgd.getKey()==key ) {
                    it.remove();
                    // is the incoming xref in need of update?
                    if( !xrefInRgd.equals(xref) ||
                        !Utils.stringsAreEqual(xrefInRgd.getXrefDescription(), xref.getXrefDescription()) ) {

                        if( Utils.isStringEmpty(xref.getXrefValue()) ) {
                            xrefTabMsg += "ERROR: can't update xref with empty value!<br>";
                        } else if( !xref.getXrefValue().contains(":") ) {
                            xrefTabMsg += "ERROR: xref must contain a colon ':' !<br>";
                        } else {
                            xrefTabMsg += "updated xref NEW ["+xrefValue[i]+"] {"+xrefInfo[i]+"}<br>";
                            xrefTabMsg += "             OLD ["+xrefInRgd.getXrefValue()+"] {"+xrefInRgd.getXrefDescription()+"}<br>";

                            odao.updateTermXRef(xref);
                        }
                    }
                    break;
                }
            }
        }
        return xrefTabMsg;
    }

    String getUnusedCustomDoTermAcc(OntologyXDAO dao) throws Exception {
        String sql = "SELECT * FROM (\n" +
                "SELECT 'DOID:9'||lpad(-1+to_number(substr(term_acc,7)),6,'0') FROM ont_terms t1\n" +
                "WHERE ont_id='RDO' AND term_acc like 'DOID:9______' AND term_acc<>'DOID:9000000'\n" +
                "AND NOT EXISTS\n" +
                "(SELECT 1 FROM ont_terms t2 WHERE t2.term_acc='DOID:9'||lpad(-1+to_number(substr(t1.term_acc,7)),6,'0'))\n" +
                "UNION ALL\n" +
                "SELECT 'DOID:9'||lpad(1+to_number(substr(term_acc,7)),6,'0') FROM ont_terms t1\n" +
                "WHERE term_acc=(SELECT MAX(term_acc) FROM ont_terms WHERE ont_id='RDO' AND term_acc like 'DOID:9______')\n" +
                ") ORDER BY DBMS_RANDOM.RANDOM";

        String acc1 = Utils.NVL(StringListQuery.execute(dao, sql).get(0), "DOID:9000000");
        String acc2 = Utils.NVL(StringListQuery.execute(dao, sql).get(0), "DOID:9000000");
        // return a smaller term acc from two random picks
        return acc1.compareTo(acc2)<0 ? acc1 : acc2;
    }

    String getUnusedPwTermAcc(OntologyXDAO dao) throws Exception {
        String sql = "SELECT MIN('PW:'||lpad(1+to_number(substr(term_acc,4)),7,'0')) FROM ont_terms t1\n" +
                "WHERE term_acc=(SELECT MAX(term_acc) FROM ont_terms WHERE term_acc LIKE 'PW:_______')";
        return Utils.NVL(StringListQuery.execute(dao, sql).get(0), "PW:0000000");
    }

    String getUnusedRsTermAcc(OntologyXDAO dao) throws Exception {
        String sql = "SELECT MIN('RS:'||lpad(1+to_number(substr(term_acc,4)),7,'0')) FROM ont_terms t1\n" +
                "WHERE term_acc=(SELECT MAX(term_acc) FROM ont_terms WHERE term_acc LIKE 'RS:_______')";
        return Utils.NVL(StringListQuery.execute(dao, sql).get(0), "RS:0000000");
    }

    String getUnusedCmoTermAcc(OntologyXDAO dao) throws Exception {
        String sql = "SELECT MIN('CMO:'||lpad(1+to_number(substr(term_acc,5)),7,'0')) FROM ont_terms t1\n" +
                "WHERE term_acc=(SELECT MAX(term_acc) FROM ont_terms WHERE term_acc LIKE 'CMO:_______')";
        return Utils.NVL(StringListQuery.execute(dao, sql).get(0), "CMO:0000000");
    }

    String getUnusedMmoTermAcc(OntologyXDAO dao) throws Exception {
        String sql = "SELECT MIN('MMO:'||lpad(1+to_number(substr(term_acc,5)),7,'0')) FROM ont_terms t1\n" +
                "WHERE term_acc=(SELECT MAX(term_acc) FROM ont_terms WHERE term_acc LIKE 'MMO:_______')";
        return Utils.NVL(StringListQuery.execute(dao, sql).get(0), "MMO:0000000");
    }

    String getUnusedXcoTermAcc(OntologyXDAO dao) throws Exception {
        String sql = "SELECT MIN('XCO:'||lpad(1+to_number(substr(term_acc,5)),7,'0')) FROM ont_terms t1\n" +
                "WHERE term_acc=(SELECT MAX(term_acc) FROM ont_terms WHERE term_acc LIKE 'XCO:_______')";
        return Utils.NVL(StringListQuery.execute(dao, sql).get(0), "XCO:0000000");
    }

    String updateDags(HttpServletRequest req, String childTermAcc, OntologyXDAO odao) throws Exception {

        String dagTabMsg = "";

        // collect incoming data
        String[] dagTermAcc = req.getParameterValues("dag_term_acc"); // parent term acc
        String[] dagTypes = req.getParameterValues("dag_type"); // IA = 'is-a', PO = 'part-of'

        Ontology ontChild = odao.getOntologyFromAccId(childTermAcc);

        List<TermDagEdge> dagsInRgd = odao.getAncestorEdges(childTermAcc);

        if( dagTermAcc!=null ) {
            // handle dags to be added
            for( int i=0; i<dagTermAcc.length; i++ ) {
                String parentTermAcc = dagTermAcc[i];
                String dagType = dagTypes[i];

                // no support for cross-ontology relationships
                Ontology ontParent = odao.getOntologyFromAccId(parentTermAcc);
                if( !ontChild.getId().equals(ontParent.getId()) ) {
                    dagTabMsg += "WARN: cross-ontology relationships are not supported: "+parentTermAcc+" --- "+childTermAcc+"<br>";
                    continue;
                }

                // dag to be added must not be in RGD yet
                TermDagEdge dagInRgd = null;
                for( TermDagEdge dag: dagsInRgd ) {
                    if( dag.getParentTermAcc().equals(parentTermAcc) ) {
                        dagInRgd = dag;
                        break;
                    }
                }

                if( dagInRgd==null ) {
                    String relName = dagType;
                    if( odao.upsertDag(parentTermAcc, childTermAcc, relName) !=0 ) {
                        dagTabMsg += "INSERTED REL "+dagType+" to parent "+parentTermAcc+"<br>";
                    }
                }
                else {
                    // dag is not new -- see if it is marked for deletion
                    int colonPos = parentTermAcc.indexOf(':');
                    String delAcc = "dag_del_"+parentTermAcc.substring(1+colonPos);

                    if( !Utils.isStringEmpty(req.getParameter(delAcc)) ) {
                        // delete the dag!
                        if( odao.deleteDag(dagInRgd)!=0 ) {
                            dagTabMsg += "DELETED REL to parent "+parentTermAcc+"<br>";
                        }
                    } else {
                        // see if dag type changed
                        String dagTypeInRgd = dagInRgd.getRelId();
                        if( !dagTypeInRgd.equals(dagType) ) {
                            if( odao.upsertDag(parentTermAcc, childTermAcc, dagType) ==0 ) {
                                dagTabMsg += "UPDATED REL type to "+dagType+" for parent "+parentTermAcc+"<br>";
                            }
                        }
                    }
                }

            }
        }
        return dagTabMsg;
    }

    Term deleteTerm(String termAcc) throws Exception {

        OntologyXDAO dao = new OntologyXDAO();

        // the term must not have any parent/child relationships
        if( dao.getCountOfAncestors(termAcc)!=0 || dao.getCountOfDescendants(termAcc)!=0 ) {
            throw new Exception("Cannot delete a term "+termAcc+" having relationships!");
        }

        Term term = dao.getTermByAccId(termAcc);

        // drop synonyms
        List<TermSynonym> synonyms = dao.getTermSynonyms(termAcc);
        if( !synonyms.isEmpty() ) {
            dao.deleteTermSynonyms(synonyms);
        }

        // drop the term itself
        String sql = "DELETE FROM ont_terms WHERE term_acc=?";
        dao.update(sql, termAcc);

        return term;
    }

    Term obsoleteTerm(String termAcc) throws Exception {

        OntologyXDAO dao = new OntologyXDAO();

        // the term must not have any parent/child relationships
        if( dao.getCountOfAncestors(termAcc)!=0 || dao.getCountOfDescendants(termAcc)!=0 ) {
            throw new Exception("Cannot obsolete a term "+termAcc+" having relationships!");
        }

        Term term = dao.getTermByAccId(termAcc);

        if( term.isObsolete() ) {
            throw new Exception("Cannot obsolete a term "+termAcc+" because it is already obsolete!");
        }

        // obsolete the term
        String sql = "UPDATE ont_terms SET is_obsolete=4,modification_date=SYSDATE WHERE term_acc=?";
        dao.update(sql, termAcc);

        term.setObsolete(4);
        term.setModificationDate(new Date());
        return term;
    }

    public static String getCreatedBy(HttpServletRequest req) throws Exception {
        /* old code -- used by MyRgd -- does not work anymore
        Principal p = req.getUserPrincipal();
        if( p==null ) {
            return "rgd";
        }
        String name = p.getName();
        int atPos = name.indexOf('@');
        if( atPos>0 ) {
            return name.substring(0, atPos);
        } else {
            return name;
        }
        */

        String loginFromSession = (String) req.getSession().getAttribute("login");
        if( loginFromSession!=null && loginFromSession.length()>0 ) {
            return loginFromSession;
        }

        String token = req.getParameter("token");
        if( token==null || token.length()<10 ) {
            token = req.getParameter("accessToken");
        }
        if( token==null || token.length()<10 ) {
            return "rgd"; // no authentication: default is 'rgd'
        }

        URL url = new URL("https://api.github.com/user");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestProperty("User-Agent", "Mozilla/5.0");
        conn.setRequestProperty("Authorization", "Token " + token);

        try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
            String line = in.readLine();
            System.out.println(line);
            // the response is json, and it looks like this:
            // {"login":"tutajm","id:3s.....
            String loginTemplate = "\"login\":\"";
            int loginPos = line.indexOf("\"login\":\"");
            if (loginPos > 0) {
                loginPos += loginTemplate.length(); // point to start of login name
                int loginPos2 = line.indexOf("\"", loginPos);
                if (loginPos2 > loginPos) {
                    String loginStr = line.substring(loginPos, loginPos2);

                    req.getSession().setAttribute("login", loginStr);
                    return loginStr;
                }
            }
            return "rgd";// no authentication: default is 'rgd'
        }
    }
}
