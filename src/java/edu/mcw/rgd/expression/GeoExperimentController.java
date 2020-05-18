package edu.mcw.rgd.expression;

import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.pheno.Sample;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;


public class GeoExperimentController implements Controller {

    PhenominerDAO pdao = new PhenominerDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList<String> status = new ArrayList<>();
        ArrayList<String> error = new ArrayList<>();

            if (request.getParameter("count") != null) {
                try {
                int count = Integer.parseInt(request.getParameter("count"));
                String gse = request.getParameter("gse");
                for (int i = 1; i < count; i++) {
                    Sample s = new Sample();
                    s.setSex(request.getParameter("sex" + i));
                    s.setTissueAccId(request.getParameter("tissueId") + i);
                    s.setCellTypeAccId(request.getParameter("cellId") + i);
                    s.setGeoSampleAcc(request.getParameter("sampleId") + i);
                    s.setStrainAccId(request.getParameter("strainId") + i);
                    s.setBioSampleId(request.getParameter("sampleId") + i);
                    if (request.getParameter("ageHigh" + i) != null && !request.getParameter("ageHigh" + i).equals(""))
                        s.setAgeDaysFromHighBound(Integer.parseInt(request.getParameter("ageHigh" + i)));
                    if (request.getParameter("ageLow" + i) != null && !request.getParameter("ageLow" + i).equals(""))
                        s.setAgeDaysFromLowBound(Integer.parseInt(request.getParameter("ageLow" + i)));
                    if (request.getParameter("noOfAnimals" + i) != null && !request.getParameter("noOfAnimals" + i).equals(""))
                        s.setNumberOfAnimals(Integer.parseInt(request.getParameter("noOfAnimals" + i)));
                    int sampleId = pdao.insertSample(s);
                    status.add("Sample inserted successfully " + sampleId);
                }
                pdao.updateGeoStudyStatus(gse, "loaded");
            }catch (Exception e){
                    error.add("Sample insertion failed " + e.getMessage());

            }
                request.setAttribute("status", status);
                request.setAttribute("error", error);
                return new ModelAndView("/WEB-INF/jsp/expression/" + "experiments.jsp");
            }
            if (request.getParameter("act") != null && request.getParameter("act").equalsIgnoreCase("update")) {
                String gse = request.getParameter("geoId");
                String curationStatus = request.getParameter("status");
                pdao.updateGeoStudyStatus(gse, curationStatus);
                status.add("Status updated successfully for" + gse);
                request.setAttribute("status", status);
                return new ModelAndView("/WEB-INF/jsp/expression/" + "experiments.jsp");
            }
            if (request.getParameter("gse") != null) {
                return new ModelAndView("/WEB-INF/jsp/expression/createSample.jsp");
            } else return new ModelAndView("/WEB-INF/jsp/expression/" + "experiments.jsp");

        }

    }

