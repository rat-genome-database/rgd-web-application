<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="edu.mcw.rgd.datamodel.MapData" %>
<%@ page import="java.util.List" %>
<%
    String description = "Genome Information of Various Species";
    String pageTitle = "Genome Information"+ " - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = description;

%>

<%@ include file="/common/headerarea.jsp"%>
<link href="/rgdweb/css/genomeInformation/genomeInfo.css" type="text/css" rel="stylesheet"/>




<div id="titleDivWrapper">
    <div id="title">
     <!--a href="genomeInformation.html" style="color:#24619c;font-size: 40px;font-family: Futura;text-decoration: none;text-shadow: 1px 4px 4px #555;" title="Click to go to Genome Home Page">Genome Information</a-->
        <a href="genomeInformation.html" style="color:#24619c;font-size: 40px;text-decoration: none;" title="Click to go to Genome Home Page">Genome Information</a>
    </div>
</div>
<!--div class="container"-->
<hr>
