<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<br><br.

Received the following
<%
    String dest=request.getParameter("dest");
    String loc = request.getParameter("loc");
    String assembly = request.getParameter("assembly");
%>

<table>
    <tr>
        <td>dest: </td><td><%=dest%></td>
        <td>loc: </td><td><%=loc%></td>
        <td>assembly: </td><td><%=assembly%></td>
    </tr>
</table>

<a href="https://rgd.mcw.edu/jbrowse2/index.html?config=config.json&assembly=<%=assembly%>&loc=<%=loc%>>&tracks=Rat mRatBN7.2 (rn7) Genes and Transcripts-mRatBN7.2">Continue to JBrowse2</a>


