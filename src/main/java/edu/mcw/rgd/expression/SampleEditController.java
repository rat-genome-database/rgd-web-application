package edu.mcw.rgd.expression;

import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.GeoRecord;
import edu.mcw.rgd.datamodel.pheno.Sample;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.RgdContext;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class SampleEditController implements Controller {

    public String login = "";
    PhenominerDAO pdao = new PhenominerDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        /* todo: search for sample based on sample ID to start
        *   possibly, use experiments controller redirect to a jsp for create button for re-usability
        *
        */
        ArrayList<String> status = new ArrayList<>();
        ArrayList<String> error = new ArrayList<>();

        String accessToken = null;
        if(request.getCookies() != null && request.getCookies().length != 0)
            if(request.getCookies()[0].getName().equalsIgnoreCase("accessToken"))
                accessToken = request.getCookies()[0].getValue();


        if(!checkToken(accessToken)) {
          //  response.sendRedirect("https://github.com/login/oauth/authorize?client_id=dc5513384190f8a788e5&scope=user&redirect_uri=https://pipelines.rgd.mcw.edu/rgdweb/curation/login.html");
            response.sendRedirect(RgdContext.getGithubOauthRedirectUrl());

            return null;
        }

        if (request.getParameter("count") != null) {
            try {
                int count = Integer.parseInt(request.getParameter("count"));
                for (int i = 0; i < count; i++){
                    Sample s = new Sample();
                    int sampleId = Integer.parseInt(request.getParameter("sample"+i));
                    s.setId(sampleId);
                    s.setStrainAccId(request.getParameter("strainId"+i));
                    s.setCellTypeAccId(request.getParameter("cellTypeId"+i));
                    s.setCellLineId(request.getParameter("cellLine"+i));
                    s.setTissueAccId(request.getParameter("tissueId"+i));
                    s.setGeoSampleAcc(request.getParameter("geoAcc"+i));
                    s.setSex(request.getParameter("sex"+i));
                    s.setLifeStage(request.getParameter("lifeStage" + i));
                    s.setNotes(request.getParameter("notes"+i));
                    if (request.getParameter("ageHigh" + i) != null && !request.getParameter("ageHigh" + i).isEmpty())
                        s.setAgeDaysFromHighBound(Double.parseDouble(request.getParameter("ageHigh" + i)));
                    if (request.getParameter("ageLow" + i) != null && !request.getParameter("ageLow" + i).isEmpty() )
                        s.setAgeDaysFromLowBound(Double.parseDouble(request.getParameter("ageLow" + i)));

                    pdao.updateSample(s);
                }
            }
            catch (Exception e){
                error.add("Sample update failed for "+e.getMessage());
            }
            request.setAttribute("error", error);

        }
        String id = request.getParameter("sampleSearch");
        String geoId = request.getParameter("gse");
        String studyExper = request.getParameter("studyExperBtn");
        String studyExperID = request.getParameter("studyExperSearch");

        if (Utils.isStringEmpty(id) && Utils.isStringEmpty(geoId) && Utils.isStringEmpty(studyExperID)){
            return new ModelAndView("/WEB-INF/jsp/curation/expression/" + "searchSample.jsp");
        }
        if (!Utils.isStringEmpty(id)) {
            try {
                String[] ids = id.split("[,\\s\\n\\r(a-z)(A-Z)]");
//            int sampleId = Integer.parseInt(id);
                List<String> sampleIds = new ArrayList<>(Arrays.asList(ids));
                sampleIds.removeIf(String::isEmpty);
                List<Sample> samples = pdao.getSamplesByIds(sampleIds);
                request.setAttribute("samples", samples);
                return new ModelAndView("/WEB-INF/jsp/curation/expression/editExistingSamples.jsp");
            } catch (Exception ignore) {
                error.add("Invalid sample! " + ignore.getMessage());
            }
        }
        if (!Utils.isStringEmpty(studyExperID) && !Utils.isStringEmpty(studyExper)){
            try {
                if (studyExper.equals("Study")) {
                    List<Sample> studySamples =pdao.getSamplesByStudyId(Integer.parseInt(studyExperID));
                    request.setAttribute("samples", studySamples);
                    return new ModelAndView("/WEB-INF/jsp/curation/expression/editExistingSamples.jsp");
                } else if (studyExper.equals("Experiment")) {
                    List<Sample> experimentSamples =pdao.getSamplesByExperimentId(Integer.parseInt(studyExperID));
                    request.setAttribute("samples", experimentSamples);
                    return new ModelAndView("/WEB-INF/jsp/curation/expression/editExistingSamples.jsp");
                }
            }
            catch (Exception e){
                error.add("Study or Experiment ID! "+e.getMessage());
            }
        }
        if (!Utils.isStringEmpty(geoId)){
            try {
                String species = request.getParameter("species");
                List<GeoRecord> samples = pdao.getGeoRecords(geoId,species);
                if (samples.isEmpty()){
                    error.add("No Geo Samples Found");
                    request.setAttribute("error", error);
                    return new ModelAndView("/WEB-INF/jsp/curation/expression/searchSample.jsp");
                }
                return new ModelAndView("/WEB-INF/jsp/curation/expression/editSample.jsp");
            }
            catch (Exception e){

            }
        }
        request.setAttribute("error", error);
        return new ModelAndView("/WEB-INF/jsp/curation/expression/searchSample.jsp");
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
}
