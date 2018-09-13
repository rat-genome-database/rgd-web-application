<%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.web.*" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>


<%
    String pageTitle = "GA Tool: Annotation Search and Export";
    String headContent = "";
    String pageDescription = "Generate an annotation report for a list of genes.";

    int mapKey = MapManager.getInstance().getReferenceAssembly(SpeciesType.RAT).getKey();
    if (request.getParameter("mapKey") != null) {
        mapKey=Integer.parseInt(request.getParameter("mapKey"));
    }

%>
<%@ include file="../common/headerarea.jsp" %>


<%@ include file="../WEB-INF/jsp/ga/gaHeader.jsp" %>

<form>


<%
    String tutorialLink="http://rgd.mcw.edu/wg/home/rgd_rat_community_videos/gene-annotator-tutorial";
    String pageHeader="Gene Annotator (GA Tool)";
%>
<%@ include file="/common/title.jsp" %>
<br>


<div style="border-top-right-radius:30px;background-image: url(/rgdweb/common/images/bg3.png)">

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
           <input value ="Enter a Gene Symbol List" type="button" onClick="this.form.action='start.jsp';this.form.submit();"  style="border-radius:50px;font-size:18px; height:60px; width:250px" name="chr" size="6" />
        </td>
        <td style="padding:5px;">
           <input value ="Genes in Genomic Region" type="button" onClick="this.form.action='region.jsp';this.form.submit();" style=" border-radius:50px;font-size:18px; height:60px; width:250px" name="chr" size="6" />
        </td>
        <td style="padding:5px;" >
           <input value ="Limit Genes by Annotation" type="button" onClick="location.href='/rgdweb/generator/list.html?ga=1'"  style="border-radius:50px;font-size:18px; height:60px; width:250px" name="chr" size="6" />
        </td>
    </tr>
    <tr>
        <td  width=250 valign="top" style="color:white; font-size:14px;padding:10px;">Search for strain variation based on an individual gene or gene list</td>
        <td  width=250 valign="top" style="color: white; font-size:14px;;padding:10px;">A region can be defined using a genomic position or 2 gene/SSLP flanks located on the same chromosome</td>
        <td  width=250 valign="top" style="color:white; font-size:14px;padding:10px;">Build a gene list based on one or more ontology annotations</td>
    </tr>

</table>

</form>
<br>
<br>

</div>


<%@ include file="../common/footerarea.jsp" %>

