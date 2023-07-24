package edu.mcw.rgd.gviewer;

import edu.mcw.rgd.process.mapping.MapManager;
import jakarta.servlet.ServletRequest;

import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: 8/14/12
 * Time: 8:16 AM
 */
public class GViewerBean {

    private String[] terms;
    private String[] onts;
    private String[] ops;
    private List<String[]> lines; // term lines
    private String color;
    private String speciesType;

    public void loadParametersFromRequest(ServletRequest request) {

        this.setTerms(request.getParameterValues("term[]"));
        this.setOps(request.getParameterValues("op[]"));

        String[] o1 = request.getParameterValues("go[]");
        String[] o2 = request.getParameterValues("do[]");
        String[] o3 = request.getParameterValues("wo[]");
        String[] o4 = request.getParameterValues("bo[]");
        String[] o5 = request.getParameterValues("po[]");

        String[] o6 = request.getParameterValues("cmo[]");
        String[] o7 = request.getParameterValues("mmo[]");
        String[] o8 = request.getParameterValues("xco[]");
        String[] o9 = request.getParameterValues("vt[]");
        String[] o10 = request.getParameterValues("chebi[]");
        String[] o11 = request.getParameterValues("rs[]");

        String[] onts = new String[o1.length];
        for( int i=0; i<o1.length; i++ ) {
            String ont = "";
            if( !o1[i].equals("-1") )
                ont += "," + o1[i];
            if( o2!=null && i<o2.length && !o2[i].equals("-1") )
                ont += "," + o2[i];
            if( o3!=null && i<o3.length && !o3[i].equals("-1") )
                ont += "," + o3[i];
            if( o4!=null && i<o4.length && !o4[i].equals("-1") )
                ont += "," + o4[i];
            if( o5!=null && i<o5.length && !o5[i].equals("-1") )
                ont += "," + o5[i];

            if( o6!=null && i<o6.length && !o6[i].equals("-1") )
                ont += "," + o6[i];
            if( o7!=null && i<o7.length && !o7[i].equals("-1") )
                ont += "," + o7[i];
            if( o8!=null && i<o8.length && !o8[i].equals("-1") )
                ont += "," + o8[i];
            if( o9!=null && i<o9.length && !o9[i].equals("-1") )
                ont += "," + o9[i];
            if( o10!=null && i<o10.length && !o10[i].equals("-1") )
                ont += "," + o10[i];
            if( o11!=null && i<o11.length && !o11[i].equals("-1") )
                ont += "," + o11[i];

            if( !ont.isEmpty() )
                onts[i] = "'"+ont.substring(1).replace(",","','")+"'";
        }
        this.setOnts(onts);

        this.setColor(request.getParameter("color"));
        this.setSpeciesType(request.getParameter("speciesType"));
    }

    public String buildSqlForAnnotations() {

        StringBuilder sql = new StringBuilder();

        for( int i=0; i<terms.length; i++ ) {
            sql.append("SELECT annotated_object_rgd_id rgd_id,NVL(object_symbol,object_name) object_symbol,DECODE(rgd_object_key,1,'gene',6,'qtl','strain') object_type\n");
            sql.append("FROM full_annot a,ont_terms t\n");
            sql.append("WHERE rgd_object_key IN(1,5,6)\n");
            sql.append(" AND a.term_acc=t.term_acc AND t.is_obsolete=0 \n");
            sql.append(" AND EXISTS(SELECT 1 FROM ont_term_stats2 s WHERE s.term_acc=t.term_acc AND stat_name='annotated_object_count' AND with_children>0) \n");
            sql.append(" AND a.term_acc in (\n");
            sql.append("    SELECT child_term_acc FROM ont_dag \n");
            sql.append("    START WITH child_term_acc IN(\n");
            sql.append("      SELECT term_acc FROM ont_terms t\n");
            sql.append("      WHERE (upper(t.term) like upper('%"+terms[i]+"%')\n");
            sql.append("             and t.ont_id in ("+onts[i]+"))\n");
            sql.append("    ) CONNECT BY PRIOR child_term_acc=parent_term_acc\n");
            sql.append(")\n");

            if( ops!=null && i<ops.length ) {
                if( ops[i].equals("AND") )
                    sql.append("INTERSECT \n");
                else if( ops[i].equals("OR") )
                    sql.append("UNION \n");
                else if( ops[i].equals("AND NOT") )
                    sql.append("MINUS \n");
            }
        }

        return sql.toString();
    }

    public String buildSqlForGViewerAnnotations() throws Exception{
        return buildSqlForGViewerAnnotations(MapManager.getInstance().getReferenceAssembly(3).getKey());
    }

