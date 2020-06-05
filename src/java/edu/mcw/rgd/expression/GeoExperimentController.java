package edu.mcw.rgd.expression;

import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.pheno.Sample;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.HashMap;
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
                    String species = request.getParameter("species");
                    Report r = new Report();
                    Record header = new Record();
                    header.append("Sample ID");
                    header.append("Geo Accession ID");
                    header.append("Tissue ID");
                    header.append("Strain ID");
                    header.append("Cell ID");
                    header.append("Age High");
                    header.append("Age Low");
                    header.append("Sex");
                    r.append(header);
                for (int i = 1; i < count; i++) {
                    Sample s = new Sample();
                    Record rec = new Record();
                    s.setSex(request.getParameter("sex" + i));
                    s.setTissueAccId(request.getParameter("tissueId" + i));
                    s.setCellTypeAccId(request.getParameter("cellId" + i));
                    s.setGeoSampleAcc(request.getParameter("sampleId" + i));
                    s.setStrainAccId(request.getParameter("strainId" + i));
                    s.setBioSampleId(request.getParameter("sampleId" + i));
                    if (request.getParameter("ageHigh" + i) != null && !request.getParameter("ageHigh" + i).equals(""))
                        s.setAgeDaysFromHighBound(Integer.parseInt(request.getParameter("ageHigh" + i)));
                    if (request.getParameter("ageLow" + i) != null && !request.getParameter("ageLow" + i).equals(""))
                        s.setAgeDaysFromLowBound(Integer.parseInt(request.getParameter("ageLow" + i)));

                    s.setNumberOfAnimals(1);
                    int sampleId = pdao.insertSample(s);
                    rec.append(String.valueOf(sampleId));
                    rec.append(s.getGeoSampleAcc());
                    rec.append(s.getTissueAccId());
                    rec.append(s.getStrainAccId());
                    rec.append(s.getCellTypeAccId());
                    rec.append(String.valueOf(s.getAgeDaysFromHighBound()));
                    rec.append(String.valueOf(s.getAgeDaysFromLowBound()));
                    rec.append(s.getSex());
                    r.append(rec);
                }

                pdao.updateGeoStudyStatus(gse, "loaded",species);
                    request.setAttribute("report",r);
            }catch (Exception e){
                    error.add("Sample insertion failed " + e.getMessage());

            }
                request.setAttribute("error", error);

                return new ModelAndView("/WEB-INF/jsp/expression/" + "samples.jsp");
            }
            if (request.getParameter("act") != null && request.getParameter("act").equalsIgnoreCase("update")) {
                String gse = request.getParameter("geoId");
                String species = request.getParameter("species");
                String curationStatus = request.getParameter("status");
                pdao.updateGeoStudyStatus(gse, curationStatus,species);
                status.add("Status updated successfully for " + gse);
                request.setAttribute("status", status);
                return new ModelAndView("/WEB-INF/jsp/expression/" + "experiments.jsp");
            }
            if(request.getParameter("tcount") != null){
                int tcount = Integer.parseInt(request.getParameter("tcount"));
                int scount = Integer.parseInt(request.getParameter("scount"));
                int ageCount = Integer.parseInt(request.getParameter("agecount"));
                String gse = request.getParameter("gse");
                String species = request.getParameter("species");
                HashMap<String,String> tissueMap = new HashMap();
                HashMap<String,String> strainMap = new HashMap();
                HashMap<String,String> ageLow = new HashMap<>();
                HashMap<String,String> ageHigh = new HashMap<>();
                for(int i = 1; i < tcount;i++){
                    tissueMap.put(request.getParameter("tissue" + i),request.getParameter("tissueId"+i));
                }
                for(int i = 1; i < scount;i++){
                    strainMap.put(request.getParameter("strain" + i),request.getParameter("strainId"+i));
                }
                for(int i = 1; i < ageCount;i++){
                    ageLow.put(request.getParameter("age" + i),request.getParameter("ageLow"+i));
                    ageHigh.put(request.getParameter("age" + i),request.getParameter("ageHigh"+i));
                }
                request.setAttribute("tissueMap",tissueMap);
                request.setAttribute("strainMap",strainMap);
                request.setAttribute("ageLow",ageLow);
                request.setAttribute("ageHigh",ageHigh);
                request.setAttribute("species",species);
                request.setAttribute("gse",gse);
                return new ModelAndView("/WEB-INF/jsp/expression/createSample.jsp");
            }
            if (request.getParameter("gse") != null) {
                System.out.println("In the block");

                return new ModelAndView("/WEB-INF/jsp/expression/editSample.jsp");
            } else return new ModelAndView("/WEB-INF/jsp/expression/" + "experiments.jsp");

        }

    }

