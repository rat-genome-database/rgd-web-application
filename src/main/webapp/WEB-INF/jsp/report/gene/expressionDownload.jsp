<%@ page import="edu.mcw.rgd.dao.impl.GeneExpressionDAO" %><%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %><%@ page import="edu.mcw.rgd.datamodel.GeneExpression" %><%@ page import="java.util.List" %><%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %><%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %><%@ page import="edu.mcw.rgd.datamodel.Map" %><%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %><%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %><%@ page import="edu.mcw.rgd.process.Utils" %><%@ page import="edu.mcw.rgd.datamodel.pheno.*" %><%
    response.setHeader("Content-disposition","attachment;filename=\"gene_expression_data.csv\"");
    int rgdId = (int) request.getAttribute("rgdId");
    String termAcc = (String) request.getAttribute("termAcc");
    GeneExpressionDAO gdao = new GeneExpressionDAO();
    PhenominerDAO pdao = new PhenominerDAO();
    MapDAO mdao = new MapDAO();
    OntologyXDAO xdao = new OntologyXDAO();
    List<GeneExpression> expressionList = gdao.getGeneExpressionObjectsByTermRgdIdUnit(termAcc, rgdId, "TPM");
    out.print("Strain");
    out.print(",");
    out.print("Sex");
    out.print(",");
    out.print("Age");
    out.print(",");
    out.print("Tissue");
    out.print(",");
    out.print("Geo Sample ID");
    out.print(",");
    out.print("Value");
    out.print(",");
    out.print("Unit");
    out.print(",");
    out.print("Assembly");
    out.print(",");
    out.println("Reference");
    for (GeneExpression ge : expressionList){

        GeneExpressionRecordValue v = ge.getGeneExpressionRecordValue();
        GeneExpressionRecord r = ge.getGeneExpressionRecord();
        Sample s = ge.getSample();

        Map asm = mdao.getMap(v.getMapKey());
        Term strain = null;
        if ( !Utils.isStringEmpty(s.getStrainAccId()) )
            strain = xdao.getTermByAccId(s.getStrainAccId());

        Term annat = null;
        if(!Utils.isStringEmpty(s.getTissueAccId()))
            annat = xdao.getTermByAccId(s.getTissueAccId());

        String age = "";
            if (s.getAgeDaysFromLowBound() == 0 && s.getAgeDaysFromHighBound() == 0)
                age = "not available";
            else {
                if (s.getAgeDaysFromHighBound() < 0 || s.getAgeDaysFromLowBound() < 0) {
                    if (r.getSpeciesTypeKey() == SpeciesType.HUMAN) {
                        String ageLow = String.valueOf(s.getAgeDaysFromLowBound() + 280);
                        String ageHigh = String.valueOf(s.getAgeDaysFromHighBound() + 280);
                        if (ageLow.equalsIgnoreCase(ageHigh))
                            age = ageLow + " days post conception";
                        else {
                            age = ageLow + " - " + ageHigh;
                            age += " days post conception";
                        }
                    } else {
                        String ageLow = String.valueOf(s.getAgeDaysFromLowBound() + 22);
                        String ageHigh = String.valueOf(s.getAgeDaysFromHighBound() + 22);
                        if (ageLow.equalsIgnoreCase(ageHigh))
                            age = ageLow + " embryonic days";
                        else {
                            age = ageLow + " - " + ageHigh;
                            age += " embryonic days";
                        }
                    }
                } else {
                    if (s.getAgeDaysFromLowBound().compareTo(s.getAgeDaysFromHighBound()) == 0) {
                        age = s.getAgeDaysFromLowBound() + " days";
                    } else {
                        age = s.getAgeDaysFromLowBound() + " - " + s.getAgeDaysFromHighBound() + " days";
                    }
                }
            }

        Experiment exp = pdao.getExperiment(r.getExperimentId());
        Study study = pdao.getStudy(exp.getStudyId());

        out.print(strain != null ? strain.getTerm()+"|"+strain.getAccId() : "No Strain Available");
        out.print(",");
        out.print(s.getSex());
        out.print(",");
        out.print(age);
        out.print(",");
        out.print(annat!=null ? annat.getTerm() +"|"+annat.getAccId() : "No Tissue Available");
        out.print(",");
        out.print(!Utils.isStringEmpty(s.getGeoSampleAcc()) ? s.getGeoSampleAcc() : "No Geo Sample Id");
        out.print(",");
        out.print(v.getTpmValue());
        out.print(",");
        out.print("TPM");
        out.print(",");
        out.print(asm.getName());
        out.print(",");
        out.println("https://rgd.mcw.edu//rgdweb/report/reference/main.html?id="+study.getRefRgdId());
    }
%>
