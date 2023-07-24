package edu.mcw.rgd.report;


import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

/**
 * Created by hsnalabolu on 03/31/2020.
 */
public class StrainFileDownloadController implements Controller{



    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        return new ModelAndView("/WEB-INF/jsp/report/strain/strainFileDownload.jsp");
    }

}
