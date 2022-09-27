<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.GeoRecord" %>
<%@ page import="java.util.HashMap" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
<style>
    #t{
        border:1px solid #ddd;
        border-radius:2px;
        width: 100%;
        text-align: center;
        font-size: 12px;

    }
    #t th{
        background: rgb(246,248,249); /* Old browsers */
        background: -moz-linear-gradient(top, rgba(246,248,249,1) 0%, rgba(229,235,238,1) 50%, rgba(215,222,227,1) 51%, rgba(245,247,249,1) 100%); /* FF3.6-15 */
        background: -webkit-linear-gradient(top, rgba(246,248,249,1) 0%,rgba(229,235,238,1) 50%,rgba(215,222,227,1) 51%,rgba(245,247,249,1) 100%); /* Chrome10-25,Safari5.1-6 */
        background: linear-gradient(to bottom, rgba(246,248,249,1) 0%,rgba(229,235,238,1) 50%,rgba(215,222,227,1) 51%,rgba(245,247,249,1) 100%); /* W3C, IE10+, FF16+, Chrome26+, Opera12+, Safari7+ */
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f6f8f9', endColorstr='#f5f7f9',GradientType=0 );
    }
    #t td{
        max-width: 15px;
        min-width: 5px;
        padding: 2px;

    }
    #t  tr:nth-child(odd) {background-color: #f2f2f2}
    #t tr:hover {
        background-color: #daeffc;
    }

</style>

<%
    String pageHeader="Create GEO Samples";
    String pageTitle="Create GEO Samples";
    String headContent="Create GEO Samples";
    String pageDescription = "Create GEO Samples";
%>
<%@ include file="/common/headerarea.jsp"%>
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
            <label for="species" style="color: #24609c; font-weight: bold;">Select a Species:</label>
    <select id="species" name="species" >
        <option value="Rattus">Rat</option>
        <option  value="Mus">Mouse</option>
        <option  value="Homo">Human</option>
        <option  value="Chinchilla">Chinchilla</option>
        <option  value="Pan">Bonobo</option>
        <option  value="Canis">Dog</option>
        <option  value="Ictidomys">Squirrel</option>
        <option value="Sus">Pig</option>
        <option value="Glaber">Naked Mole-Rat</option>
        <option value="Sabaeus">Green Monkey</option>

    </select>

    <label for="status" style="color: #24609c; font-weight: bold;">Select Curation Status:</label>
    <select id="status" name="status" >
        <option  value="pending">Pending</option>
        <option value="loaded">Loaded</option>
        <option  value="not4Curation">Not For Curation</option>
    </select>
<br><br>

            <input type="submit" class="btn btn-info btn-md" value="Search">
</form>
</div>
<div class="container-fluid">
    <%
        if(request.getParameter("species") != null) {
            String species = request.getParameter("species");
            PhenominerDAO pdao = new PhenominerDAO();
            HashMap<String,GeoRecord> records = pdao.getGeoStudies(species,request.getParameter("status"));
            System.out.println(records.size());

    %>
            <table id="t">
                <tr>
                    <th>
                        Geo Accession Id
                    </th>
                    <th>PubMed Id</th>
                    <th>Study</th>
                    <th>Curation Status</th>
                    <th>Link to edit</th>
                </tr>
    <%
            for(String gse: records.keySet()) {
                GeoRecord rec = records.get(gse);
                String link = "<a href=/rgdweb/curation/expression/experiments.html?gse="+gse+"&species="+species+" >Edit</a>";
    %>

            <tr>
                <td><a href="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=<%=rec.getGeoAccessionId()%>" target="_blank"><%=rec.getGeoAccessionId()%></a></td>
                <td><%=rec.getPubmedId()%></td>
                <td><%=rec.getStudyTitle()%></td>
                <td><%=rec.getCurationStatus()%></td>
                <td><%=link%></td>
            </tr>
    <%
            }
     %>
        </table>
    <%
        }
    %>
</div>
</body>
</html>

<%@ include file="/common/footerarea.jsp"%>
