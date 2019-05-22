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
<table border="0" width="100%" >
    <tbody>
    <tr>
<h1> Welcome {{name}} !!!</h1>
        <hr />

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
                    <a href="/curation/">Curation Web</a></td>
            </tr>
            <tr valign="top">
                <td>
                    <a href="/rgdCuration/">NEW Curation Tools</a></td>
            </tr>
            <tr valign="top">
                <td>
                    <a href="/rgdweb/curation/edit/editObject.html">Object Edit</a></td>
            </tr>
            <tr valign="top">
                <td>
                    <a href="/rgdweb/curation/nomen/nomenSearch.html">Nomenclature</a></td>
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
                    <a href="/rgdweb/curation/phenominer/home.html">Phenominer</a></td>
            </tr>
            <tr valign="top">
                <td>
                    <a href="/rgdweb/curation/edit/submittedStrains/editStrains.html">Submitted Strains</a></td>
            </tr>
            <tr valign="top">
                <td>
                    <a href="/rgdweb/curation/pipeline/list.html">Pipeline Logs</a></td>
            </tr>
            <tr valign="top">
                <td>
                    <a href="journals.shtml">Journal List and Links</a></td>
            </tr>
            <tr valign="top">
                <td>
                    <a href="retrieve.shtml">Import new reference from PubMed</a></td>
            </tr>
            </tbody>
        </table>

    </tr>
    </tbody>
</table>
</div>
<script>
    var v = new Vue({
        el: 'curation',
        data: {
            accessToken:"",
            name:""
        },
        methods: {
            getToken: function (){
                var requestToken = '<%=request.getParameter("code")%>';
                axios
                        .post('https://github.com/login/oauth/access_token?client_id=7de10c5ae2c3e3825007&client_secret=0bf648f790ad12f2be1d54dcb0a9f57972289fd0&code='+requestToken)
                        .then(function (response) {
                            v.accessToken = response.data.access_token;
                            v.getDetails();
                        });
            },

            getDetails: function(){
                axios
                        .post('https://api.github.com/user',
                                {
                                    headers: {
                                        Authorization: 'token ' + v.accessToken
                                    }
                                })
                        .then(function (response) {
                            v.name = response.data.name;
                        });
            }
        }
    });

    v.getToken();

</script>