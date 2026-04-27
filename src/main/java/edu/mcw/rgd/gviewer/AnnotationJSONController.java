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

        response.setContentType("application/json");

        PrintWriter out = response.getWriter();

        GViewerBean bean = new GViewerBean();
        bean.loadParametersFromRequest(request);

        String sql = bean.buildSqlForGViewerAnnotations();

        Connection conn = null;
        try {
            conn = DataSourceFactory.getInstance().getDataSource().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            out.print("{\"genome\":{\"feature\":[");
            boolean first = true;
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
                String symbol = rs.getString("object_symbol").replaceAll("\\<.*?>", "");

                if (!first) out.print(",");
                first = false;

                out.print("{");
                out.print("\"chromosome\":\""+rs.getString("chromosome")+"\",");
                out.print("\"start\":\""+rs.getString("start_pos")+"\",");
                out.print("\"end\":\""+rs.getString("stop_pos")+"\",");
                out.print("\"type\":\""+objectType+"\",");
                out.print("\"label\":\""+escapeJson(symbol)+"\",");
                out.print("\"link\":\""+escapeJson(link)+"\",");
                out.print("\"color\":\""+color+"\"");
                out.print("}");
            }
            out.println("]}}");

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

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
