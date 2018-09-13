package edu.mcw.rgd.report.GenomeModel;


import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.datamodel.ontologyx.TermWithStats;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by jthota on 11/28/2017.
 */
public class AnnotatedObjectsDAO extends OntologyXDAO {
    public List<DiseaseObject> getAnnotatedObjects(String accId, String aspect, int mapKey, String chromosome) throws Exception {

        String sql="SELECT g.RGD_ID, g.GENE_SYMBOL, g.GENE_TYPE_LC, m.CHROMOSOME, m.START_POS, m.STOP_POS, m.STRAND, f.TERM \n" +
                " FROM GENES g \n" +
                " JOIN MAPS_DATA m ON (g.RGD_ID= m.RGD_ID AND m.MAP_KEY=? AND m.CHROMOSOME=?)\n" +
                " JOIN FULL_ANNOT f ON (f.ANNOTATED_OBJECT_RGD_ID=g.RGD_ID AND f.ASPECT=?)\n" +
                " JOIN FULL_ANNOT_INDEX i ON ( i.FULL_ANNOT_KEY= f.FULL_ANNOT_KEY AND i.TERM_ACC=? )\n" +
                " JOIN RGD_IDS r ON (r.RGD_ID=g.RGD_ID AND r.OBJECT_STATUS='ACTIVE')";
        Connection conn= this.getDataSource().getConnection();
        PreparedStatement ps= conn.prepareStatement(sql);
        ps.setInt(1, mapKey);
        ps.setString(2, chromosome);
        ps.setString(3, aspect);
        ps.setString(4, accId);
        ResultSet rs= ps.executeQuery();
        List<DiseaseObject> objects= new ArrayList<>();
        while(rs.next()){
            DiseaseObject obj= new DiseaseObject();
            obj.setGeneRgdId(rs.getInt("rgd_id"));
            obj.setGeneSymbol(rs.getString("gene_symbol"));
            obj.setGeneType(rs.getString("gene_type_lc"));
            obj.setStartPos(rs.getString("start_pos"));
            obj.setStopPos(rs.getString("stop_pos"));
            obj.setStrand(rs.getString("strand"));

            if(!contains(obj, objects)){
                objects.add(obj);
            }

        }


        rs.close();
        ps.close();
        conn.close();
        return objects;
    }
    public boolean contains(DiseaseObject obj, List<DiseaseObject> objects){
        for(DiseaseObject o:objects){
            if(obj.getGeneRgdId()==o.getGeneRgdId()){
                return true;
            }
        }
        return false;
    }
    public static void main(String[] args) throws Exception {
        AnnotatedObjectsDAO dao= new AnnotatedObjectsDAO();
        dao.getAnnotatedObjects("DOID:2490", "I", 360, "1");
        System.out.println("DONE");
    }
}
