<%@ page import="edu.mcw.rgd.datamodel.GWASCatalog" %><%@ page import="java.util.List" %><%@ page import="edu.mcw.rgd.process.Utils" %><%@ page import="edu.mcw.rgd.dao.impl.GWASCatalogDAO" %><%@ page contentType="text/csv;charset=UTF-8" language="java" %><%
    response.setHeader("Content-disposition","attachment;filename=\"related_gwas_data.csv\"");
    GWASCatalogDAO gdao = new GWASCatalogDAO();
    String rsId = (String) request.getAttribute("rsId");
    Integer species = (Integer) request.getAttribute("species");
    List<GWASCatalog> gwas = gdao.getGWASListByRsId(rsId);
    if (species==1) {
        out.print("QTL RGD ID");
        out.print(",");
        out.print("GWAS Catalog Study Id");
        out.print(",");
        out.print("Disease Trait");
        out.print(",");
        out.print("Study Size");
        out.print(",");
        out.print("Risk Allele");
        out.print(",");
        out.print("Risk Allele Frequency");
        out.print(",");
        out.print("P Value");
        out.print(",");
        out.print("P Value MLOG");
        out.print(",");
        out.print("Peak Marker");
        out.print(",");
        out.print("Reported Odds Ratio or Beta Coefficient");
        out.print(",");
        out.print("Ontology Terms");
        out.print(",");
        out.println("PubMed");

        for (GWASCatalog g : gwas) {
            out.print(g.getQtlRgdId());
            out.print(",");
            out.print(g.getStudyAcc());
            out.print(",");
            out.print(g.getDiseaseTrait().replace(",", "|"));
            out.print(",");
            String sampleSize = g.getInitialSample().replace(",", "");
            out.print(sampleSize);
            out.print(",");
            out.print(Utils.NVL(g.getStrongSnpRiskallele(), "N/A"));
            out.print(",");
            out.print(g.getRiskAlleleFreq());
            out.print(",");
            out.print(g.getpVal());
            out.print(",");
            out.print(g.getpValMlog());
            out.print(",");
            out.print(g.getSnps().replace(",", "|"));
            out.print(",");
            out.print(Utils.NVL(g.getOrBeta(), "N/A"));
            out.print(",");
            String efoIds = g.getEfoId().replace("_", ":");
            efoIds = efoIds.replace(",", "|");
            out.print(efoIds);
            out.print(",");
            out.println(g.getPmid().replace(",", "|"));
        }
    }
    else {
        out.print("QTL RGD ID");
        out.print(",");
        out.print("Mapped Trait");
        out.print(",");
        out.print("Trait Detail");
        out.print(",");
        out.print("Risk Allele");
        out.print(",");
        out.print("P Value");
        out.print(",");
        out.print("Peak Marker");
        out.print(",");
        out.print("Reported Odds Ratio or Beta Coefficient");
        out.print(",");
        out.println("Ontology Terms");

        for (GWASCatalog g : gwas) {
            out.print(g.getQtlRgdId());
            out.print(",");
            out.print(g.getMapTrait().replace(",", "|"));
            out.print(",");
            out.print(Utils.NVL(g.getContext(), "N/A"));
            out.print(",");
            out.print(Utils.NVL(g.getStrongSnpRiskallele(), "N/A"));
            out.print(",");
            out.print(g.getpVal());
            out.print(",");
            out.print(g.getSnps().replace(",", "|"));
            out.print(",");
            out.print(Utils.NVL(g.getOrBeta(), "N/A"));
            out.print(",");
            String ontIds = g.getEfoId().replace("_", ":");
            ontIds = ontIds.replace(",", "|");
            out.println(ontIds);
        }
    }
%>
