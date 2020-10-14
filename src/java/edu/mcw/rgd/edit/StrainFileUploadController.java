package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.StrainDAO;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;


public class StrainFileUploadController implements Controller {
    String login = "";
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();
        StrainDAO dao =new StrainDAO();
        int strainId = 0;
        if(request.getCookies() != null && request.getCookies().length != 0)
            if(request.getCookies()[0].getName().equalsIgnoreCase("accessToken")) {
                String accessToken = request.getCookies()[0].getValue();
                if(!checkToken(accessToken)) {
                    response.sendRedirect("https://github.com/login/oauth/authorize?client_id=dc5513384190f8a788e5&scope=user&redirect_uri=https://pipelines.rgd.mcw.edu/rgdweb/curation/login.html");
                    return null;
                }
            }
        try{
        if(request.getParameter("strainId") != null){
            strainId = Integer.parseInt(request.getParameter("strainId"));
            String[] types = {"Genotype","Highlights","Supplemental"};
                for (String type : types) {
                    boolean isSet = false;
                    try {
                        Part file = request.getPart(type);
                        isSet = true;
                        if (isSet) {
                            String fileName = file.getHeader("content-disposition");
                            int index = fileName.lastIndexOf("=");
                            fileName = fileName.substring(index+1);

                            if (!fileName.isEmpty() && fileName != "") {
                                fileName = fileName.replace("\"", "");
                                    InputStream data = file.getInputStream();
                                    String contentType = dao.getContentType(strainId, type);
                                    if (contentType == null) {
                                        dao.insertStrainAttachment(strainId, type, data, file.getContentType(), fileName,login);
                                        status.add("File Uploaded Successfully for strain " + strainId + " and " + type);

                                    } else {
                                        dao.updateStrainAttachment(strainId, type, data, file.getContentType(), fileName,login);
                                        warning.add("File already Exists for strain " + strainId + " and " + type);
                                        status.add("File Replaced Successfully for strain " + strainId + " and "+ type);

                                    }
                                }
                             }

                    }catch(Exception e) {
                        isSet = false;
                    }

                    }

            String oldGenotype = dao.getFileName(strainId,"Genotype");
            String oldHighlights = dao.getFileName(strainId,"Highlights");
            String Supplemental = dao.getFileName(strainId,"Supplemental");
            if(oldGenotype == null)
                request.setAttribute("genotypeFile","");
            else request.setAttribute("genotypeFile",oldGenotype);
            if(oldHighlights == null)
                request.setAttribute("highlightsFile","");
            else request.setAttribute("highlightsFile",oldHighlights);
            if(Supplemental == null)
                request.setAttribute("supplementalFile","");
            else request.setAttribute("supplementalFile",Supplemental);
            request.setAttribute("strainId",strainId);


        }
        }catch(Exception e){
            error.add(e.getMessage());
        }

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);



        return new ModelAndView("/WEB-INF/jsp/curation/strainFileUpload.jsp");
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