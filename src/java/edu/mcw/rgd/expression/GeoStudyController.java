package edu.mcw.rgd.expression;

import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.GeoRecord;
import edu.mcw.rgd.datamodel.pheno.Experiment;
import edu.mcw.rgd.datamodel.pheno.Sample;
import edu.mcw.rgd.datamodel.pheno.Study;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


public class GeoStudyController implements Controller {

    PhenominerDAO pdao = new PhenominerDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList<String> status = new ArrayList<>();
        ArrayList<String> error = new ArrayList<>();

        if(request.getParameter("act") != null &&
                ( request.getParameter("act").equalsIgnoreCase("createExperiment") || request.getParameter("act").equalsIgnoreCase("editExperiment")) ){
            try{
                Experiment e = new Experiment();
                e.setStudyId(Integer.parseInt(request.getParameter("studyId")));
                e.setName(request.getParameter("name"));
                e.setTraitOntId(request.getParameter("traitOntId"));
                e.setNotes(request.getParameter("notes"));
                if (request.getParameter("act").equalsIgnoreCase("createExperiment"))
                    pdao.insertExperiment(e);
                else if (request.getParameter("act").equalsIgnoreCase("editExperiment")) {
                    e.setId(Integer.parseInt(request.getParameter("expId")));
                    pdao.updateExperiment(e);
                }

                request.setAttribute("studyId",e.getStudyId());
            }catch (Exception e){
                error.add("Experiment insertion failed for" + e.getMessage());
            }
            return new ModelAndView("/WEB-INF/jsp/expression/study.jsp");
        }
        else if (request.getParameter("act") != null ) {
         try{
             Study s = new Study();
            s.setName(request.getParameter("name"));
            s.setSource(request.getParameter("source"));
            s.setType(request.getParameter("type"));
            s.setRefRgdId(Integer.parseInt(request.getParameter("refRgdId")));
            s.setGeoSeriesAcc(request.getParameter("geoSeriesAcc"));

            if (request.getParameter("act").equalsIgnoreCase("createStudy"))
                pdao.insertStudy(s);

            else if (request.getParameter("act").equalsIgnoreCase("editStudy")) {
                s.setId(Integer.parseInt(request.getParameter("studyId")));
                pdao.updateStudy(s);
            }
            status.add("Study Creation Successful");
             request.setAttribute("studyId",s.getId());
        }catch (Exception e){
            error.add("Study creation failed for" + e.getMessage());

        }
            return new ModelAndView("/WEB-INF/jsp/expression/study.jsp");
        }

        if(request.getParameter("studyId") != null) {
            request.setAttribute("studyId", request.getParameter("studyId"));
            return new ModelAndView("/WEB-INF/jsp/expression/editExperiment.jsp");
        } else {
            String gse = request.getParameter("gse");
            List<GeoRecord> samples = pdao.getGeoRecords(gse,request.getParameter("species"));
            request.setAttribute("title",samples.get(0).getStudyTitle());
            request.setAttribute("pmid",samples.get(0).getPubmedId());
            return new ModelAndView("/WEB-INF/jsp/expression/study.jsp");
        }


    }
}



