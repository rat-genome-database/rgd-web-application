package edu.mcw.rgd.pathway;

import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Feb 19, 2008
 * Time: 3:16:05 PM
 * To change this template use File | Settings | File Templates.
 */
public class PathwayDiagramController implements Controller {

    ArrayList error = new ArrayList();
    ArrayList warning = new ArrayList();
    ArrayList status = new ArrayList();
    public static String dataDir;

    public String getUploadingDir() {
        return uploadingDir;
    }

    public void setUploadingDir(String uploadingDir) {
        this.uploadingDir = uploadingDir;
    }

    public static String uploadingDir;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(request);
        String type = req.getParameter("type");
        String name = req.getParameter("name");
        String acc  =  req.getParameter("acc_id");

        String htmlContent = generateContent(type, acc);

        if(htmlContent.equals("")){
            ArrayList errorNew = new ArrayList();
            request.setAttribute("error", errorNew);
            errorNew.add("Something went wrong in acquiring the pathway diagram, try uploading the correct pathway diagram again");
            ModelAndView mv = new ModelAndView("/WEB-INF/jsp/curation/pathway/pathwayCreate.jsp");
            mv.addObject("uploadingDir", uploadingDir);
            mv.addObject("dataDir", dataDir);
            mv.addObject("error", errorNew);
            return mv;
        }else{
            response.getWriter().write(htmlContent);
            return null;
        }
    }

public String generateContent(String type, String acc_id) throws Exception {


         DiagramGenerator dg = new DiagramGenerator();
         String content = "";

         if (type.equals("small")) {
            content = dg.getSmallImage(acc_id, uploadingDir);

         }else
         if(type.equals("gpp")){
             content = dg.getGPPFile(acc_id, uploadingDir);
             
         }else
         if (type.equals("map")) {
            content = dg.getImageMap(acc_id, uploadingDir, dataDir);
             //System.out.println("no content");
             // unfortunately diagram generator wraps the chart within <body> tags -- who did that???

         }
         else {
            throw new Exception("unknown type: "+type);
         }

         if(content.contains("</body>")){
             return content.replace("<body>","").replace("</body>","");
         }else{
             //System.out.println("no content");
             return "";
         }

    }

    public void setDataDir(String dataDir) {
        this.dataDir = dataDir;
    }

    public String getDataDir() {
        return dataDir;
    }
}
