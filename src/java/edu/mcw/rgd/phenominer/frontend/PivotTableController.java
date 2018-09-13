package edu.mcw.rgd.phenominer.frontend;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.pheno.Condition;
import edu.mcw.rgd.datamodel.pheno.Record;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.reporting.DelimitedReportStrategy;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;

/**
 * Created by jdepons on 5/11/2017.
 */
public class PivotTableController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(request);

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        String formatStr=req.getParameter("fmt");
        if (formatStr.equals("")) {
            formatStr="1";
        }

        int format = Integer.parseInt(formatStr);

        int speciesTypeKey;
        String species = req.getParameter("species");
        if( Utils.isStringEmpty(species) ) {
            speciesTypeKey = 3;
        } else {
            speciesTypeKey = Integer.parseInt(species);
        }

        int refRgdId;
        try {
            refRgdId = Integer.parseInt(req.getParameter("refRgdId"));
        } catch (NumberFormatException e) {
            refRgdId = 0;
        }

        StringBuffer idsWithoutMM = new StringBuffer();
        List<Record> records;
        if( refRgdId!=0 ) {
            records = getRecordsByRefRgdId(refRgdId);
        } else {
            records = getRecordsByTerms(req, speciesTypeKey, idsWithoutMM);
        }


        Report report = new Report();
        edu.mcw.rgd.reporting.Record re = new edu.mcw.rgd.reporting.Record();

        if (format > 1) {
            re.append("Study ID");
            re.append("Study");
            re.append("Experiment Name");
            re.append("Experiment Notes");
            re.append("Strain Ont ID");
            re.append("Strain");
            re.append("Sex");
            re.append("Age");
            re.append("# of Animals");
            re.append("Sample Notes");
            re.append("Clinical Measurement Ont ID");
            re.append("Phenotype");
            re.append("Formula");
            re.append("Clinical Measurement Notes");
            re.append("Average Type");
            re.append("Value");
            re.append("Units");
            re.append("SEM");
            re.append("SD");
            re.append("Method Ont ID");
            re.append("Method");
            re.append("Method Site");
            re.append("Method Duration");
            re.append("Method Notes");
            re.append("Post Insult Type");
            re.append("Post Insult Time Value");
            re.append("Post Insult Time Unit");
            re.append("Conditions");
            /*
            re.append("Condition 1 Ont ID");
            re.append("Condition 1 Term");
            re.append("Condition 1 Ordinality");
            re.append("Condition 1 Duration");
            re.append("Condition 1 Value");
            re.append("Condition 1 Units");
            re.append("Condition 1 Notes");
            re.append("Condition 1 Application Method");
            re.append("Condition 2 Ont ID");
            re.append("Condition 2 Term");
            re.append("Condition 2 Ordinality");
            re.append("Condition 2 Duration");
            re.append("Condition 2 Value");
            re.append("Condition 2 Units");
            re.append("Condition 2 Notes");
            re.append("Condition 2 Application Method");
            re.append("Condition 3 Ont ID");
            re.append("Condition 3 Term");
            re.append("Condition 3 Ordinality");
            re.append("Condition 3 Duration");
            re.append("Condition 3 Value");
            re.append("Condition 3 Units");
            re.append("Condition 3 Notes");
            re.append("Condition 3 Application Method");
            */
        }else {
            re.append("# of Animals");
            re.append("Phenotype");
            re.append("Strain");
            re.append("Sex");
            re.append("Value");
            re.append("Units");
            re.append("Conditions");
            //re.append("Condition 2");
            //re.append("Condition 3");

        }

        re.append("Record ID");

        report.append(re);

        HashMap<String, Term> termResolver = new HashMap<String, Term>();
        List<String> termList = new ArrayList<String>();
        HashMap<String,String> measurements = new HashMap<String,String>();
        HashMap<String,String> methods = new HashMap<String,String>();
        HashMap<String,String> samples = new HashMap<String,String>();
        HashMap<String,String> conditions =  new HashMap<String,String>();

        double min = 1000000000;
        double max = -1000000000;

        LinkedHashMap<String,String> ageRanges= new LinkedHashMap<String,String>();

        for (Record r: records) {
            termList.add(r.getSample().getStrainAccId());
            samples.put(r.getSample().getStrainAccId(), null);
            termList.add(r.getClinicalMeasurement().getAccId());
            measurements.put(r.getClinicalMeasurement().getAccId(), null);
            termList.add(r.getMeasurementMethod().getAccId());
            methods.put(r.getMeasurementMethod().getAccId(), null);

            for (Condition c : r.getConditions()) {
                termList.add(c.getOntologyId());
                conditions.put(c.getOntologyId(), null);
            }

            double thisVal = Double.parseDouble(r.getMeasurementValue());

            if (thisVal < min) {
                min = thisVal;
            }

            if (thisVal > max) {
                max = thisVal;
            }

            ageRanges.put(r.getSample().getAgeDaysFromLowBound() + " days - " + r.getSample().getAgeDaysFromHighBound() + " days",null);
        }

        if( !termList.isEmpty() ) {
            String[] termIds = new String[termList.size()];
            termIds = termList.toArray(termIds);

            OntologyXDAO xdao = new OntologyXDAO();
            List<Term> ontTerms = xdao.getTermByAccId(termIds);

            for (Term term : ontTerms) {
                termResolver.put(term.getAccId(), term);
            }
        }

        LinkedHashMap conditionSet = new LinkedHashMap();

        for (Record r: records) {

            re = new edu.mcw.rgd.reporting.Record();

            if (format > 1) {
                re.append(r.getStudyId() + "");
                re.append(r.getStudyName());
                re.append(r.getExperimentName());
                re.append(r.getExperimentNotes());
                re.append(r.getSample().getStrainAccId());
                re.append(termResolver.get(r.getSample().getStrainAccId()).getTerm());
                re.append(r.getSample().getSex());

                int ageDaysHighBound = r.getSample().getAgeDaysFromHighBound()==null ? 0 : r.getSample().getAgeDaysFromHighBound();
                int ageDaysLowBound = r.getSample().getAgeDaysFromLowBound()==null ? 0 : r.getSample().getAgeDaysFromLowBound();
                if( ageDaysHighBound==ageDaysLowBound ) {
                    re.append(ageDaysHighBound + "&nbsp;days");
                }else {
                    re.append(ageDaysHighBound + "&nbsp;days to " + ageDaysLowBound + "&nbsp;days");
                }

                re.append(r.getSample().getNumberOfAnimals() + "");
                re.append(r.getSample().getNotes());
                re.append(r.getClinicalMeasurement().getAccId());
                re.append(termResolver.get(r.getClinicalMeasurement().getAccId()).getTerm());
                re.append(r.getClinicalMeasurement().getFormula());
                re.append(r.getClinicalMeasurement().getNotes());
                re.append(r.getClinicalMeasurement().getAverageType());
                re.append(r.getMeasurementValue());
                re.append(r.getMeasurementUnits());
                re.append(this.round(r.getMeasurementSem(),4));
                re.append(this.round(r.getMeasurementSD(),4));
                re.append(r.getMeasurementMethod().getAccId());
                re.append(termResolver.get(r.getMeasurementMethod().getAccId()).getTerm());
                re.append(r.getMeasurementMethod().getSite());
                re.append(r.getMeasurementMethod().getDuration());
                re.append(r.getMeasurementMethod().getNotes());
                re.append(r.getMeasurementMethod().getPiType());
                re.append(r.getMeasurementMethod().getPiTimeValue() + "");
                re.append(r.getMeasurementMethod().getPiTypeUnit());
                re.append(r.getConditionDescription());

                /*
                for (Condition c : r.getConditions()) {
                    re.append(c.getOntologyId());
                    re.append(termResolver.get(c.getOntologyId()).getTerm());
                    re.append(c.getOrdinality() + "");

                    DecimalFormat df = new DecimalFormat("###.#");

                    if (c.getDurationLowerBound() > 0 || c.getDurationUpperBound() > 0) {
                        if (c.getDurationLowerBound() == c.getDurationUpperBound()) {


                            if ((c.getDurationLowerBound() / 86400) < 1) {
                                re.append(df.format(c.getDurationLowerBound() / 3600) + "&nbsp;hours");

                            } else {
                                re.append(df.format(c.getDurationLowerBound() / 86400) + "&nbsp;days");

                            }
                        } else {
                            if ((c.getDurationLowerBound() / 86400) < 1 || (c.getDurationUpperBound() / 86400) < 1) {
                                re.append(df.format(c.getDurationLowerBound() / 3600) + " to " + df.format(c.getDurationUpperBound() / 3600) + "&nbsp;hours");

                            } else {
                                re.append(df.format(c.getDurationLowerBound() / 86400) + " to " + df.format(c.getDurationUpperBound() / 86400) + "&nbsp;days");
                            }
                        }
                    }else {
                        re.append("");
                    }

                    re.append(c.getValue());
                    re.append(c.getUnits());
                    re.append(c.getNotes());
                    re.append(c.getApplicationMethod());
                }

                for ( int i=0; i< (3 - r.getConditions().size()); i++) {
                    re.append("&nbsp;");
                    re.append("&nbsp;");
                    re.append("&nbsp;");
                    re.append("&nbsp;");
                    re.append("&nbsp;");
                    re.append("&nbsp;");
                    re.append("&nbsp;");
                    re.append("&nbsp;");
                }
                */
                re.append(r.getId() + "");

            }else {
                re.append(r.getSample().getNumberOfAnimals() + "");

                re.append(termResolver.get(r.getClinicalMeasurement().getAccId()).getTerm());
                re.append(termResolver.get(r.getSample().getStrainAccId()).getTerm());
                re.append(r.getSample().getSex());
                re.append(r.getMeasurementValue());
                re.append(r.getMeasurementUnits());

                /*
                for (Condition c : r.getConditions()) {
                    re.append(termResolver.get(c.getOntologyId()).getTerm());
                }

                for ( int i=0; i< (3 - r.getConditions().size()); i++) {
                    re.append("&nbsp;");
                }
                */
                re.append(r.getConditionDescription());
                re.append(r.getId() + "");

            }

            report.append(re);
        }

        if (format == 3) {
            response.setContentType("application/csv");
            response.setHeader("Content-Disposition","filename=phenominer.csv");
            DelimitedReportStrategy drs = new DelimitedReportStrategy();
            drs.setDelimiter(",");
            response.getWriter().print(drs.format(report));
            return null;
        }

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);
        request.setAttribute("report",report);
        request.setAttribute("termResolver", termResolver);
        request.setAttribute("methods", methods);
        request.setAttribute("conditions", conditions);
        request.setAttribute("samples",samples);
        request.setAttribute("measurements", measurements);
        request.setAttribute("ageRanges", ageRanges);
        request.setAttribute("minValue",min);
        request.setAttribute("maxValue",max);
        request.setAttribute("conditionSet", conditionSet);

        request.setAttribute("idsWithoutMM",idsWithoutMM.toString());

        return new ModelAndView("/WEB-INF/jsp/phenominer/table.jsp", "", null);
    }

    List<Record> getRecordsByTerms(HttpRequestFacade req, int speciesTypeKey, StringBuffer idsWithoutMM) throws Exception {
        List<String> sampleIds = new ArrayList<String>();
        List mmIds = new ArrayList<String>();
        List cmIds = new ArrayList<String>();
        List ecIds = new ArrayList<String>();

        String termString = req.getParameter("terms");

        String[] terms = termString.split(",");

        for (int j=0; j< terms.length; j++) {
            String[] termParts = terms[j].split(":");

            while (termParts[1].length()<7) {
                termParts[1]="0" + termParts[1];
            }

            terms[j] = termParts[0] + ":" + termParts[1];
        }

        int count=0;

        for( String term: terms ) {
            if (term.startsWith("RS") || term.startsWith("CS")) {
                sampleIds.add(term);
            } else if (term.startsWith("CMO")) {
                cmIds.add(term);
            } else if (term.startsWith("MMO")) {
                mmIds.add(term);
            } else if (term.startsWith("XCO")) {
                ecIds.add(term);
            }


            if (!term.startsWith("CMO")) {
                if (count == 0) {
                    idsWithoutMM.append(term);
                } else {
                    idsWithoutMM.append(",").append(term);
                }
                count++;
            }
        }

        PhenominerDAO pdao = new PhenominerDAO();
        List<Record> records = pdao.getFullRecords(sampleIds,mmIds,cmIds,ecIds, speciesTypeKey);
        return records;
    }

    List<Record> getRecordsByRefRgdId(int refRgdId) throws Exception {
        PhenominerDAO pdao = new PhenominerDAO();
        return pdao.getFullRecords(refRgdId);
    }

    public double round(double value, int numberOfDigitsAfterDecimalPoint) {
        BigDecimal bigDecimal = new BigDecimal(value);
        bigDecimal = bigDecimal.setScale(numberOfDigitsAfterDecimalPoint,
                BigDecimal.ROUND_HALF_UP);
        return bigDecimal.doubleValue();
    }

    public String round(String value, int numberOfDigitsAfterDecimalPoint) {
        if (value == null || value.equals("")) {
            return "";
        }

        BigDecimal bigDecimal = new BigDecimal(value);
        bigDecimal = bigDecimal.setScale(numberOfDigitsAfterDecimalPoint,
                BigDecimal.ROUND_HALF_UP);
        return bigDecimal.doubleValue() + "";
    }

}
