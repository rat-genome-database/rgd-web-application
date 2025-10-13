<%@ page import="edu.mcw.rgd.datamodel.GeneExpression" %><%@ page import="java.util.List" %><%@ page import="edu.mcw.rgd.datamodel.Map" %><%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %><%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %><%@ page import="edu.mcw.rgd.process.Utils" %><%@ page import="edu.mcw.rgd.datamodel.pheno.*" %><%@ page import="edu.mcw.rgd.datamodel.RgdId" %><%@ page import="edu.mcw.rgd.dao.impl.*" %><%@ page import="java.util.HashMap" %><%
    String geneSymbol = request.getAttribute("geneSymbol") != null ? request.getAttribute("geneSymbol").toString() : "unknown";
    response.setHeader("Content-disposition","attachment;filename=\""+geneSymbol+"_expression_data.csv\"");
    RGDManagementDAO rdao = new RGDManagementDAO();
    int rgdId = (int) request.getAttribute("rgdId");
    RgdId geneId = rdao.getRgdId2(rgdId);
    String termAcc = (String) request.getAttribute("termAcc");
    GeneExpressionDAO gdao = new GeneExpressionDAO();
    PhenominerDAO pdao = new PhenominerDAO();
    MapDAO mdao = new MapDAO();
    OntologyXDAO xdao = new OntologyXDAO();
    List<GeneExpression> expressionList = gdao.getGeneExpressionObjectsByTermRgdIdUnit(termAcc, rgdId, "TPM");
    HashMap<String, String> tissueTerms = new HashMap<>();
    if (geneId.getSpeciesTypeKey()==1)
        out.print("Cell Line");
    else
        out.print("Strain");
    out.print(",");
    out.print("Sex");
    out.print(",");
    out.print("Computed Sex");
    out.print(",");
    out.print("Age");
    out.print(",");
    out.print("Tissue");
    out.print(",");
    out.print("Geo Sample ID");
    out.print(",");
    out.print("Value");
    out.print(",");
    out.print("Expression Level");
    out.print(",");
    out.print("Unit");
    out.print(",");
    out.print("Assembly");
    out.print(",");
    out.print("Reference");
    out.print(",");
    out.println("GEO Study");
    for (GeneExpression ge : expressionList){

        GeneExpressionRecordValue v = ge.getGeneExpressionRecordValue();
        GeneExpressionRecord r = ge.getGeneExpressionRecord();
        Sample s = ge.getSample();
        List<Integer> refs = pdao.getStudyReferences(ge.getStudyId());
        Map asm = mdao.getMap(v.getMapKey());
        Term strain = null;
        if ( !Utils.isStringEmpty(s.getStrainAccId()) )
            strain = xdao.getTermByAccId(s.getStrainAccId());

        Term annat = null;
        String tissueTermAcc = s.getTissueAccId();
        tissueTerms.put(null, "No Tissue Available");
        tissueTerms.put("", "No Tissue Available");
        if(!Utils.isStringEmpty(s.getTissueAccId())) {
            if (tissueTerms.get(s.getTissueAccId())==null){
                annat = xdao.getTermByAccId(s.getTissueAccId());
//                System.out.println(annat.getAccId());
                if (annat==null)
                    tissueTermAcc = null;
                else {
//                    System.out.println(annat.getAccId()+"|"+annat.getTerm());
                    tissueTermAcc = annat.getAccId();
                    tissueTerms.put(annat.getAccId(), annat.getTerm());
                }
            }
        }

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

        out.print(strain != null ? strain.getTerm()+"|"+strain.getAccId() : "No Strain Available");
        out.print(",");
        out.print(s.getSex());
        out.print(",");
        out.print(Utils.isStringEmpty(s.getComputedSex()) ? "N/A" : s.getComputedSex());
        out.print(",");
        out.print(age);
        out.print(",");
        out.print(tissueTerms.get(tissueTermAcc));
        out.print(",");
        out.print(!Utils.isStringEmpty(s.getGeoSampleAcc()) ? s.getGeoSampleAcc() : "No Geo Sample Id");
        out.print(",");
        out.print(v.getTpmValue());
        out.print(",");
        out.print("TPM");
        out.print(",");
        out.print(ge.getGeneExpressionRecordValue().getExpressionLevel());
        out.print(",");
        out.print(asm.getName());
        out.print(",");
        StringBuilder refBuilder = new StringBuilder();
        for (int i = 0; i < refs.size(); i++){
            int ref = refs.get(i);
            if (i == refs.size()-1)
                refBuilder.append("RGD:").append(ref);
            else
                refBuilder.append("RGD:").append(ref).append("|");
        }
        if (Utils.isStringEmpty(refBuilder.toString()) )
            out.print("N/A");
        else
            out.print(refBuilder.toString());
        out.print(",");
        out.println(Utils.isStringEmpty(ge.getGeoSeriesAcc()) ? "N/A" : ge.getGeoSeriesAcc());
    }
%>
