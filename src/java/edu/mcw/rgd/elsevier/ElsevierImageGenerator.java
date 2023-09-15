package edu.mcw.rgd.elsevier;

import edu.mcw.rgd.dao.impl.AnnotationDAO;
import edu.mcw.rgd.dao.impl.ReferenceDAO;
import edu.mcw.rgd.ontology.OntDotController;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Created by IntelliJ IDEA.
 * User: pjayaraman
 * Date: 3/5/12
 * Time: 1:07 PM
 */
public class ElsevierImageGenerator implements Controller{

    ReferenceDAO refDao = new ReferenceDAO();
    AnnotationDAO annDao = new AnnotationDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(request);

        String doiId = req.getParameter("doi");
        String type = "";
        if(!(req.getParameter("type")==null)){
            type = req.getParameter("type");
        }

        int refRgdId =  refDao.getReferenceRgdIdByDOI(doiId);

        if((!(doiId.equals(""))) && (type.equals(""))){
            returnImage(refRgdId, response);
        }else if((!(doiId.equals(""))) && (type.equals("redirect"))){
            returnUrl(refRgdId, response);
        }

        return null;

    }

    private void returnUrl(int refRgdId, HttpServletResponse resp) throws Exception{

        String url = Link.ref(refRgdId)+"&abstract=0";
        int annotcount = annDao.getCountOfAnnotationsByReference(refRgdId);

        if(annotcount>0){
            resp.sendRedirect(url);
        }else{
            resp.sendRedirect(null);
        }
    }

    public void returnImage(int refRgdId, HttpServletResponse resp) throws Exception {

        OntDotController ontDot = new OntDotController();
        ontDot.setTmpFileDir("/rgd/www/common/images/");
        String imgId;


        if(refRgdId == 0){
            imgId = "dot_clear.png";
        }else{
            int annotcount = annDao.getCountOfAnnotationsByReference(refRgdId);
            if(annotcount>0){
                imgId = "rgd_logo.png";
            }else{
                imgId = "dot_clear.png";
            }
        }
        ontDot.serveImage(imgId, resp);

    }



}
