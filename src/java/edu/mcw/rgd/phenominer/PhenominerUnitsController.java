package edu.mcw.rgd.phenominer;

import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.pheno.PhenominerUnit;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;

public class PhenominerUnitsController extends  PhenominerController {
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(request);
        String action = req.getParameter("act");
        PhenominerDAO dao = new PhenominerDAO();

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();
        Report report = new Report();

        String viewPath = "/WEB-INF/jsp/curation/phenominer/phenominerUnits.jsp";


        if(request.getCookies() != null && request.getCookies().length != 0)
            if(request.getCookies()[0].getName().equalsIgnoreCase("accessToken")) {
                String accessToken = request.getCookies()[0].getValue();
                if(!checkToken(accessToken)) {
                    response.sendRedirect("https://github.com/login/oauth/authorize?client_id=7de10c5ae2c3e3825007&scope=user&redirect_uri=https://dev.rgd.mcw.edu/rgdweb/curation/login.html");
                    return null;
                }
            }

        String query = "select distinct e.STUDY_ID, er.EXPERIMENT_ID, er.EXPERIMENT_RECORD_ID, cm.CLINICAL_MEASUREMENT_ONT_ID, ot.TERM, er.MEASUREMENT_UNITS, us.STANDARD_UNIT,s.REF_RGD_ID from EXPERIMENT_RECORD er\n" +
                "join CLINICAL_MEASUREMENT cm on cm.CLINICAL_MEASUREMENT_ID=er.CLINICAL_MEASUREMENT_ID \n" +
                "join PHENOMINER_STANDARD_UNITS us on us.ont_id=cm.CLINICAL_MEASUREMENT_ONT_ID \n" +
                "join ONT_TERMS ot on ot.TERM_ACC=cm.CLINICAL_MEASUREMENT_ONT_ID\n" +
                "join EXPERIMENT e on e.EXPERIMENT_ID=er.EXPERIMENT_ID\n" +
                "join STUDY s on e.STUDY_ID=s.STUDY_ID\n" +
                "where \n" +
                "(cm.CLINICAL_MEASUREMENT_ONT_ID in(select tus.ONT_ID from PHENOMINER_TERM_UNIT_SCALES tus) and\n" +
                "er.MEASUREMENT_UNITS not in(select tus.UNIT_FROM from PHENOMINER_TERM_UNIT_SCALES tus where tus.ONT_ID=cm.CLINICAL_MEASUREMENT_ONT_ID)) \n" +
                "or\n" +
                "(cm.CLINICAL_MEASUREMENT_ONT_ID not in (select us.ONT_ID from PHENOMINER_STANDARD_UNITS us join PHENOMINER_TERM_UNIT_SCALES tus on us.ONT_ID = tus.ONT_ID))\n";

        List<PhenominerUnit> phenominerUnits = dao.getPhenominerUnits(query);
        report = this.buildPhenominerUnitsReport(phenominerUnits, dao, true);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView(viewPath, "report", report);
    }

    //Build records to show on ui
    private Report buildPhenominerUnitsReport(List<PhenominerUnit> phenominerUnits, PhenominerDAO dao, boolean edit) throws Exception{
        Report report = new Report();
        Record header = new Record();

        header.append("Study ID");
        header.append("Experiment ID");
        header.append("Experiment Record ID");
        header.append("CMO ID");
        header.append("Term");
        header.append("Measurement Units");
        header.append("Standard Unit");
        header.append("Reference RGD ID");
        header.append("");
        report.insert(0, header);

        for (PhenominerUnit p : phenominerUnits) {
            Record rec = new Record();
            rec.append(this.buildLink("studies.html?act=edit&studyId=" + p.getStudyId(), p.getStudyId()));
            rec.append("<a href='experiments.html?act=edit&expId=" + p.getExperimentId() + "&studyId=" + p.getStudyId() + "'>" + p.getExperimentId() + "</a>");
            rec.append("<a href='records.html?act=edit&expId=" + p.getExperimentId() + "&id=" + p.getExperimentRecordId() + "&studyId=" + p.getStudyId() + "'>" + p.getExperimentRecordId() + "</a>");
            rec.append(p.getCmoId());
            rec.append(p.getpTerm());
            rec.append(p.getMeasurementUnit());
            rec.append(p.getStdUnit());
            rec.append("<a href=\"" + Link.ref(p.getpRefRgdId()) + "\">" + p.getpRefRgdId() + "</a>");

            report.append(rec);
        }
        return report;
    }
}
