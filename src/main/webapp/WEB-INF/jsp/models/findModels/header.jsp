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
<%
    String term = "";
    if(request.getAttribute("term")!=null){
        term+=(String) request.getAttribute("term");
    }
%>
<div class="">
<form id="models-form" action="findModels.html" method="post">
    <div class="" >

        <div class="container">

            <div class="form-row row">

                <div class="form-group col-md-2">
                    <input type="hidden" id="modelsAspect" value="all">


                </div>
                <div class="form-group col-md-8">
                    <small class="form-text text-muted" style="font-size: 14px">Enter a Disease or Phenotype or Strain or Condition to find the rat models</small>
                    <div class="input-group" >

                        <input id="modelsSearchTerm" name="modelsSearchTerm" class="form-control form-control-lg border-secondary" type="search"  placeholder="Enter Search Term ...." value="<%=term%>"/>

                        <div class="input-group-append">

                            <button class="btn btn-outline-secondary" type="submit" href="findModels.html">
                                <i class="fa fa-search"></i>
                            </button>
                        </div>
                    </div>
                    <small class="form-text text-muted">Examples: <a href="/rgdweb/models/findModels.html?qualifier=&modelsSearchTerm=hypertension" >Hypertension</a>, <a href="/rgdweb/models/findModels.html?qualifier=&modelsSearchTerm=cancer" >Cancer</a>,
                        <a href="/rgdweb/models/findModels.html?qualifier=&modelsSearchTerm=MHS/Gib&models-aspect=MODEL" >MHS/Gib</a>
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
