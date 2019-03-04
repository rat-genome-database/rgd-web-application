<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>


<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
<link rel="stylesheet" type="text/css" href="/rgdweb/css/enrichment/analysis.css">
<html>
<body style="background-color: white">
<%@ include file="/common/compactHeaderArea.jsp" %>


<div id="enrichment" >
    <%@ include file="annotatedGenes.jsp" %>
    <%@ include file="terms.jsp" %>
</div>
<script src="/rgdweb/js/enrichment/analysis.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>
<script>
    var host='https://dev.rgd.mcw.edu';
    //    var host = window.location.protocol + window.location.host;
    //    if (window.location.host.indexOf('localhost') > -1) {
    //       host= window.location.protocol + '//dev.rgd.mcw.edu';
    //   } else if (window.location.host.indexOf('dev.rgd') > -1) {
    //       host= window.location.protocol + '//dev.rgd.mcw.edu';
    //   }else if (window.location.host.indexOf('test.rgd') > -1) {
    //        host= window.location.protocol + '//test.rgd.mcw.edu';
    //    }else if (window.location.host.indexOf('pipelines.rgd') > -1) {
    //        host= window.location.protocol + '//pipelines.rgd.mcw.edu';
    //   }else {
    //       host=window.location.protocol + '//rest.rgd.mcw.edu';
    //    }
    var speciesKey = 3;
    var ont = 'RDO';
    var genes = ["lepr","a2m","xiap"];
    var graph=2;
    var enrichment = EnrichmentVue('enrichment',speciesKey,ont,genes,graph,host);
</script>


</body>
</html>