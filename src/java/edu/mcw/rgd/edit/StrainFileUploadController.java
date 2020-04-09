package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.StrainDAO;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.InputStream;
import java.sql.Blob;
import java.util.ArrayList;


public class StrainFileUploadController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        try{
        if(request.getParameter("strainId") != null){
            int strainId = Integer.parseInt(request.getParameter("strainId"));
            String type = request.getParameter("fileType");
            Part file = request.getPart("file");
            if (file != null) {
                InputStream data = file.getInputStream();
                StrainDAO dao =new StrainDAO();
                String contentType = dao.getContentType(strainId,type);
                if(contentType == null) {
                    dao.insertStrainAttachment(strainId, type, data, file.getContentType());
                    status.add("File Uploaded Successfully for strain "+strainId+ " and "+type);
                }
                else {
                    dao.updateStrainAttachment(strainId, type, data, file.getContentType());
                    warning.add("File already Exists for strain "+strainId+ " and "+type);
                    status.add("File Replaced Successfully for strain "+strainId+ " and \"+type");
                }
            }
        }}catch(Exception e){
            error.add(e.getMessage());
        }

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);
        return new ModelAndView("/WEB-INF/jsp/strainFileUpload.jsp");
    }

}