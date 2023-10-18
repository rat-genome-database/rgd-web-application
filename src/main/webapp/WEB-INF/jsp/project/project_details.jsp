<%@ page import="edu.mcw.rgd.dao.impl.ProjectDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="java.util.List" %>
<jsp:useBean id="project" scope="request" class="java.util.ArrayList" />
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
<%--<% List<Project> pro = (List<Project>)request.getAttribute("project");%>--%>
<% List<Project> pro=(List<Project>)project;%>
<h1>Welcome!</h1>
<%for(Project i:pro){%>
<h2><%=i.getDesc()%></h2>
<%}%>
<%--<%@ include file="../report/references.jsp"%>--%>
</body>
<%@ include file="/common/footerarea.jsp"%>