package edu.mcw.rgd.expression;

import edu.mcw.rgd.dao.impl.GeneExpressionDAO;
import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.datamodel.pheno.*;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.apache.commons.math3.analysis.function.Exp;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


public class GeoExperimentController implements Controller {

//    PhenominerDAO geDAO = new PhenominerDAO();
    GeneExpressionDAO geDAO = new GeneExpressionDAO();
    public String login = "";
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList<String> status = new ArrayList<>();
        ArrayList<String> error = new ArrayList<>();
        String accessToken = null;
        if(request.getCookies() != null && request.getCookies().length != 0)
            if(request.getCookies()[0].getName().equalsIgnoreCase("accessToken"))
                accessToken = request.getCookies()[0].getValue();

        if(!checkToken(accessToken)) {
            response.sendRedirect("https://github.com/login/oauth/authorize?client_id=dc5513384190f8a788e5&scope=user&redirect_uri=https://pipelines.rgd.mcw.edu/rgdweb/curation/login.html");
            return null;
        }
        if (request.getParameter("count") != null) {
            Report r = new Report();
            try {
            int count = Integer.parseInt(request.getParameter("count"));
            String gse = request.getParameter("gse");
            String title = request.getParameter("title");
                String species = request.getParameter("species");
                List<Experiment> eList = new ArrayList<>();
                List<Experiment> newExp = new ArrayList<>();

//                    List<Study> studyList = new ArrayList<>();
                List<Sample> sampleList = new ArrayList<>();
                HashMap<Integer,List<Condition>> sampleConditions = new HashMap<>();
                HashMap<Integer, Experiment> sampleExperiment = new HashMap<>();
                int speciesType = SpeciesType.RAT;
                switch (species.toLowerCase()){
                    case "mus":
                        speciesType = SpeciesType.MOUSE;
                        break;
                    case "homo":
                        speciesType = SpeciesType.HUMAN;
                        break;
                    case "chinchilla":
                        speciesType = SpeciesType.CHINCHILLA;
                        break;
                    case "pan":
                        speciesType = SpeciesType.BONOBO;
                        break;
                    case "canis":
                        speciesType = SpeciesType.DOG;
                        break;
                    case "ictidomys":
                        speciesType = SpeciesType.SQUIRREL;
                        break;
                    case "sus":
                        speciesType = SpeciesType.PIG;
                        break;
                    case "glaber":
                        speciesType = SpeciesType.NAKED_MOLE_RAT;
                        break;
                    case "sabaeus":
                        speciesType = SpeciesType.VERVET;
                    default:
                        speciesType = SpeciesType.RAT;
                        break;
                }

            for (int i = 0; i < count; i++) {
                Sample s = new Sample();

                List<Condition> conditions = new ArrayList<>();
                s.setSex(request.getParameter("sex" + i));
                s.setTissueAccId(request.getParameter("tissueId" + i));
                s.setCellTypeAccId(request.getParameter("cellTypeId" + i));
                s.setCultureDur(!Utils.isStringEmpty(request.getParameter("cultureDur"+i)) ? Integer.parseInt(request.getParameter("cultureDur"+i)) : null);
                s.setCultureDurUnit(request.getParameter("cultureUnits"+i));
                s.setCellLineId(request.getParameter("cellLineId" + i));
                s.setGeoSampleAcc(request.getParameter("sampleId" + i));
                s.setStrainAccId(request.getParameter("strainId" + i));
                s.setBioSampleId(request.getParameter("sampleId" + i));
                String[] lifeStages = request.getParameterValues("lifeStage"+i);
                String stage = "";
//                System.out.println(s.getGeoSampleAcc());
                if (lifeStages!=null) {
                    for (int j = 0; j < lifeStages.length; j++) {
                        stage += lifeStages[j];
                        if (j != lifeStages.length - 1)
                            stage += ";";
                    }
                }
                if (stage.isEmpty())
                    stage=null;
                s.setLifeStage(stage);
                s.setNotes(request.getParameter("notes"+i));
                s.setCuratorNotes(request.getParameter("cNotes"+i));
                String curStatus = request.getParameter("status"+i);
                String curAction = request.getParameter("action"+i);

                if (request.getParameter("ageHigh" + i) != null && !request.getParameter("ageHigh" + i).isEmpty())
                    s.setAgeDaysFromHighBound(Integer.parseInt(request.getParameter("ageHigh" + i)));
                if (request.getParameter("ageLow" + i) != null && !request.getParameter("ageLow" + i).isEmpty() )
                    s.setAgeDaysFromLowBound(Integer.parseInt(request.getParameter("ageLow" + i)));

                s.setNumberOfAnimals(1);
                int sampleId = 0;
                Sample sample = geDAO.getSampleByGeoId(s.getBioSampleId());
                boolean loadIt = curAction.equals("load") || curAction.equals("edit");
                if(sample == null && loadIt){//curAction.equals("load")) {
                    s.setCreatedBy(login);
                    sampleId = geDAO.insertSample(s);
                    sampleList.add(s);
                }
                else if (loadIt){
                    s.setId(sample.getId());
                    sampleId = sample.getId();
                    s.setLastModifiedBy(login);
                    geDAO.updateSample(s);
                    sampleList.add(s);
                }
                if (curStatus.equals("pending") && curAction.equals("load"))
                    geDAO.updateGeoSampleStatus(gse,s.getBioSampleId(),"loaded",species);
                else {
                    switch (curStatus) {
                        case "loaded":
                            geDAO.updateGeoSampleStatus(gse, s.getBioSampleId(), "loaded", species);
                            break;
                        case "not4Curation":
                            geDAO.updateGeoSampleStatus(gse, s.getBioSampleId(), "not4Curation", species);
                            break;
                        case "futureCuration":
                            geDAO.updateGeoSampleStatus(gse, s.getBioSampleId(), "futureCuration", species);
                            break;
                        case "pending":
                            geDAO.updateGeoSampleStatus(gse, s.getBioSampleId(), "pending", species);
                            break;
                    }
                }
                if (curAction.equals("load") || curAction.equals("edit")) {
                    // find/create study
                    GeneExpressionRecord gre = null;
                    Study study = geDAO.getStudyByGeoId(gse);
                    int studyId = 0 ;
                    if (study == null) {
                        study = new Study();
                        study.setGeoSeriesAcc(gse);
                        study.setType("RNA-SEQ");
                        study.setName(title);
                        study.setSource("GEO");
                        study.setDataType("rna-seq_expression");
                        study.setCreatedBy(login);
                        studyId = geDAO.insertStudy(study);
                    }
                    else
                        studyId = study.getId();

                    // find/create experiment by study

                    eList = geDAO.getExperiments(study.getId());
                    Experiment exp = null;
                    if (eList == null || eList.isEmpty()) {
                        eList = new ArrayList<>();
                        Experiment e = new Experiment();
                        e.setStudyId(studyId);
                        e.setName(study.getName());
                        e.setCreatedBy(login);
                        e.setTraitOntId(request.getParameter("vtId" + i));
                        geDAO.insertExperiment(e);
                        exp = e;
                        eList.add(e);
                        newExp.add(e);
                    }
                    else { // need to find correct experiment based on VT
                        Experiment e = null;
                        String vtId = request.getParameter("vtId" + i);
                        gre = geDAO.getGeneExpressionRecordBySampleId(sampleId);
                        if (gre==null) { // store experiment to make sure another is not made
                            for (Experiment experiment : newExp){
                                if (experiment.getTraitOntId().equals(vtId))
                                    exp = experiment;
                            }
                            if (exp == null) {
                                e = new Experiment();
                                e.setStudyId(studyId);
                                e.setName(study.getName());
                                e.setCreatedBy(login);
                                e.setTraitOntId(request.getParameter("vtId" + i));
                                geDAO.insertExperiment(e);
                                exp = e;
                                eList.add(e);
                                newExp.add(e);
                            }
                        }
                        else {
                            exp = geDAO.getExperiment(gre.getExperimentId());
                            if (exp == null) {
                                e = new Experiment();
                                e.setStudyId(studyId);
                                e.setName(study.getName());
                                e.setCreatedBy(login);
                                e.setTraitOntId(request.getParameter("vtId" + i));
                                geDAO.insertExperiment(e);
                                exp = e;
                                eList.add(e);
                                newExp.add(e);
                            } else if (!Utils.isStringEmpty(vtId) && !Utils.stringsAreEqual(exp.getTraitOntId(), vtId)) {
                                exp.setTraitOntId(vtId);
                                newExp.add(exp);
                                geDAO.updateExperiment(exp);
                            }
                        }

                    }
                    sampleExperiment.put(sampleId, exp);

                    // find/create gene_expression_exp_record by experiment
//                        for (Experiment ex : eList) {
                        if (sampleId == 0)
                            continue;
                        int geId = 0;
                        if (gre==null)
                            gre = geDAO.getGeneExpressionRecordByExperimentIdAndSampleId(exp.getId(), sampleId);
                        Integer oldCmoId;
                        try {
                            oldCmoId = gre.getClinicalMeasurementId();
                        }
                        catch (Exception e){
                            oldCmoId = null;
                        }

                        Integer cmoId = null;
//                        GeneExpressionRecord copy = gre;
                        if (gre == null) {
                            gre = new GeneExpressionRecord();
                            gre.setExperimentId(exp.getId());
                            gre.setSampleId(sampleId);
                            gre.setCurationStatus(35);
                            gre.setSpeciesTypeKey(speciesType);
                            gre.setLastModifiedBy(login);
                            ClinicalMeasurement cmo = null;
//                            cmoId = cmo.getId();
                            String cmoAcc = Utils.NVL(request.getParameter("cmoId"+i),"");
                            // if null create, else update
                            if (!Utils.isStringEmpty(cmoAcc)){
                                cmo = new ClinicalMeasurement();
                                cmo.setAccId(cmoAcc);
                                cmoId = geDAO.insertClinicalMeasurement(cmo);
                                gre.setClinicalMeasurementId(cmoId);
                            }
                            geId = geDAO.insertGeneExpressionRecord(gre);
                        } else {
                            geId = gre.getId();
                            // get CMO from record
                            ClinicalMeasurement cmo;

                            if (gre.getClinicalMeasurementId()==null){
                                cmo = null;
                            }
                            else {
                                cmo = geDAO.getClinicalMeasurement(gre.getClinicalMeasurementId());
                            }

                            String cmoAcc = Utils.NVL(request.getParameter("cmoId"+i),"");
                            // if null create, else update
                            if (cmo==null && !Utils.isStringEmpty(cmoAcc)){
                                cmo = new ClinicalMeasurement();
                                cmo.setAccId(cmoAcc);
                                cmoId = geDAO.insertClinicalMeasurement(cmo);
                                cmo.setId(cmoId);
                                gre.setClinicalMeasurementId(cmoId);
                            }
                            else{
                                if (cmo != null && !Utils.stringsAreEqual(cmo.getAccId(), cmoAcc) && !Utils.isStringEmpty(cmoAcc)) {
                                    cmo.setAccId(cmoAcc);
                                    geDAO.updateClinicalMeasurement(cmo);
                                }
                            }
                            if (cmoId != null && !cmoId.equals(oldCmoId)) {
                                gre.setLastModifiedBy(login);
                                geDAO.updateGeneExpressionRecord(gre);
                            }

                        }
                        // find/create experiment conditions by gene_expression_exp_record

                        HttpRequestFacade req = new HttpRequestFacade(request);
                        String[] checkboxes = request.getParameterValues("expCondition" + i);
                        String[] cId = request.getParameterValues("cId" + i);
                        String[] cValueMin = req.getRequest().getParameterValues("cValueMin" + i);
                        String[] cValueMax = req.getRequest().getParameterValues("cValueMax" + i);
                        String[] cUnits = req.getRequest().getParameterValues("cUnits" + i);
                        String[] cMinDuration = req.getRequest().getParameterValues("cMinDuration" + i);
                        String[] cMinDurationUnits = req.getRequest().getParameterValues("cMinDurationUnits" + i);
                        String[] cMaxDuration = req.getRequest().getParameterValues("cMaxDuration" + i);
                        String[] cMaxDurationUnits = req.getRequest().getParameterValues("cMaxDurationUnits" + i);
                        String[] cApplicationMethod = req.getRequest().getParameterValues("cApplicationMethod" + i);
                        String[] cOrdinality = req.getRequest().getParameterValues("cOrdinality" + i);
                        String[] cNotes = req.getRequest().getParameterValues("conNotes" + i);
                        if (checkboxes==null)
                            continue;
                        for (String j : checkboxes) {
                            int k = Integer.parseInt(j);
                            String xcoId = request.getParameter("xcoId" + i +"_"+ k);
                            Condition c = new Condition();
                            c.setOntologyId(xcoId);
                            c.setValueMin(Utils.isStringEmpty(cValueMin[k]) ? "0" : cValueMin[k]);
                            c.setValueMax(Utils.isStringEmpty(cValueMax[k]) ? null : cValueMax[k]);
                            c.setUnits(cUnits[k]);
                            if (!Utils.isStringEmpty(cMinDuration[k])) {
                                c.setDurationLowerBound(convertToSeconds(Double.parseDouble(cMinDuration[k]), cMinDurationUnits[k]));
                            }
                            if (!Utils.isStringEmpty(cMaxDuration[k])) {
                                c.setDurationUpperBound(convertToSeconds(Double.parseDouble(cMaxDuration[k]), cMaxDurationUnits[k]));
                            }
                            c.setApplicationMethod(cApplicationMethod[k]);
                            int ord;
                            try{
                                ord = Integer.parseInt(cOrdinality[k]);
                            }
                            catch (Exception e){
                                ord = 1;
                            }
                            c.setOrdinality(ord);
                            c.setNotes(cNotes[k]);
                            c.setGeneExpressionRecordId(geId);

                            if (Utils.isStringEmpty(cId[k])) {
//                                    geDAO.insertCondition(c);
                                c.setId(-1);
                                conditions.add(c);

//                                    insConds.add(c);
                            }
                            else {
                                c.setId(Integer.parseInt(cId[k]));
//                                    geDAO.updateCondition(c);
                                conditions.add(c);
//                                    updateConds.add(c);
                            }

                        }

//                        }
                } // end condition addons
                if (loadIt) {
                    insertConditions(conditions);
                    sampleConditions.put(sampleId, conditions);
                }

            } // end for
            int tissue = 0, strain = 0, cell = 0, culture = 0, cellLine = 0, age = 0, lifeStage = 0, notes = 0, cNotes = 0;
            int maxCond = 0, vtId = 0, cmoIds = 0;
//                List<Integer> minMaxVals = new ArrayList<>(), minMaxDurs = new ArrayList<>(), appMethods = new ArrayList<>(), condNotes = new ArrayList<>();
            HashMap<String, Integer> minMaxVals = new HashMap<>();
            HashMap<String, Integer> minMaxDurs = new HashMap<>();
            HashMap<String, Integer> appMethods = new HashMap<>();
            HashMap<String, Integer> condNotes = new HashMap<>();
            for (Sample s : sampleList){
                // go through samples and conditions/VT to filter columns
                // ints and doubles should be checked if both values are 0, if both zero then time was not used
                if (!Utils.isStringEmpty(s.getTissueAccId()))
                    tissue++;
                if (!Utils.isStringEmpty(s.getStrainAccId()))
                    strain++;
                if (!Utils.isStringEmpty(s.getCellTypeAccId()))
                    cell++;
                if (s.getCultureDur()!=null)
                    culture++;
                if (!Utils.isStringEmpty(s.getCellLineId()))
                    cellLine++;
                if ((s.getAgeDaysFromLowBound() != null && s.getAgeDaysFromHighBound() != null) &&
                        (s.getAgeDaysFromLowBound() != 0 && s.getAgeDaysFromHighBound() != 0))
                    age++;
                if (!Utils.isStringEmpty(s.getLifeStage()))
                    lifeStage++;
                if (!Utils.isStringEmpty(s.getNotes()))
                    notes++;
                if (!Utils.isStringEmpty(s.getCuratorNotes()))
                    cNotes++;

//                    List<Experiment> expList = sampleExperiment.get(s.getId());
                Experiment e = sampleExperiment.get(s.getId());
                GeneExpressionRecord gre = geDAO.getGeneExpressionRecordByExperimentIdAndSampleId(e.getId(),s.getId());
                List<Condition> condList = sampleConditions.get(s.getId());
                if (condList != null && condList.size() > maxCond)
                    maxCond = condList.size();
                if (condList==null)
                    condList=new ArrayList<>();

//                    for (Experiment e : expList){
                if (!Utils.isStringEmpty(e.getTraitOntId()))
                    vtId++;
//                    }
                if (gre.getClinicalMeasurementId()!=null && gre.getClinicalMeasurementId()!=0)
                    cmoIds++;
                for (int i = 0; i < condList.size() ; i++){
                    //
                    int minMaxVal = 0, minMaxDur = 0, appMethod = 0, condNote = 0;
                    Condition c = condList.get(i);
                    if (!Utils.isStringEmpty(c.getValueMin()) && !Utils.isStringEmpty(c.getValueMax()) && !Utils.isStringEmpty(c.getUnits())){
                        minMaxVal++;
                    }
                    if (c.getDurationLowerBound()!=0 && c.getDurationUpperBound()!=0)
                        minMaxDur++;
                    if (!Utils.isStringEmpty(c.getApplicationMethod()))
                        appMethod++;
                    if (!Utils.isStringEmpty(c.getNotes()))
                        condNote++;
                    if (minMaxVals.get("cond"+i) == null || minMaxVal>0)
                        minMaxVals.put("cond"+i,minMaxVal);
                    if (minMaxDurs.get("cond"+i) == null || minMaxDur>0)
                        minMaxDurs.put("cond"+i,minMaxDur);
                    if (appMethods.get("cond"+i) == null || appMethod>0)
                        appMethods.put("cond"+i,appMethod);
                    if (condNotes.get("cond"+i) == null || condNote>0)
                        condNotes.put("cond"+i,condNote);
                }

            }

                Record header = new Record();
                header.append("Sample ID");
                header.append("Geo Accession ID");
                if (tissue != 0)
                    header.append("Tissue ID");
                if (vtId != 0)
                    header.append("Vertebrate Trait");
                if (cmoIds != 0)
                    header.append("Clinical Measurement");
                if (strain != 0)
                    header.append("Strain ID");
                if (cell != 0)
                    header.append("Cell ID");
                if (culture != 0) {
                    header.append("Culture Duration");
                    header.append("Culture Units");
                }
                if (cellLine != 0)
                    header.append("Cell Line ID");
                if (age != 0) {
                    header.append("Age High");
                    header.append("Age Low");
                }
                header.append("Sex");
                if (lifeStage != 0)
                    header.append("Life Stage");
                if (notes != 0)
                    header.append("Notes");
                if (cNotes != 0)
                    header.append("Curator Notes");

                for (int i = 0 ; i < maxCond; i++){
                    int num = i+1;
                    header.append("XCO Id " + num);
                    if (minMaxVals.get("cond"+i)!=0) {
                        header.append("Min value " + num);
                        header.append("Max Value " + num);
                        header.append("Unit " + num);
                    }
                    if (minMaxDurs.get("cond"+i) != 0){
                        header.append("Min Dur " + num);
                        header.append("Max Dur " + num);
                    }
                    if (appMethods.get("cond"+i) != 0)
                        header.append("Application Method " + num);
                    header.append("Ordinality " + num);
                    if (condNotes.get("cond"+i)!=0)
                        header.append("Condition Notes " + num);

                }
                r.append(header);

                for (Sample s : sampleList){
                    Record rec = new Record();
                    rec.append(s.getId()+"");
                    rec.append(s.getGeoSampleAcc());
                    Experiment e = sampleExperiment.get(s.getId());
                    if (tissue != 0)
                        rec.append(s.getTissueAccId());
                    if (vtId != 0) {
                        rec.append(e.getTraitOntId());
                    }
                    if (cmoIds!=0){
                        GeneExpressionRecord g = geDAO.getGeneExpressionRecordByExperimentIdAndSampleId(e.getId(),s.getId());
                        ClinicalMeasurement c = geDAO.getClinicalMeasurement(g.getClinicalMeasurementId());
                        if (c!=null)
                            rec.append(c.getAccId());
                        else
                            rec.append("");
                    }
                    if (strain != 0)
                        rec.append(s.getStrainAccId());
                    if (cell != 0)
                        rec.append(s.getCellTypeAccId());
                    if (culture != 0){
                        rec.append(Utils.NVL(String.valueOf(s.getCultureDur()),""));
                        rec.append(s.getCultureDurUnit());
                    }
                    if (cellLine != 0)
                        rec.append(s.getCellLineId());
                    if (age != 0) {
                        rec.append(s.getAgeDaysFromHighBound()+"");
                        rec.append(s.getAgeDaysFromLowBound()+"");
                    }
                    rec.append(s.getSex());
                    if (lifeStage != 0)
                        rec.append(s.getLifeStage());
                    if (notes != 0)
                        rec.append(s.getNotes());
                    if (cNotes != 0)
                        rec.append(s.getCuratorNotes());

                    List<Condition> conds = sampleConditions.get(s.getId());
                    if (conds == null)
                        conds = new ArrayList<>();
                    for (int i = 0; i < conds.size(); i++){
                        Condition c = conds.get(i);
                        rec.append(c.getOntologyId());
                        if (minMaxVals.get("cond"+i) != 0) {
                            rec.append(c.getValueMin());
                            rec.append(c.getValueMax());
                            rec.append(c.getUnits());
                        }
                        if (minMaxDurs.get("cond"+i) != 0){
                            rec.append(c.getDurationLowerBound()+"");
                            rec.append(c.getDurationUpperBound()+"");
                        }
                        if (appMethods.get("cond"+i) != 0)
                            rec.append(c.getApplicationMethod());
                        rec.append(c.getOrdinality()+"");
                        if (condNotes.get("cond"+i) != 0)
                            rec.append(c.getNotes());
                    }

                    r.append(rec);
                }

        }catch (Exception e){
                error.add("Sample insertion failed for " + e);
                e.printStackTrace();

        }
            request.setAttribute("error", error);
            request.setAttribute("report",r);
            return new ModelAndView("/WEB-INF/jsp/curation/expression/" + "samples.jsp");
        }
        if (request.getParameter("act") != null && request.getParameter("act").equalsIgnoreCase("update")) {
            String gse = request.getParameter("geoId");
            String species = request.getParameter("species");
            String curationStatus = request.getParameter("status");
            geDAO.updateGeoStudyStatus(gse, curationStatus,species);
            status.add("Status updated successfully for " + gse);
            request.setAttribute("status", status);
            return new ModelAndView("/WEB-INF/jsp/curation/expression/" + "experiments.jsp");
        }
        if(request.getParameter("tcount") != null){
            int tcount = Integer.parseInt(request.getParameter("tcount"));
            int scount = Integer.parseInt(request.getParameter("scount"));
            int ctcount = Integer.parseInt(request.getParameter("ctcount"));
            int clcount = Integer.parseInt(request.getParameter("clcount"));
            int ageCount = Integer.parseInt(request.getParameter("agecount"));
            int gcount = Integer.parseInt(request.getParameter("gcount"));
            int noteCnt = Integer.parseInt(request.getParameter("notescount"));
            int condCnt = Integer.parseInt(request.getParameter("conditionCount"));
            int sampleSize = Integer.parseInt(request.getParameter("samplesExist"));
            String gse = request.getParameter("gse");
            String species = request.getParameter("species");
            HashMap<String,String> tissueMap = new HashMap();
            HashMap<String,String> tissuneNameMap = new HashMap<>();
            HashMap<String,String> vtMap = new HashMap<>();
            HashMap<String,String> vtNameMap = new HashMap<>();
            HashMap<String,String> cmoMap = new HashMap<>();
            HashMap<String,String> cmoNameMap = new HashMap<>();
            HashMap<String,String> strainMap = new HashMap();
            HashMap<String,String> strainNameMap = new HashMap<>();
            HashMap<String,String> clinMeasMap = new HashMap<>();
            HashMap<String,String> clinMeasNameMap = new HashMap<>();
            HashMap<String,String> cellType = new HashMap();
            HashMap<String,String> cellNameMap = new HashMap<>();
            HashMap<String,String> cellLine = new HashMap();
            HashMap<String,String> ageLow = new HashMap<>();
            HashMap<String,String> ageHigh = new HashMap<>();
            HashMap<String,String> gender = new HashMap<>();
            HashMap<String,String> lifeStage = new HashMap<>();
            HashMap<String,String> notes = new HashMap<>();
            HashMap<String,String> curNotes = new HashMap<>();
            HashMap<String,String> xcoMap = new HashMap<>();
            HashMap<String,String> culture = new HashMap<>();
            HashMap<String,String> cultureUnit = new HashMap<>();
            List<Condition> conditions = new ArrayList<Condition>();
            for(int i = 0; i < tcount;i++){
                if (request.getParameter("tissue" + i).contains("imported!")) {
                    tissueMap.put(null, request.getParameter("tissueId" + i));
                    tissuneNameMap.put(null,request.getParameter("uberon"+i+"_term"));
                    vtMap.put(null,request.getParameter("vtId"+i));
                    vtNameMap.put(null, request.getParameter("vt"+i+"_term"));
                    clinMeasMap.put(null, request.getParameter("clinicalMeasurement"+i));
                    clinMeasNameMap.put(null,request.getParameter("cmo"+i+"_term"));
                }
                else {
                    tissueMap.put(request.getParameter("tissue" + i), request.getParameter("tissueId" + i));
                    tissuneNameMap.put(request.getParameter("tissue" + i),request.getParameter("uberon"+i+"_term"));
                    vtMap.put(request.getParameter("tissue" + i),request.getParameter("vtId"+i));
                    vtNameMap.put(request.getParameter("tissue" + i), request.getParameter("vt"+i+"_term"));
                    clinMeasMap.put(request.getParameter("tissue" + i), request.getParameter("clinicalMeasurement"+i));
                    clinMeasNameMap.put(request.getParameter("tissue" + i),request.getParameter("cmo"+i+"_term"));
                }
            }
            for(int i = 0; i < scount;i++){
                if (request.getParameter("strain" + i).contains("imported!")) {
                    strainMap.put(null, request.getParameter("strainId" + i));
                    strainNameMap.put(null,request.getParameter("rs"+i+"_term"));
                }
                else {
                    strainMap.put(request.getParameter("strain" + i), request.getParameter("strainId" + i));
                    strainNameMap.put(request.getParameter("strain" + i),request.getParameter("rs"+i+"_term"));
                }
            }
            for(int i = 0; i < ageCount;i++){
                ageLow.put(request.getParameter("age" + i),request.getParameter("ageLow"+i));
                ageHigh.put(request.getParameter("age" + i),request.getParameter("ageHigh"+i));
                String[] lifeStages = request.getParameterValues("lifeStage"+i);
                String stage = "";
                if (lifeStages!=null) {
                    for (int j = 0; j < lifeStages.length; j++) {
                        stage += lifeStages[j];
                        if (j != lifeStages.length - 1)
                            stage += ";";
                    }
                }
                lifeStage.put(request.getParameter("age"+i),stage);
            }
            for(int i = 0; i < ctcount;i++){
                if (request.getParameter("cellType"+i).contains("imported!")) {
                    cellType.put(null, request.getParameter("cellTypeId" + i));
                    cellNameMap.put(null,request.getParameter("cl"+i+"_term"));
                    culture.put(null, request.getParameter("cultureDur"+i));
                    cultureUnit.put(null,request.getParameter("cultureUnits"+i));
                }
                else {
                    cellType.put(request.getParameter("cellType" + i), request.getParameter("cellTypeId" + i));
                    cellNameMap.put(request.getParameter("cellType" + i),request.getParameter("cl_term"+i));
                    culture.put(request.getParameter("cellType" + i), request.getParameter("cultureDur"+i));
                    cultureUnit.put(request.getParameter("cellType" + i),request.getParameter("cultureUnits"+i));
                }
            }
            for(int i = 0; i < clcount;i++){
                if (request.getParameter("cellLine" + i).contains("imported!"))
                    cellLine.put(null,request.getParameter("cellLineId"+i));
                else
                    cellLine.put(request.getParameter("cellLine" + i),request.getParameter("cellLineId"+i));
            }
            for(int i = 0; i < gcount;i++){
                gender.put(request.getParameter("gender" + i),request.getParameter("sex"+i));
            }
            for (int i = 0; i < noteCnt ; i++){
                notes.put(null,request.getParameter("notesId"+i));
                curNotes.put(null,request.getParameter("cNotesId"+i));
            }

            HttpRequestFacade req = new HttpRequestFacade(request);
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
            HashMap<String, List<Integer>> ordinality = new HashMap<>(condCnt);
            for (int i = 0; i < condCnt; i++) {
                String xcoId = request.getParameter("xcoId"+i);
                if (!Utils.isStringEmpty(xcoId) && (!Utils.isStringEmpty(cOrdinality[i]) || cOrdinality[i].equals("0")) ) {
                    String xcoTerm = request.getParameter("xco"+i+"_term");
                    xcoMap.put(xcoId, xcoTerm);
                    Condition c = new Condition();
                    c.setOntologyId(xcoId);
                    c.setValueMin(cValueMin[i]);
                    c.setValueMax(cValueMax[i]);
                    c.setUnits(cUnits[i]);
                    if (!Utils.isStringEmpty(cMinDuration[i])) {
                        c.setDurationLowerBound(convertToSeconds(Double.parseDouble(cMinDuration[i]),cMinDurationUnits[i]) );
                    }
                    if (!Utils.isStringEmpty(cMaxDuration[i])) {
                        c.setDurationUpperBound(convertToSeconds(Double.parseDouble(cMaxDuration[i]),cMaxDurationUnits[i]) );
                    }
                    c.setApplicationMethod(cApplicationMethod[i]);

                    c.setOrdinality(Integer.parseInt(cOrdinality[i]));
                    c.setNotes(cNotes[i]);
                    conditions.add(c);
                }

            }

            request.setAttribute("tissueMap",tissueMap);
            request.setAttribute("tissueNameMap", tissuneNameMap);
            request.setAttribute("vtMap",vtMap);
            request.setAttribute("vtNameMap",vtNameMap);
            request.setAttribute("cmoMap",cmoMap);
            request.setAttribute("cmoNameMap",cmoNameMap);
            request.setAttribute("strainMap",strainMap);
            request.setAttribute("strainNameMap",strainNameMap);
            request.setAttribute("clinMeasMap",clinMeasMap);
            request.setAttribute("clinMeasNameMap",clinMeasNameMap);
            request.setAttribute("cellLine",cellLine);
            request.setAttribute("cellType",cellType);
            request.setAttribute("cellNameMap",cellNameMap);
            request.setAttribute("gender",gender);
            request.setAttribute("ageLow",ageLow);
            request.setAttribute("ageHigh",ageHigh);
            request.setAttribute("species",species);
            request.setAttribute("gse",gse);
            request.setAttribute("lifeStage",lifeStage);
            request.setAttribute("notesMap",notes);
            request.setAttribute("curNotesMap",curNotes);
            request.setAttribute("samplesExist", sampleSize);
            request.setAttribute("conditions", conditions);
            request.setAttribute("xcoTerms", xcoMap);
            request.setAttribute("cultureDur", culture);
            request.setAttribute("cultureUnit", cultureUnit);
            return new ModelAndView("/WEB-INF/jsp/curation/expression/createSample.jsp");
        }
        if (request.getParameter("gse") != null) {
            return new ModelAndView("/WEB-INF/jsp/curation/expression/editSample.jsp");
        } else return new ModelAndView("/WEB-INF/jsp/curation/expression/" + "experiments.jsp");

        }
    protected boolean checkToken(String token) throws Exception{
        if(token == null || token.isEmpty()){
            return false;
        }else {
            URL url = new URL("https://api.github.com/user");
            HttpURLConnection conn = (HttpURLConnection)url.openConnection();
            conn.setRequestProperty("User-Agent", "Mozilla/5.0");
            conn.setRequestProperty("Authorization", "Token "+token);

            try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream())) ) {
                String line = in.readLine();
                JSONObject json = new JSONObject(line);
                login = (String)json.get("login");
                if(!login.equals("")){
                    URL checkUrl = new URL("https://api.github.com/orgs/rat-genome-database/members/"+login);
                    HttpURLConnection connection = (HttpURLConnection)checkUrl.openConnection();
                    connection.setRequestProperty("User-Agent", "Mozilla/5.0");
                    connection.setRequestProperty("Authorization", "Token "+token);
                    if(connection.getResponseCode()== 204)
                        return true;
                }
            }
            return false;
        }
    }
    private Double convertToSeconds(Double value, String units) {

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

    private void insertConditions(List<Condition> conds) throws Exception{
        List<String> ords = new ArrayList<>();
        for (int i = conds.size()-1; i >= 0 ; i--){
            // check ordinality
                Condition c = conds.get(i);
                if (c.getOrdinality()==1)
                    break;
                else if (i==0 || c.getOrdinality() <= 0){
                    conds.get(conds.indexOf(c)).setOrdinality(1);
                }
        }
        for (Condition c : conds){
            // insert/update
            if (c.getId()==-1){
                geDAO.insertCondition(c);
            }
            else {
                geDAO.updateCondition(c);
            }
        }
    }

}

