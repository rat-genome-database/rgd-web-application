
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
<link rel="stylesheet" type="text/css" href="/rgdweb/css/enrichment/analysis.css">


<div id="enrichement">
    <%@ include file="../../WEB-INF/jsp/enrichment/annotatedGenes.jsp" %>
    <%@ include file="../../WEB-INF/jsp/enrichment/speciesTable.jsp" %>
    <%@ include file="../../WEB-INF/jsp/enrichment/speciesChart.jsp" %>

</div>

<script src="/rgdweb/js/enrichment/analysis.js?44"></script>
<script>

    //

    var speciesKey ="Rat";
    var ont = ["RDO"];
    var genes = ["A2m","Xiap","Lepr"];
    var graph=true;
    var enrichment = EnrichmentVue('enrichment',speciesKey,ont,genes,graph,"http://dev.rgd.mcw.edu:8080");
</script>
