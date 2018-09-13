<%-- include into Molecular Pathway Annotations section --%>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%
    Collections.sort(xdbKeggPathways, new Comparator<XdbId>() {
        public int compare(XdbId o1, XdbId o2) {
            return Utils.defaultString(o1.getXdbKey()+o1.getLinkText()).compareToIgnoreCase(Utils.defaultString(o2.getXdbKey()+o2.getLinkText()));
        }
    });
%>
<h4>External Pathway Database Links</h4>

<table border="0" >
<%  int kRow = 0;

    for (XdbId xid: xdbKeggPathways) {

        int xdbKey = xid.getXdbKey();
        String xdbName = xdbDAO.getXdbName(xdbKey);
        String url = xdbDAO.getXdbUrl(xdbKey, obj.getSpeciesTypeKey());

        kRow++;
        String link = Utils.NVL(xid.getLinkText(), xid.getAccId());
        String bkColorKegg = kRow%2==1 ? "#e2e2e2" : "#f4f4f4";
%>
    <tr>
        <%  if( kRow==1 ) { %>
        <td style="background-color:<%=bkColorKegg%>;font-weight:bold;"><%=xdbName%></td>
        <% } else { %>
        <td style="background-color:<%=bkColorKegg%>;"></td>
        <% } %>

        <td style="background-color:<%=bkColorKegg%>;">
            <a href="<%=url%><%=xid.getAccId()%>"><%=link%></a>
        </td>
    </tr>
    <% } %>

</table>
<br>