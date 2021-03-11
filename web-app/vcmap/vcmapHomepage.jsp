<%--
  Creat ed by IntelliJ IDEA.
  User: kthorat
  Date: 1/11/2021
  Time: 1:46 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="bioneos.vcmap.VCMap" %>
<html>
<head>
    <title>VCMap</title>
</head>
<%
    String pageHeader = "VCMAP";
    String pageTitle = "VCMap";
    String headContent = "VCMap";
    String pageDescription = "VCMap";
%>

<body>
<jsp:useBean id="link" scope="application" class = "bioneos.vcmap.VCMap" />
<%@ include file="/common/headerarea.jsp" %>
<%
    String[] args = new String[1];
    args[0] = "-d";
    VCMap.main(args);
%>
<%@ include file="/common/footerarea.jsp" %>
</body>
</html>
