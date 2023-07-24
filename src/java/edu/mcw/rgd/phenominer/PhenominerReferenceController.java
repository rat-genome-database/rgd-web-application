package edu.mcw.rgd.phenominer;

import edu.mcw.rgd.dao.impl.ReferenceDAO;
import edu.mcw.rgd.datamodel.Reference;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class PhenominerReferenceController extends PhenominerController {


    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

        String action = req.getParameter("act");

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        String viewPath = "/WEB-INF/jsp/curation/phenominer/reference.jsp";

        ReferenceDAO rdao = new ReferenceDAO();


        int year = -1;
        if (!req.getParameter("year").equals("")) {
            year = Integer.parseInt(req.getParameter("year"));
        }

        List<Reference> references = rdao.getActiveReferences(req.getParameter("title"), req.getParameter("author"), year);

        Report report = new Report();

        Record header = new Record();
        header.append("");
        header.append("RGD ID");
        header.append("Title");
        header.append("Citation");

        report.insert(0, header);
        report.addSortMapping(0, Report.NUMERIC_SORT);
        report.addSortMapping(1, Report.NUMERIC_SORT);

        for (Reference ref : references) {
            Record rec = new Record();
            rec.append("<a href='studies.html?act=edit&referenceId=" + ref.getRgdId() + "'>Select</a>");
            rec.append(buildLink(Link.ref(ref.getRgdId()), ref.getRgdId()));
            rec.append(ref.getTitle());
            rec.append(ref.getCitation());
            report.append(rec);
        }

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView(viewPath, "report", report);

    }
}