package edu.mcw.rgd.ontology;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.gviewer.GViewerBean;
import edu.mcw.rgd.process.mapping.MapManager;
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
import java.util.ArrayList;
import java.util.List;

/**
 * @author mtutaj
 * @since Apr 22, 2011
 * Given term accession id ('acc_id') and species type ('species_type') parameters,
 * return an xml stream of objects to be shown in GViewer.
 */
public class OntGViewerDataController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        //HttpRequestFacade req = new HttpRequestFacade(request);
        //String aValue = "";
        //ArrayList<String> urlParts = new ArrayList<String>();
        // read term accession id and species type key


//        String accId = request.getParameter("acc_id");
//        int speciesType = Integer.parseInt(request.getParameter("species_type"));
//        int oKey = Integer.parseInt(request.getParameter("objectKey"));
//

//        String withChilds = request.getParameter("with_childs");


        // generate a stream of xml objects
        String ids = request.getParameter("ids");
        if(ids!=null && !ids.equals("") && !ids.equals("undefined"))
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
                //System.out.println("len = 0 ");
                idStr += idArray[i];
            }else {
                idStr += "," + idArray[i];
            }

            if (i!=0 && i % 999 == 0) {
                //System.out.println("adding " + i + " " + idStr);
                idList.add(idStr);
                idStr = "";
            }

        }

        //System.out.println("adding " + idStr);
        idList.add(idStr);
        //System.out.println("ids list size = " + idList.size());

        try {

            if (idList.size() > 0) {

                for (String lst: idList) {

                    if (lst.length() > 0) {
                        if (sql.length() > 0) {
                            sql += " union ";
                        }

                        sql += "SELECT DISTINCT m.chromosome,m.start_pos,m.stop_pos, m.rgd_id, object_symbol,DECODE(rgd_object_key,1,'gene',6,'qtl','strain') object_type " +
                                "FROM maps_data m, full_annot fa where m.rgd_id in (" + lst + ") ";
                        sql += " and m.rgd_id=fa.annotated_object_rgd_id and m.map_key IN " + getMapKeysForGViewer();

                    }
                }
            } else {
                sql = bean.buildSqlForGViewerAnnotations();
            }

        }catch (Exception e) {
            e.printStackTrace();
        }

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
    }

    // comma separated list of map_key s
    static String _strMapKeys = null;

    synchronized static String getMapKeysForGViewer() throws Exception {

        if( _strMapKeys==null ) {
            MapManager mm = MapManager.getInstance();
            _strMapKeys = "("
                + mm.getReferenceAssembly(1).getKey() + ","
                + mm.getReferenceAssembly(2).getKey() + ","
                + mm.getReferenceAssembly(3).getKey() + ","
                + mm.getReferenceAssembly(4).getKey() + ","
                + mm.getReferenceAssembly(5).getKey() + ","
                + mm.getReferenceAssembly(6).getKey() + ","
                + mm.getReferenceAssembly(7).getKey() + ","
                + mm.getReferenceAssembly(9).getKey() + ")";
        }
        return _strMapKeys;
    }
}
