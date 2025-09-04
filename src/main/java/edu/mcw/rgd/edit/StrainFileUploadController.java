package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.StrainDAO;
import edu.mcw.rgd.web.RgdContext;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;


public class StrainFileUploadController implements Controller {
    String login = "";
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        // Debug logging
        System.out.println("StrainFileUploadController: Method=" + request.getMethod());
        System.out.println("StrainFileUploadController: Content-Type=" + request.getContentType());
        System.out.println("StrainFileUploadController: Request URI=" + request.getRequestURI());
        
        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();
        StrainDAO dao =new StrainDAO();
        int strainId = 0;
        
        // Authentication is handled by AuthenticationInterceptor
        // For GET requests: interceptor checks auth before page loads
        // For POST requests: interceptor skips check (user already authenticated)
        
        // Extract login from access token if present (for logging purposes)
        if(request.getCookies() != null && request.getCookies().length != 0) {
            for(jakarta.servlet.http.Cookie cookie : request.getCookies()) {
                if(cookie.getName().equalsIgnoreCase("accessToken")) {
                    String accessToken = cookie.getValue();
                    try {
                        extractLoginFromToken(accessToken);
                    } catch(Exception e) {
                        // Ignore token extraction errors
                    }
                    break;
                }
            }
        }
        
        try{
        System.out.println("StrainFileUploadController: Checking for strainId parameter");
        String strainIdParam = request.getParameter("strainId");
        System.out.println("StrainFileUploadController: strainId parameter = " + strainIdParam);
        
        if(strainIdParam != null){
            strainId = Integer.parseInt(strainIdParam);
            System.out.println("StrainFileUploadController: Processing strainId=" + strainId);
            String[] types = {"Genotype","Highlights","Supplemental"};
                for (String type : types) {
                    boolean isSet = false;
                    try {
                        System.out.println("StrainFileUploadController: Attempting to get part for type=" + type);
                        Part file = request.getPart(type);
                        System.out.println("StrainFileUploadController: Got part for type=" + type + ", part=" + file);
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
            System.out.println("StrainFileUploadController: Exception caught - " + e.getClass().getName() + ": " + e.getMessage());
            e.printStackTrace();
            error.add(e.getMessage());
        }

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);



        return new ModelAndView("/WEB-INF/jsp/curation/strainFileUpload.jsp");
    }
    protected void extractLoginFromToken(String token) throws Exception {
        if(token != null && !token.isEmpty()) {
            URL url = new URL("https://api.github.com/user");
            HttpURLConnection conn = (HttpURLConnection)url.openConnection();
            conn.setRequestProperty("User-Agent", "Mozilla/5.0");
            conn.setRequestProperty("Authorization", "Token "+token);

            try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream())) ) {
                String line = in.readLine();
                JSONObject json = new JSONObject(line);
                login = (String)json.get("login");
            }
        }
    }
}