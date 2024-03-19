<%@ page import="edu.mcw.rgd.*" %>
<%@ page import="java.util.*" %>
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 30, 2008
  Time: 4:19:11 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<% try { %>

<%
    String pageTitle = " Pipeline logs - Rat Genome Database";
    String headContent = "";
    String pageDescription = "Access database logs of any pipeline";

%>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="pipelineCss.jsp"%>

  <div class="searchBox">
    <h2>Pipeline List</h2>
    Click on the name of the pipeline you would like to see.
    <table border="0" width="95%" class="pip">
 <%
    Report report = (Report) request.getAttribute("report");
    int rowno = 0;
    Iterator it = report.iterator();
    Record header = null;
    if( it.hasNext() )
      header = (Record) it.next();
    if( header!=null ) {
 %>
    <tr>
        <th><%= header.get(0)%></th>
        <th><%= header.get(1)%></th>
        <th><%= header.get(2)%></th>
    </tr>
<%
    }
    while( it.hasNext() ) {
      Record rec = (Record) it.next();
      if( ++rowno%2==1 ) {
%>  <tr class="alt"><% } else { %><tr><% } %>
         <td><%=rec.get(0)%></td>
         <td><a href="list.html?pkey=<%=rec.get(0)%>"><%=rec.get(1)%></a></td>
         <td><%=rec.get(2)%></td>
     </tr>
<%  } %>
    </table>
   </div>
<%@ include file="/common/footerarea.jsp"%>

<% }catch (Exception e) {
    e.printStackTrace();
   }
%>