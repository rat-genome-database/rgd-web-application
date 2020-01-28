<%@ page import="edu.mcw.rgd.datamodel.pheno.*" %>
<%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ include file="../sectionHeader.jsp"%>
<style>
    .exprData {
        border:1px solid black;
        border-radius:2px;
        border-spacing: 5px;
    }
    .exprData td,th{
        border: 1px solid #dddddd;
        text-align: left;
        padding: 8px;
    }


</style>
<%
    GeneExpressionDAO geneExpressionDAO = new GeneExpressionDAO();
    OntologyXDAO xdao = new OntologyXDAO();
    Set<String> traits = new TreeSet<>();
    List<GeneExpressionRecordValue> geneExpressionRecordValues = geneExpressionDAO.getGeneExprRecordValuesForGene(obj.getRgdId(),"TPM");
    HashMap<Integer,GeneExpressionRecord> geneExprRecMap = new HashMap<>();
    HashMap<Integer, Experiment> experimentMap = new HashMap<>();

    for (GeneExpressionRecordValue rec : geneExpressionRecordValues) {

        GeneExpressionRecord geneExpRec;
        edu.mcw.rgd.datamodel.pheno.Sample s;
        Experiment e;

        if (geneExprRecMap.isEmpty() || !geneExprRecMap.keySet().contains(rec.getGeneExpressionRecordId())) {
            geneExpRec = geneExpressionDAO.getGeneExpressionRecordById(rec.getGeneExpressionRecordId());
            geneExprRecMap.put(rec.getGeneExpressionRecordId(), geneExpRec);
        } else geneExpRec = geneExprRecMap.get(rec.getGeneExpressionRecordId());

        if (experimentMap.isEmpty() || !experimentMap.keySet().contains(geneExpRec.getExperimentId())) {
            e = phenominerDAO.getExperiment(geneExpRec.getExperimentId());
            experimentMap.put(e.getId(), e);

        } else e = experimentMap.get(geneExpRec.getExperimentId());

        if(e.getTraitOntId() != null)
            traits.add(e.getTraitOntId());


    }

            if( !geneExpressionRecordValues.isEmpty() ) {
%>

<%=ui.dynOpen("rna-seq", "RNA-SEQ Expression")%>    <br>



<b ><span style="color: DarkBlue">High:</span> > 1000 TPM value</b>&nbsp;&nbsp;
<b><span style="color: DarkBlue">Medium:</span> Between 11 and 1000 TPM</b><br>
<b><span style="color: Red">Low:</span> Between 0.5 and 10 TPM</b>&nbsp;&nbsp;
<b><span style="color: Red">Below Cutoff:</span> < 0.5 TPM</b>
<br><br>
<table class="exprData">
    <tr>
        <td></td>
    <% for(String trait:traits) {
        Term term = xdao.getTermByAccId(trait);
        if( term != null) {
    %>
        <td><%=xdao.getTerm(trait).getTerm()%></td>
        <% } else{  %>
        <td><%=trait%></td>
        <%

        } } %>
    </tr>
    <tr>
        <td>High</td>
        <% for(String trait:traits) {

            List<GeneExpressionRecordValue> val = geneExpressionDAO.getGeneExprRecordValuesForGeneByTrait(obj.getRgdId(),"TPM","high",trait);
            if( val.size() != 0) {
        %>
        <td style="background-color: SteelBlue ">
            <span class="detailReportLink"><a href="/rgdweb/report/gene/expressionData.html?id=<%=obj.getRgdId()%>&fmt=full&level=high&tissue=<%=trait%>"><b><%=val.size()%></b> </a></span>
        </td>

        <% } else {%>
        <td style="background-color: SteelBlue "></td>
        <%}}  %>
    </tr>
    <tr>
        <td>Medium</td>
        <% for(String trait:traits) {
            List<GeneExpressionRecordValue> val = geneExpressionDAO.getGeneExprRecordValuesForGeneByTrait(obj.getRgdId(),"TPM","medium",trait);
            if(val.size() != 0) {
        %>
        <td style="background-color: LightSteelBlue ">
            <span class="detailReportLink"><a href="/rgdweb/report/gene/expressionData.html?id=<%=obj.getRgdId()%>&fmt=full&level=medium&tissue=<%=trait%>"><b><%=val.size()%></b>  </a></span>
        </td >

        <% } else {%>
        <td style="background-color: LightSteelBlue "></td>
        <% }} %>
    </tr>
    <tr>
        <td>Low</td>
        <% for(String trait:traits) {
            List<GeneExpressionRecordValue> val = geneExpressionDAO.getGeneExprRecordValuesForGeneByTrait(obj.getRgdId(),"TPM","low",trait);
            if(val.size() != 0) {
        %>
        <td style="background-color: LightBlue">
            <span class="detailReportLink"><a href="/rgdweb/report/gene/expressionData.html?id=<%=obj.getRgdId()%>&fmt=full&level=low&tissue=<%=trait%>"><b><%=val.size()%></b> </a></span>
        </td>

        <% } else {%>
        <td style="background-color: LightBlue"></td>
        <% }} %>
    </tr>
    <tr>
        <td>Below cutoff</td>

        <% for(String trait:traits) {
            List<GeneExpressionRecordValue> val = geneExpressionDAO.getGeneExprRecordValuesForGeneByTrait(obj.getRgdId(),"TPM","below cutoff",trait);
            if(val.size() != 0) {
        %>
        <td>
            <span class="detailReportLink"><a href="/rgdweb/report/gene/expressionData.html?id=<%=obj.getRgdId()%>&fmt=full&level=below cutoff&tissue=<%=trait%>"><b><%=val.size()%></b> </a></span>
        </td>

        <% } else{ %>
        <td></td>
        <%} } %>
    </tr>

</table>
<br>

<span class="detailReportLink" style="font-size: large; font-weight: 700"><a href="/rgdweb/report/gene/expressionData.html?id=<%=obj.getRgdId()%>&fmt=full&level=&tissue="> View RNA-SEQ Expression Data </a></span>
<br><br>
<%}%>


<%=ui.dynClose("rna-seq")%>

<%@ include file="../sectionFooter.jsp"%>
