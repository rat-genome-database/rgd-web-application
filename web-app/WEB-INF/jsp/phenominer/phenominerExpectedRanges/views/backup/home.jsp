<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>

<% String pageTitle = " Phenominer Expected Ranges - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "";
%>
<%@ include file="/common/headerarea.jsp"%>
<!-- Bootstrap CSS CDN -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">

<!-- Our Custom CSS -->
<link href="/rgdweb/css/expectedRanges/range.css" type="text/css" rel="stylesheet">
<style>
    .wrapper1 {
        display: flex;
        align-items: stretch;
    }

    #sidebar {
        min-width: 250px;
        max-width: 250px;
        min-height: 100vh;
    }

    #sidebar.active {
        margin-left: -250px;
    }

    a[data-toggle="collapse"] {
        position: relative;
    }

    a[aria-expanded="false"]::before, a[aria-expanded="true"]::before {
        content: '\e259';
        display: block;
        position: absolute;
        right: 20px;
        font-family: 'Glyphicons Halflings', serif;
        font-size: 0.6em;
    }

    a[aria-expanded="true"]::before {
        content: '\e260';
    }

    @media (max-width: 768px) {
        #sidebar {
            margin-left: -250px;
        }
        #sidebar.active {
            margin-left: 0;
        }
    }




    body {
        font-family: 'Poppins', sans-serif;
        background: #fafafa;
    }

    p {
        font-family: 'Poppins', sans-serif;
        font-size: 1.1em;
        font-weight: 300;
        line-height: 1.7em;
        color: #999;
    }

    a, a:hover, a:focus {
        color: inherit;
        text-decoration: none;
        transition: all 0.3s;
    }

    #sidebar {
        /* don't forget to add all the previously mentioned styles here too */
        background: #7386D5;
        color: #fff;
        transition: all 0.3s;
    }

    #sidebar .sidebar-header {
        padding: 20px;
        background: #6d7fcc;
    }

    #sidebar ul.components {
        padding: 20px 0;
        border-bottom: 1px solid #47748b;
    }

    #sidebar ul p {
        color: #fff;
        padding: 10px;
    }

    #sidebar ul li a {
        padding: 10px;
        font-size: 1.1em;
        display: block;
        color:whitesmoke;
    }
    #sidebar ul li a:hover {
        color: #7386D5;
        background: #fff;
    }

    #sidebar ul li.active > a, a[aria-expanded="true"] {
        color: #fff;
        background: #6d7fcc;
    }
    ul ul a {
        font-size: 0.9em !important;
        padding-left: 30px !important;
        background: #6d7fcc;
    }
    #erHomePhenotypeTable tr th{
        font-size:small;
        color:#24609c
    }

</style>




<!-- jQuery CDN -->
<script src="https://code.jquery.com/jquery-1.12.0.min.js"></script>
<!-- Bootstrap Js CDN -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
<script>
    $(document).ready(function () {

        $('#sidebarCollapse').on('click', function () {
            $('#sidebar').toggleClass('active');
        });

    });
</script>

<div class="wrapper1">

    <!-- Sidebar -->
    <nav id="sidebar">
        <!-- Sidebar Header -->
        <div class="sidebar-header">
            <h3>Trait Ontology</h3></div>

        <ul class="list-unstyled components">
            <li><a href="home.html">All Traits</a></li>
            <c:forEach items="${model.traitMap}" var="t">
                <li><a href="home.html?trait=${t.value}"><span style="text-transform: capitalize">${t.key}</span></a></li>
            </c:forEach>
            <li><a href="home.html?trait=pga">PGA</a></li>
        </ul>

    </nav>

    <!-- Page Content -->
    <div class="container" style="margin-left:0">
        <!-- We'll fill this with dummy content -->

        <button type="button" id="sidebarCollapse" class="btn btn-info navbar-btn">
            <i class="glyphicon glyphicon-align-left"></i>

        </button>


        <h3>Phenominer Expected Ranges <c:if test="${model.trait!=null}"> - ${model.trait}</c:if></h3>
        <ul class="nav nav-tabs">
            <li class="active"><a href="#phenotypes" role="tab" data-toggle="tab"><strong>Phenotypes with Expected Ranges</strong></a></li>
            <li><a href="#strains" role="tab" data-toggle="tab"><strong>Strains</strong></a></li>
        </ul>
        <div class="tab-content">
            <!----Phenotypes TAB--->
            <div class="tab-pane active" id="phenotypes">
                <table class="table table-striped table-hover expectedRangesTable" >
                    <thead>
                    <tr><th>Subtrait</th><th>Sub-Subtrait</th><th>Phenotype</th><th>Normal Range</th><th>No. of Strains with <br>Expected Ranges</th><th>No. of Strains with <br>Expected Range <br>of Sex Specified Samples</th><th>No. of Strains With <br>Expected Ranges <br>of Age Specified Samples</th></tr>

                    </thead>
                    <tbody>

                    <c:forEach items="${model.counts}" var="item">
                        <tr>
                            <td><span style="text-transform: capitalize">
                                        <c:forEach items="${item.traitAncestors}" var="t">
                                            ${t.subTrait.term}<br>
                                        </c:forEach></span></td>
                            <td><span style="text-transform: capitalize">${item.trait}</span></td>
                            <td><span style="text-transform: capitalize;"><a href="selectedMeasurement.html?cmoId=${item.clinicalMeasurementOntId}&trait=${model.traitOntId}" style="cursor: hand;color:#006dba" title="Click to view measurement data">${item.clinicalMeasurement}</a></span></td>
                            <td>${item.normalRange}</td>
                            <td style="text-align: center">${item.strainSpecifiedRecordCount}</td>
                            <td style="text-align: center">${item.sexSpecifiedRecordCount}</td>
                            <td style="text-align: center">${item.ageSpecifiedRecordCount}</td>
                        </tr>
                    </c:forEach>


                    </tbody>
                </table>


            </div>
            <!----Strains TAB--->
            <div class="tab-pane" id="strains">


                <table class="table expectedRangesTable">
                    <thead>
                    <tr><th>Strain Group</th><th>Phenotypes</th></tr>

                    </thead>
                    <tbody>
                    <c:forEach items="${model.strainObjects}" var="item">
                        <tr><td><a href="strain.html?strainGroupId=${item.strainGroupId}&cmoIds=${item.cmoAccIds}&trait=${model.traitOntId}">${item.strainGroupName}</a></td><td>${fn:length(item.cmoAccIds)}</td></tr>
                    </c:forEach>
                    </tbody>
                </table>

            </div>


        </div>

    </div>
</div>


<%@ include file="/common/footerarea.jsp"%>
