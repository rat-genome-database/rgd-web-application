package edu.mcw.rgd.vv;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.VariantDAO;
import edu.mcw.rgd.datamodel.Variant;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.FormUtility;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class CarpenovoSearchController implements Controller {

    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        VariantDAO vdao = new VariantDAO();
        vdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());

        int sampleId=0;
        String chr=new String();
        long start=0L;
        long end=0L;
        int fmt=0;

        try {
            if(request.getParameter("sampleId")!=null)
            sampleId = Integer.parseInt(request.getParameter("sampleId"));
            if(request.getParameter("chr")!=null)
            chr = request.getParameter("chr");
            if(request.getParameter("start")!=null)
            start = Long.parseLong(request.getParameter("start"));
            if(request.getParameter("end")!=null)
            end = Long.parseLong(request.getParameter("end"));
            if(request.getParameter("fmt")!=null)
            fmt = Integer.parseInt(request.getParameter("fmt"));

        } catch(Exception e) {
            System.out.println("CarpenovoSearchController: missing parameter: "+e.toString());
            return new ModelAndView("redirect:/front/select.html");
        }

        if ((start - end) > 30000000) {
            //throw new Exception("BP range too large");
        }

        List<Variant> variants = vdao.getVariants(sampleId, chr, start, end);

        FormUtility fu = new FormUtility();
        Report r = new Report();
        Record record = new Record();

        record.append("chr");
        record.append("start");
        record.append("stop");
        record.append("reference nuc");
        record.append("variant nuc");
        record.append("depth");
        record.append("genic status");
        record.append("zygosity");
        //record.append("region");
        record.append("variant ID");
        /*
        record.append("transcript");
        record.append("aa change");
        record.append("reference aa");
        record.append("variant aa");
        record.append("Gene Splice");
        record.append("NearSpliceSite");
        record.append("PolyPhen Prediction");
        */
        r.append(record);

        for (Variant v : variants) {
            record = new Record();

            record.append(fu.chkNull(v.getChromosome()));
            record.append(fu.chkNull(v.getStartPos() + ""));
            record.append(fu.chkNull(v.getEndPos() + ""));
            record.append(fu.chkNull(v.getReferenceNucleotide()));
            record.append(fu.chkNull(v.getVariantNucleotide()));
            record.append(fu.chkNull(v.getDepth() + ""));
            record.append(fu.chkNull(v.getGenicStatus() + ""));
            record.append(fu.chkNull(v.getZygosityStatus()));
           // record.append(fu.chkNull(v.getRegionName()));
            record.append(fu.chkNull(v.getId() + ""));

            r.append(record);
        }
        request.setAttribute("report", r);

        String path = "/WEB-INF/jsp/search/";

        if (fmt == 2) {
            return new ModelAndView(path + "csv.jsp");
        } else if (fmt == 3) {
            return new ModelAndView(path + "tab.jsp");

        } else if (fmt == 4) {
            return new ModelAndView(path + "print.jsp");

        } else if (fmt == 5) {
            return new ModelAndView(path + "gviewer.jsp");
        } else if (fmt == 6) {
            return new ModelAndView(path + "gviewerXML.jsp");
        }
        return new ModelAndView(path + "csv.jsp");
    }
}