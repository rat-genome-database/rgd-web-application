package edu.mcw.rgd.ontology;

import edu.mcw.rgd.dao.AbstractDAO;
import org.springframework.jdbc.core.*;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.ResultSet;
import java.sql.SQLException;

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

        // read term accession id and species type key
        String accId = request.getParameter("acc_id");
        String speciesType = request.getParameter("species_type");
        String withChilds = request.getParameter("with_childs");

        // generate a stream of xml objects

        String dataElements = getGViewerData(accId, speciesType, withChilds);

        String xmlData = "<?xml version='1.0' standalone='yes' ?>";

        //fixed issue with empty document having the word null at the end.
        if (dataElements != null && !dataElements.equals("null")) {
                xmlData +=dataElements;
        }else {
            xmlData += "<empty/>";
        }

        // stream the content
        response.setContentType("text/xml");
        response.setContentLength(xmlData.length());
        response.getWriter().print(xmlData);

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
}
