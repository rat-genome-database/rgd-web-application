package edu.mcw.rgd.pipeline;

import edu.mcw.rgd.dao.AbstractDAO;
import edu.mcw.rgd.dao.impl.PipelineLogDAO;
import edu.mcw.rgd.datamodel.Pipeline;
import edu.mcw.rgd.datamodel.PipelineLog;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: Jun 21, 2010
 * Time: 2:08:53 PM
 * To change this template use File | Settings | File Templates.
 */
public class TranscriptsController implements Controller {

    AbstractDAO dao = new AbstractDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String rgdid = request.getParameter("rgdid");
        if( rgdid==null || rgdid.trim().length()==0 ) {
            // no data
        }
        else {
            int rgdId = Integer.parseInt(rgdid);
            ArrayList<HashMap> mapData = loadData(rgdId);
            request.setAttribute("md", mapData);
            request.setAttribute("id", rgdid);
        }

        return new ModelAndView("/WEB-INF/jsp/curation/pipeline/transcripts.jsp");
    }

    ArrayList<HashMap> loadData(int geneRgdId) throws Exception {

        String query =
        "select header,symbol,map_name,x.chromosome,start_pos,stop_pos,strand,x.transcript_rgd_id from ( "+
        "select DECODE(t.is_non_coding_ind,'Y','NON CODING REGION','TRANSCRIPT') header,t.acc_id symbol,m.start_pos,m.stop_pos,m.strand,t.transcript_rgd_id,m.map_key,m.chromosome "+
        "from transcripts t,maps_data m where t.gene_rgd_id=? and m.rgd_id=t.transcript_rgd_id "+
        "union all "+
        "select '' header,DECODE(r.object_key,15,'EXON',17,'5''UTR5',20,'3''UTR3','OTHER')||' RGD_ID:'||d.rgd_id symbol,d.start_pos,d.stop_pos,d.strand,t.transcript_rgd_id,d.map_key,d.chromosome "+
        "from transcripts t,maps_data m,transcript_features f,maps_data d,rgd_ids r "+
        "where t.gene_rgd_id=? and m.rgd_id=t.transcript_rgd_id and t.transcript_rgd_id=f.transcript_rgd_id "+
        " and f.feature_rgd_id=d.rgd_id and f.feature_rgd_id=r.rgd_id and m.map_key=d.map_key"+
        ") x,maps p "+
        "WHERE x.map_key=p.map_key "+
        "ORDER BY transcript_rgd_id,map_name,header,start_pos,stop_pos";

        ArrayList rows = new ArrayList();
        Connection conn = dao.getConnection();
        int transcriptStartPos = 0;
        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, geneRgdId);
            stmt.setInt(2, geneRgdId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                HashMap<String,String> map = new HashMap<String,String>();
                String header = rs.getString(1);

                String symbol = rs.getString(2);
                map.put("header", header);
                map.put("symbol", symbol);
                String mapName = rs.getString(3);
                map.put("map", mapName);
                map.put("chromosome", rs.getString(4));
                String strand = rs.getString(7);
                int startPos = rs.getInt(5);
                int stopPos = rs.getInt(6);
                String coords = startPos+".."+stopPos+" ("+strand+")  len="+(stopPos-startPos+1);

                if( header!=null && header.trim().length()>0 ) {
                    transcriptStartPos = startPos-1; // save starting position for transcript region
                }
                else {
                    // in map name column display relative range
                    map.put("map", "");
                    coords += "</br>"+(startPos-transcriptStartPos)+".."+(stopPos-transcriptStartPos);
                }
                map.put("coords", coords);

                map.put("attr",
                    (header!=null && header.startsWith("TRANSCRIPT")) ? "style='background-color:lightgreen'":
                    (header!=null && header.startsWith("NON")) ? "style='background-color:purple'":
                    symbol.startsWith("EXON") ? "style='background-color:yellow'" :
                    symbol.startsWith("3") ? "style='background-color:pink'" :
                    symbol.startsWith("5") ? "style='background-color:orange'" : ""
                );
                rows.add(map);
            }

        } finally {
            try {
               conn.close();
            }catch (Exception ignored) {
            }
        }
        return rows;

    }
}

