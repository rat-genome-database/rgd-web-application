<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="v-on" uri="http://www.springframework.org/tags/form" %>
<%@ page import="edu.mcw.rgd.datamodel.MappedGene" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>

<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%
    String pageTitle = "Gene Ortholog Tool";
    String headContent = "";
    String pageDescription = "Generate an ortholog report for a list of genes.";
    String pageHeader="Ortholog Report";

%>
<%@ include file="/common/headerarea.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>
<script src="/rgdweb/js/ortholog/orthologVue.js"></script>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">

<%
    Map<Integer, List<MappedGene>> genes = (Map<Integer, List<MappedGene>>) request.getAttribute("geneMap");
    Map<Integer, Integer> orthoMap = (Map<Integer, Integer>)request.getAttribute("orthologMap");
    Map<Integer, List<MappedGene>> geneMap = (Map<Integer, List<MappedGene>>)request.getAttribute("mappedGenes");
    int inSpeciesKey = Integer.parseInt(request.getParameter("inSpecies"));
    int outSpeciesKey = Integer.parseInt(request.getParameter("outSpecies"));
    int inMapKey = Integer.parseInt(request.getParameter("inMapKey"));
    int outMapKey = Integer.parseInt(request.getParameter("outMapKey"));
    List<String> geneSymbols = (List)request.getAttribute("genes");
    List<String> symbolsNotFound = (List)request.getAttribute("notFound");
    Iterator symbolIt = geneSymbols.iterator();
    List symbols = new ArrayList<>();
    while (symbolIt.hasNext()) {

            if (symbols.size() == 0)
                symbols.add("\"" + symbolIt.next() + "\"");
            else
                symbols.add("\"" + symbolIt.next() + "\"");

    }
    String inSpecies = SpeciesType.getCommonName(inSpeciesKey);
    String outSpecies = SpeciesType.getCommonName(outSpeciesKey);
    String inMap = MapManager.getInstance().getMap(inMapKey).getName();
    GeneDAO gdao = new GeneDAO();

%>

<div class="container" id="ortholog">
  <div class="container-fluid">
    <div class="row">
    <div class="col-md-6"><h2 class="text-left" id="title"><%=pageHeader%></h2></div>
    <div class="col-md-6"><button v-on:click="download()">Download</button></div>
    </div>
  </div>
<%if(symbolsNotFound.size() != 0) { %>
<div style=" font-size:14px; font-weight:500; height:55px; overflow-y: scroll;padding:10px; width: 1200px; ">  Symbols Not Found in <%=inMap%>: <br>
           <span style="color:red;"> <%=symbolsNotFound%></span>
</div>
<%} %>
     <br>
    <table class="table table-bordered table-striped">
    <thead style="font-size: 12px"><th><%=inSpecies%> Rgd Id</th><th><%=inSpecies%> Gene Symbol</th><th>Chr</th><th>Start</th><th>End</th><th>Strand</th>
    <th><%=outSpecies%> Rgd Id</th><th><%=outSpecies%> Ortholog</th><th>Chr</th><th>Start</th><th>End</th><th>Strand</th></thead>
<tbody>
<%    for (Integer rgdId: genes.keySet()) {


%>
<tr align="center">
    <td><%=rgdId%></td>
    <td><a href="/rgdweb/report/gene/main.html?id=<%=rgdId%>"><%=genes.get(rgdId).get(0).getGene().getSymbol()%></a></td>
    <td colspan="4" ><table class="table table-sm table-borderless">

<%
    for(MappedGene inputGene: genes.get(rgdId)) {%>
        <tr align="center">
    <td><%=inputGene.getChromosome()%></td>
    <td><%=inputGene.getStart()%></td>
    <td><%=inputGene.getStop()%></td>
    <td><%=inputGene.getStrand()%></td>
    </tr>
<% } %>
    </table>
    </td>
<% if((orthoMap.keySet().contains(rgdId))){
    if((geneMap.keySet().contains(orthoMap.get(rgdId)))){%>
    <td><%=geneMap.get(orthoMap.get(rgdId)).get(0).getGene().getRgdId()%></td>
    <td><a href="/rgdweb/report/gene/main.html?id=<%=geneMap.get(orthoMap.get(rgdId)).get(0).getGene().getRgdId()%>"><%=geneMap.get(orthoMap.get(rgdId)).get(0).getGene().getSymbol()%></a></td>
    <td colspan="4"><table class="table table-sm table-borderless">
<%                for(MappedGene ortholog: geneMap.get(orthoMap.get(rgdId))) {
%>

        <tr align="center">
                    <td><%=ortholog.getChromosome()%></td>
                    <td><%=ortholog.getStart()%></td>
                    <td><%=ortholog.getStop()%></td>
                    <td><%=ortholog.getStrand()%></td>
    </tr>
<%             } %>
    </table>
    </td>
</tr>

<%            }else{ %>
<td><%=orthoMap.get(rgdId)%></td>
<td><a href="/rgdweb/report/gene/main.html?id=<%=orthoMap.get(rgdId)%>"><%=gdao.getGene(orthoMap.get(rgdId)).getSymbol()%></a></td>

<td colspan="4"> No position found for this gene</td>

</tr>
<%} }else { %>
    <td colspan="6"> No ortholog found for this gene</td>

    </tr>
<%}     }%>

</tbody>
    </table>

</div>

<script>

    var v= new OrthologVue("ortholog");
    v.inSpecies = <%=inSpeciesKey%>;
    v.outSpecies = <%=outSpeciesKey%>;
    v.inMapKey = <%=inMapKey%>;
    v.outMapKey = <%=outMapKey%>;
    v.genes = <%=symbols%>;
</script>

