
<%
    String pageTitle = "GOLF: Gene and Ortholog Location Finder";
    String headContent = "";
    String pageDescription = "Generate an ortholog report for a list of genes.";
%>
<%@ include file="/common/headerarea.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>
<script src="/rgdweb/js/ortholog/orthologVue.js"></script>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">


<%
    String pageHeader="GOLF: Gene and Ortholog Location Finder";
%>
<br>

    <div class="container-fluid" id="ortholog">
        <div class="container" >
            <h2 class="text-center" id="title"><%=pageHeader%></h2>
            <hr>
            <form role="form" method="post" action="/rgdweb/ortholog/report.html">
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
                                <select class="form-control" id="inSpecies" name="inSpecies" v-model="inSpecies" onchange="v.setMaps(inSpecies,'inMaps')">
                                    <option value="3">Rat</option>
                                    <option  value="2">Mouse</option>
                                    <option  value="1">Human</option>
                                    <option  value="4">Chinchilla</option>
                                    <option  value="5">Bonobo</option>
                                    <option  value="6">Dog</option>
                                    <option  value="7">Squirrel</option>
                                    <option value="9">Pig</option>
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
                                <textarea  class="form-control" placeholder="When entering multiple identifiers your list can be separated by commas, spaces, tabs, or line feeds. Example: a2m,xiap,lepr,tnf" id="genes" name="genes" rows="6" cols=35 ></textarea>
                            </div>
                            <p style="color:#24609c; font-weight: bold; font-size: 16px;">(Or)</p>
<p style="color:#24609c; font-weight: bold;">Enter Genomic Position </p>
                                <div class="row">
                                    <div class="form-group">
                                    <div class="col-md-1">
                                        <label for="chr" style="color: #24609c; font-weight: bold;">Chromosome:</label><br>
                                        <select id="chr" name="chr" v-model="chr">
                                            <option v-for="value in chromosomes" :value="value">{{value}}</option>
                                        </select>
                                    </div>
                                        </div>
                                    <div class="form-group">
                                    <div class="col-md-1">
                                        <label for="start" style="color: #24609c; font-weight: bold;">Start:</label><br>
                                        <input id="start" type="text" name="start" />
                                    </div>
                                        </div>
                                        <div class="form-group">
                                    <div class="col-md-1">
                                        <label for="stop" style="color: #24609c; font-weight: bold;">Stop:</label><br>
                                        <input id="stop" type="text" name="stop" />
                                    </div>
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
                                <select class="form-control" id="outSpecies" name="outSpecies"v-model="outSpecies" onchange="v.setMaps(outSpecies,'outMaps')">
                                    <option value="3">Rat</option>
                                    <option  value="2">Mouse</option>
                                    <option  value="1">Human</option>
                                    <option  value="4">Chinchilla</option>
                                    <option  value="5">Bonobo</option>
                                    <option  value="6">Dog</option>
                                    <option  value="7">Squirrel</option>
                                    <option value="9">Pig</option>
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
