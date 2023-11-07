<%@ page import="edu.mcw.rgd.dao.impl.ProjectDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="java.util.List" %>
<%--<jsp:useBean id="allProjects" scope="request" class="java.util.ArrayList" />--%>
<%
    String pageTitle = "Rat Genome Database Projects";
    String headContent = "";
    String pageDescription = "Rat Genome Database Projects";


%>

<style>
    body {
        font-family: Arial, sans-serif;
    }
    .test{
        color:black;
    }
    h1 {
        color: #0066cc;
        text-align: center;
    }

    table .pro{
        width: 100%;
        border-collapse: collapse;
    }

    .he{
        padding: 20px;
        text-align: left;
        border-bottom: 1px solid #ddd;
    }

    th {
        background-color: #6693C8;
    }

    #b:hover {
        background-color: #E6EEF7;
    }
    /*.footer {*/
    /*    background-color: #333;*/
    /*    color: #fff;*/
    /*    padding: 2px;*/
    /*    !*margin-top: 50px;*!*/
    /*    text-align: center;*/
    /*}*/

    /*.footer a {*/
    /*    color: #fff;*/
    /*    text-decoration: none;*/
    /*}*/

</style>
<%--<%   ProjectDAO pdao = new ProjectDAO();--%>
<%--List<Project> pro = pdao.getAllProjects();--%>
<%--%>--%>
<%@ include file="/common/headerarea.jsp"%>
<h1 class="test"> Scientific Community Projects</h1>
<body>

<hr>
<table class="pro">
<tr id="a">
    <th class="he">Project ID</th>
    <th class="he">Project Name</th>
    <th class="he">Project Description</th>
</tr>

    <%
        List<Project>p1 = (List<Project>)request.getAttribute("test");
//        List<Project> p=(List<Project>)allProjects;
        for(Project i:p1){%>
    <tr id="b">
        <td class="he"><a href="/rgdweb/report/project/main.html?id=<%= i.getRgdId() %>">RGD:<%= i.getRgdId() %></a></td>
        <td class="he"><%= i.getName() %></td>
        <td class="he"><%= i.getDesc() %></td>
    </tr>
    <%}
    %>
</table>
<%--<footer class="footer">--%>
<%--    <p> 2023 RGD Website. All rights reserved. | <a href="#">Privacy Policy</a> | <a href="#">Terms of Service</a></p>--%>
<%--</footer>--%>
<%@ include file="/common/footerarea.jsp"%>
</body>



