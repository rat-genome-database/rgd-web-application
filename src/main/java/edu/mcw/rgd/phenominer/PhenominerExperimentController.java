package edu.mcw.rgd.phenominer;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.datamodel.pheno.Study;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.pheno.Experiment;
import edu.mcw.rgd.process.pheno.SearchBean;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;

/**
 * @author jdepons
 * @since Jun 2, 2008
 */
public class PhenominerExperimentController extends PhenominerController {

    public final static String[] STATUS_COLORS={"red", "brown", "blue", "green", "black"};
    public final static String[] STATUS_INITIALS={"IL", "IP", "C", "F", "W"};

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        System.out.println("in the top");
        HttpRequestFacade req = new HttpRequestFacade(request);

        String action = req.getParameter("act");
        PhenominerDAO dao = new PhenominerDAO();

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        String viewPath = "/WEB-INF/jsp/curation/phenominer/experiments.jsp";
        Report report = new Report();

        if(request.getCookies() != null && request.getCookies().length != 0)
            if(request.getCookies()[0].getName().equalsIgnoreCase("accessToken")) {
                String accessToken = request.getCookies()[0].getValue();
                if(!checkToken(accessToken)) {
                  //  response.sendRedirect("https://github.com/login/oauth/authorize?client_id=dc5513384190f8a788e5&scope=user&redirect_uri=https://pipelines.rgd.mcw.edu/rgdweb/curation/login.html");
                 response.sendRedirect(RgdContext.getGithubOauthRedirectUrl());
                    return null;
                }
            }

