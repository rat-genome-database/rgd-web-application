package edu.mcw.rgd.phenominer;

import edu.mcw.rgd.datamodel.HistogramRecord;
import edu.mcw.rgd.datamodel.pheno.Enumerable;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.pheno.Condition;
import edu.mcw.rgd.datamodel.pheno.Record;
import edu.mcw.rgd.process.pheno.SearchBean;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class PhenominerRecordController extends PhenominerController {

    static String TERM_REQUEST = "00:0000000";
    static String VALUE_REQUEST = "REQUEST NEW VALUE";

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

        String action = req.getParameter("act");
        PhenominerDAO dao = new PhenominerDAO();

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        String viewPath = "/WEB-INF/jsp/curation/phenominer/records.jsp";
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

        try {
            if (action.equals("edit")) {
                viewPath = "/WEB-INF/jsp/curation/phenominer/editRecord.jsp";
                List<String> idList = req.getParameterValues("id");

                if (idList.size() > 999) {
                    idList = idList.subList(0, 999);
                    status.add("More than 1000 results found.  Displaying first 1000");
                }

                List<Record> records = dao.getRecords(idList);
                report = buildReport(records, dao, false);
            } else if (action.equals("editSS")) {
                viewPath = "/WEB-INF/jsp/curation/phenominer/editRecordSS.jsp";
                List<String> idList = req.getParameterValues("id");

                if (idList.size() > 999) {
                    idList = idList.subList(0, 999);
                    status.add("More than 1000 results found.  Displaying first 1000");
                }

                List<Record> records = dao.getRecords(idList);
                report = buildReport(records, dao, false);

            }else if (action.equals("edit_experiment_records")) {
                viewPath = "/WEB-INF/jsp/curation/phenominer/records.jsp";
                List<String> expIdList = req.getParameterValues("expId");

                List<Record> records = new ArrayList<Record>();
                for (String expId : expIdList) {
                    records.addAll(dao.getRecords(Integer.parseInt(expId)));
                }

//                if (idList.size() > 999) {
//                    idList = idList.subList(0, 999);
//                    status.add("More than 1000 results found.  Displaying first 1000");
//                }

                report = buildReport(records, dao, true);
            } else if (action.equals("search")) {
                SearchBean sb = this.buildSearchBean(req, dao);
                request.getSession().setAttribute("searchBean", sb);

                List idList = dao.getRecordIds(sb, Integer.parseInt(sb.getStudyId()),
                        Integer.parseInt(sb.getExperimentId()),
                        Integer.parseInt(sb.getRecordId()), -1);

                if (idList.size() > 999) {
                    idList = idList.subList(0, 999);
                    status.add("More than 1000 results found.  Displaying first 1000");
                } else if (idList.size() == 0) {
                    error.add("0 records found");
                    viewPath = "/WEB-INF/jsp/curation/phenominer/search.jsp";
                }

                List<Record> records = dao.getRecords(idList);
                report = this.buildReport(records, dao, true);
            } else if (action.equals("new")) {
                viewPath = "/WEB-INF/jsp/curation/phenominer/editRecord.jsp";
            } else if (action.equals("saveSS")) {
                try {
                    String mode = req.getParameter("mode");
                    if (mode != null && mode.equals("addUnit")) {

                        Enumerable e = new Enumerable();
                        String unitType = request.getParameter("unitType");
                        e.setType(Integer.parseInt(unitType));
                        String unitValue = request.getParameter("unitValue");
                        String description = request.getParameter("description");
                        e.setValue(unitValue);
                        e.setLabel(unitValue);
                        e.setDescription(description);

                        if (Integer.parseInt(unitType) == 3) {
                            List<String> existingCMO = dao.getDistinct("PHENOMINER_ENUMERABLES where type=3  ", "label", true);
                            if (!existingCMO.contains(unitValue)) {
                                if (unitValue != null && unitValue != "")
                                    dao.insertEnumerable(e);
                            }
                            String termAcc = request.getParameter("accId");
                            if (request.getParameterMap().containsKey("termScale")) {
                                String termScale = request.getParameter("termScale");
                                dao.insertUnitConversion(termAcc, unitValue, termScale);
                            } else dao.checkUnitConversion(termAcc, unitValue);

                        } else {
                            List<String> existingXCO = dao.getDistinct("PHENOMINER_ENUMERABLES where type=2  ", "label", true);
                            if (!existingXCO.contains(unitValue)) {
                                if (unitValue != null && unitValue != "")
                                    dao.insertEnumerable(e);
                            }
                        }
                    }
                    List<String> idList = req.getParameterValues("id");
                    List<String> ids = new ArrayList<String>();

                    for(String id: idList) {
                        if (!id.startsWith("_")) {
                            ids.add(id);
                        }
                    }

                    if (ids.size() == 0) {
                        viewPath = "/WEB-INF/jsp/curation/phenominer/records.jsp";
                        Record r = new Record();
                        try {
                            this.validate(req, false);
                            r = this.buildRecord(req, r, false);
                            r.setLastModifiedBy(login);
                            r.setCreatedBy(login);
                            dao.insertRecord(r);
                            status.add("Record Create Successful");
                            response.getWriter().println("Update Successful:" + r.getId());
                            return null;

                        } catch (Exception e) {
                            viewPath = "/WEB-INF/jsp/curation/phenominer/editRecord.jsp";
                            throw e;
                        }


                        //List<Record> records = dao.getRecords(Integer.parseInt(req.getParameter("expId")));
                        //report = buildReport(records, dao, true);


                    } else {

                        viewPath = "/WEB-INF/jsp/curation/phenominer/editRecord.jsp";

                        for (String id : ids) {
                            Record r = dao.getRecord(Integer.parseInt(id));

                            r = this.buildRecord(req, r, ids.size() > 1);
                            try {
                                this.validate(req, ids.size() > 1);
                            } catch (Exception e) {
                                List<Record> records = dao.getRecords(ids);
                                report = buildReport(records, dao, false);
                                throw e;
                            }
                            r.setLastModifiedBy(login);
                            dao.updateRecord(r);

                            String[] cDelete = req.getRequest().getParameterValues("cDelete");

                            if (cDelete != null) {
                                for (String aCDelete : cDelete) {
                                    Integer cId = Integer.parseInt(aCDelete);
                                    if (cId > 0) {
                                        dao.deleteExperimentCondition(cId);
                                    } else {
                                        List<Condition> rCond = r.getConditions();
                                        Integer cIdReal = rCond.get(-1 - cId).getId();
                                        dao.deleteExperimentCondition(cIdReal);
                                    }
                                }
                            }
                        }

                        status.add("Record Update Successful");

                        response.getWriter().println("Update Successful");
                        return null;
                    }

                }catch (Exception e3){
                    response.getWriter().println("Save Failed: " + e3.getMessage());
                    e3.printStackTrace();
                    return null;

                }
            } else if (action.equals("save")) {
                String mode = req.getParameter("mode");
                if (mode != null && mode.equals("addUnit")) {

                    Enumerable e = new Enumerable();
                    String unitType = request.getParameter("unitType");
                    e.setType(Integer.parseInt(unitType));
                    String unitValue = request.getParameter("unitValue");
                    String description = request.getParameter("description");
                    e.setValue(unitValue);
                    e.setLabel(unitValue);
                    e.setDescription(description);

                    if (Integer.parseInt(unitType) == 3) {
                        List<String> existingCMO = dao.getDistinct("PHENOMINER_ENUMERABLES where type=3  ", "label", true);
                        if (!existingCMO.contains(unitValue)) {
                            if (unitValue != null && unitValue != "")
                                dao.insertEnumerable(e);
                        }
                        String termAcc = request.getParameter("accId");
                        if (request.getParameterMap().containsKey("termScale")) {
                            String termScale = request.getParameter("termScale");
                            dao.insertUnitConversion(termAcc, unitValue, termScale);
                        } else dao.checkUnitConversion(termAcc, unitValue);

                    } else {
                        List<String> existingXCO = dao.getDistinct("PHENOMINER_ENUMERABLES where type=2  ", "label", true);
                        if (!existingXCO.contains(unitValue)) {
                            if (unitValue != null && unitValue != "")
                                dao.insertEnumerable(e);
                        }
                    }
                }
                List<String> ids = req.getParameterValues("id");

                if (ids.size() == 0) {
                    viewPath = "/WEB-INF/jsp/curation/phenominer/records.jsp";

                    Record r = new Record();
                    try {
                        this.validate(req, false);
                        r = this.buildRecord(req, r, false);
                        r.setLastModifiedBy(login);
                        r.setCreatedBy(login);
                        dao.insertRecord(r);
                        status.add("Record Create Successful");
                    } catch (Exception e) {
                        viewPath = "/WEB-INF/jsp/curation/phenominer/editRecord.jsp";
                        throw e;
                    }


                    List<Record> records = dao.getRecords(Integer.parseInt(req.getParameter("expId")));
                    report = buildReport(records, dao, true);


                } else {

                    viewPath = "/WEB-INF/jsp/curation/phenominer/editRecord.jsp";

                    for (String id : ids) {
                        Record r = dao.getRecord(Integer.parseInt(id));

                        r = this.buildRecord(req, r, ids.size() > 1);
                        try {
                            this.validate(req, ids.size() > 1);
                        } catch (Exception e) {
                            List<Record> records = dao.getRecords(ids);
                            report = buildReport(records, dao, false);
                            throw e;
                        }
                        r.setLastModifiedBy(login);
                        dao.updateRecord(r);

                        String[] cDelete = req.getRequest().getParameterValues("cDelete");

                        if (cDelete != null) {
                            for (String aCDelete : cDelete) {
                                Integer cId = Integer.parseInt(aCDelete);
                                if (cId > 0) {
                                    dao.deleteExperimentCondition(cId);
                                } else {
                                    List<Condition> rCond = r.getConditions();
                                    Integer cIdReal = rCond.get(-1 - cId).getId();
                                    dao.deleteExperimentCondition(cIdReal);
                                }
                            }
                        }
                    }

                    status.add("Record Update Successful");

                    List<String> idList = req.getParameterValues("id");
                    if (idList.size() > 999) {
                        idList = idList.subList(0, 999);
                        status.add("More than 1000 results found.  Displaying first 1000");
                    }

                    List<Record> records = dao.getRecords(idList);
                    report = buildReport(records, dao, false);
                }


            } else if (action.equals("del")) {

                String[] ids = request.getParameterValues("id");
                for (String id : ids) {
                    dao.deleteRecord(Integer.parseInt(id));
                }
                status.add("Record Delete Successful");

                report = buildReport(this.getRecords(req, dao), dao, true);
            } else {
                report = buildReport(this.getRecords(req, dao), dao, true);
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

    private List<Record> getRecords(HttpRequestFacade req, PhenominerDAO dao) throws Exception {
        List<Record> records = null;
        if (req.getParameter("expId").equals("")) {
            SearchBean sb = (SearchBean) req.getRequest().getSession().getAttribute("searchBean");
            List idList = dao.getRecordIds(sb, 40);

            if (idList.size() > 999) {
                idList = idList.subList(0, 999);
            }
            records = dao.getRecords(idList);
        } else {
            records = dao.getRecords(Integer.parseInt(req.getParameter("expId")));
        }
        return records;
    }


    static Report buildReport(List<Record> records, PhenominerDAO dao, boolean edit) throws Exception {

        OntologyXDAO ontDao = new OntologyXDAO();

        Report report = new Report();

        edu.mcw.rgd.reporting.Record header = new edu.mcw.rgd.reporting.Record();
        if (edit) header.append("");
        header.append("SID");
        header.append("EID");
        header.append("RID");
        header.append("Status");
        header.append("Clinical Measurement");
        header.append("CM Site");
        header.append("Value");
        header.append("Units");
        header.append("SD");
        header.append("SEM");
        header.append("Error");
        header.append("Ave Type");
        header.append("Formula");
        header.append("Measurement Method");
        header.append("Duration");
        header.append("MM Site");
        header.append("PI Type");
        header.append("PI Time");
        header.append("PI Unit");
        header.append("Strain");
        header.append("Animal Count");
        header.append("Min Age");
        header.append("Max Age");
        header.append("Sex");
        header.append("BioSample Id");

        final DecimalFormat d_f = new DecimalFormat("0.####");

        List<String> ids = new ArrayList<String>();
        for (Record record : records) {
            ids.add(Integer.toString(record.getId()));
        }
        if (ids.size() > 999) {
            ids = ids.subList(0, 999);
        }

        List<HistogramRecord> ords = dao.getOrdCounts(ids);

        if (ords != null && ords.size() > 0) {
            Integer maxOrd = Integer.parseInt((ords.get(0)).value);
            for (Integer i = 1; i <= maxOrd; i++) {
                header.append("Condition " + i.toString());
                header.append("Value");
                header.append("Units");
                header.append("Min Duration");
                header.append("Max Duration");
                header.append("Application Method");
                header.append("Ordinality");
            }
        }

        report.insert(0, header);

        report.addSortMapping(0, Report.NUMERIC_SORT);

        for (Record r : records) {
            edu.mcw.rgd.reporting.Record rec = new edu.mcw.rgd.reporting.Record();
            if (edit) rec.append("<input name='id' value='" + r.getId() + "' type='checkbox'/>");
            rec.append("<a href='studies.html?act=edit" + "&studyId=" + r.getStudyId() + "'>" + r.getStudyId() + "</a>");
            rec.append("<a href='experiments.html?act=edit&expId=" + r.getExperimentId() + "&studyId=" + r.getStudyId() + "'>" + r.getExperimentId() + "</a>");
            rec.append("<a href='records.html?act=edit&expId=" + r.getExperimentId() + "&id=" + r.getId() + "&studyId=" + r.getStudyId() + "'>" + r.getId() + "</a>");
            rec.append("" + dao.getEnumerableLabel(6, r.getCurationStatus()));

            try {
                rec.append(ontDao.getTermByAccId(r.getClinicalMeasurement().getAccId()).getTerm() + "(" + r.getClinicalMeasurement().getAccId() + ")");
            } catch (Exception e) {
                rec.append("<span style='color:red'>INVALID:</span>" + r.getClinicalMeasurement().getAccId());
            }

            rec.append(r.getClinicalMeasurement().getSite());
            rec.append(r.getMeasurementValue());
            rec.append((r.getMeasurementUnits() == null || r.getMeasurementUnits().equals("null")) ? "" : r.getMeasurementUnits());
            rec.append(r.getMeasurementSD() != null ? d_f.format(Double.parseDouble(r.getMeasurementSD())) : r.getMeasurementSD());
            rec.append(r.getMeasurementSem() != null ? d_f.format(Double.parseDouble(r.getMeasurementSem())) : r.getMeasurementSem());
            rec.append(r.getMeasurementError());
            rec.append(r.getClinicalMeasurement().getAverageType());
            rec.append(r.getClinicalMeasurement().getFormula());

            try {
                rec.append(ontDao.getTermByAccId(r.getMeasurementMethod().getAccId()).getTerm() + "(" + r.getMeasurementMethod().getAccId() + ")");
            } catch (Exception e) {
                rec.append("<span style='color:red'>INVALID:</span>" + r.getMeasurementMethod().getAccId());
            }

            try {
                rec.append(r.getMeasurementMethod().getDuration() == null ? null :
                        Condition.convertDurationBoundToString(Double.parseDouble(r.getMeasurementMethod().getDuration())) + "");
            } catch (Exception e) {
                rec.append(r.getMeasurementMethod().getDuration());
            }
            rec.append(r.getMeasurementMethod().getSite());
            rec.append(r.getMeasurementMethod().getPiType());
            rec.append(r.getMeasurementMethod().getPiTimeValue() + "");
            rec.append(r.getMeasurementMethod().getPiTypeUnit());

            try {
                rec.append(ontDao.getTermByAccId(r.getSample().getStrainAccId()).getTerm() + "(" + r.getSample().getStrainAccId() + ")");
            } catch (Exception e) {
                rec.append("<span style='color:red'>INVALID:</span>" + r.getSample().getStrainAccId());
            }
            rec.append(r.getSample().getNumberOfAnimals().equals(0) ? "N/A" : r.getSample().getNumberOfAnimals() + "");
            rec.append(r.getSample().getAgeDaysFromLowBound() + "");
            rec.append(r.getSample().getAgeDaysFromHighBound() + "");
            rec.append(r.getSample().getSex());
            rec.append(r.getSample().getBioSampleId());

            List<Condition> conditions =
                    dao != null ? dao.getConditions(r.getId()) : r.getConditions();

            for (Condition cond : conditions) {
                try {
                    rec.append(ontDao.getTermByAccId(cond.getOntologyId()).getTerm() + "(" + cond.getOntologyId() + ")");
                } catch (Exception e) {
                    rec.append("<span style='color:red'>INVALID:</span>" + cond.getOntologyId());
                }
                rec.append(cond.getValue());
                rec.append(cond.getUnits());
                rec.append(Condition.convertDurationBoundToString(cond.getDurationLowerBound()) + "");
                rec.append(Condition.convertDurationBoundToString(cond.getDurationUpperBound()) + "");
                rec.append(cond.getApplicationMethod());
                rec.append(cond.getOrdinality() + "");

            }
            report.append(rec);
        }
        return report;
    }

    private void validate(HttpRequestFacade req, boolean bulkMode) throws Exception {
        PhenominerDAO pdao = new PhenominerDAO();
        if (req.getParameter("expId") != null && req.getParameter("expId").length() > 0) {
            try {
                String expId = req.getParameter("expId");
                Long eid = Long.parseLong(expId);
                pdao.getExperiment(eid.intValue());
            } catch (Exception e) {
                throw new Exception("Experiment ID " + req.getParameter("expId") + " is not valid!");
            }
        }

        OntologyXDAO dao = new OntologyXDAO();
        String rsAccID = req.getParameter("sAccId");
        String cmAccID = req.getParameter("cmAccId");
        String mmAccId = req.getParameter("mmAccId");
        String cmUnits = req.getParameterOriginal("cmUnits");

        if (rsAccID.equals("")) {
            if (!bulkMode) throw new Exception("Strain ACC ID is required");
        } else {
            if (!rsAccID.equals(TERM_REQUEST)) {
                if (!rsAccID.startsWith("RS:") || dao.getTermByAccId(rsAccID) == null)
                    throw new Exception("Strain ACC ID: " + rsAccID + " not found!");
                if (!dao.isForCuration(rsAccID))
                    throw new Exception("Strain ACC ID: " + rsAccID + " is not for curation!");
            }
        }
        if (req.getParameter("sAnimalCount").equals("")) {
            if (!bulkMode) throw new Exception("Strain Animal Count is required");
        }
        if (req.getParameter("sMinAge").equals("")) {
            if (!bulkMode) throw new Exception("Strain Min Age is required");
        }
        if (req.getParameter("sMaxAge").equals("")) {
            if (!bulkMode) throw new Exception("Strain Max Age is required");
        }
        if (req.getParameter("sSex").equals("")) {
            if (!bulkMode) throw new Exception("Strain Sex is required");
        }

        if (cmAccID.equals("")) {
            if (!bulkMode) throw new Exception("Clinical Measurement ACC ID is required");
        } else {
            if (!cmAccID.equals(TERM_REQUEST)) {
                if (!cmAccID.startsWith("CMO") || dao.getTermByAccId(cmAccID) == null)
                    throw new Exception("Clinical Measurement ACC ID: " + cmAccID + " not found!");
                if (!dao.isForCuration(cmAccID))
                    throw new Exception("Clinical Measurement ACC ID: " + cmAccID + " is not for curation!");
            }
        }

        try {
            Double.parseDouble(req.getParameter("cmValue"));
        }catch (Exception ignored) {
            if (!bulkMode) {
                throw new Exception("Clinical Measurement value is not numeric");
            }
        }


        if (cmUnits.equals("")) {
            if (!bulkMode) throw new Exception("Clinical measurement unit is required");
        } else if ((!cmAccID.equals("") && !cmAccID.equals(TERM_REQUEST)) && !cmUnits.equals(VALUE_REQUEST)) {
            String unitConversion = pdao.checkUnitConversion(cmAccID, cmUnits);
            if (!unitConversion.equals("")) throw new Exception(unitConversion);
        }

        if (mmAccId.equals("")) {
            if (!bulkMode) throw new Exception("Measurement Method ACC ID is required");
        } else {
            if (!mmAccId.equals(TERM_REQUEST)) {
                if (!mmAccId.startsWith("MMO:") || dao.getTermByAccId(mmAccId) == null)
                    throw new Exception("Measurement Method ACC ID: " + mmAccId + " not found!");
                if (!dao.isForCuration(mmAccId))
                    throw new Exception("Measurement Method ACC ID: " + mmAccId + " is not for curation!");
            }
        }

        if (!req.getParameter("mmSiteAccID").equals("") && !req.getParameter("mmSiteAccID").equals("\\")) {
            String[] mmIds = req.getParameter("mmSiteAccID").split("\\|");
            for (String mmId : mmIds) {
                if (!mmId.equals(TERM_REQUEST)) {
                    if (!mmId.startsWith("UBERON:") || dao.getTermByAccId(mmId) == null)
                        throw new Exception("Measurement Method Site ACC ID: " + mmId + " not found!");
                    if (!dao.isForCuration(mmId))
                        throw new Exception("Measurement Method Site ACC ID: " + mmId + " is not for curation!");
                }
            }
        }

        if (!req.getParameter("cmSiteAccID").equals("") && !req.getParameter("cmSiteAccID").equals("\\")) {
            String[] cmIds = req.getParameter("cmSiteAccID").split("\\|");
            for (String cmId : cmIds) {
                if (!cmId.equals(TERM_REQUEST)) {
                    if (!(cmId.startsWith("UBERON:") || cmId.startsWith("CL:")) || dao.getTermByAccId(cmId) == null)
                        throw new Exception("Clinical Measurement Site ACC ID: " + cmId + " not found!");
                    if (!dao.isForCuration(cmId))
                        throw new Exception("Clinical Measurement Site ACC ID: " + cmId + " is not for curation!");
                }
            }
        }

        String[] ord = req.getRequest().getParameterValues("cOrdinality");
        String[] acc = req.getRequest().getParameterValues("cAccId");
        String[] minValues = req.getRequest().getParameterValues("cValueMin");
        String[] maxValues = req.getRequest().getParameterValues("cValueMax");
        String[] minDura = req.getRequest().getParameterValues("cMinDuration");
        String[] maxDura = req.getRequest().getParameterValues("cMaxDuration");

        if (!bulkMode) {
            for (int i = 0; i < ord.length; i++) {
                if (ord[i].equals("") && !acc[i].equals("")) {
                    throw new Exception("Condition Ordinality is required for Condition " + (i + 1));
                }
            }
        }

        for (int i = 0; i < ord.length; i++) {
            if (acc[i].trim().length() > 0 && !acc[i].equals(TERM_REQUEST)) {
                if (!acc[i].startsWith("XCO:") || dao.getTermByAccId(acc[i]) == null)
                    throw new Exception("Experimental Condition ACC ID: " + acc[i] + " not found!");
                if (!dao.isForCuration(acc[i]))
                    throw new Exception("Experimental Condition ACC ID: " + acc[i] + " is not for curation!");
            }

            if (!bulkMode && ((minValues[i] + maxValues[i]
                    + minDura[i] + maxDura[i]).trim().length()
                    > 0) && acc[i].trim().length() == 0) {
                throw new Exception("Experiment Condition ACC ID is required for Condition " + (i + 1));
            }
        }

    }

    private Record buildRecord(HttpRequestFacade req, Record r, boolean multiEdit) throws Exception {


        try {
            if (req.getParameter("expId") != null && req.getParameter("expId").length() > 0)
                r.setExperimentId(Integer.parseInt(req.getParameter("expId")));
        } catch (Exception e) {
//            e.printStackTrace();
        }

        //check for clinical measurement values
        if (!req.getParameter("cmAccId").equals("")) {
            r.getClinicalMeasurement().setAccId(req.getParameter("cmAccId"));
        }

        if (!req.getParameter("cmValue").equals("")) {
            r.setMeasurementValue(checkForDeletion(req.getParameter("cmValue")));
        }
        if (!req.getParameter("cmUnits").equals("")) {
            r.setMeasurementUnits(req.getParameter("cmUnits"));
        }
        if (!req.getParameter("cmSD").equals("")) {
            r.setMeasurementSD(checkForDeletion(req.getParameter("cmSD")));
        }
        if (!req.getParameter("cmSEM").equals("")) {
            r.setMeasurementSem(checkForDeletion(req.getParameter("cmSEM")));
        }
        if (!req.getParameter("cmError").equals("")) {
            r.setMeasurementError(checkForDeletion(req.getParameter("cmError")));
        }
        if (!req.getParameter("cmAveType").equals("")) {
            r.getClinicalMeasurement().setAverageType(checkForDeletion(req.getParameter("cmAveType")));
        }
        if (!req.getParameter("cmFormula").equals("")) {
            r.getClinicalMeasurement().setFormula(checkForDeletion(req.getParameter("cmFormula")));
        }
        if (!req.getParameter("cmNote").equals("")) {
            r.getClinicalMeasurement().setNotes(checkForDeletion(req.getParameter("cmNote")));
        }

        //check for measurement method values
        if (!req.getParameter("mmAccId").equals("")) {
            r.getMeasurementMethod().setAccId(req.getParameter("mmAccId"));
        }

        String mm_units = req.getParameter("mmDurationUnits");
        if (!req.getParameter("mmDuration").equals("")) {
            if (checkForDeletion(req.getParameter("mmDuration")) == null) {
                r.getMeasurementMethod().setDuration(null);
            } else {
                r.getMeasurementMethod().setDuration("" + this.convertToSeconds(Double.parseDouble(req.getParameter("mmDuration")), req.getParameter("mmDurationUnits")));
            }
        } else if (!multiEdit || Condition.convertStringToDurationBound(mm_units) < 0) {
            r.getMeasurementMethod().setDuration("" + Condition.convertStringToDurationBound(mm_units));
        } else if (multiEdit && !mm_units.equals("secs")) {
            r.getMeasurementMethod().setDuration("" + this.convertToSeconds(Long.parseLong(r.getMeasurementMethod().getDuration()), req.getParameter("mmDurationUnits")));
        }

        if (!req.getParameter("mmSite").equals("")) {
            r.getMeasurementMethod().setSite(checkForDeletion(req.getParameter("mmSite")));
        }
        if (!req.getParameter("mmSiteAccID").equals("")) {
            if (req.getParameter("mmSiteAccID").equals("\\") && req.getParameter("mmSite").equals(""))
                r.getMeasurementMethod().setSite(null);
            r.getMeasurementMethod().setSiteOntIds(checkForDeletion(req.getParameter("mmSiteAccID")));
        }

        if (!req.getParameter("cmSite").equals("")) {
            r.getClinicalMeasurement().setSite(checkForDeletion(req.getParameter("cmSite")));
        }
        if (!req.getParameter("cmSiteAccID").equals("")) {
            if (req.getParameter("cmSiteAccID").equals("\\") && req.getParameter("cmSite").equals(""))
                r.getClinicalMeasurement().setSite(null);
            r.getClinicalMeasurement().setSiteOntIds(checkForDeletion(req.getParameter("cmSiteAccID")));
        }

        if (!req.getParameter("mmPostInsultType").equals("")) {
            r.getMeasurementMethod().setPiType(checkForDeletion(req.getParameter("mmPostInsultType")));
        }
        if (!req.getParameter("mmPostInsultTime").equals("")) {
            if (checkForDeletion(req.getParameter("mmPostInsultTime")) == null) {
                r.getMeasurementMethod().setPiTimeValue(null);
            } else {
                r.getMeasurementMethod().setPiTimeValue(Integer.parseInt(req.getParameter("mmPostInsultTime")));
            }
        }
        if (!req.getParameter("mmInsultTimeUnit").equals("")) {
            r.getMeasurementMethod().setPiTypeUnit(checkForDeletion(req.getParameter("mmInsultTimeUnit")));
        }
        if (!req.getParameter("mmNotes").equals("")) {
            r.getMeasurementMethod().setNotes(checkForDeletion(req.getParameter("mmNotes")));
        }

        String minAge = req.getParameter("sMinAge");
        String maxAge = req.getParameter("sMaxAge");
        String ac = req.getParameter("sAnimalCount");
        //check for strain values
        if (!req.getParameter("sAccId").equals("")) {
            r.getSample().setStrainAccId(req.getParameter("sAccId"));
        }
        if (!ac.equals("")) {
            if (ac.equalsIgnoreCase("NA") || ac.equalsIgnoreCase("N/A")) {
                r.getSample().setNumberOfAnimals(0);
            } else r.getSample().setNumberOfAnimals(Integer.parseInt(ac));
        }
        if (!minAge.equals("")) {
            if (minAge.equalsIgnoreCase("\\") || minAge.equalsIgnoreCase("NA") ||
                    minAge.equalsIgnoreCase("N/A")) {
                r.getSample().setAgeDaysFromLowBound(null);
            } else r.getSample().setAgeDaysFromLowBound(Double.parseDouble(minAge));
        }
        if (!maxAge.equals("")) {
            if (maxAge.equalsIgnoreCase("\\") || maxAge.equalsIgnoreCase("NA") ||
                    maxAge.equalsIgnoreCase("N/A")) {
                r.getSample().setAgeDaysFromHighBound(null);
            } else r.getSample().setAgeDaysFromHighBound(Double.parseDouble(maxAge));
        }
        if (!req.getParameter("sSex").equals("")) {
            r.getSample().setSex(req.getParameter("sSex"));
        }

        if (!req.getParameter("sStatus").equals("")) {
            r.setCurationStatus(Integer.parseInt(req.getParameter("sStatus")));
        }

        String[] cAccId = req.getRequest().getParameterValues("cAccId");
        String[] cValueMin = req.getRequest().getParameterValues("cValueMin");
        String[] cValueMax = req.getRequest().getParameterValues("cValueMax");
        String[] cUnits = req.getRequest().getParameterValues("cUnits");
        String[] cMinDuration = req.getRequest().getParameterValues("cMinDuration");
        String[] cMinDurationUnits = req.getRequest().getParameterValues("cMinDurationUnits");
        String[] cMaxDuration = req.getRequest().getParameterValues("cMaxDuration");
        String[] cMaxDurationUnits = req.getRequest().getParameterValues("cMaxDurationUnits");
        String[] cApplicationMethod = req.getRequest().getParameterValues("cApplicationMethod");
        String[] cOrdinality = req.getRequest().getParameterValues("cOrdinality");
        String[] cNotes = req.getRequest().getParameterValues("cNotes");

        int activeCondition = 0;
        String[] cDelete = req.getRequest().getParameterValues("cDelete");
        String[] cId = req.getRequest().getParameterValues("cId");

        for (int j = 0; j < cAccId.length; j++) {

            // Check if current cId exists in the cDelete ID list,
            // so that unwanted cloned conditions can be ignored.
            if (cDelete != null) {
                boolean toDelete = false;
                for (String cDelId : cDelete) {
                    if (cDelId.equals(cId[j])) {
                        toDelete = true;
                        break;
                    }
                }
                if (toDelete) continue;
            }

            if (activeCondition >= r.getConditions().size() && !cAccId[j].equals("")) {
                r.getConditions().add(new Condition());
            } else if (activeCondition >= r.getConditions().size()) {
                continue;
            }

            Condition c = r.getConditions().get(activeCondition);
            if (cAccId[j].equals("") && c.getOntologyId() == null) {
                continue;
            }

            if (!cAccId[j].equals("")) {
                r.getConditions().get(activeCondition).setOntologyId(cAccId[j]);
            }
            if (!cValueMin[j].equals("")) {
                r.getConditions().get(activeCondition).setValueMin(checkForDeletion(cValueMin[j]));
            }
            if (!cValueMax[j].equals("")) {
                r.getConditions().get(activeCondition).setValueMax(checkForDeletion(cValueMax[j]));
            }
            if (!cUnits[j].equals("")) {
                r.getConditions().get(activeCondition).setUnits(checkForDeletion(cUnits[j]));
            }

            if (!cMinDuration[j].equals("")) {
                r.getConditions().get(activeCondition).setDurationLowerBound(cMinDuration[j].equals("\\") ? 0
                        : this.convertToSeconds(Double.parseDouble(cMinDuration[j]), cMinDurationUnits[j]));
            } else if (!multiEdit || Condition.convertStringToDurationBound(cMinDurationUnits[j]) < 0) {
                r.getConditions().get(activeCondition).setDurationLowerBound(Condition.convertStringToDurationBound(cMinDurationUnits[j]));
            } else if (multiEdit && !cMinDurationUnits[j].equals("secs")) {
                r.getConditions().get(activeCondition).setDurationLowerBound(this.convertToSeconds(r.getConditions().get(activeCondition).getDurationLowerBound(), cMinDurationUnits[j]));
            }

            if (!cMaxDuration[j].equals("")) {
                r.getConditions().get(activeCondition).setDurationUpperBound(cMaxDuration[j].equals("\\") ? 0 :
                        this.convertToSeconds(Double.parseDouble(cMaxDuration[j]), cMaxDurationUnits[j]));
            } else if (!multiEdit || Condition.convertStringToDurationBound(cMaxDurationUnits[j]) < 0) {
                r.getConditions().get(activeCondition).setDurationUpperBound(Condition.convertStringToDurationBound(cMaxDurationUnits[j]));
            } else if (multiEdit && !cMaxDurationUnits[j].equals("secs")) {
                r.getConditions().get(activeCondition).setDurationUpperBound(this.convertToSeconds(r.getConditions().get(activeCondition).getDurationUpperBound(), cMaxDurationUnits[j]));
            }

            if (!cApplicationMethod[j].equals("")) {
                r.getConditions().get(activeCondition).setApplicationMethod(checkForDeletion(cApplicationMethod[j]));
            }
            if (!cOrdinality[j].equals("")) {
                r.getConditions().get(activeCondition).setOrdinality(Integer.parseInt(cOrdinality[j]));
            }
            if (!cNotes[j].equals("")) {
                r.getConditions().get(activeCondition).setNotes(checkForDeletion(cNotes[j]));
            }
            activeCondition++;
        }

        return r;
    }

    private String checkForDeletion(String value) {
        return (value.equals("\\") || value.equals("null") ? null : value);
    }

    private double convertToSeconds(double value, String units) {

        if (units.equals("secs")) {
            return value;
        } else if (units.equals("mins")) {
            return value * 60;
        } else if (units.equals("hours")) {
            return value * 60 * 60;
        } else if (units.equals("days")) {
            return value * 60 * 60 * 24;
        } else if (units.equals("weeks")) {
            return value * 60 * 60 * 24 * 7;
        } else if (units.equals("months")) {
            return value * 60 * 60 * 24 * (365 / 12);
        } else if (units.equals("years")) {
            return value * 60 * 60 * 24 * 365;
        }

        return Condition.convertStringToDurationBound(units);
    }

}
