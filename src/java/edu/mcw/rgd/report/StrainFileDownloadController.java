package edu.mcw.rgd.report;


import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.InputStream;
import java.sql.Blob;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

/**
 * Created by hsnalabolu on 03/31/2020.
 */
public class StrainFileDownloadController implements Controller{



    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        return new ModelAndView("/WEB-INF/jsp/report/strain/strainFileDownload.jsp");
    }

}
