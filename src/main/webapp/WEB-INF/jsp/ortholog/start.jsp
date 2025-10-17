<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%
    String pageTitle = "GOLF: Gene and Ortholog Location Finder";
    String headContent = "";
    String pageDescription = "Generate an ortholog report for a list of genes.";

%><%@ include file="/common/headerarea.jsp" %>

<%
    String pageHeader="GOLF: Gene and Ortholog Location Finder";
    HttpRequestFacade req = new HttpRequestFacade(request);
    DisplayMapper dm = new DisplayMapper(req,  new java.util.ArrayList());
%>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://cdn.jsdelivr.net/npm/es6-promise@4/dist/es6-promise.js"></script>
<script src="https://cdn.jsdelivr.net/npm/es6-promise@4/dist/es6-promise.auto.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>
<script src="/rgdweb/js/ortholog/orthologVue.js?9"></script>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">


<br>

    <div class="container-fluid" id="ortholog">
        <div class="container" >
            <h2 class="text-center" id="title"><%=pageHeader%></h2>
            <hr>
            <form role="form" method="post" action="/rgdweb/ortholog/report.html" name="form" onsubmit="return v.validate()">
                <div class="row justify-content-center align-items-center">

                    <div class="col-md-5">
                       <br>
                        <br>
                        <br>
                        <br>
                        <p class="text-uppercase pull-center"> ENTER INPUT DETAILS</p>
                        <fieldset>
                            <br>

                            <div class="form-group">
                                <label for="inSpecies" style="color: #24609c; font-weight: bold;">Select a species:</label><br>
                                <select class="form-control" id="inSpecies" name="inSpecies" v-model="inSpecies" @change="setMaps($event.target.value,'inMaps')" >
                                    <option value="3">Rat</option>
                                    <option value="2">Mouse</option>
                                    <option value="1">Human</option>
                                    <option value="4">Chinchilla</option>
                                    <option value="5">Bonobo</option>
                                    <option value="6">Dog</option>
                                    <option value="7">Squirrel</option>
                                    <option value="9">Pig</option>
                                    <option value="14">Naked Mole-Rat</option>
                                    <option value="13">Green Monkey</option>
                                    <option value="17">Black Rat</option>

                                </select>
                            </div>
                            <div class="form-group">
                                <label for="inMapKey" style="color: #24609c; font-weight: bold;">Assembly:</label><br>
                                <select id="inMapKey" name="inMapKey" v-model="inMapKey">
                                    <option v-for="value in inMaps" :value="value.key">{{value.name}}</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="genes" style="color: #24609c; font-weight: bold;">Enter Gene Symbols:</label><br>
                                <textarea  class="form-control" placeholder="When entering multiple identifiers your list can be separated by commas, spaces, tabs, or line feeds. Example: a2m,xiap,lepr,tnf" id="genes" name="genes" rows="6" cols=35 >
                                </textarea>
                            </div>
                            <p style="color:#24609c; font-weight: bold; font-size: 16px;">(Or)</p>
<p style="color:#24609c; font-weight: bold;">Enter Genomic Position </p>
                            <div class="row justify-content-right align-items-right">

                                    <div class="form-group">
<table>
    <tr><td>
                                        <label for="chr" style="color: #24609c; font-weight: bold;">Chromosome:</label>
                                        <select id="chr" name="chr" v-model="chr">
                                            <option v-for="value in chromosomes" :value="value">{{value}}</option>
                                        </select>
    </td><td>
                                        <label for="start" style="color: #24609c; font-weight: bold;">Start:</label>
                                        <input id="start" type="text" name="start" />
    </td><td>
                                        <label for="stop" style="color: #24609c; font-weight: bold;">Stop:</label>
                                        <input id="stop" type="text" name="stop"/>
    </td>  </tr>
</table>
</div>

                                </div>

                        </fieldset>
                    </div>

                    <div class="col-md-2">
                        <!-------null------>
                    </div>


                    <div class="col-md-5">
                        <p class="text-uppercase pull-center"> ENTER OUTPUT DETAILS</p>
                        <fieldset>
                            <br>

                            <div class="form-group">
                                <label for="outSpecies" style="color: #24609c; font-weight: bold;">Select a species:</label><br>
                                <select class="form-control" id="outSpecies" name="outSpecies" v-model="outSpecies" @change="setMaps($event.target.value,'outMaps')" >
                                    <option value="3">Rat</option>
                                    <option value="2">Mouse</option>
                                    <option value="1">Human</option>
                                    <option value="4">Chinchilla</option>
                                    <option value="5">Bonobo</option>
                                    <option value="6">Dog</option>
                                    <option value="7">Squirrel</option>
                                    <option value="9">Pig</option>
                                    <option value="14">Naked Mole-Rat</option>
                                    <option value="13">Green Monkey</option>
                                    <option value="17">Black Rat</option>

                                </select>
                            </div>
                            <div class="form-group">
                                <label for="outMapKey" style="color: #24609c; font-weight: bold;">Assembly:</label><br>
                                <select id="outMapKey" name="outMapKey" v-model="outMapKey">
                                    <option v-for="value in outMaps" :value="value.key">{{value.name}}</option>
                                </select>
                            </div>
                        </fieldset>
                    </div>
                </div>
                <br>
                <input type="submit" name="submit" class="btn btn-info btn-md" value="submit">
            </form>
        </div>
    </div>

<script>
    var v= new OrthologVue("ortholog");
    v.inSpecies = <%=request.getParameter("species")%>;
    v.setMaps(<%=request.getParameter("species")%>,'inMaps');
    v.setMaps(1, 'outMaps');

</script>

 <%@ include file="/common/footerarea.jsp" %>
