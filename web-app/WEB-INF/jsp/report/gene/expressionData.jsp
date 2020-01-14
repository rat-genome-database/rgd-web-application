<%@ page import="edu.mcw.rgd.datamodel.pheno.*" %>
<%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %>
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
    Set<String> tissues = new TreeSet<>();
    List<GeneExpressionRecordValue> geneExpressionRecordValues = geneExpressionDAO.getGeneExprRecordValuesForGene(obj.getRgdId(),"TPM");
    HashMap<Integer,GeneExpressionRecord> geneExprRecMap = new HashMap<>();
    HashMap<Integer, edu.mcw.rgd.datamodel.pheno.Sample> sampleMap = new HashMap<>();

    for (GeneExpressionRecordValue rec : geneExpressionRecordValues) {

        GeneExpressionRecord geneExpRec;
        edu.mcw.rgd.datamodel.pheno.Sample s;

        if (geneExprRecMap.isEmpty() || !geneExprRecMap.keySet().contains(rec.getGeneExpressionRecordId())) {
            geneExpRec = geneExpressionDAO.getGeneExpressionRecordById(rec.getGeneExpressionRecordId());
            geneExprRecMap.put(rec.getGeneExpressionRecordId(), geneExpRec);
        } else geneExpRec = geneExprRecMap.get(rec.getGeneExpressionRecordId());

        if (sampleMap.isEmpty() || !sampleMap.keySet().contains(geneExpRec.getSampleId())) {
            s = phenominerDAO.getSample(geneExpRec.getSampleId());
            sampleMap.put(s.getId(), s);

        } else s = sampleMap.get(geneExpRec.getSampleId());

        tissues.add(s.getTissueAccId());


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
        <th></th>
    <% for(String tissue:tissues) {%>
        <th><%=xdao.getTerm(tissue).getTerm()%></th>
        <% } %>
    </tr>
    <tr>
        <th>High</th>
        <% for(String tissue:tissues) {
            List<GeneExpressionRecordValue> val = geneExpressionDAO.getGeneExprRecordValuesForGeneByTissue(obj.getRgdId(),"TPM","high",tissue);
            if( val.size() != 0) {
        %>
        <td style="background-color: SteelBlue ">
            <span class="detailReportLink"><a href="/rgdweb/report/gene/expressionData.html?id=<%=obj.getRgdId()%>&fmt=full&level=high&tissue=<%=tissue%>"><b><%=val.size()%></b> </a></span>
        </td>

        <% } else {%>
        <td style="background-color: SteelBlue "></td>
        <%}}  %>
    </tr>
    <tr>
        <th>Medium</th>
        <% for(String tissue:tissues) {
            List<GeneExpressionRecordValue> val = geneExpressionDAO.getGeneExprRecordValuesForGeneByTissue(obj.getRgdId(),"TPM","medium",tissue);
            if(val.size() != 0) {
        %>
        <td style="background-color: LightSteelBlue ">
            <span class="detailReportLink"><a href="/rgdweb/report/gene/expressionData.html?id=<%=obj.getRgdId()%>&fmt=full&level=medium&tissue=<%=tissue%>"><b><%=val.size()%></b>  </a></span>
        </td >

        <% } else {%>
        <td style="background-color: LightSteelBlue "></td>
        <% }} %>
    </tr>
    <tr>
        <th>Low</th>
        <% for(String tissue:tissues) {
            List<GeneExpressionRecordValue> val = geneExpressionDAO.getGeneExprRecordValuesForGeneByTissue(obj.getRgdId(),"TPM","low",tissue);
            if(val.size() != 0) {
        %>
        <td style="background-color: LightBlue">
            <span class="detailReportLink"><a href="/rgdweb/report/gene/expressionData.html?id=<%=obj.getRgdId()%>&fmt=full&level=low&tissue=<%=tissue%>"><b><%=val.size()%></b> </a></span>
        </td>

        <% } else {%>
        <td style="background-color: LightBlue"></td>
        <% }} %>
    </tr>
    <tr>
        <th>Below cutoff</th>

        <% for(String tissue:tissues) {
            List<GeneExpressionRecordValue> val = geneExpressionDAO.getGeneExprRecordValuesForGeneByTissue(obj.getRgdId(),"TPM","below cutoff",tissue);
            if(val.size() != 0) {
        %>
        <td>
            <span class="detailReportLink"><a href="/rgdweb/report/gene/expressionData.html?id=<%=obj.getRgdId()%>&fmt=full&level=below cutoff&tissue=<%=tissue%>"><b><%=val.size()%></b> </a></span>
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
