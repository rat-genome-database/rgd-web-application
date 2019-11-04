package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.MiRnaTarget;
import edu.mcw.rgd.datamodel.pheno.Experiment;
import edu.mcw.rgd.datamodel.pheno.GeneExpressionRecord;
import edu.mcw.rgd.datamodel.pheno.GeneExpressionRecordValue;
import edu.mcw.rgd.datamodel.pheno.Study;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: hsnalabolu
 * <p>
 * to download list of tpm values data for a given gene
 */
public class ExpressionDataController implements Controller {

    GeneExpressionDAO geneExpressionDAO = new GeneExpressionDAO();
    PhenominerDAO phenominerDAO = new PhenominerDAO();
    OntologyXDAO xdao = new OntologyXDAO();

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        int rgdId = Integer.parseInt(Utils.NVL(request.getParameter("id"), "0"));
        String fmt = Utils.NVL(request.getParameter("fmt"), "full"); // one of 'full','csv','tab','print'
        String level = request.getParameter("level");
        String tissueId = request.getParameter("tissue");

        GeneDAO geneDAO = new GeneDAO();
        Gene obj;
        try {
            obj = geneDAO.getGene(rgdId);
        } catch(GeneDAO.GeneDAOException e) {
            obj = new Gene();
            obj.setSymbol("");
        }
        request.setAttribute("geneSymbol", obj.getSymbol());
        request.setAttribute("geneId",obj.getRgdId());
        request.setAttribute("level",level);
        request.setAttribute("tissueId",tissueId);
        Report report = getExpressionData(obj, fmt.equals("full"), request);
        request.setAttribute("report", report);
        return new ModelAndView("/WEB-INF/jsp/report/gene/expressionData_"+fmt+".jsp");
    }

    Report getExpressionData(Gene obj, boolean generateGeneLinks, HttpServletRequest request) throws Exception {

        String level = request.getParameter("level");
        String tissueId = request.getParameter("tissue");
        List<GeneExpressionRecordValue> geneExpressionRecordValues;
        if(level.equals("") || tissueId.equals("")) {
            geneExpressionRecordValues = geneExpressionDAO.getGeneExprRecordValuesForGene(obj.getRgdId(),"TPM");
        }
        else geneExpressionRecordValues = geneExpressionDAO.getGeneExprRecordValuesForGeneByTissue(obj.getRgdId(),"TPM",level,tissueId);
        HashMap<Integer,GeneExpressionRecord> geneExprRecMap = new HashMap<>();
        HashMap<Integer,Experiment> experimentMap = new HashMap<>();
        HashMap<Integer, edu.mcw.rgd.datamodel.pheno.Sample> sampleMap = new HashMap<>();
        HashMap<Integer,Study> studyMap = new HashMap<>();

        Report report = new Report();
        Record recHeader = new Record();
        recHeader.append("Strain");
        recHeader.append("Sex");
        recHeader.append("Age");
        recHeader.append("Value");
        recHeader.append("Unit");
        recHeader.append("Assembly");
        recHeader.append("Reference");
        report.append(recHeader);


        for (GeneExpressionRecordValue rec : geneExpressionRecordValues) {
            GeneExpressionRecord geneExpRec;
            Experiment e;
            edu.mcw.rgd.datamodel.pheno.Sample s;
            Study study;
            if (geneExprRecMap.isEmpty() || !geneExprRecMap.keySet().contains(rec.getGeneExpressionRecordId())) {
                geneExpRec = geneExpressionDAO.getGeneExpressionRecordById(rec.getGeneExpressionRecordId());
                geneExprRecMap.put(rec.getGeneExpressionRecordId(), geneExpRec);
            } else geneExpRec = geneExprRecMap.get(rec.getGeneExpressionRecordId());

            if (experimentMap.isEmpty() || !experimentMap.keySet().contains(geneExpRec.getExperimentId())) {
                e = phenominerDAO.getExperiment(geneExpRec.getExperimentId());
                study = phenominerDAO.getStudy(e.getStudyId());
                experimentMap.put(e.getId(), e);
                studyMap.put(e.getStudyId(), study);
            } else {
                e = experimentMap.get(geneExpRec.getExperimentId());
                study = studyMap.get(e.getStudyId());
            }

            if (sampleMap.isEmpty() || !sampleMap.keySet().contains(geneExpRec.getSampleId())) {
                s = phenominerDAO.getSample(geneExpRec.getSampleId());
                sampleMap.put(s.getId(), s);

            } else s = sampleMap.get(geneExpRec.getSampleId());


                Record record = new Record();

                String age;
                if(s.getAgeDaysFromHighBound() < 0 || s.getAgeDaysFromLowBound() < 0) {
                    String ageLow = String.valueOf(s.getAgeDaysFromLowBound() + 21);
                    String ageHigh = String.valueOf(s.getAgeDaysFromHighBound() + 23);
                    if(ageLow.equalsIgnoreCase(ageLow))
                        age= ageLow + " embryonic days";
                    else {
                        age=ageLow + " - " + ageHigh;
                        age+= " embryonic days";
                    }
                }
                else { if(s.getAgeDaysFromLowBound().compareTo(s.getAgeDaysFromHighBound()) == 0 )
                    age = s.getAgeDaysFromLowBound() + " days";
                else age = String.valueOf(s.getAgeDaysFromLowBound()) + " - " + String.valueOf(s.getAgeDaysFromHighBound()) + " days";
                }

                record.append(xdao.getTerm(s.getStrainAccId()).getTerm());
                record.append(s.getSex());
                record.append(age);
                record.append(rec.getExpressionValue().toString());
                record.append("TPM");
                record.append(MapManager.getInstance().getMap(rec.getMapKey()).getName());
                record.append("<a href="+Link.ref(study.getRefRgdId())+">"+study.getRefRgdId()+"</a>");
                report.append(record);




        }


        return report;
    }
}
