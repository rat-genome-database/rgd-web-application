package edu.mcw.rgd.phenominer.frontend;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.ontologyx.Relation;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.ontologyx.TermWithStats;
import edu.mcw.rgd.process.Utils;
import org.apache.commons.collections4.CollectionUtils;

//add collections 4
import java.util.*;

/**
 * @author mtutaj
 * @since 6/12/2017
 * <p>
 * Ontology trees used by phenominer
 */
public class OTrees {
    OntologyXDAO odao = new OntologyXDAO();
    PhenominerDAO pdao = new PhenominerDAO();

    private Map<String, OTree> oTrees = new HashMap<>();

    private static final OTrees _instance = new OTrees();

    // private constructor to force instantiation via getInstance() method
    private OTrees() {}

    // singleton
    public static OTrees getInstance() {
        return _instance;
    }

    // generate XML representation of given ontology tree
    public String generateXml(String ontId, String sex, int speciesTypeKey) throws Exception {
        OTree tree = getOTree(ontId, sex, speciesTypeKey);
     //   System.out.println("in generate xml with ontId " + ontId);
        return tree.generateXml(null);
    }

    // generate XML representation of an ontology subtree identified by ontology and set of filter terms
    public String generateXml(String ontId, String sex, int speciesTypeKey, String terms) throws Exception {

        OTree subtree = getFilteredTree(ontId, sex, speciesTypeKey, terms);
        return subtree.generateXml(subtree.selectedTerms);
    }

    public OTree getFilteredTree(String ontId, String sex, int speciesTypeKey, String terms) throws Exception {

        // group filter terms by ontology
        Map<String, Set<String>> filterTermsByOnt = splitTermsByOntology(terms);

        // get the to-be-selected terms
        Set<String> selectedTerms = filterTermsByOnt.get(ontId);
        if( selectedTerms!=null ) {
            filterTermsByOnt.remove(ontId);
        }

        // if all selected terms come from the same ontology as the tree, show the entire tree
        if( filterTermsByOnt.isEmpty() ) {
            // create a ontology subtree based on the record ids
            OTree tree = getOTree(ontId, sex, speciesTypeKey);
            tree.selectedTerms = selectedTerms;
            return tree;
        }

        // determine record ids matching the ontology filters
        // note: if multiple ontologies are in the filter, INTERSECT operation must be applied
        Collection<Integer> recordIds = null;
        for( Map.Entry<String, Set<String>> entry: filterTermsByOnt.entrySet() ) {
            String filterOntId = entry.getKey();
            OTree oTree = getOTree(filterOntId, null, speciesTypeKey);
            Set<Integer> recordIdsForOneOnt = oTree.getRecordIdsForTermsOnly(entry.getValue());
            if( recordIds==null ) {
                recordIds = recordIdsForOneOnt;
            } else {
                recordIds = CollectionUtils.intersection(recordIds, recordIdsForOneOnt);

            }
        }

        // create a ontology subtree based on the record ids
        OTree tree = getOTree(ontId, sex, speciesTypeKey);
        OTree subtree = tree.getSubtree(recordIds);
        subtree.selectedTerms = selectedTerms;
        return subtree;
    }

    public int getRecordCount(String termAcc, String sex, int speciesTypeKey) throws Exception {
        String ont = getOntFromTermAcc(termAcc);
        OTree oTree = getOTree(ont, sex, speciesTypeKey);
        return oTree.getRecordCount(termAcc);
    }

    public String getTermName(String termAcc, String sex, int speciesTypeKey) throws Exception {
        String ont = getOntFromTermAcc(termAcc);
        OTree oTree = getOTree(ont, sex, speciesTypeKey);
        OTerm term = oTree.terms.get(termAcc);
        return term==null ? "" : term.termName;
    }

