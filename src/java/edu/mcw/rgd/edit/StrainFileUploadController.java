package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.StrainDAO;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.InputStream;


public class StrainFileUploadController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        if(request.getParameter("fileType") != null){
            int strainId = Integer.parseInt(request.getParameter("strainId"));
            String type = request.getParameter("fileType");
            String desc = request.getParameter("description");
            Part file = request.getPart("file");
            if (file != null) {
                InputStream data = file.getInputStream();
                StrainDAO dao =new StrainDAO();
                dao.insertStrainAttachment(strainId,type,data,desc);
            }
            System.out.println(type);
        }
        return new ModelAndView("/WEB-INF/jsp/strainFileUpload.jsp");
    }

}