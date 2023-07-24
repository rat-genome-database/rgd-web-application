package edu.mcw.rgd.phenominer;

import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.process.pheno.SearchBean;
import edu.mcw.rgd.web.HttpRequestFacade;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;
import org.springframework.web.servlet.mvc.Controller;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Feb 25, 2011
 * Time: 4:38:23 PM
 * To change this template use File | Settings | File Templates.
 */

/**
 * Base class for curation software controllers
 */

public abstract class PhenominerController implements Controller {

    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;

    String login = "";
    protected SearchBean buildSearchBean(HttpRequestFacade req, PhenominerDAO dao) {

        SearchBean sb = new SearchBean();

        if (!req.getParameter("studyId").equals("")) {
            sb.setStudyId(req.getParameter("studyId"));
        }
        if (!req.getParameter("studyName").equals("")) {
            sb.setStudyName(req.getParameter("studyName"));
        }
        if (!req.getParameter("source").equals("")) {
            sb.setStudySource(req.getParameter("source"));
        }
        if (!req.getParameter("type").equals("")) {
            sb.setStudyType(req.getParameter("type"));
        }
        if (!req.getParameter("reference").equals("")) {
            sb.setReference(req.getParameter("reference"));
        }

        if (!req.getParameter("expId").equals("")) {
            sb.setExperimentId(req.getParameter("expId"));
        }
        if (!req.getParameter("expName").equals("")) {
            sb.setExperimentName(req.getParameter("expName"));
        }

        if (!req.getParameter("recordId").equals("")) {
            sb.setRecordId(req.getParameter("recordId"));
        }
        //check for clinical measurement values
        if (!req.getParameter("cmAccId").equals("")) {
            sb.setCmAccId(req.getParameter("cmAccId"));
        }
        if (!req.getParameter("cmValue").equals("")) {
            sb.setCmValue(req.getParameter("cmValue"));
        }
        if (!req.getParameter("cmUnits").equals("")) {
            sb.setCmUnits(req.getParameter("cmUnits"));
        }
        if (!req.getParameter("cmSD").equals("")) {
            sb.setCmSD(req.getParameter("cmSD"));
        }
        if (!req.getParameter("cmSEM").equals("")) {
            sb.setCmSEM(req.getParameter("cmSEM"));
        }
        if (!req.getParameter("cmError").equals("")) {
            sb.setCmError(req.getParameter("cmError"));
        }
        if (!req.getParameter("cmAveType").equals("")) {
            sb.setCmAveType(req.getParameter("cmAveType"));
        }
        if (!req.getParameter("cmFormula").equals("")) {
            sb.setCmFormula(req.getParameter("cmFormula"));
        }

        //check for measurement method values
        if (!req.getParameter("mmAccId").equals("")) {
            sb.setMmAccId(req.getParameter("mmAccId"));
        }
        if (!req.getParameter("mmDuration").equals("")) {
            sb.setMmDuration(req.getParameter("mmDuration"));
        }
        if (!req.getParameter("mmSite").equals("")) {
            sb.setMmSite(req.getParameter("mmSite"));
        }
        if (!req.getParameter("mmPostInsultType").equals("")) {
            sb.setMmPIType(req.getParameter("mmPostInsultType"));
        }
        if (!req.getParameter("mmPostInsultTime").equals("")) {
            sb.setMmPITime(req.getParameter("mmPostInsultTime"));
        }
        if (!req.getParameter("mmInsultTimeUnit").equals("")) {
            sb.setMmPIUnit(req.getParameter("mmInsultTimeUnit"));
        }

        //check for strain values
        if (!req.getParameter("sAccId").equals("")) {
            sb.setSAccId(req.getParameter("sAccId"));
        }
        if (!req.getParameter("sAnimalCount").equals("")) {
            sb.setSAnimalCount(req.getParameter("sAnimalCount"));
        }
        if (!req.getParameter("sMinAge").equals("")) {
            sb.setSMinAge(req.getParameter("sMinAge"));
        }
        if (!req.getParameter("sMaxAge").equals("")) {
            sb.setSMaxAge(req.getParameter("sMaxAge"));
        }
        if (!req.getParameter("sSex").equals("")) {
            sb.setSSex(req.getParameter("sSex"));
        }


        if (!req.getParameter("cAccId").equals("")) {
            sb.setCAccId(req.getParameter("cAccId"));
        }
        if (!req.getParameter("cValueMin").equals("")) {
            sb.setCValueMin(req.getParameter("cValueMin"));
        }
        if (!req.getParameter("cValueMax").equals("")) {
            sb.setCValueMax(req.getParameter("cValueMax"));
        }
        if (!req.getParameter("cUnits").equals("")) {
            sb.setCUnits(req.getParameter("cUnits"));
        }
        if (!req.getParameter("cMinDuration").equals("")) {
            sb.setCMinDuration(req.getParameter("cMinDuration"));
        }
        if (!req.getParameter("cMaxDuration").equals("")) {
            sb.setCMaxDuration(req.getParameter("cMaxDuration"));
        }
        if (!req.getParameter("cApplicationMethod").equals("")) {
            sb.setCapplicationMethod(req.getParameter("cApplicationMethod"));
        }
        if (!req.getParameter("cOrdinality").equals("")) {
            sb.setCordinality(req.getParameter("cOrdinality"));
        }

        return sb;


    }

    protected String buildLink(String url, String text) {
        return "<a href=\"" + url + "\">" + text + "</a>";
    }

    protected String buildLink(String url, int text) {
        return this.buildLink(url, text + "");
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