    String getOntFromTermAcc(String termAcc) {
        // determine ontology based on term acc
        String ontId = "";
        if( termAcc.startsWith("RS:") ) {
            ontId = "RS";
        } else if( termAcc.startsWith("MMO:") ) {
            ontId = "MMO";
        } else if( termAcc.startsWith("CMO:") ) {
            ontId = "CMO";
        } else if( termAcc.startsWith("XCO:") ) {
            ontId = "XCO";
        } else if( termAcc.startsWith("CS:") ) {
            ontId = "CS";
        } else if( termAcc.startsWith("VT:") ) {

        ontId = "VT";
        }


        return ontId;
    }

    Map<String, Set<String>> splitTermsByOntology(String filterTerms) {
        if( filterTerms.isEmpty() ) {
            return null;
        }

        Map<String, Set<String>> ontologyLists = new HashMap<>(); // map ontology id to list of terms in that ontology
        String[] termAccs = filterTerms.split(",");
        for (String termAcc : termAccs) {
            // determine ontology based on term acc
            String ontId = getOntFromTermAcc(termAcc);

            // add the term to the ontology
            Set<String> termAccsPerOnt = ontologyLists.get(ontId);
            if( termAccsPerOnt==null ) {
                termAccsPerOnt = new HashSet<>();
                ontologyLists.put(ontId, termAccsPerOnt);
            }
            termAccsPerOnt.add(termAcc);
        }
        return ontologyLists.isEmpty() ? null : ontologyLists;
    }

    public synchronized OTree getOTree(String ontId, String sex, int speciesTypeKey) throws Exception {
        String key = ontId+sex+speciesTypeKey;
        OTree oTree = oTrees.get(key);
        if( oTree==null ) {
            oTree = new OTree(ontId, sex, speciesTypeKey);
            oTree.initFromDb();
            oTrees.put(key, oTree);
        }
        // patch: should not happen
        if( oTree.rootNode.oTerm==null ) {
            String rootTermAcc = odao.getRootTerm(ontId);
            oTree.rootNode.oTerm = oTree.loadTerm(rootTermAcc);
        }
        return oTree;
    }

    class OTerm {
        public String accId;
        public String termName;
        public Collection<Integer> recordIds; // record ids for term and child terms
        public Collection<Integer> recordIdsForTermOnly;
    }

    class ONode {
        public OTerm oTerm;
        public List<ONode> children;

        public ONode(OTerm oTerm) {
            this.oTerm = oTerm;
        }

        public void addChild(ONode node) {
            if( children==null ) {
                children = new ArrayList<>();
            }
            children.add(node);
        }

        // sort child nodes by term name
        public void sortChildNodes() {
            if( children!=null && children.size()>1 ) {
                Collections.sort(children, new Comparator<ONode>() {
                    @Override
                    public int compare(ONode o1, ONode o2) {
                        return Utils.stringsCompareToIgnoreCase(o1.oTerm.termName, o2.oTerm.termName);
                    }
                });
            }
        }
    }

    // ontology tree
    public class OTree {
        private String ontId; // f.e. 'RS', 'MMO'
        private String sex; // null, 'male', 'female'
        private int speciesTypeKey;
        private Map<String,OTerm> terms = new HashMap<>(); // (term acc id, OTerm)
        private ONode rootNode; // root node of the ontology tree

        public Collection<String> selectedTerms; // set for a subtree

        public OTree(String ontId, String sex, int speciesTypeKey) {
            this.ontId = ontId;
            this.sex = sex;
            this.speciesTypeKey = speciesTypeKey;
        }

        public void initFromDb() throws Exception {
            String rootTermAcc = odao.getRootTerm(ontId);
            System.out.println("loading " + rootTermAcc + " for " + ontId);
            rootNode = new ONode(loadTerm(rootTermAcc));
            System.out.println(rootNode);
            System.out.println(rootTermAcc);
            loadTerms(rootNode, rootTermAcc);
        }

        // get record count for root node
        public int getRecordCount() throws Exception {
            String rootTermAcc = rootNode.oTerm.accId;
            return getRecordCount(rootTermAcc);
        }

