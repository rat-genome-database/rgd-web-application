<%@ page import="edu.mcw.rgd.datamodel.pheno.Study" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.Record" %>
<%@ page import="edu.mcw.rgd.process.Stamp" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %>
<%
    String pageTitle = "Studies";
    String headContent = "";
    String pageDescription = "";
%>
<%@ include file="editHeader.jsp"%>

<style>
    #studiesContainer table {
        width: 100%;
        /*max-width: 100vw;*/
        border-collapse: collapse;
        margin-bottom: 1em; /* Add some space between each table */
    }

    #studiesContainer table th,
    #studiesContainer table td {
        border: 1px solid #ddd;
        padding: 8px;
        text-align: left;
    }

    .pagination-bar {
        display: flex;
    }

    .studies-range {
        white-space: nowrap;
        align-self: center;
    }


    .pagination-container {
        text-align: center; /* Center the pagination */
        margin-top: 0px;
        width: 100%;
    }

    .pagination {
        display: inline-block;
        list-style-type: none;
    }

    .pagination li {
        display: inline-block;
        margin-right: 3px; /* Spacing between page numbers */
    }

    .pagination li a {
        text-decoration: none;
        color: black;
        padding: 5px 10px;
        border: 1px solid #99BFE6;
        border-radius: 5px;
    }

    .pagination li.active a {
        background-color: #2865A3;
        color: white;
        border-color: #2865A3;
    }

</style>

<span class="phenominerPageHeader">Phenominer Studies</span>
<div class="phenoNavBar">
<table >
    <tr>
        <td><a href='javascript:edit("studyId");'>Edit</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='javascript:editExperiments("studyId");'>Show Experiments</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='javascript:del("studyId")'>Delete</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='javascript:selectAll("studyId")'>Toggle All</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='studies.html?act=new'>Create New Study</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='home.html'>Home</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='search.html?act=new'>Search</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='studies.html'>List All Studies</a></td>
    </tr>
</table>
</div>
<%
    int totalNumberOfPages = (Integer) request.getAttribute("totalNumberOfPages");
    int currentPage = (Integer) request.getAttribute("currentPage");
    int firstStudy = (Integer) request.getAttribute("firstStudy");
    int lastStudy = (Integer) request.getAttribute("lastStudy");
%>
<div class="pagination-bar">
    <p class="studies-range" style="font-size: 15px;"><b>Showing Studies from <%=firstStudy%> to <%=lastStudy%></b></p>
<div class="pagination-container">
    <ul class="pagination">
        <% if(currentPage > 1) { %>
        <li><a href="studies.html?page=<%= currentPage - 1 %>">Previous</a></li>
        <% } %>

        <% for(int i = 1; i <= totalNumberOfPages; i++) { %>
        <li class="<%= (i == currentPage) ? "active" : "" %>">
            <a href="studies.html?page=<%= i %>"><%= i %></a>
        </li>
        <% } %>

        <% if(currentPage < totalNumberOfPages) { %>
        <li><a href="studies.html?page=<%= currentPage + 1 %>">Next</a></li>
        <% } %>
    </ul>
</div>
</div>
<form name="form1" action="studies.html" method="get">

<input type="hidden" name="act" value=""/>
<%
    Report report = (Report) request.getAttribute("report");

    HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
    strat.setTableProperties("class='sortable'");%>
    <div id="studiesContainer">
        <%= report.format(strat) %>
    </div>
</form>
<div class="pagination-container">
    <ul class="pagination">
        <% if(currentPage > 1) { %>
        <li><a href="studies.html?page=<%= currentPage - 1 %>">Previous</a></li>
        <% } %>

        <% for(int i = 1; i <= totalNumberOfPages; i++) { %>
        <li class="<%= (i == currentPage) ? "active" : "" %>">
            <a href="studies.html?page=<%= i %>"><%= i %></a>
        </li>
        <% } %>

        <% if(currentPage < totalNumberOfPages) { %>
        <li><a href="studies.html?page=<%= currentPage + 1 %>">Next</a></li>
        <% } %>
    </ul>
</div>

<%@ include file="editFooter.jsp"%>
