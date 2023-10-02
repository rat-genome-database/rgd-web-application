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
<div id="relatedRatStrainsTableDiv" class="light-table-border">
    <div class="sectionHeading" id="relatedRatStrains">Related Rat Strains</div>
    The following Strains have been annotated to <span class="highlight"><%=displayName%></span>

    <div id="relatedRatStrainsTableWrapper">
    <%
        List records = new ArrayList();
        for (Strain s : strainList) {
            records.add("<tr><td><a href=\"" + Link.strain(s.getRgdId()) + "\">" + s.getSymbol() + "</a></td></tr>");
        }
        out.print(formatter.buildTable(records, 4));
    %>
    </div>
</div>
<br>

<% } %>

<%@ include file="sectionFooter.jsp"%>
