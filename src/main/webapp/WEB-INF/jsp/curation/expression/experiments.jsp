<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.datamodel.GeoRecord" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>
<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css'>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">

<style>
    #expressionExperimentsTable{
        border:1px solid #ddd;
        border-radius:2px;
        width: 100%;
        text-align: center;
        font-size: 12px;

    }
    /*#expressionExperimentsTable th{*/
    /*    background: rgb(246,248,249); !* Old browsers *!*/
    /*    background: -moz-linear-gradient(top, rgba(246,248,249,1) 0%, rgba(229,235,238,1) 50%, rgba(215,222,227,1) 51%, rgba(245,247,249,1) 100%); !* FF3.6-15 *!*/
    /*    background: -webkit-linear-gradient(top, rgba(246,248,249,1) 0%,rgba(229,235,238,1) 50%,rgba(215,222,227,1) 51%,rgba(245,247,249,1) 100%); !* Chrome10-25,Safari5.1-6 *!*/
    /*    background: linear-gradient(to bottom, rgba(246,248,249,1) 0%,rgba(229,235,238,1) 50%,rgba(215,222,227,1) 51%,rgba(245,247,249,1) 100%); !* W3C, IE10+, FF16+, Chrome26+, Opera12+, Safari7+ *!*/
    /*    !*filter: progid:DXIma/geTransform.Microsoft.gradient( startColorstr='#f6f8f9', endColorstr='#f5f7f9',GradientType=0 );*!*/
    /*}*/
    #expressionExperimentsTable td{
        max-width: 15px;
        min-width: 5px;
        padding: 2px;
        background-color: inherit;
    }
    #expressionExperimentsTable  tr:nth-child(odd) {background-color: #f2f2f2}
    #ExpressionExperimentsTable tr:hover {
        background-color: #daeffc;
    }
    .pagination-container {
        display: flex;
        justify-content: center;
        align-items: center;
        margin: 15px 0;
        flex-wrap: wrap;
        gap: 5px;
    }
    .pagination-container a, .pagination-container span {
        padding: 8px 12px;
        margin: 2px;
        border: 1px solid #ddd;
        border-radius: 4px;
        text-decoration: none;
        color: #24609c;
    }
    .pagination-container a:hover {
        background-color: #e9ecef;
    }
    .pagination-container .active {
        background-color: #24609c;
        color: white;
        border-color: #24609c;
    }
    .pagination-container .disabled {
        color: #6c757d;
        pointer-events: none;
    }
    .pagination-info {
        text-align: center;
        margin: 10px 0;
        color: #666;
        font-size: 14px;
    }
</style>

<%
    String pageHeader="Create GEO Samples";
    String pageTitle="Create GEO Samples";
    String headContent="Create GEO Samples";
    String pageDescription = "Create GEO Samples";
%>
<%@ include file="/common/headerarea.jsp"%>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.js"> </script>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.widgets.js"></script>

<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.jui.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.blue.css" rel="stylesheet" type="text/css"/>
<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading"><%=pageHeader%></div>
</div>


<html>
<head>
    <title>Create GEO Samples</title>
</head>
<body>

<h2>View GEO Samples</h2>


    <div class="container">
<form action="experiments.html">
    <input type="hidden" value="<%=request.getParameter("token")%>" name="token" />
            <label for="species" style="color: #24609c; font-weight: bold;">Select a Species:</label>
    <select id="species" name="species" >
        <option value="Rattus_norvegicus">Rat</option>
        <option  value="Mus_musculus">Mouse</option>
        <option  value="Homo_sapiens">Human</option>
        <option  value="Chinchilla_lanigera">Chinchilla</option>
        <option  value="Pan_paniscus">Bonobo</option>
        <option  value="Canis_lupus_familiaris">Dog</option>
        <option  value="Ictidomys_tridecemlineatus">Squirrel</option>
        <option value="Sus_scrofa">Pig</option>
        <option value="Heterocephalus_glaber">Naked Mole-Rat</option>
        <option value="Chlorocebus_sabaeus">Green Monkey</option>
        <option value="Rattus_rattus">Black Rat</option>
    </select>

    <label for="status" style="color: #24609c; font-weight: bold;">Select Curation Status:</label>
    <select id="status" name="status" >
        <option  value="pending">Pending</option>
        <option value="loaded">Loaded</option>
        <option  value="not4Curation">Not For Curation</option>
        <option value="futureCuration">Future Curation</option>
    </select>
<br><br>

            <input type="submit" class="btn btn-info btn-md" value="Search">
