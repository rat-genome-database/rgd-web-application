<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 2/9/24
  Time: 10:02 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% String pageTitle = " AI Test - " ;
String headContent = "";
String pageDescription = "";
%>

<%@ include file="/common/headerarea.jsp"%>

<nav class="navbar navbar-light bg-light">
    <form class="form-inline" action="/rgdweb/ai/output.html">
       PMID: <input class="form-control mr-sm-2" type="search" placeholder="Enter PMID" aria-label="Search" name="pmid" id="pmid">
        <button class="btn btn-outline-success my-2 my-sm-0">Find [disease]---[gene]</button>
</form>
</nav>
<%if(request.getAttribute("output")!=null && request.getAttribute("output").toString().length()>0){%>
<div id="output">
    <h4>Output:</h4>
    <%=request.getAttribute("output")%>
</div>
    <%}%>

<%@ include file="/common/footerarea.jsp"%>
