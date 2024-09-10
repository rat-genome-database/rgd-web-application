<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%  String pageTitle =  "Find Models";
    String pageDescription ="Find Models";
    String headContent = "";%>
<%@ include file="/common/headerarea.jsp"%>
<style>
    .jumbotron{
        /*	background:linear-gradient(to bottom, white 0%, #D6EAF8 100%); */
        background:linear-gradient(to bottom, white 0%, #D6EAF8 100%);
        background-color: #D1F2EB;
    }
</style>
<div class="container-fluid">
    <div style="text-align: center">
        <p><span style="color:#24619c;font-size: 40px;text-decoration: none;"><img src="/rgdweb/common/images/searchGlass.png" width="100px; height:100px"/>Find Rat Models </span> </p>
        <p class="lead" style="color:#2865A3">Find models of a disease or phenotype of your interest</p>
    </div>
    <hr>
    <div class="jumbotron">
    <%@include file="findModels/header.jsp"%>
    </div>
    <div class="container">
        <div class="row">
            <div class="col-md-4">
                <div class="card" style="width: 25rem;border:0">

                    <div class="card-body">
                        <h5 class="card-title" style="font-weight: bold;font-size: 20px;color:#24619c;">The Find Models will ...</h5>
                        <p class="card-text" style="color:grey;text-align: justify"> Help you search strain models specific to a disease or phenotype that is searched for.Also help you search model annotations.</p>
                        <!--a href="#" class="btn btn-primary">Go somewhere</a-->
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card" style="width: 25rem;border:0">

                    <div class="card-body">
                        <h5 class="card-title" style="font-weight: bold;font-size: 20px;color:#24619c;">Other Portals & Tools</h5>
                        <p class="card-text" style="color:grey"></p>


                                <ul>

                                    <li style="color:grey"><a href="/rgdweb/portal/index.jsp">RGD Disease Portals</a></li>
                                    <li style="color:grey"><a href="/rgdweb/phenominer/home.jsp">Phenominer</a> </li>
                                    <li style="color:grey"><a href="/rgdweb/phenominer/phenominerExpectedRanges/views/home.html">Expected Ranges</a></li>
                                    <li style="color:grey"><a href="/wg/gerrc/">GERRC</a></li>
                                    <li style="color:grey"><a href="/rgdweb/models/allModels.html">Genetic Models</a></li>
                                    <li style="color:grey"><a href="/wg/strain-availability/">Strain Availability</a></li>
                                    <li style="color:grey"><a href="/wg/physiology/additionalmodels/">Phenotypes in other animal models</a></li>

                                </ul>


                        <!--a href="#" class="btn btn-primary">Go somewhere</a-->
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card" style="width: 25rem;border:0">

                    <div class="card-body" >
                        <h5 class="card-title" style="font-weight: bold;font-size: 20px;color:#24619c">Links & Resources</h5>
                        <p class="card-text" style="color:grey">

                            <a href="/nomen/nomen.shtml#StrainNomenclature" class="list-group-item">Strain Nomenclature</a>
                            <a href="/tools/strains/strainRegistrationIndex.cgi" class="list-group-item">Strain Submission/Registration</a>
                        </p>

                    </div>
                </div>
            </div>

        </div>
    </div>
</div>



<%@ include file="/common/footerarea.jsp"%>