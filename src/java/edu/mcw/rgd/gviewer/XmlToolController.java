package edu.mcw.rgd.gviewer;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.AnnotationDAO;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.reporting.Link;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: 8/13/12
 * Time: 4:23 PM
 */
public class XmlToolController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        GViewerBean bean = new GViewerBean();
        bean.loadParametersFromRequest(request);

        LinkedList<String[]> lines = new LinkedList<String[]>();
        bean.setLines(lines);

        // handle GViewer - AddObject - OntologyTerm
        String gviewer = request.getParameter("gviewer");
        if( gviewer!=null && gviewer.equalsIgnoreCase("addObjTerm") ) {
            return handleGViewerAddObjectTerm(bean);
        }

        String sql = bean.buildSqlForGViewerAnnotations();
        //System.out.println(sql);

        Map<String, String[]> linesMap = new HashMap<String, String[]>();

        Connection conn = null;
        try {
            conn = DataSourceFactory.getInstance().getDataSource().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                String rgdId = rs.getString("rgd_id");

                // do not insert duplicate lines into 'lines' table
                if( linesMap.get(rgdId)!=null )
                    continue;

                String objectType = rs.getString("object_type");
                String link = objectType.equals("gene") ? Link.gene(Integer.parseInt(rgdId)) :
                        objectType.equals("qtl") ? Link.qtl(Integer.parseInt(rgdId)) :
                        objectType.equals("strain") ? Link.strain(Integer.parseInt(rgdId)) :
                        "";
                String symbol = rs.getString("object_symbol");

                String[] line = new String[4+bean.getTerms().length];
                line[0] = rgdId;
                line[1] = objectType;
                line[2] = symbol;
                line[3] = link;

                lines.add(line);

                linesMap.put(rgdId, line);
            }

        }catch(SQLException se) {
            se.printStackTrace();
        } finally {
            try {
               if( conn!=null ) conn.close();
            }catch (Exception ignored) {
            }
        }

        for( int termIndex=0; termIndex<bean.getTerms().length; termIndex++ ) {

            String selTerm = bean.getTerms()[termIndex].toLowerCase();

            try {
                conn = null;
                conn = DataSourceFactory.getInstance().getDataSource().getConnection();
                PreparedStatement ps = conn.prepareStatement(bean.buildSqlForTerm(termIndex));
                ResultSet rs = ps.executeQuery();

                while (rs.next()) {

                    String rgdId = rs.getString("rgd_id");
                    String termAcc = rs.getString("term_acc");
                    String termName = rs.getString("term");

                    // extract ont id
                    int pos = termAcc.indexOf(':');
                    String ontId = termAcc.substring(0, pos+1) + ' ';

                    String link = "<a href='"+Link.ontAnnot(termAcc)+"'>"+ontId+GViewerBean.highlight(termName, selTerm)+"</a>";

                    String[] line = linesMap.get(rgdId);
                    if( line==null ) {
                        // this object is not on our annotated obj list;
                        continue;
                    }
                    String contents = line[4+termIndex];
                    if( contents==null )
                        contents = link;
                    else
                        contents += "<br>" + link;
                    line[4+termIndex] = contents;
                }

            }catch(SQLException se) {
                se.printStackTrace();
            } finally {
                try {
                   if( conn!=null ) conn.close();
                }catch (Exception ignored) {
                }
            }

        }

        ModelAndView mv = new ModelAndView("/gTool/GViewerTerms.jsp");
        mv.addObject("bean", bean);
        return mv;
    }

    ModelAndView handleGViewerAddObjectTerm(GViewerBean bean) throws Exception {

        String sql = bean.buildSqlForAddObjectTerm();

        AnnotationDAO annotationDAO = new AnnotationDAO();

        //   0         1        2          3          4             5
        // TERM_ACC | TERM | ONTOLOGY | RAT_COUNT | MOUSE_COUNT | HUMAN_COUNT
        List<String[]> lines = bean.getLines();

        Connection conn = null;
        try {
            conn = DataSourceFactory.getInstance().getDataSource().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                String term = rs.getString("term");
                String termAcc = rs.getString("term_acc");
                String ontName = rs.getString("ont_name");

                int annotObjCountRat = annotationDAO.getAnnotatedObjectCount(termAcc, true, SpeciesType.RAT, 0);
                int annotObjCountMouse = annotationDAO.getAnnotatedObjectCount(termAcc, true, SpeciesType.MOUSE, 0);
                int annotObjCountHuman = annotationDAO.getAnnotatedObjectCount(termAcc, true, SpeciesType.HUMAN, 0);

                String[] line = new String[6];
                line[0] = termAcc;
                line[1] = term;
                line[2] = ontName;
                line[3] = Integer.toString(annotObjCountRat);
                line[4] = Integer.toString(annotObjCountMouse);
                line[5] = Integer.toString(annotObjCountHuman);

                lines.add(line);
            }

        }catch(SQLException se) {
            se.printStackTrace();
        } finally {
            try {
               if( conn!=null ) conn.close();
            }catch (Exception ignored) {
            }
        }

        ModelAndView mv = new ModelAndView("/gTool/GViewerAddObjectTerm.jsp");
        mv.addObject("bean", bean);
        return mv;
    }
}
