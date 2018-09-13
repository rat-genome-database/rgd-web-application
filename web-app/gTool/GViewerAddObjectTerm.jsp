<%@ page import="edu.mcw.rgd.gviewer.GViewerBean" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<link rel="stylesheet" type="text/css" href="/rgdweb/css/ontology.css">
<script src="/common/js/sorttable.js"></script>
<style>
/* Sortable tables */
table.sortable thead {
    background-color:#eee;
    color:#666666;
    font-weight: bold;
    cursor: pointer;
}
</style>
<br>
<table border='0' style='font-size:13;' width='95%' class="sortable" cellspacing="0">
    <thead>
    <tr style="font-weight:700; text-decoration: underline;">
        <td>Term</td>
        <td>Ontology&nbsp;</td>
        <td align="right">Rat</td>
        <td align="right">Mouse</td>
        <td align="right">Human</td>
        <td align="right">Tree</td>
    </tr>
    </thead>
    <% GViewerBean bean = (GViewerBean) request.getAttribute("bean");
      for( String[] line: bean.getLines() ) {
        String selTerm = bean.getTerms()[0];
        String termAcc = line[0];
        String termName = line[1];
        String ontName = line[2];
        String annotObjCountRat = line[3];
        String annotObjCountMouse = line[4];
        String annotObjCountHuman = line[5];
    %>
          <tr>
            <td><a href="javascript:gview().addObjectsByURL('/plf/plfRGD/?module=gviewerStandAlone&func=getAnnotationXML&term_acc=<%=termAcc%>&speciesType=<%=bean.getSpeciesType()%>','<%=bean.getColor()%>','<%=termName%>');void(0);"><%=GViewerBean.highlight(termName, selTerm)%></a></td>
            <td><%=ontName%></td>
            <td align="right"><%=annotObjCountRat%></td>
            <td align="right"><%=annotObjCountMouse%></td>
            <td align="right"><%=annotObjCountHuman%></td>
            <td align="right"><a target="_blank" href="<%=Link.ontView(termAcc)%>"><img style="border-style: none; border:0;" border="0" src="/common/images/tree2.gif" height=15/></a></td>
		  </tr>
      <% } %>

  </table>
