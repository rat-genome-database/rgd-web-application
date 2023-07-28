<%@ page import="edu.mcw.rgd.dao.impl.ProjectDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="java.util.List" %>
<%--<jsp:useBean id="allProjects" scope="request" class="java.util.ArrayList" />--%>
<%
    String pageTitle = "Rat Genome Database Projects";
    String headContent = "";
    String pageDescription = "Rat Genome Database Projects";
%>
<%@ include file="/common/headerarea.jsp"%>
<style>
    h1{
        text-align: center;
        margin-bottom: 50px;
    }
    h2{
        text-align: center;
    }
</style>
<body>
<% List<Project> pro = (List<Project>)request.getAttribute("project");%>
<h1>Welcome!</h1>
<%for(Project i:pro){%>
<h2><%=i.getDesc()%></h2>
<%}%>
</body>
<%@ include file="/common/footerarea.jsp"%>