<%@ page import="edu.mcw.rgd.*" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%--
  Created by IntelliJ IDEA.
  User: mtutaj
  Date: June 21, 2010
  Time: 4:19:11 PM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String pageTitle = " Transcript View - Rat Genome Database";
    String headContent = "";
    String pageDescription = "Transcript view -test";

%>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="pipelineCss.jsp"%>

  <div class="searchBox">
    <h2>Transcript List for RGD_ID=<%=request.getAttribute("id")%></h2>
    <table border="0" width="95%" class="pip">
    <tr>
        <th>Id</th>
        <th>Header</th>
        <th>Symbol</th>
        <th>Map Name</th>
        <th>Chr</th>
        <th>Genomic coordinates</th>
    </tr>
    <c:forEach items="${md}" var="ar" varStatus="it">
        <tr ${ar.attr}>
            <td>${it.index+1}.</td>
            <td>${ar.header}</td>
            <td>${ar.symbol}</td>
            <td>${ar.map}</td>
            <td>${ar.chromosome}</td>
            <td>${ar.coords}</td>
        </tr>
    </c:forEach>
    </table>
   </div>
<%@ include file="/common/footerarea.jsp"%>

