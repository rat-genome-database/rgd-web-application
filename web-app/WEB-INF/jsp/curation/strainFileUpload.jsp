<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%
    String pageTitle = "Upload Strain Files";
    String headContent = "";
    String pageDescription = "Upload Strain Files";
%>
<%@ include file="/common/headerarea.jsp"%>

<script type="text/javascript" src="/rgdweb/js/util.js"></script>

<link rel="stylesheet" href="/rgdweb/js/windowfiles/dhtmlwindow.css" type="text/css"/>
<script type="text/javascript" src="/rgdweb/js/windowfiles/dhtmlwindow.js">
    /***********************************************
     * DHTML Window Widget- � Dynamic Drive (www.dynamicdrive.com)
     * This notice must stay intact for legal use.
     * Visit http://www.dynamicdrive.com/ for full source code
     ***********************************************/
</script>
<script type="text/javascript" src="/rgdweb/js/lookup.js"></script>
<html>
<head>
    <title>Upload files</title>
</head>
<body>

<h2>Upload Files</h2>
<%
    HttpRequestFacade req = (HttpRequestFacade) request.getAttribute("requestFacade");

    DisplayMapper dm = new DisplayMapper(req,error);
%>
<div class="container-fluid">
<form method="POST" action="strainFileUpload.html" enctype="multipart/form-data">

            <label for="rgdId1" style="color: #24609c; font-weight: bold;">Select a Strain Id:</label>
            <input type="text" id="rgdId1" name="strainId" value="<%=dm.out("strainId",request.getParameter("strainId"))%>"/>
     <a href="javascript:lookup_render('rgdId1')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a>
<br><br>
    <% if(request.getParameter("strainId") != null) {
        String strainId = request.getParameter("strainId");
    %>
    <span style="font-weight: bold; "><u>EXISTING FILES</u></span> <br><br>
    <span style="color: green; font-weight: bold;"> Genotype File: </span> <%=request.getAttribute("genotypeFile")%> <br><br>
    <span style="color: green; font-weight: bold;"> Highlights File: </span> <%=request.getAttribute("highlightsFile")%> <br><br>
    <span style="color: green; font-weight: bold;"> Supplemental File: </span><%=request.getAttribute("supplementalFile")%> <br><br>

    <span style="font-weight: bold;"><u>ADD FILES</u></span> <br><br>
    <label for="Genotype" style="color: #24609c; font-weight: bold;">Genotype: </label>
            <input type="file" id="Genotype" name="Genotype"  />
<br><br>
    <label for="Highlights" style="color: #24609c; font-weight: bold;">Highlights: </label>
    <input type="file" id="Highlights" name="Highlights"  />
    <br><br>
    <label for="Supplemental" style="color: #24609c; font-weight: bold;">Supplemental: </label>
    <input type="file" id="Supplemental" name="Supplemental"  />
    <br><br>

    <a href="/rgdweb/report/strain/main.html?id=<%=strainId%>" >Strain Report</a><br><br>
<% } %>
            <input type="submit" value="Upload" />

</form>

</div>

</body>
</html>