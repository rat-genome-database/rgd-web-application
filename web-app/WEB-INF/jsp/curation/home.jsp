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

<table border="0" width="100%" >
    <tbody>
    <tr>
<h1 > Welcome {{name}} !!!</h1>
        <hr />
        <a href="https://dev.rgd.mcw.edu/rgdweb/curation/logout.html">Logout</a>

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
                    <a href="/rgdCuration/?module=curation&func=contents&token=<%=request.getParameter("accessToken")%>">Curation Tool</a></td>
            </tr>
            <tr valign="top">
                <td>
                    <a :href="/rgdweb/curation/edit/editObject.html?token=<%=request.getParameter("accessToken")%>&login={{name}}">Object Editor</a></td>
            </tr>
            <tr valign="top">
                <td>
                    <a :href="/rgdweb/curation/nomen/nomenSearch.html?token=<%=request.getParameter("accessToken")%>&login={{name}}">Nomenclature Search</a></td>
            </tr>
            <tr>
                <td>
                    <a href="/rgdCuration/?module=objectNomen&func=selectObjects&token=<%=request.getParameter("accessToken")%>">Merge/Retire/Split Objects</a>
                </td>
            </tr>
            <tr>
                <td>
                    <a href="/rgdCuration/?module=notesEdit&func=selectObjects&token=<%=request.getParameter("accessToken")%>">Notes Editor</a>
                </td>
            </tr>
            <tr>
                <td>
                    <a href="/rgdCuration/?module=ont&func=obsoleteTerms&token=<%=request.getParameter("accessToken")%>">Obsolete Terms</a>
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
                    <a href="/rgdweb/curation/phenominer/home.html?token=<%=request.getParameter("accessToken")%>&login={{name}}">Phenominer</a></td>
            </tr>
            <tr valign="top">
                <td>
                    <a href="/rgdweb/curation/edit/submittedStrains/editStrains.html?token=<%=request.getParameter("accessToken")%>&login={{name}}">Submitted Strains</a></td>
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
            userloggedin:""
        },
        methods: {
          getUser: function(){
              axios
                      .get('https://api.github.com/user',
                              {
                                  headers: {
                                      'Authorization': 'Token ' + '<%=request.getParameter("accessToken")%>'
                                  }
                              })
                      .then(function (response) {
                          v.name = response.data.login;
                          v.getRepos(v.name);
                      });
          },
          getRepos: function(name){
              axios
                      .get('https://api.github.com/orgs/rat-genome-database/members/'+name,
                              {
                                  headers: {
                                      'Authorization': 'Token ' + '<%=request.getParameter("accessToken")%>'
                                  }
                              })
                      .then(function (response) {
                          v.userloggedin = response.status;
                      });
          }
        },
        mounted: function(){
            this.getUser();
        }

    });



</script>