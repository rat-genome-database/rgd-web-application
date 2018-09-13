<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<table width="95%" style="padding-top:10px;" border="0">
    <tr>
        <% if( RgdContext.isChinchilla(request) ) { %>
        <td style="font-size:20px; color:#96151d; font-weight:700;"><%=pageHeader%></td>
        <% } else { %>
        <td style="font-size:20px; color:#2865A3; font-weight:700;"><%=pageHeader%></td>
        <% } %>

        <% if( tutorialLink!=null && !tutorialLink.isEmpty() && !RgdContext.isChinchilla(request) ) { %>
        <td align="right">
                    <a  href="<%=tutorialLink%>"><img src="http://rgd.mcw.edu/common/images/tutorial.png" border=0/></a>
        </td>
        <% } %>
    </tr>
</table>
