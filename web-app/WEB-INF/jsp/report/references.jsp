<%@ include file="sectionHeader.jsp"%>

<%
    List<Reference> refs = associationDAO.getReferenceAssociations(obj.getRgdId());
    if (refs.size() > 0 ) {
        // sort references by citation
        Collections.sort(refs, new Comparator<Reference>() {
            public int compare(Reference o1, Reference o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getCitation(), o2.getCitation());
            }
        });
%>


<%=ui.dynOpen("refAssociation", "References - curated")%>    <br>

    <table>
    <%
    int count=1;
    for(Reference ref: refs ) {
    %>
        <tr>
            <td><%=count++%>.</td>
            <td><a href="<%=Link.ref(ref.getRgdId())%>"><%=ref.getCitation()%></a><br></td>
        </tr>
    <%
        }
    %>
    </table>
    <%=ui.dynClose("refAssociation")%>

<% } %>
<%@ include file="sectionFooter.jsp"%>
