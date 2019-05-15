package edu.mcw.rgd.gviewer;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.reporting.Link;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
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
public class AnnotationXmlController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        response.setContentType("text/xml");

        PrintWriter out = response.getWriter();
        out.println("<?xml version='1.0' standalone='yes' ?>");
        out.println("<genome>");

        GViewerBean bean = new GViewerBean();
        try {
            bean.loadParametersFromRequest(request);
        }catch (Exception e) {

        }

        String sql = "";

        String ids = request.getParameter("ids");

        try {

            System.out.println("hello");
            if (ids != null && !ids.equals("")) {
                sql = "SELECT DISTINCT m.chromosome,m.start_pos,m.stop_pos, m.rgd_id, object_symbol,DECODE(rgd_object_key,1,'gene',6,'qtl','strain') object_type " +
                        "FROM maps_data m, full_annot fa where m.rgd_id in (";


                String[] idArray = ids.split(",");

                for (int i = 0; i < idArray.length; i++) {
                    if (i > 0) {
                        sql += ",";
                    }
                    sql += idArray[i];
                }

                sql += ") and m.rgd_id=fa.annotated_object_rgd_id and m.map_key in ( ";

                sql += MapManager.getInstance().getReferenceAssembly(1).getKey();
                sql += MapManager.getInstance().getReferenceAssembly(2).getKey() + ",";
                sql += MapManager.getInstance().getReferenceAssembly(3).getKey() + ",";
                sql += MapManager.getInstance().getReferenceAssembly(4).getKey() + ",";
                sql += MapManager.getInstance().getReferenceAssembly(5).getKey() + ",";
                sql += MapManager.getInstance().getReferenceAssembly(6).getKey() + ",";
                sql += MapManager.getInstance().getReferenceAssembly(7).getKey() + ")";

            } else {
                sql = bean.buildSqlForGViewerAnnotations();
            }

        }catch (Exception e) {
            e.printStackTrace();
        }

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

                out.println("<feature>");
                out.println("<chromosome>"+rs.getString("chromosome")+"</chromosome>");
                out.println("<start>"+rs.getString("start_pos")+"</start>");
                out.println("<end>"+rs.getString("stop_pos")+"</end>");
                out.println("<type>"+objectType+"</type>");
                out.println("<label>"+symbol+"</label>");
                out.println("<link>"+link+"</link>");
                out.println("<color>"+color+"</color>");
                out.println("</feature>");
            }

            out.println("</genome>");
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
