package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.apache.http.HttpRequest;
import org.apache.http.HttpResponse;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class GeneReportController extends ReportController {


    public String getViewUrl() throws Exception {
       return "gene/main.jsp";

    }

    public Object getObject(int rgdId) throws Exception{
        return new GeneDAO().getGene(rgdId);
    }

}