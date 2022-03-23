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

    String pageTitle = "Phenominer";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="/common/headerarea.jsp"%>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>

<script>
    document.body.style.backgroundColor="white";
</script>


<div id="site-wrapper" style="position:relative; left:0px; top:00px;">

<div class="row" id="phenoController">

    <div class=" sidebar">
        <%@include file="sideBar.jsp"%>
    </div>
    <main role="main" class="col" id="results">
        <%@include file="phenominerChart.jsp"%>
    </main>
</div>
</div>



<%@ include file="/common/compactFooterArea.jsp"%>
