package edu.mcw.rgd.web;

import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.reporting.Record;
import org.springframework.web.servlet.mvc.Controller;
import org.springframework.web.servlet.ModelAndView;
import edu.mcw.rgd.reporting.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class FormatController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(request);

        int height = Integer.parseInt(Utils.NVL(request.getParameter("height"), "0"));
        int width = Integer.parseInt(Utils.NVL(request.getParameter("width"), "0"));

        Report report = new Report();

        for(int i=0; i < height; i++) {
            Record record = new Record();
            for (int j=0; j< width; j++) {
                record.append(req.getParameter("v" + i + "_" + j));
            }
            report.append(record);
        }

        report.sort(1,Report.CHROMOSOME_SORT,Report.ASCENDING_SORT, false);


        response.setContentType("application/msexcel");
        response.setHeader("Content-Disposition", "inline; filename=gviewer.csv" );

        response.getWriter().println(new DelimitedReportStrategy().format(report));
        return null;
    }
}