        // get record count for term and child terms for any node
        public int getRecordCount(String termAcc) throws Exception {
            OTerm term = terms.get(termAcc);
            return term==null ? 0 : term.recordIds.size();
        }

        public int getRecordCountForTermOnly() throws Exception {
            Set<Integer> recIds1 = new HashSet<>();
            if( selectedTerms!=null ) {
                for (String termAcc : selectedTerms) {
                    OTerm ot = terms.get(termAcc);
                    if (ot != null) {
                        if (ot.recordIds != null) {
                            recIds1.addAll(ot.recordIds);
                        }
                    }
                }
            }
            //System.out.println("c1="+recIds1.size());
            return recIds1.size();
        }

        public int getRecordCountForTermOnly(String termAcc) throws Exception {
            OTerm term = terms.get(termAcc);
            return term==null ? 0 : term.recordIdsForTermOnly.size();
        }

        void loadTerms(ONode node, String parentTermAcc) throws Exception {

            Map<String, Relation> childTerms = odao.getTermDescendants(parentTermAcc);

            for( String termAcc: childTerms.keySet() ) {

                OTerm o = loadTerm(termAcc);
                if( o!=null ) {
                    ONode childNode = new ONode(o);
                    node.addChild(childNode);
                    loadTerms(childNode, termAcc);
                }
            }

            // sort child nodes by term name
            node.sortChildNodes();
        }

        OTerm loadTerm(String accId) throws Exception {

            OTerm o = terms.get(accId);
            if( o==null ) {

                List<Integer> recordIds = pdao.getRecordIdsForTermAndDescendantsCached(accId, sex, speciesTypeKey);
                if( recordIds==null || recordIds.isEmpty() ) {
                    //System.out.println(" no record ids for "+accId);
                    return null;
                }

                //System.out.println(" rec ids for "+accId+": "+recordIds.size());
                o = new OTerm();
                o.accId = accId;
                TermWithStats term = odao.getTermWithStatsCached(accId);
                o.termName = term.getTerm();
                o.recordIds = recordIds;
                o.recordIdsForTermOnly = pdao.getRecordIdsForTermOnly(accId, sex, speciesTypeKey);
                terms.put(accId, o);
            } else {
                //System.out.println("term "+accId+" in already in hash");
            }
            return o;
        }

        void generateXml(ONode parentNode, Map<String,Integer> termCounts, int level, StringBuilder out, Collection<String> selectedTerms) throws Exception {

          //  System.out.println("parent Node " + parentNode);
            List<ONode> nodes = parentNode.children;
            for( ONode node: nodes ) {

                int recordCount = 0;
                if(node.oTerm!=null && node.oTerm.recordIds!=null)
                      recordCount=  node.oTerm.recordIds.size();

                // we got an annotated term! compute unique id for the term
                assert node.oTerm != null;
                String id = getUniqueId(node.oTerm.accId, termCounts);

                String text = node.oTerm.termName+"("+recordCount+")";

                boolean outputLeafTerm = node.children!=null && node.oTerm.recordIdsForTermOnly.size()>0;

                // pad output with spaces
                padWithSpaces(out, level);
                out.append("<item id=\"").append(id).append("\" text=\"").append(text).append("\"");
                if( !outputLeafTerm && selectedTerms!=null && selectedTerms.contains(node.oTerm.accId) ) {
                    out.append(" checked=\"1\"");
                }
                out.append(">\n");

                // handle child terms
                if( node.children!=null ) {
                    // output this term additionally as a leaf if it has term-only annotations
                    if( node.oTerm.recordIdsForTermOnly.size()>0 ) {
                        // pad output with spaces
                        padWithSpaces(out, level+1);

                        id = getUniqueId(node.oTerm.accId, termCounts);
                        text = node.oTerm.termName+"("+node.oTerm.recordIdsForTermOnly.size()+")";

                        out.append("<item id=\"").append(id).append("\" text=\"").append(text).append("\"");
                        if (selectedTerms != null && selectedTerms.contains(node.oTerm.accId)) {
                            out.append(" checked=\"1\"");
                        }
                        out.append("/>\n");
                    }

                    generateXml(node, termCounts, level + 1, out, selectedTerms);
                }

                // finish the current item
                padWithSpaces(out, level);
                out.append("</item>\n");
            }
        }