    public String buildSqlForGViewerAnnotations(int mapKey) {

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT DISTINCT m.chromosome,m.start_pos,m.stop_pos,z.rgd_id,z.object_symbol,z.object_type \n");
        sql.append("FROM maps_data m,(\n").append(buildSqlForAnnotations()).append(")z\n");
        sql.append("WHERE z.rgd_id=m.rgd_id AND m.map_key=" + mapKey + "\n");
        sql.append("ORDER BY z.object_type,z.object_symbol");

        return sql.toString();
    }

    public String buildSqlForTerm(int termIndex) {

        StringBuilder sql = new StringBuilder();

        sql.append("SELECT DISTINCT a.annotated_object_rgd_id rgd_id,t.term_acc,t.term\n");
        sql.append("FROM full_annot a,ont_terms t\n");
        sql.append("WHERE rgd_object_key IN(1,5,6)\n");
        sql.append(" AND a.term_acc=t.term_acc AND t.is_obsolete=0 \n");
        //sql.append(" AND NVL(s.rat_annots_with_children,0)+NVL(s.mouse_annots_with_children,0)+NVL(s.human_annots_with_children,0)>0 \n");
        sql.append(" AND EXISTS(SELECT 1 FROM ont_term_stats2 s WHERE s.term_acc=t.term_acc AND stat_name='annotated_object_count' AND with_children>0) \n");
        sql.append(" AND t.term_acc in (\n");
        sql.append("    SELECT child_term_acc FROM ont_dag \n");
        sql.append("    START WITH child_term_acc IN(\n");
        sql.append("      SELECT term_acc FROM ont_terms t\n");
        sql.append("      WHERE (upper(t.term) like upper('%"+terms[termIndex]+"%')\n");
        sql.append("             and t.ont_id in ("+onts[termIndex]+"))\n");
        sql.append("    ) CONNECT BY PRIOR child_term_acc=parent_term_acc\n");
        sql.append(")\n");
        sql.append("ORDER BY a.annotated_object_rgd_id\n");

        return sql.toString();
    }

    /**
     * gviewer has a feature to add a custom object by searching for ontology term;
     * this query returns all terms, with annotations, within the set of supported ontologies
     * @return
     */
    public String buildSqlForAddObjectTerm() {

        StringBuilder sql = new StringBuilder();

        sql.append("SELECT t.term_acc,t.term,o.ont_name\n");
        sql.append("FROM ont_terms t,ontologies o\n");
        sql.append("WHERE t.is_obsolete=0 AND o.ont_id=t.ont_id\n");
        //sql.append(" AND NVL(s.rat_annots_with_children,0)+NVL(s.mouse_annots_with_children,0)+NVL(s.human_annots_with_children,0)>0 \n");
        sql.append(" AND EXISTS(SELECT 1 FROM ont_term_stats2 s WHERE s.term_acc=t.term_acc AND stat_name='annotated_object_count' AND with_children>0) \n");
        sql.append(" AND t.term_acc IN (\n");
        sql.append("    SELECT child_term_acc FROM ont_dag \n");
        sql.append("    START WITH child_term_acc IN(\n");
        sql.append("      SELECT term_acc FROM ont_terms t\n");
        sql.append("      WHERE (upper(t.term) like upper('%"+terms[0]+"%')\n");
        sql.append("             and t.ont_id in ("+onts[0]+"))\n");
        sql.append("    ) CONNECT BY PRIOR child_term_acc=parent_term_acc\n");
        sql.append(")\n");
        sql.append("ORDER BY o.ont_name,t.term\n");

        return sql.toString();
    }

    static public String highlight(String term, String selTerm) {
        if( term==null )
            return term;
        term = term.toLowerCase();

        if( term.contains(selTerm) ) {
            term = term.replace(selTerm, "<b>"+selTerm+"</b>");
        }
        return term;
    }

    public String[] getTerms() {
        return terms;
    }

    public void setTerms(String[] terms) {
        this.terms = new String[terms.length];
        for (int i=0; i<terms.length; i++) {
            int pos = terms[i].indexOf(" (");
            if (pos > 0) {
                this.terms[i] = terms[i].substring(0,pos);
            }else {
                this.terms[i] = terms[i];
            }
        }
        //this.terms = terms;
    }

    public String[] getOnts() {
        return onts;
    }

    public void setOnts(String[] onts) {
        this.onts = onts;
    }

    public String[] getOps() {
        return ops;
    }

    public void setOps(String[] ops) {
        this.ops = ops;
    }

    public List<String[]> getLines() {
        return lines;
    }

    public void setLines(List<String[]> lines) {
        this.lines = lines;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getSpeciesType() {
        return speciesType;
    }

    public void setSpeciesType(String speciesType) {
        this.speciesType = speciesType;
    }
}
