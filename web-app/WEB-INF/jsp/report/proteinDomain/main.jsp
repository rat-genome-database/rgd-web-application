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

    // organize genes per species
    Map<Integer, List<Gene>> geneBuckets = new HashMap<>();
    for( Gene g: genes ) {
        List<Gene> list = geneBuckets.get(g.getSpeciesTypeKey());
        if( list==null ) {
            list = new ArrayList<>();
            geneBuckets.put(g.getSpeciesTypeKey(), list);
        }
        list.add(g);
    }

    // sort gene list by gene symbol
    for( List<Gene> geneList: geneBuckets.values() ) {
        Collections.sort(geneList, new Comparator<Gene>() {
            @Override
            public int compare(Gene o1, Gene o2) {
                return o1.getSymbol().compareToIgnoreCase(o2.getSymbol());
            }
        });
    }

    // print header with species names
    Report report = new Report();
    edu.mcw.rgd.reporting.Record re = new edu.mcw.rgd.reporting.Record();
    Collection<Integer> speciesTypeKeys = SpeciesType.getSpeciesTypeKeys();
    for( int sp: speciesTypeKeys ) {
        if( SpeciesType.isSearchable(sp) && geneBuckets.get(sp)!=null ) {
            re.append(SpeciesType.getCommonName(sp)+" &nbsp; ");
        }
    }
    report.append(re);

    // print genes
    re = new edu.mcw.rgd.reporting.Record();
    for( int sp: speciesTypeKeys ) {
        if( SpeciesType.isSearchable(sp) ) {
            List<Gene> geneList = geneBuckets.get(sp);
            if( geneList==null ) {
                continue;
            }
            String content = "";
            for( Gene g: geneList ) {
                content += "<a href='"+ Link.gene(g.getRgdId())+"'>"+g.getSymbol()+"</a> &nbsp; <br>";
            }
            re.append(content);
        }
    }
    report.append(re);

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