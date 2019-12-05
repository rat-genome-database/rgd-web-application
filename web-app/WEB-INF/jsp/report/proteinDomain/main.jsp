<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Map" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../dao.jsp"%>

<%
    String title = "Protein Domains";
    GenomicElement obj = (GenomicElement) request.getAttribute("reportObject");
    String objectType="proteinDomain";
    String displayName=obj.getSymbol();

    List<Gene> genes = geneDAO.getGenesForProteinDomain(obj.getRgdId());

    // organize genes per lower-case gene symbol: for that symbol an array with genes with all species is provided;
    //  in that array, species type key is an array index
    List emptyListOfTenElements = new ArrayList<>(10);
    for( int i=0; i<10; i++ ) {
        emptyListOfTenElements.add(null);
    }

    // species 
    Map<String, List<Gene>> geneSymbolsMap = new TreeMap<>();
    for( Gene g: genes ) {
        String geneSymbolLC = g.getSymbol().toLowerCase();
        List<Gene> bucket = geneSymbolsMap.get(geneSymbolLC);
        if( bucket==null ) {
            bucket = new ArrayList<>();
            bucket.addAll(emptyListOfTenElements);
            geneSymbolsMap.put(geneSymbolLC, bucket);
        }
        bucket.set(g.getSpeciesTypeKey(), g);
    }

    // print header with species names
    Report report = new Report();
    edu.mcw.rgd.reporting.Record re = new edu.mcw.rgd.reporting.Record();
    Collection<Integer> speciesTypeKeys = SpeciesType.getSpeciesTypeKeys();
    for( int sp: speciesTypeKeys ) {
        if( SpeciesType.isSearchable(sp) ) {
            re.append(SpeciesType.getCommonName(sp)+" &nbsp; ");
        }
    }
    report.append(re);


    // print genes
    for( List<Gene> bucket: geneSymbolsMap.values() ) {
        re = new edu.mcw.rgd.reporting.Record();
        for( int sp: speciesTypeKeys ) {
            if( SpeciesType.isSearchable(sp) ) {
                Gene g = bucket.size()>sp ? bucket.get(sp) : null;
                if( g!=null ) {
                    re.append("<a href='" + Link.gene(g.getRgdId()) + "'>" + g.getSymbol() + "</a>");
                } else {
                    re.append("");
                }
            }
        }
        report.append(re);
    }

    String description = displayName;
    String pageTitle = obj.getSymbol() + " (" + obj.getName() + ") - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = description;
%>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>

<script type="application/ld+json">
{
"@context": "http://schema.org",
"@type": "Dataset",
"name": "<%=obj.getSymbol()%>",
"description": "<%=pageDescription%>",
"url": "https://rgd.mcw.edu/rgdweb/report/proteinDomain/main.html?id=<%=obj.getRgdId()%>",
"keywords": "Rat Gene RGD Genome",
"includedInDataCatalog": "https://rgd.mcw.edu",
"creator": {
"@type": "Organization",
"name": "Rat Genome Database"
},
"version": "1",
"license": "Creative Commons CC BY 4.0"
}
</script>


<%
    String pageHeader="Protein Domain: " + obj.getSymbol();

%>
<table width="95%" style="padding-top:10px;" border="0">
    <tr>
        <td style="font-size:20px; color:#2865A3; font-weight:700;"><%=pageHeader%></td>
    </tr>
</table>

<p>
<table width="95%" border="0">
    <tr>
        <td>
            <script type="text/javascript" src="https://www.kryogenix.org/code/browser/sorttable/sorttable.js"></script>
            <%
                HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
                strat.setTableProperties(" class='sortable' ");
                String[] tdProps = {"valign='top'","valign='top'","valign='top'","valign='top'","valign='top'","valign='top'","valign='top'","valign='top'"};
                strat.setTdProperties(tdProps);
                out.print(strat.format(report));
            %>
        </td>
        <td>&nbsp;</td>
        <td valign="top">
            <%@ include file="../idInfo.jsp" %>
        </td>
    </tr>
</table>

<%@ include file="../reportFooter.jsp"%>
<%@ include file="/common/footerarea.jsp"%>