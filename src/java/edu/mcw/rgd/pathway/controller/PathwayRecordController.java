package edu.mcw.rgd.pathway.controller;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.PathwayDAO;
import edu.mcw.rgd.datamodel.Pathway;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.Map;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class PathwayRecordController implements Controller {
    PathwayDAO pwDAO = new PathwayDAO();
    OntologyXDAO ontxDao = new OntologyXDAO();

    public String getUploadingDir() {
        return uploadingDir;
    }

    public void setUploadingDir(String uploadingDir) {
        this.uploadingDir = uploadingDir;
    }

    private static String uploadingDir;

    public static String getDataDir() {
        return dataDir;
    }

    public void setDataDir(String dataDir) {
        this.dataDir = dataDir;
    }

    private static String dataDir;

    


    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        HttpRequestFacade req = new HttpRequestFacade(request);
        //status.add("is this the Pathway you are talking about?");

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);
        String  entryTerm="";

        if(req.getParameter("acc_id").equals("")){
            error.add("Pathway term not supplied");
            ModelAndView mv = new ModelAndView("/WEB-INF/jsp/curation/pathway/home.jsp");
            mv.addObject("error" , error);
            Map<String, String> pwAccMap = new PathwayHomeController().makePathwayListsMap();
            mv.addObject("pwMap", pwAccMap);
            return mv;
        }else{
            entryTerm = request.getParameter("acc_id").trim().toUpperCase();
        }
        Pathway newPw = pwDAO.getPathwayInfo(entryTerm);
        Term pwTerm = ontxDao.getTermByAccId(entryTerm);

        if( newPw==null ){

            if( pwTerm!=null ) {
                warning.add("this Pathway is new. It needs to be created");

                ModelAndView newpwObj = new ModelAndView("/WEB-INF/jsp/curation/pathway/pathwayCreate.jsp");
                newpwObj.addObject("createPwObj", pwTerm);
                newpwObj.addObject("uploadingDir", uploadingDir);
                newpwObj.addObject("dataDir", dataDir);
                newpwObj.addObject("warning", warning);
                return newpwObj;
            }else{
                error.add("Pathway Term not in Database: " + entryTerm );
                ModelAndView mv = new ModelAndView("/WEB-INF/jsp/curation/pathway/home.jsp");
                mv.addObject("error" , error);
                Map<String, String> pwAccMap = new PathwayHomeController().makePathwayListsMap();
                mv.addObject("pwMap", pwAccMap);
                return mv;
            }

        }else{

            ModelAndView mv2 = new ModelAndView("/WEB-INF/jsp/curation/pathway/pathwayCreate.jsp");
            mv2.addObject("editPwObj", pwTerm );
            mv2.addObject("uploadingDir", uploadingDir);
            mv2.addObject("dataDir", dataDir);
            return mv2;
        }
    }
}