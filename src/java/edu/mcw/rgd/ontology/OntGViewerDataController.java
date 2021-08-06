package edu.mcw.rgd.ontology;

import edu.mcw.rgd.dao.AbstractDAO;
import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.gviewer.GViewerBean;
import edu.mcw.rgd.process.generator.GeneratorCommandParser;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.apache.commons.collections.ListUtils;
import org.springframework.jdbc.core.*;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: Apr 22, 2011
 * Time: 4:47:15 PM
 * Given term accession id ('acc_id') and species type ('species_type') parameters,
 * return an xml stream of objects to be shown in GViewer.
 */
public class OntGViewerDataController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);
        String aValue = "";
        ArrayList<String> urlParts = new ArrayList<String>();
        // read term accession id and species type key


//        String accId = request.getParameter("acc_id");
//        int speciesType = Integer.parseInt(request.getParameter("species_type"));
//        int oKey = Integer.parseInt(request.getParameter("objectKey"));
//

//        String withChilds = request.getParameter("with_childs");


        // generate a stream of xml objects
        String ids = request.getParameter("ids");

        generate(request, response, ids);

//        String dataElements = getGViewerData(accId, speciesType, withChilds);
//
//        String xmlData = "<?xml version='1.0' standalone='yes' ?>";
//
//        //fixed issue with empty document having the word null at the end.
//        if (dataElements != null && !dataElements.equals("null")) {
//                xmlData +=dataElements;
//        }else {
//            xmlData += "<empty/>";
//        }

        // stream the content
//        response.setContentType("text/xml");
//        response.setContentLength(xmlData.length());
//        response.getWriter().print(xmlData);

        return null;
    }

    private String getGViewerData(String accId, String speciesType, String withChilds) throws Exception {

        AbstractDAO dao = new AbstractDAO();
        JdbcTemplate jt = new JdbcTemplate(dao.getDataSource());
        String sql = "SELECT "+(speciesType.equals("1")?"HUMAN":speciesType.equals("2")?"MOUSE":speciesType.equals("4")?"RAT":"RAT")
                +(withChilds.equals("1")?"_GVIEWER_WITH_CHILDREN":"_GVIEWER_FOR_TERM")
                +" FROM ONT_TERM_STATS WHERE term_acc=?";
        final StringBuffer buf = new StringBuffer();
        jt.query(sql, new Object[]{accId}, new RowMapper(){
            public Object mapRow(ResultSet rs, int i) throws SQLException {
                buf.append(rs.getString(1));
                return null;
            }
        });
        return buf.toString();
    }

    public void generate(HttpServletRequest request, HttpServletResponse response, String ids) throws Exception {
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

//        String ids = request.getParameter("ids");
//        ids = "2004,620948";
        String[] idArray = ids.split(",");

        List<String> idList = new <String>ArrayList();

        //System.out.println("id list = " + ids);

        String idStr = "";
        for (int i = 0; i < idArray.length; i++) {

            if (idStr.length()==0) {
                System.out.println("len = 0 ");
                idStr += idArray[i];
            }else {
                idStr += "," + idArray[i];
            }

            if (i!=0 && i % 999 == 0) {
                System.out.println("adding " + i + " " + idStr);
                idList.add(idStr);
                idStr = "";
            }

        }

        System.out.println("adding " + idStr);
        idList.add(idStr);
        System.out.println("ids list size = " + idList.size());

        try {

            if (idList.size() > 0) {

                for (String lst: idList) {

                    if (sql.length() > 0) {
                        sql += " union ";
                    }


                    sql += "SELECT DISTINCT m.chromosome,m.start_pos,m.stop_pos, m.rgd_id, object_symbol,DECODE(rgd_object_key,1,'gene',6,'qtl','strain') object_type " +
                            "FROM maps_data m, full_annot fa where m.rgd_id in (" + lst + ") ";

                    sql += " and m.rgd_id=fa.annotated_object_rgd_id and m.map_key in ( ";

                    sql += MapManager.getInstance().getReferenceAssembly(1).getKey() + ",";
                    sql += MapManager.getInstance().getReferenceAssembly(2).getKey() + ",";
                    sql += MapManager.getInstance().getReferenceAssembly(3).getKey() + ",";
                    sql += MapManager.getInstance().getReferenceAssembly(4).getKey() + ",";
                    sql += MapManager.getInstance().getReferenceAssembly(5).getKey() + ",";
                    sql += MapManager.getInstance().getReferenceAssembly(6).getKey() + ",";
                    sql += MapManager.getInstance().getReferenceAssembly(7).getKey() + ",";
                    sql += MapManager.getInstance().getReferenceAssembly(9).getKey() + ")";
                }
            } else {
                sql = bean.buildSqlForGViewerAnnotations();
            }

        }catch (Exception e) {
            e.printStackTrace();
        }

        System.out.println(sql);

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
        return;
    }

}
