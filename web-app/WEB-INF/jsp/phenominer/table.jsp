<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>

<meta name="referrer" content="no-referrer" />

<script src="https://d3js.org/d3.v4.min.js"></script>
<%

    HttpRequestFacade req = new HttpRequestFacade(request);
    Report report = (Report)request.getAttribute("report");
    HashMap<String,Term> termResolver =(HashMap<String,Term>) request.getAttribute("termResolver");
    HashMap<String,String> measurements = (HashMap<String,String>) request.getAttribute("measurements");
    HashMap<String,String> conditions = (HashMap<String,String>) request.getAttribute("conditions");
    HashMap<String,String> methods = (HashMap<String,String>) request.getAttribute("methods");
    HashMap<String,String> samples = (HashMap<String,String>) request.getAttribute("samples");
    Double minValue = (Double) request.getAttribute("minValue");
    Double maxValue = (Double) request.getAttribute("maxValue");
    String idsWithoutMM = (String) request.getAttribute("idsWithoutMM");
    Integer refRgdId = (Integer) request.getAttribute("refRgdId");

    int speciesTypeKey = 3;
    try {
        speciesTypeKey= Integer.parseInt(request.getParameter("species"));
    }catch(Exception e) {

    }

    String tableUrl = "/rgdweb/phenominer/table.html?species="+speciesTypeKey;
    String reqTerms = request.getParameter("terms");
    if( !Utils.isStringEmpty(reqTerms) ) {
        tableUrl += "&terms=" + reqTerms;
    }
    if( refRgdId!=0 ) {
        tableUrl += "&refRgdId="+refRgdId;
    }
%>

<%

    String pageTitle = "Phenominer";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="/common/headerarea.jsp"%>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>

<script>
    document.body.style.backgroundColor="white";
</script>

<script>

</script>
<%@include file="chartjs.jsp"%>

<div class="row" id="phenoController" ng-controller="phenoController as pheno">

<div class="col-md-3  sidebar">
    <!--div class="sidebar-sticky"-->
    <%@include file="sideBar.jsp"%>

    <!--/div-->
</div>
<main role="main" class="col-md-9" id="results">
    <%@include file="phenominerChart.jsp"%>
</main>
</div>




<%@ include file="/common/compactFooterArea.jsp"%>
