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

    .spinner {
        border: 4px solid #99BFE6;
        border-top: 4px solid #2865A3;
        border-radius: 50%;
        width: 20px;
        height: 20px;
        animation: spin 1s linear infinite;
    }

    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

    #loadMoreBtn {
        background-color: #2865A3;
        color: white;
        padding: 10px 20px;
        border: none;
        border-radius: 5px;
        font-size: 16px;
        cursor: pointer;
        transition: background-color 0.3s, transform 0.3s;
    }

    #loadMoreBtn:hover {
        background-color: #99BFE6;
        transform: scale(1.05);
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
<div style="display: flex; justify-content: center;align-items: center;">
    <button id="loadMoreBtn">Load More</button>
    <div id="loadingSpinner" style="display: none;">
        <div class="spinner"></div>
    </div>
</div>
<script>
    var currentPage = 1;
    var pageSize = 100;
    var totalRecords = <%= request.getAttribute("totalRecords") %>;
    document.getElementById('loadMoreBtn').addEventListener('click', function() {
        var loadMoreBtn = document.getElementById('loadMoreBtn');
        var loadingSpinner = document.getElementById('loadingSpinner');
        currentPage++;
        loadMoreBtn.style.display = 'none'; // Hide the button
        loadingSpinner.style.display = 'inline-block'; // Show the spinner
        fetchStudies(currentPage, pageSize);
        nextMaxRecordCount = (currentPage) * pageSize;

        function fetchStudies(page, size) {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', 'studies.html?page=' + page + '&size=' + size + '&ajax=true', true);
            xhr.onload = function() {
                loadingSpinner.style.display = 'none';
                if (this.status == 200) {
                    document.getElementById('studiesContainer').innerHTML += this.responseText;
                    loadMoreBtn.style.display = ((currentPage * pageSize) >= totalRecords) ? 'none' : 'inline-block';
                } else {
                    console.error('Error fetching data:', this.statusText);
                    loadMoreBtn.style.display = 'inline-block';
                }
            };
            xhr.onerror = function() {
                loadingSpinner.style.display = 'none';
                loadMoreBtn.style.display = 'inline-block';
                console.error('Request failed');
            };
            xhr.send();
        }

    });
</script>
<%@ include file="editFooter.jsp"%>
