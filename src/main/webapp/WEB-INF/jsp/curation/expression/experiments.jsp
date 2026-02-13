<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.datamodel.GeoRecord" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    boolean isAjax = "1".equals(request.getParameter("ajax"));

    // Data section: compute pagination if species is present
    String species = request.getParameter("species");
    String speciesDisplay = null;
    HashMap<String,GeoRecord> records = null;
    List<String> gseKeys = null;
    int totalRecords = 0;
    int recordsPerPage = 100;
    int currentPage = 1;
    int totalPages = 0;
    int startIndex = 0;
    int endIndex = 0;

    if(species != null) {
        speciesDisplay = species.replace("_"," ");
        PhenominerDAO pdao = new PhenominerDAO();
        records = pdao.getGeoStudies(speciesDisplay, request.getParameter("status"));
        gseKeys = new ArrayList<>(records.keySet());

        // Apply search filter if present
        String searchTerm = request.getParameter("search");
        if(searchTerm != null && !searchTerm.trim().isEmpty()) {
            searchTerm = searchTerm.trim();
            String searchLower = searchTerm.toLowerCase();
            List<String> filtered = new ArrayList<>();
            for(String gse : gseKeys) {
                GeoRecord rec = records.get(gse);
                if((rec.getGeoAccessionId() != null && rec.getGeoAccessionId().toLowerCase().contains(searchLower)) ||
                   (rec.getPubmedId() != null && rec.getPubmedId().toLowerCase().contains(searchLower)) ||
                   (rec.getStudyTitle() != null && rec.getStudyTitle().toLowerCase().contains(searchLower))) {
                    filtered.add(gse);
                }
            }
            gseKeys = filtered;
        }

        totalRecords = gseKeys.size();
        totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);

        String pageParam = request.getParameter("page");
        if(pageParam != null) {
            try {
                currentPage = Integer.parseInt(pageParam);
                if(currentPage < 1) currentPage = 1;
            } catch(NumberFormatException e) {
                currentPage = 1;
            }
        }
        if(currentPage > totalPages && totalPages > 0) currentPage = totalPages;

        startIndex = (currentPage - 1) * recordsPerPage;
        endIndex = Math.min(startIndex + recordsPerPage, totalRecords);
    }
%>
<% if(!isAjax) { %>
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
<% if(species != null) { %>
<div style="margin: 15px 0; display: flex; align-items: center; gap: 10px;">
    <label for="tableSearch" style="color: #24609c; font-weight: bold; margin: 0;">Search results:</label>
    <input type="text" id="tableSearch" placeholder="Filter by Accession ID, PubMed ID, or Study Title..."
           style="padding: 6px 12px; border: 1px solid #ccc; border-radius: 4px; width: 400px; font-size: 13px;"
           value="<%= request.getParameter("search") != null ? request.getParameter("search").replace("\"", "&quot;") : "" %>" />
    <button id="searchBtn" class="btn btn-info btn-sm">Go</button>
    <button id="clearSearchBtn" class="btn btn-outline-secondary btn-sm">Clear</button>
</div>
<% } %>
<div id="dataContainer">
<% } %>
<%-- ========== DATA SECTION (returned for both full page and AJAX) ========== --%>
<% if(species != null && records != null) {
    String statusParam = request.getParameter("status");
    String tokenParam = request.getParameter("token");
    String searchParam = request.getParameter("search");
    String baseUrl = "experiments.html?species=" + species + "&status=" + statusParam + "&token=" + tokenParam;
    if(searchParam != null && !searchParam.trim().isEmpty()) {
        baseUrl += "&search=" + java.net.URLEncoder.encode(searchParam.trim(), "UTF-8");
    }
%>
            <div class="pagination-info">
                Showing records <%= startIndex + 1 %> - <%= endIndex %> of <%= totalRecords %> <% if(searchParam != null && !searchParam.trim().isEmpty()) { %>matching<% } else { %>total<% } %> records
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
                String link = "<a href=/rgdweb/curation/expression/experiments.html?gse="+gse+"&species="+speciesDisplay+" >Edit</a>";
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
<%-- ========== END DATA SECTION ========== --%>
<% if(!isAjax) { %>
</div>
</div>
</body>
</html>

<%@ include file="/common/footerarea.jsp"%>
<script>
    // Initialize tablesorter on the current page of rows
    $(function () {
        var $table = $('#expressionExperimentsTable');
        if ($table.length) {
            $table.tablesorter({ theme: 'grey', widgets: ['zebra'] });
        }
    });

    // AJAX pagination: intercept pagination link clicks
    $(document).on('click', '.pagination-container a', function (e) {
        e.preventDefault();
        var url = $(this).attr('href');
        if (!url || url === '#') return;

        // Add ajax=1 parameter
        url += '&ajax=1';

        $('#dataContainer').css('opacity', '0.5');
        $.get(url, function (html) {
            $('#dataContainer').html(html).css('opacity', '1');
            // Re-init tablesorter on fresh table
            var $table = $('#expressionExperimentsTable');
            if ($table.length) {
                $table.tablesorter({ theme: 'grey', widgets: ['zebra'] });
            }
            // Scroll to table
            var tableTop = $('#dataContainer').offset();
            if (tableTop) window.scrollTo(0, tableTop.top - 20);
        });
    });

    // Build base URL from current form params
    function getBaseUrl() {
        var params = new URLSearchParams(window.location.search);
        return 'experiments.html?species=' + encodeURIComponent(params.get('species') || '') +
               '&status=' + encodeURIComponent(params.get('status') || '') +
               '&token=' + encodeURIComponent(params.get('token') || '');
    }

    // Search button click
    $('#searchBtn').on('click', function () {
        var term = $('#tableSearch').val().trim();
        var url = getBaseUrl() + '&page=1&ajax=1';
        if (term) url += '&search=' + encodeURIComponent(term);
        $('#dataContainer').css('opacity', '0.5');
        $.get(url, function (html) {
            $('#dataContainer').html(html).css('opacity', '1');
            var $table = $('#expressionExperimentsTable');
            if ($table.length) {
                $table.tablesorter({ theme: 'grey', widgets: ['zebra'] });
            }
        });
    });

    // Allow Enter key in search box
    $('#tableSearch').on('keypress', function (e) {
        if (e.which === 13) {
            e.preventDefault();
            $('#searchBtn').click();
        }
    });

    // Clear search
    $('#clearSearchBtn').on('click', function () {
        $('#tableSearch').val('');
        var url = getBaseUrl() + '&page=1&ajax=1';
        $('#dataContainer').css('opacity', '0.5');
        $.get(url, function (html) {
            $('#dataContainer').html(html).css('opacity', '1');
            var $table = $('#expressionExperimentsTable');
            if ($table.length) {
                $table.tablesorter({ theme: 'grey', widgets: ['zebra'] });
            }
        });
    });
</script>
<% } %>
