<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="v-on" uri="http://www.springframework.org/tags/form" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="java.util.Map" %>
<%@ page import="edu.mcw.rgd.datamodel.MappedGene" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.FixedWidthReportStrategy" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="java.util.Iterator" %>
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

%>

<div class="container" id="ortholog">
  <div class="container-fluid">
    <h2 class="text-left" id="title"><%=pageHeader%></h2>
  <button v-on:click="download()">Download</button>
  </div>
    <table class="table table-hover">
    <thead><th><%=inSpecies%> Rgd Id</th><th><%=inSpecies%> Gene Symbol</th><th>Chromosome</th><th>Start Pos</th><th>End Pos</th>
    <th><%=outSpecies%> Rgd Id</th><th><%=outSpecies%> Ortholog</th><th>Chromosome</th><th>Start Pos</th><th>End Pos</th><th>Strand</th></thead>
<tbody>
<%    for (Integer rgdId: genes.keySet()) {
        if((orthoMap.keySet().contains(rgdId))){
            if((geneMap.keySet().contains(orthoMap.get(rgdId)))){
%>
<tr>
    <td><%=rgdId%></td>
    <td><%=genes.get(rgdId).get(0).getGene().getSymbol()%></td>
    <td colspan="3" ><table class="table table-sm table-borderless ">

<%
    for(MappedGene inputGene: genes.get(rgdId)) {%>
        <tr align="center">
    <td><%=inputGene.getChromosome()%></td>
    <td><%=inputGene.getStart()%></td>
    <td><%=inputGene.getStop()%></td>
    </tr>
<% } %>
    </table>
    </td>
    <td><%=geneMap.get(orthoMap.get(rgdId)).get(0).getGene().getRgdId()%></td>
    <td><%=geneMap.get(orthoMap.get(rgdId)).get(0).getGene().getSymbol()%></td>
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
<%            }
       }
    }%>
</tbody>
    </table>
</div>
<script>
    alert(<%=symbols%>);
    var v= new OrthologVue("ortholog");
    v.inSpecies = <%=inSpeciesKey%>;
    v.outSpecies = <%=outSpeciesKey%>;
    v.inMapKey = <%=inMapKey%>;
    v.outMapKey = <%=outMapKey%>;
    v.genes = <%=symbols%>;
</script>

