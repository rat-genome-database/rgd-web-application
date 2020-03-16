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
        <p><span style="color:#24619c;font-size: 40px;text-decoration: none;"><img src="/rgdweb/common/images/searchGlass.png" width="100px; height:100px"/>Find Models </span> </p>
        <p class="lead" style="color:#2865A3">Find models by disease or phenotype of your interest</p>
    </div>
    <hr>
    <form id="models-form" action="findModels.html" method="post">
        <div class="jumbotron">
            <div class="container">

                <div class="form-row row">
                    <div class="form-group col-md-4">

                        <select class="form-control form-control-lg selectpicker" id="models-aspect" name="models-aspect">
                            <option value="all">Find by Model/Disease/Phenotype</option>
                            <option value="D">Find by Disease</option>
                            <option value="N">Find by Phenotype</option>
                            <option value="MODEL">Find By Model/Strain</option>

                        </select>

                    </div>
                    <div class="form-group col-md-8">
                        <div class="input-group" >
                            <input id="models-search-term" name="models-search-term" class="form-control form-control-lg border-secondary" type="search"  placeholder="Enter Search Term ...." />

                            <div class="input-group-append">

                                <button class="btn btn-outline-secondary" type="submit">
                                    <i class="fa fa-search"></i>
                                </button>
                            </div>
                        </div>
                        <small class="form-text text-muted">Examples: <a href="/rgdweb/models/findModels.html?qualifier=&models-search-term=hypertension" target="_blank">Hypertension</a>, <a href="/rgdweb/models/findModels.html?qualifier=&models-search-term=cancer" target="_blank">Cancer</a>,
                            <a href="/rgdweb/models/findModels.html?qualifier=&models-search-term=MHS/Gib&models-aspect=MODEL" target="_blank">MHS/Gib</a>
                        </small>
                    </div>
                </div>
            </div>
            <div class="form-group col-md-12">
                <table class="table" >
                    <tr id="lastRow">

                    </tr>
                </table>
            </div>



            <!--div class="form-group col-md-12" style="text-align: center" >
                <div class="form-group" style="display: inline-block">
                    <table style="alignment: center">
                        <tr>

                            <td><button class="btn btn-primary" type="submit" onclick="" href="findModels.html">
                                Search
                            </button></td>
                        </tr>
                    </table>
                </div>
            </div-->
        </div>
    </form>

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

                                    <li style="color:grey"><a href="/wg/portals/">RGD Disease Portals</a></li>
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