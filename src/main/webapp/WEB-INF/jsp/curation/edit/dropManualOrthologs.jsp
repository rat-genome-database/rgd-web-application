<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.edit.DropManualOrthologsBean" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.edit.DropManualOrthologsBean" />

<%
    String pageTitle = "Drop Manual Orthologs";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="/common/headerarea.jsp"%>
<style>
  .mouse {background-color: #ffffdd;}
  .human {background-color: #ccffff;}
  .rat {background-color: #00ffbb;}
  .inactive {background-color: #cc0044;font-weight: bold;}
</style>

<h1>Drop Manual Orthologs</h1>
<% if( bean.getMsg()!=null ) { %>
<p style="border: solid 1px red;padding: 4px;color:red;font-weight:bold;">
<%=bean.getMsg()%>
</p>
<% } %>

<form action="/rgdweb/curation/edit/dropManualOrthologs.html" method="get">
    Gene symbol filter:
    <input type="text" name="filter" value="<%=bean.getFilter()%>">
    <input type="submit" name="submit" value="submit">
</form>

<p>
    <table border cellpadding="3" cellspacing="1">
    <tr>
        <th>Legend:</th>
        <td class="rat">RAT</td>
        <td class="mouse">MOUSE</td>
        <td class="human">HUMAN</td>
        <td class="inactive">NON-ACTIVE GENE</td>
    </tr>
    </table>
</p>
<table border cellpadding="2" cellspacing="1">
    <tr>
        <th>Nr</th>
        <th>&nbsp;</th>
        <th>Source gene</th>
        <th>Src species</th>
        <th>Dest gene</th>
        <th>Dest species</th>
        <th>Source</th>
        <th>Set</th>
        <th>Cr by</th>
        <th>Cr date</th>
        <th>Mod by</th>
        <th>Mod date</th>
        <th>Ortholog Type</th>
    </tr>
<%
    List<DropManualOrthologsBean.OrthologInfo> orthos = bean.getInfos();
    int nr = 0;
    for( DropManualOrthologsBean.OrthologInfo o: orthos ) {
        nr++;
        String s1 = "", s2 = ""; // cell styles depending on species and active inactive status
        if( !o.sourceRgdId.getObjectStatus().equals("ACTIVE") )
            s1 = "inactive";
        else if( o.ortholog.getSrcSpeciesTypeKey()==SpeciesType.RAT )
            s1 = "rat";
        else if( o.ortholog.getSrcSpeciesTypeKey()==SpeciesType.MOUSE )
            s1 = "mouse";
        else if( o.ortholog.getSrcSpeciesTypeKey()==SpeciesType.HUMAN )
            s1 = "human";

        if( !o.destRgdId.getObjectStatus().equals("ACTIVE") )
            s2 = "inactive";
        else if( o.ortholog.getDestSpeciesTypeKey()==SpeciesType.RAT )
            s2 = "rat";
        else if( o.ortholog.getDestSpeciesTypeKey()==SpeciesType.MOUSE )
            s2 = "mouse";
        else if( o.ortholog.getDestSpeciesTypeKey()==SpeciesType.HUMAN )
            s2 = "human";
        %>
    <tr>
        <td><%=nr%>.</td>
        <td><a href="javascript:delOrtho(<%=o.ortholog.getKey()%>,'<%=o.sourceGene.getSymbol()%>','<%=o.destGene.getSymbol()%>');">drop</a></td>
        <td class="<%=s1%>"><%=o.sourceGene.getSymbol()%> (<%=o.sourceGene.getName()%>)</td>
        <td class="<%=s1%>"><%=SpeciesType.getCommonName(o.ortholog.getSrcSpeciesTypeKey())%></td>
        <td class="<%=s2%>"><%=o.destGene.getSymbol()%> (<%=o.destGene.getName()%>)</td>
        <td class="<%=s2%>"><%=SpeciesType.getCommonName(o.ortholog.getDestSpeciesTypeKey())%></td>
        <td><%=o.ortholog.getXrefDataSrc()%></td>
        <td><%=o.ortholog.getXrefDataSet()%></td>
        <td><%=o.ortholog.getCreatedBy()%></td>
        <td><%=o.ortholog.getCreatedDate()%></td>
        <td><%=o.ortholog.getLastModifiedBy()%></td>
        <td><%=o.ortholog.getLastModifiedDate()%></td>
        <td><%=bean.getOrthologTypeName(o.ortholog.getOrthologTypeKey())%> [<%=o.ortholog.getOrthologTypeKey()%>]</td>
    </tr>
<%
    }
%>
</table>
<script>
function delOrtho(key,sym1,sym2) {
    if( confirm('Do you really want to delete ortholog between "'+sym1+'" and "'+sym2+'"?') ) {
        window.location.href = '/rgdweb/curation/edit/dropManualOrthologs.html?delKey='+key+'&filter=<%=bean.getFilter()%>';
    }
    return null;
}
</script>
<%@ include file="/common/footerarea.jsp"%>

