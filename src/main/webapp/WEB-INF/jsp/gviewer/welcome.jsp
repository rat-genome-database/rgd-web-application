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
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>

    <%
        String pageTitle = "Web Genome Viewer - Rat Genome Database";
        String headContent = "";
        String pageDescription = "Gviewer provides users with complete genome view of gene and QTL annotated to a function, biological process, cellular component, phenotype, disease, or pathway. The tool will search for matching terms from the Gene Ontology, Mammalian Phenotype Ontology, Disease Ontology or Pathway Ontology.";

    %>


<%@ include file="/common/headerarea.jsp" %>

<%
    ObjectMapper om = (ObjectMapper) request.getAttribute("objectMapper");
    AnnotationDAO adao = new AnnotationDAO();
    GeneDAO gdao = new GeneDAO();
    HttpRequestFacade req = new HttpRequestFacade(request);


    int mapKey=(Integer) request.getAttribute("mapKey");

%>

<form>


<%
    String tutorialLink="http://rgd.mcw.edu/wg/home/rgd_rat_community_videos/gene-annotator-tutorial";
    String pageHeader="GViewer";
%>
<%@ include file="/common/title.jsp" %>
<br>


<div style="border-top-right-radius:30px; background-image: url(/rgdweb/common/images/bg3.png)">

<table width="95%" style="padding-top:30px;">
    <tr>
        <td ></td>
        <td align="right">
            <select id="mapKey" name="mapKey" onChange='location.href="?mapKey=" + this.options[this.selectedIndex].value'>
            <option value='17' <% if (mapKey==17) out.print("selected");%>>Human Genome Assebmly GRCh37</option>
            <option value='70' <% if (mapKey==70) out.print("selected");%>>RGSC Genome Assembly v5.0</option>
            <option value='60' <% if (mapKey==60) out.print("selected");%>>RGSC Genome Assembly v3.4</option>
            </select>

        </td>
    </tr>
</table>

<table border=0 align="center" style="padding-top:40px; padding-bottom:80px;" >
    <tr>
        <td style="padding:5px;" >
           <input value ="Enter a Gene Symbol List" type="button" onClick="this.form.action='geneList.html';this.form.submit();"  style="border-radius:50px; font-size:18px; height:60px; width:250px" name="chr" size="6" />
        </td>
        <td style="padding:5px;" >
           <input value ="Limit Genes by Annotation" type="button" onClick="this.form.action='/rgdweb/gTool/Gviewer.jsp';this.form.submit();"  style="border-radius:50px; font-size:18px; height:60px; width:250px" name="chr" size="6" />
        </td>
    </tr>
    <tr>
        <td  width=250 valign="top" style="color:white; font-size:14px;padding:10px;">Search for strain variation based on an individual gene or gene list</td>
        <td  width=250 valign="top" style="color:white; font-size:14px;padding:10px;">Build a gene list based on one or more ontology annotations</td>
    </tr>

</table>

</form>
<br>
<br>


<br><br>


<%@ include file="/common/footerarea.jsp" %>