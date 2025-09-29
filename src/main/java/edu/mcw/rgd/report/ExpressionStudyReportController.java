package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.pheno.Study;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.ArrayList;
import java.util.List;

public class ExpressionStudyReportController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();
        PhenominerDAO pdao = new PhenominerDAO();
        HttpRequestFacade req = new HttpRequestFacade(request);

        String studyIdStr = req.getParameter("id");
        String geoAcc = req.getParameter("geoAcc");
        Study obj = null;
        if (Utils.isStringEmpty(studyIdStr) && Utils.isStringEmpty(geoAcc))
            error.add("No ID was given!");
        try{
            if (!Utils.isStringEmpty(studyIdStr)){
                int studyId = Integer.parseInt(studyIdStr);
                obj = pdao.getStudy(studyId);
            } else {
                List<Study> studies = pdao.getStudiesByGeoId(geoAcc.toUpperCase());
                if (studies.isEmpty()){
                    error.add("No studies with the given GEO Accession!");
                }
                if (studies.size()==1){
                    obj = studies.get(0);
                }
                else {
                    for (Study s : studies){
                        if (Utils.stringsAreEqual(s.getSource(),"GEO")){
                            obj = s;
                            break;
                        }
                    }
                    if (obj == null){
                        obj = studies.get(0);
                    }
                }
            }
            if (obj == null){
                error.add("No study was found with the given ID!");
            }
        }
        catch (Exception e){
            error.add(e.getMessage());
        }

        request.setAttribute("reportObject", obj);
        request.setAttribute("requestFacade", req);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);


        if (error.size() > 0) {
            return new ModelAndView("/WEB-INF/jsp/search/searchByPosition.jsp");
        }
        return new ModelAndView("/WEB-INF/jsp/report/expressionStudy/main.jsp");
    }
//    @Override
//    public String getViewUrl() throws Exception {
//        return "expressionStudy/main.jsp";
//    }
//
//    @Override
//    public Object getObject(int studyId) throws Exception {
//        return new PhenominerDAO().getStudy(studyId);
//    }
}
