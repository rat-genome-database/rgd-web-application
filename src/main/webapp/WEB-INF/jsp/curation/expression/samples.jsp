<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.GeoRecord" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Condition" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
<style>
    #t{
        border:1px solid #ddd;
        border-radius:2px;
        width: 100%;
        text-align: center;
        font-size: 12px;
    }

    table tr td {
        padding-top: 10px;
        padding-bottom: 10px;
        padding-right: 15px;
    }
    #t th{
        background: rgb(246,248,249); /* Old browsers */
        background: -moz-linear-gradient(top, rgba(246,248,249,1) 0%, rgba(229,235,238,1) 50%, rgba(215,222,227,1) 51%, rgba(245,247,249,1) 100%); /* FF3.6-15 */
        background: -webkit-linear-gradient(top, rgba(246,248,249,1) 0%,rgba(229,235,238,1) 50%,rgba(215,222,227,1) 51%,rgba(245,247,249,1) 100%); /* Chrome10-25,Safari5.1-6 */
        background: linear-gradient(to bottom, rgba(246,248,249,1) 0%,rgba(229,235,238,1) 50%,rgba(215,222,227,1) 51%,rgba(245,247,249,1) 100%); /* W3C, IE10+, FF16+, Chrome26+, Opera12+, Safari7+ */
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f6f8f9', endColorstr='#f5f7f9',GradientType=0 );
    }
    #t td{
        max-width: 15px;
        min-width: 5px;
        padding: 10px;

    }
    #t  tr:nth-child(odd) {background-color: #f2f2f2}
    #t tr:hover {
        background-color: #daeffc;
    }

</style>

<%
    String pageHeader="View GEO Samples";
    String pageTitle="View GEO Samples";
    String headContent="View GEO Samples";
    String pageDescription = "View GEO Samples";
%>
<%@ include file="/common/headerarea.jsp"%>
<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading"><%=pageHeader%></div>
</div>


<html>
<head>
    <title>View GEO Samples</title>
</head>
<body>

<h2>View GEO Samples</h2>

<a href="/rgdweb/curation/expression/experiments.html">View Geo Experiments</a><br><br>
<div class="container-fluid">
    <%
        Report report = (Report) request.getAttribute("report");

        HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
        strat.setTableProperties("class='sortable'");

        out.print(report.format(strat));
        %>

</div>
<br>
<div class="container-fluid">
    <%
        Report report2 = (Report) request.getAttribute("referenceReport");

        HTMLTableReportStrategy strat2 = new HTMLTableReportStrategy();
        strat2.setTableProperties("class='sortable'");

        out.print(report2.format(strat2));
    %>
</div>
</body>
</html>
<%
    boolean tooManySamples = Utils.stringsAreEqual((String)request.getAttribute("tooManySamples"), "true");
    if (tooManySamples){
        int count = (int) request.getAttribute("count");
        HashMap<String,String> tissueMap = (HashMap) session.getAttribute("tissueMap");
        HashMap<String,String> tissueNameMap = (HashMap) session.getAttribute("tissueNameMap");
        HashMap<String,String> vtMap = (HashMap) session.getAttribute("vtMap");
        HashMap<String,String> vtNameMap = (HashMap) session.getAttribute("vtNameMap");
        HashMap<String,String> strainMap = (HashMap) session.getAttribute("strainMap");
        HashMap<String,String> strainNameMap = (HashMap) session.getAttribute("strainNameMap");
        HashMap<String,String> ageLow = (HashMap) session.getAttribute("ageLow");
        HashMap<String,String> ageHigh = (HashMap) session.getAttribute("ageHigh");
        HashMap<String,String> clinMeasMap = (HashMap) session.getAttribute("clinMeasMap");
        HashMap<String,String> clinMeasNameMap = (HashMap) session.getAttribute("clinMeasNameMap");
        HashMap<String,String> cellTypeMap = (HashMap) session.getAttribute("cellType");
        HashMap<String,String> cellNameMap = (HashMap) session.getAttribute("cellNameMap");
        HashMap<String,String> cellLine = (HashMap) session.getAttribute("cellLine");
        HashMap<String,String> gender = (HashMap) session.getAttribute("gender");
        HashMap<String,String> lifeStage = (HashMap) session.getAttribute("lifeStage");
        HashMap<String,String> notes = (HashMap) session.getAttribute("notesMap");
        HashMap<String,String> curNotes = (HashMap) session.getAttribute("curNotesMap");
        HashMap<String,String> xcoMap = (HashMap) session.getAttribute("xcoTerms");
        HashMap<String,String> culture = (HashMap) session.getAttribute("cultureDur");
        HashMap<String,String> cultureUnit = (HashMap) session.getAttribute("cultureUnit");
        List<Condition> conditions = (List) session.getAttribute("conditions");
        List<Integer> refRgdIds = (List) session.getAttribute("refRgdIds");

        session.setAttribute("tissueMap", tissueMap);
        session.setAttribute("tissueNameMap",tissueNameMap);
        session.setAttribute("vtMap",vtMap);
        session.setAttribute("vtNameMap",vtNameMap);
        session.setAttribute("strainMap",strainMap);
        session.setAttribute("strainNameMap",strainNameMap);
        session.setAttribute("ageLow",ageLow);
        session.setAttribute("ageHigh",ageHigh);
        session.setAttribute("clinMeasMap",clinMeasMap);
        session.setAttribute("clinMeasNameMap",clinMeasNameMap);
        session.setAttribute("cellType",cellTypeMap);
        session.setAttribute("cellNameMap",cellNameMap);
        session.setAttribute("cellLine",cellLine);
        session.setAttribute("gender",gender);
        session.setAttribute("lifeStage",lifeStage);
        session.setAttribute("notesMap",notes);
        session.setAttribute("curNotesMap",curNotes);
        session.setAttribute("xcoTerms",xcoMap);
        session.setAttribute("cultureDur", culture);
        session.setAttribute("cultureUnit", cultureUnit);
        session.setAttribute("conditions",conditions);
        session.setAttribute("refRgdIds",refRgdIds);
        String gse = request.getParameter("gse");
        String species = request.getParameter("species");

%>
<form id="nextSmapleBatch" action="/rgdweb/curation/expression/experiments.html" method="POST">
    <input type="hidden" id="curCount" name="curCount" value="<%=count%>">
    <input type="hidden" id="tooManySamples" name="tooManySamples" value="<%=tooManySamples%>">
    <input type="hidden" id="gse" name="gse" value="<%=gse%>">
    <input type="hidden" id="species" name="species" value="<%=species%>">
    <input type="button" value="Next Batch" onclick="submitMyForm()"/>
</form>
<% } %>
<%@ include file="/common/footerarea.jsp"%>

<script>
    function submitMyForm(){
        document.getElementById("nextSmapleBatch").submit();
    }
</script>