</form>
</div>
<div class="container-fluid">
    <%
        if(request.getParameter("species") != null) {
            String species = request.getParameter("species");
            species=species.replace("_"," ");
            PhenominerDAO pdao = new PhenominerDAO();
            HashMap<String,GeoRecord> records = pdao.getGeoStudies(species,request.getParameter("status"));

            // Pagination settings
            int recordsPerPage = 100;
            int currentPage = 1;
            String pageParam = request.getParameter("page");
            if(pageParam != null) {
                try {
                    currentPage = Integer.parseInt(pageParam);
                    if(currentPage < 1) currentPage = 1;
                } catch(NumberFormatException e) {
                    currentPage = 1;
                }
            }

            // Convert HashMap keys to List for indexed access
            List<String> gseKeys = new ArrayList<>(records.keySet());
            int totalRecords = gseKeys.size();
            int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
            if(currentPage > totalPages && totalPages > 0) currentPage = totalPages;

            int startIndex = (currentPage - 1) * recordsPerPage;
            int endIndex = Math.min(startIndex + recordsPerPage, totalRecords);

            // Build base URL for pagination links
            String speciesParam = request.getParameter("species");
            String statusParam = request.getParameter("status");
            String tokenParam = request.getParameter("token");
            String baseUrl = "experiments.html?species=" + speciesParam + "&status=" + statusParam + "&token=" + tokenParam;
    %>
            <div class="pagination-info">
                Showing records <%= startIndex + 1 %> - <%= endIndex %> of <%= totalRecords %> total records
            </div>

            <% if(totalPages > 1) { %>
            <div class="pagination-container">
                <% if(currentPage > 1) { %>
                    <a href="<%= baseUrl %>&page=1">&laquo; First</a>
                    <a href="<%= baseUrl %>&page=<%= currentPage - 1 %>">&lsaquo; Previous</a>
                <% } else { %>
                    <span class="disabled">&laquo; First</span>
                    <span class="disabled">&lsaquo; Previous</span>
                <% } %>

                <%
                    // Show page numbers (max 10 pages at a time)
                    int startPage = Math.max(1, currentPage - 4);
                    int endPage = Math.min(totalPages, startPage + 9);
                    if(endPage - startPage < 9) {
                        startPage = Math.max(1, endPage - 9);
                    }

                    for(int i = startPage; i <= endPage; i++) {
                        if(i == currentPage) {
                %>
                            <span class="active"><%= i %></span>
                <%      } else { %>
                            <a href="<%= baseUrl %>&page=<%= i %>"><%= i %></a>
                <%      }
                    }
                %>

                <% if(currentPage < totalPages) { %>
                    <a href="<%= baseUrl %>&page=<%= currentPage + 1 %>">Next &rsaquo;</a>
                    <a href="<%= baseUrl %>&page=<%= totalPages %>">Last &raquo;</a>
                <% } else { %>
                    <span class="disabled">Next &rsaquo;</span>
                    <span class="disabled">Last &raquo;</span>
                <% } %>
            </div>
            <% } %>

            <table class="tablesorter tablesorter-blue hasFilters" id="expressionExperimentsTable">
                <thead><tr>
                    <th>Geo Accession Id</th>
                    <th>PubMed Id</th>
                    <th>Study</th>
                    <th>Curation Status</th>
                    <th>Link to edit</th>
                </tr></thead>
                <tbody>
    <%
            for(int i = startIndex; i < endIndex; i++) {
                String gse = gseKeys.get(i);
                GeoRecord rec = records.get(gse);
                String link = "<a href=/rgdweb/curation/expression/experiments.html?gse="+gse+"&species="+species+" >Edit</a>";
    %>

            <tr>
                <td><a href="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=<%=rec.getGeoAccessionId()%>" target="_blank"><%=rec.getGeoAccessionId()%></a></td>
                <td><%=Utils.NVL(rec.getPubmedId(),"")%></td>
                <td><%=rec.getStudyTitle()%></td>
                <td><%=rec.getCurationStatus()%></td>
                <td><%=link%></td>
            </tr>
    <%
            }
     %>
                </tbody>
        </table>

            <% if(totalPages > 1) { %>
            <div class="pagination-container" style="margin-top: 15px;">
                <% if(currentPage > 1) { %>
                    <a href="<%= baseUrl %>&page=1">&laquo; First</a>
                    <a href="<%= baseUrl %>&page=<%= currentPage - 1 %>">&lsaquo; Previous</a>
                <% } else { %>
                    <span class="disabled">&laquo; First</span>
                    <span class="disabled">&lsaquo; Previous</span>
                <% } %>

                <%
                    int startPage2 = Math.max(1, currentPage - 4);
                    int endPage2 = Math.min(totalPages, startPage2 + 9);
                    if(endPage2 - startPage2 < 9) {
                        startPage2 = Math.max(1, endPage2 - 9);
                    }

                    for(int i = startPage2; i <= endPage2; i++) {
                        if(i == currentPage) {
                %>
                            <span class="active"><%= i %></span>
                <%      } else { %>
                            <a href="<%= baseUrl %>&page=<%= i %>"><%= i %></a>
                <%      }
                    }
                %>

                <% if(currentPage < totalPages) { %>
                    <a href="<%= baseUrl %>&page=<%= currentPage + 1 %>">Next &rsaquo;</a>
                    <a href="<%= baseUrl %>&page=<%= totalPages %>">Last &raquo;</a>
                <% } else { %>
                    <span class="disabled">Next &rsaquo;</span>
                    <span class="disabled">Last &raquo;</span>
                <% } %>
            </div>
            <% } %>
    <%
        }
    %>
</div>
</body>
</html>

<%@ include file="/common/footerarea.jsp"%>
<script>
    tableSorterReport();
    function tableSorterReport() {
        $(function () {
            $('#expressionExperimentsTable')
                .tablesorter({
                    theme: 'grey',
                    widget: ['zebra']
                });
        });
    }
</script>