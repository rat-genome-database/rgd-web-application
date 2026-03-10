<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermSynonym" %>
<%@ page import="java.util.*" %>
<%
    String pageTitle = "Obsolete GO Terms";
    String headContent = "";
    String pageDescription = "";

    List<TermSynonym> synonyms = (List<TermSynonym>) request.getAttribute("synonyms");
    Map<String, String> termNames = (Map<String, String>) request.getAttribute("termNames");
    String msg = (String) request.getAttribute("msg");
%>

<%@ include file="/common/headerarea.jsp"%>
<style>
  .goTable th { background-color: #336699; color: #ffffff; padding: 5px 8px; }
  .goTable td { padding: 4px 8px; }
  .obsolete { background-color: #fff3cd; }
  .created { background-color: #d4edda; }
</style>

<h1>Obsolete GO Term Tool</h1>

<% if( msg != null ) { %>
<p style="border: solid 1px red;padding: 4px;color:red;font-weight:bold;">
<%=msg%>
</p>
<% } %>

<h3>Create New Obsolete GO Term</h3>
<form action="/rgdweb/curation/edit/obsoleteGoTerms.html" method="get">
<TABLE>
    <TR>
        <td class="label">Current Term Acc:</td><td><input type="text" name="currentTermAcc" value="" /></td>
        <td class="label">Obsolete Term Acc:</td><td><input type="text" name="obsoleteTermAcc" value="" /></td>
        <td><input type="submit" name="Submit" value="Create New"/></td>
    </TR>
</TABLE>
</form>

<p>Total: <%=synonyms.size()%> obsolete GO term(s)</p>

<table class="goTable" border cellpadding="3" cellspacing="1">
    <tr>
        <th>Nr</th>
        <th>Current Term Acc</th>
        <th>Current Term Name</th>
        <th>Obsolete GO Term Acc</th>
        <th>Obsolete Term Name</th>
        <th>Synonym Type</th>
        <th>Source</th>
        <th>Created Date</th>
        <th>Last Modified Date</th>
        <th>&nbsp;</th>
    </tr>
<%
    int nr = 0;
    for( TermSynonym syn : synonyms ) {
        nr++;
        String currentTermName = termNames.getOrDefault(syn.getTermAcc(), "");
        String obsoleteTermName = termNames.getOrDefault(syn.getName(), "");
%>
    <tr>
        <td><%=nr%>.</td>
        <td><%=syn.getTermAcc()%></td>
        <td><%=currentTermName%></td>
        <td class="obsolete"><%=syn.getName()%></td>
        <td class="obsolete"><%=obsoleteTermName%></td>
        <td><%=syn.getType()%></td>
        <td><%=syn.getSource()%></td>
        <td class="created"><%=syn.getCreatedDate()%></td>
        <td><%=syn.getLastModifiedDate()%></td>
        <td><a href="javascript:deleteSyn(<%=syn.getKey()%>,'<%=syn.getTermAcc()%>','<%=syn.getName()%>');">Delete</a></td>
    </tr>
<%
    }
%>
</table>

<h3>Note</h3>
<p>Once a week, on Saturdays, <b>update-secondary-go-id-pipeline</b> will be run.
All GO annotations that are annotated to obsolete GO terms as specified above
will be reassigned to current GO terms, as specified above.</p>

<script>
function deleteSyn(key, termAcc, obsoleteAcc) {
    if( confirm('Are you sure you want to delete synonym "'+obsoleteAcc+'" from term "'+termAcc+'"?') ) {
        if( confirm('Please confirm again: delete synonym "'+obsoleteAcc+'" from term "'+termAcc+'"?') ) {
            window.location.href = '/rgdweb/curation/edit/obsoleteGoTerms.html?delKey='+key;
        }
    }
}
</script>
<%@ include file="/common/footerarea.jsp"%>
