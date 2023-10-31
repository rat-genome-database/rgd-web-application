package edu.mcw.rgd.ontology;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.datamodel.ontologyx.TermWithStats;
import edu.mcw.rgd.process.Utils;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.object.MappingSqlQuery;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.*;

/**
 * @author Admin
 * @since Mar 30, 2011
 */
public class OntDagUtils {

    OntologyXDAO dao = new OntologyXDAO();

    boolean termOrChildTermsHaveDiagrams(String accId) {
        TermWithStats ts = getTermWithStats(accId);
        return ts.getDiagramCount(1)>0;
    }

    void build(List<List<OntDagNode>> paths, List<OntDagNode> path, OntDagNode node, Map<String, List<Edge>> nodes) {

        // add the node to the path
        path.add(0, node);

        // examine all parent edges
        List<Edge> parentEdges = nodes.get(node.getTermAcc());
        // if there are no parent edges, we reached the top node
        // we have the complete path!
        if( parentEdges==null || parentEdges.isEmpty() ) {
            // add the parent node if not exists yet among nodes
            if( parentEdges==null ) {
                nodes.put(node.getTermAcc(), new LinkedList<Edge>());
            }
            paths.add(path);
            return;
        }

        // follow every parent edge
        List<OntDagNode> clonedPath;
        for( int i=0; i<parentEdges.size(); i++ ) {
            // every parent edge must have a separate path clone
            if( i < parentEdges.size()-1 ) {
                clonedPath = new LinkedList<OntDagNode>(path);
            }
            else {
                // the last parent edge will be using the original path
                clonedPath = path;
            }

            OntDagNode dagNode = new OntDagNode(parentEdges.get(i).parentTermAcc);
            // set the ontology relation id for this edge
            clonedPath.get(0).setOntRelId(parentEdges.get(i).ontRelId);
            build(paths, clonedPath, dagNode, nodes);
        }
    }

    /**
     * get term names and stats from database for all path nodes
     */
    void fillTerms(Set<String> termAccSet, List<List<OntDagNode>> paths, final String filter) throws Exception  {
        // validate parameters
        if( termAccSet.isEmpty() )
            return;

        // get term names for all terms used in paths
        String sql = "SELECT t.term_acc, t.term, t.is_obsolete "+
                "FROM ont_terms t WHERE t.term_acc IN("+ Utils.concatenate(termAccSet,",","'")+")";

        final Map<String,Object[]> map = new HashMap<String, Object[]>();
        MappingSqlQuery q = new MappingSqlQuery(dao.getDataSource(), sql) {
            @Override
            protected Object mapRow(ResultSet rs, int i) throws SQLException {
                String termAcc = rs.getString(1);
                TermWithStats ts = getTermWithStats(termAcc, null, filter);
                map.put(termAcc, new Object[]{
                        rs.getString(2), // term name
                        ts.getStat("annotated_object_count", SpeciesType.RAT, 0, 0, filter),
                        ts.getStat("annotated_object_count", 0, 0, 0, filter),
                        ts.getStat("annotated_object_count", 0, 0, 1, filter),
                        ts.getChildTermCount(),
                        rs.getInt(3)});
                return null;
            }
        };
        q.compile();
        q.execute();

        // now go through all paths and fill the term info
        for( List<OntDagNode> path: paths ) {
            for( OntDagNode node: path ) {
                Object[] vals = map.get(node.getTermAcc());
                if( vals==null )
                    continue; // no stats for given term? continue to the next node

                // species specific term stats
                node.setTerm(vals[0].toString());

                node.setRatAnnotCountForTerm((Integer)(vals[1]));
                node.setAnnotCountForTerm((Integer)(vals[2]));
                node.setAnnotCountForTermAndChilds((Integer)(vals[3]));
                node.setChildCount((Integer)(vals[4]));
                node.setObsolete(((Integer)(vals[5]))>0);
                node.setTerm(vals[0].toString());
            }
        }
        map.clear();
    }

/*
    public List<OntDagNode> getFilteredChildTerms(String rootTerm, String filter) throws Exception {

        boolean first = true;
        String sql = "";

        final List<OntDagNode> childTerms = this.getChildTerms(rootTerm);

        for (OntDagNode odn: childTerms) {

            if (!first) {
                sql += "union \n";
            }

            sql += "select fai.term_acc  from full_annot_index fai, full_annot fa where fa.full_annot_key=fai.full_annot_key and fai.TERM_ACC='" + odn.getTermAcc() + "' and fa.annotated_object_rgd_id in ("
                    + "select distinct annotated_object_rgd_id  from full_annot_index fai, full_annot fa where fai.TERM_ACC='" + filter + "' and fa.full_annot_key=fai.full_annot_key"
                    + ") and rownum =1 \n";

            first=false;
        }

        System.out.println(sql);


        final List<OntDagNode> list = new LinkedList<OntDagNode>();
        MappingSqlQuery q = new MappingSqlQuery(dao.getDataSource(), sql) {
            @Override
            protected Object mapRow(ResultSet rs, int i) throws SQLException {

                for (OntDagNode codn:childTerms) {
                    if (codn.getTermAcc().equals(rs.getString(1))) {
                        list.add(codn);
                    }

                }
                return null;
            }
        };
        //q.declareParameter(new SqlParameter(Types.VARCHAR));
        q.compile();
        q.execute();
        return list;

    }
*/

