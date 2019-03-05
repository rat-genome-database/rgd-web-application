<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>


<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
<link rel="stylesheet" type="text/css" href="/rgdweb/css/enrichment/analysis.css">
<html>
<body style="background-color: white">


<div id="enrichment" >
    <%@ include file="../../WEB-INF/jsp/enrichment/annotatedGenes.jsp" %>
    <%@ include file="../../WEB-INF/jsp/enrichment/terms.jsp" %>
</div>
<script src="/rgdweb/js/enrichment/analysis.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>
<script>
    var host='https://dev.rgd.mcw.edu';
    var speciesKey = 3;
    var ont = 'RDO';
    var genes = ["lepr","a2m","xiap"];
    //view = 1 shows only graph, 2 shows only table and 3 shows both
    var view=1;
    var enrichment = EnrichmentVue('enrichment',speciesKey,ont,genes,view,host);
</script>


</body>
</html>