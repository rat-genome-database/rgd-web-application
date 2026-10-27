<%@ page import="edu.mcw.rgd.datamodel.pheno.Study" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    String pageHeader="Studies Missing References";
    String pageTitle="Studies Missing References";
    String headContent="";
    String pageDescription = "Studies with a PubMed ID in RNA_SEQ but no entry in STUDY_REFERENCES";

    LinkedHashMap<Study, List<String>> studies = (LinkedHashMap<Study, List<String>>) request.getAttribute("studies");
    Map<String, Integer> refRgdIds = (Map<String, Integer>) request.getAttribute("refRgdIds");
%>
<%@ include file="/common/headerarea.jsp"%>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.js"> </script>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.widgets.js"></script>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.blue.css" rel="stylesheet" type="text/css"/>

<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading"><%=pageHeader%></div>
</div>

<div class="container-fluid">
    <p>Studies whose GEO series has a PubMed ID in RNA_SEQ but no entry in STUDY_REFERENCES:
        <b><%=studies.size()%></b> studies.
        A PubMed ID with no RGD reference has to be imported before it can be linked to the study.</p>
<%
    int studiesToFix = 0;
    int referencesToAdd = 0;
    for( List<String> studyPmids: studies.values() ) {
        java.util.Set<Integer> studyRefRgdIds = new java.util.HashSet<>();
        for( String pmid: studyPmids ) {
            if( refRgdIds.get(pmid) != null ) {
                studyRefRgdIds.add(refRgdIds.get(pmid));
            }
        }
        if( !studyRefRgdIds.isEmpty() ) {
            studiesToFix++;
            referencesToAdd += studyRefRgdIds.size();
        }
    }
    String token = request.getParameter("token");
%>
    <form method="post" action="missingStudyReferences.html"
          onsubmit="return confirm('Add <%=referencesToAdd%> study references to <%=studiesToFix%> studies?');">
        <input type="hidden" name="act" value="fixAll"/>
        <% if( token != null ) { %><input type="hidden" name="token" value="<%=org.apache.commons.text.StringEscapeUtils.escapeHtml4(token)%>"/><% } %>
        <button type="submit" class="btn btn-info btn-md" <%=referencesToAdd==0 ? "disabled" : ""%>>
            Fix All: add <%=referencesToAdd%> study references to <%=studiesToFix%> studies</button>
        <span style="margin-left:10px;">PubMed IDs that are not in RGD are skipped.</span>
    </form>
    <br>

    <table id="missingStudyReferences" class="tablesorter">
        <thead><tr>
            <th>Study ID</th>
            <th>Study Name</th>
            <th>GEO Series</th>
            <th>Source</th>
            <th>Type</th>
            <th>PubMed ID</th>
            <th>RGD Reference</th>
        </tr></thead>
        <tbody>
<%
    for( Map.Entry<Study, List<String>> entry: studies.entrySet() ) {
        Study study = entry.getKey();
        StringBuilder pmidLinks = new StringBuilder();
        StringBuilder refLinks = new StringBuilder();
        for( String pmid: entry.getValue() ) {
            if( pmidLinks.length() > 0 ) {
                pmidLinks.append("<br>");
                refLinks.append("<br>");
            }
            pmidLinks.append("<a href=\"https://pubmed.ncbi.nlm.nih.gov/").append(pmid).append("/\" target=\"_blank\">").append(pmid).append("</a>");
            Integer refRgdId = refRgdIds.get(pmid);
            if( refRgdId != null ) {
                refLinks.append("<a href=\"/rgdweb/report/reference/main.html?id=").append(refRgdId).append("\" target=\"_blank\">RGD:").append(refRgdId).append("</a>");
            } else {
                refLinks.append("not in RGD");
            }
        }
        String gse = Utils.NVL(study.getGeoSeriesAcc(), "");
%>
            <tr>
                <td><%=study.getId()%></td>
                <td><%=Utils.NVL(study.getName(), "")%></td>
                <td><a href="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=<%=gse%>" target="_blank"><%=gse%></a></td>
                <td><%=Utils.NVL(study.getSource(), "")%></td>
                <td><%=Utils.NVL(study.getType(), "")%></td>
                <td><%=pmidLinks%></td>
                <td><%=refLinks%></td>
            </tr>
<%
    }
%>
        </tbody>
    </table>
</div>

<script>
    $(function() {
        $('#missingStudyReferences').tablesorter({ theme: 'blue', widgets: ['zebra'] });
    });
</script>

<%@ include file="/common/footerarea.jsp"%>
