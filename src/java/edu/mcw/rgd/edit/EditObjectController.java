package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.AliasDAO;
import edu.mcw.rgd.dao.impl.NomenclatureDAO;
import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.ontology.Annotation;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public abstract class EditObjectController implements Controller {

    public abstract String getViewUrl() throws Exception;
    public abstract int getObjectTypeKey();
    public abstract Object update(HttpServletRequest request, boolean persist) throws Exception;
    public abstract Object getObject(int rgdId) throws Exception;
    public abstract Object getSubmittedObject(int submissionKey) throws Exception;
    public abstract Object newObject() throws Exception;

    public String geneType;
    public String login = "";
    public String getGeneType() {
        return geneType;
    }
    public void setGeneType(String geneType) {
        this.geneType = geneType;
    }


    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {        
        this.request = request;
        this.response = response;

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();
        String path = "/WEB-INF/jsp/curation/edit/";


        String action, objectStatus, sRgdId, submissionKey, geneType, additionalInfo, submittedAvailability, submittedBackgroundStrain,submittedParentGene, submittedAlleleRgdId;
        String references;
        int speciesTypeKey;
        String accessToken;
        {
            HttpRequestFacade rq = new HttpRequestFacade(request);
            request.setAttribute("requestFacade", rq);
            action = rq.getParameter("act");
            objectStatus = rq.getParameter("objectStatus");
            speciesTypeKey = SpeciesType.parse(rq.getParameter("speciesType"));
            sRgdId = rq.getParameter("rgdId");
            /***********SUBMITTED STRAIN INFORMATION***************************************/
            submissionKey=rq.getParameter("submissionKey");
            geneType=rq.getParameter("geneType");
            additionalInfo=rq.getParameter("additionalInfo");
            submittedAvailability=rq.getParameter("submittedAvailability");

            submittedBackgroundStrain= rq.getParameter("backgroundStrain");
            submittedParentGene=rq.getParameter("submittedParentGene");
            submittedAlleleRgdId=rq.getParameter("submittedAlleleRgdId");
            references=rq.getParameter("references");


            accessToken = null;
            if(request.getCookies() != null && request.getCookies().length != 0)
                if(request.getCookies()[0].getName().equalsIgnoreCase("accessToken"))
                    accessToken = request.getCookies()[0].getValue();




        }

   if(!checkToken(accessToken)) {
    //  response.sendRedirect("https://github.com/login/oauth/authorize?client_id=dc5513384190f8a788e5&scope=user&redirect_uri=https://pipelines.rgd.mcw.edu/rgdweb/curation/login.html");
    response.sendRedirect(RgdContext.getGithubOauthRedirectUrl());
        return null;
   }
    if(geneType!=null)
        {  this.setGeneType(geneType);}
        /**************************************************************************************/
        Object o = null;
        Object clone=null;
        int rgdId = -1;
        boolean isNew = false;
        boolean isClone = false;

        switch (action) {
            case "upd":
            case "add":
                try {
                    o = this.update(request, true);
                    status.add("Update Successful");
                } catch (Exception e) {
                    error.add("Error updating object. " + e.getMessage());
                    e.printStackTrace();
                }
                break;
            case "clone": {
                //RGDManagementDAO rdao = new RGDManagementDAO();
                //RgdId id = rdao.createRgdId(this.getObjectTypeKey(), objectStatus, speciesTypeKey);
                o = this.newObject();
                clone = this.getObject(Integer.parseInt(sRgdId));
                isClone = true;
                isNew = true;
                break;
            }
            case "del":
                break;
            case "new":
                o = this.newObject();
                isNew = true;
                break;
            /*******************************SUBMITTED STRAIN CASE***************************/
            case "submitted":
                o=this.getSubmittedObject(Integer.parseInt(submissionKey));
                isNew=true;
                break;
            /******************************************************************************/
            case "symbol": {
                // get symbol for an object
                rgdId = Integer.parseInt(sRgdId);
                RGDManagementDAO rdao = new RGDManagementDAO();
                Object obj = rdao.getObject(rgdId);
                if (obj instanceof ObjectWithSymbol) {
                    response.setContentType("text/plain");
                    response.getWriter().print(((ObjectWithSymbol) obj).getSymbol());
                    return null;
                } else if (obj instanceof Reference) {
                    response.setContentType("text/plain");
                    response.getWriter().print(((Reference) obj).getCitation());
                    return null;
                }

                break;
            }
            case "name": {
                // get name for an object
                rgdId = Integer.parseInt(sRgdId);
                RGDManagementDAO rdao = new RGDManagementDAO();
                Object obj = rdao.getObject(rgdId);
                if (obj instanceof ObjectWithName) {
                    response.setContentType("text/plain");
                    response.getWriter().print(((ObjectWithName) obj).getName());
                    return null;
                }

                break;
            }
            default:

                if (sRgdId.equals("")) {

                    return new ModelAndView(path + "editObject.jsp");
                }
                o = this.getObject(Integer.parseInt(sRgdId));
                break;


        }

    //    request.setAttribute("token",accessToken);
        request.setAttribute("editObject", o);
        request.setAttribute("cloneObject", clone);
        request.setAttribute("isClone", isClone);
        request.setAttribute("isNew", isNew);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        request.setAttribute("additionalInfo", additionalInfo);
        request.setAttribute("submittedAvailability", submittedAvailability);
        request.setAttribute("submittedBackgroundStrain", submittedBackgroundStrain);
        request.setAttribute("submittedParentGene", submittedParentGene);
        request.setAttribute("submittedAlleleRgdId", submittedAlleleRgdId);
        request.setAttribute("references", references);

        if (action.equals("upd") || error.size() > 0 || request.getParameter("clone_and_curate") !=null) {
            return new ModelAndView(path + "status.jsp");
        }else if (action.equals("add")) {
            if(o instanceof Annotation) {
                response.sendRedirect(request.getContextPath() + "/curation/edit/" + this.getViewUrl().replaceAll(".jsp", ".html") + "?rgdId=" + ((Annotation) o).getKey());
                return null;
            }else {
                Identifiable id = (Identifiable) o;
                assert id != null;
                response.sendRedirect(request.getContextPath() + "/curation/edit/" + this.getViewUrl().replaceAll(".jsp", ".html") + "?rgdId=" + id.getRgdId() + "&submittedParentGene=" + submittedParentGene + "&submittedAlleleRgdId=" + submittedAlleleRgdId + "&references=" + references);
                return null;
            }
        }else{
            return new ModelAndView(path + this.getViewUrl());
        }
    }

    protected void addNomenEvents(List<NomenclatureEvent> nomenEvents) throws Exception{
        if (nomenEvents.size() > 0 ) {
            NomenclatureDAO ndao = new NomenclatureDAO();
            for (NomenclatureEvent ne : nomenEvents) {
                ndao.createNomenEvent(ne);
            }
       }        
    }

    /// return nr of aliases inserted into db
    /// Note: duplicate aliases are NOT added
    int insertAliases(List<Alias> aliases) throws Exception {

        AliasDAO aliasDAO = new AliasDAO();

        int aliasesInserted = 0;
        for( Alias alias: aliases ) {
            Alias aliasInRgd = aliasDAO.getAliasByValue(alias.getRgdId(), alias.getValue());
            if (aliasInRgd == null) {
                if( alias.getNotes()==null ) {
                    alias.setNotes("created by Object Edit tool on " + new Date());
                }
                aliasDAO.insertAlias(alias);
                aliasesInserted++;
            }
        }
        return aliasesInserted;
    }

    protected boolean isSet(String value) throws Exception{
        if (value == null || value.trim().equals("")) {
            return false;
        }else {
            return true;
        }
    }

    protected boolean checkSet(String name, String value) throws Exception{
        if (value == null || value.trim().equals("")) {
            throw new Exception(name + " is required.");
        }
        return true;
    }

    protected boolean checkInteger(String name, String value, boolean required) throws Exception{

        if (!required) {
            if (value == null || value.trim().equals("")) {
                return false;
            }
        }

        try {
            Integer.parseInt(value);
        } catch (Exception e) {
            throw new Exception(name + " must be numeric.");
        }
        return true;
    }

    protected boolean checkNumeric(String name, String value, boolean required) throws Exception{

        if (!required) {
            if (value == null || value.trim().equals("")) {
                return false;
            }
        }

        try {
            Double.parseDouble(value);
        } catch (Exception e) {
            throw new Exception(name + " must be numeric.");
        }
        return true;
    }

    protected boolean checkChromosome(String value, boolean required) throws Exception{

        if (!required) {
            if (value == null || value.trim().equals("")) {
                return false;
            }
        }

        try {
            int chrVal = Integer.parseInt(value);
            if (chrVal < 1 || chrVal > 22) {
                throw new Exception("Chromosome value is invalid");
            }
        } catch (Exception e) {
            if (!(value.toLowerCase().equals("x") || value.toLowerCase().equals("y"))) {
                throw new Exception("Chromosome value is invalid");
            }
        }        
        return true;
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
