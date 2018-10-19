package edu.mcw.rgd.pubmed;

import edu.mcw.rgd.dao.impl.AnnotationDAO;
import edu.mcw.rgd.dao.impl.ReferenceDAO;
import edu.mcw.rgd.ontology.OntDotController;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Created by IntelliJ IDEA.
 * User: pjayaraman
 * Date: 3/5/12
 * Time: 1:07 PM
 */
public class PubmedImageGenerator implements Controller{

    ReferenceDAO refDao = new ReferenceDAO();
    AnnotationDAO annDao = new AnnotationDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(request);

        String pmId = req.getParameter("pmid");
        String type = "";
        if(!(req.getParameter("type")==null)){
            type = req.getParameter("type");
        }

        int refRgdId =  refDao.getMaxReferenceRgdIdByPubmedId(pmId);

        if((!(pmId.equals(""))) && (type.equals(""))){
            returnImage(refRgdId, response);
        }else if((!(pmId.equals(""))) && (type.equals("redirect"))){
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

        //System.out.println("ref rgdid is:"+refRgdId);

        if(refRgdId == 0){
            imgId = "dot_clear.png";
        }else{
            int annotcount = annDao.getCountOfAnnotationsByReference(refRgdId, "RGD");
            if(annotcount>0){
                imgId = "rgd_logo.png";
            }else{
                imgId = "dot_clear.png";
            }
        }
        ontDot.serveImage(imgId, resp);

    }



}
