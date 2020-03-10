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
        <p class="lead" style="color:#2865A3">Find models by disease or phenotype of your intereste</p>
    </div>
    <hr>
    <form id="models-form" action="findModels.html" method="post"   target="_blank">
        <div class="jumbotron">
            <div class="container">

                <div class="form-row row">
                    <div class="form-group col-md-4" id="selOnt0">

                        <select class="form-control form-control-lg" id="models-aspect" name="models-aspect">
                            <option value="all">All</option>
                            <option value="D">Disease</option>
                            <option value="N">Phenotype</option>

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
                        <small class="form-text text-muted">Examples: <a href="/rgdweb/models/findModels.html?qualifier=&models-search-term=hypertension" target="_blank">Hypertension</a>, <a href="/rgdweb/models/findModels.html?qualifier=&models-search-term=cancer" target="_blank">Cancer</a></small>
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
                        <h5 class="card-title" style="font-weight: bold;font-size: 20px;color:#24619c;">About</h5>
                        <p class="card-text" style="color:grey;text-align: justify">The Find Models will help you search strain models specific to the disease or phenotype searched for.</p>
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

                                    <li style="color:grey">RGD Disease Portals</li>
                                    <li style="color:grey">Phenominer </li>
                                    <li style="color:grey">Expected Ranges</li>
                                    <li style="color:grey">GERRC</li>
                                    <li style="color:grey">Genetic Models</li>
                                    <li style="color:grey">Strain Availability</li>
                                    <li style="color:grey">Phenotypes in other animal models</li>

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