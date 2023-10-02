package edu.mcw.rgd.gviewer;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.reporting.Link;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: 8/13/12
 * Time: 4:23 PM
 */
public class AnnotationJSONController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        response.setContentType("text/JSON");

        PrintWriter out = response.getWriter();
        out.println("{");

        GViewerBean bean = new GViewerBean();
        bean.loadParametersFromRequest(request);

        String sql = bean.buildSqlForGViewerAnnotations();
        //System.out.println(sql);

        Connection conn = null;
        try {
            conn = DataSourceFactory.getInstance().getDataSource().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                String rgdId = rs.getString("rgd_id");
                String objectType = rs.getString("object_type");
                String link = objectType.equals("gene") ? Link.gene(Integer.parseInt(rgdId)) :
                        objectType.equals("qtl") ? Link.qtl(Integer.parseInt(rgdId)) :
                        objectType.equals("strain") ? Link.strain(Integer.parseInt(rgdId)) :
                        "";
                String color = objectType.equals("gene") ? "0x79CC3D" :
                        objectType.equals("qtl") ? "0xFFFFFF" :
                        objectType.equals("strain") ? "#76AC1A" :
                        "";
                // strip html tags from symbol (we return xml, so these tags will break the xml structure)
                String symbol = rs.getString("object_symbol").replaceAll("\\<.*?>", "");


                out.println("{");
                out.println("\"chromosome\":\""+rs.getString("chromosome")+"\",");
                out.println("\"start\":"+rs.getString("start_pos")+"\",");
                out.println("\"end\":"+rs.getString("stop_pos")+"\",");
                out.println("\"type\":\""+objectType+"\",");
                out.println("\"label\":\""+symbol+"\",");
                out.println("\"link\":\""+link+"\",");
                out.println("\"color\":\""+color+"\"");
                out.println("}");
            }

            out.println("}");
        }catch(SQLException se) {
            se.printStackTrace();
        } finally {
            try {
               if( conn!=null ) conn.close();
            }catch (Exception ignored) {
            }
        }
        return null;
    }
}
