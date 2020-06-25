package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.StrainDAO;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.InputStream;
import java.util.ArrayList;


public class StrainFileUploadController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();
        StrainDAO dao =new StrainDAO();
        try{
        if(request.getParameter("strainId") != null){
            int strainId = Integer.parseInt(request.getParameter("strainId"));
            System.out.println("In");
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
                                        dao.insertStrainAttachment(strainId, type, data, file.getContentType(), fileName);
                                        status.add("File Uploaded Successfully for strain " + strainId + " and " + type);
                                    } else {
                                        dao.updateStrainAttachment(strainId, type, data, file.getContentType(), fileName);
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

}