        if (action.equals("edit")) {
            viewPath = "/WEB-INF/jsp/curation/phenominer/editExperiment.jsp";
            List<String> idList = req.getParameterValues("expId");
            List exps = dao.getExperiments(idList);
            report = this.buildReport(exps, dao, false);
        }  else if (action.equals("edit_experiments")) {
                viewPath = "/WEB-INF/jsp/curation/phenominer/experiments.jsp";
                List<String> studyIdList = req.getParameterValues("studyId");

                List<Experiment> experiments = new ArrayList<Experiment>();
                for (String studyId : studyIdList) {
                    experiments.addAll(dao.getExperiments(Integer.parseInt(studyId)));
                }

//                if (idList.size() > 999) {
//                    idList = idList.subList(0, 999);
//                    status.add("More than 1000 results found.  Displaying first 1000");
//                }

                report = buildReport(experiments, dao, true);
            } else if (action.equals("search")) {

            SearchBean sb = this.buildSearchBean(req, dao);
            request.getSession().setAttribute("searchBean", sb);
            List idList = dao.getExperimentIds(sb, Integer.parseInt(sb.getStudyId()),
                        Integer.parseInt(sb.getExperimentId()), Integer.parseInt(sb.getRecordId()));

            if (idList.size() > 999) {
                idList = idList.subList(0, 999);
                status.add("More than 1000 results found.  Displaying first 1000");
            } else if (idList.size() == 0) {
                error.add("0 records found");
                viewPath = "/WEB-INF/jsp/curation/phenominer/search.jsp";
            }


            List exps = dao.getExperiments(idList);
            report = this.buildReport(exps, dao, true, sb);
        } else if (action.equals("save")) {

            System.out.println("made it to save");
            viewPath = "/WEB-INF/jsp/curation/phenominer/editExperiment.jsp";
            try {
            //String[] ids = request.getParameterValues("id");

            List<String> ids = req.getParameterValues("expId");

            if (ids.size() == 0) {
                Experiment e = new Experiment();

                if (!req.getParameter("name").equals("")) {
                    e.setName(req.getParameter("name"));
                }
                if (!req.getParameter("notes").equals("")) {
                    if (req.getParameter("notes").equals("\\")) {
                        e.setNotes(req.getParameter(""));
                    } else {
                        e.setNotes(req.getParameter("notes"));
                    }
                }

                e.setStudyId(Integer.parseInt(req.getParameter("studyId")));
                if (!req.getParameter("traitOntId").equals("")) {
                    e.setTraitOntId(req.getParameter("traitOntId"));
                }
                if (!req.getParameter("traitOntId2").equals("")) {
                    System.out.println("setting");
                    e.setTraitOntId2(req.getParameter("traitOntId2"));
                }
                if (!req.getParameter("traitOntId3").equals("")) {
                    e.setTraitOntId3(req.getParameter("traitOntId3"));
                }

                e.setLastModifiedBy(login);
                e.setCreatedBy(login);
                validate(req, false);
                dao.insertExperiment(e);
                status.add("Experiment Create Successful");

                List<Experiment> exps = dao.getExperiments(Integer.parseInt(req.getParameter("studyId")));
                report = this.buildReport(exps, dao, true);
            } else {

                for (int i = 0; i < ids.size(); i++) {

                    Experiment e = dao.getExperiment(Integer.parseInt(ids.get(i)));

                    if (!req.getParameter("name").equals("")) {
                        e.setName(req.getParameter("name"));
                    }
                    if (!req.getParameter("notes").equals("")) {
                        if (req.getParameter("notes").equals("\\")) {
                            e.setNotes(req.getParameter(""));
                        } else {
                            e.setNotes(req.getParameter("notes"));
                        }
                    }
                    if (!req.getParameter("studyId").equals("")) {
                        e.setStudyId(Integer.parseInt(req.getParameter("studyId")));
                    }
                    if (!req.getParameter("traitOntId").equals("")) {
                        e.setTraitOntId(req.getParameter("traitOntId"));
                    }else{
                        e.setTraitOntId(null);
                    }

                    if (!req.getParameter("traitOntId2").equals("")) {
                        e.setTraitOntId2(req.getParameter("traitOntId2"));
                    }else {
                        e.setTraitOntId2(null);
                    }
                    if (!req.getParameter("traitOntId3").equals("")) {
                        e.setTraitOntId3(req.getParameter("traitOntId3"));
                    }else {
                        e.setTraitOntId3(null);
                    }
                    if (!req.getParameter("traitOntId2").equals("")) {
                        System.out.println("setting");
                        e.setTraitOntId2(req.getParameter("traitOntId2"));
                    }
                    if (!req.getParameter("traitOntId3").equals("")) {
                        e.setTraitOntId3(req.getParameter("traitOntId3"));
                    }

                    e.setCurationStatus((req.getParameter("sStatus") != null && req.getParameter("sStatus").length()>0) ?
                    Integer.parseInt(req.getParameter("sStatus")) : -1) ;
                    try {
                        validate(req, ids.size() > 1);
                    } catch (Exception exp) {
                        List<String> idList = req.getParameterValues("expId");
                        List exps = dao.getExperiments(idList);
                        report = this.buildReport(exps, dao, false);
                        viewPath = "/WEB-INF/jsp/curation/phenominer/editExperiment.jsp";
                        throw exp;
                    }

                    e.setLastModifiedBy(login);
                    dao.updateExperiment(e);
                }

                viewPath = "/WEB-INF/jsp/curation/phenominer/editExperiment.jsp";
                status.add("Experiment Update Successful");
                List<String> idList = req.getParameterValues("expId");
                List exps = dao.getExperiments(idList);
                report = this.buildReport(exps, dao, false);
            }
            } catch (Exception e) {
                error.add(e.getMessage());
                e.printStackTrace();
                }

        } else if (action.equals("new")) {
            viewPath = "/WEB-INF/jsp/curation/phenominer/editExperiment.jsp";

        } else if (action.equals("del")) {

            String[] ids = request.getParameterValues("expId");
            List<Experiment> experimentsLeft = new ArrayList<Experiment>();
            for (String id : ids) {
                Integer idInt = Integer.parseInt(id);
                if (dao.getRecordCount(idInt) == 0) {
                    dao.deleteExperiment(idInt);
                } else {
                    experimentsLeft.add(dao.getExperiment(idInt));
                }
            }

            int experiments_deleted = ids.length - experimentsLeft.size();
            if (ids.length == experiments_deleted) {
                report = this.buildReport(this.getExperiments(req, dao), dao, true);
                status.add("Successful! " + experiments_deleted + " experiment(s) deleted.");
            } else {
                report = this.buildReport(experimentsLeft, dao, true);
                status.add(experiments_deleted + " experiment(s) deleted. " + experimentsLeft.size() + " experiments cannot be deleted because they have experiment records.");
            }

        } else {

            //List<Experiment> exps = dao.getExperiments(Integer.parseInt(req.getParameter("studyId")));
            report = this.buildReport(this.getExperiments(req, dao), dao, true);

        }

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView(viewPath, "report", report);

    }

    private List<Experiment> getExperiments(HttpRequestFacade req, PhenominerDAO dao) throws Exception {
        List<Experiment> experiments = null;
        if (req.getParameter("studyId").equals("")) {
            SearchBean sb = (SearchBean) req.getRequest().getSession().getAttribute("searchBean");
            List idList = dao.getExperimentIds(sb);

            if (idList.size() > 999) {
                idList = idList.subList(0, 999);
            }
            experiments = dao.getExperiments(idList);
        } else {
            experiments = dao.getExperiments(Integer.parseInt(req.getParameter("studyId")));
        }
        return experiments;
    }


    private Report buildReport(List<Experiment> exps, PhenominerDAO dao, boolean edit) throws Exception {
        return this.buildReport(exps, dao, edit, null);
    }

    private Report buildReport(List<Experiment> exps, PhenominerDAO dao, boolean edit, SearchBean sb) throws Exception {

        Report report = new Report();

        Record header = new Record();
        if (edit) header.append("");
        header.append("SID");
        header.append("EID");
        header.append("Name");
        header.append("Acc IDs");
        header.append("Notes");
        String records_header = "Records(";
        for (int i = 0; i < STATUS_INITIALS.length; i ++) {
            records_header += (i==0?"":",") + "<font color='" + STATUS_COLORS[i] + "'>" + STATUS_INITIALS[i] +
                "</font>";
        }
        records_header += ")";
        header.append(records_header);
//        header.append("Records(<font color='red'>IL</font>,<font color='Brown'>C</font>,<font color='blue'>IP</font>,<font color='green'>F</font>)");
        header.append("");

        report.insert(0, header);

        report.addSortMapping(0, Report.NUMERIC_SORT);
        report.addSortMapping(3, Report.NUMERIC_SORT);


        for (Experiment e : exps) {
            Record rec = new Record();
            if (edit) rec.append("<input name='expId' value='" + e.getId() + "' type='checkbox'/>");
            rec.append("<a href='studies.html?act=edit&studyId=" + e.getStudyId() + "'>" + e.getStudyId() + "</a>");
            rec.append("<a href='experiments.html?act=edit&expId=" + e.getId() + "&studyId=" + e.getStudyId() + "'>" + e.getId() + "</a>");
            rec.append(e.getName());

            String traits = e.getTraitOntId();
            if (e.getTraitOntId2() != null) {
                traits += "; " + e.getTraitOntId2();
            }
            if (e.getTraitOntId3() != null) {
                traits += "; " + e.getTraitOntId3();

            }

            rec.append(traits);
            rec.append(e.getNotes());

//            int recordCount = dao.getRecordCount(e.getId());
            List<Integer> recordCounts = dao.getRecordStatusCount(e.getId());

            if (recordCounts.get(0) > 0) {
                String count_str = "", total_color="grey";
                for (int i = 0; i < STATUS_INITIALS.length; i ++) {
                    count_str += (i==0?"":",") + "<font color='" + STATUS_COLORS[i] + "'>" + recordCounts.get(i+1) +
                        "</font>";
                    if (recordCounts.get(0).equals(recordCounts.get(i+1))) {
                        total_color = STATUS_COLORS[i];
                    }
                }
                count_str = "<font color='" + total_color + "'>" + recordCounts.get(0) +
                        "</font>(" + count_str + ")";

                rec.append("<a href='records.html?expId=" + e.getId() + "&studyId=" + e.getStudyId() + "'>" + count_str + "</a>");
            } else {
                rec.append("0");
            }

            rec.append("<a href='records.html?act=new&expId=" + e.getId() + "&studyId=" + e.getStudyId() + "'>(Add Record)</a>");
            report.append(rec);
        }

        return report;
    }

    private void validate(HttpRequestFacade req, boolean bulkMode) throws Exception {
        OntologyXDAO dao = new OntologyXDAO();
        String accID = req.getParameter("traitOntId");
        if (accID.equals("")) {
             if (!bulkMode) throw new Exception("Acc ID is required");
        } else {
            if (!accID.equals(PhenominerRecordController.TERM_REQUEST))
            {
                if (!(accID.startsWith("DOID:")|| accID.startsWith("VT:")) || dao.getTermByAccId(accID) == null) throw new Exception("ACC ID: " + accID + " not found!");
                if (!dao.isForCuration(accID)) throw new Exception("ACC ID: " + accID + " is not for curation!");
            }
        }
    }
}