        String getUniqueId(String termAcc, Map<String,Integer> termCounts) {
            // we got an annotated term! compute unique id for the term
            Integer cnt = termCounts.get(termAcc);
            if (cnt == null) {
                cnt = 1;
            } else {
                cnt++;
            }
            termCounts.put(termAcc, cnt);
            String id = termAcc+"_"+cnt;
            return id;
        }

        void padWithSpaces(StringBuilder out, int level) {
            for (int i = 0; i < level; i++) {
                out.append("  ");
            }
        }

        String generateXml(Collection<String> selectedTerms) throws Exception {

            StringBuilder out = new StringBuilder("<tree id='0'>\n");

            Map<String,Integer> termCounts = new HashMap<>(); // how many times given term appears in the xml tree
           // System.out.println("child size = " + rootNode.children.size());
            generateXml(rootNode, termCounts, 1, out, selectedTerms);
            out.append("</tree>\n");

            return out.toString();
        }

        Set<Integer> getRecordIdsForTerms(Set<String> termAccs) {
            Set<Integer> recordIds = new HashSet<>();
            for( String termAcc: termAccs ) {
                OTerm oTerm = terms.get(termAcc);
                if( oTerm!=null ) {
                    recordIds.addAll(oTerm.recordIds);
                }
            }
            return recordIds;
        }

        Set<Integer> getRecordIdsForTermsOnly(Set<String> termAccs) {
            Set<Integer> recordIds = new HashSet<>();
            for( String termAcc: termAccs ) {
                OTerm oTerm = terms.get(termAcc);
                if( oTerm!=null ) {
                    recordIds.addAll(oTerm.recordIdsForTermOnly);
                }
            }
            return recordIds;
        }

        OTree getSubtree(Collection<Integer> recordIds) {
            OTree subtree = new OTree(ontId, sex, speciesTypeKey);

            // create root term
            OTerm term0 = new OTerm();
            term0.accId = rootNode.oTerm.accId;
            term0.termName = rootNode.oTerm.termName;
            term0.recordIds = new ArrayList<>(recordIds);

            // record ids for term only for tree without filters
            Collection<Integer> recIdsUnfiltered = terms.get(term0.accId).recordIdsForTermOnly;
            term0.recordIdsForTermOnly = CollectionUtils.intersection(recIdsUnfiltered, recordIds);

            subtree.terms.put(term0.accId, term0);

            ONode node0 = new ONode(term0);
            subtree.rootNode = node0;

            createSubtreeChildren(rootNode, node0, recordIds, subtree);

            return subtree;
        }

        void createSubtreeChildren(ONode parentNode, ONode parentSubtreeNode, Collection<Integer> recordIds, OTree subtree) {


            if( parentNode.children==null ) {
                return;
            }
            for( ONode node: parentNode.children ) {
                // does this node have shared record ids
                Collection<Integer> sharedRecordIds = CollectionUtils.intersection(node.oTerm.recordIds, recordIds);
                if( sharedRecordIds.isEmpty() ) {
                    continue; // no shared record ids
                }
                OTerm term = new OTerm();
                term.accId = node.oTerm.accId;
                term.termName = node.oTerm.termName;
                term.recordIds = sharedRecordIds;

                // record ids for term only for tree without filters
                Collection<Integer> recIdsUnfiltered = terms.get(term.accId).recordIdsForTermOnly;
                term.recordIdsForTermOnly = CollectionUtils.intersection(recIdsUnfiltered, recordIds);

                subtree.terms.put(term.accId, term);

                ONode subtreeNode = new ONode(term);
                parentSubtreeNode.addChild(subtreeNode);

                createSubtreeChildren(node, subtreeNode, recordIds, subtree);
            }
        }
    }
}