     public List<OntDagNode> getChildTerms(String termAcc, final String filter) throws Exception {

        // retrieve immediate children of the term
        String sql = "SELECT t.term_acc,term,ont_rel_id,is_obsolete "+
                "FROM ont_terms t,ont_dag "+
                "WHERE parent_term_acc=? AND child_term_acc=t.term_acc "+
                "ORDER BY term";

        final List<OntDagNode> list = new LinkedList<OntDagNode>();
        MappingSqlQuery q = new MappingSqlQuery(dao.getDataSource(), sql) {
            @Override
            protected Object mapRow(ResultSet rs, int i) throws SQLException {
                OntDagNode node = new OntDagNode(rs.getString(1));
                node.setTerm(rs.getString(2));
                node.setOntRelId(rs.getString(3));
                node.setObsolete(rs.getInt(4)>0);

                TermWithStats ts = getTermWithStats(node.getTermAcc(), null, filter);
                node.setChildCount(ts.getChildTermCount());

                list.add(node);
                return null;
            }
        };
        q.declareParameter(new SqlParameter(Types.VARCHAR));
        q.compile();
        q.execute(termAcc);
        return list;
    }

    TermWithStats getTermWithStats(String termAcc) {
        return getTermWithStats(termAcc, null, null);
    }

    TermWithStats getTermWithStats(String termAcc, String child, String filter) {
        try {
            return dao.getTermWithStatsCached(termAcc, null, filter);
        } catch(Exception e) {
            e.printStackTrace();
            return null;
        }
    }



    // loads stats for collection of OntDagNode objects
    public void loadStats(Collection<OntDagNode> nodes, String filter) throws Exception {

        // validate input parameters
        if( nodes==null || nodes.isEmpty() )
            return; // nothing to do

        // gather stats in batches of up to 1000 nodes
        final int batchSize = 1000;
        OntDagNode[] nodeArr = new OntDagNode[batchSize];
        int pos = 0;

        for( OntDagNode node: nodes ) {

            nodeArr[pos++] = node;

            // flush the batch?
            if( pos == batchSize ) {
                loadStats(nodeArr, filter);
                pos = 0; // start new batch
            }
        }

        // finish incomplete batch
        if( pos>0 ) {
            for( int i=pos; i<batchSize; i++ ) {
                nodeArr[i] = null;
            }

            loadStats(nodeArr, filter);
        }
    }

    void loadStats(OntDagNode[] nodes, String filter) throws Exception {

        for( OntDagNode node: nodes ) {

            if( node==null ) {
                continue;
            }

            TermWithStats ts = getTermWithStats(node.getTermAcc(), null, filter);
            node.setChildCount(ts.getChildTermCount());
            node.setRatAnnotCountForTerm(ts.getStat("annotated_object_count", SpeciesType.RAT, 0, 0, filter));
            node.setAnnotCountForTerm(ts.getStat("annotated_object_count", 0, 0, 0, filter));
            node.setAnnotCountForTermAndChilds(ts.getStat("annotated_object_count", 0, 0, 1, filter));
        }
    }

    class Edge {
        public String parentTermAcc;
        //public String childTermAcc;
        public String ontRelId;
    }

}