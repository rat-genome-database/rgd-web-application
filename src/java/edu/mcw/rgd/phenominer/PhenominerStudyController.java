package edu.mcw.rgd.phenominer;

import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.pheno.Study;
import edu.mcw.rgd.process.pheno.SearchBean;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;

/**
 * @author jdepons
 * @since Jun 2, 2008
 */
public class PhenominerStudyController extends PhenominerController {


    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(request);

        String action = req.getParameter("act");
        PhenominerDAO dao = new PhenominerDAO();

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        String viewPath = "/WEB-INF/jsp/curation/phenominer/studies.jsp";
        Report report = new Report();

        try {

            if (action.equals("edit")) {
                List idList;
                if (!req.getParameter("referenceId").isEmpty()) {

                    SearchBean sb = new SearchBean();
                    sb.setReference(req.getParameter("referenceId"));
                    idList = dao.getStudyIds(sb);

                    if (idList.size() > 0) {
                        viewPath = "/WEB-INF/jsp/curation/phenominer/studies.jsp";

                    } else {
                        viewPath = "/WEB-INF/jsp/curation/phenominer/editStudy.jsp";

                    }

                } else {

                    viewPath = "/WEB-INF/jsp/curation/phenominer/editStudy.jsp";
                    idList = req.getParameterValues("studyId");

                }

                report = null;
                if (idList.size() > 0) {
                    report = this.buildReport(dao.getStudies(idList), dao, false);
                }

            } else if (action.equals("search")) {
                SearchBean sb = this.buildSearchBean(req, dao);
                List idList = dao.getStudyIds(sb, Integer.parseInt(sb.getStudyId()),
                        Integer.parseInt(sb.getExperimentId()), Integer.parseInt(sb.getRecordId()));

                if (idList.size() > 999) {
                    idList = idList.subList(0, 999);
                    status.add("More than 1000 results found.  Displaying first 1000");
                } else if (idList.isEmpty()) {
                    error.add("0 records found");
                    viewPath = "/WEB-INF/jsp/curation/phenominer/search.jsp";
                }


                report = this.buildReport(dao.getStudies(idList), dao, true, sb);

            } else if (action.equals("save")) {

                List<String> ids = req.getParameterValues("studyId");
                if (ids.isEmpty()) {

                    // validation ensures all study parameters are valid
                    try {
                        this.validate(req);
                    } catch (Exception e) {
                        viewPath = "/WEB-INF/jsp/curation/phenominer/editStudy.jsp";
                        throw e;
                    }

                    Study s = new Study();
                    s.setName(req.getParameter("name"));
                    s.setSource(req.getParameter("source"));
                    s.setType(req.getParameter("type"));
                    s.setRefRgdId(Integer.parseInt(req.getParameter("refRgdId")));
                    dao.insertStudy(s);

                    status.add("Study Create Successful");

                    List<Study> studies = dao.getStudies();
                    report = this.buildReport(studies, dao, true);
                    viewPath = "/WEB-INF/jsp/curation/phenominer/studies.jsp";
                } else {
                    for (String id : ids) {
                        Study s = dao.getStudy(Integer.parseInt(id));

                        if (!req.getParameter("name").equals("")) {
                            s.setName(req.getParameter("name"));
                        }
                        if (!req.getParameter("source").equals("")) {
                            s.setSource(req.getParameter("source"));
                        }
                        if (!req.getParameter("type").equals("")) {
                            s.setType(req.getParameter("type"));
                        }
                        if (!req.getParameter("refRgdId").equals("")) {
                            s.setRefRgdId(Integer.parseInt(req.getParameter("refRgdId")));
                        }
                        if (!req.getParameter("dataType").equals("")) {
                            s.setDataType(req.getParameter("dataType"));
                        }
                        if (!req.getParameter("geoSeriesAcc").equals("")) {
                            s.setGeoSeriesAcc(req.getParameter("geoSeriesAcc"));
                        }

                        s.setCurationStatus((req.getParameter("sStatus") != null && req.getParameter("sStatus").length()>0) ?
                        Integer.parseInt(req.getParameter("sStatus")) : -1) ;
                        dao.updateStudy(s);

                        status.add("Study " + id + " update Successful");

                    }

                    viewPath = "/WEB-INF/jsp/curation/phenominer/editStudy.jsp";
                    List<String> idList = req.getParameterValues("studyId");
                    if (idList.size() > 0) {
                        report = this.buildReport(dao.getStudies(idList), dao, false);
                    }

                }


            } else if (action.equals("new")) {

                viewPath = "/WEB-INF/jsp/curation/phenominer/createStudy.jsp";

            } else if (action.equals("del")) {

                String[] ids = request.getParameterValues("studyId");
                List<Study> studiesLeft = new ArrayList<Study>();
                for (String id : ids) {
                    Integer idInt = Integer.parseInt(id);
                    if (dao.getRecordCountForStudy(idInt) == 0) {
                        dao.deleteStudy(idInt);
                    } else {
                        studiesLeft.add(dao.getStudy(idInt));
                    }
                }

                int studies_deleted = ids.length - studiesLeft.size();
                if (ids.length == studies_deleted) {
                    report = this.buildReport(dao.getStudies(), dao, true);
                    status.add("Successful! " + studies_deleted + " studies deleted.");
                } else {
                    report = this.buildReport(studiesLeft, dao, true);
                    status.add(studies_deleted + " studies deleted. " + studiesLeft.size() + " studies cannot be deleted because they have experiment records.");
                }

            } else {
                List<Study> studies = dao.getStudies();
                report = this.buildReport(studies, dao, true);
            }


        } catch (Exception e) {
            error.add(e.getMessage());
            e.printStackTrace();
        }

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView(viewPath, "report", report);

    }

    private void validate(HttpRequestFacade req) throws Exception {

        if (req.getParameter("name").isEmpty()) {
            throw new Exception("Study name is required");
        }
        if (req.getParameter("source").isEmpty()) {
            throw new Exception("Study source is required");
        }
        if (req.getParameter("type").isEmpty()) {
            throw new Exception("Study type is required");
        }

        if (req.getParameter("refRgdId").isEmpty() ) {
            throw new Exception("Reference RGD Id is required");
        }
    }


    private Report buildReport(List<Study> studies, PhenominerDAO dao, boolean edit) throws Exception {
        return this.buildReport(studies, dao, edit, null);
    }

    private Report buildReport(List<Study> studies, PhenominerDAO dao, boolean edit, SearchBean sb) throws Exception {

        Report report = new Report();
        Record header = new Record();

        if (edit) header.append("");
        header.append("SID");
        header.append("Name");
        header.append("Source");
        header.append("Type");
        header.append("Reference");
        header.append("Experiments");
        String records_header = "Records(";
        for (int i = 0; i < PhenominerExperimentController.STATUS_INITIALS.length; i ++) {
            records_header += (i==0?"":",") + "<font color='" + PhenominerExperimentController.STATUS_COLORS[i]
                    + "'>" + PhenominerExperimentController.STATUS_INITIALS[i] +
                "</font>";
        }
        records_header += ")";
        header.append(records_header);
        header.append("");

        report.insert(0, header);

        for (Study s : studies) {
            Record rec = new Record();
            if (edit) rec.append("<input name='studyId' value='" + s.getId() + "' type='checkbox'/>");

            rec.append(this.buildLink("studies.html?act=edit&studyId=" + s.getId(), s.getId()));
            rec.append(s.getName());
            rec.append(s.getSource());
            rec.append(s.getType());

            rec.append("<a href=\"" + Link.ref(s.getRefRgdId()) + "\">" + s.getRefRgdId() + "</a>");

            int experimentCount = 0;
            experimentCount = dao.getExperimentCount(s.getId());
//            int recordCount = dao.getRecordCountForStudy(s.getId());
            List<Integer> recordCounts = dao.getRecordStatusCountForStudy(s.getId());

            if (experimentCount > 0) {
                rec.append("<a href='experiments.html?studyId=" + s.getId() + "'>" + experimentCount + "</a>");
            } else {
                rec.append("0");
            }


            String count_str = "", total_color="grey";
            for (int i = 0; i < PhenominerExperimentController.STATUS_INITIALS.length; i ++) {
                count_str += (i==0?"":",") + "<font color='" + PhenominerExperimentController.STATUS_COLORS[i] + "'>" + recordCounts.get(i+1) +
                    "</font>";
                if (recordCounts.get(0).equals(recordCounts.get(i+1))) {
                    total_color = PhenominerExperimentController.STATUS_COLORS[i];
                }
            }
            count_str = "<font color='" + total_color + "'>" + recordCounts.get(0) +
                    "</font>(" + count_str + ")";

            rec.append(count_str);
            rec.append("<a href='experiments.html?act=new&studyId=" + s.getId() + "'>(Add&nbsp;Experiment)</a>");
            report.append(rec);

        }
        return report;
    }


}