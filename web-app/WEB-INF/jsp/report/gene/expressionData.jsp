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
        text-align: center;
        padding: 4px;
    }


</style>
<%
    GeneExpressionDAO geneExpressionDAO = new GeneExpressionDAO();
    OntologyXDAO xdao = new OntologyXDAO();
    //int count = geneExpressionDAO.getCountOfGeneExprRecordValuesForGene(obj.getRgdId(),"TPM");
    List<String> terms = xdao.getAllSlimTerms("UBERON","AGR");
    HashMap<String,Integer> high = new HashMap();
    HashMap<String,Integer> medium = new HashMap();
    HashMap<String,Integer> low = new HashMap();
    HashMap<String,Integer> belowcutOff = new HashMap();
    List<String> exclude = new ArrayList<>();
    for(String t: terms){

        String highCount = geneExpressionDAO.getGeneExprReValCountForGeneBySlim(obj.getRgdId(),"TPM","high",t);
        String lowCount = geneExpressionDAO.getGeneExprReValCountForGeneBySlim(obj.getRgdId(),"TPM","low",t);
        String mediumCount = geneExpressionDAO.getGeneExprReValCountForGeneBySlim(obj.getRgdId(),"TPM","medium",t);
        String belowCount = geneExpressionDAO.getGeneExprReValCountForGeneBySlim(obj.getRgdId(),"TPM","below cutoff",t);
        if(highCount != null)
            high.put(t,Integer.parseInt(highCount));
        if(lowCount != null)
            low.put(t,Integer.parseInt(lowCount));
        if(mediumCount != null)
            medium.put(t,Integer.parseInt(mediumCount));
        if(belowCount != null)
            belowcutOff.put(t,Integer.parseInt(belowCount));

        if(highCount == null && lowCount == null && mediumCount == null && belowCount == null)
            exclude.add(t);
    }
  terms.removeAll(exclude);
    if( high.size() !=  0 || low.size() != 0 || medium.size() != 0 || belowcutOff.size() != 0  ) {
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
    <% for(String t:terms) {
        Term term = xdao.getTermByAccId(t);
        if( term != null) {
    %>
        <td><%=xdao.getTerm(t).getTerm()%></td>
        <% } else{  %>
        <td><%=t%></td>
        <%

        } } %>
    </tr>
    <tr>
        <td>High</td>
        <% for(String t:terms) {
            if( high.containsKey(t)) {
        %>
        <td style="background-color: SteelBlue ">
            <span class="detailReportLink"><a href="/rgdweb/report/gene/expressionData.html?id=<%=obj.getRgdId()%>&fmt=full&level=high&tissue=<%=t%>"><b><%=high.get(t)%></b> </a></span>
        </td>

        <% } else {%>
        <td style="background-color: SteelBlue "></td>
        <%}}  %>
    </tr>
    <tr>
        <td>Medium</td>
        <% for(String t:terms) {
            if( medium.containsKey(t)) {
        %>
        <td style="background-color: LightSteelBlue ">
            <span class="detailReportLink"><a href="/rgdweb/report/gene/expressionData.html?id=<%=obj.getRgdId()%>&fmt=full&level=medium&tissue=<%=t%>"><b><%=medium.get(t)%></b>  </a></span>
        </td >

        <% } else {%>
        <td style="background-color: LightSteelBlue "></td>
        <% }} %>
    </tr>
    <tr>
        <td>Low</td>
        <% for(String t:terms) {
            if( low.containsKey(t)) {
        %>
        <td style="background-color: LightBlue">
            <span class="detailReportLink"><a href="/rgdweb/report/gene/expressionData.html?id=<%=obj.getRgdId()%>&fmt=full&level=low&tissue=<%=t%>"><b><%=low.get(t)%></b> </a></span>
        </td>

        <% } else {%>
        <td style="background-color: LightBlue"></td>
        <% }} %>
    </tr>
    <tr>
        <td>Below cutoff</td>

        <% for(String t:terms) {
            if( belowcutOff.containsKey(t)) {
        %>
        <td>
            <span class="detailReportLink"><a href="/rgdweb/report/gene/expressionData.html?id=<%=obj.getRgdId()%>&fmt=full&level=below cutoff&tissue=<%=t%>"><b><%=belowcutOff.get(t)%></b> </a></span>
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
