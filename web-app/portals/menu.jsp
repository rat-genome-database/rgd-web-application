<%@ page import="edu.mcw.rgd.dao.impl.PortalDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.PortalTermSet" %>
<div id="menu" style="height:600px;overflow-y:auto; width:230px; border: 1px solid black; padding: 3px; background-color:#F0F6F9;">

<table border=0>

    <a href="">All</a><br>

<%

    int key = Integer.parseInt(req.getParameter("key"));
    List<PortalTermSet> terms = pdao.getTopLevelPortalTermSet(key);

    for (PortalTermSet pts: terms) {
        int objectCount=adao.getAnnotatedObjectCount(pts.getTermAcc(),true);
%>
    <tr>
        <td><li></li></td>
        <td colspan=3><a style="font-size:10px;" href='content.jsp?key=<%=pts.getPortalKey()%>&term=<%=pts.getTermAcc()%>'><%=pts.getOntTermName()%>&nbsp;(<%=objectCount%>)</a><br></td>

    </tr>
<%
        List<PortalTermSet> children = pdao.getPortalTermSet(pts.getPortalTermSetId(), key);
        for (PortalTermSet child: children) {
            objectCount=adao.getAnnotatedObjectCount(child.getTermAcc(),true);
            if (objectCount > 0) {

%>

            <tr>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td><li></li></td>
                <td style="font-size:10px;"><a style="font-size:11px;" href='content.jsp?key=<%=child.getPortalKey()%>&term=<%=child.getTermAcc()%>'><%=child.getOntTermName()%>&nbsp;(<%=objectCount%>)</a></td>
            </tr>

<%
            }
        }

    }
%>
</table>

</div>
