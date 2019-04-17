<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
<link rel="stylesheet" type="text/css" href="/rgdweb/css/enrichment/analysis.css">
<html>
<body style="background-color: white">

<%

    String pageTitle = "RGD Gene Enrichement";
    String headContent = "";
    String pageDescription = "Gene enrichment for multiple ontologies";

%>

<%@ include file="/common/headerarea.jsp" %>
<%
    HttpRequestFacade req = new HttpRequestFacade(request);
    ObjectMapper om = (ObjectMapper) request.getAttribute("objectMapper");
%>
<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading">Gene List Enrichement: Result</div>
</div>

<% if (om.getMapped().size() == 0) {
    return;
}%>
<div style="color:#2865a3; font-size:14px; font-weight:500; height:55px; overflow-y: scroll;padding:10px; "><%=om.getMapped().size()%> Genes in set:

<%
    String firstId = null;
    String species = req.getParameter("species");
    List symbols = (List) request.getAttribute("genes");
    String ontology = "";
    ontology = "\""+req.getParameter("o")+"\"";
    Iterator symbolIt = om.getMapped().iterator();
    List<String> geneSymbols = new ArrayList<>();
    while (symbolIt.hasNext()) {
        Object obj = symbolIt.next();
        String symbol = "";
        int rgdId = -1;
        String type = "";
        if (obj instanceof Gene) {
            Gene g = (Gene) obj;
            symbol = g.getSymbol();
            rgdId = g.getRgdId();
            if(geneSymbols.size() == 0)
                geneSymbols.add("\""+symbol+"\"");
            else
                geneSymbols.add("\""+symbol+"\""); %>
    <a style="color:#2865a3;" href= <%=Link.gene(g.getRgdId())%> \><u><%= g.getSymbol()%></u></a><span style="font-size:11px;">&nbsp;</span>
<%
        }
    }
%>


</div>
<br>
<div id="enrichment" >
    <%@ include file="annotatedGenes.jsp" %>
    <table >
        <tr>
        <td><button type="button" v-bind:class="{'btn':true, 'btn-sm':true, 'btn-primary': selectedOne, 'btn-success': selectedAll,'disabled': loading}" @click="loadView('All')">All</button>&nbsp;&nbsp;</td>
            <td v-for="s in allSpecies"><button type="button" v-bind:class="{'btn':true, 'btn-sm':true, 'btn-primary': true, 'btn-success': getSpeciesKey(s)== species[0], 'disabled': loading }" @click="loadOntView(s)">{{s}}</button>&nbsp;&nbsp;</td>
        </tr>
  </table>
    <table><tr>
        <td v-for="o in allOntologies"><button type="button" v-bind:class="{ 'btn':true, 'btn-sm':true, 'btn-primary':true,  'btn-success': o==ontology[0],'disabled': loading }" @click="loadSpeciesView(o)">{{getOntologyTitle(o)}}</button></td>
    </tr></table>

    <section v-if="errored">
        <p>We're sorry, we're not able to retrieve this information at the moment, please try back later</p>
    </section>

    <section v-else>
        <br>
        <section v-if="selectedAll" >
            <%@ include file="species.jsp" %>
        </section>
        <section v-else>
            <%@ include file="terms.jsp" %>
        </section>
    </section>
</div>
<script src="/rgdweb/js/enrichment/analysis.js"></script>

<script>

    var host = window.location.protocol + window.location.host;
    if (window.location.host.indexOf('localhost') > -1) {
        host= window.location.protocol + '//dev.rgd.mcw.edu';
   } else if (window.location.host.indexOf('dev.rgd') > -1) {
        host= window.location.protocol + '//dev.rgd.mcw.edu';
    }else if (window.location.host.indexOf('test.rgd') > -1) {
        host= window.location.protocol + '//test.rgd.mcw.edu';
    }else if (window.location.host.indexOf('pipelines.rgd') > -1) {
        host= window.location.protocol + '//pipelines.rgd.mcw.edu';
    }else {
        host=window.location.protocol + '//rest.rgd.mcw.edu';
    }
   
    var speciesKey = <%=req.getParameter("species")%>;
    var ont = <%=ontology%>;
    var genes = <%=geneSymbols%>;
    //view = 1 shows only graph, 2 shows only table and 3 shows both
    var view=3;
    var enrichment = EnrichmentVue('enrichment',speciesKey,ont,genes,view,host);
</script>


</body>
</html>