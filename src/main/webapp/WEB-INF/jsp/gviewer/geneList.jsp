<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %>
<%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %>
<%@ page import="edu.mcw.rgd.reporting.Record" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.AnnotationDAO" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="edu.mcw.rgd.web.*" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.TermWrapper" %>


<%
    String pageTitle = "Gviewer";
    String headContent = "";
    String pageDescription = "Generate an annotation report for a list of genes.";

    //initializations
    HttpRequestFacade req = new HttpRequestFacade(request);
    edu.mcw.rgd.web.DisplayMapper dm = new DisplayMapper(req,  new java.util.ArrayList());
    FormUtility fu = new FormUtility();
    UI ui=new UI();
    AnnotationDAO adao = new AnnotationDAO();
    GeneDAO gdao = new GeneDAO();

    ObjectMapper om = (ObjectMapper) request.getAttribute("objectMapper");
    List termSet= Utils.symbolSplit(req.getParameter("terms"));
    List<TermWrapper> termWrappers = new ArrayList<TermWrapper>();

    String method="get";

    if (Utils.symbolSplit(req.getParameter("genes")).size() > 250) {
        method="post";
    }

%>
<%@ include file="../../../common/headerarea.jsp" %>

<% try { %>

<%

    List chromosomes = new ArrayList();
    chromosomes.add("1");
    chromosomes.add("2");
    chromosomes.add("3");
    chromosomes.add("4");
    chromosomes.add("5");
    chromosomes.add("6");
    chromosomes.add("7");
    chromosomes.add("8");
    chromosomes.add("9");
    chromosomes.add("10");
    chromosomes.add("11");
    chromosomes.add("12");
    chromosomes.add("13");
    chromosomes.add("14");
    chromosomes.add("15");
    chromosomes.add("16");
    chromosomes.add("17");
    chromosomes.add("18");
    chromosomes.add("19");
    chromosomes.add("20");
    chromosomes.add("21");
    chromosomes.add("22");
    chromosomes.add("X");
    chromosomes.add("Y");


    MapDAO mdao = new MapDAO();

    List<Map> chinMaps = null;

    List<Map> ratMaps= mdao.getMaps(SpeciesType.RAT, "bp");
    List<Map> mouseMaps= mdao.getMaps(SpeciesType.MOUSE, "bp");
    List<Map> humanMaps= mdao.getMaps(SpeciesType.HUMAN, "bp");

    LinkedHashMap chinKeyValues= new LinkedHashMap();
    LinkedHashMap ratKeyValues= new LinkedHashMap();
    LinkedHashMap humanKeyValues= new LinkedHashMap();
    LinkedHashMap mouseKeyValues= new LinkedHashMap();

    Iterator it = ratMaps.iterator();
    while (it.hasNext()) {
        Map m = (Map)it.next();
        ratKeyValues.put(m.getKey() + "", m.getName());
    }

    if (RgdContext.isChinchilla(request)) {
        chinMaps = mdao.getMaps(SpeciesType.CHINCHILLA, "bp");
        it = chinMaps.iterator();
        while (it.hasNext()) {
            Map m = (Map)it.next();
            chinKeyValues.put(m.getKey() + "", m.getName());
        }
    } else {
        it = mouseMaps.iterator();
        while (it.hasNext()) {
            Map m = (Map)it.next();
            mouseKeyValues.put(m.getKey() + "", m.getName());
        }
        it = humanMaps.iterator();
        while (it.hasNext()) {
            Map m = (Map)it.next();
            humanKeyValues.put(m.getKey() + "", m.getName());
        }
    }
%>


<script>

    <% if (RgdContext.isChinchilla(request)) {   %>
        var chinMapHtml = '<%=fu.buildSelectList("mapKey", chinKeyValues, mdao.getPrimaryRefAssembly(4).getKey() + "")%>';
    <% } else { %>
    var ratMapHtml = '<%=fu.buildSelectList("mapKey", ratKeyValues, mdao.getPrimaryRefAssembly(3).getKey() + "")%>';
    var mouseMapHtml='<%=fu.buildSelectList("mapKey", mouseKeyValues, mdao.getPrimaryRefAssembly(2).getKey() + "")%>';
    <% } %>
    var humanMapHtml='<%=fu.buildSelectList("mapKey", humanKeyValues, mdao.getPrimaryRefAssembly(1).getKey() + "")%>';

     function setMap(obj) {
        var selected = obj.options[obj.selectedIndex].value;

        var maps=document.getElementById("maps");

        if (selected==1) {
            maps.innerHTML=humanMapHtml;
        }else if (selected==2) {
            maps.innerHTML=mouseMapHtml;
        }else if (selected==3) {
            maps.innerHTML=ratMapHtml;
        }else if (selected==4) {
            maps.innerHTML=chinMapHtml;
        }else {
            maps.innerHTML=ratMapHtml;
        }

        if( selected==4 ) {
            $("#gaPos").hide();
        } else {
            $("#gaPos").show();
        }
    }
</script>

<%
    String tutorialLink="http://rgd.mcw.edu/wg/home/rgd_rat_community_videos/gene-annotator-tutorial";
    String pageHeader="GViewer";
%>
<%@ include file="/common/title.jsp" %>
<br>


<div style="padding-bottom: 10px; padding-top:10px; padding-left:10px; padding-right:10px;  background-image: url(/rgdweb/common/images/bg3.png)">


<form action="/rgdweb/gviewer/genome.html" method="get">
<input type="hidden" name="mapKey" value="<%=request.getParameter("mapKey")%>" />
<table border=0>
    <tr><td>&nbsp;</td></tr>
    <tr>
        <td valign="top" style="color:white;">
            When entering multiple identifiers<br> your list can be separated by commas,<br>spaces, tabs, or line feeds
            <br><br>

            <table style="border: 1px solid #e6e6e6; ">
                <tr>
                    <td colspan=3 style="font-weight:700;color:white;">Valid identifier types:</td>
                </tr>
                <tr>
                    <td style="font-size:11px;color:white;">Affymetrix</td>
                    <td style="font-size:11px;color:white;">GenBank Nucleotide</td>
                    <td style="font-size:11px;color:white;">Ontology Term ID</td>
                </tr>
                <tr>
                    <td style="font-size:11px;color:white;">Ensembl Gene</td>
                    <td style="font-size:11px;color:white;">GenBank Protein</td>
                    <td style="font-size:11px;color:white;">RGD ID</td>
                </tr>
                <tr>
                    <td style="font-size:11px;color:white;">Ensembl Protein</td>
                    <td style="font-size:11px;color:white;">Gene Symbol</td>
                    <td style="font-size:11px;color:white;">dbSNP ID</td>
                </tr>
                <tr>
                    <td style="font-size:11px;color:white;">EntrezGene ID</td>
                    <td style="font-size:11px;color:white;">Kegg Pathway</td>
                </tr>
             </table>
        </td>
        <td style="padding-left:30px;">
            <textarea name="genes" rows="12" cols=70 ><%=dm.out("genes",req.getParameter("genes"))%></textarea>
        </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
        <td colspan=2 align="right"><input style="font-size:20px;" type="submit" value="Continue >>"/></td>
    </tr>
</table>

</div>

<script>
    setMap(document.getElementById("species"));
</script>

   <% } catch (Exception e) {
        e.printStackTrace();
     } %>

<%@ include file="../../../common/footerarea.jsp" %>

