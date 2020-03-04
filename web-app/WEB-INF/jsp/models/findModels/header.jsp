<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%  String pageTitle =  "Find Models";
    String pageDescription ="Find Models";
    String headContent = "";%>

<%@ include file="/common/headerarea.jsp"%>
<div class="jumbotron">
<form id="models-form" action="findModels.html" method="post"   target="_blank">
    <div class="" >

        <div class="container">

            <div class="form-row row">
                <!--div class="form-group col-md-2">
                <span style="color:#24619c;font-size: 20px;text-decoration: none;"><!--img src="/rgdweb/common/images/searchGlass.png" width="50px; height:50px"/>Find Models By: </span>
                <!--/div-->
                <div class="form-group col-md-4">

                    <select class="form-control form-control-lg" id="models-aspect" name="models-aspect">
                        <c:if test="${model.aspect==''}">
                        <option class="form-control" value="all" selected>All Models</option>
                            <option class="form-control" value="D">Models by Disease </option>
                            <option class="form-control" value="N">Models by Phenotype</option>
                        </c:if>
                        <c:if test="${model.aspect=='D'}">
                            <option class="form-control" value="all" selected>All Models</option>
                            <option class="form-control" value="D" selected>Models by Disease </option>
                            <option class="form-control" value="N">Models by Phenotype</option>
                        </c:if>
                        <c:if test="${model.aspect=='N'}">
                            <option class="form-control" value="all" selected>All Models</option>
                            <option class="form-control" value="D">Models by Disease </option>
                            <option class="form-control" value="N" selected>Models by Phenotype</option>
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
                    <small class="form-text text-muted">Examples: <a href="" target="_blank">Hypertension</a>, <a href="" target="_blank">Cancer</a></small>
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
