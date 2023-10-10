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
    The following Strains have been annotated to <span class="highlight"><%=displayName%></span>

    <%--  OLD CODE
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

    <table id="relatedRatStrainsTable" style="margin-top: 10px">
        <thead></thead>
        <tbody>

        <%  int si=0;
            for (Strain s : strainList) {
                ++si;
                String scl = si%2==1 ? "report-page-grey" : "";
        %>
        <tr>
            <td class="<%=scl%>">
                <a href="<%=Link.strain(s.getRgdId())%>"><%=s.getSymbol()%></a>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table></div>
<br>

<% } %>

<%@ include file="sectionFooter.jsp"%>
