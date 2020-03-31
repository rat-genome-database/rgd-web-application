<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .jumbotron{
        /*	background:linear-gradient(to bottom, white 0%, #D6EAF8 100%); */
        background:linear-gradient(to bottom, white 0%, #D6EAF8 100%);
        background-color: #D1F2EB;
    }
</style>
<style>
    .ui-autocomplete {
        height: 200px; overflow-y: scroll; overflow-x: hidden;box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);}
</style>
<script>

    $(function () {

        $("#modelsSearchTerm").autocomplete({

            delay:500,
            source: function(request, response) {
                var aspect=$("#modelsAspect").val();
                $.ajax({
                    url:"/rgdweb/models/autocomplete.html",
                    type: "POST",
                    data: {term: request.term,
                    aspect: aspect},
                    max: 100,
                    dataType: "json",
                    success: function(data) {

                        response(data);
                    }
                });
            }

        });
    })
</script>

<div class="jumbotron">
<form id="models-form" action="findModels.html" method="post"   target="_blank">
    <div class="" >

        <div class="container">

            <div class="form-row row">

                <div class="form-group col-md-4">

                    <select class="form-control form-control-lg selectpicker" id="modelsAspect" name="modelsAspect">
                        <c:if test="${model.aspect==null || model.aspect==''}">
                        <option class="form-control" value="all" selected>Find By Model/Disease/Phenotype</option>
                            <option  value="D">Find by Disease </option>
                            <option value="N">Find by Phenotype </option>
                            <option value="MODEL">Find By Model/Strain</option>
                        </c:if>
                        <c:if test="${model.aspect=='D'}">
                            <option value="all">Find By Model/Disease/Phenotype</option>
                            <option  value="D" selected>Find by Disease </option>
                            <option value="N">Find by Phenotype </option>
                            <option value="MODEL">Find By Model/Strain</option>
                        </c:if>
                        <c:if test="${model.aspect=='N'}">
                            <option  value="all" >Find By Model/Disease/Phenotype</option>
                            <option  value="D">Find by Disease </option>
                            <option  value="N" selected>Find by Phenotype </option>
                            <option value="MODEL">Find By Model/Strain</option>
                        </c:if>

                        <c:if test="${model.aspect=='MODEL'}">
                            <option value="all" >Find By Model/Disease/Phenotype</option>
                            <option  value="D">Find by Disease </option>
                            <option  value="N">Find by Phenotype </option>
                            <option value="MODEL" selected>Find By Model/Strain</option>
                        </c:if>
                    </select>

                </div>
                <div class="form-group col-md-8">
                    <div class="input-group" >
                        <input id="modelsSearchTerm" name="modelsSearchTerm" class="form-control form-control-lg border-secondary" type="search"  placeholder="Enter Search Term ...." value="${model.term}"/>

                        <div class="input-group-append">

                            <button class="btn btn-outline-secondary" type="submit" href="findModels.html">
                                <i class="fa fa-search"></i>
                            </button>
                        </div>
                    </div>
                    <small class="form-text text-muted">Examples: <a href="/rgdweb/models/findModels.html?qualifier=&modelsSearchTerm=hypertension" target="_blank">Hypertension</a>, <a href="/rgdweb/models/findModels.html?qualifier=&modelsSearchTerm=cancer" target="_blank">Cancer</a>,
                        <a href="/rgdweb/models/findModels.html?qualifier=&modelsSearchTerm=MHS/Gib&models-aspect=MODEL" target="_blank">MHS/Gib</a>
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
