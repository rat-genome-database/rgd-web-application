package edu.mcw.rgd.webservice;

import edu.mcw.rgd.dao.impl.AnnotationDAO;
import edu.mcw.rgd.dao.impl.ReferenceDAO;
import edu.mcw.rgd.datamodel.ontology.Annotation;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: pjayaraman
 * Date: 3/5/12
 * Time: 1:07 PM
 */
public class PmidImageGenerator implements Controller{

    ReferenceDAO refDao = new ReferenceDAO();
    AnnotationDAO annDao = new AnnotationDAO();


    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        HttpRequestFacade req = new HttpRequestFacade(request);

        String pmId = req.getParameter("pmid");
        String term_acc = req.getParameter("aspect");
        String obj_key = req.getParameter("obj_key");
        int objKey=0;
        if(!(obj_key.equals(""))){
            objKey = Integer.parseInt(obj_key);
        }

        String jsonpParam = req.getParameter("jsonp");

        ModelAndView mv = new ModelAndView("/WEB-INF/jsp/webservice/refAnnots.jsp");

        List<Annotation> objAnnots = new ArrayList<Annotation>();

        if(!(pmId.equals(""))){
            objAnnots = returnAnnotations(pmId, term_acc, objKey);
        }else{
            error.add("please add in a pubmedId ..");
        }

        mv.addObject("annots", objAnnots);
        mv.addObject("jsonP", jsonpParam);
        mv.addObject("error", error);

        return mv;

    }

    private List<Annotation> returnAnnotations(String pmId, String aspect, int objKey) throws Exception {

        int refRgdId =  refDao.getReferenceRgdIdByPubmedId(pmId);
        List<Annotation> objAnnots = new ArrayList<Annotation>();

        if(aspect.equals("") && objKey==0){
            objAnnots = annDao.getAnnotationsByReferenceSource(refRgdId, "RGD");
        }else if((!(aspect.equals(""))) && (objKey==0)){
            objAnnots = annDao.getAnnotationsByReference(refRgdId, aspect, "RGD");
        }else if((!(aspect.equals(""))) && (objKey!=0)){
            objAnnots = annDao.getAnnotationsByReference(refRgdId, aspect, objKey, "RGD");
        }

        sortAnnotationBySymbol(objAnnots);

        if(!(objAnnots.isEmpty())){
            return objAnnots;
        }else{
            return null;
        }
    }

    public void sortAnnotationBySymbol(List<Annotation> annots){
        Collections.sort(annots, new Comparator<Annotation>(){
            public int compare(Annotation o1, Annotation o2){
                int result = o1.getObjectSymbol().compareToIgnoreCase(o2.getObjectSymbol());
                if (result == 0) {
                    // Strings are equal, sort by date
                    return o1.getTerm().compareToIgnoreCase(o2.getTerm());
                }
                else {
                    return result;
                }
            }
        });


    }


}
