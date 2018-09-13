<%@ page import="edu.mcw.rgd.datamodel.Strain" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.Collections" %>
<%-- to be included as a line in info.jsp --%>
<%
    List<Strain> relatedStrains = associationDAO.getAssociatedStrainsForMasterRgdId(obj.getRgdId(), "cellline_to_strain");
    if( relatedStrains.size() > 0 ) {

        // sort by strain symbol
        Collections.sort(relatedStrains, new Comparator<Strain>() {
            public int compare(Strain o1, Strain o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getSymbol(), o2.getSymbol());
            }
        });
%>
        <tr>
            <td class="label">Related Strains:</td>
            <td><%
            for( Strain ge: relatedStrains) {
            %>
                <a href="<%=Link.strain(ge.getRgdId())%>"><%=ge.getSymbol()%></a> &nbsp;<%
         }%></td>
        </tr>
<%}%>