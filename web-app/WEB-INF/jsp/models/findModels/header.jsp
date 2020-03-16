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

<div class="jumbotron">
<form id="models-form" action="findModels.html" method="post"   target="_blank">
    <div class="" >

        <div class="container">

            <div class="form-row row">
                <!--div class="form-group col-md-2">
                <span style="color:#24619c;font-size: 20px;text-decoration: none;"><!--img src="/rgdweb/common/images/searchGlass.png" width="50px; height:50px"/>Find Models By: </span>
                <!--/div-->
                <div class="form-group col-md-4">

                    <select class="form-control form-control-lg selectpicker" id="models-aspect" name="models-aspect">
                        <c:if test="${model.aspect==''}">
                        <option class="form-control" value="all" selected>Find by Model/Disease/Phenotype</option>
                            <option  value="D">Find by Disease </option>
                            <option value="N">Find by Phenotype </option>
                            <option value="MODEL">Anotations by Model/Strain</option>
                        </c:if>
                        <c:if test="${model.aspect=='D'}">
                            <option value="all">Find by Model/Disease/Phenotype</option>
                            <option  value="D" selected>Find by Disease </option>
                            <option value="N">Find by Phenotype </option>
                            <option value="MODEL">Find by Model/Strain</option>
                        </c:if>
                        <c:if test="${model.aspect=='N'}">
                            <option  value="all" >Find by Model/Disease/Phenotype</option>
                            <option  value="D">Find by Disease </option>
                            <option  value="N" selected>Find by Phenotype </option>
                            <option value="MODEL">Anotations by Model/Strain</option>
                        </c:if>

                        <c:if test="${model.aspect=='MODEL'}">
                            <option value="all" >Find by Model/Disease/Phenotype</option>
                            <option  value="D">Find by Disease </option>
                            <option  value="N">Find by Phenotype </option>
                            <option value="MODEL" selected>Find by Model/Strain</option>
                        </c:if>
                    </select>

                </div>
                <div class="form-group col-md-8">
                    <div class="input-group" >
                        <input id="models-search-term" name="models-search-term" class="form-control form-control-lg border-secondary" type="search"  placeholder="Enter Search Term ...." value="${model.term}"/>

                        <div class="input-group-append">

                            <button class="btn btn-outline-secondary" type="submit" href="findModels.html">
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
</div>
