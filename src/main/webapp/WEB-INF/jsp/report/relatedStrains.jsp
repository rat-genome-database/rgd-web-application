<%@ page import="edu.mcw.rgd.reporting.Link" %>

<%@ include file="sectionHeader.jsp"%>

<%

List<Strain> strainList = strainDAO.getAssociatedStrains(obj.getRgdId());
if (strainList.size() > 0) {

    // sort strains by symbol
    Collections.sort(strainList, new Comparator<Strain>() {
        public int compare(Strain o1, Strain o2) {
            return Utils.stringsCompareToIgnoreCase(o1.getSymbol(), o2.getSymbol());
        }
    });
%>

<br>
<div class="reportTable light-table-border" id="relatedRatStrainsTableWrapper">
    <div class="sectionHeading" id="relatedRatStrains">Related Rat Strains</div>
    <div style="padding-top:10px; padding-bottom:10px">The following Strains have been annotated to <span class="highlight"><%=displayName%></span></div>

    <%--  OLD CODE (makes the report page broken)
    <div id="relatedRatStrainsTable">
    <%
        List records = new ArrayList();
        for (Strain s : strainList) {
            records.add("\n<tr><td><a href=\"" + Link.strain(s.getRgdId()) + "\">" + s.getSymbol() + "</a></td></tr>");
        }
        out.print(formatter.buildTable(records, 4));
    %>
    </div>
    --%>

    <div id="relatedRatStrainsTable" style="border: 1px solid black; padding: 10px;" class="report-page-grey">

        <% for (Strain s : strainList) { %>
               <span style="white-space: pre"><a href="<%=Link.strain(s.getRgdId())%>"><%=s.getSymbol()%></a></span> &nbsp; &nbsp;
        <% } %>
    </div>
</div>
<br>

<% } %>

<%@ include file="sectionFooter.jsp"%>
