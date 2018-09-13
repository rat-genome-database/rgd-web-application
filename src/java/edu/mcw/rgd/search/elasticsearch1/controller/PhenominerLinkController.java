package edu.mcw.rgd.search.elasticsearch1.controller;

import edu.mcw.rgd.dao.impl.AnnotationDAO;
import edu.mcw.rgd.datamodel.ontology.Annotation;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;


/**
 * Created by jthota on 5/10/2017.
 */
public class PhenominerLinkController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        AnnotationDAO annotationDAO= new AnnotationDAO();
        String rgdids= request.getParameter("rgdIds");
        String[] tokens= rgdids.split(",");
        List<Integer> ids= new ArrayList<>();
        for(String token:tokens){
            ids.add(Integer.parseInt(token));
        }
        List<Annotation> annots=annotationDAO.getAnnotationsByRgdIdsListAndAspect(ids, "S");
        StringBuilder terms= new StringBuilder();
        boolean first=true;
        for(Annotation a:annots){
            if(first){
                terms.append(a.getTermAcc());
                first=false;
            }else{
                terms.append(",");
                terms.append(a.getTermAcc());
            }

        }

      //  response.sendRedirect("http://www.rgd.mcw.edu/phenotypes/termSelection/ontChoices?terms=" +terms);
        response.sendRedirect("/rgdweb/phenominer/ontChoices.html?terms=" +terms +"&sex=both");
        return null;
    }


}
