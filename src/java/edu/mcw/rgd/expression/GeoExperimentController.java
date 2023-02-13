package edu.mcw.rgd.expression;

import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.pheno.Condition;
import edu.mcw.rgd.datamodel.pheno.Sample;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


public class GeoExperimentController implements Controller {

    PhenominerDAO pdao = new PhenominerDAO();
    public String login = "";
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList<String> status = new ArrayList<>();
        ArrayList<String> error = new ArrayList<>();
        String accessToken = null;
        if(request.getCookies() != null && request.getCookies().length != 0)
            if(request.getCookies()[0].getName().equalsIgnoreCase("accessToken"))
                accessToken = request.getCookies()[0].getValue();


        if(!checkToken(accessToken)) {
            response.sendRedirect("https://github.com/login/oauth/authorize?client_id=dc5513384190f8a788e5&scope=user&redirect_uri=https://pipelines.rgd.mcw.edu/rgdweb/curation/login.html");
            return null;
        }
            if (request.getParameter("count") != null) {
                Report r = new Report();
                try {
                int count = Integer.parseInt(request.getParameter("count"));
                String gse = request.getParameter("gse");
                    String species = request.getParameter("species");

                    Record header = new Record();
                    header.append("Sample ID");
                    header.append("Geo Accession ID");
                    header.append("Tissue ID");
                    header.append("Strain ID");
                    header.append("Cell ID");
                    header.append("Cell Line ID");
                    header.append("Age High");
                    header.append("Age Low");
                    header.append("Sex");
                    header.append("Life Stage");
                    header.append("Notes");
                    header.append("Curator Notes");
                    r.append(header);
                for (int i = 0; i < count; i++) {
                    Sample s = new Sample();
                    Record rec = new Record();
                    s.setSex(request.getParameter("sex" + i));
                    s.setTissueAccId(request.getParameter("tissueId" + i));
                    s.setCellTypeAccId(request.getParameter("cellTypeId" + i));
                    s.setCellLineId(request.getParameter("cellLineId" + i));
                    s.setGeoSampleAcc(request.getParameter("sampleId" + i));
                    s.setStrainAccId(request.getParameter("strainId" + i));
                    s.setBioSampleId(request.getParameter("sampleId" + i));
                    String[] lifeStages = request.getParameterValues("lifeStage"+i);
                    String stage = "";
                    if (lifeStages!=null) {
                        for (int j = 0; j < lifeStages.length; j++) {
                            stage += lifeStages[j];
                            if (j != lifeStages.length - 1)
                                stage += ";";
                        }
                    }
                    if (stage.isEmpty())
                        stage=null;
                    s.setLifeStage(stage);
                    s.setNotes(request.getParameter("notes"+i));
                    s.setCuratorNotes(request.getParameter("cNotes"+i));
                    String curStatus = request.getParameter("status"+i);
                    String curAction = request.getParameter("action"+i);

                    if (request.getParameter("ageHigh" + i) != null && !request.getParameter("ageHigh" + i).isEmpty())
                        s.setAgeDaysFromHighBound(Integer.parseInt(request.getParameter("ageHigh" + i)));
                    if (request.getParameter("ageLow" + i) != null && !request.getParameter("ageLow" + i).isEmpty() )
                        s.setAgeDaysFromLowBound(Integer.parseInt(request.getParameter("ageLow" + i)));

                    s.setNumberOfAnimals(1);
                    int sampleId = 0;
                    Sample sample = pdao.getSampleByGeoId(s.getBioSampleId());


                    if(sample == null && curAction.equals("load")) {
                        s.setCreatedBy(login);
                        sampleId = pdao.insertSample(s);
                    }
                    else if (curAction.equals("load") || curAction.equals("edit")){
                        s.setId(sample.getId());
                        sampleId = sample.getId();
                        s.setLastModifiedBy(login);
                        pdao.updateSample(s);
                    }
                    if (curAction.equals("load") || curAction.equals("edit")) {
                        rec.append(String.valueOf(sampleId));
                        rec.append(s.getGeoSampleAcc());
                        rec.append(s.getTissueAccId());
                        rec.append(s.getStrainAccId());
                        rec.append(s.getCellTypeAccId());
                        rec.append(s.getCellLineId());
                        rec.append(String.valueOf(s.getAgeDaysFromHighBound()));
                        rec.append(String.valueOf(s.getAgeDaysFromLowBound()));
                        rec.append(s.getSex());
                        rec.append(s.getLifeStage());
                        rec.append(s.getNotes());
                        rec.append(s.getCuratorNotes());
                        r.append(rec);
                    }
                    if (curStatus.equals("pending") && curAction.equals("load"))
                        pdao.updateGeoSampleStatus(gse,s.getBioSampleId(),"loaded",species);
                    else {
                        switch (curStatus) {
                            case "loaded":
                                pdao.updateGeoSampleStatus(gse, s.getBioSampleId(), "loaded", species);
                                break;
                            case "not4Curation":
                                pdao.updateGeoSampleStatus(gse, s.getBioSampleId(), "not4Curation", species);
                                break;
                            case "futureCuration":
                                pdao.updateGeoSampleStatus(gse, s.getBioSampleId(), "futureCuration", species);
                                break;
                            case "pending":
                                pdao.updateGeoSampleStatus(gse, s.getBioSampleId(), "pending", species);
                                break;
                        }
                    }

                    // stuff with experimental conditions
                    edu.mcw.rgd.datamodel.pheno.Record record = new edu.mcw.rgd.datamodel.pheno.Record();
                }


//                pdao.updateGeoStudyStatus(gse, "loaded",species);

            }catch (Exception e){
                    error.add("Sample insertion failed for" + e.getMessage());

            }
                request.setAttribute("error", error);
                request.setAttribute("report",r);
                return new ModelAndView("/WEB-INF/jsp/curation/expression/" + "samples.jsp");
            }
            if (request.getParameter("act") != null && request.getParameter("act").equalsIgnoreCase("update")) {
                String gse = request.getParameter("geoId");
                String species = request.getParameter("species");
                String curationStatus = request.getParameter("status");
                pdao.updateGeoStudyStatus(gse, curationStatus,species);
                status.add("Status updated successfully for " + gse);
                request.setAttribute("status", status);
                return new ModelAndView("/WEB-INF/jsp/curation/expression/" + "experiments.jsp");
            }
            if(request.getParameter("tcount") != null){
                int tcount = Integer.parseInt(request.getParameter("tcount"));
                int scount = Integer.parseInt(request.getParameter("scount"));
                int ctcount = Integer.parseInt(request.getParameter("ctcount"));
                int clcount = Integer.parseInt(request.getParameter("clcount"));
                int ageCount = Integer.parseInt(request.getParameter("agecount"));
                int gcount = Integer.parseInt(request.getParameter("gcount"));
                int noteCnt = Integer.parseInt(request.getParameter("notescount"));
                int condCnt = Integer.parseInt(request.getParameter("conditionCount"));
                int sampleSize = Integer.parseInt(request.getParameter("samplesExist"));
                String gse = request.getParameter("gse");
                String species = request.getParameter("species");
                HashMap<String,String> tissueMap = new HashMap();
                HashMap<String, String> tissuneNameMap = new HashMap<>();
                HashMap<String,String> strainMap = new HashMap();
                HashMap<String,String> strainNameMap = new HashMap<>();
                HashMap<String,String> cellType = new HashMap();
                HashMap<String,String> cellNameMap = new HashMap<>();
                HashMap<String,String> cellLine = new HashMap();
                HashMap<String,String> ageLow = new HashMap<>();
                HashMap<String,String> ageHigh = new HashMap<>();
                HashMap<String,String> gender = new HashMap<>();
                HashMap<String,String> lifeStage = new HashMap<>();
                HashMap<String,String> notes = new HashMap<>();
                HashMap<String, String> curNotes = new HashMap<>();
                HashMap<String,String> xcoMap = new HashMap<>();
                List<Condition> conditions = new ArrayList<Condition>();
                for(int i = 0; i < tcount;i++){
                    if (request.getParameter("tissue" + i).contains("imported!")) {
                        tissueMap.put(null, request.getParameter("tissueId" + i));
                        tissuneNameMap.put(null,request.getParameter("uberon"+i+"_term"));
                    }
                    else {
                        tissueMap.put(request.getParameter("tissue" + i), request.getParameter("tissueId" + i));
                        tissuneNameMap.put(request.getParameter("tissue" + i),request.getParameter("uberon"+i+"_term"));
                    }
                }
                for(int i = 0; i < scount;i++){
                    if (request.getParameter("strain" + i).contains("imported!")) {
                        strainMap.put(null, request.getParameter("strainId" + i));
                        strainNameMap.put(null,request.getParameter("rs"+i+"_term"));
                    }
                    else {
                        strainMap.put(request.getParameter("strain" + i), request.getParameter("strainId" + i));
                        strainNameMap.put(request.getParameter("strain" + i),request.getParameter("rs"+i+"_term"));
                    }
                }
                for(int i = 0; i < ageCount;i++){
                    ageLow.put(request.getParameter("age" + i),request.getParameter("ageLow"+i));
                    ageHigh.put(request.getParameter("age" + i),request.getParameter("ageHigh"+i));
                    String[] lifeStages = request.getParameterValues("lifeStage"+i);
                    String stage = "";
                    if (lifeStages!=null) {
                        for (int j = 0; j < lifeStages.length; j++) {
                            stage += lifeStages[j];
                            if (j != lifeStages.length - 1)
                                stage += ";";
                        }
                    }
                    lifeStage.put(request.getParameter("age"+i),stage);
                }
                for(int i = 0; i < ctcount;i++){
                    if (request.getParameter("cellType"+i).contains("imported!")) {
                        cellType.put(null, request.getParameter("cellTypeId" + i));
                        cellNameMap.put(null,request.getParameter("cl"+i+"_term"));
                    }
                    else {
                        cellType.put(request.getParameter("cellType" + i), request.getParameter("cellTypeId" + i));
                        cellNameMap.put(request.getParameter("cellType" + i),request.getParameter("cl_term"+i));
                    }
                }
                for(int i = 0; i < clcount;i++){
                    if (request.getParameter("cellLine" + i).contains("imported!"))
                        cellLine.put(null,request.getParameter("cellLineId"+i));
                    else
                        cellLine.put(request.getParameter("cellLine" + i),request.getParameter("cellLineId"+i));
                }
                for(int i = 0; i < gcount;i++){
                    gender.put(request.getParameter("gender" + i),request.getParameter("sex"+i));
                }
                for (int i = 0; i < noteCnt ; i++){
                    notes.put(null,request.getParameter("notesId"+i));
                    curNotes.put(null,request.getParameter("cNotesId"+i));
                }

                HttpRequestFacade req = new HttpRequestFacade(request);
                String[] cValueMin = req.getRequest().getParameterValues("cValueMin");
                String[] cValueMax = req.getRequest().getParameterValues("cValueMax");
                String[] cUnits = req.getRequest().getParameterValues("cUnits");
                String[] cMinDuration = req.getRequest().getParameterValues("cMinDuration");
                String[] cMinDurationUnits = req.getRequest().getParameterValues("cMinDurationUnits");
                String[] cMaxDuration = req.getRequest().getParameterValues("cMaxDuration");
                String[] cMaxDurationUnits = req.getRequest().getParameterValues("cMaxDurationUnits");
                String[] cApplicationMethod = req.getRequest().getParameterValues("cApplicationMethod");
                String[] cOrdinality = req.getRequest().getParameterValues("cOrdinality");
                String[] cNotes = req.getRequest().getParameterValues("cNotes");
                for (int i = 0; i < condCnt; i++) {
                    String xcoId = request.getParameter("xcoId"+i);
                    if (!Utils.isStringEmpty(xcoId) && !Utils.isStringEmpty(cOrdinality[i]) ) {
                        String xcoTerm = request.getParameter("xco"+i+"_term");
                        xcoMap.put(xcoId, xcoTerm);
                        Condition c = new Condition();
                        c.setOntologyId(xcoId);
                        c.setValueMin(cValueMin[i]);
                        c.setValueMax(cValueMax[i]);
                        c.setUnits(cUnits[i]);
                        if (!Utils.isStringEmpty(cMinDuration[i])) {
                            c.setDurationLowerBound(convertToSeconds(Double.parseDouble(cMinDuration[i]),cMinDurationUnits[i]) );
                        }
                        if (!Utils.isStringEmpty(cMaxDuration[i])) {
                            c.setDurationUpperBound(convertToSeconds(Double.parseDouble(cMaxDuration[i]),cMaxDurationUnits[i]) );
                        }
                        c.setApplicationMethod(cApplicationMethod[i]);
                        c.setOrdinality(i);
                        c.setNotes(cNotes[i]);
                        conditions.add(c);
                    }
                }

                request.setAttribute("tissueMap",tissueMap);
                request.setAttribute("tissueNameMap", tissuneNameMap);
                request.setAttribute("strainMap",strainMap);
                request.setAttribute("strainNameMap",strainNameMap);
                request.setAttribute("cellLine",cellLine);
                request.setAttribute("cellType",cellType);
                request.setAttribute("cellNameMap",cellNameMap);
                request.setAttribute("gender",gender);
                request.setAttribute("ageLow",ageLow);
                request.setAttribute("ageHigh",ageHigh);
                request.setAttribute("species",species);
                request.setAttribute("gse",gse);
                request.setAttribute("lifeStage",lifeStage);
                request.setAttribute("notesMap",notes);
                request.setAttribute("curNotesMap",curNotes);
                request.setAttribute("samplesExist", sampleSize);
                request.setAttribute("conditions", conditions);
                request.setAttribute("xcoTerms", xcoMap);
                return new ModelAndView("/WEB-INF/jsp/curation/expression/createSample.jsp");
            }
            if (request.getParameter("gse") != null) {
                return new ModelAndView("/WEB-INF/jsp/curation/expression/editSample.jsp");
            } else return new ModelAndView("/WEB-INF/jsp/curation/expression/" + "experiments.jsp");

        }
    protected boolean checkToken(String token) throws Exception{
        if(token == null || token.isEmpty()){
            return false;
        }else {
            URL url = new URL("https://api.github.com/user");
            HttpURLConnection conn = (HttpURLConnection)url.openConnection();
            conn.setRequestProperty("User-Agent", "Mozilla/5.0");
            conn.setRequestProperty("Authorization", "Token "+token);

            try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream())) ) {
                String line = in.readLine();
                JSONObject json = new JSONObject(line);
                login = (String)json.get("login");
                if(!login.equals("")){
                    URL checkUrl = new URL("https://api.github.com/orgs/rat-genome-database/members/"+login);
                    HttpURLConnection connection = (HttpURLConnection)checkUrl.openConnection();
                    connection.setRequestProperty("User-Agent", "Mozilla/5.0");
                    connection.setRequestProperty("Authorization", "Token "+token);
                    if(connection.getResponseCode()== 204)
                        return true;
                }
            }


            return false;
        }
    }
    private double convertToSeconds(double value, String units) {

        if (units.equals("secs")) {
            return value;
        } else if (units.equals("mins")) {
            return value * 60;
        } else if (units.equals("hours")) {
            return value * 60 * 60;
        } else if (units.equals("days")) {
            return value * 60 * 60 * 24;
        } else if (units.equals("weeks")) {
            return value * 60 * 60 * 24 * 7;
        } else if (units.equals("months")) {
            return value * 60 * 60 * 24 * (365 / 12);
        } else if (units.equals("years")) {
            return value * 60 * 60 * 24 * 365;
        }

        return Condition.convertStringToDurationBound(units);
    }
}

