package edu.mcw.rgd.phenominer;

import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.pheno.Study;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.pheno.SearchBean;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * @author jdepons
 * @since Jun 2, 2008
 */
public class PhenominerStudyController extends PhenominerController {

    int pageNumber = 1;
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(request);

        String action = req.getParameter("act");
        PhenominerDAO dao = new PhenominerDAO();
        List<Study> total = dao.getStudies();
        int totalPageRecords = total.size();
        int pageSize = 100;
        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            pageNumber = Integer.parseInt(pageParam);
        }

        String pageParam1 = req.getParameter("size");
        if (pageParam1 != null && !pageParam1.isEmpty()) {
            pageSize = Integer.parseInt(pageParam1);
        }
        String ajaxParam = request.getParameter("ajax");

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();
        String partialPath = "/WEB-INF/jsp/curation/phenominer/studiesNew.jsp";
        String viewPath = "/WEB-INF/jsp/curation/phenominer/studies.jsp";
        Report report = new Report();

        if(request.getCookies() != null && request.getCookies().length != 0)
            if(request.getCookies()[0].getName().equalsIgnoreCase("accessToken")) {
                String accessToken = request.getCookies()[0].getValue();
                if(!checkToken(accessToken)) {
                   // response.sendRedirect("https://github.com/login/oauth/authorize?client_id=dc5513384190f8a788e5&scope=user&redirect_uri=https://pipelines.rgd.mcw.edu/rgdweb/curation/login.html");
                  response.sendRedirect(RgdContext.getGithubOauthRedirectUrl());
                    return null;
                }
            }

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

                    String refRgdId = req.getParameter("refRgdId0");

                    String refRgdId2 = req.getParameter("refRgdId1");
                    String refRgdId3 = req.getParameter("refRgdId2");

                    s.setLastModifiedBy(login);
                    s.setCreatedBy(login);
                    int sId = dao.insertStudy(s);
                    dao.insertStudyReference(sId,Integer.parseInt(refRgdId));

                    if (Utils.isStringEmpty(refRgdId2) || Utils.isStringEmpty(refRgdId3)){
                        try{
                            int ref2 = Integer.parseInt(refRgdId2);
                            dao.insertStudyReference(sId,ref2);
                        }
                        catch (Exception ignore){}
                        try{
                            int ref3 = Integer.parseInt(refRgdId3);
                            dao.insertStudyReference(sId,ref3);
                        }
                        catch (Exception ignore){}
                    }

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
                        if (!req.getParameter("dataType").equals("")) {
                            s.setDataType(req.getParameter("dataType"));
                        }
                        if (!req.getParameter("geoSeriesAcc").equals("")) {
                            s.setGeoSeriesAcc(req.getParameter("geoSeriesAcc"));
                        }

                        s.setCurationStatus((req.getParameter("sStatus") != null && req.getParameter("sStatus").length()>0) ?
                        Integer.parseInt(req.getParameter("sStatus")) : -1) ;
                        s.setLastModifiedBy(login);
                        dao.updateStudy(s);

                        List<Integer> refRgdIds = new ArrayList<>();
                        for (int i = 0; i < 3; i++){
                            Record record = new Record();
                            try{
                                int x = Integer.parseInt(request.getParameter("refRgdId"+i));
                                refRgdIds.add(x);
                            }
                            catch (Exception e){ }

                        }
                        // compare both integer lists and insert new, delete ones that no longer exist
                        List<Integer> existingRefs = s.getRefRgdIds();
                        dropSharedRgdIds(refRgdIds,existingRefs);

                        for (Integer rgdId : refRgdIds){
                            dao.insertStudyReference(s.getId(),rgdId);
                        }

                        for (Integer rgdId : existingRefs){
                            dao.deleteStudyReference(s.getId(), rgdId);
                        }

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
//                List<Study> studies = dao.getStudies();
                List<Study> studies = dao.getStudiesByPageNum(pageNumber,pageSize);
                report = this.buildReport(studies, dao, true);
                if ("true".equals(ajaxParam)) {
                    // Return only the data part (the additional studies)
                    return new ModelAndView(partialPath, "report", report);
                }
            }


        } catch (Exception e) {
            error.add(e.getMessage());
            e.printStackTrace();
        }
        request.setAttribute("totalRecords",totalPageRecords);
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

        if (req.getParameter("refRgdId0").isEmpty() ) {
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
            List<Integer> refIds = dao.getStudyReferences(s.getId());
            Record rec = new Record();
            if (edit) rec.append("<input name='studyId' value='" + s.getId() + "' type='checkbox'/>");
            rec.append(this.buildLink("studies.html?act=edit&studyId=" + s.getId(), s.getId()));
            rec.append(s.getName());
            rec.append(s.getSource());
            rec.append(s.getType());
            String refs = "";
            if (refIds!=null && !refIds.isEmpty()){
                for (int i = 0 ; i < refIds.size(); i++){
                    if (i == refIds.size()-1)
                        refs += "<a href=\"" + Link.ref(refIds.get(i)) + "\">" + refIds.get(i) + "</a>";
                    else
                        refs += "<a href=\"" + Link.ref(refIds.get(i)) + "\">" + refIds.get(i) + "</a>, ";
                }
            }
            rec.append(refs);

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
//        report.append(new Record().append(""));
        return report;
    }

    int dropSharedRgdIds(List<Integer> incomingRgdIds, List<Integer> existingRgdIds) throws Exception {

        int droppedCount = 0;
        if(incomingRgdIds!=null) {
            // find incoming annotation that matches existingAnnotation
            Iterator<Integer> it1 = incomingRgdIds.iterator();
            while (it1.hasNext()) {
                Integer var1 = it1.next();

                Iterator<Integer> it2 = existingRgdIds.iterator();
                while (it2.hasNext()) {
                    Integer var2 = it2.next();

                    if (var1.equals(var2)) {

                        droppedCount++;
                        it1.remove();
                        it2.remove();
                        break; // break inner loop
                    }
                }
            }
            return droppedCount;
        } else return existingRgdIds.size();
    }

}