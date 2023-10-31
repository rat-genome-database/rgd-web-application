<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<%
    String pageTitle = "Curation Home Page";
    String headContent = "";
    String pageDescription = "";

%>
<%@ include file="/common/headerarea.jsp" %>

<div id="curation">
    <section v-if="userloggedin == 204">

<h1 > Welcome {{name}} !!!</h1>
<% if (request.getRequestURL().toString().startsWith("https://pipelines")) { %>
Current Server: <span style="color:green; font-size:18px;">PIPELINES</span>&nbsp;&nbsp;&nbsp;&nbsp; <a v-bind:href="'https://dev.rgd.mcw.edu/rgdweb/curation/home.html?accessToken='+token">Access DEVELOPMENT site</a>
<% } %>

<% if (request.getRequestURL().toString().startsWith("https://dev")) { %>
Current Server: <span style="color:red; font-size:18px;">DEV</span>
<% } %>

<% if (request.getRequestURL().toString().startsWith("http://localhost")) { %>
Current Server: <span style="color:purple; font-size:18px;">LOCALHOST</span>&nbsp;&nbsp;&nbsp;&nbsp;<a v-bind:href="'https://dev.rgd.mcw.edu/rgdweb/curation/home.html?accessToken='+token">Access DEVELOPMENT site</a>
<% } %>


<hr />


<table border="0" width="100%" >
    <tbody>
    <tr>

        <table border="0" width="100%" cellpadding="4">
            <tbody>

            <tr valign="top">
                <td colspan="2" bgcolor="#006699"><b><span style="color: #ffffff;"> Curation Links </span></b></td>
            </tr>
            <tr>
                <td></td>
            </tr>
            <tr>
                <td></td>
            </tr>
            <tr valign="top">
                <td>
                    <a v-bind:href="'/rgdCuration/?module=curation&func=contents&token='+token">Curation Tool</a></td>
            </tr>
            <tr valign="top">
                <td>
                    <a v-bind:href="'/rgdweb/curation/edit/editObject.html?token='+token+'&login='+name">Object Editor</a></td>
            </tr>
            <tr valign="top">
                <td>
                    <a v-bind:href="'/rgdweb/curation/nomen/nomenSearch.html?token='+token+'&login='+name">Nomenclature Search</a></td>
            </tr>
            <tr>
                <td>
                    <a v-bind:href="'/rgdCuration/?module=objectNomen&func=selectObjects&token='+token">Merge/Retire/Split Objects</a>
                </td>
            </tr>
            <tr>
                <td>
                    <a v-bind:href="'/rgdCuration/?module=notesEdit&func=selectObjects&token='+token">Notes Editor</a>
                </td>
            </tr>
            <tr>
                <td>
                    <a v-bind:href="'/rgdCuration/?module=ont&func=obsoleteTerms&token='+token">Obsolete Terms</a>
                </td>
            </tr>
			    <td>
                    <a v-bind:href="'/rgdweb/curation/strainFileUpload.html?token='+token">Strain Files Upload</a></td>
            </tr>
            <tr>
                <td>
                    <a v-bind:href="'/rgdweb/curation/edit/editNews.html?token='+token+'&login='+name">Create News or Conference</a>
                </td>
            </tr>
            <tr>
                <td>
                    <a v-bind:href="'/rgdweb/curation/expression/experiments.html?token='+token+'&login='+name">Edit GEO Expressions</a>
                </td>
            </tr>
            <tr>
                <td>
                    <a v-bind:href="'/rgdweb/curation/expression/editSamples.html?token='+token+'&login='+name">Edit Phenominer Sample by ID</a>
                </td>
            </tr>
            <tr>
                <td>
                    <a v-bind:href="'/rgdweb/curation/geneBinning/index.html?accessToken='+token">Gene Binning</a>
                </td>
            </tr>
            <tr valign="top">
                <td colspan="2"></td>
            </tr>
            <tr valign="top">
                <td></td>
            </tr>


            <tr valign="top">
                <td colspan="2"></td>
            </tr>
            <tr valign="top">
                <td></td>
            </tr>
            <tr valign="top">
                <td colspan="2" bgcolor="#006699"><b><span style="color: #ffffff;"> Other Tools </span></b></td>
            </tr>
            <tr>
                <td></td>
            </tr>
            <tr>
                <td></td>
            </tr>
            <tr valign="top">
                <td>
                    <a href="/rgdweb/score/board.jsp">Score Board</a></td>
            </tr>
            <tr valign="top">
                <td>
                    <a href="/rgdweb/seqretrieve/retrieve.html">Ref Sequence</a></td>
            </tr>
            <tr valign="top">
                <td>
                    <a v-bind:href="'/rgdweb/curation/phenominer/home.html?token='+token+'&login='+name">Phenominer</a></td>
            </tr>
            <tr valign="top">
                <td>
                    <a v-bind:href="'/rgdweb/curation/edit/submittedStrains/editStrains.html?token='+token+'&login='+name">Submitted Strains</a></td>
            </tr>
            <tr valign="top">
                <td>
                    <a href="journals.shtml">Journal List and Links</a></td>
            </tr>
            </tbody>
        </table>

    </tr>
    </tbody>
</table>
</section>

</div>
<script>
    var v = new Vue({
        el: '#curation',
        data: {
            name:"",
            userloggedin:"",
            token:""
        },
        mounted: function(){
            getUser();
        }

    });

    function getUser(){

        /* $.get('https://api.github.com/user',
                 {
                     headers: {
                         'Authorization': 'Token ' + '<%=request.getParameter("accessToken")%>'
                    }
                })
            .then(function (response) {
                v.name = response.data.login;
                v.getRepos(v.name);
                v.token = "<%=request.getParameter("accessToken")%>";
            });*/
        $.ajax({
            url: 'https://api.github.com/user',
            beforeSend: function(xhr) {
                xhr.setRequestHeader("Authorization", 'Token ' + '<%=request.getParameter("accessToken")%>')
            }
        }).then(function (response) {
            v.name = response.login;
            v.token = "<%=request.getParameter("accessToken")%>";
            getRepos(v.name);
            // console.log("V.NAME:"+ v.name)
        })
    }
    function getRepos(name){
        /*   axios
               $.get('https://api.github.com/orgs/rat-genome-database/members/'+name,
                   {
                       headers: {
                           'Authorization': 'Token ' + '<%=request.getParameter("accessToken")%>'
                    }
                })
            .then(function (response) {
                v.userloggedin = response.status;
            });*/
        $.ajax({
            url: 'https://api.github.com/orgs/rat-genome-database/members/'+name,
            beforeSend: function(xhr) {
                xhr.setRequestHeader("Authorization", 'Token ' + v.token)
            },
            method:"GET",
            statusCode: {
                204: function() {
                    v.userloggedin=204
                }
            }
        })
    }
</script>