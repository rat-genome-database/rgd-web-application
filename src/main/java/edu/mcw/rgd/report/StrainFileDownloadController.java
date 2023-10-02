package edu.mcw.rgd.report;


import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.SampleDAO;
import edu.mcw.rgd.dao.impl.StrainDAO;
import edu.mcw.rgd.dao.impl.VariantDAO;
import edu.mcw.rgd.datamodel.Map;
import edu.mcw.rgd.datamodel.Sample;
import edu.mcw.rgd.datamodel.Variant;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.reporting.Report;
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
